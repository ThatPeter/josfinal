
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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
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
  80003b:	c7 05 04 30 80 00 80 	movl   $0x802480,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 5f 1c 00 00       	call   801cad <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 8c 24 80 00       	push   $0x80248c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 95 24 80 00       	push   $0x802495
  800064:	e8 09 03 00 00       	call   800372 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 4c 10 00 00       	call   8010ba <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 a5 24 80 00       	push   $0x8024a5
  80007a:	6a 11                	push   $0x11
  80007c:	68 95 24 80 00       	push   $0x802495
  800081:	e8 ec 02 00 00       	call   800372 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 50             	mov    0x50(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ae 24 80 00       	push   $0x8024ae
  8000a2:	e8 a4 03 00 00       	call   80044b <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 ba 13 00 00       	call   80146c <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 50             	mov    0x50(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 cb 24 80 00       	push   $0x8024cb
  8000c6:	e8 80 03 00 00       	call   80044b <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 5d 15 00 00       	call   801639 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 e8 24 80 00       	push   $0x8024e8
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 95 24 80 00       	push   $0x802495
  8000f2:	e8 7b 02 00 00       	call   800372 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 6c 09 00 00       	call   800a7a <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 f1 24 80 00       	push   $0x8024f1
  80011d:	e8 29 03 00 00       	call   80044b <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 0d 25 80 00       	push   $0x80250d
  800134:	e8 12 03 00 00       	call   80044b <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 17 02 00 00       	call   800358 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 50             	mov    0x50(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ae 24 80 00       	push   $0x8024ae
  80015a:	e8 ec 02 00 00       	call   80044b <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 02 13 00 00       	call   80146c <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 50             	mov    0x50(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 20 25 80 00       	push   $0x802520
  80017e:	e8 c8 02 00 00       	call   80044b <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 06 08 00 00       	call   800997 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 df 14 00 00       	call   801682 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 e4 07 00 00       	call   800997 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 3d 25 80 00       	push   $0x80253d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 95 24 80 00       	push   $0x802495
  8001c7:	e8 a6 01 00 00       	call   800372 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 95 12 00 00       	call   80146c <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 50 1c 00 00       	call   801e33 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 47 	movl   $0x802547,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 b5 1a 00 00       	call   801cad <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 8c 24 80 00       	push   $0x80248c
  800207:	6a 2c                	push   $0x2c
  800209:	68 95 24 80 00       	push   $0x802495
  80020e:	e8 5f 01 00 00       	call   800372 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 a2 0e 00 00       	call   8010ba <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 a5 24 80 00       	push   $0x8024a5
  800224:	6a 2f                	push   $0x2f
  800226:	68 95 24 80 00       	push   $0x802495
  80022b:	e8 42 01 00 00       	call   800372 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 2d 12 00 00       	call   80146c <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 54 25 80 00       	push   $0x802554
  80024a:	e8 fc 01 00 00       	call   80044b <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 56 25 80 00       	push   $0x802556
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 21 14 00 00       	call   801682 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 58 25 80 00       	push   $0x802558
  800271:	e8 d5 01 00 00       	call   80044b <cprintf>
		exit();
  800276:	e8 dd 00 00 00       	call   800358 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 e3 11 00 00       	call   80146c <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 d8 11 00 00       	call   80146c <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 97 1b 00 00       	call   801e33 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 75 25 80 00 	movl   $0x802575,(%esp)
  8002a3:	e8 a3 01 00 00       	call   80044b <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8002bb:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8002c2:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8002c5:	e8 cb 0a 00 00       	call   800d95 <sys_getenvid>
  8002ca:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	50                   	push   %eax
  8002d0:	68 cc 25 80 00       	push   $0x8025cc
  8002d5:	e8 71 01 00 00       	call   80044b <cprintf>
  8002da:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8002e0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002ed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8002f2:	89 c1                	mov    %eax,%ecx
  8002f4:	c1 e1 07             	shl    $0x7,%ecx
  8002f7:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8002fe:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800301:	39 cb                	cmp    %ecx,%ebx
  800303:	0f 44 fa             	cmove  %edx,%edi
  800306:	b9 01 00 00 00       	mov    $0x1,%ecx
  80030b:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80030e:	83 c0 01             	add    $0x1,%eax
  800311:	81 c2 84 00 00 00    	add    $0x84,%edx
  800317:	3d 00 04 00 00       	cmp    $0x400,%eax
  80031c:	75 d4                	jne    8002f2 <libmain+0x40>
  80031e:	89 f0                	mov    %esi,%eax
  800320:	84 c0                	test   %al,%al
  800322:	74 06                	je     80032a <libmain+0x78>
  800324:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80032a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80032e:	7e 0a                	jle    80033a <libmain+0x88>
		binaryname = argv[0];
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
  800333:	8b 00                	mov    (%eax),%eax
  800335:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80033a:	83 ec 08             	sub    $0x8,%esp
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	e8 eb fc ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800348:	e8 0b 00 00 00       	call   800358 <exit>
}
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80035e:	e8 34 11 00 00       	call   801497 <close_all>
	sys_env_destroy(0);
  800363:	83 ec 0c             	sub    $0xc,%esp
  800366:	6a 00                	push   $0x0
  800368:	e8 e7 09 00 00       	call   800d54 <sys_env_destroy>
}
  80036d:	83 c4 10             	add    $0x10,%esp
  800370:	c9                   	leave  
  800371:	c3                   	ret    

00800372 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800377:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80037a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800380:	e8 10 0a 00 00       	call   800d95 <sys_getenvid>
  800385:	83 ec 0c             	sub    $0xc,%esp
  800388:	ff 75 0c             	pushl  0xc(%ebp)
  80038b:	ff 75 08             	pushl  0x8(%ebp)
  80038e:	56                   	push   %esi
  80038f:	50                   	push   %eax
  800390:	68 f8 25 80 00       	push   $0x8025f8
  800395:	e8 b1 00 00 00       	call   80044b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80039a:	83 c4 18             	add    $0x18,%esp
  80039d:	53                   	push   %ebx
  80039e:	ff 75 10             	pushl  0x10(%ebp)
  8003a1:	e8 54 00 00 00       	call   8003fa <vcprintf>
	cprintf("\n");
  8003a6:	c7 04 24 c9 24 80 00 	movl   $0x8024c9,(%esp)
  8003ad:	e8 99 00 00 00       	call   80044b <cprintf>
  8003b2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003b5:	cc                   	int3   
  8003b6:	eb fd                	jmp    8003b5 <_panic+0x43>

008003b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 04             	sub    $0x4,%esp
  8003bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003c2:	8b 13                	mov    (%ebx),%edx
  8003c4:	8d 42 01             	lea    0x1(%edx),%eax
  8003c7:	89 03                	mov    %eax,(%ebx)
  8003c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003d5:	75 1a                	jne    8003f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	68 ff 00 00 00       	push   $0xff
  8003df:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e2:	50                   	push   %eax
  8003e3:	e8 2f 09 00 00       	call   800d17 <sys_cputs>
		b->idx = 0;
  8003e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800403:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80040a:	00 00 00 
	b.cnt = 0;
  80040d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800414:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800417:	ff 75 0c             	pushl  0xc(%ebp)
  80041a:	ff 75 08             	pushl  0x8(%ebp)
  80041d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800423:	50                   	push   %eax
  800424:	68 b8 03 80 00       	push   $0x8003b8
  800429:	e8 54 01 00 00       	call   800582 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80042e:	83 c4 08             	add    $0x8,%esp
  800431:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800437:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80043d:	50                   	push   %eax
  80043e:	e8 d4 08 00 00       	call   800d17 <sys_cputs>

	return b.cnt;
}
  800443:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800451:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800454:	50                   	push   %eax
  800455:	ff 75 08             	pushl  0x8(%ebp)
  800458:	e8 9d ff ff ff       	call   8003fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80045d:	c9                   	leave  
  80045e:	c3                   	ret    

0080045f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	57                   	push   %edi
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	83 ec 1c             	sub    $0x1c,%esp
  800468:	89 c7                	mov    %eax,%edi
  80046a:	89 d6                	mov    %edx,%esi
  80046c:	8b 45 08             	mov    0x8(%ebp),%eax
  80046f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800472:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800475:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800478:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80047b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800480:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800483:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800486:	39 d3                	cmp    %edx,%ebx
  800488:	72 05                	jb     80048f <printnum+0x30>
  80048a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80048d:	77 45                	ja     8004d4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80048f:	83 ec 0c             	sub    $0xc,%esp
  800492:	ff 75 18             	pushl  0x18(%ebp)
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80049b:	53                   	push   %ebx
  80049c:	ff 75 10             	pushl  0x10(%ebp)
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ae:	e8 3d 1d 00 00       	call   8021f0 <__udivdi3>
  8004b3:	83 c4 18             	add    $0x18,%esp
  8004b6:	52                   	push   %edx
  8004b7:	50                   	push   %eax
  8004b8:	89 f2                	mov    %esi,%edx
  8004ba:	89 f8                	mov    %edi,%eax
  8004bc:	e8 9e ff ff ff       	call   80045f <printnum>
  8004c1:	83 c4 20             	add    $0x20,%esp
  8004c4:	eb 18                	jmp    8004de <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	56                   	push   %esi
  8004ca:	ff 75 18             	pushl  0x18(%ebp)
  8004cd:	ff d7                	call   *%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	eb 03                	jmp    8004d7 <printnum+0x78>
  8004d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004d7:	83 eb 01             	sub    $0x1,%ebx
  8004da:	85 db                	test   %ebx,%ebx
  8004dc:	7f e8                	jg     8004c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	56                   	push   %esi
  8004e2:	83 ec 04             	sub    $0x4,%esp
  8004e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8004f1:	e8 2a 1e 00 00       	call   802320 <__umoddi3>
  8004f6:	83 c4 14             	add    $0x14,%esp
  8004f9:	0f be 80 1b 26 80 00 	movsbl 0x80261b(%eax),%eax
  800500:	50                   	push   %eax
  800501:	ff d7                	call   *%edi
}
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800509:	5b                   	pop    %ebx
  80050a:	5e                   	pop    %esi
  80050b:	5f                   	pop    %edi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800511:	83 fa 01             	cmp    $0x1,%edx
  800514:	7e 0e                	jle    800524 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800516:	8b 10                	mov    (%eax),%edx
  800518:	8d 4a 08             	lea    0x8(%edx),%ecx
  80051b:	89 08                	mov    %ecx,(%eax)
  80051d:	8b 02                	mov    (%edx),%eax
  80051f:	8b 52 04             	mov    0x4(%edx),%edx
  800522:	eb 22                	jmp    800546 <getuint+0x38>
	else if (lflag)
  800524:	85 d2                	test   %edx,%edx
  800526:	74 10                	je     800538 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052d:	89 08                	mov    %ecx,(%eax)
  80052f:	8b 02                	mov    (%edx),%eax
  800531:	ba 00 00 00 00       	mov    $0x0,%edx
  800536:	eb 0e                	jmp    800546 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800538:	8b 10                	mov    (%eax),%edx
  80053a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80053d:	89 08                	mov    %ecx,(%eax)
  80053f:	8b 02                	mov    (%edx),%eax
  800541:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800546:	5d                   	pop    %ebp
  800547:	c3                   	ret    

00800548 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800552:	8b 10                	mov    (%eax),%edx
  800554:	3b 50 04             	cmp    0x4(%eax),%edx
  800557:	73 0a                	jae    800563 <sprintputch+0x1b>
		*b->buf++ = ch;
  800559:	8d 4a 01             	lea    0x1(%edx),%ecx
  80055c:	89 08                	mov    %ecx,(%eax)
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	88 02                	mov    %al,(%edx)
}
  800563:	5d                   	pop    %ebp
  800564:	c3                   	ret    

00800565 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80056b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056e:	50                   	push   %eax
  80056f:	ff 75 10             	pushl  0x10(%ebp)
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	ff 75 08             	pushl  0x8(%ebp)
  800578:	e8 05 00 00 00       	call   800582 <vprintfmt>
	va_end(ap);
}
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	c9                   	leave  
  800581:	c3                   	ret    

00800582 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	57                   	push   %edi
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	83 ec 2c             	sub    $0x2c,%esp
  80058b:	8b 75 08             	mov    0x8(%ebp),%esi
  80058e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800591:	8b 7d 10             	mov    0x10(%ebp),%edi
  800594:	eb 12                	jmp    8005a8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800596:	85 c0                	test   %eax,%eax
  800598:	0f 84 89 03 00 00    	je     800927 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	50                   	push   %eax
  8005a3:	ff d6                	call   *%esi
  8005a5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a8:	83 c7 01             	add    $0x1,%edi
  8005ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005af:	83 f8 25             	cmp    $0x25,%eax
  8005b2:	75 e2                	jne    800596 <vprintfmt+0x14>
  8005b4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d2:	eb 07                	jmp    8005db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8d 47 01             	lea    0x1(%edi),%eax
  8005de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e1:	0f b6 07             	movzbl (%edi),%eax
  8005e4:	0f b6 c8             	movzbl %al,%ecx
  8005e7:	83 e8 23             	sub    $0x23,%eax
  8005ea:	3c 55                	cmp    $0x55,%al
  8005ec:	0f 87 1a 03 00 00    	ja     80090c <vprintfmt+0x38a>
  8005f2:	0f b6 c0             	movzbl %al,%eax
  8005f5:	ff 24 85 60 27 80 00 	jmp    *0x802760(,%eax,4)
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ff:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800603:	eb d6                	jmp    8005db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800608:	b8 00 00 00 00       	mov    $0x0,%eax
  80060d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800610:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800613:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800617:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80061a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80061d:	83 fa 09             	cmp    $0x9,%edx
  800620:	77 39                	ja     80065b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800622:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800625:	eb e9                	jmp    800610 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 48 04             	lea    0x4(%eax),%ecx
  80062d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800630:	8b 00                	mov    (%eax),%eax
  800632:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800638:	eb 27                	jmp    800661 <vprintfmt+0xdf>
  80063a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063d:	85 c0                	test   %eax,%eax
  80063f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800644:	0f 49 c8             	cmovns %eax,%ecx
  800647:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064d:	eb 8c                	jmp    8005db <vprintfmt+0x59>
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800652:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800659:	eb 80                	jmp    8005db <vprintfmt+0x59>
  80065b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800661:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800665:	0f 89 70 ff ff ff    	jns    8005db <vprintfmt+0x59>
				width = precision, precision = -1;
  80066b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800671:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800678:	e9 5e ff ff ff       	jmp    8005db <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80067d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800683:	e9 53 ff ff ff       	jmp    8005db <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	ff 30                	pushl  (%eax)
  800697:	ff d6                	call   *%esi
			break;
  800699:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80069f:	e9 04 ff ff ff       	jmp    8005a8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	99                   	cltd   
  8006b0:	31 d0                	xor    %edx,%eax
  8006b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b4:	83 f8 0f             	cmp    $0xf,%eax
  8006b7:	7f 0b                	jg     8006c4 <vprintfmt+0x142>
  8006b9:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	75 18                	jne    8006dc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006c4:	50                   	push   %eax
  8006c5:	68 33 26 80 00       	push   $0x802633
  8006ca:	53                   	push   %ebx
  8006cb:	56                   	push   %esi
  8006cc:	e8 94 fe ff ff       	call   800565 <printfmt>
  8006d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d7:	e9 cc fe ff ff       	jmp    8005a8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006dc:	52                   	push   %edx
  8006dd:	68 71 2a 80 00       	push   $0x802a71
  8006e2:	53                   	push   %ebx
  8006e3:	56                   	push   %esi
  8006e4:	e8 7c fe ff ff       	call   800565 <printfmt>
  8006e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ef:	e9 b4 fe ff ff       	jmp    8005a8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006ff:	85 ff                	test   %edi,%edi
  800701:	b8 2c 26 80 00       	mov    $0x80262c,%eax
  800706:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800709:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80070d:	0f 8e 94 00 00 00    	jle    8007a7 <vprintfmt+0x225>
  800713:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800717:	0f 84 98 00 00 00    	je     8007b5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	ff 75 d0             	pushl  -0x30(%ebp)
  800723:	57                   	push   %edi
  800724:	e8 86 02 00 00       	call   8009af <strnlen>
  800729:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80072c:	29 c1                	sub    %eax,%ecx
  80072e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800731:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800734:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800738:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80073b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80073e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800740:	eb 0f                	jmp    800751 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	53                   	push   %ebx
  800746:	ff 75 e0             	pushl  -0x20(%ebp)
  800749:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	83 ef 01             	sub    $0x1,%edi
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	85 ff                	test   %edi,%edi
  800753:	7f ed                	jg     800742 <vprintfmt+0x1c0>
  800755:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800758:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80075b:	85 c9                	test   %ecx,%ecx
  80075d:	b8 00 00 00 00       	mov    $0x0,%eax
  800762:	0f 49 c1             	cmovns %ecx,%eax
  800765:	29 c1                	sub    %eax,%ecx
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	89 cb                	mov    %ecx,%ebx
  800772:	eb 4d                	jmp    8007c1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800774:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800778:	74 1b                	je     800795 <vprintfmt+0x213>
  80077a:	0f be c0             	movsbl %al,%eax
  80077d:	83 e8 20             	sub    $0x20,%eax
  800780:	83 f8 5e             	cmp    $0x5e,%eax
  800783:	76 10                	jbe    800795 <vprintfmt+0x213>
					putch('?', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	ff 75 0c             	pushl  0xc(%ebp)
  80078b:	6a 3f                	push   $0x3f
  80078d:	ff 55 08             	call   *0x8(%ebp)
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	eb 0d                	jmp    8007a2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	52                   	push   %edx
  80079c:	ff 55 08             	call   *0x8(%ebp)
  80079f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a2:	83 eb 01             	sub    $0x1,%ebx
  8007a5:	eb 1a                	jmp    8007c1 <vprintfmt+0x23f>
  8007a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8007aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007b3:	eb 0c                	jmp    8007c1 <vprintfmt+0x23f>
  8007b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007c1:	83 c7 01             	add    $0x1,%edi
  8007c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007c8:	0f be d0             	movsbl %al,%edx
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	74 23                	je     8007f2 <vprintfmt+0x270>
  8007cf:	85 f6                	test   %esi,%esi
  8007d1:	78 a1                	js     800774 <vprintfmt+0x1f2>
  8007d3:	83 ee 01             	sub    $0x1,%esi
  8007d6:	79 9c                	jns    800774 <vprintfmt+0x1f2>
  8007d8:	89 df                	mov    %ebx,%edi
  8007da:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e0:	eb 18                	jmp    8007fa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	53                   	push   %ebx
  8007e6:	6a 20                	push   $0x20
  8007e8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ea:	83 ef 01             	sub    $0x1,%edi
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	eb 08                	jmp    8007fa <vprintfmt+0x278>
  8007f2:	89 df                	mov    %ebx,%edi
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007fa:	85 ff                	test   %edi,%edi
  8007fc:	7f e4                	jg     8007e2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800801:	e9 a2 fd ff ff       	jmp    8005a8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800806:	83 fa 01             	cmp    $0x1,%edx
  800809:	7e 16                	jle    800821 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 08             	lea    0x8(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)
  800814:	8b 50 04             	mov    0x4(%eax),%edx
  800817:	8b 00                	mov    (%eax),%eax
  800819:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80081f:	eb 32                	jmp    800853 <vprintfmt+0x2d1>
	else if (lflag)
  800821:	85 d2                	test   %edx,%edx
  800823:	74 18                	je     80083d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8d 50 04             	lea    0x4(%eax),%edx
  80082b:	89 55 14             	mov    %edx,0x14(%ebp)
  80082e:	8b 00                	mov    (%eax),%eax
  800830:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800833:	89 c1                	mov    %eax,%ecx
  800835:	c1 f9 1f             	sar    $0x1f,%ecx
  800838:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80083b:	eb 16                	jmp    800853 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8d 50 04             	lea    0x4(%eax),%edx
  800843:	89 55 14             	mov    %edx,0x14(%ebp)
  800846:	8b 00                	mov    (%eax),%eax
  800848:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084b:	89 c1                	mov    %eax,%ecx
  80084d:	c1 f9 1f             	sar    $0x1f,%ecx
  800850:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800853:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800856:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800859:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80085e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800862:	79 74                	jns    8008d8 <vprintfmt+0x356>
				putch('-', putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 2d                	push   $0x2d
  80086a:	ff d6                	call   *%esi
				num = -(long long) num;
  80086c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80086f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800872:	f7 d8                	neg    %eax
  800874:	83 d2 00             	adc    $0x0,%edx
  800877:	f7 da                	neg    %edx
  800879:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80087c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800881:	eb 55                	jmp    8008d8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800883:	8d 45 14             	lea    0x14(%ebp),%eax
  800886:	e8 83 fc ff ff       	call   80050e <getuint>
			base = 10;
  80088b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800890:	eb 46                	jmp    8008d8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
  800895:	e8 74 fc ff ff       	call   80050e <getuint>
			base = 8;
  80089a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80089f:	eb 37                	jmp    8008d8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 30                	push   $0x30
  8008a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 78                	push   $0x78
  8008af:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8d 50 04             	lea    0x4(%eax),%edx
  8008b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ba:	8b 00                	mov    (%eax),%eax
  8008bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008c9:	eb 0d                	jmp    8008d8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ce:	e8 3b fc ff ff       	call   80050e <getuint>
			base = 16;
  8008d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d8:	83 ec 0c             	sub    $0xc,%esp
  8008db:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008df:	57                   	push   %edi
  8008e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008e3:	51                   	push   %ecx
  8008e4:	52                   	push   %edx
  8008e5:	50                   	push   %eax
  8008e6:	89 da                	mov    %ebx,%edx
  8008e8:	89 f0                	mov    %esi,%eax
  8008ea:	e8 70 fb ff ff       	call   80045f <printnum>
			break;
  8008ef:	83 c4 20             	add    $0x20,%esp
  8008f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f5:	e9 ae fc ff ff       	jmp    8005a8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fa:	83 ec 08             	sub    $0x8,%esp
  8008fd:	53                   	push   %ebx
  8008fe:	51                   	push   %ecx
  8008ff:	ff d6                	call   *%esi
			break;
  800901:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800904:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800907:	e9 9c fc ff ff       	jmp    8005a8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	53                   	push   %ebx
  800910:	6a 25                	push   $0x25
  800912:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800914:	83 c4 10             	add    $0x10,%esp
  800917:	eb 03                	jmp    80091c <vprintfmt+0x39a>
  800919:	83 ef 01             	sub    $0x1,%edi
  80091c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800920:	75 f7                	jne    800919 <vprintfmt+0x397>
  800922:	e9 81 fc ff ff       	jmp    8005a8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800927:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 18             	sub    $0x18,%esp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800942:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800945:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094c:	85 c0                	test   %eax,%eax
  80094e:	74 26                	je     800976 <vsnprintf+0x47>
  800950:	85 d2                	test   %edx,%edx
  800952:	7e 22                	jle    800976 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800954:	ff 75 14             	pushl  0x14(%ebp)
  800957:	ff 75 10             	pushl  0x10(%ebp)
  80095a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095d:	50                   	push   %eax
  80095e:	68 48 05 80 00       	push   $0x800548
  800963:	e8 1a fc ff ff       	call   800582 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800968:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80096b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	eb 05                	jmp    80097b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800976:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800986:	50                   	push   %eax
  800987:	ff 75 10             	pushl  0x10(%ebp)
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	ff 75 08             	pushl  0x8(%ebp)
  800990:	e8 9a ff ff ff       	call   80092f <vsnprintf>
	va_end(ap);

	return rc;
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a2:	eb 03                	jmp    8009a7 <strlen+0x10>
		n++;
  8009a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ab:	75 f7                	jne    8009a4 <strlen+0xd>
		n++;
	return n;
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	eb 03                	jmp    8009c2 <strnlen+0x13>
		n++;
  8009bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c2:	39 c2                	cmp    %eax,%edx
  8009c4:	74 08                	je     8009ce <strnlen+0x1f>
  8009c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ca:	75 f3                	jne    8009bf <strnlen+0x10>
  8009cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	53                   	push   %ebx
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009da:	89 c2                	mov    %eax,%edx
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e9:	84 db                	test   %bl,%bl
  8009eb:	75 ef                	jne    8009dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	53                   	push   %ebx
  8009f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f7:	53                   	push   %ebx
  8009f8:	e8 9a ff ff ff       	call   800997 <strlen>
  8009fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	01 d8                	add    %ebx,%eax
  800a05:	50                   	push   %eax
  800a06:	e8 c5 ff ff ff       	call   8009d0 <strcpy>
	return dst;
}
  800a0b:	89 d8                	mov    %ebx,%eax
  800a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1d:	89 f3                	mov    %esi,%ebx
  800a1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a22:	89 f2                	mov    %esi,%edx
  800a24:	eb 0f                	jmp    800a35 <strncpy+0x23>
		*dst++ = *src;
  800a26:	83 c2 01             	add    $0x1,%edx
  800a29:	0f b6 01             	movzbl (%ecx),%eax
  800a2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a35:	39 da                	cmp    %ebx,%edx
  800a37:	75 ed                	jne    800a26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a39:	89 f0                	mov    %esi,%eax
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 75 08             	mov    0x8(%ebp),%esi
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4f:	85 d2                	test   %edx,%edx
  800a51:	74 21                	je     800a74 <strlcpy+0x35>
  800a53:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a57:	89 f2                	mov    %esi,%edx
  800a59:	eb 09                	jmp    800a64 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a64:	39 c2                	cmp    %eax,%edx
  800a66:	74 09                	je     800a71 <strlcpy+0x32>
  800a68:	0f b6 19             	movzbl (%ecx),%ebx
  800a6b:	84 db                	test   %bl,%bl
  800a6d:	75 ec                	jne    800a5b <strlcpy+0x1c>
  800a6f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a71:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a74:	29 f0                	sub    %esi,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a83:	eb 06                	jmp    800a8b <strcmp+0x11>
		p++, q++;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	84 c0                	test   %al,%al
  800a90:	74 04                	je     800a96 <strcmp+0x1c>
  800a92:	3a 02                	cmp    (%edx),%al
  800a94:	74 ef                	je     800a85 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a96:	0f b6 c0             	movzbl %al,%eax
  800a99:	0f b6 12             	movzbl (%edx),%edx
  800a9c:	29 d0                	sub    %edx,%eax
}
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	89 c3                	mov    %eax,%ebx
  800aac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aaf:	eb 06                	jmp    800ab7 <strncmp+0x17>
		n--, p++, q++;
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab7:	39 d8                	cmp    %ebx,%eax
  800ab9:	74 15                	je     800ad0 <strncmp+0x30>
  800abb:	0f b6 08             	movzbl (%eax),%ecx
  800abe:	84 c9                	test   %cl,%cl
  800ac0:	74 04                	je     800ac6 <strncmp+0x26>
  800ac2:	3a 0a                	cmp    (%edx),%cl
  800ac4:	74 eb                	je     800ab1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac6:	0f b6 00             	movzbl (%eax),%eax
  800ac9:	0f b6 12             	movzbl (%edx),%edx
  800acc:	29 d0                	sub    %edx,%eax
  800ace:	eb 05                	jmp    800ad5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae2:	eb 07                	jmp    800aeb <strchr+0x13>
		if (*s == c)
  800ae4:	38 ca                	cmp    %cl,%dl
  800ae6:	74 0f                	je     800af7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	0f b6 10             	movzbl (%eax),%edx
  800aee:	84 d2                	test   %dl,%dl
  800af0:	75 f2                	jne    800ae4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b03:	eb 03                	jmp    800b08 <strfind+0xf>
  800b05:	83 c0 01             	add    $0x1,%eax
  800b08:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b0b:	38 ca                	cmp    %cl,%dl
  800b0d:	74 04                	je     800b13 <strfind+0x1a>
  800b0f:	84 d2                	test   %dl,%dl
  800b11:	75 f2                	jne    800b05 <strfind+0xc>
			break;
	return (char *) s;
}
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b21:	85 c9                	test   %ecx,%ecx
  800b23:	74 36                	je     800b5b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2b:	75 28                	jne    800b55 <memset+0x40>
  800b2d:	f6 c1 03             	test   $0x3,%cl
  800b30:	75 23                	jne    800b55 <memset+0x40>
		c &= 0xFF;
  800b32:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	c1 e3 08             	shl    $0x8,%ebx
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	c1 e6 18             	shl    $0x18,%esi
  800b40:	89 d0                	mov    %edx,%eax
  800b42:	c1 e0 10             	shl    $0x10,%eax
  800b45:	09 f0                	or     %esi,%eax
  800b47:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b49:	89 d8                	mov    %ebx,%eax
  800b4b:	09 d0                	or     %edx,%eax
  800b4d:	c1 e9 02             	shr    $0x2,%ecx
  800b50:	fc                   	cld    
  800b51:	f3 ab                	rep stos %eax,%es:(%edi)
  800b53:	eb 06                	jmp    800b5b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	fc                   	cld    
  800b59:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5b:	89 f8                	mov    %edi,%eax
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b70:	39 c6                	cmp    %eax,%esi
  800b72:	73 35                	jae    800ba9 <memmove+0x47>
  800b74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b77:	39 d0                	cmp    %edx,%eax
  800b79:	73 2e                	jae    800ba9 <memmove+0x47>
		s += n;
		d += n;
  800b7b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	09 fe                	or     %edi,%esi
  800b82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b88:	75 13                	jne    800b9d <memmove+0x3b>
  800b8a:	f6 c1 03             	test   $0x3,%cl
  800b8d:	75 0e                	jne    800b9d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8f:	83 ef 04             	sub    $0x4,%edi
  800b92:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b95:	c1 e9 02             	shr    $0x2,%ecx
  800b98:	fd                   	std    
  800b99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9b:	eb 09                	jmp    800ba6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9d:	83 ef 01             	sub    $0x1,%edi
  800ba0:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba3:	fd                   	std    
  800ba4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba6:	fc                   	cld    
  800ba7:	eb 1d                	jmp    800bc6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba9:	89 f2                	mov    %esi,%edx
  800bab:	09 c2                	or     %eax,%edx
  800bad:	f6 c2 03             	test   $0x3,%dl
  800bb0:	75 0f                	jne    800bc1 <memmove+0x5f>
  800bb2:	f6 c1 03             	test   $0x3,%cl
  800bb5:	75 0a                	jne    800bc1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb7:	c1 e9 02             	shr    $0x2,%ecx
  800bba:	89 c7                	mov    %eax,%edi
  800bbc:	fc                   	cld    
  800bbd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbf:	eb 05                	jmp    800bc6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc1:	89 c7                	mov    %eax,%edi
  800bc3:	fc                   	cld    
  800bc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcd:	ff 75 10             	pushl  0x10(%ebp)
  800bd0:	ff 75 0c             	pushl  0xc(%ebp)
  800bd3:	ff 75 08             	pushl  0x8(%ebp)
  800bd6:	e8 87 ff ff ff       	call   800b62 <memmove>
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be8:	89 c6                	mov    %eax,%esi
  800bea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bed:	eb 1a                	jmp    800c09 <memcmp+0x2c>
		if (*s1 != *s2)
  800bef:	0f b6 08             	movzbl (%eax),%ecx
  800bf2:	0f b6 1a             	movzbl (%edx),%ebx
  800bf5:	38 d9                	cmp    %bl,%cl
  800bf7:	74 0a                	je     800c03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf9:	0f b6 c1             	movzbl %cl,%eax
  800bfc:	0f b6 db             	movzbl %bl,%ebx
  800bff:	29 d8                	sub    %ebx,%eax
  800c01:	eb 0f                	jmp    800c12 <memcmp+0x35>
		s1++, s2++;
  800c03:	83 c0 01             	add    $0x1,%eax
  800c06:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c09:	39 f0                	cmp    %esi,%eax
  800c0b:	75 e2                	jne    800bef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	53                   	push   %ebx
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1d:	89 c1                	mov    %eax,%ecx
  800c1f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c22:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c26:	eb 0a                	jmp    800c32 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c28:	0f b6 10             	movzbl (%eax),%edx
  800c2b:	39 da                	cmp    %ebx,%edx
  800c2d:	74 07                	je     800c36 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2f:	83 c0 01             	add    $0x1,%eax
  800c32:	39 c8                	cmp    %ecx,%eax
  800c34:	72 f2                	jb     800c28 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c36:	5b                   	pop    %ebx
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c45:	eb 03                	jmp    800c4a <strtol+0x11>
		s++;
  800c47:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4a:	0f b6 01             	movzbl (%ecx),%eax
  800c4d:	3c 20                	cmp    $0x20,%al
  800c4f:	74 f6                	je     800c47 <strtol+0xe>
  800c51:	3c 09                	cmp    $0x9,%al
  800c53:	74 f2                	je     800c47 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c55:	3c 2b                	cmp    $0x2b,%al
  800c57:	75 0a                	jne    800c63 <strtol+0x2a>
		s++;
  800c59:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c61:	eb 11                	jmp    800c74 <strtol+0x3b>
  800c63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c68:	3c 2d                	cmp    $0x2d,%al
  800c6a:	75 08                	jne    800c74 <strtol+0x3b>
		s++, neg = 1;
  800c6c:	83 c1 01             	add    $0x1,%ecx
  800c6f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7a:	75 15                	jne    800c91 <strtol+0x58>
  800c7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7f:	75 10                	jne    800c91 <strtol+0x58>
  800c81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c85:	75 7c                	jne    800d03 <strtol+0xca>
		s += 2, base = 16;
  800c87:	83 c1 02             	add    $0x2,%ecx
  800c8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8f:	eb 16                	jmp    800ca7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c91:	85 db                	test   %ebx,%ebx
  800c93:	75 12                	jne    800ca7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9d:	75 08                	jne    800ca7 <strtol+0x6e>
		s++, base = 8;
  800c9f:	83 c1 01             	add    $0x1,%ecx
  800ca2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800caf:	0f b6 11             	movzbl (%ecx),%edx
  800cb2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb5:	89 f3                	mov    %esi,%ebx
  800cb7:	80 fb 09             	cmp    $0x9,%bl
  800cba:	77 08                	ja     800cc4 <strtol+0x8b>
			dig = *s - '0';
  800cbc:	0f be d2             	movsbl %dl,%edx
  800cbf:	83 ea 30             	sub    $0x30,%edx
  800cc2:	eb 22                	jmp    800ce6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc7:	89 f3                	mov    %esi,%ebx
  800cc9:	80 fb 19             	cmp    $0x19,%bl
  800ccc:	77 08                	ja     800cd6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cce:	0f be d2             	movsbl %dl,%edx
  800cd1:	83 ea 57             	sub    $0x57,%edx
  800cd4:	eb 10                	jmp    800ce6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd9:	89 f3                	mov    %esi,%ebx
  800cdb:	80 fb 19             	cmp    $0x19,%bl
  800cde:	77 16                	ja     800cf6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ce0:	0f be d2             	movsbl %dl,%edx
  800ce3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce9:	7d 0b                	jge    800cf6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ceb:	83 c1 01             	add    $0x1,%ecx
  800cee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf4:	eb b9                	jmp    800caf <strtol+0x76>

	if (endptr)
  800cf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cfa:	74 0d                	je     800d09 <strtol+0xd0>
		*endptr = (char *) s;
  800cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cff:	89 0e                	mov    %ecx,(%esi)
  800d01:	eb 06                	jmp    800d09 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d03:	85 db                	test   %ebx,%ebx
  800d05:	74 98                	je     800c9f <strtol+0x66>
  800d07:	eb 9e                	jmp    800ca7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d09:	89 c2                	mov    %eax,%edx
  800d0b:	f7 da                	neg    %edx
  800d0d:	85 ff                	test   %edi,%edi
  800d0f:	0f 45 c2             	cmovne %edx,%eax
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	89 c3                	mov    %eax,%ebx
  800d2a:	89 c7                	mov    %eax,%edi
  800d2c:	89 c6                	mov    %eax,%esi
  800d2e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 01 00 00 00       	mov    $0x1,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d62:	b8 03 00 00 00       	mov    $0x3,%eax
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	89 cb                	mov    %ecx,%ebx
  800d6c:	89 cf                	mov    %ecx,%edi
  800d6e:	89 ce                	mov    %ecx,%esi
  800d70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 17                	jle    800d8d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 03                	push   $0x3
  800d7c:	68 1f 29 80 00       	push   $0x80291f
  800d81:	6a 23                	push   $0x23
  800d83:	68 3c 29 80 00       	push   $0x80293c
  800d88:	e8 e5 f5 ff ff       	call   800372 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 02 00 00 00       	mov    $0x2,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_yield>:

void
sys_yield(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	be 00 00 00 00       	mov    $0x0,%esi
  800de1:	b8 04 00 00 00       	mov    $0x4,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800def:	89 f7                	mov    %esi,%edi
  800df1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 17                	jle    800e0e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	50                   	push   %eax
  800dfb:	6a 04                	push   $0x4
  800dfd:	68 1f 29 80 00       	push   $0x80291f
  800e02:	6a 23                	push   $0x23
  800e04:	68 3c 29 80 00       	push   $0x80293c
  800e09:	e8 64 f5 ff ff       	call   800372 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800e1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e30:	8b 75 18             	mov    0x18(%ebp),%esi
  800e33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 17                	jle    800e50 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	50                   	push   %eax
  800e3d:	6a 05                	push   $0x5
  800e3f:	68 1f 29 80 00       	push   $0x80291f
  800e44:	6a 23                	push   $0x23
  800e46:	68 3c 29 80 00       	push   $0x80293c
  800e4b:	e8 22 f5 ff ff       	call   800372 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800e66:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800e79:	7e 17                	jle    800e92 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	50                   	push   %eax
  800e7f:	6a 06                	push   $0x6
  800e81:	68 1f 29 80 00       	push   $0x80291f
  800e86:	6a 23                	push   $0x23
  800e88:	68 3c 29 80 00       	push   $0x80293c
  800e8d:	e8 e0 f4 ff ff       	call   800372 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 17                	jle    800ed4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	50                   	push   %eax
  800ec1:	6a 08                	push   $0x8
  800ec3:	68 1f 29 80 00       	push   $0x80291f
  800ec8:	6a 23                	push   $0x23
  800eca:	68 3c 29 80 00       	push   $0x80293c
  800ecf:	e8 9e f4 ff ff       	call   800372 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eea:	b8 09 00 00 00       	mov    $0x9,%eax
  800eef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	89 df                	mov    %ebx,%edi
  800ef7:	89 de                	mov    %ebx,%esi
  800ef9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800efb:	85 c0                	test   %eax,%eax
  800efd:	7e 17                	jle    800f16 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	50                   	push   %eax
  800f03:	6a 09                	push   $0x9
  800f05:	68 1f 29 80 00       	push   $0x80291f
  800f0a:	6a 23                	push   $0x23
  800f0c:	68 3c 29 80 00       	push   $0x80293c
  800f11:	e8 5c f4 ff ff       	call   800372 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	89 df                	mov    %ebx,%edi
  800f39:	89 de                	mov    %ebx,%esi
  800f3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7e 17                	jle    800f58 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	50                   	push   %eax
  800f45:	6a 0a                	push   $0xa
  800f47:	68 1f 29 80 00       	push   $0x80291f
  800f4c:	6a 23                	push   $0x23
  800f4e:	68 3c 29 80 00       	push   $0x80293c
  800f53:	e8 1a f4 ff ff       	call   800372 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f66:	be 00 00 00 00       	mov    $0x0,%esi
  800f6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
  800f99:	89 cb                	mov    %ecx,%ebx
  800f9b:	89 cf                	mov    %ecx,%edi
  800f9d:	89 ce                	mov    %ecx,%esi
  800f9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	7e 17                	jle    800fbc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa5:	83 ec 0c             	sub    $0xc,%esp
  800fa8:	50                   	push   %eax
  800fa9:	6a 0d                	push   $0xd
  800fab:	68 1f 29 80 00       	push   $0x80291f
  800fb0:	6a 23                	push   $0x23
  800fb2:	68 3c 29 80 00       	push   $0x80293c
  800fb7:	e8 b6 f3 ff ff       	call   800372 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd7:	89 cb                	mov    %ecx,%ebx
  800fd9:	89 cf                	mov    %ecx,%edi
  800fdb:	89 ce                	mov    %ecx,%esi
  800fdd:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 04             	sub    $0x4,%esp
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fee:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ff0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ff4:	74 11                	je     801007 <pgfault+0x23>
  800ff6:	89 d8                	mov    %ebx,%eax
  800ff8:	c1 e8 0c             	shr    $0xc,%eax
  800ffb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801002:	f6 c4 08             	test   $0x8,%ah
  801005:	75 14                	jne    80101b <pgfault+0x37>
		panic("faulting access");
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	68 4a 29 80 00       	push   $0x80294a
  80100f:	6a 1d                	push   $0x1d
  801011:	68 5a 29 80 00       	push   $0x80295a
  801016:	e8 57 f3 ff ff       	call   800372 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80101b:	83 ec 04             	sub    $0x4,%esp
  80101e:	6a 07                	push   $0x7
  801020:	68 00 f0 7f 00       	push   $0x7ff000
  801025:	6a 00                	push   $0x0
  801027:	e8 a7 fd ff ff       	call   800dd3 <sys_page_alloc>
	if (r < 0) {
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	79 12                	jns    801045 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801033:	50                   	push   %eax
  801034:	68 65 29 80 00       	push   $0x802965
  801039:	6a 2b                	push   $0x2b
  80103b:	68 5a 29 80 00       	push   $0x80295a
  801040:	e8 2d f3 ff ff       	call   800372 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801045:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	68 00 10 00 00       	push   $0x1000
  801053:	53                   	push   %ebx
  801054:	68 00 f0 7f 00       	push   $0x7ff000
  801059:	e8 6c fb ff ff       	call   800bca <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80105e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801065:	53                   	push   %ebx
  801066:	6a 00                	push   $0x0
  801068:	68 00 f0 7f 00       	push   $0x7ff000
  80106d:	6a 00                	push   $0x0
  80106f:	e8 a2 fd ff ff       	call   800e16 <sys_page_map>
	if (r < 0) {
  801074:	83 c4 20             	add    $0x20,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	79 12                	jns    80108d <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80107b:	50                   	push   %eax
  80107c:	68 65 29 80 00       	push   $0x802965
  801081:	6a 32                	push   $0x32
  801083:	68 5a 29 80 00       	push   $0x80295a
  801088:	e8 e5 f2 ff ff       	call   800372 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	68 00 f0 7f 00       	push   $0x7ff000
  801095:	6a 00                	push   $0x0
  801097:	e8 bc fd ff ff       	call   800e58 <sys_page_unmap>
	if (r < 0) {
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 12                	jns    8010b5 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8010a3:	50                   	push   %eax
  8010a4:	68 65 29 80 00       	push   $0x802965
  8010a9:	6a 36                	push   $0x36
  8010ab:	68 5a 29 80 00       	push   $0x80295a
  8010b0:	e8 bd f2 ff ff       	call   800372 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8010b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8010c3:	68 e4 0f 80 00       	push   $0x800fe4
  8010c8:	e8 3a 0f 00 00       	call   802007 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010cd:	b8 07 00 00 00       	mov    $0x7,%eax
  8010d2:	cd 30                	int    $0x30
  8010d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 17                	jns    8010f5 <fork+0x3b>
		panic("fork fault %e");
  8010de:	83 ec 04             	sub    $0x4,%esp
  8010e1:	68 7e 29 80 00       	push   $0x80297e
  8010e6:	68 83 00 00 00       	push   $0x83
  8010eb:	68 5a 29 80 00       	push   $0x80295a
  8010f0:	e8 7d f2 ff ff       	call   800372 <_panic>
  8010f5:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8010f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010fb:	75 25                	jne    801122 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010fd:	e8 93 fc ff ff       	call   800d95 <sys_getenvid>
  801102:	25 ff 03 00 00       	and    $0x3ff,%eax
  801107:	89 c2                	mov    %eax,%edx
  801109:	c1 e2 07             	shl    $0x7,%edx
  80110c:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801113:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	e9 61 01 00 00       	jmp    801283 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	6a 07                	push   $0x7
  801127:	68 00 f0 bf ee       	push   $0xeebff000
  80112c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112f:	e8 9f fc ff ff       	call   800dd3 <sys_page_alloc>
  801134:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801137:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80113c:	89 d8                	mov    %ebx,%eax
  80113e:	c1 e8 16             	shr    $0x16,%eax
  801141:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801148:	a8 01                	test   $0x1,%al
  80114a:	0f 84 fc 00 00 00    	je     80124c <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801150:	89 d8                	mov    %ebx,%eax
  801152:	c1 e8 0c             	shr    $0xc,%eax
  801155:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80115c:	f6 c2 01             	test   $0x1,%dl
  80115f:	0f 84 e7 00 00 00    	je     80124c <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801165:	89 c6                	mov    %eax,%esi
  801167:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80116a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801171:	f6 c6 04             	test   $0x4,%dh
  801174:	74 39                	je     8011af <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801176:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	25 07 0e 00 00       	and    $0xe07,%eax
  801185:	50                   	push   %eax
  801186:	56                   	push   %esi
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	6a 00                	push   $0x0
  80118b:	e8 86 fc ff ff       	call   800e16 <sys_page_map>
		if (r < 0) {
  801190:	83 c4 20             	add    $0x20,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	0f 89 b1 00 00 00    	jns    80124c <fork+0x192>
		    	panic("sys page map fault %e");
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	68 8c 29 80 00       	push   $0x80298c
  8011a3:	6a 53                	push   $0x53
  8011a5:	68 5a 29 80 00       	push   $0x80295a
  8011aa:	e8 c3 f1 ff ff       	call   800372 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8011af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011b6:	f6 c2 02             	test   $0x2,%dl
  8011b9:	75 0c                	jne    8011c7 <fork+0x10d>
  8011bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c2:	f6 c4 08             	test   $0x8,%ah
  8011c5:	74 5b                	je     801222 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	68 05 08 00 00       	push   $0x805
  8011cf:	56                   	push   %esi
  8011d0:	57                   	push   %edi
  8011d1:	56                   	push   %esi
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 3d fc ff ff       	call   800e16 <sys_page_map>
		if (r < 0) {
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	79 14                	jns    8011f4 <fork+0x13a>
		    	panic("sys page map fault %e");
  8011e0:	83 ec 04             	sub    $0x4,%esp
  8011e3:	68 8c 29 80 00       	push   $0x80298c
  8011e8:	6a 5a                	push   $0x5a
  8011ea:	68 5a 29 80 00       	push   $0x80295a
  8011ef:	e8 7e f1 ff ff       	call   800372 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	68 05 08 00 00       	push   $0x805
  8011fc:	56                   	push   %esi
  8011fd:	6a 00                	push   $0x0
  8011ff:	56                   	push   %esi
  801200:	6a 00                	push   $0x0
  801202:	e8 0f fc ff ff       	call   800e16 <sys_page_map>
		if (r < 0) {
  801207:	83 c4 20             	add    $0x20,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	79 3e                	jns    80124c <fork+0x192>
		    	panic("sys page map fault %e");
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	68 8c 29 80 00       	push   $0x80298c
  801216:	6a 5e                	push   $0x5e
  801218:	68 5a 29 80 00       	push   $0x80295a
  80121d:	e8 50 f1 ff ff       	call   800372 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801222:	83 ec 0c             	sub    $0xc,%esp
  801225:	6a 05                	push   $0x5
  801227:	56                   	push   %esi
  801228:	57                   	push   %edi
  801229:	56                   	push   %esi
  80122a:	6a 00                	push   $0x0
  80122c:	e8 e5 fb ff ff       	call   800e16 <sys_page_map>
		if (r < 0) {
  801231:	83 c4 20             	add    $0x20,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	79 14                	jns    80124c <fork+0x192>
		    	panic("sys page map fault %e");
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	68 8c 29 80 00       	push   $0x80298c
  801240:	6a 63                	push   $0x63
  801242:	68 5a 29 80 00       	push   $0x80295a
  801247:	e8 26 f1 ff ff       	call   800372 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80124c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801252:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801258:	0f 85 de fe ff ff    	jne    80113c <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80125e:	a1 04 40 80 00       	mov    0x804004,%eax
  801263:	8b 40 6c             	mov    0x6c(%eax),%eax
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	50                   	push   %eax
  80126a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80126d:	57                   	push   %edi
  80126e:	e8 ab fc ff ff       	call   800f1e <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801273:	83 c4 08             	add    $0x8,%esp
  801276:	6a 02                	push   $0x2
  801278:	57                   	push   %edi
  801279:	e8 1c fc ff ff       	call   800e9a <sys_env_set_status>
	
	return envid;
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <sfork>:

envid_t
sfork(void)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	68 a4 29 80 00       	push   $0x8029a4
  8012a6:	e8 a0 f1 ff ff       	call   80044b <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  8012ab:	89 1c 24             	mov    %ebx,(%esp)
  8012ae:	e8 11 fd ff ff       	call   800fc4 <sys_thread_create>
  8012b3:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012b5:	83 c4 08             	add    $0x8,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	68 a4 29 80 00       	push   $0x8029a4
  8012be:	e8 88 f1 ff ff       	call   80044b <cprintf>
	return id;
}
  8012c3:	89 f0                	mov    %esi,%eax
  8012c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012df:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 ea 16             	shr    $0x16,%edx
  801303:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130a:	f6 c2 01             	test   $0x1,%dl
  80130d:	74 11                	je     801320 <fd_alloc+0x2d>
  80130f:	89 c2                	mov    %eax,%edx
  801311:	c1 ea 0c             	shr    $0xc,%edx
  801314:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131b:	f6 c2 01             	test   $0x1,%dl
  80131e:	75 09                	jne    801329 <fd_alloc+0x36>
			*fd_store = fd;
  801320:	89 01                	mov    %eax,(%ecx)
			return 0;
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
  801327:	eb 17                	jmp    801340 <fd_alloc+0x4d>
  801329:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80132e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801333:	75 c9                	jne    8012fe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801335:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80133b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801348:	83 f8 1f             	cmp    $0x1f,%eax
  80134b:	77 36                	ja     801383 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80134d:	c1 e0 0c             	shl    $0xc,%eax
  801350:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801355:	89 c2                	mov    %eax,%edx
  801357:	c1 ea 16             	shr    $0x16,%edx
  80135a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801361:	f6 c2 01             	test   $0x1,%dl
  801364:	74 24                	je     80138a <fd_lookup+0x48>
  801366:	89 c2                	mov    %eax,%edx
  801368:	c1 ea 0c             	shr    $0xc,%edx
  80136b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801372:	f6 c2 01             	test   $0x1,%dl
  801375:	74 1a                	je     801391 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801377:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137a:	89 02                	mov    %eax,(%edx)
	return 0;
  80137c:	b8 00 00 00 00       	mov    $0x0,%eax
  801381:	eb 13                	jmp    801396 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801383:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801388:	eb 0c                	jmp    801396 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138f:	eb 05                	jmp    801396 <fd_lookup+0x54>
  801391:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a1:	ba 48 2a 80 00       	mov    $0x802a48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a6:	eb 13                	jmp    8013bb <dev_lookup+0x23>
  8013a8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ab:	39 08                	cmp    %ecx,(%eax)
  8013ad:	75 0c                	jne    8013bb <dev_lookup+0x23>
			*dev = devtab[i];
  8013af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b9:	eb 2e                	jmp    8013e9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013bb:	8b 02                	mov    (%edx),%eax
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	75 e7                	jne    8013a8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c6:	8b 40 50             	mov    0x50(%eax),%eax
  8013c9:	83 ec 04             	sub    $0x4,%esp
  8013cc:	51                   	push   %ecx
  8013cd:	50                   	push   %eax
  8013ce:	68 c8 29 80 00       	push   $0x8029c8
  8013d3:	e8 73 f0 ff ff       	call   80044b <cprintf>
	*dev = 0;
  8013d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 10             	sub    $0x10,%esp
  8013f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801403:	c1 e8 0c             	shr    $0xc,%eax
  801406:	50                   	push   %eax
  801407:	e8 36 ff ff ff       	call   801342 <fd_lookup>
  80140c:	83 c4 08             	add    $0x8,%esp
  80140f:	85 c0                	test   %eax,%eax
  801411:	78 05                	js     801418 <fd_close+0x2d>
	    || fd != fd2)
  801413:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801416:	74 0c                	je     801424 <fd_close+0x39>
		return (must_exist ? r : 0);
  801418:	84 db                	test   %bl,%bl
  80141a:	ba 00 00 00 00       	mov    $0x0,%edx
  80141f:	0f 44 c2             	cmove  %edx,%eax
  801422:	eb 41                	jmp    801465 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	ff 36                	pushl  (%esi)
  80142d:	e8 66 ff ff ff       	call   801398 <dev_lookup>
  801432:	89 c3                	mov    %eax,%ebx
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	78 1a                	js     801455 <fd_close+0x6a>
		if (dev->dev_close)
  80143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801441:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801446:	85 c0                	test   %eax,%eax
  801448:	74 0b                	je     801455 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	56                   	push   %esi
  80144e:	ff d0                	call   *%eax
  801450:	89 c3                	mov    %eax,%ebx
  801452:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	56                   	push   %esi
  801459:	6a 00                	push   $0x0
  80145b:	e8 f8 f9 ff ff       	call   800e58 <sys_page_unmap>
	return r;
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	89 d8                	mov    %ebx,%eax
}
  801465:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	ff 75 08             	pushl  0x8(%ebp)
  801479:	e8 c4 fe ff ff       	call   801342 <fd_lookup>
  80147e:	83 c4 08             	add    $0x8,%esp
  801481:	85 c0                	test   %eax,%eax
  801483:	78 10                	js     801495 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	6a 01                	push   $0x1
  80148a:	ff 75 f4             	pushl  -0xc(%ebp)
  80148d:	e8 59 ff ff ff       	call   8013eb <fd_close>
  801492:	83 c4 10             	add    $0x10,%esp
}
  801495:	c9                   	leave  
  801496:	c3                   	ret    

00801497 <close_all>:

void
close_all(void)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	53                   	push   %ebx
  80149b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80149e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	e8 c0 ff ff ff       	call   80146c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ac:	83 c3 01             	add    $0x1,%ebx
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	83 fb 20             	cmp    $0x20,%ebx
  8014b5:	75 ec                	jne    8014a3 <close_all+0xc>
		close(i);
}
  8014b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	57                   	push   %edi
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 2c             	sub    $0x2c,%esp
  8014c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	ff 75 08             	pushl  0x8(%ebp)
  8014cf:	e8 6e fe ff ff       	call   801342 <fd_lookup>
  8014d4:	83 c4 08             	add    $0x8,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	0f 88 c1 00 00 00    	js     8015a0 <dup+0xe4>
		return r;
	close(newfdnum);
  8014df:	83 ec 0c             	sub    $0xc,%esp
  8014e2:	56                   	push   %esi
  8014e3:	e8 84 ff ff ff       	call   80146c <close>

	newfd = INDEX2FD(newfdnum);
  8014e8:	89 f3                	mov    %esi,%ebx
  8014ea:	c1 e3 0c             	shl    $0xc,%ebx
  8014ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f3:	83 c4 04             	add    $0x4,%esp
  8014f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014f9:	e8 de fd ff ff       	call   8012dc <fd2data>
  8014fe:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801500:	89 1c 24             	mov    %ebx,(%esp)
  801503:	e8 d4 fd ff ff       	call   8012dc <fd2data>
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80150e:	89 f8                	mov    %edi,%eax
  801510:	c1 e8 16             	shr    $0x16,%eax
  801513:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151a:	a8 01                	test   $0x1,%al
  80151c:	74 37                	je     801555 <dup+0x99>
  80151e:	89 f8                	mov    %edi,%eax
  801520:	c1 e8 0c             	shr    $0xc,%eax
  801523:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152a:	f6 c2 01             	test   $0x1,%dl
  80152d:	74 26                	je     801555 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	25 07 0e 00 00       	and    $0xe07,%eax
  80153e:	50                   	push   %eax
  80153f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801542:	6a 00                	push   $0x0
  801544:	57                   	push   %edi
  801545:	6a 00                	push   $0x0
  801547:	e8 ca f8 ff ff       	call   800e16 <sys_page_map>
  80154c:	89 c7                	mov    %eax,%edi
  80154e:	83 c4 20             	add    $0x20,%esp
  801551:	85 c0                	test   %eax,%eax
  801553:	78 2e                	js     801583 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801555:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801558:	89 d0                	mov    %edx,%eax
  80155a:	c1 e8 0c             	shr    $0xc,%eax
  80155d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	25 07 0e 00 00       	and    $0xe07,%eax
  80156c:	50                   	push   %eax
  80156d:	53                   	push   %ebx
  80156e:	6a 00                	push   $0x0
  801570:	52                   	push   %edx
  801571:	6a 00                	push   $0x0
  801573:	e8 9e f8 ff ff       	call   800e16 <sys_page_map>
  801578:	89 c7                	mov    %eax,%edi
  80157a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80157d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157f:	85 ff                	test   %edi,%edi
  801581:	79 1d                	jns    8015a0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	53                   	push   %ebx
  801587:	6a 00                	push   $0x0
  801589:	e8 ca f8 ff ff       	call   800e58 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	ff 75 d4             	pushl  -0x2c(%ebp)
  801594:	6a 00                	push   $0x0
  801596:	e8 bd f8 ff ff       	call   800e58 <sys_page_unmap>
	return r;
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	89 f8                	mov    %edi,%eax
}
  8015a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5f                   	pop    %edi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    

008015a8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 14             	sub    $0x14,%esp
  8015af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	53                   	push   %ebx
  8015b7:	e8 86 fd ff ff       	call   801342 <fd_lookup>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 6d                	js     801632 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	ff 30                	pushl  (%eax)
  8015d1:	e8 c2 fd ff ff       	call   801398 <dev_lookup>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 4c                	js     801629 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e0:	8b 42 08             	mov    0x8(%edx),%eax
  8015e3:	83 e0 03             	and    $0x3,%eax
  8015e6:	83 f8 01             	cmp    $0x1,%eax
  8015e9:	75 21                	jne    80160c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f0:	8b 40 50             	mov    0x50(%eax),%eax
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	50                   	push   %eax
  8015f8:	68 0c 2a 80 00       	push   $0x802a0c
  8015fd:	e8 49 ee ff ff       	call   80044b <cprintf>
		return -E_INVAL;
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160a:	eb 26                	jmp    801632 <read+0x8a>
	}
	if (!dev->dev_read)
  80160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160f:	8b 40 08             	mov    0x8(%eax),%eax
  801612:	85 c0                	test   %eax,%eax
  801614:	74 17                	je     80162d <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801616:	83 ec 04             	sub    $0x4,%esp
  801619:	ff 75 10             	pushl  0x10(%ebp)
  80161c:	ff 75 0c             	pushl  0xc(%ebp)
  80161f:	52                   	push   %edx
  801620:	ff d0                	call   *%eax
  801622:	89 c2                	mov    %eax,%edx
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	eb 09                	jmp    801632 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801629:	89 c2                	mov    %eax,%edx
  80162b:	eb 05                	jmp    801632 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80162d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801632:	89 d0                	mov    %edx,%eax
  801634:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	57                   	push   %edi
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	8b 7d 08             	mov    0x8(%ebp),%edi
  801645:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801648:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164d:	eb 21                	jmp    801670 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80164f:	83 ec 04             	sub    $0x4,%esp
  801652:	89 f0                	mov    %esi,%eax
  801654:	29 d8                	sub    %ebx,%eax
  801656:	50                   	push   %eax
  801657:	89 d8                	mov    %ebx,%eax
  801659:	03 45 0c             	add    0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	57                   	push   %edi
  80165e:	e8 45 ff ff ff       	call   8015a8 <read>
		if (m < 0)
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	78 10                	js     80167a <readn+0x41>
			return m;
		if (m == 0)
  80166a:	85 c0                	test   %eax,%eax
  80166c:	74 0a                	je     801678 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80166e:	01 c3                	add    %eax,%ebx
  801670:	39 f3                	cmp    %esi,%ebx
  801672:	72 db                	jb     80164f <readn+0x16>
  801674:	89 d8                	mov    %ebx,%eax
  801676:	eb 02                	jmp    80167a <readn+0x41>
  801678:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5f                   	pop    %edi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 14             	sub    $0x14,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	53                   	push   %ebx
  801691:	e8 ac fc ff ff       	call   801342 <fd_lookup>
  801696:	83 c4 08             	add    $0x8,%esp
  801699:	89 c2                	mov    %eax,%edx
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 68                	js     801707 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a9:	ff 30                	pushl  (%eax)
  8016ab:	e8 e8 fc ff ff       	call   801398 <dev_lookup>
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 47                	js     8016fe <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016be:	75 21                	jne    8016e1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c5:	8b 40 50             	mov    0x50(%eax),%eax
  8016c8:	83 ec 04             	sub    $0x4,%esp
  8016cb:	53                   	push   %ebx
  8016cc:	50                   	push   %eax
  8016cd:	68 28 2a 80 00       	push   $0x802a28
  8016d2:	e8 74 ed ff ff       	call   80044b <cprintf>
		return -E_INVAL;
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016df:	eb 26                	jmp    801707 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e7:	85 d2                	test   %edx,%edx
  8016e9:	74 17                	je     801702 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	ff 75 10             	pushl  0x10(%ebp)
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	50                   	push   %eax
  8016f5:	ff d2                	call   *%edx
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	eb 09                	jmp    801707 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	eb 05                	jmp    801707 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801702:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801707:	89 d0                	mov    %edx,%eax
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <seek>:

int
seek(int fdnum, off_t offset)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801714:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	ff 75 08             	pushl  0x8(%ebp)
  80171b:	e8 22 fc ff ff       	call   801342 <fd_lookup>
  801720:	83 c4 08             	add    $0x8,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	78 0e                	js     801735 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801727:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80172a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801730:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 14             	sub    $0x14,%esp
  80173e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801741:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801744:	50                   	push   %eax
  801745:	53                   	push   %ebx
  801746:	e8 f7 fb ff ff       	call   801342 <fd_lookup>
  80174b:	83 c4 08             	add    $0x8,%esp
  80174e:	89 c2                	mov    %eax,%edx
  801750:	85 c0                	test   %eax,%eax
  801752:	78 65                	js     8017b9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175e:	ff 30                	pushl  (%eax)
  801760:	e8 33 fc ff ff       	call   801398 <dev_lookup>
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 44                	js     8017b0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801773:	75 21                	jne    801796 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801775:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80177a:	8b 40 50             	mov    0x50(%eax),%eax
  80177d:	83 ec 04             	sub    $0x4,%esp
  801780:	53                   	push   %ebx
  801781:	50                   	push   %eax
  801782:	68 e8 29 80 00       	push   $0x8029e8
  801787:	e8 bf ec ff ff       	call   80044b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801794:	eb 23                	jmp    8017b9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801796:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801799:	8b 52 18             	mov    0x18(%edx),%edx
  80179c:	85 d2                	test   %edx,%edx
  80179e:	74 14                	je     8017b4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	50                   	push   %eax
  8017a7:	ff d2                	call   *%edx
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	eb 09                	jmp    8017b9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	eb 05                	jmp    8017b9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017b9:	89 d0                	mov    %edx,%eax
  8017bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 14             	sub    $0x14,%esp
  8017c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cd:	50                   	push   %eax
  8017ce:	ff 75 08             	pushl  0x8(%ebp)
  8017d1:	e8 6c fb ff ff       	call   801342 <fd_lookup>
  8017d6:	83 c4 08             	add    $0x8,%esp
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 58                	js     801837 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e5:	50                   	push   %eax
  8017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e9:	ff 30                	pushl  (%eax)
  8017eb:	e8 a8 fb ff ff       	call   801398 <dev_lookup>
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 37                	js     80182e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017fe:	74 32                	je     801832 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801800:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801803:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80180a:	00 00 00 
	stat->st_isdir = 0;
  80180d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801814:	00 00 00 
	stat->st_dev = dev;
  801817:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	53                   	push   %ebx
  801821:	ff 75 f0             	pushl  -0x10(%ebp)
  801824:	ff 50 14             	call   *0x14(%eax)
  801827:	89 c2                	mov    %eax,%edx
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	eb 09                	jmp    801837 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182e:	89 c2                	mov    %eax,%edx
  801830:	eb 05                	jmp    801837 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801832:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801837:	89 d0                	mov    %edx,%eax
  801839:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	6a 00                	push   $0x0
  801848:	ff 75 08             	pushl  0x8(%ebp)
  80184b:	e8 e3 01 00 00       	call   801a33 <open>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	78 1b                	js     801874 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801859:	83 ec 08             	sub    $0x8,%esp
  80185c:	ff 75 0c             	pushl  0xc(%ebp)
  80185f:	50                   	push   %eax
  801860:	e8 5b ff ff ff       	call   8017c0 <fstat>
  801865:	89 c6                	mov    %eax,%esi
	close(fd);
  801867:	89 1c 24             	mov    %ebx,(%esp)
  80186a:	e8 fd fb ff ff       	call   80146c <close>
	return r;
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	89 f0                	mov    %esi,%eax
}
  801874:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	89 c6                	mov    %eax,%esi
  801882:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801884:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80188b:	75 12                	jne    80189f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	6a 01                	push   $0x1
  801892:	e8 d6 08 00 00       	call   80216d <ipc_find_env>
  801897:	a3 00 40 80 00       	mov    %eax,0x804000
  80189c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80189f:	6a 07                	push   $0x7
  8018a1:	68 00 50 80 00       	push   $0x805000
  8018a6:	56                   	push   %esi
  8018a7:	ff 35 00 40 80 00    	pushl  0x804000
  8018ad:	e8 59 08 00 00       	call   80210b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b2:	83 c4 0c             	add    $0xc,%esp
  8018b5:	6a 00                	push   $0x0
  8018b7:	53                   	push   %ebx
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 d7 07 00 00       	call   802096 <ipc_recv>
}
  8018bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018da:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8018e9:	e8 8d ff ff ff       	call   80187b <fsipc>
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	b8 06 00 00 00       	mov    $0x6,%eax
  80190b:	e8 6b ff ff ff       	call   80187b <fsipc>
}
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	53                   	push   %ebx
  801916:	83 ec 04             	sub    $0x4,%esp
  801919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	b8 05 00 00 00       	mov    $0x5,%eax
  801931:	e8 45 ff ff ff       	call   80187b <fsipc>
  801936:	85 c0                	test   %eax,%eax
  801938:	78 2c                	js     801966 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80193a:	83 ec 08             	sub    $0x8,%esp
  80193d:	68 00 50 80 00       	push   $0x805000
  801942:	53                   	push   %ebx
  801943:	e8 88 f0 ff ff       	call   8009d0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801948:	a1 80 50 80 00       	mov    0x805080,%eax
  80194d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801953:	a1 84 50 80 00       	mov    0x805084,%eax
  801958:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801966:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	83 ec 0c             	sub    $0xc,%esp
  801971:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801974:	8b 55 08             	mov    0x8(%ebp),%edx
  801977:	8b 52 0c             	mov    0xc(%edx),%edx
  80197a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801980:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801985:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80198a:	0f 47 c2             	cmova  %edx,%eax
  80198d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801992:	50                   	push   %eax
  801993:	ff 75 0c             	pushl  0xc(%ebp)
  801996:	68 08 50 80 00       	push   $0x805008
  80199b:	e8 c2 f1 ff ff       	call   800b62 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8019aa:	e8 cc fe ff ff       	call   80187b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019c4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d4:	e8 a2 fe ff ff       	call   80187b <fsipc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 4b                	js     801a2a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019df:	39 c6                	cmp    %eax,%esi
  8019e1:	73 16                	jae    8019f9 <devfile_read+0x48>
  8019e3:	68 58 2a 80 00       	push   $0x802a58
  8019e8:	68 5f 2a 80 00       	push   $0x802a5f
  8019ed:	6a 7c                	push   $0x7c
  8019ef:	68 74 2a 80 00       	push   $0x802a74
  8019f4:	e8 79 e9 ff ff       	call   800372 <_panic>
	assert(r <= PGSIZE);
  8019f9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019fe:	7e 16                	jle    801a16 <devfile_read+0x65>
  801a00:	68 7f 2a 80 00       	push   $0x802a7f
  801a05:	68 5f 2a 80 00       	push   $0x802a5f
  801a0a:	6a 7d                	push   $0x7d
  801a0c:	68 74 2a 80 00       	push   $0x802a74
  801a11:	e8 5c e9 ff ff       	call   800372 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a16:	83 ec 04             	sub    $0x4,%esp
  801a19:	50                   	push   %eax
  801a1a:	68 00 50 80 00       	push   $0x805000
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	e8 3b f1 ff ff       	call   800b62 <memmove>
	return r;
  801a27:	83 c4 10             	add    $0x10,%esp
}
  801a2a:	89 d8                	mov    %ebx,%eax
  801a2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	53                   	push   %ebx
  801a37:	83 ec 20             	sub    $0x20,%esp
  801a3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a3d:	53                   	push   %ebx
  801a3e:	e8 54 ef ff ff       	call   800997 <strlen>
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a4b:	7f 67                	jg     801ab4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4d:	83 ec 0c             	sub    $0xc,%esp
  801a50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a53:	50                   	push   %eax
  801a54:	e8 9a f8 ff ff       	call   8012f3 <fd_alloc>
  801a59:	83 c4 10             	add    $0x10,%esp
		return r;
  801a5c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 57                	js     801ab9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a62:	83 ec 08             	sub    $0x8,%esp
  801a65:	53                   	push   %ebx
  801a66:	68 00 50 80 00       	push   $0x805000
  801a6b:	e8 60 ef ff ff       	call   8009d0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a73:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a7b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a80:	e8 f6 fd ff ff       	call   80187b <fsipc>
  801a85:	89 c3                	mov    %eax,%ebx
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	79 14                	jns    801aa2 <open+0x6f>
		fd_close(fd, 0);
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	6a 00                	push   $0x0
  801a93:	ff 75 f4             	pushl  -0xc(%ebp)
  801a96:	e8 50 f9 ff ff       	call   8013eb <fd_close>
		return r;
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	89 da                	mov    %ebx,%edx
  801aa0:	eb 17                	jmp    801ab9 <open+0x86>
	}

	return fd2num(fd);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa8:	e8 1f f8 ff ff       	call   8012cc <fd2num>
  801aad:	89 c2                	mov    %eax,%edx
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	eb 05                	jmp    801ab9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ab4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ab9:	89 d0                	mov    %edx,%eax
  801abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  801acb:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad0:	e8 a6 fd ff ff       	call   80187b <fsipc>
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	ff 75 08             	pushl  0x8(%ebp)
  801ae5:	e8 f2 f7 ff ff       	call   8012dc <fd2data>
  801aea:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aec:	83 c4 08             	add    $0x8,%esp
  801aef:	68 8b 2a 80 00       	push   $0x802a8b
  801af4:	53                   	push   %ebx
  801af5:	e8 d6 ee ff ff       	call   8009d0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801afa:	8b 46 04             	mov    0x4(%esi),%eax
  801afd:	2b 06                	sub    (%esi),%eax
  801aff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b05:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b0c:	00 00 00 
	stat->st_dev = &devpipe;
  801b0f:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b16:	30 80 00 
	return 0;
}
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	53                   	push   %ebx
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b2f:	53                   	push   %ebx
  801b30:	6a 00                	push   $0x0
  801b32:	e8 21 f3 ff ff       	call   800e58 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b37:	89 1c 24             	mov    %ebx,(%esp)
  801b3a:	e8 9d f7 ff ff       	call   8012dc <fd2data>
  801b3f:	83 c4 08             	add    $0x8,%esp
  801b42:	50                   	push   %eax
  801b43:	6a 00                	push   $0x0
  801b45:	e8 0e f3 ff ff       	call   800e58 <sys_page_unmap>
}
  801b4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    

00801b4f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	57                   	push   %edi
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	83 ec 1c             	sub    $0x1c,%esp
  801b58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b5b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b5d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b62:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b65:	83 ec 0c             	sub    $0xc,%esp
  801b68:	ff 75 e0             	pushl  -0x20(%ebp)
  801b6b:	e8 3d 06 00 00       	call   8021ad <pageref>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	89 3c 24             	mov    %edi,(%esp)
  801b75:	e8 33 06 00 00       	call   8021ad <pageref>
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	39 c3                	cmp    %eax,%ebx
  801b7f:	0f 94 c1             	sete   %cl
  801b82:	0f b6 c9             	movzbl %cl,%ecx
  801b85:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b88:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b8e:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801b91:	39 ce                	cmp    %ecx,%esi
  801b93:	74 1b                	je     801bb0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b95:	39 c3                	cmp    %eax,%ebx
  801b97:	75 c4                	jne    801b5d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b99:	8b 42 60             	mov    0x60(%edx),%eax
  801b9c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b9f:	50                   	push   %eax
  801ba0:	56                   	push   %esi
  801ba1:	68 92 2a 80 00       	push   $0x802a92
  801ba6:	e8 a0 e8 ff ff       	call   80044b <cprintf>
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	eb ad                	jmp    801b5d <_pipeisclosed+0xe>
	}
}
  801bb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5f                   	pop    %edi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	57                   	push   %edi
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 28             	sub    $0x28,%esp
  801bc4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bc7:	56                   	push   %esi
  801bc8:	e8 0f f7 ff ff       	call   8012dc <fd2data>
  801bcd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801bd7:	eb 4b                	jmp    801c24 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bd9:	89 da                	mov    %ebx,%edx
  801bdb:	89 f0                	mov    %esi,%eax
  801bdd:	e8 6d ff ff ff       	call   801b4f <_pipeisclosed>
  801be2:	85 c0                	test   %eax,%eax
  801be4:	75 48                	jne    801c2e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801be6:	e8 c9 f1 ff ff       	call   800db4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801beb:	8b 43 04             	mov    0x4(%ebx),%eax
  801bee:	8b 0b                	mov    (%ebx),%ecx
  801bf0:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf3:	39 d0                	cmp    %edx,%eax
  801bf5:	73 e2                	jae    801bd9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bfe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	c1 fa 1f             	sar    $0x1f,%edx
  801c06:	89 d1                	mov    %edx,%ecx
  801c08:	c1 e9 1b             	shr    $0x1b,%ecx
  801c0b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c0e:	83 e2 1f             	and    $0x1f,%edx
  801c11:	29 ca                	sub    %ecx,%edx
  801c13:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c17:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c1b:	83 c0 01             	add    $0x1,%eax
  801c1e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c21:	83 c7 01             	add    $0x1,%edi
  801c24:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c27:	75 c2                	jne    801beb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c29:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2c:	eb 05                	jmp    801c33 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	57                   	push   %edi
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 18             	sub    $0x18,%esp
  801c44:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c47:	57                   	push   %edi
  801c48:	e8 8f f6 ff ff       	call   8012dc <fd2data>
  801c4d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c57:	eb 3d                	jmp    801c96 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c59:	85 db                	test   %ebx,%ebx
  801c5b:	74 04                	je     801c61 <devpipe_read+0x26>
				return i;
  801c5d:	89 d8                	mov    %ebx,%eax
  801c5f:	eb 44                	jmp    801ca5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c61:	89 f2                	mov    %esi,%edx
  801c63:	89 f8                	mov    %edi,%eax
  801c65:	e8 e5 fe ff ff       	call   801b4f <_pipeisclosed>
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	75 32                	jne    801ca0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c6e:	e8 41 f1 ff ff       	call   800db4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c73:	8b 06                	mov    (%esi),%eax
  801c75:	3b 46 04             	cmp    0x4(%esi),%eax
  801c78:	74 df                	je     801c59 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7a:	99                   	cltd   
  801c7b:	c1 ea 1b             	shr    $0x1b,%edx
  801c7e:	01 d0                	add    %edx,%eax
  801c80:	83 e0 1f             	and    $0x1f,%eax
  801c83:	29 d0                	sub    %edx,%eax
  801c85:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c90:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c93:	83 c3 01             	add    $0x1,%ebx
  801c96:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c99:	75 d8                	jne    801c73 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9e:	eb 05                	jmp    801ca5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5e                   	pop    %esi
  801caa:	5f                   	pop    %edi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	56                   	push   %esi
  801cb1:	53                   	push   %ebx
  801cb2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb8:	50                   	push   %eax
  801cb9:	e8 35 f6 ff ff       	call   8012f3 <fd_alloc>
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 88 2c 01 00 00    	js     801df7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccb:	83 ec 04             	sub    $0x4,%esp
  801cce:	68 07 04 00 00       	push   $0x407
  801cd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 f6 f0 ff ff       	call   800dd3 <sys_page_alloc>
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	89 c2                	mov    %eax,%edx
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	0f 88 0d 01 00 00    	js     801df7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cea:	83 ec 0c             	sub    $0xc,%esp
  801ced:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf0:	50                   	push   %eax
  801cf1:	e8 fd f5 ff ff       	call   8012f3 <fd_alloc>
  801cf6:	89 c3                	mov    %eax,%ebx
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	0f 88 e2 00 00 00    	js     801de5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d03:	83 ec 04             	sub    $0x4,%esp
  801d06:	68 07 04 00 00       	push   $0x407
  801d0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 be f0 ff ff       	call   800dd3 <sys_page_alloc>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	0f 88 c3 00 00 00    	js     801de5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	ff 75 f4             	pushl  -0xc(%ebp)
  801d28:	e8 af f5 ff ff       	call   8012dc <fd2data>
  801d2d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2f:	83 c4 0c             	add    $0xc,%esp
  801d32:	68 07 04 00 00       	push   $0x407
  801d37:	50                   	push   %eax
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 94 f0 ff ff       	call   800dd3 <sys_page_alloc>
  801d3f:	89 c3                	mov    %eax,%ebx
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	85 c0                	test   %eax,%eax
  801d46:	0f 88 89 00 00 00    	js     801dd5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4c:	83 ec 0c             	sub    $0xc,%esp
  801d4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d52:	e8 85 f5 ff ff       	call   8012dc <fd2data>
  801d57:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d5e:	50                   	push   %eax
  801d5f:	6a 00                	push   $0x0
  801d61:	56                   	push   %esi
  801d62:	6a 00                	push   $0x0
  801d64:	e8 ad f0 ff ff       	call   800e16 <sys_page_map>
  801d69:	89 c3                	mov    %eax,%ebx
  801d6b:	83 c4 20             	add    $0x20,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 55                	js     801dc7 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d72:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d80:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d87:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d90:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d95:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d9c:	83 ec 0c             	sub    $0xc,%esp
  801d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801da2:	e8 25 f5 ff ff       	call   8012cc <fd2num>
  801da7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801daa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dac:	83 c4 04             	add    $0x4,%esp
  801daf:	ff 75 f0             	pushl  -0x10(%ebp)
  801db2:	e8 15 f5 ff ff       	call   8012cc <fd2num>
  801db7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dba:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc5:	eb 30                	jmp    801df7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dc7:	83 ec 08             	sub    $0x8,%esp
  801dca:	56                   	push   %esi
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 86 f0 ff ff       	call   800e58 <sys_page_unmap>
  801dd2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dd5:	83 ec 08             	sub    $0x8,%esp
  801dd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 76 f0 ff ff       	call   800e58 <sys_page_unmap>
  801de2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801de5:	83 ec 08             	sub    $0x8,%esp
  801de8:	ff 75 f4             	pushl  -0xc(%ebp)
  801deb:	6a 00                	push   $0x0
  801ded:	e8 66 f0 ff ff       	call   800e58 <sys_page_unmap>
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801df7:	89 d0                	mov    %edx,%eax
  801df9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e09:	50                   	push   %eax
  801e0a:	ff 75 08             	pushl  0x8(%ebp)
  801e0d:	e8 30 f5 ff ff       	call   801342 <fd_lookup>
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 18                	js     801e31 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1f:	e8 b8 f4 ff ff       	call   8012dc <fd2data>
	return _pipeisclosed(fd, p);
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e29:	e8 21 fd ff ff       	call   801b4f <_pipeisclosed>
  801e2e:	83 c4 10             	add    $0x10,%esp
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e3b:	85 f6                	test   %esi,%esi
  801e3d:	75 16                	jne    801e55 <wait+0x22>
  801e3f:	68 aa 2a 80 00       	push   $0x802aaa
  801e44:	68 5f 2a 80 00       	push   $0x802a5f
  801e49:	6a 09                	push   $0x9
  801e4b:	68 b5 2a 80 00       	push   $0x802ab5
  801e50:	e8 1d e5 ff ff       	call   800372 <_panic>
	e = &envs[ENVX(envid)];
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e5c:	89 c2                	mov    %eax,%edx
  801e5e:	c1 e2 07             	shl    $0x7,%edx
  801e61:	8d 9c 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%ebx
  801e68:	eb 05                	jmp    801e6f <wait+0x3c>
		sys_yield();
  801e6a:	e8 45 ef ff ff       	call   800db4 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e6f:	8b 43 50             	mov    0x50(%ebx),%eax
  801e72:	39 c6                	cmp    %eax,%esi
  801e74:	75 07                	jne    801e7d <wait+0x4a>
  801e76:	8b 43 5c             	mov    0x5c(%ebx),%eax
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	75 ed                	jne    801e6a <wait+0x37>
		sys_yield();
}
  801e7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e87:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8c:	5d                   	pop    %ebp
  801e8d:	c3                   	ret    

00801e8e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e94:	68 c0 2a 80 00       	push   $0x802ac0
  801e99:	ff 75 0c             	pushl  0xc(%ebp)
  801e9c:	e8 2f eb ff ff       	call   8009d0 <strcpy>
	return 0;
}
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	57                   	push   %edi
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebf:	eb 2d                	jmp    801eee <devcons_write+0x46>
		m = n - tot;
  801ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ec6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ec9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ece:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed1:	83 ec 04             	sub    $0x4,%esp
  801ed4:	53                   	push   %ebx
  801ed5:	03 45 0c             	add    0xc(%ebp),%eax
  801ed8:	50                   	push   %eax
  801ed9:	57                   	push   %edi
  801eda:	e8 83 ec ff ff       	call   800b62 <memmove>
		sys_cputs(buf, m);
  801edf:	83 c4 08             	add    $0x8,%esp
  801ee2:	53                   	push   %ebx
  801ee3:	57                   	push   %edi
  801ee4:	e8 2e ee ff ff       	call   800d17 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee9:	01 de                	add    %ebx,%esi
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	89 f0                	mov    %esi,%eax
  801ef0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef3:	72 cc                	jb     801ec1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ef5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 08             	sub    $0x8,%esp
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f0c:	74 2a                	je     801f38 <devcons_read+0x3b>
  801f0e:	eb 05                	jmp    801f15 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f10:	e8 9f ee ff ff       	call   800db4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f15:	e8 1b ee ff ff       	call   800d35 <sys_cgetc>
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	74 f2                	je     801f10 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 16                	js     801f38 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f22:	83 f8 04             	cmp    $0x4,%eax
  801f25:	74 0c                	je     801f33 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2a:	88 02                	mov    %al,(%edx)
	return 1;
  801f2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f31:	eb 05                	jmp    801f38 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f46:	6a 01                	push   $0x1
  801f48:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f4b:	50                   	push   %eax
  801f4c:	e8 c6 ed ff ff       	call   800d17 <sys_cputs>
}
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    

00801f56 <getchar>:

int
getchar(void)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f5c:	6a 01                	push   $0x1
  801f5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f61:	50                   	push   %eax
  801f62:	6a 00                	push   $0x0
  801f64:	e8 3f f6 ff ff       	call   8015a8 <read>
	if (r < 0)
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 0f                	js     801f7f <getchar+0x29>
		return r;
	if (r < 1)
  801f70:	85 c0                	test   %eax,%eax
  801f72:	7e 06                	jle    801f7a <getchar+0x24>
		return -E_EOF;
	return c;
  801f74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f78:	eb 05                	jmp    801f7f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f7a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8a:	50                   	push   %eax
  801f8b:	ff 75 08             	pushl  0x8(%ebp)
  801f8e:	e8 af f3 ff ff       	call   801342 <fd_lookup>
  801f93:	83 c4 10             	add    $0x10,%esp
  801f96:	85 c0                	test   %eax,%eax
  801f98:	78 11                	js     801fab <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fa3:	39 10                	cmp    %edx,(%eax)
  801fa5:	0f 94 c0             	sete   %al
  801fa8:	0f b6 c0             	movzbl %al,%eax
}
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <opencons>:

int
opencons(void)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	e8 37 f3 ff ff       	call   8012f3 <fd_alloc>
  801fbc:	83 c4 10             	add    $0x10,%esp
		return r;
  801fbf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 3e                	js     802003 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fc5:	83 ec 04             	sub    $0x4,%esp
  801fc8:	68 07 04 00 00       	push   $0x407
  801fcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd0:	6a 00                	push   $0x0
  801fd2:	e8 fc ed ff ff       	call   800dd3 <sys_page_alloc>
  801fd7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fda:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	78 23                	js     802003 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fe0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ff5:	83 ec 0c             	sub    $0xc,%esp
  801ff8:	50                   	push   %eax
  801ff9:	e8 ce f2 ff ff       	call   8012cc <fd2num>
  801ffe:	89 c2                	mov    %eax,%edx
  802000:	83 c4 10             	add    $0x10,%esp
}
  802003:	89 d0                	mov    %edx,%eax
  802005:	c9                   	leave  
  802006:	c3                   	ret    

00802007 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80200d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802014:	75 2a                	jne    802040 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802016:	83 ec 04             	sub    $0x4,%esp
  802019:	6a 07                	push   $0x7
  80201b:	68 00 f0 bf ee       	push   $0xeebff000
  802020:	6a 00                	push   $0x0
  802022:	e8 ac ed ff ff       	call   800dd3 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	85 c0                	test   %eax,%eax
  80202c:	79 12                	jns    802040 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80202e:	50                   	push   %eax
  80202f:	68 cc 2a 80 00       	push   $0x802acc
  802034:	6a 23                	push   $0x23
  802036:	68 d0 2a 80 00       	push   $0x802ad0
  80203b:	e8 32 e3 ff ff       	call   800372 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802040:	8b 45 08             	mov    0x8(%ebp),%eax
  802043:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802048:	83 ec 08             	sub    $0x8,%esp
  80204b:	68 72 20 80 00       	push   $0x802072
  802050:	6a 00                	push   $0x0
  802052:	e8 c7 ee ff ff       	call   800f1e <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	79 12                	jns    802070 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80205e:	50                   	push   %eax
  80205f:	68 cc 2a 80 00       	push   $0x802acc
  802064:	6a 2c                	push   $0x2c
  802066:	68 d0 2a 80 00       	push   $0x802ad0
  80206b:	e8 02 e3 ff ff       	call   800372 <_panic>
	}
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802072:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802073:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802078:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80207a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80207d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802081:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802086:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80208a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80208c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80208f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802090:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802093:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802094:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802095:	c3                   	ret    

00802096 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	56                   	push   %esi
  80209a:	53                   	push   %ebx
  80209b:	8b 75 08             	mov    0x8(%ebp),%esi
  80209e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	75 12                	jne    8020ba <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020a8:	83 ec 0c             	sub    $0xc,%esp
  8020ab:	68 00 00 c0 ee       	push   $0xeec00000
  8020b0:	e8 ce ee ff ff       	call   800f83 <sys_ipc_recv>
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	eb 0c                	jmp    8020c6 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020ba:	83 ec 0c             	sub    $0xc,%esp
  8020bd:	50                   	push   %eax
  8020be:	e8 c0 ee ff ff       	call   800f83 <sys_ipc_recv>
  8020c3:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020c6:	85 f6                	test   %esi,%esi
  8020c8:	0f 95 c1             	setne  %cl
  8020cb:	85 db                	test   %ebx,%ebx
  8020cd:	0f 95 c2             	setne  %dl
  8020d0:	84 d1                	test   %dl,%cl
  8020d2:	74 09                	je     8020dd <ipc_recv+0x47>
  8020d4:	89 c2                	mov    %eax,%edx
  8020d6:	c1 ea 1f             	shr    $0x1f,%edx
  8020d9:	84 d2                	test   %dl,%dl
  8020db:	75 27                	jne    802104 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020dd:	85 f6                	test   %esi,%esi
  8020df:	74 0a                	je     8020eb <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8020e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e6:	8b 40 7c             	mov    0x7c(%eax),%eax
  8020e9:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020eb:	85 db                	test   %ebx,%ebx
  8020ed:	74 0d                	je     8020fc <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  8020ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8020fa:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020fc:	a1 04 40 80 00       	mov    0x804004,%eax
  802101:	8b 40 78             	mov    0x78(%eax),%eax
}
  802104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    

0080210b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	57                   	push   %edi
  80210f:	56                   	push   %esi
  802110:	53                   	push   %ebx
  802111:	83 ec 0c             	sub    $0xc,%esp
  802114:	8b 7d 08             	mov    0x8(%ebp),%edi
  802117:	8b 75 0c             	mov    0xc(%ebp),%esi
  80211a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80211d:	85 db                	test   %ebx,%ebx
  80211f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802124:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802127:	ff 75 14             	pushl  0x14(%ebp)
  80212a:	53                   	push   %ebx
  80212b:	56                   	push   %esi
  80212c:	57                   	push   %edi
  80212d:	e8 2e ee ff ff       	call   800f60 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802132:	89 c2                	mov    %eax,%edx
  802134:	c1 ea 1f             	shr    $0x1f,%edx
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	84 d2                	test   %dl,%dl
  80213c:	74 17                	je     802155 <ipc_send+0x4a>
  80213e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802141:	74 12                	je     802155 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802143:	50                   	push   %eax
  802144:	68 de 2a 80 00       	push   $0x802ade
  802149:	6a 47                	push   $0x47
  80214b:	68 ec 2a 80 00       	push   $0x802aec
  802150:	e8 1d e2 ff ff       	call   800372 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802155:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802158:	75 07                	jne    802161 <ipc_send+0x56>
			sys_yield();
  80215a:	e8 55 ec ff ff       	call   800db4 <sys_yield>
  80215f:	eb c6                	jmp    802127 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802161:	85 c0                	test   %eax,%eax
  802163:	75 c2                	jne    802127 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    

0080216d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802173:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802178:	89 c2                	mov    %eax,%edx
  80217a:	c1 e2 07             	shl    $0x7,%edx
  80217d:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802184:	8b 52 58             	mov    0x58(%edx),%edx
  802187:	39 ca                	cmp    %ecx,%edx
  802189:	75 11                	jne    80219c <ipc_find_env+0x2f>
			return envs[i].env_id;
  80218b:	89 c2                	mov    %eax,%edx
  80218d:	c1 e2 07             	shl    $0x7,%edx
  802190:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  802197:	8b 40 50             	mov    0x50(%eax),%eax
  80219a:	eb 0f                	jmp    8021ab <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80219c:	83 c0 01             	add    $0x1,%eax
  80219f:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a4:	75 d2                	jne    802178 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    

008021ad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
  8021b0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b3:	89 d0                	mov    %edx,%eax
  8021b5:	c1 e8 16             	shr    $0x16,%eax
  8021b8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021bf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c4:	f6 c1 01             	test   $0x1,%cl
  8021c7:	74 1d                	je     8021e6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021c9:	c1 ea 0c             	shr    $0xc,%edx
  8021cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d3:	f6 c2 01             	test   $0x1,%dl
  8021d6:	74 0e                	je     8021e6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d8:	c1 ea 0c             	shr    $0xc,%edx
  8021db:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e2:	ef 
  8021e3:	0f b7 c0             	movzwl %ax,%eax
}
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 f6                	test   %esi,%esi
  802209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220d:	89 ca                	mov    %ecx,%edx
  80220f:	89 f8                	mov    %edi,%eax
  802211:	75 3d                	jne    802250 <__udivdi3+0x60>
  802213:	39 cf                	cmp    %ecx,%edi
  802215:	0f 87 c5 00 00 00    	ja     8022e0 <__udivdi3+0xf0>
  80221b:	85 ff                	test   %edi,%edi
  80221d:	89 fd                	mov    %edi,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f7                	div    %edi
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 c8                	mov    %ecx,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c1                	mov    %eax,%ecx
  802234:	89 d8                	mov    %ebx,%eax
  802236:	89 cf                	mov    %ecx,%edi
  802238:	f7 f5                	div    %ebp
  80223a:	89 c3                	mov    %eax,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	39 ce                	cmp    %ecx,%esi
  802252:	77 74                	ja     8022c8 <__udivdi3+0xd8>
  802254:	0f bd fe             	bsr    %esi,%edi
  802257:	83 f7 1f             	xor    $0x1f,%edi
  80225a:	0f 84 98 00 00 00    	je     8022f8 <__udivdi3+0x108>
  802260:	bb 20 00 00 00       	mov    $0x20,%ebx
  802265:	89 f9                	mov    %edi,%ecx
  802267:	89 c5                	mov    %eax,%ebp
  802269:	29 fb                	sub    %edi,%ebx
  80226b:	d3 e6                	shl    %cl,%esi
  80226d:	89 d9                	mov    %ebx,%ecx
  80226f:	d3 ed                	shr    %cl,%ebp
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e0                	shl    %cl,%eax
  802275:	09 ee                	or     %ebp,%esi
  802277:	89 d9                	mov    %ebx,%ecx
  802279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227d:	89 d5                	mov    %edx,%ebp
  80227f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802283:	d3 ed                	shr    %cl,%ebp
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e2                	shl    %cl,%edx
  802289:	89 d9                	mov    %ebx,%ecx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	09 c2                	or     %eax,%edx
  80228f:	89 d0                	mov    %edx,%eax
  802291:	89 ea                	mov    %ebp,%edx
  802293:	f7 f6                	div    %esi
  802295:	89 d5                	mov    %edx,%ebp
  802297:	89 c3                	mov    %eax,%ebx
  802299:	f7 64 24 0c          	mull   0xc(%esp)
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	72 10                	jb     8022b1 <__udivdi3+0xc1>
  8022a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e6                	shl    %cl,%esi
  8022a9:	39 c6                	cmp    %eax,%esi
  8022ab:	73 07                	jae    8022b4 <__udivdi3+0xc4>
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	75 03                	jne    8022b4 <__udivdi3+0xc4>
  8022b1:	83 eb 01             	sub    $0x1,%ebx
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 d8                	mov    %ebx,%eax
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	31 ff                	xor    %edi,%edi
  8022ca:	31 db                	xor    %ebx,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 d8                	mov    %ebx,%eax
  8022e2:	f7 f7                	div    %edi
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 fa                	mov    %edi,%edx
  8022ec:	83 c4 1c             	add    $0x1c,%esp
  8022ef:	5b                   	pop    %ebx
  8022f0:	5e                   	pop    %esi
  8022f1:	5f                   	pop    %edi
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 ce                	cmp    %ecx,%esi
  8022fa:	72 0c                	jb     802308 <__udivdi3+0x118>
  8022fc:	31 db                	xor    %ebx,%ebx
  8022fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802302:	0f 87 34 ff ff ff    	ja     80223c <__udivdi3+0x4c>
  802308:	bb 01 00 00 00       	mov    $0x1,%ebx
  80230d:	e9 2a ff ff ff       	jmp    80223c <__udivdi3+0x4c>
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 1c             	sub    $0x1c,%esp
  802327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80232b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802337:	85 d2                	test   %edx,%edx
  802339:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80233d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802341:	89 f3                	mov    %esi,%ebx
  802343:	89 3c 24             	mov    %edi,(%esp)
  802346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80234a:	75 1c                	jne    802368 <__umoddi3+0x48>
  80234c:	39 f7                	cmp    %esi,%edi
  80234e:	76 50                	jbe    8023a0 <__umoddi3+0x80>
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	f7 f7                	div    %edi
  802356:	89 d0                	mov    %edx,%eax
  802358:	31 d2                	xor    %edx,%edx
  80235a:	83 c4 1c             	add    $0x1c,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802368:	39 f2                	cmp    %esi,%edx
  80236a:	89 d0                	mov    %edx,%eax
  80236c:	77 52                	ja     8023c0 <__umoddi3+0xa0>
  80236e:	0f bd ea             	bsr    %edx,%ebp
  802371:	83 f5 1f             	xor    $0x1f,%ebp
  802374:	75 5a                	jne    8023d0 <__umoddi3+0xb0>
  802376:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80237a:	0f 82 e0 00 00 00    	jb     802460 <__umoddi3+0x140>
  802380:	39 0c 24             	cmp    %ecx,(%esp)
  802383:	0f 86 d7 00 00 00    	jbe    802460 <__umoddi3+0x140>
  802389:	8b 44 24 08          	mov    0x8(%esp),%eax
  80238d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802391:	83 c4 1c             	add    $0x1c,%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	85 ff                	test   %edi,%edi
  8023a2:	89 fd                	mov    %edi,%ebp
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x91>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f7                	div    %edi
  8023af:	89 c5                	mov    %eax,%ebp
  8023b1:	89 f0                	mov    %esi,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f5                	div    %ebp
  8023b7:	89 c8                	mov    %ecx,%eax
  8023b9:	f7 f5                	div    %ebp
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	eb 99                	jmp    802358 <__umoddi3+0x38>
  8023bf:	90                   	nop
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	83 c4 1c             	add    $0x1c,%esp
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5f                   	pop    %edi
  8023ca:	5d                   	pop    %ebp
  8023cb:	c3                   	ret    
  8023cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	8b 34 24             	mov    (%esp),%esi
  8023d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	29 ef                	sub    %ebp,%edi
  8023dc:	d3 e0                	shl    %cl,%eax
  8023de:	89 f9                	mov    %edi,%ecx
  8023e0:	89 f2                	mov    %esi,%edx
  8023e2:	d3 ea                	shr    %cl,%edx
  8023e4:	89 e9                	mov    %ebp,%ecx
  8023e6:	09 c2                	or     %eax,%edx
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	89 14 24             	mov    %edx,(%esp)
  8023ed:	89 f2                	mov    %esi,%edx
  8023ef:	d3 e2                	shl    %cl,%edx
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	d3 e3                	shl    %cl,%ebx
  802403:	89 f9                	mov    %edi,%ecx
  802405:	89 d0                	mov    %edx,%eax
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	09 d8                	or     %ebx,%eax
  80240d:	89 d3                	mov    %edx,%ebx
  80240f:	89 f2                	mov    %esi,%edx
  802411:	f7 34 24             	divl   (%esp)
  802414:	89 d6                	mov    %edx,%esi
  802416:	d3 e3                	shl    %cl,%ebx
  802418:	f7 64 24 04          	mull   0x4(%esp)
  80241c:	39 d6                	cmp    %edx,%esi
  80241e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802422:	89 d1                	mov    %edx,%ecx
  802424:	89 c3                	mov    %eax,%ebx
  802426:	72 08                	jb     802430 <__umoddi3+0x110>
  802428:	75 11                	jne    80243b <__umoddi3+0x11b>
  80242a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80242e:	73 0b                	jae    80243b <__umoddi3+0x11b>
  802430:	2b 44 24 04          	sub    0x4(%esp),%eax
  802434:	1b 14 24             	sbb    (%esp),%edx
  802437:	89 d1                	mov    %edx,%ecx
  802439:	89 c3                	mov    %eax,%ebx
  80243b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80243f:	29 da                	sub    %ebx,%edx
  802441:	19 ce                	sbb    %ecx,%esi
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 f0                	mov    %esi,%eax
  802447:	d3 e0                	shl    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	d3 ea                	shr    %cl,%edx
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	d3 ee                	shr    %cl,%esi
  802451:	09 d0                	or     %edx,%eax
  802453:	89 f2                	mov    %esi,%edx
  802455:	83 c4 1c             	add    $0x1c,%esp
  802458:	5b                   	pop    %ebx
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	8d 76 00             	lea    0x0(%esi),%esi
  802460:	29 f9                	sub    %edi,%ecx
  802462:	19 d6                	sbb    %edx,%esi
  802464:	89 74 24 04          	mov    %esi,0x4(%esp)
  802468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246c:	e9 18 ff ff ff       	jmp    802389 <__umoddi3+0x69>
