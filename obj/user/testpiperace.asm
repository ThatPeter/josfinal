
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
  80003b:	68 80 23 80 00       	push   $0x802380
  800040:	e8 40 03 00 00       	call   800385 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 e9 1c 00 00       	call   801d39 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 99 23 80 00       	push   $0x802399
  80005d:	6a 0d                	push   $0xd
  80005f:	68 a2 23 80 00       	push   $0x8023a2
  800064:	e8 43 02 00 00       	call   8002ac <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 86 0f 00 00       	call   800ff4 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 b6 23 80 00       	push   $0x8023b6
  80007a:	6a 10                	push   $0x10
  80007c:	68 a2 23 80 00       	push   $0x8023a2
  800081:	e8 26 02 00 00       	call   8002ac <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 28 14 00 00       	call   8014bd <close>
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
  8000a3:	e8 e4 1d 00 00       	call   801e8c <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 bf 23 80 00       	push   $0x8023bf
  8000b7:	e8 c9 02 00 00       	call   800385 <cprintf>
				exit();
  8000bc:	e8 d1 01 00 00       	call   800292 <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 25 0c 00 00       	call   800cee <sys_yield>
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
  8000d7:	e8 2a 11 00 00       	call   801206 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 da 23 80 00       	push   $0x8023da
  8000e8:	e8 98 02 00 00       	call   800385 <cprintf>
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
  8000fb:	8d 04 b0             	lea    (%eax,%esi,4),%eax
  8000fe:	c1 f8 02             	sar    $0x2,%eax
  800101:	69 c0 e1 83 0f 3e    	imul   $0x3e0f83e1,%eax,%eax
  800107:	50                   	push   %eax
  800108:	68 e5 23 80 00       	push   $0x8023e5
  80010d:	e8 73 02 00 00       	call   800385 <cprintf>
	dup(p[0], 10);
  800112:	83 c4 08             	add    $0x8,%esp
  800115:	6a 0a                	push   $0xa
  800117:	ff 75 f0             	pushl  -0x10(%ebp)
  80011a:	e8 ee 13 00 00       	call   80150d <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	89 f0                	mov    %esi,%eax
  800124:	c1 e0 07             	shl    $0x7,%eax
  800127:	8d 9c b0 00 00 c0 ee 	lea    -0x11400000(%eax,%esi,4),%ebx
  80012e:	eb 10                	jmp    800140 <umain+0x10d>
		dup(p[0], 10);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	6a 0a                	push   $0xa
  800135:	ff 75 f0             	pushl  -0x10(%ebp)
  800138:	e8 d0 13 00 00       	call   80150d <dup>
  80013d:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800140:	8b 43 5c             	mov    0x5c(%ebx),%eax
  800143:	83 f8 02             	cmp    $0x2,%eax
  800146:	74 e8                	je     800130 <umain+0xfd>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	68 f0 23 80 00       	push   $0x8023f0
  800150:	e8 30 02 00 00       	call   800385 <cprintf>
	if (pipeisclosed(p[0]))
  800155:	83 c4 04             	add    $0x4,%esp
  800158:	ff 75 f0             	pushl  -0x10(%ebp)
  80015b:	e8 2c 1d 00 00       	call   801e8c <pipeisclosed>
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	85 c0                	test   %eax,%eax
  800165:	74 14                	je     80017b <umain+0x148>
		panic("somehow the other end of p[0] got closed!");
  800167:	83 ec 04             	sub    $0x4,%esp
  80016a:	68 4c 24 80 00       	push   $0x80244c
  80016f:	6a 3a                	push   $0x3a
  800171:	68 a2 23 80 00       	push   $0x8023a2
  800176:	e8 31 01 00 00       	call   8002ac <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	ff 75 f0             	pushl  -0x10(%ebp)
  800185:	e8 09 12 00 00       	call   801393 <fd_lookup>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 12                	jns    8001a3 <umain+0x170>
		panic("cannot look up p[0]: %e", r);
  800191:	50                   	push   %eax
  800192:	68 06 24 80 00       	push   $0x802406
  800197:	6a 3c                	push   $0x3c
  800199:	68 a2 23 80 00       	push   $0x8023a2
  80019e:	e8 09 01 00 00       	call   8002ac <_panic>
	va = fd2data(fd);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a9:	e8 7f 11 00 00       	call   80132d <fd2data>
	if (pageref(va) != 3+1)
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 72 19 00 00       	call   801b28 <pageref>
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	83 f8 04             	cmp    $0x4,%eax
  8001bc:	74 12                	je     8001d0 <umain+0x19d>
		cprintf("\nchild detected race\n");
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	68 1e 24 80 00       	push   $0x80241e
  8001c6:	e8 ba 01 00 00       	call   800385 <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	eb 15                	jmp    8001e5 <umain+0x1b2>
	else
		cprintf("\nrace didn't happen\n", max);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	68 c8 00 00 00       	push   $0xc8
  8001d8:	68 34 24 80 00       	push   $0x802434
  8001dd:	e8 a3 01 00 00       	call   800385 <cprintf>
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
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001f5:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001fc:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001ff:	e8 cb 0a 00 00       	call   800ccf <sys_getenvid>
  800204:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	50                   	push   %eax
  80020a:	68 78 24 80 00       	push   $0x802478
  80020f:	e8 71 01 00 00       	call   800385 <cprintf>
  800214:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80021a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800227:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80022c:	89 c1                	mov    %eax,%ecx
  80022e:	c1 e1 07             	shl    $0x7,%ecx
  800231:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800238:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80023b:	39 cb                	cmp    %ecx,%ebx
  80023d:	0f 44 fa             	cmove  %edx,%edi
  800240:	b9 01 00 00 00       	mov    $0x1,%ecx
  800245:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800248:	83 c0 01             	add    $0x1,%eax
  80024b:	81 c2 84 00 00 00    	add    $0x84,%edx
  800251:	3d 00 04 00 00       	cmp    $0x400,%eax
  800256:	75 d4                	jne    80022c <libmain+0x40>
  800258:	89 f0                	mov    %esi,%eax
  80025a:	84 c0                	test   %al,%al
  80025c:	74 06                	je     800264 <libmain+0x78>
  80025e:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800264:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800268:	7e 0a                	jle    800274 <libmain+0x88>
		binaryname = argv[0];
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026d:	8b 00                	mov    (%eax),%eax
  80026f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800274:	83 ec 08             	sub    $0x8,%esp
  800277:	ff 75 0c             	pushl  0xc(%ebp)
  80027a:	ff 75 08             	pushl  0x8(%ebp)
  80027d:	e8 b1 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800282:	e8 0b 00 00 00       	call   800292 <exit>
}
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800298:	e8 4b 12 00 00       	call   8014e8 <close_all>
	sys_env_destroy(0);
  80029d:	83 ec 0c             	sub    $0xc,%esp
  8002a0:	6a 00                	push   $0x0
  8002a2:	e8 e7 09 00 00       	call   800c8e <sys_env_destroy>
}
  8002a7:	83 c4 10             	add    $0x10,%esp
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002b1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002ba:	e8 10 0a 00 00       	call   800ccf <sys_getenvid>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	ff 75 08             	pushl  0x8(%ebp)
  8002c8:	56                   	push   %esi
  8002c9:	50                   	push   %eax
  8002ca:	68 a4 24 80 00       	push   $0x8024a4
  8002cf:	e8 b1 00 00 00       	call   800385 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	53                   	push   %ebx
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	e8 54 00 00 00       	call   800334 <vcprintf>
	cprintf("\n");
  8002e0:	c7 04 24 97 23 80 00 	movl   $0x802397,(%esp)
  8002e7:	e8 99 00 00 00       	call   800385 <cprintf>
  8002ec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ef:	cc                   	int3   
  8002f0:	eb fd                	jmp    8002ef <_panic+0x43>

008002f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 04             	sub    $0x4,%esp
  8002f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fc:	8b 13                	mov    (%ebx),%edx
  8002fe:	8d 42 01             	lea    0x1(%edx),%eax
  800301:	89 03                	mov    %eax,(%ebx)
  800303:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800306:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80030a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030f:	75 1a                	jne    80032b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	68 ff 00 00 00       	push   $0xff
  800319:	8d 43 08             	lea    0x8(%ebx),%eax
  80031c:	50                   	push   %eax
  80031d:	e8 2f 09 00 00       	call   800c51 <sys_cputs>
		b->idx = 0;
  800322:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800328:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80032b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80032f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80033d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800344:	00 00 00 
	b.cnt = 0;
  800347:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80034e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80035d:	50                   	push   %eax
  80035e:	68 f2 02 80 00       	push   $0x8002f2
  800363:	e8 54 01 00 00       	call   8004bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800368:	83 c4 08             	add    $0x8,%esp
  80036b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800371:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800377:	50                   	push   %eax
  800378:	e8 d4 08 00 00       	call   800c51 <sys_cputs>

	return b.cnt;
}
  80037d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80038e:	50                   	push   %eax
  80038f:	ff 75 08             	pushl  0x8(%ebp)
  800392:	e8 9d ff ff ff       	call   800334 <vcprintf>
	va_end(ap);

	return cnt;
}
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	57                   	push   %edi
  80039d:	56                   	push   %esi
  80039e:	53                   	push   %ebx
  80039f:	83 ec 1c             	sub    $0x1c,%esp
  8003a2:	89 c7                	mov    %eax,%edi
  8003a4:	89 d6                	mov    %edx,%esi
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003af:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003bd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003c0:	39 d3                	cmp    %edx,%ebx
  8003c2:	72 05                	jb     8003c9 <printnum+0x30>
  8003c4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003c7:	77 45                	ja     80040e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c9:	83 ec 0c             	sub    $0xc,%esp
  8003cc:	ff 75 18             	pushl  0x18(%ebp)
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003d5:	53                   	push   %ebx
  8003d6:	ff 75 10             	pushl  0x10(%ebp)
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003df:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e8:	e8 f3 1c 00 00       	call   8020e0 <__udivdi3>
  8003ed:	83 c4 18             	add    $0x18,%esp
  8003f0:	52                   	push   %edx
  8003f1:	50                   	push   %eax
  8003f2:	89 f2                	mov    %esi,%edx
  8003f4:	89 f8                	mov    %edi,%eax
  8003f6:	e8 9e ff ff ff       	call   800399 <printnum>
  8003fb:	83 c4 20             	add    $0x20,%esp
  8003fe:	eb 18                	jmp    800418 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	56                   	push   %esi
  800404:	ff 75 18             	pushl  0x18(%ebp)
  800407:	ff d7                	call   *%edi
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	eb 03                	jmp    800411 <printnum+0x78>
  80040e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800411:	83 eb 01             	sub    $0x1,%ebx
  800414:	85 db                	test   %ebx,%ebx
  800416:	7f e8                	jg     800400 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	56                   	push   %esi
  80041c:	83 ec 04             	sub    $0x4,%esp
  80041f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800422:	ff 75 e0             	pushl  -0x20(%ebp)
  800425:	ff 75 dc             	pushl  -0x24(%ebp)
  800428:	ff 75 d8             	pushl  -0x28(%ebp)
  80042b:	e8 e0 1d 00 00       	call   802210 <__umoddi3>
  800430:	83 c4 14             	add    $0x14,%esp
  800433:	0f be 80 c7 24 80 00 	movsbl 0x8024c7(%eax),%eax
  80043a:	50                   	push   %eax
  80043b:	ff d7                	call   *%edi
}
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800443:	5b                   	pop    %ebx
  800444:	5e                   	pop    %esi
  800445:	5f                   	pop    %edi
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80044b:	83 fa 01             	cmp    $0x1,%edx
  80044e:	7e 0e                	jle    80045e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800450:	8b 10                	mov    (%eax),%edx
  800452:	8d 4a 08             	lea    0x8(%edx),%ecx
  800455:	89 08                	mov    %ecx,(%eax)
  800457:	8b 02                	mov    (%edx),%eax
  800459:	8b 52 04             	mov    0x4(%edx),%edx
  80045c:	eb 22                	jmp    800480 <getuint+0x38>
	else if (lflag)
  80045e:	85 d2                	test   %edx,%edx
  800460:	74 10                	je     800472 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800462:	8b 10                	mov    (%eax),%edx
  800464:	8d 4a 04             	lea    0x4(%edx),%ecx
  800467:	89 08                	mov    %ecx,(%eax)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	ba 00 00 00 00       	mov    $0x0,%edx
  800470:	eb 0e                	jmp    800480 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 04             	lea    0x4(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800480:	5d                   	pop    %ebp
  800481:	c3                   	ret    

00800482 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800488:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80048c:	8b 10                	mov    (%eax),%edx
  80048e:	3b 50 04             	cmp    0x4(%eax),%edx
  800491:	73 0a                	jae    80049d <sprintputch+0x1b>
		*b->buf++ = ch;
  800493:	8d 4a 01             	lea    0x1(%edx),%ecx
  800496:	89 08                	mov    %ecx,(%eax)
  800498:	8b 45 08             	mov    0x8(%ebp),%eax
  80049b:	88 02                	mov    %al,(%edx)
}
  80049d:	5d                   	pop    %ebp
  80049e:	c3                   	ret    

0080049f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a8:	50                   	push   %eax
  8004a9:	ff 75 10             	pushl  0x10(%ebp)
  8004ac:	ff 75 0c             	pushl  0xc(%ebp)
  8004af:	ff 75 08             	pushl  0x8(%ebp)
  8004b2:	e8 05 00 00 00       	call   8004bc <vprintfmt>
	va_end(ap);
}
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	57                   	push   %edi
  8004c0:	56                   	push   %esi
  8004c1:	53                   	push   %ebx
  8004c2:	83 ec 2c             	sub    $0x2c,%esp
  8004c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004cb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ce:	eb 12                	jmp    8004e2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	0f 84 89 03 00 00    	je     800861 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	50                   	push   %eax
  8004dd:	ff d6                	call   *%esi
  8004df:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e2:	83 c7 01             	add    $0x1,%edi
  8004e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e9:	83 f8 25             	cmp    $0x25,%eax
  8004ec:	75 e2                	jne    8004d0 <vprintfmt+0x14>
  8004ee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004f2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800500:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800507:	ba 00 00 00 00       	mov    $0x0,%edx
  80050c:	eb 07                	jmp    800515 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800511:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8d 47 01             	lea    0x1(%edi),%eax
  800518:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051b:	0f b6 07             	movzbl (%edi),%eax
  80051e:	0f b6 c8             	movzbl %al,%ecx
  800521:	83 e8 23             	sub    $0x23,%eax
  800524:	3c 55                	cmp    $0x55,%al
  800526:	0f 87 1a 03 00 00    	ja     800846 <vprintfmt+0x38a>
  80052c:	0f b6 c0             	movzbl %al,%eax
  80052f:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  800536:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800539:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80053d:	eb d6                	jmp    800515 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	b8 00 00 00 00       	mov    $0x0,%eax
  800547:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80054a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80054d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800551:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800554:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800557:	83 fa 09             	cmp    $0x9,%edx
  80055a:	77 39                	ja     800595 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80055c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80055f:	eb e9                	jmp    80054a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 48 04             	lea    0x4(%eax),%ecx
  800567:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800572:	eb 27                	jmp    80059b <vprintfmt+0xdf>
  800574:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800577:	85 c0                	test   %eax,%eax
  800579:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057e:	0f 49 c8             	cmovns %eax,%ecx
  800581:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800587:	eb 8c                	jmp    800515 <vprintfmt+0x59>
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80058c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800593:	eb 80                	jmp    800515 <vprintfmt+0x59>
  800595:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800598:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80059b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059f:	0f 89 70 ff ff ff    	jns    800515 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005b2:	e9 5e ff ff ff       	jmp    800515 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005bd:	e9 53 ff ff ff       	jmp    800515 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	ff 30                	pushl  (%eax)
  8005d1:	ff d6                	call   *%esi
			break;
  8005d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005d9:	e9 04 ff ff ff       	jmp    8004e2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	99                   	cltd   
  8005ea:	31 d0                	xor    %edx,%eax
  8005ec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ee:	83 f8 0f             	cmp    $0xf,%eax
  8005f1:	7f 0b                	jg     8005fe <vprintfmt+0x142>
  8005f3:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	75 18                	jne    800616 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005fe:	50                   	push   %eax
  8005ff:	68 df 24 80 00       	push   $0x8024df
  800604:	53                   	push   %ebx
  800605:	56                   	push   %esi
  800606:	e8 94 fe ff ff       	call   80049f <printfmt>
  80060b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800611:	e9 cc fe ff ff       	jmp    8004e2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800616:	52                   	push   %edx
  800617:	68 29 29 80 00       	push   $0x802929
  80061c:	53                   	push   %ebx
  80061d:	56                   	push   %esi
  80061e:	e8 7c fe ff ff       	call   80049f <printfmt>
  800623:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800629:	e9 b4 fe ff ff       	jmp    8004e2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800639:	85 ff                	test   %edi,%edi
  80063b:	b8 d8 24 80 00       	mov    $0x8024d8,%eax
  800640:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800643:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800647:	0f 8e 94 00 00 00    	jle    8006e1 <vprintfmt+0x225>
  80064d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800651:	0f 84 98 00 00 00    	je     8006ef <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 d0             	pushl  -0x30(%ebp)
  80065d:	57                   	push   %edi
  80065e:	e8 86 02 00 00       	call   8008e9 <strnlen>
  800663:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800666:	29 c1                	sub    %eax,%ecx
  800668:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80066b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80066e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800672:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800675:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800678:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067a:	eb 0f                	jmp    80068b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	ff 75 e0             	pushl  -0x20(%ebp)
  800683:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	85 ff                	test   %edi,%edi
  80068d:	7f ed                	jg     80067c <vprintfmt+0x1c0>
  80068f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800692:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800695:	85 c9                	test   %ecx,%ecx
  800697:	b8 00 00 00 00       	mov    $0x0,%eax
  80069c:	0f 49 c1             	cmovns %ecx,%eax
  80069f:	29 c1                	sub    %eax,%ecx
  8006a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006aa:	89 cb                	mov    %ecx,%ebx
  8006ac:	eb 4d                	jmp    8006fb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b2:	74 1b                	je     8006cf <vprintfmt+0x213>
  8006b4:	0f be c0             	movsbl %al,%eax
  8006b7:	83 e8 20             	sub    $0x20,%eax
  8006ba:	83 f8 5e             	cmp    $0x5e,%eax
  8006bd:	76 10                	jbe    8006cf <vprintfmt+0x213>
					putch('?', putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	6a 3f                	push   $0x3f
  8006c7:	ff 55 08             	call   *0x8(%ebp)
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 0d                	jmp    8006dc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	52                   	push   %edx
  8006d6:	ff 55 08             	call   *0x8(%ebp)
  8006d9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006dc:	83 eb 01             	sub    $0x1,%ebx
  8006df:	eb 1a                	jmp    8006fb <vprintfmt+0x23f>
  8006e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ed:	eb 0c                	jmp    8006fb <vprintfmt+0x23f>
  8006ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006fb:	83 c7 01             	add    $0x1,%edi
  8006fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800702:	0f be d0             	movsbl %al,%edx
  800705:	85 d2                	test   %edx,%edx
  800707:	74 23                	je     80072c <vprintfmt+0x270>
  800709:	85 f6                	test   %esi,%esi
  80070b:	78 a1                	js     8006ae <vprintfmt+0x1f2>
  80070d:	83 ee 01             	sub    $0x1,%esi
  800710:	79 9c                	jns    8006ae <vprintfmt+0x1f2>
  800712:	89 df                	mov    %ebx,%edi
  800714:	8b 75 08             	mov    0x8(%ebp),%esi
  800717:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071a:	eb 18                	jmp    800734 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 20                	push   $0x20
  800722:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800724:	83 ef 01             	sub    $0x1,%edi
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb 08                	jmp    800734 <vprintfmt+0x278>
  80072c:	89 df                	mov    %ebx,%edi
  80072e:	8b 75 08             	mov    0x8(%ebp),%esi
  800731:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800734:	85 ff                	test   %edi,%edi
  800736:	7f e4                	jg     80071c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073b:	e9 a2 fd ff ff       	jmp    8004e2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800740:	83 fa 01             	cmp    $0x1,%edx
  800743:	7e 16                	jle    80075b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8d 50 08             	lea    0x8(%eax),%edx
  80074b:	89 55 14             	mov    %edx,0x14(%ebp)
  80074e:	8b 50 04             	mov    0x4(%eax),%edx
  800751:	8b 00                	mov    (%eax),%eax
  800753:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800756:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800759:	eb 32                	jmp    80078d <vprintfmt+0x2d1>
	else if (lflag)
  80075b:	85 d2                	test   %edx,%edx
  80075d:	74 18                	je     800777 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076d:	89 c1                	mov    %eax,%ecx
  80076f:	c1 f9 1f             	sar    $0x1f,%ecx
  800772:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800775:	eb 16                	jmp    80078d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 04             	lea    0x4(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)
  800780:	8b 00                	mov    (%eax),%eax
  800782:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800785:	89 c1                	mov    %eax,%ecx
  800787:	c1 f9 1f             	sar    $0x1f,%ecx
  80078a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80078d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800790:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800793:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800798:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079c:	79 74                	jns    800812 <vprintfmt+0x356>
				putch('-', putdat);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	53                   	push   %ebx
  8007a2:	6a 2d                	push   $0x2d
  8007a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ac:	f7 d8                	neg    %eax
  8007ae:	83 d2 00             	adc    $0x0,%edx
  8007b1:	f7 da                	neg    %edx
  8007b3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007bb:	eb 55                	jmp    800812 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c0:	e8 83 fc ff ff       	call   800448 <getuint>
			base = 10;
  8007c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ca:	eb 46                	jmp    800812 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cf:	e8 74 fc ff ff       	call   800448 <getuint>
			base = 8;
  8007d4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007d9:	eb 37                	jmp    800812 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	53                   	push   %ebx
  8007df:	6a 30                	push   $0x30
  8007e1:	ff d6                	call   *%esi
			putch('x', putdat);
  8007e3:	83 c4 08             	add    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	6a 78                	push   $0x78
  8007e9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 50 04             	lea    0x4(%eax),%edx
  8007f1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f4:	8b 00                	mov    (%eax),%eax
  8007f6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007fb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800803:	eb 0d                	jmp    800812 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	e8 3b fc ff ff       	call   800448 <getuint>
			base = 16;
  80080d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800812:	83 ec 0c             	sub    $0xc,%esp
  800815:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800819:	57                   	push   %edi
  80081a:	ff 75 e0             	pushl  -0x20(%ebp)
  80081d:	51                   	push   %ecx
  80081e:	52                   	push   %edx
  80081f:	50                   	push   %eax
  800820:	89 da                	mov    %ebx,%edx
  800822:	89 f0                	mov    %esi,%eax
  800824:	e8 70 fb ff ff       	call   800399 <printnum>
			break;
  800829:	83 c4 20             	add    $0x20,%esp
  80082c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80082f:	e9 ae fc ff ff       	jmp    8004e2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	53                   	push   %ebx
  800838:	51                   	push   %ecx
  800839:	ff d6                	call   *%esi
			break;
  80083b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800841:	e9 9c fc ff ff       	jmp    8004e2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	53                   	push   %ebx
  80084a:	6a 25                	push   $0x25
  80084c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	eb 03                	jmp    800856 <vprintfmt+0x39a>
  800853:	83 ef 01             	sub    $0x1,%edi
  800856:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80085a:	75 f7                	jne    800853 <vprintfmt+0x397>
  80085c:	e9 81 fc ff ff       	jmp    8004e2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800861:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5f                   	pop    %edi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	83 ec 18             	sub    $0x18,%esp
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800875:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800878:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80087c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80087f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800886:	85 c0                	test   %eax,%eax
  800888:	74 26                	je     8008b0 <vsnprintf+0x47>
  80088a:	85 d2                	test   %edx,%edx
  80088c:	7e 22                	jle    8008b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088e:	ff 75 14             	pushl  0x14(%ebp)
  800891:	ff 75 10             	pushl  0x10(%ebp)
  800894:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800897:	50                   	push   %eax
  800898:	68 82 04 80 00       	push   $0x800482
  80089d:	e8 1a fc ff ff       	call   8004bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	eb 05                	jmp    8008b5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c0:	50                   	push   %eax
  8008c1:	ff 75 10             	pushl  0x10(%ebp)
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 9a ff ff ff       	call   800869 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dc:	eb 03                	jmp    8008e1 <strlen+0x10>
		n++;
  8008de:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e5:	75 f7                	jne    8008de <strlen+0xd>
		n++;
	return n;
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f7:	eb 03                	jmp    8008fc <strnlen+0x13>
		n++;
  8008f9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fc:	39 c2                	cmp    %eax,%edx
  8008fe:	74 08                	je     800908 <strnlen+0x1f>
  800900:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800904:	75 f3                	jne    8008f9 <strnlen+0x10>
  800906:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800914:	89 c2                	mov    %eax,%edx
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800920:	88 5a ff             	mov    %bl,-0x1(%edx)
  800923:	84 db                	test   %bl,%bl
  800925:	75 ef                	jne    800916 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800931:	53                   	push   %ebx
  800932:	e8 9a ff ff ff       	call   8008d1 <strlen>
  800937:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80093a:	ff 75 0c             	pushl  0xc(%ebp)
  80093d:	01 d8                	add    %ebx,%eax
  80093f:	50                   	push   %eax
  800940:	e8 c5 ff ff ff       	call   80090a <strcpy>
	return dst;
}
  800945:	89 d8                	mov    %ebx,%eax
  800947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 75 08             	mov    0x8(%ebp),%esi
  800954:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800957:	89 f3                	mov    %esi,%ebx
  800959:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095c:	89 f2                	mov    %esi,%edx
  80095e:	eb 0f                	jmp    80096f <strncpy+0x23>
		*dst++ = *src;
  800960:	83 c2 01             	add    $0x1,%edx
  800963:	0f b6 01             	movzbl (%ecx),%eax
  800966:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800969:	80 39 01             	cmpb   $0x1,(%ecx)
  80096c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096f:	39 da                	cmp    %ebx,%edx
  800971:	75 ed                	jne    800960 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800973:	89 f0                	mov    %esi,%eax
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 75 08             	mov    0x8(%ebp),%esi
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800984:	8b 55 10             	mov    0x10(%ebp),%edx
  800987:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800989:	85 d2                	test   %edx,%edx
  80098b:	74 21                	je     8009ae <strlcpy+0x35>
  80098d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800991:	89 f2                	mov    %esi,%edx
  800993:	eb 09                	jmp    80099e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800995:	83 c2 01             	add    $0x1,%edx
  800998:	83 c1 01             	add    $0x1,%ecx
  80099b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80099e:	39 c2                	cmp    %eax,%edx
  8009a0:	74 09                	je     8009ab <strlcpy+0x32>
  8009a2:	0f b6 19             	movzbl (%ecx),%ebx
  8009a5:	84 db                	test   %bl,%bl
  8009a7:	75 ec                	jne    800995 <strlcpy+0x1c>
  8009a9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ae:	29 f0                	sub    %esi,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009bd:	eb 06                	jmp    8009c5 <strcmp+0x11>
		p++, q++;
  8009bf:	83 c1 01             	add    $0x1,%ecx
  8009c2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c5:	0f b6 01             	movzbl (%ecx),%eax
  8009c8:	84 c0                	test   %al,%al
  8009ca:	74 04                	je     8009d0 <strcmp+0x1c>
  8009cc:	3a 02                	cmp    (%edx),%al
  8009ce:	74 ef                	je     8009bf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d0:	0f b6 c0             	movzbl %al,%eax
  8009d3:	0f b6 12             	movzbl (%edx),%edx
  8009d6:	29 d0                	sub    %edx,%eax
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e4:	89 c3                	mov    %eax,%ebx
  8009e6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e9:	eb 06                	jmp    8009f1 <strncmp+0x17>
		n--, p++, q++;
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f1:	39 d8                	cmp    %ebx,%eax
  8009f3:	74 15                	je     800a0a <strncmp+0x30>
  8009f5:	0f b6 08             	movzbl (%eax),%ecx
  8009f8:	84 c9                	test   %cl,%cl
  8009fa:	74 04                	je     800a00 <strncmp+0x26>
  8009fc:	3a 0a                	cmp    (%edx),%cl
  8009fe:	74 eb                	je     8009eb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a00:	0f b6 00             	movzbl (%eax),%eax
  800a03:	0f b6 12             	movzbl (%edx),%edx
  800a06:	29 d0                	sub    %edx,%eax
  800a08:	eb 05                	jmp    800a0f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a0f:	5b                   	pop    %ebx
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1c:	eb 07                	jmp    800a25 <strchr+0x13>
		if (*s == c)
  800a1e:	38 ca                	cmp    %cl,%dl
  800a20:	74 0f                	je     800a31 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	75 f2                	jne    800a1e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3d:	eb 03                	jmp    800a42 <strfind+0xf>
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a45:	38 ca                	cmp    %cl,%dl
  800a47:	74 04                	je     800a4d <strfind+0x1a>
  800a49:	84 d2                	test   %dl,%dl
  800a4b:	75 f2                	jne    800a3f <strfind+0xc>
			break;
	return (char *) s;
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a5b:	85 c9                	test   %ecx,%ecx
  800a5d:	74 36                	je     800a95 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a65:	75 28                	jne    800a8f <memset+0x40>
  800a67:	f6 c1 03             	test   $0x3,%cl
  800a6a:	75 23                	jne    800a8f <memset+0x40>
		c &= 0xFF;
  800a6c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a70:	89 d3                	mov    %edx,%ebx
  800a72:	c1 e3 08             	shl    $0x8,%ebx
  800a75:	89 d6                	mov    %edx,%esi
  800a77:	c1 e6 18             	shl    $0x18,%esi
  800a7a:	89 d0                	mov    %edx,%eax
  800a7c:	c1 e0 10             	shl    $0x10,%eax
  800a7f:	09 f0                	or     %esi,%eax
  800a81:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a83:	89 d8                	mov    %ebx,%eax
  800a85:	09 d0                	or     %edx,%eax
  800a87:	c1 e9 02             	shr    $0x2,%ecx
  800a8a:	fc                   	cld    
  800a8b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8d:	eb 06                	jmp    800a95 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a92:	fc                   	cld    
  800a93:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a95:	89 f8                	mov    %edi,%eax
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aaa:	39 c6                	cmp    %eax,%esi
  800aac:	73 35                	jae    800ae3 <memmove+0x47>
  800aae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab1:	39 d0                	cmp    %edx,%eax
  800ab3:	73 2e                	jae    800ae3 <memmove+0x47>
		s += n;
		d += n;
  800ab5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab8:	89 d6                	mov    %edx,%esi
  800aba:	09 fe                	or     %edi,%esi
  800abc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac2:	75 13                	jne    800ad7 <memmove+0x3b>
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 0e                	jne    800ad7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ac9:	83 ef 04             	sub    $0x4,%edi
  800acc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800acf:	c1 e9 02             	shr    $0x2,%ecx
  800ad2:	fd                   	std    
  800ad3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad5:	eb 09                	jmp    800ae0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ad7:	83 ef 01             	sub    $0x1,%edi
  800ada:	8d 72 ff             	lea    -0x1(%edx),%esi
  800add:	fd                   	std    
  800ade:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae0:	fc                   	cld    
  800ae1:	eb 1d                	jmp    800b00 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae3:	89 f2                	mov    %esi,%edx
  800ae5:	09 c2                	or     %eax,%edx
  800ae7:	f6 c2 03             	test   $0x3,%dl
  800aea:	75 0f                	jne    800afb <memmove+0x5f>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 0a                	jne    800afb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800af1:	c1 e9 02             	shr    $0x2,%ecx
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	fc                   	cld    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb 05                	jmp    800b00 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	fc                   	cld    
  800afe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b07:	ff 75 10             	pushl  0x10(%ebp)
  800b0a:	ff 75 0c             	pushl  0xc(%ebp)
  800b0d:	ff 75 08             	pushl  0x8(%ebp)
  800b10:	e8 87 ff ff ff       	call   800a9c <memmove>
}
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b22:	89 c6                	mov    %eax,%esi
  800b24:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b27:	eb 1a                	jmp    800b43 <memcmp+0x2c>
		if (*s1 != *s2)
  800b29:	0f b6 08             	movzbl (%eax),%ecx
  800b2c:	0f b6 1a             	movzbl (%edx),%ebx
  800b2f:	38 d9                	cmp    %bl,%cl
  800b31:	74 0a                	je     800b3d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b33:	0f b6 c1             	movzbl %cl,%eax
  800b36:	0f b6 db             	movzbl %bl,%ebx
  800b39:	29 d8                	sub    %ebx,%eax
  800b3b:	eb 0f                	jmp    800b4c <memcmp+0x35>
		s1++, s2++;
  800b3d:	83 c0 01             	add    $0x1,%eax
  800b40:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b43:	39 f0                	cmp    %esi,%eax
  800b45:	75 e2                	jne    800b29 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	53                   	push   %ebx
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b57:	89 c1                	mov    %eax,%ecx
  800b59:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b60:	eb 0a                	jmp    800b6c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b62:	0f b6 10             	movzbl (%eax),%edx
  800b65:	39 da                	cmp    %ebx,%edx
  800b67:	74 07                	je     800b70 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b69:	83 c0 01             	add    $0x1,%eax
  800b6c:	39 c8                	cmp    %ecx,%eax
  800b6e:	72 f2                	jb     800b62 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7f:	eb 03                	jmp    800b84 <strtol+0x11>
		s++;
  800b81:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b84:	0f b6 01             	movzbl (%ecx),%eax
  800b87:	3c 20                	cmp    $0x20,%al
  800b89:	74 f6                	je     800b81 <strtol+0xe>
  800b8b:	3c 09                	cmp    $0x9,%al
  800b8d:	74 f2                	je     800b81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b8f:	3c 2b                	cmp    $0x2b,%al
  800b91:	75 0a                	jne    800b9d <strtol+0x2a>
		s++;
  800b93:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b96:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9b:	eb 11                	jmp    800bae <strtol+0x3b>
  800b9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ba2:	3c 2d                	cmp    $0x2d,%al
  800ba4:	75 08                	jne    800bae <strtol+0x3b>
		s++, neg = 1;
  800ba6:	83 c1 01             	add    $0x1,%ecx
  800ba9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb4:	75 15                	jne    800bcb <strtol+0x58>
  800bb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb9:	75 10                	jne    800bcb <strtol+0x58>
  800bbb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bbf:	75 7c                	jne    800c3d <strtol+0xca>
		s += 2, base = 16;
  800bc1:	83 c1 02             	add    $0x2,%ecx
  800bc4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc9:	eb 16                	jmp    800be1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bcb:	85 db                	test   %ebx,%ebx
  800bcd:	75 12                	jne    800be1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bcf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd7:	75 08                	jne    800be1 <strtol+0x6e>
		s++, base = 8;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be9:	0f b6 11             	movzbl (%ecx),%edx
  800bec:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bef:	89 f3                	mov    %esi,%ebx
  800bf1:	80 fb 09             	cmp    $0x9,%bl
  800bf4:	77 08                	ja     800bfe <strtol+0x8b>
			dig = *s - '0';
  800bf6:	0f be d2             	movsbl %dl,%edx
  800bf9:	83 ea 30             	sub    $0x30,%edx
  800bfc:	eb 22                	jmp    800c20 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bfe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c01:	89 f3                	mov    %esi,%ebx
  800c03:	80 fb 19             	cmp    $0x19,%bl
  800c06:	77 08                	ja     800c10 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c08:	0f be d2             	movsbl %dl,%edx
  800c0b:	83 ea 57             	sub    $0x57,%edx
  800c0e:	eb 10                	jmp    800c20 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c10:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c13:	89 f3                	mov    %esi,%ebx
  800c15:	80 fb 19             	cmp    $0x19,%bl
  800c18:	77 16                	ja     800c30 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c1a:	0f be d2             	movsbl %dl,%edx
  800c1d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c20:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c23:	7d 0b                	jge    800c30 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c25:	83 c1 01             	add    $0x1,%ecx
  800c28:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c2c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c2e:	eb b9                	jmp    800be9 <strtol+0x76>

	if (endptr)
  800c30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c34:	74 0d                	je     800c43 <strtol+0xd0>
		*endptr = (char *) s;
  800c36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c39:	89 0e                	mov    %ecx,(%esi)
  800c3b:	eb 06                	jmp    800c43 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3d:	85 db                	test   %ebx,%ebx
  800c3f:	74 98                	je     800bd9 <strtol+0x66>
  800c41:	eb 9e                	jmp    800be1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c43:	89 c2                	mov    %eax,%edx
  800c45:	f7 da                	neg    %edx
  800c47:	85 ff                	test   %edi,%edi
  800c49:	0f 45 c2             	cmovne %edx,%eax
}
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	89 c3                	mov    %eax,%ebx
  800c64:	89 c7                	mov    %eax,%edi
  800c66:	89 c6                	mov    %eax,%esi
  800c68:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 cb                	mov    %ecx,%ebx
  800ca6:	89 cf                	mov    %ecx,%edi
  800ca8:	89 ce                	mov    %ecx,%esi
  800caa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 17                	jle    800cc7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 03                	push   $0x3
  800cb6:	68 bf 27 80 00       	push   $0x8027bf
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 dc 27 80 00       	push   $0x8027dc
  800cc2:	e8 e5 f5 ff ff       	call   8002ac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cda:	b8 02 00 00 00       	mov    $0x2,%eax
  800cdf:	89 d1                	mov    %edx,%ecx
  800ce1:	89 d3                	mov    %edx,%ebx
  800ce3:	89 d7                	mov    %edx,%edi
  800ce5:	89 d6                	mov    %edx,%esi
  800ce7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_yield>:

void
sys_yield(void)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfe:	89 d1                	mov    %edx,%ecx
  800d00:	89 d3                	mov    %edx,%ebx
  800d02:	89 d7                	mov    %edx,%edi
  800d04:	89 d6                	mov    %edx,%esi
  800d06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	be 00 00 00 00       	mov    $0x0,%esi
  800d1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d29:	89 f7                	mov    %esi,%edi
  800d2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 04                	push   $0x4
  800d37:	68 bf 27 80 00       	push   $0x8027bf
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 dc 27 80 00       	push   $0x8027dc
  800d43:	e8 64 f5 ff ff       	call   8002ac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 17                	jle    800d8a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	50                   	push   %eax
  800d77:	6a 05                	push   $0x5
  800d79:	68 bf 27 80 00       	push   $0x8027bf
  800d7e:	6a 23                	push   $0x23
  800d80:	68 dc 27 80 00       	push   $0x8027dc
  800d85:	e8 22 f5 ff ff       	call   8002ac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da0:	b8 06 00 00 00       	mov    $0x6,%eax
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 df                	mov    %ebx,%edi
  800dad:	89 de                	mov    %ebx,%esi
  800daf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 17                	jle    800dcc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	50                   	push   %eax
  800db9:	6a 06                	push   $0x6
  800dbb:	68 bf 27 80 00       	push   $0x8027bf
  800dc0:	6a 23                	push   $0x23
  800dc2:	68 dc 27 80 00       	push   $0x8027dc
  800dc7:	e8 e0 f4 ff ff       	call   8002ac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de2:	b8 08 00 00 00       	mov    $0x8,%eax
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	89 df                	mov    %ebx,%edi
  800def:	89 de                	mov    %ebx,%esi
  800df1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 17                	jle    800e0e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	50                   	push   %eax
  800dfb:	6a 08                	push   $0x8
  800dfd:	68 bf 27 80 00       	push   $0x8027bf
  800e02:	6a 23                	push   $0x23
  800e04:	68 dc 27 80 00       	push   $0x8027dc
  800e09:	e8 9e f4 ff ff       	call   8002ac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e24:	b8 09 00 00 00       	mov    $0x9,%eax
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	89 df                	mov    %ebx,%edi
  800e31:	89 de                	mov    %ebx,%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 17                	jle    800e50 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	50                   	push   %eax
  800e3d:	6a 09                	push   $0x9
  800e3f:	68 bf 27 80 00       	push   $0x8027bf
  800e44:	6a 23                	push   $0x23
  800e46:	68 dc 27 80 00       	push   $0x8027dc
  800e4b:	e8 5c f4 ff ff       	call   8002ac <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	57                   	push   %edi
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e66:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e71:	89 df                	mov    %ebx,%edi
  800e73:	89 de                	mov    %ebx,%esi
  800e75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 17                	jle    800e92 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	50                   	push   %eax
  800e7f:	6a 0a                	push   $0xa
  800e81:	68 bf 27 80 00       	push   $0x8027bf
  800e86:	6a 23                	push   $0x23
  800e88:	68 dc 27 80 00       	push   $0x8027dc
  800e8d:	e8 1a f4 ff ff       	call   8002ac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea0:	be 00 00 00 00       	mov    $0x0,%esi
  800ea5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed3:	89 cb                	mov    %ecx,%ebx
  800ed5:	89 cf                	mov    %ecx,%edi
  800ed7:	89 ce                	mov    %ecx,%esi
  800ed9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800edb:	85 c0                	test   %eax,%eax
  800edd:	7e 17                	jle    800ef6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	50                   	push   %eax
  800ee3:	6a 0d                	push   $0xd
  800ee5:	68 bf 27 80 00       	push   $0x8027bf
  800eea:	6a 23                	push   $0x23
  800eec:	68 dc 27 80 00       	push   $0x8027dc
  800ef1:	e8 b6 f3 ff ff       	call   8002ac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f09:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f11:	89 cb                	mov    %ecx,%ebx
  800f13:	89 cf                	mov    %ecx,%edi
  800f15:	89 ce                	mov    %ecx,%esi
  800f17:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	53                   	push   %ebx
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f28:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f2a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f2e:	74 11                	je     800f41 <pgfault+0x23>
  800f30:	89 d8                	mov    %ebx,%eax
  800f32:	c1 e8 0c             	shr    $0xc,%eax
  800f35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3c:	f6 c4 08             	test   $0x8,%ah
  800f3f:	75 14                	jne    800f55 <pgfault+0x37>
		panic("faulting access");
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	68 ea 27 80 00       	push   $0x8027ea
  800f49:	6a 1d                	push   $0x1d
  800f4b:	68 fa 27 80 00       	push   $0x8027fa
  800f50:	e8 57 f3 ff ff       	call   8002ac <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	6a 07                	push   $0x7
  800f5a:	68 00 f0 7f 00       	push   $0x7ff000
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 a7 fd ff ff       	call   800d0d <sys_page_alloc>
	if (r < 0) {
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	79 12                	jns    800f7f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f6d:	50                   	push   %eax
  800f6e:	68 05 28 80 00       	push   $0x802805
  800f73:	6a 2b                	push   $0x2b
  800f75:	68 fa 27 80 00       	push   $0x8027fa
  800f7a:	e8 2d f3 ff ff       	call   8002ac <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f7f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	68 00 10 00 00       	push   $0x1000
  800f8d:	53                   	push   %ebx
  800f8e:	68 00 f0 7f 00       	push   $0x7ff000
  800f93:	e8 6c fb ff ff       	call   800b04 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f98:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f9f:	53                   	push   %ebx
  800fa0:	6a 00                	push   $0x0
  800fa2:	68 00 f0 7f 00       	push   $0x7ff000
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 a2 fd ff ff       	call   800d50 <sys_page_map>
	if (r < 0) {
  800fae:	83 c4 20             	add    $0x20,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	79 12                	jns    800fc7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800fb5:	50                   	push   %eax
  800fb6:	68 05 28 80 00       	push   $0x802805
  800fbb:	6a 32                	push   $0x32
  800fbd:	68 fa 27 80 00       	push   $0x8027fa
  800fc2:	e8 e5 f2 ff ff       	call   8002ac <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800fc7:	83 ec 08             	sub    $0x8,%esp
  800fca:	68 00 f0 7f 00       	push   $0x7ff000
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 bc fd ff ff       	call   800d92 <sys_page_unmap>
	if (r < 0) {
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	79 12                	jns    800fef <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fdd:	50                   	push   %eax
  800fde:	68 05 28 80 00       	push   $0x802805
  800fe3:	6a 36                	push   $0x36
  800fe5:	68 fa 27 80 00       	push   $0x8027fa
  800fea:	e8 bd f2 ff ff       	call   8002ac <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ffd:	68 1e 0f 80 00       	push   $0x800f1e
  801002:	e8 3b 10 00 00       	call   802042 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801007:	b8 07 00 00 00       	mov    $0x7,%eax
  80100c:	cd 30                	int    $0x30
  80100e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	79 17                	jns    80102f <fork+0x3b>
		panic("fork fault %e");
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	68 1e 28 80 00       	push   $0x80281e
  801020:	68 83 00 00 00       	push   $0x83
  801025:	68 fa 27 80 00       	push   $0x8027fa
  80102a:	e8 7d f2 ff ff       	call   8002ac <_panic>
  80102f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801031:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801035:	75 25                	jne    80105c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801037:	e8 93 fc ff ff       	call   800ccf <sys_getenvid>
  80103c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801041:	89 c2                	mov    %eax,%edx
  801043:	c1 e2 07             	shl    $0x7,%edx
  801046:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80104d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801052:	b8 00 00 00 00       	mov    $0x0,%eax
  801057:	e9 61 01 00 00       	jmp    8011bd <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	6a 07                	push   $0x7
  801061:	68 00 f0 bf ee       	push   $0xeebff000
  801066:	ff 75 e4             	pushl  -0x1c(%ebp)
  801069:	e8 9f fc ff ff       	call   800d0d <sys_page_alloc>
  80106e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801071:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801076:	89 d8                	mov    %ebx,%eax
  801078:	c1 e8 16             	shr    $0x16,%eax
  80107b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801082:	a8 01                	test   $0x1,%al
  801084:	0f 84 fc 00 00 00    	je     801186 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80108a:	89 d8                	mov    %ebx,%eax
  80108c:	c1 e8 0c             	shr    $0xc,%eax
  80108f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801096:	f6 c2 01             	test   $0x1,%dl
  801099:	0f 84 e7 00 00 00    	je     801186 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80109f:	89 c6                	mov    %eax,%esi
  8010a1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8010a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ab:	f6 c6 04             	test   $0x4,%dh
  8010ae:	74 39                	je     8010e9 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8010bf:	50                   	push   %eax
  8010c0:	56                   	push   %esi
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	6a 00                	push   $0x0
  8010c5:	e8 86 fc ff ff       	call   800d50 <sys_page_map>
		if (r < 0) {
  8010ca:	83 c4 20             	add    $0x20,%esp
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	0f 89 b1 00 00 00    	jns    801186 <fork+0x192>
		    	panic("sys page map fault %e");
  8010d5:	83 ec 04             	sub    $0x4,%esp
  8010d8:	68 2c 28 80 00       	push   $0x80282c
  8010dd:	6a 53                	push   $0x53
  8010df:	68 fa 27 80 00       	push   $0x8027fa
  8010e4:	e8 c3 f1 ff ff       	call   8002ac <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f0:	f6 c2 02             	test   $0x2,%dl
  8010f3:	75 0c                	jne    801101 <fork+0x10d>
  8010f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fc:	f6 c4 08             	test   $0x8,%ah
  8010ff:	74 5b                	je     80115c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	68 05 08 00 00       	push   $0x805
  801109:	56                   	push   %esi
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	6a 00                	push   $0x0
  80110e:	e8 3d fc ff ff       	call   800d50 <sys_page_map>
		if (r < 0) {
  801113:	83 c4 20             	add    $0x20,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	79 14                	jns    80112e <fork+0x13a>
		    	panic("sys page map fault %e");
  80111a:	83 ec 04             	sub    $0x4,%esp
  80111d:	68 2c 28 80 00       	push   $0x80282c
  801122:	6a 5a                	push   $0x5a
  801124:	68 fa 27 80 00       	push   $0x8027fa
  801129:	e8 7e f1 ff ff       	call   8002ac <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80112e:	83 ec 0c             	sub    $0xc,%esp
  801131:	68 05 08 00 00       	push   $0x805
  801136:	56                   	push   %esi
  801137:	6a 00                	push   $0x0
  801139:	56                   	push   %esi
  80113a:	6a 00                	push   $0x0
  80113c:	e8 0f fc ff ff       	call   800d50 <sys_page_map>
		if (r < 0) {
  801141:	83 c4 20             	add    $0x20,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	79 3e                	jns    801186 <fork+0x192>
		    	panic("sys page map fault %e");
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	68 2c 28 80 00       	push   $0x80282c
  801150:	6a 5e                	push   $0x5e
  801152:	68 fa 27 80 00       	push   $0x8027fa
  801157:	e8 50 f1 ff ff       	call   8002ac <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	6a 05                	push   $0x5
  801161:	56                   	push   %esi
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	6a 00                	push   $0x0
  801166:	e8 e5 fb ff ff       	call   800d50 <sys_page_map>
		if (r < 0) {
  80116b:	83 c4 20             	add    $0x20,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	79 14                	jns    801186 <fork+0x192>
		    	panic("sys page map fault %e");
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	68 2c 28 80 00       	push   $0x80282c
  80117a:	6a 63                	push   $0x63
  80117c:	68 fa 27 80 00       	push   $0x8027fa
  801181:	e8 26 f1 ff ff       	call   8002ac <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801186:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80118c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801192:	0f 85 de fe ff ff    	jne    801076 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801198:	a1 04 40 80 00       	mov    0x804004,%eax
  80119d:	8b 40 6c             	mov    0x6c(%eax),%eax
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	50                   	push   %eax
  8011a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011a7:	57                   	push   %edi
  8011a8:	e8 ab fc ff ff       	call   800e58 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	6a 02                	push   $0x2
  8011b2:	57                   	push   %edi
  8011b3:	e8 1c fc ff ff       	call   800dd4 <sys_env_set_status>
	
	return envid;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5e                   	pop    %esi
  8011c2:	5f                   	pop    %edi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <sfork>:

envid_t
sfork(void)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	53                   	push   %ebx
  8011db:	68 44 28 80 00       	push   $0x802844
  8011e0:	e8 a0 f1 ff ff       	call   800385 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  8011e5:	89 1c 24             	mov    %ebx,(%esp)
  8011e8:	e8 11 fd ff ff       	call   800efe <sys_thread_create>
  8011ed:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011ef:	83 c4 08             	add    $0x8,%esp
  8011f2:	53                   	push   %ebx
  8011f3:	68 44 28 80 00       	push   $0x802844
  8011f8:	e8 88 f1 ff ff       	call   800385 <cprintf>
	return id;
}
  8011fd:	89 f0                	mov    %esi,%eax
  8011ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	56                   	push   %esi
  80120a:	53                   	push   %ebx
  80120b:	8b 75 08             	mov    0x8(%ebp),%esi
  80120e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801211:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801214:	85 c0                	test   %eax,%eax
  801216:	75 12                	jne    80122a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	68 00 00 c0 ee       	push   $0xeec00000
  801220:	e8 98 fc ff ff       	call   800ebd <sys_ipc_recv>
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	eb 0c                	jmp    801236 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	50                   	push   %eax
  80122e:	e8 8a fc ff ff       	call   800ebd <sys_ipc_recv>
  801233:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801236:	85 f6                	test   %esi,%esi
  801238:	0f 95 c1             	setne  %cl
  80123b:	85 db                	test   %ebx,%ebx
  80123d:	0f 95 c2             	setne  %dl
  801240:	84 d1                	test   %dl,%cl
  801242:	74 09                	je     80124d <ipc_recv+0x47>
  801244:	89 c2                	mov    %eax,%edx
  801246:	c1 ea 1f             	shr    $0x1f,%edx
  801249:	84 d2                	test   %dl,%dl
  80124b:	75 27                	jne    801274 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80124d:	85 f6                	test   %esi,%esi
  80124f:	74 0a                	je     80125b <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801251:	a1 04 40 80 00       	mov    0x804004,%eax
  801256:	8b 40 7c             	mov    0x7c(%eax),%eax
  801259:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80125b:	85 db                	test   %ebx,%ebx
  80125d:	74 0d                	je     80126c <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  80125f:	a1 04 40 80 00       	mov    0x804004,%eax
  801264:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80126a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80126c:	a1 04 40 80 00       	mov    0x804004,%eax
  801271:	8b 40 78             	mov    0x78(%eax),%eax
}
  801274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	57                   	push   %edi
  80127f:	56                   	push   %esi
  801280:	53                   	push   %ebx
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	8b 7d 08             	mov    0x8(%ebp),%edi
  801287:	8b 75 0c             	mov    0xc(%ebp),%esi
  80128a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80128d:	85 db                	test   %ebx,%ebx
  80128f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801294:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801297:	ff 75 14             	pushl  0x14(%ebp)
  80129a:	53                   	push   %ebx
  80129b:	56                   	push   %esi
  80129c:	57                   	push   %edi
  80129d:	e8 f8 fb ff ff       	call   800e9a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	c1 ea 1f             	shr    $0x1f,%edx
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	84 d2                	test   %dl,%dl
  8012ac:	74 17                	je     8012c5 <ipc_send+0x4a>
  8012ae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012b1:	74 12                	je     8012c5 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8012b3:	50                   	push   %eax
  8012b4:	68 67 28 80 00       	push   $0x802867
  8012b9:	6a 47                	push   $0x47
  8012bb:	68 75 28 80 00       	push   $0x802875
  8012c0:	e8 e7 ef ff ff       	call   8002ac <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8012c5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012c8:	75 07                	jne    8012d1 <ipc_send+0x56>
			sys_yield();
  8012ca:	e8 1f fa ff ff       	call   800cee <sys_yield>
  8012cf:	eb c6                	jmp    801297 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	75 c2                	jne    801297 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8012d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5f                   	pop    %edi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012e3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	c1 e2 07             	shl    $0x7,%edx
  8012ed:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8012f4:	8b 52 58             	mov    0x58(%edx),%edx
  8012f7:	39 ca                	cmp    %ecx,%edx
  8012f9:	75 11                	jne    80130c <ipc_find_env+0x2f>
			return envs[i].env_id;
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	c1 e2 07             	shl    $0x7,%edx
  801300:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801307:	8b 40 50             	mov    0x50(%eax),%eax
  80130a:	eb 0f                	jmp    80131b <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80130c:	83 c0 01             	add    $0x1,%eax
  80130f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801314:	75 d2                	jne    8012e8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801316:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	05 00 00 00 30       	add    $0x30000000,%eax
  801328:	c1 e8 0c             	shr    $0xc,%eax
}
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	05 00 00 00 30       	add    $0x30000000,%eax
  801338:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80133d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134f:	89 c2                	mov    %eax,%edx
  801351:	c1 ea 16             	shr    $0x16,%edx
  801354:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135b:	f6 c2 01             	test   $0x1,%dl
  80135e:	74 11                	je     801371 <fd_alloc+0x2d>
  801360:	89 c2                	mov    %eax,%edx
  801362:	c1 ea 0c             	shr    $0xc,%edx
  801365:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136c:	f6 c2 01             	test   $0x1,%dl
  80136f:	75 09                	jne    80137a <fd_alloc+0x36>
			*fd_store = fd;
  801371:	89 01                	mov    %eax,(%ecx)
			return 0;
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
  801378:	eb 17                	jmp    801391 <fd_alloc+0x4d>
  80137a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80137f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801384:	75 c9                	jne    80134f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801386:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80138c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    

00801393 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801399:	83 f8 1f             	cmp    $0x1f,%eax
  80139c:	77 36                	ja     8013d4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139e:	c1 e0 0c             	shl    $0xc,%eax
  8013a1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	c1 ea 16             	shr    $0x16,%edx
  8013ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b2:	f6 c2 01             	test   $0x1,%dl
  8013b5:	74 24                	je     8013db <fd_lookup+0x48>
  8013b7:	89 c2                	mov    %eax,%edx
  8013b9:	c1 ea 0c             	shr    $0xc,%edx
  8013bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c3:	f6 c2 01             	test   $0x1,%dl
  8013c6:	74 1a                	je     8013e2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8013cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d2:	eb 13                	jmp    8013e7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d9:	eb 0c                	jmp    8013e7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e0:	eb 05                	jmp    8013e7 <fd_lookup+0x54>
  8013e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f2:	ba 00 29 80 00       	mov    $0x802900,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f7:	eb 13                	jmp    80140c <dev_lookup+0x23>
  8013f9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013fc:	39 08                	cmp    %ecx,(%eax)
  8013fe:	75 0c                	jne    80140c <dev_lookup+0x23>
			*dev = devtab[i];
  801400:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801403:	89 01                	mov    %eax,(%ecx)
			return 0;
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
  80140a:	eb 2e                	jmp    80143a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80140c:	8b 02                	mov    (%edx),%eax
  80140e:	85 c0                	test   %eax,%eax
  801410:	75 e7                	jne    8013f9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801412:	a1 04 40 80 00       	mov    0x804004,%eax
  801417:	8b 40 50             	mov    0x50(%eax),%eax
  80141a:	83 ec 04             	sub    $0x4,%esp
  80141d:	51                   	push   %ecx
  80141e:	50                   	push   %eax
  80141f:	68 80 28 80 00       	push   $0x802880
  801424:	e8 5c ef ff ff       	call   800385 <cprintf>
	*dev = 0;
  801429:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	83 ec 10             	sub    $0x10,%esp
  801444:	8b 75 08             	mov    0x8(%ebp),%esi
  801447:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801454:	c1 e8 0c             	shr    $0xc,%eax
  801457:	50                   	push   %eax
  801458:	e8 36 ff ff ff       	call   801393 <fd_lookup>
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 05                	js     801469 <fd_close+0x2d>
	    || fd != fd2)
  801464:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801467:	74 0c                	je     801475 <fd_close+0x39>
		return (must_exist ? r : 0);
  801469:	84 db                	test   %bl,%bl
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	0f 44 c2             	cmove  %edx,%eax
  801473:	eb 41                	jmp    8014b6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	ff 36                	pushl  (%esi)
  80147e:	e8 66 ff ff ff       	call   8013e9 <dev_lookup>
  801483:	89 c3                	mov    %eax,%ebx
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 1a                	js     8014a6 <fd_close+0x6a>
		if (dev->dev_close)
  80148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801492:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801497:	85 c0                	test   %eax,%eax
  801499:	74 0b                	je     8014a6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80149b:	83 ec 0c             	sub    $0xc,%esp
  80149e:	56                   	push   %esi
  80149f:	ff d0                	call   *%eax
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	56                   	push   %esi
  8014aa:	6a 00                	push   $0x0
  8014ac:	e8 e1 f8 ff ff       	call   800d92 <sys_page_unmap>
	return r;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	89 d8                	mov    %ebx,%eax
}
  8014b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5e                   	pop    %esi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	ff 75 08             	pushl  0x8(%ebp)
  8014ca:	e8 c4 fe ff ff       	call   801393 <fd_lookup>
  8014cf:	83 c4 08             	add    $0x8,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 10                	js     8014e6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	6a 01                	push   $0x1
  8014db:	ff 75 f4             	pushl  -0xc(%ebp)
  8014de:	e8 59 ff ff ff       	call   80143c <fd_close>
  8014e3:	83 c4 10             	add    $0x10,%esp
}
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <close_all>:

void
close_all(void)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	53                   	push   %ebx
  8014ec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	53                   	push   %ebx
  8014f8:	e8 c0 ff ff ff       	call   8014bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014fd:	83 c3 01             	add    $0x1,%ebx
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	83 fb 20             	cmp    $0x20,%ebx
  801506:	75 ec                	jne    8014f4 <close_all+0xc>
		close(i);
}
  801508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	57                   	push   %edi
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	83 ec 2c             	sub    $0x2c,%esp
  801516:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801519:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	ff 75 08             	pushl  0x8(%ebp)
  801520:	e8 6e fe ff ff       	call   801393 <fd_lookup>
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	0f 88 c1 00 00 00    	js     8015f1 <dup+0xe4>
		return r;
	close(newfdnum);
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	56                   	push   %esi
  801534:	e8 84 ff ff ff       	call   8014bd <close>

	newfd = INDEX2FD(newfdnum);
  801539:	89 f3                	mov    %esi,%ebx
  80153b:	c1 e3 0c             	shl    $0xc,%ebx
  80153e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801544:	83 c4 04             	add    $0x4,%esp
  801547:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154a:	e8 de fd ff ff       	call   80132d <fd2data>
  80154f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801551:	89 1c 24             	mov    %ebx,(%esp)
  801554:	e8 d4 fd ff ff       	call   80132d <fd2data>
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155f:	89 f8                	mov    %edi,%eax
  801561:	c1 e8 16             	shr    $0x16,%eax
  801564:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156b:	a8 01                	test   $0x1,%al
  80156d:	74 37                	je     8015a6 <dup+0x99>
  80156f:	89 f8                	mov    %edi,%eax
  801571:	c1 e8 0c             	shr    $0xc,%eax
  801574:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80157b:	f6 c2 01             	test   $0x1,%dl
  80157e:	74 26                	je     8015a6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801580:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801587:	83 ec 0c             	sub    $0xc,%esp
  80158a:	25 07 0e 00 00       	and    $0xe07,%eax
  80158f:	50                   	push   %eax
  801590:	ff 75 d4             	pushl  -0x2c(%ebp)
  801593:	6a 00                	push   $0x0
  801595:	57                   	push   %edi
  801596:	6a 00                	push   $0x0
  801598:	e8 b3 f7 ff ff       	call   800d50 <sys_page_map>
  80159d:	89 c7                	mov    %eax,%edi
  80159f:	83 c4 20             	add    $0x20,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 2e                	js     8015d4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a9:	89 d0                	mov    %edx,%eax
  8015ab:	c1 e8 0c             	shr    $0xc,%eax
  8015ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8015bd:	50                   	push   %eax
  8015be:	53                   	push   %ebx
  8015bf:	6a 00                	push   $0x0
  8015c1:	52                   	push   %edx
  8015c2:	6a 00                	push   $0x0
  8015c4:	e8 87 f7 ff ff       	call   800d50 <sys_page_map>
  8015c9:	89 c7                	mov    %eax,%edi
  8015cb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015ce:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015d0:	85 ff                	test   %edi,%edi
  8015d2:	79 1d                	jns    8015f1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	53                   	push   %ebx
  8015d8:	6a 00                	push   $0x0
  8015da:	e8 b3 f7 ff ff       	call   800d92 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015df:	83 c4 08             	add    $0x8,%esp
  8015e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e5:	6a 00                	push   $0x0
  8015e7:	e8 a6 f7 ff ff       	call   800d92 <sys_page_unmap>
	return r;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	89 f8                	mov    %edi,%eax
}
  8015f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5e                   	pop    %esi
  8015f6:	5f                   	pop    %edi
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    

008015f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 14             	sub    $0x14,%esp
  801600:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801603:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	53                   	push   %ebx
  801608:	e8 86 fd ff ff       	call   801393 <fd_lookup>
  80160d:	83 c4 08             	add    $0x8,%esp
  801610:	89 c2                	mov    %eax,%edx
  801612:	85 c0                	test   %eax,%eax
  801614:	78 6d                	js     801683 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	ff 30                	pushl  (%eax)
  801622:	e8 c2 fd ff ff       	call   8013e9 <dev_lookup>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 4c                	js     80167a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80162e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801631:	8b 42 08             	mov    0x8(%edx),%eax
  801634:	83 e0 03             	and    $0x3,%eax
  801637:	83 f8 01             	cmp    $0x1,%eax
  80163a:	75 21                	jne    80165d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80163c:	a1 04 40 80 00       	mov    0x804004,%eax
  801641:	8b 40 50             	mov    0x50(%eax),%eax
  801644:	83 ec 04             	sub    $0x4,%esp
  801647:	53                   	push   %ebx
  801648:	50                   	push   %eax
  801649:	68 c4 28 80 00       	push   $0x8028c4
  80164e:	e8 32 ed ff ff       	call   800385 <cprintf>
		return -E_INVAL;
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165b:	eb 26                	jmp    801683 <read+0x8a>
	}
	if (!dev->dev_read)
  80165d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801660:	8b 40 08             	mov    0x8(%eax),%eax
  801663:	85 c0                	test   %eax,%eax
  801665:	74 17                	je     80167e <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801667:	83 ec 04             	sub    $0x4,%esp
  80166a:	ff 75 10             	pushl  0x10(%ebp)
  80166d:	ff 75 0c             	pushl  0xc(%ebp)
  801670:	52                   	push   %edx
  801671:	ff d0                	call   *%eax
  801673:	89 c2                	mov    %eax,%edx
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	eb 09                	jmp    801683 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	eb 05                	jmp    801683 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80167e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801683:	89 d0                	mov    %edx,%eax
  801685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	57                   	push   %edi
  80168e:	56                   	push   %esi
  80168f:	53                   	push   %ebx
  801690:	83 ec 0c             	sub    $0xc,%esp
  801693:	8b 7d 08             	mov    0x8(%ebp),%edi
  801696:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801699:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169e:	eb 21                	jmp    8016c1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	89 f0                	mov    %esi,%eax
  8016a5:	29 d8                	sub    %ebx,%eax
  8016a7:	50                   	push   %eax
  8016a8:	89 d8                	mov    %ebx,%eax
  8016aa:	03 45 0c             	add    0xc(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	57                   	push   %edi
  8016af:	e8 45 ff ff ff       	call   8015f9 <read>
		if (m < 0)
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 10                	js     8016cb <readn+0x41>
			return m;
		if (m == 0)
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	74 0a                	je     8016c9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016bf:	01 c3                	add    %eax,%ebx
  8016c1:	39 f3                	cmp    %esi,%ebx
  8016c3:	72 db                	jb     8016a0 <readn+0x16>
  8016c5:	89 d8                	mov    %ebx,%eax
  8016c7:	eb 02                	jmp    8016cb <readn+0x41>
  8016c9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ce:	5b                   	pop    %ebx
  8016cf:	5e                   	pop    %esi
  8016d0:	5f                   	pop    %edi
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 14             	sub    $0x14,%esp
  8016da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e0:	50                   	push   %eax
  8016e1:	53                   	push   %ebx
  8016e2:	e8 ac fc ff ff       	call   801393 <fd_lookup>
  8016e7:	83 c4 08             	add    $0x8,%esp
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 68                	js     801758 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f6:	50                   	push   %eax
  8016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fa:	ff 30                	pushl  (%eax)
  8016fc:	e8 e8 fc ff ff       	call   8013e9 <dev_lookup>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	85 c0                	test   %eax,%eax
  801706:	78 47                	js     80174f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801708:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170f:	75 21                	jne    801732 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801711:	a1 04 40 80 00       	mov    0x804004,%eax
  801716:	8b 40 50             	mov    0x50(%eax),%eax
  801719:	83 ec 04             	sub    $0x4,%esp
  80171c:	53                   	push   %ebx
  80171d:	50                   	push   %eax
  80171e:	68 e0 28 80 00       	push   $0x8028e0
  801723:	e8 5d ec ff ff       	call   800385 <cprintf>
		return -E_INVAL;
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801730:	eb 26                	jmp    801758 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801732:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801735:	8b 52 0c             	mov    0xc(%edx),%edx
  801738:	85 d2                	test   %edx,%edx
  80173a:	74 17                	je     801753 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80173c:	83 ec 04             	sub    $0x4,%esp
  80173f:	ff 75 10             	pushl  0x10(%ebp)
  801742:	ff 75 0c             	pushl  0xc(%ebp)
  801745:	50                   	push   %eax
  801746:	ff d2                	call   *%edx
  801748:	89 c2                	mov    %eax,%edx
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	eb 09                	jmp    801758 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174f:	89 c2                	mov    %eax,%edx
  801751:	eb 05                	jmp    801758 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801753:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801758:	89 d0                	mov    %edx,%eax
  80175a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <seek>:

int
seek(int fdnum, off_t offset)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801765:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801768:	50                   	push   %eax
  801769:	ff 75 08             	pushl  0x8(%ebp)
  80176c:	e8 22 fc ff ff       	call   801393 <fd_lookup>
  801771:	83 c4 08             	add    $0x8,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	78 0e                	js     801786 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801778:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80177b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801781:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 14             	sub    $0x14,%esp
  80178f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801792:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801795:	50                   	push   %eax
  801796:	53                   	push   %ebx
  801797:	e8 f7 fb ff ff       	call   801393 <fd_lookup>
  80179c:	83 c4 08             	add    $0x8,%esp
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 65                	js     80180a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ab:	50                   	push   %eax
  8017ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017af:	ff 30                	pushl  (%eax)
  8017b1:	e8 33 fc ff ff       	call   8013e9 <dev_lookup>
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 44                	js     801801 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c4:	75 21                	jne    8017e7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017cb:	8b 40 50             	mov    0x50(%eax),%eax
  8017ce:	83 ec 04             	sub    $0x4,%esp
  8017d1:	53                   	push   %ebx
  8017d2:	50                   	push   %eax
  8017d3:	68 a0 28 80 00       	push   $0x8028a0
  8017d8:	e8 a8 eb ff ff       	call   800385 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e5:	eb 23                	jmp    80180a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ea:	8b 52 18             	mov    0x18(%edx),%edx
  8017ed:	85 d2                	test   %edx,%edx
  8017ef:	74 14                	je     801805 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	ff 75 0c             	pushl  0xc(%ebp)
  8017f7:	50                   	push   %eax
  8017f8:	ff d2                	call   *%edx
  8017fa:	89 c2                	mov    %eax,%edx
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	eb 09                	jmp    80180a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801801:	89 c2                	mov    %eax,%edx
  801803:	eb 05                	jmp    80180a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801805:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80180a:	89 d0                	mov    %edx,%eax
  80180c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	53                   	push   %ebx
  801815:	83 ec 14             	sub    $0x14,%esp
  801818:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181e:	50                   	push   %eax
  80181f:	ff 75 08             	pushl  0x8(%ebp)
  801822:	e8 6c fb ff ff       	call   801393 <fd_lookup>
  801827:	83 c4 08             	add    $0x8,%esp
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 58                	js     801888 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801836:	50                   	push   %eax
  801837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183a:	ff 30                	pushl  (%eax)
  80183c:	e8 a8 fb ff ff       	call   8013e9 <dev_lookup>
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	85 c0                	test   %eax,%eax
  801846:	78 37                	js     80187f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184f:	74 32                	je     801883 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801851:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801854:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185b:	00 00 00 
	stat->st_isdir = 0;
  80185e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801865:	00 00 00 
	stat->st_dev = dev;
  801868:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	53                   	push   %ebx
  801872:	ff 75 f0             	pushl  -0x10(%ebp)
  801875:	ff 50 14             	call   *0x14(%eax)
  801878:	89 c2                	mov    %eax,%edx
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	eb 09                	jmp    801888 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187f:	89 c2                	mov    %eax,%edx
  801881:	eb 05                	jmp    801888 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801883:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801888:	89 d0                	mov    %edx,%eax
  80188a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	6a 00                	push   $0x0
  801899:	ff 75 08             	pushl  0x8(%ebp)
  80189c:	e8 e3 01 00 00       	call   801a84 <open>
  8018a1:	89 c3                	mov    %eax,%ebx
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 1b                	js     8018c5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	50                   	push   %eax
  8018b1:	e8 5b ff ff ff       	call   801811 <fstat>
  8018b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b8:	89 1c 24             	mov    %ebx,(%esp)
  8018bb:	e8 fd fb ff ff       	call   8014bd <close>
	return r;
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	89 f0                	mov    %esi,%eax
}
  8018c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c8:	5b                   	pop    %ebx
  8018c9:	5e                   	pop    %esi
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	89 c6                	mov    %eax,%esi
  8018d3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018dc:	75 12                	jne    8018f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018de:	83 ec 0c             	sub    $0xc,%esp
  8018e1:	6a 01                	push   $0x1
  8018e3:	e8 f5 f9 ff ff       	call   8012dd <ipc_find_env>
  8018e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8018ed:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018f0:	6a 07                	push   $0x7
  8018f2:	68 00 50 80 00       	push   $0x805000
  8018f7:	56                   	push   %esi
  8018f8:	ff 35 00 40 80 00    	pushl  0x804000
  8018fe:	e8 78 f9 ff ff       	call   80127b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801903:	83 c4 0c             	add    $0xc,%esp
  801906:	6a 00                	push   $0x0
  801908:	53                   	push   %ebx
  801909:	6a 00                	push   $0x0
  80190b:	e8 f6 f8 ff ff       	call   801206 <ipc_recv>
}
  801910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	8b 40 0c             	mov    0xc(%eax),%eax
  801923:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801930:	ba 00 00 00 00       	mov    $0x0,%edx
  801935:	b8 02 00 00 00       	mov    $0x2,%eax
  80193a:	e8 8d ff ff ff       	call   8018cc <fsipc>
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	8b 40 0c             	mov    0xc(%eax),%eax
  80194d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801952:	ba 00 00 00 00       	mov    $0x0,%edx
  801957:	b8 06 00 00 00       	mov    $0x6,%eax
  80195c:	e8 6b ff ff ff       	call   8018cc <fsipc>
}
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	53                   	push   %ebx
  801967:	83 ec 04             	sub    $0x4,%esp
  80196a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	8b 40 0c             	mov    0xc(%eax),%eax
  801973:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801978:	ba 00 00 00 00       	mov    $0x0,%edx
  80197d:	b8 05 00 00 00       	mov    $0x5,%eax
  801982:	e8 45 ff ff ff       	call   8018cc <fsipc>
  801987:	85 c0                	test   %eax,%eax
  801989:	78 2c                	js     8019b7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	68 00 50 80 00       	push   $0x805000
  801993:	53                   	push   %ebx
  801994:	e8 71 ef ff ff       	call   80090a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801999:	a1 80 50 80 00       	mov    0x805080,%eax
  80199e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a4:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8019cb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019d1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019db:	0f 47 c2             	cmova  %edx,%eax
  8019de:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019e3:	50                   	push   %eax
  8019e4:	ff 75 0c             	pushl  0xc(%ebp)
  8019e7:	68 08 50 80 00       	push   $0x805008
  8019ec:	e8 ab f0 ff ff       	call   800a9c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8019fb:	e8 cc fe ff ff       	call   8018cc <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a15:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	b8 03 00 00 00       	mov    $0x3,%eax
  801a25:	e8 a2 fe ff ff       	call   8018cc <fsipc>
  801a2a:	89 c3                	mov    %eax,%ebx
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 4b                	js     801a7b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a30:	39 c6                	cmp    %eax,%esi
  801a32:	73 16                	jae    801a4a <devfile_read+0x48>
  801a34:	68 10 29 80 00       	push   $0x802910
  801a39:	68 17 29 80 00       	push   $0x802917
  801a3e:	6a 7c                	push   $0x7c
  801a40:	68 2c 29 80 00       	push   $0x80292c
  801a45:	e8 62 e8 ff ff       	call   8002ac <_panic>
	assert(r <= PGSIZE);
  801a4a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4f:	7e 16                	jle    801a67 <devfile_read+0x65>
  801a51:	68 37 29 80 00       	push   $0x802937
  801a56:	68 17 29 80 00       	push   $0x802917
  801a5b:	6a 7d                	push   $0x7d
  801a5d:	68 2c 29 80 00       	push   $0x80292c
  801a62:	e8 45 e8 ff ff       	call   8002ac <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a67:	83 ec 04             	sub    $0x4,%esp
  801a6a:	50                   	push   %eax
  801a6b:	68 00 50 80 00       	push   $0x805000
  801a70:	ff 75 0c             	pushl  0xc(%ebp)
  801a73:	e8 24 f0 ff ff       	call   800a9c <memmove>
	return r;
  801a78:	83 c4 10             	add    $0x10,%esp
}
  801a7b:	89 d8                	mov    %ebx,%eax
  801a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	53                   	push   %ebx
  801a88:	83 ec 20             	sub    $0x20,%esp
  801a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8e:	53                   	push   %ebx
  801a8f:	e8 3d ee ff ff       	call   8008d1 <strlen>
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9c:	7f 67                	jg     801b05 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	e8 9a f8 ff ff       	call   801344 <fd_alloc>
  801aaa:	83 c4 10             	add    $0x10,%esp
		return r;
  801aad:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 57                	js     801b0a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	53                   	push   %ebx
  801ab7:	68 00 50 80 00       	push   $0x805000
  801abc:	e8 49 ee ff ff       	call   80090a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801acc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad1:	e8 f6 fd ff ff       	call   8018cc <fsipc>
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	79 14                	jns    801af3 <open+0x6f>
		fd_close(fd, 0);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	6a 00                	push   $0x0
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	e8 50 f9 ff ff       	call   80143c <fd_close>
		return r;
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	89 da                	mov    %ebx,%edx
  801af1:	eb 17                	jmp    801b0a <open+0x86>
	}

	return fd2num(fd);
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	ff 75 f4             	pushl  -0xc(%ebp)
  801af9:	e8 1f f8 ff ff       	call   80131d <fd2num>
  801afe:	89 c2                	mov    %eax,%edx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	eb 05                	jmp    801b0a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b05:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b0a:	89 d0                	mov    %edx,%eax
  801b0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b17:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1c:	b8 08 00 00 00       	mov    $0x8,%eax
  801b21:	e8 a6 fd ff ff       	call   8018cc <fsipc>
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2e:	89 d0                	mov    %edx,%eax
  801b30:	c1 e8 16             	shr    $0x16,%eax
  801b33:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3f:	f6 c1 01             	test   $0x1,%cl
  801b42:	74 1d                	je     801b61 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b44:	c1 ea 0c             	shr    $0xc,%edx
  801b47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b4e:	f6 c2 01             	test   $0x1,%dl
  801b51:	74 0e                	je     801b61 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b53:	c1 ea 0c             	shr    $0xc,%edx
  801b56:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b5d:	ef 
  801b5e:	0f b7 c0             	movzwl %ax,%eax
}
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	ff 75 08             	pushl  0x8(%ebp)
  801b71:	e8 b7 f7 ff ff       	call   80132d <fd2data>
  801b76:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b78:	83 c4 08             	add    $0x8,%esp
  801b7b:	68 43 29 80 00       	push   $0x802943
  801b80:	53                   	push   %ebx
  801b81:	e8 84 ed ff ff       	call   80090a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b86:	8b 46 04             	mov    0x4(%esi),%eax
  801b89:	2b 06                	sub    (%esi),%eax
  801b8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b98:	00 00 00 
	stat->st_dev = &devpipe;
  801b9b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba2:	30 80 00 
	return 0;
}
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  801baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bbb:	53                   	push   %ebx
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 cf f1 ff ff       	call   800d92 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc3:	89 1c 24             	mov    %ebx,(%esp)
  801bc6:	e8 62 f7 ff ff       	call   80132d <fd2data>
  801bcb:	83 c4 08             	add    $0x8,%esp
  801bce:	50                   	push   %eax
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 bc f1 ff ff       	call   800d92 <sys_page_unmap>
}
  801bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	83 ec 1c             	sub    $0x1c,%esp
  801be4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801be7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bee:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf7:	e8 2c ff ff ff       	call   801b28 <pageref>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	89 3c 24             	mov    %edi,(%esp)
  801c01:	e8 22 ff ff ff       	call   801b28 <pageref>
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	39 c3                	cmp    %eax,%ebx
  801c0b:	0f 94 c1             	sete   %cl
  801c0e:	0f b6 c9             	movzbl %cl,%ecx
  801c11:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c14:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c1a:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801c1d:	39 ce                	cmp    %ecx,%esi
  801c1f:	74 1b                	je     801c3c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c21:	39 c3                	cmp    %eax,%ebx
  801c23:	75 c4                	jne    801be9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c25:	8b 42 60             	mov    0x60(%edx),%eax
  801c28:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2b:	50                   	push   %eax
  801c2c:	56                   	push   %esi
  801c2d:	68 4a 29 80 00       	push   $0x80294a
  801c32:	e8 4e e7 ff ff       	call   800385 <cprintf>
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	eb ad                	jmp    801be9 <_pipeisclosed+0xe>
	}
}
  801c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	57                   	push   %edi
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 28             	sub    $0x28,%esp
  801c50:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c53:	56                   	push   %esi
  801c54:	e8 d4 f6 ff ff       	call   80132d <fd2data>
  801c59:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c63:	eb 4b                	jmp    801cb0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c65:	89 da                	mov    %ebx,%edx
  801c67:	89 f0                	mov    %esi,%eax
  801c69:	e8 6d ff ff ff       	call   801bdb <_pipeisclosed>
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	75 48                	jne    801cba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c72:	e8 77 f0 ff ff       	call   800cee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c77:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7a:	8b 0b                	mov    (%ebx),%ecx
  801c7c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c7f:	39 d0                	cmp    %edx,%eax
  801c81:	73 e2                	jae    801c65 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	c1 fa 1f             	sar    $0x1f,%edx
  801c92:	89 d1                	mov    %edx,%ecx
  801c94:	c1 e9 1b             	shr    $0x1b,%ecx
  801c97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c9a:	83 e2 1f             	and    $0x1f,%edx
  801c9d:	29 ca                	sub    %ecx,%edx
  801c9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ca3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca7:	83 c0 01             	add    $0x1,%eax
  801caa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cad:	83 c7 01             	add    $0x1,%edi
  801cb0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb3:	75 c2                	jne    801c77 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb8:	eb 05                	jmp    801cbf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	83 ec 18             	sub    $0x18,%esp
  801cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cd3:	57                   	push   %edi
  801cd4:	e8 54 f6 ff ff       	call   80132d <fd2data>
  801cd9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce3:	eb 3d                	jmp    801d22 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ce5:	85 db                	test   %ebx,%ebx
  801ce7:	74 04                	je     801ced <devpipe_read+0x26>
				return i;
  801ce9:	89 d8                	mov    %ebx,%eax
  801ceb:	eb 44                	jmp    801d31 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	e8 e5 fe ff ff       	call   801bdb <_pipeisclosed>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	75 32                	jne    801d2c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cfa:	e8 ef ef ff ff       	call   800cee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cff:	8b 06                	mov    (%esi),%eax
  801d01:	3b 46 04             	cmp    0x4(%esi),%eax
  801d04:	74 df                	je     801ce5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d06:	99                   	cltd   
  801d07:	c1 ea 1b             	shr    $0x1b,%edx
  801d0a:	01 d0                	add    %edx,%eax
  801d0c:	83 e0 1f             	and    $0x1f,%eax
  801d0f:	29 d0                	sub    %edx,%eax
  801d11:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d19:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d1c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1f:	83 c3 01             	add    $0x1,%ebx
  801d22:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d25:	75 d8                	jne    801cff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d27:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2a:	eb 05                	jmp    801d31 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	e8 fa f5 ff ff       	call   801344 <fd_alloc>
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	89 c2                	mov    %eax,%edx
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	0f 88 2c 01 00 00    	js     801e83 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d57:	83 ec 04             	sub    $0x4,%esp
  801d5a:	68 07 04 00 00       	push   $0x407
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	6a 00                	push   $0x0
  801d64:	e8 a4 ef ff ff       	call   800d0d <sys_page_alloc>
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	89 c2                	mov    %eax,%edx
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 0d 01 00 00    	js     801e83 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	e8 c2 f5 ff ff       	call   801344 <fd_alloc>
  801d82:	89 c3                	mov    %eax,%ebx
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	0f 88 e2 00 00 00    	js     801e71 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8f:	83 ec 04             	sub    $0x4,%esp
  801d92:	68 07 04 00 00       	push   $0x407
  801d97:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 6c ef ff ff       	call   800d0d <sys_page_alloc>
  801da1:	89 c3                	mov    %eax,%ebx
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	85 c0                	test   %eax,%eax
  801da8:	0f 88 c3 00 00 00    	js     801e71 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dae:	83 ec 0c             	sub    $0xc,%esp
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	e8 74 f5 ff ff       	call   80132d <fd2data>
  801db9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbb:	83 c4 0c             	add    $0xc,%esp
  801dbe:	68 07 04 00 00       	push   $0x407
  801dc3:	50                   	push   %eax
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 42 ef ff ff       	call   800d0d <sys_page_alloc>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 89 00 00 00    	js     801e61 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd8:	83 ec 0c             	sub    $0xc,%esp
  801ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dde:	e8 4a f5 ff ff       	call   80132d <fd2data>
  801de3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dea:	50                   	push   %eax
  801deb:	6a 00                	push   $0x0
  801ded:	56                   	push   %esi
  801dee:	6a 00                	push   $0x0
  801df0:	e8 5b ef ff ff       	call   800d50 <sys_page_map>
  801df5:	89 c3                	mov    %eax,%ebx
  801df7:	83 c4 20             	add    $0x20,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 55                	js     801e53 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dfe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e21:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2e:	e8 ea f4 ff ff       	call   80131d <fd2num>
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e36:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e38:	83 c4 04             	add    $0x4,%esp
  801e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3e:	e8 da f4 ff ff       	call   80131d <fd2num>
  801e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e46:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e51:	eb 30                	jmp    801e83 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	56                   	push   %esi
  801e57:	6a 00                	push   $0x0
  801e59:	e8 34 ef ff ff       	call   800d92 <sys_page_unmap>
  801e5e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	ff 75 f0             	pushl  -0x10(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 24 ef ff ff       	call   800d92 <sys_page_unmap>
  801e6e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e71:	83 ec 08             	sub    $0x8,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	6a 00                	push   $0x0
  801e79:	e8 14 ef ff ff       	call   800d92 <sys_page_unmap>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e83:	89 d0                	mov    %edx,%eax
  801e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	ff 75 08             	pushl  0x8(%ebp)
  801e99:	e8 f5 f4 ff ff       	call   801393 <fd_lookup>
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 18                	js     801ebd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eab:	e8 7d f4 ff ff       	call   80132d <fd2data>
	return _pipeisclosed(fd, p);
  801eb0:	89 c2                	mov    %eax,%edx
  801eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb5:	e8 21 fd ff ff       	call   801bdb <_pipeisclosed>
  801eba:	83 c4 10             	add    $0x10,%esp
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ecf:	68 62 29 80 00       	push   $0x802962
  801ed4:	ff 75 0c             	pushl  0xc(%ebp)
  801ed7:	e8 2e ea ff ff       	call   80090a <strcpy>
	return 0;
}
  801edc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	57                   	push   %edi
  801ee7:	56                   	push   %esi
  801ee8:	53                   	push   %ebx
  801ee9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801efa:	eb 2d                	jmp    801f29 <devcons_write+0x46>
		m = n - tot;
  801efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eff:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f01:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f04:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f09:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f0c:	83 ec 04             	sub    $0x4,%esp
  801f0f:	53                   	push   %ebx
  801f10:	03 45 0c             	add    0xc(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	57                   	push   %edi
  801f15:	e8 82 eb ff ff       	call   800a9c <memmove>
		sys_cputs(buf, m);
  801f1a:	83 c4 08             	add    $0x8,%esp
  801f1d:	53                   	push   %ebx
  801f1e:	57                   	push   %edi
  801f1f:	e8 2d ed ff ff       	call   800c51 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f24:	01 de                	add    %ebx,%esi
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	89 f0                	mov    %esi,%eax
  801f2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f2e:	72 cc                	jb     801efc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f47:	74 2a                	je     801f73 <devcons_read+0x3b>
  801f49:	eb 05                	jmp    801f50 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f4b:	e8 9e ed ff ff       	call   800cee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f50:	e8 1a ed ff ff       	call   800c6f <sys_cgetc>
  801f55:	85 c0                	test   %eax,%eax
  801f57:	74 f2                	je     801f4b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 16                	js     801f73 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f5d:	83 f8 04             	cmp    $0x4,%eax
  801f60:	74 0c                	je     801f6e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f65:	88 02                	mov    %al,(%edx)
	return 1;
  801f67:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6c:	eb 05                	jmp    801f73 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f81:	6a 01                	push   $0x1
  801f83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	e8 c5 ec ff ff       	call   800c51 <sys_cputs>
}
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <getchar>:

int
getchar(void)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f97:	6a 01                	push   $0x1
  801f99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f9c:	50                   	push   %eax
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 55 f6 ff ff       	call   8015f9 <read>
	if (r < 0)
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	78 0f                	js     801fba <getchar+0x29>
		return r;
	if (r < 1)
  801fab:	85 c0                	test   %eax,%eax
  801fad:	7e 06                	jle    801fb5 <getchar+0x24>
		return -E_EOF;
	return c;
  801faf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fb3:	eb 05                	jmp    801fba <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fb5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc5:	50                   	push   %eax
  801fc6:	ff 75 08             	pushl  0x8(%ebp)
  801fc9:	e8 c5 f3 ff ff       	call   801393 <fd_lookup>
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 11                	js     801fe6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fde:	39 10                	cmp    %edx,(%eax)
  801fe0:	0f 94 c0             	sete   %al
  801fe3:	0f b6 c0             	movzbl %al,%eax
}
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <opencons>:

int
opencons(void)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff1:	50                   	push   %eax
  801ff2:	e8 4d f3 ff ff       	call   801344 <fd_alloc>
  801ff7:	83 c4 10             	add    $0x10,%esp
		return r;
  801ffa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	78 3e                	js     80203e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	68 07 04 00 00       	push   $0x407
  802008:	ff 75 f4             	pushl  -0xc(%ebp)
  80200b:	6a 00                	push   $0x0
  80200d:	e8 fb ec ff ff       	call   800d0d <sys_page_alloc>
  802012:	83 c4 10             	add    $0x10,%esp
		return r;
  802015:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802017:	85 c0                	test   %eax,%eax
  802019:	78 23                	js     80203e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80201b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802024:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802026:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802029:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802030:	83 ec 0c             	sub    $0xc,%esp
  802033:	50                   	push   %eax
  802034:	e8 e4 f2 ff ff       	call   80131d <fd2num>
  802039:	89 c2                	mov    %eax,%edx
  80203b:	83 c4 10             	add    $0x10,%esp
}
  80203e:	89 d0                	mov    %edx,%eax
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802048:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80204f:	75 2a                	jne    80207b <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802051:	83 ec 04             	sub    $0x4,%esp
  802054:	6a 07                	push   $0x7
  802056:	68 00 f0 bf ee       	push   $0xeebff000
  80205b:	6a 00                	push   $0x0
  80205d:	e8 ab ec ff ff       	call   800d0d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	85 c0                	test   %eax,%eax
  802067:	79 12                	jns    80207b <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802069:	50                   	push   %eax
  80206a:	68 6e 29 80 00       	push   $0x80296e
  80206f:	6a 23                	push   $0x23
  802071:	68 72 29 80 00       	push   $0x802972
  802076:	e8 31 e2 ff ff       	call   8002ac <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802083:	83 ec 08             	sub    $0x8,%esp
  802086:	68 ad 20 80 00       	push   $0x8020ad
  80208b:	6a 00                	push   $0x0
  80208d:	e8 c6 ed ff ff       	call   800e58 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	79 12                	jns    8020ab <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802099:	50                   	push   %eax
  80209a:	68 6e 29 80 00       	push   $0x80296e
  80209f:	6a 2c                	push   $0x2c
  8020a1:	68 72 29 80 00       	push   $0x802972
  8020a6:	e8 01 e2 ff ff       	call   8002ac <_panic>
	}
}
  8020ab:	c9                   	leave  
  8020ac:	c3                   	ret    

008020ad <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020ad:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020ae:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020b3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020b5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020b8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020bc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020c1:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020c5:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020c7:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020ca:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020cb:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020ce:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020cf:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020d0:	c3                   	ret    
  8020d1:	66 90                	xchg   %ax,%ax
  8020d3:	66 90                	xchg   %ax,%ax
  8020d5:	66 90                	xchg   %ax,%ax
  8020d7:	66 90                	xchg   %ax,%ax
  8020d9:	66 90                	xchg   %ax,%ax
  8020db:	66 90                	xchg   %ax,%ax
  8020dd:	66 90                	xchg   %ax,%ax
  8020df:	90                   	nop

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
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
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
