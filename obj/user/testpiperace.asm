
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 bc 01 00 00       	call   8001ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 20 26 80 00       	push   $0x802620
  800040:	e8 04 03 00 00       	call   800349 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 a1 1f 00 00       	call   801ff1 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 39 26 80 00       	push   $0x802639
  80005d:	6a 0d                	push   $0xd
  80005f:	68 42 26 80 00       	push   $0x802642
  800064:	e8 07 02 00 00       	call   800270 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 8a 0f 00 00       	call   800ff8 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 56 26 80 00       	push   $0x802656
  80007a:	6a 10                	push   $0x10
  80007c:	68 42 26 80 00       	push   $0x802642
  800081:	e8 ea 01 00 00       	call   800270 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 ce 16 00 00       	call   801763 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 9c 20 00 00       	call   802144 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 5f 26 80 00       	push   $0x80265f
  8000b7:	e8 8d 02 00 00       	call   800349 <cprintf>
				exit();
  8000bc:	e8 95 01 00 00       	call   800256 <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 e9 0b 00 00       	call   800cb2 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 c2 13 00 00       	call   80149e <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 7a 26 80 00       	push   $0x80267a
  8000e8:	e8 5c 02 00 00       	call   800349 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	69 c6 d8 00 00 00    	imul   $0xd8,%esi,%eax
  8000fc:	c1 f8 03             	sar    $0x3,%eax
  8000ff:	69 c0 13 da 4b 68    	imul   $0x684bda13,%eax,%eax
  800105:	50                   	push   %eax
  800106:	68 85 26 80 00       	push   $0x802685
  80010b:	e8 39 02 00 00       	call   800349 <cprintf>
	dup(p[0], 10);
  800110:	83 c4 08             	add    $0x8,%esp
  800113:	6a 0a                	push   $0xa
  800115:	ff 75 f0             	pushl  -0x10(%ebp)
  800118:	e8 96 16 00 00       	call   8017b3 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	69 de d8 00 00 00    	imul   $0xd8,%esi,%ebx
  800126:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80012c:	eb 10                	jmp    80013e <umain+0x10b>
		dup(p[0], 10);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	6a 0a                	push   $0xa
  800133:	ff 75 f0             	pushl  -0x10(%ebp)
  800136:	e8 78 16 00 00       	call   8017b3 <dup>
  80013b:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  80013e:	8b 93 b0 00 00 00    	mov    0xb0(%ebx),%edx
  800144:	83 fa 02             	cmp    $0x2,%edx
  800147:	74 e5                	je     80012e <umain+0xfb>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 90 26 80 00       	push   $0x802690
  800151:	e8 f3 01 00 00       	call   800349 <cprintf>
	if (pipeisclosed(p[0]))
  800156:	83 c4 04             	add    $0x4,%esp
  800159:	ff 75 f0             	pushl  -0x10(%ebp)
  80015c:	e8 e3 1f 00 00       	call   802144 <pipeisclosed>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	74 14                	je     80017c <umain+0x149>
		panic("somehow the other end of p[0] got closed!");
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	68 ec 26 80 00       	push   $0x8026ec
  800170:	6a 3a                	push   $0x3a
  800172:	68 42 26 80 00       	push   $0x802642
  800177:	e8 f4 00 00 00       	call   800270 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017c:	83 ec 08             	sub    $0x8,%esp
  80017f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	ff 75 f0             	pushl  -0x10(%ebp)
  800186:	e8 ab 14 00 00       	call   801636 <fd_lookup>
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 12                	jns    8001a4 <umain+0x171>
		panic("cannot look up p[0]: %e", r);
  800192:	50                   	push   %eax
  800193:	68 a6 26 80 00       	push   $0x8026a6
  800198:	6a 3c                	push   $0x3c
  80019a:	68 42 26 80 00       	push   $0x802642
  80019f:	e8 cc 00 00 00       	call   800270 <_panic>
	va = fd2data(fd);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001aa:	e8 21 14 00 00       	call   8015d0 <fd2data>
	if (pageref(va) != 3+1)
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 20 1c 00 00       	call   801dd7 <pageref>
  8001b7:	83 c4 10             	add    $0x10,%esp
  8001ba:	83 f8 04             	cmp    $0x4,%eax
  8001bd:	74 12                	je     8001d1 <umain+0x19e>
		cprintf("\nchild detected race\n");
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	68 be 26 80 00       	push   $0x8026be
  8001c7:	e8 7d 01 00 00       	call   800349 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	eb 15                	jmp    8001e6 <umain+0x1b3>
	else
		cprintf("\nrace didn't happen\n", max);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	68 c8 00 00 00       	push   $0xc8
  8001d9:	68 d4 26 80 00       	push   $0x8026d4
  8001de:	e8 66 01 00 00       	call   800349 <cprintf>
  8001e3:	83 c4 10             	add    $0x10,%esp
}
  8001e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001f8:	e8 96 0a 00 00       	call   800c93 <sys_getenvid>
  8001fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800202:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020d:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800212:	85 db                	test   %ebx,%ebx
  800214:	7e 07                	jle    80021d <libmain+0x30>
		binaryname = argv[0];
  800216:	8b 06                	mov    (%esi),%eax
  800218:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	e8 0c fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800227:	e8 2a 00 00 00       	call   800256 <exit>
}
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80023c:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800241:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800243:	e8 4b 0a 00 00       	call   800c93 <sys_getenvid>
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	e8 91 0c 00 00       	call   800ee2 <sys_thread_free>
}
  800251:	83 c4 10             	add    $0x10,%esp
  800254:	c9                   	leave  
  800255:	c3                   	ret    

00800256 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80025c:	e8 2d 15 00 00       	call   80178e <close_all>
	sys_env_destroy(0);
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	6a 00                	push   $0x0
  800266:	e8 e7 09 00 00       	call   800c52 <sys_env_destroy>
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800275:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800278:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80027e:	e8 10 0a 00 00       	call   800c93 <sys_getenvid>
  800283:	83 ec 0c             	sub    $0xc,%esp
  800286:	ff 75 0c             	pushl  0xc(%ebp)
  800289:	ff 75 08             	pushl  0x8(%ebp)
  80028c:	56                   	push   %esi
  80028d:	50                   	push   %eax
  80028e:	68 20 27 80 00       	push   $0x802720
  800293:	e8 b1 00 00 00       	call   800349 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800298:	83 c4 18             	add    $0x18,%esp
  80029b:	53                   	push   %ebx
  80029c:	ff 75 10             	pushl  0x10(%ebp)
  80029f:	e8 54 00 00 00       	call   8002f8 <vcprintf>
	cprintf("\n");
  8002a4:	c7 04 24 06 2b 80 00 	movl   $0x802b06,(%esp)
  8002ab:	e8 99 00 00 00       	call   800349 <cprintf>
  8002b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002b3:	cc                   	int3   
  8002b4:	eb fd                	jmp    8002b3 <_panic+0x43>

008002b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 04             	sub    $0x4,%esp
  8002bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002c0:	8b 13                	mov    (%ebx),%edx
  8002c2:	8d 42 01             	lea    0x1(%edx),%eax
  8002c5:	89 03                	mov    %eax,(%ebx)
  8002c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002d3:	75 1a                	jne    8002ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	68 ff 00 00 00       	push   $0xff
  8002dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e0:	50                   	push   %eax
  8002e1:	e8 2f 09 00 00       	call   800c15 <sys_cputs>
		b->idx = 0;
  8002e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800301:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800308:	00 00 00 
	b.cnt = 0;
  80030b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800312:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800321:	50                   	push   %eax
  800322:	68 b6 02 80 00       	push   $0x8002b6
  800327:	e8 54 01 00 00       	call   800480 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80032c:	83 c4 08             	add    $0x8,%esp
  80032f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800335:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80033b:	50                   	push   %eax
  80033c:	e8 d4 08 00 00       	call   800c15 <sys_cputs>

	return b.cnt;
}
  800341:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800347:	c9                   	leave  
  800348:	c3                   	ret    

00800349 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800352:	50                   	push   %eax
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 9d ff ff ff       	call   8002f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 1c             	sub    $0x1c,%esp
  800366:	89 c7                	mov    %eax,%edi
  800368:	89 d6                	mov    %edx,%esi
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800370:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800373:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800376:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800379:	bb 00 00 00 00       	mov    $0x0,%ebx
  80037e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800381:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800384:	39 d3                	cmp    %edx,%ebx
  800386:	72 05                	jb     80038d <printnum+0x30>
  800388:	39 45 10             	cmp    %eax,0x10(%ebp)
  80038b:	77 45                	ja     8003d2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	ff 75 18             	pushl  0x18(%ebp)
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800399:	53                   	push   %ebx
  80039a:	ff 75 10             	pushl  0x10(%ebp)
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ac:	e8 df 1f 00 00       	call   802390 <__udivdi3>
  8003b1:	83 c4 18             	add    $0x18,%esp
  8003b4:	52                   	push   %edx
  8003b5:	50                   	push   %eax
  8003b6:	89 f2                	mov    %esi,%edx
  8003b8:	89 f8                	mov    %edi,%eax
  8003ba:	e8 9e ff ff ff       	call   80035d <printnum>
  8003bf:	83 c4 20             	add    $0x20,%esp
  8003c2:	eb 18                	jmp    8003dc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	56                   	push   %esi
  8003c8:	ff 75 18             	pushl  0x18(%ebp)
  8003cb:	ff d7                	call   *%edi
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	eb 03                	jmp    8003d5 <printnum+0x78>
  8003d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d5:	83 eb 01             	sub    $0x1,%ebx
  8003d8:	85 db                	test   %ebx,%ebx
  8003da:	7f e8                	jg     8003c4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003dc:	83 ec 08             	sub    $0x8,%esp
  8003df:	56                   	push   %esi
  8003e0:	83 ec 04             	sub    $0x4,%esp
  8003e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ef:	e8 cc 20 00 00       	call   8024c0 <__umoddi3>
  8003f4:	83 c4 14             	add    $0x14,%esp
  8003f7:	0f be 80 43 27 80 00 	movsbl 0x802743(%eax),%eax
  8003fe:	50                   	push   %eax
  8003ff:	ff d7                	call   *%edi
}
  800401:	83 c4 10             	add    $0x10,%esp
  800404:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800407:	5b                   	pop    %ebx
  800408:	5e                   	pop    %esi
  800409:	5f                   	pop    %edi
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80040f:	83 fa 01             	cmp    $0x1,%edx
  800412:	7e 0e                	jle    800422 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800414:	8b 10                	mov    (%eax),%edx
  800416:	8d 4a 08             	lea    0x8(%edx),%ecx
  800419:	89 08                	mov    %ecx,(%eax)
  80041b:	8b 02                	mov    (%edx),%eax
  80041d:	8b 52 04             	mov    0x4(%edx),%edx
  800420:	eb 22                	jmp    800444 <getuint+0x38>
	else if (lflag)
  800422:	85 d2                	test   %edx,%edx
  800424:	74 10                	je     800436 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800426:	8b 10                	mov    (%eax),%edx
  800428:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042b:	89 08                	mov    %ecx,(%eax)
  80042d:	8b 02                	mov    (%edx),%eax
  80042f:	ba 00 00 00 00       	mov    $0x0,%edx
  800434:	eb 0e                	jmp    800444 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800436:	8b 10                	mov    (%eax),%edx
  800438:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043b:	89 08                	mov    %ecx,(%eax)
  80043d:	8b 02                	mov    (%edx),%eax
  80043f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800450:	8b 10                	mov    (%eax),%edx
  800452:	3b 50 04             	cmp    0x4(%eax),%edx
  800455:	73 0a                	jae    800461 <sprintputch+0x1b>
		*b->buf++ = ch;
  800457:	8d 4a 01             	lea    0x1(%edx),%ecx
  80045a:	89 08                	mov    %ecx,(%eax)
  80045c:	8b 45 08             	mov    0x8(%ebp),%eax
  80045f:	88 02                	mov    %al,(%edx)
}
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800469:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046c:	50                   	push   %eax
  80046d:	ff 75 10             	pushl  0x10(%ebp)
  800470:	ff 75 0c             	pushl  0xc(%ebp)
  800473:	ff 75 08             	pushl  0x8(%ebp)
  800476:	e8 05 00 00 00       	call   800480 <vprintfmt>
	va_end(ap);
}
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	57                   	push   %edi
  800484:	56                   	push   %esi
  800485:	53                   	push   %ebx
  800486:	83 ec 2c             	sub    $0x2c,%esp
  800489:	8b 75 08             	mov    0x8(%ebp),%esi
  80048c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80048f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800492:	eb 12                	jmp    8004a6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800494:	85 c0                	test   %eax,%eax
  800496:	0f 84 89 03 00 00    	je     800825 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	53                   	push   %ebx
  8004a0:	50                   	push   %eax
  8004a1:	ff d6                	call   *%esi
  8004a3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a6:	83 c7 01             	add    $0x1,%edi
  8004a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ad:	83 f8 25             	cmp    $0x25,%eax
  8004b0:	75 e2                	jne    800494 <vprintfmt+0x14>
  8004b2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004b6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d0:	eb 07                	jmp    8004d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8d 47 01             	lea    0x1(%edi),%eax
  8004dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004df:	0f b6 07             	movzbl (%edi),%eax
  8004e2:	0f b6 c8             	movzbl %al,%ecx
  8004e5:	83 e8 23             	sub    $0x23,%eax
  8004e8:	3c 55                	cmp    $0x55,%al
  8004ea:	0f 87 1a 03 00 00    	ja     80080a <vprintfmt+0x38a>
  8004f0:	0f b6 c0             	movzbl %al,%eax
  8004f3:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004fd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800501:	eb d6                	jmp    8004d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800506:	b8 00 00 00 00       	mov    $0x0,%eax
  80050b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800511:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800515:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800518:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80051b:	83 fa 09             	cmp    $0x9,%edx
  80051e:	77 39                	ja     800559 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800520:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800523:	eb e9                	jmp    80050e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 48 04             	lea    0x4(%eax),%ecx
  80052b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800536:	eb 27                	jmp    80055f <vprintfmt+0xdf>
  800538:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053b:	85 c0                	test   %eax,%eax
  80053d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800542:	0f 49 c8             	cmovns %eax,%ecx
  800545:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054b:	eb 8c                	jmp    8004d9 <vprintfmt+0x59>
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800550:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800557:	eb 80                	jmp    8004d9 <vprintfmt+0x59>
  800559:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80055c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80055f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800563:	0f 89 70 ff ff ff    	jns    8004d9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800569:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80056c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800576:	e9 5e ff ff ff       	jmp    8004d9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80057b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800581:	e9 53 ff ff ff       	jmp    8004d9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	ff 30                	pushl  (%eax)
  800595:	ff d6                	call   *%esi
			break;
  800597:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80059d:	e9 04 ff ff ff       	jmp    8004a6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	99                   	cltd   
  8005ae:	31 d0                	xor    %edx,%eax
  8005b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b2:	83 f8 0f             	cmp    $0xf,%eax
  8005b5:	7f 0b                	jg     8005c2 <vprintfmt+0x142>
  8005b7:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	75 18                	jne    8005da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005c2:	50                   	push   %eax
  8005c3:	68 5b 27 80 00       	push   $0x80275b
  8005c8:	53                   	push   %ebx
  8005c9:	56                   	push   %esi
  8005ca:	e8 94 fe ff ff       	call   800463 <printfmt>
  8005cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d5:	e9 cc fe ff ff       	jmp    8004a6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005da:	52                   	push   %edx
  8005db:	68 89 2c 80 00       	push   $0x802c89
  8005e0:	53                   	push   %ebx
  8005e1:	56                   	push   %esi
  8005e2:	e8 7c fe ff ff       	call   800463 <printfmt>
  8005e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	e9 b4 fe ff ff       	jmp    8004a6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005fd:	85 ff                	test   %edi,%edi
  8005ff:	b8 54 27 80 00       	mov    $0x802754,%eax
  800604:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800607:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060b:	0f 8e 94 00 00 00    	jle    8006a5 <vprintfmt+0x225>
  800611:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800615:	0f 84 98 00 00 00    	je     8006b3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	ff 75 d0             	pushl  -0x30(%ebp)
  800621:	57                   	push   %edi
  800622:	e8 86 02 00 00       	call   8008ad <strnlen>
  800627:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80062a:	29 c1                	sub    %eax,%ecx
  80062c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80062f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800632:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800636:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800639:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80063c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063e:	eb 0f                	jmp    80064f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	ff 75 e0             	pushl  -0x20(%ebp)
  800647:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800649:	83 ef 01             	sub    $0x1,%edi
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	85 ff                	test   %edi,%edi
  800651:	7f ed                	jg     800640 <vprintfmt+0x1c0>
  800653:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800656:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800659:	85 c9                	test   %ecx,%ecx
  80065b:	b8 00 00 00 00       	mov    $0x0,%eax
  800660:	0f 49 c1             	cmovns %ecx,%eax
  800663:	29 c1                	sub    %eax,%ecx
  800665:	89 75 08             	mov    %esi,0x8(%ebp)
  800668:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066e:	89 cb                	mov    %ecx,%ebx
  800670:	eb 4d                	jmp    8006bf <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800672:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800676:	74 1b                	je     800693 <vprintfmt+0x213>
  800678:	0f be c0             	movsbl %al,%eax
  80067b:	83 e8 20             	sub    $0x20,%eax
  80067e:	83 f8 5e             	cmp    $0x5e,%eax
  800681:	76 10                	jbe    800693 <vprintfmt+0x213>
					putch('?', putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	ff 75 0c             	pushl  0xc(%ebp)
  800689:	6a 3f                	push   $0x3f
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb 0d                	jmp    8006a0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff 55 08             	call   *0x8(%ebp)
  80069d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a0:	83 eb 01             	sub    $0x1,%ebx
  8006a3:	eb 1a                	jmp    8006bf <vprintfmt+0x23f>
  8006a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b1:	eb 0c                	jmp    8006bf <vprintfmt+0x23f>
  8006b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006bf:	83 c7 01             	add    $0x1,%edi
  8006c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c6:	0f be d0             	movsbl %al,%edx
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	74 23                	je     8006f0 <vprintfmt+0x270>
  8006cd:	85 f6                	test   %esi,%esi
  8006cf:	78 a1                	js     800672 <vprintfmt+0x1f2>
  8006d1:	83 ee 01             	sub    $0x1,%esi
  8006d4:	79 9c                	jns    800672 <vprintfmt+0x1f2>
  8006d6:	89 df                	mov    %ebx,%edi
  8006d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006de:	eb 18                	jmp    8006f8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	6a 20                	push   $0x20
  8006e6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e8:	83 ef 01             	sub    $0x1,%edi
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	eb 08                	jmp    8006f8 <vprintfmt+0x278>
  8006f0:	89 df                	mov    %ebx,%edi
  8006f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f8:	85 ff                	test   %edi,%edi
  8006fa:	7f e4                	jg     8006e0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ff:	e9 a2 fd ff ff       	jmp    8004a6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800704:	83 fa 01             	cmp    $0x1,%edx
  800707:	7e 16                	jle    80071f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8d 50 08             	lea    0x8(%eax),%edx
  80070f:	89 55 14             	mov    %edx,0x14(%ebp)
  800712:	8b 50 04             	mov    0x4(%eax),%edx
  800715:	8b 00                	mov    (%eax),%eax
  800717:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80071d:	eb 32                	jmp    800751 <vprintfmt+0x2d1>
	else if (lflag)
  80071f:	85 d2                	test   %edx,%edx
  800721:	74 18                	je     80073b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8d 50 04             	lea    0x4(%eax),%edx
  800729:	89 55 14             	mov    %edx,0x14(%ebp)
  80072c:	8b 00                	mov    (%eax),%eax
  80072e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800731:	89 c1                	mov    %eax,%ecx
  800733:	c1 f9 1f             	sar    $0x1f,%ecx
  800736:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800739:	eb 16                	jmp    800751 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 04             	lea    0x4(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)
  800744:	8b 00                	mov    (%eax),%eax
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 c1                	mov    %eax,%ecx
  80074b:	c1 f9 1f             	sar    $0x1f,%ecx
  80074e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800751:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800754:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800757:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80075c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800760:	79 74                	jns    8007d6 <vprintfmt+0x356>
				putch('-', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 2d                	push   $0x2d
  800768:	ff d6                	call   *%esi
				num = -(long long) num;
  80076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80076d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800770:	f7 d8                	neg    %eax
  800772:	83 d2 00             	adc    $0x0,%edx
  800775:	f7 da                	neg    %edx
  800777:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80077a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80077f:	eb 55                	jmp    8007d6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800781:	8d 45 14             	lea    0x14(%ebp),%eax
  800784:	e8 83 fc ff ff       	call   80040c <getuint>
			base = 10;
  800789:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80078e:	eb 46                	jmp    8007d6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	e8 74 fc ff ff       	call   80040c <getuint>
			base = 8;
  800798:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80079d:	eb 37                	jmp    8007d6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 30                	push   $0x30
  8007a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a7:	83 c4 08             	add    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	6a 78                	push   $0x78
  8007ad:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b8:	8b 00                	mov    (%eax),%eax
  8007ba:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007bf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007c7:	eb 0d                	jmp    8007d6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cc:	e8 3b fc ff ff       	call   80040c <getuint>
			base = 16;
  8007d1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d6:	83 ec 0c             	sub    $0xc,%esp
  8007d9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007dd:	57                   	push   %edi
  8007de:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e1:	51                   	push   %ecx
  8007e2:	52                   	push   %edx
  8007e3:	50                   	push   %eax
  8007e4:	89 da                	mov    %ebx,%edx
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	e8 70 fb ff ff       	call   80035d <printnum>
			break;
  8007ed:	83 c4 20             	add    $0x20,%esp
  8007f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f3:	e9 ae fc ff ff       	jmp    8004a6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f8:	83 ec 08             	sub    $0x8,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	51                   	push   %ecx
  8007fd:	ff d6                	call   *%esi
			break;
  8007ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800802:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800805:	e9 9c fc ff ff       	jmp    8004a6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	53                   	push   %ebx
  80080e:	6a 25                	push   $0x25
  800810:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	eb 03                	jmp    80081a <vprintfmt+0x39a>
  800817:	83 ef 01             	sub    $0x1,%edi
  80081a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80081e:	75 f7                	jne    800817 <vprintfmt+0x397>
  800820:	e9 81 fc ff ff       	jmp    8004a6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800825:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5f                   	pop    %edi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	83 ec 18             	sub    $0x18,%esp
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800839:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80083c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800840:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800843:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084a:	85 c0                	test   %eax,%eax
  80084c:	74 26                	je     800874 <vsnprintf+0x47>
  80084e:	85 d2                	test   %edx,%edx
  800850:	7e 22                	jle    800874 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800852:	ff 75 14             	pushl  0x14(%ebp)
  800855:	ff 75 10             	pushl  0x10(%ebp)
  800858:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80085b:	50                   	push   %eax
  80085c:	68 46 04 80 00       	push   $0x800446
  800861:	e8 1a fc ff ff       	call   800480 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800866:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800869:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	eb 05                	jmp    800879 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 9a ff ff ff       	call   80082d <vsnprintf>
	va_end(ap);

	return rc;
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a0:	eb 03                	jmp    8008a5 <strlen+0x10>
		n++;
  8008a2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a9:	75 f7                	jne    8008a2 <strlen+0xd>
		n++;
	return n;
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8008bb:	eb 03                	jmp    8008c0 <strnlen+0x13>
		n++;
  8008bd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c0:	39 c2                	cmp    %eax,%edx
  8008c2:	74 08                	je     8008cc <strnlen+0x1f>
  8008c4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008c8:	75 f3                	jne    8008bd <strnlen+0x10>
  8008ca:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	53                   	push   %ebx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	83 c2 01             	add    $0x1,%edx
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	75 ef                	jne    8008da <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008eb:	5b                   	pop    %ebx
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	53                   	push   %ebx
  8008f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f5:	53                   	push   %ebx
  8008f6:	e8 9a ff ff ff       	call   800895 <strlen>
  8008fb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	01 d8                	add    %ebx,%eax
  800903:	50                   	push   %eax
  800904:	e8 c5 ff ff ff       	call   8008ce <strcpy>
	return dst;
}
  800909:	89 d8                	mov    %ebx,%eax
  80090b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 75 08             	mov    0x8(%ebp),%esi
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	89 f3                	mov    %esi,%ebx
  80091d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800920:	89 f2                	mov    %esi,%edx
  800922:	eb 0f                	jmp    800933 <strncpy+0x23>
		*dst++ = *src;
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	0f b6 01             	movzbl (%ecx),%eax
  80092a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092d:	80 39 01             	cmpb   $0x1,(%ecx)
  800930:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800933:	39 da                	cmp    %ebx,%edx
  800935:	75 ed                	jne    800924 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800937:	89 f0                	mov    %esi,%eax
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 75 08             	mov    0x8(%ebp),%esi
  800945:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800948:	8b 55 10             	mov    0x10(%ebp),%edx
  80094b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094d:	85 d2                	test   %edx,%edx
  80094f:	74 21                	je     800972 <strlcpy+0x35>
  800951:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800955:	89 f2                	mov    %esi,%edx
  800957:	eb 09                	jmp    800962 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	83 c1 01             	add    $0x1,%ecx
  80095f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800962:	39 c2                	cmp    %eax,%edx
  800964:	74 09                	je     80096f <strlcpy+0x32>
  800966:	0f b6 19             	movzbl (%ecx),%ebx
  800969:	84 db                	test   %bl,%bl
  80096b:	75 ec                	jne    800959 <strlcpy+0x1c>
  80096d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80096f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800972:	29 f0                	sub    %esi,%eax
}
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800981:	eb 06                	jmp    800989 <strcmp+0x11>
		p++, q++;
  800983:	83 c1 01             	add    $0x1,%ecx
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800989:	0f b6 01             	movzbl (%ecx),%eax
  80098c:	84 c0                	test   %al,%al
  80098e:	74 04                	je     800994 <strcmp+0x1c>
  800990:	3a 02                	cmp    (%edx),%al
  800992:	74 ef                	je     800983 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800994:	0f b6 c0             	movzbl %al,%eax
  800997:	0f b6 12             	movzbl (%edx),%edx
  80099a:	29 d0                	sub    %edx,%eax
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a8:	89 c3                	mov    %eax,%ebx
  8009aa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ad:	eb 06                	jmp    8009b5 <strncmp+0x17>
		n--, p++, q++;
  8009af:	83 c0 01             	add    $0x1,%eax
  8009b2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b5:	39 d8                	cmp    %ebx,%eax
  8009b7:	74 15                	je     8009ce <strncmp+0x30>
  8009b9:	0f b6 08             	movzbl (%eax),%ecx
  8009bc:	84 c9                	test   %cl,%cl
  8009be:	74 04                	je     8009c4 <strncmp+0x26>
  8009c0:	3a 0a                	cmp    (%edx),%cl
  8009c2:	74 eb                	je     8009af <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c4:	0f b6 00             	movzbl (%eax),%eax
  8009c7:	0f b6 12             	movzbl (%edx),%edx
  8009ca:	29 d0                	sub    %edx,%eax
  8009cc:	eb 05                	jmp    8009d3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e0:	eb 07                	jmp    8009e9 <strchr+0x13>
		if (*s == c)
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	74 0f                	je     8009f5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	0f b6 10             	movzbl (%eax),%edx
  8009ec:	84 d2                	test   %dl,%dl
  8009ee:	75 f2                	jne    8009e2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a01:	eb 03                	jmp    800a06 <strfind+0xf>
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a09:	38 ca                	cmp    %cl,%dl
  800a0b:	74 04                	je     800a11 <strfind+0x1a>
  800a0d:	84 d2                	test   %dl,%dl
  800a0f:	75 f2                	jne    800a03 <strfind+0xc>
			break;
	return (char *) s;
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a1f:	85 c9                	test   %ecx,%ecx
  800a21:	74 36                	je     800a59 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a23:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a29:	75 28                	jne    800a53 <memset+0x40>
  800a2b:	f6 c1 03             	test   $0x3,%cl
  800a2e:	75 23                	jne    800a53 <memset+0x40>
		c &= 0xFF;
  800a30:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a34:	89 d3                	mov    %edx,%ebx
  800a36:	c1 e3 08             	shl    $0x8,%ebx
  800a39:	89 d6                	mov    %edx,%esi
  800a3b:	c1 e6 18             	shl    $0x18,%esi
  800a3e:	89 d0                	mov    %edx,%eax
  800a40:	c1 e0 10             	shl    $0x10,%eax
  800a43:	09 f0                	or     %esi,%eax
  800a45:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a47:	89 d8                	mov    %ebx,%eax
  800a49:	09 d0                	or     %edx,%eax
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
  800a4e:	fc                   	cld    
  800a4f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a51:	eb 06                	jmp    800a59 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	fc                   	cld    
  800a57:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a59:	89 f8                	mov    %edi,%eax
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6e:	39 c6                	cmp    %eax,%esi
  800a70:	73 35                	jae    800aa7 <memmove+0x47>
  800a72:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	73 2e                	jae    800aa7 <memmove+0x47>
		s += n;
		d += n;
  800a79:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	89 d6                	mov    %edx,%esi
  800a7e:	09 fe                	or     %edi,%esi
  800a80:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a86:	75 13                	jne    800a9b <memmove+0x3b>
  800a88:	f6 c1 03             	test   $0x3,%cl
  800a8b:	75 0e                	jne    800a9b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a8d:	83 ef 04             	sub    $0x4,%edi
  800a90:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a93:	c1 e9 02             	shr    $0x2,%ecx
  800a96:	fd                   	std    
  800a97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a99:	eb 09                	jmp    800aa4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9b:	83 ef 01             	sub    $0x1,%edi
  800a9e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aa1:	fd                   	std    
  800aa2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa4:	fc                   	cld    
  800aa5:	eb 1d                	jmp    800ac4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa7:	89 f2                	mov    %esi,%edx
  800aa9:	09 c2                	or     %eax,%edx
  800aab:	f6 c2 03             	test   $0x3,%dl
  800aae:	75 0f                	jne    800abf <memmove+0x5f>
  800ab0:	f6 c1 03             	test   $0x3,%cl
  800ab3:	75 0a                	jne    800abf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ab5:	c1 e9 02             	shr    $0x2,%ecx
  800ab8:	89 c7                	mov    %eax,%edi
  800aba:	fc                   	cld    
  800abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abd:	eb 05                	jmp    800ac4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abf:	89 c7                	mov    %eax,%edi
  800ac1:	fc                   	cld    
  800ac2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800acb:	ff 75 10             	pushl  0x10(%ebp)
  800ace:	ff 75 0c             	pushl  0xc(%ebp)
  800ad1:	ff 75 08             	pushl  0x8(%ebp)
  800ad4:	e8 87 ff ff ff       	call   800a60 <memmove>
}
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae6:	89 c6                	mov    %eax,%esi
  800ae8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aeb:	eb 1a                	jmp    800b07 <memcmp+0x2c>
		if (*s1 != *s2)
  800aed:	0f b6 08             	movzbl (%eax),%ecx
  800af0:	0f b6 1a             	movzbl (%edx),%ebx
  800af3:	38 d9                	cmp    %bl,%cl
  800af5:	74 0a                	je     800b01 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800af7:	0f b6 c1             	movzbl %cl,%eax
  800afa:	0f b6 db             	movzbl %bl,%ebx
  800afd:	29 d8                	sub    %ebx,%eax
  800aff:	eb 0f                	jmp    800b10 <memcmp+0x35>
		s1++, s2++;
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b07:	39 f0                	cmp    %esi,%eax
  800b09:	75 e2                	jne    800aed <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	53                   	push   %ebx
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b1b:	89 c1                	mov    %eax,%ecx
  800b1d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b20:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b24:	eb 0a                	jmp    800b30 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	0f b6 10             	movzbl (%eax),%edx
  800b29:	39 da                	cmp    %ebx,%edx
  800b2b:	74 07                	je     800b34 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b2d:	83 c0 01             	add    $0x1,%eax
  800b30:	39 c8                	cmp    %ecx,%eax
  800b32:	72 f2                	jb     800b26 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b34:	5b                   	pop    %ebx
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b43:	eb 03                	jmp    800b48 <strtol+0x11>
		s++;
  800b45:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b48:	0f b6 01             	movzbl (%ecx),%eax
  800b4b:	3c 20                	cmp    $0x20,%al
  800b4d:	74 f6                	je     800b45 <strtol+0xe>
  800b4f:	3c 09                	cmp    $0x9,%al
  800b51:	74 f2                	je     800b45 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b53:	3c 2b                	cmp    $0x2b,%al
  800b55:	75 0a                	jne    800b61 <strtol+0x2a>
		s++;
  800b57:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5f:	eb 11                	jmp    800b72 <strtol+0x3b>
  800b61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b66:	3c 2d                	cmp    $0x2d,%al
  800b68:	75 08                	jne    800b72 <strtol+0x3b>
		s++, neg = 1;
  800b6a:	83 c1 01             	add    $0x1,%ecx
  800b6d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b78:	75 15                	jne    800b8f <strtol+0x58>
  800b7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7d:	75 10                	jne    800b8f <strtol+0x58>
  800b7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b83:	75 7c                	jne    800c01 <strtol+0xca>
		s += 2, base = 16;
  800b85:	83 c1 02             	add    $0x2,%ecx
  800b88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b8d:	eb 16                	jmp    800ba5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b8f:	85 db                	test   %ebx,%ebx
  800b91:	75 12                	jne    800ba5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b93:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b98:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9b:	75 08                	jne    800ba5 <strtol+0x6e>
		s++, base = 8;
  800b9d:	83 c1 01             	add    $0x1,%ecx
  800ba0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bad:	0f b6 11             	movzbl (%ecx),%edx
  800bb0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb3:	89 f3                	mov    %esi,%ebx
  800bb5:	80 fb 09             	cmp    $0x9,%bl
  800bb8:	77 08                	ja     800bc2 <strtol+0x8b>
			dig = *s - '0';
  800bba:	0f be d2             	movsbl %dl,%edx
  800bbd:	83 ea 30             	sub    $0x30,%edx
  800bc0:	eb 22                	jmp    800be4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bc2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc5:	89 f3                	mov    %esi,%ebx
  800bc7:	80 fb 19             	cmp    $0x19,%bl
  800bca:	77 08                	ja     800bd4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bcc:	0f be d2             	movsbl %dl,%edx
  800bcf:	83 ea 57             	sub    $0x57,%edx
  800bd2:	eb 10                	jmp    800be4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bd4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bd7:	89 f3                	mov    %esi,%ebx
  800bd9:	80 fb 19             	cmp    $0x19,%bl
  800bdc:	77 16                	ja     800bf4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bde:	0f be d2             	movsbl %dl,%edx
  800be1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800be4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be7:	7d 0b                	jge    800bf4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800be9:	83 c1 01             	add    $0x1,%ecx
  800bec:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bf0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bf2:	eb b9                	jmp    800bad <strtol+0x76>

	if (endptr)
  800bf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf8:	74 0d                	je     800c07 <strtol+0xd0>
		*endptr = (char *) s;
  800bfa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfd:	89 0e                	mov    %ecx,(%esi)
  800bff:	eb 06                	jmp    800c07 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c01:	85 db                	test   %ebx,%ebx
  800c03:	74 98                	je     800b9d <strtol+0x66>
  800c05:	eb 9e                	jmp    800ba5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c07:	89 c2                	mov    %eax,%edx
  800c09:	f7 da                	neg    %edx
  800c0b:	85 ff                	test   %edi,%edi
  800c0d:	0f 45 c2             	cmovne %edx,%eax
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	89 c7                	mov    %eax,%edi
  800c2a:	89 c6                	mov    %eax,%esi
  800c2c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c43:	89 d1                	mov    %edx,%ecx
  800c45:	89 d3                	mov    %edx,%ebx
  800c47:	89 d7                	mov    %edx,%edi
  800c49:	89 d6                	mov    %edx,%esi
  800c4b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c60:	b8 03 00 00 00       	mov    $0x3,%eax
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 cb                	mov    %ecx,%ebx
  800c6a:	89 cf                	mov    %ecx,%edi
  800c6c:	89 ce                	mov    %ecx,%esi
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 03                	push   $0x3
  800c7a:	68 3f 2a 80 00       	push   $0x802a3f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 5c 2a 80 00       	push   $0x802a5c
  800c86:	e8 e5 f5 ff ff       	call   800270 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800c9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	89 d3                	mov    %edx,%ebx
  800ca7:	89 d7                	mov    %edx,%edi
  800ca9:	89 d6                	mov    %edx,%esi
  800cab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_yield>:

void
sys_yield(void)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc2:	89 d1                	mov    %edx,%ecx
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	89 d7                	mov    %edx,%edi
  800cc8:	89 d6                	mov    %edx,%esi
  800cca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	be 00 00 00 00       	mov    $0x0,%esi
  800cdf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ced:	89 f7                	mov    %esi,%edi
  800cef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 17                	jle    800d0c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 04                	push   $0x4
  800cfb:	68 3f 2a 80 00       	push   $0x802a3f
  800d00:	6a 23                	push   $0x23
  800d02:	68 5c 2a 80 00       	push   $0x802a5c
  800d07:	e8 64 f5 ff ff       	call   800270 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 17                	jle    800d4e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	50                   	push   %eax
  800d3b:	6a 05                	push   $0x5
  800d3d:	68 3f 2a 80 00       	push   $0x802a3f
  800d42:	6a 23                	push   $0x23
  800d44:	68 5c 2a 80 00       	push   $0x802a5c
  800d49:	e8 22 f5 ff ff       	call   800270 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d64:	b8 06 00 00 00       	mov    $0x6,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	89 df                	mov    %ebx,%edi
  800d71:	89 de                	mov    %ebx,%esi
  800d73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7e 17                	jle    800d90 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	50                   	push   %eax
  800d7d:	6a 06                	push   $0x6
  800d7f:	68 3f 2a 80 00       	push   $0x802a3f
  800d84:	6a 23                	push   $0x23
  800d86:	68 5c 2a 80 00       	push   $0x802a5c
  800d8b:	e8 e0 f4 ff ff       	call   800270 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da6:	b8 08 00 00 00       	mov    $0x8,%eax
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	89 df                	mov    %ebx,%edi
  800db3:	89 de                	mov    %ebx,%esi
  800db5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db7:	85 c0                	test   %eax,%eax
  800db9:	7e 17                	jle    800dd2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	50                   	push   %eax
  800dbf:	6a 08                	push   $0x8
  800dc1:	68 3f 2a 80 00       	push   $0x802a3f
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 5c 2a 80 00       	push   $0x802a5c
  800dcd:	e8 9e f4 ff ff       	call   800270 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 17                	jle    800e14 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	50                   	push   %eax
  800e01:	6a 09                	push   $0x9
  800e03:	68 3f 2a 80 00       	push   $0x802a3f
  800e08:	6a 23                	push   $0x23
  800e0a:	68 5c 2a 80 00       	push   $0x802a5c
  800e0f:	e8 5c f4 ff ff       	call   800270 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	89 df                	mov    %ebx,%edi
  800e37:	89 de                	mov    %ebx,%esi
  800e39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	7e 17                	jle    800e56 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	50                   	push   %eax
  800e43:	6a 0a                	push   $0xa
  800e45:	68 3f 2a 80 00       	push   $0x802a3f
  800e4a:	6a 23                	push   $0x23
  800e4c:	68 5c 2a 80 00       	push   $0x802a5c
  800e51:	e8 1a f4 ff ff       	call   800270 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e64:	be 00 00 00 00       	mov    $0x0,%esi
  800e69:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	89 cb                	mov    %ecx,%ebx
  800e99:	89 cf                	mov    %ecx,%edi
  800e9b:	89 ce                	mov    %ecx,%esi
  800e9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	7e 17                	jle    800eba <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	50                   	push   %eax
  800ea7:	6a 0d                	push   $0xd
  800ea9:	68 3f 2a 80 00       	push   $0x802a3f
  800eae:	6a 23                	push   $0x23
  800eb0:	68 5c 2a 80 00       	push   $0x802a5c
  800eb5:	e8 b6 f3 ff ff       	call   800270 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ed2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed5:	89 cb                	mov    %ecx,%ebx
  800ed7:	89 cf                	mov    %ecx,%edi
  800ed9:	89 ce                	mov    %ecx,%esi
  800edb:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eed:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 cb                	mov    %ecx,%ebx
  800ef7:	89 cf                	mov    %ecx,%edi
  800ef9:	89 ce                	mov    %ecx,%esi
  800efb:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0d:	b8 10 00 00 00       	mov    $0x10,%eax
  800f12:	8b 55 08             	mov    0x8(%ebp),%edx
  800f15:	89 cb                	mov    %ecx,%ebx
  800f17:	89 cf                	mov    %ecx,%edi
  800f19:	89 ce                	mov    %ecx,%esi
  800f1b:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	53                   	push   %ebx
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f2c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f2e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f32:	74 11                	je     800f45 <pgfault+0x23>
  800f34:	89 d8                	mov    %ebx,%eax
  800f36:	c1 e8 0c             	shr    $0xc,%eax
  800f39:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f40:	f6 c4 08             	test   $0x8,%ah
  800f43:	75 14                	jne    800f59 <pgfault+0x37>
		panic("faulting access");
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	68 6a 2a 80 00       	push   $0x802a6a
  800f4d:	6a 1f                	push   $0x1f
  800f4f:	68 7a 2a 80 00       	push   $0x802a7a
  800f54:	e8 17 f3 ff ff       	call   800270 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	6a 07                	push   $0x7
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	6a 00                	push   $0x0
  800f65:	e8 67 fd ff ff       	call   800cd1 <sys_page_alloc>
	if (r < 0) {
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	79 12                	jns    800f83 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f71:	50                   	push   %eax
  800f72:	68 85 2a 80 00       	push   $0x802a85
  800f77:	6a 2d                	push   $0x2d
  800f79:	68 7a 2a 80 00       	push   $0x802a7a
  800f7e:	e8 ed f2 ff ff       	call   800270 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f83:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f89:	83 ec 04             	sub    $0x4,%esp
  800f8c:	68 00 10 00 00       	push   $0x1000
  800f91:	53                   	push   %ebx
  800f92:	68 00 f0 7f 00       	push   $0x7ff000
  800f97:	e8 2c fb ff ff       	call   800ac8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f9c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fa3:	53                   	push   %ebx
  800fa4:	6a 00                	push   $0x0
  800fa6:	68 00 f0 7f 00       	push   $0x7ff000
  800fab:	6a 00                	push   $0x0
  800fad:	e8 62 fd ff ff       	call   800d14 <sys_page_map>
	if (r < 0) {
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 12                	jns    800fcb <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800fb9:	50                   	push   %eax
  800fba:	68 85 2a 80 00       	push   $0x802a85
  800fbf:	6a 34                	push   $0x34
  800fc1:	68 7a 2a 80 00       	push   $0x802a7a
  800fc6:	e8 a5 f2 ff ff       	call   800270 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800fcb:	83 ec 08             	sub    $0x8,%esp
  800fce:	68 00 f0 7f 00       	push   $0x7ff000
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 7c fd ff ff       	call   800d56 <sys_page_unmap>
	if (r < 0) {
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	79 12                	jns    800ff3 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fe1:	50                   	push   %eax
  800fe2:	68 85 2a 80 00       	push   $0x802a85
  800fe7:	6a 38                	push   $0x38
  800fe9:	68 7a 2a 80 00       	push   $0x802a7a
  800fee:	e8 7d f2 ff ff       	call   800270 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801001:	68 22 0f 80 00       	push   $0x800f22
  801006:	e8 ef 12 00 00       	call   8022fa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80100b:	b8 07 00 00 00       	mov    $0x7,%eax
  801010:	cd 30                	int    $0x30
  801012:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 17                	jns    801033 <fork+0x3b>
		panic("fork fault %e");
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 9e 2a 80 00       	push   $0x802a9e
  801024:	68 85 00 00 00       	push   $0x85
  801029:	68 7a 2a 80 00       	push   $0x802a7a
  80102e:	e8 3d f2 ff ff       	call   800270 <_panic>
  801033:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801035:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801039:	75 24                	jne    80105f <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80103b:	e8 53 fc ff ff       	call   800c93 <sys_getenvid>
  801040:	25 ff 03 00 00       	and    $0x3ff,%eax
  801045:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80104b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801050:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801055:	b8 00 00 00 00       	mov    $0x0,%eax
  80105a:	e9 64 01 00 00       	jmp    8011c3 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80105f:	83 ec 04             	sub    $0x4,%esp
  801062:	6a 07                	push   $0x7
  801064:	68 00 f0 bf ee       	push   $0xeebff000
  801069:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106c:	e8 60 fc ff ff       	call   800cd1 <sys_page_alloc>
  801071:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801074:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801079:	89 d8                	mov    %ebx,%eax
  80107b:	c1 e8 16             	shr    $0x16,%eax
  80107e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801085:	a8 01                	test   $0x1,%al
  801087:	0f 84 fc 00 00 00    	je     801189 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80108d:	89 d8                	mov    %ebx,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
  801092:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801099:	f6 c2 01             	test   $0x1,%dl
  80109c:	0f 84 e7 00 00 00    	je     801189 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8010a2:	89 c6                	mov    %eax,%esi
  8010a4:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8010a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ae:	f6 c6 04             	test   $0x4,%dh
  8010b1:	74 39                	je     8010ec <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c2:	50                   	push   %eax
  8010c3:	56                   	push   %esi
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	6a 00                	push   $0x0
  8010c8:	e8 47 fc ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  8010cd:	83 c4 20             	add    $0x20,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	0f 89 b1 00 00 00    	jns    801189 <fork+0x191>
		    	panic("sys page map fault %e");
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	68 ac 2a 80 00       	push   $0x802aac
  8010e0:	6a 55                	push   $0x55
  8010e2:	68 7a 2a 80 00       	push   $0x802a7a
  8010e7:	e8 84 f1 ff ff       	call   800270 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f3:	f6 c2 02             	test   $0x2,%dl
  8010f6:	75 0c                	jne    801104 <fork+0x10c>
  8010f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ff:	f6 c4 08             	test   $0x8,%ah
  801102:	74 5b                	je     80115f <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	68 05 08 00 00       	push   $0x805
  80110c:	56                   	push   %esi
  80110d:	57                   	push   %edi
  80110e:	56                   	push   %esi
  80110f:	6a 00                	push   $0x0
  801111:	e8 fe fb ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  801116:	83 c4 20             	add    $0x20,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	79 14                	jns    801131 <fork+0x139>
		    	panic("sys page map fault %e");
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	68 ac 2a 80 00       	push   $0x802aac
  801125:	6a 5c                	push   $0x5c
  801127:	68 7a 2a 80 00       	push   $0x802a7a
  80112c:	e8 3f f1 ff ff       	call   800270 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	68 05 08 00 00       	push   $0x805
  801139:	56                   	push   %esi
  80113a:	6a 00                	push   $0x0
  80113c:	56                   	push   %esi
  80113d:	6a 00                	push   $0x0
  80113f:	e8 d0 fb ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  801144:	83 c4 20             	add    $0x20,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	79 3e                	jns    801189 <fork+0x191>
		    	panic("sys page map fault %e");
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	68 ac 2a 80 00       	push   $0x802aac
  801153:	6a 60                	push   $0x60
  801155:	68 7a 2a 80 00       	push   $0x802a7a
  80115a:	e8 11 f1 ff ff       	call   800270 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	6a 05                	push   $0x5
  801164:	56                   	push   %esi
  801165:	57                   	push   %edi
  801166:	56                   	push   %esi
  801167:	6a 00                	push   $0x0
  801169:	e8 a6 fb ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  80116e:	83 c4 20             	add    $0x20,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	79 14                	jns    801189 <fork+0x191>
		    	panic("sys page map fault %e");
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	68 ac 2a 80 00       	push   $0x802aac
  80117d:	6a 65                	push   $0x65
  80117f:	68 7a 2a 80 00       	push   $0x802a7a
  801184:	e8 e7 f0 ff ff       	call   800270 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801189:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80118f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801195:	0f 85 de fe ff ff    	jne    801079 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80119b:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a0:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	50                   	push   %eax
  8011aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011ad:	57                   	push   %edi
  8011ae:	e8 69 fc ff ff       	call   800e1c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011b3:	83 c4 08             	add    $0x8,%esp
  8011b6:	6a 02                	push   $0x2
  8011b8:	57                   	push   %edi
  8011b9:	e8 da fb ff ff       	call   800d98 <sys_env_set_status>
	
	return envid;
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c6:	5b                   	pop    %ebx
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <sfork>:

envid_t
sfork(void)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8011dd:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	53                   	push   %ebx
  8011e7:	68 3c 2b 80 00       	push   $0x802b3c
  8011ec:	e8 58 f1 ff ff       	call   800349 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011f1:	c7 04 24 36 02 80 00 	movl   $0x800236,(%esp)
  8011f8:	e8 c5 fc ff ff       	call   800ec2 <sys_thread_create>
  8011fd:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011ff:	83 c4 08             	add    $0x8,%esp
  801202:	53                   	push   %ebx
  801203:	68 3c 2b 80 00       	push   $0x802b3c
  801208:	e8 3c f1 ff ff       	call   800349 <cprintf>
	return id;
}
  80120d:	89 f0                	mov    %esi,%eax
  80120f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801212:	5b                   	pop    %ebx
  801213:	5e                   	pop    %esi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80121c:	ff 75 08             	pushl  0x8(%ebp)
  80121f:	e8 be fc ff ff       	call   800ee2 <sys_thread_free>
}
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80122f:	ff 75 08             	pushl  0x8(%ebp)
  801232:	e8 cb fc ff ff       	call   800f02 <sys_thread_join>
}
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	8b 75 08             	mov    0x8(%ebp),%esi
  801244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801247:	83 ec 04             	sub    $0x4,%esp
  80124a:	6a 07                	push   $0x7
  80124c:	6a 00                	push   $0x0
  80124e:	56                   	push   %esi
  80124f:	e8 7d fa ff ff       	call   800cd1 <sys_page_alloc>
	if (r < 0) {
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	79 15                	jns    801270 <queue_append+0x34>
		panic("%e\n", r);
  80125b:	50                   	push   %eax
  80125c:	68 38 2b 80 00       	push   $0x802b38
  801261:	68 c4 00 00 00       	push   $0xc4
  801266:	68 7a 2a 80 00       	push   $0x802a7a
  80126b:	e8 00 f0 ff ff       	call   800270 <_panic>
	}	
	wt->envid = envid;
  801270:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801276:	83 ec 04             	sub    $0x4,%esp
  801279:	ff 33                	pushl  (%ebx)
  80127b:	56                   	push   %esi
  80127c:	68 60 2b 80 00       	push   $0x802b60
  801281:	e8 c3 f0 ff ff       	call   800349 <cprintf>
	if (queue->first == NULL) {
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	83 3b 00             	cmpl   $0x0,(%ebx)
  80128c:	75 29                	jne    8012b7 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80128e:	83 ec 0c             	sub    $0xc,%esp
  801291:	68 c2 2a 80 00       	push   $0x802ac2
  801296:	e8 ae f0 ff ff       	call   800349 <cprintf>
		queue->first = wt;
  80129b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8012a1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8012a8:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012af:	00 00 00 
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	eb 2b                	jmp    8012e2 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	68 dc 2a 80 00       	push   $0x802adc
  8012bf:	e8 85 f0 ff ff       	call   800349 <cprintf>
		queue->last->next = wt;
  8012c4:	8b 43 04             	mov    0x4(%ebx),%eax
  8012c7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8012ce:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012d5:	00 00 00 
		queue->last = wt;
  8012d8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8012df:	83 c4 10             	add    $0x10,%esp
	}
}
  8012e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8012f3:	8b 02                	mov    (%edx),%eax
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	75 17                	jne    801310 <queue_pop+0x27>
		panic("queue empty!\n");
  8012f9:	83 ec 04             	sub    $0x4,%esp
  8012fc:	68 fa 2a 80 00       	push   $0x802afa
  801301:	68 d8 00 00 00       	push   $0xd8
  801306:	68 7a 2a 80 00       	push   $0x802a7a
  80130b:	e8 60 ef ff ff       	call   800270 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801310:	8b 48 04             	mov    0x4(%eax),%ecx
  801313:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801315:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	53                   	push   %ebx
  80131b:	68 08 2b 80 00       	push   $0x802b08
  801320:	e8 24 f0 ff ff       	call   800349 <cprintf>
	return envid;
}
  801325:	89 d8                	mov    %ebx,%eax
  801327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 04             	sub    $0x4,%esp
  801333:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80133e:	85 c0                	test   %eax,%eax
  801340:	74 5a                	je     80139c <mutex_lock+0x70>
  801342:	8b 43 04             	mov    0x4(%ebx),%eax
  801345:	83 38 00             	cmpl   $0x0,(%eax)
  801348:	75 52                	jne    80139c <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	68 88 2b 80 00       	push   $0x802b88
  801352:	e8 f2 ef ff ff       	call   800349 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801357:	8b 5b 04             	mov    0x4(%ebx),%ebx
  80135a:	e8 34 f9 ff ff       	call   800c93 <sys_getenvid>
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	53                   	push   %ebx
  801363:	50                   	push   %eax
  801364:	e8 d3 fe ff ff       	call   80123c <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801369:	e8 25 f9 ff ff       	call   800c93 <sys_getenvid>
  80136e:	83 c4 08             	add    $0x8,%esp
  801371:	6a 04                	push   $0x4
  801373:	50                   	push   %eax
  801374:	e8 1f fa ff ff       	call   800d98 <sys_env_set_status>
		if (r < 0) {
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	79 15                	jns    801395 <mutex_lock+0x69>
			panic("%e\n", r);
  801380:	50                   	push   %eax
  801381:	68 38 2b 80 00       	push   $0x802b38
  801386:	68 eb 00 00 00       	push   $0xeb
  80138b:	68 7a 2a 80 00       	push   $0x802a7a
  801390:	e8 db ee ff ff       	call   800270 <_panic>
		}
		sys_yield();
  801395:	e8 18 f9 ff ff       	call   800cb2 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80139a:	eb 18                	jmp    8013b4 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80139c:	83 ec 0c             	sub    $0xc,%esp
  80139f:	68 a8 2b 80 00       	push   $0x802ba8
  8013a4:	e8 a0 ef ff ff       	call   800349 <cprintf>
	mtx->owner = sys_getenvid();}
  8013a9:	e8 e5 f8 ff ff       	call   800c93 <sys_getenvid>
  8013ae:	89 43 08             	mov    %eax,0x8(%ebx)
  8013b1:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8013b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b7:	c9                   	leave  
  8013b8:	c3                   	ret    

008013b9 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c8:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8013cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8013ce:	83 38 00             	cmpl   $0x0,(%eax)
  8013d1:	74 33                	je     801406 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	50                   	push   %eax
  8013d7:	e8 0d ff ff ff       	call   8012e9 <queue_pop>
  8013dc:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	6a 02                	push   $0x2
  8013e4:	50                   	push   %eax
  8013e5:	e8 ae f9 ff ff       	call   800d98 <sys_env_set_status>
		if (r < 0) {
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	79 15                	jns    801406 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8013f1:	50                   	push   %eax
  8013f2:	68 38 2b 80 00       	push   $0x802b38
  8013f7:	68 00 01 00 00       	push   $0x100
  8013fc:	68 7a 2a 80 00       	push   $0x802a7a
  801401:	e8 6a ee ff ff       	call   800270 <_panic>
		}
	}

	asm volatile("pause");
  801406:	f3 90                	pause  
	//sys_yield();
}
  801408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	53                   	push   %ebx
  801411:	83 ec 04             	sub    $0x4,%esp
  801414:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801417:	e8 77 f8 ff ff       	call   800c93 <sys_getenvid>
  80141c:	83 ec 04             	sub    $0x4,%esp
  80141f:	6a 07                	push   $0x7
  801421:	53                   	push   %ebx
  801422:	50                   	push   %eax
  801423:	e8 a9 f8 ff ff       	call   800cd1 <sys_page_alloc>
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	79 15                	jns    801444 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80142f:	50                   	push   %eax
  801430:	68 23 2b 80 00       	push   $0x802b23
  801435:	68 0d 01 00 00       	push   $0x10d
  80143a:	68 7a 2a 80 00       	push   $0x802a7a
  80143f:	e8 2c ee ff ff       	call   800270 <_panic>
	}	
	mtx->locked = 0;
  801444:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80144a:	8b 43 04             	mov    0x4(%ebx),%eax
  80144d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801453:	8b 43 04             	mov    0x4(%ebx),%eax
  801456:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80145d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801464:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80146f:	e8 1f f8 ff ff       	call   800c93 <sys_getenvid>
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	ff 75 08             	pushl  0x8(%ebp)
  80147a:	50                   	push   %eax
  80147b:	e8 d6 f8 ff ff       	call   800d56 <sys_page_unmap>
	if (r < 0) {
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	79 15                	jns    80149c <mutex_destroy+0x33>
		panic("%e\n", r);
  801487:	50                   	push   %eax
  801488:	68 38 2b 80 00       	push   $0x802b38
  80148d:	68 1a 01 00 00       	push   $0x11a
  801492:	68 7a 2a 80 00       	push   $0x802a7a
  801497:	e8 d4 ed ff ff       	call   800270 <_panic>
	}
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	56                   	push   %esi
  8014a2:	53                   	push   %ebx
  8014a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	75 12                	jne    8014c2 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	68 00 00 c0 ee       	push   $0xeec00000
  8014b8:	e8 c4 f9 ff ff       	call   800e81 <sys_ipc_recv>
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	eb 0c                	jmp    8014ce <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	50                   	push   %eax
  8014c6:	e8 b6 f9 ff ff       	call   800e81 <sys_ipc_recv>
  8014cb:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8014ce:	85 f6                	test   %esi,%esi
  8014d0:	0f 95 c1             	setne  %cl
  8014d3:	85 db                	test   %ebx,%ebx
  8014d5:	0f 95 c2             	setne  %dl
  8014d8:	84 d1                	test   %dl,%cl
  8014da:	74 09                	je     8014e5 <ipc_recv+0x47>
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	c1 ea 1f             	shr    $0x1f,%edx
  8014e1:	84 d2                	test   %dl,%dl
  8014e3:	75 2d                	jne    801512 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8014e5:	85 f6                	test   %esi,%esi
  8014e7:	74 0d                	je     8014f6 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8014e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ee:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8014f4:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8014f6:	85 db                	test   %ebx,%ebx
  8014f8:	74 0d                	je     801507 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8014fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ff:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801505:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801507:	a1 04 40 80 00       	mov    0x804004,%eax
  80150c:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801512:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    

00801519 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	57                   	push   %edi
  80151d:	56                   	push   %esi
  80151e:	53                   	push   %ebx
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	8b 7d 08             	mov    0x8(%ebp),%edi
  801525:	8b 75 0c             	mov    0xc(%ebp),%esi
  801528:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80152b:	85 db                	test   %ebx,%ebx
  80152d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801532:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801535:	ff 75 14             	pushl  0x14(%ebp)
  801538:	53                   	push   %ebx
  801539:	56                   	push   %esi
  80153a:	57                   	push   %edi
  80153b:	e8 1e f9 ff ff       	call   800e5e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801540:	89 c2                	mov    %eax,%edx
  801542:	c1 ea 1f             	shr    $0x1f,%edx
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	84 d2                	test   %dl,%dl
  80154a:	74 17                	je     801563 <ipc_send+0x4a>
  80154c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80154f:	74 12                	je     801563 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801551:	50                   	push   %eax
  801552:	68 c8 2b 80 00       	push   $0x802bc8
  801557:	6a 47                	push   $0x47
  801559:	68 d6 2b 80 00       	push   $0x802bd6
  80155e:	e8 0d ed ff ff       	call   800270 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801563:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801566:	75 07                	jne    80156f <ipc_send+0x56>
			sys_yield();
  801568:	e8 45 f7 ff ff       	call   800cb2 <sys_yield>
  80156d:	eb c6                	jmp    801535 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80156f:	85 c0                	test   %eax,%eax
  801571:	75 c2                	jne    801535 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801573:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801581:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801586:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80158c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801592:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801598:	39 ca                	cmp    %ecx,%edx
  80159a:	75 13                	jne    8015af <ipc_find_env+0x34>
			return envs[i].env_id;
  80159c:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8015a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015a7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015ad:	eb 0f                	jmp    8015be <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015af:	83 c0 01             	add    $0x1,%eax
  8015b2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015b7:	75 cd                	jne    801586 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8015b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8015d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8015e0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	c1 ea 16             	shr    $0x16,%edx
  8015f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015fe:	f6 c2 01             	test   $0x1,%dl
  801601:	74 11                	je     801614 <fd_alloc+0x2d>
  801603:	89 c2                	mov    %eax,%edx
  801605:	c1 ea 0c             	shr    $0xc,%edx
  801608:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80160f:	f6 c2 01             	test   $0x1,%dl
  801612:	75 09                	jne    80161d <fd_alloc+0x36>
			*fd_store = fd;
  801614:	89 01                	mov    %eax,(%ecx)
			return 0;
  801616:	b8 00 00 00 00       	mov    $0x0,%eax
  80161b:	eb 17                	jmp    801634 <fd_alloc+0x4d>
  80161d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801622:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801627:	75 c9                	jne    8015f2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801629:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80162f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80163c:	83 f8 1f             	cmp    $0x1f,%eax
  80163f:	77 36                	ja     801677 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801641:	c1 e0 0c             	shl    $0xc,%eax
  801644:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801649:	89 c2                	mov    %eax,%edx
  80164b:	c1 ea 16             	shr    $0x16,%edx
  80164e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801655:	f6 c2 01             	test   $0x1,%dl
  801658:	74 24                	je     80167e <fd_lookup+0x48>
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	c1 ea 0c             	shr    $0xc,%edx
  80165f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801666:	f6 c2 01             	test   $0x1,%dl
  801669:	74 1a                	je     801685 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80166b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166e:	89 02                	mov    %eax,(%edx)
	return 0;
  801670:	b8 00 00 00 00       	mov    $0x0,%eax
  801675:	eb 13                	jmp    80168a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801677:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167c:	eb 0c                	jmp    80168a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80167e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801683:	eb 05                	jmp    80168a <fd_lookup+0x54>
  801685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801695:	ba 60 2c 80 00       	mov    $0x802c60,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80169a:	eb 13                	jmp    8016af <dev_lookup+0x23>
  80169c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80169f:	39 08                	cmp    %ecx,(%eax)
  8016a1:	75 0c                	jne    8016af <dev_lookup+0x23>
			*dev = devtab[i];
  8016a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ad:	eb 31                	jmp    8016e0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016af:	8b 02                	mov    (%edx),%eax
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	75 e7                	jne    80169c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ba:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016c0:	83 ec 04             	sub    $0x4,%esp
  8016c3:	51                   	push   %ecx
  8016c4:	50                   	push   %eax
  8016c5:	68 e0 2b 80 00       	push   $0x802be0
  8016ca:	e8 7a ec ff ff       	call   800349 <cprintf>
	*dev = 0;
  8016cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 10             	sub    $0x10,%esp
  8016ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8016fa:	c1 e8 0c             	shr    $0xc,%eax
  8016fd:	50                   	push   %eax
  8016fe:	e8 33 ff ff ff       	call   801636 <fd_lookup>
  801703:	83 c4 08             	add    $0x8,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 05                	js     80170f <fd_close+0x2d>
	    || fd != fd2)
  80170a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80170d:	74 0c                	je     80171b <fd_close+0x39>
		return (must_exist ? r : 0);
  80170f:	84 db                	test   %bl,%bl
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
  801716:	0f 44 c2             	cmove  %edx,%eax
  801719:	eb 41                	jmp    80175c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	ff 36                	pushl  (%esi)
  801724:	e8 63 ff ff ff       	call   80168c <dev_lookup>
  801729:	89 c3                	mov    %eax,%ebx
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 1a                	js     80174c <fd_close+0x6a>
		if (dev->dev_close)
  801732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801735:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801738:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80173d:	85 c0                	test   %eax,%eax
  80173f:	74 0b                	je     80174c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	56                   	push   %esi
  801745:	ff d0                	call   *%eax
  801747:	89 c3                	mov    %eax,%ebx
  801749:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	56                   	push   %esi
  801750:	6a 00                	push   $0x0
  801752:	e8 ff f5 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	89 d8                	mov    %ebx,%eax
}
  80175c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	ff 75 08             	pushl  0x8(%ebp)
  801770:	e8 c1 fe ff ff       	call   801636 <fd_lookup>
  801775:	83 c4 08             	add    $0x8,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 10                	js     80178c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	6a 01                	push   $0x1
  801781:	ff 75 f4             	pushl  -0xc(%ebp)
  801784:	e8 59 ff ff ff       	call   8016e2 <fd_close>
  801789:	83 c4 10             	add    $0x10,%esp
}
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <close_all>:

void
close_all(void)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	53                   	push   %ebx
  801792:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801795:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80179a:	83 ec 0c             	sub    $0xc,%esp
  80179d:	53                   	push   %ebx
  80179e:	e8 c0 ff ff ff       	call   801763 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017a3:	83 c3 01             	add    $0x1,%ebx
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	83 fb 20             	cmp    $0x20,%ebx
  8017ac:	75 ec                	jne    80179a <close_all+0xc>
		close(i);
}
  8017ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	57                   	push   %edi
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 2c             	sub    $0x2c,%esp
  8017bc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8017bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017c2:	50                   	push   %eax
  8017c3:	ff 75 08             	pushl  0x8(%ebp)
  8017c6:	e8 6b fe ff ff       	call   801636 <fd_lookup>
  8017cb:	83 c4 08             	add    $0x8,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	0f 88 c1 00 00 00    	js     801897 <dup+0xe4>
		return r;
	close(newfdnum);
  8017d6:	83 ec 0c             	sub    $0xc,%esp
  8017d9:	56                   	push   %esi
  8017da:	e8 84 ff ff ff       	call   801763 <close>

	newfd = INDEX2FD(newfdnum);
  8017df:	89 f3                	mov    %esi,%ebx
  8017e1:	c1 e3 0c             	shl    $0xc,%ebx
  8017e4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8017ea:	83 c4 04             	add    $0x4,%esp
  8017ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017f0:	e8 db fd ff ff       	call   8015d0 <fd2data>
  8017f5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8017f7:	89 1c 24             	mov    %ebx,(%esp)
  8017fa:	e8 d1 fd ff ff       	call   8015d0 <fd2data>
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801805:	89 f8                	mov    %edi,%eax
  801807:	c1 e8 16             	shr    $0x16,%eax
  80180a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801811:	a8 01                	test   $0x1,%al
  801813:	74 37                	je     80184c <dup+0x99>
  801815:	89 f8                	mov    %edi,%eax
  801817:	c1 e8 0c             	shr    $0xc,%eax
  80181a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801821:	f6 c2 01             	test   $0x1,%dl
  801824:	74 26                	je     80184c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801826:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	25 07 0e 00 00       	and    $0xe07,%eax
  801835:	50                   	push   %eax
  801836:	ff 75 d4             	pushl  -0x2c(%ebp)
  801839:	6a 00                	push   $0x0
  80183b:	57                   	push   %edi
  80183c:	6a 00                	push   $0x0
  80183e:	e8 d1 f4 ff ff       	call   800d14 <sys_page_map>
  801843:	89 c7                	mov    %eax,%edi
  801845:	83 c4 20             	add    $0x20,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 2e                	js     80187a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80184c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80184f:	89 d0                	mov    %edx,%eax
  801851:	c1 e8 0c             	shr    $0xc,%eax
  801854:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	25 07 0e 00 00       	and    $0xe07,%eax
  801863:	50                   	push   %eax
  801864:	53                   	push   %ebx
  801865:	6a 00                	push   $0x0
  801867:	52                   	push   %edx
  801868:	6a 00                	push   $0x0
  80186a:	e8 a5 f4 ff ff       	call   800d14 <sys_page_map>
  80186f:	89 c7                	mov    %eax,%edi
  801871:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801874:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801876:	85 ff                	test   %edi,%edi
  801878:	79 1d                	jns    801897 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	53                   	push   %ebx
  80187e:	6a 00                	push   $0x0
  801880:	e8 d1 f4 ff ff       	call   800d56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801885:	83 c4 08             	add    $0x8,%esp
  801888:	ff 75 d4             	pushl  -0x2c(%ebp)
  80188b:	6a 00                	push   $0x0
  80188d:	e8 c4 f4 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	89 f8                	mov    %edi,%eax
}
  801897:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189a:	5b                   	pop    %ebx
  80189b:	5e                   	pop    %esi
  80189c:	5f                   	pop    %edi
  80189d:	5d                   	pop    %ebp
  80189e:	c3                   	ret    

0080189f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	53                   	push   %ebx
  8018a3:	83 ec 14             	sub    $0x14,%esp
  8018a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	53                   	push   %ebx
  8018ae:	e8 83 fd ff ff       	call   801636 <fd_lookup>
  8018b3:	83 c4 08             	add    $0x8,%esp
  8018b6:	89 c2                	mov    %eax,%edx
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 70                	js     80192c <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c2:	50                   	push   %eax
  8018c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c6:	ff 30                	pushl  (%eax)
  8018c8:	e8 bf fd ff ff       	call   80168c <dev_lookup>
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 4f                	js     801923 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018d7:	8b 42 08             	mov    0x8(%edx),%eax
  8018da:	83 e0 03             	and    $0x3,%eax
  8018dd:	83 f8 01             	cmp    $0x1,%eax
  8018e0:	75 24                	jne    801906 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018ed:	83 ec 04             	sub    $0x4,%esp
  8018f0:	53                   	push   %ebx
  8018f1:	50                   	push   %eax
  8018f2:	68 24 2c 80 00       	push   $0x802c24
  8018f7:	e8 4d ea ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801904:	eb 26                	jmp    80192c <read+0x8d>
	}
	if (!dev->dev_read)
  801906:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801909:	8b 40 08             	mov    0x8(%eax),%eax
  80190c:	85 c0                	test   %eax,%eax
  80190e:	74 17                	je     801927 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801910:	83 ec 04             	sub    $0x4,%esp
  801913:	ff 75 10             	pushl  0x10(%ebp)
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	52                   	push   %edx
  80191a:	ff d0                	call   *%eax
  80191c:	89 c2                	mov    %eax,%edx
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	eb 09                	jmp    80192c <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801923:	89 c2                	mov    %eax,%edx
  801925:	eb 05                	jmp    80192c <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801927:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80192c:	89 d0                	mov    %edx,%eax
  80192e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	57                   	push   %edi
  801937:	56                   	push   %esi
  801938:	53                   	push   %ebx
  801939:	83 ec 0c             	sub    $0xc,%esp
  80193c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80193f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801942:	bb 00 00 00 00       	mov    $0x0,%ebx
  801947:	eb 21                	jmp    80196a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801949:	83 ec 04             	sub    $0x4,%esp
  80194c:	89 f0                	mov    %esi,%eax
  80194e:	29 d8                	sub    %ebx,%eax
  801950:	50                   	push   %eax
  801951:	89 d8                	mov    %ebx,%eax
  801953:	03 45 0c             	add    0xc(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	57                   	push   %edi
  801958:	e8 42 ff ff ff       	call   80189f <read>
		if (m < 0)
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	78 10                	js     801974 <readn+0x41>
			return m;
		if (m == 0)
  801964:	85 c0                	test   %eax,%eax
  801966:	74 0a                	je     801972 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801968:	01 c3                	add    %eax,%ebx
  80196a:	39 f3                	cmp    %esi,%ebx
  80196c:	72 db                	jb     801949 <readn+0x16>
  80196e:	89 d8                	mov    %ebx,%eax
  801970:	eb 02                	jmp    801974 <readn+0x41>
  801972:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801974:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5f                   	pop    %edi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	53                   	push   %ebx
  801980:	83 ec 14             	sub    $0x14,%esp
  801983:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801986:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	53                   	push   %ebx
  80198b:	e8 a6 fc ff ff       	call   801636 <fd_lookup>
  801990:	83 c4 08             	add    $0x8,%esp
  801993:	89 c2                	mov    %eax,%edx
  801995:	85 c0                	test   %eax,%eax
  801997:	78 6b                	js     801a04 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801999:	83 ec 08             	sub    $0x8,%esp
  80199c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199f:	50                   	push   %eax
  8019a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a3:	ff 30                	pushl  (%eax)
  8019a5:	e8 e2 fc ff ff       	call   80168c <dev_lookup>
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	78 4a                	js     8019fb <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019b8:	75 24                	jne    8019de <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8019ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8019bf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	53                   	push   %ebx
  8019c9:	50                   	push   %eax
  8019ca:	68 40 2c 80 00       	push   $0x802c40
  8019cf:	e8 75 e9 ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019dc:	eb 26                	jmp    801a04 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8019e4:	85 d2                	test   %edx,%edx
  8019e6:	74 17                	je     8019ff <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019e8:	83 ec 04             	sub    $0x4,%esp
  8019eb:	ff 75 10             	pushl  0x10(%ebp)
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	50                   	push   %eax
  8019f2:	ff d2                	call   *%edx
  8019f4:	89 c2                	mov    %eax,%edx
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	eb 09                	jmp    801a04 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	eb 05                	jmp    801a04 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8019ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801a04:	89 d0                	mov    %edx,%eax
  801a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <seek>:

int
seek(int fdnum, off_t offset)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a11:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a14:	50                   	push   %eax
  801a15:	ff 75 08             	pushl  0x8(%ebp)
  801a18:	e8 19 fc ff ff       	call   801636 <fd_lookup>
  801a1d:	83 c4 08             	add    $0x8,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 0e                	js     801a32 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801a24:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a2a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	53                   	push   %ebx
  801a38:	83 ec 14             	sub    $0x14,%esp
  801a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a41:	50                   	push   %eax
  801a42:	53                   	push   %ebx
  801a43:	e8 ee fb ff ff       	call   801636 <fd_lookup>
  801a48:	83 c4 08             	add    $0x8,%esp
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	78 68                	js     801ab9 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a57:	50                   	push   %eax
  801a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5b:	ff 30                	pushl  (%eax)
  801a5d:	e8 2a fc ff ff       	call   80168c <dev_lookup>
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 47                	js     801ab0 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a70:	75 24                	jne    801a96 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a72:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a77:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801a7d:	83 ec 04             	sub    $0x4,%esp
  801a80:	53                   	push   %ebx
  801a81:	50                   	push   %eax
  801a82:	68 00 2c 80 00       	push   $0x802c00
  801a87:	e8 bd e8 ff ff       	call   800349 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a94:	eb 23                	jmp    801ab9 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801a96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a99:	8b 52 18             	mov    0x18(%edx),%edx
  801a9c:	85 d2                	test   %edx,%edx
  801a9e:	74 14                	je     801ab4 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801aa0:	83 ec 08             	sub    $0x8,%esp
  801aa3:	ff 75 0c             	pushl  0xc(%ebp)
  801aa6:	50                   	push   %eax
  801aa7:	ff d2                	call   *%edx
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	eb 09                	jmp    801ab9 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab0:	89 c2                	mov    %eax,%edx
  801ab2:	eb 05                	jmp    801ab9 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801ab4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801ab9:	89 d0                	mov    %edx,%eax
  801abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 14             	sub    $0x14,%esp
  801ac7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	ff 75 08             	pushl  0x8(%ebp)
  801ad1:	e8 60 fb ff ff       	call   801636 <fd_lookup>
  801ad6:	83 c4 08             	add    $0x8,%esp
  801ad9:	89 c2                	mov    %eax,%edx
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 58                	js     801b37 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae5:	50                   	push   %eax
  801ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae9:	ff 30                	pushl  (%eax)
  801aeb:	e8 9c fb ff ff       	call   80168c <dev_lookup>
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 37                	js     801b2e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801afe:	74 32                	je     801b32 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b00:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b03:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b0a:	00 00 00 
	stat->st_isdir = 0;
  801b0d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b14:	00 00 00 
	stat->st_dev = dev;
  801b17:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	53                   	push   %ebx
  801b21:	ff 75 f0             	pushl  -0x10(%ebp)
  801b24:	ff 50 14             	call   *0x14(%eax)
  801b27:	89 c2                	mov    %eax,%edx
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	eb 09                	jmp    801b37 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b2e:	89 c2                	mov    %eax,%edx
  801b30:	eb 05                	jmp    801b37 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b32:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b37:	89 d0                	mov    %edx,%eax
  801b39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b43:	83 ec 08             	sub    $0x8,%esp
  801b46:	6a 00                	push   $0x0
  801b48:	ff 75 08             	pushl  0x8(%ebp)
  801b4b:	e8 e3 01 00 00       	call   801d33 <open>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 1b                	js     801b74 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	ff 75 0c             	pushl  0xc(%ebp)
  801b5f:	50                   	push   %eax
  801b60:	e8 5b ff ff ff       	call   801ac0 <fstat>
  801b65:	89 c6                	mov    %eax,%esi
	close(fd);
  801b67:	89 1c 24             	mov    %ebx,(%esp)
  801b6a:	e8 f4 fb ff ff       	call   801763 <close>
	return r;
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	89 f0                	mov    %esi,%eax
}
  801b74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	89 c6                	mov    %eax,%esi
  801b82:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b84:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b8b:	75 12                	jne    801b9f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b8d:	83 ec 0c             	sub    $0xc,%esp
  801b90:	6a 01                	push   $0x1
  801b92:	e8 e4 f9 ff ff       	call   80157b <ipc_find_env>
  801b97:	a3 00 40 80 00       	mov    %eax,0x804000
  801b9c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b9f:	6a 07                	push   $0x7
  801ba1:	68 00 50 80 00       	push   $0x805000
  801ba6:	56                   	push   %esi
  801ba7:	ff 35 00 40 80 00    	pushl  0x804000
  801bad:	e8 67 f9 ff ff       	call   801519 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bb2:	83 c4 0c             	add    $0xc,%esp
  801bb5:	6a 00                	push   $0x0
  801bb7:	53                   	push   %ebx
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 df f8 ff ff       	call   80149e <ipc_recv>
}
  801bbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc2:	5b                   	pop    %ebx
  801bc3:	5e                   	pop    %esi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bda:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  801be4:	b8 02 00 00 00       	mov    $0x2,%eax
  801be9:	e8 8d ff ff ff       	call   801b7b <fsipc>
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	8b 40 0c             	mov    0xc(%eax),%eax
  801bfc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c01:	ba 00 00 00 00       	mov    $0x0,%edx
  801c06:	b8 06 00 00 00       	mov    $0x6,%eax
  801c0b:	e8 6b ff ff ff       	call   801b7b <fsipc>
}
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    

00801c12 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	53                   	push   %ebx
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c22:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c27:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2c:	b8 05 00 00 00       	mov    $0x5,%eax
  801c31:	e8 45 ff ff ff       	call   801b7b <fsipc>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	78 2c                	js     801c66 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c3a:	83 ec 08             	sub    $0x8,%esp
  801c3d:	68 00 50 80 00       	push   $0x805000
  801c42:	53                   	push   %ebx
  801c43:	e8 86 ec ff ff       	call   8008ce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c48:	a1 80 50 80 00       	mov    0x805080,%eax
  801c4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c53:	a1 84 50 80 00       	mov    0x805084,%eax
  801c58:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	83 ec 0c             	sub    $0xc,%esp
  801c71:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c74:	8b 55 08             	mov    0x8(%ebp),%edx
  801c77:	8b 52 0c             	mov    0xc(%edx),%edx
  801c7a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801c80:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c85:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c8a:	0f 47 c2             	cmova  %edx,%eax
  801c8d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801c92:	50                   	push   %eax
  801c93:	ff 75 0c             	pushl  0xc(%ebp)
  801c96:	68 08 50 80 00       	push   $0x805008
  801c9b:	e8 c0 ed ff ff       	call   800a60 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  801caa:	e8 cc fe ff ff       	call   801b7b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	56                   	push   %esi
  801cb5:	53                   	push   %ebx
  801cb6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	8b 40 0c             	mov    0xc(%eax),%eax
  801cbf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801cc4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801cca:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccf:	b8 03 00 00 00       	mov    $0x3,%eax
  801cd4:	e8 a2 fe ff ff       	call   801b7b <fsipc>
  801cd9:	89 c3                	mov    %eax,%ebx
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	78 4b                	js     801d2a <devfile_read+0x79>
		return r;
	assert(r <= n);
  801cdf:	39 c6                	cmp    %eax,%esi
  801ce1:	73 16                	jae    801cf9 <devfile_read+0x48>
  801ce3:	68 70 2c 80 00       	push   $0x802c70
  801ce8:	68 77 2c 80 00       	push   $0x802c77
  801ced:	6a 7c                	push   $0x7c
  801cef:	68 8c 2c 80 00       	push   $0x802c8c
  801cf4:	e8 77 e5 ff ff       	call   800270 <_panic>
	assert(r <= PGSIZE);
  801cf9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cfe:	7e 16                	jle    801d16 <devfile_read+0x65>
  801d00:	68 97 2c 80 00       	push   $0x802c97
  801d05:	68 77 2c 80 00       	push   $0x802c77
  801d0a:	6a 7d                	push   $0x7d
  801d0c:	68 8c 2c 80 00       	push   $0x802c8c
  801d11:	e8 5a e5 ff ff       	call   800270 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	50                   	push   %eax
  801d1a:	68 00 50 80 00       	push   $0x805000
  801d1f:	ff 75 0c             	pushl  0xc(%ebp)
  801d22:	e8 39 ed ff ff       	call   800a60 <memmove>
	return r;
  801d27:	83 c4 10             	add    $0x10,%esp
}
  801d2a:	89 d8                	mov    %ebx,%eax
  801d2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 20             	sub    $0x20,%esp
  801d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d3d:	53                   	push   %ebx
  801d3e:	e8 52 eb ff ff       	call   800895 <strlen>
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d4b:	7f 67                	jg     801db4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d53:	50                   	push   %eax
  801d54:	e8 8e f8 ff ff       	call   8015e7 <fd_alloc>
  801d59:	83 c4 10             	add    $0x10,%esp
		return r;
  801d5c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 57                	js     801db9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d62:	83 ec 08             	sub    $0x8,%esp
  801d65:	53                   	push   %ebx
  801d66:	68 00 50 80 00       	push   $0x805000
  801d6b:	e8 5e eb ff ff       	call   8008ce <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d73:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d7b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d80:	e8 f6 fd ff ff       	call   801b7b <fsipc>
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	79 14                	jns    801da2 <open+0x6f>
		fd_close(fd, 0);
  801d8e:	83 ec 08             	sub    $0x8,%esp
  801d91:	6a 00                	push   $0x0
  801d93:	ff 75 f4             	pushl  -0xc(%ebp)
  801d96:	e8 47 f9 ff ff       	call   8016e2 <fd_close>
		return r;
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	89 da                	mov    %ebx,%edx
  801da0:	eb 17                	jmp    801db9 <open+0x86>
	}

	return fd2num(fd);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 f4             	pushl  -0xc(%ebp)
  801da8:	e8 13 f8 ff ff       	call   8015c0 <fd2num>
  801dad:	89 c2                	mov    %eax,%edx
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	eb 05                	jmp    801db9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801db4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801db9:	89 d0                	mov    %edx,%eax
  801dbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801dc6:	ba 00 00 00 00       	mov    $0x0,%edx
  801dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  801dd0:	e8 a6 fd ff ff       	call   801b7b <fsipc>
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ddd:	89 d0                	mov    %edx,%eax
  801ddf:	c1 e8 16             	shr    $0x16,%eax
  801de2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dee:	f6 c1 01             	test   $0x1,%cl
  801df1:	74 1d                	je     801e10 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801df3:	c1 ea 0c             	shr    $0xc,%edx
  801df6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dfd:	f6 c2 01             	test   $0x1,%dl
  801e00:	74 0e                	je     801e10 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e02:	c1 ea 0c             	shr    $0xc,%edx
  801e05:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e0c:	ef 
  801e0d:	0f b7 c0             	movzwl %ax,%eax
}
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	56                   	push   %esi
  801e16:	53                   	push   %ebx
  801e17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	ff 75 08             	pushl  0x8(%ebp)
  801e20:	e8 ab f7 ff ff       	call   8015d0 <fd2data>
  801e25:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e27:	83 c4 08             	add    $0x8,%esp
  801e2a:	68 a3 2c 80 00       	push   $0x802ca3
  801e2f:	53                   	push   %ebx
  801e30:	e8 99 ea ff ff       	call   8008ce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e35:	8b 46 04             	mov    0x4(%esi),%eax
  801e38:	2b 06                	sub    (%esi),%eax
  801e3a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e40:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e47:	00 00 00 
	stat->st_dev = &devpipe;
  801e4a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801e51:	30 80 00 
	return 0;
}
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
  801e59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5d                   	pop    %ebp
  801e5f:	c3                   	ret    

00801e60 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	53                   	push   %ebx
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e6a:	53                   	push   %ebx
  801e6b:	6a 00                	push   $0x0
  801e6d:	e8 e4 ee ff ff       	call   800d56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e72:	89 1c 24             	mov    %ebx,(%esp)
  801e75:	e8 56 f7 ff ff       	call   8015d0 <fd2data>
  801e7a:	83 c4 08             	add    $0x8,%esp
  801e7d:	50                   	push   %eax
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 d1 ee ff ff       	call   800d56 <sys_page_unmap>
}
  801e85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	57                   	push   %edi
  801e8e:	56                   	push   %esi
  801e8f:	53                   	push   %ebx
  801e90:	83 ec 1c             	sub    $0x1c,%esp
  801e93:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e96:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e98:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9d:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ea3:	83 ec 0c             	sub    $0xc,%esp
  801ea6:	ff 75 e0             	pushl  -0x20(%ebp)
  801ea9:	e8 29 ff ff ff       	call   801dd7 <pageref>
  801eae:	89 c3                	mov    %eax,%ebx
  801eb0:	89 3c 24             	mov    %edi,(%esp)
  801eb3:	e8 1f ff ff ff       	call   801dd7 <pageref>
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	39 c3                	cmp    %eax,%ebx
  801ebd:	0f 94 c1             	sete   %cl
  801ec0:	0f b6 c9             	movzbl %cl,%ecx
  801ec3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ec6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ecc:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801ed2:	39 ce                	cmp    %ecx,%esi
  801ed4:	74 1e                	je     801ef4 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ed6:	39 c3                	cmp    %eax,%ebx
  801ed8:	75 be                	jne    801e98 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eda:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801ee0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ee3:	50                   	push   %eax
  801ee4:	56                   	push   %esi
  801ee5:	68 aa 2c 80 00       	push   $0x802caa
  801eea:	e8 5a e4 ff ff       	call   800349 <cprintf>
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	eb a4                	jmp    801e98 <_pipeisclosed+0xe>
	}
}
  801ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efa:	5b                   	pop    %ebx
  801efb:	5e                   	pop    %esi
  801efc:	5f                   	pop    %edi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	57                   	push   %edi
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	83 ec 28             	sub    $0x28,%esp
  801f08:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f0b:	56                   	push   %esi
  801f0c:	e8 bf f6 ff ff       	call   8015d0 <fd2data>
  801f11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	bf 00 00 00 00       	mov    $0x0,%edi
  801f1b:	eb 4b                	jmp    801f68 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f1d:	89 da                	mov    %ebx,%edx
  801f1f:	89 f0                	mov    %esi,%eax
  801f21:	e8 64 ff ff ff       	call   801e8a <_pipeisclosed>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	75 48                	jne    801f72 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f2a:	e8 83 ed ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f2f:	8b 43 04             	mov    0x4(%ebx),%eax
  801f32:	8b 0b                	mov    (%ebx),%ecx
  801f34:	8d 51 20             	lea    0x20(%ecx),%edx
  801f37:	39 d0                	cmp    %edx,%eax
  801f39:	73 e2                	jae    801f1d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f42:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f45:	89 c2                	mov    %eax,%edx
  801f47:	c1 fa 1f             	sar    $0x1f,%edx
  801f4a:	89 d1                	mov    %edx,%ecx
  801f4c:	c1 e9 1b             	shr    $0x1b,%ecx
  801f4f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f52:	83 e2 1f             	and    $0x1f,%edx
  801f55:	29 ca                	sub    %ecx,%edx
  801f57:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f5b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f5f:	83 c0 01             	add    $0x1,%eax
  801f62:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f65:	83 c7 01             	add    $0x1,%edi
  801f68:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f6b:	75 c2                	jne    801f2f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f70:	eb 05                	jmp    801f77 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	57                   	push   %edi
  801f83:	56                   	push   %esi
  801f84:	53                   	push   %ebx
  801f85:	83 ec 18             	sub    $0x18,%esp
  801f88:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f8b:	57                   	push   %edi
  801f8c:	e8 3f f6 ff ff       	call   8015d0 <fd2data>
  801f91:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f93:	83 c4 10             	add    $0x10,%esp
  801f96:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f9b:	eb 3d                	jmp    801fda <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f9d:	85 db                	test   %ebx,%ebx
  801f9f:	74 04                	je     801fa5 <devpipe_read+0x26>
				return i;
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	eb 44                	jmp    801fe9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fa5:	89 f2                	mov    %esi,%edx
  801fa7:	89 f8                	mov    %edi,%eax
  801fa9:	e8 dc fe ff ff       	call   801e8a <_pipeisclosed>
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	75 32                	jne    801fe4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fb2:	e8 fb ec ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fb7:	8b 06                	mov    (%esi),%eax
  801fb9:	3b 46 04             	cmp    0x4(%esi),%eax
  801fbc:	74 df                	je     801f9d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fbe:	99                   	cltd   
  801fbf:	c1 ea 1b             	shr    $0x1b,%edx
  801fc2:	01 d0                	add    %edx,%eax
  801fc4:	83 e0 1f             	and    $0x1f,%eax
  801fc7:	29 d0                	sub    %edx,%eax
  801fc9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fd1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fd4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd7:	83 c3 01             	add    $0x1,%ebx
  801fda:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fdd:	75 d8                	jne    801fb7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fdf:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe2:	eb 05                	jmp    801fe9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fe9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fec:	5b                   	pop    %ebx
  801fed:	5e                   	pop    %esi
  801fee:	5f                   	pop    %edi
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    

00801ff1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	56                   	push   %esi
  801ff5:	53                   	push   %ebx
  801ff6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	e8 e5 f5 ff ff       	call   8015e7 <fd_alloc>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	89 c2                	mov    %eax,%edx
  802007:	85 c0                	test   %eax,%eax
  802009:	0f 88 2c 01 00 00    	js     80213b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200f:	83 ec 04             	sub    $0x4,%esp
  802012:	68 07 04 00 00       	push   $0x407
  802017:	ff 75 f4             	pushl  -0xc(%ebp)
  80201a:	6a 00                	push   $0x0
  80201c:	e8 b0 ec ff ff       	call   800cd1 <sys_page_alloc>
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	89 c2                	mov    %eax,%edx
  802026:	85 c0                	test   %eax,%eax
  802028:	0f 88 0d 01 00 00    	js     80213b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80202e:	83 ec 0c             	sub    $0xc,%esp
  802031:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	e8 ad f5 ff ff       	call   8015e7 <fd_alloc>
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	85 c0                	test   %eax,%eax
  802041:	0f 88 e2 00 00 00    	js     802129 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802047:	83 ec 04             	sub    $0x4,%esp
  80204a:	68 07 04 00 00       	push   $0x407
  80204f:	ff 75 f0             	pushl  -0x10(%ebp)
  802052:	6a 00                	push   $0x0
  802054:	e8 78 ec ff ff       	call   800cd1 <sys_page_alloc>
  802059:	89 c3                	mov    %eax,%ebx
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	0f 88 c3 00 00 00    	js     802129 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	ff 75 f4             	pushl  -0xc(%ebp)
  80206c:	e8 5f f5 ff ff       	call   8015d0 <fd2data>
  802071:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802073:	83 c4 0c             	add    $0xc,%esp
  802076:	68 07 04 00 00       	push   $0x407
  80207b:	50                   	push   %eax
  80207c:	6a 00                	push   $0x0
  80207e:	e8 4e ec ff ff       	call   800cd1 <sys_page_alloc>
  802083:	89 c3                	mov    %eax,%ebx
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	85 c0                	test   %eax,%eax
  80208a:	0f 88 89 00 00 00    	js     802119 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802090:	83 ec 0c             	sub    $0xc,%esp
  802093:	ff 75 f0             	pushl  -0x10(%ebp)
  802096:	e8 35 f5 ff ff       	call   8015d0 <fd2data>
  80209b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020a2:	50                   	push   %eax
  8020a3:	6a 00                	push   $0x0
  8020a5:	56                   	push   %esi
  8020a6:	6a 00                	push   $0x0
  8020a8:	e8 67 ec ff ff       	call   800d14 <sys_page_map>
  8020ad:	89 c3                	mov    %eax,%ebx
  8020af:	83 c4 20             	add    $0x20,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	78 55                	js     80210b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020b6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020cb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020e0:	83 ec 0c             	sub    $0xc,%esp
  8020e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e6:	e8 d5 f4 ff ff       	call   8015c0 <fd2num>
  8020eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020f0:	83 c4 04             	add    $0x4,%esp
  8020f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f6:	e8 c5 f4 ff ff       	call   8015c0 <fd2num>
  8020fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020fe:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	ba 00 00 00 00       	mov    $0x0,%edx
  802109:	eb 30                	jmp    80213b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80210b:	83 ec 08             	sub    $0x8,%esp
  80210e:	56                   	push   %esi
  80210f:	6a 00                	push   $0x0
  802111:	e8 40 ec ff ff       	call   800d56 <sys_page_unmap>
  802116:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802119:	83 ec 08             	sub    $0x8,%esp
  80211c:	ff 75 f0             	pushl  -0x10(%ebp)
  80211f:	6a 00                	push   $0x0
  802121:	e8 30 ec ff ff       	call   800d56 <sys_page_unmap>
  802126:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802129:	83 ec 08             	sub    $0x8,%esp
  80212c:	ff 75 f4             	pushl  -0xc(%ebp)
  80212f:	6a 00                	push   $0x0
  802131:	e8 20 ec ff ff       	call   800d56 <sys_page_unmap>
  802136:	83 c4 10             	add    $0x10,%esp
  802139:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    

00802144 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80214d:	50                   	push   %eax
  80214e:	ff 75 08             	pushl  0x8(%ebp)
  802151:	e8 e0 f4 ff ff       	call   801636 <fd_lookup>
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	85 c0                	test   %eax,%eax
  80215b:	78 18                	js     802175 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80215d:	83 ec 0c             	sub    $0xc,%esp
  802160:	ff 75 f4             	pushl  -0xc(%ebp)
  802163:	e8 68 f4 ff ff       	call   8015d0 <fd2data>
	return _pipeisclosed(fd, p);
  802168:	89 c2                	mov    %eax,%edx
  80216a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216d:	e8 18 fd ff ff       	call   801e8a <_pipeisclosed>
  802172:	83 c4 10             	add    $0x10,%esp
}
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80217a:	b8 00 00 00 00       	mov    $0x0,%eax
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    

00802181 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802187:	68 c2 2c 80 00       	push   $0x802cc2
  80218c:	ff 75 0c             	pushl  0xc(%ebp)
  80218f:	e8 3a e7 ff ff       	call   8008ce <strcpy>
	return 0;
}
  802194:	b8 00 00 00 00       	mov    $0x0,%eax
  802199:	c9                   	leave  
  80219a:	c3                   	ret    

0080219b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	57                   	push   %edi
  80219f:	56                   	push   %esi
  8021a0:	53                   	push   %ebx
  8021a1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b2:	eb 2d                	jmp    8021e1 <devcons_write+0x46>
		m = n - tot;
  8021b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021b7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021b9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021bc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021c1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021c4:	83 ec 04             	sub    $0x4,%esp
  8021c7:	53                   	push   %ebx
  8021c8:	03 45 0c             	add    0xc(%ebp),%eax
  8021cb:	50                   	push   %eax
  8021cc:	57                   	push   %edi
  8021cd:	e8 8e e8 ff ff       	call   800a60 <memmove>
		sys_cputs(buf, m);
  8021d2:	83 c4 08             	add    $0x8,%esp
  8021d5:	53                   	push   %ebx
  8021d6:	57                   	push   %edi
  8021d7:	e8 39 ea ff ff       	call   800c15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021dc:	01 de                	add    %ebx,%esi
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021e6:	72 cc                	jb     8021b4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021eb:	5b                   	pop    %ebx
  8021ec:	5e                   	pop    %esi
  8021ed:	5f                   	pop    %edi
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    

008021f0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	83 ec 08             	sub    $0x8,%esp
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021ff:	74 2a                	je     80222b <devcons_read+0x3b>
  802201:	eb 05                	jmp    802208 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802203:	e8 aa ea ff ff       	call   800cb2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802208:	e8 26 ea ff ff       	call   800c33 <sys_cgetc>
  80220d:	85 c0                	test   %eax,%eax
  80220f:	74 f2                	je     802203 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802211:	85 c0                	test   %eax,%eax
  802213:	78 16                	js     80222b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802215:	83 f8 04             	cmp    $0x4,%eax
  802218:	74 0c                	je     802226 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80221a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221d:	88 02                	mov    %al,(%edx)
	return 1;
  80221f:	b8 01 00 00 00       	mov    $0x1,%eax
  802224:	eb 05                	jmp    80222b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802226:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    

0080222d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80222d:	55                   	push   %ebp
  80222e:	89 e5                	mov    %esp,%ebp
  802230:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802233:	8b 45 08             	mov    0x8(%ebp),%eax
  802236:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802239:	6a 01                	push   $0x1
  80223b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80223e:	50                   	push   %eax
  80223f:	e8 d1 e9 ff ff       	call   800c15 <sys_cputs>
}
  802244:	83 c4 10             	add    $0x10,%esp
  802247:	c9                   	leave  
  802248:	c3                   	ret    

00802249 <getchar>:

int
getchar(void)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80224f:	6a 01                	push   $0x1
  802251:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802254:	50                   	push   %eax
  802255:	6a 00                	push   $0x0
  802257:	e8 43 f6 ff ff       	call   80189f <read>
	if (r < 0)
  80225c:	83 c4 10             	add    $0x10,%esp
  80225f:	85 c0                	test   %eax,%eax
  802261:	78 0f                	js     802272 <getchar+0x29>
		return r;
	if (r < 1)
  802263:	85 c0                	test   %eax,%eax
  802265:	7e 06                	jle    80226d <getchar+0x24>
		return -E_EOF;
	return c;
  802267:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80226b:	eb 05                	jmp    802272 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80226d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802272:	c9                   	leave  
  802273:	c3                   	ret    

00802274 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80227a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227d:	50                   	push   %eax
  80227e:	ff 75 08             	pushl  0x8(%ebp)
  802281:	e8 b0 f3 ff ff       	call   801636 <fd_lookup>
  802286:	83 c4 10             	add    $0x10,%esp
  802289:	85 c0                	test   %eax,%eax
  80228b:	78 11                	js     80229e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80228d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802290:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802296:	39 10                	cmp    %edx,(%eax)
  802298:	0f 94 c0             	sete   %al
  80229b:	0f b6 c0             	movzbl %al,%eax
}
  80229e:	c9                   	leave  
  80229f:	c3                   	ret    

008022a0 <opencons>:

int
opencons(void)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a9:	50                   	push   %eax
  8022aa:	e8 38 f3 ff ff       	call   8015e7 <fd_alloc>
  8022af:	83 c4 10             	add    $0x10,%esp
		return r;
  8022b2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	78 3e                	js     8022f6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022b8:	83 ec 04             	sub    $0x4,%esp
  8022bb:	68 07 04 00 00       	push   $0x407
  8022c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c3:	6a 00                	push   $0x0
  8022c5:	e8 07 ea ff ff       	call   800cd1 <sys_page_alloc>
  8022ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8022cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 23                	js     8022f6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022e8:	83 ec 0c             	sub    $0xc,%esp
  8022eb:	50                   	push   %eax
  8022ec:	e8 cf f2 ff ff       	call   8015c0 <fd2num>
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	83 c4 10             	add    $0x10,%esp
}
  8022f6:	89 d0                	mov    %edx,%eax
  8022f8:	c9                   	leave  
  8022f9:	c3                   	ret    

008022fa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022fa:	55                   	push   %ebp
  8022fb:	89 e5                	mov    %esp,%ebp
  8022fd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802300:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802307:	75 2a                	jne    802333 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802309:	83 ec 04             	sub    $0x4,%esp
  80230c:	6a 07                	push   $0x7
  80230e:	68 00 f0 bf ee       	push   $0xeebff000
  802313:	6a 00                	push   $0x0
  802315:	e8 b7 e9 ff ff       	call   800cd1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80231a:	83 c4 10             	add    $0x10,%esp
  80231d:	85 c0                	test   %eax,%eax
  80231f:	79 12                	jns    802333 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802321:	50                   	push   %eax
  802322:	68 38 2b 80 00       	push   $0x802b38
  802327:	6a 23                	push   $0x23
  802329:	68 ce 2c 80 00       	push   $0x802cce
  80232e:	e8 3d df ff ff       	call   800270 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802333:	8b 45 08             	mov    0x8(%ebp),%eax
  802336:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80233b:	83 ec 08             	sub    $0x8,%esp
  80233e:	68 65 23 80 00       	push   $0x802365
  802343:	6a 00                	push   $0x0
  802345:	e8 d2 ea ff ff       	call   800e1c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	85 c0                	test   %eax,%eax
  80234f:	79 12                	jns    802363 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802351:	50                   	push   %eax
  802352:	68 38 2b 80 00       	push   $0x802b38
  802357:	6a 2c                	push   $0x2c
  802359:	68 ce 2c 80 00       	push   $0x802cce
  80235e:	e8 0d df ff ff       	call   800270 <_panic>
	}
}
  802363:	c9                   	leave  
  802364:	c3                   	ret    

00802365 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802365:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802366:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80236b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80236d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802370:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802374:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802379:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80237d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80237f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802382:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802383:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802386:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802387:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802388:	c3                   	ret    
  802389:	66 90                	xchg   %ax,%ax
  80238b:	66 90                	xchg   %ax,%ax
  80238d:	66 90                	xchg   %ax,%ax
  80238f:	90                   	nop

00802390 <__udivdi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80239b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80239f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 f6                	test   %esi,%esi
  8023a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ad:	89 ca                	mov    %ecx,%edx
  8023af:	89 f8                	mov    %edi,%eax
  8023b1:	75 3d                	jne    8023f0 <__udivdi3+0x60>
  8023b3:	39 cf                	cmp    %ecx,%edi
  8023b5:	0f 87 c5 00 00 00    	ja     802480 <__udivdi3+0xf0>
  8023bb:	85 ff                	test   %edi,%edi
  8023bd:	89 fd                	mov    %edi,%ebp
  8023bf:	75 0b                	jne    8023cc <__udivdi3+0x3c>
  8023c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c6:	31 d2                	xor    %edx,%edx
  8023c8:	f7 f7                	div    %edi
  8023ca:	89 c5                	mov    %eax,%ebp
  8023cc:	89 c8                	mov    %ecx,%eax
  8023ce:	31 d2                	xor    %edx,%edx
  8023d0:	f7 f5                	div    %ebp
  8023d2:	89 c1                	mov    %eax,%ecx
  8023d4:	89 d8                	mov    %ebx,%eax
  8023d6:	89 cf                	mov    %ecx,%edi
  8023d8:	f7 f5                	div    %ebp
  8023da:	89 c3                	mov    %eax,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	39 ce                	cmp    %ecx,%esi
  8023f2:	77 74                	ja     802468 <__udivdi3+0xd8>
  8023f4:	0f bd fe             	bsr    %esi,%edi
  8023f7:	83 f7 1f             	xor    $0x1f,%edi
  8023fa:	0f 84 98 00 00 00    	je     802498 <__udivdi3+0x108>
  802400:	bb 20 00 00 00       	mov    $0x20,%ebx
  802405:	89 f9                	mov    %edi,%ecx
  802407:	89 c5                	mov    %eax,%ebp
  802409:	29 fb                	sub    %edi,%ebx
  80240b:	d3 e6                	shl    %cl,%esi
  80240d:	89 d9                	mov    %ebx,%ecx
  80240f:	d3 ed                	shr    %cl,%ebp
  802411:	89 f9                	mov    %edi,%ecx
  802413:	d3 e0                	shl    %cl,%eax
  802415:	09 ee                	or     %ebp,%esi
  802417:	89 d9                	mov    %ebx,%ecx
  802419:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80241d:	89 d5                	mov    %edx,%ebp
  80241f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802423:	d3 ed                	shr    %cl,%ebp
  802425:	89 f9                	mov    %edi,%ecx
  802427:	d3 e2                	shl    %cl,%edx
  802429:	89 d9                	mov    %ebx,%ecx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	09 c2                	or     %eax,%edx
  80242f:	89 d0                	mov    %edx,%eax
  802431:	89 ea                	mov    %ebp,%edx
  802433:	f7 f6                	div    %esi
  802435:	89 d5                	mov    %edx,%ebp
  802437:	89 c3                	mov    %eax,%ebx
  802439:	f7 64 24 0c          	mull   0xc(%esp)
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	72 10                	jb     802451 <__udivdi3+0xc1>
  802441:	8b 74 24 08          	mov    0x8(%esp),%esi
  802445:	89 f9                	mov    %edi,%ecx
  802447:	d3 e6                	shl    %cl,%esi
  802449:	39 c6                	cmp    %eax,%esi
  80244b:	73 07                	jae    802454 <__udivdi3+0xc4>
  80244d:	39 d5                	cmp    %edx,%ebp
  80244f:	75 03                	jne    802454 <__udivdi3+0xc4>
  802451:	83 eb 01             	sub    $0x1,%ebx
  802454:	31 ff                	xor    %edi,%edi
  802456:	89 d8                	mov    %ebx,%eax
  802458:	89 fa                	mov    %edi,%edx
  80245a:	83 c4 1c             	add    $0x1c,%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5f                   	pop    %edi
  802460:	5d                   	pop    %ebp
  802461:	c3                   	ret    
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	31 ff                	xor    %edi,%edi
  80246a:	31 db                	xor    %ebx,%ebx
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	89 fa                	mov    %edi,%edx
  802470:	83 c4 1c             	add    $0x1c,%esp
  802473:	5b                   	pop    %ebx
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	90                   	nop
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	89 d8                	mov    %ebx,%eax
  802482:	f7 f7                	div    %edi
  802484:	31 ff                	xor    %edi,%edi
  802486:	89 c3                	mov    %eax,%ebx
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	89 fa                	mov    %edi,%edx
  80248c:	83 c4 1c             	add    $0x1c,%esp
  80248f:	5b                   	pop    %ebx
  802490:	5e                   	pop    %esi
  802491:	5f                   	pop    %edi
  802492:	5d                   	pop    %ebp
  802493:	c3                   	ret    
  802494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802498:	39 ce                	cmp    %ecx,%esi
  80249a:	72 0c                	jb     8024a8 <__udivdi3+0x118>
  80249c:	31 db                	xor    %ebx,%ebx
  80249e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024a2:	0f 87 34 ff ff ff    	ja     8023dc <__udivdi3+0x4c>
  8024a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024ad:	e9 2a ff ff ff       	jmp    8023dc <__udivdi3+0x4c>
  8024b2:	66 90                	xchg   %ax,%ax
  8024b4:	66 90                	xchg   %ax,%ax
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	66 90                	xchg   %ax,%ax
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__umoddi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 1c             	sub    $0x1c,%esp
  8024c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024d7:	85 d2                	test   %edx,%edx
  8024d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024e1:	89 f3                	mov    %esi,%ebx
  8024e3:	89 3c 24             	mov    %edi,(%esp)
  8024e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ea:	75 1c                	jne    802508 <__umoddi3+0x48>
  8024ec:	39 f7                	cmp    %esi,%edi
  8024ee:	76 50                	jbe    802540 <__umoddi3+0x80>
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 f2                	mov    %esi,%edx
  8024f4:	f7 f7                	div    %edi
  8024f6:	89 d0                	mov    %edx,%eax
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	39 f2                	cmp    %esi,%edx
  80250a:	89 d0                	mov    %edx,%eax
  80250c:	77 52                	ja     802560 <__umoddi3+0xa0>
  80250e:	0f bd ea             	bsr    %edx,%ebp
  802511:	83 f5 1f             	xor    $0x1f,%ebp
  802514:	75 5a                	jne    802570 <__umoddi3+0xb0>
  802516:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80251a:	0f 82 e0 00 00 00    	jb     802600 <__umoddi3+0x140>
  802520:	39 0c 24             	cmp    %ecx,(%esp)
  802523:	0f 86 d7 00 00 00    	jbe    802600 <__umoddi3+0x140>
  802529:	8b 44 24 08          	mov    0x8(%esp),%eax
  80252d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802531:	83 c4 1c             	add    $0x1c,%esp
  802534:	5b                   	pop    %ebx
  802535:	5e                   	pop    %esi
  802536:	5f                   	pop    %edi
  802537:	5d                   	pop    %ebp
  802538:	c3                   	ret    
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	85 ff                	test   %edi,%edi
  802542:	89 fd                	mov    %edi,%ebp
  802544:	75 0b                	jne    802551 <__umoddi3+0x91>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f7                	div    %edi
  80254f:	89 c5                	mov    %eax,%ebp
  802551:	89 f0                	mov    %esi,%eax
  802553:	31 d2                	xor    %edx,%edx
  802555:	f7 f5                	div    %ebp
  802557:	89 c8                	mov    %ecx,%eax
  802559:	f7 f5                	div    %ebp
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	eb 99                	jmp    8024f8 <__umoddi3+0x38>
  80255f:	90                   	nop
  802560:	89 c8                	mov    %ecx,%eax
  802562:	89 f2                	mov    %esi,%edx
  802564:	83 c4 1c             	add    $0x1c,%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5f                   	pop    %edi
  80256a:	5d                   	pop    %ebp
  80256b:	c3                   	ret    
  80256c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802570:	8b 34 24             	mov    (%esp),%esi
  802573:	bf 20 00 00 00       	mov    $0x20,%edi
  802578:	89 e9                	mov    %ebp,%ecx
  80257a:	29 ef                	sub    %ebp,%edi
  80257c:	d3 e0                	shl    %cl,%eax
  80257e:	89 f9                	mov    %edi,%ecx
  802580:	89 f2                	mov    %esi,%edx
  802582:	d3 ea                	shr    %cl,%edx
  802584:	89 e9                	mov    %ebp,%ecx
  802586:	09 c2                	or     %eax,%edx
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	89 14 24             	mov    %edx,(%esp)
  80258d:	89 f2                	mov    %esi,%edx
  80258f:	d3 e2                	shl    %cl,%edx
  802591:	89 f9                	mov    %edi,%ecx
  802593:	89 54 24 04          	mov    %edx,0x4(%esp)
  802597:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80259b:	d3 e8                	shr    %cl,%eax
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	89 c6                	mov    %eax,%esi
  8025a1:	d3 e3                	shl    %cl,%ebx
  8025a3:	89 f9                	mov    %edi,%ecx
  8025a5:	89 d0                	mov    %edx,%eax
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 e9                	mov    %ebp,%ecx
  8025ab:	09 d8                	or     %ebx,%eax
  8025ad:	89 d3                	mov    %edx,%ebx
  8025af:	89 f2                	mov    %esi,%edx
  8025b1:	f7 34 24             	divl   (%esp)
  8025b4:	89 d6                	mov    %edx,%esi
  8025b6:	d3 e3                	shl    %cl,%ebx
  8025b8:	f7 64 24 04          	mull   0x4(%esp)
  8025bc:	39 d6                	cmp    %edx,%esi
  8025be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025c2:	89 d1                	mov    %edx,%ecx
  8025c4:	89 c3                	mov    %eax,%ebx
  8025c6:	72 08                	jb     8025d0 <__umoddi3+0x110>
  8025c8:	75 11                	jne    8025db <__umoddi3+0x11b>
  8025ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ce:	73 0b                	jae    8025db <__umoddi3+0x11b>
  8025d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025d4:	1b 14 24             	sbb    (%esp),%edx
  8025d7:	89 d1                	mov    %edx,%ecx
  8025d9:	89 c3                	mov    %eax,%ebx
  8025db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025df:	29 da                	sub    %ebx,%edx
  8025e1:	19 ce                	sbb    %ecx,%esi
  8025e3:	89 f9                	mov    %edi,%ecx
  8025e5:	89 f0                	mov    %esi,%eax
  8025e7:	d3 e0                	shl    %cl,%eax
  8025e9:	89 e9                	mov    %ebp,%ecx
  8025eb:	d3 ea                	shr    %cl,%edx
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	d3 ee                	shr    %cl,%esi
  8025f1:	09 d0                	or     %edx,%eax
  8025f3:	89 f2                	mov    %esi,%edx
  8025f5:	83 c4 1c             	add    $0x1c,%esp
  8025f8:	5b                   	pop    %ebx
  8025f9:	5e                   	pop    %esi
  8025fa:	5f                   	pop    %edi
  8025fb:	5d                   	pop    %ebp
  8025fc:	c3                   	ret    
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi
  802600:	29 f9                	sub    %edi,%ecx
  802602:	19 d6                	sbb    %edx,%esi
  802604:	89 74 24 04          	mov    %esi,0x4(%esp)
  802608:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80260c:	e9 18 ff ff ff       	jmp    802529 <__umoddi3+0x69>
