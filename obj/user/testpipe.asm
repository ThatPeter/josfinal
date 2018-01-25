
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
  800049:	e8 4d 1c 00 00       	call   801c9b <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 8c 24 80 00       	push   $0x80248c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 95 24 80 00       	push   $0x802495
  800064:	e8 cd 02 00 00       	call   800336 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 30 10 00 00       	call   80109e <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 a5 24 80 00       	push   $0x8024a5
  80007a:	6a 11                	push   $0x11
  80007c:	68 95 24 80 00       	push   $0x802495
  800081:	e8 b0 02 00 00       	call   800336 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 54             	mov    0x54(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ae 24 80 00       	push   $0x8024ae
  8000a2:	e8 68 03 00 00       	call   80040f <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 a8 13 00 00       	call   80145a <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 54             	mov    0x54(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 cb 24 80 00       	push   $0x8024cb
  8000c6:	e8 44 03 00 00       	call   80040f <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 4b 15 00 00       	call   801627 <readn>
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
  8000f2:	e8 3f 02 00 00       	call   800336 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 30 09 00 00       	call   800a3e <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 f1 24 80 00       	push   $0x8024f1
  80011d:	e8 ed 02 00 00       	call   80040f <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 0d 25 80 00       	push   $0x80250d
  800134:	e8 d6 02 00 00       	call   80040f <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 db 01 00 00       	call   80031c <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 54             	mov    0x54(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ae 24 80 00       	push   $0x8024ae
  80015a:	e8 b0 02 00 00       	call   80040f <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 f0 12 00 00       	call   80145a <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 54             	mov    0x54(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 20 25 80 00       	push   $0x802520
  80017e:	e8 8c 02 00 00       	call   80040f <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 ca 07 00 00       	call   80095b <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 cd 14 00 00       	call   801670 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 a8 07 00 00       	call   80095b <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 3d 25 80 00       	push   $0x80253d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 95 24 80 00       	push   $0x802495
  8001c7:	e8 6a 01 00 00       	call   800336 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 83 12 00 00       	call   80145a <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 3e 1c 00 00       	call   801e21 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 47 	movl   $0x802547,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 a3 1a 00 00       	call   801c9b <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 8c 24 80 00       	push   $0x80248c
  800207:	6a 2c                	push   $0x2c
  800209:	68 95 24 80 00       	push   $0x802495
  80020e:	e8 23 01 00 00       	call   800336 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 86 0e 00 00       	call   80109e <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 a5 24 80 00       	push   $0x8024a5
  800224:	6a 2f                	push   $0x2f
  800226:	68 95 24 80 00       	push   $0x802495
  80022b:	e8 06 01 00 00       	call   800336 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 1b 12 00 00       	call   80145a <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 54 25 80 00       	push   $0x802554
  80024a:	e8 c0 01 00 00       	call   80040f <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 56 25 80 00       	push   $0x802556
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 0f 14 00 00       	call   801670 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 58 25 80 00       	push   $0x802558
  800271:	e8 99 01 00 00       	call   80040f <cprintf>
		exit();
  800276:	e8 a1 00 00 00       	call   80031c <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 d1 11 00 00       	call   80145a <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 c6 11 00 00       	call   80145a <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 85 1b 00 00       	call   801e21 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 75 25 80 00 	movl   $0x802575,(%esp)
  8002a3:	e8 67 01 00 00       	call   80040f <cprintf>
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
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 97 0a 00 00       	call   800d59 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	89 c2                	mov    %eax,%edx
  8002c9:	c1 e2 07             	shl    $0x7,%edx
  8002cc:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8002d3:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d8:	85 db                	test   %ebx,%ebx
  8002da:	7e 07                	jle    8002e3 <libmain+0x31>
		binaryname = argv[0];
  8002dc:	8b 06                	mov    (%esi),%eax
  8002de:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
  8002e8:	e8 46 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002ed:	e8 2a 00 00 00       	call   80031c <exit>
}
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800302:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800307:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800309:	e8 4b 0a 00 00       	call   800d59 <sys_getenvid>
  80030e:	83 ec 0c             	sub    $0xc,%esp
  800311:	50                   	push   %eax
  800312:	e8 91 0c 00 00       	call   800fa8 <sys_thread_free>
}
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800322:	e8 5e 11 00 00       	call   801485 <close_all>
	sys_env_destroy(0);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	6a 00                	push   $0x0
  80032c:	e8 e7 09 00 00       	call   800d18 <sys_env_destroy>
}
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033e:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800344:	e8 10 0a 00 00       	call   800d59 <sys_getenvid>
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	56                   	push   %esi
  800353:	50                   	push   %eax
  800354:	68 d8 25 80 00       	push   $0x8025d8
  800359:	e8 b1 00 00 00       	call   80040f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035e:	83 c4 18             	add    $0x18,%esp
  800361:	53                   	push   %ebx
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	e8 54 00 00 00       	call   8003be <vcprintf>
	cprintf("\n");
  80036a:	c7 04 24 c9 24 80 00 	movl   $0x8024c9,(%esp)
  800371:	e8 99 00 00 00       	call   80040f <cprintf>
  800376:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800379:	cc                   	int3   
  80037a:	eb fd                	jmp    800379 <_panic+0x43>

0080037c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800386:	8b 13                	mov    (%ebx),%edx
  800388:	8d 42 01             	lea    0x1(%edx),%eax
  80038b:	89 03                	mov    %eax,(%ebx)
  80038d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800390:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800394:	3d ff 00 00 00       	cmp    $0xff,%eax
  800399:	75 1a                	jne    8003b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	68 ff 00 00 00       	push   $0xff
  8003a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a6:	50                   	push   %eax
  8003a7:	e8 2f 09 00 00       	call   800cdb <sys_cputs>
		b->idx = 0;
  8003ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ce:	00 00 00 
	b.cnt = 0;
  8003d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003db:	ff 75 0c             	pushl  0xc(%ebp)
  8003de:	ff 75 08             	pushl  0x8(%ebp)
  8003e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e7:	50                   	push   %eax
  8003e8:	68 7c 03 80 00       	push   $0x80037c
  8003ed:	e8 54 01 00 00       	call   800546 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f2:	83 c4 08             	add    $0x8,%esp
  8003f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800401:	50                   	push   %eax
  800402:	e8 d4 08 00 00       	call   800cdb <sys_cputs>

	return b.cnt;
}
  800407:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    

0080040f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800415:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800418:	50                   	push   %eax
  800419:	ff 75 08             	pushl  0x8(%ebp)
  80041c:	e8 9d ff ff ff       	call   8003be <vcprintf>
	va_end(ap);

	return cnt;
}
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	57                   	push   %edi
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 1c             	sub    $0x1c,%esp
  80042c:	89 c7                	mov    %eax,%edi
  80042e:	89 d6                	mov    %edx,%esi
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	8b 55 0c             	mov    0xc(%ebp),%edx
  800436:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800439:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800444:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800447:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044a:	39 d3                	cmp    %edx,%ebx
  80044c:	72 05                	jb     800453 <printnum+0x30>
  80044e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800451:	77 45                	ja     800498 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800453:	83 ec 0c             	sub    $0xc,%esp
  800456:	ff 75 18             	pushl  0x18(%ebp)
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80045f:	53                   	push   %ebx
  800460:	ff 75 10             	pushl  0x10(%ebp)
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	ff 75 e4             	pushl  -0x1c(%ebp)
  800469:	ff 75 e0             	pushl  -0x20(%ebp)
  80046c:	ff 75 dc             	pushl  -0x24(%ebp)
  80046f:	ff 75 d8             	pushl  -0x28(%ebp)
  800472:	e8 69 1d 00 00       	call   8021e0 <__udivdi3>
  800477:	83 c4 18             	add    $0x18,%esp
  80047a:	52                   	push   %edx
  80047b:	50                   	push   %eax
  80047c:	89 f2                	mov    %esi,%edx
  80047e:	89 f8                	mov    %edi,%eax
  800480:	e8 9e ff ff ff       	call   800423 <printnum>
  800485:	83 c4 20             	add    $0x20,%esp
  800488:	eb 18                	jmp    8004a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	56                   	push   %esi
  80048e:	ff 75 18             	pushl  0x18(%ebp)
  800491:	ff d7                	call   *%edi
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	eb 03                	jmp    80049b <printnum+0x78>
  800498:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80049b:	83 eb 01             	sub    $0x1,%ebx
  80049e:	85 db                	test   %ebx,%ebx
  8004a0:	7f e8                	jg     80048a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	56                   	push   %esi
  8004a6:	83 ec 04             	sub    $0x4,%esp
  8004a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b5:	e8 56 1e 00 00       	call   802310 <__umoddi3>
  8004ba:	83 c4 14             	add    $0x14,%esp
  8004bd:	0f be 80 fb 25 80 00 	movsbl 0x8025fb(%eax),%eax
  8004c4:	50                   	push   %eax
  8004c5:	ff d7                	call   *%edi
}
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004cd:	5b                   	pop    %ebx
  8004ce:	5e                   	pop    %esi
  8004cf:	5f                   	pop    %edi
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d5:	83 fa 01             	cmp    $0x1,%edx
  8004d8:	7e 0e                	jle    8004e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	8b 52 04             	mov    0x4(%edx),%edx
  8004e6:	eb 22                	jmp    80050a <getuint+0x38>
	else if (lflag)
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	74 10                	je     8004fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f1:	89 08                	mov    %ecx,(%eax)
  8004f3:	8b 02                	mov    (%edx),%eax
  8004f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fa:	eb 0e                	jmp    80050a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800501:	89 08                	mov    %ecx,(%eax)
  800503:	8b 02                	mov    (%edx),%eax
  800505:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050a:	5d                   	pop    %ebp
  80050b:	c3                   	ret    

0080050c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800512:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800516:	8b 10                	mov    (%eax),%edx
  800518:	3b 50 04             	cmp    0x4(%eax),%edx
  80051b:	73 0a                	jae    800527 <sprintputch+0x1b>
		*b->buf++ = ch;
  80051d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800520:	89 08                	mov    %ecx,(%eax)
  800522:	8b 45 08             	mov    0x8(%ebp),%eax
  800525:	88 02                	mov    %al,(%edx)
}
  800527:	5d                   	pop    %ebp
  800528:	c3                   	ret    

00800529 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800529:	55                   	push   %ebp
  80052a:	89 e5                	mov    %esp,%ebp
  80052c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80052f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800532:	50                   	push   %eax
  800533:	ff 75 10             	pushl  0x10(%ebp)
  800536:	ff 75 0c             	pushl  0xc(%ebp)
  800539:	ff 75 08             	pushl  0x8(%ebp)
  80053c:	e8 05 00 00 00       	call   800546 <vprintfmt>
	va_end(ap);
}
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 2c             	sub    $0x2c,%esp
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	8b 7d 10             	mov    0x10(%ebp),%edi
  800558:	eb 12                	jmp    80056c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 84 89 03 00 00    	je     8008eb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	53                   	push   %ebx
  800566:	50                   	push   %eax
  800567:	ff d6                	call   *%esi
  800569:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056c:	83 c7 01             	add    $0x1,%edi
  80056f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800573:	83 f8 25             	cmp    $0x25,%eax
  800576:	75 e2                	jne    80055a <vprintfmt+0x14>
  800578:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80057c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800583:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	eb 07                	jmp    80059f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80059b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8d 47 01             	lea    0x1(%edi),%eax
  8005a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a5:	0f b6 07             	movzbl (%edi),%eax
  8005a8:	0f b6 c8             	movzbl %al,%ecx
  8005ab:	83 e8 23             	sub    $0x23,%eax
  8005ae:	3c 55                	cmp    $0x55,%al
  8005b0:	0f 87 1a 03 00 00    	ja     8008d0 <vprintfmt+0x38a>
  8005b6:	0f b6 c0             	movzbl %al,%eax
  8005b9:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c7:	eb d6                	jmp    80059f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e1:	83 fa 09             	cmp    $0x9,%edx
  8005e4:	77 39                	ja     80061f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e9:	eb e9                	jmp    8005d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005fc:	eb 27                	jmp    800625 <vprintfmt+0xdf>
  8005fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800601:	85 c0                	test   %eax,%eax
  800603:	b9 00 00 00 00       	mov    $0x0,%ecx
  800608:	0f 49 c8             	cmovns %eax,%ecx
  80060b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800611:	eb 8c                	jmp    80059f <vprintfmt+0x59>
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800616:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80061d:	eb 80                	jmp    80059f <vprintfmt+0x59>
  80061f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800622:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800625:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800629:	0f 89 70 ff ff ff    	jns    80059f <vprintfmt+0x59>
				width = precision, precision = -1;
  80062f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800632:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800635:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80063c:	e9 5e ff ff ff       	jmp    80059f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800641:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800647:	e9 53 ff ff ff       	jmp    80059f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	ff 30                	pushl  (%eax)
  80065b:	ff d6                	call   *%esi
			break;
  80065d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800663:	e9 04 ff ff ff       	jmp    80056c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	99                   	cltd   
  800674:	31 d0                	xor    %edx,%eax
  800676:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800678:	83 f8 0f             	cmp    $0xf,%eax
  80067b:	7f 0b                	jg     800688 <vprintfmt+0x142>
  80067d:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800684:	85 d2                	test   %edx,%edx
  800686:	75 18                	jne    8006a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800688:	50                   	push   %eax
  800689:	68 13 26 80 00       	push   $0x802613
  80068e:	53                   	push   %ebx
  80068f:	56                   	push   %esi
  800690:	e8 94 fe ff ff       	call   800529 <printfmt>
  800695:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069b:	e9 cc fe ff ff       	jmp    80056c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006a0:	52                   	push   %edx
  8006a1:	68 51 2a 80 00       	push   $0x802a51
  8006a6:	53                   	push   %ebx
  8006a7:	56                   	push   %esi
  8006a8:	e8 7c fe ff ff       	call   800529 <printfmt>
  8006ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b3:	e9 b4 fe ff ff       	jmp    80056c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	b8 0c 26 80 00       	mov    $0x80260c,%eax
  8006ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d1:	0f 8e 94 00 00 00    	jle    80076b <vprintfmt+0x225>
  8006d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006db:	0f 84 98 00 00 00    	je     800779 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8006e7:	57                   	push   %edi
  8006e8:	e8 86 02 00 00       	call   800973 <strnlen>
  8006ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f0:	29 c1                	sub    %eax,%ecx
  8006f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800702:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800704:	eb 0f                	jmp    800715 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	ff 75 e0             	pushl  -0x20(%ebp)
  80070d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070f:	83 ef 01             	sub    $0x1,%edi
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	85 ff                	test   %edi,%edi
  800717:	7f ed                	jg     800706 <vprintfmt+0x1c0>
  800719:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80071c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80071f:	85 c9                	test   %ecx,%ecx
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
  800726:	0f 49 c1             	cmovns %ecx,%eax
  800729:	29 c1                	sub    %eax,%ecx
  80072b:	89 75 08             	mov    %esi,0x8(%ebp)
  80072e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800731:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800734:	89 cb                	mov    %ecx,%ebx
  800736:	eb 4d                	jmp    800785 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800738:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80073c:	74 1b                	je     800759 <vprintfmt+0x213>
  80073e:	0f be c0             	movsbl %al,%eax
  800741:	83 e8 20             	sub    $0x20,%eax
  800744:	83 f8 5e             	cmp    $0x5e,%eax
  800747:	76 10                	jbe    800759 <vprintfmt+0x213>
					putch('?', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	6a 3f                	push   $0x3f
  800751:	ff 55 08             	call   *0x8(%ebp)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 0d                	jmp    800766 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	52                   	push   %edx
  800760:	ff 55 08             	call   *0x8(%ebp)
  800763:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800766:	83 eb 01             	sub    $0x1,%ebx
  800769:	eb 1a                	jmp    800785 <vprintfmt+0x23f>
  80076b:	89 75 08             	mov    %esi,0x8(%ebp)
  80076e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800771:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800774:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800777:	eb 0c                	jmp    800785 <vprintfmt+0x23f>
  800779:	89 75 08             	mov    %esi,0x8(%ebp)
  80077c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80077f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800782:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800785:	83 c7 01             	add    $0x1,%edi
  800788:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078c:	0f be d0             	movsbl %al,%edx
  80078f:	85 d2                	test   %edx,%edx
  800791:	74 23                	je     8007b6 <vprintfmt+0x270>
  800793:	85 f6                	test   %esi,%esi
  800795:	78 a1                	js     800738 <vprintfmt+0x1f2>
  800797:	83 ee 01             	sub    $0x1,%esi
  80079a:	79 9c                	jns    800738 <vprintfmt+0x1f2>
  80079c:	89 df                	mov    %ebx,%edi
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a4:	eb 18                	jmp    8007be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	53                   	push   %ebx
  8007aa:	6a 20                	push   $0x20
  8007ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ae:	83 ef 01             	sub    $0x1,%edi
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	eb 08                	jmp    8007be <vprintfmt+0x278>
  8007b6:	89 df                	mov    %ebx,%edi
  8007b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007be:	85 ff                	test   %edi,%edi
  8007c0:	7f e4                	jg     8007a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c5:	e9 a2 fd ff ff       	jmp    80056c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ca:	83 fa 01             	cmp    $0x1,%edx
  8007cd:	7e 16                	jle    8007e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 08             	lea    0x8(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d8:	8b 50 04             	mov    0x4(%eax),%edx
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e3:	eb 32                	jmp    800817 <vprintfmt+0x2d1>
	else if (lflag)
  8007e5:	85 d2                	test   %edx,%edx
  8007e7:	74 18                	je     800801 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f2:	8b 00                	mov    (%eax),%eax
  8007f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f7:	89 c1                	mov    %eax,%ecx
  8007f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ff:	eb 16                	jmp    800817 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8d 50 04             	lea    0x4(%eax),%edx
  800807:	89 55 14             	mov    %edx,0x14(%ebp)
  80080a:	8b 00                	mov    (%eax),%eax
  80080c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080f:	89 c1                	mov    %eax,%ecx
  800811:	c1 f9 1f             	sar    $0x1f,%ecx
  800814:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800817:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80081a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800822:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800826:	79 74                	jns    80089c <vprintfmt+0x356>
				putch('-', putdat);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	53                   	push   %ebx
  80082c:	6a 2d                	push   $0x2d
  80082e:	ff d6                	call   *%esi
				num = -(long long) num;
  800830:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800833:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800836:	f7 d8                	neg    %eax
  800838:	83 d2 00             	adc    $0x0,%edx
  80083b:	f7 da                	neg    %edx
  80083d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800840:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800845:	eb 55                	jmp    80089c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
  80084a:	e8 83 fc ff ff       	call   8004d2 <getuint>
			base = 10;
  80084f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800854:	eb 46                	jmp    80089c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	e8 74 fc ff ff       	call   8004d2 <getuint>
			base = 8;
  80085e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800863:	eb 37                	jmp    80089c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 30                	push   $0x30
  80086b:	ff d6                	call   *%esi
			putch('x', putdat);
  80086d:	83 c4 08             	add    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	6a 78                	push   $0x78
  800873:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8d 50 04             	lea    0x4(%eax),%edx
  80087b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087e:	8b 00                	mov    (%eax),%eax
  800880:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800885:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800888:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80088d:	eb 0d                	jmp    80089c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
  800892:	e8 3b fc ff ff       	call   8004d2 <getuint>
			base = 16;
  800897:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089c:	83 ec 0c             	sub    $0xc,%esp
  80089f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a3:	57                   	push   %edi
  8008a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a7:	51                   	push   %ecx
  8008a8:	52                   	push   %edx
  8008a9:	50                   	push   %eax
  8008aa:	89 da                	mov    %ebx,%edx
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	e8 70 fb ff ff       	call   800423 <printnum>
			break;
  8008b3:	83 c4 20             	add    $0x20,%esp
  8008b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b9:	e9 ae fc ff ff       	jmp    80056c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	51                   	push   %ecx
  8008c3:	ff d6                	call   *%esi
			break;
  8008c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008cb:	e9 9c fc ff ff       	jmp    80056c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	53                   	push   %ebx
  8008d4:	6a 25                	push   $0x25
  8008d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	eb 03                	jmp    8008e0 <vprintfmt+0x39a>
  8008dd:	83 ef 01             	sub    $0x1,%edi
  8008e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008e4:	75 f7                	jne    8008dd <vprintfmt+0x397>
  8008e6:	e9 81 fc ff ff       	jmp    80056c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5f                   	pop    %edi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	83 ec 18             	sub    $0x18,%esp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800902:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800906:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800909:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800910:	85 c0                	test   %eax,%eax
  800912:	74 26                	je     80093a <vsnprintf+0x47>
  800914:	85 d2                	test   %edx,%edx
  800916:	7e 22                	jle    80093a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800918:	ff 75 14             	pushl  0x14(%ebp)
  80091b:	ff 75 10             	pushl  0x10(%ebp)
  80091e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800921:	50                   	push   %eax
  800922:	68 0c 05 80 00       	push   $0x80050c
  800927:	e8 1a fc ff ff       	call   800546 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80092c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800932:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	eb 05                	jmp    80093f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80093a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800947:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80094a:	50                   	push   %eax
  80094b:	ff 75 10             	pushl  0x10(%ebp)
  80094e:	ff 75 0c             	pushl  0xc(%ebp)
  800951:	ff 75 08             	pushl  0x8(%ebp)
  800954:	e8 9a ff ff ff       	call   8008f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
  800966:	eb 03                	jmp    80096b <strlen+0x10>
		n++;
  800968:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80096b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096f:	75 f7                	jne    800968 <strlen+0xd>
		n++;
	return n;
}
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	eb 03                	jmp    800986 <strnlen+0x13>
		n++;
  800983:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800986:	39 c2                	cmp    %eax,%edx
  800988:	74 08                	je     800992 <strnlen+0x1f>
  80098a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80098e:	75 f3                	jne    800983 <strnlen+0x10>
  800990:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	53                   	push   %ebx
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80099e:	89 c2                	mov    %eax,%edx
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	83 c1 01             	add    $0x1,%ecx
  8009a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ad:	84 db                	test   %bl,%bl
  8009af:	75 ef                	jne    8009a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009bb:	53                   	push   %ebx
  8009bc:	e8 9a ff ff ff       	call   80095b <strlen>
  8009c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009c4:	ff 75 0c             	pushl  0xc(%ebp)
  8009c7:	01 d8                	add    %ebx,%eax
  8009c9:	50                   	push   %eax
  8009ca:	e8 c5 ff ff ff       	call   800994 <strcpy>
	return dst;
}
  8009cf:	89 d8                	mov    %ebx,%eax
  8009d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 75 08             	mov    0x8(%ebp),%esi
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e1:	89 f3                	mov    %esi,%ebx
  8009e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e6:	89 f2                	mov    %esi,%edx
  8009e8:	eb 0f                	jmp    8009f9 <strncpy+0x23>
		*dst++ = *src;
  8009ea:	83 c2 01             	add    $0x1,%edx
  8009ed:	0f b6 01             	movzbl (%ecx),%eax
  8009f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f9:	39 da                	cmp    %ebx,%edx
  8009fb:	75 ed                	jne    8009ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009fd:	89 f0                	mov    %esi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a11:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a13:	85 d2                	test   %edx,%edx
  800a15:	74 21                	je     800a38 <strlcpy+0x35>
  800a17:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a1b:	89 f2                	mov    %esi,%edx
  800a1d:	eb 09                	jmp    800a28 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a1f:	83 c2 01             	add    $0x1,%edx
  800a22:	83 c1 01             	add    $0x1,%ecx
  800a25:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a28:	39 c2                	cmp    %eax,%edx
  800a2a:	74 09                	je     800a35 <strlcpy+0x32>
  800a2c:	0f b6 19             	movzbl (%ecx),%ebx
  800a2f:	84 db                	test   %bl,%bl
  800a31:	75 ec                	jne    800a1f <strlcpy+0x1c>
  800a33:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a35:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a38:	29 f0                	sub    %esi,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a47:	eb 06                	jmp    800a4f <strcmp+0x11>
		p++, q++;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a4f:	0f b6 01             	movzbl (%ecx),%eax
  800a52:	84 c0                	test   %al,%al
  800a54:	74 04                	je     800a5a <strcmp+0x1c>
  800a56:	3a 02                	cmp    (%edx),%al
  800a58:	74 ef                	je     800a49 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5a:	0f b6 c0             	movzbl %al,%eax
  800a5d:	0f b6 12             	movzbl (%edx),%edx
  800a60:	29 d0                	sub    %edx,%eax
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	53                   	push   %ebx
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a73:	eb 06                	jmp    800a7b <strncmp+0x17>
		n--, p++, q++;
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a7b:	39 d8                	cmp    %ebx,%eax
  800a7d:	74 15                	je     800a94 <strncmp+0x30>
  800a7f:	0f b6 08             	movzbl (%eax),%ecx
  800a82:	84 c9                	test   %cl,%cl
  800a84:	74 04                	je     800a8a <strncmp+0x26>
  800a86:	3a 0a                	cmp    (%edx),%cl
  800a88:	74 eb                	je     800a75 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8a:	0f b6 00             	movzbl (%eax),%eax
  800a8d:	0f b6 12             	movzbl (%edx),%edx
  800a90:	29 d0                	sub    %edx,%eax
  800a92:	eb 05                	jmp    800a99 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa6:	eb 07                	jmp    800aaf <strchr+0x13>
		if (*s == c)
  800aa8:	38 ca                	cmp    %cl,%dl
  800aaa:	74 0f                	je     800abb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aac:	83 c0 01             	add    $0x1,%eax
  800aaf:	0f b6 10             	movzbl (%eax),%edx
  800ab2:	84 d2                	test   %dl,%dl
  800ab4:	75 f2                	jne    800aa8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac7:	eb 03                	jmp    800acc <strfind+0xf>
  800ac9:	83 c0 01             	add    $0x1,%eax
  800acc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800acf:	38 ca                	cmp    %cl,%dl
  800ad1:	74 04                	je     800ad7 <strfind+0x1a>
  800ad3:	84 d2                	test   %dl,%dl
  800ad5:	75 f2                	jne    800ac9 <strfind+0xc>
			break;
	return (char *) s;
}
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae5:	85 c9                	test   %ecx,%ecx
  800ae7:	74 36                	je     800b1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aef:	75 28                	jne    800b19 <memset+0x40>
  800af1:	f6 c1 03             	test   $0x3,%cl
  800af4:	75 23                	jne    800b19 <memset+0x40>
		c &= 0xFF;
  800af6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800afa:	89 d3                	mov    %edx,%ebx
  800afc:	c1 e3 08             	shl    $0x8,%ebx
  800aff:	89 d6                	mov    %edx,%esi
  800b01:	c1 e6 18             	shl    $0x18,%esi
  800b04:	89 d0                	mov    %edx,%eax
  800b06:	c1 e0 10             	shl    $0x10,%eax
  800b09:	09 f0                	or     %esi,%eax
  800b0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b0d:	89 d8                	mov    %ebx,%eax
  800b0f:	09 d0                	or     %edx,%eax
  800b11:	c1 e9 02             	shr    $0x2,%ecx
  800b14:	fc                   	cld    
  800b15:	f3 ab                	rep stos %eax,%es:(%edi)
  800b17:	eb 06                	jmp    800b1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	fc                   	cld    
  800b1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1f:	89 f8                	mov    %edi,%eax
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b34:	39 c6                	cmp    %eax,%esi
  800b36:	73 35                	jae    800b6d <memmove+0x47>
  800b38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b3b:	39 d0                	cmp    %edx,%eax
  800b3d:	73 2e                	jae    800b6d <memmove+0x47>
		s += n;
		d += n;
  800b3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b42:	89 d6                	mov    %edx,%esi
  800b44:	09 fe                	or     %edi,%esi
  800b46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4c:	75 13                	jne    800b61 <memmove+0x3b>
  800b4e:	f6 c1 03             	test   $0x3,%cl
  800b51:	75 0e                	jne    800b61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b53:	83 ef 04             	sub    $0x4,%edi
  800b56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b59:	c1 e9 02             	shr    $0x2,%ecx
  800b5c:	fd                   	std    
  800b5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5f:	eb 09                	jmp    800b6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b61:	83 ef 01             	sub    $0x1,%edi
  800b64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b67:	fd                   	std    
  800b68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b6a:	fc                   	cld    
  800b6b:	eb 1d                	jmp    800b8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6d:	89 f2                	mov    %esi,%edx
  800b6f:	09 c2                	or     %eax,%edx
  800b71:	f6 c2 03             	test   $0x3,%dl
  800b74:	75 0f                	jne    800b85 <memmove+0x5f>
  800b76:	f6 c1 03             	test   $0x3,%cl
  800b79:	75 0a                	jne    800b85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	fc                   	cld    
  800b81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b83:	eb 05                	jmp    800b8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b85:	89 c7                	mov    %eax,%edi
  800b87:	fc                   	cld    
  800b88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b91:	ff 75 10             	pushl  0x10(%ebp)
  800b94:	ff 75 0c             	pushl  0xc(%ebp)
  800b97:	ff 75 08             	pushl  0x8(%ebp)
  800b9a:	e8 87 ff ff ff       	call   800b26 <memmove>
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bac:	89 c6                	mov    %eax,%esi
  800bae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb1:	eb 1a                	jmp    800bcd <memcmp+0x2c>
		if (*s1 != *s2)
  800bb3:	0f b6 08             	movzbl (%eax),%ecx
  800bb6:	0f b6 1a             	movzbl (%edx),%ebx
  800bb9:	38 d9                	cmp    %bl,%cl
  800bbb:	74 0a                	je     800bc7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bbd:	0f b6 c1             	movzbl %cl,%eax
  800bc0:	0f b6 db             	movzbl %bl,%ebx
  800bc3:	29 d8                	sub    %ebx,%eax
  800bc5:	eb 0f                	jmp    800bd6 <memcmp+0x35>
		s1++, s2++;
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcd:	39 f0                	cmp    %esi,%eax
  800bcf:	75 e2                	jne    800bb3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	53                   	push   %ebx
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be1:	89 c1                	mov    %eax,%ecx
  800be3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800be6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bea:	eb 0a                	jmp    800bf6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bec:	0f b6 10             	movzbl (%eax),%edx
  800bef:	39 da                	cmp    %ebx,%edx
  800bf1:	74 07                	je     800bfa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf3:	83 c0 01             	add    $0x1,%eax
  800bf6:	39 c8                	cmp    %ecx,%eax
  800bf8:	72 f2                	jb     800bec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c09:	eb 03                	jmp    800c0e <strtol+0x11>
		s++;
  800c0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0e:	0f b6 01             	movzbl (%ecx),%eax
  800c11:	3c 20                	cmp    $0x20,%al
  800c13:	74 f6                	je     800c0b <strtol+0xe>
  800c15:	3c 09                	cmp    $0x9,%al
  800c17:	74 f2                	je     800c0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c19:	3c 2b                	cmp    $0x2b,%al
  800c1b:	75 0a                	jne    800c27 <strtol+0x2a>
		s++;
  800c1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c20:	bf 00 00 00 00       	mov    $0x0,%edi
  800c25:	eb 11                	jmp    800c38 <strtol+0x3b>
  800c27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c2c:	3c 2d                	cmp    $0x2d,%al
  800c2e:	75 08                	jne    800c38 <strtol+0x3b>
		s++, neg = 1;
  800c30:	83 c1 01             	add    $0x1,%ecx
  800c33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c3e:	75 15                	jne    800c55 <strtol+0x58>
  800c40:	80 39 30             	cmpb   $0x30,(%ecx)
  800c43:	75 10                	jne    800c55 <strtol+0x58>
  800c45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c49:	75 7c                	jne    800cc7 <strtol+0xca>
		s += 2, base = 16;
  800c4b:	83 c1 02             	add    $0x2,%ecx
  800c4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c53:	eb 16                	jmp    800c6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c55:	85 db                	test   %ebx,%ebx
  800c57:	75 12                	jne    800c6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c61:	75 08                	jne    800c6b <strtol+0x6e>
		s++, base = 8;
  800c63:	83 c1 01             	add    $0x1,%ecx
  800c66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c73:	0f b6 11             	movzbl (%ecx),%edx
  800c76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 09             	cmp    $0x9,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0x8b>
			dig = *s - '0';
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 30             	sub    $0x30,%edx
  800c86:	eb 22                	jmp    800caa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 19             	cmp    $0x19,%bl
  800c90:	77 08                	ja     800c9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 57             	sub    $0x57,%edx
  800c98:	eb 10                	jmp    800caa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c9d:	89 f3                	mov    %esi,%ebx
  800c9f:	80 fb 19             	cmp    $0x19,%bl
  800ca2:	77 16                	ja     800cba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ca4:	0f be d2             	movsbl %dl,%edx
  800ca7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800caa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cad:	7d 0b                	jge    800cba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800caf:	83 c1 01             	add    $0x1,%ecx
  800cb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cb8:	eb b9                	jmp    800c73 <strtol+0x76>

	if (endptr)
  800cba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cbe:	74 0d                	je     800ccd <strtol+0xd0>
		*endptr = (char *) s;
  800cc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc3:	89 0e                	mov    %ecx,(%esi)
  800cc5:	eb 06                	jmp    800ccd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc7:	85 db                	test   %ebx,%ebx
  800cc9:	74 98                	je     800c63 <strtol+0x66>
  800ccb:	eb 9e                	jmp    800c6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	f7 da                	neg    %edx
  800cd1:	85 ff                	test   %edi,%edi
  800cd3:	0f 45 c2             	cmovne %edx,%eax
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	89 c3                	mov    %eax,%ebx
  800cee:	89 c7                	mov    %eax,%edi
  800cf0:	89 c6                	mov    %eax,%esi
  800cf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	ba 00 00 00 00       	mov    $0x0,%edx
  800d04:	b8 01 00 00 00       	mov    $0x1,%eax
  800d09:	89 d1                	mov    %edx,%ecx
  800d0b:	89 d3                	mov    %edx,%ebx
  800d0d:	89 d7                	mov    %edx,%edi
  800d0f:	89 d6                	mov    %edx,%esi
  800d11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d26:	b8 03 00 00 00       	mov    $0x3,%eax
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 cb                	mov    %ecx,%ebx
  800d30:	89 cf                	mov    %ecx,%edi
  800d32:	89 ce                	mov    %ecx,%esi
  800d34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 03                	push   $0x3
  800d40:	68 ff 28 80 00       	push   $0x8028ff
  800d45:	6a 23                	push   $0x23
  800d47:	68 1c 29 80 00       	push   $0x80291c
  800d4c:	e8 e5 f5 ff ff       	call   800336 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 02 00 00 00       	mov    $0x2,%eax
  800d69:	89 d1                	mov    %edx,%ecx
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	89 d7                	mov    %edx,%edi
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_yield>:

void
sys_yield(void)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d88:	89 d1                	mov    %edx,%ecx
  800d8a:	89 d3                	mov    %edx,%ebx
  800d8c:	89 d7                	mov    %edx,%edi
  800d8e:	89 d6                	mov    %edx,%esi
  800d90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	be 00 00 00 00       	mov    $0x0,%esi
  800da5:	b8 04 00 00 00       	mov    $0x4,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db3:	89 f7                	mov    %esi,%edi
  800db5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db7:	85 c0                	test   %eax,%eax
  800db9:	7e 17                	jle    800dd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	50                   	push   %eax
  800dbf:	6a 04                	push   $0x4
  800dc1:	68 ff 28 80 00       	push   $0x8028ff
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 1c 29 80 00       	push   $0x80291c
  800dcd:	e8 64 f5 ff ff       	call   800336 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800de3:	b8 05 00 00 00       	mov    $0x5,%eax
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df4:	8b 75 18             	mov    0x18(%ebp),%esi
  800df7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 17                	jle    800e14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	50                   	push   %eax
  800e01:	6a 05                	push   $0x5
  800e03:	68 ff 28 80 00       	push   $0x8028ff
  800e08:	6a 23                	push   $0x23
  800e0a:	68 1c 29 80 00       	push   $0x80291c
  800e0f:	e8 22 f5 ff ff       	call   800336 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800e2a:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800e3d:	7e 17                	jle    800e56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	50                   	push   %eax
  800e43:	6a 06                	push   $0x6
  800e45:	68 ff 28 80 00       	push   $0x8028ff
  800e4a:	6a 23                	push   $0x23
  800e4c:	68 1c 29 80 00       	push   $0x80291c
  800e51:	e8 e0 f4 ff ff       	call   800336 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	89 df                	mov    %ebx,%edi
  800e79:	89 de                	mov    %ebx,%esi
  800e7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	7e 17                	jle    800e98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e81:	83 ec 0c             	sub    $0xc,%esp
  800e84:	50                   	push   %eax
  800e85:	6a 08                	push   $0x8
  800e87:	68 ff 28 80 00       	push   $0x8028ff
  800e8c:	6a 23                	push   $0x23
  800e8e:	68 1c 29 80 00       	push   $0x80291c
  800e93:	e8 9e f4 ff ff       	call   800336 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eae:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 de                	mov    %ebx,%esi
  800ebd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 17                	jle    800eda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	50                   	push   %eax
  800ec7:	6a 09                	push   $0x9
  800ec9:	68 ff 28 80 00       	push   $0x8028ff
  800ece:	6a 23                	push   $0x23
  800ed0:	68 1c 29 80 00       	push   $0x80291c
  800ed5:	e8 5c f4 ff ff       	call   800336 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	89 df                	mov    %ebx,%edi
  800efd:	89 de                	mov    %ebx,%esi
  800eff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7e 17                	jle    800f1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	83 ec 0c             	sub    $0xc,%esp
  800f08:	50                   	push   %eax
  800f09:	6a 0a                	push   $0xa
  800f0b:	68 ff 28 80 00       	push   $0x8028ff
  800f10:	6a 23                	push   $0x23
  800f12:	68 1c 29 80 00       	push   $0x80291c
  800f17:	e8 1a f4 ff ff       	call   800336 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2a:	be 00 00 00 00       	mov    $0x0,%esi
  800f2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f37:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5d:	89 cb                	mov    %ecx,%ebx
  800f5f:	89 cf                	mov    %ecx,%edi
  800f61:	89 ce                	mov    %ecx,%esi
  800f63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 0d                	push   $0xd
  800f6f:	68 ff 28 80 00       	push   $0x8028ff
  800f74:	6a 23                	push   $0x23
  800f76:	68 1c 29 80 00       	push   $0x80291c
  800f7b:	e8 b6 f3 ff ff       	call   800336 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f93:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f98:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9b:	89 cb                	mov    %ecx,%ebx
  800f9d:	89 cf                	mov    %ecx,%edi
  800f9f:	89 ce                	mov    %ecx,%esi
  800fa1:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	89 cb                	mov    %ecx,%ebx
  800fbd:	89 cf                	mov    %ecx,%edi
  800fbf:	89 ce                	mov    %ecx,%esi
  800fc1:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fd2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800fd4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd8:	74 11                	je     800feb <pgfault+0x23>
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe6:	f6 c4 08             	test   $0x8,%ah
  800fe9:	75 14                	jne    800fff <pgfault+0x37>
		panic("faulting access");
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	68 2a 29 80 00       	push   $0x80292a
  800ff3:	6a 1e                	push   $0x1e
  800ff5:	68 3a 29 80 00       	push   $0x80293a
  800ffa:	e8 37 f3 ff ff       	call   800336 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	6a 07                	push   $0x7
  801004:	68 00 f0 7f 00       	push   $0x7ff000
  801009:	6a 00                	push   $0x0
  80100b:	e8 87 fd ff ff       	call   800d97 <sys_page_alloc>
	if (r < 0) {
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	79 12                	jns    801029 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801017:	50                   	push   %eax
  801018:	68 45 29 80 00       	push   $0x802945
  80101d:	6a 2c                	push   $0x2c
  80101f:	68 3a 29 80 00       	push   $0x80293a
  801024:	e8 0d f3 ff ff       	call   800336 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801029:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	68 00 10 00 00       	push   $0x1000
  801037:	53                   	push   %ebx
  801038:	68 00 f0 7f 00       	push   $0x7ff000
  80103d:	e8 4c fb ff ff       	call   800b8e <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801042:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801049:	53                   	push   %ebx
  80104a:	6a 00                	push   $0x0
  80104c:	68 00 f0 7f 00       	push   $0x7ff000
  801051:	6a 00                	push   $0x0
  801053:	e8 82 fd ff ff       	call   800dda <sys_page_map>
	if (r < 0) {
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	79 12                	jns    801071 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80105f:	50                   	push   %eax
  801060:	68 45 29 80 00       	push   $0x802945
  801065:	6a 33                	push   $0x33
  801067:	68 3a 29 80 00       	push   $0x80293a
  80106c:	e8 c5 f2 ff ff       	call   800336 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	68 00 f0 7f 00       	push   $0x7ff000
  801079:	6a 00                	push   $0x0
  80107b:	e8 9c fd ff ff       	call   800e1c <sys_page_unmap>
	if (r < 0) {
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	79 12                	jns    801099 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801087:	50                   	push   %eax
  801088:	68 45 29 80 00       	push   $0x802945
  80108d:	6a 37                	push   $0x37
  80108f:	68 3a 29 80 00       	push   $0x80293a
  801094:	e8 9d f2 ff ff       	call   800336 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    

0080109e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8010a7:	68 c8 0f 80 00       	push   $0x800fc8
  8010ac:	e8 44 0f 00 00       	call   801ff5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010b1:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b6:	cd 30                	int    $0x30
  8010b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	79 17                	jns    8010d9 <fork+0x3b>
		panic("fork fault %e");
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	68 5e 29 80 00       	push   $0x80295e
  8010ca:	68 84 00 00 00       	push   $0x84
  8010cf:	68 3a 29 80 00       	push   $0x80293a
  8010d4:	e8 5d f2 ff ff       	call   800336 <_panic>
  8010d9:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8010db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010df:	75 25                	jne    801106 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e1:	e8 73 fc ff ff       	call   800d59 <sys_getenvid>
  8010e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	c1 e2 07             	shl    $0x7,%edx
  8010f0:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8010f7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801101:	e9 61 01 00 00       	jmp    801267 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	6a 07                	push   $0x7
  80110b:	68 00 f0 bf ee       	push   $0xeebff000
  801110:	ff 75 e4             	pushl  -0x1c(%ebp)
  801113:	e8 7f fc ff ff       	call   800d97 <sys_page_alloc>
  801118:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80111b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801120:	89 d8                	mov    %ebx,%eax
  801122:	c1 e8 16             	shr    $0x16,%eax
  801125:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112c:	a8 01                	test   $0x1,%al
  80112e:	0f 84 fc 00 00 00    	je     801230 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801134:	89 d8                	mov    %ebx,%eax
  801136:	c1 e8 0c             	shr    $0xc,%eax
  801139:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801140:	f6 c2 01             	test   $0x1,%dl
  801143:	0f 84 e7 00 00 00    	je     801230 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801149:	89 c6                	mov    %eax,%esi
  80114b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80114e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801155:	f6 c6 04             	test   $0x4,%dh
  801158:	74 39                	je     801193 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80115a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801161:	83 ec 0c             	sub    $0xc,%esp
  801164:	25 07 0e 00 00       	and    $0xe07,%eax
  801169:	50                   	push   %eax
  80116a:	56                   	push   %esi
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	6a 00                	push   $0x0
  80116f:	e8 66 fc ff ff       	call   800dda <sys_page_map>
		if (r < 0) {
  801174:	83 c4 20             	add    $0x20,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	0f 89 b1 00 00 00    	jns    801230 <fork+0x192>
		    	panic("sys page map fault %e");
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	68 6c 29 80 00       	push   $0x80296c
  801187:	6a 54                	push   $0x54
  801189:	68 3a 29 80 00       	push   $0x80293a
  80118e:	e8 a3 f1 ff ff       	call   800336 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801193:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80119a:	f6 c2 02             	test   $0x2,%dl
  80119d:	75 0c                	jne    8011ab <fork+0x10d>
  80119f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a6:	f6 c4 08             	test   $0x8,%ah
  8011a9:	74 5b                	je     801206 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	68 05 08 00 00       	push   $0x805
  8011b3:	56                   	push   %esi
  8011b4:	57                   	push   %edi
  8011b5:	56                   	push   %esi
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 1d fc ff ff       	call   800dda <sys_page_map>
		if (r < 0) {
  8011bd:	83 c4 20             	add    $0x20,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 14                	jns    8011d8 <fork+0x13a>
		    	panic("sys page map fault %e");
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	68 6c 29 80 00       	push   $0x80296c
  8011cc:	6a 5b                	push   $0x5b
  8011ce:	68 3a 29 80 00       	push   $0x80293a
  8011d3:	e8 5e f1 ff ff       	call   800336 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8011d8:	83 ec 0c             	sub    $0xc,%esp
  8011db:	68 05 08 00 00       	push   $0x805
  8011e0:	56                   	push   %esi
  8011e1:	6a 00                	push   $0x0
  8011e3:	56                   	push   %esi
  8011e4:	6a 00                	push   $0x0
  8011e6:	e8 ef fb ff ff       	call   800dda <sys_page_map>
		if (r < 0) {
  8011eb:	83 c4 20             	add    $0x20,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	79 3e                	jns    801230 <fork+0x192>
		    	panic("sys page map fault %e");
  8011f2:	83 ec 04             	sub    $0x4,%esp
  8011f5:	68 6c 29 80 00       	push   $0x80296c
  8011fa:	6a 5f                	push   $0x5f
  8011fc:	68 3a 29 80 00       	push   $0x80293a
  801201:	e8 30 f1 ff ff       	call   800336 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	6a 05                	push   $0x5
  80120b:	56                   	push   %esi
  80120c:	57                   	push   %edi
  80120d:	56                   	push   %esi
  80120e:	6a 00                	push   $0x0
  801210:	e8 c5 fb ff ff       	call   800dda <sys_page_map>
		if (r < 0) {
  801215:	83 c4 20             	add    $0x20,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	79 14                	jns    801230 <fork+0x192>
		    	panic("sys page map fault %e");
  80121c:	83 ec 04             	sub    $0x4,%esp
  80121f:	68 6c 29 80 00       	push   $0x80296c
  801224:	6a 64                	push   $0x64
  801226:	68 3a 29 80 00       	push   $0x80293a
  80122b:	e8 06 f1 ff ff       	call   800336 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801230:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801236:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80123c:	0f 85 de fe ff ff    	jne    801120 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801242:	a1 04 40 80 00       	mov    0x804004,%eax
  801247:	8b 40 70             	mov    0x70(%eax),%eax
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	50                   	push   %eax
  80124e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801251:	57                   	push   %edi
  801252:	e8 8b fc ff ff       	call   800ee2 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	6a 02                	push   $0x2
  80125c:	57                   	push   %edi
  80125d:	e8 fc fb ff ff       	call   800e5e <sys_env_set_status>
	
	return envid;
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126a:	5b                   	pop    %ebx
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <sfork>:

envid_t
sfork(void)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801281:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	53                   	push   %ebx
  80128b:	68 84 29 80 00       	push   $0x802984
  801290:	e8 7a f1 ff ff       	call   80040f <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801295:	c7 04 24 fc 02 80 00 	movl   $0x8002fc,(%esp)
  80129c:	e8 e7 fc ff ff       	call   800f88 <sys_thread_create>
  8012a1:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012a3:	83 c4 08             	add    $0x8,%esp
  8012a6:	53                   	push   %ebx
  8012a7:	68 84 29 80 00       	push   $0x802984
  8012ac:	e8 5e f1 ff ff       	call   80040f <cprintf>
	return id;
	//return 0;
}
  8012b1:	89 f0                	mov    %esi,%eax
  8012b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c5:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d0:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012da:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	c1 ea 16             	shr    $0x16,%edx
  8012f1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f8:	f6 c2 01             	test   $0x1,%dl
  8012fb:	74 11                	je     80130e <fd_alloc+0x2d>
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	c1 ea 0c             	shr    $0xc,%edx
  801302:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801309:	f6 c2 01             	test   $0x1,%dl
  80130c:	75 09                	jne    801317 <fd_alloc+0x36>
			*fd_store = fd;
  80130e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
  801315:	eb 17                	jmp    80132e <fd_alloc+0x4d>
  801317:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801321:	75 c9                	jne    8012ec <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801323:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801329:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801336:	83 f8 1f             	cmp    $0x1f,%eax
  801339:	77 36                	ja     801371 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133b:	c1 e0 0c             	shl    $0xc,%eax
  80133e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801343:	89 c2                	mov    %eax,%edx
  801345:	c1 ea 16             	shr    $0x16,%edx
  801348:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134f:	f6 c2 01             	test   $0x1,%dl
  801352:	74 24                	je     801378 <fd_lookup+0x48>
  801354:	89 c2                	mov    %eax,%edx
  801356:	c1 ea 0c             	shr    $0xc,%edx
  801359:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801360:	f6 c2 01             	test   $0x1,%dl
  801363:	74 1a                	je     80137f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801365:	8b 55 0c             	mov    0xc(%ebp),%edx
  801368:	89 02                	mov    %eax,(%edx)
	return 0;
  80136a:	b8 00 00 00 00       	mov    $0x0,%eax
  80136f:	eb 13                	jmp    801384 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801371:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801376:	eb 0c                	jmp    801384 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801378:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137d:	eb 05                	jmp    801384 <fd_lookup+0x54>
  80137f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138f:	ba 28 2a 80 00       	mov    $0x802a28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801394:	eb 13                	jmp    8013a9 <dev_lookup+0x23>
  801396:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801399:	39 08                	cmp    %ecx,(%eax)
  80139b:	75 0c                	jne    8013a9 <dev_lookup+0x23>
			*dev = devtab[i];
  80139d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a7:	eb 2e                	jmp    8013d7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a9:	8b 02                	mov    (%edx),%eax
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	75 e7                	jne    801396 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013af:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b4:	8b 40 54             	mov    0x54(%eax),%eax
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	51                   	push   %ecx
  8013bb:	50                   	push   %eax
  8013bc:	68 a8 29 80 00       	push   $0x8029a8
  8013c1:	e8 49 f0 ff ff       	call   80040f <cprintf>
	*dev = 0;
  8013c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 10             	sub    $0x10,%esp
  8013e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013f1:	c1 e8 0c             	shr    $0xc,%eax
  8013f4:	50                   	push   %eax
  8013f5:	e8 36 ff ff ff       	call   801330 <fd_lookup>
  8013fa:	83 c4 08             	add    $0x8,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 05                	js     801406 <fd_close+0x2d>
	    || fd != fd2)
  801401:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801404:	74 0c                	je     801412 <fd_close+0x39>
		return (must_exist ? r : 0);
  801406:	84 db                	test   %bl,%bl
  801408:	ba 00 00 00 00       	mov    $0x0,%edx
  80140d:	0f 44 c2             	cmove  %edx,%eax
  801410:	eb 41                	jmp    801453 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	ff 36                	pushl  (%esi)
  80141b:	e8 66 ff ff ff       	call   801386 <dev_lookup>
  801420:	89 c3                	mov    %eax,%ebx
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	78 1a                	js     801443 <fd_close+0x6a>
		if (dev->dev_close)
  801429:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801434:	85 c0                	test   %eax,%eax
  801436:	74 0b                	je     801443 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	56                   	push   %esi
  80143c:	ff d0                	call   *%eax
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	56                   	push   %esi
  801447:	6a 00                	push   $0x0
  801449:	e8 ce f9 ff ff       	call   800e1c <sys_page_unmap>
	return r;
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	89 d8                	mov    %ebx,%eax
}
  801453:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801456:	5b                   	pop    %ebx
  801457:	5e                   	pop    %esi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	ff 75 08             	pushl  0x8(%ebp)
  801467:	e8 c4 fe ff ff       	call   801330 <fd_lookup>
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 10                	js     801483 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	6a 01                	push   $0x1
  801478:	ff 75 f4             	pushl  -0xc(%ebp)
  80147b:	e8 59 ff ff ff       	call   8013d9 <fd_close>
  801480:	83 c4 10             	add    $0x10,%esp
}
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <close_all>:

void
close_all(void)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	53                   	push   %ebx
  801489:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801491:	83 ec 0c             	sub    $0xc,%esp
  801494:	53                   	push   %ebx
  801495:	e8 c0 ff ff ff       	call   80145a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80149a:	83 c3 01             	add    $0x1,%ebx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	83 fb 20             	cmp    $0x20,%ebx
  8014a3:	75 ec                	jne    801491 <close_all+0xc>
		close(i);
}
  8014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	57                   	push   %edi
  8014ae:	56                   	push   %esi
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 2c             	sub    $0x2c,%esp
  8014b3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	ff 75 08             	pushl  0x8(%ebp)
  8014bd:	e8 6e fe ff ff       	call   801330 <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	0f 88 c1 00 00 00    	js     80158e <dup+0xe4>
		return r;
	close(newfdnum);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	56                   	push   %esi
  8014d1:	e8 84 ff ff ff       	call   80145a <close>

	newfd = INDEX2FD(newfdnum);
  8014d6:	89 f3                	mov    %esi,%ebx
  8014d8:	c1 e3 0c             	shl    $0xc,%ebx
  8014db:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014e1:	83 c4 04             	add    $0x4,%esp
  8014e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e7:	e8 de fd ff ff       	call   8012ca <fd2data>
  8014ec:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014ee:	89 1c 24             	mov    %ebx,(%esp)
  8014f1:	e8 d4 fd ff ff       	call   8012ca <fd2data>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014fc:	89 f8                	mov    %edi,%eax
  8014fe:	c1 e8 16             	shr    $0x16,%eax
  801501:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801508:	a8 01                	test   $0x1,%al
  80150a:	74 37                	je     801543 <dup+0x99>
  80150c:	89 f8                	mov    %edi,%eax
  80150e:	c1 e8 0c             	shr    $0xc,%eax
  801511:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801518:	f6 c2 01             	test   $0x1,%dl
  80151b:	74 26                	je     801543 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80151d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	25 07 0e 00 00       	and    $0xe07,%eax
  80152c:	50                   	push   %eax
  80152d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801530:	6a 00                	push   $0x0
  801532:	57                   	push   %edi
  801533:	6a 00                	push   $0x0
  801535:	e8 a0 f8 ff ff       	call   800dda <sys_page_map>
  80153a:	89 c7                	mov    %eax,%edi
  80153c:	83 c4 20             	add    $0x20,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 2e                	js     801571 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801543:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801546:	89 d0                	mov    %edx,%eax
  801548:	c1 e8 0c             	shr    $0xc,%eax
  80154b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801552:	83 ec 0c             	sub    $0xc,%esp
  801555:	25 07 0e 00 00       	and    $0xe07,%eax
  80155a:	50                   	push   %eax
  80155b:	53                   	push   %ebx
  80155c:	6a 00                	push   $0x0
  80155e:	52                   	push   %edx
  80155f:	6a 00                	push   $0x0
  801561:	e8 74 f8 ff ff       	call   800dda <sys_page_map>
  801566:	89 c7                	mov    %eax,%edi
  801568:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80156b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156d:	85 ff                	test   %edi,%edi
  80156f:	79 1d                	jns    80158e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	53                   	push   %ebx
  801575:	6a 00                	push   $0x0
  801577:	e8 a0 f8 ff ff       	call   800e1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801582:	6a 00                	push   $0x0
  801584:	e8 93 f8 ff ff       	call   800e1c <sys_page_unmap>
	return r;
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	89 f8                	mov    %edi,%eax
}
  80158e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	53                   	push   %ebx
  8015a5:	e8 86 fd ff ff       	call   801330 <fd_lookup>
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 6d                	js     801620 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	ff 30                	pushl  (%eax)
  8015bf:	e8 c2 fd ff ff       	call   801386 <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 4c                	js     801617 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ce:	8b 42 08             	mov    0x8(%edx),%eax
  8015d1:	83 e0 03             	and    $0x3,%eax
  8015d4:	83 f8 01             	cmp    $0x1,%eax
  8015d7:	75 21                	jne    8015fa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015de:	8b 40 54             	mov    0x54(%eax),%eax
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	50                   	push   %eax
  8015e6:	68 ec 29 80 00       	push   $0x8029ec
  8015eb:	e8 1f ee ff ff       	call   80040f <cprintf>
		return -E_INVAL;
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f8:	eb 26                	jmp    801620 <read+0x8a>
	}
	if (!dev->dev_read)
  8015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fd:	8b 40 08             	mov    0x8(%eax),%eax
  801600:	85 c0                	test   %eax,%eax
  801602:	74 17                	je     80161b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801604:	83 ec 04             	sub    $0x4,%esp
  801607:	ff 75 10             	pushl  0x10(%ebp)
  80160a:	ff 75 0c             	pushl  0xc(%ebp)
  80160d:	52                   	push   %edx
  80160e:	ff d0                	call   *%eax
  801610:	89 c2                	mov    %eax,%edx
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	eb 09                	jmp    801620 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	89 c2                	mov    %eax,%edx
  801619:	eb 05                	jmp    801620 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80161b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801620:	89 d0                	mov    %edx,%eax
  801622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	57                   	push   %edi
  80162b:	56                   	push   %esi
  80162c:	53                   	push   %ebx
  80162d:	83 ec 0c             	sub    $0xc,%esp
  801630:	8b 7d 08             	mov    0x8(%ebp),%edi
  801633:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801636:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163b:	eb 21                	jmp    80165e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	89 f0                	mov    %esi,%eax
  801642:	29 d8                	sub    %ebx,%eax
  801644:	50                   	push   %eax
  801645:	89 d8                	mov    %ebx,%eax
  801647:	03 45 0c             	add    0xc(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	57                   	push   %edi
  80164c:	e8 45 ff ff ff       	call   801596 <read>
		if (m < 0)
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	85 c0                	test   %eax,%eax
  801656:	78 10                	js     801668 <readn+0x41>
			return m;
		if (m == 0)
  801658:	85 c0                	test   %eax,%eax
  80165a:	74 0a                	je     801666 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165c:	01 c3                	add    %eax,%ebx
  80165e:	39 f3                	cmp    %esi,%ebx
  801660:	72 db                	jb     80163d <readn+0x16>
  801662:	89 d8                	mov    %ebx,%eax
  801664:	eb 02                	jmp    801668 <readn+0x41>
  801666:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5f                   	pop    %edi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	53                   	push   %ebx
  801674:	83 ec 14             	sub    $0x14,%esp
  801677:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	53                   	push   %ebx
  80167f:	e8 ac fc ff ff       	call   801330 <fd_lookup>
  801684:	83 c4 08             	add    $0x8,%esp
  801687:	89 c2                	mov    %eax,%edx
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 68                	js     8016f5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801697:	ff 30                	pushl  (%eax)
  801699:	e8 e8 fc ff ff       	call   801386 <dev_lookup>
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 47                	js     8016ec <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ac:	75 21                	jne    8016cf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b3:	8b 40 54             	mov    0x54(%eax),%eax
  8016b6:	83 ec 04             	sub    $0x4,%esp
  8016b9:	53                   	push   %ebx
  8016ba:	50                   	push   %eax
  8016bb:	68 08 2a 80 00       	push   $0x802a08
  8016c0:	e8 4a ed ff ff       	call   80040f <cprintf>
		return -E_INVAL;
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016cd:	eb 26                	jmp    8016f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d2:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d5:	85 d2                	test   %edx,%edx
  8016d7:	74 17                	je     8016f0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	ff 75 10             	pushl  0x10(%ebp)
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	50                   	push   %eax
  8016e3:	ff d2                	call   *%edx
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	eb 09                	jmp    8016f5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	eb 05                	jmp    8016f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f5:	89 d0                	mov    %edx,%eax
  8016f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <seek>:

int
seek(int fdnum, off_t offset)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801702:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	ff 75 08             	pushl  0x8(%ebp)
  801709:	e8 22 fc ff ff       	call   801330 <fd_lookup>
  80170e:	83 c4 08             	add    $0x8,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 0e                	js     801723 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801715:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801718:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80171e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	53                   	push   %ebx
  801729:	83 ec 14             	sub    $0x14,%esp
  80172c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	53                   	push   %ebx
  801734:	e8 f7 fb ff ff       	call   801330 <fd_lookup>
  801739:	83 c4 08             	add    $0x8,%esp
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 65                	js     8017a7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801748:	50                   	push   %eax
  801749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174c:	ff 30                	pushl  (%eax)
  80174e:	e8 33 fc ff ff       	call   801386 <dev_lookup>
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 44                	js     80179e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801761:	75 21                	jne    801784 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801763:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801768:	8b 40 54             	mov    0x54(%eax),%eax
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	53                   	push   %ebx
  80176f:	50                   	push   %eax
  801770:	68 c8 29 80 00       	push   $0x8029c8
  801775:	e8 95 ec ff ff       	call   80040f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801782:	eb 23                	jmp    8017a7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801784:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801787:	8b 52 18             	mov    0x18(%edx),%edx
  80178a:	85 d2                	test   %edx,%edx
  80178c:	74 14                	je     8017a2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	ff 75 0c             	pushl  0xc(%ebp)
  801794:	50                   	push   %eax
  801795:	ff d2                	call   *%edx
  801797:	89 c2                	mov    %eax,%edx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	eb 09                	jmp    8017a7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	89 c2                	mov    %eax,%edx
  8017a0:	eb 05                	jmp    8017a7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a7:	89 d0                	mov    %edx,%eax
  8017a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	53                   	push   %ebx
  8017b2:	83 ec 14             	sub    $0x14,%esp
  8017b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017bb:	50                   	push   %eax
  8017bc:	ff 75 08             	pushl  0x8(%ebp)
  8017bf:	e8 6c fb ff ff       	call   801330 <fd_lookup>
  8017c4:	83 c4 08             	add    $0x8,%esp
  8017c7:	89 c2                	mov    %eax,%edx
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 58                	js     801825 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cd:	83 ec 08             	sub    $0x8,%esp
  8017d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d7:	ff 30                	pushl  (%eax)
  8017d9:	e8 a8 fb ff ff       	call   801386 <dev_lookup>
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 37                	js     80181c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ec:	74 32                	je     801820 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ee:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f8:	00 00 00 
	stat->st_isdir = 0;
  8017fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801802:	00 00 00 
	stat->st_dev = dev;
  801805:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	53                   	push   %ebx
  80180f:	ff 75 f0             	pushl  -0x10(%ebp)
  801812:	ff 50 14             	call   *0x14(%eax)
  801815:	89 c2                	mov    %eax,%edx
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	eb 09                	jmp    801825 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181c:	89 c2                	mov    %eax,%edx
  80181e:	eb 05                	jmp    801825 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801820:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801825:	89 d0                	mov    %edx,%eax
  801827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	6a 00                	push   $0x0
  801836:	ff 75 08             	pushl  0x8(%ebp)
  801839:	e8 e3 01 00 00       	call   801a21 <open>
  80183e:	89 c3                	mov    %eax,%ebx
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 1b                	js     801862 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	ff 75 0c             	pushl  0xc(%ebp)
  80184d:	50                   	push   %eax
  80184e:	e8 5b ff ff ff       	call   8017ae <fstat>
  801853:	89 c6                	mov    %eax,%esi
	close(fd);
  801855:	89 1c 24             	mov    %ebx,(%esp)
  801858:	e8 fd fb ff ff       	call   80145a <close>
	return r;
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	89 f0                	mov    %esi,%eax
}
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	89 c6                	mov    %eax,%esi
  801870:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801872:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801879:	75 12                	jne    80188d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	6a 01                	push   $0x1
  801880:	e8 d9 08 00 00       	call   80215e <ipc_find_env>
  801885:	a3 00 40 80 00       	mov    %eax,0x804000
  80188a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80188d:	6a 07                	push   $0x7
  80188f:	68 00 50 80 00       	push   $0x805000
  801894:	56                   	push   %esi
  801895:	ff 35 00 40 80 00    	pushl  0x804000
  80189b:	e8 5c 08 00 00       	call   8020fc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a0:	83 c4 0c             	add    $0xc,%esp
  8018a3:	6a 00                	push   $0x0
  8018a5:	53                   	push   %ebx
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 d7 07 00 00       	call   802084 <ipc_recv>
}
  8018ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b0:	5b                   	pop    %ebx
  8018b1:	5e                   	pop    %esi
  8018b2:	5d                   	pop    %ebp
  8018b3:	c3                   	ret    

008018b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d7:	e8 8d ff ff ff       	call   801869 <fsipc>
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ea:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8018f9:	e8 6b ff ff ff       	call   801869 <fsipc>
}
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	53                   	push   %ebx
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
  80190d:	8b 40 0c             	mov    0xc(%eax),%eax
  801910:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801915:	ba 00 00 00 00       	mov    $0x0,%edx
  80191a:	b8 05 00 00 00       	mov    $0x5,%eax
  80191f:	e8 45 ff ff ff       	call   801869 <fsipc>
  801924:	85 c0                	test   %eax,%eax
  801926:	78 2c                	js     801954 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	68 00 50 80 00       	push   $0x805000
  801930:	53                   	push   %ebx
  801931:	e8 5e f0 ff ff       	call   800994 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801936:	a1 80 50 80 00       	mov    0x805080,%eax
  80193b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801941:	a1 84 50 80 00       	mov    0x805084,%eax
  801946:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801954:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801962:	8b 55 08             	mov    0x8(%ebp),%edx
  801965:	8b 52 0c             	mov    0xc(%edx),%edx
  801968:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80196e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801973:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801978:	0f 47 c2             	cmova  %edx,%eax
  80197b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801980:	50                   	push   %eax
  801981:	ff 75 0c             	pushl  0xc(%ebp)
  801984:	68 08 50 80 00       	push   $0x805008
  801989:	e8 98 f1 ff ff       	call   800b26 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80198e:	ba 00 00 00 00       	mov    $0x0,%edx
  801993:	b8 04 00 00 00       	mov    $0x4,%eax
  801998:	e8 cc fe ff ff       	call   801869 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c2:	e8 a2 fe ff ff       	call   801869 <fsipc>
  8019c7:	89 c3                	mov    %eax,%ebx
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 4b                	js     801a18 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019cd:	39 c6                	cmp    %eax,%esi
  8019cf:	73 16                	jae    8019e7 <devfile_read+0x48>
  8019d1:	68 38 2a 80 00       	push   $0x802a38
  8019d6:	68 3f 2a 80 00       	push   $0x802a3f
  8019db:	6a 7c                	push   $0x7c
  8019dd:	68 54 2a 80 00       	push   $0x802a54
  8019e2:	e8 4f e9 ff ff       	call   800336 <_panic>
	assert(r <= PGSIZE);
  8019e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ec:	7e 16                	jle    801a04 <devfile_read+0x65>
  8019ee:	68 5f 2a 80 00       	push   $0x802a5f
  8019f3:	68 3f 2a 80 00       	push   $0x802a3f
  8019f8:	6a 7d                	push   $0x7d
  8019fa:	68 54 2a 80 00       	push   $0x802a54
  8019ff:	e8 32 e9 ff ff       	call   800336 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	50                   	push   %eax
  801a08:	68 00 50 80 00       	push   $0x805000
  801a0d:	ff 75 0c             	pushl  0xc(%ebp)
  801a10:	e8 11 f1 ff ff       	call   800b26 <memmove>
	return r;
  801a15:	83 c4 10             	add    $0x10,%esp
}
  801a18:	89 d8                	mov    %ebx,%eax
  801a1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	53                   	push   %ebx
  801a25:	83 ec 20             	sub    $0x20,%esp
  801a28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a2b:	53                   	push   %ebx
  801a2c:	e8 2a ef ff ff       	call   80095b <strlen>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a39:	7f 67                	jg     801aa2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a41:	50                   	push   %eax
  801a42:	e8 9a f8 ff ff       	call   8012e1 <fd_alloc>
  801a47:	83 c4 10             	add    $0x10,%esp
		return r;
  801a4a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 57                	js     801aa7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	53                   	push   %ebx
  801a54:	68 00 50 80 00       	push   $0x805000
  801a59:	e8 36 ef ff ff       	call   800994 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a61:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a69:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6e:	e8 f6 fd ff ff       	call   801869 <fsipc>
  801a73:	89 c3                	mov    %eax,%ebx
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	79 14                	jns    801a90 <open+0x6f>
		fd_close(fd, 0);
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	6a 00                	push   $0x0
  801a81:	ff 75 f4             	pushl  -0xc(%ebp)
  801a84:	e8 50 f9 ff ff       	call   8013d9 <fd_close>
		return r;
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	89 da                	mov    %ebx,%edx
  801a8e:	eb 17                	jmp    801aa7 <open+0x86>
	}

	return fd2num(fd);
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	ff 75 f4             	pushl  -0xc(%ebp)
  801a96:	e8 1f f8 ff ff       	call   8012ba <fd2num>
  801a9b:	89 c2                	mov    %eax,%edx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	eb 05                	jmp    801aa7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aa2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aa7:	89 d0                	mov    %edx,%eax
  801aa9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab9:	b8 08 00 00 00       	mov    $0x8,%eax
  801abe:	e8 a6 fd ff ff       	call   801869 <fsipc>
}
  801ac3:	c9                   	leave  
  801ac4:	c3                   	ret    

00801ac5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801acd:	83 ec 0c             	sub    $0xc,%esp
  801ad0:	ff 75 08             	pushl  0x8(%ebp)
  801ad3:	e8 f2 f7 ff ff       	call   8012ca <fd2data>
  801ad8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ada:	83 c4 08             	add    $0x8,%esp
  801add:	68 6b 2a 80 00       	push   $0x802a6b
  801ae2:	53                   	push   %ebx
  801ae3:	e8 ac ee ff ff       	call   800994 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ae8:	8b 46 04             	mov    0x4(%esi),%eax
  801aeb:	2b 06                	sub    (%esi),%eax
  801aed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801af3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801afa:	00 00 00 
	stat->st_dev = &devpipe;
  801afd:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b04:	30 80 00 
	return 0;
}
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	53                   	push   %ebx
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b1d:	53                   	push   %ebx
  801b1e:	6a 00                	push   $0x0
  801b20:	e8 f7 f2 ff ff       	call   800e1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b25:	89 1c 24             	mov    %ebx,(%esp)
  801b28:	e8 9d f7 ff ff       	call   8012ca <fd2data>
  801b2d:	83 c4 08             	add    $0x8,%esp
  801b30:	50                   	push   %eax
  801b31:	6a 00                	push   $0x0
  801b33:	e8 e4 f2 ff ff       	call   800e1c <sys_page_unmap>
}
  801b38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	57                   	push   %edi
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
  801b43:	83 ec 1c             	sub    $0x1c,%esp
  801b46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b49:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b4b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b50:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b53:	83 ec 0c             	sub    $0xc,%esp
  801b56:	ff 75 e0             	pushl  -0x20(%ebp)
  801b59:	e8 40 06 00 00       	call   80219e <pageref>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	89 3c 24             	mov    %edi,(%esp)
  801b63:	e8 36 06 00 00       	call   80219e <pageref>
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	39 c3                	cmp    %eax,%ebx
  801b6d:	0f 94 c1             	sete   %cl
  801b70:	0f b6 c9             	movzbl %cl,%ecx
  801b73:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b76:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b7c:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801b7f:	39 ce                	cmp    %ecx,%esi
  801b81:	74 1b                	je     801b9e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b83:	39 c3                	cmp    %eax,%ebx
  801b85:	75 c4                	jne    801b4b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b87:	8b 42 64             	mov    0x64(%edx),%eax
  801b8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8d:	50                   	push   %eax
  801b8e:	56                   	push   %esi
  801b8f:	68 72 2a 80 00       	push   $0x802a72
  801b94:	e8 76 e8 ff ff       	call   80040f <cprintf>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	eb ad                	jmp    801b4b <_pipeisclosed+0xe>
	}
}
  801b9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5f                   	pop    %edi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	57                   	push   %edi
  801bad:	56                   	push   %esi
  801bae:	53                   	push   %ebx
  801baf:	83 ec 28             	sub    $0x28,%esp
  801bb2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bb5:	56                   	push   %esi
  801bb6:	e8 0f f7 ff ff       	call   8012ca <fd2data>
  801bbb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	bf 00 00 00 00       	mov    $0x0,%edi
  801bc5:	eb 4b                	jmp    801c12 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bc7:	89 da                	mov    %ebx,%edx
  801bc9:	89 f0                	mov    %esi,%eax
  801bcb:	e8 6d ff ff ff       	call   801b3d <_pipeisclosed>
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	75 48                	jne    801c1c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bd4:	e8 9f f1 ff ff       	call   800d78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bd9:	8b 43 04             	mov    0x4(%ebx),%eax
  801bdc:	8b 0b                	mov    (%ebx),%ecx
  801bde:	8d 51 20             	lea    0x20(%ecx),%edx
  801be1:	39 d0                	cmp    %edx,%eax
  801be3:	73 e2                	jae    801bc7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bec:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bef:	89 c2                	mov    %eax,%edx
  801bf1:	c1 fa 1f             	sar    $0x1f,%edx
  801bf4:	89 d1                	mov    %edx,%ecx
  801bf6:	c1 e9 1b             	shr    $0x1b,%ecx
  801bf9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bfc:	83 e2 1f             	and    $0x1f,%edx
  801bff:	29 ca                	sub    %ecx,%edx
  801c01:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c05:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c09:	83 c0 01             	add    $0x1,%eax
  801c0c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0f:	83 c7 01             	add    $0x1,%edi
  801c12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c15:	75 c2                	jne    801bd9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c17:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1a:	eb 05                	jmp    801c21 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	57                   	push   %edi
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 18             	sub    $0x18,%esp
  801c32:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c35:	57                   	push   %edi
  801c36:	e8 8f f6 ff ff       	call   8012ca <fd2data>
  801c3b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c45:	eb 3d                	jmp    801c84 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c47:	85 db                	test   %ebx,%ebx
  801c49:	74 04                	je     801c4f <devpipe_read+0x26>
				return i;
  801c4b:	89 d8                	mov    %ebx,%eax
  801c4d:	eb 44                	jmp    801c93 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c4f:	89 f2                	mov    %esi,%edx
  801c51:	89 f8                	mov    %edi,%eax
  801c53:	e8 e5 fe ff ff       	call   801b3d <_pipeisclosed>
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	75 32                	jne    801c8e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c5c:	e8 17 f1 ff ff       	call   800d78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c61:	8b 06                	mov    (%esi),%eax
  801c63:	3b 46 04             	cmp    0x4(%esi),%eax
  801c66:	74 df                	je     801c47 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c68:	99                   	cltd   
  801c69:	c1 ea 1b             	shr    $0x1b,%edx
  801c6c:	01 d0                	add    %edx,%eax
  801c6e:	83 e0 1f             	and    $0x1f,%eax
  801c71:	29 d0                	sub    %edx,%eax
  801c73:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c7e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c81:	83 c3 01             	add    $0x1,%ebx
  801c84:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c87:	75 d8                	jne    801c61 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c89:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8c:	eb 05                	jmp    801c93 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c8e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c96:	5b                   	pop    %ebx
  801c97:	5e                   	pop    %esi
  801c98:	5f                   	pop    %edi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	56                   	push   %esi
  801c9f:	53                   	push   %ebx
  801ca0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ca3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	e8 35 f6 ff ff       	call   8012e1 <fd_alloc>
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	89 c2                	mov    %eax,%edx
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	0f 88 2c 01 00 00    	js     801de5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb9:	83 ec 04             	sub    $0x4,%esp
  801cbc:	68 07 04 00 00       	push   $0x407
  801cc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 cc f0 ff ff       	call   800d97 <sys_page_alloc>
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	89 c2                	mov    %eax,%edx
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	0f 88 0d 01 00 00    	js     801de5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cd8:	83 ec 0c             	sub    $0xc,%esp
  801cdb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cde:	50                   	push   %eax
  801cdf:	e8 fd f5 ff ff       	call   8012e1 <fd_alloc>
  801ce4:	89 c3                	mov    %eax,%ebx
  801ce6:	83 c4 10             	add    $0x10,%esp
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	0f 88 e2 00 00 00    	js     801dd3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf1:	83 ec 04             	sub    $0x4,%esp
  801cf4:	68 07 04 00 00       	push   $0x407
  801cf9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfc:	6a 00                	push   $0x0
  801cfe:	e8 94 f0 ff ff       	call   800d97 <sys_page_alloc>
  801d03:	89 c3                	mov    %eax,%ebx
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	0f 88 c3 00 00 00    	js     801dd3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d10:	83 ec 0c             	sub    $0xc,%esp
  801d13:	ff 75 f4             	pushl  -0xc(%ebp)
  801d16:	e8 af f5 ff ff       	call   8012ca <fd2data>
  801d1b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1d:	83 c4 0c             	add    $0xc,%esp
  801d20:	68 07 04 00 00       	push   $0x407
  801d25:	50                   	push   %eax
  801d26:	6a 00                	push   $0x0
  801d28:	e8 6a f0 ff ff       	call   800d97 <sys_page_alloc>
  801d2d:	89 c3                	mov    %eax,%ebx
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	0f 88 89 00 00 00    	js     801dc3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3a:	83 ec 0c             	sub    $0xc,%esp
  801d3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d40:	e8 85 f5 ff ff       	call   8012ca <fd2data>
  801d45:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d4c:	50                   	push   %eax
  801d4d:	6a 00                	push   $0x0
  801d4f:	56                   	push   %esi
  801d50:	6a 00                	push   $0x0
  801d52:	e8 83 f0 ff ff       	call   800dda <sys_page_map>
  801d57:	89 c3                	mov    %eax,%ebx
  801d59:	83 c4 20             	add    $0x20,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	78 55                	js     801db5 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d60:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d69:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d75:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d83:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d8a:	83 ec 0c             	sub    $0xc,%esp
  801d8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d90:	e8 25 f5 ff ff       	call   8012ba <fd2num>
  801d95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d98:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d9a:	83 c4 04             	add    $0x4,%esp
  801d9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801da0:	e8 15 f5 ff ff       	call   8012ba <fd2num>
  801da5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da8:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	ba 00 00 00 00       	mov    $0x0,%edx
  801db3:	eb 30                	jmp    801de5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801db5:	83 ec 08             	sub    $0x8,%esp
  801db8:	56                   	push   %esi
  801db9:	6a 00                	push   $0x0
  801dbb:	e8 5c f0 ff ff       	call   800e1c <sys_page_unmap>
  801dc0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc3:	83 ec 08             	sub    $0x8,%esp
  801dc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 4c f0 ff ff       	call   800e1c <sys_page_unmap>
  801dd0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd3:	83 ec 08             	sub    $0x8,%esp
  801dd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd9:	6a 00                	push   $0x0
  801ddb:	e8 3c f0 ff ff       	call   800e1c <sys_page_unmap>
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dea:	5b                   	pop    %ebx
  801deb:	5e                   	pop    %esi
  801dec:	5d                   	pop    %ebp
  801ded:	c3                   	ret    

00801dee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df7:	50                   	push   %eax
  801df8:	ff 75 08             	pushl  0x8(%ebp)
  801dfb:	e8 30 f5 ff ff       	call   801330 <fd_lookup>
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 18                	js     801e1f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e07:	83 ec 0c             	sub    $0xc,%esp
  801e0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0d:	e8 b8 f4 ff ff       	call   8012ca <fd2data>
	return _pipeisclosed(fd, p);
  801e12:	89 c2                	mov    %eax,%edx
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	e8 21 fd ff ff       	call   801b3d <_pipeisclosed>
  801e1c:	83 c4 10             	add    $0x10,%esp
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	56                   	push   %esi
  801e25:	53                   	push   %ebx
  801e26:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e29:	85 f6                	test   %esi,%esi
  801e2b:	75 16                	jne    801e43 <wait+0x22>
  801e2d:	68 8a 2a 80 00       	push   $0x802a8a
  801e32:	68 3f 2a 80 00       	push   $0x802a3f
  801e37:	6a 09                	push   $0x9
  801e39:	68 95 2a 80 00       	push   $0x802a95
  801e3e:	e8 f3 e4 ff ff       	call   800336 <_panic>
	e = &envs[ENVX(envid)];
  801e43:	89 f0                	mov    %esi,%eax
  801e45:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e4a:	89 c2                	mov    %eax,%edx
  801e4c:	c1 e2 07             	shl    $0x7,%edx
  801e4f:	8d 9c c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%ebx
  801e56:	eb 05                	jmp    801e5d <wait+0x3c>
		sys_yield();
  801e58:	e8 1b ef ff ff       	call   800d78 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e5d:	8b 43 54             	mov    0x54(%ebx),%eax
  801e60:	39 c6                	cmp    %eax,%esi
  801e62:	75 07                	jne    801e6b <wait+0x4a>
  801e64:	8b 43 60             	mov    0x60(%ebx),%eax
  801e67:	85 c0                	test   %eax,%eax
  801e69:	75 ed                	jne    801e58 <wait+0x37>
		sys_yield();
}
  801e6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    

00801e72 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e75:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e82:	68 a0 2a 80 00       	push   $0x802aa0
  801e87:	ff 75 0c             	pushl  0xc(%ebp)
  801e8a:	e8 05 eb ff ff       	call   800994 <strcpy>
	return 0;
}
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    

00801e96 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	57                   	push   %edi
  801e9a:	56                   	push   %esi
  801e9b:	53                   	push   %ebx
  801e9c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ead:	eb 2d                	jmp    801edc <devcons_write+0x46>
		m = n - tot;
  801eaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eb2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801eb4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eb7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ebc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ebf:	83 ec 04             	sub    $0x4,%esp
  801ec2:	53                   	push   %ebx
  801ec3:	03 45 0c             	add    0xc(%ebp),%eax
  801ec6:	50                   	push   %eax
  801ec7:	57                   	push   %edi
  801ec8:	e8 59 ec ff ff       	call   800b26 <memmove>
		sys_cputs(buf, m);
  801ecd:	83 c4 08             	add    $0x8,%esp
  801ed0:	53                   	push   %ebx
  801ed1:	57                   	push   %edi
  801ed2:	e8 04 ee ff ff       	call   800cdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed7:	01 de                	add    %ebx,%esi
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	89 f0                	mov    %esi,%eax
  801ede:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ee1:	72 cc                	jb     801eaf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ee3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee6:	5b                   	pop    %ebx
  801ee7:	5e                   	pop    %esi
  801ee8:	5f                   	pop    %edi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 08             	sub    $0x8,%esp
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ef6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801efa:	74 2a                	je     801f26 <devcons_read+0x3b>
  801efc:	eb 05                	jmp    801f03 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801efe:	e8 75 ee ff ff       	call   800d78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f03:	e8 f1 ed ff ff       	call   800cf9 <sys_cgetc>
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	74 f2                	je     801efe <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 16                	js     801f26 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f10:	83 f8 04             	cmp    $0x4,%eax
  801f13:	74 0c                	je     801f21 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f15:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f18:	88 02                	mov    %al,(%edx)
	return 1;
  801f1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1f:	eb 05                	jmp    801f26 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f21:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f34:	6a 01                	push   $0x1
  801f36:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f39:	50                   	push   %eax
  801f3a:	e8 9c ed ff ff       	call   800cdb <sys_cputs>
}
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <getchar>:

int
getchar(void)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f4a:	6a 01                	push   $0x1
  801f4c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	6a 00                	push   $0x0
  801f52:	e8 3f f6 ff ff       	call   801596 <read>
	if (r < 0)
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	78 0f                	js     801f6d <getchar+0x29>
		return r;
	if (r < 1)
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	7e 06                	jle    801f68 <getchar+0x24>
		return -E_EOF;
	return c;
  801f62:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f66:	eb 05                	jmp    801f6d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f68:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f78:	50                   	push   %eax
  801f79:	ff 75 08             	pushl  0x8(%ebp)
  801f7c:	e8 af f3 ff ff       	call   801330 <fd_lookup>
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	85 c0                	test   %eax,%eax
  801f86:	78 11                	js     801f99 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f91:	39 10                	cmp    %edx,(%eax)
  801f93:	0f 94 c0             	sete   %al
  801f96:	0f b6 c0             	movzbl %al,%eax
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <opencons>:

int
opencons(void)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa4:	50                   	push   %eax
  801fa5:	e8 37 f3 ff ff       	call   8012e1 <fd_alloc>
  801faa:	83 c4 10             	add    $0x10,%esp
		return r;
  801fad:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	78 3e                	js     801ff1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb3:	83 ec 04             	sub    $0x4,%esp
  801fb6:	68 07 04 00 00       	push   $0x407
  801fbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbe:	6a 00                	push   $0x0
  801fc0:	e8 d2 ed ff ff       	call   800d97 <sys_page_alloc>
  801fc5:	83 c4 10             	add    $0x10,%esp
		return r;
  801fc8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 23                	js     801ff1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fce:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	50                   	push   %eax
  801fe7:	e8 ce f2 ff ff       	call   8012ba <fd2num>
  801fec:	89 c2                	mov    %eax,%edx
  801fee:	83 c4 10             	add    $0x10,%esp
}
  801ff1:	89 d0                	mov    %edx,%eax
  801ff3:	c9                   	leave  
  801ff4:	c3                   	ret    

00801ff5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ffb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802002:	75 2a                	jne    80202e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802004:	83 ec 04             	sub    $0x4,%esp
  802007:	6a 07                	push   $0x7
  802009:	68 00 f0 bf ee       	push   $0xeebff000
  80200e:	6a 00                	push   $0x0
  802010:	e8 82 ed ff ff       	call   800d97 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	79 12                	jns    80202e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80201c:	50                   	push   %eax
  80201d:	68 ac 2a 80 00       	push   $0x802aac
  802022:	6a 23                	push   $0x23
  802024:	68 b0 2a 80 00       	push   $0x802ab0
  802029:	e8 08 e3 ff ff       	call   800336 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80202e:	8b 45 08             	mov    0x8(%ebp),%eax
  802031:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802036:	83 ec 08             	sub    $0x8,%esp
  802039:	68 60 20 80 00       	push   $0x802060
  80203e:	6a 00                	push   $0x0
  802040:	e8 9d ee ff ff       	call   800ee2 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	85 c0                	test   %eax,%eax
  80204a:	79 12                	jns    80205e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80204c:	50                   	push   %eax
  80204d:	68 ac 2a 80 00       	push   $0x802aac
  802052:	6a 2c                	push   $0x2c
  802054:	68 b0 2a 80 00       	push   $0x802ab0
  802059:	e8 d8 e2 ff ff       	call   800336 <_panic>
	}
}
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802060:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802061:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802066:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802068:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80206b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80206f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802074:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802078:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80207a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80207d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80207e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802081:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802082:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802083:	c3                   	ret    

00802084 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	8b 75 08             	mov    0x8(%ebp),%esi
  80208c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802092:	85 c0                	test   %eax,%eax
  802094:	75 12                	jne    8020a8 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802096:	83 ec 0c             	sub    $0xc,%esp
  802099:	68 00 00 c0 ee       	push   $0xeec00000
  80209e:	e8 a4 ee ff ff       	call   800f47 <sys_ipc_recv>
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	eb 0c                	jmp    8020b4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020a8:	83 ec 0c             	sub    $0xc,%esp
  8020ab:	50                   	push   %eax
  8020ac:	e8 96 ee ff ff       	call   800f47 <sys_ipc_recv>
  8020b1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020b4:	85 f6                	test   %esi,%esi
  8020b6:	0f 95 c1             	setne  %cl
  8020b9:	85 db                	test   %ebx,%ebx
  8020bb:	0f 95 c2             	setne  %dl
  8020be:	84 d1                	test   %dl,%cl
  8020c0:	74 09                	je     8020cb <ipc_recv+0x47>
  8020c2:	89 c2                	mov    %eax,%edx
  8020c4:	c1 ea 1f             	shr    $0x1f,%edx
  8020c7:	84 d2                	test   %dl,%dl
  8020c9:	75 2a                	jne    8020f5 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020cb:	85 f6                	test   %esi,%esi
  8020cd:	74 0d                	je     8020dc <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8020da:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020dc:	85 db                	test   %ebx,%ebx
  8020de:	74 0d                	je     8020ed <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e5:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  8020eb:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f2:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  8020f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    

008020fc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	57                   	push   %edi
  802100:	56                   	push   %esi
  802101:	53                   	push   %ebx
  802102:	83 ec 0c             	sub    $0xc,%esp
  802105:	8b 7d 08             	mov    0x8(%ebp),%edi
  802108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80210b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80210e:	85 db                	test   %ebx,%ebx
  802110:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802115:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802118:	ff 75 14             	pushl  0x14(%ebp)
  80211b:	53                   	push   %ebx
  80211c:	56                   	push   %esi
  80211d:	57                   	push   %edi
  80211e:	e8 01 ee ff ff       	call   800f24 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802123:	89 c2                	mov    %eax,%edx
  802125:	c1 ea 1f             	shr    $0x1f,%edx
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	84 d2                	test   %dl,%dl
  80212d:	74 17                	je     802146 <ipc_send+0x4a>
  80212f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802132:	74 12                	je     802146 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802134:	50                   	push   %eax
  802135:	68 be 2a 80 00       	push   $0x802abe
  80213a:	6a 47                	push   $0x47
  80213c:	68 cc 2a 80 00       	push   $0x802acc
  802141:	e8 f0 e1 ff ff       	call   800336 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802146:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802149:	75 07                	jne    802152 <ipc_send+0x56>
			sys_yield();
  80214b:	e8 28 ec ff ff       	call   800d78 <sys_yield>
  802150:	eb c6                	jmp    802118 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802152:	85 c0                	test   %eax,%eax
  802154:	75 c2                	jne    802118 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802159:	5b                   	pop    %ebx
  80215a:	5e                   	pop    %esi
  80215b:	5f                   	pop    %edi
  80215c:	5d                   	pop    %ebp
  80215d:	c3                   	ret    

0080215e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802164:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802169:	89 c2                	mov    %eax,%edx
  80216b:	c1 e2 07             	shl    $0x7,%edx
  80216e:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  802175:	8b 52 5c             	mov    0x5c(%edx),%edx
  802178:	39 ca                	cmp    %ecx,%edx
  80217a:	75 11                	jne    80218d <ipc_find_env+0x2f>
			return envs[i].env_id;
  80217c:	89 c2                	mov    %eax,%edx
  80217e:	c1 e2 07             	shl    $0x7,%edx
  802181:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  802188:	8b 40 54             	mov    0x54(%eax),%eax
  80218b:	eb 0f                	jmp    80219c <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80218d:	83 c0 01             	add    $0x1,%eax
  802190:	3d 00 04 00 00       	cmp    $0x400,%eax
  802195:	75 d2                	jne    802169 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802197:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    

0080219e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a4:	89 d0                	mov    %edx,%eax
  8021a6:	c1 e8 16             	shr    $0x16,%eax
  8021a9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b5:	f6 c1 01             	test   $0x1,%cl
  8021b8:	74 1d                	je     8021d7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ba:	c1 ea 0c             	shr    $0xc,%edx
  8021bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c4:	f6 c2 01             	test   $0x1,%dl
  8021c7:	74 0e                	je     8021d7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c9:	c1 ea 0c             	shr    $0xc,%edx
  8021cc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021d3:	ef 
  8021d4:	0f b7 c0             	movzwl %ax,%eax
}
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
