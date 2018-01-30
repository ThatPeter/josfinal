
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
  80003b:	68 a0 25 80 00       	push   $0x8025a0
  800040:	e8 04 03 00 00       	call   800349 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 1f 1f 00 00       	call   801f6f <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 b9 25 80 00       	push   $0x8025b9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 c2 25 80 00       	push   $0x8025c2
  800064:	e8 07 02 00 00       	call   800270 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 8a 0f 00 00       	call   800ff8 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 d6 25 80 00       	push   $0x8025d6
  80007a:	6a 10                	push   $0x10
  80007c:	68 c2 25 80 00       	push   $0x8025c2
  800081:	e8 ea 01 00 00       	call   800270 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 4c 16 00 00       	call   8016e1 <close>
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
  8000a3:	e8 1a 20 00 00       	call   8020c2 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 df 25 80 00       	push   $0x8025df
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
  8000d7:	e8 40 13 00 00       	call   80141c <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 fa 25 80 00       	push   $0x8025fa
  8000e8:	e8 5c 02 00 00       	call   800349 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	69 c6 d4 00 00 00    	imul   $0xd4,%esi,%eax
  8000fc:	c1 f8 02             	sar    $0x2,%eax
  8000ff:	69 c0 1d 52 13 8c    	imul   $0x8c13521d,%eax,%eax
  800105:	50                   	push   %eax
  800106:	68 05 26 80 00       	push   $0x802605
  80010b:	e8 39 02 00 00       	call   800349 <cprintf>
	dup(p[0], 10);
  800110:	83 c4 08             	add    $0x8,%esp
  800113:	6a 0a                	push   $0xa
  800115:	ff 75 f0             	pushl  -0x10(%ebp)
  800118:	e8 14 16 00 00       	call   801731 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	69 de d4 00 00 00    	imul   $0xd4,%esi,%ebx
  800126:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80012c:	eb 10                	jmp    80013e <umain+0x10b>
		dup(p[0], 10);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	6a 0a                	push   $0xa
  800133:	ff 75 f0             	pushl  -0x10(%ebp)
  800136:	e8 f6 15 00 00       	call   801731 <dup>
  80013b:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  80013e:	8b 93 ac 00 00 00    	mov    0xac(%ebx),%edx
  800144:	83 fa 02             	cmp    $0x2,%edx
  800147:	74 e5                	je     80012e <umain+0xfb>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 10 26 80 00       	push   $0x802610
  800151:	e8 f3 01 00 00       	call   800349 <cprintf>
	if (pipeisclosed(p[0]))
  800156:	83 c4 04             	add    $0x4,%esp
  800159:	ff 75 f0             	pushl  -0x10(%ebp)
  80015c:	e8 61 1f 00 00       	call   8020c2 <pipeisclosed>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	74 14                	je     80017c <umain+0x149>
		panic("somehow the other end of p[0] got closed!");
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	68 6c 26 80 00       	push   $0x80266c
  800170:	6a 3a                	push   $0x3a
  800172:	68 c2 25 80 00       	push   $0x8025c2
  800177:	e8 f4 00 00 00       	call   800270 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017c:	83 ec 08             	sub    $0x8,%esp
  80017f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	ff 75 f0             	pushl  -0x10(%ebp)
  800186:	e8 29 14 00 00       	call   8015b4 <fd_lookup>
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 12                	jns    8001a4 <umain+0x171>
		panic("cannot look up p[0]: %e", r);
  800192:	50                   	push   %eax
  800193:	68 26 26 80 00       	push   $0x802626
  800198:	6a 3c                	push   $0x3c
  80019a:	68 c2 25 80 00       	push   $0x8025c2
  80019f:	e8 cc 00 00 00       	call   800270 <_panic>
	va = fd2data(fd);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001aa:	e8 9f 13 00 00       	call   80154e <fd2data>
	if (pageref(va) != 3+1)
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 9e 1b 00 00       	call   801d55 <pageref>
  8001b7:	83 c4 10             	add    $0x10,%esp
  8001ba:	83 f8 04             	cmp    $0x4,%eax
  8001bd:	74 12                	je     8001d1 <umain+0x19e>
		cprintf("\nchild detected race\n");
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	68 3e 26 80 00       	push   $0x80263e
  8001c7:	e8 7d 01 00 00       	call   800349 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	eb 15                	jmp    8001e6 <umain+0x1b3>
	else
		cprintf("\nrace didn't happen\n", max);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	68 c8 00 00 00       	push   $0xc8
  8001d9:	68 54 26 80 00       	push   $0x802654
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
  800202:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020d:	a3 04 40 80 00       	mov    %eax,0x804004

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
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
  80025c:	e8 ab 14 00 00       	call   80170c <close_all>
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
  80028e:	68 a0 26 80 00       	push   $0x8026a0
  800293:	e8 b1 00 00 00       	call   800349 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800298:	83 c4 18             	add    $0x18,%esp
  80029b:	53                   	push   %ebx
  80029c:	ff 75 10             	pushl  0x10(%ebp)
  80029f:	e8 54 00 00 00       	call   8002f8 <vcprintf>
	cprintf("\n");
  8002a4:	c7 04 24 5b 2a 80 00 	movl   $0x802a5b,(%esp)
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
  8003ac:	e8 5f 1f 00 00       	call   802310 <__udivdi3>
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
  8003ef:	e8 4c 20 00 00       	call   802440 <__umoddi3>
  8003f4:	83 c4 14             	add    $0x14,%esp
  8003f7:	0f be 80 c3 26 80 00 	movsbl 0x8026c3(%eax),%eax
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
  8004f3:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
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
  8005b7:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	75 18                	jne    8005da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005c2:	50                   	push   %eax
  8005c3:	68 db 26 80 00       	push   $0x8026db
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
  8005db:	68 39 2b 80 00       	push   $0x802b39
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
  8005ff:	b8 d4 26 80 00       	mov    $0x8026d4,%eax
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
  800c7a:	68 bf 29 80 00       	push   $0x8029bf
  800c7f:	6a 23                	push   $0x23
  800c81:	68 dc 29 80 00       	push   $0x8029dc
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
  800cfb:	68 bf 29 80 00       	push   $0x8029bf
  800d00:	6a 23                	push   $0x23
  800d02:	68 dc 29 80 00       	push   $0x8029dc
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
  800d3d:	68 bf 29 80 00       	push   $0x8029bf
  800d42:	6a 23                	push   $0x23
  800d44:	68 dc 29 80 00       	push   $0x8029dc
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
  800d7f:	68 bf 29 80 00       	push   $0x8029bf
  800d84:	6a 23                	push   $0x23
  800d86:	68 dc 29 80 00       	push   $0x8029dc
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
  800dc1:	68 bf 29 80 00       	push   $0x8029bf
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 dc 29 80 00       	push   $0x8029dc
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
  800e03:	68 bf 29 80 00       	push   $0x8029bf
  800e08:	6a 23                	push   $0x23
  800e0a:	68 dc 29 80 00       	push   $0x8029dc
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
  800e45:	68 bf 29 80 00       	push   $0x8029bf
  800e4a:	6a 23                	push   $0x23
  800e4c:	68 dc 29 80 00       	push   $0x8029dc
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
  800ea9:	68 bf 29 80 00       	push   $0x8029bf
  800eae:	6a 23                	push   $0x23
  800eb0:	68 dc 29 80 00       	push   $0x8029dc
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
  800f48:	68 ea 29 80 00       	push   $0x8029ea
  800f4d:	6a 1f                	push   $0x1f
  800f4f:	68 fa 29 80 00       	push   $0x8029fa
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
  800f72:	68 05 2a 80 00       	push   $0x802a05
  800f77:	6a 2d                	push   $0x2d
  800f79:	68 fa 29 80 00       	push   $0x8029fa
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
  800fba:	68 05 2a 80 00       	push   $0x802a05
  800fbf:	6a 34                	push   $0x34
  800fc1:	68 fa 29 80 00       	push   $0x8029fa
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
  800fe2:	68 05 2a 80 00       	push   $0x802a05
  800fe7:	6a 38                	push   $0x38
  800fe9:	68 fa 29 80 00       	push   $0x8029fa
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
  801006:	e8 6d 12 00 00       	call   802278 <set_pgfault_handler>
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
  80101f:	68 1e 2a 80 00       	push   $0x802a1e
  801024:	68 85 00 00 00       	push   $0x85
  801029:	68 fa 29 80 00       	push   $0x8029fa
  80102e:	e8 3d f2 ff ff       	call   800270 <_panic>
  801033:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801035:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801039:	75 24                	jne    80105f <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80103b:	e8 53 fc ff ff       	call   800c93 <sys_getenvid>
  801040:	25 ff 03 00 00       	and    $0x3ff,%eax
  801045:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
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
  8010db:	68 2c 2a 80 00       	push   $0x802a2c
  8010e0:	6a 55                	push   $0x55
  8010e2:	68 fa 29 80 00       	push   $0x8029fa
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
  801120:	68 2c 2a 80 00       	push   $0x802a2c
  801125:	6a 5c                	push   $0x5c
  801127:	68 fa 29 80 00       	push   $0x8029fa
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
  80114e:	68 2c 2a 80 00       	push   $0x802a2c
  801153:	6a 60                	push   $0x60
  801155:	68 fa 29 80 00       	push   $0x8029fa
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
  801178:	68 2c 2a 80 00       	push   $0x802a2c
  80117d:	6a 65                	push   $0x65
  80117f:	68 fa 29 80 00       	push   $0x8029fa
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
  8011a0:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
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

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011e3:	68 36 02 80 00       	push   $0x800236
  8011e8:	e8 d5 fc ff ff       	call   800ec2 <sys_thread_create>

	return id;
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8011f5:	ff 75 08             	pushl  0x8(%ebp)
  8011f8:	e8 e5 fc ff ff       	call   800ee2 <sys_thread_free>
}
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801208:	ff 75 08             	pushl  0x8(%ebp)
  80120b:	e8 f2 fc ff ff       	call   800f02 <sys_thread_join>
}
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	56                   	push   %esi
  801219:	53                   	push   %ebx
  80121a:	8b 75 08             	mov    0x8(%ebp),%esi
  80121d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	6a 07                	push   $0x7
  801225:	6a 00                	push   $0x0
  801227:	56                   	push   %esi
  801228:	e8 a4 fa ff ff       	call   800cd1 <sys_page_alloc>
	if (r < 0) {
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	79 15                	jns    801249 <queue_append+0x34>
		panic("%e\n", r);
  801234:	50                   	push   %eax
  801235:	68 72 2a 80 00       	push   $0x802a72
  80123a:	68 d5 00 00 00       	push   $0xd5
  80123f:	68 fa 29 80 00       	push   $0x8029fa
  801244:	e8 27 f0 ff ff       	call   800270 <_panic>
	}	

	wt->envid = envid;
  801249:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80124f:	83 3b 00             	cmpl   $0x0,(%ebx)
  801252:	75 13                	jne    801267 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801254:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80125b:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801262:	00 00 00 
  801265:	eb 1b                	jmp    801282 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801267:	8b 43 04             	mov    0x4(%ebx),%eax
  80126a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801271:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801278:	00 00 00 
		queue->last = wt;
  80127b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801282:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801292:	8b 02                	mov    (%edx),%eax
  801294:	85 c0                	test   %eax,%eax
  801296:	75 17                	jne    8012af <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801298:	83 ec 04             	sub    $0x4,%esp
  80129b:	68 42 2a 80 00       	push   $0x802a42
  8012a0:	68 ec 00 00 00       	push   $0xec
  8012a5:	68 fa 29 80 00       	push   $0x8029fa
  8012aa:	e8 c1 ef ff ff       	call   800270 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8012af:	8b 48 04             	mov    0x4(%eax),%ecx
  8012b2:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8012b4:	8b 00                	mov    (%eax),%eax
}
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 04             	sub    $0x4,%esp
  8012bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8012c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c7:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	74 45                	je     801313 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8012ce:	e8 c0 f9 ff ff       	call   800c93 <sys_getenvid>
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	83 c3 04             	add    $0x4,%ebx
  8012d9:	53                   	push   %ebx
  8012da:	50                   	push   %eax
  8012db:	e8 35 ff ff ff       	call   801215 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012e0:	e8 ae f9 ff ff       	call   800c93 <sys_getenvid>
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	6a 04                	push   $0x4
  8012ea:	50                   	push   %eax
  8012eb:	e8 a8 fa ff ff       	call   800d98 <sys_env_set_status>

		if (r < 0) {
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	79 15                	jns    80130c <mutex_lock+0x54>
			panic("%e\n", r);
  8012f7:	50                   	push   %eax
  8012f8:	68 72 2a 80 00       	push   $0x802a72
  8012fd:	68 02 01 00 00       	push   $0x102
  801302:	68 fa 29 80 00       	push   $0x8029fa
  801307:	e8 64 ef ff ff       	call   800270 <_panic>
		}
		sys_yield();
  80130c:	e8 a1 f9 ff ff       	call   800cb2 <sys_yield>
  801311:	eb 08                	jmp    80131b <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801313:	e8 7b f9 ff ff       	call   800c93 <sys_getenvid>
  801318:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 04             	sub    $0x4,%esp
  801327:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  80132a:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80132e:	74 36                	je     801366 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	8d 43 04             	lea    0x4(%ebx),%eax
  801336:	50                   	push   %eax
  801337:	e8 4d ff ff ff       	call   801289 <queue_pop>
  80133c:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	6a 02                	push   $0x2
  801344:	50                   	push   %eax
  801345:	e8 4e fa ff ff       	call   800d98 <sys_env_set_status>
		if (r < 0) {
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	79 1d                	jns    80136e <mutex_unlock+0x4e>
			panic("%e\n", r);
  801351:	50                   	push   %eax
  801352:	68 72 2a 80 00       	push   $0x802a72
  801357:	68 16 01 00 00       	push   $0x116
  80135c:	68 fa 29 80 00       	push   $0x8029fa
  801361:	e8 0a ef ff ff       	call   800270 <_panic>
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
  80136b:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80136e:	e8 3f f9 ff ff       	call   800cb2 <sys_yield>
}
  801373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	53                   	push   %ebx
  80137c:	83 ec 04             	sub    $0x4,%esp
  80137f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801382:	e8 0c f9 ff ff       	call   800c93 <sys_getenvid>
  801387:	83 ec 04             	sub    $0x4,%esp
  80138a:	6a 07                	push   $0x7
  80138c:	53                   	push   %ebx
  80138d:	50                   	push   %eax
  80138e:	e8 3e f9 ff ff       	call   800cd1 <sys_page_alloc>
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	79 15                	jns    8013af <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80139a:	50                   	push   %eax
  80139b:	68 5d 2a 80 00       	push   $0x802a5d
  8013a0:	68 23 01 00 00       	push   $0x123
  8013a5:	68 fa 29 80 00       	push   $0x8029fa
  8013aa:	e8 c1 ee ff ff       	call   800270 <_panic>
	}	
	mtx->locked = 0;
  8013af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  8013b5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  8013bc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  8013c3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    

008013cf <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8013d7:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8013da:	eb 20                	jmp    8013fc <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8013dc:	83 ec 0c             	sub    $0xc,%esp
  8013df:	56                   	push   %esi
  8013e0:	e8 a4 fe ff ff       	call   801289 <queue_pop>
  8013e5:	83 c4 08             	add    $0x8,%esp
  8013e8:	6a 02                	push   $0x2
  8013ea:	50                   	push   %eax
  8013eb:	e8 a8 f9 ff ff       	call   800d98 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8013f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8013f3:	8b 40 04             	mov    0x4(%eax),%eax
  8013f6:	89 43 04             	mov    %eax,0x4(%ebx)
  8013f9:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8013fc:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801400:	75 da                	jne    8013dc <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	68 00 10 00 00       	push   $0x1000
  80140a:	6a 00                	push   $0x0
  80140c:	53                   	push   %ebx
  80140d:	e8 01 f6 ff ff       	call   800a13 <memset>
	mtx = NULL;
}
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	56                   	push   %esi
  801420:	53                   	push   %ebx
  801421:	8b 75 08             	mov    0x8(%ebp),%esi
  801424:	8b 45 0c             	mov    0xc(%ebp),%eax
  801427:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80142a:	85 c0                	test   %eax,%eax
  80142c:	75 12                	jne    801440 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	68 00 00 c0 ee       	push   $0xeec00000
  801436:	e8 46 fa ff ff       	call   800e81 <sys_ipc_recv>
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	eb 0c                	jmp    80144c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	50                   	push   %eax
  801444:	e8 38 fa ff ff       	call   800e81 <sys_ipc_recv>
  801449:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80144c:	85 f6                	test   %esi,%esi
  80144e:	0f 95 c1             	setne  %cl
  801451:	85 db                	test   %ebx,%ebx
  801453:	0f 95 c2             	setne  %dl
  801456:	84 d1                	test   %dl,%cl
  801458:	74 09                	je     801463 <ipc_recv+0x47>
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	c1 ea 1f             	shr    $0x1f,%edx
  80145f:	84 d2                	test   %dl,%dl
  801461:	75 2d                	jne    801490 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801463:	85 f6                	test   %esi,%esi
  801465:	74 0d                	je     801474 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801467:	a1 04 40 80 00       	mov    0x804004,%eax
  80146c:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  801472:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801474:	85 db                	test   %ebx,%ebx
  801476:	74 0d                	je     801485 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801478:	a1 04 40 80 00       	mov    0x804004,%eax
  80147d:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801483:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801485:	a1 04 40 80 00       	mov    0x804004,%eax
  80148a:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  801490:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	57                   	push   %edi
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 0c             	sub    $0xc,%esp
  8014a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8014a9:	85 db                	test   %ebx,%ebx
  8014ab:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8014b0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8014b3:	ff 75 14             	pushl  0x14(%ebp)
  8014b6:	53                   	push   %ebx
  8014b7:	56                   	push   %esi
  8014b8:	57                   	push   %edi
  8014b9:	e8 a0 f9 ff ff       	call   800e5e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	c1 ea 1f             	shr    $0x1f,%edx
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	84 d2                	test   %dl,%dl
  8014c8:	74 17                	je     8014e1 <ipc_send+0x4a>
  8014ca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014cd:	74 12                	je     8014e1 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8014cf:	50                   	push   %eax
  8014d0:	68 76 2a 80 00       	push   $0x802a76
  8014d5:	6a 47                	push   $0x47
  8014d7:	68 84 2a 80 00       	push   $0x802a84
  8014dc:	e8 8f ed ff ff       	call   800270 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8014e1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014e4:	75 07                	jne    8014ed <ipc_send+0x56>
			sys_yield();
  8014e6:	e8 c7 f7 ff ff       	call   800cb2 <sys_yield>
  8014eb:	eb c6                	jmp    8014b3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	75 c2                	jne    8014b3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8014f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5f                   	pop    %edi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801504:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80150a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801510:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  801516:	39 ca                	cmp    %ecx,%edx
  801518:	75 13                	jne    80152d <ipc_find_env+0x34>
			return envs[i].env_id;
  80151a:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  801520:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801525:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80152b:	eb 0f                	jmp    80153c <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80152d:	83 c0 01             	add    $0x1,%eax
  801530:	3d 00 04 00 00       	cmp    $0x400,%eax
  801535:	75 cd                	jne    801504 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801541:	8b 45 08             	mov    0x8(%ebp),%eax
  801544:	05 00 00 00 30       	add    $0x30000000,%eax
  801549:	c1 e8 0c             	shr    $0xc,%eax
}
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801551:	8b 45 08             	mov    0x8(%ebp),%eax
  801554:	05 00 00 00 30       	add    $0x30000000,%eax
  801559:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80155e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801570:	89 c2                	mov    %eax,%edx
  801572:	c1 ea 16             	shr    $0x16,%edx
  801575:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80157c:	f6 c2 01             	test   $0x1,%dl
  80157f:	74 11                	je     801592 <fd_alloc+0x2d>
  801581:	89 c2                	mov    %eax,%edx
  801583:	c1 ea 0c             	shr    $0xc,%edx
  801586:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158d:	f6 c2 01             	test   $0x1,%dl
  801590:	75 09                	jne    80159b <fd_alloc+0x36>
			*fd_store = fd;
  801592:	89 01                	mov    %eax,(%ecx)
			return 0;
  801594:	b8 00 00 00 00       	mov    $0x0,%eax
  801599:	eb 17                	jmp    8015b2 <fd_alloc+0x4d>
  80159b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015a0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015a5:	75 c9                	jne    801570 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8015ad:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015ba:	83 f8 1f             	cmp    $0x1f,%eax
  8015bd:	77 36                	ja     8015f5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015bf:	c1 e0 0c             	shl    $0xc,%eax
  8015c2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	c1 ea 16             	shr    $0x16,%edx
  8015cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015d3:	f6 c2 01             	test   $0x1,%dl
  8015d6:	74 24                	je     8015fc <fd_lookup+0x48>
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	c1 ea 0c             	shr    $0xc,%edx
  8015dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015e4:	f6 c2 01             	test   $0x1,%dl
  8015e7:	74 1a                	je     801603 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ec:	89 02                	mov    %eax,(%edx)
	return 0;
  8015ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f3:	eb 13                	jmp    801608 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fa:	eb 0c                	jmp    801608 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801601:	eb 05                	jmp    801608 <fd_lookup+0x54>
  801603:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801613:	ba 10 2b 80 00       	mov    $0x802b10,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801618:	eb 13                	jmp    80162d <dev_lookup+0x23>
  80161a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80161d:	39 08                	cmp    %ecx,(%eax)
  80161f:	75 0c                	jne    80162d <dev_lookup+0x23>
			*dev = devtab[i];
  801621:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801624:	89 01                	mov    %eax,(%ecx)
			return 0;
  801626:	b8 00 00 00 00       	mov    $0x0,%eax
  80162b:	eb 31                	jmp    80165e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80162d:	8b 02                	mov    (%edx),%eax
  80162f:	85 c0                	test   %eax,%eax
  801631:	75 e7                	jne    80161a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801633:	a1 04 40 80 00       	mov    0x804004,%eax
  801638:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80163e:	83 ec 04             	sub    $0x4,%esp
  801641:	51                   	push   %ecx
  801642:	50                   	push   %eax
  801643:	68 90 2a 80 00       	push   $0x802a90
  801648:	e8 fc ec ff ff       	call   800349 <cprintf>
	*dev = 0;
  80164d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801650:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
  801665:	83 ec 10             	sub    $0x10,%esp
  801668:	8b 75 08             	mov    0x8(%ebp),%esi
  80166b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80166e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801678:	c1 e8 0c             	shr    $0xc,%eax
  80167b:	50                   	push   %eax
  80167c:	e8 33 ff ff ff       	call   8015b4 <fd_lookup>
  801681:	83 c4 08             	add    $0x8,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 05                	js     80168d <fd_close+0x2d>
	    || fd != fd2)
  801688:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80168b:	74 0c                	je     801699 <fd_close+0x39>
		return (must_exist ? r : 0);
  80168d:	84 db                	test   %bl,%bl
  80168f:	ba 00 00 00 00       	mov    $0x0,%edx
  801694:	0f 44 c2             	cmove  %edx,%eax
  801697:	eb 41                	jmp    8016da <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	ff 36                	pushl  (%esi)
  8016a2:	e8 63 ff ff ff       	call   80160a <dev_lookup>
  8016a7:	89 c3                	mov    %eax,%ebx
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 1a                	js     8016ca <fd_close+0x6a>
		if (dev->dev_close)
  8016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8016b6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	74 0b                	je     8016ca <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	56                   	push   %esi
  8016c3:	ff d0                	call   *%eax
  8016c5:	89 c3                	mov    %eax,%ebx
  8016c7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	56                   	push   %esi
  8016ce:	6a 00                	push   $0x0
  8016d0:	e8 81 f6 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	89 d8                	mov    %ebx,%eax
}
  8016da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016dd:	5b                   	pop    %ebx
  8016de:	5e                   	pop    %esi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ea:	50                   	push   %eax
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 c1 fe ff ff       	call   8015b4 <fd_lookup>
  8016f3:	83 c4 08             	add    $0x8,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 10                	js     80170a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	6a 01                	push   $0x1
  8016ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801702:	e8 59 ff ff ff       	call   801660 <fd_close>
  801707:	83 c4 10             	add    $0x10,%esp
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <close_all>:

void
close_all(void)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801713:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801718:	83 ec 0c             	sub    $0xc,%esp
  80171b:	53                   	push   %ebx
  80171c:	e8 c0 ff ff ff       	call   8016e1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801721:	83 c3 01             	add    $0x1,%ebx
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	83 fb 20             	cmp    $0x20,%ebx
  80172a:	75 ec                	jne    801718 <close_all+0xc>
		close(i);
}
  80172c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	57                   	push   %edi
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 2c             	sub    $0x2c,%esp
  80173a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80173d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	ff 75 08             	pushl  0x8(%ebp)
  801744:	e8 6b fe ff ff       	call   8015b4 <fd_lookup>
  801749:	83 c4 08             	add    $0x8,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	0f 88 c1 00 00 00    	js     801815 <dup+0xe4>
		return r;
	close(newfdnum);
  801754:	83 ec 0c             	sub    $0xc,%esp
  801757:	56                   	push   %esi
  801758:	e8 84 ff ff ff       	call   8016e1 <close>

	newfd = INDEX2FD(newfdnum);
  80175d:	89 f3                	mov    %esi,%ebx
  80175f:	c1 e3 0c             	shl    $0xc,%ebx
  801762:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801768:	83 c4 04             	add    $0x4,%esp
  80176b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80176e:	e8 db fd ff ff       	call   80154e <fd2data>
  801773:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801775:	89 1c 24             	mov    %ebx,(%esp)
  801778:	e8 d1 fd ff ff       	call   80154e <fd2data>
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801783:	89 f8                	mov    %edi,%eax
  801785:	c1 e8 16             	shr    $0x16,%eax
  801788:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80178f:	a8 01                	test   $0x1,%al
  801791:	74 37                	je     8017ca <dup+0x99>
  801793:	89 f8                	mov    %edi,%eax
  801795:	c1 e8 0c             	shr    $0xc,%eax
  801798:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80179f:	f6 c2 01             	test   $0x1,%dl
  8017a2:	74 26                	je     8017ca <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8017b3:	50                   	push   %eax
  8017b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017b7:	6a 00                	push   $0x0
  8017b9:	57                   	push   %edi
  8017ba:	6a 00                	push   $0x0
  8017bc:	e8 53 f5 ff ff       	call   800d14 <sys_page_map>
  8017c1:	89 c7                	mov    %eax,%edi
  8017c3:	83 c4 20             	add    $0x20,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 2e                	js     8017f8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017cd:	89 d0                	mov    %edx,%eax
  8017cf:	c1 e8 0c             	shr    $0xc,%eax
  8017d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8017e1:	50                   	push   %eax
  8017e2:	53                   	push   %ebx
  8017e3:	6a 00                	push   $0x0
  8017e5:	52                   	push   %edx
  8017e6:	6a 00                	push   $0x0
  8017e8:	e8 27 f5 ff ff       	call   800d14 <sys_page_map>
  8017ed:	89 c7                	mov    %eax,%edi
  8017ef:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8017f2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017f4:	85 ff                	test   %edi,%edi
  8017f6:	79 1d                	jns    801815 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	53                   	push   %ebx
  8017fc:	6a 00                	push   $0x0
  8017fe:	e8 53 f5 ff ff       	call   800d56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801803:	83 c4 08             	add    $0x8,%esp
  801806:	ff 75 d4             	pushl  -0x2c(%ebp)
  801809:	6a 00                	push   $0x0
  80180b:	e8 46 f5 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	89 f8                	mov    %edi,%eax
}
  801815:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5f                   	pop    %edi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	53                   	push   %ebx
  801821:	83 ec 14             	sub    $0x14,%esp
  801824:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801827:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	53                   	push   %ebx
  80182c:	e8 83 fd ff ff       	call   8015b4 <fd_lookup>
  801831:	83 c4 08             	add    $0x8,%esp
  801834:	89 c2                	mov    %eax,%edx
  801836:	85 c0                	test   %eax,%eax
  801838:	78 70                	js     8018aa <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801840:	50                   	push   %eax
  801841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801844:	ff 30                	pushl  (%eax)
  801846:	e8 bf fd ff ff       	call   80160a <dev_lookup>
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 4f                	js     8018a1 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801852:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801855:	8b 42 08             	mov    0x8(%edx),%eax
  801858:	83 e0 03             	and    $0x3,%eax
  80185b:	83 f8 01             	cmp    $0x1,%eax
  80185e:	75 24                	jne    801884 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801860:	a1 04 40 80 00       	mov    0x804004,%eax
  801865:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	53                   	push   %ebx
  80186f:	50                   	push   %eax
  801870:	68 d4 2a 80 00       	push   $0x802ad4
  801875:	e8 cf ea ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801882:	eb 26                	jmp    8018aa <read+0x8d>
	}
	if (!dev->dev_read)
  801884:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801887:	8b 40 08             	mov    0x8(%eax),%eax
  80188a:	85 c0                	test   %eax,%eax
  80188c:	74 17                	je     8018a5 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80188e:	83 ec 04             	sub    $0x4,%esp
  801891:	ff 75 10             	pushl  0x10(%ebp)
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	52                   	push   %edx
  801898:	ff d0                	call   *%eax
  80189a:	89 c2                	mov    %eax,%edx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	eb 09                	jmp    8018aa <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	eb 05                	jmp    8018aa <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8018aa:	89 d0                	mov    %edx,%eax
  8018ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	57                   	push   %edi
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018c5:	eb 21                	jmp    8018e8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	89 f0                	mov    %esi,%eax
  8018cc:	29 d8                	sub    %ebx,%eax
  8018ce:	50                   	push   %eax
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	03 45 0c             	add    0xc(%ebp),%eax
  8018d4:	50                   	push   %eax
  8018d5:	57                   	push   %edi
  8018d6:	e8 42 ff ff ff       	call   80181d <read>
		if (m < 0)
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 10                	js     8018f2 <readn+0x41>
			return m;
		if (m == 0)
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	74 0a                	je     8018f0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018e6:	01 c3                	add    %eax,%ebx
  8018e8:	39 f3                	cmp    %esi,%ebx
  8018ea:	72 db                	jb     8018c7 <readn+0x16>
  8018ec:	89 d8                	mov    %ebx,%eax
  8018ee:	eb 02                	jmp    8018f2 <readn+0x41>
  8018f0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f5:	5b                   	pop    %ebx
  8018f6:	5e                   	pop    %esi
  8018f7:	5f                   	pop    %edi
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 14             	sub    $0x14,%esp
  801901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801904:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801907:	50                   	push   %eax
  801908:	53                   	push   %ebx
  801909:	e8 a6 fc ff ff       	call   8015b4 <fd_lookup>
  80190e:	83 c4 08             	add    $0x8,%esp
  801911:	89 c2                	mov    %eax,%edx
  801913:	85 c0                	test   %eax,%eax
  801915:	78 6b                	js     801982 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191d:	50                   	push   %eax
  80191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801921:	ff 30                	pushl  (%eax)
  801923:	e8 e2 fc ff ff       	call   80160a <dev_lookup>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 4a                	js     801979 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80192f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801932:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801936:	75 24                	jne    80195c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801938:	a1 04 40 80 00       	mov    0x804004,%eax
  80193d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801943:	83 ec 04             	sub    $0x4,%esp
  801946:	53                   	push   %ebx
  801947:	50                   	push   %eax
  801948:	68 f0 2a 80 00       	push   $0x802af0
  80194d:	e8 f7 e9 ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80195a:	eb 26                	jmp    801982 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80195c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195f:	8b 52 0c             	mov    0xc(%edx),%edx
  801962:	85 d2                	test   %edx,%edx
  801964:	74 17                	je     80197d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801966:	83 ec 04             	sub    $0x4,%esp
  801969:	ff 75 10             	pushl  0x10(%ebp)
  80196c:	ff 75 0c             	pushl  0xc(%ebp)
  80196f:	50                   	push   %eax
  801970:	ff d2                	call   *%edx
  801972:	89 c2                	mov    %eax,%edx
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	eb 09                	jmp    801982 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801979:	89 c2                	mov    %eax,%edx
  80197b:	eb 05                	jmp    801982 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80197d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801982:	89 d0                	mov    %edx,%eax
  801984:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <seek>:

int
seek(int fdnum, off_t offset)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	ff 75 08             	pushl  0x8(%ebp)
  801996:	e8 19 fc ff ff       	call   8015b4 <fd_lookup>
  80199b:	83 c4 08             	add    $0x8,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 0e                	js     8019b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8019a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 14             	sub    $0x14,%esp
  8019b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	53                   	push   %ebx
  8019c1:	e8 ee fb ff ff       	call   8015b4 <fd_lookup>
  8019c6:	83 c4 08             	add    $0x8,%esp
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 68                	js     801a37 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d5:	50                   	push   %eax
  8019d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d9:	ff 30                	pushl  (%eax)
  8019db:	e8 2a fc ff ff       	call   80160a <dev_lookup>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 47                	js     801a2e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019ee:	75 24                	jne    801a14 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8019fb:	83 ec 04             	sub    $0x4,%esp
  8019fe:	53                   	push   %ebx
  8019ff:	50                   	push   %eax
  801a00:	68 b0 2a 80 00       	push   $0x802ab0
  801a05:	e8 3f e9 ff ff       	call   800349 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a12:	eb 23                	jmp    801a37 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801a14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a17:	8b 52 18             	mov    0x18(%edx),%edx
  801a1a:	85 d2                	test   %edx,%edx
  801a1c:	74 14                	je     801a32 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	50                   	push   %eax
  801a25:	ff d2                	call   *%edx
  801a27:	89 c2                	mov    %eax,%edx
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	eb 09                	jmp    801a37 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a2e:	89 c2                	mov    %eax,%edx
  801a30:	eb 05                	jmp    801a37 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a32:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801a37:	89 d0                	mov    %edx,%eax
  801a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	53                   	push   %ebx
  801a42:	83 ec 14             	sub    $0x14,%esp
  801a45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4b:	50                   	push   %eax
  801a4c:	ff 75 08             	pushl  0x8(%ebp)
  801a4f:	e8 60 fb ff ff       	call   8015b4 <fd_lookup>
  801a54:	83 c4 08             	add    $0x8,%esp
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	78 58                	js     801ab5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a5d:	83 ec 08             	sub    $0x8,%esp
  801a60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a63:	50                   	push   %eax
  801a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a67:	ff 30                	pushl  (%eax)
  801a69:	e8 9c fb ff ff       	call   80160a <dev_lookup>
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 c0                	test   %eax,%eax
  801a73:	78 37                	js     801aac <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a78:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a7c:	74 32                	je     801ab0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a7e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a81:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a88:	00 00 00 
	stat->st_isdir = 0;
  801a8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a92:	00 00 00 
	stat->st_dev = dev;
  801a95:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a9b:	83 ec 08             	sub    $0x8,%esp
  801a9e:	53                   	push   %ebx
  801a9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa2:	ff 50 14             	call   *0x14(%eax)
  801aa5:	89 c2                	mov    %eax,%edx
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	eb 09                	jmp    801ab5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aac:	89 c2                	mov    %eax,%edx
  801aae:	eb 05                	jmp    801ab5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ab0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ab5:	89 d0                	mov    %edx,%eax
  801ab7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ac1:	83 ec 08             	sub    $0x8,%esp
  801ac4:	6a 00                	push   $0x0
  801ac6:	ff 75 08             	pushl  0x8(%ebp)
  801ac9:	e8 e3 01 00 00       	call   801cb1 <open>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 1b                	js     801af2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801ad7:	83 ec 08             	sub    $0x8,%esp
  801ada:	ff 75 0c             	pushl  0xc(%ebp)
  801add:	50                   	push   %eax
  801ade:	e8 5b ff ff ff       	call   801a3e <fstat>
  801ae3:	89 c6                	mov    %eax,%esi
	close(fd);
  801ae5:	89 1c 24             	mov    %ebx,(%esp)
  801ae8:	e8 f4 fb ff ff       	call   8016e1 <close>
	return r;
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	89 f0                	mov    %esi,%eax
}
  801af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	89 c6                	mov    %eax,%esi
  801b00:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b02:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b09:	75 12                	jne    801b1d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	6a 01                	push   $0x1
  801b10:	e8 e4 f9 ff ff       	call   8014f9 <ipc_find_env>
  801b15:	a3 00 40 80 00       	mov    %eax,0x804000
  801b1a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b1d:	6a 07                	push   $0x7
  801b1f:	68 00 50 80 00       	push   $0x805000
  801b24:	56                   	push   %esi
  801b25:	ff 35 00 40 80 00    	pushl  0x804000
  801b2b:	e8 67 f9 ff ff       	call   801497 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b30:	83 c4 0c             	add    $0xc,%esp
  801b33:	6a 00                	push   $0x0
  801b35:	53                   	push   %ebx
  801b36:	6a 00                	push   $0x0
  801b38:	e8 df f8 ff ff       	call   80141c <ipc_recv>
}
  801b3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b50:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b58:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b62:	b8 02 00 00 00       	mov    $0x2,%eax
  801b67:	e8 8d ff ff ff       	call   801af9 <fsipc>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b74:	8b 45 08             	mov    0x8(%ebp),%eax
  801b77:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b84:	b8 06 00 00 00       	mov    $0x6,%eax
  801b89:	e8 6b ff ff ff       	call   801af9 <fsipc>
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	53                   	push   %ebx
  801b94:	83 ec 04             	sub    $0x4,%esp
  801b97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  801baa:	b8 05 00 00 00       	mov    $0x5,%eax
  801baf:	e8 45 ff ff ff       	call   801af9 <fsipc>
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 2c                	js     801be4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	68 00 50 80 00       	push   $0x805000
  801bc0:	53                   	push   %ebx
  801bc1:	e8 08 ed ff ff       	call   8008ce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bc6:	a1 80 50 80 00       	mov    0x805080,%eax
  801bcb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bd1:	a1 84 50 80 00       	mov    0x805084,%eax
  801bd6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  801bf5:	8b 52 0c             	mov    0xc(%edx),%edx
  801bf8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801bfe:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c03:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c08:	0f 47 c2             	cmova  %edx,%eax
  801c0b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801c10:	50                   	push   %eax
  801c11:	ff 75 0c             	pushl  0xc(%ebp)
  801c14:	68 08 50 80 00       	push   $0x805008
  801c19:	e8 42 ee ff ff       	call   800a60 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c23:	b8 04 00 00 00       	mov    $0x4,%eax
  801c28:	e8 cc fe ff ff       	call   801af9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c42:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c48:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c52:	e8 a2 fe ff ff       	call   801af9 <fsipc>
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 4b                	js     801ca8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c5d:	39 c6                	cmp    %eax,%esi
  801c5f:	73 16                	jae    801c77 <devfile_read+0x48>
  801c61:	68 20 2b 80 00       	push   $0x802b20
  801c66:	68 27 2b 80 00       	push   $0x802b27
  801c6b:	6a 7c                	push   $0x7c
  801c6d:	68 3c 2b 80 00       	push   $0x802b3c
  801c72:	e8 f9 e5 ff ff       	call   800270 <_panic>
	assert(r <= PGSIZE);
  801c77:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c7c:	7e 16                	jle    801c94 <devfile_read+0x65>
  801c7e:	68 47 2b 80 00       	push   $0x802b47
  801c83:	68 27 2b 80 00       	push   $0x802b27
  801c88:	6a 7d                	push   $0x7d
  801c8a:	68 3c 2b 80 00       	push   $0x802b3c
  801c8f:	e8 dc e5 ff ff       	call   800270 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c94:	83 ec 04             	sub    $0x4,%esp
  801c97:	50                   	push   %eax
  801c98:	68 00 50 80 00       	push   $0x805000
  801c9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ca0:	e8 bb ed ff ff       	call   800a60 <memmove>
	return r;
  801ca5:	83 c4 10             	add    $0x10,%esp
}
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	53                   	push   %ebx
  801cb5:	83 ec 20             	sub    $0x20,%esp
  801cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cbb:	53                   	push   %ebx
  801cbc:	e8 d4 eb ff ff       	call   800895 <strlen>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cc9:	7f 67                	jg     801d32 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd1:	50                   	push   %eax
  801cd2:	e8 8e f8 ff ff       	call   801565 <fd_alloc>
  801cd7:	83 c4 10             	add    $0x10,%esp
		return r;
  801cda:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	78 57                	js     801d37 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	53                   	push   %ebx
  801ce4:	68 00 50 80 00       	push   $0x805000
  801ce9:	e8 e0 eb ff ff       	call   8008ce <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfe:	e8 f6 fd ff ff       	call   801af9 <fsipc>
  801d03:	89 c3                	mov    %eax,%ebx
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	79 14                	jns    801d20 <open+0x6f>
		fd_close(fd, 0);
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	6a 00                	push   $0x0
  801d11:	ff 75 f4             	pushl  -0xc(%ebp)
  801d14:	e8 47 f9 ff ff       	call   801660 <fd_close>
		return r;
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	89 da                	mov    %ebx,%edx
  801d1e:	eb 17                	jmp    801d37 <open+0x86>
	}

	return fd2num(fd);
  801d20:	83 ec 0c             	sub    $0xc,%esp
  801d23:	ff 75 f4             	pushl  -0xc(%ebp)
  801d26:	e8 13 f8 ff ff       	call   80153e <fd2num>
  801d2b:	89 c2                	mov    %eax,%edx
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	eb 05                	jmp    801d37 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d32:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d37:	89 d0                	mov    %edx,%eax
  801d39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d44:	ba 00 00 00 00       	mov    $0x0,%edx
  801d49:	b8 08 00 00 00       	mov    $0x8,%eax
  801d4e:	e8 a6 fd ff ff       	call   801af9 <fsipc>
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	c1 e8 16             	shr    $0x16,%eax
  801d60:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d67:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d6c:	f6 c1 01             	test   $0x1,%cl
  801d6f:	74 1d                	je     801d8e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d71:	c1 ea 0c             	shr    $0xc,%edx
  801d74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d7b:	f6 c2 01             	test   $0x1,%dl
  801d7e:	74 0e                	je     801d8e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d80:	c1 ea 0c             	shr    $0xc,%edx
  801d83:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d8a:	ef 
  801d8b:	0f b7 c0             	movzwl %ax,%eax
}
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    

00801d90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
  801d95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	ff 75 08             	pushl  0x8(%ebp)
  801d9e:	e8 ab f7 ff ff       	call   80154e <fd2data>
  801da3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801da5:	83 c4 08             	add    $0x8,%esp
  801da8:	68 53 2b 80 00       	push   $0x802b53
  801dad:	53                   	push   %ebx
  801dae:	e8 1b eb ff ff       	call   8008ce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801db3:	8b 46 04             	mov    0x4(%esi),%eax
  801db6:	2b 06                	sub    (%esi),%eax
  801db8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dbe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dc5:	00 00 00 
	stat->st_dev = &devpipe;
  801dc8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801dcf:	30 80 00 
	return 0;
}
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	53                   	push   %ebx
  801de2:	83 ec 0c             	sub    $0xc,%esp
  801de5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801de8:	53                   	push   %ebx
  801de9:	6a 00                	push   $0x0
  801deb:	e8 66 ef ff ff       	call   800d56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801df0:	89 1c 24             	mov    %ebx,(%esp)
  801df3:	e8 56 f7 ff ff       	call   80154e <fd2data>
  801df8:	83 c4 08             	add    $0x8,%esp
  801dfb:	50                   	push   %eax
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 53 ef ff ff       	call   800d56 <sys_page_unmap>
}
  801e03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    

00801e08 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	57                   	push   %edi
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 1c             	sub    $0x1c,%esp
  801e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e14:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e16:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1b:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	ff 75 e0             	pushl  -0x20(%ebp)
  801e27:	e8 29 ff ff ff       	call   801d55 <pageref>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	89 3c 24             	mov    %edi,(%esp)
  801e31:	e8 1f ff ff ff       	call   801d55 <pageref>
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	39 c3                	cmp    %eax,%ebx
  801e3b:	0f 94 c1             	sete   %cl
  801e3e:	0f b6 c9             	movzbl %cl,%ecx
  801e41:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e44:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e4a:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801e50:	39 ce                	cmp    %ecx,%esi
  801e52:	74 1e                	je     801e72 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801e54:	39 c3                	cmp    %eax,%ebx
  801e56:	75 be                	jne    801e16 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e58:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801e5e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e61:	50                   	push   %eax
  801e62:	56                   	push   %esi
  801e63:	68 5a 2b 80 00       	push   $0x802b5a
  801e68:	e8 dc e4 ff ff       	call   800349 <cprintf>
  801e6d:	83 c4 10             	add    $0x10,%esp
  801e70:	eb a4                	jmp    801e16 <_pipeisclosed+0xe>
	}
}
  801e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	57                   	push   %edi
  801e81:	56                   	push   %esi
  801e82:	53                   	push   %ebx
  801e83:	83 ec 28             	sub    $0x28,%esp
  801e86:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e89:	56                   	push   %esi
  801e8a:	e8 bf f6 ff ff       	call   80154e <fd2data>
  801e8f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	bf 00 00 00 00       	mov    $0x0,%edi
  801e99:	eb 4b                	jmp    801ee6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e9b:	89 da                	mov    %ebx,%edx
  801e9d:	89 f0                	mov    %esi,%eax
  801e9f:	e8 64 ff ff ff       	call   801e08 <_pipeisclosed>
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	75 48                	jne    801ef0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ea8:	e8 05 ee ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ead:	8b 43 04             	mov    0x4(%ebx),%eax
  801eb0:	8b 0b                	mov    (%ebx),%ecx
  801eb2:	8d 51 20             	lea    0x20(%ecx),%edx
  801eb5:	39 d0                	cmp    %edx,%eax
  801eb7:	73 e2                	jae    801e9b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ebc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ec0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ec3:	89 c2                	mov    %eax,%edx
  801ec5:	c1 fa 1f             	sar    $0x1f,%edx
  801ec8:	89 d1                	mov    %edx,%ecx
  801eca:	c1 e9 1b             	shr    $0x1b,%ecx
  801ecd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ed0:	83 e2 1f             	and    $0x1f,%edx
  801ed3:	29 ca                	sub    %ecx,%edx
  801ed5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ed9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801edd:	83 c0 01             	add    $0x1,%eax
  801ee0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee3:	83 c7 01             	add    $0x1,%edi
  801ee6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ee9:	75 c2                	jne    801ead <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  801eee:	eb 05                	jmp    801ef5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ef0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ef5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	57                   	push   %edi
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
  801f03:	83 ec 18             	sub    $0x18,%esp
  801f06:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f09:	57                   	push   %edi
  801f0a:	e8 3f f6 ff ff       	call   80154e <fd2data>
  801f0f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f19:	eb 3d                	jmp    801f58 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f1b:	85 db                	test   %ebx,%ebx
  801f1d:	74 04                	je     801f23 <devpipe_read+0x26>
				return i;
  801f1f:	89 d8                	mov    %ebx,%eax
  801f21:	eb 44                	jmp    801f67 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f23:	89 f2                	mov    %esi,%edx
  801f25:	89 f8                	mov    %edi,%eax
  801f27:	e8 dc fe ff ff       	call   801e08 <_pipeisclosed>
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	75 32                	jne    801f62 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f30:	e8 7d ed ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f35:	8b 06                	mov    (%esi),%eax
  801f37:	3b 46 04             	cmp    0x4(%esi),%eax
  801f3a:	74 df                	je     801f1b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f3c:	99                   	cltd   
  801f3d:	c1 ea 1b             	shr    $0x1b,%edx
  801f40:	01 d0                	add    %edx,%eax
  801f42:	83 e0 1f             	and    $0x1f,%eax
  801f45:	29 d0                	sub    %edx,%eax
  801f47:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f4f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f52:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f55:	83 c3 01             	add    $0x1,%ebx
  801f58:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f5b:	75 d8                	jne    801f35 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f60:	eb 05                	jmp    801f67 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	e8 e5 f5 ff ff       	call   801565 <fd_alloc>
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	89 c2                	mov    %eax,%edx
  801f85:	85 c0                	test   %eax,%eax
  801f87:	0f 88 2c 01 00 00    	js     8020b9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8d:	83 ec 04             	sub    $0x4,%esp
  801f90:	68 07 04 00 00       	push   $0x407
  801f95:	ff 75 f4             	pushl  -0xc(%ebp)
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 32 ed ff ff       	call   800cd1 <sys_page_alloc>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	89 c2                	mov    %eax,%edx
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	0f 88 0d 01 00 00    	js     8020b9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fac:	83 ec 0c             	sub    $0xc,%esp
  801faf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fb2:	50                   	push   %eax
  801fb3:	e8 ad f5 ff ff       	call   801565 <fd_alloc>
  801fb8:	89 c3                	mov    %eax,%ebx
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	0f 88 e2 00 00 00    	js     8020a7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc5:	83 ec 04             	sub    $0x4,%esp
  801fc8:	68 07 04 00 00       	push   $0x407
  801fcd:	ff 75 f0             	pushl  -0x10(%ebp)
  801fd0:	6a 00                	push   $0x0
  801fd2:	e8 fa ec ff ff       	call   800cd1 <sys_page_alloc>
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	83 c4 10             	add    $0x10,%esp
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	0f 88 c3 00 00 00    	js     8020a7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fe4:	83 ec 0c             	sub    $0xc,%esp
  801fe7:	ff 75 f4             	pushl  -0xc(%ebp)
  801fea:	e8 5f f5 ff ff       	call   80154e <fd2data>
  801fef:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff1:	83 c4 0c             	add    $0xc,%esp
  801ff4:	68 07 04 00 00       	push   $0x407
  801ff9:	50                   	push   %eax
  801ffa:	6a 00                	push   $0x0
  801ffc:	e8 d0 ec ff ff       	call   800cd1 <sys_page_alloc>
  802001:	89 c3                	mov    %eax,%ebx
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	85 c0                	test   %eax,%eax
  802008:	0f 88 89 00 00 00    	js     802097 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200e:	83 ec 0c             	sub    $0xc,%esp
  802011:	ff 75 f0             	pushl  -0x10(%ebp)
  802014:	e8 35 f5 ff ff       	call   80154e <fd2data>
  802019:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802020:	50                   	push   %eax
  802021:	6a 00                	push   $0x0
  802023:	56                   	push   %esi
  802024:	6a 00                	push   $0x0
  802026:	e8 e9 ec ff ff       	call   800d14 <sys_page_map>
  80202b:	89 c3                	mov    %eax,%ebx
  80202d:	83 c4 20             	add    $0x20,%esp
  802030:	85 c0                	test   %eax,%eax
  802032:	78 55                	js     802089 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802034:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80203a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80203f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802042:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802049:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80204f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802052:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802054:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802057:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	ff 75 f4             	pushl  -0xc(%ebp)
  802064:	e8 d5 f4 ff ff       	call   80153e <fd2num>
  802069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80206c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80206e:	83 c4 04             	add    $0x4,%esp
  802071:	ff 75 f0             	pushl  -0x10(%ebp)
  802074:	e8 c5 f4 ff ff       	call   80153e <fd2num>
  802079:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80207c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	ba 00 00 00 00       	mov    $0x0,%edx
  802087:	eb 30                	jmp    8020b9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802089:	83 ec 08             	sub    $0x8,%esp
  80208c:	56                   	push   %esi
  80208d:	6a 00                	push   $0x0
  80208f:	e8 c2 ec ff ff       	call   800d56 <sys_page_unmap>
  802094:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802097:	83 ec 08             	sub    $0x8,%esp
  80209a:	ff 75 f0             	pushl  -0x10(%ebp)
  80209d:	6a 00                	push   $0x0
  80209f:	e8 b2 ec ff ff       	call   800d56 <sys_page_unmap>
  8020a4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020a7:	83 ec 08             	sub    $0x8,%esp
  8020aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ad:	6a 00                	push   $0x0
  8020af:	e8 a2 ec ff ff       	call   800d56 <sys_page_unmap>
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020b9:	89 d0                	mov    %edx,%eax
  8020bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020be:	5b                   	pop    %ebx
  8020bf:	5e                   	pop    %esi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    

008020c2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020cb:	50                   	push   %eax
  8020cc:	ff 75 08             	pushl  0x8(%ebp)
  8020cf:	e8 e0 f4 ff ff       	call   8015b4 <fd_lookup>
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 18                	js     8020f3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020db:	83 ec 0c             	sub    $0xc,%esp
  8020de:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e1:	e8 68 f4 ff ff       	call   80154e <fd2data>
	return _pipeisclosed(fd, p);
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020eb:	e8 18 fd ff ff       	call   801e08 <_pipeisclosed>
  8020f0:	83 c4 10             	add    $0x10,%esp
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    

008020f5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802105:	68 72 2b 80 00       	push   $0x802b72
  80210a:	ff 75 0c             	pushl  0xc(%ebp)
  80210d:	e8 bc e7 ff ff       	call   8008ce <strcpy>
	return 0;
}
  802112:	b8 00 00 00 00       	mov    $0x0,%eax
  802117:	c9                   	leave  
  802118:	c3                   	ret    

00802119 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	57                   	push   %edi
  80211d:	56                   	push   %esi
  80211e:	53                   	push   %ebx
  80211f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802125:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80212a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802130:	eb 2d                	jmp    80215f <devcons_write+0x46>
		m = n - tot;
  802132:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802135:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802137:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80213a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80213f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802142:	83 ec 04             	sub    $0x4,%esp
  802145:	53                   	push   %ebx
  802146:	03 45 0c             	add    0xc(%ebp),%eax
  802149:	50                   	push   %eax
  80214a:	57                   	push   %edi
  80214b:	e8 10 e9 ff ff       	call   800a60 <memmove>
		sys_cputs(buf, m);
  802150:	83 c4 08             	add    $0x8,%esp
  802153:	53                   	push   %ebx
  802154:	57                   	push   %edi
  802155:	e8 bb ea ff ff       	call   800c15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215a:	01 de                	add    %ebx,%esi
  80215c:	83 c4 10             	add    $0x10,%esp
  80215f:	89 f0                	mov    %esi,%eax
  802161:	3b 75 10             	cmp    0x10(%ebp),%esi
  802164:	72 cc                	jb     802132 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5f                   	pop    %edi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	83 ec 08             	sub    $0x8,%esp
  802174:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802179:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80217d:	74 2a                	je     8021a9 <devcons_read+0x3b>
  80217f:	eb 05                	jmp    802186 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802181:	e8 2c eb ff ff       	call   800cb2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802186:	e8 a8 ea ff ff       	call   800c33 <sys_cgetc>
  80218b:	85 c0                	test   %eax,%eax
  80218d:	74 f2                	je     802181 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80218f:	85 c0                	test   %eax,%eax
  802191:	78 16                	js     8021a9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802193:	83 f8 04             	cmp    $0x4,%eax
  802196:	74 0c                	je     8021a4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802198:	8b 55 0c             	mov    0xc(%ebp),%edx
  80219b:	88 02                	mov    %al,(%edx)
	return 1;
  80219d:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a2:	eb 05                	jmp    8021a9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021a4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021a9:	c9                   	leave  
  8021aa:	c3                   	ret    

008021ab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021b7:	6a 01                	push   $0x1
  8021b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021bc:	50                   	push   %eax
  8021bd:	e8 53 ea ff ff       	call   800c15 <sys_cputs>
}
  8021c2:	83 c4 10             	add    $0x10,%esp
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <getchar>:

int
getchar(void)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021cd:	6a 01                	push   $0x1
  8021cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d2:	50                   	push   %eax
  8021d3:	6a 00                	push   $0x0
  8021d5:	e8 43 f6 ff ff       	call   80181d <read>
	if (r < 0)
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	78 0f                	js     8021f0 <getchar+0x29>
		return r;
	if (r < 1)
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	7e 06                	jle    8021eb <getchar+0x24>
		return -E_EOF;
	return c;
  8021e5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021e9:	eb 05                	jmp    8021f0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021eb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021f0:	c9                   	leave  
  8021f1:	c3                   	ret    

008021f2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fb:	50                   	push   %eax
  8021fc:	ff 75 08             	pushl  0x8(%ebp)
  8021ff:	e8 b0 f3 ff ff       	call   8015b4 <fd_lookup>
  802204:	83 c4 10             	add    $0x10,%esp
  802207:	85 c0                	test   %eax,%eax
  802209:	78 11                	js     80221c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80220b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802214:	39 10                	cmp    %edx,(%eax)
  802216:	0f 94 c0             	sete   %al
  802219:	0f b6 c0             	movzbl %al,%eax
}
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    

0080221e <opencons>:

int
opencons(void)
{
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802224:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802227:	50                   	push   %eax
  802228:	e8 38 f3 ff ff       	call   801565 <fd_alloc>
  80222d:	83 c4 10             	add    $0x10,%esp
		return r;
  802230:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802232:	85 c0                	test   %eax,%eax
  802234:	78 3e                	js     802274 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802236:	83 ec 04             	sub    $0x4,%esp
  802239:	68 07 04 00 00       	push   $0x407
  80223e:	ff 75 f4             	pushl  -0xc(%ebp)
  802241:	6a 00                	push   $0x0
  802243:	e8 89 ea ff ff       	call   800cd1 <sys_page_alloc>
  802248:	83 c4 10             	add    $0x10,%esp
		return r;
  80224b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80224d:	85 c0                	test   %eax,%eax
  80224f:	78 23                	js     802274 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802251:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80225c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802266:	83 ec 0c             	sub    $0xc,%esp
  802269:	50                   	push   %eax
  80226a:	e8 cf f2 ff ff       	call   80153e <fd2num>
  80226f:	89 c2                	mov    %eax,%edx
  802271:	83 c4 10             	add    $0x10,%esp
}
  802274:	89 d0                	mov    %edx,%eax
  802276:	c9                   	leave  
  802277:	c3                   	ret    

00802278 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80227e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802285:	75 2a                	jne    8022b1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802287:	83 ec 04             	sub    $0x4,%esp
  80228a:	6a 07                	push   $0x7
  80228c:	68 00 f0 bf ee       	push   $0xeebff000
  802291:	6a 00                	push   $0x0
  802293:	e8 39 ea ff ff       	call   800cd1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	85 c0                	test   %eax,%eax
  80229d:	79 12                	jns    8022b1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80229f:	50                   	push   %eax
  8022a0:	68 72 2a 80 00       	push   $0x802a72
  8022a5:	6a 23                	push   $0x23
  8022a7:	68 7e 2b 80 00       	push   $0x802b7e
  8022ac:	e8 bf df ff ff       	call   800270 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b4:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8022b9:	83 ec 08             	sub    $0x8,%esp
  8022bc:	68 e3 22 80 00       	push   $0x8022e3
  8022c1:	6a 00                	push   $0x0
  8022c3:	e8 54 eb ff ff       	call   800e1c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	79 12                	jns    8022e1 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8022cf:	50                   	push   %eax
  8022d0:	68 72 2a 80 00       	push   $0x802a72
  8022d5:	6a 2c                	push   $0x2c
  8022d7:	68 7e 2b 80 00       	push   $0x802b7e
  8022dc:	e8 8f df ff ff       	call   800270 <_panic>
	}
}
  8022e1:	c9                   	leave  
  8022e2:	c3                   	ret    

008022e3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022e3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022e4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022e9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022eb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8022ee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8022f2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8022f7:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8022fb:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8022fd:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802300:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802301:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802304:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802305:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802306:	c3                   	ret    
  802307:	66 90                	xchg   %ax,%ax
  802309:	66 90                	xchg   %ax,%ax
  80230b:	66 90                	xchg   %ax,%ax
  80230d:	66 90                	xchg   %ax,%ax
  80230f:	90                   	nop

00802310 <__udivdi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80231b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80231f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 f6                	test   %esi,%esi
  802329:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80232d:	89 ca                	mov    %ecx,%edx
  80232f:	89 f8                	mov    %edi,%eax
  802331:	75 3d                	jne    802370 <__udivdi3+0x60>
  802333:	39 cf                	cmp    %ecx,%edi
  802335:	0f 87 c5 00 00 00    	ja     802400 <__udivdi3+0xf0>
  80233b:	85 ff                	test   %edi,%edi
  80233d:	89 fd                	mov    %edi,%ebp
  80233f:	75 0b                	jne    80234c <__udivdi3+0x3c>
  802341:	b8 01 00 00 00       	mov    $0x1,%eax
  802346:	31 d2                	xor    %edx,%edx
  802348:	f7 f7                	div    %edi
  80234a:	89 c5                	mov    %eax,%ebp
  80234c:	89 c8                	mov    %ecx,%eax
  80234e:	31 d2                	xor    %edx,%edx
  802350:	f7 f5                	div    %ebp
  802352:	89 c1                	mov    %eax,%ecx
  802354:	89 d8                	mov    %ebx,%eax
  802356:	89 cf                	mov    %ecx,%edi
  802358:	f7 f5                	div    %ebp
  80235a:	89 c3                	mov    %eax,%ebx
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
  802370:	39 ce                	cmp    %ecx,%esi
  802372:	77 74                	ja     8023e8 <__udivdi3+0xd8>
  802374:	0f bd fe             	bsr    %esi,%edi
  802377:	83 f7 1f             	xor    $0x1f,%edi
  80237a:	0f 84 98 00 00 00    	je     802418 <__udivdi3+0x108>
  802380:	bb 20 00 00 00       	mov    $0x20,%ebx
  802385:	89 f9                	mov    %edi,%ecx
  802387:	89 c5                	mov    %eax,%ebp
  802389:	29 fb                	sub    %edi,%ebx
  80238b:	d3 e6                	shl    %cl,%esi
  80238d:	89 d9                	mov    %ebx,%ecx
  80238f:	d3 ed                	shr    %cl,%ebp
  802391:	89 f9                	mov    %edi,%ecx
  802393:	d3 e0                	shl    %cl,%eax
  802395:	09 ee                	or     %ebp,%esi
  802397:	89 d9                	mov    %ebx,%ecx
  802399:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80239d:	89 d5                	mov    %edx,%ebp
  80239f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023a3:	d3 ed                	shr    %cl,%ebp
  8023a5:	89 f9                	mov    %edi,%ecx
  8023a7:	d3 e2                	shl    %cl,%edx
  8023a9:	89 d9                	mov    %ebx,%ecx
  8023ab:	d3 e8                	shr    %cl,%eax
  8023ad:	09 c2                	or     %eax,%edx
  8023af:	89 d0                	mov    %edx,%eax
  8023b1:	89 ea                	mov    %ebp,%edx
  8023b3:	f7 f6                	div    %esi
  8023b5:	89 d5                	mov    %edx,%ebp
  8023b7:	89 c3                	mov    %eax,%ebx
  8023b9:	f7 64 24 0c          	mull   0xc(%esp)
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	72 10                	jb     8023d1 <__udivdi3+0xc1>
  8023c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023c5:	89 f9                	mov    %edi,%ecx
  8023c7:	d3 e6                	shl    %cl,%esi
  8023c9:	39 c6                	cmp    %eax,%esi
  8023cb:	73 07                	jae    8023d4 <__udivdi3+0xc4>
  8023cd:	39 d5                	cmp    %edx,%ebp
  8023cf:	75 03                	jne    8023d4 <__udivdi3+0xc4>
  8023d1:	83 eb 01             	sub    $0x1,%ebx
  8023d4:	31 ff                	xor    %edi,%edi
  8023d6:	89 d8                	mov    %ebx,%eax
  8023d8:	89 fa                	mov    %edi,%edx
  8023da:	83 c4 1c             	add    $0x1c,%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5f                   	pop    %edi
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    
  8023e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e8:	31 ff                	xor    %edi,%edi
  8023ea:	31 db                	xor    %ebx,%ebx
  8023ec:	89 d8                	mov    %ebx,%eax
  8023ee:	89 fa                	mov    %edi,%edx
  8023f0:	83 c4 1c             	add    $0x1c,%esp
  8023f3:	5b                   	pop    %ebx
  8023f4:	5e                   	pop    %esi
  8023f5:	5f                   	pop    %edi
  8023f6:	5d                   	pop    %ebp
  8023f7:	c3                   	ret    
  8023f8:	90                   	nop
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	89 d8                	mov    %ebx,%eax
  802402:	f7 f7                	div    %edi
  802404:	31 ff                	xor    %edi,%edi
  802406:	89 c3                	mov    %eax,%ebx
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	89 fa                	mov    %edi,%edx
  80240c:	83 c4 1c             	add    $0x1c,%esp
  80240f:	5b                   	pop    %ebx
  802410:	5e                   	pop    %esi
  802411:	5f                   	pop    %edi
  802412:	5d                   	pop    %ebp
  802413:	c3                   	ret    
  802414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802418:	39 ce                	cmp    %ecx,%esi
  80241a:	72 0c                	jb     802428 <__udivdi3+0x118>
  80241c:	31 db                	xor    %ebx,%ebx
  80241e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802422:	0f 87 34 ff ff ff    	ja     80235c <__udivdi3+0x4c>
  802428:	bb 01 00 00 00       	mov    $0x1,%ebx
  80242d:	e9 2a ff ff ff       	jmp    80235c <__udivdi3+0x4c>
  802432:	66 90                	xchg   %ax,%ax
  802434:	66 90                	xchg   %ax,%ax
  802436:	66 90                	xchg   %ax,%ax
  802438:	66 90                	xchg   %ax,%ax
  80243a:	66 90                	xchg   %ax,%ax
  80243c:	66 90                	xchg   %ax,%ax
  80243e:	66 90                	xchg   %ax,%ax

00802440 <__umoddi3>:
  802440:	55                   	push   %ebp
  802441:	57                   	push   %edi
  802442:	56                   	push   %esi
  802443:	53                   	push   %ebx
  802444:	83 ec 1c             	sub    $0x1c,%esp
  802447:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80244b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80244f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802453:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802457:	85 d2                	test   %edx,%edx
  802459:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80245d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802461:	89 f3                	mov    %esi,%ebx
  802463:	89 3c 24             	mov    %edi,(%esp)
  802466:	89 74 24 04          	mov    %esi,0x4(%esp)
  80246a:	75 1c                	jne    802488 <__umoddi3+0x48>
  80246c:	39 f7                	cmp    %esi,%edi
  80246e:	76 50                	jbe    8024c0 <__umoddi3+0x80>
  802470:	89 c8                	mov    %ecx,%eax
  802472:	89 f2                	mov    %esi,%edx
  802474:	f7 f7                	div    %edi
  802476:	89 d0                	mov    %edx,%eax
  802478:	31 d2                	xor    %edx,%edx
  80247a:	83 c4 1c             	add    $0x1c,%esp
  80247d:	5b                   	pop    %ebx
  80247e:	5e                   	pop    %esi
  80247f:	5f                   	pop    %edi
  802480:	5d                   	pop    %ebp
  802481:	c3                   	ret    
  802482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802488:	39 f2                	cmp    %esi,%edx
  80248a:	89 d0                	mov    %edx,%eax
  80248c:	77 52                	ja     8024e0 <__umoddi3+0xa0>
  80248e:	0f bd ea             	bsr    %edx,%ebp
  802491:	83 f5 1f             	xor    $0x1f,%ebp
  802494:	75 5a                	jne    8024f0 <__umoddi3+0xb0>
  802496:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80249a:	0f 82 e0 00 00 00    	jb     802580 <__umoddi3+0x140>
  8024a0:	39 0c 24             	cmp    %ecx,(%esp)
  8024a3:	0f 86 d7 00 00 00    	jbe    802580 <__umoddi3+0x140>
  8024a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024b1:	83 c4 1c             	add    $0x1c,%esp
  8024b4:	5b                   	pop    %ebx
  8024b5:	5e                   	pop    %esi
  8024b6:	5f                   	pop    %edi
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    
  8024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	85 ff                	test   %edi,%edi
  8024c2:	89 fd                	mov    %edi,%ebp
  8024c4:	75 0b                	jne    8024d1 <__umoddi3+0x91>
  8024c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024cb:	31 d2                	xor    %edx,%edx
  8024cd:	f7 f7                	div    %edi
  8024cf:	89 c5                	mov    %eax,%ebp
  8024d1:	89 f0                	mov    %esi,%eax
  8024d3:	31 d2                	xor    %edx,%edx
  8024d5:	f7 f5                	div    %ebp
  8024d7:	89 c8                	mov    %ecx,%eax
  8024d9:	f7 f5                	div    %ebp
  8024db:	89 d0                	mov    %edx,%eax
  8024dd:	eb 99                	jmp    802478 <__umoddi3+0x38>
  8024df:	90                   	nop
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 f2                	mov    %esi,%edx
  8024e4:	83 c4 1c             	add    $0x1c,%esp
  8024e7:	5b                   	pop    %ebx
  8024e8:	5e                   	pop    %esi
  8024e9:	5f                   	pop    %edi
  8024ea:	5d                   	pop    %ebp
  8024eb:	c3                   	ret    
  8024ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	8b 34 24             	mov    (%esp),%esi
  8024f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024f8:	89 e9                	mov    %ebp,%ecx
  8024fa:	29 ef                	sub    %ebp,%edi
  8024fc:	d3 e0                	shl    %cl,%eax
  8024fe:	89 f9                	mov    %edi,%ecx
  802500:	89 f2                	mov    %esi,%edx
  802502:	d3 ea                	shr    %cl,%edx
  802504:	89 e9                	mov    %ebp,%ecx
  802506:	09 c2                	or     %eax,%edx
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	89 14 24             	mov    %edx,(%esp)
  80250d:	89 f2                	mov    %esi,%edx
  80250f:	d3 e2                	shl    %cl,%edx
  802511:	89 f9                	mov    %edi,%ecx
  802513:	89 54 24 04          	mov    %edx,0x4(%esp)
  802517:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80251b:	d3 e8                	shr    %cl,%eax
  80251d:	89 e9                	mov    %ebp,%ecx
  80251f:	89 c6                	mov    %eax,%esi
  802521:	d3 e3                	shl    %cl,%ebx
  802523:	89 f9                	mov    %edi,%ecx
  802525:	89 d0                	mov    %edx,%eax
  802527:	d3 e8                	shr    %cl,%eax
  802529:	89 e9                	mov    %ebp,%ecx
  80252b:	09 d8                	or     %ebx,%eax
  80252d:	89 d3                	mov    %edx,%ebx
  80252f:	89 f2                	mov    %esi,%edx
  802531:	f7 34 24             	divl   (%esp)
  802534:	89 d6                	mov    %edx,%esi
  802536:	d3 e3                	shl    %cl,%ebx
  802538:	f7 64 24 04          	mull   0x4(%esp)
  80253c:	39 d6                	cmp    %edx,%esi
  80253e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802542:	89 d1                	mov    %edx,%ecx
  802544:	89 c3                	mov    %eax,%ebx
  802546:	72 08                	jb     802550 <__umoddi3+0x110>
  802548:	75 11                	jne    80255b <__umoddi3+0x11b>
  80254a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80254e:	73 0b                	jae    80255b <__umoddi3+0x11b>
  802550:	2b 44 24 04          	sub    0x4(%esp),%eax
  802554:	1b 14 24             	sbb    (%esp),%edx
  802557:	89 d1                	mov    %edx,%ecx
  802559:	89 c3                	mov    %eax,%ebx
  80255b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80255f:	29 da                	sub    %ebx,%edx
  802561:	19 ce                	sbb    %ecx,%esi
  802563:	89 f9                	mov    %edi,%ecx
  802565:	89 f0                	mov    %esi,%eax
  802567:	d3 e0                	shl    %cl,%eax
  802569:	89 e9                	mov    %ebp,%ecx
  80256b:	d3 ea                	shr    %cl,%edx
  80256d:	89 e9                	mov    %ebp,%ecx
  80256f:	d3 ee                	shr    %cl,%esi
  802571:	09 d0                	or     %edx,%eax
  802573:	89 f2                	mov    %esi,%edx
  802575:	83 c4 1c             	add    $0x1c,%esp
  802578:	5b                   	pop    %ebx
  802579:	5e                   	pop    %esi
  80257a:	5f                   	pop    %edi
  80257b:	5d                   	pop    %ebp
  80257c:	c3                   	ret    
  80257d:	8d 76 00             	lea    0x0(%esi),%esi
  802580:	29 f9                	sub    %edi,%ecx
  802582:	19 d6                	sbb    %edx,%esi
  802584:	89 74 24 04          	mov    %esi,0x4(%esp)
  802588:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80258c:	e9 18 ff ff ff       	jmp    8024a9 <__umoddi3+0x69>
