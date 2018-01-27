
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
  800049:	e8 57 1c 00 00       	call   801ca5 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 8c 24 80 00       	push   $0x80248c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 95 24 80 00       	push   $0x802495
  800064:	e8 cc 02 00 00       	call   800335 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 2f 10 00 00       	call   80109d <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 a5 24 80 00       	push   $0x8024a5
  80007a:	6a 11                	push   $0x11
  80007c:	68 95 24 80 00       	push   $0x802495
  800081:	e8 af 02 00 00       	call   800335 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 7c             	mov    0x7c(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ae 24 80 00       	push   $0x8024ae
  8000a2:	e8 67 03 00 00       	call   80040e <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 a9 13 00 00       	call   80145b <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 7c             	mov    0x7c(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 cb 24 80 00       	push   $0x8024cb
  8000c6:	e8 43 03 00 00       	call   80040e <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 4c 15 00 00       	call   801628 <readn>
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
  8000f2:	e8 3e 02 00 00       	call   800335 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 2f 09 00 00       	call   800a3d <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 f1 24 80 00       	push   $0x8024f1
  80011d:	e8 ec 02 00 00       	call   80040e <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 0d 25 80 00       	push   $0x80250d
  800134:	e8 d5 02 00 00       	call   80040e <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 da 01 00 00       	call   80031b <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ae 24 80 00       	push   $0x8024ae
  80015a:	e8 af 02 00 00       	call   80040e <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 f1 12 00 00       	call   80145b <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 7c             	mov    0x7c(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 20 25 80 00       	push   $0x802520
  80017e:	e8 8b 02 00 00       	call   80040e <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 c9 07 00 00       	call   80095a <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 ce 14 00 00       	call   801671 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 a7 07 00 00       	call   80095a <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 3d 25 80 00       	push   $0x80253d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 95 24 80 00       	push   $0x802495
  8001c7:	e8 69 01 00 00       	call   800335 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 84 12 00 00       	call   80145b <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 48 1c 00 00       	call   801e2b <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 47 	movl   $0x802547,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 ad 1a 00 00       	call   801ca5 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 8c 24 80 00       	push   $0x80248c
  800207:	6a 2c                	push   $0x2c
  800209:	68 95 24 80 00       	push   $0x802495
  80020e:	e8 22 01 00 00       	call   800335 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 85 0e 00 00       	call   80109d <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 a5 24 80 00       	push   $0x8024a5
  800224:	6a 2f                	push   $0x2f
  800226:	68 95 24 80 00       	push   $0x802495
  80022b:	e8 05 01 00 00       	call   800335 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 1c 12 00 00       	call   80145b <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 54 25 80 00       	push   $0x802554
  80024a:	e8 bf 01 00 00       	call   80040e <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 56 25 80 00       	push   $0x802556
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 10 14 00 00       	call   801671 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 58 25 80 00       	push   $0x802558
  800271:	e8 98 01 00 00       	call   80040e <cprintf>
		exit();
  800276:	e8 a0 00 00 00       	call   80031b <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 d2 11 00 00       	call   80145b <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 c7 11 00 00       	call   80145b <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 8f 1b 00 00       	call   801e2b <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 75 25 80 00 	movl   $0x802575,(%esp)
  8002a3:	e8 66 01 00 00       	call   80040e <cprintf>
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
  8002bd:	e8 96 0a 00 00       	call   800d58 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8002cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002d2:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d7:	85 db                	test   %ebx,%ebx
  8002d9:	7e 07                	jle    8002e2 <libmain+0x30>
		binaryname = argv[0];
  8002db:	8b 06                	mov    (%esi),%eax
  8002dd:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
  8002e7:	e8 47 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002ec:	e8 2a 00 00 00       	call   80031b <exit>
}
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800301:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800306:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800308:	e8 4b 0a 00 00       	call   800d58 <sys_getenvid>
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	50                   	push   %eax
  800311:	e8 91 0c 00 00       	call   800fa7 <sys_thread_free>
}
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800321:	e8 60 11 00 00       	call   801486 <close_all>
	sys_env_destroy(0);
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	6a 00                	push   $0x0
  80032b:	e8 e7 09 00 00       	call   800d17 <sys_env_destroy>
}
  800330:	83 c4 10             	add    $0x10,%esp
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033d:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800343:	e8 10 0a 00 00       	call   800d58 <sys_getenvid>
  800348:	83 ec 0c             	sub    $0xc,%esp
  80034b:	ff 75 0c             	pushl  0xc(%ebp)
  80034e:	ff 75 08             	pushl  0x8(%ebp)
  800351:	56                   	push   %esi
  800352:	50                   	push   %eax
  800353:	68 d8 25 80 00       	push   $0x8025d8
  800358:	e8 b1 00 00 00       	call   80040e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035d:	83 c4 18             	add    $0x18,%esp
  800360:	53                   	push   %ebx
  800361:	ff 75 10             	pushl  0x10(%ebp)
  800364:	e8 54 00 00 00       	call   8003bd <vcprintf>
	cprintf("\n");
  800369:	c7 04 24 c9 24 80 00 	movl   $0x8024c9,(%esp)
  800370:	e8 99 00 00 00       	call   80040e <cprintf>
  800375:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800378:	cc                   	int3   
  800379:	eb fd                	jmp    800378 <_panic+0x43>

0080037b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	53                   	push   %ebx
  80037f:	83 ec 04             	sub    $0x4,%esp
  800382:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800385:	8b 13                	mov    (%ebx),%edx
  800387:	8d 42 01             	lea    0x1(%edx),%eax
  80038a:	89 03                	mov    %eax,(%ebx)
  80038c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800393:	3d ff 00 00 00       	cmp    $0xff,%eax
  800398:	75 1a                	jne    8003b4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	68 ff 00 00 00       	push   $0xff
  8003a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a5:	50                   	push   %eax
  8003a6:	e8 2f 09 00 00       	call   800cda <sys_cputs>
		b->idx = 0;
  8003ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cd:	00 00 00 
	b.cnt = 0;
  8003d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003da:	ff 75 0c             	pushl  0xc(%ebp)
  8003dd:	ff 75 08             	pushl  0x8(%ebp)
  8003e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e6:	50                   	push   %eax
  8003e7:	68 7b 03 80 00       	push   $0x80037b
  8003ec:	e8 54 01 00 00       	call   800545 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f1:	83 c4 08             	add    $0x8,%esp
  8003f4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800400:	50                   	push   %eax
  800401:	e8 d4 08 00 00       	call   800cda <sys_cputs>

	return b.cnt;
}
  800406:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800414:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800417:	50                   	push   %eax
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	e8 9d ff ff ff       	call   8003bd <vcprintf>
	va_end(ap);

	return cnt;
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    

00800422 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	57                   	push   %edi
  800426:	56                   	push   %esi
  800427:	53                   	push   %ebx
  800428:	83 ec 1c             	sub    $0x1c,%esp
  80042b:	89 c7                	mov    %eax,%edi
  80042d:	89 d6                	mov    %edx,%esi
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800438:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800443:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800446:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800449:	39 d3                	cmp    %edx,%ebx
  80044b:	72 05                	jb     800452 <printnum+0x30>
  80044d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800450:	77 45                	ja     800497 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800452:	83 ec 0c             	sub    $0xc,%esp
  800455:	ff 75 18             	pushl  0x18(%ebp)
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80045e:	53                   	push   %ebx
  80045f:	ff 75 10             	pushl  0x10(%ebp)
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	ff 75 e4             	pushl  -0x1c(%ebp)
  800468:	ff 75 e0             	pushl  -0x20(%ebp)
  80046b:	ff 75 dc             	pushl  -0x24(%ebp)
  80046e:	ff 75 d8             	pushl  -0x28(%ebp)
  800471:	e8 7a 1d 00 00       	call   8021f0 <__udivdi3>
  800476:	83 c4 18             	add    $0x18,%esp
  800479:	52                   	push   %edx
  80047a:	50                   	push   %eax
  80047b:	89 f2                	mov    %esi,%edx
  80047d:	89 f8                	mov    %edi,%eax
  80047f:	e8 9e ff ff ff       	call   800422 <printnum>
  800484:	83 c4 20             	add    $0x20,%esp
  800487:	eb 18                	jmp    8004a1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	56                   	push   %esi
  80048d:	ff 75 18             	pushl  0x18(%ebp)
  800490:	ff d7                	call   *%edi
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	eb 03                	jmp    80049a <printnum+0x78>
  800497:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80049a:	83 eb 01             	sub    $0x1,%ebx
  80049d:	85 db                	test   %ebx,%ebx
  80049f:	7f e8                	jg     800489 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	56                   	push   %esi
  8004a5:	83 ec 04             	sub    $0x4,%esp
  8004a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b4:	e8 67 1e 00 00       	call   802320 <__umoddi3>
  8004b9:	83 c4 14             	add    $0x14,%esp
  8004bc:	0f be 80 fb 25 80 00 	movsbl 0x8025fb(%eax),%eax
  8004c3:	50                   	push   %eax
  8004c4:	ff d7                	call   *%edi
}
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004cc:	5b                   	pop    %ebx
  8004cd:	5e                   	pop    %esi
  8004ce:	5f                   	pop    %edi
  8004cf:	5d                   	pop    %ebp
  8004d0:	c3                   	ret    

008004d1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d4:	83 fa 01             	cmp    $0x1,%edx
  8004d7:	7e 0e                	jle    8004e7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 02                	mov    (%edx),%eax
  8004e2:	8b 52 04             	mov    0x4(%edx),%edx
  8004e5:	eb 22                	jmp    800509 <getuint+0x38>
	else if (lflag)
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	74 10                	je     8004fb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f0:	89 08                	mov    %ecx,(%eax)
  8004f2:	8b 02                	mov    (%edx),%eax
  8004f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f9:	eb 0e                	jmp    800509 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004fb:	8b 10                	mov    (%eax),%edx
  8004fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800500:	89 08                	mov    %ecx,(%eax)
  800502:	8b 02                	mov    (%edx),%eax
  800504:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    

0080050b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800511:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800515:	8b 10                	mov    (%eax),%edx
  800517:	3b 50 04             	cmp    0x4(%eax),%edx
  80051a:	73 0a                	jae    800526 <sprintputch+0x1b>
		*b->buf++ = ch;
  80051c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80051f:	89 08                	mov    %ecx,(%eax)
  800521:	8b 45 08             	mov    0x8(%ebp),%eax
  800524:	88 02                	mov    %al,(%edx)
}
  800526:	5d                   	pop    %ebp
  800527:	c3                   	ret    

00800528 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80052e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800531:	50                   	push   %eax
  800532:	ff 75 10             	pushl  0x10(%ebp)
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	ff 75 08             	pushl  0x8(%ebp)
  80053b:	e8 05 00 00 00       	call   800545 <vprintfmt>
	va_end(ap);
}
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	57                   	push   %edi
  800549:	56                   	push   %esi
  80054a:	53                   	push   %ebx
  80054b:	83 ec 2c             	sub    $0x2c,%esp
  80054e:	8b 75 08             	mov    0x8(%ebp),%esi
  800551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800554:	8b 7d 10             	mov    0x10(%ebp),%edi
  800557:	eb 12                	jmp    80056b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800559:	85 c0                	test   %eax,%eax
  80055b:	0f 84 89 03 00 00    	je     8008ea <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	53                   	push   %ebx
  800565:	50                   	push   %eax
  800566:	ff d6                	call   *%esi
  800568:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056b:	83 c7 01             	add    $0x1,%edi
  80056e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800572:	83 f8 25             	cmp    $0x25,%eax
  800575:	75 e2                	jne    800559 <vprintfmt+0x14>
  800577:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80057b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800582:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800589:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800590:	ba 00 00 00 00       	mov    $0x0,%edx
  800595:	eb 07                	jmp    80059e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80059a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8d 47 01             	lea    0x1(%edi),%eax
  8005a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a4:	0f b6 07             	movzbl (%edi),%eax
  8005a7:	0f b6 c8             	movzbl %al,%ecx
  8005aa:	83 e8 23             	sub    $0x23,%eax
  8005ad:	3c 55                	cmp    $0x55,%al
  8005af:	0f 87 1a 03 00 00    	ja     8008cf <vprintfmt+0x38a>
  8005b5:	0f b6 c0             	movzbl %al,%eax
  8005b8:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c6:	eb d6                	jmp    80059e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005da:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005dd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e0:	83 fa 09             	cmp    $0x9,%edx
  8005e3:	77 39                	ja     80061e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e8:	eb e9                	jmp    8005d3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005fb:	eb 27                	jmp    800624 <vprintfmt+0xdf>
  8005fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800600:	85 c0                	test   %eax,%eax
  800602:	b9 00 00 00 00       	mov    $0x0,%ecx
  800607:	0f 49 c8             	cmovns %eax,%ecx
  80060a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800610:	eb 8c                	jmp    80059e <vprintfmt+0x59>
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800615:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80061c:	eb 80                	jmp    80059e <vprintfmt+0x59>
  80061e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800621:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800624:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800628:	0f 89 70 ff ff ff    	jns    80059e <vprintfmt+0x59>
				width = precision, precision = -1;
  80062e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800631:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800634:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80063b:	e9 5e ff ff ff       	jmp    80059e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800640:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800646:	e9 53 ff ff ff       	jmp    80059e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 50 04             	lea    0x4(%eax),%edx
  800651:	89 55 14             	mov    %edx,0x14(%ebp)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	ff 30                	pushl  (%eax)
  80065a:	ff d6                	call   *%esi
			break;
  80065c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800662:	e9 04 ff ff ff       	jmp    80056b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 50 04             	lea    0x4(%eax),%edx
  80066d:	89 55 14             	mov    %edx,0x14(%ebp)
  800670:	8b 00                	mov    (%eax),%eax
  800672:	99                   	cltd   
  800673:	31 d0                	xor    %edx,%eax
  800675:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800677:	83 f8 0f             	cmp    $0xf,%eax
  80067a:	7f 0b                	jg     800687 <vprintfmt+0x142>
  80067c:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800683:	85 d2                	test   %edx,%edx
  800685:	75 18                	jne    80069f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800687:	50                   	push   %eax
  800688:	68 13 26 80 00       	push   $0x802613
  80068d:	53                   	push   %ebx
  80068e:	56                   	push   %esi
  80068f:	e8 94 fe ff ff       	call   800528 <printfmt>
  800694:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80069a:	e9 cc fe ff ff       	jmp    80056b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80069f:	52                   	push   %edx
  8006a0:	68 51 2a 80 00       	push   $0x802a51
  8006a5:	53                   	push   %ebx
  8006a6:	56                   	push   %esi
  8006a7:	e8 7c fe ff ff       	call   800528 <printfmt>
  8006ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b2:	e9 b4 fe ff ff       	jmp    80056b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006c2:	85 ff                	test   %edi,%edi
  8006c4:	b8 0c 26 80 00       	mov    $0x80260c,%eax
  8006c9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d0:	0f 8e 94 00 00 00    	jle    80076a <vprintfmt+0x225>
  8006d6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006da:	0f 84 98 00 00 00    	je     800778 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006e6:	57                   	push   %edi
  8006e7:	e8 86 02 00 00       	call   800972 <strnlen>
  8006ec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ef:	29 c1                	sub    %eax,%ecx
  8006f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006f4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800701:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800703:	eb 0f                	jmp    800714 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	ff 75 e0             	pushl  -0x20(%ebp)
  80070c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070e:	83 ef 01             	sub    $0x1,%edi
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 ff                	test   %edi,%edi
  800716:	7f ed                	jg     800705 <vprintfmt+0x1c0>
  800718:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80071b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80071e:	85 c9                	test   %ecx,%ecx
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	0f 49 c1             	cmovns %ecx,%eax
  800728:	29 c1                	sub    %eax,%ecx
  80072a:	89 75 08             	mov    %esi,0x8(%ebp)
  80072d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800730:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800733:	89 cb                	mov    %ecx,%ebx
  800735:	eb 4d                	jmp    800784 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800737:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80073b:	74 1b                	je     800758 <vprintfmt+0x213>
  80073d:	0f be c0             	movsbl %al,%eax
  800740:	83 e8 20             	sub    $0x20,%eax
  800743:	83 f8 5e             	cmp    $0x5e,%eax
  800746:	76 10                	jbe    800758 <vprintfmt+0x213>
					putch('?', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	6a 3f                	push   $0x3f
  800750:	ff 55 08             	call   *0x8(%ebp)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 0d                	jmp    800765 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	ff 75 0c             	pushl  0xc(%ebp)
  80075e:	52                   	push   %edx
  80075f:	ff 55 08             	call   *0x8(%ebp)
  800762:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800765:	83 eb 01             	sub    $0x1,%ebx
  800768:	eb 1a                	jmp    800784 <vprintfmt+0x23f>
  80076a:	89 75 08             	mov    %esi,0x8(%ebp)
  80076d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800770:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800773:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800776:	eb 0c                	jmp    800784 <vprintfmt+0x23f>
  800778:	89 75 08             	mov    %esi,0x8(%ebp)
  80077b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80077e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800781:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800784:	83 c7 01             	add    $0x1,%edi
  800787:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078b:	0f be d0             	movsbl %al,%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	74 23                	je     8007b5 <vprintfmt+0x270>
  800792:	85 f6                	test   %esi,%esi
  800794:	78 a1                	js     800737 <vprintfmt+0x1f2>
  800796:	83 ee 01             	sub    $0x1,%esi
  800799:	79 9c                	jns    800737 <vprintfmt+0x1f2>
  80079b:	89 df                	mov    %ebx,%edi
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a3:	eb 18                	jmp    8007bd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	53                   	push   %ebx
  8007a9:	6a 20                	push   $0x20
  8007ab:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ad:	83 ef 01             	sub    $0x1,%edi
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	eb 08                	jmp    8007bd <vprintfmt+0x278>
  8007b5:	89 df                	mov    %ebx,%edi
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007bd:	85 ff                	test   %edi,%edi
  8007bf:	7f e4                	jg     8007a5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c4:	e9 a2 fd ff ff       	jmp    80056b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c9:	83 fa 01             	cmp    $0x1,%edx
  8007cc:	7e 16                	jle    8007e4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8d 50 08             	lea    0x8(%eax),%edx
  8007d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d7:	8b 50 04             	mov    0x4(%eax),%edx
  8007da:	8b 00                	mov    (%eax),%eax
  8007dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e2:	eb 32                	jmp    800816 <vprintfmt+0x2d1>
	else if (lflag)
  8007e4:	85 d2                	test   %edx,%edx
  8007e6:	74 18                	je     800800 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f6:	89 c1                	mov    %eax,%ecx
  8007f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007fe:	eb 16                	jmp    800816 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 00                	mov    (%eax),%eax
  80080b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080e:	89 c1                	mov    %eax,%ecx
  800810:	c1 f9 1f             	sar    $0x1f,%ecx
  800813:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800816:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800819:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800821:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800825:	79 74                	jns    80089b <vprintfmt+0x356>
				putch('-', putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	6a 2d                	push   $0x2d
  80082d:	ff d6                	call   *%esi
				num = -(long long) num;
  80082f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800832:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800835:	f7 d8                	neg    %eax
  800837:	83 d2 00             	adc    $0x0,%edx
  80083a:	f7 da                	neg    %edx
  80083c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80083f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800844:	eb 55                	jmp    80089b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 83 fc ff ff       	call   8004d1 <getuint>
			base = 10;
  80084e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800853:	eb 46                	jmp    80089b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
  800858:	e8 74 fc ff ff       	call   8004d1 <getuint>
			base = 8;
  80085d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800862:	eb 37                	jmp    80089b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 30                	push   $0x30
  80086a:	ff d6                	call   *%esi
			putch('x', putdat);
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 78                	push   $0x78
  800872:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 50 04             	lea    0x4(%eax),%edx
  80087a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087d:	8b 00                	mov    (%eax),%eax
  80087f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800884:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800887:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80088c:	eb 0d                	jmp    80089b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
  800891:	e8 3b fc ff ff       	call   8004d1 <getuint>
			base = 16;
  800896:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089b:	83 ec 0c             	sub    $0xc,%esp
  80089e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a2:	57                   	push   %edi
  8008a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a6:	51                   	push   %ecx
  8008a7:	52                   	push   %edx
  8008a8:	50                   	push   %eax
  8008a9:	89 da                	mov    %ebx,%edx
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	e8 70 fb ff ff       	call   800422 <printnum>
			break;
  8008b2:	83 c4 20             	add    $0x20,%esp
  8008b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b8:	e9 ae fc ff ff       	jmp    80056b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	51                   	push   %ecx
  8008c2:	ff d6                	call   *%esi
			break;
  8008c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ca:	e9 9c fc ff ff       	jmp    80056b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	53                   	push   %ebx
  8008d3:	6a 25                	push   $0x25
  8008d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	eb 03                	jmp    8008df <vprintfmt+0x39a>
  8008dc:	83 ef 01             	sub    $0x1,%edi
  8008df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008e3:	75 f7                	jne    8008dc <vprintfmt+0x397>
  8008e5:	e9 81 fc ff ff       	jmp    80056b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 18             	sub    $0x18,%esp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800901:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800905:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800908:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090f:	85 c0                	test   %eax,%eax
  800911:	74 26                	je     800939 <vsnprintf+0x47>
  800913:	85 d2                	test   %edx,%edx
  800915:	7e 22                	jle    800939 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800917:	ff 75 14             	pushl  0x14(%ebp)
  80091a:	ff 75 10             	pushl  0x10(%ebp)
  80091d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800920:	50                   	push   %eax
  800921:	68 0b 05 80 00       	push   $0x80050b
  800926:	e8 1a fc ff ff       	call   800545 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80092b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	eb 05                	jmp    80093e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800939:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800946:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800949:	50                   	push   %eax
  80094a:	ff 75 10             	pushl  0x10(%ebp)
  80094d:	ff 75 0c             	pushl  0xc(%ebp)
  800950:	ff 75 08             	pushl  0x8(%ebp)
  800953:	e8 9a ff ff ff       	call   8008f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
  800965:	eb 03                	jmp    80096a <strlen+0x10>
		n++;
  800967:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80096a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096e:	75 f7                	jne    800967 <strlen+0xd>
		n++;
	return n;
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	eb 03                	jmp    800985 <strnlen+0x13>
		n++;
  800982:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800985:	39 c2                	cmp    %eax,%edx
  800987:	74 08                	je     800991 <strnlen+0x1f>
  800989:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80098d:	75 f3                	jne    800982 <strnlen+0x10>
  80098f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	83 c2 01             	add    $0x1,%edx
  8009a2:	83 c1 01             	add    $0x1,%ecx
  8009a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ac:	84 db                	test   %bl,%bl
  8009ae:	75 ef                	jne    80099f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	53                   	push   %ebx
  8009b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ba:	53                   	push   %ebx
  8009bb:	e8 9a ff ff ff       	call   80095a <strlen>
  8009c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009c3:	ff 75 0c             	pushl  0xc(%ebp)
  8009c6:	01 d8                	add    %ebx,%eax
  8009c8:	50                   	push   %eax
  8009c9:	e8 c5 ff ff ff       	call   800993 <strcpy>
	return dst;
}
  8009ce:	89 d8                	mov    %ebx,%eax
  8009d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 75 08             	mov    0x8(%ebp),%esi
  8009dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e0:	89 f3                	mov    %esi,%ebx
  8009e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e5:	89 f2                	mov    %esi,%edx
  8009e7:	eb 0f                	jmp    8009f8 <strncpy+0x23>
		*dst++ = *src;
  8009e9:	83 c2 01             	add    $0x1,%edx
  8009ec:	0f b6 01             	movzbl (%ecx),%eax
  8009ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f2:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f8:	39 da                	cmp    %ebx,%edx
  8009fa:	75 ed                	jne    8009e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009fc:	89 f0                	mov    %esi,%eax
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0d:	8b 55 10             	mov    0x10(%ebp),%edx
  800a10:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a12:	85 d2                	test   %edx,%edx
  800a14:	74 21                	je     800a37 <strlcpy+0x35>
  800a16:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a1a:	89 f2                	mov    %esi,%edx
  800a1c:	eb 09                	jmp    800a27 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a1e:	83 c2 01             	add    $0x1,%edx
  800a21:	83 c1 01             	add    $0x1,%ecx
  800a24:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a27:	39 c2                	cmp    %eax,%edx
  800a29:	74 09                	je     800a34 <strlcpy+0x32>
  800a2b:	0f b6 19             	movzbl (%ecx),%ebx
  800a2e:	84 db                	test   %bl,%bl
  800a30:	75 ec                	jne    800a1e <strlcpy+0x1c>
  800a32:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a34:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a37:	29 f0                	sub    %esi,%eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a43:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a46:	eb 06                	jmp    800a4e <strcmp+0x11>
		p++, q++;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a4e:	0f b6 01             	movzbl (%ecx),%eax
  800a51:	84 c0                	test   %al,%al
  800a53:	74 04                	je     800a59 <strcmp+0x1c>
  800a55:	3a 02                	cmp    (%edx),%al
  800a57:	74 ef                	je     800a48 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a59:	0f b6 c0             	movzbl %al,%eax
  800a5c:	0f b6 12             	movzbl (%edx),%edx
  800a5f:	29 d0                	sub    %edx,%eax
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	53                   	push   %ebx
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6d:	89 c3                	mov    %eax,%ebx
  800a6f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a72:	eb 06                	jmp    800a7a <strncmp+0x17>
		n--, p++, q++;
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a7a:	39 d8                	cmp    %ebx,%eax
  800a7c:	74 15                	je     800a93 <strncmp+0x30>
  800a7e:	0f b6 08             	movzbl (%eax),%ecx
  800a81:	84 c9                	test   %cl,%cl
  800a83:	74 04                	je     800a89 <strncmp+0x26>
  800a85:	3a 0a                	cmp    (%edx),%cl
  800a87:	74 eb                	je     800a74 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a89:	0f b6 00             	movzbl (%eax),%eax
  800a8c:	0f b6 12             	movzbl (%edx),%edx
  800a8f:	29 d0                	sub    %edx,%eax
  800a91:	eb 05                	jmp    800a98 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	eb 07                	jmp    800aae <strchr+0x13>
		if (*s == c)
  800aa7:	38 ca                	cmp    %cl,%dl
  800aa9:	74 0f                	je     800aba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	0f b6 10             	movzbl (%eax),%edx
  800ab1:	84 d2                	test   %dl,%dl
  800ab3:	75 f2                	jne    800aa7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac6:	eb 03                	jmp    800acb <strfind+0xf>
  800ac8:	83 c0 01             	add    $0x1,%eax
  800acb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ace:	38 ca                	cmp    %cl,%dl
  800ad0:	74 04                	je     800ad6 <strfind+0x1a>
  800ad2:	84 d2                	test   %dl,%dl
  800ad4:	75 f2                	jne    800ac8 <strfind+0xc>
			break;
	return (char *) s;
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae4:	85 c9                	test   %ecx,%ecx
  800ae6:	74 36                	je     800b1e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aee:	75 28                	jne    800b18 <memset+0x40>
  800af0:	f6 c1 03             	test   $0x3,%cl
  800af3:	75 23                	jne    800b18 <memset+0x40>
		c &= 0xFF;
  800af5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	c1 e3 08             	shl    $0x8,%ebx
  800afe:	89 d6                	mov    %edx,%esi
  800b00:	c1 e6 18             	shl    $0x18,%esi
  800b03:	89 d0                	mov    %edx,%eax
  800b05:	c1 e0 10             	shl    $0x10,%eax
  800b08:	09 f0                	or     %esi,%eax
  800b0a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b0c:	89 d8                	mov    %ebx,%eax
  800b0e:	09 d0                	or     %edx,%eax
  800b10:	c1 e9 02             	shr    $0x2,%ecx
  800b13:	fc                   	cld    
  800b14:	f3 ab                	rep stos %eax,%es:(%edi)
  800b16:	eb 06                	jmp    800b1e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	fc                   	cld    
  800b1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1e:	89 f8                	mov    %edi,%eax
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b33:	39 c6                	cmp    %eax,%esi
  800b35:	73 35                	jae    800b6c <memmove+0x47>
  800b37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b3a:	39 d0                	cmp    %edx,%eax
  800b3c:	73 2e                	jae    800b6c <memmove+0x47>
		s += n;
		d += n;
  800b3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	89 d6                	mov    %edx,%esi
  800b43:	09 fe                	or     %edi,%esi
  800b45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4b:	75 13                	jne    800b60 <memmove+0x3b>
  800b4d:	f6 c1 03             	test   $0x3,%cl
  800b50:	75 0e                	jne    800b60 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b52:	83 ef 04             	sub    $0x4,%edi
  800b55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b58:	c1 e9 02             	shr    $0x2,%ecx
  800b5b:	fd                   	std    
  800b5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5e:	eb 09                	jmp    800b69 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b60:	83 ef 01             	sub    $0x1,%edi
  800b63:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b66:	fd                   	std    
  800b67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b69:	fc                   	cld    
  800b6a:	eb 1d                	jmp    800b89 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6c:	89 f2                	mov    %esi,%edx
  800b6e:	09 c2                	or     %eax,%edx
  800b70:	f6 c2 03             	test   $0x3,%dl
  800b73:	75 0f                	jne    800b84 <memmove+0x5f>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 0a                	jne    800b84 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b7a:	c1 e9 02             	shr    $0x2,%ecx
  800b7d:	89 c7                	mov    %eax,%edi
  800b7f:	fc                   	cld    
  800b80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b82:	eb 05                	jmp    800b89 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b84:	89 c7                	mov    %eax,%edi
  800b86:	fc                   	cld    
  800b87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b90:	ff 75 10             	pushl  0x10(%ebp)
  800b93:	ff 75 0c             	pushl  0xc(%ebp)
  800b96:	ff 75 08             	pushl  0x8(%ebp)
  800b99:	e8 87 ff ff ff       	call   800b25 <memmove>
}
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bab:	89 c6                	mov    %eax,%esi
  800bad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb0:	eb 1a                	jmp    800bcc <memcmp+0x2c>
		if (*s1 != *s2)
  800bb2:	0f b6 08             	movzbl (%eax),%ecx
  800bb5:	0f b6 1a             	movzbl (%edx),%ebx
  800bb8:	38 d9                	cmp    %bl,%cl
  800bba:	74 0a                	je     800bc6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bbc:	0f b6 c1             	movzbl %cl,%eax
  800bbf:	0f b6 db             	movzbl %bl,%ebx
  800bc2:	29 d8                	sub    %ebx,%eax
  800bc4:	eb 0f                	jmp    800bd5 <memcmp+0x35>
		s1++, s2++;
  800bc6:	83 c0 01             	add    $0x1,%eax
  800bc9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcc:	39 f0                	cmp    %esi,%eax
  800bce:	75 e2                	jne    800bb2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	53                   	push   %ebx
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be0:	89 c1                	mov    %eax,%ecx
  800be2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800be5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be9:	eb 0a                	jmp    800bf5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800beb:	0f b6 10             	movzbl (%eax),%edx
  800bee:	39 da                	cmp    %ebx,%edx
  800bf0:	74 07                	je     800bf9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf2:	83 c0 01             	add    $0x1,%eax
  800bf5:	39 c8                	cmp    %ecx,%eax
  800bf7:	72 f2                	jb     800beb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c08:	eb 03                	jmp    800c0d <strtol+0x11>
		s++;
  800c0a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0d:	0f b6 01             	movzbl (%ecx),%eax
  800c10:	3c 20                	cmp    $0x20,%al
  800c12:	74 f6                	je     800c0a <strtol+0xe>
  800c14:	3c 09                	cmp    $0x9,%al
  800c16:	74 f2                	je     800c0a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c18:	3c 2b                	cmp    $0x2b,%al
  800c1a:	75 0a                	jne    800c26 <strtol+0x2a>
		s++;
  800c1c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c24:	eb 11                	jmp    800c37 <strtol+0x3b>
  800c26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c2b:	3c 2d                	cmp    $0x2d,%al
  800c2d:	75 08                	jne    800c37 <strtol+0x3b>
		s++, neg = 1;
  800c2f:	83 c1 01             	add    $0x1,%ecx
  800c32:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c3d:	75 15                	jne    800c54 <strtol+0x58>
  800c3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c42:	75 10                	jne    800c54 <strtol+0x58>
  800c44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c48:	75 7c                	jne    800cc6 <strtol+0xca>
		s += 2, base = 16;
  800c4a:	83 c1 02             	add    $0x2,%ecx
  800c4d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c52:	eb 16                	jmp    800c6a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c54:	85 db                	test   %ebx,%ebx
  800c56:	75 12                	jne    800c6a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c58:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c60:	75 08                	jne    800c6a <strtol+0x6e>
		s++, base = 8;
  800c62:	83 c1 01             	add    $0x1,%ecx
  800c65:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c72:	0f b6 11             	movzbl (%ecx),%edx
  800c75:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c78:	89 f3                	mov    %esi,%ebx
  800c7a:	80 fb 09             	cmp    $0x9,%bl
  800c7d:	77 08                	ja     800c87 <strtol+0x8b>
			dig = *s - '0';
  800c7f:	0f be d2             	movsbl %dl,%edx
  800c82:	83 ea 30             	sub    $0x30,%edx
  800c85:	eb 22                	jmp    800ca9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c87:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c8a:	89 f3                	mov    %esi,%ebx
  800c8c:	80 fb 19             	cmp    $0x19,%bl
  800c8f:	77 08                	ja     800c99 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c91:	0f be d2             	movsbl %dl,%edx
  800c94:	83 ea 57             	sub    $0x57,%edx
  800c97:	eb 10                	jmp    800ca9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c99:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c9c:	89 f3                	mov    %esi,%ebx
  800c9e:	80 fb 19             	cmp    $0x19,%bl
  800ca1:	77 16                	ja     800cb9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ca3:	0f be d2             	movsbl %dl,%edx
  800ca6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ca9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cac:	7d 0b                	jge    800cb9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cae:	83 c1 01             	add    $0x1,%ecx
  800cb1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cb7:	eb b9                	jmp    800c72 <strtol+0x76>

	if (endptr)
  800cb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cbd:	74 0d                	je     800ccc <strtol+0xd0>
		*endptr = (char *) s;
  800cbf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc2:	89 0e                	mov    %ecx,(%esi)
  800cc4:	eb 06                	jmp    800ccc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc6:	85 db                	test   %ebx,%ebx
  800cc8:	74 98                	je     800c62 <strtol+0x66>
  800cca:	eb 9e                	jmp    800c6a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ccc:	89 c2                	mov    %eax,%edx
  800cce:	f7 da                	neg    %edx
  800cd0:	85 ff                	test   %edi,%edi
  800cd2:	0f 45 c2             	cmovne %edx,%eax
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	89 c3                	mov    %eax,%ebx
  800ced:	89 c7                	mov    %eax,%edi
  800cef:	89 c6                	mov    %eax,%esi
  800cf1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800d03:	b8 01 00 00 00       	mov    $0x1,%eax
  800d08:	89 d1                	mov    %edx,%ecx
  800d0a:	89 d3                	mov    %edx,%ebx
  800d0c:	89 d7                	mov    %edx,%edi
  800d0e:	89 d6                	mov    %edx,%esi
  800d10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d25:	b8 03 00 00 00       	mov    $0x3,%eax
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 cb                	mov    %ecx,%ebx
  800d2f:	89 cf                	mov    %ecx,%edi
  800d31:	89 ce                	mov    %ecx,%esi
  800d33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	7e 17                	jle    800d50 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	6a 03                	push   $0x3
  800d3f:	68 ff 28 80 00       	push   $0x8028ff
  800d44:	6a 23                	push   $0x23
  800d46:	68 1c 29 80 00       	push   $0x80291c
  800d4b:	e8 e5 f5 ff ff       	call   800335 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d63:	b8 02 00 00 00       	mov    $0x2,%eax
  800d68:	89 d1                	mov    %edx,%ecx
  800d6a:	89 d3                	mov    %edx,%ebx
  800d6c:	89 d7                	mov    %edx,%edi
  800d6e:	89 d6                	mov    %edx,%esi
  800d70:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_yield>:

void
sys_yield(void)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d82:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	89 d3                	mov    %edx,%ebx
  800d8b:	89 d7                	mov    %edx,%edi
  800d8d:	89 d6                	mov    %edx,%esi
  800d8f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	be 00 00 00 00       	mov    $0x0,%esi
  800da4:	b8 04 00 00 00       	mov    $0x4,%eax
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db2:	89 f7                	mov    %esi,%edi
  800db4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 17                	jle    800dd1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	50                   	push   %eax
  800dbe:	6a 04                	push   $0x4
  800dc0:	68 ff 28 80 00       	push   $0x8028ff
  800dc5:	6a 23                	push   $0x23
  800dc7:	68 1c 29 80 00       	push   $0x80291c
  800dcc:	e8 64 f5 ff ff       	call   800335 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	b8 05 00 00 00       	mov    $0x5,%eax
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df3:	8b 75 18             	mov    0x18(%ebp),%esi
  800df6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	7e 17                	jle    800e13 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	50                   	push   %eax
  800e00:	6a 05                	push   $0x5
  800e02:	68 ff 28 80 00       	push   $0x8028ff
  800e07:	6a 23                	push   $0x23
  800e09:	68 1c 29 80 00       	push   $0x80291c
  800e0e:	e8 22 f5 ff ff       	call   800335 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e29:	b8 06 00 00 00       	mov    $0x6,%eax
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	89 df                	mov    %ebx,%edi
  800e36:	89 de                	mov    %ebx,%esi
  800e38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	7e 17                	jle    800e55 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	50                   	push   %eax
  800e42:	6a 06                	push   $0x6
  800e44:	68 ff 28 80 00       	push   $0x8028ff
  800e49:	6a 23                	push   $0x23
  800e4b:	68 1c 29 80 00       	push   $0x80291c
  800e50:	e8 e0 f4 ff ff       	call   800335 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 df                	mov    %ebx,%edi
  800e78:	89 de                	mov    %ebx,%esi
  800e7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 17                	jle    800e97 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	50                   	push   %eax
  800e84:	6a 08                	push   $0x8
  800e86:	68 ff 28 80 00       	push   $0x8028ff
  800e8b:	6a 23                	push   $0x23
  800e8d:	68 1c 29 80 00       	push   $0x80291c
  800e92:	e8 9e f4 ff ff       	call   800335 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ead:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	89 df                	mov    %ebx,%edi
  800eba:	89 de                	mov    %ebx,%esi
  800ebc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	7e 17                	jle    800ed9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	83 ec 0c             	sub    $0xc,%esp
  800ec5:	50                   	push   %eax
  800ec6:	6a 09                	push   $0x9
  800ec8:	68 ff 28 80 00       	push   $0x8028ff
  800ecd:	6a 23                	push   $0x23
  800ecf:	68 1c 29 80 00       	push   $0x80291c
  800ed4:	e8 5c f4 ff ff       	call   800335 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	89 df                	mov    %ebx,%edi
  800efc:	89 de                	mov    %ebx,%esi
  800efe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	7e 17                	jle    800f1b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	50                   	push   %eax
  800f08:	6a 0a                	push   $0xa
  800f0a:	68 ff 28 80 00       	push   $0x8028ff
  800f0f:	6a 23                	push   $0x23
  800f11:	68 1c 29 80 00       	push   $0x80291c
  800f16:	e8 1a f4 ff ff       	call   800335 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f29:	be 00 00 00 00       	mov    $0x0,%esi
  800f2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f54:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	89 cb                	mov    %ecx,%ebx
  800f5e:	89 cf                	mov    %ecx,%edi
  800f60:	89 ce                	mov    %ecx,%esi
  800f62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	7e 17                	jle    800f7f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	50                   	push   %eax
  800f6c:	6a 0d                	push   $0xd
  800f6e:	68 ff 28 80 00       	push   $0x8028ff
  800f73:	6a 23                	push   $0x23
  800f75:	68 1c 29 80 00       	push   $0x80291c
  800f7a:	e8 b6 f3 ff ff       	call   800335 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f92:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f97:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9a:	89 cb                	mov    %ecx,%ebx
  800f9c:	89 cf                	mov    %ecx,%edi
  800f9e:	89 ce                	mov    %ecx,%esi
  800fa0:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800fa2:	5b                   	pop    %ebx
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fba:	89 cb                	mov    %ecx,%ebx
  800fbc:	89 cf                	mov    %ecx,%edi
  800fbe:	89 ce                	mov    %ecx,%esi
  800fc0:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5f                   	pop    %edi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fd1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800fd3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd7:	74 11                	je     800fea <pgfault+0x23>
  800fd9:	89 d8                	mov    %ebx,%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
  800fde:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe5:	f6 c4 08             	test   $0x8,%ah
  800fe8:	75 14                	jne    800ffe <pgfault+0x37>
		panic("faulting access");
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 2a 29 80 00       	push   $0x80292a
  800ff2:	6a 1e                	push   $0x1e
  800ff4:	68 3a 29 80 00       	push   $0x80293a
  800ff9:	e8 37 f3 ff ff       	call   800335 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	6a 07                	push   $0x7
  801003:	68 00 f0 7f 00       	push   $0x7ff000
  801008:	6a 00                	push   $0x0
  80100a:	e8 87 fd ff ff       	call   800d96 <sys_page_alloc>
	if (r < 0) {
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	85 c0                	test   %eax,%eax
  801014:	79 12                	jns    801028 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  801016:	50                   	push   %eax
  801017:	68 45 29 80 00       	push   $0x802945
  80101c:	6a 2c                	push   $0x2c
  80101e:	68 3a 29 80 00       	push   $0x80293a
  801023:	e8 0d f3 ff ff       	call   800335 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801028:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80102e:	83 ec 04             	sub    $0x4,%esp
  801031:	68 00 10 00 00       	push   $0x1000
  801036:	53                   	push   %ebx
  801037:	68 00 f0 7f 00       	push   $0x7ff000
  80103c:	e8 4c fb ff ff       	call   800b8d <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801041:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801048:	53                   	push   %ebx
  801049:	6a 00                	push   $0x0
  80104b:	68 00 f0 7f 00       	push   $0x7ff000
  801050:	6a 00                	push   $0x0
  801052:	e8 82 fd ff ff       	call   800dd9 <sys_page_map>
	if (r < 0) {
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	79 12                	jns    801070 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80105e:	50                   	push   %eax
  80105f:	68 45 29 80 00       	push   $0x802945
  801064:	6a 33                	push   $0x33
  801066:	68 3a 29 80 00       	push   $0x80293a
  80106b:	e8 c5 f2 ff ff       	call   800335 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	68 00 f0 7f 00       	push   $0x7ff000
  801078:	6a 00                	push   $0x0
  80107a:	e8 9c fd ff ff       	call   800e1b <sys_page_unmap>
	if (r < 0) {
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	79 12                	jns    801098 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801086:	50                   	push   %eax
  801087:	68 45 29 80 00       	push   $0x802945
  80108c:	6a 37                	push   $0x37
  80108e:	68 3a 29 80 00       	push   $0x80293a
  801093:	e8 9d f2 ff ff       	call   800335 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8010a6:	68 c7 0f 80 00       	push   $0x800fc7
  8010ab:	e8 53 0f 00 00       	call   802003 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010b0:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b5:	cd 30                	int    $0x30
  8010b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	79 17                	jns    8010d8 <fork+0x3b>
		panic("fork fault %e");
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	68 5e 29 80 00       	push   $0x80295e
  8010c9:	68 84 00 00 00       	push   $0x84
  8010ce:	68 3a 29 80 00       	push   $0x80293a
  8010d3:	e8 5d f2 ff ff       	call   800335 <_panic>
  8010d8:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8010da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010de:	75 24                	jne    801104 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e0:	e8 73 fc ff ff       	call   800d58 <sys_getenvid>
  8010e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ea:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8010f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f5:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ff:	e9 64 01 00 00       	jmp    801268 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	6a 07                	push   $0x7
  801109:	68 00 f0 bf ee       	push   $0xeebff000
  80110e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801111:	e8 80 fc ff ff       	call   800d96 <sys_page_alloc>
  801116:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801119:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80111e:	89 d8                	mov    %ebx,%eax
  801120:	c1 e8 16             	shr    $0x16,%eax
  801123:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112a:	a8 01                	test   $0x1,%al
  80112c:	0f 84 fc 00 00 00    	je     80122e <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801132:	89 d8                	mov    %ebx,%eax
  801134:	c1 e8 0c             	shr    $0xc,%eax
  801137:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	0f 84 e7 00 00 00    	je     80122e <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801147:	89 c6                	mov    %eax,%esi
  801149:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80114c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801153:	f6 c6 04             	test   $0x4,%dh
  801156:	74 39                	je     801191 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801158:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	25 07 0e 00 00       	and    $0xe07,%eax
  801167:	50                   	push   %eax
  801168:	56                   	push   %esi
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	6a 00                	push   $0x0
  80116d:	e8 67 fc ff ff       	call   800dd9 <sys_page_map>
		if (r < 0) {
  801172:	83 c4 20             	add    $0x20,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	0f 89 b1 00 00 00    	jns    80122e <fork+0x191>
		    	panic("sys page map fault %e");
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	68 6c 29 80 00       	push   $0x80296c
  801185:	6a 54                	push   $0x54
  801187:	68 3a 29 80 00       	push   $0x80293a
  80118c:	e8 a4 f1 ff ff       	call   800335 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801191:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801198:	f6 c2 02             	test   $0x2,%dl
  80119b:	75 0c                	jne    8011a9 <fork+0x10c>
  80119d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a4:	f6 c4 08             	test   $0x8,%ah
  8011a7:	74 5b                	je     801204 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	68 05 08 00 00       	push   $0x805
  8011b1:	56                   	push   %esi
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	6a 00                	push   $0x0
  8011b6:	e8 1e fc ff ff       	call   800dd9 <sys_page_map>
		if (r < 0) {
  8011bb:	83 c4 20             	add    $0x20,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	79 14                	jns    8011d6 <fork+0x139>
		    	panic("sys page map fault %e");
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	68 6c 29 80 00       	push   $0x80296c
  8011ca:	6a 5b                	push   $0x5b
  8011cc:	68 3a 29 80 00       	push   $0x80293a
  8011d1:	e8 5f f1 ff ff       	call   800335 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8011d6:	83 ec 0c             	sub    $0xc,%esp
  8011d9:	68 05 08 00 00       	push   $0x805
  8011de:	56                   	push   %esi
  8011df:	6a 00                	push   $0x0
  8011e1:	56                   	push   %esi
  8011e2:	6a 00                	push   $0x0
  8011e4:	e8 f0 fb ff ff       	call   800dd9 <sys_page_map>
		if (r < 0) {
  8011e9:	83 c4 20             	add    $0x20,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	79 3e                	jns    80122e <fork+0x191>
		    	panic("sys page map fault %e");
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	68 6c 29 80 00       	push   $0x80296c
  8011f8:	6a 5f                	push   $0x5f
  8011fa:	68 3a 29 80 00       	push   $0x80293a
  8011ff:	e8 31 f1 ff ff       	call   800335 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	6a 05                	push   $0x5
  801209:	56                   	push   %esi
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	6a 00                	push   $0x0
  80120e:	e8 c6 fb ff ff       	call   800dd9 <sys_page_map>
		if (r < 0) {
  801213:	83 c4 20             	add    $0x20,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	79 14                	jns    80122e <fork+0x191>
		    	panic("sys page map fault %e");
  80121a:	83 ec 04             	sub    $0x4,%esp
  80121d:	68 6c 29 80 00       	push   $0x80296c
  801222:	6a 64                	push   $0x64
  801224:	68 3a 29 80 00       	push   $0x80293a
  801229:	e8 07 f1 ff ff       	call   800335 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80122e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801234:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80123a:	0f 85 de fe ff ff    	jne    80111e <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801240:	a1 04 40 80 00       	mov    0x804004,%eax
  801245:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	50                   	push   %eax
  80124f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801252:	57                   	push   %edi
  801253:	e8 89 fc ff ff       	call   800ee1 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	6a 02                	push   $0x2
  80125d:	57                   	push   %edi
  80125e:	e8 fa fb ff ff       	call   800e5d <sys_env_set_status>
	
	return envid;
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126b:	5b                   	pop    %ebx
  80126c:	5e                   	pop    %esi
  80126d:	5f                   	pop    %edi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <sfork>:

envid_t
sfork(void)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801282:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	53                   	push   %ebx
  80128c:	68 84 29 80 00       	push   $0x802984
  801291:	e8 78 f1 ff ff       	call   80040e <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801296:	c7 04 24 fb 02 80 00 	movl   $0x8002fb,(%esp)
  80129d:	e8 e5 fc ff ff       	call   800f87 <sys_thread_create>
  8012a2:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8012a4:	83 c4 08             	add    $0x8,%esp
  8012a7:	53                   	push   %ebx
  8012a8:	68 84 29 80 00       	push   $0x802984
  8012ad:	e8 5c f1 ff ff       	call   80040e <cprintf>
	return id;
}
  8012b2:	89 f0                	mov    %esi,%eax
  8012b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012be:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c6:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012db:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	c1 ea 16             	shr    $0x16,%edx
  8012f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	74 11                	je     80130f <fd_alloc+0x2d>
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 ea 0c             	shr    $0xc,%edx
  801303:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130a:	f6 c2 01             	test   $0x1,%dl
  80130d:	75 09                	jne    801318 <fd_alloc+0x36>
			*fd_store = fd;
  80130f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
  801316:	eb 17                	jmp    80132f <fd_alloc+0x4d>
  801318:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801322:	75 c9                	jne    8012ed <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801324:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80132a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801337:	83 f8 1f             	cmp    $0x1f,%eax
  80133a:	77 36                	ja     801372 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133c:	c1 e0 0c             	shl    $0xc,%eax
  80133f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801344:	89 c2                	mov    %eax,%edx
  801346:	c1 ea 16             	shr    $0x16,%edx
  801349:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801350:	f6 c2 01             	test   $0x1,%dl
  801353:	74 24                	je     801379 <fd_lookup+0x48>
  801355:	89 c2                	mov    %eax,%edx
  801357:	c1 ea 0c             	shr    $0xc,%edx
  80135a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801361:	f6 c2 01             	test   $0x1,%dl
  801364:	74 1a                	je     801380 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801366:	8b 55 0c             	mov    0xc(%ebp),%edx
  801369:	89 02                	mov    %eax,(%edx)
	return 0;
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
  801370:	eb 13                	jmp    801385 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801372:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801377:	eb 0c                	jmp    801385 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801379:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137e:	eb 05                	jmp    801385 <fd_lookup+0x54>
  801380:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801390:	ba 28 2a 80 00       	mov    $0x802a28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801395:	eb 13                	jmp    8013aa <dev_lookup+0x23>
  801397:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80139a:	39 08                	cmp    %ecx,(%eax)
  80139c:	75 0c                	jne    8013aa <dev_lookup+0x23>
			*dev = devtab[i];
  80139e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a8:	eb 2e                	jmp    8013d8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013aa:	8b 02                	mov    (%edx),%eax
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	75 e7                	jne    801397 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b5:	8b 40 7c             	mov    0x7c(%eax),%eax
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	51                   	push   %ecx
  8013bc:	50                   	push   %eax
  8013bd:	68 a8 29 80 00       	push   $0x8029a8
  8013c2:	e8 47 f0 ff ff       	call   80040e <cprintf>
	*dev = 0;
  8013c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d8:	c9                   	leave  
  8013d9:	c3                   	ret    

008013da <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	83 ec 10             	sub    $0x10,%esp
  8013e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013f2:	c1 e8 0c             	shr    $0xc,%eax
  8013f5:	50                   	push   %eax
  8013f6:	e8 36 ff ff ff       	call   801331 <fd_lookup>
  8013fb:	83 c4 08             	add    $0x8,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 05                	js     801407 <fd_close+0x2d>
	    || fd != fd2)
  801402:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801405:	74 0c                	je     801413 <fd_close+0x39>
		return (must_exist ? r : 0);
  801407:	84 db                	test   %bl,%bl
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
  80140e:	0f 44 c2             	cmove  %edx,%eax
  801411:	eb 41                	jmp    801454 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	ff 36                	pushl  (%esi)
  80141c:	e8 66 ff ff ff       	call   801387 <dev_lookup>
  801421:	89 c3                	mov    %eax,%ebx
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 1a                	js     801444 <fd_close+0x6a>
		if (dev->dev_close)
  80142a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801430:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801435:	85 c0                	test   %eax,%eax
  801437:	74 0b                	je     801444 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801439:	83 ec 0c             	sub    $0xc,%esp
  80143c:	56                   	push   %esi
  80143d:	ff d0                	call   *%eax
  80143f:	89 c3                	mov    %eax,%ebx
  801441:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	56                   	push   %esi
  801448:	6a 00                	push   $0x0
  80144a:	e8 cc f9 ff ff       	call   800e1b <sys_page_unmap>
	return r;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	89 d8                	mov    %ebx,%eax
}
  801454:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801461:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	ff 75 08             	pushl  0x8(%ebp)
  801468:	e8 c4 fe ff ff       	call   801331 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 10                	js     801484 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	6a 01                	push   $0x1
  801479:	ff 75 f4             	pushl  -0xc(%ebp)
  80147c:	e8 59 ff ff ff       	call   8013da <fd_close>
  801481:	83 c4 10             	add    $0x10,%esp
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <close_all>:

void
close_all(void)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	53                   	push   %ebx
  80148a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	53                   	push   %ebx
  801496:	e8 c0 ff ff ff       	call   80145b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80149b:	83 c3 01             	add    $0x1,%ebx
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	83 fb 20             	cmp    $0x20,%ebx
  8014a4:	75 ec                	jne    801492 <close_all+0xc>
		close(i);
}
  8014a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	57                   	push   %edi
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 2c             	sub    $0x2c,%esp
  8014b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	ff 75 08             	pushl  0x8(%ebp)
  8014be:	e8 6e fe ff ff       	call   801331 <fd_lookup>
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	0f 88 c1 00 00 00    	js     80158f <dup+0xe4>
		return r;
	close(newfdnum);
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	56                   	push   %esi
  8014d2:	e8 84 ff ff ff       	call   80145b <close>

	newfd = INDEX2FD(newfdnum);
  8014d7:	89 f3                	mov    %esi,%ebx
  8014d9:	c1 e3 0c             	shl    $0xc,%ebx
  8014dc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014e2:	83 c4 04             	add    $0x4,%esp
  8014e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e8:	e8 de fd ff ff       	call   8012cb <fd2data>
  8014ed:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014ef:	89 1c 24             	mov    %ebx,(%esp)
  8014f2:	e8 d4 fd ff ff       	call   8012cb <fd2data>
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014fd:	89 f8                	mov    %edi,%eax
  8014ff:	c1 e8 16             	shr    $0x16,%eax
  801502:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801509:	a8 01                	test   $0x1,%al
  80150b:	74 37                	je     801544 <dup+0x99>
  80150d:	89 f8                	mov    %edi,%eax
  80150f:	c1 e8 0c             	shr    $0xc,%eax
  801512:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801519:	f6 c2 01             	test   $0x1,%dl
  80151c:	74 26                	je     801544 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80151e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801525:	83 ec 0c             	sub    $0xc,%esp
  801528:	25 07 0e 00 00       	and    $0xe07,%eax
  80152d:	50                   	push   %eax
  80152e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801531:	6a 00                	push   $0x0
  801533:	57                   	push   %edi
  801534:	6a 00                	push   $0x0
  801536:	e8 9e f8 ff ff       	call   800dd9 <sys_page_map>
  80153b:	89 c7                	mov    %eax,%edi
  80153d:	83 c4 20             	add    $0x20,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 2e                	js     801572 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801544:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801547:	89 d0                	mov    %edx,%eax
  801549:	c1 e8 0c             	shr    $0xc,%eax
  80154c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	25 07 0e 00 00       	and    $0xe07,%eax
  80155b:	50                   	push   %eax
  80155c:	53                   	push   %ebx
  80155d:	6a 00                	push   $0x0
  80155f:	52                   	push   %edx
  801560:	6a 00                	push   $0x0
  801562:	e8 72 f8 ff ff       	call   800dd9 <sys_page_map>
  801567:	89 c7                	mov    %eax,%edi
  801569:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80156c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156e:	85 ff                	test   %edi,%edi
  801570:	79 1d                	jns    80158f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	53                   	push   %ebx
  801576:	6a 00                	push   $0x0
  801578:	e8 9e f8 ff ff       	call   800e1b <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157d:	83 c4 08             	add    $0x8,%esp
  801580:	ff 75 d4             	pushl  -0x2c(%ebp)
  801583:	6a 00                	push   $0x0
  801585:	e8 91 f8 ff ff       	call   800e1b <sys_page_unmap>
	return r;
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	89 f8                	mov    %edi,%eax
}
  80158f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5f                   	pop    %edi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 14             	sub    $0x14,%esp
  80159e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	53                   	push   %ebx
  8015a6:	e8 86 fd ff ff       	call   801331 <fd_lookup>
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 6d                	js     801621 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	ff 30                	pushl  (%eax)
  8015c0:	e8 c2 fd ff ff       	call   801387 <dev_lookup>
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 4c                	js     801618 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015cf:	8b 42 08             	mov    0x8(%edx),%eax
  8015d2:	83 e0 03             	and    $0x3,%eax
  8015d5:	83 f8 01             	cmp    $0x1,%eax
  8015d8:	75 21                	jne    8015fb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015da:	a1 04 40 80 00       	mov    0x804004,%eax
  8015df:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015e2:	83 ec 04             	sub    $0x4,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	50                   	push   %eax
  8015e7:	68 ec 29 80 00       	push   $0x8029ec
  8015ec:	e8 1d ee ff ff       	call   80040e <cprintf>
		return -E_INVAL;
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f9:	eb 26                	jmp    801621 <read+0x8a>
	}
	if (!dev->dev_read)
  8015fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fe:	8b 40 08             	mov    0x8(%eax),%eax
  801601:	85 c0                	test   %eax,%eax
  801603:	74 17                	je     80161c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801605:	83 ec 04             	sub    $0x4,%esp
  801608:	ff 75 10             	pushl  0x10(%ebp)
  80160b:	ff 75 0c             	pushl  0xc(%ebp)
  80160e:	52                   	push   %edx
  80160f:	ff d0                	call   *%eax
  801611:	89 c2                	mov    %eax,%edx
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	eb 09                	jmp    801621 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801618:	89 c2                	mov    %eax,%edx
  80161a:	eb 05                	jmp    801621 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80161c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801621:	89 d0                	mov    %edx,%eax
  801623:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	57                   	push   %edi
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
  80162e:	83 ec 0c             	sub    $0xc,%esp
  801631:	8b 7d 08             	mov    0x8(%ebp),%edi
  801634:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801637:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163c:	eb 21                	jmp    80165f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163e:	83 ec 04             	sub    $0x4,%esp
  801641:	89 f0                	mov    %esi,%eax
  801643:	29 d8                	sub    %ebx,%eax
  801645:	50                   	push   %eax
  801646:	89 d8                	mov    %ebx,%eax
  801648:	03 45 0c             	add    0xc(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	57                   	push   %edi
  80164d:	e8 45 ff ff ff       	call   801597 <read>
		if (m < 0)
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 10                	js     801669 <readn+0x41>
			return m;
		if (m == 0)
  801659:	85 c0                	test   %eax,%eax
  80165b:	74 0a                	je     801667 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165d:	01 c3                	add    %eax,%ebx
  80165f:	39 f3                	cmp    %esi,%ebx
  801661:	72 db                	jb     80163e <readn+0x16>
  801663:	89 d8                	mov    %ebx,%eax
  801665:	eb 02                	jmp    801669 <readn+0x41>
  801667:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5f                   	pop    %edi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 14             	sub    $0x14,%esp
  801678:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	53                   	push   %ebx
  801680:	e8 ac fc ff ff       	call   801331 <fd_lookup>
  801685:	83 c4 08             	add    $0x8,%esp
  801688:	89 c2                	mov    %eax,%edx
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 68                	js     8016f6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801698:	ff 30                	pushl  (%eax)
  80169a:	e8 e8 fc ff ff       	call   801387 <dev_lookup>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 47                	js     8016ed <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ad:	75 21                	jne    8016d0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016af:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b4:	8b 40 7c             	mov    0x7c(%eax),%eax
  8016b7:	83 ec 04             	sub    $0x4,%esp
  8016ba:	53                   	push   %ebx
  8016bb:	50                   	push   %eax
  8016bc:	68 08 2a 80 00       	push   $0x802a08
  8016c1:	e8 48 ed ff ff       	call   80040e <cprintf>
		return -E_INVAL;
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ce:	eb 26                	jmp    8016f6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d6:	85 d2                	test   %edx,%edx
  8016d8:	74 17                	je     8016f1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	ff 75 10             	pushl  0x10(%ebp)
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	50                   	push   %eax
  8016e4:	ff d2                	call   *%edx
  8016e6:	89 c2                	mov    %eax,%edx
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	eb 09                	jmp    8016f6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	eb 05                	jmp    8016f6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f6:	89 d0                	mov    %edx,%eax
  8016f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <seek>:

int
seek(int fdnum, off_t offset)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801703:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801706:	50                   	push   %eax
  801707:	ff 75 08             	pushl  0x8(%ebp)
  80170a:	e8 22 fc ff ff       	call   801331 <fd_lookup>
  80170f:	83 c4 08             	add    $0x8,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	78 0e                	js     801724 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801716:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801719:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80171f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	53                   	push   %ebx
  80172a:	83 ec 14             	sub    $0x14,%esp
  80172d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801730:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801733:	50                   	push   %eax
  801734:	53                   	push   %ebx
  801735:	e8 f7 fb ff ff       	call   801331 <fd_lookup>
  80173a:	83 c4 08             	add    $0x8,%esp
  80173d:	89 c2                	mov    %eax,%edx
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 65                	js     8017a8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174d:	ff 30                	pushl  (%eax)
  80174f:	e8 33 fc ff ff       	call   801387 <dev_lookup>
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 44                	js     80179f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801762:	75 21                	jne    801785 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801764:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801769:	8b 40 7c             	mov    0x7c(%eax),%eax
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	53                   	push   %ebx
  801770:	50                   	push   %eax
  801771:	68 c8 29 80 00       	push   $0x8029c8
  801776:	e8 93 ec ff ff       	call   80040e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801783:	eb 23                	jmp    8017a8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801785:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801788:	8b 52 18             	mov    0x18(%edx),%edx
  80178b:	85 d2                	test   %edx,%edx
  80178d:	74 14                	je     8017a3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	ff 75 0c             	pushl  0xc(%ebp)
  801795:	50                   	push   %eax
  801796:	ff d2                	call   *%edx
  801798:	89 c2                	mov    %eax,%edx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	eb 09                	jmp    8017a8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	eb 05                	jmp    8017a8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a8:	89 d0                	mov    %edx,%eax
  8017aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    

008017af <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 14             	sub    $0x14,%esp
  8017b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017bc:	50                   	push   %eax
  8017bd:	ff 75 08             	pushl  0x8(%ebp)
  8017c0:	e8 6c fb ff ff       	call   801331 <fd_lookup>
  8017c5:	83 c4 08             	add    $0x8,%esp
  8017c8:	89 c2                	mov    %eax,%edx
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 58                	js     801826 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d4:	50                   	push   %eax
  8017d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d8:	ff 30                	pushl  (%eax)
  8017da:	e8 a8 fb ff ff       	call   801387 <dev_lookup>
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 37                	js     80181d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ed:	74 32                	je     801821 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ef:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f9:	00 00 00 
	stat->st_isdir = 0;
  8017fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801803:	00 00 00 
	stat->st_dev = dev;
  801806:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	53                   	push   %ebx
  801810:	ff 75 f0             	pushl  -0x10(%ebp)
  801813:	ff 50 14             	call   *0x14(%eax)
  801816:	89 c2                	mov    %eax,%edx
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	eb 09                	jmp    801826 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	eb 05                	jmp    801826 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801821:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801826:	89 d0                	mov    %edx,%eax
  801828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801832:	83 ec 08             	sub    $0x8,%esp
  801835:	6a 00                	push   $0x0
  801837:	ff 75 08             	pushl  0x8(%ebp)
  80183a:	e8 e3 01 00 00       	call   801a22 <open>
  80183f:	89 c3                	mov    %eax,%ebx
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	85 c0                	test   %eax,%eax
  801846:	78 1b                	js     801863 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	ff 75 0c             	pushl  0xc(%ebp)
  80184e:	50                   	push   %eax
  80184f:	e8 5b ff ff ff       	call   8017af <fstat>
  801854:	89 c6                	mov    %eax,%esi
	close(fd);
  801856:	89 1c 24             	mov    %ebx,(%esp)
  801859:	e8 fd fb ff ff       	call   80145b <close>
	return r;
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	89 f0                	mov    %esi,%eax
}
  801863:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	89 c6                	mov    %eax,%esi
  801871:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801873:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80187a:	75 12                	jne    80188e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	6a 01                	push   $0x1
  801881:	e8 e9 08 00 00       	call   80216f <ipc_find_env>
  801886:	a3 00 40 80 00       	mov    %eax,0x804000
  80188b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80188e:	6a 07                	push   $0x7
  801890:	68 00 50 80 00       	push   $0x805000
  801895:	56                   	push   %esi
  801896:	ff 35 00 40 80 00    	pushl  0x804000
  80189c:	e8 6c 08 00 00       	call   80210d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a1:	83 c4 0c             	add    $0xc,%esp
  8018a4:	6a 00                	push   $0x0
  8018a6:	53                   	push   %ebx
  8018a7:	6a 00                	push   $0x0
  8018a9:	e8 e4 07 00 00       	call   802092 <ipc_recv>
}
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d8:	e8 8d ff ff ff       	call   80186a <fsipc>
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018eb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018fa:	e8 6b ff ff ff       	call   80186a <fsipc>
}
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	53                   	push   %ebx
  801905:	83 ec 04             	sub    $0x4,%esp
  801908:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	8b 40 0c             	mov    0xc(%eax),%eax
  801911:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801916:	ba 00 00 00 00       	mov    $0x0,%edx
  80191b:	b8 05 00 00 00       	mov    $0x5,%eax
  801920:	e8 45 ff ff ff       	call   80186a <fsipc>
  801925:	85 c0                	test   %eax,%eax
  801927:	78 2c                	js     801955 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	68 00 50 80 00       	push   $0x805000
  801931:	53                   	push   %ebx
  801932:	e8 5c f0 ff ff       	call   800993 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801937:	a1 80 50 80 00       	mov    0x805080,%eax
  80193c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801942:	a1 84 50 80 00       	mov    0x805084,%eax
  801947:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801955:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801963:	8b 55 08             	mov    0x8(%ebp),%edx
  801966:	8b 52 0c             	mov    0xc(%edx),%edx
  801969:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80196f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801974:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801979:	0f 47 c2             	cmova  %edx,%eax
  80197c:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801981:	50                   	push   %eax
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	68 08 50 80 00       	push   $0x805008
  80198a:	e8 96 f1 ff ff       	call   800b25 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	b8 04 00 00 00       	mov    $0x4,%eax
  801999:	e8 cc fe ff ff       	call   80186a <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019b3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019be:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c3:	e8 a2 fe ff ff       	call   80186a <fsipc>
  8019c8:	89 c3                	mov    %eax,%ebx
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 4b                	js     801a19 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019ce:	39 c6                	cmp    %eax,%esi
  8019d0:	73 16                	jae    8019e8 <devfile_read+0x48>
  8019d2:	68 38 2a 80 00       	push   $0x802a38
  8019d7:	68 3f 2a 80 00       	push   $0x802a3f
  8019dc:	6a 7c                	push   $0x7c
  8019de:	68 54 2a 80 00       	push   $0x802a54
  8019e3:	e8 4d e9 ff ff       	call   800335 <_panic>
	assert(r <= PGSIZE);
  8019e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ed:	7e 16                	jle    801a05 <devfile_read+0x65>
  8019ef:	68 5f 2a 80 00       	push   $0x802a5f
  8019f4:	68 3f 2a 80 00       	push   $0x802a3f
  8019f9:	6a 7d                	push   $0x7d
  8019fb:	68 54 2a 80 00       	push   $0x802a54
  801a00:	e8 30 e9 ff ff       	call   800335 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a05:	83 ec 04             	sub    $0x4,%esp
  801a08:	50                   	push   %eax
  801a09:	68 00 50 80 00       	push   $0x805000
  801a0e:	ff 75 0c             	pushl  0xc(%ebp)
  801a11:	e8 0f f1 ff ff       	call   800b25 <memmove>
	return r;
  801a16:	83 c4 10             	add    $0x10,%esp
}
  801a19:	89 d8                	mov    %ebx,%eax
  801a1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1e:	5b                   	pop    %ebx
  801a1f:	5e                   	pop    %esi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	53                   	push   %ebx
  801a26:	83 ec 20             	sub    $0x20,%esp
  801a29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a2c:	53                   	push   %ebx
  801a2d:	e8 28 ef ff ff       	call   80095a <strlen>
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a3a:	7f 67                	jg     801aa3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a42:	50                   	push   %eax
  801a43:	e8 9a f8 ff ff       	call   8012e2 <fd_alloc>
  801a48:	83 c4 10             	add    $0x10,%esp
		return r;
  801a4b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	78 57                	js     801aa8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	53                   	push   %ebx
  801a55:	68 00 50 80 00       	push   $0x805000
  801a5a:	e8 34 ef ff ff       	call   800993 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a62:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6f:	e8 f6 fd ff ff       	call   80186a <fsipc>
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	79 14                	jns    801a91 <open+0x6f>
		fd_close(fd, 0);
  801a7d:	83 ec 08             	sub    $0x8,%esp
  801a80:	6a 00                	push   $0x0
  801a82:	ff 75 f4             	pushl  -0xc(%ebp)
  801a85:	e8 50 f9 ff ff       	call   8013da <fd_close>
		return r;
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	89 da                	mov    %ebx,%edx
  801a8f:	eb 17                	jmp    801aa8 <open+0x86>
	}

	return fd2num(fd);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	ff 75 f4             	pushl  -0xc(%ebp)
  801a97:	e8 1f f8 ff ff       	call   8012bb <fd2num>
  801a9c:	89 c2                	mov    %eax,%edx
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	eb 05                	jmp    801aa8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aa3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aa8:	89 d0                	mov    %edx,%eax
  801aaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aba:	b8 08 00 00 00       	mov    $0x8,%eax
  801abf:	e8 a6 fd ff ff       	call   80186a <fsipc>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	56                   	push   %esi
  801aca:	53                   	push   %ebx
  801acb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	ff 75 08             	pushl  0x8(%ebp)
  801ad4:	e8 f2 f7 ff ff       	call   8012cb <fd2data>
  801ad9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801adb:	83 c4 08             	add    $0x8,%esp
  801ade:	68 6b 2a 80 00       	push   $0x802a6b
  801ae3:	53                   	push   %ebx
  801ae4:	e8 aa ee ff ff       	call   800993 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ae9:	8b 46 04             	mov    0x4(%esi),%eax
  801aec:	2b 06                	sub    (%esi),%eax
  801aee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801af4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801afb:	00 00 00 
	stat->st_dev = &devpipe;
  801afe:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b05:	30 80 00 
	return 0;
}
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	53                   	push   %ebx
  801b18:	83 ec 0c             	sub    $0xc,%esp
  801b1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b1e:	53                   	push   %ebx
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 f5 f2 ff ff       	call   800e1b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b26:	89 1c 24             	mov    %ebx,(%esp)
  801b29:	e8 9d f7 ff ff       	call   8012cb <fd2data>
  801b2e:	83 c4 08             	add    $0x8,%esp
  801b31:	50                   	push   %eax
  801b32:	6a 00                	push   $0x0
  801b34:	e8 e2 f2 ff ff       	call   800e1b <sys_page_unmap>
}
  801b39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b4a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b51:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	ff 75 e0             	pushl  -0x20(%ebp)
  801b5d:	e8 4f 06 00 00       	call   8021b1 <pageref>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	89 3c 24             	mov    %edi,(%esp)
  801b67:	e8 45 06 00 00       	call   8021b1 <pageref>
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	39 c3                	cmp    %eax,%ebx
  801b71:	0f 94 c1             	sete   %cl
  801b74:	0f b6 c9             	movzbl %cl,%ecx
  801b77:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b7a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b80:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801b86:	39 ce                	cmp    %ecx,%esi
  801b88:	74 1e                	je     801ba8 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b8a:	39 c3                	cmp    %eax,%ebx
  801b8c:	75 be                	jne    801b4c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b8e:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801b94:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b97:	50                   	push   %eax
  801b98:	56                   	push   %esi
  801b99:	68 72 2a 80 00       	push   $0x802a72
  801b9e:	e8 6b e8 ff ff       	call   80040e <cprintf>
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	eb a4                	jmp    801b4c <_pipeisclosed+0xe>
	}
}
  801ba8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5f                   	pop    %edi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	57                   	push   %edi
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 28             	sub    $0x28,%esp
  801bbc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bbf:	56                   	push   %esi
  801bc0:	e8 06 f7 ff ff       	call   8012cb <fd2data>
  801bc5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	bf 00 00 00 00       	mov    $0x0,%edi
  801bcf:	eb 4b                	jmp    801c1c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bd1:	89 da                	mov    %ebx,%edx
  801bd3:	89 f0                	mov    %esi,%eax
  801bd5:	e8 64 ff ff ff       	call   801b3e <_pipeisclosed>
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	75 48                	jne    801c26 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bde:	e8 94 f1 ff ff       	call   800d77 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801be3:	8b 43 04             	mov    0x4(%ebx),%eax
  801be6:	8b 0b                	mov    (%ebx),%ecx
  801be8:	8d 51 20             	lea    0x20(%ecx),%edx
  801beb:	39 d0                	cmp    %edx,%eax
  801bed:	73 e2                	jae    801bd1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bf6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bf9:	89 c2                	mov    %eax,%edx
  801bfb:	c1 fa 1f             	sar    $0x1f,%edx
  801bfe:	89 d1                	mov    %edx,%ecx
  801c00:	c1 e9 1b             	shr    $0x1b,%ecx
  801c03:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c06:	83 e2 1f             	and    $0x1f,%edx
  801c09:	29 ca                	sub    %ecx,%edx
  801c0b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c0f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c13:	83 c0 01             	add    $0x1,%eax
  801c16:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c19:	83 c7 01             	add    $0x1,%edi
  801c1c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c1f:	75 c2                	jne    801be3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c21:	8b 45 10             	mov    0x10(%ebp),%eax
  801c24:	eb 05                	jmp    801c2b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5f                   	pop    %edi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	57                   	push   %edi
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	83 ec 18             	sub    $0x18,%esp
  801c3c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c3f:	57                   	push   %edi
  801c40:	e8 86 f6 ff ff       	call   8012cb <fd2data>
  801c45:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4f:	eb 3d                	jmp    801c8e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c51:	85 db                	test   %ebx,%ebx
  801c53:	74 04                	je     801c59 <devpipe_read+0x26>
				return i;
  801c55:	89 d8                	mov    %ebx,%eax
  801c57:	eb 44                	jmp    801c9d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c59:	89 f2                	mov    %esi,%edx
  801c5b:	89 f8                	mov    %edi,%eax
  801c5d:	e8 dc fe ff ff       	call   801b3e <_pipeisclosed>
  801c62:	85 c0                	test   %eax,%eax
  801c64:	75 32                	jne    801c98 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c66:	e8 0c f1 ff ff       	call   800d77 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c6b:	8b 06                	mov    (%esi),%eax
  801c6d:	3b 46 04             	cmp    0x4(%esi),%eax
  801c70:	74 df                	je     801c51 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c72:	99                   	cltd   
  801c73:	c1 ea 1b             	shr    $0x1b,%edx
  801c76:	01 d0                	add    %edx,%eax
  801c78:	83 e0 1f             	and    $0x1f,%eax
  801c7b:	29 d0                	sub    %edx,%eax
  801c7d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c85:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c88:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8b:	83 c3 01             	add    $0x1,%ebx
  801c8e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c91:	75 d8                	jne    801c6b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c93:	8b 45 10             	mov    0x10(%ebp),%eax
  801c96:	eb 05                	jmp    801c9d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c98:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb0:	50                   	push   %eax
  801cb1:	e8 2c f6 ff ff       	call   8012e2 <fd_alloc>
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	0f 88 2c 01 00 00    	js     801def <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc3:	83 ec 04             	sub    $0x4,%esp
  801cc6:	68 07 04 00 00       	push   $0x407
  801ccb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 c1 f0 ff ff       	call   800d96 <sys_page_alloc>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	89 c2                	mov    %eax,%edx
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	0f 88 0d 01 00 00    	js     801def <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce8:	50                   	push   %eax
  801ce9:	e8 f4 f5 ff ff       	call   8012e2 <fd_alloc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	0f 88 e2 00 00 00    	js     801ddd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfb:	83 ec 04             	sub    $0x4,%esp
  801cfe:	68 07 04 00 00       	push   $0x407
  801d03:	ff 75 f0             	pushl  -0x10(%ebp)
  801d06:	6a 00                	push   $0x0
  801d08:	e8 89 f0 ff ff       	call   800d96 <sys_page_alloc>
  801d0d:	89 c3                	mov    %eax,%ebx
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	85 c0                	test   %eax,%eax
  801d14:	0f 88 c3 00 00 00    	js     801ddd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d20:	e8 a6 f5 ff ff       	call   8012cb <fd2data>
  801d25:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 c4 0c             	add    $0xc,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	50                   	push   %eax
  801d30:	6a 00                	push   $0x0
  801d32:	e8 5f f0 ff ff       	call   800d96 <sys_page_alloc>
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	0f 88 89 00 00 00    	js     801dcd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4a:	e8 7c f5 ff ff       	call   8012cb <fd2data>
  801d4f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d56:	50                   	push   %eax
  801d57:	6a 00                	push   $0x0
  801d59:	56                   	push   %esi
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 78 f0 ff ff       	call   800dd9 <sys_page_map>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	83 c4 20             	add    $0x20,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	78 55                	js     801dbf <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d6a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d73:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d78:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d7f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d88:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d8d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d94:	83 ec 0c             	sub    $0xc,%esp
  801d97:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9a:	e8 1c f5 ff ff       	call   8012bb <fd2num>
  801d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801da4:	83 c4 04             	add    $0x4,%esp
  801da7:	ff 75 f0             	pushl  -0x10(%ebp)
  801daa:	e8 0c f5 ff ff       	call   8012bb <fd2num>
  801daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db2:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbd:	eb 30                	jmp    801def <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dbf:	83 ec 08             	sub    $0x8,%esp
  801dc2:	56                   	push   %esi
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 51 f0 ff ff       	call   800e1b <sys_page_unmap>
  801dca:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd3:	6a 00                	push   $0x0
  801dd5:	e8 41 f0 ff ff       	call   800e1b <sys_page_unmap>
  801dda:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ddd:	83 ec 08             	sub    $0x8,%esp
  801de0:	ff 75 f4             	pushl  -0xc(%ebp)
  801de3:	6a 00                	push   $0x0
  801de5:	e8 31 f0 ff ff       	call   800e1b <sys_page_unmap>
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801def:	89 d0                	mov    %edx,%eax
  801df1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e01:	50                   	push   %eax
  801e02:	ff 75 08             	pushl  0x8(%ebp)
  801e05:	e8 27 f5 ff ff       	call   801331 <fd_lookup>
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 18                	js     801e29 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e11:	83 ec 0c             	sub    $0xc,%esp
  801e14:	ff 75 f4             	pushl  -0xc(%ebp)
  801e17:	e8 af f4 ff ff       	call   8012cb <fd2data>
	return _pipeisclosed(fd, p);
  801e1c:	89 c2                	mov    %eax,%edx
  801e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e21:	e8 18 fd ff ff       	call   801b3e <_pipeisclosed>
  801e26:	83 c4 10             	add    $0x10,%esp
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e33:	85 f6                	test   %esi,%esi
  801e35:	75 16                	jne    801e4d <wait+0x22>
  801e37:	68 8a 2a 80 00       	push   $0x802a8a
  801e3c:	68 3f 2a 80 00       	push   $0x802a3f
  801e41:	6a 09                	push   $0x9
  801e43:	68 95 2a 80 00       	push   $0x802a95
  801e48:	e8 e8 e4 ff ff       	call   800335 <_panic>
	e = &envs[ENVX(envid)];
  801e4d:	89 f3                	mov    %esi,%ebx
  801e4f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e55:	69 db b0 00 00 00    	imul   $0xb0,%ebx,%ebx
  801e5b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e61:	eb 05                	jmp    801e68 <wait+0x3d>
		sys_yield();
  801e63:	e8 0f ef ff ff       	call   800d77 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e68:	8b 43 7c             	mov    0x7c(%ebx),%eax
  801e6b:	39 c6                	cmp    %eax,%esi
  801e6d:	75 0a                	jne    801e79 <wait+0x4e>
  801e6f:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
  801e75:	85 c0                	test   %eax,%eax
  801e77:	75 ea                	jne    801e63 <wait+0x38>
		sys_yield();
}
  801e79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e7c:	5b                   	pop    %ebx
  801e7d:	5e                   	pop    %esi
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    

00801e8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e90:	68 a0 2a 80 00       	push   $0x802aa0
  801e95:	ff 75 0c             	pushl  0xc(%ebp)
  801e98:	e8 f6 ea ff ff       	call   800993 <strcpy>
	return 0;
}
  801e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	57                   	push   %edi
  801ea8:	56                   	push   %esi
  801ea9:	53                   	push   %ebx
  801eaa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebb:	eb 2d                	jmp    801eea <devcons_write+0x46>
		m = n - tot;
  801ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ec2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ec5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eca:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ecd:	83 ec 04             	sub    $0x4,%esp
  801ed0:	53                   	push   %ebx
  801ed1:	03 45 0c             	add    0xc(%ebp),%eax
  801ed4:	50                   	push   %eax
  801ed5:	57                   	push   %edi
  801ed6:	e8 4a ec ff ff       	call   800b25 <memmove>
		sys_cputs(buf, m);
  801edb:	83 c4 08             	add    $0x8,%esp
  801ede:	53                   	push   %ebx
  801edf:	57                   	push   %edi
  801ee0:	e8 f5 ed ff ff       	call   800cda <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee5:	01 de                	add    %ebx,%esi
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	89 f0                	mov    %esi,%eax
  801eec:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eef:	72 cc                	jb     801ebd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ef1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5f                   	pop    %edi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 08             	sub    $0x8,%esp
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f08:	74 2a                	je     801f34 <devcons_read+0x3b>
  801f0a:	eb 05                	jmp    801f11 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f0c:	e8 66 ee ff ff       	call   800d77 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f11:	e8 e2 ed ff ff       	call   800cf8 <sys_cgetc>
  801f16:	85 c0                	test   %eax,%eax
  801f18:	74 f2                	je     801f0c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 16                	js     801f34 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f1e:	83 f8 04             	cmp    $0x4,%eax
  801f21:	74 0c                	je     801f2f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f26:	88 02                	mov    %al,(%edx)
	return 1;
  801f28:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2d:	eb 05                	jmp    801f34 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f2f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f34:	c9                   	leave  
  801f35:	c3                   	ret    

00801f36 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f42:	6a 01                	push   $0x1
  801f44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	e8 8d ed ff ff       	call   800cda <sys_cputs>
}
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <getchar>:

int
getchar(void)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f58:	6a 01                	push   $0x1
  801f5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f5d:	50                   	push   %eax
  801f5e:	6a 00                	push   $0x0
  801f60:	e8 32 f6 ff ff       	call   801597 <read>
	if (r < 0)
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 0f                	js     801f7b <getchar+0x29>
		return r;
	if (r < 1)
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	7e 06                	jle    801f76 <getchar+0x24>
		return -E_EOF;
	return c;
  801f70:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f74:	eb 05                	jmp    801f7b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f76:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	ff 75 08             	pushl  0x8(%ebp)
  801f8a:	e8 a2 f3 ff ff       	call   801331 <fd_lookup>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 11                	js     801fa7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f99:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f9f:	39 10                	cmp    %edx,(%eax)
  801fa1:	0f 94 c0             	sete   %al
  801fa4:	0f b6 c0             	movzbl %al,%eax
}
  801fa7:	c9                   	leave  
  801fa8:	c3                   	ret    

00801fa9 <opencons>:

int
opencons(void)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb2:	50                   	push   %eax
  801fb3:	e8 2a f3 ff ff       	call   8012e2 <fd_alloc>
  801fb8:	83 c4 10             	add    $0x10,%esp
		return r;
  801fbb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 3e                	js     801fff <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fc1:	83 ec 04             	sub    $0x4,%esp
  801fc4:	68 07 04 00 00       	push   $0x407
  801fc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcc:	6a 00                	push   $0x0
  801fce:	e8 c3 ed ff ff       	call   800d96 <sys_page_alloc>
  801fd3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 23                	js     801fff <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fdc:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ff1:	83 ec 0c             	sub    $0xc,%esp
  801ff4:	50                   	push   %eax
  801ff5:	e8 c1 f2 ff ff       	call   8012bb <fd2num>
  801ffa:	89 c2                	mov    %eax,%edx
  801ffc:	83 c4 10             	add    $0x10,%esp
}
  801fff:	89 d0                	mov    %edx,%eax
  802001:	c9                   	leave  
  802002:	c3                   	ret    

00802003 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802009:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802010:	75 2a                	jne    80203c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802012:	83 ec 04             	sub    $0x4,%esp
  802015:	6a 07                	push   $0x7
  802017:	68 00 f0 bf ee       	push   $0xeebff000
  80201c:	6a 00                	push   $0x0
  80201e:	e8 73 ed ff ff       	call   800d96 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	85 c0                	test   %eax,%eax
  802028:	79 12                	jns    80203c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80202a:	50                   	push   %eax
  80202b:	68 ac 2a 80 00       	push   $0x802aac
  802030:	6a 23                	push   $0x23
  802032:	68 b0 2a 80 00       	push   $0x802ab0
  802037:	e8 f9 e2 ff ff       	call   800335 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80203c:	8b 45 08             	mov    0x8(%ebp),%eax
  80203f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802044:	83 ec 08             	sub    $0x8,%esp
  802047:	68 6e 20 80 00       	push   $0x80206e
  80204c:	6a 00                	push   $0x0
  80204e:	e8 8e ee ff ff       	call   800ee1 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	79 12                	jns    80206c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80205a:	50                   	push   %eax
  80205b:	68 ac 2a 80 00       	push   $0x802aac
  802060:	6a 2c                	push   $0x2c
  802062:	68 b0 2a 80 00       	push   $0x802ab0
  802067:	e8 c9 e2 ff ff       	call   800335 <_panic>
	}
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80206e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80206f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802074:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802076:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802079:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80207d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802082:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802086:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802088:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80208b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80208c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80208f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802090:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802091:	c3                   	ret    

00802092 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	56                   	push   %esi
  802096:	53                   	push   %ebx
  802097:	8b 75 08             	mov    0x8(%ebp),%esi
  80209a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	75 12                	jne    8020b6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	68 00 00 c0 ee       	push   $0xeec00000
  8020ac:	e8 95 ee ff ff       	call   800f46 <sys_ipc_recv>
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	eb 0c                	jmp    8020c2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	50                   	push   %eax
  8020ba:	e8 87 ee ff ff       	call   800f46 <sys_ipc_recv>
  8020bf:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020c2:	85 f6                	test   %esi,%esi
  8020c4:	0f 95 c1             	setne  %cl
  8020c7:	85 db                	test   %ebx,%ebx
  8020c9:	0f 95 c2             	setne  %dl
  8020cc:	84 d1                	test   %dl,%cl
  8020ce:	74 09                	je     8020d9 <ipc_recv+0x47>
  8020d0:	89 c2                	mov    %eax,%edx
  8020d2:	c1 ea 1f             	shr    $0x1f,%edx
  8020d5:	84 d2                	test   %dl,%dl
  8020d7:	75 2d                	jne    802106 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020d9:	85 f6                	test   %esi,%esi
  8020db:	74 0d                	je     8020ea <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e2:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  8020e8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020ea:	85 db                	test   %ebx,%ebx
  8020ec:	74 0d                	je     8020fb <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  8020f9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020fb:	a1 04 40 80 00       	mov    0x804004,%eax
  802100:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802106:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802109:	5b                   	pop    %ebx
  80210a:	5e                   	pop    %esi
  80210b:	5d                   	pop    %ebp
  80210c:	c3                   	ret    

0080210d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	57                   	push   %edi
  802111:	56                   	push   %esi
  802112:	53                   	push   %ebx
  802113:	83 ec 0c             	sub    $0xc,%esp
  802116:	8b 7d 08             	mov    0x8(%ebp),%edi
  802119:	8b 75 0c             	mov    0xc(%ebp),%esi
  80211c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80211f:	85 db                	test   %ebx,%ebx
  802121:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802126:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802129:	ff 75 14             	pushl  0x14(%ebp)
  80212c:	53                   	push   %ebx
  80212d:	56                   	push   %esi
  80212e:	57                   	push   %edi
  80212f:	e8 ef ed ff ff       	call   800f23 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802134:	89 c2                	mov    %eax,%edx
  802136:	c1 ea 1f             	shr    $0x1f,%edx
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	84 d2                	test   %dl,%dl
  80213e:	74 17                	je     802157 <ipc_send+0x4a>
  802140:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802143:	74 12                	je     802157 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802145:	50                   	push   %eax
  802146:	68 be 2a 80 00       	push   $0x802abe
  80214b:	6a 47                	push   $0x47
  80214d:	68 cc 2a 80 00       	push   $0x802acc
  802152:	e8 de e1 ff ff       	call   800335 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802157:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80215a:	75 07                	jne    802163 <ipc_send+0x56>
			sys_yield();
  80215c:	e8 16 ec ff ff       	call   800d77 <sys_yield>
  802161:	eb c6                	jmp    802129 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802163:	85 c0                	test   %eax,%eax
  802165:	75 c2                	jne    802129 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216a:	5b                   	pop    %ebx
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    

0080216f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802175:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80217a:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  802180:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802186:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80218c:	39 ca                	cmp    %ecx,%edx
  80218e:	75 10                	jne    8021a0 <ipc_find_env+0x31>
			return envs[i].env_id;
  802190:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  802196:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80219b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80219e:	eb 0f                	jmp    8021af <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021a0:	83 c0 01             	add    $0x1,%eax
  8021a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a8:	75 d0                	jne    80217a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b7:	89 d0                	mov    %edx,%eax
  8021b9:	c1 e8 16             	shr    $0x16,%eax
  8021bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021c3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c8:	f6 c1 01             	test   $0x1,%cl
  8021cb:	74 1d                	je     8021ea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021cd:	c1 ea 0c             	shr    $0xc,%edx
  8021d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d7:	f6 c2 01             	test   $0x1,%dl
  8021da:	74 0e                	je     8021ea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021dc:	c1 ea 0c             	shr    $0xc,%edx
  8021df:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e6:	ef 
  8021e7:	0f b7 c0             	movzwl %ax,%eax
}
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    
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
