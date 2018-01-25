
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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
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
  80003b:	68 60 23 80 00       	push   $0x802360
  800040:	e8 04 03 00 00       	call   800349 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 da 1c 00 00       	call   801d2a <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 79 23 80 00       	push   $0x802379
  80005d:	6a 0d                	push   $0xd
  80005f:	68 82 23 80 00       	push   $0x802382
  800064:	e8 07 02 00 00       	call   800270 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 6a 0f 00 00       	call   800fd8 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 96 23 80 00       	push   $0x802396
  80007a:	6a 10                	push   $0x10
  80007c:	68 82 23 80 00       	push   $0x802382
  800081:	e8 ea 01 00 00       	call   800270 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 19 14 00 00       	call   8014ae <close>
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
  8000a3:	e8 d5 1d 00 00       	call   801e7d <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 9f 23 80 00       	push   $0x80239f
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
  8000d7:	e8 18 11 00 00       	call   8011f4 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 ba 23 80 00       	push   $0x8023ba
  8000e8:	e8 5c 02 00 00       	call   800349 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
  8000f6:	89 f0                	mov    %esi,%eax
  8000f8:	c1 e0 07             	shl    $0x7,%eax
	cprintf("kid is %d\n", kid-envs);
  8000fb:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  8000fe:	c1 f8 03             	sar    $0x3,%eax
  800101:	69 c0 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%eax,%eax
  800107:	50                   	push   %eax
  800108:	68 c5 23 80 00       	push   $0x8023c5
  80010d:	e8 37 02 00 00       	call   800349 <cprintf>
	dup(p[0], 10);
  800112:	83 c4 08             	add    $0x8,%esp
  800115:	6a 0a                	push   $0xa
  800117:	ff 75 f0             	pushl  -0x10(%ebp)
  80011a:	e8 df 13 00 00       	call   8014fe <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	89 f0                	mov    %esi,%eax
  800124:	c1 e0 07             	shl    $0x7,%eax
  800127:	8d 9c f0 00 00 c0 ee 	lea    -0x11400000(%eax,%esi,8),%ebx
  80012e:	eb 10                	jmp    800140 <umain+0x10d>
		dup(p[0], 10);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	6a 0a                	push   $0xa
  800135:	ff 75 f0             	pushl  -0x10(%ebp)
  800138:	e8 c1 13 00 00       	call   8014fe <dup>
  80013d:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800140:	8b 43 60             	mov    0x60(%ebx),%eax
  800143:	83 f8 02             	cmp    $0x2,%eax
  800146:	74 e8                	je     800130 <umain+0xfd>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	68 d0 23 80 00       	push   $0x8023d0
  800150:	e8 f4 01 00 00       	call   800349 <cprintf>
	if (pipeisclosed(p[0]))
  800155:	83 c4 04             	add    $0x4,%esp
  800158:	ff 75 f0             	pushl  -0x10(%ebp)
  80015b:	e8 1d 1d 00 00       	call   801e7d <pipeisclosed>
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	85 c0                	test   %eax,%eax
  800165:	74 14                	je     80017b <umain+0x148>
		panic("somehow the other end of p[0] got closed!");
  800167:	83 ec 04             	sub    $0x4,%esp
  80016a:	68 2c 24 80 00       	push   $0x80242c
  80016f:	6a 3a                	push   $0x3a
  800171:	68 82 23 80 00       	push   $0x802382
  800176:	e8 f5 00 00 00       	call   800270 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	ff 75 f0             	pushl  -0x10(%ebp)
  800185:	e8 fa 11 00 00       	call   801384 <fd_lookup>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 12                	jns    8001a3 <umain+0x170>
		panic("cannot look up p[0]: %e", r);
  800191:	50                   	push   %eax
  800192:	68 e6 23 80 00       	push   $0x8023e6
  800197:	6a 3c                	push   $0x3c
  800199:	68 82 23 80 00       	push   $0x802382
  80019e:	e8 cd 00 00 00       	call   800270 <_panic>
	va = fd2data(fd);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a9:	e8 70 11 00 00       	call   80131e <fd2data>
	if (pageref(va) != 3+1)
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 63 19 00 00       	call   801b19 <pageref>
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	83 f8 04             	cmp    $0x4,%eax
  8001bc:	74 12                	je     8001d0 <umain+0x19d>
		cprintf("\nchild detected race\n");
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	68 fe 23 80 00       	push   $0x8023fe
  8001c6:	e8 7e 01 00 00       	call   800349 <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	eb 15                	jmp    8001e5 <umain+0x1b2>
	else
		cprintf("\nrace didn't happen\n", max);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	68 c8 00 00 00       	push   $0xc8
  8001d8:	68 14 24 80 00       	push   $0x802414
  8001dd:	e8 67 01 00 00       	call   800349 <cprintf>
  8001e2:	83 c4 10             	add    $0x10,%esp
}
  8001e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001f7:	e8 97 0a 00 00       	call   800c93 <sys_getenvid>
  8001fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800201:	89 c2                	mov    %eax,%edx
  800203:	c1 e2 07             	shl    $0x7,%edx
  800206:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80020d:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800212:	85 db                	test   %ebx,%ebx
  800214:	7e 07                	jle    80021d <libmain+0x31>
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
  80025c:	e8 78 12 00 00       	call   8014d9 <close_all>
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
  80028e:	68 60 24 80 00       	push   $0x802460
  800293:	e8 b1 00 00 00       	call   800349 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800298:	83 c4 18             	add    $0x18,%esp
  80029b:	53                   	push   %ebx
  80029c:	ff 75 10             	pushl  0x10(%ebp)
  80029f:	e8 54 00 00 00       	call   8002f8 <vcprintf>
	cprintf("\n");
  8002a4:	c7 04 24 77 23 80 00 	movl   $0x802377,(%esp)
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
  8003ac:	e8 1f 1d 00 00       	call   8020d0 <__udivdi3>
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
  8003ef:	e8 0c 1e 00 00       	call   802200 <__umoddi3>
  8003f4:	83 c4 14             	add    $0x14,%esp
  8003f7:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
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
  8004f3:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
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
  8005b7:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	75 18                	jne    8005da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005c2:	50                   	push   %eax
  8005c3:	68 9b 24 80 00       	push   $0x80249b
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
  8005db:	68 e9 28 80 00       	push   $0x8028e9
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
  8005ff:	b8 94 24 80 00       	mov    $0x802494,%eax
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
  800c7a:	68 7f 27 80 00       	push   $0x80277f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 9c 27 80 00       	push   $0x80279c
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
  800cfb:	68 7f 27 80 00       	push   $0x80277f
  800d00:	6a 23                	push   $0x23
  800d02:	68 9c 27 80 00       	push   $0x80279c
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
  800d3d:	68 7f 27 80 00       	push   $0x80277f
  800d42:	6a 23                	push   $0x23
  800d44:	68 9c 27 80 00       	push   $0x80279c
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
  800d7f:	68 7f 27 80 00       	push   $0x80277f
  800d84:	6a 23                	push   $0x23
  800d86:	68 9c 27 80 00       	push   $0x80279c
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
  800dc1:	68 7f 27 80 00       	push   $0x80277f
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 9c 27 80 00       	push   $0x80279c
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
  800e03:	68 7f 27 80 00       	push   $0x80277f
  800e08:	6a 23                	push   $0x23
  800e0a:	68 9c 27 80 00       	push   $0x80279c
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
  800e45:	68 7f 27 80 00       	push   $0x80277f
  800e4a:	6a 23                	push   $0x23
  800e4c:	68 9c 27 80 00       	push   $0x80279c
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
  800ea9:	68 7f 27 80 00       	push   $0x80277f
  800eae:	6a 23                	push   $0x23
  800eb0:	68 9c 27 80 00       	push   $0x80279c
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

00800f02 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	53                   	push   %ebx
  800f06:	83 ec 04             	sub    $0x4,%esp
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f0c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f0e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f12:	74 11                	je     800f25 <pgfault+0x23>
  800f14:	89 d8                	mov    %ebx,%eax
  800f16:	c1 e8 0c             	shr    $0xc,%eax
  800f19:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f20:	f6 c4 08             	test   $0x8,%ah
  800f23:	75 14                	jne    800f39 <pgfault+0x37>
		panic("faulting access");
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	68 aa 27 80 00       	push   $0x8027aa
  800f2d:	6a 1e                	push   $0x1e
  800f2f:	68 ba 27 80 00       	push   $0x8027ba
  800f34:	e8 37 f3 ff ff       	call   800270 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	6a 07                	push   $0x7
  800f3e:	68 00 f0 7f 00       	push   $0x7ff000
  800f43:	6a 00                	push   $0x0
  800f45:	e8 87 fd ff ff       	call   800cd1 <sys_page_alloc>
	if (r < 0) {
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 12                	jns    800f63 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f51:	50                   	push   %eax
  800f52:	68 c5 27 80 00       	push   $0x8027c5
  800f57:	6a 2c                	push   $0x2c
  800f59:	68 ba 27 80 00       	push   $0x8027ba
  800f5e:	e8 0d f3 ff ff       	call   800270 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f63:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	68 00 10 00 00       	push   $0x1000
  800f71:	53                   	push   %ebx
  800f72:	68 00 f0 7f 00       	push   $0x7ff000
  800f77:	e8 4c fb ff ff       	call   800ac8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f7c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f83:	53                   	push   %ebx
  800f84:	6a 00                	push   $0x0
  800f86:	68 00 f0 7f 00       	push   $0x7ff000
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 82 fd ff ff       	call   800d14 <sys_page_map>
	if (r < 0) {
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 12                	jns    800fab <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f99:	50                   	push   %eax
  800f9a:	68 c5 27 80 00       	push   $0x8027c5
  800f9f:	6a 33                	push   $0x33
  800fa1:	68 ba 27 80 00       	push   $0x8027ba
  800fa6:	e8 c5 f2 ff ff       	call   800270 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	68 00 f0 7f 00       	push   $0x7ff000
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 9c fd ff ff       	call   800d56 <sys_page_unmap>
	if (r < 0) {
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	79 12                	jns    800fd3 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fc1:	50                   	push   %eax
  800fc2:	68 c5 27 80 00       	push   $0x8027c5
  800fc7:	6a 37                	push   $0x37
  800fc9:	68 ba 27 80 00       	push   $0x8027ba
  800fce:	e8 9d f2 ff ff       	call   800270 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fe1:	68 02 0f 80 00       	push   $0x800f02
  800fe6:	e8 48 10 00 00       	call   802033 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800feb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff0:	cd 30                	int    $0x30
  800ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	79 17                	jns    801013 <fork+0x3b>
		panic("fork fault %e");
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 de 27 80 00       	push   $0x8027de
  801004:	68 84 00 00 00       	push   $0x84
  801009:	68 ba 27 80 00       	push   $0x8027ba
  80100e:	e8 5d f2 ff ff       	call   800270 <_panic>
  801013:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801015:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801019:	75 25                	jne    801040 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80101b:	e8 73 fc ff ff       	call   800c93 <sys_getenvid>
  801020:	25 ff 03 00 00       	and    $0x3ff,%eax
  801025:	89 c2                	mov    %eax,%edx
  801027:	c1 e2 07             	shl    $0x7,%edx
  80102a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801031:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801036:	b8 00 00 00 00       	mov    $0x0,%eax
  80103b:	e9 61 01 00 00       	jmp    8011a1 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	6a 07                	push   $0x7
  801045:	68 00 f0 bf ee       	push   $0xeebff000
  80104a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104d:	e8 7f fc ff ff       	call   800cd1 <sys_page_alloc>
  801052:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801055:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80105a:	89 d8                	mov    %ebx,%eax
  80105c:	c1 e8 16             	shr    $0x16,%eax
  80105f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801066:	a8 01                	test   $0x1,%al
  801068:	0f 84 fc 00 00 00    	je     80116a <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80106e:	89 d8                	mov    %ebx,%eax
  801070:	c1 e8 0c             	shr    $0xc,%eax
  801073:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80107a:	f6 c2 01             	test   $0x1,%dl
  80107d:	0f 84 e7 00 00 00    	je     80116a <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801083:	89 c6                	mov    %eax,%esi
  801085:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801088:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108f:	f6 c6 04             	test   $0x4,%dh
  801092:	74 39                	je     8010cd <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 66 fc ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	0f 89 b1 00 00 00    	jns    80116a <fork+0x192>
		    	panic("sys page map fault %e");
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	68 ec 27 80 00       	push   $0x8027ec
  8010c1:	6a 54                	push   $0x54
  8010c3:	68 ba 27 80 00       	push   $0x8027ba
  8010c8:	e8 a3 f1 ff ff       	call   800270 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d4:	f6 c2 02             	test   $0x2,%dl
  8010d7:	75 0c                	jne    8010e5 <fork+0x10d>
  8010d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e0:	f6 c4 08             	test   $0x8,%ah
  8010e3:	74 5b                	je     801140 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	68 05 08 00 00       	push   $0x805
  8010ed:	56                   	push   %esi
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	6a 00                	push   $0x0
  8010f2:	e8 1d fc ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  8010f7:	83 c4 20             	add    $0x20,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 14                	jns    801112 <fork+0x13a>
		    	panic("sys page map fault %e");
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	68 ec 27 80 00       	push   $0x8027ec
  801106:	6a 5b                	push   $0x5b
  801108:	68 ba 27 80 00       	push   $0x8027ba
  80110d:	e8 5e f1 ff ff       	call   800270 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	68 05 08 00 00       	push   $0x805
  80111a:	56                   	push   %esi
  80111b:	6a 00                	push   $0x0
  80111d:	56                   	push   %esi
  80111e:	6a 00                	push   $0x0
  801120:	e8 ef fb ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  801125:	83 c4 20             	add    $0x20,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	79 3e                	jns    80116a <fork+0x192>
		    	panic("sys page map fault %e");
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	68 ec 27 80 00       	push   $0x8027ec
  801134:	6a 5f                	push   $0x5f
  801136:	68 ba 27 80 00       	push   $0x8027ba
  80113b:	e8 30 f1 ff ff       	call   800270 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	6a 05                	push   $0x5
  801145:	56                   	push   %esi
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	6a 00                	push   $0x0
  80114a:	e8 c5 fb ff ff       	call   800d14 <sys_page_map>
		if (r < 0) {
  80114f:	83 c4 20             	add    $0x20,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	79 14                	jns    80116a <fork+0x192>
		    	panic("sys page map fault %e");
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	68 ec 27 80 00       	push   $0x8027ec
  80115e:	6a 64                	push   $0x64
  801160:	68 ba 27 80 00       	push   $0x8027ba
  801165:	e8 06 f1 ff ff       	call   800270 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80116a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801170:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801176:	0f 85 de fe ff ff    	jne    80105a <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80117c:	a1 04 40 80 00       	mov    0x804004,%eax
  801181:	8b 40 70             	mov    0x70(%eax),%eax
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	50                   	push   %eax
  801188:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80118b:	57                   	push   %edi
  80118c:	e8 8b fc ff ff       	call   800e1c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801191:	83 c4 08             	add    $0x8,%esp
  801194:	6a 02                	push   $0x2
  801196:	57                   	push   %edi
  801197:	e8 fc fb ff ff       	call   800d98 <sys_env_set_status>
	
	return envid;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <sfork>:

envid_t
sfork(void)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8011bb:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8011c1:	83 ec 08             	sub    $0x8,%esp
  8011c4:	53                   	push   %ebx
  8011c5:	68 04 28 80 00       	push   $0x802804
  8011ca:	e8 7a f1 ff ff       	call   800349 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011cf:	c7 04 24 36 02 80 00 	movl   $0x800236,(%esp)
  8011d6:	e8 e7 fc ff ff       	call   800ec2 <sys_thread_create>
  8011db:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011dd:	83 c4 08             	add    $0x8,%esp
  8011e0:	53                   	push   %ebx
  8011e1:	68 04 28 80 00       	push   $0x802804
  8011e6:	e8 5e f1 ff ff       	call   800349 <cprintf>
	return id;
	//return 0;
}
  8011eb:	89 f0                	mov    %esi,%eax
  8011ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	56                   	push   %esi
  8011f8:	53                   	push   %ebx
  8011f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801202:	85 c0                	test   %eax,%eax
  801204:	75 12                	jne    801218 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	68 00 00 c0 ee       	push   $0xeec00000
  80120e:	e8 6e fc ff ff       	call   800e81 <sys_ipc_recv>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	eb 0c                	jmp    801224 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	50                   	push   %eax
  80121c:	e8 60 fc ff ff       	call   800e81 <sys_ipc_recv>
  801221:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801224:	85 f6                	test   %esi,%esi
  801226:	0f 95 c1             	setne  %cl
  801229:	85 db                	test   %ebx,%ebx
  80122b:	0f 95 c2             	setne  %dl
  80122e:	84 d1                	test   %dl,%cl
  801230:	74 09                	je     80123b <ipc_recv+0x47>
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 1f             	shr    $0x1f,%edx
  801237:	84 d2                	test   %dl,%dl
  801239:	75 2a                	jne    801265 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80123b:	85 f6                	test   %esi,%esi
  80123d:	74 0d                	je     80124c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80123f:	a1 04 40 80 00       	mov    0x804004,%eax
  801244:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80124a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80124c:	85 db                	test   %ebx,%ebx
  80124e:	74 0d                	je     80125d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801250:	a1 04 40 80 00       	mov    0x804004,%eax
  801255:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  80125b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80125d:	a1 04 40 80 00       	mov    0x804004,%eax
  801262:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801265:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	57                   	push   %edi
  801270:	56                   	push   %esi
  801271:	53                   	push   %ebx
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	8b 7d 08             	mov    0x8(%ebp),%edi
  801278:	8b 75 0c             	mov    0xc(%ebp),%esi
  80127b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80127e:	85 db                	test   %ebx,%ebx
  801280:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801285:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801288:	ff 75 14             	pushl  0x14(%ebp)
  80128b:	53                   	push   %ebx
  80128c:	56                   	push   %esi
  80128d:	57                   	push   %edi
  80128e:	e8 cb fb ff ff       	call   800e5e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801293:	89 c2                	mov    %eax,%edx
  801295:	c1 ea 1f             	shr    $0x1f,%edx
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	84 d2                	test   %dl,%dl
  80129d:	74 17                	je     8012b6 <ipc_send+0x4a>
  80129f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012a2:	74 12                	je     8012b6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8012a4:	50                   	push   %eax
  8012a5:	68 27 28 80 00       	push   $0x802827
  8012aa:	6a 47                	push   $0x47
  8012ac:	68 35 28 80 00       	push   $0x802835
  8012b1:	e8 ba ef ff ff       	call   800270 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8012b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012b9:	75 07                	jne    8012c2 <ipc_send+0x56>
			sys_yield();
  8012bb:	e8 f2 f9 ff ff       	call   800cb2 <sys_yield>
  8012c0:	eb c6                	jmp    801288 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	75 c2                	jne    801288 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8012c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	c1 e2 07             	shl    $0x7,%edx
  8012de:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8012e5:	8b 52 5c             	mov    0x5c(%edx),%edx
  8012e8:	39 ca                	cmp    %ecx,%edx
  8012ea:	75 11                	jne    8012fd <ipc_find_env+0x2f>
			return envs[i].env_id;
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	c1 e2 07             	shl    $0x7,%edx
  8012f1:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8012f8:	8b 40 54             	mov    0x54(%eax),%eax
  8012fb:	eb 0f                	jmp    80130c <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012fd:	83 c0 01             	add    $0x1,%eax
  801300:	3d 00 04 00 00       	cmp    $0x400,%eax
  801305:	75 d2                	jne    8012d9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801307:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	05 00 00 00 30       	add    $0x30000000,%eax
  801319:	c1 e8 0c             	shr    $0xc,%eax
}
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
  801324:	05 00 00 00 30       	add    $0x30000000,%eax
  801329:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80132e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801340:	89 c2                	mov    %eax,%edx
  801342:	c1 ea 16             	shr    $0x16,%edx
  801345:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134c:	f6 c2 01             	test   $0x1,%dl
  80134f:	74 11                	je     801362 <fd_alloc+0x2d>
  801351:	89 c2                	mov    %eax,%edx
  801353:	c1 ea 0c             	shr    $0xc,%edx
  801356:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135d:	f6 c2 01             	test   $0x1,%dl
  801360:	75 09                	jne    80136b <fd_alloc+0x36>
			*fd_store = fd;
  801362:	89 01                	mov    %eax,(%ecx)
			return 0;
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
  801369:	eb 17                	jmp    801382 <fd_alloc+0x4d>
  80136b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801370:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801375:	75 c9                	jne    801340 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801377:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80137d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80138a:	83 f8 1f             	cmp    $0x1f,%eax
  80138d:	77 36                	ja     8013c5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80138f:	c1 e0 0c             	shl    $0xc,%eax
  801392:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801397:	89 c2                	mov    %eax,%edx
  801399:	c1 ea 16             	shr    $0x16,%edx
  80139c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a3:	f6 c2 01             	test   $0x1,%dl
  8013a6:	74 24                	je     8013cc <fd_lookup+0x48>
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	c1 ea 0c             	shr    $0xc,%edx
  8013ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b4:	f6 c2 01             	test   $0x1,%dl
  8013b7:	74 1a                	je     8013d3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013bc:	89 02                	mov    %eax,(%edx)
	return 0;
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	eb 13                	jmp    8013d8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ca:	eb 0c                	jmp    8013d8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d1:	eb 05                	jmp    8013d8 <fd_lookup+0x54>
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e3:	ba c0 28 80 00       	mov    $0x8028c0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e8:	eb 13                	jmp    8013fd <dev_lookup+0x23>
  8013ea:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ed:	39 08                	cmp    %ecx,(%eax)
  8013ef:	75 0c                	jne    8013fd <dev_lookup+0x23>
			*dev = devtab[i];
  8013f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	eb 2e                	jmp    80142b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013fd:	8b 02                	mov    (%edx),%eax
  8013ff:	85 c0                	test   %eax,%eax
  801401:	75 e7                	jne    8013ea <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801403:	a1 04 40 80 00       	mov    0x804004,%eax
  801408:	8b 40 54             	mov    0x54(%eax),%eax
  80140b:	83 ec 04             	sub    $0x4,%esp
  80140e:	51                   	push   %ecx
  80140f:	50                   	push   %eax
  801410:	68 40 28 80 00       	push   $0x802840
  801415:	e8 2f ef ff ff       	call   800349 <cprintf>
	*dev = 0;
  80141a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	83 ec 10             	sub    $0x10,%esp
  801435:	8b 75 08             	mov    0x8(%ebp),%esi
  801438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801445:	c1 e8 0c             	shr    $0xc,%eax
  801448:	50                   	push   %eax
  801449:	e8 36 ff ff ff       	call   801384 <fd_lookup>
  80144e:	83 c4 08             	add    $0x8,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 05                	js     80145a <fd_close+0x2d>
	    || fd != fd2)
  801455:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801458:	74 0c                	je     801466 <fd_close+0x39>
		return (must_exist ? r : 0);
  80145a:	84 db                	test   %bl,%bl
  80145c:	ba 00 00 00 00       	mov    $0x0,%edx
  801461:	0f 44 c2             	cmove  %edx,%eax
  801464:	eb 41                	jmp    8014a7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	ff 36                	pushl  (%esi)
  80146f:	e8 66 ff ff ff       	call   8013da <dev_lookup>
  801474:	89 c3                	mov    %eax,%ebx
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 1a                	js     801497 <fd_close+0x6a>
		if (dev->dev_close)
  80147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801480:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801483:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801488:	85 c0                	test   %eax,%eax
  80148a:	74 0b                	je     801497 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80148c:	83 ec 0c             	sub    $0xc,%esp
  80148f:	56                   	push   %esi
  801490:	ff d0                	call   *%eax
  801492:	89 c3                	mov    %eax,%ebx
  801494:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	56                   	push   %esi
  80149b:	6a 00                	push   $0x0
  80149d:	e8 b4 f8 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	89 d8                	mov    %ebx,%eax
}
  8014a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	ff 75 08             	pushl  0x8(%ebp)
  8014bb:	e8 c4 fe ff ff       	call   801384 <fd_lookup>
  8014c0:	83 c4 08             	add    $0x8,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 10                	js     8014d7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	6a 01                	push   $0x1
  8014cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cf:	e8 59 ff ff ff       	call   80142d <fd_close>
  8014d4:	83 c4 10             	add    $0x10,%esp
}
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <close_all>:

void
close_all(void)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	e8 c0 ff ff ff       	call   8014ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ee:	83 c3 01             	add    $0x1,%ebx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	83 fb 20             	cmp    $0x20,%ebx
  8014f7:	75 ec                	jne    8014e5 <close_all+0xc>
		close(i);
}
  8014f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 2c             	sub    $0x2c,%esp
  801507:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80150a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	ff 75 08             	pushl  0x8(%ebp)
  801511:	e8 6e fe ff ff       	call   801384 <fd_lookup>
  801516:	83 c4 08             	add    $0x8,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	0f 88 c1 00 00 00    	js     8015e2 <dup+0xe4>
		return r;
	close(newfdnum);
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	56                   	push   %esi
  801525:	e8 84 ff ff ff       	call   8014ae <close>

	newfd = INDEX2FD(newfdnum);
  80152a:	89 f3                	mov    %esi,%ebx
  80152c:	c1 e3 0c             	shl    $0xc,%ebx
  80152f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801535:	83 c4 04             	add    $0x4,%esp
  801538:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153b:	e8 de fd ff ff       	call   80131e <fd2data>
  801540:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801542:	89 1c 24             	mov    %ebx,(%esp)
  801545:	e8 d4 fd ff ff       	call   80131e <fd2data>
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801550:	89 f8                	mov    %edi,%eax
  801552:	c1 e8 16             	shr    $0x16,%eax
  801555:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155c:	a8 01                	test   $0x1,%al
  80155e:	74 37                	je     801597 <dup+0x99>
  801560:	89 f8                	mov    %edi,%eax
  801562:	c1 e8 0c             	shr    $0xc,%eax
  801565:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80156c:	f6 c2 01             	test   $0x1,%dl
  80156f:	74 26                	je     801597 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801571:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	25 07 0e 00 00       	and    $0xe07,%eax
  801580:	50                   	push   %eax
  801581:	ff 75 d4             	pushl  -0x2c(%ebp)
  801584:	6a 00                	push   $0x0
  801586:	57                   	push   %edi
  801587:	6a 00                	push   $0x0
  801589:	e8 86 f7 ff ff       	call   800d14 <sys_page_map>
  80158e:	89 c7                	mov    %eax,%edi
  801590:	83 c4 20             	add    $0x20,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 2e                	js     8015c5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801597:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159a:	89 d0                	mov    %edx,%eax
  80159c:	c1 e8 0c             	shr    $0xc,%eax
  80159f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a6:	83 ec 0c             	sub    $0xc,%esp
  8015a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ae:	50                   	push   %eax
  8015af:	53                   	push   %ebx
  8015b0:	6a 00                	push   $0x0
  8015b2:	52                   	push   %edx
  8015b3:	6a 00                	push   $0x0
  8015b5:	e8 5a f7 ff ff       	call   800d14 <sys_page_map>
  8015ba:	89 c7                	mov    %eax,%edi
  8015bc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015bf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c1:	85 ff                	test   %edi,%edi
  8015c3:	79 1d                	jns    8015e2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	6a 00                	push   $0x0
  8015cb:	e8 86 f7 ff ff       	call   800d56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d6:	6a 00                	push   $0x0
  8015d8:	e8 79 f7 ff ff       	call   800d56 <sys_page_unmap>
	return r;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	89 f8                	mov    %edi,%eax
}
  8015e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e5:	5b                   	pop    %ebx
  8015e6:	5e                   	pop    %esi
  8015e7:	5f                   	pop    %edi
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 14             	sub    $0x14,%esp
  8015f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	53                   	push   %ebx
  8015f9:	e8 86 fd ff ff       	call   801384 <fd_lookup>
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	89 c2                	mov    %eax,%edx
  801603:	85 c0                	test   %eax,%eax
  801605:	78 6d                	js     801674 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	ff 30                	pushl  (%eax)
  801613:	e8 c2 fd ff ff       	call   8013da <dev_lookup>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 4c                	js     80166b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80161f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801622:	8b 42 08             	mov    0x8(%edx),%eax
  801625:	83 e0 03             	and    $0x3,%eax
  801628:	83 f8 01             	cmp    $0x1,%eax
  80162b:	75 21                	jne    80164e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80162d:	a1 04 40 80 00       	mov    0x804004,%eax
  801632:	8b 40 54             	mov    0x54(%eax),%eax
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	53                   	push   %ebx
  801639:	50                   	push   %eax
  80163a:	68 84 28 80 00       	push   $0x802884
  80163f:	e8 05 ed ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164c:	eb 26                	jmp    801674 <read+0x8a>
	}
	if (!dev->dev_read)
  80164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801651:	8b 40 08             	mov    0x8(%eax),%eax
  801654:	85 c0                	test   %eax,%eax
  801656:	74 17                	je     80166f <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	ff 75 10             	pushl  0x10(%ebp)
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	52                   	push   %edx
  801662:	ff d0                	call   *%eax
  801664:	89 c2                	mov    %eax,%edx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb 09                	jmp    801674 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	eb 05                	jmp    801674 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80166f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801674:	89 d0                	mov    %edx,%eax
  801676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	83 ec 0c             	sub    $0xc,%esp
  801684:	8b 7d 08             	mov    0x8(%ebp),%edi
  801687:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80168a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168f:	eb 21                	jmp    8016b2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801691:	83 ec 04             	sub    $0x4,%esp
  801694:	89 f0                	mov    %esi,%eax
  801696:	29 d8                	sub    %ebx,%eax
  801698:	50                   	push   %eax
  801699:	89 d8                	mov    %ebx,%eax
  80169b:	03 45 0c             	add    0xc(%ebp),%eax
  80169e:	50                   	push   %eax
  80169f:	57                   	push   %edi
  8016a0:	e8 45 ff ff ff       	call   8015ea <read>
		if (m < 0)
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 10                	js     8016bc <readn+0x41>
			return m;
		if (m == 0)
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	74 0a                	je     8016ba <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b0:	01 c3                	add    %eax,%ebx
  8016b2:	39 f3                	cmp    %esi,%ebx
  8016b4:	72 db                	jb     801691 <readn+0x16>
  8016b6:	89 d8                	mov    %ebx,%eax
  8016b8:	eb 02                	jmp    8016bc <readn+0x41>
  8016ba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5f                   	pop    %edi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 14             	sub    $0x14,%esp
  8016cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	53                   	push   %ebx
  8016d3:	e8 ac fc ff ff       	call   801384 <fd_lookup>
  8016d8:	83 c4 08             	add    $0x8,%esp
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 68                	js     801749 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016eb:	ff 30                	pushl  (%eax)
  8016ed:	e8 e8 fc ff ff       	call   8013da <dev_lookup>
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 47                	js     801740 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801700:	75 21                	jne    801723 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801702:	a1 04 40 80 00       	mov    0x804004,%eax
  801707:	8b 40 54             	mov    0x54(%eax),%eax
  80170a:	83 ec 04             	sub    $0x4,%esp
  80170d:	53                   	push   %ebx
  80170e:	50                   	push   %eax
  80170f:	68 a0 28 80 00       	push   $0x8028a0
  801714:	e8 30 ec ff ff       	call   800349 <cprintf>
		return -E_INVAL;
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801721:	eb 26                	jmp    801749 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801723:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801726:	8b 52 0c             	mov    0xc(%edx),%edx
  801729:	85 d2                	test   %edx,%edx
  80172b:	74 17                	je     801744 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80172d:	83 ec 04             	sub    $0x4,%esp
  801730:	ff 75 10             	pushl  0x10(%ebp)
  801733:	ff 75 0c             	pushl  0xc(%ebp)
  801736:	50                   	push   %eax
  801737:	ff d2                	call   *%edx
  801739:	89 c2                	mov    %eax,%edx
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	eb 09                	jmp    801749 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801740:	89 c2                	mov    %eax,%edx
  801742:	eb 05                	jmp    801749 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801744:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801749:	89 d0                	mov    %edx,%eax
  80174b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <seek>:

int
seek(int fdnum, off_t offset)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801756:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	ff 75 08             	pushl  0x8(%ebp)
  80175d:	e8 22 fc ff ff       	call   801384 <fd_lookup>
  801762:	83 c4 08             	add    $0x8,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 0e                	js     801777 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801769:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80176c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801772:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	53                   	push   %ebx
  80177d:	83 ec 14             	sub    $0x14,%esp
  801780:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801783:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801786:	50                   	push   %eax
  801787:	53                   	push   %ebx
  801788:	e8 f7 fb ff ff       	call   801384 <fd_lookup>
  80178d:	83 c4 08             	add    $0x8,%esp
  801790:	89 c2                	mov    %eax,%edx
  801792:	85 c0                	test   %eax,%eax
  801794:	78 65                	js     8017fb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179c:	50                   	push   %eax
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	ff 30                	pushl  (%eax)
  8017a2:	e8 33 fc ff ff       	call   8013da <dev_lookup>
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 44                	js     8017f2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b5:	75 21                	jne    8017d8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017b7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017bc:	8b 40 54             	mov    0x54(%eax),%eax
  8017bf:	83 ec 04             	sub    $0x4,%esp
  8017c2:	53                   	push   %ebx
  8017c3:	50                   	push   %eax
  8017c4:	68 60 28 80 00       	push   $0x802860
  8017c9:	e8 7b eb ff ff       	call   800349 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017d6:	eb 23                	jmp    8017fb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017db:	8b 52 18             	mov    0x18(%edx),%edx
  8017de:	85 d2                	test   %edx,%edx
  8017e0:	74 14                	je     8017f6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	50                   	push   %eax
  8017e9:	ff d2                	call   *%edx
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	eb 09                	jmp    8017fb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	eb 05                	jmp    8017fb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017fb:	89 d0                	mov    %edx,%eax
  8017fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 14             	sub    $0x14,%esp
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180f:	50                   	push   %eax
  801810:	ff 75 08             	pushl  0x8(%ebp)
  801813:	e8 6c fb ff ff       	call   801384 <fd_lookup>
  801818:	83 c4 08             	add    $0x8,%esp
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 58                	js     801879 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801827:	50                   	push   %eax
  801828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182b:	ff 30                	pushl  (%eax)
  80182d:	e8 a8 fb ff ff       	call   8013da <dev_lookup>
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	78 37                	js     801870 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801840:	74 32                	je     801874 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801842:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801845:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80184c:	00 00 00 
	stat->st_isdir = 0;
  80184f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801856:	00 00 00 
	stat->st_dev = dev;
  801859:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80185f:	83 ec 08             	sub    $0x8,%esp
  801862:	53                   	push   %ebx
  801863:	ff 75 f0             	pushl  -0x10(%ebp)
  801866:	ff 50 14             	call   *0x14(%eax)
  801869:	89 c2                	mov    %eax,%edx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	eb 09                	jmp    801879 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801870:	89 c2                	mov    %eax,%edx
  801872:	eb 05                	jmp    801879 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801874:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801879:	89 d0                	mov    %edx,%eax
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	6a 00                	push   $0x0
  80188a:	ff 75 08             	pushl  0x8(%ebp)
  80188d:	e8 e3 01 00 00       	call   801a75 <open>
  801892:	89 c3                	mov    %eax,%ebx
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	85 c0                	test   %eax,%eax
  801899:	78 1b                	js     8018b6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	ff 75 0c             	pushl  0xc(%ebp)
  8018a1:	50                   	push   %eax
  8018a2:	e8 5b ff ff ff       	call   801802 <fstat>
  8018a7:	89 c6                	mov    %eax,%esi
	close(fd);
  8018a9:	89 1c 24             	mov    %ebx,(%esp)
  8018ac:	e8 fd fb ff ff       	call   8014ae <close>
	return r;
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	89 f0                	mov    %esi,%eax
}
  8018b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5e                   	pop    %esi
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	89 c6                	mov    %eax,%esi
  8018c4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018c6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018cd:	75 12                	jne    8018e1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018cf:	83 ec 0c             	sub    $0xc,%esp
  8018d2:	6a 01                	push   $0x1
  8018d4:	e8 f5 f9 ff ff       	call   8012ce <ipc_find_env>
  8018d9:	a3 00 40 80 00       	mov    %eax,0x804000
  8018de:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e1:	6a 07                	push   $0x7
  8018e3:	68 00 50 80 00       	push   $0x805000
  8018e8:	56                   	push   %esi
  8018e9:	ff 35 00 40 80 00    	pushl  0x804000
  8018ef:	e8 78 f9 ff ff       	call   80126c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018f4:	83 c4 0c             	add    $0xc,%esp
  8018f7:	6a 00                	push   $0x0
  8018f9:	53                   	push   %ebx
  8018fa:	6a 00                	push   $0x0
  8018fc:	e8 f3 f8 ff ff       	call   8011f4 <ipc_recv>
}
  801901:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801904:	5b                   	pop    %ebx
  801905:	5e                   	pop    %esi
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	8b 40 0c             	mov    0xc(%eax),%eax
  801914:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801921:	ba 00 00 00 00       	mov    $0x0,%edx
  801926:	b8 02 00 00 00       	mov    $0x2,%eax
  80192b:	e8 8d ff ff ff       	call   8018bd <fsipc>
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	8b 40 0c             	mov    0xc(%eax),%eax
  80193e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801943:	ba 00 00 00 00       	mov    $0x0,%edx
  801948:	b8 06 00 00 00       	mov    $0x6,%eax
  80194d:	e8 6b ff ff ff       	call   8018bd <fsipc>
}
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	83 ec 04             	sub    $0x4,%esp
  80195b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	8b 40 0c             	mov    0xc(%eax),%eax
  801964:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801969:	ba 00 00 00 00       	mov    $0x0,%edx
  80196e:	b8 05 00 00 00       	mov    $0x5,%eax
  801973:	e8 45 ff ff ff       	call   8018bd <fsipc>
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 2c                	js     8019a8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	68 00 50 80 00       	push   $0x805000
  801984:	53                   	push   %ebx
  801985:	e8 44 ef ff ff       	call   8008ce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80198a:	a1 80 50 80 00       	mov    0x805080,%eax
  80198f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801995:	a1 84 50 80 00       	mov    0x805084,%eax
  80199a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8019b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8019bc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019c2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019c7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019cc:	0f 47 c2             	cmova  %edx,%eax
  8019cf:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019d4:	50                   	push   %eax
  8019d5:	ff 75 0c             	pushl  0xc(%ebp)
  8019d8:	68 08 50 80 00       	push   $0x805008
  8019dd:	e8 7e f0 ff ff       	call   800a60 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ec:	e8 cc fe ff ff       	call   8018bd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801a01:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a06:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a11:	b8 03 00 00 00       	mov    $0x3,%eax
  801a16:	e8 a2 fe ff ff       	call   8018bd <fsipc>
  801a1b:	89 c3                	mov    %eax,%ebx
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 4b                	js     801a6c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a21:	39 c6                	cmp    %eax,%esi
  801a23:	73 16                	jae    801a3b <devfile_read+0x48>
  801a25:	68 d0 28 80 00       	push   $0x8028d0
  801a2a:	68 d7 28 80 00       	push   $0x8028d7
  801a2f:	6a 7c                	push   $0x7c
  801a31:	68 ec 28 80 00       	push   $0x8028ec
  801a36:	e8 35 e8 ff ff       	call   800270 <_panic>
	assert(r <= PGSIZE);
  801a3b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a40:	7e 16                	jle    801a58 <devfile_read+0x65>
  801a42:	68 f7 28 80 00       	push   $0x8028f7
  801a47:	68 d7 28 80 00       	push   $0x8028d7
  801a4c:	6a 7d                	push   $0x7d
  801a4e:	68 ec 28 80 00       	push   $0x8028ec
  801a53:	e8 18 e8 ff ff       	call   800270 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a58:	83 ec 04             	sub    $0x4,%esp
  801a5b:	50                   	push   %eax
  801a5c:	68 00 50 80 00       	push   $0x805000
  801a61:	ff 75 0c             	pushl  0xc(%ebp)
  801a64:	e8 f7 ef ff ff       	call   800a60 <memmove>
	return r;
  801a69:	83 c4 10             	add    $0x10,%esp
}
  801a6c:	89 d8                	mov    %ebx,%eax
  801a6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	53                   	push   %ebx
  801a79:	83 ec 20             	sub    $0x20,%esp
  801a7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a7f:	53                   	push   %ebx
  801a80:	e8 10 ee ff ff       	call   800895 <strlen>
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a8d:	7f 67                	jg     801af6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	e8 9a f8 ff ff       	call   801335 <fd_alloc>
  801a9b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a9e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 57                	js     801afb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aa4:	83 ec 08             	sub    $0x8,%esp
  801aa7:	53                   	push   %ebx
  801aa8:	68 00 50 80 00       	push   $0x805000
  801aad:	e8 1c ee ff ff       	call   8008ce <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801abd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac2:	e8 f6 fd ff ff       	call   8018bd <fsipc>
  801ac7:	89 c3                	mov    %eax,%ebx
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	85 c0                	test   %eax,%eax
  801ace:	79 14                	jns    801ae4 <open+0x6f>
		fd_close(fd, 0);
  801ad0:	83 ec 08             	sub    $0x8,%esp
  801ad3:	6a 00                	push   $0x0
  801ad5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad8:	e8 50 f9 ff ff       	call   80142d <fd_close>
		return r;
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	89 da                	mov    %ebx,%edx
  801ae2:	eb 17                	jmp    801afb <open+0x86>
	}

	return fd2num(fd);
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aea:	e8 1f f8 ff ff       	call   80130e <fd2num>
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	eb 05                	jmp    801afb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801af6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b08:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0d:	b8 08 00 00 00       	mov    $0x8,%eax
  801b12:	e8 a6 fd ff ff       	call   8018bd <fsipc>
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1f:	89 d0                	mov    %edx,%eax
  801b21:	c1 e8 16             	shr    $0x16,%eax
  801b24:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b30:	f6 c1 01             	test   $0x1,%cl
  801b33:	74 1d                	je     801b52 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b35:	c1 ea 0c             	shr    $0xc,%edx
  801b38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b3f:	f6 c2 01             	test   $0x1,%dl
  801b42:	74 0e                	je     801b52 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b44:	c1 ea 0c             	shr    $0xc,%edx
  801b47:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b4e:	ef 
  801b4f:	0f b7 c0             	movzwl %ax,%eax
}
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	ff 75 08             	pushl  0x8(%ebp)
  801b62:	e8 b7 f7 ff ff       	call   80131e <fd2data>
  801b67:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b69:	83 c4 08             	add    $0x8,%esp
  801b6c:	68 03 29 80 00       	push   $0x802903
  801b71:	53                   	push   %ebx
  801b72:	e8 57 ed ff ff       	call   8008ce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b77:	8b 46 04             	mov    0x4(%esi),%eax
  801b7a:	2b 06                	sub    (%esi),%eax
  801b7c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b82:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b89:	00 00 00 
	stat->st_dev = &devpipe;
  801b8c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b93:	30 80 00 
	return 0;
}
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bac:	53                   	push   %ebx
  801bad:	6a 00                	push   $0x0
  801baf:	e8 a2 f1 ff ff       	call   800d56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb4:	89 1c 24             	mov    %ebx,(%esp)
  801bb7:	e8 62 f7 ff ff       	call   80131e <fd2data>
  801bbc:	83 c4 08             	add    $0x8,%esp
  801bbf:	50                   	push   %eax
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 8f f1 ff ff       	call   800d56 <sys_page_unmap>
}
  801bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	57                   	push   %edi
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 1c             	sub    $0x1c,%esp
  801bd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bda:	a1 04 40 80 00       	mov    0x804004,%eax
  801bdf:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 e0             	pushl  -0x20(%ebp)
  801be8:	e8 2c ff ff ff       	call   801b19 <pageref>
  801bed:	89 c3                	mov    %eax,%ebx
  801bef:	89 3c 24             	mov    %edi,(%esp)
  801bf2:	e8 22 ff ff ff       	call   801b19 <pageref>
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	39 c3                	cmp    %eax,%ebx
  801bfc:	0f 94 c1             	sete   %cl
  801bff:	0f b6 c9             	movzbl %cl,%ecx
  801c02:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c05:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c0b:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801c0e:	39 ce                	cmp    %ecx,%esi
  801c10:	74 1b                	je     801c2d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c12:	39 c3                	cmp    %eax,%ebx
  801c14:	75 c4                	jne    801bda <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c16:	8b 42 64             	mov    0x64(%edx),%eax
  801c19:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1c:	50                   	push   %eax
  801c1d:	56                   	push   %esi
  801c1e:	68 0a 29 80 00       	push   $0x80290a
  801c23:	e8 21 e7 ff ff       	call   800349 <cprintf>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	eb ad                	jmp    801bda <_pipeisclosed+0xe>
	}
}
  801c2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	57                   	push   %edi
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 28             	sub    $0x28,%esp
  801c41:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c44:	56                   	push   %esi
  801c45:	e8 d4 f6 ff ff       	call   80131e <fd2data>
  801c4a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c54:	eb 4b                	jmp    801ca1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c56:	89 da                	mov    %ebx,%edx
  801c58:	89 f0                	mov    %esi,%eax
  801c5a:	e8 6d ff ff ff       	call   801bcc <_pipeisclosed>
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	75 48                	jne    801cab <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c63:	e8 4a f0 ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c68:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6b:	8b 0b                	mov    (%ebx),%ecx
  801c6d:	8d 51 20             	lea    0x20(%ecx),%edx
  801c70:	39 d0                	cmp    %edx,%eax
  801c72:	73 e2                	jae    801c56 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c77:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c7b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c7e:	89 c2                	mov    %eax,%edx
  801c80:	c1 fa 1f             	sar    $0x1f,%edx
  801c83:	89 d1                	mov    %edx,%ecx
  801c85:	c1 e9 1b             	shr    $0x1b,%ecx
  801c88:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c8b:	83 e2 1f             	and    $0x1f,%edx
  801c8e:	29 ca                	sub    %ecx,%edx
  801c90:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c94:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c98:	83 c0 01             	add    $0x1,%eax
  801c9b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9e:	83 c7 01             	add    $0x1,%edi
  801ca1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ca4:	75 c2                	jne    801c68 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ca6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca9:	eb 05                	jmp    801cb0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    

00801cb8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 18             	sub    $0x18,%esp
  801cc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cc4:	57                   	push   %edi
  801cc5:	e8 54 f6 ff ff       	call   80131e <fd2data>
  801cca:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd4:	eb 3d                	jmp    801d13 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cd6:	85 db                	test   %ebx,%ebx
  801cd8:	74 04                	je     801cde <devpipe_read+0x26>
				return i;
  801cda:	89 d8                	mov    %ebx,%eax
  801cdc:	eb 44                	jmp    801d22 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cde:	89 f2                	mov    %esi,%edx
  801ce0:	89 f8                	mov    %edi,%eax
  801ce2:	e8 e5 fe ff ff       	call   801bcc <_pipeisclosed>
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	75 32                	jne    801d1d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ceb:	e8 c2 ef ff ff       	call   800cb2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cf0:	8b 06                	mov    (%esi),%eax
  801cf2:	3b 46 04             	cmp    0x4(%esi),%eax
  801cf5:	74 df                	je     801cd6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf7:	99                   	cltd   
  801cf8:	c1 ea 1b             	shr    $0x1b,%edx
  801cfb:	01 d0                	add    %edx,%eax
  801cfd:	83 e0 1f             	and    $0x1f,%eax
  801d00:	29 d0                	sub    %edx,%eax
  801d02:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d0a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d0d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d10:	83 c3 01             	add    $0x1,%ebx
  801d13:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d16:	75 d8                	jne    801cf0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d18:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1b:	eb 05                	jmp    801d22 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d1d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5e                   	pop    %esi
  801d27:	5f                   	pop    %edi
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    

00801d2a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	56                   	push   %esi
  801d2e:	53                   	push   %ebx
  801d2f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d35:	50                   	push   %eax
  801d36:	e8 fa f5 ff ff       	call   801335 <fd_alloc>
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	85 c0                	test   %eax,%eax
  801d42:	0f 88 2c 01 00 00    	js     801e74 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d48:	83 ec 04             	sub    $0x4,%esp
  801d4b:	68 07 04 00 00       	push   $0x407
  801d50:	ff 75 f4             	pushl  -0xc(%ebp)
  801d53:	6a 00                	push   $0x0
  801d55:	e8 77 ef ff ff       	call   800cd1 <sys_page_alloc>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	89 c2                	mov    %eax,%edx
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	0f 88 0d 01 00 00    	js     801e74 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d67:	83 ec 0c             	sub    $0xc,%esp
  801d6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6d:	50                   	push   %eax
  801d6e:	e8 c2 f5 ff ff       	call   801335 <fd_alloc>
  801d73:	89 c3                	mov    %eax,%ebx
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	0f 88 e2 00 00 00    	js     801e62 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d80:	83 ec 04             	sub    $0x4,%esp
  801d83:	68 07 04 00 00       	push   $0x407
  801d88:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 3f ef ff ff       	call   800cd1 <sys_page_alloc>
  801d92:	89 c3                	mov    %eax,%ebx
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	0f 88 c3 00 00 00    	js     801e62 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	ff 75 f4             	pushl  -0xc(%ebp)
  801da5:	e8 74 f5 ff ff       	call   80131e <fd2data>
  801daa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dac:	83 c4 0c             	add    $0xc,%esp
  801daf:	68 07 04 00 00       	push   $0x407
  801db4:	50                   	push   %eax
  801db5:	6a 00                	push   $0x0
  801db7:	e8 15 ef ff ff       	call   800cd1 <sys_page_alloc>
  801dbc:	89 c3                	mov    %eax,%ebx
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	0f 88 89 00 00 00    	js     801e52 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcf:	e8 4a f5 ff ff       	call   80131e <fd2data>
  801dd4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ddb:	50                   	push   %eax
  801ddc:	6a 00                	push   $0x0
  801dde:	56                   	push   %esi
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 2e ef ff ff       	call   800d14 <sys_page_map>
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	83 c4 20             	add    $0x20,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 55                	js     801e44 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801def:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e04:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e12:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1f:	e8 ea f4 ff ff       	call   80130e <fd2num>
  801e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e27:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e29:	83 c4 04             	add    $0x4,%esp
  801e2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e2f:	e8 da f4 ff ff       	call   80130e <fd2num>
  801e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e37:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e42:	eb 30                	jmp    801e74 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e44:	83 ec 08             	sub    $0x8,%esp
  801e47:	56                   	push   %esi
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 07 ef ff ff       	call   800d56 <sys_page_unmap>
  801e4f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	ff 75 f0             	pushl  -0x10(%ebp)
  801e58:	6a 00                	push   $0x0
  801e5a:	e8 f7 ee ff ff       	call   800d56 <sys_page_unmap>
  801e5f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e62:	83 ec 08             	sub    $0x8,%esp
  801e65:	ff 75 f4             	pushl  -0xc(%ebp)
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 e7 ee ff ff       	call   800d56 <sys_page_unmap>
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e74:	89 d0                	mov    %edx,%eax
  801e76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e79:	5b                   	pop    %ebx
  801e7a:	5e                   	pop    %esi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e86:	50                   	push   %eax
  801e87:	ff 75 08             	pushl  0x8(%ebp)
  801e8a:	e8 f5 f4 ff ff       	call   801384 <fd_lookup>
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 18                	js     801eae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e96:	83 ec 0c             	sub    $0xc,%esp
  801e99:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9c:	e8 7d f4 ff ff       	call   80131e <fd2data>
	return _pipeisclosed(fd, p);
  801ea1:	89 c2                	mov    %eax,%edx
  801ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea6:	e8 21 fd ff ff       	call   801bcc <_pipeisclosed>
  801eab:	83 c4 10             	add    $0x10,%esp
}
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    

00801eb0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ec0:	68 22 29 80 00       	push   $0x802922
  801ec5:	ff 75 0c             	pushl  0xc(%ebp)
  801ec8:	e8 01 ea ff ff       	call   8008ce <strcpy>
	return 0;
}
  801ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eeb:	eb 2d                	jmp    801f1a <devcons_write+0x46>
		m = n - tot;
  801eed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ef2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ef5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801efa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801efd:	83 ec 04             	sub    $0x4,%esp
  801f00:	53                   	push   %ebx
  801f01:	03 45 0c             	add    0xc(%ebp),%eax
  801f04:	50                   	push   %eax
  801f05:	57                   	push   %edi
  801f06:	e8 55 eb ff ff       	call   800a60 <memmove>
		sys_cputs(buf, m);
  801f0b:	83 c4 08             	add    $0x8,%esp
  801f0e:	53                   	push   %ebx
  801f0f:	57                   	push   %edi
  801f10:	e8 00 ed ff ff       	call   800c15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f15:	01 de                	add    %ebx,%esi
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	89 f0                	mov    %esi,%eax
  801f1c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f1f:	72 cc                	jb     801eed <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f24:	5b                   	pop    %ebx
  801f25:	5e                   	pop    %esi
  801f26:	5f                   	pop    %edi
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	83 ec 08             	sub    $0x8,%esp
  801f2f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f38:	74 2a                	je     801f64 <devcons_read+0x3b>
  801f3a:	eb 05                	jmp    801f41 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f3c:	e8 71 ed ff ff       	call   800cb2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f41:	e8 ed ec ff ff       	call   800c33 <sys_cgetc>
  801f46:	85 c0                	test   %eax,%eax
  801f48:	74 f2                	je     801f3c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	78 16                	js     801f64 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f4e:	83 f8 04             	cmp    $0x4,%eax
  801f51:	74 0c                	je     801f5f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f53:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f56:	88 02                	mov    %al,(%edx)
	return 1;
  801f58:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5d:	eb 05                	jmp    801f64 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    

00801f66 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f72:	6a 01                	push   $0x1
  801f74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f77:	50                   	push   %eax
  801f78:	e8 98 ec ff ff       	call   800c15 <sys_cputs>
}
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    

00801f82 <getchar>:

int
getchar(void)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f88:	6a 01                	push   $0x1
  801f8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8d:	50                   	push   %eax
  801f8e:	6a 00                	push   $0x0
  801f90:	e8 55 f6 ff ff       	call   8015ea <read>
	if (r < 0)
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	78 0f                	js     801fab <getchar+0x29>
		return r;
	if (r < 1)
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	7e 06                	jle    801fa6 <getchar+0x24>
		return -E_EOF;
	return c;
  801fa0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fa4:	eb 05                	jmp    801fab <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fa6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	ff 75 08             	pushl  0x8(%ebp)
  801fba:	e8 c5 f3 ff ff       	call   801384 <fd_lookup>
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 11                	js     801fd7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fcf:	39 10                	cmp    %edx,(%eax)
  801fd1:	0f 94 c0             	sete   %al
  801fd4:	0f b6 c0             	movzbl %al,%eax
}
  801fd7:	c9                   	leave  
  801fd8:	c3                   	ret    

00801fd9 <opencons>:

int
opencons(void)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe2:	50                   	push   %eax
  801fe3:	e8 4d f3 ff ff       	call   801335 <fd_alloc>
  801fe8:	83 c4 10             	add    $0x10,%esp
		return r;
  801feb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fed:	85 c0                	test   %eax,%eax
  801fef:	78 3e                	js     80202f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff1:	83 ec 04             	sub    $0x4,%esp
  801ff4:	68 07 04 00 00       	push   $0x407
  801ff9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffc:	6a 00                	push   $0x0
  801ffe:	e8 ce ec ff ff       	call   800cd1 <sys_page_alloc>
  802003:	83 c4 10             	add    $0x10,%esp
		return r;
  802006:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 23                	js     80202f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80200c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802015:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	50                   	push   %eax
  802025:	e8 e4 f2 ff ff       	call   80130e <fd2num>
  80202a:	89 c2                	mov    %eax,%edx
  80202c:	83 c4 10             	add    $0x10,%esp
}
  80202f:	89 d0                	mov    %edx,%eax
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802039:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802040:	75 2a                	jne    80206c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802042:	83 ec 04             	sub    $0x4,%esp
  802045:	6a 07                	push   $0x7
  802047:	68 00 f0 bf ee       	push   $0xeebff000
  80204c:	6a 00                	push   $0x0
  80204e:	e8 7e ec ff ff       	call   800cd1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	79 12                	jns    80206c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80205a:	50                   	push   %eax
  80205b:	68 2e 29 80 00       	push   $0x80292e
  802060:	6a 23                	push   $0x23
  802062:	68 32 29 80 00       	push   $0x802932
  802067:	e8 04 e2 ff ff       	call   800270 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80206c:	8b 45 08             	mov    0x8(%ebp),%eax
  80206f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802074:	83 ec 08             	sub    $0x8,%esp
  802077:	68 9e 20 80 00       	push   $0x80209e
  80207c:	6a 00                	push   $0x0
  80207e:	e8 99 ed ff ff       	call   800e1c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	79 12                	jns    80209c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80208a:	50                   	push   %eax
  80208b:	68 2e 29 80 00       	push   $0x80292e
  802090:	6a 2c                	push   $0x2c
  802092:	68 32 29 80 00       	push   $0x802932
  802097:	e8 d4 e1 ff ff       	call   800270 <_panic>
	}
}
  80209c:	c9                   	leave  
  80209d:	c3                   	ret    

0080209e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80209e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80209f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020a4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020a6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020a9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020ad:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020b2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020b6:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020b8:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020bb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020bc:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020bf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020c0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020c1:	c3                   	ret    
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
