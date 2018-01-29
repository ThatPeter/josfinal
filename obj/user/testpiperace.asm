
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
  80003b:	68 c0 23 80 00       	push   $0x8023c0
  800040:	e8 04 03 00 00       	call   800349 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 3f 1d 00 00       	call   801d8f <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 d9 23 80 00       	push   $0x8023d9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 e2 23 80 00       	push   $0x8023e2
  800064:	e8 07 02 00 00       	call   800270 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 8a 0f 00 00       	call   800ff8 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 f6 23 80 00       	push   $0x8023f6
  80007a:	6a 10                	push   $0x10
  80007c:	68 e2 23 80 00       	push   $0x8023e2
  800081:	e8 ea 01 00 00       	call   800270 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 6c 14 00 00       	call   801501 <close>
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
  8000a3:	e8 3a 1e 00 00       	call   801ee2 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 ff 23 80 00       	push   $0x8023ff
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
  8000d7:	e8 60 11 00 00       	call   80123c <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 1a 24 80 00       	push   $0x80241a
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
  800106:	68 25 24 80 00       	push   $0x802425
  80010b:	e8 39 02 00 00       	call   800349 <cprintf>
	dup(p[0], 10);
  800110:	83 c4 08             	add    $0x8,%esp
  800113:	6a 0a                	push   $0xa
  800115:	ff 75 f0             	pushl  -0x10(%ebp)
  800118:	e8 34 14 00 00       	call   801551 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	69 de d8 00 00 00    	imul   $0xd8,%esi,%ebx
  800126:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80012c:	eb 10                	jmp    80013e <umain+0x10b>
		dup(p[0], 10);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	6a 0a                	push   $0xa
  800133:	ff 75 f0             	pushl  -0x10(%ebp)
  800136:	e8 16 14 00 00       	call   801551 <dup>
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
  80014c:	68 30 24 80 00       	push   $0x802430
  800151:	e8 f3 01 00 00       	call   800349 <cprintf>
	if (pipeisclosed(p[0]))
  800156:	83 c4 04             	add    $0x4,%esp
  800159:	ff 75 f0             	pushl  -0x10(%ebp)
  80015c:	e8 81 1d 00 00       	call   801ee2 <pipeisclosed>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	74 14                	je     80017c <umain+0x149>
		panic("somehow the other end of p[0] got closed!");
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	68 8c 24 80 00       	push   $0x80248c
  800170:	6a 3a                	push   $0x3a
  800172:	68 e2 23 80 00       	push   $0x8023e2
  800177:	e8 f4 00 00 00       	call   800270 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017c:	83 ec 08             	sub    $0x8,%esp
  80017f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	ff 75 f0             	pushl  -0x10(%ebp)
  800186:	e8 49 12 00 00       	call   8013d4 <fd_lookup>
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 12                	jns    8001a4 <umain+0x171>
		panic("cannot look up p[0]: %e", r);
  800192:	50                   	push   %eax
  800193:	68 46 24 80 00       	push   $0x802446
  800198:	6a 3c                	push   $0x3c
  80019a:	68 e2 23 80 00       	push   $0x8023e2
  80019f:	e8 cc 00 00 00       	call   800270 <_panic>
	va = fd2data(fd);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001aa:	e8 bf 11 00 00       	call   80136e <fd2data>
	if (pageref(va) != 3+1)
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 be 19 00 00       	call   801b75 <pageref>
  8001b7:	83 c4 10             	add    $0x10,%esp
  8001ba:	83 f8 04             	cmp    $0x4,%eax
  8001bd:	74 12                	je     8001d1 <umain+0x19e>
		cprintf("\nchild detected race\n");
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	68 5e 24 80 00       	push   $0x80245e
  8001c7:	e8 7d 01 00 00       	call   800349 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	eb 15                	jmp    8001e6 <umain+0x1b3>
	else
		cprintf("\nrace didn't happen\n", max);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	68 c8 00 00 00       	push   $0xc8
  8001d9:	68 74 24 80 00       	push   $0x802474
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
  80025c:	e8 cb 12 00 00       	call   80152c <close_all>
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
  80028e:	68 c0 24 80 00       	push   $0x8024c0
  800293:	e8 b1 00 00 00       	call   800349 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800298:	83 c4 18             	add    $0x18,%esp
  80029b:	53                   	push   %ebx
  80029c:	ff 75 10             	pushl  0x10(%ebp)
  80029f:	e8 54 00 00 00       	call   8002f8 <vcprintf>
	cprintf("\n");
  8002a4:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
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
  8003ac:	e8 7f 1d 00 00       	call   802130 <__udivdi3>
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
  8003ef:	e8 6c 1e 00 00       	call   802260 <__umoddi3>
  8003f4:	83 c4 14             	add    $0x14,%esp
  8003f7:	0f be 80 e3 24 80 00 	movsbl 0x8024e3(%eax),%eax
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
  8004f3:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
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
  8005b7:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	75 18                	jne    8005da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005c2:	50                   	push   %eax
  8005c3:	68 fb 24 80 00       	push   $0x8024fb
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
  8005db:	68 49 29 80 00       	push   $0x802949
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
  8005ff:	b8 f4 24 80 00       	mov    $0x8024f4,%eax
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
  800c7a:	68 df 27 80 00       	push   $0x8027df
  800c7f:	6a 23                	push   $0x23
  800c81:	68 fc 27 80 00       	push   $0x8027fc
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
  800cfb:	68 df 27 80 00       	push   $0x8027df
  800d00:	6a 23                	push   $0x23
  800d02:	68 fc 27 80 00       	push   $0x8027fc
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
  800d3d:	68 df 27 80 00       	push   $0x8027df
  800d42:	6a 23                	push   $0x23
  800d44:	68 fc 27 80 00       	push   $0x8027fc
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
  800d7f:	68 df 27 80 00       	push   $0x8027df
  800d84:	6a 23                	push   $0x23
  800d86:	68 fc 27 80 00       	push   $0x8027fc
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
  800dc1:	68 df 27 80 00       	push   $0x8027df
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 fc 27 80 00       	push   $0x8027fc
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
  800e03:	68 df 27 80 00       	push   $0x8027df
  800e08:	6a 23                	push   $0x23
  800e0a:	68 fc 27 80 00       	push   $0x8027fc
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
  800e45:	68 df 27 80 00       	push   $0x8027df
  800e4a:	6a 23                	push   $0x23
  800e4c:	68 fc 27 80 00       	push   $0x8027fc
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
  800ea9:	68 df 27 80 00       	push   $0x8027df
  800eae:	6a 23                	push   $0x23
  800eb0:	68 fc 27 80 00       	push   $0x8027fc
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
  800f48:	68 0a 28 80 00       	push   $0x80280a
  800f4d:	6a 1e                	push   $0x1e
  800f4f:	68 1a 28 80 00       	push   $0x80281a
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
  800f72:	68 25 28 80 00       	push   $0x802825
  800f77:	6a 2c                	push   $0x2c
  800f79:	68 1a 28 80 00       	push   $0x80281a
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
  800fba:	68 25 28 80 00       	push   $0x802825
  800fbf:	6a 33                	push   $0x33
  800fc1:	68 1a 28 80 00       	push   $0x80281a
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
  800fe2:	68 25 28 80 00       	push   $0x802825
  800fe7:	6a 37                	push   $0x37
  800fe9:	68 1a 28 80 00       	push   $0x80281a
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
  801006:	e8 8d 10 00 00       	call   802098 <set_pgfault_handler>
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
  80101f:	68 3e 28 80 00       	push   $0x80283e
  801024:	68 84 00 00 00       	push   $0x84
  801029:	68 1a 28 80 00       	push   $0x80281a
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
  8010db:	68 4c 28 80 00       	push   $0x80284c
  8010e0:	6a 54                	push   $0x54
  8010e2:	68 1a 28 80 00       	push   $0x80281a
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
  801120:	68 4c 28 80 00       	push   $0x80284c
  801125:	6a 5b                	push   $0x5b
  801127:	68 1a 28 80 00       	push   $0x80281a
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
  80114e:	68 4c 28 80 00       	push   $0x80284c
  801153:	6a 5f                	push   $0x5f
  801155:	68 1a 28 80 00       	push   $0x80281a
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
  801178:	68 4c 28 80 00       	push   $0x80284c
  80117d:	6a 64                	push   $0x64
  80117f:	68 1a 28 80 00       	push   $0x80281a
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
  8011e7:	68 64 28 80 00       	push   $0x802864
  8011ec:	e8 58 f1 ff ff       	call   800349 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011f1:	c7 04 24 36 02 80 00 	movl   $0x800236,(%esp)
  8011f8:	e8 c5 fc ff ff       	call   800ec2 <sys_thread_create>
  8011fd:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011ff:	83 c4 08             	add    $0x8,%esp
  801202:	53                   	push   %ebx
  801203:	68 64 28 80 00       	push   $0x802864
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

0080123c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	8b 75 08             	mov    0x8(%ebp),%esi
  801244:	8b 45 0c             	mov    0xc(%ebp),%eax
  801247:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80124a:	85 c0                	test   %eax,%eax
  80124c:	75 12                	jne    801260 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	68 00 00 c0 ee       	push   $0xeec00000
  801256:	e8 26 fc ff ff       	call   800e81 <sys_ipc_recv>
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	eb 0c                	jmp    80126c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	50                   	push   %eax
  801264:	e8 18 fc ff ff       	call   800e81 <sys_ipc_recv>
  801269:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80126c:	85 f6                	test   %esi,%esi
  80126e:	0f 95 c1             	setne  %cl
  801271:	85 db                	test   %ebx,%ebx
  801273:	0f 95 c2             	setne  %dl
  801276:	84 d1                	test   %dl,%cl
  801278:	74 09                	je     801283 <ipc_recv+0x47>
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	c1 ea 1f             	shr    $0x1f,%edx
  80127f:	84 d2                	test   %dl,%dl
  801281:	75 2d                	jne    8012b0 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801283:	85 f6                	test   %esi,%esi
  801285:	74 0d                	je     801294 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801287:	a1 04 40 80 00       	mov    0x804004,%eax
  80128c:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801292:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801294:	85 db                	test   %ebx,%ebx
  801296:	74 0d                	je     8012a5 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801298:	a1 04 40 80 00       	mov    0x804004,%eax
  80129d:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8012a3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8012a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012aa:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8012b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	57                   	push   %edi
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 0c             	sub    $0xc,%esp
  8012c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8012c9:	85 db                	test   %ebx,%ebx
  8012cb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8012d0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8012d3:	ff 75 14             	pushl  0x14(%ebp)
  8012d6:	53                   	push   %ebx
  8012d7:	56                   	push   %esi
  8012d8:	57                   	push   %edi
  8012d9:	e8 80 fb ff ff       	call   800e5e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	c1 ea 1f             	shr    $0x1f,%edx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	84 d2                	test   %dl,%dl
  8012e8:	74 17                	je     801301 <ipc_send+0x4a>
  8012ea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012ed:	74 12                	je     801301 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8012ef:	50                   	push   %eax
  8012f0:	68 87 28 80 00       	push   $0x802887
  8012f5:	6a 47                	push   $0x47
  8012f7:	68 95 28 80 00       	push   $0x802895
  8012fc:	e8 6f ef ff ff       	call   800270 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801301:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801304:	75 07                	jne    80130d <ipc_send+0x56>
			sys_yield();
  801306:	e8 a7 f9 ff ff       	call   800cb2 <sys_yield>
  80130b:	eb c6                	jmp    8012d3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80130d:	85 c0                	test   %eax,%eax
  80130f:	75 c2                	jne    8012d3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801311:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5f                   	pop    %edi
  801317:	5d                   	pop    %ebp
  801318:	c3                   	ret    

00801319 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801324:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80132a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801330:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801336:	39 ca                	cmp    %ecx,%edx
  801338:	75 13                	jne    80134d <ipc_find_env+0x34>
			return envs[i].env_id;
  80133a:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801340:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801345:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80134b:	eb 0f                	jmp    80135c <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80134d:	83 c0 01             	add    $0x1,%eax
  801350:	3d 00 04 00 00       	cmp    $0x400,%eax
  801355:	75 cd                	jne    801324 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801361:	8b 45 08             	mov    0x8(%ebp),%eax
  801364:	05 00 00 00 30       	add    $0x30000000,%eax
  801369:	c1 e8 0c             	shr    $0xc,%eax
}
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    

0080136e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801371:	8b 45 08             	mov    0x8(%ebp),%eax
  801374:	05 00 00 00 30       	add    $0x30000000,%eax
  801379:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80137e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801390:	89 c2                	mov    %eax,%edx
  801392:	c1 ea 16             	shr    $0x16,%edx
  801395:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80139c:	f6 c2 01             	test   $0x1,%dl
  80139f:	74 11                	je     8013b2 <fd_alloc+0x2d>
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	c1 ea 0c             	shr    $0xc,%edx
  8013a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ad:	f6 c2 01             	test   $0x1,%dl
  8013b0:	75 09                	jne    8013bb <fd_alloc+0x36>
			*fd_store = fd;
  8013b2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b9:	eb 17                	jmp    8013d2 <fd_alloc+0x4d>
  8013bb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c5:	75 c9                	jne    801390 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013cd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013da:	83 f8 1f             	cmp    $0x1f,%eax
  8013dd:	77 36                	ja     801415 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013df:	c1 e0 0c             	shl    $0xc,%eax
  8013e2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e7:	89 c2                	mov    %eax,%edx
  8013e9:	c1 ea 16             	shr    $0x16,%edx
  8013ec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f3:	f6 c2 01             	test   $0x1,%dl
  8013f6:	74 24                	je     80141c <fd_lookup+0x48>
  8013f8:	89 c2                	mov    %eax,%edx
  8013fa:	c1 ea 0c             	shr    $0xc,%edx
  8013fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801404:	f6 c2 01             	test   $0x1,%dl
  801407:	74 1a                	je     801423 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801409:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140c:	89 02                	mov    %eax,(%edx)
	return 0;
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
  801413:	eb 13                	jmp    801428 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141a:	eb 0c                	jmp    801428 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801421:	eb 05                	jmp    801428 <fd_lookup+0x54>
  801423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801433:	ba 20 29 80 00       	mov    $0x802920,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801438:	eb 13                	jmp    80144d <dev_lookup+0x23>
  80143a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80143d:	39 08                	cmp    %ecx,(%eax)
  80143f:	75 0c                	jne    80144d <dev_lookup+0x23>
			*dev = devtab[i];
  801441:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801444:	89 01                	mov    %eax,(%ecx)
			return 0;
  801446:	b8 00 00 00 00       	mov    $0x0,%eax
  80144b:	eb 31                	jmp    80147e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80144d:	8b 02                	mov    (%edx),%eax
  80144f:	85 c0                	test   %eax,%eax
  801451:	75 e7                	jne    80143a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801453:	a1 04 40 80 00       	mov    0x804004,%eax
  801458:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	51                   	push   %ecx
  801462:	50                   	push   %eax
  801463:	68 a0 28 80 00       	push   $0x8028a0
  801468:	e8 dc ee ff ff       	call   800349 <cprintf>
	*dev = 0;
  80146d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801470:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 10             	sub    $0x10,%esp
  801488:	8b 75 08             	mov    0x8(%ebp),%esi
  80148b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80148e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801498:	c1 e8 0c             	shr    $0xc,%eax
  80149b:	50                   	push   %eax
  80149c:	e8 33 ff ff ff       	call   8013d4 <fd_lookup>
  8014a1:	83 c4 08             	add    $0x8,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 05                	js     8014ad <fd_close+0x2d>
	    || fd != fd2)
  8014a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014ab:	74 0c                	je     8014b9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014ad:	84 db                	test   %bl,%bl
  8014af:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b4:	0f 44 c2             	cmove  %edx,%eax
  8014b7:	eb 41                	jmp    8014fa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	ff 36                	pushl  (%esi)
  8014c2:	e8 63 ff ff ff       	call   80142a <dev_lookup>
  8014c7:	89 c3                	mov    %eax,%ebx
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 1a                	js     8014ea <fd_close+0x6a>
		if (dev->dev_close)
  8014d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014d6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	74 0b                	je     8014ea <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014df:	83 ec 0c             	sub    $0xc,%esp
  8014e2:	56                   	push   %esi
  8014e3:	ff d0                	call   *%eax
  8014e5:	89 c3                	mov    %eax,%ebx
  8014e7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	56                   	push   %esi
  8014ee:	6a 00                	push   $0x0
  8014f0:	e8 61 f8 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	89 d8                	mov    %ebx,%eax
}
  8014fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5e                   	pop    %esi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    

00801501 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801507:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	ff 75 08             	pushl  0x8(%ebp)
  80150e:	e8 c1 fe ff ff       	call   8013d4 <fd_lookup>
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 10                	js     80152a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	6a 01                	push   $0x1
  80151f:	ff 75 f4             	pushl  -0xc(%ebp)
  801522:	e8 59 ff ff ff       	call   801480 <fd_close>
  801527:	83 c4 10             	add    $0x10,%esp
}
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <close_all>:

void
close_all(void)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	53                   	push   %ebx
  801530:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801533:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	53                   	push   %ebx
  80153c:	e8 c0 ff ff ff       	call   801501 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801541:	83 c3 01             	add    $0x1,%ebx
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	83 fb 20             	cmp    $0x20,%ebx
  80154a:	75 ec                	jne    801538 <close_all+0xc>
		close(i);
}
  80154c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	57                   	push   %edi
  801555:	56                   	push   %esi
  801556:	53                   	push   %ebx
  801557:	83 ec 2c             	sub    $0x2c,%esp
  80155a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80155d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	ff 75 08             	pushl  0x8(%ebp)
  801564:	e8 6b fe ff ff       	call   8013d4 <fd_lookup>
  801569:	83 c4 08             	add    $0x8,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	0f 88 c1 00 00 00    	js     801635 <dup+0xe4>
		return r;
	close(newfdnum);
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	56                   	push   %esi
  801578:	e8 84 ff ff ff       	call   801501 <close>

	newfd = INDEX2FD(newfdnum);
  80157d:	89 f3                	mov    %esi,%ebx
  80157f:	c1 e3 0c             	shl    $0xc,%ebx
  801582:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801588:	83 c4 04             	add    $0x4,%esp
  80158b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80158e:	e8 db fd ff ff       	call   80136e <fd2data>
  801593:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801595:	89 1c 24             	mov    %ebx,(%esp)
  801598:	e8 d1 fd ff ff       	call   80136e <fd2data>
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a3:	89 f8                	mov    %edi,%eax
  8015a5:	c1 e8 16             	shr    $0x16,%eax
  8015a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015af:	a8 01                	test   $0x1,%al
  8015b1:	74 37                	je     8015ea <dup+0x99>
  8015b3:	89 f8                	mov    %edi,%eax
  8015b5:	c1 e8 0c             	shr    $0xc,%eax
  8015b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015bf:	f6 c2 01             	test   $0x1,%dl
  8015c2:	74 26                	je     8015ea <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015cb:	83 ec 0c             	sub    $0xc,%esp
  8015ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d3:	50                   	push   %eax
  8015d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d7:	6a 00                	push   $0x0
  8015d9:	57                   	push   %edi
  8015da:	6a 00                	push   $0x0
  8015dc:	e8 33 f7 ff ff       	call   800d14 <sys_page_map>
  8015e1:	89 c7                	mov    %eax,%edi
  8015e3:	83 c4 20             	add    $0x20,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 2e                	js     801618 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ed:	89 d0                	mov    %edx,%eax
  8015ef:	c1 e8 0c             	shr    $0xc,%eax
  8015f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f9:	83 ec 0c             	sub    $0xc,%esp
  8015fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801601:	50                   	push   %eax
  801602:	53                   	push   %ebx
  801603:	6a 00                	push   $0x0
  801605:	52                   	push   %edx
  801606:	6a 00                	push   $0x0
  801608:	e8 07 f7 ff ff       	call   800d14 <sys_page_map>
  80160d:	89 c7                	mov    %eax,%edi
  80160f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801612:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801614:	85 ff                	test   %edi,%edi
  801616:	79 1d                	jns    801635 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	53                   	push   %ebx
  80161c:	6a 00                	push   $0x0
  80161e:	e8 33 f7 ff ff       	call   800d56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801623:	83 c4 08             	add    $0x8,%esp
  801626:	ff 75 d4             	pushl  -0x2c(%ebp)
  801629:	6a 00                	push   $0x0
  80162b:	e8 26 f7 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	89 f8                	mov    %edi,%eax
}
  801635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801638:	5b                   	pop    %ebx
  801639:	5e                   	pop    %esi
  80163a:	5f                   	pop    %edi
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    

0080163d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 14             	sub    $0x14,%esp
  801644:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	53                   	push   %ebx
  80164c:	e8 83 fd ff ff       	call   8013d4 <fd_lookup>
  801651:	83 c4 08             	add    $0x8,%esp
  801654:	89 c2                	mov    %eax,%edx
  801656:	85 c0                	test   %eax,%eax
  801658:	78 70                	js     8016ca <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801664:	ff 30                	pushl  (%eax)
  801666:	e8 bf fd ff ff       	call   80142a <dev_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 4f                	js     8016c1 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801672:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801675:	8b 42 08             	mov    0x8(%edx),%eax
  801678:	83 e0 03             	and    $0x3,%eax
  80167b:	83 f8 01             	cmp    $0x1,%eax
  80167e:	75 24                	jne    8016a4 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801680:	a1 04 40 80 00       	mov    0x804004,%eax
  801685:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	53                   	push   %ebx
  80168f:	50                   	push   %eax
  801690:	68 e4 28 80 00       	push   $0x8028e4
  801695:	e8 af ec ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a2:	eb 26                	jmp    8016ca <read+0x8d>
	}
	if (!dev->dev_read)
  8016a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a7:	8b 40 08             	mov    0x8(%eax),%eax
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	74 17                	je     8016c5 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	ff 75 10             	pushl  0x10(%ebp)
  8016b4:	ff 75 0c             	pushl  0xc(%ebp)
  8016b7:	52                   	push   %edx
  8016b8:	ff d0                	call   *%eax
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb 09                	jmp    8016ca <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c1:	89 c2                	mov    %eax,%edx
  8016c3:	eb 05                	jmp    8016ca <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016ca:	89 d0                	mov    %edx,%eax
  8016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	57                   	push   %edi
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e5:	eb 21                	jmp    801708 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016e7:	83 ec 04             	sub    $0x4,%esp
  8016ea:	89 f0                	mov    %esi,%eax
  8016ec:	29 d8                	sub    %ebx,%eax
  8016ee:	50                   	push   %eax
  8016ef:	89 d8                	mov    %ebx,%eax
  8016f1:	03 45 0c             	add    0xc(%ebp),%eax
  8016f4:	50                   	push   %eax
  8016f5:	57                   	push   %edi
  8016f6:	e8 42 ff ff ff       	call   80163d <read>
		if (m < 0)
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 10                	js     801712 <readn+0x41>
			return m;
		if (m == 0)
  801702:	85 c0                	test   %eax,%eax
  801704:	74 0a                	je     801710 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801706:	01 c3                	add    %eax,%ebx
  801708:	39 f3                	cmp    %esi,%ebx
  80170a:	72 db                	jb     8016e7 <readn+0x16>
  80170c:	89 d8                	mov    %ebx,%eax
  80170e:	eb 02                	jmp    801712 <readn+0x41>
  801710:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	5f                   	pop    %edi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	83 ec 14             	sub    $0x14,%esp
  801721:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801724:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801727:	50                   	push   %eax
  801728:	53                   	push   %ebx
  801729:	e8 a6 fc ff ff       	call   8013d4 <fd_lookup>
  80172e:	83 c4 08             	add    $0x8,%esp
  801731:	89 c2                	mov    %eax,%edx
  801733:	85 c0                	test   %eax,%eax
  801735:	78 6b                	js     8017a2 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801741:	ff 30                	pushl  (%eax)
  801743:	e8 e2 fc ff ff       	call   80142a <dev_lookup>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 4a                	js     801799 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801752:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801756:	75 24                	jne    80177c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801758:	a1 04 40 80 00       	mov    0x804004,%eax
  80175d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	53                   	push   %ebx
  801767:	50                   	push   %eax
  801768:	68 00 29 80 00       	push   $0x802900
  80176d:	e8 d7 eb ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80177a:	eb 26                	jmp    8017a2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80177c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177f:	8b 52 0c             	mov    0xc(%edx),%edx
  801782:	85 d2                	test   %edx,%edx
  801784:	74 17                	je     80179d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	ff 75 10             	pushl  0x10(%ebp)
  80178c:	ff 75 0c             	pushl  0xc(%ebp)
  80178f:	50                   	push   %eax
  801790:	ff d2                	call   *%edx
  801792:	89 c2                	mov    %eax,%edx
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	eb 09                	jmp    8017a2 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801799:	89 c2                	mov    %eax,%edx
  80179b:	eb 05                	jmp    8017a2 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80179d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017a2:	89 d0                	mov    %edx,%eax
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017b2:	50                   	push   %eax
  8017b3:	ff 75 08             	pushl  0x8(%ebp)
  8017b6:	e8 19 fc ff ff       	call   8013d4 <fd_lookup>
  8017bb:	83 c4 08             	add    $0x8,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 0e                	js     8017d0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 14             	sub    $0x14,%esp
  8017d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	53                   	push   %ebx
  8017e1:	e8 ee fb ff ff       	call   8013d4 <fd_lookup>
  8017e6:	83 c4 08             	add    $0x8,%esp
  8017e9:	89 c2                	mov    %eax,%edx
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 68                	js     801857 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f5:	50                   	push   %eax
  8017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f9:	ff 30                	pushl  (%eax)
  8017fb:	e8 2a fc ff ff       	call   80142a <dev_lookup>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 47                	js     80184e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801807:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80180e:	75 24                	jne    801834 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801810:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801815:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	53                   	push   %ebx
  80181f:	50                   	push   %eax
  801820:	68 c0 28 80 00       	push   $0x8028c0
  801825:	e8 1f eb ff ff       	call   800349 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801832:	eb 23                	jmp    801857 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801834:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801837:	8b 52 18             	mov    0x18(%edx),%edx
  80183a:	85 d2                	test   %edx,%edx
  80183c:	74 14                	je     801852 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80183e:	83 ec 08             	sub    $0x8,%esp
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	50                   	push   %eax
  801845:	ff d2                	call   *%edx
  801847:	89 c2                	mov    %eax,%edx
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	eb 09                	jmp    801857 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184e:	89 c2                	mov    %eax,%edx
  801850:	eb 05                	jmp    801857 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801852:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801857:	89 d0                	mov    %edx,%eax
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	83 ec 14             	sub    $0x14,%esp
  801865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	ff 75 08             	pushl  0x8(%ebp)
  80186f:	e8 60 fb ff ff       	call   8013d4 <fd_lookup>
  801874:	83 c4 08             	add    $0x8,%esp
  801877:	89 c2                	mov    %eax,%edx
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 58                	js     8018d5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801883:	50                   	push   %eax
  801884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801887:	ff 30                	pushl  (%eax)
  801889:	e8 9c fb ff ff       	call   80142a <dev_lookup>
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	85 c0                	test   %eax,%eax
  801893:	78 37                	js     8018cc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801898:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80189c:	74 32                	je     8018d0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80189e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018a8:	00 00 00 
	stat->st_isdir = 0;
  8018ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b2:	00 00 00 
	stat->st_dev = dev;
  8018b5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	53                   	push   %ebx
  8018bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c2:	ff 50 14             	call   *0x14(%eax)
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb 09                	jmp    8018d5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cc:	89 c2                	mov    %eax,%edx
  8018ce:	eb 05                	jmp    8018d5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018d5:	89 d0                	mov    %edx,%eax
  8018d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	6a 00                	push   $0x0
  8018e6:	ff 75 08             	pushl  0x8(%ebp)
  8018e9:	e8 e3 01 00 00       	call   801ad1 <open>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 1b                	js     801912 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	ff 75 0c             	pushl  0xc(%ebp)
  8018fd:	50                   	push   %eax
  8018fe:	e8 5b ff ff ff       	call   80185e <fstat>
  801903:	89 c6                	mov    %eax,%esi
	close(fd);
  801905:	89 1c 24             	mov    %ebx,(%esp)
  801908:	e8 f4 fb ff ff       	call   801501 <close>
	return r;
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	89 f0                	mov    %esi,%eax
}
  801912:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	89 c6                	mov    %eax,%esi
  801920:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801922:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801929:	75 12                	jne    80193d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	6a 01                	push   $0x1
  801930:	e8 e4 f9 ff ff       	call   801319 <ipc_find_env>
  801935:	a3 00 40 80 00       	mov    %eax,0x804000
  80193a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80193d:	6a 07                	push   $0x7
  80193f:	68 00 50 80 00       	push   $0x805000
  801944:	56                   	push   %esi
  801945:	ff 35 00 40 80 00    	pushl  0x804000
  80194b:	e8 67 f9 ff ff       	call   8012b7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801950:	83 c4 0c             	add    $0xc,%esp
  801953:	6a 00                	push   $0x0
  801955:	53                   	push   %ebx
  801956:	6a 00                	push   $0x0
  801958:	e8 df f8 ff ff       	call   80123c <ipc_recv>
}
  80195d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	8b 40 0c             	mov    0xc(%eax),%eax
  801970:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801975:	8b 45 0c             	mov    0xc(%ebp),%eax
  801978:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80197d:	ba 00 00 00 00       	mov    $0x0,%edx
  801982:	b8 02 00 00 00       	mov    $0x2,%eax
  801987:	e8 8d ff ff ff       	call   801919 <fsipc>
}
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	8b 40 0c             	mov    0xc(%eax),%eax
  80199a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a9:	e8 6b ff ff ff       	call   801919 <fsipc>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 04             	sub    $0x4,%esp
  8019b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8019cf:	e8 45 ff ff ff       	call   801919 <fsipc>
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 2c                	js     801a04 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	68 00 50 80 00       	push   $0x805000
  8019e0:	53                   	push   %ebx
  8019e1:	e8 e8 ee ff ff       	call   8008ce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8019eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8019f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a12:	8b 55 08             	mov    0x8(%ebp),%edx
  801a15:	8b 52 0c             	mov    0xc(%edx),%edx
  801a18:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a1e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a23:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a28:	0f 47 c2             	cmova  %edx,%eax
  801a2b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a30:	50                   	push   %eax
  801a31:	ff 75 0c             	pushl  0xc(%ebp)
  801a34:	68 08 50 80 00       	push   $0x805008
  801a39:	e8 22 f0 ff ff       	call   800a60 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a43:	b8 04 00 00 00       	mov    $0x4,%eax
  801a48:	e8 cc fe ff ff       	call   801919 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a57:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a62:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a68:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6d:	b8 03 00 00 00       	mov    $0x3,%eax
  801a72:	e8 a2 fe ff ff       	call   801919 <fsipc>
  801a77:	89 c3                	mov    %eax,%ebx
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 4b                	js     801ac8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a7d:	39 c6                	cmp    %eax,%esi
  801a7f:	73 16                	jae    801a97 <devfile_read+0x48>
  801a81:	68 30 29 80 00       	push   $0x802930
  801a86:	68 37 29 80 00       	push   $0x802937
  801a8b:	6a 7c                	push   $0x7c
  801a8d:	68 4c 29 80 00       	push   $0x80294c
  801a92:	e8 d9 e7 ff ff       	call   800270 <_panic>
	assert(r <= PGSIZE);
  801a97:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a9c:	7e 16                	jle    801ab4 <devfile_read+0x65>
  801a9e:	68 57 29 80 00       	push   $0x802957
  801aa3:	68 37 29 80 00       	push   $0x802937
  801aa8:	6a 7d                	push   $0x7d
  801aaa:	68 4c 29 80 00       	push   $0x80294c
  801aaf:	e8 bc e7 ff ff       	call   800270 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ab4:	83 ec 04             	sub    $0x4,%esp
  801ab7:	50                   	push   %eax
  801ab8:	68 00 50 80 00       	push   $0x805000
  801abd:	ff 75 0c             	pushl  0xc(%ebp)
  801ac0:	e8 9b ef ff ff       	call   800a60 <memmove>
	return r;
  801ac5:	83 c4 10             	add    $0x10,%esp
}
  801ac8:	89 d8                	mov    %ebx,%eax
  801aca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 20             	sub    $0x20,%esp
  801ad8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801adb:	53                   	push   %ebx
  801adc:	e8 b4 ed ff ff       	call   800895 <strlen>
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae9:	7f 67                	jg     801b52 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af1:	50                   	push   %eax
  801af2:	e8 8e f8 ff ff       	call   801385 <fd_alloc>
  801af7:	83 c4 10             	add    $0x10,%esp
		return r;
  801afa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 57                	js     801b57 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b00:	83 ec 08             	sub    $0x8,%esp
  801b03:	53                   	push   %ebx
  801b04:	68 00 50 80 00       	push   $0x805000
  801b09:	e8 c0 ed ff ff       	call   8008ce <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b11:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b19:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1e:	e8 f6 fd ff ff       	call   801919 <fsipc>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	79 14                	jns    801b40 <open+0x6f>
		fd_close(fd, 0);
  801b2c:	83 ec 08             	sub    $0x8,%esp
  801b2f:	6a 00                	push   $0x0
  801b31:	ff 75 f4             	pushl  -0xc(%ebp)
  801b34:	e8 47 f9 ff ff       	call   801480 <fd_close>
		return r;
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	89 da                	mov    %ebx,%edx
  801b3e:	eb 17                	jmp    801b57 <open+0x86>
	}

	return fd2num(fd);
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	ff 75 f4             	pushl  -0xc(%ebp)
  801b46:	e8 13 f8 ff ff       	call   80135e <fd2num>
  801b4b:	89 c2                	mov    %eax,%edx
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	eb 05                	jmp    801b57 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b52:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b57:	89 d0                	mov    %edx,%eax
  801b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b64:	ba 00 00 00 00       	mov    $0x0,%edx
  801b69:	b8 08 00 00 00       	mov    $0x8,%eax
  801b6e:	e8 a6 fd ff ff       	call   801919 <fsipc>
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	c1 e8 16             	shr    $0x16,%eax
  801b80:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8c:	f6 c1 01             	test   $0x1,%cl
  801b8f:	74 1d                	je     801bae <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b91:	c1 ea 0c             	shr    $0xc,%edx
  801b94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9b:	f6 c2 01             	test   $0x1,%dl
  801b9e:	74 0e                	je     801bae <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba0:	c1 ea 0c             	shr    $0xc,%edx
  801ba3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801baa:	ef 
  801bab:	0f b7 c0             	movzwl %ax,%eax
}
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	ff 75 08             	pushl  0x8(%ebp)
  801bbe:	e8 ab f7 ff ff       	call   80136e <fd2data>
  801bc3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bc5:	83 c4 08             	add    $0x8,%esp
  801bc8:	68 63 29 80 00       	push   $0x802963
  801bcd:	53                   	push   %ebx
  801bce:	e8 fb ec ff ff       	call   8008ce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd3:	8b 46 04             	mov    0x4(%esi),%eax
  801bd6:	2b 06                	sub    (%esi),%eax
  801bd8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bde:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801be5:	00 00 00 
	stat->st_dev = &devpipe;
  801be8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bef:	30 80 00 
	return 0;
}
  801bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfa:	5b                   	pop    %ebx
  801bfb:	5e                   	pop    %esi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	53                   	push   %ebx
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c08:	53                   	push   %ebx
  801c09:	6a 00                	push   $0x0
  801c0b:	e8 46 f1 ff ff       	call   800d56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c10:	89 1c 24             	mov    %ebx,(%esp)
  801c13:	e8 56 f7 ff ff       	call   80136e <fd2data>
  801c18:	83 c4 08             	add    $0x8,%esp
  801c1b:	50                   	push   %eax
  801c1c:	6a 00                	push   $0x0
  801c1e:	e8 33 f1 ff ff       	call   800d56 <sys_page_unmap>
}
  801c23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	57                   	push   %edi
  801c2c:	56                   	push   %esi
  801c2d:	53                   	push   %ebx
  801c2e:	83 ec 1c             	sub    $0x1c,%esp
  801c31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c34:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c36:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3b:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	ff 75 e0             	pushl  -0x20(%ebp)
  801c47:	e8 29 ff ff ff       	call   801b75 <pageref>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	89 3c 24             	mov    %edi,(%esp)
  801c51:	e8 1f ff ff ff       	call   801b75 <pageref>
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	39 c3                	cmp    %eax,%ebx
  801c5b:	0f 94 c1             	sete   %cl
  801c5e:	0f b6 c9             	movzbl %cl,%ecx
  801c61:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c64:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c6a:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	74 1e                	je     801c92 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c74:	39 c3                	cmp    %eax,%ebx
  801c76:	75 be                	jne    801c36 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c78:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801c7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c81:	50                   	push   %eax
  801c82:	56                   	push   %esi
  801c83:	68 6a 29 80 00       	push   $0x80296a
  801c88:	e8 bc e6 ff ff       	call   800349 <cprintf>
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	eb a4                	jmp    801c36 <_pipeisclosed+0xe>
	}
}
  801c92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5f                   	pop    %edi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	57                   	push   %edi
  801ca1:	56                   	push   %esi
  801ca2:	53                   	push   %ebx
  801ca3:	83 ec 28             	sub    $0x28,%esp
  801ca6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ca9:	56                   	push   %esi
  801caa:	e8 bf f6 ff ff       	call   80136e <fd2data>
  801caf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	bf 00 00 00 00       	mov    $0x0,%edi
  801cb9:	eb 4b                	jmp    801d06 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cbb:	89 da                	mov    %ebx,%edx
  801cbd:	89 f0                	mov    %esi,%eax
  801cbf:	e8 64 ff ff ff       	call   801c28 <_pipeisclosed>
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	75 48                	jne    801d10 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cc8:	e8 e5 ef ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ccd:	8b 43 04             	mov    0x4(%ebx),%eax
  801cd0:	8b 0b                	mov    (%ebx),%ecx
  801cd2:	8d 51 20             	lea    0x20(%ecx),%edx
  801cd5:	39 d0                	cmp    %edx,%eax
  801cd7:	73 e2                	jae    801cbb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cdc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ce0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ce3:	89 c2                	mov    %eax,%edx
  801ce5:	c1 fa 1f             	sar    $0x1f,%edx
  801ce8:	89 d1                	mov    %edx,%ecx
  801cea:	c1 e9 1b             	shr    $0x1b,%ecx
  801ced:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cf0:	83 e2 1f             	and    $0x1f,%edx
  801cf3:	29 ca                	sub    %ecx,%edx
  801cf5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cf9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cfd:	83 c0 01             	add    $0x1,%eax
  801d00:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d03:	83 c7 01             	add    $0x1,%edi
  801d06:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d09:	75 c2                	jne    801ccd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0e:	eb 05                	jmp    801d15 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d18:	5b                   	pop    %ebx
  801d19:	5e                   	pop    %esi
  801d1a:	5f                   	pop    %edi
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	57                   	push   %edi
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	83 ec 18             	sub    $0x18,%esp
  801d26:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d29:	57                   	push   %edi
  801d2a:	e8 3f f6 ff ff       	call   80136e <fd2data>
  801d2f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d39:	eb 3d                	jmp    801d78 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d3b:	85 db                	test   %ebx,%ebx
  801d3d:	74 04                	je     801d43 <devpipe_read+0x26>
				return i;
  801d3f:	89 d8                	mov    %ebx,%eax
  801d41:	eb 44                	jmp    801d87 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d43:	89 f2                	mov    %esi,%edx
  801d45:	89 f8                	mov    %edi,%eax
  801d47:	e8 dc fe ff ff       	call   801c28 <_pipeisclosed>
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	75 32                	jne    801d82 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d50:	e8 5d ef ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d55:	8b 06                	mov    (%esi),%eax
  801d57:	3b 46 04             	cmp    0x4(%esi),%eax
  801d5a:	74 df                	je     801d3b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d5c:	99                   	cltd   
  801d5d:	c1 ea 1b             	shr    $0x1b,%edx
  801d60:	01 d0                	add    %edx,%eax
  801d62:	83 e0 1f             	and    $0x1f,%eax
  801d65:	29 d0                	sub    %edx,%eax
  801d67:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d72:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d75:	83 c3 01             	add    $0x1,%ebx
  801d78:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d7b:	75 d8                	jne    801d55 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d80:	eb 05                	jmp    801d87 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9a:	50                   	push   %eax
  801d9b:	e8 e5 f5 ff ff       	call   801385 <fd_alloc>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	89 c2                	mov    %eax,%edx
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 2c 01 00 00    	js     801ed9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dad:	83 ec 04             	sub    $0x4,%esp
  801db0:	68 07 04 00 00       	push   $0x407
  801db5:	ff 75 f4             	pushl  -0xc(%ebp)
  801db8:	6a 00                	push   $0x0
  801dba:	e8 12 ef ff ff       	call   800cd1 <sys_page_alloc>
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	89 c2                	mov    %eax,%edx
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	0f 88 0d 01 00 00    	js     801ed9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dcc:	83 ec 0c             	sub    $0xc,%esp
  801dcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dd2:	50                   	push   %eax
  801dd3:	e8 ad f5 ff ff       	call   801385 <fd_alloc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 e2 00 00 00    	js     801ec7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	68 07 04 00 00       	push   $0x407
  801ded:	ff 75 f0             	pushl  -0x10(%ebp)
  801df0:	6a 00                	push   $0x0
  801df2:	e8 da ee ff ff       	call   800cd1 <sys_page_alloc>
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	83 c4 10             	add    $0x10,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	0f 88 c3 00 00 00    	js     801ec7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e04:	83 ec 0c             	sub    $0xc,%esp
  801e07:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0a:	e8 5f f5 ff ff       	call   80136e <fd2data>
  801e0f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e11:	83 c4 0c             	add    $0xc,%esp
  801e14:	68 07 04 00 00       	push   $0x407
  801e19:	50                   	push   %eax
  801e1a:	6a 00                	push   $0x0
  801e1c:	e8 b0 ee ff ff       	call   800cd1 <sys_page_alloc>
  801e21:	89 c3                	mov    %eax,%ebx
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	85 c0                	test   %eax,%eax
  801e28:	0f 88 89 00 00 00    	js     801eb7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	ff 75 f0             	pushl  -0x10(%ebp)
  801e34:	e8 35 f5 ff ff       	call   80136e <fd2data>
  801e39:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e40:	50                   	push   %eax
  801e41:	6a 00                	push   $0x0
  801e43:	56                   	push   %esi
  801e44:	6a 00                	push   $0x0
  801e46:	e8 c9 ee ff ff       	call   800d14 <sys_page_map>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	83 c4 20             	add    $0x20,%esp
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 55                	js     801ea9 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e54:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e62:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e72:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e77:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	ff 75 f4             	pushl  -0xc(%ebp)
  801e84:	e8 d5 f4 ff ff       	call   80135e <fd2num>
  801e89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e8c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e8e:	83 c4 04             	add    $0x4,%esp
  801e91:	ff 75 f0             	pushl  -0x10(%ebp)
  801e94:	e8 c5 f4 ff ff       	call   80135e <fd2num>
  801e99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea7:	eb 30                	jmp    801ed9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ea9:	83 ec 08             	sub    $0x8,%esp
  801eac:	56                   	push   %esi
  801ead:	6a 00                	push   $0x0
  801eaf:	e8 a2 ee ff ff       	call   800d56 <sys_page_unmap>
  801eb4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eb7:	83 ec 08             	sub    $0x8,%esp
  801eba:	ff 75 f0             	pushl  -0x10(%ebp)
  801ebd:	6a 00                	push   $0x0
  801ebf:	e8 92 ee ff ff       	call   800d56 <sys_page_unmap>
  801ec4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ec7:	83 ec 08             	sub    $0x8,%esp
  801eca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 82 ee ff ff       	call   800d56 <sys_page_unmap>
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ed9:	89 d0                	mov    %edx,%eax
  801edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ee8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eeb:	50                   	push   %eax
  801eec:	ff 75 08             	pushl  0x8(%ebp)
  801eef:	e8 e0 f4 ff ff       	call   8013d4 <fd_lookup>
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	78 18                	js     801f13 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	ff 75 f4             	pushl  -0xc(%ebp)
  801f01:	e8 68 f4 ff ff       	call   80136e <fd2data>
	return _pipeisclosed(fd, p);
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	e8 18 fd ff ff       	call   801c28 <_pipeisclosed>
  801f10:	83 c4 10             	add    $0x10,%esp
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f18:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f25:	68 82 29 80 00       	push   $0x802982
  801f2a:	ff 75 0c             	pushl  0xc(%ebp)
  801f2d:	e8 9c e9 ff ff       	call   8008ce <strcpy>
	return 0;
}
  801f32:	b8 00 00 00 00       	mov    $0x0,%eax
  801f37:	c9                   	leave  
  801f38:	c3                   	ret    

00801f39 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	57                   	push   %edi
  801f3d:	56                   	push   %esi
  801f3e:	53                   	push   %ebx
  801f3f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f45:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f4a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f50:	eb 2d                	jmp    801f7f <devcons_write+0x46>
		m = n - tot;
  801f52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f55:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f57:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f5a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f5f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f62:	83 ec 04             	sub    $0x4,%esp
  801f65:	53                   	push   %ebx
  801f66:	03 45 0c             	add    0xc(%ebp),%eax
  801f69:	50                   	push   %eax
  801f6a:	57                   	push   %edi
  801f6b:	e8 f0 ea ff ff       	call   800a60 <memmove>
		sys_cputs(buf, m);
  801f70:	83 c4 08             	add    $0x8,%esp
  801f73:	53                   	push   %ebx
  801f74:	57                   	push   %edi
  801f75:	e8 9b ec ff ff       	call   800c15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f7a:	01 de                	add    %ebx,%esi
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	89 f0                	mov    %esi,%eax
  801f81:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f84:	72 cc                	jb     801f52 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f89:	5b                   	pop    %ebx
  801f8a:	5e                   	pop    %esi
  801f8b:	5f                   	pop    %edi
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 08             	sub    $0x8,%esp
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f9d:	74 2a                	je     801fc9 <devcons_read+0x3b>
  801f9f:	eb 05                	jmp    801fa6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fa1:	e8 0c ed ff ff       	call   800cb2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fa6:	e8 88 ec ff ff       	call   800c33 <sys_cgetc>
  801fab:	85 c0                	test   %eax,%eax
  801fad:	74 f2                	je     801fa1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	78 16                	js     801fc9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fb3:	83 f8 04             	cmp    $0x4,%eax
  801fb6:	74 0c                	je     801fc4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbb:	88 02                	mov    %al,(%edx)
	return 1;
  801fbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc2:	eb 05                	jmp    801fc9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fc4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fd7:	6a 01                	push   $0x1
  801fd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fdc:	50                   	push   %eax
  801fdd:	e8 33 ec ff ff       	call   800c15 <sys_cputs>
}
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    

00801fe7 <getchar>:

int
getchar(void)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fed:	6a 01                	push   $0x1
  801fef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff2:	50                   	push   %eax
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 43 f6 ff ff       	call   80163d <read>
	if (r < 0)
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 0f                	js     802010 <getchar+0x29>
		return r;
	if (r < 1)
  802001:	85 c0                	test   %eax,%eax
  802003:	7e 06                	jle    80200b <getchar+0x24>
		return -E_EOF;
	return c;
  802005:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802009:	eb 05                	jmp    802010 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80200b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802018:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201b:	50                   	push   %eax
  80201c:	ff 75 08             	pushl  0x8(%ebp)
  80201f:	e8 b0 f3 ff ff       	call   8013d4 <fd_lookup>
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	85 c0                	test   %eax,%eax
  802029:	78 11                	js     80203c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80202b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802034:	39 10                	cmp    %edx,(%eax)
  802036:	0f 94 c0             	sete   %al
  802039:	0f b6 c0             	movzbl %al,%eax
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <opencons>:

int
opencons(void)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802044:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802047:	50                   	push   %eax
  802048:	e8 38 f3 ff ff       	call   801385 <fd_alloc>
  80204d:	83 c4 10             	add    $0x10,%esp
		return r;
  802050:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802052:	85 c0                	test   %eax,%eax
  802054:	78 3e                	js     802094 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802056:	83 ec 04             	sub    $0x4,%esp
  802059:	68 07 04 00 00       	push   $0x407
  80205e:	ff 75 f4             	pushl  -0xc(%ebp)
  802061:	6a 00                	push   $0x0
  802063:	e8 69 ec ff ff       	call   800cd1 <sys_page_alloc>
  802068:	83 c4 10             	add    $0x10,%esp
		return r;
  80206b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 23                	js     802094 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802071:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802077:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80207c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802086:	83 ec 0c             	sub    $0xc,%esp
  802089:	50                   	push   %eax
  80208a:	e8 cf f2 ff ff       	call   80135e <fd2num>
  80208f:	89 c2                	mov    %eax,%edx
  802091:	83 c4 10             	add    $0x10,%esp
}
  802094:	89 d0                	mov    %edx,%eax
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80209e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020a5:	75 2a                	jne    8020d1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8020a7:	83 ec 04             	sub    $0x4,%esp
  8020aa:	6a 07                	push   $0x7
  8020ac:	68 00 f0 bf ee       	push   $0xeebff000
  8020b1:	6a 00                	push   $0x0
  8020b3:	e8 19 ec ff ff       	call   800cd1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	79 12                	jns    8020d1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8020bf:	50                   	push   %eax
  8020c0:	68 8e 29 80 00       	push   $0x80298e
  8020c5:	6a 23                	push   $0x23
  8020c7:	68 92 29 80 00       	push   $0x802992
  8020cc:	e8 9f e1 ff ff       	call   800270 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d4:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020d9:	83 ec 08             	sub    $0x8,%esp
  8020dc:	68 03 21 80 00       	push   $0x802103
  8020e1:	6a 00                	push   $0x0
  8020e3:	e8 34 ed ff ff       	call   800e1c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	79 12                	jns    802101 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020ef:	50                   	push   %eax
  8020f0:	68 8e 29 80 00       	push   $0x80298e
  8020f5:	6a 2c                	push   $0x2c
  8020f7:	68 92 29 80 00       	push   $0x802992
  8020fc:	e8 6f e1 ff ff       	call   800270 <_panic>
	}
}
  802101:	c9                   	leave  
  802102:	c3                   	ret    

00802103 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802103:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802104:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802109:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80210b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80210e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802112:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802117:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80211b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80211d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802120:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802121:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802124:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802125:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802126:	c3                   	ret    
  802127:	66 90                	xchg   %ax,%ax
  802129:	66 90                	xchg   %ax,%ax
  80212b:	66 90                	xchg   %ax,%ax
  80212d:	66 90                	xchg   %ax,%ax
  80212f:	90                   	nop

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80213b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80213f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 f6                	test   %esi,%esi
  802149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214d:	89 ca                	mov    %ecx,%edx
  80214f:	89 f8                	mov    %edi,%eax
  802151:	75 3d                	jne    802190 <__udivdi3+0x60>
  802153:	39 cf                	cmp    %ecx,%edi
  802155:	0f 87 c5 00 00 00    	ja     802220 <__udivdi3+0xf0>
  80215b:	85 ff                	test   %edi,%edi
  80215d:	89 fd                	mov    %edi,%ebp
  80215f:	75 0b                	jne    80216c <__udivdi3+0x3c>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	31 d2                	xor    %edx,%edx
  802168:	f7 f7                	div    %edi
  80216a:	89 c5                	mov    %eax,%ebp
  80216c:	89 c8                	mov    %ecx,%eax
  80216e:	31 d2                	xor    %edx,%edx
  802170:	f7 f5                	div    %ebp
  802172:	89 c1                	mov    %eax,%ecx
  802174:	89 d8                	mov    %ebx,%eax
  802176:	89 cf                	mov    %ecx,%edi
  802178:	f7 f5                	div    %ebp
  80217a:	89 c3                	mov    %eax,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	39 ce                	cmp    %ecx,%esi
  802192:	77 74                	ja     802208 <__udivdi3+0xd8>
  802194:	0f bd fe             	bsr    %esi,%edi
  802197:	83 f7 1f             	xor    $0x1f,%edi
  80219a:	0f 84 98 00 00 00    	je     802238 <__udivdi3+0x108>
  8021a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	89 c5                	mov    %eax,%ebp
  8021a9:	29 fb                	sub    %edi,%ebx
  8021ab:	d3 e6                	shl    %cl,%esi
  8021ad:	89 d9                	mov    %ebx,%ecx
  8021af:	d3 ed                	shr    %cl,%ebp
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	d3 e0                	shl    %cl,%eax
  8021b5:	09 ee                	or     %ebp,%esi
  8021b7:	89 d9                	mov    %ebx,%ecx
  8021b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bd:	89 d5                	mov    %edx,%ebp
  8021bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021c3:	d3 ed                	shr    %cl,%ebp
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e2                	shl    %cl,%edx
  8021c9:	89 d9                	mov    %ebx,%ecx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	09 c2                	or     %eax,%edx
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	89 ea                	mov    %ebp,%edx
  8021d3:	f7 f6                	div    %esi
  8021d5:	89 d5                	mov    %edx,%ebp
  8021d7:	89 c3                	mov    %eax,%ebx
  8021d9:	f7 64 24 0c          	mull   0xc(%esp)
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	72 10                	jb     8021f1 <__udivdi3+0xc1>
  8021e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e6                	shl    %cl,%esi
  8021e9:	39 c6                	cmp    %eax,%esi
  8021eb:	73 07                	jae    8021f4 <__udivdi3+0xc4>
  8021ed:	39 d5                	cmp    %edx,%ebp
  8021ef:	75 03                	jne    8021f4 <__udivdi3+0xc4>
  8021f1:	83 eb 01             	sub    $0x1,%ebx
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 d8                	mov    %ebx,%eax
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	31 ff                	xor    %edi,%edi
  80220a:	31 db                	xor    %ebx,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d8                	mov    %ebx,%eax
  802222:	f7 f7                	div    %edi
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 c3                	mov    %eax,%ebx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 fa                	mov    %edi,%edx
  80222c:	83 c4 1c             	add    $0x1c,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5f                   	pop    %edi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	39 ce                	cmp    %ecx,%esi
  80223a:	72 0c                	jb     802248 <__udivdi3+0x118>
  80223c:	31 db                	xor    %ebx,%ebx
  80223e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802242:	0f 87 34 ff ff ff    	ja     80217c <__udivdi3+0x4c>
  802248:	bb 01 00 00 00       	mov    $0x1,%ebx
  80224d:	e9 2a ff ff ff       	jmp    80217c <__udivdi3+0x4c>
  802252:	66 90                	xchg   %ax,%ax
  802254:	66 90                	xchg   %ax,%ax
  802256:	66 90                	xchg   %ax,%ax
  802258:	66 90                	xchg   %ax,%ax
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__umoddi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80226b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80226f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 d2                	test   %edx,%edx
  802279:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80227d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802281:	89 f3                	mov    %esi,%ebx
  802283:	89 3c 24             	mov    %edi,(%esp)
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	75 1c                	jne    8022a8 <__umoddi3+0x48>
  80228c:	39 f7                	cmp    %esi,%edi
  80228e:	76 50                	jbe    8022e0 <__umoddi3+0x80>
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	f7 f7                	div    %edi
  802296:	89 d0                	mov    %edx,%eax
  802298:	31 d2                	xor    %edx,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	89 d0                	mov    %edx,%eax
  8022ac:	77 52                	ja     802300 <__umoddi3+0xa0>
  8022ae:	0f bd ea             	bsr    %edx,%ebp
  8022b1:	83 f5 1f             	xor    $0x1f,%ebp
  8022b4:	75 5a                	jne    802310 <__umoddi3+0xb0>
  8022b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ba:	0f 82 e0 00 00 00    	jb     8023a0 <__umoddi3+0x140>
  8022c0:	39 0c 24             	cmp    %ecx,(%esp)
  8022c3:	0f 86 d7 00 00 00    	jbe    8023a0 <__umoddi3+0x140>
  8022c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	85 ff                	test   %edi,%edi
  8022e2:	89 fd                	mov    %edi,%ebp
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x91>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f7                	div    %edi
  8022ef:	89 c5                	mov    %eax,%ebp
  8022f1:	89 f0                	mov    %esi,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f5                	div    %ebp
  8022f7:	89 c8                	mov    %ecx,%eax
  8022f9:	f7 f5                	div    %ebp
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	eb 99                	jmp    802298 <__umoddi3+0x38>
  8022ff:	90                   	nop
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	83 c4 1c             	add    $0x1c,%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	8b 34 24             	mov    (%esp),%esi
  802313:	bf 20 00 00 00       	mov    $0x20,%edi
  802318:	89 e9                	mov    %ebp,%ecx
  80231a:	29 ef                	sub    %ebp,%edi
  80231c:	d3 e0                	shl    %cl,%eax
  80231e:	89 f9                	mov    %edi,%ecx
  802320:	89 f2                	mov    %esi,%edx
  802322:	d3 ea                	shr    %cl,%edx
  802324:	89 e9                	mov    %ebp,%ecx
  802326:	09 c2                	or     %eax,%edx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 14 24             	mov    %edx,(%esp)
  80232d:	89 f2                	mov    %esi,%edx
  80232f:	d3 e2                	shl    %cl,%edx
  802331:	89 f9                	mov    %edi,%ecx
  802333:	89 54 24 04          	mov    %edx,0x4(%esp)
  802337:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80233b:	d3 e8                	shr    %cl,%eax
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	89 c6                	mov    %eax,%esi
  802341:	d3 e3                	shl    %cl,%ebx
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 d0                	mov    %edx,%eax
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	09 d8                	or     %ebx,%eax
  80234d:	89 d3                	mov    %edx,%ebx
  80234f:	89 f2                	mov    %esi,%edx
  802351:	f7 34 24             	divl   (%esp)
  802354:	89 d6                	mov    %edx,%esi
  802356:	d3 e3                	shl    %cl,%ebx
  802358:	f7 64 24 04          	mull   0x4(%esp)
  80235c:	39 d6                	cmp    %edx,%esi
  80235e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802362:	89 d1                	mov    %edx,%ecx
  802364:	89 c3                	mov    %eax,%ebx
  802366:	72 08                	jb     802370 <__umoddi3+0x110>
  802368:	75 11                	jne    80237b <__umoddi3+0x11b>
  80236a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80236e:	73 0b                	jae    80237b <__umoddi3+0x11b>
  802370:	2b 44 24 04          	sub    0x4(%esp),%eax
  802374:	1b 14 24             	sbb    (%esp),%edx
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 c3                	mov    %eax,%ebx
  80237b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80237f:	29 da                	sub    %ebx,%edx
  802381:	19 ce                	sbb    %ecx,%esi
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e0                	shl    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	d3 ea                	shr    %cl,%edx
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	d3 ee                	shr    %cl,%esi
  802391:	09 d0                	or     %edx,%eax
  802393:	89 f2                	mov    %esi,%edx
  802395:	83 c4 1c             	add    $0x1c,%esp
  802398:	5b                   	pop    %ebx
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	29 f9                	sub    %edi,%ecx
  8023a2:	19 d6                	sbb    %edx,%esi
  8023a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ac:	e9 18 ff ff ff       	jmp    8022c9 <__umoddi3+0x69>
