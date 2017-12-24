
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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  80003b:	68 00 23 80 00       	push   $0x802300
  800040:	e8 20 03 00 00       	call   800365 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 74 1c 00 00       	call   801cc4 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 19 23 80 00       	push   $0x802319
  80005d:	6a 0d                	push   $0xd
  80005f:	68 22 23 80 00       	push   $0x802322
  800064:	e8 23 02 00 00       	call   80028c <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 46 0f 00 00       	call   800fb4 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 36 23 80 00       	push   $0x802336
  80007a:	6a 10                	push   $0x10
  80007c:	68 22 23 80 00       	push   $0x802322
  800081:	e8 06 02 00 00       	call   80028c <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 b3 13 00 00       	call   801448 <close>
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
  8000a3:	e8 6f 1d 00 00       	call   801e17 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 3f 23 80 00       	push   $0x80233f
  8000b7:	e8 a9 02 00 00       	call   800365 <cprintf>
				exit();
  8000bc:	e8 b1 01 00 00       	call   800272 <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 05 0c 00 00       	call   800cce <sys_yield>
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
  8000d7:	e8 bf 10 00 00       	call   80119b <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 5a 23 80 00       	push   $0x80235a
  8000e8:	e8 78 02 00 00       	call   800365 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 65 23 80 00       	push   $0x802365
  800108:	e8 58 02 00 00       	call   800365 <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 7e 13 00 00       	call   801498 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 63 13 00 00       	call   801498 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 70 23 80 00       	push   $0x802370
  800148:	e8 18 02 00 00       	call   800365 <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 bf 1c 00 00       	call   801e17 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 cc 23 80 00       	push   $0x8023cc
  800167:	6a 3a                	push   $0x3a
  800169:	68 22 23 80 00       	push   $0x802322
  80016e:	e8 19 01 00 00       	call   80028c <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 9c 11 00 00       	call   80131e <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 86 23 80 00       	push   $0x802386
  80018f:	6a 3c                	push   $0x3c
  800191:	68 22 23 80 00       	push   $0x802322
  800196:	e8 f1 00 00 00       	call   80028c <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 12 11 00 00       	call   8012b8 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 05 19 00 00       	call   801ab3 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 9e 23 80 00       	push   $0x80239e
  8001be:	e8 a2 01 00 00       	call   800365 <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 b4 23 80 00       	push   $0x8023b4
  8001d5:	e8 8b 01 00 00       	call   800365 <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001ed:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001f4:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001f7:	e8 b3 0a 00 00       	call   800caf <sys_getenvid>
  8001fc:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800202:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800207:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80020c:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800211:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800214:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80021a:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80021d:	39 c8                	cmp    %ecx,%eax
  80021f:	0f 44 fb             	cmove  %ebx,%edi
  800222:	b9 01 00 00 00       	mov    $0x1,%ecx
  800227:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80022a:	83 c2 01             	add    $0x1,%edx
  80022d:	83 c3 7c             	add    $0x7c,%ebx
  800230:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800236:	75 d9                	jne    800211 <libmain+0x2d>
  800238:	89 f0                	mov    %esi,%eax
  80023a:	84 c0                	test   %al,%al
  80023c:	74 06                	je     800244 <libmain+0x60>
  80023e:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800244:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800248:	7e 0a                	jle    800254 <libmain+0x70>
		binaryname = argv[0];
  80024a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024d:	8b 00                	mov    (%eax),%eax
  80024f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	e8 d1 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800262:	e8 0b 00 00 00       	call   800272 <exit>
}
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800278:	e8 f6 11 00 00       	call   801473 <close_all>
	sys_env_destroy(0);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	6a 00                	push   $0x0
  800282:	e8 e7 09 00 00       	call   800c6e <sys_env_destroy>
}
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800291:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800294:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80029a:	e8 10 0a 00 00       	call   800caf <sys_getenvid>
  80029f:	83 ec 0c             	sub    $0xc,%esp
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	ff 75 08             	pushl  0x8(%ebp)
  8002a8:	56                   	push   %esi
  8002a9:	50                   	push   %eax
  8002aa:	68 00 24 80 00       	push   $0x802400
  8002af:	e8 b1 00 00 00       	call   800365 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b4:	83 c4 18             	add    $0x18,%esp
  8002b7:	53                   	push   %ebx
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	e8 54 00 00 00       	call   800314 <vcprintf>
	cprintf("\n");
  8002c0:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  8002c7:	e8 99 00 00 00       	call   800365 <cprintf>
  8002cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002cf:	cc                   	int3   
  8002d0:	eb fd                	jmp    8002cf <_panic+0x43>

008002d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 04             	sub    $0x4,%esp
  8002d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002dc:	8b 13                	mov    (%ebx),%edx
  8002de:	8d 42 01             	lea    0x1(%edx),%eax
  8002e1:	89 03                	mov    %eax,(%ebx)
  8002e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ef:	75 1a                	jne    80030b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	68 ff 00 00 00       	push   $0xff
  8002f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002fc:	50                   	push   %eax
  8002fd:	e8 2f 09 00 00       	call   800c31 <sys_cputs>
		b->idx = 0;
  800302:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800308:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80030b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80030f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80031d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800324:	00 00 00 
	b.cnt = 0;
  800327:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80032e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80033d:	50                   	push   %eax
  80033e:	68 d2 02 80 00       	push   $0x8002d2
  800343:	e8 54 01 00 00       	call   80049c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800348:	83 c4 08             	add    $0x8,%esp
  80034b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800351:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	e8 d4 08 00 00       	call   800c31 <sys_cputs>

	return b.cnt;
}
  80035d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800363:	c9                   	leave  
  800364:	c3                   	ret    

00800365 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80036b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80036e:	50                   	push   %eax
  80036f:	ff 75 08             	pushl  0x8(%ebp)
  800372:	e8 9d ff ff ff       	call   800314 <vcprintf>
	va_end(ap);

	return cnt;
}
  800377:	c9                   	leave  
  800378:	c3                   	ret    

00800379 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	57                   	push   %edi
  80037d:	56                   	push   %esi
  80037e:	53                   	push   %ebx
  80037f:	83 ec 1c             	sub    $0x1c,%esp
  800382:	89 c7                	mov    %eax,%edi
  800384:	89 d6                	mov    %edx,%esi
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800392:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800395:	bb 00 00 00 00       	mov    $0x0,%ebx
  80039a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80039d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003a0:	39 d3                	cmp    %edx,%ebx
  8003a2:	72 05                	jb     8003a9 <printnum+0x30>
  8003a4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003a7:	77 45                	ja     8003ee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003a9:	83 ec 0c             	sub    $0xc,%esp
  8003ac:	ff 75 18             	pushl  0x18(%ebp)
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003b5:	53                   	push   %ebx
  8003b6:	ff 75 10             	pushl  0x10(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c8:	e8 93 1c 00 00       	call   802060 <__udivdi3>
  8003cd:	83 c4 18             	add    $0x18,%esp
  8003d0:	52                   	push   %edx
  8003d1:	50                   	push   %eax
  8003d2:	89 f2                	mov    %esi,%edx
  8003d4:	89 f8                	mov    %edi,%eax
  8003d6:	e8 9e ff ff ff       	call   800379 <printnum>
  8003db:	83 c4 20             	add    $0x20,%esp
  8003de:	eb 18                	jmp    8003f8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	56                   	push   %esi
  8003e4:	ff 75 18             	pushl  0x18(%ebp)
  8003e7:	ff d7                	call   *%edi
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	eb 03                	jmp    8003f1 <printnum+0x78>
  8003ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003f1:	83 eb 01             	sub    $0x1,%ebx
  8003f4:	85 db                	test   %ebx,%ebx
  8003f6:	7f e8                	jg     8003e0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	56                   	push   %esi
  8003fc:	83 ec 04             	sub    $0x4,%esp
  8003ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800402:	ff 75 e0             	pushl  -0x20(%ebp)
  800405:	ff 75 dc             	pushl  -0x24(%ebp)
  800408:	ff 75 d8             	pushl  -0x28(%ebp)
  80040b:	e8 80 1d 00 00       	call   802190 <__umoddi3>
  800410:	83 c4 14             	add    $0x14,%esp
  800413:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  80041a:	50                   	push   %eax
  80041b:	ff d7                	call   *%edi
}
  80041d:	83 c4 10             	add    $0x10,%esp
  800420:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800423:	5b                   	pop    %ebx
  800424:	5e                   	pop    %esi
  800425:	5f                   	pop    %edi
  800426:	5d                   	pop    %ebp
  800427:	c3                   	ret    

00800428 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042b:	83 fa 01             	cmp    $0x1,%edx
  80042e:	7e 0e                	jle    80043e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800430:	8b 10                	mov    (%eax),%edx
  800432:	8d 4a 08             	lea    0x8(%edx),%ecx
  800435:	89 08                	mov    %ecx,(%eax)
  800437:	8b 02                	mov    (%edx),%eax
  800439:	8b 52 04             	mov    0x4(%edx),%edx
  80043c:	eb 22                	jmp    800460 <getuint+0x38>
	else if (lflag)
  80043e:	85 d2                	test   %edx,%edx
  800440:	74 10                	je     800452 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800442:	8b 10                	mov    (%eax),%edx
  800444:	8d 4a 04             	lea    0x4(%edx),%ecx
  800447:	89 08                	mov    %ecx,(%eax)
  800449:	8b 02                	mov    (%edx),%eax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
  800450:	eb 0e                	jmp    800460 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800452:	8b 10                	mov    (%eax),%edx
  800454:	8d 4a 04             	lea    0x4(%edx),%ecx
  800457:	89 08                	mov    %ecx,(%eax)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800468:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80046c:	8b 10                	mov    (%eax),%edx
  80046e:	3b 50 04             	cmp    0x4(%eax),%edx
  800471:	73 0a                	jae    80047d <sprintputch+0x1b>
		*b->buf++ = ch;
  800473:	8d 4a 01             	lea    0x1(%edx),%ecx
  800476:	89 08                	mov    %ecx,(%eax)
  800478:	8b 45 08             	mov    0x8(%ebp),%eax
  80047b:	88 02                	mov    %al,(%edx)
}
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800485:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800488:	50                   	push   %eax
  800489:	ff 75 10             	pushl  0x10(%ebp)
  80048c:	ff 75 0c             	pushl  0xc(%ebp)
  80048f:	ff 75 08             	pushl  0x8(%ebp)
  800492:	e8 05 00 00 00       	call   80049c <vprintfmt>
	va_end(ap);
}
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	c9                   	leave  
  80049b:	c3                   	ret    

0080049c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 2c             	sub    $0x2c,%esp
  8004a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ae:	eb 12                	jmp    8004c2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	0f 84 89 03 00 00    	je     800841 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	53                   	push   %ebx
  8004bc:	50                   	push   %eax
  8004bd:	ff d6                	call   *%esi
  8004bf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c2:	83 c7 01             	add    $0x1,%edi
  8004c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c9:	83 f8 25             	cmp    $0x25,%eax
  8004cc:	75 e2                	jne    8004b0 <vprintfmt+0x14>
  8004ce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004d2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ec:	eb 07                	jmp    8004f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8d 47 01             	lea    0x1(%edi),%eax
  8004f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004fb:	0f b6 07             	movzbl (%edi),%eax
  8004fe:	0f b6 c8             	movzbl %al,%ecx
  800501:	83 e8 23             	sub    $0x23,%eax
  800504:	3c 55                	cmp    $0x55,%al
  800506:	0f 87 1a 03 00 00    	ja     800826 <vprintfmt+0x38a>
  80050c:	0f b6 c0             	movzbl %al,%eax
  80050f:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800519:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80051d:	eb d6                	jmp    8004f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800522:	b8 00 00 00 00       	mov    $0x0,%eax
  800527:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80052a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80052d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800531:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800534:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800537:	83 fa 09             	cmp    $0x9,%edx
  80053a:	77 39                	ja     800575 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80053c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80053f:	eb e9                	jmp    80052a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 48 04             	lea    0x4(%eax),%ecx
  800547:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800552:	eb 27                	jmp    80057b <vprintfmt+0xdf>
  800554:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800557:	85 c0                	test   %eax,%eax
  800559:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055e:	0f 49 c8             	cmovns %eax,%ecx
  800561:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	eb 8c                	jmp    8004f5 <vprintfmt+0x59>
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80056c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800573:	eb 80                	jmp    8004f5 <vprintfmt+0x59>
  800575:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800578:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80057b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057f:	0f 89 70 ff ff ff    	jns    8004f5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800585:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800588:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800592:	e9 5e ff ff ff       	jmp    8004f5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800597:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80059d:	e9 53 ff ff ff       	jmp    8004f5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	ff 30                	pushl  (%eax)
  8005b1:	ff d6                	call   *%esi
			break;
  8005b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005b9:	e9 04 ff ff ff       	jmp    8004c2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	99                   	cltd   
  8005ca:	31 d0                	xor    %edx,%eax
  8005cc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ce:	83 f8 0f             	cmp    $0xf,%eax
  8005d1:	7f 0b                	jg     8005de <vprintfmt+0x142>
  8005d3:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8005da:	85 d2                	test   %edx,%edx
  8005dc:	75 18                	jne    8005f6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005de:	50                   	push   %eax
  8005df:	68 3b 24 80 00       	push   $0x80243b
  8005e4:	53                   	push   %ebx
  8005e5:	56                   	push   %esi
  8005e6:	e8 94 fe ff ff       	call   80047f <printfmt>
  8005eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005f1:	e9 cc fe ff ff       	jmp    8004c2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005f6:	52                   	push   %edx
  8005f7:	68 79 28 80 00       	push   $0x802879
  8005fc:	53                   	push   %ebx
  8005fd:	56                   	push   %esi
  8005fe:	e8 7c fe ff ff       	call   80047f <printfmt>
  800603:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800609:	e9 b4 fe ff ff       	jmp    8004c2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800619:	85 ff                	test   %edi,%edi
  80061b:	b8 34 24 80 00       	mov    $0x802434,%eax
  800620:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800623:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800627:	0f 8e 94 00 00 00    	jle    8006c1 <vprintfmt+0x225>
  80062d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800631:	0f 84 98 00 00 00    	je     8006cf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	ff 75 d0             	pushl  -0x30(%ebp)
  80063d:	57                   	push   %edi
  80063e:	e8 86 02 00 00       	call   8008c9 <strnlen>
  800643:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800646:	29 c1                	sub    %eax,%ecx
  800648:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80064b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80064e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800652:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800655:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800658:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065a:	eb 0f                	jmp    80066b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	ff 75 e0             	pushl  -0x20(%ebp)
  800663:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800665:	83 ef 01             	sub    $0x1,%edi
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	85 ff                	test   %edi,%edi
  80066d:	7f ed                	jg     80065c <vprintfmt+0x1c0>
  80066f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800672:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800675:	85 c9                	test   %ecx,%ecx
  800677:	b8 00 00 00 00       	mov    $0x0,%eax
  80067c:	0f 49 c1             	cmovns %ecx,%eax
  80067f:	29 c1                	sub    %eax,%ecx
  800681:	89 75 08             	mov    %esi,0x8(%ebp)
  800684:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800687:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068a:	89 cb                	mov    %ecx,%ebx
  80068c:	eb 4d                	jmp    8006db <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80068e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800692:	74 1b                	je     8006af <vprintfmt+0x213>
  800694:	0f be c0             	movsbl %al,%eax
  800697:	83 e8 20             	sub    $0x20,%eax
  80069a:	83 f8 5e             	cmp    $0x5e,%eax
  80069d:	76 10                	jbe    8006af <vprintfmt+0x213>
					putch('?', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	ff 75 0c             	pushl  0xc(%ebp)
  8006a5:	6a 3f                	push   $0x3f
  8006a7:	ff 55 08             	call   *0x8(%ebp)
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	eb 0d                	jmp    8006bc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	52                   	push   %edx
  8006b6:	ff 55 08             	call   *0x8(%ebp)
  8006b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006bc:	83 eb 01             	sub    $0x1,%ebx
  8006bf:	eb 1a                	jmp    8006db <vprintfmt+0x23f>
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006cd:	eb 0c                	jmp    8006db <vprintfmt+0x23f>
  8006cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006db:	83 c7 01             	add    $0x1,%edi
  8006de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e2:	0f be d0             	movsbl %al,%edx
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 23                	je     80070c <vprintfmt+0x270>
  8006e9:	85 f6                	test   %esi,%esi
  8006eb:	78 a1                	js     80068e <vprintfmt+0x1f2>
  8006ed:	83 ee 01             	sub    $0x1,%esi
  8006f0:	79 9c                	jns    80068e <vprintfmt+0x1f2>
  8006f2:	89 df                	mov    %ebx,%edi
  8006f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fa:	eb 18                	jmp    800714 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 20                	push   $0x20
  800702:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800704:	83 ef 01             	sub    $0x1,%edi
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	eb 08                	jmp    800714 <vprintfmt+0x278>
  80070c:	89 df                	mov    %ebx,%edi
  80070e:	8b 75 08             	mov    0x8(%ebp),%esi
  800711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800714:	85 ff                	test   %edi,%edi
  800716:	7f e4                	jg     8006fc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800718:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071b:	e9 a2 fd ff ff       	jmp    8004c2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800720:	83 fa 01             	cmp    $0x1,%edx
  800723:	7e 16                	jle    80073b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8d 50 08             	lea    0x8(%eax),%edx
  80072b:	89 55 14             	mov    %edx,0x14(%ebp)
  80072e:	8b 50 04             	mov    0x4(%eax),%edx
  800731:	8b 00                	mov    (%eax),%eax
  800733:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800736:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800739:	eb 32                	jmp    80076d <vprintfmt+0x2d1>
	else if (lflag)
  80073b:	85 d2                	test   %edx,%edx
  80073d:	74 18                	je     800757 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8d 50 04             	lea    0x4(%eax),%edx
  800745:	89 55 14             	mov    %edx,0x14(%ebp)
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074d:	89 c1                	mov    %eax,%ecx
  80074f:	c1 f9 1f             	sar    $0x1f,%ecx
  800752:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800755:	eb 16                	jmp    80076d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800765:	89 c1                	mov    %eax,%ecx
  800767:	c1 f9 1f             	sar    $0x1f,%ecx
  80076a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80076d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800770:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800773:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800778:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80077c:	79 74                	jns    8007f2 <vprintfmt+0x356>
				putch('-', putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	53                   	push   %ebx
  800782:	6a 2d                	push   $0x2d
  800784:	ff d6                	call   *%esi
				num = -(long long) num;
  800786:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800789:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80078c:	f7 d8                	neg    %eax
  80078e:	83 d2 00             	adc    $0x0,%edx
  800791:	f7 da                	neg    %edx
  800793:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800796:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80079b:	eb 55                	jmp    8007f2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	e8 83 fc ff ff       	call   800428 <getuint>
			base = 10;
  8007a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007aa:	eb 46                	jmp    8007f2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8007af:	e8 74 fc ff ff       	call   800428 <getuint>
			base = 8;
  8007b4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007b9:	eb 37                	jmp    8007f2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	53                   	push   %ebx
  8007bf:	6a 30                	push   $0x30
  8007c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8007c3:	83 c4 08             	add    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 78                	push   $0x78
  8007c9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 04             	lea    0x4(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007db:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007e3:	eb 0d                	jmp    8007f2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e8:	e8 3b fc ff ff       	call   800428 <getuint>
			base = 16;
  8007ed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f2:	83 ec 0c             	sub    $0xc,%esp
  8007f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007f9:	57                   	push   %edi
  8007fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fd:	51                   	push   %ecx
  8007fe:	52                   	push   %edx
  8007ff:	50                   	push   %eax
  800800:	89 da                	mov    %ebx,%edx
  800802:	89 f0                	mov    %esi,%eax
  800804:	e8 70 fb ff ff       	call   800379 <printnum>
			break;
  800809:	83 c4 20             	add    $0x20,%esp
  80080c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080f:	e9 ae fc ff ff       	jmp    8004c2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	51                   	push   %ecx
  800819:	ff d6                	call   *%esi
			break;
  80081b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800821:	e9 9c fc ff ff       	jmp    8004c2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	53                   	push   %ebx
  80082a:	6a 25                	push   $0x25
  80082c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 03                	jmp    800836 <vprintfmt+0x39a>
  800833:	83 ef 01             	sub    $0x1,%edi
  800836:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80083a:	75 f7                	jne    800833 <vprintfmt+0x397>
  80083c:	e9 81 fc ff ff       	jmp    8004c2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800841:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5f                   	pop    %edi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 18             	sub    $0x18,%esp
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800855:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800858:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800866:	85 c0                	test   %eax,%eax
  800868:	74 26                	je     800890 <vsnprintf+0x47>
  80086a:	85 d2                	test   %edx,%edx
  80086c:	7e 22                	jle    800890 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086e:	ff 75 14             	pushl  0x14(%ebp)
  800871:	ff 75 10             	pushl  0x10(%ebp)
  800874:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800877:	50                   	push   %eax
  800878:	68 62 04 80 00       	push   $0x800462
  80087d:	e8 1a fc ff ff       	call   80049c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800882:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800885:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	eb 05                	jmp    800895 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800890:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a0:	50                   	push   %eax
  8008a1:	ff 75 10             	pushl  0x10(%ebp)
  8008a4:	ff 75 0c             	pushl  0xc(%ebp)
  8008a7:	ff 75 08             	pushl  0x8(%ebp)
  8008aa:	e8 9a ff ff ff       	call   800849 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	eb 03                	jmp    8008c1 <strlen+0x10>
		n++;
  8008be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c5:	75 f7                	jne    8008be <strlen+0xd>
		n++;
	return n;
}
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d7:	eb 03                	jmp    8008dc <strnlen+0x13>
		n++;
  8008d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	39 c2                	cmp    %eax,%edx
  8008de:	74 08                	je     8008e8 <strnlen+0x1f>
  8008e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008e4:	75 f3                	jne    8008d9 <strnlen+0x10>
  8008e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f4:	89 c2                	mov    %eax,%edx
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	83 c1 01             	add    $0x1,%ecx
  8008fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800900:	88 5a ff             	mov    %bl,-0x1(%edx)
  800903:	84 db                	test   %bl,%bl
  800905:	75 ef                	jne    8008f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800911:	53                   	push   %ebx
  800912:	e8 9a ff ff ff       	call   8008b1 <strlen>
  800917:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80091a:	ff 75 0c             	pushl  0xc(%ebp)
  80091d:	01 d8                	add    %ebx,%eax
  80091f:	50                   	push   %eax
  800920:	e8 c5 ff ff ff       	call   8008ea <strcpy>
	return dst;
}
  800925:	89 d8                	mov    %ebx,%eax
  800927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 75 08             	mov    0x8(%ebp),%esi
  800934:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800937:	89 f3                	mov    %esi,%ebx
  800939:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093c:	89 f2                	mov    %esi,%edx
  80093e:	eb 0f                	jmp    80094f <strncpy+0x23>
		*dst++ = *src;
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	0f b6 01             	movzbl (%ecx),%eax
  800946:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800949:	80 39 01             	cmpb   $0x1,(%ecx)
  80094c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094f:	39 da                	cmp    %ebx,%edx
  800951:	75 ed                	jne    800940 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800953:	89 f0                	mov    %esi,%eax
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 75 08             	mov    0x8(%ebp),%esi
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800964:	8b 55 10             	mov    0x10(%ebp),%edx
  800967:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800969:	85 d2                	test   %edx,%edx
  80096b:	74 21                	je     80098e <strlcpy+0x35>
  80096d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800971:	89 f2                	mov    %esi,%edx
  800973:	eb 09                	jmp    80097e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	83 c1 01             	add    $0x1,%ecx
  80097b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80097e:	39 c2                	cmp    %eax,%edx
  800980:	74 09                	je     80098b <strlcpy+0x32>
  800982:	0f b6 19             	movzbl (%ecx),%ebx
  800985:	84 db                	test   %bl,%bl
  800987:	75 ec                	jne    800975 <strlcpy+0x1c>
  800989:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80098b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098e:	29 f0                	sub    %esi,%eax
}
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099d:	eb 06                	jmp    8009a5 <strcmp+0x11>
		p++, q++;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a5:	0f b6 01             	movzbl (%ecx),%eax
  8009a8:	84 c0                	test   %al,%al
  8009aa:	74 04                	je     8009b0 <strcmp+0x1c>
  8009ac:	3a 02                	cmp    (%edx),%al
  8009ae:	74 ef                	je     80099f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b0:	0f b6 c0             	movzbl %al,%eax
  8009b3:	0f b6 12             	movzbl (%edx),%edx
  8009b6:	29 d0                	sub    %edx,%eax
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c3                	mov    %eax,%ebx
  8009c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c9:	eb 06                	jmp    8009d1 <strncmp+0x17>
		n--, p++, q++;
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d1:	39 d8                	cmp    %ebx,%eax
  8009d3:	74 15                	je     8009ea <strncmp+0x30>
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	84 c9                	test   %cl,%cl
  8009da:	74 04                	je     8009e0 <strncmp+0x26>
  8009dc:	3a 0a                	cmp    (%edx),%cl
  8009de:	74 eb                	je     8009cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e0:	0f b6 00             	movzbl (%eax),%eax
  8009e3:	0f b6 12             	movzbl (%edx),%edx
  8009e6:	29 d0                	sub    %edx,%eax
  8009e8:	eb 05                	jmp    8009ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fc:	eb 07                	jmp    800a05 <strchr+0x13>
		if (*s == c)
  8009fe:	38 ca                	cmp    %cl,%dl
  800a00:	74 0f                	je     800a11 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	75 f2                	jne    8009fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1d:	eb 03                	jmp    800a22 <strfind+0xf>
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a25:	38 ca                	cmp    %cl,%dl
  800a27:	74 04                	je     800a2d <strfind+0x1a>
  800a29:	84 d2                	test   %dl,%dl
  800a2b:	75 f2                	jne    800a1f <strfind+0xc>
			break;
	return (char *) s;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3b:	85 c9                	test   %ecx,%ecx
  800a3d:	74 36                	je     800a75 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a45:	75 28                	jne    800a6f <memset+0x40>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 23                	jne    800a6f <memset+0x40>
		c &= 0xFF;
  800a4c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a50:	89 d3                	mov    %edx,%ebx
  800a52:	c1 e3 08             	shl    $0x8,%ebx
  800a55:	89 d6                	mov    %edx,%esi
  800a57:	c1 e6 18             	shl    $0x18,%esi
  800a5a:	89 d0                	mov    %edx,%eax
  800a5c:	c1 e0 10             	shl    $0x10,%eax
  800a5f:	09 f0                	or     %esi,%eax
  800a61:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a63:	89 d8                	mov    %ebx,%eax
  800a65:	09 d0                	or     %edx,%eax
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	fc                   	cld    
  800a6b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6d:	eb 06                	jmp    800a75 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a72:	fc                   	cld    
  800a73:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a75:	89 f8                	mov    %edi,%eax
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8a:	39 c6                	cmp    %eax,%esi
  800a8c:	73 35                	jae    800ac3 <memmove+0x47>
  800a8e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a91:	39 d0                	cmp    %edx,%eax
  800a93:	73 2e                	jae    800ac3 <memmove+0x47>
		s += n;
		d += n;
  800a95:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	09 fe                	or     %edi,%esi
  800a9c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa2:	75 13                	jne    800ab7 <memmove+0x3b>
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 0e                	jne    800ab7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aa9:	83 ef 04             	sub    $0x4,%edi
  800aac:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aaf:	c1 e9 02             	shr    $0x2,%ecx
  800ab2:	fd                   	std    
  800ab3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab5:	eb 09                	jmp    800ac0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab7:	83 ef 01             	sub    $0x1,%edi
  800aba:	8d 72 ff             	lea    -0x1(%edx),%esi
  800abd:	fd                   	std    
  800abe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac0:	fc                   	cld    
  800ac1:	eb 1d                	jmp    800ae0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac3:	89 f2                	mov    %esi,%edx
  800ac5:	09 c2                	or     %eax,%edx
  800ac7:	f6 c2 03             	test   $0x3,%dl
  800aca:	75 0f                	jne    800adb <memmove+0x5f>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0a                	jne    800adb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ad1:	c1 e9 02             	shr    $0x2,%ecx
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad9:	eb 05                	jmp    800ae0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800adb:	89 c7                	mov    %eax,%edi
  800add:	fc                   	cld    
  800ade:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae7:	ff 75 10             	pushl  0x10(%ebp)
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	ff 75 08             	pushl  0x8(%ebp)
  800af0:	e8 87 ff ff ff       	call   800a7c <memmove>
}
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	89 c6                	mov    %eax,%esi
  800b04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b07:	eb 1a                	jmp    800b23 <memcmp+0x2c>
		if (*s1 != *s2)
  800b09:	0f b6 08             	movzbl (%eax),%ecx
  800b0c:	0f b6 1a             	movzbl (%edx),%ebx
  800b0f:	38 d9                	cmp    %bl,%cl
  800b11:	74 0a                	je     800b1d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b13:	0f b6 c1             	movzbl %cl,%eax
  800b16:	0f b6 db             	movzbl %bl,%ebx
  800b19:	29 d8                	sub    %ebx,%eax
  800b1b:	eb 0f                	jmp    800b2c <memcmp+0x35>
		s1++, s2++;
  800b1d:	83 c0 01             	add    $0x1,%eax
  800b20:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	39 f0                	cmp    %esi,%eax
  800b25:	75 e2                	jne    800b09 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	53                   	push   %ebx
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b37:	89 c1                	mov    %eax,%ecx
  800b39:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b40:	eb 0a                	jmp    800b4c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b42:	0f b6 10             	movzbl (%eax),%edx
  800b45:	39 da                	cmp    %ebx,%edx
  800b47:	74 07                	je     800b50 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	39 c8                	cmp    %ecx,%eax
  800b4e:	72 f2                	jb     800b42 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5f:	eb 03                	jmp    800b64 <strtol+0x11>
		s++;
  800b61:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b64:	0f b6 01             	movzbl (%ecx),%eax
  800b67:	3c 20                	cmp    $0x20,%al
  800b69:	74 f6                	je     800b61 <strtol+0xe>
  800b6b:	3c 09                	cmp    $0x9,%al
  800b6d:	74 f2                	je     800b61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b6f:	3c 2b                	cmp    $0x2b,%al
  800b71:	75 0a                	jne    800b7d <strtol+0x2a>
		s++;
  800b73:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b76:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7b:	eb 11                	jmp    800b8e <strtol+0x3b>
  800b7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b82:	3c 2d                	cmp    $0x2d,%al
  800b84:	75 08                	jne    800b8e <strtol+0x3b>
		s++, neg = 1;
  800b86:	83 c1 01             	add    $0x1,%ecx
  800b89:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b94:	75 15                	jne    800bab <strtol+0x58>
  800b96:	80 39 30             	cmpb   $0x30,(%ecx)
  800b99:	75 10                	jne    800bab <strtol+0x58>
  800b9b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b9f:	75 7c                	jne    800c1d <strtol+0xca>
		s += 2, base = 16;
  800ba1:	83 c1 02             	add    $0x2,%ecx
  800ba4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba9:	eb 16                	jmp    800bc1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bab:	85 db                	test   %ebx,%ebx
  800bad:	75 12                	jne    800bc1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800baf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb7:	75 08                	jne    800bc1 <strtol+0x6e>
		s++, base = 8;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc9:	0f b6 11             	movzbl (%ecx),%edx
  800bcc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bcf:	89 f3                	mov    %esi,%ebx
  800bd1:	80 fb 09             	cmp    $0x9,%bl
  800bd4:	77 08                	ja     800bde <strtol+0x8b>
			dig = *s - '0';
  800bd6:	0f be d2             	movsbl %dl,%edx
  800bd9:	83 ea 30             	sub    $0x30,%edx
  800bdc:	eb 22                	jmp    800c00 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bde:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be1:	89 f3                	mov    %esi,%ebx
  800be3:	80 fb 19             	cmp    $0x19,%bl
  800be6:	77 08                	ja     800bf0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800be8:	0f be d2             	movsbl %dl,%edx
  800beb:	83 ea 57             	sub    $0x57,%edx
  800bee:	eb 10                	jmp    800c00 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf3:	89 f3                	mov    %esi,%ebx
  800bf5:	80 fb 19             	cmp    $0x19,%bl
  800bf8:	77 16                	ja     800c10 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bfa:	0f be d2             	movsbl %dl,%edx
  800bfd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c00:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c03:	7d 0b                	jge    800c10 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c05:	83 c1 01             	add    $0x1,%ecx
  800c08:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c0c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c0e:	eb b9                	jmp    800bc9 <strtol+0x76>

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 0d                	je     800c23 <strtol+0xd0>
		*endptr = (char *) s;
  800c16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c19:	89 0e                	mov    %ecx,(%esi)
  800c1b:	eb 06                	jmp    800c23 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c1d:	85 db                	test   %ebx,%ebx
  800c1f:	74 98                	je     800bb9 <strtol+0x66>
  800c21:	eb 9e                	jmp    800bc1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c23:	89 c2                	mov    %eax,%edx
  800c25:	f7 da                	neg    %edx
  800c27:	85 ff                	test   %edi,%edi
  800c29:	0f 45 c2             	cmovne %edx,%eax
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 c3                	mov    %eax,%ebx
  800c44:	89 c7                	mov    %eax,%edi
  800c46:	89 c6                	mov    %eax,%esi
  800c48:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 cb                	mov    %ecx,%ebx
  800c86:	89 cf                	mov    %ecx,%edi
  800c88:	89 ce                	mov    %ecx,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 03                	push   $0x3
  800c96:	68 1f 27 80 00       	push   $0x80271f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 3c 27 80 00       	push   $0x80273c
  800ca2:	e8 e5 f5 ff ff       	call   80028c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cba:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	89 d3                	mov    %edx,%ebx
  800cc3:	89 d7                	mov    %edx,%edi
  800cc5:	89 d6                	mov    %edx,%esi
  800cc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_yield>:

void
sys_yield(void)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cde:	89 d1                	mov    %edx,%ecx
  800ce0:	89 d3                	mov    %edx,%ebx
  800ce2:	89 d7                	mov    %edx,%edi
  800ce4:	89 d6                	mov    %edx,%esi
  800ce6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	be 00 00 00 00       	mov    $0x0,%esi
  800cfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d09:	89 f7                	mov    %esi,%edi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 04                	push   $0x4
  800d17:	68 1f 27 80 00       	push   $0x80271f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 3c 27 80 00       	push   $0x80273c
  800d23:	e8 64 f5 ff ff       	call   80028c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	b8 05 00 00 00       	mov    $0x5,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 05                	push   $0x5
  800d59:	68 1f 27 80 00       	push   $0x80271f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 3c 27 80 00       	push   $0x80273c
  800d65:	e8 22 f5 ff ff       	call   80028c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d80:	b8 06 00 00 00       	mov    $0x6,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 df                	mov    %ebx,%edi
  800d8d:	89 de                	mov    %ebx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 06                	push   $0x6
  800d9b:	68 1f 27 80 00       	push   $0x80271f
  800da0:	6a 23                	push   $0x23
  800da2:	68 3c 27 80 00       	push   $0x80273c
  800da7:	e8 e0 f4 ff ff       	call   80028c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 17                	jle    800dee <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 08                	push   $0x8
  800ddd:	68 1f 27 80 00       	push   $0x80271f
  800de2:	6a 23                	push   $0x23
  800de4:	68 3c 27 80 00       	push   $0x80273c
  800de9:	e8 9e f4 ff ff       	call   80028c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e04:	b8 09 00 00 00       	mov    $0x9,%eax
  800e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 df                	mov    %ebx,%edi
  800e11:	89 de                	mov    %ebx,%esi
  800e13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 17                	jle    800e30 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	50                   	push   %eax
  800e1d:	6a 09                	push   $0x9
  800e1f:	68 1f 27 80 00       	push   $0x80271f
  800e24:	6a 23                	push   $0x23
  800e26:	68 3c 27 80 00       	push   $0x80273c
  800e2b:	e8 5c f4 ff ff       	call   80028c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e51:	89 df                	mov    %ebx,%edi
  800e53:	89 de                	mov    %ebx,%esi
  800e55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e57:	85 c0                	test   %eax,%eax
  800e59:	7e 17                	jle    800e72 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	50                   	push   %eax
  800e5f:	6a 0a                	push   $0xa
  800e61:	68 1f 27 80 00       	push   $0x80271f
  800e66:	6a 23                	push   $0x23
  800e68:	68 3c 27 80 00       	push   $0x80273c
  800e6d:	e8 1a f4 ff ff       	call   80028c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	be 00 00 00 00       	mov    $0x0,%esi
  800e85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e96:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eab:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 cb                	mov    %ecx,%ebx
  800eb5:	89 cf                	mov    %ecx,%edi
  800eb7:	89 ce                	mov    %ecx,%esi
  800eb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	7e 17                	jle    800ed6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	50                   	push   %eax
  800ec3:	6a 0d                	push   $0xd
  800ec5:	68 1f 27 80 00       	push   $0x80271f
  800eca:	6a 23                	push   $0x23
  800ecc:	68 3c 27 80 00       	push   $0x80273c
  800ed1:	e8 b6 f3 ff ff       	call   80028c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ee8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800eea:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eee:	74 11                	je     800f01 <pgfault+0x23>
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	c1 e8 0c             	shr    $0xc,%eax
  800ef5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800efc:	f6 c4 08             	test   $0x8,%ah
  800eff:	75 14                	jne    800f15 <pgfault+0x37>
		panic("faulting access");
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	68 4a 27 80 00       	push   $0x80274a
  800f09:	6a 1d                	push   $0x1d
  800f0b:	68 5a 27 80 00       	push   $0x80275a
  800f10:	e8 77 f3 ff ff       	call   80028c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	6a 07                	push   $0x7
  800f1a:	68 00 f0 7f 00       	push   $0x7ff000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 c7 fd ff ff       	call   800ced <sys_page_alloc>
	if (r < 0) {
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 12                	jns    800f3f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 65 27 80 00       	push   $0x802765
  800f33:	6a 2b                	push   $0x2b
  800f35:	68 5a 27 80 00       	push   $0x80275a
  800f3a:	e8 4d f3 ff ff       	call   80028c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f3f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	68 00 10 00 00       	push   $0x1000
  800f4d:	53                   	push   %ebx
  800f4e:	68 00 f0 7f 00       	push   $0x7ff000
  800f53:	e8 8c fb ff ff       	call   800ae4 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f58:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5f:	53                   	push   %ebx
  800f60:	6a 00                	push   $0x0
  800f62:	68 00 f0 7f 00       	push   $0x7ff000
  800f67:	6a 00                	push   $0x0
  800f69:	e8 c2 fd ff ff       	call   800d30 <sys_page_map>
	if (r < 0) {
  800f6e:	83 c4 20             	add    $0x20,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	79 12                	jns    800f87 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f75:	50                   	push   %eax
  800f76:	68 65 27 80 00       	push   $0x802765
  800f7b:	6a 32                	push   $0x32
  800f7d:	68 5a 27 80 00       	push   $0x80275a
  800f82:	e8 05 f3 ff ff       	call   80028c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	68 00 f0 7f 00       	push   $0x7ff000
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 dc fd ff ff       	call   800d72 <sys_page_unmap>
	if (r < 0) {
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 12                	jns    800faf <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f9d:	50                   	push   %eax
  800f9e:	68 65 27 80 00       	push   $0x802765
  800fa3:	6a 36                	push   $0x36
  800fa5:	68 5a 27 80 00       	push   $0x80275a
  800faa:	e8 dd f2 ff ff       	call   80028c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fbd:	68 de 0e 80 00       	push   $0x800ede
  800fc2:	e8 06 10 00 00       	call   801fcd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fc7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcc:	cd 30                	int    $0x30
  800fce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	79 17                	jns    800fef <fork+0x3b>
		panic("fork fault %e");
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	68 7e 27 80 00       	push   $0x80277e
  800fe0:	68 83 00 00 00       	push   $0x83
  800fe5:	68 5a 27 80 00       	push   $0x80275a
  800fea:	e8 9d f2 ff ff       	call   80028c <_panic>
  800fef:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ff1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ff5:	75 21                	jne    801018 <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff7:	e8 b3 fc ff ff       	call   800caf <sys_getenvid>
  800ffc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801001:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801004:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801009:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80100e:	b8 00 00 00 00       	mov    $0x0,%eax
  801013:	e9 61 01 00 00       	jmp    801179 <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	6a 07                	push   $0x7
  80101d:	68 00 f0 bf ee       	push   $0xeebff000
  801022:	ff 75 e4             	pushl  -0x1c(%ebp)
  801025:	e8 c3 fc ff ff       	call   800ced <sys_page_alloc>
  80102a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801032:	89 d8                	mov    %ebx,%eax
  801034:	c1 e8 16             	shr    $0x16,%eax
  801037:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103e:	a8 01                	test   $0x1,%al
  801040:	0f 84 fc 00 00 00    	je     801142 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801046:	89 d8                	mov    %ebx,%eax
  801048:	c1 e8 0c             	shr    $0xc,%eax
  80104b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801052:	f6 c2 01             	test   $0x1,%dl
  801055:	0f 84 e7 00 00 00    	je     801142 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80105b:	89 c6                	mov    %eax,%esi
  80105d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801060:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801067:	f6 c6 04             	test   $0x4,%dh
  80106a:	74 39                	je     8010a5 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80106c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	25 07 0e 00 00       	and    $0xe07,%eax
  80107b:	50                   	push   %eax
  80107c:	56                   	push   %esi
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	6a 00                	push   $0x0
  801081:	e8 aa fc ff ff       	call   800d30 <sys_page_map>
		if (r < 0) {
  801086:	83 c4 20             	add    $0x20,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	0f 89 b1 00 00 00    	jns    801142 <fork+0x18e>
		    	panic("sys page map fault %e");
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	68 8c 27 80 00       	push   $0x80278c
  801099:	6a 53                	push   $0x53
  80109b:	68 5a 27 80 00       	push   $0x80275a
  8010a0:	e8 e7 f1 ff ff       	call   80028c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ac:	f6 c2 02             	test   $0x2,%dl
  8010af:	75 0c                	jne    8010bd <fork+0x109>
  8010b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b8:	f6 c4 08             	test   $0x8,%ah
  8010bb:	74 5b                	je     801118 <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	68 05 08 00 00       	push   $0x805
  8010c5:	56                   	push   %esi
  8010c6:	57                   	push   %edi
  8010c7:	56                   	push   %esi
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 61 fc ff ff       	call   800d30 <sys_page_map>
		if (r < 0) {
  8010cf:	83 c4 20             	add    $0x20,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	79 14                	jns    8010ea <fork+0x136>
		    	panic("sys page map fault %e");
  8010d6:	83 ec 04             	sub    $0x4,%esp
  8010d9:	68 8c 27 80 00       	push   $0x80278c
  8010de:	6a 5a                	push   $0x5a
  8010e0:	68 5a 27 80 00       	push   $0x80275a
  8010e5:	e8 a2 f1 ff ff       	call   80028c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	68 05 08 00 00       	push   $0x805
  8010f2:	56                   	push   %esi
  8010f3:	6a 00                	push   $0x0
  8010f5:	56                   	push   %esi
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 33 fc ff ff       	call   800d30 <sys_page_map>
		if (r < 0) {
  8010fd:	83 c4 20             	add    $0x20,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	79 3e                	jns    801142 <fork+0x18e>
		    	panic("sys page map fault %e");
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	68 8c 27 80 00       	push   $0x80278c
  80110c:	6a 5e                	push   $0x5e
  80110e:	68 5a 27 80 00       	push   $0x80275a
  801113:	e8 74 f1 ff ff       	call   80028c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	6a 05                	push   $0x5
  80111d:	56                   	push   %esi
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	6a 00                	push   $0x0
  801122:	e8 09 fc ff ff       	call   800d30 <sys_page_map>
		if (r < 0) {
  801127:	83 c4 20             	add    $0x20,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	79 14                	jns    801142 <fork+0x18e>
		    	panic("sys page map fault %e");
  80112e:	83 ec 04             	sub    $0x4,%esp
  801131:	68 8c 27 80 00       	push   $0x80278c
  801136:	6a 63                	push   $0x63
  801138:	68 5a 27 80 00       	push   $0x80275a
  80113d:	e8 4a f1 ff ff       	call   80028c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801142:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801148:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80114e:	0f 85 de fe ff ff    	jne    801032 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801154:	a1 04 40 80 00       	mov    0x804004,%eax
  801159:	8b 40 64             	mov    0x64(%eax),%eax
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	50                   	push   %eax
  801160:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801163:	57                   	push   %edi
  801164:	e8 cf fc ff ff       	call   800e38 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801169:	83 c4 08             	add    $0x8,%esp
  80116c:	6a 02                	push   $0x2
  80116e:	57                   	push   %edi
  80116f:	e8 40 fc ff ff       	call   800db4 <sys_env_set_status>
	
	return envid;
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <sfork>:

// Challenge!
int
sfork(void)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801187:	68 a2 27 80 00       	push   $0x8027a2
  80118c:	68 a1 00 00 00       	push   $0xa1
  801191:	68 5a 27 80 00       	push   $0x80275a
  801196:	e8 f1 f0 ff ff       	call   80028c <_panic>

0080119b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	75 12                	jne    8011bf <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8011ad:	83 ec 0c             	sub    $0xc,%esp
  8011b0:	68 00 00 c0 ee       	push   $0xeec00000
  8011b5:	e8 e3 fc ff ff       	call   800e9d <sys_ipc_recv>
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	eb 0c                	jmp    8011cb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8011bf:	83 ec 0c             	sub    $0xc,%esp
  8011c2:	50                   	push   %eax
  8011c3:	e8 d5 fc ff ff       	call   800e9d <sys_ipc_recv>
  8011c8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8011cb:	85 f6                	test   %esi,%esi
  8011cd:	0f 95 c1             	setne  %cl
  8011d0:	85 db                	test   %ebx,%ebx
  8011d2:	0f 95 c2             	setne  %dl
  8011d5:	84 d1                	test   %dl,%cl
  8011d7:	74 09                	je     8011e2 <ipc_recv+0x47>
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	c1 ea 1f             	shr    $0x1f,%edx
  8011de:	84 d2                	test   %dl,%dl
  8011e0:	75 24                	jne    801206 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8011e2:	85 f6                	test   %esi,%esi
  8011e4:	74 0a                	je     8011f0 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8011e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011eb:	8b 40 74             	mov    0x74(%eax),%eax
  8011ee:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8011f0:	85 db                	test   %ebx,%ebx
  8011f2:	74 0a                	je     8011fe <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  8011f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f9:	8b 40 78             	mov    0x78(%eax),%eax
  8011fc:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801203:	8b 40 70             	mov    0x70(%eax),%eax
}
  801206:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801209:	5b                   	pop    %ebx
  80120a:	5e                   	pop    %esi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	8b 7d 08             	mov    0x8(%ebp),%edi
  801219:	8b 75 0c             	mov    0xc(%ebp),%esi
  80121c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80121f:	85 db                	test   %ebx,%ebx
  801221:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801226:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801229:	ff 75 14             	pushl  0x14(%ebp)
  80122c:	53                   	push   %ebx
  80122d:	56                   	push   %esi
  80122e:	57                   	push   %edi
  80122f:	e8 46 fc ff ff       	call   800e7a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801234:	89 c2                	mov    %eax,%edx
  801236:	c1 ea 1f             	shr    $0x1f,%edx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	84 d2                	test   %dl,%dl
  80123e:	74 17                	je     801257 <ipc_send+0x4a>
  801240:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801243:	74 12                	je     801257 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801245:	50                   	push   %eax
  801246:	68 b8 27 80 00       	push   $0x8027b8
  80124b:	6a 47                	push   $0x47
  80124d:	68 c6 27 80 00       	push   $0x8027c6
  801252:	e8 35 f0 ff ff       	call   80028c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801257:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80125a:	75 07                	jne    801263 <ipc_send+0x56>
			sys_yield();
  80125c:	e8 6d fa ff ff       	call   800cce <sys_yield>
  801261:	eb c6                	jmp    801229 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801263:	85 c0                	test   %eax,%eax
  801265:	75 c2                	jne    801229 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80127a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80127d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801283:	8b 52 50             	mov    0x50(%edx),%edx
  801286:	39 ca                	cmp    %ecx,%edx
  801288:	75 0d                	jne    801297 <ipc_find_env+0x28>
			return envs[i].env_id;
  80128a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80128d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801292:	8b 40 48             	mov    0x48(%eax),%eax
  801295:	eb 0f                	jmp    8012a6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801297:	83 c0 01             	add    $0x1,%eax
  80129a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80129f:	75 d9                	jne    80127a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8012b3:	c1 e8 0c             	shr    $0xc,%eax
}
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012be:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012c8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 16             	shr    $0x16,%edx
  8012df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	74 11                	je     8012fc <fd_alloc+0x2d>
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	c1 ea 0c             	shr    $0xc,%edx
  8012f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f7:	f6 c2 01             	test   $0x1,%dl
  8012fa:	75 09                	jne    801305 <fd_alloc+0x36>
			*fd_store = fd;
  8012fc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	eb 17                	jmp    80131c <fd_alloc+0x4d>
  801305:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80130a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130f:	75 c9                	jne    8012da <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801311:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801317:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801324:	83 f8 1f             	cmp    $0x1f,%eax
  801327:	77 36                	ja     80135f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801329:	c1 e0 0c             	shl    $0xc,%eax
  80132c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 16             	shr    $0x16,%edx
  801336:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	74 24                	je     801366 <fd_lookup+0x48>
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 0c             	shr    $0xc,%edx
  801347:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	74 1a                	je     80136d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801353:	8b 55 0c             	mov    0xc(%ebp),%edx
  801356:	89 02                	mov    %eax,(%edx)
	return 0;
  801358:	b8 00 00 00 00       	mov    $0x0,%eax
  80135d:	eb 13                	jmp    801372 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801364:	eb 0c                	jmp    801372 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801366:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136b:	eb 05                	jmp    801372 <fd_lookup+0x54>
  80136d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137d:	ba 50 28 80 00       	mov    $0x802850,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801382:	eb 13                	jmp    801397 <dev_lookup+0x23>
  801384:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801387:	39 08                	cmp    %ecx,(%eax)
  801389:	75 0c                	jne    801397 <dev_lookup+0x23>
			*dev = devtab[i];
  80138b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801390:	b8 00 00 00 00       	mov    $0x0,%eax
  801395:	eb 2e                	jmp    8013c5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801397:	8b 02                	mov    (%edx),%eax
  801399:	85 c0                	test   %eax,%eax
  80139b:	75 e7                	jne    801384 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80139d:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a2:	8b 40 48             	mov    0x48(%eax),%eax
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	51                   	push   %ecx
  8013a9:	50                   	push   %eax
  8013aa:	68 d0 27 80 00       	push   $0x8027d0
  8013af:	e8 b1 ef ff ff       	call   800365 <cprintf>
	*dev = 0;
  8013b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 10             	sub    $0x10,%esp
  8013cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013df:	c1 e8 0c             	shr    $0xc,%eax
  8013e2:	50                   	push   %eax
  8013e3:	e8 36 ff ff ff       	call   80131e <fd_lookup>
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 05                	js     8013f4 <fd_close+0x2d>
	    || fd != fd2)
  8013ef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f2:	74 0c                	je     801400 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013f4:	84 db                	test   %bl,%bl
  8013f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fb:	0f 44 c2             	cmove  %edx,%eax
  8013fe:	eb 41                	jmp    801441 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801406:	50                   	push   %eax
  801407:	ff 36                	pushl  (%esi)
  801409:	e8 66 ff ff ff       	call   801374 <dev_lookup>
  80140e:	89 c3                	mov    %eax,%ebx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 1a                	js     801431 <fd_close+0x6a>
		if (dev->dev_close)
  801417:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80141d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801422:	85 c0                	test   %eax,%eax
  801424:	74 0b                	je     801431 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	56                   	push   %esi
  80142a:	ff d0                	call   *%eax
  80142c:	89 c3                	mov    %eax,%ebx
  80142e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	56                   	push   %esi
  801435:	6a 00                	push   $0x0
  801437:	e8 36 f9 ff ff       	call   800d72 <sys_page_unmap>
	return r;
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	89 d8                	mov    %ebx,%eax
}
  801441:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	ff 75 08             	pushl  0x8(%ebp)
  801455:	e8 c4 fe ff ff       	call   80131e <fd_lookup>
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 10                	js     801471 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	6a 01                	push   $0x1
  801466:	ff 75 f4             	pushl  -0xc(%ebp)
  801469:	e8 59 ff ff ff       	call   8013c7 <fd_close>
  80146e:	83 c4 10             	add    $0x10,%esp
}
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <close_all>:

void
close_all(void)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80147a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80147f:	83 ec 0c             	sub    $0xc,%esp
  801482:	53                   	push   %ebx
  801483:	e8 c0 ff ff ff       	call   801448 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801488:	83 c3 01             	add    $0x1,%ebx
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	83 fb 20             	cmp    $0x20,%ebx
  801491:	75 ec                	jne    80147f <close_all+0xc>
		close(i);
}
  801493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	57                   	push   %edi
  80149c:	56                   	push   %esi
  80149d:	53                   	push   %ebx
  80149e:	83 ec 2c             	sub    $0x2c,%esp
  8014a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 75 08             	pushl  0x8(%ebp)
  8014ab:	e8 6e fe ff ff       	call   80131e <fd_lookup>
  8014b0:	83 c4 08             	add    $0x8,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	0f 88 c1 00 00 00    	js     80157c <dup+0xe4>
		return r;
	close(newfdnum);
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	56                   	push   %esi
  8014bf:	e8 84 ff ff ff       	call   801448 <close>

	newfd = INDEX2FD(newfdnum);
  8014c4:	89 f3                	mov    %esi,%ebx
  8014c6:	c1 e3 0c             	shl    $0xc,%ebx
  8014c9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014cf:	83 c4 04             	add    $0x4,%esp
  8014d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d5:	e8 de fd ff ff       	call   8012b8 <fd2data>
  8014da:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014dc:	89 1c 24             	mov    %ebx,(%esp)
  8014df:	e8 d4 fd ff ff       	call   8012b8 <fd2data>
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ea:	89 f8                	mov    %edi,%eax
  8014ec:	c1 e8 16             	shr    $0x16,%eax
  8014ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014f6:	a8 01                	test   $0x1,%al
  8014f8:	74 37                	je     801531 <dup+0x99>
  8014fa:	89 f8                	mov    %edi,%eax
  8014fc:	c1 e8 0c             	shr    $0xc,%eax
  8014ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801506:	f6 c2 01             	test   $0x1,%dl
  801509:	74 26                	je     801531 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80150b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	25 07 0e 00 00       	and    $0xe07,%eax
  80151a:	50                   	push   %eax
  80151b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151e:	6a 00                	push   $0x0
  801520:	57                   	push   %edi
  801521:	6a 00                	push   $0x0
  801523:	e8 08 f8 ff ff       	call   800d30 <sys_page_map>
  801528:	89 c7                	mov    %eax,%edi
  80152a:	83 c4 20             	add    $0x20,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 2e                	js     80155f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801531:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801534:	89 d0                	mov    %edx,%eax
  801536:	c1 e8 0c             	shr    $0xc,%eax
  801539:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	25 07 0e 00 00       	and    $0xe07,%eax
  801548:	50                   	push   %eax
  801549:	53                   	push   %ebx
  80154a:	6a 00                	push   $0x0
  80154c:	52                   	push   %edx
  80154d:	6a 00                	push   $0x0
  80154f:	e8 dc f7 ff ff       	call   800d30 <sys_page_map>
  801554:	89 c7                	mov    %eax,%edi
  801556:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801559:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80155b:	85 ff                	test   %edi,%edi
  80155d:	79 1d                	jns    80157c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	53                   	push   %ebx
  801563:	6a 00                	push   $0x0
  801565:	e8 08 f8 ff ff       	call   800d72 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801570:	6a 00                	push   $0x0
  801572:	e8 fb f7 ff ff       	call   800d72 <sys_page_unmap>
	return r;
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	89 f8                	mov    %edi,%eax
}
  80157c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5f                   	pop    %edi
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    

00801584 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 14             	sub    $0x14,%esp
  80158b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	53                   	push   %ebx
  801593:	e8 86 fd ff ff       	call   80131e <fd_lookup>
  801598:	83 c4 08             	add    $0x8,%esp
  80159b:	89 c2                	mov    %eax,%edx
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 6d                	js     80160e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ab:	ff 30                	pushl  (%eax)
  8015ad:	e8 c2 fd ff ff       	call   801374 <dev_lookup>
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 4c                	js     801605 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015bc:	8b 42 08             	mov    0x8(%edx),%eax
  8015bf:	83 e0 03             	and    $0x3,%eax
  8015c2:	83 f8 01             	cmp    $0x1,%eax
  8015c5:	75 21                	jne    8015e8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cc:	8b 40 48             	mov    0x48(%eax),%eax
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	50                   	push   %eax
  8015d4:	68 14 28 80 00       	push   $0x802814
  8015d9:	e8 87 ed ff ff       	call   800365 <cprintf>
		return -E_INVAL;
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e6:	eb 26                	jmp    80160e <read+0x8a>
	}
	if (!dev->dev_read)
  8015e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015eb:	8b 40 08             	mov    0x8(%eax),%eax
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	74 17                	je     801609 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	ff 75 10             	pushl  0x10(%ebp)
  8015f8:	ff 75 0c             	pushl  0xc(%ebp)
  8015fb:	52                   	push   %edx
  8015fc:	ff d0                	call   *%eax
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb 09                	jmp    80160e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	89 c2                	mov    %eax,%edx
  801607:	eb 05                	jmp    80160e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801609:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80160e:	89 d0                	mov    %edx,%eax
  801610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801613:	c9                   	leave  
  801614:	c3                   	ret    

00801615 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	57                   	push   %edi
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801621:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801624:	bb 00 00 00 00       	mov    $0x0,%ebx
  801629:	eb 21                	jmp    80164c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	89 f0                	mov    %esi,%eax
  801630:	29 d8                	sub    %ebx,%eax
  801632:	50                   	push   %eax
  801633:	89 d8                	mov    %ebx,%eax
  801635:	03 45 0c             	add    0xc(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	57                   	push   %edi
  80163a:	e8 45 ff ff ff       	call   801584 <read>
		if (m < 0)
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	85 c0                	test   %eax,%eax
  801644:	78 10                	js     801656 <readn+0x41>
			return m;
		if (m == 0)
  801646:	85 c0                	test   %eax,%eax
  801648:	74 0a                	je     801654 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164a:	01 c3                	add    %eax,%ebx
  80164c:	39 f3                	cmp    %esi,%ebx
  80164e:	72 db                	jb     80162b <readn+0x16>
  801650:	89 d8                	mov    %ebx,%eax
  801652:	eb 02                	jmp    801656 <readn+0x41>
  801654:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801656:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801659:	5b                   	pop    %ebx
  80165a:	5e                   	pop    %esi
  80165b:	5f                   	pop    %edi
  80165c:	5d                   	pop    %ebp
  80165d:	c3                   	ret    

0080165e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	53                   	push   %ebx
  801662:	83 ec 14             	sub    $0x14,%esp
  801665:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801668:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	53                   	push   %ebx
  80166d:	e8 ac fc ff ff       	call   80131e <fd_lookup>
  801672:	83 c4 08             	add    $0x8,%esp
  801675:	89 c2                	mov    %eax,%edx
  801677:	85 c0                	test   %eax,%eax
  801679:	78 68                	js     8016e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801685:	ff 30                	pushl  (%eax)
  801687:	e8 e8 fc ff ff       	call   801374 <dev_lookup>
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 47                	js     8016da <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801693:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801696:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169a:	75 21                	jne    8016bd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80169c:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a1:	8b 40 48             	mov    0x48(%eax),%eax
  8016a4:	83 ec 04             	sub    $0x4,%esp
  8016a7:	53                   	push   %ebx
  8016a8:	50                   	push   %eax
  8016a9:	68 30 28 80 00       	push   $0x802830
  8016ae:	e8 b2 ec ff ff       	call   800365 <cprintf>
		return -E_INVAL;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016bb:	eb 26                	jmp    8016e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8016c3:	85 d2                	test   %edx,%edx
  8016c5:	74 17                	je     8016de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016c7:	83 ec 04             	sub    $0x4,%esp
  8016ca:	ff 75 10             	pushl  0x10(%ebp)
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	50                   	push   %eax
  8016d1:	ff d2                	call   *%edx
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	eb 09                	jmp    8016e3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	eb 05                	jmp    8016e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016e3:	89 d0                	mov    %edx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	ff 75 08             	pushl  0x8(%ebp)
  8016f7:	e8 22 fc ff ff       	call   80131e <fd_lookup>
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 0e                	js     801711 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801703:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801706:	8b 55 0c             	mov    0xc(%ebp),%edx
  801709:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80170c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	53                   	push   %ebx
  801717:	83 ec 14             	sub    $0x14,%esp
  80171a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	53                   	push   %ebx
  801722:	e8 f7 fb ff ff       	call   80131e <fd_lookup>
  801727:	83 c4 08             	add    $0x8,%esp
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 65                	js     801795 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173a:	ff 30                	pushl  (%eax)
  80173c:	e8 33 fc ff ff       	call   801374 <dev_lookup>
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	85 c0                	test   %eax,%eax
  801746:	78 44                	js     80178c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80174f:	75 21                	jne    801772 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801751:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801756:	8b 40 48             	mov    0x48(%eax),%eax
  801759:	83 ec 04             	sub    $0x4,%esp
  80175c:	53                   	push   %ebx
  80175d:	50                   	push   %eax
  80175e:	68 f0 27 80 00       	push   $0x8027f0
  801763:	e8 fd eb ff ff       	call   800365 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801770:	eb 23                	jmp    801795 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801772:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801775:	8b 52 18             	mov    0x18(%edx),%edx
  801778:	85 d2                	test   %edx,%edx
  80177a:	74 14                	je     801790 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	50                   	push   %eax
  801783:	ff d2                	call   *%edx
  801785:	89 c2                	mov    %eax,%edx
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	eb 09                	jmp    801795 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	eb 05                	jmp    801795 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801790:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801795:	89 d0                	mov    %edx,%eax
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	53                   	push   %ebx
  8017a0:	83 ec 14             	sub    $0x14,%esp
  8017a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a9:	50                   	push   %eax
  8017aa:	ff 75 08             	pushl  0x8(%ebp)
  8017ad:	e8 6c fb ff ff       	call   80131e <fd_lookup>
  8017b2:	83 c4 08             	add    $0x8,%esp
  8017b5:	89 c2                	mov    %eax,%edx
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 58                	js     801813 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c1:	50                   	push   %eax
  8017c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c5:	ff 30                	pushl  (%eax)
  8017c7:	e8 a8 fb ff ff       	call   801374 <dev_lookup>
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	78 37                	js     80180a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017da:	74 32                	je     80180e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017e6:	00 00 00 
	stat->st_isdir = 0;
  8017e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017f0:	00 00 00 
	stat->st_dev = dev;
  8017f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	53                   	push   %ebx
  8017fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801800:	ff 50 14             	call   *0x14(%eax)
  801803:	89 c2                	mov    %eax,%edx
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	eb 09                	jmp    801813 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	eb 05                	jmp    801813 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80180e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801813:	89 d0                	mov    %edx,%eax
  801815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	56                   	push   %esi
  80181e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	6a 00                	push   $0x0
  801824:	ff 75 08             	pushl  0x8(%ebp)
  801827:	e8 e3 01 00 00       	call   801a0f <open>
  80182c:	89 c3                	mov    %eax,%ebx
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	78 1b                	js     801850 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	ff 75 0c             	pushl  0xc(%ebp)
  80183b:	50                   	push   %eax
  80183c:	e8 5b ff ff ff       	call   80179c <fstat>
  801841:	89 c6                	mov    %eax,%esi
	close(fd);
  801843:	89 1c 24             	mov    %ebx,(%esp)
  801846:	e8 fd fb ff ff       	call   801448 <close>
	return r;
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	89 f0                	mov    %esi,%eax
}
  801850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	89 c6                	mov    %eax,%esi
  80185e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801860:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801867:	75 12                	jne    80187b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	6a 01                	push   $0x1
  80186e:	e8 fc f9 ff ff       	call   80126f <ipc_find_env>
  801873:	a3 00 40 80 00       	mov    %eax,0x804000
  801878:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80187b:	6a 07                	push   $0x7
  80187d:	68 00 50 80 00       	push   $0x805000
  801882:	56                   	push   %esi
  801883:	ff 35 00 40 80 00    	pushl  0x804000
  801889:	e8 7f f9 ff ff       	call   80120d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80188e:	83 c4 0c             	add    $0xc,%esp
  801891:	6a 00                	push   $0x0
  801893:	53                   	push   %ebx
  801894:	6a 00                	push   $0x0
  801896:	e8 00 f9 ff ff       	call   80119b <ipc_recv>
}
  80189b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5e                   	pop    %esi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c5:	e8 8d ff ff ff       	call   801857 <fsipc>
}
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    

008018cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e7:	e8 6b ff ff ff       	call   801857 <fsipc>
}
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 04             	sub    $0x4,%esp
  8018f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801903:	ba 00 00 00 00       	mov    $0x0,%edx
  801908:	b8 05 00 00 00       	mov    $0x5,%eax
  80190d:	e8 45 ff ff ff       	call   801857 <fsipc>
  801912:	85 c0                	test   %eax,%eax
  801914:	78 2c                	js     801942 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	68 00 50 80 00       	push   $0x805000
  80191e:	53                   	push   %ebx
  80191f:	e8 c6 ef ff ff       	call   8008ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801924:	a1 80 50 80 00       	mov    0x805080,%eax
  801929:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80192f:	a1 84 50 80 00       	mov    0x805084,%eax
  801934:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801942:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801950:	8b 55 08             	mov    0x8(%ebp),%edx
  801953:	8b 52 0c             	mov    0xc(%edx),%edx
  801956:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80195c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801961:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801966:	0f 47 c2             	cmova  %edx,%eax
  801969:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80196e:	50                   	push   %eax
  80196f:	ff 75 0c             	pushl  0xc(%ebp)
  801972:	68 08 50 80 00       	push   $0x805008
  801977:	e8 00 f1 ff ff       	call   800a7c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80197c:	ba 00 00 00 00       	mov    $0x0,%edx
  801981:	b8 04 00 00 00       	mov    $0x4,%eax
  801986:	e8 cc fe ff ff       	call   801857 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801995:	8b 45 08             	mov    0x8(%ebp),%eax
  801998:	8b 40 0c             	mov    0xc(%eax),%eax
  80199b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019a0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b0:	e8 a2 fe ff ff       	call   801857 <fsipc>
  8019b5:	89 c3                	mov    %eax,%ebx
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	78 4b                	js     801a06 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019bb:	39 c6                	cmp    %eax,%esi
  8019bd:	73 16                	jae    8019d5 <devfile_read+0x48>
  8019bf:	68 60 28 80 00       	push   $0x802860
  8019c4:	68 67 28 80 00       	push   $0x802867
  8019c9:	6a 7c                	push   $0x7c
  8019cb:	68 7c 28 80 00       	push   $0x80287c
  8019d0:	e8 b7 e8 ff ff       	call   80028c <_panic>
	assert(r <= PGSIZE);
  8019d5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019da:	7e 16                	jle    8019f2 <devfile_read+0x65>
  8019dc:	68 87 28 80 00       	push   $0x802887
  8019e1:	68 67 28 80 00       	push   $0x802867
  8019e6:	6a 7d                	push   $0x7d
  8019e8:	68 7c 28 80 00       	push   $0x80287c
  8019ed:	e8 9a e8 ff ff       	call   80028c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	50                   	push   %eax
  8019f6:	68 00 50 80 00       	push   $0x805000
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	e8 79 f0 ff ff       	call   800a7c <memmove>
	return r;
  801a03:	83 c4 10             	add    $0x10,%esp
}
  801a06:	89 d8                	mov    %ebx,%eax
  801a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	53                   	push   %ebx
  801a13:	83 ec 20             	sub    $0x20,%esp
  801a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a19:	53                   	push   %ebx
  801a1a:	e8 92 ee ff ff       	call   8008b1 <strlen>
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a27:	7f 67                	jg     801a90 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2f:	50                   	push   %eax
  801a30:	e8 9a f8 ff ff       	call   8012cf <fd_alloc>
  801a35:	83 c4 10             	add    $0x10,%esp
		return r;
  801a38:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 57                	js     801a95 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a3e:	83 ec 08             	sub    $0x8,%esp
  801a41:	53                   	push   %ebx
  801a42:	68 00 50 80 00       	push   $0x805000
  801a47:	e8 9e ee ff ff       	call   8008ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a57:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5c:	e8 f6 fd ff ff       	call   801857 <fsipc>
  801a61:	89 c3                	mov    %eax,%ebx
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	79 14                	jns    801a7e <open+0x6f>
		fd_close(fd, 0);
  801a6a:	83 ec 08             	sub    $0x8,%esp
  801a6d:	6a 00                	push   $0x0
  801a6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a72:	e8 50 f9 ff ff       	call   8013c7 <fd_close>
		return r;
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	89 da                	mov    %ebx,%edx
  801a7c:	eb 17                	jmp    801a95 <open+0x86>
	}

	return fd2num(fd);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	ff 75 f4             	pushl  -0xc(%ebp)
  801a84:	e8 1f f8 ff ff       	call   8012a8 <fd2num>
  801a89:	89 c2                	mov    %eax,%edx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	eb 05                	jmp    801a95 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a90:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a95:	89 d0                	mov    %edx,%eax
  801a97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa7:	b8 08 00 00 00       	mov    $0x8,%eax
  801aac:	e8 a6 fd ff ff       	call   801857 <fsipc>
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ab9:	89 d0                	mov    %edx,%eax
  801abb:	c1 e8 16             	shr    $0x16,%eax
  801abe:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ac5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aca:	f6 c1 01             	test   $0x1,%cl
  801acd:	74 1d                	je     801aec <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801acf:	c1 ea 0c             	shr    $0xc,%edx
  801ad2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ad9:	f6 c2 01             	test   $0x1,%dl
  801adc:	74 0e                	je     801aec <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ade:	c1 ea 0c             	shr    $0xc,%edx
  801ae1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ae8:	ef 
  801ae9:	0f b7 c0             	movzwl %ax,%eax
}
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	56                   	push   %esi
  801af2:	53                   	push   %ebx
  801af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	ff 75 08             	pushl  0x8(%ebp)
  801afc:	e8 b7 f7 ff ff       	call   8012b8 <fd2data>
  801b01:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b03:	83 c4 08             	add    $0x8,%esp
  801b06:	68 93 28 80 00       	push   $0x802893
  801b0b:	53                   	push   %ebx
  801b0c:	e8 d9 ed ff ff       	call   8008ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b11:	8b 46 04             	mov    0x4(%esi),%eax
  801b14:	2b 06                	sub    (%esi),%eax
  801b16:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b1c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b23:	00 00 00 
	stat->st_dev = &devpipe;
  801b26:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b2d:	30 80 00 
	return 0;
}
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
  801b35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b46:	53                   	push   %ebx
  801b47:	6a 00                	push   $0x0
  801b49:	e8 24 f2 ff ff       	call   800d72 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b4e:	89 1c 24             	mov    %ebx,(%esp)
  801b51:	e8 62 f7 ff ff       	call   8012b8 <fd2data>
  801b56:	83 c4 08             	add    $0x8,%esp
  801b59:	50                   	push   %eax
  801b5a:	6a 00                	push   $0x0
  801b5c:	e8 11 f2 ff ff       	call   800d72 <sys_page_unmap>
}
  801b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	57                   	push   %edi
  801b6a:	56                   	push   %esi
  801b6b:	53                   	push   %ebx
  801b6c:	83 ec 1c             	sub    $0x1c,%esp
  801b6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b72:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b74:	a1 04 40 80 00       	mov    0x804004,%eax
  801b79:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b7c:	83 ec 0c             	sub    $0xc,%esp
  801b7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b82:	e8 2c ff ff ff       	call   801ab3 <pageref>
  801b87:	89 c3                	mov    %eax,%ebx
  801b89:	89 3c 24             	mov    %edi,(%esp)
  801b8c:	e8 22 ff ff ff       	call   801ab3 <pageref>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	39 c3                	cmp    %eax,%ebx
  801b96:	0f 94 c1             	sete   %cl
  801b99:	0f b6 c9             	movzbl %cl,%ecx
  801b9c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b9f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ba5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ba8:	39 ce                	cmp    %ecx,%esi
  801baa:	74 1b                	je     801bc7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bac:	39 c3                	cmp    %eax,%ebx
  801bae:	75 c4                	jne    801b74 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb0:	8b 42 58             	mov    0x58(%edx),%eax
  801bb3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb6:	50                   	push   %eax
  801bb7:	56                   	push   %esi
  801bb8:	68 9a 28 80 00       	push   $0x80289a
  801bbd:	e8 a3 e7 ff ff       	call   800365 <cprintf>
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	eb ad                	jmp    801b74 <_pipeisclosed+0xe>
	}
}
  801bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 28             	sub    $0x28,%esp
  801bdb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bde:	56                   	push   %esi
  801bdf:	e8 d4 f6 ff ff       	call   8012b8 <fd2data>
  801be4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	bf 00 00 00 00       	mov    $0x0,%edi
  801bee:	eb 4b                	jmp    801c3b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf0:	89 da                	mov    %ebx,%edx
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	e8 6d ff ff ff       	call   801b66 <_pipeisclosed>
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	75 48                	jne    801c45 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bfd:	e8 cc f0 ff ff       	call   800cce <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c02:	8b 43 04             	mov    0x4(%ebx),%eax
  801c05:	8b 0b                	mov    (%ebx),%ecx
  801c07:	8d 51 20             	lea    0x20(%ecx),%edx
  801c0a:	39 d0                	cmp    %edx,%eax
  801c0c:	73 e2                	jae    801bf0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c11:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c15:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c18:	89 c2                	mov    %eax,%edx
  801c1a:	c1 fa 1f             	sar    $0x1f,%edx
  801c1d:	89 d1                	mov    %edx,%ecx
  801c1f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c22:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c25:	83 e2 1f             	and    $0x1f,%edx
  801c28:	29 ca                	sub    %ecx,%edx
  801c2a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c38:	83 c7 01             	add    $0x1,%edi
  801c3b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3e:	75 c2                	jne    801c02 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c40:	8b 45 10             	mov    0x10(%ebp),%eax
  801c43:	eb 05                	jmp    801c4a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 18             	sub    $0x18,%esp
  801c5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5e:	57                   	push   %edi
  801c5f:	e8 54 f6 ff ff       	call   8012b8 <fd2data>
  801c64:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6e:	eb 3d                	jmp    801cad <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c70:	85 db                	test   %ebx,%ebx
  801c72:	74 04                	je     801c78 <devpipe_read+0x26>
				return i;
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	eb 44                	jmp    801cbc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c78:	89 f2                	mov    %esi,%edx
  801c7a:	89 f8                	mov    %edi,%eax
  801c7c:	e8 e5 fe ff ff       	call   801b66 <_pipeisclosed>
  801c81:	85 c0                	test   %eax,%eax
  801c83:	75 32                	jne    801cb7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c85:	e8 44 f0 ff ff       	call   800cce <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c8a:	8b 06                	mov    (%esi),%eax
  801c8c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c8f:	74 df                	je     801c70 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c91:	99                   	cltd   
  801c92:	c1 ea 1b             	shr    $0x1b,%edx
  801c95:	01 d0                	add    %edx,%eax
  801c97:	83 e0 1f             	and    $0x1f,%eax
  801c9a:	29 d0                	sub    %edx,%eax
  801c9c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801caa:	83 c3 01             	add    $0x1,%ebx
  801cad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb0:	75 d8                	jne    801c8a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb5:	eb 05                	jmp    801cbc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    

00801cc4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ccc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccf:	50                   	push   %eax
  801cd0:	e8 fa f5 ff ff       	call   8012cf <fd_alloc>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	89 c2                	mov    %eax,%edx
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	0f 88 2c 01 00 00    	js     801e0e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce2:	83 ec 04             	sub    $0x4,%esp
  801ce5:	68 07 04 00 00       	push   $0x407
  801cea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ced:	6a 00                	push   $0x0
  801cef:	e8 f9 ef ff ff       	call   800ced <sys_page_alloc>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	89 c2                	mov    %eax,%edx
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	0f 88 0d 01 00 00    	js     801e0e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d01:	83 ec 0c             	sub    $0xc,%esp
  801d04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d07:	50                   	push   %eax
  801d08:	e8 c2 f5 ff ff       	call   8012cf <fd_alloc>
  801d0d:	89 c3                	mov    %eax,%ebx
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	85 c0                	test   %eax,%eax
  801d14:	0f 88 e2 00 00 00    	js     801dfc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1a:	83 ec 04             	sub    $0x4,%esp
  801d1d:	68 07 04 00 00       	push   $0x407
  801d22:	ff 75 f0             	pushl  -0x10(%ebp)
  801d25:	6a 00                	push   $0x0
  801d27:	e8 c1 ef ff ff       	call   800ced <sys_page_alloc>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	0f 88 c3 00 00 00    	js     801dfc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d39:	83 ec 0c             	sub    $0xc,%esp
  801d3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3f:	e8 74 f5 ff ff       	call   8012b8 <fd2data>
  801d44:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d46:	83 c4 0c             	add    $0xc,%esp
  801d49:	68 07 04 00 00       	push   $0x407
  801d4e:	50                   	push   %eax
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 97 ef ff ff       	call   800ced <sys_page_alloc>
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	0f 88 89 00 00 00    	js     801dec <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	ff 75 f0             	pushl  -0x10(%ebp)
  801d69:	e8 4a f5 ff ff       	call   8012b8 <fd2data>
  801d6e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d75:	50                   	push   %eax
  801d76:	6a 00                	push   $0x0
  801d78:	56                   	push   %esi
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 b0 ef ff ff       	call   800d30 <sys_page_map>
  801d80:	89 c3                	mov    %eax,%ebx
  801d82:	83 c4 20             	add    $0x20,%esp
  801d85:	85 c0                	test   %eax,%eax
  801d87:	78 55                	js     801dde <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff 75 f4             	pushl  -0xc(%ebp)
  801db9:	e8 ea f4 ff ff       	call   8012a8 <fd2num>
  801dbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc3:	83 c4 04             	add    $0x4,%esp
  801dc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc9:	e8 da f4 ff ff       	call   8012a8 <fd2num>
  801dce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ddc:	eb 30                	jmp    801e0e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dde:	83 ec 08             	sub    $0x8,%esp
  801de1:	56                   	push   %esi
  801de2:	6a 00                	push   $0x0
  801de4:	e8 89 ef ff ff       	call   800d72 <sys_page_unmap>
  801de9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dec:	83 ec 08             	sub    $0x8,%esp
  801def:	ff 75 f0             	pushl  -0x10(%ebp)
  801df2:	6a 00                	push   $0x0
  801df4:	e8 79 ef ff ff       	call   800d72 <sys_page_unmap>
  801df9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	ff 75 f4             	pushl  -0xc(%ebp)
  801e02:	6a 00                	push   $0x0
  801e04:	e8 69 ef ff ff       	call   800d72 <sys_page_unmap>
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e0e:	89 d0                	mov    %edx,%eax
  801e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e13:	5b                   	pop    %ebx
  801e14:	5e                   	pop    %esi
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    

00801e17 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	ff 75 08             	pushl  0x8(%ebp)
  801e24:	e8 f5 f4 ff ff       	call   80131e <fd_lookup>
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	78 18                	js     801e48 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e30:	83 ec 0c             	sub    $0xc,%esp
  801e33:	ff 75 f4             	pushl  -0xc(%ebp)
  801e36:	e8 7d f4 ff ff       	call   8012b8 <fd2data>
	return _pipeisclosed(fd, p);
  801e3b:	89 c2                	mov    %eax,%edx
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	e8 21 fd ff ff       	call   801b66 <_pipeisclosed>
  801e45:	83 c4 10             	add    $0x10,%esp
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5a:	68 b2 28 80 00       	push   $0x8028b2
  801e5f:	ff 75 0c             	pushl  0xc(%ebp)
  801e62:	e8 83 ea ff ff       	call   8008ea <strcpy>
	return 0;
}
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e7f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e85:	eb 2d                	jmp    801eb4 <devcons_write+0x46>
		m = n - tot;
  801e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e8c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e8f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e94:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	53                   	push   %ebx
  801e9b:	03 45 0c             	add    0xc(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	57                   	push   %edi
  801ea0:	e8 d7 eb ff ff       	call   800a7c <memmove>
		sys_cputs(buf, m);
  801ea5:	83 c4 08             	add    $0x8,%esp
  801ea8:	53                   	push   %ebx
  801ea9:	57                   	push   %edi
  801eaa:	e8 82 ed ff ff       	call   800c31 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eaf:	01 de                	add    %ebx,%esi
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	89 f0                	mov    %esi,%eax
  801eb6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb9:	72 cc                	jb     801e87 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5e                   	pop    %esi
  801ec0:	5f                   	pop    %edi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 08             	sub    $0x8,%esp
  801ec9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ece:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed2:	74 2a                	je     801efe <devcons_read+0x3b>
  801ed4:	eb 05                	jmp    801edb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed6:	e8 f3 ed ff ff       	call   800cce <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801edb:	e8 6f ed ff ff       	call   800c4f <sys_cgetc>
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	74 f2                	je     801ed6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 16                	js     801efe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee8:	83 f8 04             	cmp    $0x4,%eax
  801eeb:	74 0c                	je     801ef9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eed:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef0:	88 02                	mov    %al,(%edx)
	return 1;
  801ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef7:	eb 05                	jmp    801efe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f06:	8b 45 08             	mov    0x8(%ebp),%eax
  801f09:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f0c:	6a 01                	push   $0x1
  801f0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f11:	50                   	push   %eax
  801f12:	e8 1a ed ff ff       	call   800c31 <sys_cputs>
}
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <getchar>:

int
getchar(void)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f22:	6a 01                	push   $0x1
  801f24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f27:	50                   	push   %eax
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 55 f6 ff ff       	call   801584 <read>
	if (r < 0)
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	78 0f                	js     801f45 <getchar+0x29>
		return r;
	if (r < 1)
  801f36:	85 c0                	test   %eax,%eax
  801f38:	7e 06                	jle    801f40 <getchar+0x24>
		return -E_EOF;
	return c;
  801f3a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3e:	eb 05                	jmp    801f45 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f40:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f50:	50                   	push   %eax
  801f51:	ff 75 08             	pushl  0x8(%ebp)
  801f54:	e8 c5 f3 ff ff       	call   80131e <fd_lookup>
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 11                	js     801f71 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f69:	39 10                	cmp    %edx,(%eax)
  801f6b:	0f 94 c0             	sete   %al
  801f6e:	0f b6 c0             	movzbl %al,%eax
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <opencons>:

int
opencons(void)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	e8 4d f3 ff ff       	call   8012cf <fd_alloc>
  801f82:	83 c4 10             	add    $0x10,%esp
		return r;
  801f85:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 3e                	js     801fc9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8b:	83 ec 04             	sub    $0x4,%esp
  801f8e:	68 07 04 00 00       	push   $0x407
  801f93:	ff 75 f4             	pushl  -0xc(%ebp)
  801f96:	6a 00                	push   $0x0
  801f98:	e8 50 ed ff ff       	call   800ced <sys_page_alloc>
  801f9d:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 23                	js     801fc9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fbb:	83 ec 0c             	sub    $0xc,%esp
  801fbe:	50                   	push   %eax
  801fbf:	e8 e4 f2 ff ff       	call   8012a8 <fd2num>
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	83 c4 10             	add    $0x10,%esp
}
  801fc9:	89 d0                	mov    %edx,%eax
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fd3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fda:	75 2a                	jne    802006 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fdc:	83 ec 04             	sub    $0x4,%esp
  801fdf:	6a 07                	push   $0x7
  801fe1:	68 00 f0 bf ee       	push   $0xeebff000
  801fe6:	6a 00                	push   $0x0
  801fe8:	e8 00 ed ff ff       	call   800ced <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	79 12                	jns    802006 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ff4:	50                   	push   %eax
  801ff5:	68 be 28 80 00       	push   $0x8028be
  801ffa:	6a 23                	push   $0x23
  801ffc:	68 c2 28 80 00       	push   $0x8028c2
  802001:	e8 86 e2 ff ff       	call   80028c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80200e:	83 ec 08             	sub    $0x8,%esp
  802011:	68 38 20 80 00       	push   $0x802038
  802016:	6a 00                	push   $0x0
  802018:	e8 1b ee ff ff       	call   800e38 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	85 c0                	test   %eax,%eax
  802022:	79 12                	jns    802036 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802024:	50                   	push   %eax
  802025:	68 be 28 80 00       	push   $0x8028be
  80202a:	6a 2c                	push   $0x2c
  80202c:	68 c2 28 80 00       	push   $0x8028c2
  802031:	e8 56 e2 ff ff       	call   80028c <_panic>
	}
}
  802036:	c9                   	leave  
  802037:	c3                   	ret    

00802038 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802038:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802039:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80203e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802040:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802043:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802047:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80204c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802050:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802052:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802055:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802056:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802059:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80205a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80205b:	c3                   	ret    
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
