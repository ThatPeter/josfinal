
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
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802420,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 fc 1b 00 00       	call   801c4a <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 2c 24 80 00       	push   $0x80242c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 35 24 80 00       	push   $0x802435
  800064:	e8 f1 02 00 00       	call   80035a <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 14 10 00 00       	call   801082 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 45 24 80 00       	push   $0x802445
  80007a:	6a 11                	push   $0x11
  80007c:	68 35 24 80 00       	push   $0x802435
  800081:	e8 d4 02 00 00       	call   80035a <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 4e 24 80 00       	push   $0x80244e
  8000a2:	e8 8c 03 00 00       	call   800433 <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 57 13 00 00       	call   801409 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 6b 24 80 00       	push   $0x80246b
  8000c6:	e8 68 03 00 00       	call   800433 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 fa 14 00 00       	call   8015d6 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 88 24 80 00       	push   $0x802488
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 35 24 80 00       	push   $0x802435
  8000f2:	e8 63 02 00 00       	call   80035a <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 54 09 00 00       	call   800a62 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 91 24 80 00       	push   $0x802491
  80011d:	e8 11 03 00 00       	call   800433 <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 ad 24 80 00       	push   $0x8024ad
  800134:	e8 fa 02 00 00       	call   800433 <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 ff 01 00 00       	call   800340 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 4e 24 80 00       	push   $0x80244e
  80015a:	e8 d4 02 00 00       	call   800433 <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 9f 12 00 00       	call   801409 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 c0 24 80 00       	push   $0x8024c0
  80017e:	e8 b0 02 00 00       	call   800433 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 ee 07 00 00       	call   80097f <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 7c 14 00 00       	call   80161f <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 cc 07 00 00       	call   80097f <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 dd 24 80 00       	push   $0x8024dd
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 35 24 80 00       	push   $0x802435
  8001c7:	e8 8e 01 00 00       	call   80035a <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 32 12 00 00       	call   801409 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 ed 1b 00 00       	call   801dd0 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 e7 	movl   $0x8024e7,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 52 1a 00 00       	call   801c4a <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 2c 24 80 00       	push   $0x80242c
  800207:	6a 2c                	push   $0x2c
  800209:	68 35 24 80 00       	push   $0x802435
  80020e:	e8 47 01 00 00       	call   80035a <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 6a 0e 00 00       	call   801082 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 45 24 80 00       	push   $0x802445
  800224:	6a 2f                	push   $0x2f
  800226:	68 35 24 80 00       	push   $0x802435
  80022b:	e8 2a 01 00 00       	call   80035a <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 ca 11 00 00       	call   801409 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 f4 24 80 00       	push   $0x8024f4
  80024a:	e8 e4 01 00 00       	call   800433 <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 f6 24 80 00       	push   $0x8024f6
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 be 13 00 00       	call   80161f <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 f8 24 80 00       	push   $0x8024f8
  800271:	e8 bd 01 00 00       	call   800433 <cprintf>
		exit();
  800276:	e8 c5 00 00 00       	call   800340 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 80 11 00 00       	call   801409 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 75 11 00 00       	call   801409 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 34 1b 00 00       	call   801dd0 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  8002a3:	e8 8b 01 00 00       	call   800433 <cprintf>
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
  8002c5:	e8 b3 0a 00 00       	call   800d7d <sys_getenvid>
  8002ca:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8002d0:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8002d5:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8002df:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8002e2:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8002e8:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8002eb:	39 c8                	cmp    %ecx,%eax
  8002ed:	0f 44 fb             	cmove  %ebx,%edi
  8002f0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8002f5:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8002f8:	83 c2 01             	add    $0x1,%edx
  8002fb:	83 c3 7c             	add    $0x7c,%ebx
  8002fe:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800304:	75 d9                	jne    8002df <libmain+0x2d>
  800306:	89 f0                	mov    %esi,%eax
  800308:	84 c0                	test   %al,%al
  80030a:	74 06                	je     800312 <libmain+0x60>
  80030c:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800312:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800316:	7e 0a                	jle    800322 <libmain+0x70>
		binaryname = argv[0];
  800318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031b:	8b 00                	mov    (%eax),%eax
  80031d:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 03 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800330:	e8 0b 00 00 00       	call   800340 <exit>
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800346:	e8 e9 10 00 00       	call   801434 <close_all>
	sys_env_destroy(0);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	6a 00                	push   $0x0
  800350:	e8 e7 09 00 00       	call   800d3c <sys_env_destroy>
}
  800355:	83 c4 10             	add    $0x10,%esp
  800358:	c9                   	leave  
  800359:	c3                   	ret    

0080035a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	56                   	push   %esi
  80035e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80035f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800362:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800368:	e8 10 0a 00 00       	call   800d7d <sys_getenvid>
  80036d:	83 ec 0c             	sub    $0xc,%esp
  800370:	ff 75 0c             	pushl  0xc(%ebp)
  800373:	ff 75 08             	pushl  0x8(%ebp)
  800376:	56                   	push   %esi
  800377:	50                   	push   %eax
  800378:	68 78 25 80 00       	push   $0x802578
  80037d:	e8 b1 00 00 00       	call   800433 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800382:	83 c4 18             	add    $0x18,%esp
  800385:	53                   	push   %ebx
  800386:	ff 75 10             	pushl  0x10(%ebp)
  800389:	e8 54 00 00 00       	call   8003e2 <vcprintf>
	cprintf("\n");
  80038e:	c7 04 24 69 24 80 00 	movl   $0x802469,(%esp)
  800395:	e8 99 00 00 00       	call   800433 <cprintf>
  80039a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80039d:	cc                   	int3   
  80039e:	eb fd                	jmp    80039d <_panic+0x43>

008003a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 04             	sub    $0x4,%esp
  8003a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003aa:	8b 13                	mov    (%ebx),%edx
  8003ac:	8d 42 01             	lea    0x1(%edx),%eax
  8003af:	89 03                	mov    %eax,(%ebx)
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003bd:	75 1a                	jne    8003d9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	68 ff 00 00 00       	push   $0xff
  8003c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ca:	50                   	push   %eax
  8003cb:	e8 2f 09 00 00       	call   800cff <sys_cputs>
		b->idx = 0;
  8003d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003e0:	c9                   	leave  
  8003e1:	c3                   	ret    

008003e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003f2:	00 00 00 
	b.cnt = 0;
  8003f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ff:	ff 75 0c             	pushl  0xc(%ebp)
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040b:	50                   	push   %eax
  80040c:	68 a0 03 80 00       	push   $0x8003a0
  800411:	e8 54 01 00 00       	call   80056a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800416:	83 c4 08             	add    $0x8,%esp
  800419:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80041f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800425:	50                   	push   %eax
  800426:	e8 d4 08 00 00       	call   800cff <sys_cputs>

	return b.cnt;
}
  80042b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800431:	c9                   	leave  
  800432:	c3                   	ret    

00800433 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800439:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043c:	50                   	push   %eax
  80043d:	ff 75 08             	pushl  0x8(%ebp)
  800440:	e8 9d ff ff ff       	call   8003e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800445:	c9                   	leave  
  800446:	c3                   	ret    

00800447 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	57                   	push   %edi
  80044b:	56                   	push   %esi
  80044c:	53                   	push   %ebx
  80044d:	83 ec 1c             	sub    $0x1c,%esp
  800450:	89 c7                	mov    %eax,%edi
  800452:	89 d6                	mov    %edx,%esi
  800454:	8b 45 08             	mov    0x8(%ebp),%eax
  800457:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800460:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800463:	bb 00 00 00 00       	mov    $0x0,%ebx
  800468:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80046b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80046e:	39 d3                	cmp    %edx,%ebx
  800470:	72 05                	jb     800477 <printnum+0x30>
  800472:	39 45 10             	cmp    %eax,0x10(%ebp)
  800475:	77 45                	ja     8004bc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800477:	83 ec 0c             	sub    $0xc,%esp
  80047a:	ff 75 18             	pushl  0x18(%ebp)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800483:	53                   	push   %ebx
  800484:	ff 75 10             	pushl  0x10(%ebp)
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048d:	ff 75 e0             	pushl  -0x20(%ebp)
  800490:	ff 75 dc             	pushl  -0x24(%ebp)
  800493:	ff 75 d8             	pushl  -0x28(%ebp)
  800496:	e8 e5 1c 00 00       	call   802180 <__udivdi3>
  80049b:	83 c4 18             	add    $0x18,%esp
  80049e:	52                   	push   %edx
  80049f:	50                   	push   %eax
  8004a0:	89 f2                	mov    %esi,%edx
  8004a2:	89 f8                	mov    %edi,%eax
  8004a4:	e8 9e ff ff ff       	call   800447 <printnum>
  8004a9:	83 c4 20             	add    $0x20,%esp
  8004ac:	eb 18                	jmp    8004c6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	56                   	push   %esi
  8004b2:	ff 75 18             	pushl  0x18(%ebp)
  8004b5:	ff d7                	call   *%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	eb 03                	jmp    8004bf <printnum+0x78>
  8004bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004bf:	83 eb 01             	sub    $0x1,%ebx
  8004c2:	85 db                	test   %ebx,%ebx
  8004c4:	7f e8                	jg     8004ae <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	56                   	push   %esi
  8004ca:	83 ec 04             	sub    $0x4,%esp
  8004cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d9:	e8 d2 1d 00 00       	call   8022b0 <__umoddi3>
  8004de:	83 c4 14             	add    $0x14,%esp
  8004e1:	0f be 80 9b 25 80 00 	movsbl 0x80259b(%eax),%eax
  8004e8:	50                   	push   %eax
  8004e9:	ff d7                	call   *%edi
}
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f1:	5b                   	pop    %ebx
  8004f2:	5e                   	pop    %esi
  8004f3:	5f                   	pop    %edi
  8004f4:	5d                   	pop    %ebp
  8004f5:	c3                   	ret    

008004f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004f9:	83 fa 01             	cmp    $0x1,%edx
  8004fc:	7e 0e                	jle    80050c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	8d 4a 08             	lea    0x8(%edx),%ecx
  800503:	89 08                	mov    %ecx,(%eax)
  800505:	8b 02                	mov    (%edx),%eax
  800507:	8b 52 04             	mov    0x4(%edx),%edx
  80050a:	eb 22                	jmp    80052e <getuint+0x38>
	else if (lflag)
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 10                	je     800520 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800510:	8b 10                	mov    (%eax),%edx
  800512:	8d 4a 04             	lea    0x4(%edx),%ecx
  800515:	89 08                	mov    %ecx,(%eax)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	ba 00 00 00 00       	mov    $0x0,%edx
  80051e:	eb 0e                	jmp    80052e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800520:	8b 10                	mov    (%eax),%edx
  800522:	8d 4a 04             	lea    0x4(%edx),%ecx
  800525:	89 08                	mov    %ecx,(%eax)
  800527:	8b 02                	mov    (%edx),%eax
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800536:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	3b 50 04             	cmp    0x4(%eax),%edx
  80053f:	73 0a                	jae    80054b <sprintputch+0x1b>
		*b->buf++ = ch;
  800541:	8d 4a 01             	lea    0x1(%edx),%ecx
  800544:	89 08                	mov    %ecx,(%eax)
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	88 02                	mov    %al,(%edx)
}
  80054b:	5d                   	pop    %ebp
  80054c:	c3                   	ret    

0080054d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800553:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800556:	50                   	push   %eax
  800557:	ff 75 10             	pushl  0x10(%ebp)
  80055a:	ff 75 0c             	pushl  0xc(%ebp)
  80055d:	ff 75 08             	pushl  0x8(%ebp)
  800560:	e8 05 00 00 00       	call   80056a <vprintfmt>
	va_end(ap);
}
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	c9                   	leave  
  800569:	c3                   	ret    

0080056a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	57                   	push   %edi
  80056e:	56                   	push   %esi
  80056f:	53                   	push   %ebx
  800570:	83 ec 2c             	sub    $0x2c,%esp
  800573:	8b 75 08             	mov    0x8(%ebp),%esi
  800576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800579:	8b 7d 10             	mov    0x10(%ebp),%edi
  80057c:	eb 12                	jmp    800590 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80057e:	85 c0                	test   %eax,%eax
  800580:	0f 84 89 03 00 00    	je     80090f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	50                   	push   %eax
  80058b:	ff d6                	call   *%esi
  80058d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800590:	83 c7 01             	add    $0x1,%edi
  800593:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800597:	83 f8 25             	cmp    $0x25,%eax
  80059a:	75 e2                	jne    80057e <vprintfmt+0x14>
  80059c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ba:	eb 07                	jmp    8005c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005bf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8d 47 01             	lea    0x1(%edi),%eax
  8005c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c9:	0f b6 07             	movzbl (%edi),%eax
  8005cc:	0f b6 c8             	movzbl %al,%ecx
  8005cf:	83 e8 23             	sub    $0x23,%eax
  8005d2:	3c 55                	cmp    $0x55,%al
  8005d4:	0f 87 1a 03 00 00    	ja     8008f4 <vprintfmt+0x38a>
  8005da:	0f b6 c0             	movzbl %al,%eax
  8005dd:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005eb:	eb d6                	jmp    8005c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005fb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005ff:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800602:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800605:	83 fa 09             	cmp    $0x9,%edx
  800608:	77 39                	ja     800643 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80060a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80060d:	eb e9                	jmp    8005f8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 48 04             	lea    0x4(%eax),%ecx
  800615:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800620:	eb 27                	jmp    800649 <vprintfmt+0xdf>
  800622:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800625:	85 c0                	test   %eax,%eax
  800627:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062c:	0f 49 c8             	cmovns %eax,%ecx
  80062f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800635:	eb 8c                	jmp    8005c3 <vprintfmt+0x59>
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80063a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800641:	eb 80                	jmp    8005c3 <vprintfmt+0x59>
  800643:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800646:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800649:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064d:	0f 89 70 ff ff ff    	jns    8005c3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800653:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800656:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800659:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800660:	e9 5e ff ff ff       	jmp    8005c3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800665:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80066b:	e9 53 ff ff ff       	jmp    8005c3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	ff 30                	pushl  (%eax)
  80067f:	ff d6                	call   *%esi
			break;
  800681:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800687:	e9 04 ff ff ff       	jmp    800590 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	99                   	cltd   
  800698:	31 d0                	xor    %edx,%eax
  80069a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80069c:	83 f8 0f             	cmp    $0xf,%eax
  80069f:	7f 0b                	jg     8006ac <vprintfmt+0x142>
  8006a1:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  8006a8:	85 d2                	test   %edx,%edx
  8006aa:	75 18                	jne    8006c4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006ac:	50                   	push   %eax
  8006ad:	68 b3 25 80 00       	push   $0x8025b3
  8006b2:	53                   	push   %ebx
  8006b3:	56                   	push   %esi
  8006b4:	e8 94 fe ff ff       	call   80054d <printfmt>
  8006b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006bf:	e9 cc fe ff ff       	jmp    800590 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006c4:	52                   	push   %edx
  8006c5:	68 e1 29 80 00       	push   $0x8029e1
  8006ca:	53                   	push   %ebx
  8006cb:	56                   	push   %esi
  8006cc:	e8 7c fe ff ff       	call   80054d <printfmt>
  8006d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d7:	e9 b4 fe ff ff       	jmp    800590 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006e7:	85 ff                	test   %edi,%edi
  8006e9:	b8 ac 25 80 00       	mov    $0x8025ac,%eax
  8006ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f5:	0f 8e 94 00 00 00    	jle    80078f <vprintfmt+0x225>
  8006fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ff:	0f 84 98 00 00 00    	je     80079d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	ff 75 d0             	pushl  -0x30(%ebp)
  80070b:	57                   	push   %edi
  80070c:	e8 86 02 00 00       	call   800997 <strnlen>
  800711:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800714:	29 c1                	sub    %eax,%ecx
  800716:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800719:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80071c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800720:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800723:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800726:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800728:	eb 0f                	jmp    800739 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	ff 75 e0             	pushl  -0x20(%ebp)
  800731:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800733:	83 ef 01             	sub    $0x1,%edi
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	85 ff                	test   %edi,%edi
  80073b:	7f ed                	jg     80072a <vprintfmt+0x1c0>
  80073d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800740:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800743:	85 c9                	test   %ecx,%ecx
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	0f 49 c1             	cmovns %ecx,%eax
  80074d:	29 c1                	sub    %eax,%ecx
  80074f:	89 75 08             	mov    %esi,0x8(%ebp)
  800752:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800755:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800758:	89 cb                	mov    %ecx,%ebx
  80075a:	eb 4d                	jmp    8007a9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80075c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800760:	74 1b                	je     80077d <vprintfmt+0x213>
  800762:	0f be c0             	movsbl %al,%eax
  800765:	83 e8 20             	sub    $0x20,%eax
  800768:	83 f8 5e             	cmp    $0x5e,%eax
  80076b:	76 10                	jbe    80077d <vprintfmt+0x213>
					putch('?', putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	6a 3f                	push   $0x3f
  800775:	ff 55 08             	call   *0x8(%ebp)
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 0d                	jmp    80078a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	52                   	push   %edx
  800784:	ff 55 08             	call   *0x8(%ebp)
  800787:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078a:	83 eb 01             	sub    $0x1,%ebx
  80078d:	eb 1a                	jmp    8007a9 <vprintfmt+0x23f>
  80078f:	89 75 08             	mov    %esi,0x8(%ebp)
  800792:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800795:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800798:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80079b:	eb 0c                	jmp    8007a9 <vprintfmt+0x23f>
  80079d:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007a9:	83 c7 01             	add    $0x1,%edi
  8007ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007b0:	0f be d0             	movsbl %al,%edx
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	74 23                	je     8007da <vprintfmt+0x270>
  8007b7:	85 f6                	test   %esi,%esi
  8007b9:	78 a1                	js     80075c <vprintfmt+0x1f2>
  8007bb:	83 ee 01             	sub    $0x1,%esi
  8007be:	79 9c                	jns    80075c <vprintfmt+0x1f2>
  8007c0:	89 df                	mov    %ebx,%edi
  8007c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c8:	eb 18                	jmp    8007e2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	53                   	push   %ebx
  8007ce:	6a 20                	push   $0x20
  8007d0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d2:	83 ef 01             	sub    $0x1,%edi
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	eb 08                	jmp    8007e2 <vprintfmt+0x278>
  8007da:	89 df                	mov    %ebx,%edi
  8007dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e2:	85 ff                	test   %edi,%edi
  8007e4:	7f e4                	jg     8007ca <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e9:	e9 a2 fd ff ff       	jmp    800590 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ee:	83 fa 01             	cmp    $0x1,%edx
  8007f1:	7e 16                	jle    800809 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 50 08             	lea    0x8(%eax),%edx
  8007f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fc:	8b 50 04             	mov    0x4(%eax),%edx
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800804:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800807:	eb 32                	jmp    80083b <vprintfmt+0x2d1>
	else if (lflag)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 18                	je     800825 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80080d:	8b 45 14             	mov    0x14(%ebp),%eax
  800810:	8d 50 04             	lea    0x4(%eax),%edx
  800813:	89 55 14             	mov    %edx,0x14(%ebp)
  800816:	8b 00                	mov    (%eax),%eax
  800818:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081b:	89 c1                	mov    %eax,%ecx
  80081d:	c1 f9 1f             	sar    $0x1f,%ecx
  800820:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800823:	eb 16                	jmp    80083b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8d 50 04             	lea    0x4(%eax),%edx
  80082b:	89 55 14             	mov    %edx,0x14(%ebp)
  80082e:	8b 00                	mov    (%eax),%eax
  800830:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800833:	89 c1                	mov    %eax,%ecx
  800835:	c1 f9 1f             	sar    $0x1f,%ecx
  800838:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80083b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80083e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800841:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800846:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80084a:	79 74                	jns    8008c0 <vprintfmt+0x356>
				putch('-', putdat);
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	53                   	push   %ebx
  800850:	6a 2d                	push   $0x2d
  800852:	ff d6                	call   *%esi
				num = -(long long) num;
  800854:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800857:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80085a:	f7 d8                	neg    %eax
  80085c:	83 d2 00             	adc    $0x0,%edx
  80085f:	f7 da                	neg    %edx
  800861:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800864:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800869:	eb 55                	jmp    8008c0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	e8 83 fc ff ff       	call   8004f6 <getuint>
			base = 10;
  800873:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800878:	eb 46                	jmp    8008c0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80087a:	8d 45 14             	lea    0x14(%ebp),%eax
  80087d:	e8 74 fc ff ff       	call   8004f6 <getuint>
			base = 8;
  800882:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800887:	eb 37                	jmp    8008c0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	6a 30                	push   $0x30
  80088f:	ff d6                	call   *%esi
			putch('x', putdat);
  800891:	83 c4 08             	add    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	6a 78                	push   $0x78
  800897:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8d 50 04             	lea    0x4(%eax),%edx
  80089f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008a2:	8b 00                	mov    (%eax),%eax
  8008a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008b1:	eb 0d                	jmp    8008c0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b6:	e8 3b fc ff ff       	call   8004f6 <getuint>
			base = 16;
  8008bb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008c0:	83 ec 0c             	sub    $0xc,%esp
  8008c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008c7:	57                   	push   %edi
  8008c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008cb:	51                   	push   %ecx
  8008cc:	52                   	push   %edx
  8008cd:	50                   	push   %eax
  8008ce:	89 da                	mov    %ebx,%edx
  8008d0:	89 f0                	mov    %esi,%eax
  8008d2:	e8 70 fb ff ff       	call   800447 <printnum>
			break;
  8008d7:	83 c4 20             	add    $0x20,%esp
  8008da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008dd:	e9 ae fc ff ff       	jmp    800590 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	51                   	push   %ecx
  8008e7:	ff d6                	call   *%esi
			break;
  8008e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ef:	e9 9c fc ff ff       	jmp    800590 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	53                   	push   %ebx
  8008f8:	6a 25                	push   $0x25
  8008fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	eb 03                	jmp    800904 <vprintfmt+0x39a>
  800901:	83 ef 01             	sub    $0x1,%edi
  800904:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800908:	75 f7                	jne    800901 <vprintfmt+0x397>
  80090a:	e9 81 fc ff ff       	jmp    800590 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80090f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 18             	sub    $0x18,%esp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800923:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800926:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800934:	85 c0                	test   %eax,%eax
  800936:	74 26                	je     80095e <vsnprintf+0x47>
  800938:	85 d2                	test   %edx,%edx
  80093a:	7e 22                	jle    80095e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093c:	ff 75 14             	pushl  0x14(%ebp)
  80093f:	ff 75 10             	pushl  0x10(%ebp)
  800942:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800945:	50                   	push   %eax
  800946:	68 30 05 80 00       	push   $0x800530
  80094b:	e8 1a fc ff ff       	call   80056a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800950:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800953:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	eb 05                	jmp    800963 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096e:	50                   	push   %eax
  80096f:	ff 75 10             	pushl  0x10(%ebp)
  800972:	ff 75 0c             	pushl  0xc(%ebp)
  800975:	ff 75 08             	pushl  0x8(%ebp)
  800978:	e8 9a ff ff ff       	call   800917 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
  80098a:	eb 03                	jmp    80098f <strlen+0x10>
		n++;
  80098c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80098f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800993:	75 f7                	jne    80098c <strlen+0xd>
		n++;
	return n;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a5:	eb 03                	jmp    8009aa <strnlen+0x13>
		n++;
  8009a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009aa:	39 c2                	cmp    %eax,%edx
  8009ac:	74 08                	je     8009b6 <strnlen+0x1f>
  8009ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009b2:	75 f3                	jne    8009a7 <strnlen+0x10>
  8009b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c2:	89 c2                	mov    %eax,%edx
  8009c4:	83 c2 01             	add    $0x1,%edx
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d1:	84 db                	test   %bl,%bl
  8009d3:	75 ef                	jne    8009c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	53                   	push   %ebx
  8009dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009df:	53                   	push   %ebx
  8009e0:	e8 9a ff ff ff       	call   80097f <strlen>
  8009e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009e8:	ff 75 0c             	pushl  0xc(%ebp)
  8009eb:	01 d8                	add    %ebx,%eax
  8009ed:	50                   	push   %eax
  8009ee:	e8 c5 ff ff ff       	call   8009b8 <strcpy>
	return dst;
}
  8009f3:	89 d8                	mov    %ebx,%eax
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a05:	89 f3                	mov    %esi,%ebx
  800a07:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0a:	89 f2                	mov    %esi,%edx
  800a0c:	eb 0f                	jmp    800a1d <strncpy+0x23>
		*dst++ = *src;
  800a0e:	83 c2 01             	add    $0x1,%edx
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a17:	80 39 01             	cmpb   $0x1,(%ecx)
  800a1a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1d:	39 da                	cmp    %ebx,%edx
  800a1f:	75 ed                	jne    800a0e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a21:	89 f0                	mov    %esi,%eax
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a32:	8b 55 10             	mov    0x10(%ebp),%edx
  800a35:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a37:	85 d2                	test   %edx,%edx
  800a39:	74 21                	je     800a5c <strlcpy+0x35>
  800a3b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a3f:	89 f2                	mov    %esi,%edx
  800a41:	eb 09                	jmp    800a4c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a43:	83 c2 01             	add    $0x1,%edx
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a4c:	39 c2                	cmp    %eax,%edx
  800a4e:	74 09                	je     800a59 <strlcpy+0x32>
  800a50:	0f b6 19             	movzbl (%ecx),%ebx
  800a53:	84 db                	test   %bl,%bl
  800a55:	75 ec                	jne    800a43 <strlcpy+0x1c>
  800a57:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a59:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5c:	29 f0                	sub    %esi,%eax
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a68:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6b:	eb 06                	jmp    800a73 <strcmp+0x11>
		p++, q++;
  800a6d:	83 c1 01             	add    $0x1,%ecx
  800a70:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a73:	0f b6 01             	movzbl (%ecx),%eax
  800a76:	84 c0                	test   %al,%al
  800a78:	74 04                	je     800a7e <strcmp+0x1c>
  800a7a:	3a 02                	cmp    (%edx),%al
  800a7c:	74 ef                	je     800a6d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7e:	0f b6 c0             	movzbl %al,%eax
  800a81:	0f b6 12             	movzbl (%edx),%edx
  800a84:	29 d0                	sub    %edx,%eax
}
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a97:	eb 06                	jmp    800a9f <strncmp+0x17>
		n--, p++, q++;
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9f:	39 d8                	cmp    %ebx,%eax
  800aa1:	74 15                	je     800ab8 <strncmp+0x30>
  800aa3:	0f b6 08             	movzbl (%eax),%ecx
  800aa6:	84 c9                	test   %cl,%cl
  800aa8:	74 04                	je     800aae <strncmp+0x26>
  800aaa:	3a 0a                	cmp    (%edx),%cl
  800aac:	74 eb                	je     800a99 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aae:	0f b6 00             	movzbl (%eax),%eax
  800ab1:	0f b6 12             	movzbl (%edx),%edx
  800ab4:	29 d0                	sub    %edx,%eax
  800ab6:	eb 05                	jmp    800abd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aca:	eb 07                	jmp    800ad3 <strchr+0x13>
		if (*s == c)
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	74 0f                	je     800adf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	0f b6 10             	movzbl (%eax),%edx
  800ad6:	84 d2                	test   %dl,%dl
  800ad8:	75 f2                	jne    800acc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aeb:	eb 03                	jmp    800af0 <strfind+0xf>
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af3:	38 ca                	cmp    %cl,%dl
  800af5:	74 04                	je     800afb <strfind+0x1a>
  800af7:	84 d2                	test   %dl,%dl
  800af9:	75 f2                	jne    800aed <strfind+0xc>
			break;
	return (char *) s;
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b09:	85 c9                	test   %ecx,%ecx
  800b0b:	74 36                	je     800b43 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b13:	75 28                	jne    800b3d <memset+0x40>
  800b15:	f6 c1 03             	test   $0x3,%cl
  800b18:	75 23                	jne    800b3d <memset+0x40>
		c &= 0xFF;
  800b1a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1e:	89 d3                	mov    %edx,%ebx
  800b20:	c1 e3 08             	shl    $0x8,%ebx
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	c1 e6 18             	shl    $0x18,%esi
  800b28:	89 d0                	mov    %edx,%eax
  800b2a:	c1 e0 10             	shl    $0x10,%eax
  800b2d:	09 f0                	or     %esi,%eax
  800b2f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b31:	89 d8                	mov    %ebx,%eax
  800b33:	09 d0                	or     %edx,%eax
  800b35:	c1 e9 02             	shr    $0x2,%ecx
  800b38:	fc                   	cld    
  800b39:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3b:	eb 06                	jmp    800b43 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b40:	fc                   	cld    
  800b41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b43:	89 f8                	mov    %edi,%eax
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b58:	39 c6                	cmp    %eax,%esi
  800b5a:	73 35                	jae    800b91 <memmove+0x47>
  800b5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5f:	39 d0                	cmp    %edx,%eax
  800b61:	73 2e                	jae    800b91 <memmove+0x47>
		s += n;
		d += n;
  800b63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	09 fe                	or     %edi,%esi
  800b6a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b70:	75 13                	jne    800b85 <memmove+0x3b>
  800b72:	f6 c1 03             	test   $0x3,%cl
  800b75:	75 0e                	jne    800b85 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b77:	83 ef 04             	sub    $0x4,%edi
  800b7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7d:	c1 e9 02             	shr    $0x2,%ecx
  800b80:	fd                   	std    
  800b81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b83:	eb 09                	jmp    800b8e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b85:	83 ef 01             	sub    $0x1,%edi
  800b88:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b8b:	fd                   	std    
  800b8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8e:	fc                   	cld    
  800b8f:	eb 1d                	jmp    800bae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b91:	89 f2                	mov    %esi,%edx
  800b93:	09 c2                	or     %eax,%edx
  800b95:	f6 c2 03             	test   $0x3,%dl
  800b98:	75 0f                	jne    800ba9 <memmove+0x5f>
  800b9a:	f6 c1 03             	test   $0x3,%cl
  800b9d:	75 0a                	jne    800ba9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b9f:	c1 e9 02             	shr    $0x2,%ecx
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	fc                   	cld    
  800ba5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba7:	eb 05                	jmp    800bae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	fc                   	cld    
  800bac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb5:	ff 75 10             	pushl  0x10(%ebp)
  800bb8:	ff 75 0c             	pushl  0xc(%ebp)
  800bbb:	ff 75 08             	pushl  0x8(%ebp)
  800bbe:	e8 87 ff ff ff       	call   800b4a <memmove>
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd0:	89 c6                	mov    %eax,%esi
  800bd2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd5:	eb 1a                	jmp    800bf1 <memcmp+0x2c>
		if (*s1 != *s2)
  800bd7:	0f b6 08             	movzbl (%eax),%ecx
  800bda:	0f b6 1a             	movzbl (%edx),%ebx
  800bdd:	38 d9                	cmp    %bl,%cl
  800bdf:	74 0a                	je     800beb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be1:	0f b6 c1             	movzbl %cl,%eax
  800be4:	0f b6 db             	movzbl %bl,%ebx
  800be7:	29 d8                	sub    %ebx,%eax
  800be9:	eb 0f                	jmp    800bfa <memcmp+0x35>
		s1++, s2++;
  800beb:	83 c0 01             	add    $0x1,%eax
  800bee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf1:	39 f0                	cmp    %esi,%eax
  800bf3:	75 e2                	jne    800bd7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	53                   	push   %ebx
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c05:	89 c1                	mov    %eax,%ecx
  800c07:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0e:	eb 0a                	jmp    800c1a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c10:	0f b6 10             	movzbl (%eax),%edx
  800c13:	39 da                	cmp    %ebx,%edx
  800c15:	74 07                	je     800c1e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c17:	83 c0 01             	add    $0x1,%eax
  800c1a:	39 c8                	cmp    %ecx,%eax
  800c1c:	72 f2                	jb     800c10 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2d:	eb 03                	jmp    800c32 <strtol+0x11>
		s++;
  800c2f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c32:	0f b6 01             	movzbl (%ecx),%eax
  800c35:	3c 20                	cmp    $0x20,%al
  800c37:	74 f6                	je     800c2f <strtol+0xe>
  800c39:	3c 09                	cmp    $0x9,%al
  800c3b:	74 f2                	je     800c2f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3d:	3c 2b                	cmp    $0x2b,%al
  800c3f:	75 0a                	jne    800c4b <strtol+0x2a>
		s++;
  800c41:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c44:	bf 00 00 00 00       	mov    $0x0,%edi
  800c49:	eb 11                	jmp    800c5c <strtol+0x3b>
  800c4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c50:	3c 2d                	cmp    $0x2d,%al
  800c52:	75 08                	jne    800c5c <strtol+0x3b>
		s++, neg = 1;
  800c54:	83 c1 01             	add    $0x1,%ecx
  800c57:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c62:	75 15                	jne    800c79 <strtol+0x58>
  800c64:	80 39 30             	cmpb   $0x30,(%ecx)
  800c67:	75 10                	jne    800c79 <strtol+0x58>
  800c69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c6d:	75 7c                	jne    800ceb <strtol+0xca>
		s += 2, base = 16;
  800c6f:	83 c1 02             	add    $0x2,%ecx
  800c72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c77:	eb 16                	jmp    800c8f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c79:	85 db                	test   %ebx,%ebx
  800c7b:	75 12                	jne    800c8f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c82:	80 39 30             	cmpb   $0x30,(%ecx)
  800c85:	75 08                	jne    800c8f <strtol+0x6e>
		s++, base = 8;
  800c87:	83 c1 01             	add    $0x1,%ecx
  800c8a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c97:	0f b6 11             	movzbl (%ecx),%edx
  800c9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c9d:	89 f3                	mov    %esi,%ebx
  800c9f:	80 fb 09             	cmp    $0x9,%bl
  800ca2:	77 08                	ja     800cac <strtol+0x8b>
			dig = *s - '0';
  800ca4:	0f be d2             	movsbl %dl,%edx
  800ca7:	83 ea 30             	sub    $0x30,%edx
  800caa:	eb 22                	jmp    800cce <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800caf:	89 f3                	mov    %esi,%ebx
  800cb1:	80 fb 19             	cmp    $0x19,%bl
  800cb4:	77 08                	ja     800cbe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb6:	0f be d2             	movsbl %dl,%edx
  800cb9:	83 ea 57             	sub    $0x57,%edx
  800cbc:	eb 10                	jmp    800cce <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cbe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc1:	89 f3                	mov    %esi,%ebx
  800cc3:	80 fb 19             	cmp    $0x19,%bl
  800cc6:	77 16                	ja     800cde <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cc8:	0f be d2             	movsbl %dl,%edx
  800ccb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cce:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd1:	7d 0b                	jge    800cde <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cd3:	83 c1 01             	add    $0x1,%ecx
  800cd6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cda:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cdc:	eb b9                	jmp    800c97 <strtol+0x76>

	if (endptr)
  800cde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce2:	74 0d                	je     800cf1 <strtol+0xd0>
		*endptr = (char *) s;
  800ce4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce7:	89 0e                	mov    %ecx,(%esi)
  800ce9:	eb 06                	jmp    800cf1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ceb:	85 db                	test   %ebx,%ebx
  800ced:	74 98                	je     800c87 <strtol+0x66>
  800cef:	eb 9e                	jmp    800c8f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cf1:	89 c2                	mov    %eax,%edx
  800cf3:	f7 da                	neg    %edx
  800cf5:	85 ff                	test   %edi,%edi
  800cf7:	0f 45 c2             	cmovne %edx,%eax
}
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 c3                	mov    %eax,%ebx
  800d12:	89 c7                	mov    %eax,%edi
  800d14:	89 c6                	mov    %eax,%esi
  800d16:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_cgetc>:

int
sys_cgetc(void)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	ba 00 00 00 00       	mov    $0x0,%edx
  800d28:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2d:	89 d1                	mov    %edx,%ecx
  800d2f:	89 d3                	mov    %edx,%ebx
  800d31:	89 d7                	mov    %edx,%edi
  800d33:	89 d6                	mov    %edx,%esi
  800d35:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	89 cb                	mov    %ecx,%ebx
  800d54:	89 cf                	mov    %ecx,%edi
  800d56:	89 ce                	mov    %ecx,%esi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 03                	push   $0x3
  800d64:	68 9f 28 80 00       	push   $0x80289f
  800d69:	6a 23                	push   $0x23
  800d6b:	68 bc 28 80 00       	push   $0x8028bc
  800d70:	e8 e5 f5 ff ff       	call   80035a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	ba 00 00 00 00       	mov    $0x0,%edx
  800d88:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8d:	89 d1                	mov    %edx,%ecx
  800d8f:	89 d3                	mov    %edx,%ebx
  800d91:	89 d7                	mov    %edx,%edi
  800d93:	89 d6                	mov    %edx,%esi
  800d95:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_yield>:

void
sys_yield(void)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da2:	ba 00 00 00 00       	mov    $0x0,%edx
  800da7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dac:	89 d1                	mov    %edx,%ecx
  800dae:	89 d3                	mov    %edx,%ebx
  800db0:	89 d7                	mov    %edx,%edi
  800db2:	89 d6                	mov    %edx,%esi
  800db4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	be 00 00 00 00       	mov    $0x0,%esi
  800dc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd7:	89 f7                	mov    %esi,%edi
  800dd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7e 17                	jle    800df6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	50                   	push   %eax
  800de3:	6a 04                	push   $0x4
  800de5:	68 9f 28 80 00       	push   $0x80289f
  800dea:	6a 23                	push   $0x23
  800dec:	68 bc 28 80 00       	push   $0x8028bc
  800df1:	e8 64 f5 ff ff       	call   80035a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e18:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	7e 17                	jle    800e38 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e21:	83 ec 0c             	sub    $0xc,%esp
  800e24:	50                   	push   %eax
  800e25:	6a 05                	push   $0x5
  800e27:	68 9f 28 80 00       	push   $0x80289f
  800e2c:	6a 23                	push   $0x23
  800e2e:	68 bc 28 80 00       	push   $0x8028bc
  800e33:	e8 22 f5 ff ff       	call   80035a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 df                	mov    %ebx,%edi
  800e5b:	89 de                	mov    %ebx,%esi
  800e5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	7e 17                	jle    800e7a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	50                   	push   %eax
  800e67:	6a 06                	push   $0x6
  800e69:	68 9f 28 80 00       	push   $0x80289f
  800e6e:	6a 23                	push   $0x23
  800e70:	68 bc 28 80 00       	push   $0x8028bc
  800e75:	e8 e0 f4 ff ff       	call   80035a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e90:	b8 08 00 00 00       	mov    $0x8,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	89 df                	mov    %ebx,%edi
  800e9d:	89 de                	mov    %ebx,%esi
  800e9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 17                	jle    800ebc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	83 ec 0c             	sub    $0xc,%esp
  800ea8:	50                   	push   %eax
  800ea9:	6a 08                	push   $0x8
  800eab:	68 9f 28 80 00       	push   $0x80289f
  800eb0:	6a 23                	push   $0x23
  800eb2:	68 bc 28 80 00       	push   $0x8028bc
  800eb7:	e8 9e f4 ff ff       	call   80035a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 df                	mov    %ebx,%edi
  800edf:	89 de                	mov    %ebx,%esi
  800ee1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	7e 17                	jle    800efe <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee7:	83 ec 0c             	sub    $0xc,%esp
  800eea:	50                   	push   %eax
  800eeb:	6a 09                	push   $0x9
  800eed:	68 9f 28 80 00       	push   $0x80289f
  800ef2:	6a 23                	push   $0x23
  800ef4:	68 bc 28 80 00       	push   $0x8028bc
  800ef9:	e8 5c f4 ff ff       	call   80035a <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 df                	mov    %ebx,%edi
  800f21:	89 de                	mov    %ebx,%esi
  800f23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f25:	85 c0                	test   %eax,%eax
  800f27:	7e 17                	jle    800f40 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	50                   	push   %eax
  800f2d:	6a 0a                	push   $0xa
  800f2f:	68 9f 28 80 00       	push   $0x80289f
  800f34:	6a 23                	push   $0x23
  800f36:	68 bc 28 80 00       	push   $0x8028bc
  800f3b:	e8 1a f4 ff ff       	call   80035a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
  800f71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f81:	89 cb                	mov    %ecx,%ebx
  800f83:	89 cf                	mov    %ecx,%edi
  800f85:	89 ce                	mov    %ecx,%esi
  800f87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 17                	jle    800fa4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	50                   	push   %eax
  800f91:	6a 0d                	push   $0xd
  800f93:	68 9f 28 80 00       	push   $0x80289f
  800f98:	6a 23                	push   $0x23
  800f9a:	68 bc 28 80 00       	push   $0x8028bc
  800f9f:	e8 b6 f3 ff ff       	call   80035a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 04             	sub    $0x4,%esp
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fb6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800fb8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fbc:	74 11                	je     800fcf <pgfault+0x23>
  800fbe:	89 d8                	mov    %ebx,%eax
  800fc0:	c1 e8 0c             	shr    $0xc,%eax
  800fc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fca:	f6 c4 08             	test   $0x8,%ah
  800fcd:	75 14                	jne    800fe3 <pgfault+0x37>
		panic("faulting access");
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	68 ca 28 80 00       	push   $0x8028ca
  800fd7:	6a 1d                	push   $0x1d
  800fd9:	68 da 28 80 00       	push   $0x8028da
  800fde:	e8 77 f3 ff ff       	call   80035a <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800fe3:	83 ec 04             	sub    $0x4,%esp
  800fe6:	6a 07                	push   $0x7
  800fe8:	68 00 f0 7f 00       	push   $0x7ff000
  800fed:	6a 00                	push   $0x0
  800fef:	e8 c7 fd ff ff       	call   800dbb <sys_page_alloc>
	if (r < 0) {
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	79 12                	jns    80100d <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ffb:	50                   	push   %eax
  800ffc:	68 e5 28 80 00       	push   $0x8028e5
  801001:	6a 2b                	push   $0x2b
  801003:	68 da 28 80 00       	push   $0x8028da
  801008:	e8 4d f3 ff ff       	call   80035a <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80100d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  801013:	83 ec 04             	sub    $0x4,%esp
  801016:	68 00 10 00 00       	push   $0x1000
  80101b:	53                   	push   %ebx
  80101c:	68 00 f0 7f 00       	push   $0x7ff000
  801021:	e8 8c fb ff ff       	call   800bb2 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801026:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80102d:	53                   	push   %ebx
  80102e:	6a 00                	push   $0x0
  801030:	68 00 f0 7f 00       	push   $0x7ff000
  801035:	6a 00                	push   $0x0
  801037:	e8 c2 fd ff ff       	call   800dfe <sys_page_map>
	if (r < 0) {
  80103c:	83 c4 20             	add    $0x20,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 12                	jns    801055 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801043:	50                   	push   %eax
  801044:	68 e5 28 80 00       	push   $0x8028e5
  801049:	6a 32                	push   $0x32
  80104b:	68 da 28 80 00       	push   $0x8028da
  801050:	e8 05 f3 ff ff       	call   80035a <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801055:	83 ec 08             	sub    $0x8,%esp
  801058:	68 00 f0 7f 00       	push   $0x7ff000
  80105d:	6a 00                	push   $0x0
  80105f:	e8 dc fd ff ff       	call   800e40 <sys_page_unmap>
	if (r < 0) {
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	79 12                	jns    80107d <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80106b:	50                   	push   %eax
  80106c:	68 e5 28 80 00       	push   $0x8028e5
  801071:	6a 36                	push   $0x36
  801073:	68 da 28 80 00       	push   $0x8028da
  801078:	e8 dd f2 ff ff       	call   80035a <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80107d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80108b:	68 ac 0f 80 00       	push   $0x800fac
  801090:	e8 0d 0f 00 00       	call   801fa2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801095:	b8 07 00 00 00       	mov    $0x7,%eax
  80109a:	cd 30                	int    $0x30
  80109c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	79 17                	jns    8010bd <fork+0x3b>
		panic("fork fault %e");
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	68 fe 28 80 00       	push   $0x8028fe
  8010ae:	68 83 00 00 00       	push   $0x83
  8010b3:	68 da 28 80 00       	push   $0x8028da
  8010b8:	e8 9d f2 ff ff       	call   80035a <_panic>
  8010bd:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8010bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010c3:	75 21                	jne    8010e6 <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c5:	e8 b3 fc ff ff       	call   800d7d <sys_getenvid>
  8010ca:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010cf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	e9 61 01 00 00       	jmp    801247 <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	6a 07                	push   $0x7
  8010eb:	68 00 f0 bf ee       	push   $0xeebff000
  8010f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f3:	e8 c3 fc ff ff       	call   800dbb <sys_page_alloc>
  8010f8:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801100:	89 d8                	mov    %ebx,%eax
  801102:	c1 e8 16             	shr    $0x16,%eax
  801105:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110c:	a8 01                	test   $0x1,%al
  80110e:	0f 84 fc 00 00 00    	je     801210 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801114:	89 d8                	mov    %ebx,%eax
  801116:	c1 e8 0c             	shr    $0xc,%eax
  801119:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	0f 84 e7 00 00 00    	je     801210 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801129:	89 c6                	mov    %eax,%esi
  80112b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80112e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801135:	f6 c6 04             	test   $0x4,%dh
  801138:	74 39                	je     801173 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80113a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	25 07 0e 00 00       	and    $0xe07,%eax
  801149:	50                   	push   %eax
  80114a:	56                   	push   %esi
  80114b:	57                   	push   %edi
  80114c:	56                   	push   %esi
  80114d:	6a 00                	push   $0x0
  80114f:	e8 aa fc ff ff       	call   800dfe <sys_page_map>
		if (r < 0) {
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 89 b1 00 00 00    	jns    801210 <fork+0x18e>
		    	panic("sys page map fault %e");
  80115f:	83 ec 04             	sub    $0x4,%esp
  801162:	68 0c 29 80 00       	push   $0x80290c
  801167:	6a 53                	push   $0x53
  801169:	68 da 28 80 00       	push   $0x8028da
  80116e:	e8 e7 f1 ff ff       	call   80035a <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801173:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80117a:	f6 c2 02             	test   $0x2,%dl
  80117d:	75 0c                	jne    80118b <fork+0x109>
  80117f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801186:	f6 c4 08             	test   $0x8,%ah
  801189:	74 5b                	je     8011e6 <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	68 05 08 00 00       	push   $0x805
  801193:	56                   	push   %esi
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	6a 00                	push   $0x0
  801198:	e8 61 fc ff ff       	call   800dfe <sys_page_map>
		if (r < 0) {
  80119d:	83 c4 20             	add    $0x20,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	79 14                	jns    8011b8 <fork+0x136>
		    	panic("sys page map fault %e");
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	68 0c 29 80 00       	push   $0x80290c
  8011ac:	6a 5a                	push   $0x5a
  8011ae:	68 da 28 80 00       	push   $0x8028da
  8011b3:	e8 a2 f1 ff ff       	call   80035a <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8011b8:	83 ec 0c             	sub    $0xc,%esp
  8011bb:	68 05 08 00 00       	push   $0x805
  8011c0:	56                   	push   %esi
  8011c1:	6a 00                	push   $0x0
  8011c3:	56                   	push   %esi
  8011c4:	6a 00                	push   $0x0
  8011c6:	e8 33 fc ff ff       	call   800dfe <sys_page_map>
		if (r < 0) {
  8011cb:	83 c4 20             	add    $0x20,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	79 3e                	jns    801210 <fork+0x18e>
		    	panic("sys page map fault %e");
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	68 0c 29 80 00       	push   $0x80290c
  8011da:	6a 5e                	push   $0x5e
  8011dc:	68 da 28 80 00       	push   $0x8028da
  8011e1:	e8 74 f1 ff ff       	call   80035a <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8011e6:	83 ec 0c             	sub    $0xc,%esp
  8011e9:	6a 05                	push   $0x5
  8011eb:	56                   	push   %esi
  8011ec:	57                   	push   %edi
  8011ed:	56                   	push   %esi
  8011ee:	6a 00                	push   $0x0
  8011f0:	e8 09 fc ff ff       	call   800dfe <sys_page_map>
		if (r < 0) {
  8011f5:	83 c4 20             	add    $0x20,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	79 14                	jns    801210 <fork+0x18e>
		    	panic("sys page map fault %e");
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	68 0c 29 80 00       	push   $0x80290c
  801204:	6a 63                	push   $0x63
  801206:	68 da 28 80 00       	push   $0x8028da
  80120b:	e8 4a f1 ff ff       	call   80035a <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801210:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801216:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80121c:	0f 85 de fe ff ff    	jne    801100 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801222:	a1 04 40 80 00       	mov    0x804004,%eax
  801227:	8b 40 64             	mov    0x64(%eax),%eax
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	50                   	push   %eax
  80122e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801231:	57                   	push   %edi
  801232:	e8 cf fc ff ff       	call   800f06 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801237:	83 c4 08             	add    $0x8,%esp
  80123a:	6a 02                	push   $0x2
  80123c:	57                   	push   %edi
  80123d:	e8 40 fc ff ff       	call   800e82 <sys_env_set_status>
	
	return envid;
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <sfork>:

// Challenge!
int
sfork(void)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801255:	68 22 29 80 00       	push   $0x802922
  80125a:	68 a1 00 00 00       	push   $0xa1
  80125f:	68 da 28 80 00       	push   $0x8028da
  801264:	e8 f1 f0 ff ff       	call   80035a <_panic>

00801269 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
  80126f:	05 00 00 00 30       	add    $0x30000000,%eax
  801274:	c1 e8 0c             	shr    $0xc,%eax
}
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80127c:	8b 45 08             	mov    0x8(%ebp),%eax
  80127f:	05 00 00 00 30       	add    $0x30000000,%eax
  801284:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801289:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801296:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	c1 ea 16             	shr    $0x16,%edx
  8012a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a7:	f6 c2 01             	test   $0x1,%dl
  8012aa:	74 11                	je     8012bd <fd_alloc+0x2d>
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	c1 ea 0c             	shr    $0xc,%edx
  8012b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b8:	f6 c2 01             	test   $0x1,%dl
  8012bb:	75 09                	jne    8012c6 <fd_alloc+0x36>
			*fd_store = fd;
  8012bd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c4:	eb 17                	jmp    8012dd <fd_alloc+0x4d>
  8012c6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d0:	75 c9                	jne    80129b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e5:	83 f8 1f             	cmp    $0x1f,%eax
  8012e8:	77 36                	ja     801320 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ea:	c1 e0 0c             	shl    $0xc,%eax
  8012ed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	c1 ea 16             	shr    $0x16,%edx
  8012f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012fe:	f6 c2 01             	test   $0x1,%dl
  801301:	74 24                	je     801327 <fd_lookup+0x48>
  801303:	89 c2                	mov    %eax,%edx
  801305:	c1 ea 0c             	shr    $0xc,%edx
  801308:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 1a                	je     80132e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	89 02                	mov    %eax,(%edx)
	return 0;
  801319:	b8 00 00 00 00       	mov    $0x0,%eax
  80131e:	eb 13                	jmp    801333 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801320:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801325:	eb 0c                	jmp    801333 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801327:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132c:	eb 05                	jmp    801333 <fd_lookup+0x54>
  80132e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133e:	ba b8 29 80 00       	mov    $0x8029b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801343:	eb 13                	jmp    801358 <dev_lookup+0x23>
  801345:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801348:	39 08                	cmp    %ecx,(%eax)
  80134a:	75 0c                	jne    801358 <dev_lookup+0x23>
			*dev = devtab[i];
  80134c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801351:	b8 00 00 00 00       	mov    $0x0,%eax
  801356:	eb 2e                	jmp    801386 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801358:	8b 02                	mov    (%edx),%eax
  80135a:	85 c0                	test   %eax,%eax
  80135c:	75 e7                	jne    801345 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80135e:	a1 04 40 80 00       	mov    0x804004,%eax
  801363:	8b 40 48             	mov    0x48(%eax),%eax
  801366:	83 ec 04             	sub    $0x4,%esp
  801369:	51                   	push   %ecx
  80136a:	50                   	push   %eax
  80136b:	68 38 29 80 00       	push   $0x802938
  801370:	e8 be f0 ff ff       	call   800433 <cprintf>
	*dev = 0;
  801375:	8b 45 0c             	mov    0xc(%ebp),%eax
  801378:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	83 ec 10             	sub    $0x10,%esp
  801390:	8b 75 08             	mov    0x8(%ebp),%esi
  801393:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a0:	c1 e8 0c             	shr    $0xc,%eax
  8013a3:	50                   	push   %eax
  8013a4:	e8 36 ff ff ff       	call   8012df <fd_lookup>
  8013a9:	83 c4 08             	add    $0x8,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 05                	js     8013b5 <fd_close+0x2d>
	    || fd != fd2)
  8013b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b3:	74 0c                	je     8013c1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013b5:	84 db                	test   %bl,%bl
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	0f 44 c2             	cmove  %edx,%eax
  8013bf:	eb 41                	jmp    801402 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 36                	pushl  (%esi)
  8013ca:	e8 66 ff ff ff       	call   801335 <dev_lookup>
  8013cf:	89 c3                	mov    %eax,%ebx
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 1a                	js     8013f2 <fd_close+0x6a>
		if (dev->dev_close)
  8013d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	74 0b                	je     8013f2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	56                   	push   %esi
  8013eb:	ff d0                	call   *%eax
  8013ed:	89 c3                	mov    %eax,%ebx
  8013ef:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	56                   	push   %esi
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 43 fa ff ff       	call   800e40 <sys_page_unmap>
	return r;
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	89 d8                	mov    %ebx,%eax
}
  801402:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    

00801409 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80140f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	ff 75 08             	pushl  0x8(%ebp)
  801416:	e8 c4 fe ff ff       	call   8012df <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 10                	js     801432 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801422:	83 ec 08             	sub    $0x8,%esp
  801425:	6a 01                	push   $0x1
  801427:	ff 75 f4             	pushl  -0xc(%ebp)
  80142a:	e8 59 ff ff ff       	call   801388 <fd_close>
  80142f:	83 c4 10             	add    $0x10,%esp
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <close_all>:

void
close_all(void)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	53                   	push   %ebx
  801438:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	53                   	push   %ebx
  801444:	e8 c0 ff ff ff       	call   801409 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801449:	83 c3 01             	add    $0x1,%ebx
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	83 fb 20             	cmp    $0x20,%ebx
  801452:	75 ec                	jne    801440 <close_all+0xc>
		close(i);
}
  801454:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801457:	c9                   	leave  
  801458:	c3                   	ret    

00801459 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	57                   	push   %edi
  80145d:	56                   	push   %esi
  80145e:	53                   	push   %ebx
  80145f:	83 ec 2c             	sub    $0x2c,%esp
  801462:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801465:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	ff 75 08             	pushl  0x8(%ebp)
  80146c:	e8 6e fe ff ff       	call   8012df <fd_lookup>
  801471:	83 c4 08             	add    $0x8,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	0f 88 c1 00 00 00    	js     80153d <dup+0xe4>
		return r;
	close(newfdnum);
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	56                   	push   %esi
  801480:	e8 84 ff ff ff       	call   801409 <close>

	newfd = INDEX2FD(newfdnum);
  801485:	89 f3                	mov    %esi,%ebx
  801487:	c1 e3 0c             	shl    $0xc,%ebx
  80148a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801490:	83 c4 04             	add    $0x4,%esp
  801493:	ff 75 e4             	pushl  -0x1c(%ebp)
  801496:	e8 de fd ff ff       	call   801279 <fd2data>
  80149b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80149d:	89 1c 24             	mov    %ebx,(%esp)
  8014a0:	e8 d4 fd ff ff       	call   801279 <fd2data>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ab:	89 f8                	mov    %edi,%eax
  8014ad:	c1 e8 16             	shr    $0x16,%eax
  8014b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b7:	a8 01                	test   $0x1,%al
  8014b9:	74 37                	je     8014f2 <dup+0x99>
  8014bb:	89 f8                	mov    %edi,%eax
  8014bd:	c1 e8 0c             	shr    $0xc,%eax
  8014c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c7:	f6 c2 01             	test   $0x1,%dl
  8014ca:	74 26                	je     8014f2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014db:	50                   	push   %eax
  8014dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014df:	6a 00                	push   $0x0
  8014e1:	57                   	push   %edi
  8014e2:	6a 00                	push   $0x0
  8014e4:	e8 15 f9 ff ff       	call   800dfe <sys_page_map>
  8014e9:	89 c7                	mov    %eax,%edi
  8014eb:	83 c4 20             	add    $0x20,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 2e                	js     801520 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014f5:	89 d0                	mov    %edx,%eax
  8014f7:	c1 e8 0c             	shr    $0xc,%eax
  8014fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	25 07 0e 00 00       	and    $0xe07,%eax
  801509:	50                   	push   %eax
  80150a:	53                   	push   %ebx
  80150b:	6a 00                	push   $0x0
  80150d:	52                   	push   %edx
  80150e:	6a 00                	push   $0x0
  801510:	e8 e9 f8 ff ff       	call   800dfe <sys_page_map>
  801515:	89 c7                	mov    %eax,%edi
  801517:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80151a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80151c:	85 ff                	test   %edi,%edi
  80151e:	79 1d                	jns    80153d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	53                   	push   %ebx
  801524:	6a 00                	push   $0x0
  801526:	e8 15 f9 ff ff       	call   800e40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152b:	83 c4 08             	add    $0x8,%esp
  80152e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801531:	6a 00                	push   $0x0
  801533:	e8 08 f9 ff ff       	call   800e40 <sys_page_unmap>
	return r;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	89 f8                	mov    %edi,%eax
}
  80153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 14             	sub    $0x14,%esp
  80154c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	53                   	push   %ebx
  801554:	e8 86 fd ff ff       	call   8012df <fd_lookup>
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 6d                	js     8015cf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	ff 30                	pushl  (%eax)
  80156e:	e8 c2 fd ff ff       	call   801335 <dev_lookup>
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 4c                	js     8015c6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80157a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80157d:	8b 42 08             	mov    0x8(%edx),%eax
  801580:	83 e0 03             	and    $0x3,%eax
  801583:	83 f8 01             	cmp    $0x1,%eax
  801586:	75 21                	jne    8015a9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801588:	a1 04 40 80 00       	mov    0x804004,%eax
  80158d:	8b 40 48             	mov    0x48(%eax),%eax
  801590:	83 ec 04             	sub    $0x4,%esp
  801593:	53                   	push   %ebx
  801594:	50                   	push   %eax
  801595:	68 7c 29 80 00       	push   $0x80297c
  80159a:	e8 94 ee ff ff       	call   800433 <cprintf>
		return -E_INVAL;
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a7:	eb 26                	jmp    8015cf <read+0x8a>
	}
	if (!dev->dev_read)
  8015a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ac:	8b 40 08             	mov    0x8(%eax),%eax
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	74 17                	je     8015ca <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015b3:	83 ec 04             	sub    $0x4,%esp
  8015b6:	ff 75 10             	pushl  0x10(%ebp)
  8015b9:	ff 75 0c             	pushl  0xc(%ebp)
  8015bc:	52                   	push   %edx
  8015bd:	ff d0                	call   *%eax
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	eb 09                	jmp    8015cf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	eb 05                	jmp    8015cf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015cf:	89 d0                	mov    %edx,%eax
  8015d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	57                   	push   %edi
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ea:	eb 21                	jmp    80160d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	89 f0                	mov    %esi,%eax
  8015f1:	29 d8                	sub    %ebx,%eax
  8015f3:	50                   	push   %eax
  8015f4:	89 d8                	mov    %ebx,%eax
  8015f6:	03 45 0c             	add    0xc(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	57                   	push   %edi
  8015fb:	e8 45 ff ff ff       	call   801545 <read>
		if (m < 0)
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 10                	js     801617 <readn+0x41>
			return m;
		if (m == 0)
  801607:	85 c0                	test   %eax,%eax
  801609:	74 0a                	je     801615 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160b:	01 c3                	add    %eax,%ebx
  80160d:	39 f3                	cmp    %esi,%ebx
  80160f:	72 db                	jb     8015ec <readn+0x16>
  801611:	89 d8                	mov    %ebx,%eax
  801613:	eb 02                	jmp    801617 <readn+0x41>
  801615:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 14             	sub    $0x14,%esp
  801626:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801629:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	53                   	push   %ebx
  80162e:	e8 ac fc ff ff       	call   8012df <fd_lookup>
  801633:	83 c4 08             	add    $0x8,%esp
  801636:	89 c2                	mov    %eax,%edx
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 68                	js     8016a4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801642:	50                   	push   %eax
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	ff 30                	pushl  (%eax)
  801648:	e8 e8 fc ff ff       	call   801335 <dev_lookup>
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	85 c0                	test   %eax,%eax
  801652:	78 47                	js     80169b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801657:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165b:	75 21                	jne    80167e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80165d:	a1 04 40 80 00       	mov    0x804004,%eax
  801662:	8b 40 48             	mov    0x48(%eax),%eax
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	53                   	push   %ebx
  801669:	50                   	push   %eax
  80166a:	68 98 29 80 00       	push   $0x802998
  80166f:	e8 bf ed ff ff       	call   800433 <cprintf>
		return -E_INVAL;
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167c:	eb 26                	jmp    8016a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80167e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801681:	8b 52 0c             	mov    0xc(%edx),%edx
  801684:	85 d2                	test   %edx,%edx
  801686:	74 17                	je     80169f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801688:	83 ec 04             	sub    $0x4,%esp
  80168b:	ff 75 10             	pushl  0x10(%ebp)
  80168e:	ff 75 0c             	pushl  0xc(%ebp)
  801691:	50                   	push   %eax
  801692:	ff d2                	call   *%edx
  801694:	89 c2                	mov    %eax,%edx
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	eb 09                	jmp    8016a4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	89 c2                	mov    %eax,%edx
  80169d:	eb 05                	jmp    8016a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80169f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016a4:	89 d0                	mov    %edx,%eax
  8016a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	ff 75 08             	pushl  0x8(%ebp)
  8016b8:	e8 22 fc ff ff       	call   8012df <fd_lookup>
  8016bd:	83 c4 08             	add    $0x8,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 0e                	js     8016d2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 14             	sub    $0x14,%esp
  8016db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	53                   	push   %ebx
  8016e3:	e8 f7 fb ff ff       	call   8012df <fd_lookup>
  8016e8:	83 c4 08             	add    $0x8,%esp
  8016eb:	89 c2                	mov    %eax,%edx
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 65                	js     801756 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fb:	ff 30                	pushl  (%eax)
  8016fd:	e8 33 fc ff ff       	call   801335 <dev_lookup>
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	78 44                	js     80174d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801710:	75 21                	jne    801733 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801712:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801717:	8b 40 48             	mov    0x48(%eax),%eax
  80171a:	83 ec 04             	sub    $0x4,%esp
  80171d:	53                   	push   %ebx
  80171e:	50                   	push   %eax
  80171f:	68 58 29 80 00       	push   $0x802958
  801724:	e8 0a ed ff ff       	call   800433 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801731:	eb 23                	jmp    801756 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801733:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801736:	8b 52 18             	mov    0x18(%edx),%edx
  801739:	85 d2                	test   %edx,%edx
  80173b:	74 14                	je     801751 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	50                   	push   %eax
  801744:	ff d2                	call   *%edx
  801746:	89 c2                	mov    %eax,%edx
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	eb 09                	jmp    801756 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	eb 05                	jmp    801756 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801751:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801756:	89 d0                	mov    %edx,%eax
  801758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	53                   	push   %ebx
  801761:	83 ec 14             	sub    $0x14,%esp
  801764:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801767:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	ff 75 08             	pushl  0x8(%ebp)
  80176e:	e8 6c fb ff ff       	call   8012df <fd_lookup>
  801773:	83 c4 08             	add    $0x8,%esp
  801776:	89 c2                	mov    %eax,%edx
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 58                	js     8017d4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	50                   	push   %eax
  801783:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801786:	ff 30                	pushl  (%eax)
  801788:	e8 a8 fb ff ff       	call   801335 <dev_lookup>
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	85 c0                	test   %eax,%eax
  801792:	78 37                	js     8017cb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80179b:	74 32                	je     8017cf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80179d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a7:	00 00 00 
	stat->st_isdir = 0;
  8017aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b1:	00 00 00 
	stat->st_dev = dev;
  8017b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	53                   	push   %ebx
  8017be:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c1:	ff 50 14             	call   *0x14(%eax)
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	eb 09                	jmp    8017d4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	eb 05                	jmp    8017d4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d4:	89 d0                	mov    %edx,%eax
  8017d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e0:	83 ec 08             	sub    $0x8,%esp
  8017e3:	6a 00                	push   $0x0
  8017e5:	ff 75 08             	pushl  0x8(%ebp)
  8017e8:	e8 e3 01 00 00       	call   8019d0 <open>
  8017ed:	89 c3                	mov    %eax,%ebx
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 1b                	js     801811 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	ff 75 0c             	pushl  0xc(%ebp)
  8017fc:	50                   	push   %eax
  8017fd:	e8 5b ff ff ff       	call   80175d <fstat>
  801802:	89 c6                	mov    %eax,%esi
	close(fd);
  801804:	89 1c 24             	mov    %ebx,(%esp)
  801807:	e8 fd fb ff ff       	call   801409 <close>
	return r;
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	89 f0                	mov    %esi,%eax
}
  801811:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801814:	5b                   	pop    %ebx
  801815:	5e                   	pop    %esi
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	89 c6                	mov    %eax,%esi
  80181f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801821:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801828:	75 12                	jne    80183c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	6a 01                	push   $0x1
  80182f:	e8 d1 08 00 00       	call   802105 <ipc_find_env>
  801834:	a3 00 40 80 00       	mov    %eax,0x804000
  801839:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80183c:	6a 07                	push   $0x7
  80183e:	68 00 50 80 00       	push   $0x805000
  801843:	56                   	push   %esi
  801844:	ff 35 00 40 80 00    	pushl  0x804000
  80184a:	e8 54 08 00 00       	call   8020a3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80184f:	83 c4 0c             	add    $0xc,%esp
  801852:	6a 00                	push   $0x0
  801854:	53                   	push   %ebx
  801855:	6a 00                	push   $0x0
  801857:	e8 d5 07 00 00       	call   802031 <ipc_recv>
}
  80185c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801874:	8b 45 0c             	mov    0xc(%ebp),%eax
  801877:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 02 00 00 00       	mov    $0x2,%eax
  801886:	e8 8d ff ff ff       	call   801818 <fsipc>
}
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	8b 40 0c             	mov    0xc(%eax),%eax
  801899:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a8:	e8 6b ff ff ff       	call   801818 <fsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	83 ec 04             	sub    $0x4,%esp
  8018b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ce:	e8 45 ff ff ff       	call   801818 <fsipc>
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 2c                	js     801903 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	68 00 50 80 00       	push   $0x805000
  8018df:	53                   	push   %ebx
  8018e0:	e8 d3 f0 ff ff       	call   8009b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018e5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018f5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801903:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801911:	8b 55 08             	mov    0x8(%ebp),%edx
  801914:	8b 52 0c             	mov    0xc(%edx),%edx
  801917:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80191d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801922:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801927:	0f 47 c2             	cmova  %edx,%eax
  80192a:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80192f:	50                   	push   %eax
  801930:	ff 75 0c             	pushl  0xc(%ebp)
  801933:	68 08 50 80 00       	push   $0x805008
  801938:	e8 0d f2 ff ff       	call   800b4a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80193d:	ba 00 00 00 00       	mov    $0x0,%edx
  801942:	b8 04 00 00 00       	mov    $0x4,%eax
  801947:	e8 cc fe ff ff       	call   801818 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	8b 40 0c             	mov    0xc(%eax),%eax
  80195c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801961:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801967:	ba 00 00 00 00       	mov    $0x0,%edx
  80196c:	b8 03 00 00 00       	mov    $0x3,%eax
  801971:	e8 a2 fe ff ff       	call   801818 <fsipc>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 4b                	js     8019c7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80197c:	39 c6                	cmp    %eax,%esi
  80197e:	73 16                	jae    801996 <devfile_read+0x48>
  801980:	68 c8 29 80 00       	push   $0x8029c8
  801985:	68 cf 29 80 00       	push   $0x8029cf
  80198a:	6a 7c                	push   $0x7c
  80198c:	68 e4 29 80 00       	push   $0x8029e4
  801991:	e8 c4 e9 ff ff       	call   80035a <_panic>
	assert(r <= PGSIZE);
  801996:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80199b:	7e 16                	jle    8019b3 <devfile_read+0x65>
  80199d:	68 ef 29 80 00       	push   $0x8029ef
  8019a2:	68 cf 29 80 00       	push   $0x8029cf
  8019a7:	6a 7d                	push   $0x7d
  8019a9:	68 e4 29 80 00       	push   $0x8029e4
  8019ae:	e8 a7 e9 ff ff       	call   80035a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b3:	83 ec 04             	sub    $0x4,%esp
  8019b6:	50                   	push   %eax
  8019b7:	68 00 50 80 00       	push   $0x805000
  8019bc:	ff 75 0c             	pushl  0xc(%ebp)
  8019bf:	e8 86 f1 ff ff       	call   800b4a <memmove>
	return r;
  8019c4:	83 c4 10             	add    $0x10,%esp
}
  8019c7:	89 d8                	mov    %ebx,%eax
  8019c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 20             	sub    $0x20,%esp
  8019d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019da:	53                   	push   %ebx
  8019db:	e8 9f ef ff ff       	call   80097f <strlen>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e8:	7f 67                	jg     801a51 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f0:	50                   	push   %eax
  8019f1:	e8 9a f8 ff ff       	call   801290 <fd_alloc>
  8019f6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 57                	js     801a56 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ff:	83 ec 08             	sub    $0x8,%esp
  801a02:	53                   	push   %ebx
  801a03:	68 00 50 80 00       	push   $0x805000
  801a08:	e8 ab ef ff ff       	call   8009b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a10:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a18:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1d:	e8 f6 fd ff ff       	call   801818 <fsipc>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	79 14                	jns    801a3f <open+0x6f>
		fd_close(fd, 0);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	6a 00                	push   $0x0
  801a30:	ff 75 f4             	pushl  -0xc(%ebp)
  801a33:	e8 50 f9 ff ff       	call   801388 <fd_close>
		return r;
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	89 da                	mov    %ebx,%edx
  801a3d:	eb 17                	jmp    801a56 <open+0x86>
	}

	return fd2num(fd);
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	ff 75 f4             	pushl  -0xc(%ebp)
  801a45:	e8 1f f8 ff ff       	call   801269 <fd2num>
  801a4a:	89 c2                	mov    %eax,%edx
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	eb 05                	jmp    801a56 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a51:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a56:	89 d0                	mov    %edx,%eax
  801a58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a63:	ba 00 00 00 00       	mov    $0x0,%edx
  801a68:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6d:	e8 a6 fd ff ff       	call   801818 <fsipc>
}
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	56                   	push   %esi
  801a78:	53                   	push   %ebx
  801a79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	ff 75 08             	pushl  0x8(%ebp)
  801a82:	e8 f2 f7 ff ff       	call   801279 <fd2data>
  801a87:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a89:	83 c4 08             	add    $0x8,%esp
  801a8c:	68 fb 29 80 00       	push   $0x8029fb
  801a91:	53                   	push   %ebx
  801a92:	e8 21 ef ff ff       	call   8009b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a97:	8b 46 04             	mov    0x4(%esi),%eax
  801a9a:	2b 06                	sub    (%esi),%eax
  801a9c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aa2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa9:	00 00 00 
	stat->st_dev = &devpipe;
  801aac:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801ab3:	30 80 00 
	return 0;
}
  801ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  801abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801acc:	53                   	push   %ebx
  801acd:	6a 00                	push   $0x0
  801acf:	e8 6c f3 ff ff       	call   800e40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ad4:	89 1c 24             	mov    %ebx,(%esp)
  801ad7:	e8 9d f7 ff ff       	call   801279 <fd2data>
  801adc:	83 c4 08             	add    $0x8,%esp
  801adf:	50                   	push   %eax
  801ae0:	6a 00                	push   $0x0
  801ae2:	e8 59 f3 ff ff       	call   800e40 <sys_page_unmap>
}
  801ae7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aea:	c9                   	leave  
  801aeb:	c3                   	ret    

00801aec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	57                   	push   %edi
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
  801af2:	83 ec 1c             	sub    $0x1c,%esp
  801af5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801af8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801afa:	a1 04 40 80 00       	mov    0x804004,%eax
  801aff:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	ff 75 e0             	pushl  -0x20(%ebp)
  801b08:	e8 31 06 00 00       	call   80213e <pageref>
  801b0d:	89 c3                	mov    %eax,%ebx
  801b0f:	89 3c 24             	mov    %edi,(%esp)
  801b12:	e8 27 06 00 00       	call   80213e <pageref>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	39 c3                	cmp    %eax,%ebx
  801b1c:	0f 94 c1             	sete   %cl
  801b1f:	0f b6 c9             	movzbl %cl,%ecx
  801b22:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b25:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b2b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b2e:	39 ce                	cmp    %ecx,%esi
  801b30:	74 1b                	je     801b4d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b32:	39 c3                	cmp    %eax,%ebx
  801b34:	75 c4                	jne    801afa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b36:	8b 42 58             	mov    0x58(%edx),%eax
  801b39:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b3c:	50                   	push   %eax
  801b3d:	56                   	push   %esi
  801b3e:	68 02 2a 80 00       	push   $0x802a02
  801b43:	e8 eb e8 ff ff       	call   800433 <cprintf>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	eb ad                	jmp    801afa <_pipeisclosed+0xe>
	}
}
  801b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	57                   	push   %edi
  801b5c:	56                   	push   %esi
  801b5d:	53                   	push   %ebx
  801b5e:	83 ec 28             	sub    $0x28,%esp
  801b61:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b64:	56                   	push   %esi
  801b65:	e8 0f f7 ff ff       	call   801279 <fd2data>
  801b6a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b74:	eb 4b                	jmp    801bc1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b76:	89 da                	mov    %ebx,%edx
  801b78:	89 f0                	mov    %esi,%eax
  801b7a:	e8 6d ff ff ff       	call   801aec <_pipeisclosed>
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	75 48                	jne    801bcb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b83:	e8 14 f2 ff ff       	call   800d9c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b88:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8b:	8b 0b                	mov    (%ebx),%ecx
  801b8d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b90:	39 d0                	cmp    %edx,%eax
  801b92:	73 e2                	jae    801b76 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b97:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b9b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	c1 fa 1f             	sar    $0x1f,%edx
  801ba3:	89 d1                	mov    %edx,%ecx
  801ba5:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bab:	83 e2 1f             	and    $0x1f,%edx
  801bae:	29 ca                	sub    %ecx,%edx
  801bb0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bb4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb8:	83 c0 01             	add    $0x1,%eax
  801bbb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbe:	83 c7 01             	add    $0x1,%edi
  801bc1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bc4:	75 c2                	jne    801b88 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bc6:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc9:	eb 05                	jmp    801bd0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bcb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	57                   	push   %edi
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 18             	sub    $0x18,%esp
  801be1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801be4:	57                   	push   %edi
  801be5:	e8 8f f6 ff ff       	call   801279 <fd2data>
  801bea:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf4:	eb 3d                	jmp    801c33 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf6:	85 db                	test   %ebx,%ebx
  801bf8:	74 04                	je     801bfe <devpipe_read+0x26>
				return i;
  801bfa:	89 d8                	mov    %ebx,%eax
  801bfc:	eb 44                	jmp    801c42 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bfe:	89 f2                	mov    %esi,%edx
  801c00:	89 f8                	mov    %edi,%eax
  801c02:	e8 e5 fe ff ff       	call   801aec <_pipeisclosed>
  801c07:	85 c0                	test   %eax,%eax
  801c09:	75 32                	jne    801c3d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c0b:	e8 8c f1 ff ff       	call   800d9c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c10:	8b 06                	mov    (%esi),%eax
  801c12:	3b 46 04             	cmp    0x4(%esi),%eax
  801c15:	74 df                	je     801bf6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c17:	99                   	cltd   
  801c18:	c1 ea 1b             	shr    $0x1b,%edx
  801c1b:	01 d0                	add    %edx,%eax
  801c1d:	83 e0 1f             	and    $0x1f,%eax
  801c20:	29 d0                	sub    %edx,%eax
  801c22:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c2d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c30:	83 c3 01             	add    $0x1,%ebx
  801c33:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c36:	75 d8                	jne    801c10 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c38:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3b:	eb 05                	jmp    801c42 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c45:	5b                   	pop    %ebx
  801c46:	5e                   	pop    %esi
  801c47:	5f                   	pop    %edi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	56                   	push   %esi
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c55:	50                   	push   %eax
  801c56:	e8 35 f6 ff ff       	call   801290 <fd_alloc>
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	89 c2                	mov    %eax,%edx
  801c60:	85 c0                	test   %eax,%eax
  801c62:	0f 88 2c 01 00 00    	js     801d94 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c68:	83 ec 04             	sub    $0x4,%esp
  801c6b:	68 07 04 00 00       	push   $0x407
  801c70:	ff 75 f4             	pushl  -0xc(%ebp)
  801c73:	6a 00                	push   $0x0
  801c75:	e8 41 f1 ff ff       	call   800dbb <sys_page_alloc>
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	89 c2                	mov    %eax,%edx
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	0f 88 0d 01 00 00    	js     801d94 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	e8 fd f5 ff ff       	call   801290 <fd_alloc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	0f 88 e2 00 00 00    	js     801d82 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca0:	83 ec 04             	sub    $0x4,%esp
  801ca3:	68 07 04 00 00       	push   $0x407
  801ca8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cab:	6a 00                	push   $0x0
  801cad:	e8 09 f1 ff ff       	call   800dbb <sys_page_alloc>
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 c3 00 00 00    	js     801d82 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	e8 af f5 ff ff       	call   801279 <fd2data>
  801cca:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccc:	83 c4 0c             	add    $0xc,%esp
  801ccf:	68 07 04 00 00       	push   $0x407
  801cd4:	50                   	push   %eax
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 df f0 ff ff       	call   800dbb <sys_page_alloc>
  801cdc:	89 c3                	mov    %eax,%ebx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	0f 88 89 00 00 00    	js     801d72 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	ff 75 f0             	pushl  -0x10(%ebp)
  801cef:	e8 85 f5 ff ff       	call   801279 <fd2data>
  801cf4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cfb:	50                   	push   %eax
  801cfc:	6a 00                	push   $0x0
  801cfe:	56                   	push   %esi
  801cff:	6a 00                	push   $0x0
  801d01:	e8 f8 f0 ff ff       	call   800dfe <sys_page_map>
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	83 c4 20             	add    $0x20,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 55                	js     801d64 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d0f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d18:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d24:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d32:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d39:	83 ec 0c             	sub    $0xc,%esp
  801d3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3f:	e8 25 f5 ff ff       	call   801269 <fd2num>
  801d44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d47:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d49:	83 c4 04             	add    $0x4,%esp
  801d4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4f:	e8 15 f5 ff ff       	call   801269 <fd2num>
  801d54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d57:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d62:	eb 30                	jmp    801d94 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d64:	83 ec 08             	sub    $0x8,%esp
  801d67:	56                   	push   %esi
  801d68:	6a 00                	push   $0x0
  801d6a:	e8 d1 f0 ff ff       	call   800e40 <sys_page_unmap>
  801d6f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	ff 75 f0             	pushl  -0x10(%ebp)
  801d78:	6a 00                	push   $0x0
  801d7a:	e8 c1 f0 ff ff       	call   800e40 <sys_page_unmap>
  801d7f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d82:	83 ec 08             	sub    $0x8,%esp
  801d85:	ff 75 f4             	pushl  -0xc(%ebp)
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 b1 f0 ff ff       	call   800e40 <sys_page_unmap>
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d94:	89 d0                	mov    %edx,%eax
  801d96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da6:	50                   	push   %eax
  801da7:	ff 75 08             	pushl  0x8(%ebp)
  801daa:	e8 30 f5 ff ff       	call   8012df <fd_lookup>
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 18                	js     801dce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db6:	83 ec 0c             	sub    $0xc,%esp
  801db9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbc:	e8 b8 f4 ff ff       	call   801279 <fd2data>
	return _pipeisclosed(fd, p);
  801dc1:	89 c2                	mov    %eax,%edx
  801dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc6:	e8 21 fd ff ff       	call   801aec <_pipeisclosed>
  801dcb:	83 c4 10             	add    $0x10,%esp
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	56                   	push   %esi
  801dd4:	53                   	push   %ebx
  801dd5:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801dd8:	85 f6                	test   %esi,%esi
  801dda:	75 16                	jne    801df2 <wait+0x22>
  801ddc:	68 1a 2a 80 00       	push   $0x802a1a
  801de1:	68 cf 29 80 00       	push   $0x8029cf
  801de6:	6a 09                	push   $0x9
  801de8:	68 25 2a 80 00       	push   $0x802a25
  801ded:	e8 68 e5 ff ff       	call   80035a <_panic>
	e = &envs[ENVX(envid)];
  801df2:	89 f3                	mov    %esi,%ebx
  801df4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dfa:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801dfd:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e03:	eb 05                	jmp    801e0a <wait+0x3a>
		sys_yield();
  801e05:	e8 92 ef ff ff       	call   800d9c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e0a:	8b 43 48             	mov    0x48(%ebx),%eax
  801e0d:	39 c6                	cmp    %eax,%esi
  801e0f:	75 07                	jne    801e18 <wait+0x48>
  801e11:	8b 43 54             	mov    0x54(%ebx),%eax
  801e14:	85 c0                	test   %eax,%eax
  801e16:	75 ed                	jne    801e05 <wait+0x35>
		sys_yield();
}
  801e18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5e                   	pop    %esi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e22:	b8 00 00 00 00       	mov    $0x0,%eax
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e2f:	68 30 2a 80 00       	push   $0x802a30
  801e34:	ff 75 0c             	pushl  0xc(%ebp)
  801e37:	e8 7c eb ff ff       	call   8009b8 <strcpy>
	return 0;
}
  801e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	57                   	push   %edi
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e4f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e54:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5a:	eb 2d                	jmp    801e89 <devcons_write+0x46>
		m = n - tot;
  801e5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e5f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e61:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e64:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e69:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6c:	83 ec 04             	sub    $0x4,%esp
  801e6f:	53                   	push   %ebx
  801e70:	03 45 0c             	add    0xc(%ebp),%eax
  801e73:	50                   	push   %eax
  801e74:	57                   	push   %edi
  801e75:	e8 d0 ec ff ff       	call   800b4a <memmove>
		sys_cputs(buf, m);
  801e7a:	83 c4 08             	add    $0x8,%esp
  801e7d:	53                   	push   %ebx
  801e7e:	57                   	push   %edi
  801e7f:	e8 7b ee ff ff       	call   800cff <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e84:	01 de                	add    %ebx,%esi
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	89 f0                	mov    %esi,%eax
  801e8b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e8e:	72 cc                	jb     801e5c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 08             	sub    $0x8,%esp
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ea3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ea7:	74 2a                	je     801ed3 <devcons_read+0x3b>
  801ea9:	eb 05                	jmp    801eb0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eab:	e8 ec ee ff ff       	call   800d9c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eb0:	e8 68 ee ff ff       	call   800d1d <sys_cgetc>
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	74 f2                	je     801eab <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 16                	js     801ed3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ebd:	83 f8 04             	cmp    $0x4,%eax
  801ec0:	74 0c                	je     801ece <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec5:	88 02                	mov    %al,(%edx)
	return 1;
  801ec7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecc:	eb 05                	jmp    801ed3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ed3:	c9                   	leave  
  801ed4:	c3                   	ret    

00801ed5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ee1:	6a 01                	push   $0x1
  801ee3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee6:	50                   	push   %eax
  801ee7:	e8 13 ee ff ff       	call   800cff <sys_cputs>
}
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <getchar>:

int
getchar(void)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ef7:	6a 01                	push   $0x1
  801ef9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efc:	50                   	push   %eax
  801efd:	6a 00                	push   $0x0
  801eff:	e8 41 f6 ff ff       	call   801545 <read>
	if (r < 0)
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 0f                	js     801f1a <getchar+0x29>
		return r;
	if (r < 1)
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	7e 06                	jle    801f15 <getchar+0x24>
		return -E_EOF;
	return c;
  801f0f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f13:	eb 05                	jmp    801f1a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f15:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f25:	50                   	push   %eax
  801f26:	ff 75 08             	pushl  0x8(%ebp)
  801f29:	e8 b1 f3 ff ff       	call   8012df <fd_lookup>
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 11                	js     801f46 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f38:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f3e:	39 10                	cmp    %edx,(%eax)
  801f40:	0f 94 c0             	sete   %al
  801f43:	0f b6 c0             	movzbl %al,%eax
}
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    

00801f48 <opencons>:

int
opencons(void)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	e8 39 f3 ff ff       	call   801290 <fd_alloc>
  801f57:	83 c4 10             	add    $0x10,%esp
		return r;
  801f5a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 3e                	js     801f9e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	68 07 04 00 00       	push   $0x407
  801f68:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6b:	6a 00                	push   $0x0
  801f6d:	e8 49 ee ff ff       	call   800dbb <sys_page_alloc>
  801f72:	83 c4 10             	add    $0x10,%esp
		return r;
  801f75:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 23                	js     801f9e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f7b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f84:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f89:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	50                   	push   %eax
  801f94:	e8 d0 f2 ff ff       	call   801269 <fd2num>
  801f99:	89 c2                	mov    %eax,%edx
  801f9b:	83 c4 10             	add    $0x10,%esp
}
  801f9e:	89 d0                	mov    %edx,%eax
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fa8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801faf:	75 2a                	jne    801fdb <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fb1:	83 ec 04             	sub    $0x4,%esp
  801fb4:	6a 07                	push   $0x7
  801fb6:	68 00 f0 bf ee       	push   $0xeebff000
  801fbb:	6a 00                	push   $0x0
  801fbd:	e8 f9 ed ff ff       	call   800dbb <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	79 12                	jns    801fdb <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fc9:	50                   	push   %eax
  801fca:	68 3c 2a 80 00       	push   $0x802a3c
  801fcf:	6a 23                	push   $0x23
  801fd1:	68 40 2a 80 00       	push   $0x802a40
  801fd6:	e8 7f e3 ff ff       	call   80035a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fe3:	83 ec 08             	sub    $0x8,%esp
  801fe6:	68 0d 20 80 00       	push   $0x80200d
  801feb:	6a 00                	push   $0x0
  801fed:	e8 14 ef ff ff       	call   800f06 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	79 12                	jns    80200b <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ff9:	50                   	push   %eax
  801ffa:	68 3c 2a 80 00       	push   $0x802a3c
  801fff:	6a 2c                	push   $0x2c
  802001:	68 40 2a 80 00       	push   $0x802a40
  802006:	e8 4f e3 ff ff       	call   80035a <_panic>
	}
}
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    

0080200d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80200d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80200e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802013:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802015:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802018:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80201c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802021:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802025:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802027:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80202a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80202b:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80202e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80202f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802030:	c3                   	ret    

00802031 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	56                   	push   %esi
  802035:	53                   	push   %ebx
  802036:	8b 75 08             	mov    0x8(%ebp),%esi
  802039:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80203f:	85 c0                	test   %eax,%eax
  802041:	75 12                	jne    802055 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802043:	83 ec 0c             	sub    $0xc,%esp
  802046:	68 00 00 c0 ee       	push   $0xeec00000
  80204b:	e8 1b ef ff ff       	call   800f6b <sys_ipc_recv>
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	eb 0c                	jmp    802061 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802055:	83 ec 0c             	sub    $0xc,%esp
  802058:	50                   	push   %eax
  802059:	e8 0d ef ff ff       	call   800f6b <sys_ipc_recv>
  80205e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802061:	85 f6                	test   %esi,%esi
  802063:	0f 95 c1             	setne  %cl
  802066:	85 db                	test   %ebx,%ebx
  802068:	0f 95 c2             	setne  %dl
  80206b:	84 d1                	test   %dl,%cl
  80206d:	74 09                	je     802078 <ipc_recv+0x47>
  80206f:	89 c2                	mov    %eax,%edx
  802071:	c1 ea 1f             	shr    $0x1f,%edx
  802074:	84 d2                	test   %dl,%dl
  802076:	75 24                	jne    80209c <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802078:	85 f6                	test   %esi,%esi
  80207a:	74 0a                	je     802086 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80207c:	a1 04 40 80 00       	mov    0x804004,%eax
  802081:	8b 40 74             	mov    0x74(%eax),%eax
  802084:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802086:	85 db                	test   %ebx,%ebx
  802088:	74 0a                	je     802094 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  80208a:	a1 04 40 80 00       	mov    0x804004,%eax
  80208f:	8b 40 78             	mov    0x78(%eax),%eax
  802092:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802094:	a1 04 40 80 00       	mov    0x804004,%eax
  802099:	8b 40 70             	mov    0x70(%eax),%eax
}
  80209c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	57                   	push   %edi
  8020a7:	56                   	push   %esi
  8020a8:	53                   	push   %ebx
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020b5:	85 db                	test   %ebx,%ebx
  8020b7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020bc:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020bf:	ff 75 14             	pushl  0x14(%ebp)
  8020c2:	53                   	push   %ebx
  8020c3:	56                   	push   %esi
  8020c4:	57                   	push   %edi
  8020c5:	e8 7e ee ff ff       	call   800f48 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020ca:	89 c2                	mov    %eax,%edx
  8020cc:	c1 ea 1f             	shr    $0x1f,%edx
  8020cf:	83 c4 10             	add    $0x10,%esp
  8020d2:	84 d2                	test   %dl,%dl
  8020d4:	74 17                	je     8020ed <ipc_send+0x4a>
  8020d6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d9:	74 12                	je     8020ed <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020db:	50                   	push   %eax
  8020dc:	68 4e 2a 80 00       	push   $0x802a4e
  8020e1:	6a 47                	push   $0x47
  8020e3:	68 5c 2a 80 00       	push   $0x802a5c
  8020e8:	e8 6d e2 ff ff       	call   80035a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020ed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020f0:	75 07                	jne    8020f9 <ipc_send+0x56>
			sys_yield();
  8020f2:	e8 a5 ec ff ff       	call   800d9c <sys_yield>
  8020f7:	eb c6                	jmp    8020bf <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	75 c2                	jne    8020bf <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80210b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802110:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802113:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802119:	8b 52 50             	mov    0x50(%edx),%edx
  80211c:	39 ca                	cmp    %ecx,%edx
  80211e:	75 0d                	jne    80212d <ipc_find_env+0x28>
			return envs[i].env_id;
  802120:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802128:	8b 40 48             	mov    0x48(%eax),%eax
  80212b:	eb 0f                	jmp    80213c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80212d:	83 c0 01             	add    $0x1,%eax
  802130:	3d 00 04 00 00       	cmp    $0x400,%eax
  802135:	75 d9                	jne    802110 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    

0080213e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802144:	89 d0                	mov    %edx,%eax
  802146:	c1 e8 16             	shr    $0x16,%eax
  802149:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802150:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802155:	f6 c1 01             	test   $0x1,%cl
  802158:	74 1d                	je     802177 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80215a:	c1 ea 0c             	shr    $0xc,%edx
  80215d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802164:	f6 c2 01             	test   $0x1,%dl
  802167:	74 0e                	je     802177 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802169:	c1 ea 0c             	shr    $0xc,%edx
  80216c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802173:	ef 
  802174:	0f b7 c0             	movzwl %ax,%eax
}
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	66 90                	xchg   %ax,%ax
  80217b:	66 90                	xchg   %ax,%ax
  80217d:	66 90                	xchg   %ax,%ax
  80217f:	90                   	nop

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
