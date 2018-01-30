
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 8d 02 00 00       	call   8002be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 c0 	movl   $0x8026c0,0x803004
  800042:	26 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 95 1e 00 00       	call   801ee3 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 cc 26 80 00       	push   $0x8026cc
  80005d:	6a 0e                	push   $0xe
  80005f:	68 d5 26 80 00       	push   $0x8026d5
  800064:	e8 d8 02 00 00       	call   800341 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 5b 10 00 00       	call   8010c9 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 e5 26 80 00       	push   $0x8026e5
  80007a:	6a 11                	push   $0x11
  80007c:	68 d5 26 80 00       	push   $0x8026d5
  800081:	e8 bb 02 00 00       	call   800341 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 be 00 00 00    	jne    80014c <umain+0x119>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800099:	83 ec 04             	sub    $0x4,%esp
  80009c:	ff 75 90             	pushl  -0x70(%ebp)
  80009f:	50                   	push   %eax
  8000a0:	68 ee 26 80 00       	push   $0x8026ee
  8000a5:	e8 70 03 00 00       	call   80041a <cprintf>
		close(p[1]);
  8000aa:	83 c4 04             	add    $0x4,%esp
  8000ad:	ff 75 90             	pushl  -0x70(%ebp)
  8000b0:	e8 db 15 00 00       	call   801690 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ba:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c6:	50                   	push   %eax
  8000c7:	68 0b 27 80 00       	push   $0x80270b
  8000cc:	e8 49 03 00 00       	call   80041a <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000d1:	83 c4 0c             	add    $0xc,%esp
  8000d4:	6a 63                	push   $0x63
  8000d6:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d9:	50                   	push   %eax
  8000da:	ff 75 8c             	pushl  -0x74(%ebp)
  8000dd:	e8 7e 17 00 00       	call   801860 <readn>
  8000e2:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	79 12                	jns    8000fd <umain+0xca>
			panic("read: %e", i);
  8000eb:	50                   	push   %eax
  8000ec:	68 28 27 80 00       	push   $0x802728
  8000f1:	6a 19                	push   $0x19
  8000f3:	68 d5 26 80 00       	push   $0x8026d5
  8000f8:	e8 44 02 00 00       	call   800341 <_panic>
		buf[i] = 0;
  8000fd:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800102:	83 ec 08             	sub    $0x8,%esp
  800105:	ff 35 00 30 80 00    	pushl  0x803000
  80010b:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80010e:	50                   	push   %eax
  80010f:	e8 35 09 00 00       	call   800a49 <strcmp>
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	85 c0                	test   %eax,%eax
  800119:	75 12                	jne    80012d <umain+0xfa>
			cprintf("\npipe read closed properly\n");
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	68 31 27 80 00       	push   $0x802731
  800123:	e8 f2 02 00 00       	call   80041a <cprintf>
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	eb 15                	jmp    800142 <umain+0x10f>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80012d:	83 ec 04             	sub    $0x4,%esp
  800130:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	56                   	push   %esi
  800135:	68 4d 27 80 00       	push   $0x80274d
  80013a:	e8 db 02 00 00       	call   80041a <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
		exit();
  800142:	e8 e0 01 00 00       	call   800327 <exit>
  800147:	e9 9a 00 00 00       	jmp    8001e6 <umain+0x1b3>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80014c:	a1 04 40 80 00       	mov    0x804004,%eax
  800151:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	ff 75 8c             	pushl  -0x74(%ebp)
  80015d:	50                   	push   %eax
  80015e:	68 ee 26 80 00       	push   $0x8026ee
  800163:	e8 b2 02 00 00       	call   80041a <cprintf>
		close(p[0]);
  800168:	83 c4 04             	add    $0x4,%esp
  80016b:	ff 75 8c             	pushl  -0x74(%ebp)
  80016e:	e8 1d 15 00 00       	call   801690 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  800173:	a1 04 40 80 00       	mov    0x804004,%eax
  800178:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80017e:	83 c4 0c             	add    $0xc,%esp
  800181:	ff 75 90             	pushl  -0x70(%ebp)
  800184:	50                   	push   %eax
  800185:	68 60 27 80 00       	push   $0x802760
  80018a:	e8 8b 02 00 00       	call   80041a <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  80018f:	83 c4 04             	add    $0x4,%esp
  800192:	ff 35 00 30 80 00    	pushl  0x803000
  800198:	e8 c9 07 00 00       	call   800966 <strlen>
  80019d:	83 c4 0c             	add    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	ff 35 00 30 80 00    	pushl  0x803000
  8001a7:	ff 75 90             	pushl  -0x70(%ebp)
  8001aa:	e8 fa 16 00 00       	call   8018a9 <write>
  8001af:	89 c6                	mov    %eax,%esi
  8001b1:	83 c4 04             	add    $0x4,%esp
  8001b4:	ff 35 00 30 80 00    	pushl  0x803000
  8001ba:	e8 a7 07 00 00       	call   800966 <strlen>
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	39 c6                	cmp    %eax,%esi
  8001c4:	74 12                	je     8001d8 <umain+0x1a5>
			panic("write: %e", i);
  8001c6:	56                   	push   %esi
  8001c7:	68 7d 27 80 00       	push   $0x80277d
  8001cc:	6a 25                	push   $0x25
  8001ce:	68 d5 26 80 00       	push   $0x8026d5
  8001d3:	e8 69 01 00 00       	call   800341 <_panic>
		close(p[1]);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 90             	pushl  -0x70(%ebp)
  8001de:	e8 ad 14 00 00       	call   801690 <close>
  8001e3:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	53                   	push   %ebx
  8001ea:	e8 7a 1e 00 00       	call   802069 <wait>

	binaryname = "pipewriteeof";
  8001ef:	c7 05 04 30 80 00 87 	movl   $0x802787,0x803004
  8001f6:	27 80 00 
	if ((i = pipe(p)) < 0)
  8001f9:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 df 1c 00 00       	call   801ee3 <pipe>
  800204:	89 c6                	mov    %eax,%esi
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	85 c0                	test   %eax,%eax
  80020b:	79 12                	jns    80021f <umain+0x1ec>
		panic("pipe: %e", i);
  80020d:	50                   	push   %eax
  80020e:	68 cc 26 80 00       	push   $0x8026cc
  800213:	6a 2c                	push   $0x2c
  800215:	68 d5 26 80 00       	push   $0x8026d5
  80021a:	e8 22 01 00 00       	call   800341 <_panic>

	if ((pid = fork()) < 0)
  80021f:	e8 a5 0e 00 00       	call   8010c9 <fork>
  800224:	89 c3                	mov    %eax,%ebx
  800226:	85 c0                	test   %eax,%eax
  800228:	79 12                	jns    80023c <umain+0x209>
		panic("fork: %e", i);
  80022a:	56                   	push   %esi
  80022b:	68 e5 26 80 00       	push   $0x8026e5
  800230:	6a 2f                	push   $0x2f
  800232:	68 d5 26 80 00       	push   $0x8026d5
  800237:	e8 05 01 00 00       	call   800341 <_panic>

	if (pid == 0) {
  80023c:	85 c0                	test   %eax,%eax
  80023e:	75 4a                	jne    80028a <umain+0x257>
		close(p[0]);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 8c             	pushl  -0x74(%ebp)
  800246:	e8 45 14 00 00       	call   801690 <close>
  80024b:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 94 27 80 00       	push   $0x802794
  800256:	e8 bf 01 00 00       	call   80041a <cprintf>
			if (write(p[1], "x", 1) != 1)
  80025b:	83 c4 0c             	add    $0xc,%esp
  80025e:	6a 01                	push   $0x1
  800260:	68 96 27 80 00       	push   $0x802796
  800265:	ff 75 90             	pushl  -0x70(%ebp)
  800268:	e8 3c 16 00 00       	call   8018a9 <write>
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	83 f8 01             	cmp    $0x1,%eax
  800273:	74 d9                	je     80024e <umain+0x21b>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	68 98 27 80 00       	push   $0x802798
  80027d:	e8 98 01 00 00       	call   80041a <cprintf>
		exit();
  800282:	e8 a0 00 00 00       	call   800327 <exit>
  800287:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	ff 75 8c             	pushl  -0x74(%ebp)
  800290:	e8 fb 13 00 00       	call   801690 <close>
	close(p[1]);
  800295:	83 c4 04             	add    $0x4,%esp
  800298:	ff 75 90             	pushl  -0x70(%ebp)
  80029b:	e8 f0 13 00 00       	call   801690 <close>
	wait(pid);
  8002a0:	89 1c 24             	mov    %ebx,(%esp)
  8002a3:	e8 c1 1d 00 00       	call   802069 <wait>

	cprintf("pipe tests passed\n");
  8002a8:	c7 04 24 b5 27 80 00 	movl   $0x8027b5,(%esp)
  8002af:	e8 66 01 00 00       	call   80041a <cprintf>
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002c9:	e8 96 0a 00 00       	call   800d64 <sys_getenvid>
  8002ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8002d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002de:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e3:	85 db                	test   %ebx,%ebx
  8002e5:	7e 07                	jle    8002ee <libmain+0x30>
		binaryname = argv[0];
  8002e7:	8b 06                	mov    (%esi),%eax
  8002e9:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002ee:	83 ec 08             	sub    $0x8,%esp
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	e8 3b fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002f8:	e8 2a 00 00 00       	call   800327 <exit>
}
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800303:	5b                   	pop    %ebx
  800304:	5e                   	pop    %esi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80030d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800312:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800314:	e8 4b 0a 00 00       	call   800d64 <sys_getenvid>
  800319:	83 ec 0c             	sub    $0xc,%esp
  80031c:	50                   	push   %eax
  80031d:	e8 91 0c 00 00       	call   800fb3 <sys_thread_free>
}
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80032d:	e8 89 13 00 00       	call   8016bb <close_all>
	sys_env_destroy(0);
  800332:	83 ec 0c             	sub    $0xc,%esp
  800335:	6a 00                	push   $0x0
  800337:	e8 e7 09 00 00       	call   800d23 <sys_env_destroy>
}
  80033c:	83 c4 10             	add    $0x10,%esp
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800349:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80034f:	e8 10 0a 00 00       	call   800d64 <sys_getenvid>
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	ff 75 0c             	pushl  0xc(%ebp)
  80035a:	ff 75 08             	pushl  0x8(%ebp)
  80035d:	56                   	push   %esi
  80035e:	50                   	push   %eax
  80035f:	68 18 28 80 00       	push   $0x802818
  800364:	e8 b1 00 00 00       	call   80041a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800369:	83 c4 18             	add    $0x18,%esp
  80036c:	53                   	push   %ebx
  80036d:	ff 75 10             	pushl  0x10(%ebp)
  800370:	e8 54 00 00 00       	call   8003c9 <vcprintf>
	cprintf("\n");
  800375:	c7 04 24 db 2b 80 00 	movl   $0x802bdb,(%esp)
  80037c:	e8 99 00 00 00       	call   80041a <cprintf>
  800381:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800384:	cc                   	int3   
  800385:	eb fd                	jmp    800384 <_panic+0x43>

00800387 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	53                   	push   %ebx
  80038b:	83 ec 04             	sub    $0x4,%esp
  80038e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800391:	8b 13                	mov    (%ebx),%edx
  800393:	8d 42 01             	lea    0x1(%edx),%eax
  800396:	89 03                	mov    %eax,(%ebx)
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a4:	75 1a                	jne    8003c0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	68 ff 00 00 00       	push   $0xff
  8003ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b1:	50                   	push   %eax
  8003b2:	e8 2f 09 00 00       	call   800ce6 <sys_cputs>
		b->idx = 0;
  8003b7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c7:	c9                   	leave  
  8003c8:	c3                   	ret    

008003c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d9:	00 00 00 
	b.cnt = 0;
  8003dc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e6:	ff 75 0c             	pushl  0xc(%ebp)
  8003e9:	ff 75 08             	pushl  0x8(%ebp)
  8003ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f2:	50                   	push   %eax
  8003f3:	68 87 03 80 00       	push   $0x800387
  8003f8:	e8 54 01 00 00       	call   800551 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fd:	83 c4 08             	add    $0x8,%esp
  800400:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800406:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040c:	50                   	push   %eax
  80040d:	e8 d4 08 00 00       	call   800ce6 <sys_cputs>

	return b.cnt;
}
  800412:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800420:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800423:	50                   	push   %eax
  800424:	ff 75 08             	pushl  0x8(%ebp)
  800427:	e8 9d ff ff ff       	call   8003c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 1c             	sub    $0x1c,%esp
  800437:	89 c7                	mov    %eax,%edi
  800439:	89 d6                	mov    %edx,%esi
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800441:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800444:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800447:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80044a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800452:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800455:	39 d3                	cmp    %edx,%ebx
  800457:	72 05                	jb     80045e <printnum+0x30>
  800459:	39 45 10             	cmp    %eax,0x10(%ebp)
  80045c:	77 45                	ja     8004a3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045e:	83 ec 0c             	sub    $0xc,%esp
  800461:	ff 75 18             	pushl  0x18(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80046a:	53                   	push   %ebx
  80046b:	ff 75 10             	pushl  0x10(%ebp)
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	ff 75 e4             	pushl  -0x1c(%ebp)
  800474:	ff 75 e0             	pushl  -0x20(%ebp)
  800477:	ff 75 dc             	pushl  -0x24(%ebp)
  80047a:	ff 75 d8             	pushl  -0x28(%ebp)
  80047d:	e8 ae 1f 00 00       	call   802430 <__udivdi3>
  800482:	83 c4 18             	add    $0x18,%esp
  800485:	52                   	push   %edx
  800486:	50                   	push   %eax
  800487:	89 f2                	mov    %esi,%edx
  800489:	89 f8                	mov    %edi,%eax
  80048b:	e8 9e ff ff ff       	call   80042e <printnum>
  800490:	83 c4 20             	add    $0x20,%esp
  800493:	eb 18                	jmp    8004ad <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	56                   	push   %esi
  800499:	ff 75 18             	pushl  0x18(%ebp)
  80049c:	ff d7                	call   *%edi
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	eb 03                	jmp    8004a6 <printnum+0x78>
  8004a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a6:	83 eb 01             	sub    $0x1,%ebx
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	7f e8                	jg     800495 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	56                   	push   %esi
  8004b1:	83 ec 04             	sub    $0x4,%esp
  8004b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c0:	e8 9b 20 00 00       	call   802560 <__umoddi3>
  8004c5:	83 c4 14             	add    $0x14,%esp
  8004c8:	0f be 80 3b 28 80 00 	movsbl 0x80283b(%eax),%eax
  8004cf:	50                   	push   %eax
  8004d0:	ff d7                	call   *%edi
}
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d8:	5b                   	pop    %ebx
  8004d9:	5e                   	pop    %esi
  8004da:	5f                   	pop    %edi
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e0:	83 fa 01             	cmp    $0x1,%edx
  8004e3:	7e 0e                	jle    8004f3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ea:	89 08                	mov    %ecx,(%eax)
  8004ec:	8b 02                	mov    (%edx),%eax
  8004ee:	8b 52 04             	mov    0x4(%edx),%edx
  8004f1:	eb 22                	jmp    800515 <getuint+0x38>
	else if (lflag)
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 10                	je     800507 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f7:	8b 10                	mov    (%eax),%edx
  8004f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 02                	mov    (%edx),%eax
  800500:	ba 00 00 00 00       	mov    $0x0,%edx
  800505:	eb 0e                	jmp    800515 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800507:	8b 10                	mov    (%eax),%edx
  800509:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050c:	89 08                	mov    %ecx,(%eax)
  80050e:	8b 02                	mov    (%edx),%eax
  800510:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80051d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800521:	8b 10                	mov    (%eax),%edx
  800523:	3b 50 04             	cmp    0x4(%eax),%edx
  800526:	73 0a                	jae    800532 <sprintputch+0x1b>
		*b->buf++ = ch;
  800528:	8d 4a 01             	lea    0x1(%edx),%ecx
  80052b:	89 08                	mov    %ecx,(%eax)
  80052d:	8b 45 08             	mov    0x8(%ebp),%eax
  800530:	88 02                	mov    %al,(%edx)
}
  800532:	5d                   	pop    %ebp
  800533:	c3                   	ret    

00800534 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80053a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053d:	50                   	push   %eax
  80053e:	ff 75 10             	pushl  0x10(%ebp)
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	ff 75 08             	pushl  0x8(%ebp)
  800547:	e8 05 00 00 00       	call   800551 <vprintfmt>
	va_end(ap);
}
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	c9                   	leave  
  800550:	c3                   	ret    

00800551 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	57                   	push   %edi
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
  800557:	83 ec 2c             	sub    $0x2c,%esp
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	8b 7d 10             	mov    0x10(%ebp),%edi
  800563:	eb 12                	jmp    800577 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800565:	85 c0                	test   %eax,%eax
  800567:	0f 84 89 03 00 00    	je     8008f6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	53                   	push   %ebx
  800571:	50                   	push   %eax
  800572:	ff d6                	call   *%esi
  800574:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800577:	83 c7 01             	add    $0x1,%edi
  80057a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057e:	83 f8 25             	cmp    $0x25,%eax
  800581:	75 e2                	jne    800565 <vprintfmt+0x14>
  800583:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800587:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80058e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800595:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80059c:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a1:	eb 07                	jmp    8005aa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8d 47 01             	lea    0x1(%edi),%eax
  8005ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b0:	0f b6 07             	movzbl (%edi),%eax
  8005b3:	0f b6 c8             	movzbl %al,%ecx
  8005b6:	83 e8 23             	sub    $0x23,%eax
  8005b9:	3c 55                	cmp    $0x55,%al
  8005bb:	0f 87 1a 03 00 00    	ja     8008db <vprintfmt+0x38a>
  8005c1:	0f b6 c0             	movzbl %al,%eax
  8005c4:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ce:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005d2:	eb d6                	jmp    8005aa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005df:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005e6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005e9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ec:	83 fa 09             	cmp    $0x9,%edx
  8005ef:	77 39                	ja     80062a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005f4:	eb e9                	jmp    8005df <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8005fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800607:	eb 27                	jmp    800630 <vprintfmt+0xdf>
  800609:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060c:	85 c0                	test   %eax,%eax
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	0f 49 c8             	cmovns %eax,%ecx
  800616:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061c:	eb 8c                	jmp    8005aa <vprintfmt+0x59>
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800621:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800628:	eb 80                	jmp    8005aa <vprintfmt+0x59>
  80062a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800630:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800634:	0f 89 70 ff ff ff    	jns    8005aa <vprintfmt+0x59>
				width = precision, precision = -1;
  80063a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800640:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800647:	e9 5e ff ff ff       	jmp    8005aa <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80064c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800652:	e9 53 ff ff ff       	jmp    8005aa <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	ff 30                	pushl  (%eax)
  800666:	ff d6                	call   *%esi
			break;
  800668:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80066e:	e9 04 ff ff ff       	jmp    800577 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 04             	lea    0x4(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	99                   	cltd   
  80067f:	31 d0                	xor    %edx,%eax
  800681:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800683:	83 f8 0f             	cmp    $0xf,%eax
  800686:	7f 0b                	jg     800693 <vprintfmt+0x142>
  800688:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	75 18                	jne    8006ab <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800693:	50                   	push   %eax
  800694:	68 53 28 80 00       	push   $0x802853
  800699:	53                   	push   %ebx
  80069a:	56                   	push   %esi
  80069b:	e8 94 fe ff ff       	call   800534 <printfmt>
  8006a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a6:	e9 cc fe ff ff       	jmp    800577 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006ab:	52                   	push   %edx
  8006ac:	68 a1 2c 80 00       	push   $0x802ca1
  8006b1:	53                   	push   %ebx
  8006b2:	56                   	push   %esi
  8006b3:	e8 7c fe ff ff       	call   800534 <printfmt>
  8006b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006be:	e9 b4 fe ff ff       	jmp    800577 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 04             	lea    0x4(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006ce:	85 ff                	test   %edi,%edi
  8006d0:	b8 4c 28 80 00       	mov    $0x80284c,%eax
  8006d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006dc:	0f 8e 94 00 00 00    	jle    800776 <vprintfmt+0x225>
  8006e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006e6:	0f 84 98 00 00 00    	je     800784 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8006f2:	57                   	push   %edi
  8006f3:	e8 86 02 00 00       	call   80097e <strnlen>
  8006f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fb:	29 c1                	sub    %eax,%ecx
  8006fd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800700:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800703:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800707:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80070d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070f:	eb 0f                	jmp    800720 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	ff 75 e0             	pushl  -0x20(%ebp)
  800718:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80071a:	83 ef 01             	sub    $0x1,%edi
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	85 ff                	test   %edi,%edi
  800722:	7f ed                	jg     800711 <vprintfmt+0x1c0>
  800724:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800727:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80072a:	85 c9                	test   %ecx,%ecx
  80072c:	b8 00 00 00 00       	mov    $0x0,%eax
  800731:	0f 49 c1             	cmovns %ecx,%eax
  800734:	29 c1                	sub    %eax,%ecx
  800736:	89 75 08             	mov    %esi,0x8(%ebp)
  800739:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80073c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073f:	89 cb                	mov    %ecx,%ebx
  800741:	eb 4d                	jmp    800790 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800743:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800747:	74 1b                	je     800764 <vprintfmt+0x213>
  800749:	0f be c0             	movsbl %al,%eax
  80074c:	83 e8 20             	sub    $0x20,%eax
  80074f:	83 f8 5e             	cmp    $0x5e,%eax
  800752:	76 10                	jbe    800764 <vprintfmt+0x213>
					putch('?', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	ff 75 0c             	pushl  0xc(%ebp)
  80075a:	6a 3f                	push   $0x3f
  80075c:	ff 55 08             	call   *0x8(%ebp)
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 0d                	jmp    800771 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	ff 75 0c             	pushl  0xc(%ebp)
  80076a:	52                   	push   %edx
  80076b:	ff 55 08             	call   *0x8(%ebp)
  80076e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800771:	83 eb 01             	sub    $0x1,%ebx
  800774:	eb 1a                	jmp    800790 <vprintfmt+0x23f>
  800776:	89 75 08             	mov    %esi,0x8(%ebp)
  800779:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80077c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800782:	eb 0c                	jmp    800790 <vprintfmt+0x23f>
  800784:	89 75 08             	mov    %esi,0x8(%ebp)
  800787:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80078a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800790:	83 c7 01             	add    $0x1,%edi
  800793:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800797:	0f be d0             	movsbl %al,%edx
  80079a:	85 d2                	test   %edx,%edx
  80079c:	74 23                	je     8007c1 <vprintfmt+0x270>
  80079e:	85 f6                	test   %esi,%esi
  8007a0:	78 a1                	js     800743 <vprintfmt+0x1f2>
  8007a2:	83 ee 01             	sub    $0x1,%esi
  8007a5:	79 9c                	jns    800743 <vprintfmt+0x1f2>
  8007a7:	89 df                	mov    %ebx,%edi
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007af:	eb 18                	jmp    8007c9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	53                   	push   %ebx
  8007b5:	6a 20                	push   $0x20
  8007b7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b9:	83 ef 01             	sub    $0x1,%edi
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	eb 08                	jmp    8007c9 <vprintfmt+0x278>
  8007c1:	89 df                	mov    %ebx,%edi
  8007c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c9:	85 ff                	test   %edi,%edi
  8007cb:	7f e4                	jg     8007b1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d0:	e9 a2 fd ff ff       	jmp    800577 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d5:	83 fa 01             	cmp    $0x1,%edx
  8007d8:	7e 16                	jle    8007f0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 08             	lea    0x8(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	8b 50 04             	mov    0x4(%eax),%edx
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ee:	eb 32                	jmp    800822 <vprintfmt+0x2d1>
	else if (lflag)
  8007f0:	85 d2                	test   %edx,%edx
  8007f2:	74 18                	je     80080c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8d 50 04             	lea    0x4(%eax),%edx
  8007fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fd:	8b 00                	mov    (%eax),%eax
  8007ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800802:	89 c1                	mov    %eax,%ecx
  800804:	c1 f9 1f             	sar    $0x1f,%ecx
  800807:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80080a:	eb 16                	jmp    800822 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 50 04             	lea    0x4(%eax),%edx
  800812:	89 55 14             	mov    %edx,0x14(%ebp)
  800815:	8b 00                	mov    (%eax),%eax
  800817:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081a:	89 c1                	mov    %eax,%ecx
  80081c:	c1 f9 1f             	sar    $0x1f,%ecx
  80081f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800822:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800825:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800828:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80082d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800831:	79 74                	jns    8008a7 <vprintfmt+0x356>
				putch('-', putdat);
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	53                   	push   %ebx
  800837:	6a 2d                	push   $0x2d
  800839:	ff d6                	call   *%esi
				num = -(long long) num;
  80083b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80083e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800841:	f7 d8                	neg    %eax
  800843:	83 d2 00             	adc    $0x0,%edx
  800846:	f7 da                	neg    %edx
  800848:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80084b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800850:	eb 55                	jmp    8008a7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	e8 83 fc ff ff       	call   8004dd <getuint>
			base = 10;
  80085a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80085f:	eb 46                	jmp    8008a7 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800861:	8d 45 14             	lea    0x14(%ebp),%eax
  800864:	e8 74 fc ff ff       	call   8004dd <getuint>
			base = 8;
  800869:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80086e:	eb 37                	jmp    8008a7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 30                	push   $0x30
  800876:	ff d6                	call   *%esi
			putch('x', putdat);
  800878:	83 c4 08             	add    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	6a 78                	push   $0x78
  80087e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8d 50 04             	lea    0x4(%eax),%edx
  800886:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800889:	8b 00                	mov    (%eax),%eax
  80088b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800890:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800893:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800898:	eb 0d                	jmp    8008a7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
  80089d:	e8 3b fc ff ff       	call   8004dd <getuint>
			base = 16;
  8008a2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a7:	83 ec 0c             	sub    $0xc,%esp
  8008aa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008ae:	57                   	push   %edi
  8008af:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b2:	51                   	push   %ecx
  8008b3:	52                   	push   %edx
  8008b4:	50                   	push   %eax
  8008b5:	89 da                	mov    %ebx,%edx
  8008b7:	89 f0                	mov    %esi,%eax
  8008b9:	e8 70 fb ff ff       	call   80042e <printnum>
			break;
  8008be:	83 c4 20             	add    $0x20,%esp
  8008c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c4:	e9 ae fc ff ff       	jmp    800577 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	53                   	push   %ebx
  8008cd:	51                   	push   %ecx
  8008ce:	ff d6                	call   *%esi
			break;
  8008d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d6:	e9 9c fc ff ff       	jmp    800577 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	53                   	push   %ebx
  8008df:	6a 25                	push   $0x25
  8008e1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e3:	83 c4 10             	add    $0x10,%esp
  8008e6:	eb 03                	jmp    8008eb <vprintfmt+0x39a>
  8008e8:	83 ef 01             	sub    $0x1,%edi
  8008eb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ef:	75 f7                	jne    8008e8 <vprintfmt+0x397>
  8008f1:	e9 81 fc ff ff       	jmp    800577 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 18             	sub    $0x18,%esp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800911:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800914:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091b:	85 c0                	test   %eax,%eax
  80091d:	74 26                	je     800945 <vsnprintf+0x47>
  80091f:	85 d2                	test   %edx,%edx
  800921:	7e 22                	jle    800945 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800923:	ff 75 14             	pushl  0x14(%ebp)
  800926:	ff 75 10             	pushl  0x10(%ebp)
  800929:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092c:	50                   	push   %eax
  80092d:	68 17 05 80 00       	push   $0x800517
  800932:	e8 1a fc ff ff       	call   800551 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800937:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80093a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	eb 05                	jmp    80094a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800945:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800952:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800955:	50                   	push   %eax
  800956:	ff 75 10             	pushl  0x10(%ebp)
  800959:	ff 75 0c             	pushl  0xc(%ebp)
  80095c:	ff 75 08             	pushl  0x8(%ebp)
  80095f:	e8 9a ff ff ff       	call   8008fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
  800971:	eb 03                	jmp    800976 <strlen+0x10>
		n++;
  800973:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80097a:	75 f7                	jne    800973 <strlen+0xd>
		n++;
	return n;
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800987:	ba 00 00 00 00       	mov    $0x0,%edx
  80098c:	eb 03                	jmp    800991 <strnlen+0x13>
		n++;
  80098e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	39 c2                	cmp    %eax,%edx
  800993:	74 08                	je     80099d <strnlen+0x1f>
  800995:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800999:	75 f3                	jne    80098e <strnlen+0x10>
  80099b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a9:	89 c2                	mov    %eax,%edx
  8009ab:	83 c2 01             	add    $0x1,%edx
  8009ae:	83 c1 01             	add    $0x1,%ecx
  8009b1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b8:	84 db                	test   %bl,%bl
  8009ba:	75 ef                	jne    8009ab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c6:	53                   	push   %ebx
  8009c7:	e8 9a ff ff ff       	call   800966 <strlen>
  8009cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	01 d8                	add    %ebx,%eax
  8009d4:	50                   	push   %eax
  8009d5:	e8 c5 ff ff ff       	call   80099f <strcpy>
	return dst;
}
  8009da:	89 d8                	mov    %ebx,%eax
  8009dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ec:	89 f3                	mov    %esi,%ebx
  8009ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f1:	89 f2                	mov    %esi,%edx
  8009f3:	eb 0f                	jmp    800a04 <strncpy+0x23>
		*dst++ = *src;
  8009f5:	83 c2 01             	add    $0x1,%edx
  8009f8:	0f b6 01             	movzbl (%ecx),%eax
  8009fb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009fe:	80 39 01             	cmpb   $0x1,(%ecx)
  800a01:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a04:	39 da                	cmp    %ebx,%edx
  800a06:	75 ed                	jne    8009f5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a08:	89 f0                	mov    %esi,%eax
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 75 08             	mov    0x8(%ebp),%esi
  800a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a19:	8b 55 10             	mov    0x10(%ebp),%edx
  800a1c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1e:	85 d2                	test   %edx,%edx
  800a20:	74 21                	je     800a43 <strlcpy+0x35>
  800a22:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a26:	89 f2                	mov    %esi,%edx
  800a28:	eb 09                	jmp    800a33 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a2a:	83 c2 01             	add    $0x1,%edx
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a33:	39 c2                	cmp    %eax,%edx
  800a35:	74 09                	je     800a40 <strlcpy+0x32>
  800a37:	0f b6 19             	movzbl (%ecx),%ebx
  800a3a:	84 db                	test   %bl,%bl
  800a3c:	75 ec                	jne    800a2a <strlcpy+0x1c>
  800a3e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a40:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a43:	29 f0                	sub    %esi,%eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a52:	eb 06                	jmp    800a5a <strcmp+0x11>
		p++, q++;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5a:	0f b6 01             	movzbl (%ecx),%eax
  800a5d:	84 c0                	test   %al,%al
  800a5f:	74 04                	je     800a65 <strcmp+0x1c>
  800a61:	3a 02                	cmp    (%edx),%al
  800a63:	74 ef                	je     800a54 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a65:	0f b6 c0             	movzbl %al,%eax
  800a68:	0f b6 12             	movzbl (%edx),%edx
  800a6b:	29 d0                	sub    %edx,%eax
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	53                   	push   %ebx
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a79:	89 c3                	mov    %eax,%ebx
  800a7b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a7e:	eb 06                	jmp    800a86 <strncmp+0x17>
		n--, p++, q++;
  800a80:	83 c0 01             	add    $0x1,%eax
  800a83:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a86:	39 d8                	cmp    %ebx,%eax
  800a88:	74 15                	je     800a9f <strncmp+0x30>
  800a8a:	0f b6 08             	movzbl (%eax),%ecx
  800a8d:	84 c9                	test   %cl,%cl
  800a8f:	74 04                	je     800a95 <strncmp+0x26>
  800a91:	3a 0a                	cmp    (%edx),%cl
  800a93:	74 eb                	je     800a80 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a95:	0f b6 00             	movzbl (%eax),%eax
  800a98:	0f b6 12             	movzbl (%edx),%edx
  800a9b:	29 d0                	sub    %edx,%eax
  800a9d:	eb 05                	jmp    800aa4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab1:	eb 07                	jmp    800aba <strchr+0x13>
		if (*s == c)
  800ab3:	38 ca                	cmp    %cl,%dl
  800ab5:	74 0f                	je     800ac6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	0f b6 10             	movzbl (%eax),%edx
  800abd:	84 d2                	test   %dl,%dl
  800abf:	75 f2                	jne    800ab3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad2:	eb 03                	jmp    800ad7 <strfind+0xf>
  800ad4:	83 c0 01             	add    $0x1,%eax
  800ad7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ada:	38 ca                	cmp    %cl,%dl
  800adc:	74 04                	je     800ae2 <strfind+0x1a>
  800ade:	84 d2                	test   %dl,%dl
  800ae0:	75 f2                	jne    800ad4 <strfind+0xc>
			break;
	return (char *) s;
}
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  800aea:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af0:	85 c9                	test   %ecx,%ecx
  800af2:	74 36                	je     800b2a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afa:	75 28                	jne    800b24 <memset+0x40>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 23                	jne    800b24 <memset+0x40>
		c &= 0xFF;
  800b01:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b05:	89 d3                	mov    %edx,%ebx
  800b07:	c1 e3 08             	shl    $0x8,%ebx
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	c1 e6 18             	shl    $0x18,%esi
  800b0f:	89 d0                	mov    %edx,%eax
  800b11:	c1 e0 10             	shl    $0x10,%eax
  800b14:	09 f0                	or     %esi,%eax
  800b16:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b18:	89 d8                	mov    %ebx,%eax
  800b1a:	09 d0                	or     %edx,%eax
  800b1c:	c1 e9 02             	shr    $0x2,%ecx
  800b1f:	fc                   	cld    
  800b20:	f3 ab                	rep stos %eax,%es:(%edi)
  800b22:	eb 06                	jmp    800b2a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	fc                   	cld    
  800b28:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2a:	89 f8                	mov    %edi,%eax
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
  800b39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3f:	39 c6                	cmp    %eax,%esi
  800b41:	73 35                	jae    800b78 <memmove+0x47>
  800b43:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b46:	39 d0                	cmp    %edx,%eax
  800b48:	73 2e                	jae    800b78 <memmove+0x47>
		s += n;
		d += n;
  800b4a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	09 fe                	or     %edi,%esi
  800b51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b57:	75 13                	jne    800b6c <memmove+0x3b>
  800b59:	f6 c1 03             	test   $0x3,%cl
  800b5c:	75 0e                	jne    800b6c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b5e:	83 ef 04             	sub    $0x4,%edi
  800b61:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b64:	c1 e9 02             	shr    $0x2,%ecx
  800b67:	fd                   	std    
  800b68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6a:	eb 09                	jmp    800b75 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6c:	83 ef 01             	sub    $0x1,%edi
  800b6f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b72:	fd                   	std    
  800b73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b75:	fc                   	cld    
  800b76:	eb 1d                	jmp    800b95 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	89 f2                	mov    %esi,%edx
  800b7a:	09 c2                	or     %eax,%edx
  800b7c:	f6 c2 03             	test   $0x3,%dl
  800b7f:	75 0f                	jne    800b90 <memmove+0x5f>
  800b81:	f6 c1 03             	test   $0x3,%cl
  800b84:	75 0a                	jne    800b90 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b86:	c1 e9 02             	shr    $0x2,%ecx
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	fc                   	cld    
  800b8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8e:	eb 05                	jmp    800b95 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	fc                   	cld    
  800b93:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b9c:	ff 75 10             	pushl  0x10(%ebp)
  800b9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ba2:	ff 75 08             	pushl  0x8(%ebp)
  800ba5:	e8 87 ff ff ff       	call   800b31 <memmove>
}
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb7:	89 c6                	mov    %eax,%esi
  800bb9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbc:	eb 1a                	jmp    800bd8 <memcmp+0x2c>
		if (*s1 != *s2)
  800bbe:	0f b6 08             	movzbl (%eax),%ecx
  800bc1:	0f b6 1a             	movzbl (%edx),%ebx
  800bc4:	38 d9                	cmp    %bl,%cl
  800bc6:	74 0a                	je     800bd2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc8:	0f b6 c1             	movzbl %cl,%eax
  800bcb:	0f b6 db             	movzbl %bl,%ebx
  800bce:	29 d8                	sub    %ebx,%eax
  800bd0:	eb 0f                	jmp    800be1 <memcmp+0x35>
		s1++, s2++;
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd8:	39 f0                	cmp    %esi,%eax
  800bda:	75 e2                	jne    800bbe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	53                   	push   %ebx
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bec:	89 c1                	mov    %eax,%ecx
  800bee:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf5:	eb 0a                	jmp    800c01 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf7:	0f b6 10             	movzbl (%eax),%edx
  800bfa:	39 da                	cmp    %ebx,%edx
  800bfc:	74 07                	je     800c05 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfe:	83 c0 01             	add    $0x1,%eax
  800c01:	39 c8                	cmp    %ecx,%eax
  800c03:	72 f2                	jb     800bf7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c05:	5b                   	pop    %ebx
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c14:	eb 03                	jmp    800c19 <strtol+0x11>
		s++;
  800c16:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c19:	0f b6 01             	movzbl (%ecx),%eax
  800c1c:	3c 20                	cmp    $0x20,%al
  800c1e:	74 f6                	je     800c16 <strtol+0xe>
  800c20:	3c 09                	cmp    $0x9,%al
  800c22:	74 f2                	je     800c16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c24:	3c 2b                	cmp    $0x2b,%al
  800c26:	75 0a                	jne    800c32 <strtol+0x2a>
		s++;
  800c28:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c30:	eb 11                	jmp    800c43 <strtol+0x3b>
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c37:	3c 2d                	cmp    $0x2d,%al
  800c39:	75 08                	jne    800c43 <strtol+0x3b>
		s++, neg = 1;
  800c3b:	83 c1 01             	add    $0x1,%ecx
  800c3e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c43:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c49:	75 15                	jne    800c60 <strtol+0x58>
  800c4b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4e:	75 10                	jne    800c60 <strtol+0x58>
  800c50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c54:	75 7c                	jne    800cd2 <strtol+0xca>
		s += 2, base = 16;
  800c56:	83 c1 02             	add    $0x2,%ecx
  800c59:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5e:	eb 16                	jmp    800c76 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c60:	85 db                	test   %ebx,%ebx
  800c62:	75 12                	jne    800c76 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c64:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c69:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6c:	75 08                	jne    800c76 <strtol+0x6e>
		s++, base = 8;
  800c6e:	83 c1 01             	add    $0x1,%ecx
  800c71:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c76:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7e:	0f b6 11             	movzbl (%ecx),%edx
  800c81:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c84:	89 f3                	mov    %esi,%ebx
  800c86:	80 fb 09             	cmp    $0x9,%bl
  800c89:	77 08                	ja     800c93 <strtol+0x8b>
			dig = *s - '0';
  800c8b:	0f be d2             	movsbl %dl,%edx
  800c8e:	83 ea 30             	sub    $0x30,%edx
  800c91:	eb 22                	jmp    800cb5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c93:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c96:	89 f3                	mov    %esi,%ebx
  800c98:	80 fb 19             	cmp    $0x19,%bl
  800c9b:	77 08                	ja     800ca5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c9d:	0f be d2             	movsbl %dl,%edx
  800ca0:	83 ea 57             	sub    $0x57,%edx
  800ca3:	eb 10                	jmp    800cb5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ca5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca8:	89 f3                	mov    %esi,%ebx
  800caa:	80 fb 19             	cmp    $0x19,%bl
  800cad:	77 16                	ja     800cc5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800caf:	0f be d2             	movsbl %dl,%edx
  800cb2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb8:	7d 0b                	jge    800cc5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cba:	83 c1 01             	add    $0x1,%ecx
  800cbd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc3:	eb b9                	jmp    800c7e <strtol+0x76>

	if (endptr)
  800cc5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc9:	74 0d                	je     800cd8 <strtol+0xd0>
		*endptr = (char *) s;
  800ccb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cce:	89 0e                	mov    %ecx,(%esi)
  800cd0:	eb 06                	jmp    800cd8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd2:	85 db                	test   %ebx,%ebx
  800cd4:	74 98                	je     800c6e <strtol+0x66>
  800cd6:	eb 9e                	jmp    800c76 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd8:	89 c2                	mov    %eax,%edx
  800cda:	f7 da                	neg    %edx
  800cdc:	85 ff                	test   %edi,%edi
  800cde:	0f 45 c2             	cmovne %edx,%eax
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 c3                	mov    %eax,%ebx
  800cf9:	89 c7                	mov    %eax,%edi
  800cfb:	89 c6                	mov    %eax,%esi
  800cfd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d31:	b8 03 00 00 00       	mov    $0x3,%eax
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 cb                	mov    %ecx,%ebx
  800d3b:	89 cf                	mov    %ecx,%edi
  800d3d:	89 ce                	mov    %ecx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 03                	push   $0x3
  800d4b:	68 3f 2b 80 00       	push   $0x802b3f
  800d50:	6a 23                	push   $0x23
  800d52:	68 5c 2b 80 00       	push   $0x802b5c
  800d57:	e8 e5 f5 ff ff       	call   800341 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6f:	b8 02 00 00 00       	mov    $0x2,%eax
  800d74:	89 d1                	mov    %edx,%ecx
  800d76:	89 d3                	mov    %edx,%ebx
  800d78:	89 d7                	mov    %edx,%edi
  800d7a:	89 d6                	mov    %edx,%esi
  800d7c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_yield>:

void
sys_yield(void)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d93:	89 d1                	mov    %edx,%ecx
  800d95:	89 d3                	mov    %edx,%ebx
  800d97:	89 d7                	mov    %edx,%edi
  800d99:	89 d6                	mov    %edx,%esi
  800d9b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	b8 04 00 00 00       	mov    $0x4,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	89 f7                	mov    %esi,%edi
  800dc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 17                	jle    800ddd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 04                	push   $0x4
  800dcc:	68 3f 2b 80 00       	push   $0x802b3f
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 5c 2b 80 00       	push   $0x802b5c
  800dd8:	e8 64 f5 ff ff       	call   800341 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	b8 05 00 00 00       	mov    $0x5,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dff:	8b 75 18             	mov    0x18(%ebp),%esi
  800e02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e04:	85 c0                	test   %eax,%eax
  800e06:	7e 17                	jle    800e1f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	50                   	push   %eax
  800e0c:	6a 05                	push   $0x5
  800e0e:	68 3f 2b 80 00       	push   $0x802b3f
  800e13:	6a 23                	push   $0x23
  800e15:	68 5c 2b 80 00       	push   $0x802b5c
  800e1a:	e8 22 f5 ff ff       	call   800341 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e35:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	89 df                	mov    %ebx,%edi
  800e42:	89 de                	mov    %ebx,%esi
  800e44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7e 17                	jle    800e61 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	50                   	push   %eax
  800e4e:	6a 06                	push   $0x6
  800e50:	68 3f 2b 80 00       	push   $0x802b3f
  800e55:	6a 23                	push   $0x23
  800e57:	68 5c 2b 80 00       	push   $0x802b5c
  800e5c:	e8 e0 f4 ff ff       	call   800341 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e77:	b8 08 00 00 00       	mov    $0x8,%eax
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	89 df                	mov    %ebx,%edi
  800e84:	89 de                	mov    %ebx,%esi
  800e86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 17                	jle    800ea3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	50                   	push   %eax
  800e90:	6a 08                	push   $0x8
  800e92:	68 3f 2b 80 00       	push   $0x802b3f
  800e97:	6a 23                	push   $0x23
  800e99:	68 5c 2b 80 00       	push   $0x802b5c
  800e9e:	e8 9e f4 ff ff       	call   800341 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb9:	b8 09 00 00 00       	mov    $0x9,%eax
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	89 df                	mov    %ebx,%edi
  800ec6:	89 de                	mov    %ebx,%esi
  800ec8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	7e 17                	jle    800ee5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	50                   	push   %eax
  800ed2:	6a 09                	push   $0x9
  800ed4:	68 3f 2b 80 00       	push   $0x802b3f
  800ed9:	6a 23                	push   $0x23
  800edb:	68 5c 2b 80 00       	push   $0x802b5c
  800ee0:	e8 5c f4 ff ff       	call   800341 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 17                	jle    800f27 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 0a                	push   $0xa
  800f16:	68 3f 2b 80 00       	push   $0x802b3f
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 5c 2b 80 00       	push   $0x802b5c
  800f22:	e8 1a f4 ff ff       	call   800341 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f35:	be 00 00 00 00       	mov    $0x0,%esi
  800f3a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f48:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f4b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f60:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	89 cb                	mov    %ecx,%ebx
  800f6a:	89 cf                	mov    %ecx,%edi
  800f6c:	89 ce                	mov    %ecx,%esi
  800f6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f70:	85 c0                	test   %eax,%eax
  800f72:	7e 17                	jle    800f8b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	50                   	push   %eax
  800f78:	6a 0d                	push   $0xd
  800f7a:	68 3f 2b 80 00       	push   $0x802b3f
  800f7f:	6a 23                	push   $0x23
  800f81:	68 5c 2b 80 00       	push   $0x802b5c
  800f86:	e8 b6 f3 ff ff       	call   800341 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	89 cb                	mov    %ecx,%ebx
  800fa8:	89 cf                	mov    %ecx,%edi
  800faa:	89 ce                	mov    %ecx,%esi
  800fac:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbe:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	89 cb                	mov    %ecx,%ebx
  800fc8:	89 cf                	mov    %ecx,%edi
  800fca:	89 ce                	mov    %ecx,%esi
  800fcc:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fde:	b8 10 00 00 00       	mov    $0x10,%eax
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	89 cb                	mov    %ecx,%ebx
  800fe8:	89 cf                	mov    %ecx,%edi
  800fea:	89 ce                	mov    %ecx,%esi
  800fec:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	53                   	push   %ebx
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ffd:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800fff:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801003:	74 11                	je     801016 <pgfault+0x23>
  801005:	89 d8                	mov    %ebx,%eax
  801007:	c1 e8 0c             	shr    $0xc,%eax
  80100a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801011:	f6 c4 08             	test   $0x8,%ah
  801014:	75 14                	jne    80102a <pgfault+0x37>
		panic("faulting access");
  801016:	83 ec 04             	sub    $0x4,%esp
  801019:	68 6a 2b 80 00       	push   $0x802b6a
  80101e:	6a 1f                	push   $0x1f
  801020:	68 7a 2b 80 00       	push   $0x802b7a
  801025:	e8 17 f3 ff ff       	call   800341 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80102a:	83 ec 04             	sub    $0x4,%esp
  80102d:	6a 07                	push   $0x7
  80102f:	68 00 f0 7f 00       	push   $0x7ff000
  801034:	6a 00                	push   $0x0
  801036:	e8 67 fd ff ff       	call   800da2 <sys_page_alloc>
	if (r < 0) {
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	79 12                	jns    801054 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801042:	50                   	push   %eax
  801043:	68 85 2b 80 00       	push   $0x802b85
  801048:	6a 2d                	push   $0x2d
  80104a:	68 7a 2b 80 00       	push   $0x802b7a
  80104f:	e8 ed f2 ff ff       	call   800341 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801054:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	68 00 10 00 00       	push   $0x1000
  801062:	53                   	push   %ebx
  801063:	68 00 f0 7f 00       	push   $0x7ff000
  801068:	e8 2c fb ff ff       	call   800b99 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80106d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801074:	53                   	push   %ebx
  801075:	6a 00                	push   $0x0
  801077:	68 00 f0 7f 00       	push   $0x7ff000
  80107c:	6a 00                	push   $0x0
  80107e:	e8 62 fd ff ff       	call   800de5 <sys_page_map>
	if (r < 0) {
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	79 12                	jns    80109c <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80108a:	50                   	push   %eax
  80108b:	68 85 2b 80 00       	push   $0x802b85
  801090:	6a 34                	push   $0x34
  801092:	68 7a 2b 80 00       	push   $0x802b7a
  801097:	e8 a5 f2 ff ff       	call   800341 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80109c:	83 ec 08             	sub    $0x8,%esp
  80109f:	68 00 f0 7f 00       	push   $0x7ff000
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 7c fd ff ff       	call   800e27 <sys_page_unmap>
	if (r < 0) {
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	79 12                	jns    8010c4 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8010b2:	50                   	push   %eax
  8010b3:	68 85 2b 80 00       	push   $0x802b85
  8010b8:	6a 38                	push   $0x38
  8010ba:	68 7a 2b 80 00       	push   $0x802b7a
  8010bf:	e8 7d f2 ff ff       	call   800341 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c7:	c9                   	leave  
  8010c8:	c3                   	ret    

008010c9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	57                   	push   %edi
  8010cd:	56                   	push   %esi
  8010ce:	53                   	push   %ebx
  8010cf:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8010d2:	68 f3 0f 80 00       	push   $0x800ff3
  8010d7:	e8 68 11 00 00       	call   802244 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010dc:	b8 07 00 00 00       	mov    $0x7,%eax
  8010e1:	cd 30                	int    $0x30
  8010e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	79 17                	jns    801104 <fork+0x3b>
		panic("fork fault %e");
  8010ed:	83 ec 04             	sub    $0x4,%esp
  8010f0:	68 9e 2b 80 00       	push   $0x802b9e
  8010f5:	68 85 00 00 00       	push   $0x85
  8010fa:	68 7a 2b 80 00       	push   $0x802b7a
  8010ff:	e8 3d f2 ff ff       	call   800341 <_panic>
  801104:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801106:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80110a:	75 24                	jne    801130 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80110c:	e8 53 fc ff ff       	call   800d64 <sys_getenvid>
  801111:	25 ff 03 00 00       	and    $0x3ff,%eax
  801116:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80111c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801121:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801126:	b8 00 00 00 00       	mov    $0x0,%eax
  80112b:	e9 64 01 00 00       	jmp    801294 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	6a 07                	push   $0x7
  801135:	68 00 f0 bf ee       	push   $0xeebff000
  80113a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113d:	e8 60 fc ff ff       	call   800da2 <sys_page_alloc>
  801142:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801145:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80114a:	89 d8                	mov    %ebx,%eax
  80114c:	c1 e8 16             	shr    $0x16,%eax
  80114f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801156:	a8 01                	test   $0x1,%al
  801158:	0f 84 fc 00 00 00    	je     80125a <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80115e:	89 d8                	mov    %ebx,%eax
  801160:	c1 e8 0c             	shr    $0xc,%eax
  801163:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	0f 84 e7 00 00 00    	je     80125a <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801173:	89 c6                	mov    %eax,%esi
  801175:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801178:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80117f:	f6 c6 04             	test   $0x4,%dh
  801182:	74 39                	je     8011bd <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801184:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	25 07 0e 00 00       	and    $0xe07,%eax
  801193:	50                   	push   %eax
  801194:	56                   	push   %esi
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	6a 00                	push   $0x0
  801199:	e8 47 fc ff ff       	call   800de5 <sys_page_map>
		if (r < 0) {
  80119e:	83 c4 20             	add    $0x20,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	0f 89 b1 00 00 00    	jns    80125a <fork+0x191>
		    	panic("sys page map fault %e");
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	68 ac 2b 80 00       	push   $0x802bac
  8011b1:	6a 55                	push   $0x55
  8011b3:	68 7a 2b 80 00       	push   $0x802b7a
  8011b8:	e8 84 f1 ff ff       	call   800341 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8011bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011c4:	f6 c2 02             	test   $0x2,%dl
  8011c7:	75 0c                	jne    8011d5 <fork+0x10c>
  8011c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d0:	f6 c4 08             	test   $0x8,%ah
  8011d3:	74 5b                	je     801230 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	68 05 08 00 00       	push   $0x805
  8011dd:	56                   	push   %esi
  8011de:	57                   	push   %edi
  8011df:	56                   	push   %esi
  8011e0:	6a 00                	push   $0x0
  8011e2:	e8 fe fb ff ff       	call   800de5 <sys_page_map>
		if (r < 0) {
  8011e7:	83 c4 20             	add    $0x20,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	79 14                	jns    801202 <fork+0x139>
		    	panic("sys page map fault %e");
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	68 ac 2b 80 00       	push   $0x802bac
  8011f6:	6a 5c                	push   $0x5c
  8011f8:	68 7a 2b 80 00       	push   $0x802b7a
  8011fd:	e8 3f f1 ff ff       	call   800341 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801202:	83 ec 0c             	sub    $0xc,%esp
  801205:	68 05 08 00 00       	push   $0x805
  80120a:	56                   	push   %esi
  80120b:	6a 00                	push   $0x0
  80120d:	56                   	push   %esi
  80120e:	6a 00                	push   $0x0
  801210:	e8 d0 fb ff ff       	call   800de5 <sys_page_map>
		if (r < 0) {
  801215:	83 c4 20             	add    $0x20,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	79 3e                	jns    80125a <fork+0x191>
		    	panic("sys page map fault %e");
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	68 ac 2b 80 00       	push   $0x802bac
  801224:	6a 60                	push   $0x60
  801226:	68 7a 2b 80 00       	push   $0x802b7a
  80122b:	e8 11 f1 ff ff       	call   800341 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	6a 05                	push   $0x5
  801235:	56                   	push   %esi
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	6a 00                	push   $0x0
  80123a:	e8 a6 fb ff ff       	call   800de5 <sys_page_map>
		if (r < 0) {
  80123f:	83 c4 20             	add    $0x20,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	79 14                	jns    80125a <fork+0x191>
		    	panic("sys page map fault %e");
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	68 ac 2b 80 00       	push   $0x802bac
  80124e:	6a 65                	push   $0x65
  801250:	68 7a 2b 80 00       	push   $0x802b7a
  801255:	e8 e7 f0 ff ff       	call   800341 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80125a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801260:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801266:	0f 85 de fe ff ff    	jne    80114a <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80126c:	a1 04 40 80 00       	mov    0x804004,%eax
  801271:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	50                   	push   %eax
  80127b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80127e:	57                   	push   %edi
  80127f:	e8 69 fc ff ff       	call   800eed <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	6a 02                	push   $0x2
  801289:	57                   	push   %edi
  80128a:	e8 da fb ff ff       	call   800e69 <sys_env_set_status>
	
	return envid;
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5f                   	pop    %edi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <sfork>:

envid_t
sfork(void)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8012ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8012af:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8012b4:	68 07 03 80 00       	push   $0x800307
  8012b9:	e8 d5 fc ff ff       	call   800f93 <sys_thread_create>

	return id;
}
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8012c6:	ff 75 08             	pushl  0x8(%ebp)
  8012c9:	e8 e5 fc ff ff       	call   800fb3 <sys_thread_free>
}
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    

008012d3 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 f2 fc ff ff       	call   800fd3 <sys_thread_join>
}
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	56                   	push   %esi
  8012ea:	53                   	push   %ebx
  8012eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8012f1:	83 ec 04             	sub    $0x4,%esp
  8012f4:	6a 07                	push   $0x7
  8012f6:	6a 00                	push   $0x0
  8012f8:	56                   	push   %esi
  8012f9:	e8 a4 fa ff ff       	call   800da2 <sys_page_alloc>
	if (r < 0) {
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	79 15                	jns    80131a <queue_append+0x34>
		panic("%e\n", r);
  801305:	50                   	push   %eax
  801306:	68 f2 2b 80 00       	push   $0x802bf2
  80130b:	68 d5 00 00 00       	push   $0xd5
  801310:	68 7a 2b 80 00       	push   $0x802b7a
  801315:	e8 27 f0 ff ff       	call   800341 <_panic>
	}	

	wt->envid = envid;
  80131a:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801320:	83 3b 00             	cmpl   $0x0,(%ebx)
  801323:	75 13                	jne    801338 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801325:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80132c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801333:	00 00 00 
  801336:	eb 1b                	jmp    801353 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801338:	8b 43 04             	mov    0x4(%ebx),%eax
  80133b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801342:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801349:	00 00 00 
		queue->last = wt;
  80134c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801353:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801356:	5b                   	pop    %ebx
  801357:	5e                   	pop    %esi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801363:	8b 02                	mov    (%edx),%eax
  801365:	85 c0                	test   %eax,%eax
  801367:	75 17                	jne    801380 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801369:	83 ec 04             	sub    $0x4,%esp
  80136c:	68 c2 2b 80 00       	push   $0x802bc2
  801371:	68 ec 00 00 00       	push   $0xec
  801376:	68 7a 2b 80 00       	push   $0x802b7a
  80137b:	e8 c1 ef ff ff       	call   800341 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801380:	8b 48 04             	mov    0x4(%eax),%ecx
  801383:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801385:	8b 00                	mov    (%eax),%eax
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	53                   	push   %ebx
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801393:	b8 01 00 00 00       	mov    $0x1,%eax
  801398:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80139b:	85 c0                	test   %eax,%eax
  80139d:	74 45                	je     8013e4 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80139f:	e8 c0 f9 ff ff       	call   800d64 <sys_getenvid>
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	83 c3 04             	add    $0x4,%ebx
  8013aa:	53                   	push   %ebx
  8013ab:	50                   	push   %eax
  8013ac:	e8 35 ff ff ff       	call   8012e6 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8013b1:	e8 ae f9 ff ff       	call   800d64 <sys_getenvid>
  8013b6:	83 c4 08             	add    $0x8,%esp
  8013b9:	6a 04                	push   $0x4
  8013bb:	50                   	push   %eax
  8013bc:	e8 a8 fa ff ff       	call   800e69 <sys_env_set_status>

		if (r < 0) {
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	79 15                	jns    8013dd <mutex_lock+0x54>
			panic("%e\n", r);
  8013c8:	50                   	push   %eax
  8013c9:	68 f2 2b 80 00       	push   $0x802bf2
  8013ce:	68 02 01 00 00       	push   $0x102
  8013d3:	68 7a 2b 80 00       	push   $0x802b7a
  8013d8:	e8 64 ef ff ff       	call   800341 <_panic>
		}
		sys_yield();
  8013dd:	e8 a1 f9 ff ff       	call   800d83 <sys_yield>
  8013e2:	eb 08                	jmp    8013ec <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8013e4:	e8 7b f9 ff ff       	call   800d64 <sys_getenvid>
  8013e9:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8013ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 04             	sub    $0x4,%esp
  8013f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8013fb:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8013ff:	74 36                	je     801437 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801401:	83 ec 0c             	sub    $0xc,%esp
  801404:	8d 43 04             	lea    0x4(%ebx),%eax
  801407:	50                   	push   %eax
  801408:	e8 4d ff ff ff       	call   80135a <queue_pop>
  80140d:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801410:	83 c4 08             	add    $0x8,%esp
  801413:	6a 02                	push   $0x2
  801415:	50                   	push   %eax
  801416:	e8 4e fa ff ff       	call   800e69 <sys_env_set_status>
		if (r < 0) {
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	79 1d                	jns    80143f <mutex_unlock+0x4e>
			panic("%e\n", r);
  801422:	50                   	push   %eax
  801423:	68 f2 2b 80 00       	push   $0x802bf2
  801428:	68 16 01 00 00       	push   $0x116
  80142d:	68 7a 2b 80 00       	push   $0x802b7a
  801432:	e8 0a ef ff ff       	call   800341 <_panic>
  801437:	b8 00 00 00 00       	mov    $0x0,%eax
  80143c:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80143f:	e8 3f f9 ff ff       	call   800d83 <sys_yield>
}
  801444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	53                   	push   %ebx
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801453:	e8 0c f9 ff ff       	call   800d64 <sys_getenvid>
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	6a 07                	push   $0x7
  80145d:	53                   	push   %ebx
  80145e:	50                   	push   %eax
  80145f:	e8 3e f9 ff ff       	call   800da2 <sys_page_alloc>
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	79 15                	jns    801480 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80146b:	50                   	push   %eax
  80146c:	68 dd 2b 80 00       	push   $0x802bdd
  801471:	68 23 01 00 00       	push   $0x123
  801476:	68 7a 2b 80 00       	push   $0x802b7a
  80147b:	e8 c1 ee ff ff       	call   800341 <_panic>
	}	
	mtx->locked = 0;
  801480:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801486:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80148d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801494:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80149b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
  8014a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8014a8:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8014ab:	eb 20                	jmp    8014cd <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	56                   	push   %esi
  8014b1:	e8 a4 fe ff ff       	call   80135a <queue_pop>
  8014b6:	83 c4 08             	add    $0x8,%esp
  8014b9:	6a 02                	push   $0x2
  8014bb:	50                   	push   %eax
  8014bc:	e8 a8 f9 ff ff       	call   800e69 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8014c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8014c4:	8b 40 04             	mov    0x4(%eax),%eax
  8014c7:	89 43 04             	mov    %eax,0x4(%ebx)
  8014ca:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8014cd:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8014d1:	75 da                	jne    8014ad <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	68 00 10 00 00       	push   $0x1000
  8014db:	6a 00                	push   $0x0
  8014dd:	53                   	push   %ebx
  8014de:	e8 01 f6 ff ff       	call   800ae4 <memset>
	mtx = NULL;
}
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	05 00 00 00 30       	add    $0x30000000,%eax
  8014f8:	c1 e8 0c             	shr    $0xc,%eax
}
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	05 00 00 00 30       	add    $0x30000000,%eax
  801508:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80150d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    

00801514 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80151f:	89 c2                	mov    %eax,%edx
  801521:	c1 ea 16             	shr    $0x16,%edx
  801524:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80152b:	f6 c2 01             	test   $0x1,%dl
  80152e:	74 11                	je     801541 <fd_alloc+0x2d>
  801530:	89 c2                	mov    %eax,%edx
  801532:	c1 ea 0c             	shr    $0xc,%edx
  801535:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80153c:	f6 c2 01             	test   $0x1,%dl
  80153f:	75 09                	jne    80154a <fd_alloc+0x36>
			*fd_store = fd;
  801541:	89 01                	mov    %eax,(%ecx)
			return 0;
  801543:	b8 00 00 00 00       	mov    $0x0,%eax
  801548:	eb 17                	jmp    801561 <fd_alloc+0x4d>
  80154a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80154f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801554:	75 c9                	jne    80151f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801556:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80155c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801569:	83 f8 1f             	cmp    $0x1f,%eax
  80156c:	77 36                	ja     8015a4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80156e:	c1 e0 0c             	shl    $0xc,%eax
  801571:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801576:	89 c2                	mov    %eax,%edx
  801578:	c1 ea 16             	shr    $0x16,%edx
  80157b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801582:	f6 c2 01             	test   $0x1,%dl
  801585:	74 24                	je     8015ab <fd_lookup+0x48>
  801587:	89 c2                	mov    %eax,%edx
  801589:	c1 ea 0c             	shr    $0xc,%edx
  80158c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801593:	f6 c2 01             	test   $0x1,%dl
  801596:	74 1a                	je     8015b2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801598:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159b:	89 02                	mov    %eax,(%edx)
	return 0;
  80159d:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a2:	eb 13                	jmp    8015b7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a9:	eb 0c                	jmp    8015b7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b0:	eb 05                	jmp    8015b7 <fd_lookup+0x54>
  8015b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c2:	ba 78 2c 80 00       	mov    $0x802c78,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015c7:	eb 13                	jmp    8015dc <dev_lookup+0x23>
  8015c9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015cc:	39 08                	cmp    %ecx,(%eax)
  8015ce:	75 0c                	jne    8015dc <dev_lookup+0x23>
			*dev = devtab[i];
  8015d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015da:	eb 31                	jmp    80160d <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015dc:	8b 02                	mov    (%edx),%eax
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	75 e7                	jne    8015c9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	51                   	push   %ecx
  8015f1:	50                   	push   %eax
  8015f2:	68 f8 2b 80 00       	push   $0x802bf8
  8015f7:	e8 1e ee ff ff       	call   80041a <cprintf>
	*dev = 0;
  8015fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 10             	sub    $0x10,%esp
  801617:	8b 75 08             	mov    0x8(%ebp),%esi
  80161a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801627:	c1 e8 0c             	shr    $0xc,%eax
  80162a:	50                   	push   %eax
  80162b:	e8 33 ff ff ff       	call   801563 <fd_lookup>
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 05                	js     80163c <fd_close+0x2d>
	    || fd != fd2)
  801637:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80163a:	74 0c                	je     801648 <fd_close+0x39>
		return (must_exist ? r : 0);
  80163c:	84 db                	test   %bl,%bl
  80163e:	ba 00 00 00 00       	mov    $0x0,%edx
  801643:	0f 44 c2             	cmove  %edx,%eax
  801646:	eb 41                	jmp    801689 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 36                	pushl  (%esi)
  801651:	e8 63 ff ff ff       	call   8015b9 <dev_lookup>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1a                	js     801679 <fd_close+0x6a>
		if (dev->dev_close)
  80165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801662:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801665:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80166a:	85 c0                	test   %eax,%eax
  80166c:	74 0b                	je     801679 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	56                   	push   %esi
  801672:	ff d0                	call   *%eax
  801674:	89 c3                	mov    %eax,%ebx
  801676:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	56                   	push   %esi
  80167d:	6a 00                	push   $0x0
  80167f:	e8 a3 f7 ff ff       	call   800e27 <sys_page_unmap>
	return r;
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	89 d8                	mov    %ebx,%eax
}
  801689:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	ff 75 08             	pushl  0x8(%ebp)
  80169d:	e8 c1 fe ff ff       	call   801563 <fd_lookup>
  8016a2:	83 c4 08             	add    $0x8,%esp
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 10                	js     8016b9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	6a 01                	push   $0x1
  8016ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b1:	e8 59 ff ff ff       	call   80160f <fd_close>
  8016b6:	83 c4 10             	add    $0x10,%esp
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <close_all>:

void
close_all(void)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	53                   	push   %ebx
  8016cb:	e8 c0 ff ff ff       	call   801690 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016d0:	83 c3 01             	add    $0x1,%ebx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	83 fb 20             	cmp    $0x20,%ebx
  8016d9:	75 ec                	jne    8016c7 <close_all+0xc>
		close(i);
}
  8016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	57                   	push   %edi
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 2c             	sub    $0x2c,%esp
  8016e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	ff 75 08             	pushl  0x8(%ebp)
  8016f3:	e8 6b fe ff ff       	call   801563 <fd_lookup>
  8016f8:	83 c4 08             	add    $0x8,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	0f 88 c1 00 00 00    	js     8017c4 <dup+0xe4>
		return r;
	close(newfdnum);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	56                   	push   %esi
  801707:	e8 84 ff ff ff       	call   801690 <close>

	newfd = INDEX2FD(newfdnum);
  80170c:	89 f3                	mov    %esi,%ebx
  80170e:	c1 e3 0c             	shl    $0xc,%ebx
  801711:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801717:	83 c4 04             	add    $0x4,%esp
  80171a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80171d:	e8 db fd ff ff       	call   8014fd <fd2data>
  801722:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801724:	89 1c 24             	mov    %ebx,(%esp)
  801727:	e8 d1 fd ff ff       	call   8014fd <fd2data>
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801732:	89 f8                	mov    %edi,%eax
  801734:	c1 e8 16             	shr    $0x16,%eax
  801737:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80173e:	a8 01                	test   $0x1,%al
  801740:	74 37                	je     801779 <dup+0x99>
  801742:	89 f8                	mov    %edi,%eax
  801744:	c1 e8 0c             	shr    $0xc,%eax
  801747:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80174e:	f6 c2 01             	test   $0x1,%dl
  801751:	74 26                	je     801779 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801753:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	25 07 0e 00 00       	and    $0xe07,%eax
  801762:	50                   	push   %eax
  801763:	ff 75 d4             	pushl  -0x2c(%ebp)
  801766:	6a 00                	push   $0x0
  801768:	57                   	push   %edi
  801769:	6a 00                	push   $0x0
  80176b:	e8 75 f6 ff ff       	call   800de5 <sys_page_map>
  801770:	89 c7                	mov    %eax,%edi
  801772:	83 c4 20             	add    $0x20,%esp
  801775:	85 c0                	test   %eax,%eax
  801777:	78 2e                	js     8017a7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801779:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80177c:	89 d0                	mov    %edx,%eax
  80177e:	c1 e8 0c             	shr    $0xc,%eax
  801781:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801788:	83 ec 0c             	sub    $0xc,%esp
  80178b:	25 07 0e 00 00       	and    $0xe07,%eax
  801790:	50                   	push   %eax
  801791:	53                   	push   %ebx
  801792:	6a 00                	push   $0x0
  801794:	52                   	push   %edx
  801795:	6a 00                	push   $0x0
  801797:	e8 49 f6 ff ff       	call   800de5 <sys_page_map>
  80179c:	89 c7                	mov    %eax,%edi
  80179e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8017a1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017a3:	85 ff                	test   %edi,%edi
  8017a5:	79 1d                	jns    8017c4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	53                   	push   %ebx
  8017ab:	6a 00                	push   $0x0
  8017ad:	e8 75 f6 ff ff       	call   800e27 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017b2:	83 c4 08             	add    $0x8,%esp
  8017b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017b8:	6a 00                	push   $0x0
  8017ba:	e8 68 f6 ff ff       	call   800e27 <sys_page_unmap>
	return r;
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	89 f8                	mov    %edi,%eax
}
  8017c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5f                   	pop    %edi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 14             	sub    $0x14,%esp
  8017d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	53                   	push   %ebx
  8017db:	e8 83 fd ff ff       	call   801563 <fd_lookup>
  8017e0:	83 c4 08             	add    $0x8,%esp
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 70                	js     801859 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ef:	50                   	push   %eax
  8017f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f3:	ff 30                	pushl  (%eax)
  8017f5:	e8 bf fd ff ff       	call   8015b9 <dev_lookup>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 4f                	js     801850 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801801:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801804:	8b 42 08             	mov    0x8(%edx),%eax
  801807:	83 e0 03             	and    $0x3,%eax
  80180a:	83 f8 01             	cmp    $0x1,%eax
  80180d:	75 24                	jne    801833 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180f:	a1 04 40 80 00       	mov    0x804004,%eax
  801814:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	53                   	push   %ebx
  80181e:	50                   	push   %eax
  80181f:	68 3c 2c 80 00       	push   $0x802c3c
  801824:	e8 f1 eb ff ff       	call   80041a <cprintf>
		return -E_INVAL;
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801831:	eb 26                	jmp    801859 <read+0x8d>
	}
	if (!dev->dev_read)
  801833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801836:	8b 40 08             	mov    0x8(%eax),%eax
  801839:	85 c0                	test   %eax,%eax
  80183b:	74 17                	je     801854 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	ff 75 10             	pushl  0x10(%ebp)
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	52                   	push   %edx
  801847:	ff d0                	call   *%eax
  801849:	89 c2                	mov    %eax,%edx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	eb 09                	jmp    801859 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801850:	89 c2                	mov    %eax,%edx
  801852:	eb 05                	jmp    801859 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801854:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801859:	89 d0                	mov    %edx,%eax
  80185b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	57                   	push   %edi
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80186f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801874:	eb 21                	jmp    801897 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	89 f0                	mov    %esi,%eax
  80187b:	29 d8                	sub    %ebx,%eax
  80187d:	50                   	push   %eax
  80187e:	89 d8                	mov    %ebx,%eax
  801880:	03 45 0c             	add    0xc(%ebp),%eax
  801883:	50                   	push   %eax
  801884:	57                   	push   %edi
  801885:	e8 42 ff ff ff       	call   8017cc <read>
		if (m < 0)
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 10                	js     8018a1 <readn+0x41>
			return m;
		if (m == 0)
  801891:	85 c0                	test   %eax,%eax
  801893:	74 0a                	je     80189f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801895:	01 c3                	add    %eax,%ebx
  801897:	39 f3                	cmp    %esi,%ebx
  801899:	72 db                	jb     801876 <readn+0x16>
  80189b:	89 d8                	mov    %ebx,%eax
  80189d:	eb 02                	jmp    8018a1 <readn+0x41>
  80189f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5f                   	pop    %edi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 14             	sub    $0x14,%esp
  8018b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b6:	50                   	push   %eax
  8018b7:	53                   	push   %ebx
  8018b8:	e8 a6 fc ff ff       	call   801563 <fd_lookup>
  8018bd:	83 c4 08             	add    $0x8,%esp
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 6b                	js     801931 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d0:	ff 30                	pushl  (%eax)
  8018d2:	e8 e2 fc ff ff       	call   8015b9 <dev_lookup>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 4a                	js     801928 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e5:	75 24                	jne    80190b <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ec:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018f2:	83 ec 04             	sub    $0x4,%esp
  8018f5:	53                   	push   %ebx
  8018f6:	50                   	push   %eax
  8018f7:	68 58 2c 80 00       	push   $0x802c58
  8018fc:	e8 19 eb ff ff       	call   80041a <cprintf>
		return -E_INVAL;
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801909:	eb 26                	jmp    801931 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80190b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190e:	8b 52 0c             	mov    0xc(%edx),%edx
  801911:	85 d2                	test   %edx,%edx
  801913:	74 17                	je     80192c <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	ff 75 10             	pushl  0x10(%ebp)
  80191b:	ff 75 0c             	pushl  0xc(%ebp)
  80191e:	50                   	push   %eax
  80191f:	ff d2                	call   *%edx
  801921:	89 c2                	mov    %eax,%edx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	eb 09                	jmp    801931 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801928:	89 c2                	mov    %eax,%edx
  80192a:	eb 05                	jmp    801931 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80192c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801931:	89 d0                	mov    %edx,%eax
  801933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <seek>:

int
seek(int fdnum, off_t offset)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	ff 75 08             	pushl  0x8(%ebp)
  801945:	e8 19 fc ff ff       	call   801563 <fd_lookup>
  80194a:	83 c4 08             	add    $0x8,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 0e                	js     80195f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801951:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801954:	8b 55 0c             	mov    0xc(%ebp),%edx
  801957:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80195a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	53                   	push   %ebx
  801965:	83 ec 14             	sub    $0x14,%esp
  801968:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196e:	50                   	push   %eax
  80196f:	53                   	push   %ebx
  801970:	e8 ee fb ff ff       	call   801563 <fd_lookup>
  801975:	83 c4 08             	add    $0x8,%esp
  801978:	89 c2                	mov    %eax,%edx
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 68                	js     8019e6 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801988:	ff 30                	pushl  (%eax)
  80198a:	e8 2a fc ff ff       	call   8015b9 <dev_lookup>
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	85 c0                	test   %eax,%eax
  801994:	78 47                	js     8019dd <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801996:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801999:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80199d:	75 24                	jne    8019c3 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80199f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019a4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8019aa:	83 ec 04             	sub    $0x4,%esp
  8019ad:	53                   	push   %ebx
  8019ae:	50                   	push   %eax
  8019af:	68 18 2c 80 00       	push   $0x802c18
  8019b4:	e8 61 ea ff ff       	call   80041a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019c1:	eb 23                	jmp    8019e6 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8019c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c6:	8b 52 18             	mov    0x18(%edx),%edx
  8019c9:	85 d2                	test   %edx,%edx
  8019cb:	74 14                	je     8019e1 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	ff 75 0c             	pushl  0xc(%ebp)
  8019d3:	50                   	push   %eax
  8019d4:	ff d2                	call   *%edx
  8019d6:	89 c2                	mov    %eax,%edx
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	eb 09                	jmp    8019e6 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019dd:	89 c2                	mov    %eax,%edx
  8019df:	eb 05                	jmp    8019e6 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019e6:	89 d0                	mov    %edx,%eax
  8019e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	53                   	push   %ebx
  8019f1:	83 ec 14             	sub    $0x14,%esp
  8019f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019fa:	50                   	push   %eax
  8019fb:	ff 75 08             	pushl  0x8(%ebp)
  8019fe:	e8 60 fb ff ff       	call   801563 <fd_lookup>
  801a03:	83 c4 08             	add    $0x8,%esp
  801a06:	89 c2                	mov    %eax,%edx
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 58                	js     801a64 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a12:	50                   	push   %eax
  801a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a16:	ff 30                	pushl  (%eax)
  801a18:	e8 9c fb ff ff       	call   8015b9 <dev_lookup>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 37                	js     801a5b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a27:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a2b:	74 32                	je     801a5f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a2d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a30:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a37:	00 00 00 
	stat->st_isdir = 0;
  801a3a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a41:	00 00 00 
	stat->st_dev = dev;
  801a44:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	53                   	push   %ebx
  801a4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a51:	ff 50 14             	call   *0x14(%eax)
  801a54:	89 c2                	mov    %eax,%edx
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	eb 09                	jmp    801a64 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	eb 05                	jmp    801a64 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a5f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a64:	89 d0                	mov    %edx,%eax
  801a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	6a 00                	push   $0x0
  801a75:	ff 75 08             	pushl  0x8(%ebp)
  801a78:	e8 e3 01 00 00       	call   801c60 <open>
  801a7d:	89 c3                	mov    %eax,%ebx
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 1b                	js     801aa1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a86:	83 ec 08             	sub    $0x8,%esp
  801a89:	ff 75 0c             	pushl  0xc(%ebp)
  801a8c:	50                   	push   %eax
  801a8d:	e8 5b ff ff ff       	call   8019ed <fstat>
  801a92:	89 c6                	mov    %eax,%esi
	close(fd);
  801a94:	89 1c 24             	mov    %ebx,(%esp)
  801a97:	e8 f4 fb ff ff       	call   801690 <close>
	return r;
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	89 f0                	mov    %esi,%eax
}
  801aa1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	89 c6                	mov    %eax,%esi
  801aaf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801ab1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ab8:	75 12                	jne    801acc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	6a 01                	push   $0x1
  801abf:	e8 ec 08 00 00       	call   8023b0 <ipc_find_env>
  801ac4:	a3 00 40 80 00       	mov    %eax,0x804000
  801ac9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801acc:	6a 07                	push   $0x7
  801ace:	68 00 50 80 00       	push   $0x805000
  801ad3:	56                   	push   %esi
  801ad4:	ff 35 00 40 80 00    	pushl  0x804000
  801ada:	e8 6f 08 00 00       	call   80234e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801adf:	83 c4 0c             	add    $0xc,%esp
  801ae2:	6a 00                	push   $0x0
  801ae4:	53                   	push   %ebx
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 e7 07 00 00       	call   8022d3 <ipc_recv>
}
  801aec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	8b 40 0c             	mov    0xc(%eax),%eax
  801aff:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b07:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b11:	b8 02 00 00 00       	mov    $0x2,%eax
  801b16:	e8 8d ff ff ff       	call   801aa8 <fsipc>
}
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	8b 40 0c             	mov    0xc(%eax),%eax
  801b29:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b33:	b8 06 00 00 00       	mov    $0x6,%eax
  801b38:	e8 6b ff ff ff       	call   801aa8 <fsipc>
}
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	53                   	push   %ebx
  801b43:	83 ec 04             	sub    $0x4,%esp
  801b46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b54:	ba 00 00 00 00       	mov    $0x0,%edx
  801b59:	b8 05 00 00 00       	mov    $0x5,%eax
  801b5e:	e8 45 ff ff ff       	call   801aa8 <fsipc>
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 2c                	js     801b93 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	68 00 50 80 00       	push   $0x805000
  801b6f:	53                   	push   %ebx
  801b70:	e8 2a ee ff ff       	call   80099f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b75:	a1 80 50 80 00       	mov    0x805080,%eax
  801b7a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b80:	a1 84 50 80 00       	mov    0x805084,%eax
  801b85:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  801ba4:	8b 52 0c             	mov    0xc(%edx),%edx
  801ba7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801bad:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bb2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bb7:	0f 47 c2             	cmova  %edx,%eax
  801bba:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801bbf:	50                   	push   %eax
  801bc0:	ff 75 0c             	pushl  0xc(%ebp)
  801bc3:	68 08 50 80 00       	push   $0x805008
  801bc8:	e8 64 ef ff ff       	call   800b31 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd2:	b8 04 00 00 00       	mov    $0x4,%eax
  801bd7:	e8 cc fe ff ff       	call   801aa8 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801be6:	8b 45 08             	mov    0x8(%ebp),%eax
  801be9:	8b 40 0c             	mov    0xc(%eax),%eax
  801bec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bf1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfc:	b8 03 00 00 00       	mov    $0x3,%eax
  801c01:	e8 a2 fe ff ff       	call   801aa8 <fsipc>
  801c06:	89 c3                	mov    %eax,%ebx
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 4b                	js     801c57 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c0c:	39 c6                	cmp    %eax,%esi
  801c0e:	73 16                	jae    801c26 <devfile_read+0x48>
  801c10:	68 88 2c 80 00       	push   $0x802c88
  801c15:	68 8f 2c 80 00       	push   $0x802c8f
  801c1a:	6a 7c                	push   $0x7c
  801c1c:	68 a4 2c 80 00       	push   $0x802ca4
  801c21:	e8 1b e7 ff ff       	call   800341 <_panic>
	assert(r <= PGSIZE);
  801c26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c2b:	7e 16                	jle    801c43 <devfile_read+0x65>
  801c2d:	68 af 2c 80 00       	push   $0x802caf
  801c32:	68 8f 2c 80 00       	push   $0x802c8f
  801c37:	6a 7d                	push   $0x7d
  801c39:	68 a4 2c 80 00       	push   $0x802ca4
  801c3e:	e8 fe e6 ff ff       	call   800341 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c43:	83 ec 04             	sub    $0x4,%esp
  801c46:	50                   	push   %eax
  801c47:	68 00 50 80 00       	push   $0x805000
  801c4c:	ff 75 0c             	pushl  0xc(%ebp)
  801c4f:	e8 dd ee ff ff       	call   800b31 <memmove>
	return r;
  801c54:	83 c4 10             	add    $0x10,%esp
}
  801c57:	89 d8                	mov    %ebx,%eax
  801c59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5c:	5b                   	pop    %ebx
  801c5d:	5e                   	pop    %esi
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	83 ec 20             	sub    $0x20,%esp
  801c67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c6a:	53                   	push   %ebx
  801c6b:	e8 f6 ec ff ff       	call   800966 <strlen>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c78:	7f 67                	jg     801ce1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c80:	50                   	push   %eax
  801c81:	e8 8e f8 ff ff       	call   801514 <fd_alloc>
  801c86:	83 c4 10             	add    $0x10,%esp
		return r;
  801c89:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 57                	js     801ce6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c8f:	83 ec 08             	sub    $0x8,%esp
  801c92:	53                   	push   %ebx
  801c93:	68 00 50 80 00       	push   $0x805000
  801c98:	e8 02 ed ff ff       	call   80099f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ca5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca8:	b8 01 00 00 00       	mov    $0x1,%eax
  801cad:	e8 f6 fd ff ff       	call   801aa8 <fsipc>
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	79 14                	jns    801ccf <open+0x6f>
		fd_close(fd, 0);
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	6a 00                	push   $0x0
  801cc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc3:	e8 47 f9 ff ff       	call   80160f <fd_close>
		return r;
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	89 da                	mov    %ebx,%edx
  801ccd:	eb 17                	jmp    801ce6 <open+0x86>
	}

	return fd2num(fd);
  801ccf:	83 ec 0c             	sub    $0xc,%esp
  801cd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd5:	e8 13 f8 ff ff       	call   8014ed <fd2num>
  801cda:	89 c2                	mov    %eax,%edx
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	eb 05                	jmp    801ce6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ce1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cf3:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf8:	b8 08 00 00 00       	mov    $0x8,%eax
  801cfd:	e8 a6 fd ff ff       	call   801aa8 <fsipc>
}
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
  801d09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff 75 08             	pushl  0x8(%ebp)
  801d12:	e8 e6 f7 ff ff       	call   8014fd <fd2data>
  801d17:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d19:	83 c4 08             	add    $0x8,%esp
  801d1c:	68 bb 2c 80 00       	push   $0x802cbb
  801d21:	53                   	push   %ebx
  801d22:	e8 78 ec ff ff       	call   80099f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d27:	8b 46 04             	mov    0x4(%esi),%eax
  801d2a:	2b 06                	sub    (%esi),%eax
  801d2c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d32:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d39:	00 00 00 
	stat->st_dev = &devpipe;
  801d3c:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801d43:	30 80 00 
	return 0;
}
  801d46:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4e:	5b                   	pop    %ebx
  801d4f:	5e                   	pop    %esi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	53                   	push   %ebx
  801d56:	83 ec 0c             	sub    $0xc,%esp
  801d59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d5c:	53                   	push   %ebx
  801d5d:	6a 00                	push   $0x0
  801d5f:	e8 c3 f0 ff ff       	call   800e27 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d64:	89 1c 24             	mov    %ebx,(%esp)
  801d67:	e8 91 f7 ff ff       	call   8014fd <fd2data>
  801d6c:	83 c4 08             	add    $0x8,%esp
  801d6f:	50                   	push   %eax
  801d70:	6a 00                	push   $0x0
  801d72:	e8 b0 f0 ff ff       	call   800e27 <sys_page_unmap>
}
  801d77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	83 ec 1c             	sub    $0x1c,%esp
  801d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d88:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8f:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	ff 75 e0             	pushl  -0x20(%ebp)
  801d9b:	e8 55 06 00 00       	call   8023f5 <pageref>
  801da0:	89 c3                	mov    %eax,%ebx
  801da2:	89 3c 24             	mov    %edi,(%esp)
  801da5:	e8 4b 06 00 00       	call   8023f5 <pageref>
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	39 c3                	cmp    %eax,%ebx
  801daf:	0f 94 c1             	sete   %cl
  801db2:	0f b6 c9             	movzbl %cl,%ecx
  801db5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801db8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dbe:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801dc4:	39 ce                	cmp    %ecx,%esi
  801dc6:	74 1e                	je     801de6 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801dc8:	39 c3                	cmp    %eax,%ebx
  801dca:	75 be                	jne    801d8a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dcc:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801dd2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dd5:	50                   	push   %eax
  801dd6:	56                   	push   %esi
  801dd7:	68 c2 2c 80 00       	push   $0x802cc2
  801ddc:	e8 39 e6 ff ff       	call   80041a <cprintf>
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	eb a4                	jmp    801d8a <_pipeisclosed+0xe>
	}
}
  801de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	57                   	push   %edi
  801df5:	56                   	push   %esi
  801df6:	53                   	push   %ebx
  801df7:	83 ec 28             	sub    $0x28,%esp
  801dfa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dfd:	56                   	push   %esi
  801dfe:	e8 fa f6 ff ff       	call   8014fd <fd2data>
  801e03:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	bf 00 00 00 00       	mov    $0x0,%edi
  801e0d:	eb 4b                	jmp    801e5a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e0f:	89 da                	mov    %ebx,%edx
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	e8 64 ff ff ff       	call   801d7c <_pipeisclosed>
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	75 48                	jne    801e64 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e1c:	e8 62 ef ff ff       	call   800d83 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e21:	8b 43 04             	mov    0x4(%ebx),%eax
  801e24:	8b 0b                	mov    (%ebx),%ecx
  801e26:	8d 51 20             	lea    0x20(%ecx),%edx
  801e29:	39 d0                	cmp    %edx,%eax
  801e2b:	73 e2                	jae    801e0f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e30:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e34:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e37:	89 c2                	mov    %eax,%edx
  801e39:	c1 fa 1f             	sar    $0x1f,%edx
  801e3c:	89 d1                	mov    %edx,%ecx
  801e3e:	c1 e9 1b             	shr    $0x1b,%ecx
  801e41:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e44:	83 e2 1f             	and    $0x1f,%edx
  801e47:	29 ca                	sub    %ecx,%edx
  801e49:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e4d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e51:	83 c0 01             	add    $0x1,%eax
  801e54:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e57:	83 c7 01             	add    $0x1,%edi
  801e5a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e5d:	75 c2                	jne    801e21 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e62:	eb 05                	jmp    801e69 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e6c:	5b                   	pop    %ebx
  801e6d:	5e                   	pop    %esi
  801e6e:	5f                   	pop    %edi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	57                   	push   %edi
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	83 ec 18             	sub    $0x18,%esp
  801e7a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e7d:	57                   	push   %edi
  801e7e:	e8 7a f6 ff ff       	call   8014fd <fd2data>
  801e83:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e8d:	eb 3d                	jmp    801ecc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e8f:	85 db                	test   %ebx,%ebx
  801e91:	74 04                	je     801e97 <devpipe_read+0x26>
				return i;
  801e93:	89 d8                	mov    %ebx,%eax
  801e95:	eb 44                	jmp    801edb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e97:	89 f2                	mov    %esi,%edx
  801e99:	89 f8                	mov    %edi,%eax
  801e9b:	e8 dc fe ff ff       	call   801d7c <_pipeisclosed>
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	75 32                	jne    801ed6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ea4:	e8 da ee ff ff       	call   800d83 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ea9:	8b 06                	mov    (%esi),%eax
  801eab:	3b 46 04             	cmp    0x4(%esi),%eax
  801eae:	74 df                	je     801e8f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eb0:	99                   	cltd   
  801eb1:	c1 ea 1b             	shr    $0x1b,%edx
  801eb4:	01 d0                	add    %edx,%eax
  801eb6:	83 e0 1f             	and    $0x1f,%eax
  801eb9:	29 d0                	sub    %edx,%eax
  801ebb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ec3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ec6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec9:	83 c3 01             	add    $0x1,%ebx
  801ecc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ecf:	75 d8                	jne    801ea9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ed1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed4:	eb 05                	jmp    801edb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ed6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    

00801ee3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	56                   	push   %esi
  801ee7:	53                   	push   %ebx
  801ee8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801eeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eee:	50                   	push   %eax
  801eef:	e8 20 f6 ff ff       	call   801514 <fd_alloc>
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	89 c2                	mov    %eax,%edx
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	0f 88 2c 01 00 00    	js     80202d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f01:	83 ec 04             	sub    $0x4,%esp
  801f04:	68 07 04 00 00       	push   $0x407
  801f09:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0c:	6a 00                	push   $0x0
  801f0e:	e8 8f ee ff ff       	call   800da2 <sys_page_alloc>
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	89 c2                	mov    %eax,%edx
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	0f 88 0d 01 00 00    	js     80202d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f26:	50                   	push   %eax
  801f27:	e8 e8 f5 ff ff       	call   801514 <fd_alloc>
  801f2c:	89 c3                	mov    %eax,%ebx
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	85 c0                	test   %eax,%eax
  801f33:	0f 88 e2 00 00 00    	js     80201b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	68 07 04 00 00       	push   $0x407
  801f41:	ff 75 f0             	pushl  -0x10(%ebp)
  801f44:	6a 00                	push   $0x0
  801f46:	e8 57 ee ff ff       	call   800da2 <sys_page_alloc>
  801f4b:	89 c3                	mov    %eax,%ebx
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 88 c3 00 00 00    	js     80201b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f58:	83 ec 0c             	sub    $0xc,%esp
  801f5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5e:	e8 9a f5 ff ff       	call   8014fd <fd2data>
  801f63:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f65:	83 c4 0c             	add    $0xc,%esp
  801f68:	68 07 04 00 00       	push   $0x407
  801f6d:	50                   	push   %eax
  801f6e:	6a 00                	push   $0x0
  801f70:	e8 2d ee ff ff       	call   800da2 <sys_page_alloc>
  801f75:	89 c3                	mov    %eax,%ebx
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	0f 88 89 00 00 00    	js     80200b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f82:	83 ec 0c             	sub    $0xc,%esp
  801f85:	ff 75 f0             	pushl  -0x10(%ebp)
  801f88:	e8 70 f5 ff ff       	call   8014fd <fd2data>
  801f8d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f94:	50                   	push   %eax
  801f95:	6a 00                	push   $0x0
  801f97:	56                   	push   %esi
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 46 ee ff ff       	call   800de5 <sys_page_map>
  801f9f:	89 c3                	mov    %eax,%ebx
  801fa1:	83 c4 20             	add    $0x20,%esp
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 55                	js     801ffd <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fa8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fbd:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd8:	e8 10 f5 ff ff       	call   8014ed <fd2num>
  801fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fe2:	83 c4 04             	add    $0x4,%esp
  801fe5:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe8:	e8 00 f5 ff ff       	call   8014ed <fd2num>
  801fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff0:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffb:	eb 30                	jmp    80202d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ffd:	83 ec 08             	sub    $0x8,%esp
  802000:	56                   	push   %esi
  802001:	6a 00                	push   $0x0
  802003:	e8 1f ee ff ff       	call   800e27 <sys_page_unmap>
  802008:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80200b:	83 ec 08             	sub    $0x8,%esp
  80200e:	ff 75 f0             	pushl  -0x10(%ebp)
  802011:	6a 00                	push   $0x0
  802013:	e8 0f ee ff ff       	call   800e27 <sys_page_unmap>
  802018:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80201b:	83 ec 08             	sub    $0x8,%esp
  80201e:	ff 75 f4             	pushl  -0xc(%ebp)
  802021:	6a 00                	push   $0x0
  802023:	e8 ff ed ff ff       	call   800e27 <sys_page_unmap>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80202d:	89 d0                	mov    %edx,%eax
  80202f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203f:	50                   	push   %eax
  802040:	ff 75 08             	pushl  0x8(%ebp)
  802043:	e8 1b f5 ff ff       	call   801563 <fd_lookup>
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 18                	js     802067 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80204f:	83 ec 0c             	sub    $0xc,%esp
  802052:	ff 75 f4             	pushl  -0xc(%ebp)
  802055:	e8 a3 f4 ff ff       	call   8014fd <fd2data>
	return _pipeisclosed(fd, p);
  80205a:	89 c2                	mov    %eax,%edx
  80205c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205f:	e8 18 fd ff ff       	call   801d7c <_pipeisclosed>
  802064:	83 c4 10             	add    $0x10,%esp
}
  802067:	c9                   	leave  
  802068:	c3                   	ret    

00802069 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	56                   	push   %esi
  80206d:	53                   	push   %ebx
  80206e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802071:	85 f6                	test   %esi,%esi
  802073:	75 16                	jne    80208b <wait+0x22>
  802075:	68 da 2c 80 00       	push   $0x802cda
  80207a:	68 8f 2c 80 00       	push   $0x802c8f
  80207f:	6a 09                	push   $0x9
  802081:	68 e5 2c 80 00       	push   $0x802ce5
  802086:	e8 b6 e2 ff ff       	call   800341 <_panic>
	e = &envs[ENVX(envid)];
  80208b:	89 f3                	mov    %esi,%ebx
  80208d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802093:	69 db d4 00 00 00    	imul   $0xd4,%ebx,%ebx
  802099:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80209f:	eb 05                	jmp    8020a6 <wait+0x3d>
		sys_yield();
  8020a1:	e8 dd ec ff ff       	call   800d83 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8020a6:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
  8020ac:	39 c6                	cmp    %eax,%esi
  8020ae:	75 0a                	jne    8020ba <wait+0x51>
  8020b0:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	75 e7                	jne    8020a1 <wait+0x38>
		sys_yield();
}
  8020ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    

008020c1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020d1:	68 f0 2c 80 00       	push   $0x802cf0
  8020d6:	ff 75 0c             	pushl  0xc(%ebp)
  8020d9:	e8 c1 e8 ff ff       	call   80099f <strcpy>
	return 0;
}
  8020de:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	57                   	push   %edi
  8020e9:	56                   	push   %esi
  8020ea:	53                   	push   %ebx
  8020eb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020f1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020f6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020fc:	eb 2d                	jmp    80212b <devcons_write+0x46>
		m = n - tot;
  8020fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802101:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802103:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802106:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80210b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80210e:	83 ec 04             	sub    $0x4,%esp
  802111:	53                   	push   %ebx
  802112:	03 45 0c             	add    0xc(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	57                   	push   %edi
  802117:	e8 15 ea ff ff       	call   800b31 <memmove>
		sys_cputs(buf, m);
  80211c:	83 c4 08             	add    $0x8,%esp
  80211f:	53                   	push   %ebx
  802120:	57                   	push   %edi
  802121:	e8 c0 eb ff ff       	call   800ce6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802126:	01 de                	add    %ebx,%esi
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	89 f0                	mov    %esi,%eax
  80212d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802130:	72 cc                	jb     8020fe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802135:	5b                   	pop    %ebx
  802136:	5e                   	pop    %esi
  802137:	5f                   	pop    %edi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    

0080213a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 08             	sub    $0x8,%esp
  802140:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802145:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802149:	74 2a                	je     802175 <devcons_read+0x3b>
  80214b:	eb 05                	jmp    802152 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80214d:	e8 31 ec ff ff       	call   800d83 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802152:	e8 ad eb ff ff       	call   800d04 <sys_cgetc>
  802157:	85 c0                	test   %eax,%eax
  802159:	74 f2                	je     80214d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80215b:	85 c0                	test   %eax,%eax
  80215d:	78 16                	js     802175 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80215f:	83 f8 04             	cmp    $0x4,%eax
  802162:	74 0c                	je     802170 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802164:	8b 55 0c             	mov    0xc(%ebp),%edx
  802167:	88 02                	mov    %al,(%edx)
	return 1;
  802169:	b8 01 00 00 00       	mov    $0x1,%eax
  80216e:	eb 05                	jmp    802175 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802170:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80217d:	8b 45 08             	mov    0x8(%ebp),%eax
  802180:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802183:	6a 01                	push   $0x1
  802185:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802188:	50                   	push   %eax
  802189:	e8 58 eb ff ff       	call   800ce6 <sys_cputs>
}
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	c9                   	leave  
  802192:	c3                   	ret    

00802193 <getchar>:

int
getchar(void)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802199:	6a 01                	push   $0x1
  80219b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80219e:	50                   	push   %eax
  80219f:	6a 00                	push   $0x0
  8021a1:	e8 26 f6 ff ff       	call   8017cc <read>
	if (r < 0)
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	78 0f                	js     8021bc <getchar+0x29>
		return r;
	if (r < 1)
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	7e 06                	jle    8021b7 <getchar+0x24>
		return -E_EOF;
	return c;
  8021b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021b5:	eb 05                	jmp    8021bc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021b7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021bc:	c9                   	leave  
  8021bd:	c3                   	ret    

008021be <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c7:	50                   	push   %eax
  8021c8:	ff 75 08             	pushl  0x8(%ebp)
  8021cb:	e8 93 f3 ff ff       	call   801563 <fd_lookup>
  8021d0:	83 c4 10             	add    $0x10,%esp
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	78 11                	js     8021e8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021da:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021e0:	39 10                	cmp    %edx,(%eax)
  8021e2:	0f 94 c0             	sete   %al
  8021e5:	0f b6 c0             	movzbl %al,%eax
}
  8021e8:	c9                   	leave  
  8021e9:	c3                   	ret    

008021ea <opencons>:

int
opencons(void)
{
  8021ea:	55                   	push   %ebp
  8021eb:	89 e5                	mov    %esp,%ebp
  8021ed:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f3:	50                   	push   %eax
  8021f4:	e8 1b f3 ff ff       	call   801514 <fd_alloc>
  8021f9:	83 c4 10             	add    $0x10,%esp
		return r;
  8021fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021fe:	85 c0                	test   %eax,%eax
  802200:	78 3e                	js     802240 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802202:	83 ec 04             	sub    $0x4,%esp
  802205:	68 07 04 00 00       	push   $0x407
  80220a:	ff 75 f4             	pushl  -0xc(%ebp)
  80220d:	6a 00                	push   $0x0
  80220f:	e8 8e eb ff ff       	call   800da2 <sys_page_alloc>
  802214:	83 c4 10             	add    $0x10,%esp
		return r;
  802217:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802219:	85 c0                	test   %eax,%eax
  80221b:	78 23                	js     802240 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80221d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802223:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802226:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802232:	83 ec 0c             	sub    $0xc,%esp
  802235:	50                   	push   %eax
  802236:	e8 b2 f2 ff ff       	call   8014ed <fd2num>
  80223b:	89 c2                	mov    %eax,%edx
  80223d:	83 c4 10             	add    $0x10,%esp
}
  802240:	89 d0                	mov    %edx,%eax
  802242:	c9                   	leave  
  802243:	c3                   	ret    

00802244 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802244:	55                   	push   %ebp
  802245:	89 e5                	mov    %esp,%ebp
  802247:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80224a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802251:	75 2a                	jne    80227d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802253:	83 ec 04             	sub    $0x4,%esp
  802256:	6a 07                	push   $0x7
  802258:	68 00 f0 bf ee       	push   $0xeebff000
  80225d:	6a 00                	push   $0x0
  80225f:	e8 3e eb ff ff       	call   800da2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	85 c0                	test   %eax,%eax
  802269:	79 12                	jns    80227d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80226b:	50                   	push   %eax
  80226c:	68 f2 2b 80 00       	push   $0x802bf2
  802271:	6a 23                	push   $0x23
  802273:	68 fc 2c 80 00       	push   $0x802cfc
  802278:	e8 c4 e0 ff ff       	call   800341 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80227d:	8b 45 08             	mov    0x8(%ebp),%eax
  802280:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802285:	83 ec 08             	sub    $0x8,%esp
  802288:	68 af 22 80 00       	push   $0x8022af
  80228d:	6a 00                	push   $0x0
  80228f:	e8 59 ec ff ff       	call   800eed <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	85 c0                	test   %eax,%eax
  802299:	79 12                	jns    8022ad <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80229b:	50                   	push   %eax
  80229c:	68 f2 2b 80 00       	push   $0x802bf2
  8022a1:	6a 2c                	push   $0x2c
  8022a3:	68 fc 2c 80 00       	push   $0x802cfc
  8022a8:	e8 94 e0 ff ff       	call   800341 <_panic>
	}
}
  8022ad:	c9                   	leave  
  8022ae:	c3                   	ret    

008022af <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022af:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022b0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022b5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022b7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8022ba:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8022be:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8022c3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8022c7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8022c9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8022cc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8022cd:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8022d0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8022d1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022d2:	c3                   	ret    

008022d3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	56                   	push   %esi
  8022d7:	53                   	push   %ebx
  8022d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	75 12                	jne    8022f7 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8022e5:	83 ec 0c             	sub    $0xc,%esp
  8022e8:	68 00 00 c0 ee       	push   $0xeec00000
  8022ed:	e8 60 ec ff ff       	call   800f52 <sys_ipc_recv>
  8022f2:	83 c4 10             	add    $0x10,%esp
  8022f5:	eb 0c                	jmp    802303 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8022f7:	83 ec 0c             	sub    $0xc,%esp
  8022fa:	50                   	push   %eax
  8022fb:	e8 52 ec ff ff       	call   800f52 <sys_ipc_recv>
  802300:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802303:	85 f6                	test   %esi,%esi
  802305:	0f 95 c1             	setne  %cl
  802308:	85 db                	test   %ebx,%ebx
  80230a:	0f 95 c2             	setne  %dl
  80230d:	84 d1                	test   %dl,%cl
  80230f:	74 09                	je     80231a <ipc_recv+0x47>
  802311:	89 c2                	mov    %eax,%edx
  802313:	c1 ea 1f             	shr    $0x1f,%edx
  802316:	84 d2                	test   %dl,%dl
  802318:	75 2d                	jne    802347 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80231a:	85 f6                	test   %esi,%esi
  80231c:	74 0d                	je     80232b <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80231e:	a1 04 40 80 00       	mov    0x804004,%eax
  802323:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802329:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80232b:	85 db                	test   %ebx,%ebx
  80232d:	74 0d                	je     80233c <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80232f:	a1 04 40 80 00       	mov    0x804004,%eax
  802334:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80233a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80233c:	a1 04 40 80 00       	mov    0x804004,%eax
  802341:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802347:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80234a:	5b                   	pop    %ebx
  80234b:	5e                   	pop    %esi
  80234c:	5d                   	pop    %ebp
  80234d:	c3                   	ret    

0080234e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 0c             	sub    $0xc,%esp
  802357:	8b 7d 08             	mov    0x8(%ebp),%edi
  80235a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80235d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802360:	85 db                	test   %ebx,%ebx
  802362:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802367:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80236a:	ff 75 14             	pushl  0x14(%ebp)
  80236d:	53                   	push   %ebx
  80236e:	56                   	push   %esi
  80236f:	57                   	push   %edi
  802370:	e8 ba eb ff ff       	call   800f2f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802375:	89 c2                	mov    %eax,%edx
  802377:	c1 ea 1f             	shr    $0x1f,%edx
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	84 d2                	test   %dl,%dl
  80237f:	74 17                	je     802398 <ipc_send+0x4a>
  802381:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802384:	74 12                	je     802398 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802386:	50                   	push   %eax
  802387:	68 0a 2d 80 00       	push   $0x802d0a
  80238c:	6a 47                	push   $0x47
  80238e:	68 18 2d 80 00       	push   $0x802d18
  802393:	e8 a9 df ff ff       	call   800341 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802398:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80239b:	75 07                	jne    8023a4 <ipc_send+0x56>
			sys_yield();
  80239d:	e8 e1 e9 ff ff       	call   800d83 <sys_yield>
  8023a2:	eb c6                	jmp    80236a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	75 c2                	jne    80236a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8023a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ab:	5b                   	pop    %ebx
  8023ac:	5e                   	pop    %esi
  8023ad:	5f                   	pop    %edi
  8023ae:	5d                   	pop    %ebp
  8023af:	c3                   	ret    

008023b0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023bb:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8023c1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023c7:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8023cd:	39 ca                	cmp    %ecx,%edx
  8023cf:	75 13                	jne    8023e4 <ipc_find_env+0x34>
			return envs[i].env_id;
  8023d1:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8023d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023dc:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8023e2:	eb 0f                	jmp    8023f3 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023e4:	83 c0 01             	add    $0x1,%eax
  8023e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ec:	75 cd                	jne    8023bb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    

008023f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	c1 e8 16             	shr    $0x16,%eax
  802400:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802407:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80240c:	f6 c1 01             	test   $0x1,%cl
  80240f:	74 1d                	je     80242e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802411:	c1 ea 0c             	shr    $0xc,%edx
  802414:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80241b:	f6 c2 01             	test   $0x1,%dl
  80241e:	74 0e                	je     80242e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802420:	c1 ea 0c             	shr    $0xc,%edx
  802423:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80242a:	ef 
  80242b:	0f b7 c0             	movzwl %ax,%eax
}
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <__udivdi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80243b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80243f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 f6                	test   %esi,%esi
  802449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80244d:	89 ca                	mov    %ecx,%edx
  80244f:	89 f8                	mov    %edi,%eax
  802451:	75 3d                	jne    802490 <__udivdi3+0x60>
  802453:	39 cf                	cmp    %ecx,%edi
  802455:	0f 87 c5 00 00 00    	ja     802520 <__udivdi3+0xf0>
  80245b:	85 ff                	test   %edi,%edi
  80245d:	89 fd                	mov    %edi,%ebp
  80245f:	75 0b                	jne    80246c <__udivdi3+0x3c>
  802461:	b8 01 00 00 00       	mov    $0x1,%eax
  802466:	31 d2                	xor    %edx,%edx
  802468:	f7 f7                	div    %edi
  80246a:	89 c5                	mov    %eax,%ebp
  80246c:	89 c8                	mov    %ecx,%eax
  80246e:	31 d2                	xor    %edx,%edx
  802470:	f7 f5                	div    %ebp
  802472:	89 c1                	mov    %eax,%ecx
  802474:	89 d8                	mov    %ebx,%eax
  802476:	89 cf                	mov    %ecx,%edi
  802478:	f7 f5                	div    %ebp
  80247a:	89 c3                	mov    %eax,%ebx
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	89 fa                	mov    %edi,%edx
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	90                   	nop
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	39 ce                	cmp    %ecx,%esi
  802492:	77 74                	ja     802508 <__udivdi3+0xd8>
  802494:	0f bd fe             	bsr    %esi,%edi
  802497:	83 f7 1f             	xor    $0x1f,%edi
  80249a:	0f 84 98 00 00 00    	je     802538 <__udivdi3+0x108>
  8024a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	89 c5                	mov    %eax,%ebp
  8024a9:	29 fb                	sub    %edi,%ebx
  8024ab:	d3 e6                	shl    %cl,%esi
  8024ad:	89 d9                	mov    %ebx,%ecx
  8024af:	d3 ed                	shr    %cl,%ebp
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	d3 e0                	shl    %cl,%eax
  8024b5:	09 ee                	or     %ebp,%esi
  8024b7:	89 d9                	mov    %ebx,%ecx
  8024b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024bd:	89 d5                	mov    %edx,%ebp
  8024bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c3:	d3 ed                	shr    %cl,%ebp
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e2                	shl    %cl,%edx
  8024c9:	89 d9                	mov    %ebx,%ecx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	09 c2                	or     %eax,%edx
  8024cf:	89 d0                	mov    %edx,%eax
  8024d1:	89 ea                	mov    %ebp,%edx
  8024d3:	f7 f6                	div    %esi
  8024d5:	89 d5                	mov    %edx,%ebp
  8024d7:	89 c3                	mov    %eax,%ebx
  8024d9:	f7 64 24 0c          	mull   0xc(%esp)
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	72 10                	jb     8024f1 <__udivdi3+0xc1>
  8024e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e6                	shl    %cl,%esi
  8024e9:	39 c6                	cmp    %eax,%esi
  8024eb:	73 07                	jae    8024f4 <__udivdi3+0xc4>
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	75 03                	jne    8024f4 <__udivdi3+0xc4>
  8024f1:	83 eb 01             	sub    $0x1,%ebx
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	89 fa                	mov    %edi,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	31 ff                	xor    %edi,%edi
  80250a:	31 db                	xor    %ebx,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d8                	mov    %ebx,%eax
  802522:	f7 f7                	div    %edi
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 c3                	mov    %eax,%ebx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 fa                	mov    %edi,%edx
  80252c:	83 c4 1c             	add    $0x1c,%esp
  80252f:	5b                   	pop    %ebx
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	39 ce                	cmp    %ecx,%esi
  80253a:	72 0c                	jb     802548 <__udivdi3+0x118>
  80253c:	31 db                	xor    %ebx,%ebx
  80253e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802542:	0f 87 34 ff ff ff    	ja     80247c <__udivdi3+0x4c>
  802548:	bb 01 00 00 00       	mov    $0x1,%ebx
  80254d:	e9 2a ff ff ff       	jmp    80247c <__udivdi3+0x4c>
  802552:	66 90                	xchg   %ax,%ax
  802554:	66 90                	xchg   %ax,%ax
  802556:	66 90                	xchg   %ax,%ax
  802558:	66 90                	xchg   %ax,%ax
  80255a:	66 90                	xchg   %ax,%ax
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <__umoddi3>:
  802560:	55                   	push   %ebp
  802561:	57                   	push   %edi
  802562:	56                   	push   %esi
  802563:	53                   	push   %ebx
  802564:	83 ec 1c             	sub    $0x1c,%esp
  802567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80256b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80256f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802577:	85 d2                	test   %edx,%edx
  802579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80257d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802581:	89 f3                	mov    %esi,%ebx
  802583:	89 3c 24             	mov    %edi,(%esp)
  802586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80258a:	75 1c                	jne    8025a8 <__umoddi3+0x48>
  80258c:	39 f7                	cmp    %esi,%edi
  80258e:	76 50                	jbe    8025e0 <__umoddi3+0x80>
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	f7 f7                	div    %edi
  802596:	89 d0                	mov    %edx,%eax
  802598:	31 d2                	xor    %edx,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	89 d0                	mov    %edx,%eax
  8025ac:	77 52                	ja     802600 <__umoddi3+0xa0>
  8025ae:	0f bd ea             	bsr    %edx,%ebp
  8025b1:	83 f5 1f             	xor    $0x1f,%ebp
  8025b4:	75 5a                	jne    802610 <__umoddi3+0xb0>
  8025b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ba:	0f 82 e0 00 00 00    	jb     8026a0 <__umoddi3+0x140>
  8025c0:	39 0c 24             	cmp    %ecx,(%esp)
  8025c3:	0f 86 d7 00 00 00    	jbe    8026a0 <__umoddi3+0x140>
  8025c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	85 ff                	test   %edi,%edi
  8025e2:	89 fd                	mov    %edi,%ebp
  8025e4:	75 0b                	jne    8025f1 <__umoddi3+0x91>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f7                	div    %edi
  8025ef:	89 c5                	mov    %eax,%ebp
  8025f1:	89 f0                	mov    %esi,%eax
  8025f3:	31 d2                	xor    %edx,%edx
  8025f5:	f7 f5                	div    %ebp
  8025f7:	89 c8                	mov    %ecx,%eax
  8025f9:	f7 f5                	div    %ebp
  8025fb:	89 d0                	mov    %edx,%eax
  8025fd:	eb 99                	jmp    802598 <__umoddi3+0x38>
  8025ff:	90                   	nop
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	83 c4 1c             	add    $0x1c,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    
  80260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802610:	8b 34 24             	mov    (%esp),%esi
  802613:	bf 20 00 00 00       	mov    $0x20,%edi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	29 ef                	sub    %ebp,%edi
  80261c:	d3 e0                	shl    %cl,%eax
  80261e:	89 f9                	mov    %edi,%ecx
  802620:	89 f2                	mov    %esi,%edx
  802622:	d3 ea                	shr    %cl,%edx
  802624:	89 e9                	mov    %ebp,%ecx
  802626:	09 c2                	or     %eax,%edx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 14 24             	mov    %edx,(%esp)
  80262d:	89 f2                	mov    %esi,%edx
  80262f:	d3 e2                	shl    %cl,%edx
  802631:	89 f9                	mov    %edi,%ecx
  802633:	89 54 24 04          	mov    %edx,0x4(%esp)
  802637:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	89 c6                	mov    %eax,%esi
  802641:	d3 e3                	shl    %cl,%ebx
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 d0                	mov    %edx,%eax
  802647:	d3 e8                	shr    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	09 d8                	or     %ebx,%eax
  80264d:	89 d3                	mov    %edx,%ebx
  80264f:	89 f2                	mov    %esi,%edx
  802651:	f7 34 24             	divl   (%esp)
  802654:	89 d6                	mov    %edx,%esi
  802656:	d3 e3                	shl    %cl,%ebx
  802658:	f7 64 24 04          	mull   0x4(%esp)
  80265c:	39 d6                	cmp    %edx,%esi
  80265e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802662:	89 d1                	mov    %edx,%ecx
  802664:	89 c3                	mov    %eax,%ebx
  802666:	72 08                	jb     802670 <__umoddi3+0x110>
  802668:	75 11                	jne    80267b <__umoddi3+0x11b>
  80266a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80266e:	73 0b                	jae    80267b <__umoddi3+0x11b>
  802670:	2b 44 24 04          	sub    0x4(%esp),%eax
  802674:	1b 14 24             	sbb    (%esp),%edx
  802677:	89 d1                	mov    %edx,%ecx
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80267f:	29 da                	sub    %ebx,%edx
  802681:	19 ce                	sbb    %ecx,%esi
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 f0                	mov    %esi,%eax
  802687:	d3 e0                	shl    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	d3 ea                	shr    %cl,%edx
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	d3 ee                	shr    %cl,%esi
  802691:	09 d0                	or     %edx,%eax
  802693:	89 f2                	mov    %esi,%edx
  802695:	83 c4 1c             	add    $0x1c,%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5f                   	pop    %edi
  80269b:	5d                   	pop    %ebp
  80269c:	c3                   	ret    
  80269d:	8d 76 00             	lea    0x0(%esi),%esi
  8026a0:	29 f9                	sub    %edi,%ecx
  8026a2:	19 d6                	sbb    %edx,%esi
  8026a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ac:	e9 18 ff ff ff       	jmp    8025c9 <__umoddi3+0x69>
