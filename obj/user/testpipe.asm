
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
  80003b:	c7 05 04 30 80 00 e0 	movl   $0x8024e0,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 b5 1c 00 00       	call   801d03 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 ec 24 80 00       	push   $0x8024ec
  80005d:	6a 0e                	push   $0xe
  80005f:	68 f5 24 80 00       	push   $0x8024f5
  800064:	e8 d8 02 00 00       	call   800341 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 5b 10 00 00       	call   8010c9 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 05 25 80 00       	push   $0x802505
  80007a:	6a 11                	push   $0x11
  80007c:	68 f5 24 80 00       	push   $0x8024f5
  800081:	e8 bb 02 00 00       	call   800341 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 be 00 00 00    	jne    80014c <umain+0x119>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800099:	83 ec 04             	sub    $0x4,%esp
  80009c:	ff 75 90             	pushl  -0x70(%ebp)
  80009f:	50                   	push   %eax
  8000a0:	68 0e 25 80 00       	push   $0x80250e
  8000a5:	e8 70 03 00 00       	call   80041a <cprintf>
		close(p[1]);
  8000aa:	83 c4 04             	add    $0x4,%esp
  8000ad:	ff 75 90             	pushl  -0x70(%ebp)
  8000b0:	e8 fb 13 00 00       	call   8014b0 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ba:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c6:	50                   	push   %eax
  8000c7:	68 2b 25 80 00       	push   $0x80252b
  8000cc:	e8 49 03 00 00       	call   80041a <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000d1:	83 c4 0c             	add    $0xc,%esp
  8000d4:	6a 63                	push   $0x63
  8000d6:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d9:	50                   	push   %eax
  8000da:	ff 75 8c             	pushl  -0x74(%ebp)
  8000dd:	e8 9e 15 00 00       	call   801680 <readn>
  8000e2:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	79 12                	jns    8000fd <umain+0xca>
			panic("read: %e", i);
  8000eb:	50                   	push   %eax
  8000ec:	68 48 25 80 00       	push   $0x802548
  8000f1:	6a 19                	push   $0x19
  8000f3:	68 f5 24 80 00       	push   $0x8024f5
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
  80011e:	68 51 25 80 00       	push   $0x802551
  800123:	e8 f2 02 00 00       	call   80041a <cprintf>
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	eb 15                	jmp    800142 <umain+0x10f>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80012d:	83 ec 04             	sub    $0x4,%esp
  800130:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	56                   	push   %esi
  800135:	68 6d 25 80 00       	push   $0x80256d
  80013a:	e8 db 02 00 00       	call   80041a <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
		exit();
  800142:	e8 e0 01 00 00       	call   800327 <exit>
  800147:	e9 9a 00 00 00       	jmp    8001e6 <umain+0x1b3>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80014c:	a1 04 40 80 00       	mov    0x804004,%eax
  800151:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	ff 75 8c             	pushl  -0x74(%ebp)
  80015d:	50                   	push   %eax
  80015e:	68 0e 25 80 00       	push   $0x80250e
  800163:	e8 b2 02 00 00       	call   80041a <cprintf>
		close(p[0]);
  800168:	83 c4 04             	add    $0x4,%esp
  80016b:	ff 75 8c             	pushl  -0x74(%ebp)
  80016e:	e8 3d 13 00 00       	call   8014b0 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  800173:	a1 04 40 80 00       	mov    0x804004,%eax
  800178:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80017e:	83 c4 0c             	add    $0xc,%esp
  800181:	ff 75 90             	pushl  -0x70(%ebp)
  800184:	50                   	push   %eax
  800185:	68 80 25 80 00       	push   $0x802580
  80018a:	e8 8b 02 00 00       	call   80041a <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  80018f:	83 c4 04             	add    $0x4,%esp
  800192:	ff 35 00 30 80 00    	pushl  0x803000
  800198:	e8 c9 07 00 00       	call   800966 <strlen>
  80019d:	83 c4 0c             	add    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	ff 35 00 30 80 00    	pushl  0x803000
  8001a7:	ff 75 90             	pushl  -0x70(%ebp)
  8001aa:	e8 1a 15 00 00       	call   8016c9 <write>
  8001af:	89 c6                	mov    %eax,%esi
  8001b1:	83 c4 04             	add    $0x4,%esp
  8001b4:	ff 35 00 30 80 00    	pushl  0x803000
  8001ba:	e8 a7 07 00 00       	call   800966 <strlen>
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	39 c6                	cmp    %eax,%esi
  8001c4:	74 12                	je     8001d8 <umain+0x1a5>
			panic("write: %e", i);
  8001c6:	56                   	push   %esi
  8001c7:	68 9d 25 80 00       	push   $0x80259d
  8001cc:	6a 25                	push   $0x25
  8001ce:	68 f5 24 80 00       	push   $0x8024f5
  8001d3:	e8 69 01 00 00       	call   800341 <_panic>
		close(p[1]);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 90             	pushl  -0x70(%ebp)
  8001de:	e8 cd 12 00 00       	call   8014b0 <close>
  8001e3:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	53                   	push   %ebx
  8001ea:	e8 9a 1c 00 00       	call   801e89 <wait>

	binaryname = "pipewriteeof";
  8001ef:	c7 05 04 30 80 00 a7 	movl   $0x8025a7,0x803004
  8001f6:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001f9:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 ff 1a 00 00       	call   801d03 <pipe>
  800204:	89 c6                	mov    %eax,%esi
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	85 c0                	test   %eax,%eax
  80020b:	79 12                	jns    80021f <umain+0x1ec>
		panic("pipe: %e", i);
  80020d:	50                   	push   %eax
  80020e:	68 ec 24 80 00       	push   $0x8024ec
  800213:	6a 2c                	push   $0x2c
  800215:	68 f5 24 80 00       	push   $0x8024f5
  80021a:	e8 22 01 00 00       	call   800341 <_panic>

	if ((pid = fork()) < 0)
  80021f:	e8 a5 0e 00 00       	call   8010c9 <fork>
  800224:	89 c3                	mov    %eax,%ebx
  800226:	85 c0                	test   %eax,%eax
  800228:	79 12                	jns    80023c <umain+0x209>
		panic("fork: %e", i);
  80022a:	56                   	push   %esi
  80022b:	68 05 25 80 00       	push   $0x802505
  800230:	6a 2f                	push   $0x2f
  800232:	68 f5 24 80 00       	push   $0x8024f5
  800237:	e8 05 01 00 00       	call   800341 <_panic>

	if (pid == 0) {
  80023c:	85 c0                	test   %eax,%eax
  80023e:	75 4a                	jne    80028a <umain+0x257>
		close(p[0]);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 8c             	pushl  -0x74(%ebp)
  800246:	e8 65 12 00 00       	call   8014b0 <close>
  80024b:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 b4 25 80 00       	push   $0x8025b4
  800256:	e8 bf 01 00 00       	call   80041a <cprintf>
			if (write(p[1], "x", 1) != 1)
  80025b:	83 c4 0c             	add    $0xc,%esp
  80025e:	6a 01                	push   $0x1
  800260:	68 b6 25 80 00       	push   $0x8025b6
  800265:	ff 75 90             	pushl  -0x70(%ebp)
  800268:	e8 5c 14 00 00       	call   8016c9 <write>
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	83 f8 01             	cmp    $0x1,%eax
  800273:	74 d9                	je     80024e <umain+0x21b>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	68 b8 25 80 00       	push   $0x8025b8
  80027d:	e8 98 01 00 00       	call   80041a <cprintf>
		exit();
  800282:	e8 a0 00 00 00       	call   800327 <exit>
  800287:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	ff 75 8c             	pushl  -0x74(%ebp)
  800290:	e8 1b 12 00 00       	call   8014b0 <close>
	close(p[1]);
  800295:	83 c4 04             	add    $0x4,%esp
  800298:	ff 75 90             	pushl  -0x70(%ebp)
  80029b:	e8 10 12 00 00       	call   8014b0 <close>
	wait(pid);
  8002a0:	89 1c 24             	mov    %ebx,(%esp)
  8002a3:	e8 e1 1b 00 00       	call   801e89 <wait>

	cprintf("pipe tests passed\n");
  8002a8:	c7 04 24 d5 25 80 00 	movl   $0x8025d5,(%esp)
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
  8002d3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8002d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002de:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80032d:	e8 a9 11 00 00       	call   8014db <close_all>
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
  80035f:	68 38 26 80 00       	push   $0x802638
  800364:	e8 b1 00 00 00       	call   80041a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800369:	83 c4 18             	add    $0x18,%esp
  80036c:	53                   	push   %ebx
  80036d:	ff 75 10             	pushl  0x10(%ebp)
  800370:	e8 54 00 00 00       	call   8003c9 <vcprintf>
	cprintf("\n");
  800375:	c7 04 24 29 25 80 00 	movl   $0x802529,(%esp)
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
  80047d:	e8 ce 1d 00 00       	call   802250 <__udivdi3>
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
  8004c0:	e8 bb 1e 00 00       	call   802380 <__umoddi3>
  8004c5:	83 c4 14             	add    $0x14,%esp
  8004c8:	0f be 80 5b 26 80 00 	movsbl 0x80265b(%eax),%eax
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
  8005c4:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
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
  800688:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	75 18                	jne    8006ab <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800693:	50                   	push   %eax
  800694:	68 73 26 80 00       	push   $0x802673
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
  8006ac:	68 b1 2a 80 00       	push   $0x802ab1
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
  8006d0:	b8 6c 26 80 00       	mov    $0x80266c,%eax
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
  800d4b:	68 5f 29 80 00       	push   $0x80295f
  800d50:	6a 23                	push   $0x23
  800d52:	68 7c 29 80 00       	push   $0x80297c
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
  800dcc:	68 5f 29 80 00       	push   $0x80295f
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 7c 29 80 00       	push   $0x80297c
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
  800e0e:	68 5f 29 80 00       	push   $0x80295f
  800e13:	6a 23                	push   $0x23
  800e15:	68 7c 29 80 00       	push   $0x80297c
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
  800e50:	68 5f 29 80 00       	push   $0x80295f
  800e55:	6a 23                	push   $0x23
  800e57:	68 7c 29 80 00       	push   $0x80297c
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
  800e92:	68 5f 29 80 00       	push   $0x80295f
  800e97:	6a 23                	push   $0x23
  800e99:	68 7c 29 80 00       	push   $0x80297c
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
  800ed4:	68 5f 29 80 00       	push   $0x80295f
  800ed9:	6a 23                	push   $0x23
  800edb:	68 7c 29 80 00       	push   $0x80297c
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
  800f16:	68 5f 29 80 00       	push   $0x80295f
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 7c 29 80 00       	push   $0x80297c
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
  800f7a:	68 5f 29 80 00       	push   $0x80295f
  800f7f:	6a 23                	push   $0x23
  800f81:	68 7c 29 80 00       	push   $0x80297c
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
  801019:	68 8a 29 80 00       	push   $0x80298a
  80101e:	6a 1e                	push   $0x1e
  801020:	68 9a 29 80 00       	push   $0x80299a
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
  801043:	68 a5 29 80 00       	push   $0x8029a5
  801048:	6a 2c                	push   $0x2c
  80104a:	68 9a 29 80 00       	push   $0x80299a
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
  80108b:	68 a5 29 80 00       	push   $0x8029a5
  801090:	6a 33                	push   $0x33
  801092:	68 9a 29 80 00       	push   $0x80299a
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
  8010b3:	68 a5 29 80 00       	push   $0x8029a5
  8010b8:	6a 37                	push   $0x37
  8010ba:	68 9a 29 80 00       	push   $0x80299a
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
  8010d7:	e8 88 0f 00 00       	call   802064 <set_pgfault_handler>
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
  8010f0:	68 be 29 80 00       	push   $0x8029be
  8010f5:	68 84 00 00 00       	push   $0x84
  8010fa:	68 9a 29 80 00       	push   $0x80299a
  8010ff:	e8 3d f2 ff ff       	call   800341 <_panic>
  801104:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801106:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80110a:	75 24                	jne    801130 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80110c:	e8 53 fc ff ff       	call   800d64 <sys_getenvid>
  801111:	25 ff 03 00 00       	and    $0x3ff,%eax
  801116:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8011ac:	68 cc 29 80 00       	push   $0x8029cc
  8011b1:	6a 54                	push   $0x54
  8011b3:	68 9a 29 80 00       	push   $0x80299a
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
  8011f1:	68 cc 29 80 00       	push   $0x8029cc
  8011f6:	6a 5b                	push   $0x5b
  8011f8:	68 9a 29 80 00       	push   $0x80299a
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
  80121f:	68 cc 29 80 00       	push   $0x8029cc
  801224:	6a 5f                	push   $0x5f
  801226:	68 9a 29 80 00       	push   $0x80299a
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
  801249:	68 cc 29 80 00       	push   $0x8029cc
  80124e:	6a 64                	push   $0x64
  801250:	68 9a 29 80 00       	push   $0x80299a
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
  801271:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
  8012ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8012ae:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	53                   	push   %ebx
  8012b8:	68 e4 29 80 00       	push   $0x8029e4
  8012bd:	e8 58 f1 ff ff       	call   80041a <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8012c2:	c7 04 24 07 03 80 00 	movl   $0x800307,(%esp)
  8012c9:	e8 c5 fc ff ff       	call   800f93 <sys_thread_create>
  8012ce:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012d0:	83 c4 08             	add    $0x8,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	68 e4 29 80 00       	push   $0x8029e4
  8012d9:	e8 3c f1 ff ff       	call   80041a <cprintf>
	return id;
}
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5e                   	pop    %esi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8012ed:	ff 75 08             	pushl  0x8(%ebp)
  8012f0:	e8 be fc ff ff       	call   800fb3 <sys_thread_free>
}
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801300:	ff 75 08             	pushl  0x8(%ebp)
  801303:	e8 cb fc ff ff       	call   800fd3 <sys_thread_join>
}
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	05 00 00 00 30       	add    $0x30000000,%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
}
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	05 00 00 00 30       	add    $0x30000000,%eax
  801328:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80132d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80133f:	89 c2                	mov    %eax,%edx
  801341:	c1 ea 16             	shr    $0x16,%edx
  801344:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134b:	f6 c2 01             	test   $0x1,%dl
  80134e:	74 11                	je     801361 <fd_alloc+0x2d>
  801350:	89 c2                	mov    %eax,%edx
  801352:	c1 ea 0c             	shr    $0xc,%edx
  801355:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135c:	f6 c2 01             	test   $0x1,%dl
  80135f:	75 09                	jne    80136a <fd_alloc+0x36>
			*fd_store = fd;
  801361:	89 01                	mov    %eax,(%ecx)
			return 0;
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	eb 17                	jmp    801381 <fd_alloc+0x4d>
  80136a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80136f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801374:	75 c9                	jne    80133f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801376:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80137c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801389:	83 f8 1f             	cmp    $0x1f,%eax
  80138c:	77 36                	ja     8013c4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80138e:	c1 e0 0c             	shl    $0xc,%eax
  801391:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801396:	89 c2                	mov    %eax,%edx
  801398:	c1 ea 16             	shr    $0x16,%edx
  80139b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a2:	f6 c2 01             	test   $0x1,%dl
  8013a5:	74 24                	je     8013cb <fd_lookup+0x48>
  8013a7:	89 c2                	mov    %eax,%edx
  8013a9:	c1 ea 0c             	shr    $0xc,%edx
  8013ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b3:	f6 c2 01             	test   $0x1,%dl
  8013b6:	74 1a                	je     8013d2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013bb:	89 02                	mov    %eax,(%edx)
	return 0;
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	eb 13                	jmp    8013d7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c9:	eb 0c                	jmp    8013d7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d0:	eb 05                	jmp    8013d7 <fd_lookup+0x54>
  8013d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e2:	ba 88 2a 80 00       	mov    $0x802a88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e7:	eb 13                	jmp    8013fc <dev_lookup+0x23>
  8013e9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ec:	39 08                	cmp    %ecx,(%eax)
  8013ee:	75 0c                	jne    8013fc <dev_lookup+0x23>
			*dev = devtab[i];
  8013f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fa:	eb 31                	jmp    80142d <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013fc:	8b 02                	mov    (%edx),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	75 e7                	jne    8013e9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801402:	a1 04 40 80 00       	mov    0x804004,%eax
  801407:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	51                   	push   %ecx
  801411:	50                   	push   %eax
  801412:	68 08 2a 80 00       	push   $0x802a08
  801417:	e8 fe ef ff ff       	call   80041a <cprintf>
	*dev = 0;
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 10             	sub    $0x10,%esp
  801437:	8b 75 08             	mov    0x8(%ebp),%esi
  80143a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
  80144a:	50                   	push   %eax
  80144b:	e8 33 ff ff ff       	call   801383 <fd_lookup>
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 05                	js     80145c <fd_close+0x2d>
	    || fd != fd2)
  801457:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145a:	74 0c                	je     801468 <fd_close+0x39>
		return (must_exist ? r : 0);
  80145c:	84 db                	test   %bl,%bl
  80145e:	ba 00 00 00 00       	mov    $0x0,%edx
  801463:	0f 44 c2             	cmove  %edx,%eax
  801466:	eb 41                	jmp    8014a9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	ff 36                	pushl  (%esi)
  801471:	e8 63 ff ff ff       	call   8013d9 <dev_lookup>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 1a                	js     801499 <fd_close+0x6a>
		if (dev->dev_close)
  80147f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801482:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801485:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80148a:	85 c0                	test   %eax,%eax
  80148c:	74 0b                	je     801499 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	56                   	push   %esi
  801492:	ff d0                	call   *%eax
  801494:	89 c3                	mov    %eax,%ebx
  801496:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	56                   	push   %esi
  80149d:	6a 00                	push   $0x0
  80149f:	e8 83 f9 ff ff       	call   800e27 <sys_page_unmap>
	return r;
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	89 d8                	mov    %ebx,%eax
}
  8014a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	ff 75 08             	pushl  0x8(%ebp)
  8014bd:	e8 c1 fe ff ff       	call   801383 <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 10                	js     8014d9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	6a 01                	push   $0x1
  8014ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d1:	e8 59 ff ff ff       	call   80142f <fd_close>
  8014d6:	83 c4 10             	add    $0x10,%esp
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <close_all>:

void
close_all(void)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014e7:	83 ec 0c             	sub    $0xc,%esp
  8014ea:	53                   	push   %ebx
  8014eb:	e8 c0 ff ff ff       	call   8014b0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f0:	83 c3 01             	add    $0x1,%ebx
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	83 fb 20             	cmp    $0x20,%ebx
  8014f9:	75 ec                	jne    8014e7 <close_all+0xc>
		close(i);
}
  8014fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	53                   	push   %ebx
  801506:	83 ec 2c             	sub    $0x2c,%esp
  801509:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80150c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	ff 75 08             	pushl  0x8(%ebp)
  801513:	e8 6b fe ff ff       	call   801383 <fd_lookup>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	0f 88 c1 00 00 00    	js     8015e4 <dup+0xe4>
		return r;
	close(newfdnum);
  801523:	83 ec 0c             	sub    $0xc,%esp
  801526:	56                   	push   %esi
  801527:	e8 84 ff ff ff       	call   8014b0 <close>

	newfd = INDEX2FD(newfdnum);
  80152c:	89 f3                	mov    %esi,%ebx
  80152e:	c1 e3 0c             	shl    $0xc,%ebx
  801531:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801537:	83 c4 04             	add    $0x4,%esp
  80153a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153d:	e8 db fd ff ff       	call   80131d <fd2data>
  801542:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801544:	89 1c 24             	mov    %ebx,(%esp)
  801547:	e8 d1 fd ff ff       	call   80131d <fd2data>
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801552:	89 f8                	mov    %edi,%eax
  801554:	c1 e8 16             	shr    $0x16,%eax
  801557:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155e:	a8 01                	test   $0x1,%al
  801560:	74 37                	je     801599 <dup+0x99>
  801562:	89 f8                	mov    %edi,%eax
  801564:	c1 e8 0c             	shr    $0xc,%eax
  801567:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80156e:	f6 c2 01             	test   $0x1,%dl
  801571:	74 26                	je     801599 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801573:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	25 07 0e 00 00       	and    $0xe07,%eax
  801582:	50                   	push   %eax
  801583:	ff 75 d4             	pushl  -0x2c(%ebp)
  801586:	6a 00                	push   $0x0
  801588:	57                   	push   %edi
  801589:	6a 00                	push   $0x0
  80158b:	e8 55 f8 ff ff       	call   800de5 <sys_page_map>
  801590:	89 c7                	mov    %eax,%edi
  801592:	83 c4 20             	add    $0x20,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 2e                	js     8015c7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801599:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159c:	89 d0                	mov    %edx,%eax
  80159e:	c1 e8 0c             	shr    $0xc,%eax
  8015a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a8:	83 ec 0c             	sub    $0xc,%esp
  8015ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b0:	50                   	push   %eax
  8015b1:	53                   	push   %ebx
  8015b2:	6a 00                	push   $0x0
  8015b4:	52                   	push   %edx
  8015b5:	6a 00                	push   $0x0
  8015b7:	e8 29 f8 ff ff       	call   800de5 <sys_page_map>
  8015bc:	89 c7                	mov    %eax,%edi
  8015be:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015c1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c3:	85 ff                	test   %edi,%edi
  8015c5:	79 1d                	jns    8015e4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	6a 00                	push   $0x0
  8015cd:	e8 55 f8 ff ff       	call   800e27 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d8:	6a 00                	push   $0x0
  8015da:	e8 48 f8 ff ff       	call   800e27 <sys_page_unmap>
	return r;
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	89 f8                	mov    %edi,%eax
}
  8015e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 14             	sub    $0x14,%esp
  8015f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	53                   	push   %ebx
  8015fb:	e8 83 fd ff ff       	call   801383 <fd_lookup>
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	89 c2                	mov    %eax,%edx
  801605:	85 c0                	test   %eax,%eax
  801607:	78 70                	js     801679 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	ff 30                	pushl  (%eax)
  801615:	e8 bf fd ff ff       	call   8013d9 <dev_lookup>
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 4f                	js     801670 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801621:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801624:	8b 42 08             	mov    0x8(%edx),%eax
  801627:	83 e0 03             	and    $0x3,%eax
  80162a:	83 f8 01             	cmp    $0x1,%eax
  80162d:	75 24                	jne    801653 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80162f:	a1 04 40 80 00       	mov    0x804004,%eax
  801634:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80163a:	83 ec 04             	sub    $0x4,%esp
  80163d:	53                   	push   %ebx
  80163e:	50                   	push   %eax
  80163f:	68 4c 2a 80 00       	push   $0x802a4c
  801644:	e8 d1 ed ff ff       	call   80041a <cprintf>
		return -E_INVAL;
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801651:	eb 26                	jmp    801679 <read+0x8d>
	}
	if (!dev->dev_read)
  801653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801656:	8b 40 08             	mov    0x8(%eax),%eax
  801659:	85 c0                	test   %eax,%eax
  80165b:	74 17                	je     801674 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	ff 75 10             	pushl  0x10(%ebp)
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	52                   	push   %edx
  801667:	ff d0                	call   *%eax
  801669:	89 c2                	mov    %eax,%edx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	eb 09                	jmp    801679 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801670:	89 c2                	mov    %eax,%edx
  801672:	eb 05                	jmp    801679 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801674:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801679:	89 d0                	mov    %edx,%eax
  80167b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	57                   	push   %edi
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80168f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801694:	eb 21                	jmp    8016b7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801696:	83 ec 04             	sub    $0x4,%esp
  801699:	89 f0                	mov    %esi,%eax
  80169b:	29 d8                	sub    %ebx,%eax
  80169d:	50                   	push   %eax
  80169e:	89 d8                	mov    %ebx,%eax
  8016a0:	03 45 0c             	add    0xc(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	57                   	push   %edi
  8016a5:	e8 42 ff ff ff       	call   8015ec <read>
		if (m < 0)
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 10                	js     8016c1 <readn+0x41>
			return m;
		if (m == 0)
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	74 0a                	je     8016bf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b5:	01 c3                	add    %eax,%ebx
  8016b7:	39 f3                	cmp    %esi,%ebx
  8016b9:	72 db                	jb     801696 <readn+0x16>
  8016bb:	89 d8                	mov    %ebx,%eax
  8016bd:	eb 02                	jmp    8016c1 <readn+0x41>
  8016bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5e                   	pop    %esi
  8016c6:	5f                   	pop    %edi
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 14             	sub    $0x14,%esp
  8016d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	53                   	push   %ebx
  8016d8:	e8 a6 fc ff ff       	call   801383 <fd_lookup>
  8016dd:	83 c4 08             	add    $0x8,%esp
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 6b                	js     801751 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	ff 30                	pushl  (%eax)
  8016f2:	e8 e2 fc ff ff       	call   8013d9 <dev_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 4a                	js     801748 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801705:	75 24                	jne    80172b <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801707:	a1 04 40 80 00       	mov    0x804004,%eax
  80170c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	53                   	push   %ebx
  801716:	50                   	push   %eax
  801717:	68 68 2a 80 00       	push   $0x802a68
  80171c:	e8 f9 ec ff ff       	call   80041a <cprintf>
		return -E_INVAL;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801729:	eb 26                	jmp    801751 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172e:	8b 52 0c             	mov    0xc(%edx),%edx
  801731:	85 d2                	test   %edx,%edx
  801733:	74 17                	je     80174c <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	ff 75 10             	pushl  0x10(%ebp)
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	50                   	push   %eax
  80173f:	ff d2                	call   *%edx
  801741:	89 c2                	mov    %eax,%edx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	eb 09                	jmp    801751 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801748:	89 c2                	mov    %eax,%edx
  80174a:	eb 05                	jmp    801751 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801751:	89 d0                	mov    %edx,%eax
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <seek>:

int
seek(int fdnum, off_t offset)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	ff 75 08             	pushl  0x8(%ebp)
  801765:	e8 19 fc ff ff       	call   801383 <fd_lookup>
  80176a:	83 c4 08             	add    $0x8,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 0e                	js     80177f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801771:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801774:	8b 55 0c             	mov    0xc(%ebp),%edx
  801777:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 14             	sub    $0x14,%esp
  801788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	53                   	push   %ebx
  801790:	e8 ee fb ff ff       	call   801383 <fd_lookup>
  801795:	83 c4 08             	add    $0x8,%esp
  801798:	89 c2                	mov    %eax,%edx
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 68                	js     801806 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	ff 30                	pushl  (%eax)
  8017aa:	e8 2a fc ff ff       	call   8013d9 <dev_lookup>
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 47                	js     8017fd <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bd:	75 24                	jne    8017e3 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017bf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017ca:	83 ec 04             	sub    $0x4,%esp
  8017cd:	53                   	push   %ebx
  8017ce:	50                   	push   %eax
  8017cf:	68 28 2a 80 00       	push   $0x802a28
  8017d4:	e8 41 ec ff ff       	call   80041a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e1:	eb 23                	jmp    801806 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e6:	8b 52 18             	mov    0x18(%edx),%edx
  8017e9:	85 d2                	test   %edx,%edx
  8017eb:	74 14                	je     801801 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	ff 75 0c             	pushl  0xc(%ebp)
  8017f3:	50                   	push   %eax
  8017f4:	ff d2                	call   *%edx
  8017f6:	89 c2                	mov    %eax,%edx
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	eb 09                	jmp    801806 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fd:	89 c2                	mov    %eax,%edx
  8017ff:	eb 05                	jmp    801806 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801801:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801806:	89 d0                	mov    %edx,%eax
  801808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	53                   	push   %ebx
  801811:	83 ec 14             	sub    $0x14,%esp
  801814:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801817:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181a:	50                   	push   %eax
  80181b:	ff 75 08             	pushl  0x8(%ebp)
  80181e:	e8 60 fb ff ff       	call   801383 <fd_lookup>
  801823:	83 c4 08             	add    $0x8,%esp
  801826:	89 c2                	mov    %eax,%edx
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 58                	js     801884 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801836:	ff 30                	pushl  (%eax)
  801838:	e8 9c fb ff ff       	call   8013d9 <dev_lookup>
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	78 37                	js     80187b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801847:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184b:	74 32                	je     80187f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80184d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801850:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801857:	00 00 00 
	stat->st_isdir = 0;
  80185a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801861:	00 00 00 
	stat->st_dev = dev;
  801864:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	53                   	push   %ebx
  80186e:	ff 75 f0             	pushl  -0x10(%ebp)
  801871:	ff 50 14             	call   *0x14(%eax)
  801874:	89 c2                	mov    %eax,%edx
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	eb 09                	jmp    801884 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	eb 05                	jmp    801884 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801884:	89 d0                	mov    %edx,%eax
  801886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	6a 00                	push   $0x0
  801895:	ff 75 08             	pushl  0x8(%ebp)
  801898:	e8 e3 01 00 00       	call   801a80 <open>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 1b                	js     8018c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	ff 75 0c             	pushl  0xc(%ebp)
  8018ac:	50                   	push   %eax
  8018ad:	e8 5b ff ff ff       	call   80180d <fstat>
  8018b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b4:	89 1c 24             	mov    %ebx,(%esp)
  8018b7:	e8 f4 fb ff ff       	call   8014b0 <close>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	89 f0                	mov    %esi,%eax
}
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	89 c6                	mov    %eax,%esi
  8018cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d8:	75 12                	jne    8018ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	6a 01                	push   $0x1
  8018df:	e8 ec 08 00 00       	call   8021d0 <ipc_find_env>
  8018e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8018e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ec:	6a 07                	push   $0x7
  8018ee:	68 00 50 80 00       	push   $0x805000
  8018f3:	56                   	push   %esi
  8018f4:	ff 35 00 40 80 00    	pushl  0x804000
  8018fa:	e8 6f 08 00 00       	call   80216e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ff:	83 c4 0c             	add    $0xc,%esp
  801902:	6a 00                	push   $0x0
  801904:	53                   	push   %ebx
  801905:	6a 00                	push   $0x0
  801907:	e8 e7 07 00 00       	call   8020f3 <ipc_recv>
}
  80190c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	8b 40 0c             	mov    0xc(%eax),%eax
  80191f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801924:	8b 45 0c             	mov    0xc(%ebp),%eax
  801927:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
  801931:	b8 02 00 00 00       	mov    $0x2,%eax
  801936:	e8 8d ff ff ff       	call   8018c8 <fsipc>
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	8b 40 0c             	mov    0xc(%eax),%eax
  801949:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	b8 06 00 00 00       	mov    $0x6,%eax
  801958:	e8 6b ff ff ff       	call   8018c8 <fsipc>
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	53                   	push   %ebx
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801969:	8b 45 08             	mov    0x8(%ebp),%eax
  80196c:	8b 40 0c             	mov    0xc(%eax),%eax
  80196f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 05 00 00 00       	mov    $0x5,%eax
  80197e:	e8 45 ff ff ff       	call   8018c8 <fsipc>
  801983:	85 c0                	test   %eax,%eax
  801985:	78 2c                	js     8019b3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	68 00 50 80 00       	push   $0x805000
  80198f:	53                   	push   %ebx
  801990:	e8 0a f0 ff ff       	call   80099f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801995:	a1 80 50 80 00       	mov    0x805080,%eax
  80199a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8019c7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019cd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019d7:	0f 47 c2             	cmova  %edx,%eax
  8019da:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019df:	50                   	push   %eax
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	68 08 50 80 00       	push   $0x805008
  8019e8:	e8 44 f1 ff ff       	call   800b31 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f7:	e8 cc fe ff ff       	call   8018c8 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a11:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a17:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1c:	b8 03 00 00 00       	mov    $0x3,%eax
  801a21:	e8 a2 fe ff ff       	call   8018c8 <fsipc>
  801a26:	89 c3                	mov    %eax,%ebx
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 4b                	js     801a77 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a2c:	39 c6                	cmp    %eax,%esi
  801a2e:	73 16                	jae    801a46 <devfile_read+0x48>
  801a30:	68 98 2a 80 00       	push   $0x802a98
  801a35:	68 9f 2a 80 00       	push   $0x802a9f
  801a3a:	6a 7c                	push   $0x7c
  801a3c:	68 b4 2a 80 00       	push   $0x802ab4
  801a41:	e8 fb e8 ff ff       	call   800341 <_panic>
	assert(r <= PGSIZE);
  801a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4b:	7e 16                	jle    801a63 <devfile_read+0x65>
  801a4d:	68 bf 2a 80 00       	push   $0x802abf
  801a52:	68 9f 2a 80 00       	push   $0x802a9f
  801a57:	6a 7d                	push   $0x7d
  801a59:	68 b4 2a 80 00       	push   $0x802ab4
  801a5e:	e8 de e8 ff ff       	call   800341 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	50                   	push   %eax
  801a67:	68 00 50 80 00       	push   $0x805000
  801a6c:	ff 75 0c             	pushl  0xc(%ebp)
  801a6f:	e8 bd f0 ff ff       	call   800b31 <memmove>
	return r;
  801a74:	83 c4 10             	add    $0x10,%esp
}
  801a77:	89 d8                	mov    %ebx,%eax
  801a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	53                   	push   %ebx
  801a84:	83 ec 20             	sub    $0x20,%esp
  801a87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8a:	53                   	push   %ebx
  801a8b:	e8 d6 ee ff ff       	call   800966 <strlen>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a98:	7f 67                	jg     801b01 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa0:	50                   	push   %eax
  801aa1:	e8 8e f8 ff ff       	call   801334 <fd_alloc>
  801aa6:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 57                	js     801b06 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aaf:	83 ec 08             	sub    $0x8,%esp
  801ab2:	53                   	push   %ebx
  801ab3:	68 00 50 80 00       	push   $0x805000
  801ab8:	e8 e2 ee ff ff       	call   80099f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac8:	b8 01 00 00 00       	mov    $0x1,%eax
  801acd:	e8 f6 fd ff ff       	call   8018c8 <fsipc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	79 14                	jns    801aef <open+0x6f>
		fd_close(fd, 0);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	6a 00                	push   $0x0
  801ae0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae3:	e8 47 f9 ff ff       	call   80142f <fd_close>
		return r;
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	89 da                	mov    %ebx,%edx
  801aed:	eb 17                	jmp    801b06 <open+0x86>
	}

	return fd2num(fd);
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	ff 75 f4             	pushl  -0xc(%ebp)
  801af5:	e8 13 f8 ff ff       	call   80130d <fd2num>
  801afa:	89 c2                	mov    %eax,%edx
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	eb 05                	jmp    801b06 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b01:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b06:	89 d0                	mov    %edx,%eax
  801b08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b13:	ba 00 00 00 00       	mov    $0x0,%edx
  801b18:	b8 08 00 00 00       	mov    $0x8,%eax
  801b1d:	e8 a6 fd ff ff       	call   8018c8 <fsipc>
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	ff 75 08             	pushl  0x8(%ebp)
  801b32:	e8 e6 f7 ff ff       	call   80131d <fd2data>
  801b37:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b39:	83 c4 08             	add    $0x8,%esp
  801b3c:	68 cb 2a 80 00       	push   $0x802acb
  801b41:	53                   	push   %ebx
  801b42:	e8 58 ee ff ff       	call   80099f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b47:	8b 46 04             	mov    0x4(%esi),%eax
  801b4a:	2b 06                	sub    (%esi),%eax
  801b4c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b52:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b59:	00 00 00 
	stat->st_dev = &devpipe;
  801b5c:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b63:	30 80 00 
	return 0;
}
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6e:	5b                   	pop    %ebx
  801b6f:	5e                   	pop    %esi
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b7c:	53                   	push   %ebx
  801b7d:	6a 00                	push   $0x0
  801b7f:	e8 a3 f2 ff ff       	call   800e27 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b84:	89 1c 24             	mov    %ebx,(%esp)
  801b87:	e8 91 f7 ff ff       	call   80131d <fd2data>
  801b8c:	83 c4 08             	add    $0x8,%esp
  801b8f:	50                   	push   %eax
  801b90:	6a 00                	push   $0x0
  801b92:	e8 90 f2 ff ff       	call   800e27 <sys_page_unmap>
}
  801b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	57                   	push   %edi
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 1c             	sub    $0x1c,%esp
  801ba5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801baa:	a1 04 40 80 00       	mov    0x804004,%eax
  801baf:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbb:	e8 55 06 00 00       	call   802215 <pageref>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	89 3c 24             	mov    %edi,(%esp)
  801bc5:	e8 4b 06 00 00       	call   802215 <pageref>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	39 c3                	cmp    %eax,%ebx
  801bcf:	0f 94 c1             	sete   %cl
  801bd2:	0f b6 c9             	movzbl %cl,%ecx
  801bd5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bd8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bde:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801be4:	39 ce                	cmp    %ecx,%esi
  801be6:	74 1e                	je     801c06 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801be8:	39 c3                	cmp    %eax,%ebx
  801bea:	75 be                	jne    801baa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bec:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801bf2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf5:	50                   	push   %eax
  801bf6:	56                   	push   %esi
  801bf7:	68 d2 2a 80 00       	push   $0x802ad2
  801bfc:	e8 19 e8 ff ff       	call   80041a <cprintf>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	eb a4                	jmp    801baa <_pipeisclosed+0xe>
	}
}
  801c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	57                   	push   %edi
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	83 ec 28             	sub    $0x28,%esp
  801c1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1d:	56                   	push   %esi
  801c1e:	e8 fa f6 ff ff       	call   80131d <fd2data>
  801c23:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2d:	eb 4b                	jmp    801c7a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c2f:	89 da                	mov    %ebx,%edx
  801c31:	89 f0                	mov    %esi,%eax
  801c33:	e8 64 ff ff ff       	call   801b9c <_pipeisclosed>
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	75 48                	jne    801c84 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3c:	e8 42 f1 ff ff       	call   800d83 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c41:	8b 43 04             	mov    0x4(%ebx),%eax
  801c44:	8b 0b                	mov    (%ebx),%ecx
  801c46:	8d 51 20             	lea    0x20(%ecx),%edx
  801c49:	39 d0                	cmp    %edx,%eax
  801c4b:	73 e2                	jae    801c2f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c50:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c54:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	c1 fa 1f             	sar    $0x1f,%edx
  801c5c:	89 d1                	mov    %edx,%ecx
  801c5e:	c1 e9 1b             	shr    $0x1b,%ecx
  801c61:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c64:	83 e2 1f             	and    $0x1f,%edx
  801c67:	29 ca                	sub    %ecx,%edx
  801c69:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c71:	83 c0 01             	add    $0x1,%eax
  801c74:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c77:	83 c7 01             	add    $0x1,%edi
  801c7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7d:	75 c2                	jne    801c41 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c82:	eb 05                	jmp    801c89 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c84:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	57                   	push   %edi
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	83 ec 18             	sub    $0x18,%esp
  801c9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c9d:	57                   	push   %edi
  801c9e:	e8 7a f6 ff ff       	call   80131d <fd2data>
  801ca3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cad:	eb 3d                	jmp    801cec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801caf:	85 db                	test   %ebx,%ebx
  801cb1:	74 04                	je     801cb7 <devpipe_read+0x26>
				return i;
  801cb3:	89 d8                	mov    %ebx,%eax
  801cb5:	eb 44                	jmp    801cfb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb7:	89 f2                	mov    %esi,%edx
  801cb9:	89 f8                	mov    %edi,%eax
  801cbb:	e8 dc fe ff ff       	call   801b9c <_pipeisclosed>
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	75 32                	jne    801cf6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc4:	e8 ba f0 ff ff       	call   800d83 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cc9:	8b 06                	mov    (%esi),%eax
  801ccb:	3b 46 04             	cmp    0x4(%esi),%eax
  801cce:	74 df                	je     801caf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd0:	99                   	cltd   
  801cd1:	c1 ea 1b             	shr    $0x1b,%edx
  801cd4:	01 d0                	add    %edx,%eax
  801cd6:	83 e0 1f             	and    $0x1f,%eax
  801cd9:	29 d0                	sub    %edx,%eax
  801cdb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ce6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce9:	83 c3 01             	add    $0x1,%ebx
  801cec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cef:	75 d8                	jne    801cc9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf1:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf4:	eb 05                	jmp    801cfb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfe:	5b                   	pop    %ebx
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	56                   	push   %esi
  801d07:	53                   	push   %ebx
  801d08:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0e:	50                   	push   %eax
  801d0f:	e8 20 f6 ff ff       	call   801334 <fd_alloc>
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	89 c2                	mov    %eax,%edx
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	0f 88 2c 01 00 00    	js     801e4d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d21:	83 ec 04             	sub    $0x4,%esp
  801d24:	68 07 04 00 00       	push   $0x407
  801d29:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 6f f0 ff ff       	call   800da2 <sys_page_alloc>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	89 c2                	mov    %eax,%edx
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	0f 88 0d 01 00 00    	js     801e4d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	e8 e8 f5 ff ff       	call   801334 <fd_alloc>
  801d4c:	89 c3                	mov    %eax,%ebx
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	85 c0                	test   %eax,%eax
  801d53:	0f 88 e2 00 00 00    	js     801e3b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	68 07 04 00 00       	push   $0x407
  801d61:	ff 75 f0             	pushl  -0x10(%ebp)
  801d64:	6a 00                	push   $0x0
  801d66:	e8 37 f0 ff ff       	call   800da2 <sys_page_alloc>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	0f 88 c3 00 00 00    	js     801e3b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	e8 9a f5 ff ff       	call   80131d <fd2data>
  801d83:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d85:	83 c4 0c             	add    $0xc,%esp
  801d88:	68 07 04 00 00       	push   $0x407
  801d8d:	50                   	push   %eax
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 0d f0 ff ff       	call   800da2 <sys_page_alloc>
  801d95:	89 c3                	mov    %eax,%ebx
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	0f 88 89 00 00 00    	js     801e2b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 f0             	pushl  -0x10(%ebp)
  801da8:	e8 70 f5 ff ff       	call   80131d <fd2data>
  801dad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db4:	50                   	push   %eax
  801db5:	6a 00                	push   $0x0
  801db7:	56                   	push   %esi
  801db8:	6a 00                	push   $0x0
  801dba:	e8 26 f0 ff ff       	call   800de5 <sys_page_map>
  801dbf:	89 c3                	mov    %eax,%ebx
  801dc1:	83 c4 20             	add    $0x20,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 55                	js     801e1d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dc8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ddd:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801deb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df2:	83 ec 0c             	sub    $0xc,%esp
  801df5:	ff 75 f4             	pushl  -0xc(%ebp)
  801df8:	e8 10 f5 ff ff       	call   80130d <fd2num>
  801dfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e02:	83 c4 04             	add    $0x4,%esp
  801e05:	ff 75 f0             	pushl  -0x10(%ebp)
  801e08:	e8 00 f5 ff ff       	call   80130d <fd2num>
  801e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e10:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1b:	eb 30                	jmp    801e4d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e1d:	83 ec 08             	sub    $0x8,%esp
  801e20:	56                   	push   %esi
  801e21:	6a 00                	push   $0x0
  801e23:	e8 ff ef ff ff       	call   800e27 <sys_page_unmap>
  801e28:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e2b:	83 ec 08             	sub    $0x8,%esp
  801e2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e31:	6a 00                	push   $0x0
  801e33:	e8 ef ef ff ff       	call   800e27 <sys_page_unmap>
  801e38:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e3b:	83 ec 08             	sub    $0x8,%esp
  801e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e41:	6a 00                	push   $0x0
  801e43:	e8 df ef ff ff       	call   800e27 <sys_page_unmap>
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e4d:	89 d0                	mov    %edx,%eax
  801e4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    

00801e56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	ff 75 08             	pushl  0x8(%ebp)
  801e63:	e8 1b f5 ff ff       	call   801383 <fd_lookup>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 18                	js     801e87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	ff 75 f4             	pushl  -0xc(%ebp)
  801e75:	e8 a3 f4 ff ff       	call   80131d <fd2data>
	return _pipeisclosed(fd, p);
  801e7a:	89 c2                	mov    %eax,%edx
  801e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7f:	e8 18 fd ff ff       	call   801b9c <_pipeisclosed>
  801e84:	83 c4 10             	add    $0x10,%esp
}
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	56                   	push   %esi
  801e8d:	53                   	push   %ebx
  801e8e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e91:	85 f6                	test   %esi,%esi
  801e93:	75 16                	jne    801eab <wait+0x22>
  801e95:	68 ea 2a 80 00       	push   $0x802aea
  801e9a:	68 9f 2a 80 00       	push   $0x802a9f
  801e9f:	6a 09                	push   $0x9
  801ea1:	68 f5 2a 80 00       	push   $0x802af5
  801ea6:	e8 96 e4 ff ff       	call   800341 <_panic>
	e = &envs[ENVX(envid)];
  801eab:	89 f3                	mov    %esi,%ebx
  801ead:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801eb3:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  801eb9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801ebf:	eb 05                	jmp    801ec6 <wait+0x3d>
		sys_yield();
  801ec1:	e8 bd ee ff ff       	call   800d83 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ec6:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  801ecc:	39 c6                	cmp    %eax,%esi
  801ece:	75 0a                	jne    801eda <wait+0x51>
  801ed0:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	75 e7                	jne    801ec1 <wait+0x38>
		sys_yield();
}
  801eda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801edd:	5b                   	pop    %ebx
  801ede:	5e                   	pop    %esi
  801edf:	5d                   	pop    %ebp
  801ee0:	c3                   	ret    

00801ee1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ef1:	68 00 2b 80 00       	push   $0x802b00
  801ef6:	ff 75 0c             	pushl  0xc(%ebp)
  801ef9:	e8 a1 ea ff ff       	call   80099f <strcpy>
	return 0;
}
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	57                   	push   %edi
  801f09:	56                   	push   %esi
  801f0a:	53                   	push   %ebx
  801f0b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f11:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f16:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f1c:	eb 2d                	jmp    801f4b <devcons_write+0x46>
		m = n - tot;
  801f1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f21:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f23:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f26:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f2b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f2e:	83 ec 04             	sub    $0x4,%esp
  801f31:	53                   	push   %ebx
  801f32:	03 45 0c             	add    0xc(%ebp),%eax
  801f35:	50                   	push   %eax
  801f36:	57                   	push   %edi
  801f37:	e8 f5 eb ff ff       	call   800b31 <memmove>
		sys_cputs(buf, m);
  801f3c:	83 c4 08             	add    $0x8,%esp
  801f3f:	53                   	push   %ebx
  801f40:	57                   	push   %edi
  801f41:	e8 a0 ed ff ff       	call   800ce6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f46:	01 de                	add    %ebx,%esi
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	89 f0                	mov    %esi,%eax
  801f4d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f50:	72 cc                	jb     801f1e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5f                   	pop    %edi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	83 ec 08             	sub    $0x8,%esp
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f69:	74 2a                	je     801f95 <devcons_read+0x3b>
  801f6b:	eb 05                	jmp    801f72 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f6d:	e8 11 ee ff ff       	call   800d83 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f72:	e8 8d ed ff ff       	call   800d04 <sys_cgetc>
  801f77:	85 c0                	test   %eax,%eax
  801f79:	74 f2                	je     801f6d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	78 16                	js     801f95 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f7f:	83 f8 04             	cmp    $0x4,%eax
  801f82:	74 0c                	je     801f90 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f87:	88 02                	mov    %al,(%edx)
	return 1;
  801f89:	b8 01 00 00 00       	mov    $0x1,%eax
  801f8e:	eb 05                	jmp    801f95 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fa3:	6a 01                	push   $0x1
  801fa5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa8:	50                   	push   %eax
  801fa9:	e8 38 ed ff ff       	call   800ce6 <sys_cputs>
}
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <getchar>:

int
getchar(void)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fb9:	6a 01                	push   $0x1
  801fbb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fbe:	50                   	push   %eax
  801fbf:	6a 00                	push   $0x0
  801fc1:	e8 26 f6 ff ff       	call   8015ec <read>
	if (r < 0)
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 0f                	js     801fdc <getchar+0x29>
		return r;
	if (r < 1)
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	7e 06                	jle    801fd7 <getchar+0x24>
		return -E_EOF;
	return c;
  801fd1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fd5:	eb 05                	jmp    801fdc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fd7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe7:	50                   	push   %eax
  801fe8:	ff 75 08             	pushl  0x8(%ebp)
  801feb:	e8 93 f3 ff ff       	call   801383 <fd_lookup>
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	78 11                	js     802008 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffa:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802000:	39 10                	cmp    %edx,(%eax)
  802002:	0f 94 c0             	sete   %al
  802005:	0f b6 c0             	movzbl %al,%eax
}
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <opencons>:

int
opencons(void)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802010:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802013:	50                   	push   %eax
  802014:	e8 1b f3 ff ff       	call   801334 <fd_alloc>
  802019:	83 c4 10             	add    $0x10,%esp
		return r;
  80201c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80201e:	85 c0                	test   %eax,%eax
  802020:	78 3e                	js     802060 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802022:	83 ec 04             	sub    $0x4,%esp
  802025:	68 07 04 00 00       	push   $0x407
  80202a:	ff 75 f4             	pushl  -0xc(%ebp)
  80202d:	6a 00                	push   $0x0
  80202f:	e8 6e ed ff ff       	call   800da2 <sys_page_alloc>
  802034:	83 c4 10             	add    $0x10,%esp
		return r;
  802037:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802039:	85 c0                	test   %eax,%eax
  80203b:	78 23                	js     802060 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80203d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802046:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802048:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802052:	83 ec 0c             	sub    $0xc,%esp
  802055:	50                   	push   %eax
  802056:	e8 b2 f2 ff ff       	call   80130d <fd2num>
  80205b:	89 c2                	mov    %eax,%edx
  80205d:	83 c4 10             	add    $0x10,%esp
}
  802060:	89 d0                	mov    %edx,%eax
  802062:	c9                   	leave  
  802063:	c3                   	ret    

00802064 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80206a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802071:	75 2a                	jne    80209d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802073:	83 ec 04             	sub    $0x4,%esp
  802076:	6a 07                	push   $0x7
  802078:	68 00 f0 bf ee       	push   $0xeebff000
  80207d:	6a 00                	push   $0x0
  80207f:	e8 1e ed ff ff       	call   800da2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802084:	83 c4 10             	add    $0x10,%esp
  802087:	85 c0                	test   %eax,%eax
  802089:	79 12                	jns    80209d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80208b:	50                   	push   %eax
  80208c:	68 0c 2b 80 00       	push   $0x802b0c
  802091:	6a 23                	push   $0x23
  802093:	68 10 2b 80 00       	push   $0x802b10
  802098:	e8 a4 e2 ff ff       	call   800341 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80209d:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a0:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020a5:	83 ec 08             	sub    $0x8,%esp
  8020a8:	68 cf 20 80 00       	push   $0x8020cf
  8020ad:	6a 00                	push   $0x0
  8020af:	e8 39 ee ff ff       	call   800eed <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	79 12                	jns    8020cd <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020bb:	50                   	push   %eax
  8020bc:	68 0c 2b 80 00       	push   $0x802b0c
  8020c1:	6a 2c                	push   $0x2c
  8020c3:	68 10 2b 80 00       	push   $0x802b10
  8020c8:	e8 74 e2 ff ff       	call   800341 <_panic>
	}
}
  8020cd:	c9                   	leave  
  8020ce:	c3                   	ret    

008020cf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020cf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020d0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020d5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020d7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020da:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020de:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020e3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020e7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020e9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020ec:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020ed:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020f0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020f1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020f2:	c3                   	ret    

008020f3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8020fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802101:	85 c0                	test   %eax,%eax
  802103:	75 12                	jne    802117 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802105:	83 ec 0c             	sub    $0xc,%esp
  802108:	68 00 00 c0 ee       	push   $0xeec00000
  80210d:	e8 40 ee ff ff       	call   800f52 <sys_ipc_recv>
  802112:	83 c4 10             	add    $0x10,%esp
  802115:	eb 0c                	jmp    802123 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802117:	83 ec 0c             	sub    $0xc,%esp
  80211a:	50                   	push   %eax
  80211b:	e8 32 ee ff ff       	call   800f52 <sys_ipc_recv>
  802120:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802123:	85 f6                	test   %esi,%esi
  802125:	0f 95 c1             	setne  %cl
  802128:	85 db                	test   %ebx,%ebx
  80212a:	0f 95 c2             	setne  %dl
  80212d:	84 d1                	test   %dl,%cl
  80212f:	74 09                	je     80213a <ipc_recv+0x47>
  802131:	89 c2                	mov    %eax,%edx
  802133:	c1 ea 1f             	shr    $0x1f,%edx
  802136:	84 d2                	test   %dl,%dl
  802138:	75 2d                	jne    802167 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80213a:	85 f6                	test   %esi,%esi
  80213c:	74 0d                	je     80214b <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80213e:	a1 04 40 80 00       	mov    0x804004,%eax
  802143:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802149:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80214b:	85 db                	test   %ebx,%ebx
  80214d:	74 0d                	je     80215c <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80214f:	a1 04 40 80 00       	mov    0x804004,%eax
  802154:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80215a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80215c:	a1 04 40 80 00       	mov    0x804004,%eax
  802161:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802167:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 0c             	sub    $0xc,%esp
  802177:	8b 7d 08             	mov    0x8(%ebp),%edi
  80217a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80217d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802180:	85 db                	test   %ebx,%ebx
  802182:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802187:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80218a:	ff 75 14             	pushl  0x14(%ebp)
  80218d:	53                   	push   %ebx
  80218e:	56                   	push   %esi
  80218f:	57                   	push   %edi
  802190:	e8 9a ed ff ff       	call   800f2f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802195:	89 c2                	mov    %eax,%edx
  802197:	c1 ea 1f             	shr    $0x1f,%edx
  80219a:	83 c4 10             	add    $0x10,%esp
  80219d:	84 d2                	test   %dl,%dl
  80219f:	74 17                	je     8021b8 <ipc_send+0x4a>
  8021a1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021a4:	74 12                	je     8021b8 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021a6:	50                   	push   %eax
  8021a7:	68 1e 2b 80 00       	push   $0x802b1e
  8021ac:	6a 47                	push   $0x47
  8021ae:	68 2c 2b 80 00       	push   $0x802b2c
  8021b3:	e8 89 e1 ff ff       	call   800341 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021b8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021bb:	75 07                	jne    8021c4 <ipc_send+0x56>
			sys_yield();
  8021bd:	e8 c1 eb ff ff       	call   800d83 <sys_yield>
  8021c2:	eb c6                	jmp    80218a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	75 c2                	jne    80218a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cb:	5b                   	pop    %ebx
  8021cc:	5e                   	pop    %esi
  8021cd:	5f                   	pop    %edi
  8021ce:	5d                   	pop    %ebp
  8021cf:	c3                   	ret    

008021d0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021d6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021db:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8021e1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021e7:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8021ed:	39 ca                	cmp    %ecx,%edx
  8021ef:	75 13                	jne    802204 <ipc_find_env+0x34>
			return envs[i].env_id;
  8021f1:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021fc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802202:	eb 0f                	jmp    802213 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802204:	83 c0 01             	add    $0x1,%eax
  802207:	3d 00 04 00 00       	cmp    $0x400,%eax
  80220c:	75 cd                	jne    8021db <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	c1 e8 16             	shr    $0x16,%eax
  802220:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802227:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80222c:	f6 c1 01             	test   $0x1,%cl
  80222f:	74 1d                	je     80224e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802231:	c1 ea 0c             	shr    $0xc,%edx
  802234:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80223b:	f6 c2 01             	test   $0x1,%dl
  80223e:	74 0e                	je     80224e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802240:	c1 ea 0c             	shr    $0xc,%edx
  802243:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80224a:	ef 
  80224b:	0f b7 c0             	movzwl %ax,%eax
}
  80224e:	5d                   	pop    %ebp
  80224f:	c3                   	ret    

00802250 <__udivdi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80225b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80225f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 f6                	test   %esi,%esi
  802269:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226d:	89 ca                	mov    %ecx,%edx
  80226f:	89 f8                	mov    %edi,%eax
  802271:	75 3d                	jne    8022b0 <__udivdi3+0x60>
  802273:	39 cf                	cmp    %ecx,%edi
  802275:	0f 87 c5 00 00 00    	ja     802340 <__udivdi3+0xf0>
  80227b:	85 ff                	test   %edi,%edi
  80227d:	89 fd                	mov    %edi,%ebp
  80227f:	75 0b                	jne    80228c <__udivdi3+0x3c>
  802281:	b8 01 00 00 00       	mov    $0x1,%eax
  802286:	31 d2                	xor    %edx,%edx
  802288:	f7 f7                	div    %edi
  80228a:	89 c5                	mov    %eax,%ebp
  80228c:	89 c8                	mov    %ecx,%eax
  80228e:	31 d2                	xor    %edx,%edx
  802290:	f7 f5                	div    %ebp
  802292:	89 c1                	mov    %eax,%ecx
  802294:	89 d8                	mov    %ebx,%eax
  802296:	89 cf                	mov    %ecx,%edi
  802298:	f7 f5                	div    %ebp
  80229a:	89 c3                	mov    %eax,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	39 ce                	cmp    %ecx,%esi
  8022b2:	77 74                	ja     802328 <__udivdi3+0xd8>
  8022b4:	0f bd fe             	bsr    %esi,%edi
  8022b7:	83 f7 1f             	xor    $0x1f,%edi
  8022ba:	0f 84 98 00 00 00    	je     802358 <__udivdi3+0x108>
  8022c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	89 c5                	mov    %eax,%ebp
  8022c9:	29 fb                	sub    %edi,%ebx
  8022cb:	d3 e6                	shl    %cl,%esi
  8022cd:	89 d9                	mov    %ebx,%ecx
  8022cf:	d3 ed                	shr    %cl,%ebp
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	d3 e0                	shl    %cl,%eax
  8022d5:	09 ee                	or     %ebp,%esi
  8022d7:	89 d9                	mov    %ebx,%ecx
  8022d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022dd:	89 d5                	mov    %edx,%ebp
  8022df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022e3:	d3 ed                	shr    %cl,%ebp
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	d3 e2                	shl    %cl,%edx
  8022e9:	89 d9                	mov    %ebx,%ecx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	09 c2                	or     %eax,%edx
  8022ef:	89 d0                	mov    %edx,%eax
  8022f1:	89 ea                	mov    %ebp,%edx
  8022f3:	f7 f6                	div    %esi
  8022f5:	89 d5                	mov    %edx,%ebp
  8022f7:	89 c3                	mov    %eax,%ebx
  8022f9:	f7 64 24 0c          	mull   0xc(%esp)
  8022fd:	39 d5                	cmp    %edx,%ebp
  8022ff:	72 10                	jb     802311 <__udivdi3+0xc1>
  802301:	8b 74 24 08          	mov    0x8(%esp),%esi
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e6                	shl    %cl,%esi
  802309:	39 c6                	cmp    %eax,%esi
  80230b:	73 07                	jae    802314 <__udivdi3+0xc4>
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	75 03                	jne    802314 <__udivdi3+0xc4>
  802311:	83 eb 01             	sub    $0x1,%ebx
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 d8                	mov    %ebx,%eax
  802318:	89 fa                	mov    %edi,%edx
  80231a:	83 c4 1c             	add    $0x1c,%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5f                   	pop    %edi
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    
  802322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802328:	31 ff                	xor    %edi,%edi
  80232a:	31 db                	xor    %ebx,%ebx
  80232c:	89 d8                	mov    %ebx,%eax
  80232e:	89 fa                	mov    %edi,%edx
  802330:	83 c4 1c             	add    $0x1c,%esp
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	90                   	nop
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 d8                	mov    %ebx,%eax
  802342:	f7 f7                	div    %edi
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 c3                	mov    %eax,%ebx
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	89 fa                	mov    %edi,%edx
  80234c:	83 c4 1c             	add    $0x1c,%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5f                   	pop    %edi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	39 ce                	cmp    %ecx,%esi
  80235a:	72 0c                	jb     802368 <__udivdi3+0x118>
  80235c:	31 db                	xor    %ebx,%ebx
  80235e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802362:	0f 87 34 ff ff ff    	ja     80229c <__udivdi3+0x4c>
  802368:	bb 01 00 00 00       	mov    $0x1,%ebx
  80236d:	e9 2a ff ff ff       	jmp    80229c <__udivdi3+0x4c>
  802372:	66 90                	xchg   %ax,%ax
  802374:	66 90                	xchg   %ax,%ax
  802376:	66 90                	xchg   %ax,%ax
  802378:	66 90                	xchg   %ax,%ax
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__umoddi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80238b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80238f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 d2                	test   %edx,%edx
  802399:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80239d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023a1:	89 f3                	mov    %esi,%ebx
  8023a3:	89 3c 24             	mov    %edi,(%esp)
  8023a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023aa:	75 1c                	jne    8023c8 <__umoddi3+0x48>
  8023ac:	39 f7                	cmp    %esi,%edi
  8023ae:	76 50                	jbe    802400 <__umoddi3+0x80>
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	f7 f7                	div    %edi
  8023b6:	89 d0                	mov    %edx,%eax
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	83 c4 1c             	add    $0x1c,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    
  8023c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c8:	39 f2                	cmp    %esi,%edx
  8023ca:	89 d0                	mov    %edx,%eax
  8023cc:	77 52                	ja     802420 <__umoddi3+0xa0>
  8023ce:	0f bd ea             	bsr    %edx,%ebp
  8023d1:	83 f5 1f             	xor    $0x1f,%ebp
  8023d4:	75 5a                	jne    802430 <__umoddi3+0xb0>
  8023d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023da:	0f 82 e0 00 00 00    	jb     8024c0 <__umoddi3+0x140>
  8023e0:	39 0c 24             	cmp    %ecx,(%esp)
  8023e3:	0f 86 d7 00 00 00    	jbe    8024c0 <__umoddi3+0x140>
  8023e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023f1:	83 c4 1c             	add    $0x1c,%esp
  8023f4:	5b                   	pop    %ebx
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	85 ff                	test   %edi,%edi
  802402:	89 fd                	mov    %edi,%ebp
  802404:	75 0b                	jne    802411 <__umoddi3+0x91>
  802406:	b8 01 00 00 00       	mov    $0x1,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	f7 f7                	div    %edi
  80240f:	89 c5                	mov    %eax,%ebp
  802411:	89 f0                	mov    %esi,%eax
  802413:	31 d2                	xor    %edx,%edx
  802415:	f7 f5                	div    %ebp
  802417:	89 c8                	mov    %ecx,%eax
  802419:	f7 f5                	div    %ebp
  80241b:	89 d0                	mov    %edx,%eax
  80241d:	eb 99                	jmp    8023b8 <__umoddi3+0x38>
  80241f:	90                   	nop
  802420:	89 c8                	mov    %ecx,%eax
  802422:	89 f2                	mov    %esi,%edx
  802424:	83 c4 1c             	add    $0x1c,%esp
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    
  80242c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802430:	8b 34 24             	mov    (%esp),%esi
  802433:	bf 20 00 00 00       	mov    $0x20,%edi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	29 ef                	sub    %ebp,%edi
  80243c:	d3 e0                	shl    %cl,%eax
  80243e:	89 f9                	mov    %edi,%ecx
  802440:	89 f2                	mov    %esi,%edx
  802442:	d3 ea                	shr    %cl,%edx
  802444:	89 e9                	mov    %ebp,%ecx
  802446:	09 c2                	or     %eax,%edx
  802448:	89 d8                	mov    %ebx,%eax
  80244a:	89 14 24             	mov    %edx,(%esp)
  80244d:	89 f2                	mov    %esi,%edx
  80244f:	d3 e2                	shl    %cl,%edx
  802451:	89 f9                	mov    %edi,%ecx
  802453:	89 54 24 04          	mov    %edx,0x4(%esp)
  802457:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	89 c6                	mov    %eax,%esi
  802461:	d3 e3                	shl    %cl,%ebx
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 d0                	mov    %edx,%eax
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	09 d8                	or     %ebx,%eax
  80246d:	89 d3                	mov    %edx,%ebx
  80246f:	89 f2                	mov    %esi,%edx
  802471:	f7 34 24             	divl   (%esp)
  802474:	89 d6                	mov    %edx,%esi
  802476:	d3 e3                	shl    %cl,%ebx
  802478:	f7 64 24 04          	mull   0x4(%esp)
  80247c:	39 d6                	cmp    %edx,%esi
  80247e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802482:	89 d1                	mov    %edx,%ecx
  802484:	89 c3                	mov    %eax,%ebx
  802486:	72 08                	jb     802490 <__umoddi3+0x110>
  802488:	75 11                	jne    80249b <__umoddi3+0x11b>
  80248a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80248e:	73 0b                	jae    80249b <__umoddi3+0x11b>
  802490:	2b 44 24 04          	sub    0x4(%esp),%eax
  802494:	1b 14 24             	sbb    (%esp),%edx
  802497:	89 d1                	mov    %edx,%ecx
  802499:	89 c3                	mov    %eax,%ebx
  80249b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80249f:	29 da                	sub    %ebx,%edx
  8024a1:	19 ce                	sbb    %ecx,%esi
  8024a3:	89 f9                	mov    %edi,%ecx
  8024a5:	89 f0                	mov    %esi,%eax
  8024a7:	d3 e0                	shl    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	d3 ea                	shr    %cl,%edx
  8024ad:	89 e9                	mov    %ebp,%ecx
  8024af:	d3 ee                	shr    %cl,%esi
  8024b1:	09 d0                	or     %edx,%eax
  8024b3:	89 f2                	mov    %esi,%edx
  8024b5:	83 c4 1c             	add    $0x1c,%esp
  8024b8:	5b                   	pop    %ebx
  8024b9:	5e                   	pop    %esi
  8024ba:	5f                   	pop    %edi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    
  8024bd:	8d 76 00             	lea    0x0(%esi),%esi
  8024c0:	29 f9                	sub    %edi,%ecx
  8024c2:	19 d6                	sbb    %edx,%esi
  8024c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024cc:	e9 18 ff ff ff       	jmp    8023e9 <__umoddi3+0x69>
