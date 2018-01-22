
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 80 23 80 00       	push   $0x802380
  800043:	e8 f1 18 00 00       	call   801939 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 85 23 80 00       	push   $0x802385
  800057:	6a 0c                	push   $0xc
  800059:	68 93 23 80 00       	push   $0x802393
  80005e:	e8 15 02 00 00       	call   800278 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 a6 15 00 00       	call   801614 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 be 14 00 00       	call   80153f <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 a8 23 80 00       	push   $0x8023a8
  800090:	6a 0f                	push   $0xf
  800092:	68 93 23 80 00       	push   $0x802393
  800097:	e8 dc 01 00 00       	call   800278 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 1f 0f 00 00       	call   800fc0 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 b2 23 80 00       	push   $0x8023b2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 93 23 80 00       	push   $0x802393
  8000b4:	e8 bf 01 00 00       	call   800278 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 48 15 00 00       	call   801614 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  8000d3:	e8 79 02 00 00       	call   800351 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 54 14 00 00       	call   80153f <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 34 24 80 00       	push   $0x802434
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 93 23 80 00       	push   $0x802393
  800103:	e8 70 01 00 00       	call   800278 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 c8 09 00 00       	call   800ae3 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 60 24 80 00       	push   $0x802460
  80012a:	6a 19                	push   $0x19
  80012c:	68 93 23 80 00       	push   $0x802393
  800131:	e8 42 01 00 00       	call   800278 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 bb 23 80 00       	push   $0x8023bb
  80013e:	e8 0e 02 00 00       	call   800351 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 c6 14 00 00       	call   801614 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 1c 12 00 00       	call   801372 <close>
		exit();
  800156:	e8 03 01 00 00       	call   80025e <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 d2 1b 00 00       	call   801d39 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 c5 13 00 00       	call   80153f <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 98 24 80 00       	push   $0x802498
  80018b:	6a 21                	push   $0x21
  80018d:	68 93 23 80 00       	push   $0x802393
  800192:	e8 e1 00 00 00       	call   800278 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 d4 23 80 00       	push   $0x8023d4
  80019f:	e8 ad 01 00 00       	call   800351 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 c6 11 00 00       	call   801372 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001c1:	c7 05 20 44 80 00 00 	movl   $0x0,0x804420
  8001c8:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001cb:	e8 cb 0a 00 00       	call   800c9b <sys_getenvid>
  8001d0:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8001d2:	83 ec 08             	sub    $0x8,%esp
  8001d5:	50                   	push   %eax
  8001d6:	68 bc 24 80 00       	push   $0x8024bc
  8001db:	e8 71 01 00 00       	call   800351 <cprintf>
  8001e0:	8b 3d 20 44 80 00    	mov    0x804420,%edi
  8001e6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8001eb:	83 c4 10             	add    $0x10,%esp
  8001ee:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8001f8:	89 c1                	mov    %eax,%ecx
  8001fa:	c1 e1 07             	shl    $0x7,%ecx
  8001fd:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800204:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800207:	39 cb                	cmp    %ecx,%ebx
  800209:	0f 44 fa             	cmove  %edx,%edi
  80020c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800211:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800214:	83 c0 01             	add    $0x1,%eax
  800217:	81 c2 84 00 00 00    	add    $0x84,%edx
  80021d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800222:	75 d4                	jne    8001f8 <libmain+0x40>
  800224:	89 f0                	mov    %esi,%eax
  800226:	84 c0                	test   %al,%al
  800228:	74 06                	je     800230 <libmain+0x78>
  80022a:	89 3d 20 44 80 00    	mov    %edi,0x804420
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800230:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800234:	7e 0a                	jle    800240 <libmain+0x88>
		binaryname = argv[0];
  800236:	8b 45 0c             	mov    0xc(%ebp),%eax
  800239:	8b 00                	mov    (%eax),%eax
  80023b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	e8 e5 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80024e:	e8 0b 00 00 00       	call   80025e <exit>
}
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800264:	e8 34 11 00 00       	call   80139d <close_all>
	sys_env_destroy(0);
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	6a 00                	push   $0x0
  80026e:	e8 e7 09 00 00       	call   800c5a <sys_env_destroy>
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80027d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800280:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800286:	e8 10 0a 00 00       	call   800c9b <sys_getenvid>
  80028b:	83 ec 0c             	sub    $0xc,%esp
  80028e:	ff 75 0c             	pushl  0xc(%ebp)
  800291:	ff 75 08             	pushl  0x8(%ebp)
  800294:	56                   	push   %esi
  800295:	50                   	push   %eax
  800296:	68 e8 24 80 00       	push   $0x8024e8
  80029b:	e8 b1 00 00 00       	call   800351 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a0:	83 c4 18             	add    $0x18,%esp
  8002a3:	53                   	push   %ebx
  8002a4:	ff 75 10             	pushl  0x10(%ebp)
  8002a7:	e8 54 00 00 00       	call   800300 <vcprintf>
	cprintf("\n");
  8002ac:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  8002b3:	e8 99 00 00 00       	call   800351 <cprintf>
  8002b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002bb:	cc                   	int3   
  8002bc:	eb fd                	jmp    8002bb <_panic+0x43>

008002be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 04             	sub    $0x4,%esp
  8002c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002c8:	8b 13                	mov    (%ebx),%edx
  8002ca:	8d 42 01             	lea    0x1(%edx),%eax
  8002cd:	89 03                	mov    %eax,(%ebx)
  8002cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002db:	75 1a                	jne    8002f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002dd:	83 ec 08             	sub    $0x8,%esp
  8002e0:	68 ff 00 00 00       	push   $0xff
  8002e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e8:	50                   	push   %eax
  8002e9:	e8 2f 09 00 00       	call   800c1d <sys_cputs>
		b->idx = 0;
  8002ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800309:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800310:	00 00 00 
	b.cnt = 0;
  800313:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80031a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80031d:	ff 75 0c             	pushl  0xc(%ebp)
  800320:	ff 75 08             	pushl  0x8(%ebp)
  800323:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800329:	50                   	push   %eax
  80032a:	68 be 02 80 00       	push   $0x8002be
  80032f:	e8 54 01 00 00       	call   800488 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800334:	83 c4 08             	add    $0x8,%esp
  800337:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80033d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800343:	50                   	push   %eax
  800344:	e8 d4 08 00 00       	call   800c1d <sys_cputs>

	return b.cnt;
}
  800349:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80034f:	c9                   	leave  
  800350:	c3                   	ret    

00800351 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800357:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80035a:	50                   	push   %eax
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 9d ff ff ff       	call   800300 <vcprintf>
	va_end(ap);

	return cnt;
}
  800363:	c9                   	leave  
  800364:	c3                   	ret    

00800365 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
  80036b:	83 ec 1c             	sub    $0x1c,%esp
  80036e:	89 c7                	mov    %eax,%edi
  800370:	89 d6                	mov    %edx,%esi
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	8b 55 0c             	mov    0xc(%ebp),%edx
  800378:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80037b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80037e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800381:	bb 00 00 00 00       	mov    $0x0,%ebx
  800386:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800389:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80038c:	39 d3                	cmp    %edx,%ebx
  80038e:	72 05                	jb     800395 <printnum+0x30>
  800390:	39 45 10             	cmp    %eax,0x10(%ebp)
  800393:	77 45                	ja     8003da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800395:	83 ec 0c             	sub    $0xc,%esp
  800398:	ff 75 18             	pushl  0x18(%ebp)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003a1:	53                   	push   %ebx
  8003a2:	ff 75 10             	pushl  0x10(%ebp)
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b4:	e8 37 1d 00 00       	call   8020f0 <__udivdi3>
  8003b9:	83 c4 18             	add    $0x18,%esp
  8003bc:	52                   	push   %edx
  8003bd:	50                   	push   %eax
  8003be:	89 f2                	mov    %esi,%edx
  8003c0:	89 f8                	mov    %edi,%eax
  8003c2:	e8 9e ff ff ff       	call   800365 <printnum>
  8003c7:	83 c4 20             	add    $0x20,%esp
  8003ca:	eb 18                	jmp    8003e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	ff 75 18             	pushl  0x18(%ebp)
  8003d3:	ff d7                	call   *%edi
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	eb 03                	jmp    8003dd <printnum+0x78>
  8003da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003dd:	83 eb 01             	sub    $0x1,%ebx
  8003e0:	85 db                	test   %ebx,%ebx
  8003e2:	7f e8                	jg     8003cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e4:	83 ec 08             	sub    $0x8,%esp
  8003e7:	56                   	push   %esi
  8003e8:	83 ec 04             	sub    $0x4,%esp
  8003eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f7:	e8 24 1e 00 00       	call   802220 <__umoddi3>
  8003fc:	83 c4 14             	add    $0x14,%esp
  8003ff:	0f be 80 0b 25 80 00 	movsbl 0x80250b(%eax),%eax
  800406:	50                   	push   %eax
  800407:	ff d7                	call   *%edi
}
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80040f:	5b                   	pop    %ebx
  800410:	5e                   	pop    %esi
  800411:	5f                   	pop    %edi
  800412:	5d                   	pop    %ebp
  800413:	c3                   	ret    

00800414 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800417:	83 fa 01             	cmp    $0x1,%edx
  80041a:	7e 0e                	jle    80042a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800421:	89 08                	mov    %ecx,(%eax)
  800423:	8b 02                	mov    (%edx),%eax
  800425:	8b 52 04             	mov    0x4(%edx),%edx
  800428:	eb 22                	jmp    80044c <getuint+0x38>
	else if (lflag)
  80042a:	85 d2                	test   %edx,%edx
  80042c:	74 10                	je     80043e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80042e:	8b 10                	mov    (%eax),%edx
  800430:	8d 4a 04             	lea    0x4(%edx),%ecx
  800433:	89 08                	mov    %ecx,(%eax)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	ba 00 00 00 00       	mov    $0x0,%edx
  80043c:	eb 0e                	jmp    80044c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	8d 4a 04             	lea    0x4(%edx),%ecx
  800443:	89 08                	mov    %ecx,(%eax)
  800445:	8b 02                	mov    (%edx),%eax
  800447:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800454:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	3b 50 04             	cmp    0x4(%eax),%edx
  80045d:	73 0a                	jae    800469 <sprintputch+0x1b>
		*b->buf++ = ch;
  80045f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800462:	89 08                	mov    %ecx,(%eax)
  800464:	8b 45 08             	mov    0x8(%ebp),%eax
  800467:	88 02                	mov    %al,(%edx)
}
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800471:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800474:	50                   	push   %eax
  800475:	ff 75 10             	pushl  0x10(%ebp)
  800478:	ff 75 0c             	pushl  0xc(%ebp)
  80047b:	ff 75 08             	pushl  0x8(%ebp)
  80047e:	e8 05 00 00 00       	call   800488 <vprintfmt>
	va_end(ap);
}
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	57                   	push   %edi
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 2c             	sub    $0x2c,%esp
  800491:	8b 75 08             	mov    0x8(%ebp),%esi
  800494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800497:	8b 7d 10             	mov    0x10(%ebp),%edi
  80049a:	eb 12                	jmp    8004ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049c:	85 c0                	test   %eax,%eax
  80049e:	0f 84 89 03 00 00    	je     80082d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	53                   	push   %ebx
  8004a8:	50                   	push   %eax
  8004a9:	ff d6                	call   *%esi
  8004ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ae:	83 c7 01             	add    $0x1,%edi
  8004b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b5:	83 f8 25             	cmp    $0x25,%eax
  8004b8:	75 e2                	jne    80049c <vprintfmt+0x14>
  8004ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	eb 07                	jmp    8004e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8d 47 01             	lea    0x1(%edi),%eax
  8004e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e7:	0f b6 07             	movzbl (%edi),%eax
  8004ea:	0f b6 c8             	movzbl %al,%ecx
  8004ed:	83 e8 23             	sub    $0x23,%eax
  8004f0:	3c 55                	cmp    $0x55,%al
  8004f2:	0f 87 1a 03 00 00    	ja     800812 <vprintfmt+0x38a>
  8004f8:	0f b6 c0             	movzbl %al,%eax
  8004fb:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800505:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800509:	eb d6                	jmp    8004e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050e:	b8 00 00 00 00       	mov    $0x0,%eax
  800513:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800516:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800519:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80051d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800520:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800523:	83 fa 09             	cmp    $0x9,%edx
  800526:	77 39                	ja     800561 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800528:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80052b:	eb e9                	jmp    800516 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 48 04             	lea    0x4(%eax),%ecx
  800533:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80053e:	eb 27                	jmp    800567 <vprintfmt+0xdf>
  800540:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800543:	85 c0                	test   %eax,%eax
  800545:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054a:	0f 49 c8             	cmovns %eax,%ecx
  80054d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800553:	eb 8c                	jmp    8004e1 <vprintfmt+0x59>
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800558:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80055f:	eb 80                	jmp    8004e1 <vprintfmt+0x59>
  800561:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800564:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800567:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80056b:	0f 89 70 ff ff ff    	jns    8004e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800571:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800574:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800577:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80057e:	e9 5e ff ff ff       	jmp    8004e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800583:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800589:	e9 53 ff ff ff       	jmp    8004e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	ff 30                	pushl  (%eax)
  80059d:	ff d6                	call   *%esi
			break;
  80059f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a5:	e9 04 ff ff ff       	jmp    8004ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	99                   	cltd   
  8005b6:	31 d0                	xor    %edx,%eax
  8005b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ba:	83 f8 0f             	cmp    $0xf,%eax
  8005bd:	7f 0b                	jg     8005ca <vprintfmt+0x142>
  8005bf:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	75 18                	jne    8005e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ca:	50                   	push   %eax
  8005cb:	68 23 25 80 00       	push   $0x802523
  8005d0:	53                   	push   %ebx
  8005d1:	56                   	push   %esi
  8005d2:	e8 94 fe ff ff       	call   80046b <printfmt>
  8005d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005dd:	e9 cc fe ff ff       	jmp    8004ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005e2:	52                   	push   %edx
  8005e3:	68 51 29 80 00       	push   $0x802951
  8005e8:	53                   	push   %ebx
  8005e9:	56                   	push   %esi
  8005ea:	e8 7c fe ff ff       	call   80046b <printfmt>
  8005ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f5:	e9 b4 fe ff ff       	jmp    8004ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800605:	85 ff                	test   %edi,%edi
  800607:	b8 1c 25 80 00       	mov    $0x80251c,%eax
  80060c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80060f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800613:	0f 8e 94 00 00 00    	jle    8006ad <vprintfmt+0x225>
  800619:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80061d:	0f 84 98 00 00 00    	je     8006bb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	ff 75 d0             	pushl  -0x30(%ebp)
  800629:	57                   	push   %edi
  80062a:	e8 86 02 00 00       	call   8008b5 <strnlen>
  80062f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800632:	29 c1                	sub    %eax,%ecx
  800634:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800637:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80063a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80063e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800641:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800644:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800646:	eb 0f                	jmp    800657 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	ff 75 e0             	pushl  -0x20(%ebp)
  80064f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800651:	83 ef 01             	sub    $0x1,%edi
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	85 ff                	test   %edi,%edi
  800659:	7f ed                	jg     800648 <vprintfmt+0x1c0>
  80065b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80065e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800661:	85 c9                	test   %ecx,%ecx
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
  800668:	0f 49 c1             	cmovns %ecx,%eax
  80066b:	29 c1                	sub    %eax,%ecx
  80066d:	89 75 08             	mov    %esi,0x8(%ebp)
  800670:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800673:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800676:	89 cb                	mov    %ecx,%ebx
  800678:	eb 4d                	jmp    8006c7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80067a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067e:	74 1b                	je     80069b <vprintfmt+0x213>
  800680:	0f be c0             	movsbl %al,%eax
  800683:	83 e8 20             	sub    $0x20,%eax
  800686:	83 f8 5e             	cmp    $0x5e,%eax
  800689:	76 10                	jbe    80069b <vprintfmt+0x213>
					putch('?', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	ff 75 0c             	pushl  0xc(%ebp)
  800691:	6a 3f                	push   $0x3f
  800693:	ff 55 08             	call   *0x8(%ebp)
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb 0d                	jmp    8006a8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	52                   	push   %edx
  8006a2:	ff 55 08             	call   *0x8(%ebp)
  8006a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a8:	83 eb 01             	sub    $0x1,%ebx
  8006ab:	eb 1a                	jmp    8006c7 <vprintfmt+0x23f>
  8006ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b9:	eb 0c                	jmp    8006c7 <vprintfmt+0x23f>
  8006bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8006be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006c7:	83 c7 01             	add    $0x1,%edi
  8006ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ce:	0f be d0             	movsbl %al,%edx
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	74 23                	je     8006f8 <vprintfmt+0x270>
  8006d5:	85 f6                	test   %esi,%esi
  8006d7:	78 a1                	js     80067a <vprintfmt+0x1f2>
  8006d9:	83 ee 01             	sub    $0x1,%esi
  8006dc:	79 9c                	jns    80067a <vprintfmt+0x1f2>
  8006de:	89 df                	mov    %ebx,%edi
  8006e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e6:	eb 18                	jmp    800700 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 20                	push   $0x20
  8006ee:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f0:	83 ef 01             	sub    $0x1,%edi
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	eb 08                	jmp    800700 <vprintfmt+0x278>
  8006f8:	89 df                	mov    %ebx,%edi
  8006fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800700:	85 ff                	test   %edi,%edi
  800702:	7f e4                	jg     8006e8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800707:	e9 a2 fd ff ff       	jmp    8004ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070c:	83 fa 01             	cmp    $0x1,%edx
  80070f:	7e 16                	jle    800727 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8d 50 08             	lea    0x8(%eax),%edx
  800717:	89 55 14             	mov    %edx,0x14(%ebp)
  80071a:	8b 50 04             	mov    0x4(%eax),%edx
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800722:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800725:	eb 32                	jmp    800759 <vprintfmt+0x2d1>
	else if (lflag)
  800727:	85 d2                	test   %edx,%edx
  800729:	74 18                	je     800743 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8d 50 04             	lea    0x4(%eax),%edx
  800731:	89 55 14             	mov    %edx,0x14(%ebp)
  800734:	8b 00                	mov    (%eax),%eax
  800736:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800739:	89 c1                	mov    %eax,%ecx
  80073b:	c1 f9 1f             	sar    $0x1f,%ecx
  80073e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800741:	eb 16                	jmp    800759 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 50 04             	lea    0x4(%eax),%edx
  800749:	89 55 14             	mov    %edx,0x14(%ebp)
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800751:	89 c1                	mov    %eax,%ecx
  800753:	c1 f9 1f             	sar    $0x1f,%ecx
  800756:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800759:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80075c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80075f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800764:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800768:	79 74                	jns    8007de <vprintfmt+0x356>
				putch('-', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 2d                	push   $0x2d
  800770:	ff d6                	call   *%esi
				num = -(long long) num;
  800772:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800775:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800778:	f7 d8                	neg    %eax
  80077a:	83 d2 00             	adc    $0x0,%edx
  80077d:	f7 da                	neg    %edx
  80077f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800782:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800787:	eb 55                	jmp    8007de <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
  80078c:	e8 83 fc ff ff       	call   800414 <getuint>
			base = 10;
  800791:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800796:	eb 46                	jmp    8007de <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
  80079b:	e8 74 fc ff ff       	call   800414 <getuint>
			base = 8;
  8007a0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007a5:	eb 37                	jmp    8007de <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	6a 30                	push   $0x30
  8007ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	6a 78                	push   $0x78
  8007b5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 04             	lea    0x4(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ca:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007cf:	eb 0d                	jmp    8007de <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d4:	e8 3b fc ff ff       	call   800414 <getuint>
			base = 16;
  8007d9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007de:	83 ec 0c             	sub    $0xc,%esp
  8007e1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007e5:	57                   	push   %edi
  8007e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e9:	51                   	push   %ecx
  8007ea:	52                   	push   %edx
  8007eb:	50                   	push   %eax
  8007ec:	89 da                	mov    %ebx,%edx
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	e8 70 fb ff ff       	call   800365 <printnum>
			break;
  8007f5:	83 c4 20             	add    $0x20,%esp
  8007f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007fb:	e9 ae fc ff ff       	jmp    8004ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	53                   	push   %ebx
  800804:	51                   	push   %ecx
  800805:	ff d6                	call   *%esi
			break;
  800807:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80080d:	e9 9c fc ff ff       	jmp    8004ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	53                   	push   %ebx
  800816:	6a 25                	push   $0x25
  800818:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb 03                	jmp    800822 <vprintfmt+0x39a>
  80081f:	83 ef 01             	sub    $0x1,%edi
  800822:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800826:	75 f7                	jne    80081f <vprintfmt+0x397>
  800828:	e9 81 fc ff ff       	jmp    8004ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80082d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5f                   	pop    %edi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 18             	sub    $0x18,%esp
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800841:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800844:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800848:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80084b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800852:	85 c0                	test   %eax,%eax
  800854:	74 26                	je     80087c <vsnprintf+0x47>
  800856:	85 d2                	test   %edx,%edx
  800858:	7e 22                	jle    80087c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085a:	ff 75 14             	pushl  0x14(%ebp)
  80085d:	ff 75 10             	pushl  0x10(%ebp)
  800860:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800863:	50                   	push   %eax
  800864:	68 4e 04 80 00       	push   $0x80044e
  800869:	e8 1a fc ff ff       	call   800488 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800871:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800874:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800877:	83 c4 10             	add    $0x10,%esp
  80087a:	eb 05                	jmp    800881 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80087c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800889:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80088c:	50                   	push   %eax
  80088d:	ff 75 10             	pushl  0x10(%ebp)
  800890:	ff 75 0c             	pushl  0xc(%ebp)
  800893:	ff 75 08             	pushl  0x8(%ebp)
  800896:	e8 9a ff ff ff       	call   800835 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	eb 03                	jmp    8008ad <strlen+0x10>
		n++;
  8008aa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b1:	75 f7                	jne    8008aa <strlen+0xd>
		n++;
	return n;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008be:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c3:	eb 03                	jmp    8008c8 <strnlen+0x13>
		n++;
  8008c5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c8:	39 c2                	cmp    %eax,%edx
  8008ca:	74 08                	je     8008d4 <strnlen+0x1f>
  8008cc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008d0:	75 f3                	jne    8008c5 <strnlen+0x10>
  8008d2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	53                   	push   %ebx
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	83 c2 01             	add    $0x1,%edx
  8008e5:	83 c1 01             	add    $0x1,%ecx
  8008e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	75 ef                	jne    8008e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fd:	53                   	push   %ebx
  8008fe:	e8 9a ff ff ff       	call   80089d <strlen>
  800903:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	01 d8                	add    %ebx,%eax
  80090b:	50                   	push   %eax
  80090c:	e8 c5 ff ff ff       	call   8008d6 <strcpy>
	return dst;
}
  800911:	89 d8                	mov    %ebx,%eax
  800913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 75 08             	mov    0x8(%ebp),%esi
  800920:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800923:	89 f3                	mov    %esi,%ebx
  800925:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800928:	89 f2                	mov    %esi,%edx
  80092a:	eb 0f                	jmp    80093b <strncpy+0x23>
		*dst++ = *src;
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	0f b6 01             	movzbl (%ecx),%eax
  800932:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800935:	80 39 01             	cmpb   $0x1,(%ecx)
  800938:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	39 da                	cmp    %ebx,%edx
  80093d:	75 ed                	jne    80092c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80093f:	89 f0                	mov    %esi,%eax
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 75 08             	mov    0x8(%ebp),%esi
  80094d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800950:	8b 55 10             	mov    0x10(%ebp),%edx
  800953:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800955:	85 d2                	test   %edx,%edx
  800957:	74 21                	je     80097a <strlcpy+0x35>
  800959:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80095d:	89 f2                	mov    %esi,%edx
  80095f:	eb 09                	jmp    80096a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800961:	83 c2 01             	add    $0x1,%edx
  800964:	83 c1 01             	add    $0x1,%ecx
  800967:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80096a:	39 c2                	cmp    %eax,%edx
  80096c:	74 09                	je     800977 <strlcpy+0x32>
  80096e:	0f b6 19             	movzbl (%ecx),%ebx
  800971:	84 db                	test   %bl,%bl
  800973:	75 ec                	jne    800961 <strlcpy+0x1c>
  800975:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800977:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097a:	29 f0                	sub    %esi,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800989:	eb 06                	jmp    800991 <strcmp+0x11>
		p++, q++;
  80098b:	83 c1 01             	add    $0x1,%ecx
  80098e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800991:	0f b6 01             	movzbl (%ecx),%eax
  800994:	84 c0                	test   %al,%al
  800996:	74 04                	je     80099c <strcmp+0x1c>
  800998:	3a 02                	cmp    (%edx),%al
  80099a:	74 ef                	je     80098b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099c:	0f b6 c0             	movzbl %al,%eax
  80099f:	0f b6 12             	movzbl (%edx),%edx
  8009a2:	29 d0                	sub    %edx,%eax
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 c3                	mov    %eax,%ebx
  8009b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b5:	eb 06                	jmp    8009bd <strncmp+0x17>
		n--, p++, q++;
  8009b7:	83 c0 01             	add    $0x1,%eax
  8009ba:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009bd:	39 d8                	cmp    %ebx,%eax
  8009bf:	74 15                	je     8009d6 <strncmp+0x30>
  8009c1:	0f b6 08             	movzbl (%eax),%ecx
  8009c4:	84 c9                	test   %cl,%cl
  8009c6:	74 04                	je     8009cc <strncmp+0x26>
  8009c8:	3a 0a                	cmp    (%edx),%cl
  8009ca:	74 eb                	je     8009b7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cc:	0f b6 00             	movzbl (%eax),%eax
  8009cf:	0f b6 12             	movzbl (%edx),%edx
  8009d2:	29 d0                	sub    %edx,%eax
  8009d4:	eb 05                	jmp    8009db <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e8:	eb 07                	jmp    8009f1 <strchr+0x13>
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	74 0f                	je     8009fd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	0f b6 10             	movzbl (%eax),%edx
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	75 f2                	jne    8009ea <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a09:	eb 03                	jmp    800a0e <strfind+0xf>
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 04                	je     800a19 <strfind+0x1a>
  800a15:	84 d2                	test   %dl,%dl
  800a17:	75 f2                	jne    800a0b <strfind+0xc>
			break;
	return (char *) s;
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a24:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a27:	85 c9                	test   %ecx,%ecx
  800a29:	74 36                	je     800a61 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a31:	75 28                	jne    800a5b <memset+0x40>
  800a33:	f6 c1 03             	test   $0x3,%cl
  800a36:	75 23                	jne    800a5b <memset+0x40>
		c &= 0xFF;
  800a38:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3c:	89 d3                	mov    %edx,%ebx
  800a3e:	c1 e3 08             	shl    $0x8,%ebx
  800a41:	89 d6                	mov    %edx,%esi
  800a43:	c1 e6 18             	shl    $0x18,%esi
  800a46:	89 d0                	mov    %edx,%eax
  800a48:	c1 e0 10             	shl    $0x10,%eax
  800a4b:	09 f0                	or     %esi,%eax
  800a4d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a4f:	89 d8                	mov    %ebx,%eax
  800a51:	09 d0                	or     %edx,%eax
  800a53:	c1 e9 02             	shr    $0x2,%ecx
  800a56:	fc                   	cld    
  800a57:	f3 ab                	rep stos %eax,%es:(%edi)
  800a59:	eb 06                	jmp    800a61 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	fc                   	cld    
  800a5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a61:	89 f8                	mov    %edi,%eax
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a76:	39 c6                	cmp    %eax,%esi
  800a78:	73 35                	jae    800aaf <memmove+0x47>
  800a7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7d:	39 d0                	cmp    %edx,%eax
  800a7f:	73 2e                	jae    800aaf <memmove+0x47>
		s += n;
		d += n;
  800a81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	89 d6                	mov    %edx,%esi
  800a86:	09 fe                	or     %edi,%esi
  800a88:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8e:	75 13                	jne    800aa3 <memmove+0x3b>
  800a90:	f6 c1 03             	test   $0x3,%cl
  800a93:	75 0e                	jne    800aa3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a95:	83 ef 04             	sub    $0x4,%edi
  800a98:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
  800a9e:	fd                   	std    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 09                	jmp    800aac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa3:	83 ef 01             	sub    $0x1,%edi
  800aa6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aa9:	fd                   	std    
  800aaa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aac:	fc                   	cld    
  800aad:	eb 1d                	jmp    800acc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	89 f2                	mov    %esi,%edx
  800ab1:	09 c2                	or     %eax,%edx
  800ab3:	f6 c2 03             	test   $0x3,%dl
  800ab6:	75 0f                	jne    800ac7 <memmove+0x5f>
  800ab8:	f6 c1 03             	test   $0x3,%cl
  800abb:	75 0a                	jne    800ac7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800abd:	c1 e9 02             	shr    $0x2,%ecx
  800ac0:	89 c7                	mov    %eax,%edi
  800ac2:	fc                   	cld    
  800ac3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac5:	eb 05                	jmp    800acc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	fc                   	cld    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad3:	ff 75 10             	pushl  0x10(%ebp)
  800ad6:	ff 75 0c             	pushl  0xc(%ebp)
  800ad9:	ff 75 08             	pushl  0x8(%ebp)
  800adc:	e8 87 ff ff ff       	call   800a68 <memmove>
}
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aee:	89 c6                	mov    %eax,%esi
  800af0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af3:	eb 1a                	jmp    800b0f <memcmp+0x2c>
		if (*s1 != *s2)
  800af5:	0f b6 08             	movzbl (%eax),%ecx
  800af8:	0f b6 1a             	movzbl (%edx),%ebx
  800afb:	38 d9                	cmp    %bl,%cl
  800afd:	74 0a                	je     800b09 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aff:	0f b6 c1             	movzbl %cl,%eax
  800b02:	0f b6 db             	movzbl %bl,%ebx
  800b05:	29 d8                	sub    %ebx,%eax
  800b07:	eb 0f                	jmp    800b18 <memcmp+0x35>
		s1++, s2++;
  800b09:	83 c0 01             	add    $0x1,%eax
  800b0c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0f:	39 f0                	cmp    %esi,%eax
  800b11:	75 e2                	jne    800af5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	53                   	push   %ebx
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b23:	89 c1                	mov    %eax,%ecx
  800b25:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b28:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b2c:	eb 0a                	jmp    800b38 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2e:	0f b6 10             	movzbl (%eax),%edx
  800b31:	39 da                	cmp    %ebx,%edx
  800b33:	74 07                	je     800b3c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	39 c8                	cmp    %ecx,%eax
  800b3a:	72 f2                	jb     800b2e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4b:	eb 03                	jmp    800b50 <strtol+0x11>
		s++;
  800b4d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b50:	0f b6 01             	movzbl (%ecx),%eax
  800b53:	3c 20                	cmp    $0x20,%al
  800b55:	74 f6                	je     800b4d <strtol+0xe>
  800b57:	3c 09                	cmp    $0x9,%al
  800b59:	74 f2                	je     800b4d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b5b:	3c 2b                	cmp    $0x2b,%al
  800b5d:	75 0a                	jne    800b69 <strtol+0x2a>
		s++;
  800b5f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b62:	bf 00 00 00 00       	mov    $0x0,%edi
  800b67:	eb 11                	jmp    800b7a <strtol+0x3b>
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b6e:	3c 2d                	cmp    $0x2d,%al
  800b70:	75 08                	jne    800b7a <strtol+0x3b>
		s++, neg = 1;
  800b72:	83 c1 01             	add    $0x1,%ecx
  800b75:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b80:	75 15                	jne    800b97 <strtol+0x58>
  800b82:	80 39 30             	cmpb   $0x30,(%ecx)
  800b85:	75 10                	jne    800b97 <strtol+0x58>
  800b87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8b:	75 7c                	jne    800c09 <strtol+0xca>
		s += 2, base = 16;
  800b8d:	83 c1 02             	add    $0x2,%ecx
  800b90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b95:	eb 16                	jmp    800bad <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b97:	85 db                	test   %ebx,%ebx
  800b99:	75 12                	jne    800bad <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b9b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba3:	75 08                	jne    800bad <strtol+0x6e>
		s++, base = 8;
  800ba5:	83 c1 01             	add    $0x1,%ecx
  800ba8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb5:	0f b6 11             	movzbl (%ecx),%edx
  800bb8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bbb:	89 f3                	mov    %esi,%ebx
  800bbd:	80 fb 09             	cmp    $0x9,%bl
  800bc0:	77 08                	ja     800bca <strtol+0x8b>
			dig = *s - '0';
  800bc2:	0f be d2             	movsbl %dl,%edx
  800bc5:	83 ea 30             	sub    $0x30,%edx
  800bc8:	eb 22                	jmp    800bec <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bca:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bcd:	89 f3                	mov    %esi,%ebx
  800bcf:	80 fb 19             	cmp    $0x19,%bl
  800bd2:	77 08                	ja     800bdc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bd4:	0f be d2             	movsbl %dl,%edx
  800bd7:	83 ea 57             	sub    $0x57,%edx
  800bda:	eb 10                	jmp    800bec <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bdc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 16                	ja     800bfc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800be6:	0f be d2             	movsbl %dl,%edx
  800be9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bec:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bef:	7d 0b                	jge    800bfc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bf1:	83 c1 01             	add    $0x1,%ecx
  800bf4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bf8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bfa:	eb b9                	jmp    800bb5 <strtol+0x76>

	if (endptr)
  800bfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c00:	74 0d                	je     800c0f <strtol+0xd0>
		*endptr = (char *) s;
  800c02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c05:	89 0e                	mov    %ecx,(%esi)
  800c07:	eb 06                	jmp    800c0f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c09:	85 db                	test   %ebx,%ebx
  800c0b:	74 98                	je     800ba5 <strtol+0x66>
  800c0d:	eb 9e                	jmp    800bad <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c0f:	89 c2                	mov    %eax,%edx
  800c11:	f7 da                	neg    %edx
  800c13:	85 ff                	test   %edi,%edi
  800c15:	0f 45 c2             	cmovne %edx,%eax
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	b8 00 00 00 00       	mov    $0x0,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 c3                	mov    %eax,%ebx
  800c30:	89 c7                	mov    %eax,%edi
  800c32:	89 c6                	mov    %eax,%esi
  800c34:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c68:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 cb                	mov    %ecx,%ebx
  800c72:	89 cf                	mov    %ecx,%edi
  800c74:	89 ce                	mov    %ecx,%esi
  800c76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 17                	jle    800c93 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	83 ec 0c             	sub    $0xc,%esp
  800c7f:	50                   	push   %eax
  800c80:	6a 03                	push   $0x3
  800c82:	68 ff 27 80 00       	push   $0x8027ff
  800c87:	6a 23                	push   $0x23
  800c89:	68 1c 28 80 00       	push   $0x80281c
  800c8e:	e8 e5 f5 ff ff       	call   800278 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	89 d3                	mov    %edx,%ebx
  800caf:	89 d7                	mov    %edx,%edi
  800cb1:	89 d6                	mov    %edx,%esi
  800cb3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_yield>:

void
sys_yield(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	89 d3                	mov    %edx,%ebx
  800cce:	89 d7                	mov    %edx,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	be 00 00 00 00       	mov    $0x0,%esi
  800ce7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf5:	89 f7                	mov    %esi,%edi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 04                	push   $0x4
  800d03:	68 ff 27 80 00       	push   $0x8027ff
  800d08:	6a 23                	push   $0x23
  800d0a:	68 1c 28 80 00       	push   $0x80281c
  800d0f:	e8 64 f5 ff ff       	call   800278 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d36:	8b 75 18             	mov    0x18(%ebp),%esi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 05                	push   $0x5
  800d45:	68 ff 27 80 00       	push   $0x8027ff
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 1c 28 80 00       	push   $0x80281c
  800d51:	e8 22 f5 ff ff       	call   800278 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 06                	push   $0x6
  800d87:	68 ff 27 80 00       	push   $0x8027ff
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 1c 28 80 00       	push   $0x80281c
  800d93:	e8 e0 f4 ff ff       	call   800278 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 08 00 00 00       	mov    $0x8,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 08                	push   $0x8
  800dc9:	68 ff 27 80 00       	push   $0x8027ff
  800dce:	6a 23                	push   $0x23
  800dd0:	68 1c 28 80 00       	push   $0x80281c
  800dd5:	e8 9e f4 ff ff       	call   800278 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 09 00 00 00       	mov    $0x9,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 09                	push   $0x9
  800e0b:	68 ff 27 80 00       	push   $0x8027ff
  800e10:	6a 23                	push   $0x23
  800e12:	68 1c 28 80 00       	push   $0x80281c
  800e17:	e8 5c f4 ff ff       	call   800278 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	89 df                	mov    %ebx,%edi
  800e3f:	89 de                	mov    %ebx,%esi
  800e41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 17                	jle    800e5e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	50                   	push   %eax
  800e4b:	6a 0a                	push   $0xa
  800e4d:	68 ff 27 80 00       	push   $0x8027ff
  800e52:	6a 23                	push   $0x23
  800e54:	68 1c 28 80 00       	push   $0x80281c
  800e59:	e8 1a f4 ff ff       	call   800278 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	be 00 00 00 00       	mov    $0x0,%esi
  800e71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 cb                	mov    %ecx,%ebx
  800ea1:	89 cf                	mov    %ecx,%edi
  800ea3:	89 ce                	mov    %ecx,%esi
  800ea5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	7e 17                	jle    800ec2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eab:	83 ec 0c             	sub    $0xc,%esp
  800eae:	50                   	push   %eax
  800eaf:	6a 0d                	push   $0xd
  800eb1:	68 ff 27 80 00       	push   $0x8027ff
  800eb6:	6a 23                	push   $0x23
  800eb8:	68 1c 28 80 00       	push   $0x80281c
  800ebd:	e8 b6 f3 ff ff       	call   800278 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 cb                	mov    %ecx,%ebx
  800edf:	89 cf                	mov    %ecx,%edi
  800ee1:	89 ce                	mov    %ecx,%esi
  800ee3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	53                   	push   %ebx
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ef6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800efa:	74 11                	je     800f0d <pgfault+0x23>
  800efc:	89 d8                	mov    %ebx,%eax
  800efe:	c1 e8 0c             	shr    $0xc,%eax
  800f01:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f08:	f6 c4 08             	test   $0x8,%ah
  800f0b:	75 14                	jne    800f21 <pgfault+0x37>
		panic("faulting access");
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	68 2a 28 80 00       	push   $0x80282a
  800f15:	6a 1d                	push   $0x1d
  800f17:	68 3a 28 80 00       	push   $0x80283a
  800f1c:	e8 57 f3 ff ff       	call   800278 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	6a 07                	push   $0x7
  800f26:	68 00 f0 7f 00       	push   $0x7ff000
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 a7 fd ff ff       	call   800cd9 <sys_page_alloc>
	if (r < 0) {
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	79 12                	jns    800f4b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f39:	50                   	push   %eax
  800f3a:	68 45 28 80 00       	push   $0x802845
  800f3f:	6a 2b                	push   $0x2b
  800f41:	68 3a 28 80 00       	push   $0x80283a
  800f46:	e8 2d f3 ff ff       	call   800278 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f4b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	68 00 10 00 00       	push   $0x1000
  800f59:	53                   	push   %ebx
  800f5a:	68 00 f0 7f 00       	push   $0x7ff000
  800f5f:	e8 6c fb ff ff       	call   800ad0 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f64:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f6b:	53                   	push   %ebx
  800f6c:	6a 00                	push   $0x0
  800f6e:	68 00 f0 7f 00       	push   $0x7ff000
  800f73:	6a 00                	push   $0x0
  800f75:	e8 a2 fd ff ff       	call   800d1c <sys_page_map>
	if (r < 0) {
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 12                	jns    800f93 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f81:	50                   	push   %eax
  800f82:	68 45 28 80 00       	push   $0x802845
  800f87:	6a 32                	push   $0x32
  800f89:	68 3a 28 80 00       	push   $0x80283a
  800f8e:	e8 e5 f2 ff ff       	call   800278 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f93:	83 ec 08             	sub    $0x8,%esp
  800f96:	68 00 f0 7f 00       	push   $0x7ff000
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 bc fd ff ff       	call   800d5e <sys_page_unmap>
	if (r < 0) {
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 12                	jns    800fbb <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fa9:	50                   	push   %eax
  800faa:	68 45 28 80 00       	push   $0x802845
  800faf:	6a 36                	push   $0x36
  800fb1:	68 3a 28 80 00       	push   $0x80283a
  800fb6:	e8 bd f2 ff ff       	call   800278 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
  800fc6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fc9:	68 ea 0e 80 00       	push   $0x800eea
  800fce:	e8 3a 0f 00 00       	call   801f0d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd8:	cd 30                	int    $0x30
  800fda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	79 17                	jns    800ffb <fork+0x3b>
		panic("fork fault %e");
  800fe4:	83 ec 04             	sub    $0x4,%esp
  800fe7:	68 5e 28 80 00       	push   $0x80285e
  800fec:	68 83 00 00 00       	push   $0x83
  800ff1:	68 3a 28 80 00       	push   $0x80283a
  800ff6:	e8 7d f2 ff ff       	call   800278 <_panic>
  800ffb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ffd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801001:	75 25                	jne    801028 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801003:	e8 93 fc ff ff       	call   800c9b <sys_getenvid>
  801008:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100d:	89 c2                	mov    %eax,%edx
  80100f:	c1 e2 07             	shl    $0x7,%edx
  801012:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801019:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80101e:	b8 00 00 00 00       	mov    $0x0,%eax
  801023:	e9 61 01 00 00       	jmp    801189 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	6a 07                	push   $0x7
  80102d:	68 00 f0 bf ee       	push   $0xeebff000
  801032:	ff 75 e4             	pushl  -0x1c(%ebp)
  801035:	e8 9f fc ff ff       	call   800cd9 <sys_page_alloc>
  80103a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80103d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801042:	89 d8                	mov    %ebx,%eax
  801044:	c1 e8 16             	shr    $0x16,%eax
  801047:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104e:	a8 01                	test   $0x1,%al
  801050:	0f 84 fc 00 00 00    	je     801152 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801056:	89 d8                	mov    %ebx,%eax
  801058:	c1 e8 0c             	shr    $0xc,%eax
  80105b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801062:	f6 c2 01             	test   $0x1,%dl
  801065:	0f 84 e7 00 00 00    	je     801152 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80106b:	89 c6                	mov    %eax,%esi
  80106d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801070:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801077:	f6 c6 04             	test   $0x4,%dh
  80107a:	74 39                	je     8010b5 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80107c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	25 07 0e 00 00       	and    $0xe07,%eax
  80108b:	50                   	push   %eax
  80108c:	56                   	push   %esi
  80108d:	57                   	push   %edi
  80108e:	56                   	push   %esi
  80108f:	6a 00                	push   $0x0
  801091:	e8 86 fc ff ff       	call   800d1c <sys_page_map>
		if (r < 0) {
  801096:	83 c4 20             	add    $0x20,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	0f 89 b1 00 00 00    	jns    801152 <fork+0x192>
		    	panic("sys page map fault %e");
  8010a1:	83 ec 04             	sub    $0x4,%esp
  8010a4:	68 6c 28 80 00       	push   $0x80286c
  8010a9:	6a 53                	push   $0x53
  8010ab:	68 3a 28 80 00       	push   $0x80283a
  8010b0:	e8 c3 f1 ff ff       	call   800278 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010b5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bc:	f6 c2 02             	test   $0x2,%dl
  8010bf:	75 0c                	jne    8010cd <fork+0x10d>
  8010c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c8:	f6 c4 08             	test   $0x8,%ah
  8010cb:	74 5b                	je     801128 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	68 05 08 00 00       	push   $0x805
  8010d5:	56                   	push   %esi
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 3d fc ff ff       	call   800d1c <sys_page_map>
		if (r < 0) {
  8010df:	83 c4 20             	add    $0x20,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	79 14                	jns    8010fa <fork+0x13a>
		    	panic("sys page map fault %e");
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	68 6c 28 80 00       	push   $0x80286c
  8010ee:	6a 5a                	push   $0x5a
  8010f0:	68 3a 28 80 00       	push   $0x80283a
  8010f5:	e8 7e f1 ff ff       	call   800278 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	68 05 08 00 00       	push   $0x805
  801102:	56                   	push   %esi
  801103:	6a 00                	push   $0x0
  801105:	56                   	push   %esi
  801106:	6a 00                	push   $0x0
  801108:	e8 0f fc ff ff       	call   800d1c <sys_page_map>
		if (r < 0) {
  80110d:	83 c4 20             	add    $0x20,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	79 3e                	jns    801152 <fork+0x192>
		    	panic("sys page map fault %e");
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	68 6c 28 80 00       	push   $0x80286c
  80111c:	6a 5e                	push   $0x5e
  80111e:	68 3a 28 80 00       	push   $0x80283a
  801123:	e8 50 f1 ff ff       	call   800278 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	6a 05                	push   $0x5
  80112d:	56                   	push   %esi
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	6a 00                	push   $0x0
  801132:	e8 e5 fb ff ff       	call   800d1c <sys_page_map>
		if (r < 0) {
  801137:	83 c4 20             	add    $0x20,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	79 14                	jns    801152 <fork+0x192>
		    	panic("sys page map fault %e");
  80113e:	83 ec 04             	sub    $0x4,%esp
  801141:	68 6c 28 80 00       	push   $0x80286c
  801146:	6a 63                	push   $0x63
  801148:	68 3a 28 80 00       	push   $0x80283a
  80114d:	e8 26 f1 ff ff       	call   800278 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801152:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801158:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80115e:	0f 85 de fe ff ff    	jne    801042 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801164:	a1 20 44 80 00       	mov    0x804420,%eax
  801169:	8b 40 6c             	mov    0x6c(%eax),%eax
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	50                   	push   %eax
  801170:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801173:	57                   	push   %edi
  801174:	e8 ab fc ff ff       	call   800e24 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801179:	83 c4 08             	add    $0x8,%esp
  80117c:	6a 02                	push   $0x2
  80117e:	57                   	push   %edi
  80117f:	e8 1c fc ff ff       	call   800da0 <sys_env_set_status>
	
	return envid;
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <sfork>:

envid_t
sfork(void)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	53                   	push   %ebx
  8011a7:	68 84 28 80 00       	push   $0x802884
  8011ac:	e8 a0 f1 ff ff       	call   800351 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  8011b1:	89 1c 24             	mov    %ebx,(%esp)
  8011b4:	e8 11 fd ff ff       	call   800eca <sys_thread_create>
  8011b9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011bb:	83 c4 08             	add    $0x8,%esp
  8011be:	53                   	push   %ebx
  8011bf:	68 84 28 80 00       	push   $0x802884
  8011c4:	e8 88 f1 ff ff       	call   800351 <cprintf>
	return id;
}
  8011c9:	89 f0                	mov    %esi,%eax
  8011cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011dd:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ff:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801204:	89 c2                	mov    %eax,%edx
  801206:	c1 ea 16             	shr    $0x16,%edx
  801209:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801210:	f6 c2 01             	test   $0x1,%dl
  801213:	74 11                	je     801226 <fd_alloc+0x2d>
  801215:	89 c2                	mov    %eax,%edx
  801217:	c1 ea 0c             	shr    $0xc,%edx
  80121a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801221:	f6 c2 01             	test   $0x1,%dl
  801224:	75 09                	jne    80122f <fd_alloc+0x36>
			*fd_store = fd;
  801226:	89 01                	mov    %eax,(%ecx)
			return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
  80122d:	eb 17                	jmp    801246 <fd_alloc+0x4d>
  80122f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801234:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801239:	75 c9                	jne    801204 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801241:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124e:	83 f8 1f             	cmp    $0x1f,%eax
  801251:	77 36                	ja     801289 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801253:	c1 e0 0c             	shl    $0xc,%eax
  801256:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 16             	shr    $0x16,%edx
  801260:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 24                	je     801290 <fd_lookup+0x48>
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	c1 ea 0c             	shr    $0xc,%edx
  801271:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801278:	f6 c2 01             	test   $0x1,%dl
  80127b:	74 1a                	je     801297 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801280:	89 02                	mov    %eax,(%edx)
	return 0;
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	eb 13                	jmp    80129c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128e:	eb 0c                	jmp    80129c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801295:	eb 05                	jmp    80129c <fd_lookup+0x54>
  801297:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a7:	ba 28 29 80 00       	mov    $0x802928,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ac:	eb 13                	jmp    8012c1 <dev_lookup+0x23>
  8012ae:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b1:	39 08                	cmp    %ecx,(%eax)
  8012b3:	75 0c                	jne    8012c1 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	eb 2e                	jmp    8012ef <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c1:	8b 02                	mov    (%edx),%eax
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	75 e7                	jne    8012ae <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c7:	a1 20 44 80 00       	mov    0x804420,%eax
  8012cc:	8b 40 50             	mov    0x50(%eax),%eax
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	51                   	push   %ecx
  8012d3:	50                   	push   %eax
  8012d4:	68 a8 28 80 00       	push   $0x8028a8
  8012d9:	e8 73 f0 ff ff       	call   800351 <cprintf>
	*dev = 0;
  8012de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 10             	sub    $0x10,%esp
  8012f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801309:	c1 e8 0c             	shr    $0xc,%eax
  80130c:	50                   	push   %eax
  80130d:	e8 36 ff ff ff       	call   801248 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 05                	js     80131e <fd_close+0x2d>
	    || fd != fd2)
  801319:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131c:	74 0c                	je     80132a <fd_close+0x39>
		return (must_exist ? r : 0);
  80131e:	84 db                	test   %bl,%bl
  801320:	ba 00 00 00 00       	mov    $0x0,%edx
  801325:	0f 44 c2             	cmove  %edx,%eax
  801328:	eb 41                	jmp    80136b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 36                	pushl  (%esi)
  801333:	e8 66 ff ff ff       	call   80129e <dev_lookup>
  801338:	89 c3                	mov    %eax,%ebx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 1a                	js     80135b <fd_close+0x6a>
		if (dev->dev_close)
  801341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801344:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134c:	85 c0                	test   %eax,%eax
  80134e:	74 0b                	je     80135b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	56                   	push   %esi
  801354:	ff d0                	call   *%eax
  801356:	89 c3                	mov    %eax,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	56                   	push   %esi
  80135f:	6a 00                	push   $0x0
  801361:	e8 f8 f9 ff ff       	call   800d5e <sys_page_unmap>
	return r;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	89 d8                	mov    %ebx,%eax
}
  80136b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 75 08             	pushl  0x8(%ebp)
  80137f:	e8 c4 fe ff ff       	call   801248 <fd_lookup>
  801384:	83 c4 08             	add    $0x8,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 10                	js     80139b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	6a 01                	push   $0x1
  801390:	ff 75 f4             	pushl  -0xc(%ebp)
  801393:	e8 59 ff ff ff       	call   8012f1 <fd_close>
  801398:	83 c4 10             	add    $0x10,%esp
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <close_all>:

void
close_all(void)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a9:	83 ec 0c             	sub    $0xc,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	e8 c0 ff ff ff       	call   801372 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b2:	83 c3 01             	add    $0x1,%ebx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	83 fb 20             	cmp    $0x20,%ebx
  8013bb:	75 ec                	jne    8013a9 <close_all+0xc>
		close(i);
}
  8013bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 2c             	sub    $0x2c,%esp
  8013cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	ff 75 08             	pushl  0x8(%ebp)
  8013d5:	e8 6e fe ff ff       	call   801248 <fd_lookup>
  8013da:	83 c4 08             	add    $0x8,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	0f 88 c1 00 00 00    	js     8014a6 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	56                   	push   %esi
  8013e9:	e8 84 ff ff ff       	call   801372 <close>

	newfd = INDEX2FD(newfdnum);
  8013ee:	89 f3                	mov    %esi,%ebx
  8013f0:	c1 e3 0c             	shl    $0xc,%ebx
  8013f3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013f9:	83 c4 04             	add    $0x4,%esp
  8013fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ff:	e8 de fd ff ff       	call   8011e2 <fd2data>
  801404:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801406:	89 1c 24             	mov    %ebx,(%esp)
  801409:	e8 d4 fd ff ff       	call   8011e2 <fd2data>
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801414:	89 f8                	mov    %edi,%eax
  801416:	c1 e8 16             	shr    $0x16,%eax
  801419:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801420:	a8 01                	test   $0x1,%al
  801422:	74 37                	je     80145b <dup+0x99>
  801424:	89 f8                	mov    %edi,%eax
  801426:	c1 e8 0c             	shr    $0xc,%eax
  801429:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801430:	f6 c2 01             	test   $0x1,%dl
  801433:	74 26                	je     80145b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801435:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	25 07 0e 00 00       	and    $0xe07,%eax
  801444:	50                   	push   %eax
  801445:	ff 75 d4             	pushl  -0x2c(%ebp)
  801448:	6a 00                	push   $0x0
  80144a:	57                   	push   %edi
  80144b:	6a 00                	push   $0x0
  80144d:	e8 ca f8 ff ff       	call   800d1c <sys_page_map>
  801452:	89 c7                	mov    %eax,%edi
  801454:	83 c4 20             	add    $0x20,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 2e                	js     801489 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80145e:	89 d0                	mov    %edx,%eax
  801460:	c1 e8 0c             	shr    $0xc,%eax
  801463:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146a:	83 ec 0c             	sub    $0xc,%esp
  80146d:	25 07 0e 00 00       	and    $0xe07,%eax
  801472:	50                   	push   %eax
  801473:	53                   	push   %ebx
  801474:	6a 00                	push   $0x0
  801476:	52                   	push   %edx
  801477:	6a 00                	push   $0x0
  801479:	e8 9e f8 ff ff       	call   800d1c <sys_page_map>
  80147e:	89 c7                	mov    %eax,%edi
  801480:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801483:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801485:	85 ff                	test   %edi,%edi
  801487:	79 1d                	jns    8014a6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	6a 00                	push   $0x0
  80148f:	e8 ca f8 ff ff       	call   800d5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801494:	83 c4 08             	add    $0x8,%esp
  801497:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149a:	6a 00                	push   $0x0
  80149c:	e8 bd f8 ff ff       	call   800d5e <sys_page_unmap>
	return r;
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	89 f8                	mov    %edi,%eax
}
  8014a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 14             	sub    $0x14,%esp
  8014b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	53                   	push   %ebx
  8014bd:	e8 86 fd ff ff       	call   801248 <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 6d                	js     801538 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	ff 30                	pushl  (%eax)
  8014d7:	e8 c2 fd ff ff       	call   80129e <dev_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 4c                	js     80152f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e6:	8b 42 08             	mov    0x8(%edx),%eax
  8014e9:	83 e0 03             	and    $0x3,%eax
  8014ec:	83 f8 01             	cmp    $0x1,%eax
  8014ef:	75 21                	jne    801512 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f1:	a1 20 44 80 00       	mov    0x804420,%eax
  8014f6:	8b 40 50             	mov    0x50(%eax),%eax
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	50                   	push   %eax
  8014fe:	68 ec 28 80 00       	push   $0x8028ec
  801503:	e8 49 ee ff ff       	call   800351 <cprintf>
		return -E_INVAL;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801510:	eb 26                	jmp    801538 <read+0x8a>
	}
	if (!dev->dev_read)
  801512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801515:	8b 40 08             	mov    0x8(%eax),%eax
  801518:	85 c0                	test   %eax,%eax
  80151a:	74 17                	je     801533 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	ff 75 10             	pushl  0x10(%ebp)
  801522:	ff 75 0c             	pushl  0xc(%ebp)
  801525:	52                   	push   %edx
  801526:	ff d0                	call   *%eax
  801528:	89 c2                	mov    %eax,%edx
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	eb 09                	jmp    801538 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	89 c2                	mov    %eax,%edx
  801531:	eb 05                	jmp    801538 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801533:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801538:	89 d0                	mov    %edx,%eax
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	57                   	push   %edi
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801553:	eb 21                	jmp    801576 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	89 f0                	mov    %esi,%eax
  80155a:	29 d8                	sub    %ebx,%eax
  80155c:	50                   	push   %eax
  80155d:	89 d8                	mov    %ebx,%eax
  80155f:	03 45 0c             	add    0xc(%ebp),%eax
  801562:	50                   	push   %eax
  801563:	57                   	push   %edi
  801564:	e8 45 ff ff ff       	call   8014ae <read>
		if (m < 0)
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 10                	js     801580 <readn+0x41>
			return m;
		if (m == 0)
  801570:	85 c0                	test   %eax,%eax
  801572:	74 0a                	je     80157e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801574:	01 c3                	add    %eax,%ebx
  801576:	39 f3                	cmp    %esi,%ebx
  801578:	72 db                	jb     801555 <readn+0x16>
  80157a:	89 d8                	mov    %ebx,%eax
  80157c:	eb 02                	jmp    801580 <readn+0x41>
  80157e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801580:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5f                   	pop    %edi
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	53                   	push   %ebx
  80158c:	83 ec 14             	sub    $0x14,%esp
  80158f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801592:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	53                   	push   %ebx
  801597:	e8 ac fc ff ff       	call   801248 <fd_lookup>
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	89 c2                	mov    %eax,%edx
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 68                	js     80160d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015af:	ff 30                	pushl  (%eax)
  8015b1:	e8 e8 fc ff ff       	call   80129e <dev_lookup>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 47                	js     801604 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c4:	75 21                	jne    8015e7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c6:	a1 20 44 80 00       	mov    0x804420,%eax
  8015cb:	8b 40 50             	mov    0x50(%eax),%eax
  8015ce:	83 ec 04             	sub    $0x4,%esp
  8015d1:	53                   	push   %ebx
  8015d2:	50                   	push   %eax
  8015d3:	68 08 29 80 00       	push   $0x802908
  8015d8:	e8 74 ed ff ff       	call   800351 <cprintf>
		return -E_INVAL;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e5:	eb 26                	jmp    80160d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ed:	85 d2                	test   %edx,%edx
  8015ef:	74 17                	je     801608 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f1:	83 ec 04             	sub    $0x4,%esp
  8015f4:	ff 75 10             	pushl  0x10(%ebp)
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	50                   	push   %eax
  8015fb:	ff d2                	call   *%edx
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb 09                	jmp    80160d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	89 c2                	mov    %eax,%edx
  801606:	eb 05                	jmp    80160d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801608:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160d:	89 d0                	mov    %edx,%eax
  80160f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <seek>:

int
seek(int fdnum, off_t offset)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	ff 75 08             	pushl  0x8(%ebp)
  801621:	e8 22 fc ff ff       	call   801248 <fd_lookup>
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 0e                	js     80163b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801630:	8b 55 0c             	mov    0xc(%ebp),%edx
  801633:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801636:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 14             	sub    $0x14,%esp
  801644:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	53                   	push   %ebx
  80164c:	e8 f7 fb ff ff       	call   801248 <fd_lookup>
  801651:	83 c4 08             	add    $0x8,%esp
  801654:	89 c2                	mov    %eax,%edx
  801656:	85 c0                	test   %eax,%eax
  801658:	78 65                	js     8016bf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801664:	ff 30                	pushl  (%eax)
  801666:	e8 33 fc ff ff       	call   80129e <dev_lookup>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 44                	js     8016b6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801679:	75 21                	jne    80169c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167b:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801680:	8b 40 50             	mov    0x50(%eax),%eax
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	53                   	push   %ebx
  801687:	50                   	push   %eax
  801688:	68 c8 28 80 00       	push   $0x8028c8
  80168d:	e8 bf ec ff ff       	call   800351 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169a:	eb 23                	jmp    8016bf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169f:	8b 52 18             	mov    0x18(%edx),%edx
  8016a2:	85 d2                	test   %edx,%edx
  8016a4:	74 14                	je     8016ba <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	50                   	push   %eax
  8016ad:	ff d2                	call   *%edx
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	eb 09                	jmp    8016bf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	eb 05                	jmp    8016bf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016bf:	89 d0                	mov    %edx,%eax
  8016c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 14             	sub    $0x14,%esp
  8016cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	ff 75 08             	pushl  0x8(%ebp)
  8016d7:	e8 6c fb ff ff       	call   801248 <fd_lookup>
  8016dc:	83 c4 08             	add    $0x8,%esp
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 58                	js     80173d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	ff 30                	pushl  (%eax)
  8016f1:	e8 a8 fb ff ff       	call   80129e <dev_lookup>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 37                	js     801734 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801700:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801704:	74 32                	je     801738 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801706:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801709:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801710:	00 00 00 
	stat->st_isdir = 0;
  801713:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171a:	00 00 00 
	stat->st_dev = dev;
  80171d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	53                   	push   %ebx
  801727:	ff 75 f0             	pushl  -0x10(%ebp)
  80172a:	ff 50 14             	call   *0x14(%eax)
  80172d:	89 c2                	mov    %eax,%edx
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	eb 09                	jmp    80173d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	89 c2                	mov    %eax,%edx
  801736:	eb 05                	jmp    80173d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801738:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173d:	89 d0                	mov    %edx,%eax
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	6a 00                	push   $0x0
  80174e:	ff 75 08             	pushl  0x8(%ebp)
  801751:	e8 e3 01 00 00       	call   801939 <open>
  801756:	89 c3                	mov    %eax,%ebx
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 1b                	js     80177a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	50                   	push   %eax
  801766:	e8 5b ff ff ff       	call   8016c6 <fstat>
  80176b:	89 c6                	mov    %eax,%esi
	close(fd);
  80176d:	89 1c 24             	mov    %ebx,(%esp)
  801770:	e8 fd fb ff ff       	call   801372 <close>
	return r;
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	89 f0                	mov    %esi,%eax
}
  80177a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	89 c6                	mov    %eax,%esi
  801788:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80178a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801791:	75 12                	jne    8017a5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	6a 01                	push   $0x1
  801798:	e8 d6 08 00 00       	call   802073 <ipc_find_env>
  80179d:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a5:	6a 07                	push   $0x7
  8017a7:	68 00 50 80 00       	push   $0x805000
  8017ac:	56                   	push   %esi
  8017ad:	ff 35 00 40 80 00    	pushl  0x804000
  8017b3:	e8 59 08 00 00       	call   802011 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b8:	83 c4 0c             	add    $0xc,%esp
  8017bb:	6a 00                	push   $0x0
  8017bd:	53                   	push   %ebx
  8017be:	6a 00                	push   $0x0
  8017c0:	e8 d7 07 00 00       	call   801f9c <ipc_recv>
}
  8017c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ef:	e8 8d ff ff ff       	call   801781 <fsipc>
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801802:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801807:	ba 00 00 00 00       	mov    $0x0,%edx
  80180c:	b8 06 00 00 00       	mov    $0x6,%eax
  801811:	e8 6b ff ff ff       	call   801781 <fsipc>
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	53                   	push   %ebx
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	8b 40 0c             	mov    0xc(%eax),%eax
  801828:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 05 00 00 00       	mov    $0x5,%eax
  801837:	e8 45 ff ff ff       	call   801781 <fsipc>
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 2c                	js     80186c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	68 00 50 80 00       	push   $0x805000
  801848:	53                   	push   %ebx
  801849:	e8 88 f0 ff ff       	call   8008d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184e:	a1 80 50 80 00       	mov    0x805080,%eax
  801853:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801859:	a1 84 50 80 00       	mov    0x805084,%eax
  80185e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	83 ec 0c             	sub    $0xc,%esp
  801877:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187a:	8b 55 08             	mov    0x8(%ebp),%edx
  80187d:	8b 52 0c             	mov    0xc(%edx),%edx
  801880:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801886:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80188b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801890:	0f 47 c2             	cmova  %edx,%eax
  801893:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801898:	50                   	push   %eax
  801899:	ff 75 0c             	pushl  0xc(%ebp)
  80189c:	68 08 50 80 00       	push   $0x805008
  8018a1:	e8 c2 f1 ff ff       	call   800a68 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b0:	e8 cc fe ff ff       	call   801781 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	56                   	push   %esi
  8018bb:	53                   	push   %ebx
  8018bc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018ca:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 03 00 00 00       	mov    $0x3,%eax
  8018da:	e8 a2 fe ff ff       	call   801781 <fsipc>
  8018df:	89 c3                	mov    %eax,%ebx
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 4b                	js     801930 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e5:	39 c6                	cmp    %eax,%esi
  8018e7:	73 16                	jae    8018ff <devfile_read+0x48>
  8018e9:	68 38 29 80 00       	push   $0x802938
  8018ee:	68 3f 29 80 00       	push   $0x80293f
  8018f3:	6a 7c                	push   $0x7c
  8018f5:	68 54 29 80 00       	push   $0x802954
  8018fa:	e8 79 e9 ff ff       	call   800278 <_panic>
	assert(r <= PGSIZE);
  8018ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801904:	7e 16                	jle    80191c <devfile_read+0x65>
  801906:	68 5f 29 80 00       	push   $0x80295f
  80190b:	68 3f 29 80 00       	push   $0x80293f
  801910:	6a 7d                	push   $0x7d
  801912:	68 54 29 80 00       	push   $0x802954
  801917:	e8 5c e9 ff ff       	call   800278 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80191c:	83 ec 04             	sub    $0x4,%esp
  80191f:	50                   	push   %eax
  801920:	68 00 50 80 00       	push   $0x805000
  801925:	ff 75 0c             	pushl  0xc(%ebp)
  801928:	e8 3b f1 ff ff       	call   800a68 <memmove>
	return r;
  80192d:	83 c4 10             	add    $0x10,%esp
}
  801930:	89 d8                	mov    %ebx,%eax
  801932:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    

00801939 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	53                   	push   %ebx
  80193d:	83 ec 20             	sub    $0x20,%esp
  801940:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801943:	53                   	push   %ebx
  801944:	e8 54 ef ff ff       	call   80089d <strlen>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801951:	7f 67                	jg     8019ba <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801959:	50                   	push   %eax
  80195a:	e8 9a f8 ff ff       	call   8011f9 <fd_alloc>
  80195f:	83 c4 10             	add    $0x10,%esp
		return r;
  801962:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801964:	85 c0                	test   %eax,%eax
  801966:	78 57                	js     8019bf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	53                   	push   %ebx
  80196c:	68 00 50 80 00       	push   $0x805000
  801971:	e8 60 ef ff ff       	call   8008d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801976:	8b 45 0c             	mov    0xc(%ebp),%eax
  801979:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80197e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801981:	b8 01 00 00 00       	mov    $0x1,%eax
  801986:	e8 f6 fd ff ff       	call   801781 <fsipc>
  80198b:	89 c3                	mov    %eax,%ebx
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	85 c0                	test   %eax,%eax
  801992:	79 14                	jns    8019a8 <open+0x6f>
		fd_close(fd, 0);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	6a 00                	push   $0x0
  801999:	ff 75 f4             	pushl  -0xc(%ebp)
  80199c:	e8 50 f9 ff ff       	call   8012f1 <fd_close>
		return r;
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	89 da                	mov    %ebx,%edx
  8019a6:	eb 17                	jmp    8019bf <open+0x86>
	}

	return fd2num(fd);
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ae:	e8 1f f8 ff ff       	call   8011d2 <fd2num>
  8019b3:	89 c2                	mov    %eax,%edx
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	eb 05                	jmp    8019bf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ba:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019bf:	89 d0                	mov    %edx,%eax
  8019c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d6:	e8 a6 fd ff ff       	call   801781 <fsipc>
}
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	ff 75 08             	pushl  0x8(%ebp)
  8019eb:	e8 f2 f7 ff ff       	call   8011e2 <fd2data>
  8019f0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019f2:	83 c4 08             	add    $0x8,%esp
  8019f5:	68 6b 29 80 00       	push   $0x80296b
  8019fa:	53                   	push   %ebx
  8019fb:	e8 d6 ee ff ff       	call   8008d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a00:	8b 46 04             	mov    0x4(%esi),%eax
  801a03:	2b 06                	sub    (%esi),%eax
  801a05:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a0b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a12:	00 00 00 
	stat->st_dev = &devpipe;
  801a15:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a1c:	30 80 00 
	return 0;
}
  801a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	53                   	push   %ebx
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a35:	53                   	push   %ebx
  801a36:	6a 00                	push   $0x0
  801a38:	e8 21 f3 ff ff       	call   800d5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a3d:	89 1c 24             	mov    %ebx,(%esp)
  801a40:	e8 9d f7 ff ff       	call   8011e2 <fd2data>
  801a45:	83 c4 08             	add    $0x8,%esp
  801a48:	50                   	push   %eax
  801a49:	6a 00                	push   $0x0
  801a4b:	e8 0e f3 ff ff       	call   800d5e <sys_page_unmap>
}
  801a50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	57                   	push   %edi
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	83 ec 1c             	sub    $0x1c,%esp
  801a5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a61:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a63:	a1 20 44 80 00       	mov    0x804420,%eax
  801a68:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a71:	e8 3d 06 00 00       	call   8020b3 <pageref>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	89 3c 24             	mov    %edi,(%esp)
  801a7b:	e8 33 06 00 00       	call   8020b3 <pageref>
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	39 c3                	cmp    %eax,%ebx
  801a85:	0f 94 c1             	sete   %cl
  801a88:	0f b6 c9             	movzbl %cl,%ecx
  801a8b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a8e:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a94:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801a97:	39 ce                	cmp    %ecx,%esi
  801a99:	74 1b                	je     801ab6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a9b:	39 c3                	cmp    %eax,%ebx
  801a9d:	75 c4                	jne    801a63 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a9f:	8b 42 60             	mov    0x60(%edx),%eax
  801aa2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa5:	50                   	push   %eax
  801aa6:	56                   	push   %esi
  801aa7:	68 72 29 80 00       	push   $0x802972
  801aac:	e8 a0 e8 ff ff       	call   800351 <cprintf>
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	eb ad                	jmp    801a63 <_pipeisclosed+0xe>
	}
}
  801ab6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5f                   	pop    %edi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	57                   	push   %edi
  801ac5:	56                   	push   %esi
  801ac6:	53                   	push   %ebx
  801ac7:	83 ec 28             	sub    $0x28,%esp
  801aca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801acd:	56                   	push   %esi
  801ace:	e8 0f f7 ff ff       	call   8011e2 <fd2data>
  801ad3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	bf 00 00 00 00       	mov    $0x0,%edi
  801add:	eb 4b                	jmp    801b2a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801adf:	89 da                	mov    %ebx,%edx
  801ae1:	89 f0                	mov    %esi,%eax
  801ae3:	e8 6d ff ff ff       	call   801a55 <_pipeisclosed>
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	75 48                	jne    801b34 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aec:	e8 c9 f1 ff ff       	call   800cba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801af1:	8b 43 04             	mov    0x4(%ebx),%eax
  801af4:	8b 0b                	mov    (%ebx),%ecx
  801af6:	8d 51 20             	lea    0x20(%ecx),%edx
  801af9:	39 d0                	cmp    %edx,%eax
  801afb:	73 e2                	jae    801adf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b00:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b04:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b07:	89 c2                	mov    %eax,%edx
  801b09:	c1 fa 1f             	sar    $0x1f,%edx
  801b0c:	89 d1                	mov    %edx,%ecx
  801b0e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b11:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b14:	83 e2 1f             	and    $0x1f,%edx
  801b17:	29 ca                	sub    %ecx,%edx
  801b19:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b1d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b21:	83 c0 01             	add    $0x1,%eax
  801b24:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b27:	83 c7 01             	add    $0x1,%edi
  801b2a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b2d:	75 c2                	jne    801af1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b2f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b32:	eb 05                	jmp    801b39 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	57                   	push   %edi
  801b45:	56                   	push   %esi
  801b46:	53                   	push   %ebx
  801b47:	83 ec 18             	sub    $0x18,%esp
  801b4a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b4d:	57                   	push   %edi
  801b4e:	e8 8f f6 ff ff       	call   8011e2 <fd2data>
  801b53:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b5d:	eb 3d                	jmp    801b9c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b5f:	85 db                	test   %ebx,%ebx
  801b61:	74 04                	je     801b67 <devpipe_read+0x26>
				return i;
  801b63:	89 d8                	mov    %ebx,%eax
  801b65:	eb 44                	jmp    801bab <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b67:	89 f2                	mov    %esi,%edx
  801b69:	89 f8                	mov    %edi,%eax
  801b6b:	e8 e5 fe ff ff       	call   801a55 <_pipeisclosed>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	75 32                	jne    801ba6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b74:	e8 41 f1 ff ff       	call   800cba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b79:	8b 06                	mov    (%esi),%eax
  801b7b:	3b 46 04             	cmp    0x4(%esi),%eax
  801b7e:	74 df                	je     801b5f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b80:	99                   	cltd   
  801b81:	c1 ea 1b             	shr    $0x1b,%edx
  801b84:	01 d0                	add    %edx,%eax
  801b86:	83 e0 1f             	and    $0x1f,%eax
  801b89:	29 d0                	sub    %edx,%eax
  801b8b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b93:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b96:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b99:	83 c3 01             	add    $0x1,%ebx
  801b9c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b9f:	75 d8                	jne    801b79 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba4:	eb 05                	jmp    801bab <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5f                   	pop    %edi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbe:	50                   	push   %eax
  801bbf:	e8 35 f6 ff ff       	call   8011f9 <fd_alloc>
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	0f 88 2c 01 00 00    	js     801cfd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd1:	83 ec 04             	sub    $0x4,%esp
  801bd4:	68 07 04 00 00       	push   $0x407
  801bd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 f6 f0 ff ff       	call   800cd9 <sys_page_alloc>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	89 c2                	mov    %eax,%edx
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 0d 01 00 00    	js     801cfd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf6:	50                   	push   %eax
  801bf7:	e8 fd f5 ff ff       	call   8011f9 <fd_alloc>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	85 c0                	test   %eax,%eax
  801c03:	0f 88 e2 00 00 00    	js     801ceb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c09:	83 ec 04             	sub    $0x4,%esp
  801c0c:	68 07 04 00 00       	push   $0x407
  801c11:	ff 75 f0             	pushl  -0x10(%ebp)
  801c14:	6a 00                	push   $0x0
  801c16:	e8 be f0 ff ff       	call   800cd9 <sys_page_alloc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 c3 00 00 00    	js     801ceb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c28:	83 ec 0c             	sub    $0xc,%esp
  801c2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2e:	e8 af f5 ff ff       	call   8011e2 <fd2data>
  801c33:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 c4 0c             	add    $0xc,%esp
  801c38:	68 07 04 00 00       	push   $0x407
  801c3d:	50                   	push   %eax
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 94 f0 ff ff       	call   800cd9 <sys_page_alloc>
  801c45:	89 c3                	mov    %eax,%ebx
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	0f 88 89 00 00 00    	js     801cdb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c52:	83 ec 0c             	sub    $0xc,%esp
  801c55:	ff 75 f0             	pushl  -0x10(%ebp)
  801c58:	e8 85 f5 ff ff       	call   8011e2 <fd2data>
  801c5d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c64:	50                   	push   %eax
  801c65:	6a 00                	push   $0x0
  801c67:	56                   	push   %esi
  801c68:	6a 00                	push   $0x0
  801c6a:	e8 ad f0 ff ff       	call   800d1c <sys_page_map>
  801c6f:	89 c3                	mov    %eax,%ebx
  801c71:	83 c4 20             	add    $0x20,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 55                	js     801ccd <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c78:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c81:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c8d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c96:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca8:	e8 25 f5 ff ff       	call   8011d2 <fd2num>
  801cad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cb2:	83 c4 04             	add    $0x4,%esp
  801cb5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb8:	e8 15 f5 ff ff       	call   8011d2 <fd2num>
  801cbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc0:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccb:	eb 30                	jmp    801cfd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ccd:	83 ec 08             	sub    $0x8,%esp
  801cd0:	56                   	push   %esi
  801cd1:	6a 00                	push   $0x0
  801cd3:	e8 86 f0 ff ff       	call   800d5e <sys_page_unmap>
  801cd8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cdb:	83 ec 08             	sub    $0x8,%esp
  801cde:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 76 f0 ff ff       	call   800d5e <sys_page_unmap>
  801ce8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ceb:	83 ec 08             	sub    $0x8,%esp
  801cee:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf1:	6a 00                	push   $0x0
  801cf3:	e8 66 f0 ff ff       	call   800d5e <sys_page_unmap>
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cfd:	89 d0                	mov    %edx,%eax
  801cff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d02:	5b                   	pop    %ebx
  801d03:	5e                   	pop    %esi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0f:	50                   	push   %eax
  801d10:	ff 75 08             	pushl  0x8(%ebp)
  801d13:	e8 30 f5 ff ff       	call   801248 <fd_lookup>
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 18                	js     801d37 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff 75 f4             	pushl  -0xc(%ebp)
  801d25:	e8 b8 f4 ff ff       	call   8011e2 <fd2data>
	return _pipeisclosed(fd, p);
  801d2a:	89 c2                	mov    %eax,%edx
  801d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2f:	e8 21 fd ff ff       	call   801a55 <_pipeisclosed>
  801d34:	83 c4 10             	add    $0x10,%esp
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d41:	85 f6                	test   %esi,%esi
  801d43:	75 16                	jne    801d5b <wait+0x22>
  801d45:	68 8a 29 80 00       	push   $0x80298a
  801d4a:	68 3f 29 80 00       	push   $0x80293f
  801d4f:	6a 09                	push   $0x9
  801d51:	68 95 29 80 00       	push   $0x802995
  801d56:	e8 1d e5 ff ff       	call   800278 <_panic>
	e = &envs[ENVX(envid)];
  801d5b:	89 f0                	mov    %esi,%eax
  801d5d:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d62:	89 c2                	mov    %eax,%edx
  801d64:	c1 e2 07             	shl    $0x7,%edx
  801d67:	8d 9c 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%ebx
  801d6e:	eb 05                	jmp    801d75 <wait+0x3c>
		sys_yield();
  801d70:	e8 45 ef ff ff       	call   800cba <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d75:	8b 43 50             	mov    0x50(%ebx),%eax
  801d78:	39 c6                	cmp    %eax,%esi
  801d7a:	75 07                	jne    801d83 <wait+0x4a>
  801d7c:	8b 43 5c             	mov    0x5c(%ebx),%eax
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	75 ed                	jne    801d70 <wait+0x37>
		sys_yield();
}
  801d83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d9a:	68 a0 29 80 00       	push   $0x8029a0
  801d9f:	ff 75 0c             	pushl  0xc(%ebp)
  801da2:	e8 2f eb ff ff       	call   8008d6 <strcpy>
	return 0;
}
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dba:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dbf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc5:	eb 2d                	jmp    801df4 <devcons_write+0x46>
		m = n - tot;
  801dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dca:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dcc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dcf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dd4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd7:	83 ec 04             	sub    $0x4,%esp
  801dda:	53                   	push   %ebx
  801ddb:	03 45 0c             	add    0xc(%ebp),%eax
  801dde:	50                   	push   %eax
  801ddf:	57                   	push   %edi
  801de0:	e8 83 ec ff ff       	call   800a68 <memmove>
		sys_cputs(buf, m);
  801de5:	83 c4 08             	add    $0x8,%esp
  801de8:	53                   	push   %ebx
  801de9:	57                   	push   %edi
  801dea:	e8 2e ee ff ff       	call   800c1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801def:	01 de                	add    %ebx,%esi
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	89 f0                	mov    %esi,%eax
  801df6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df9:	72 cc                	jb     801dc7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    

00801e03 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 08             	sub    $0x8,%esp
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e12:	74 2a                	je     801e3e <devcons_read+0x3b>
  801e14:	eb 05                	jmp    801e1b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e16:	e8 9f ee ff ff       	call   800cba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e1b:	e8 1b ee ff ff       	call   800c3b <sys_cgetc>
  801e20:	85 c0                	test   %eax,%eax
  801e22:	74 f2                	je     801e16 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e24:	85 c0                	test   %eax,%eax
  801e26:	78 16                	js     801e3e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e28:	83 f8 04             	cmp    $0x4,%eax
  801e2b:	74 0c                	je     801e39 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e30:	88 02                	mov    %al,(%edx)
	return 1;
  801e32:	b8 01 00 00 00       	mov    $0x1,%eax
  801e37:	eb 05                	jmp    801e3e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e39:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e46:	8b 45 08             	mov    0x8(%ebp),%eax
  801e49:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e4c:	6a 01                	push   $0x1
  801e4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e51:	50                   	push   %eax
  801e52:	e8 c6 ed ff ff       	call   800c1d <sys_cputs>
}
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <getchar>:

int
getchar(void)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e62:	6a 01                	push   $0x1
  801e64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e67:	50                   	push   %eax
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 3f f6 ff ff       	call   8014ae <read>
	if (r < 0)
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	85 c0                	test   %eax,%eax
  801e74:	78 0f                	js     801e85 <getchar+0x29>
		return r;
	if (r < 1)
  801e76:	85 c0                	test   %eax,%eax
  801e78:	7e 06                	jle    801e80 <getchar+0x24>
		return -E_EOF;
	return c;
  801e7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e7e:	eb 05                	jmp    801e85 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e80:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e85:	c9                   	leave  
  801e86:	c3                   	ret    

00801e87 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e90:	50                   	push   %eax
  801e91:	ff 75 08             	pushl  0x8(%ebp)
  801e94:	e8 af f3 ff ff       	call   801248 <fd_lookup>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 11                	js     801eb1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea9:	39 10                	cmp    %edx,(%eax)
  801eab:	0f 94 c0             	sete   %al
  801eae:	0f b6 c0             	movzbl %al,%eax
}
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <opencons>:

int
opencons(void)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebc:	50                   	push   %eax
  801ebd:	e8 37 f3 ff ff       	call   8011f9 <fd_alloc>
  801ec2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 3e                	js     801f09 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	68 07 04 00 00       	push   $0x407
  801ed3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 fc ed ff ff       	call   800cd9 <sys_page_alloc>
  801edd:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 23                	js     801f09 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ee6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	50                   	push   %eax
  801eff:	e8 ce f2 ff ff       	call   8011d2 <fd2num>
  801f04:	89 c2                	mov    %eax,%edx
  801f06:	83 c4 10             	add    $0x10,%esp
}
  801f09:	89 d0                	mov    %edx,%eax
  801f0b:	c9                   	leave  
  801f0c:	c3                   	ret    

00801f0d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f13:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f1a:	75 2a                	jne    801f46 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f1c:	83 ec 04             	sub    $0x4,%esp
  801f1f:	6a 07                	push   $0x7
  801f21:	68 00 f0 bf ee       	push   $0xeebff000
  801f26:	6a 00                	push   $0x0
  801f28:	e8 ac ed ff ff       	call   800cd9 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	85 c0                	test   %eax,%eax
  801f32:	79 12                	jns    801f46 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f34:	50                   	push   %eax
  801f35:	68 ac 29 80 00       	push   $0x8029ac
  801f3a:	6a 23                	push   $0x23
  801f3c:	68 b0 29 80 00       	push   $0x8029b0
  801f41:	e8 32 e3 ff ff       	call   800278 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f46:	8b 45 08             	mov    0x8(%ebp),%eax
  801f49:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f4e:	83 ec 08             	sub    $0x8,%esp
  801f51:	68 78 1f 80 00       	push   $0x801f78
  801f56:	6a 00                	push   $0x0
  801f58:	e8 c7 ee ff ff       	call   800e24 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	85 c0                	test   %eax,%eax
  801f62:	79 12                	jns    801f76 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f64:	50                   	push   %eax
  801f65:	68 ac 29 80 00       	push   $0x8029ac
  801f6a:	6a 2c                	push   $0x2c
  801f6c:	68 b0 29 80 00       	push   $0x8029b0
  801f71:	e8 02 e3 ff ff       	call   800278 <_panic>
	}
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f78:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f79:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f7e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f80:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f83:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f87:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f8c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f90:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f92:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f95:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f96:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f99:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f9a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f9b:	c3                   	ret    

00801f9c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	56                   	push   %esi
  801fa0:	53                   	push   %ebx
  801fa1:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801faa:	85 c0                	test   %eax,%eax
  801fac:	75 12                	jne    801fc0 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801fae:	83 ec 0c             	sub    $0xc,%esp
  801fb1:	68 00 00 c0 ee       	push   $0xeec00000
  801fb6:	e8 ce ee ff ff       	call   800e89 <sys_ipc_recv>
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	eb 0c                	jmp    801fcc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	50                   	push   %eax
  801fc4:	e8 c0 ee ff ff       	call   800e89 <sys_ipc_recv>
  801fc9:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801fcc:	85 f6                	test   %esi,%esi
  801fce:	0f 95 c1             	setne  %cl
  801fd1:	85 db                	test   %ebx,%ebx
  801fd3:	0f 95 c2             	setne  %dl
  801fd6:	84 d1                	test   %dl,%cl
  801fd8:	74 09                	je     801fe3 <ipc_recv+0x47>
  801fda:	89 c2                	mov    %eax,%edx
  801fdc:	c1 ea 1f             	shr    $0x1f,%edx
  801fdf:	84 d2                	test   %dl,%dl
  801fe1:	75 27                	jne    80200a <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801fe3:	85 f6                	test   %esi,%esi
  801fe5:	74 0a                	je     801ff1 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801fe7:	a1 20 44 80 00       	mov    0x804420,%eax
  801fec:	8b 40 7c             	mov    0x7c(%eax),%eax
  801fef:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ff1:	85 db                	test   %ebx,%ebx
  801ff3:	74 0d                	je     802002 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ff5:	a1 20 44 80 00       	mov    0x804420,%eax
  801ffa:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802000:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802002:	a1 20 44 80 00       	mov    0x804420,%eax
  802007:	8b 40 78             	mov    0x78(%eax),%eax
}
  80200a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	57                   	push   %edi
  802015:	56                   	push   %esi
  802016:	53                   	push   %ebx
  802017:	83 ec 0c             	sub    $0xc,%esp
  80201a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80201d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802020:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802023:	85 db                	test   %ebx,%ebx
  802025:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80202a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80202d:	ff 75 14             	pushl  0x14(%ebp)
  802030:	53                   	push   %ebx
  802031:	56                   	push   %esi
  802032:	57                   	push   %edi
  802033:	e8 2e ee ff ff       	call   800e66 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802038:	89 c2                	mov    %eax,%edx
  80203a:	c1 ea 1f             	shr    $0x1f,%edx
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	84 d2                	test   %dl,%dl
  802042:	74 17                	je     80205b <ipc_send+0x4a>
  802044:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802047:	74 12                	je     80205b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802049:	50                   	push   %eax
  80204a:	68 be 29 80 00       	push   $0x8029be
  80204f:	6a 47                	push   $0x47
  802051:	68 cc 29 80 00       	push   $0x8029cc
  802056:	e8 1d e2 ff ff       	call   800278 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80205b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80205e:	75 07                	jne    802067 <ipc_send+0x56>
			sys_yield();
  802060:	e8 55 ec ff ff       	call   800cba <sys_yield>
  802065:	eb c6                	jmp    80202d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802067:	85 c0                	test   %eax,%eax
  802069:	75 c2                	jne    80202d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80206b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206e:	5b                   	pop    %ebx
  80206f:	5e                   	pop    %esi
  802070:	5f                   	pop    %edi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80207e:	89 c2                	mov    %eax,%edx
  802080:	c1 e2 07             	shl    $0x7,%edx
  802083:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80208a:	8b 52 58             	mov    0x58(%edx),%edx
  80208d:	39 ca                	cmp    %ecx,%edx
  80208f:	75 11                	jne    8020a2 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802091:	89 c2                	mov    %eax,%edx
  802093:	c1 e2 07             	shl    $0x7,%edx
  802096:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80209d:	8b 40 50             	mov    0x50(%eax),%eax
  8020a0:	eb 0f                	jmp    8020b1 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020a2:	83 c0 01             	add    $0x1,%eax
  8020a5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020aa:	75 d2                	jne    80207e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    

008020b3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b9:	89 d0                	mov    %edx,%eax
  8020bb:	c1 e8 16             	shr    $0x16,%eax
  8020be:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020c5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ca:	f6 c1 01             	test   $0x1,%cl
  8020cd:	74 1d                	je     8020ec <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020cf:	c1 ea 0c             	shr    $0xc,%edx
  8020d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d9:	f6 c2 01             	test   $0x1,%dl
  8020dc:	74 0e                	je     8020ec <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020de:	c1 ea 0c             	shr    $0xc,%edx
  8020e1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e8:	ef 
  8020e9:	0f b7 c0             	movzwl %ax,%eax
}
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 f6                	test   %esi,%esi
  802109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80210d:	89 ca                	mov    %ecx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	75 3d                	jne    802150 <__udivdi3+0x60>
  802113:	39 cf                	cmp    %ecx,%edi
  802115:	0f 87 c5 00 00 00    	ja     8021e0 <__udivdi3+0xf0>
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 fd                	mov    %edi,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f7                	div    %edi
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 c8                	mov    %ecx,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c1                	mov    %eax,%ecx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	89 cf                	mov    %ecx,%edi
  802138:	f7 f5                	div    %ebp
  80213a:	89 c3                	mov    %eax,%ebx
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
  802150:	39 ce                	cmp    %ecx,%esi
  802152:	77 74                	ja     8021c8 <__udivdi3+0xd8>
  802154:	0f bd fe             	bsr    %esi,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0x108>
  802160:	bb 20 00 00 00       	mov    $0x20,%ebx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	89 c5                	mov    %eax,%ebp
  802169:	29 fb                	sub    %edi,%ebx
  80216b:	d3 e6                	shl    %cl,%esi
  80216d:	89 d9                	mov    %ebx,%ecx
  80216f:	d3 ed                	shr    %cl,%ebp
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	09 ee                	or     %ebp,%esi
  802177:	89 d9                	mov    %ebx,%ecx
  802179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217d:	89 d5                	mov    %edx,%ebp
  80217f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802183:	d3 ed                	shr    %cl,%ebp
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 d9                	mov    %ebx,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 c2                	or     %eax,%edx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	89 ea                	mov    %ebp,%edx
  802193:	f7 f6                	div    %esi
  802195:	89 d5                	mov    %edx,%ebp
  802197:	89 c3                	mov    %eax,%ebx
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	72 10                	jb     8021b1 <__udivdi3+0xc1>
  8021a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e6                	shl    %cl,%esi
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 07                	jae    8021b4 <__udivdi3+0xc4>
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	75 03                	jne    8021b4 <__udivdi3+0xc4>
  8021b1:	83 eb 01             	sub    $0x1,%ebx
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	31 ff                	xor    %edi,%edi
  8021ca:	31 db                	xor    %ebx,%ebx
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
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f7                	div    %edi
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	39 ce                	cmp    %ecx,%esi
  8021fa:	72 0c                	jb     802208 <__udivdi3+0x118>
  8021fc:	31 db                	xor    %ebx,%ebx
  8021fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802202:	0f 87 34 ff ff ff    	ja     80213c <__udivdi3+0x4c>
  802208:	bb 01 00 00 00       	mov    $0x1,%ebx
  80220d:	e9 2a ff ff ff       	jmp    80213c <__udivdi3+0x4c>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 d2                	test   %edx,%edx
  802239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f3                	mov    %esi,%ebx
  802243:	89 3c 24             	mov    %edi,(%esp)
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	75 1c                	jne    802268 <__umoddi3+0x48>
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	76 50                	jbe    8022a0 <__umoddi3+0x80>
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	f7 f7                	div    %edi
  802256:	89 d0                	mov    %edx,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	77 52                	ja     8022c0 <__umoddi3+0xa0>
  80226e:	0f bd ea             	bsr    %edx,%ebp
  802271:	83 f5 1f             	xor    $0x1f,%ebp
  802274:	75 5a                	jne    8022d0 <__umoddi3+0xb0>
  802276:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	39 0c 24             	cmp    %ecx,(%esp)
  802283:	0f 86 d7 00 00 00    	jbe    802360 <__umoddi3+0x140>
  802289:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	89 fd                	mov    %edi,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 c8                	mov    %ecx,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	eb 99                	jmp    802258 <__umoddi3+0x38>
  8022bf:	90                   	nop
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	8b 34 24             	mov    (%esp),%esi
  8022d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	29 ef                	sub    %ebp,%edi
  8022dc:	d3 e0                	shl    %cl,%eax
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	d3 ea                	shr    %cl,%edx
  8022e4:	89 e9                	mov    %ebp,%ecx
  8022e6:	09 c2                	or     %eax,%edx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 14 24             	mov    %edx,(%esp)
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	d3 e2                	shl    %cl,%edx
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	89 c6                	mov    %eax,%esi
  802301:	d3 e3                	shl    %cl,%ebx
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 d0                	mov    %edx,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	09 d8                	or     %ebx,%eax
  80230d:	89 d3                	mov    %edx,%ebx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	f7 34 24             	divl   (%esp)
  802314:	89 d6                	mov    %edx,%esi
  802316:	d3 e3                	shl    %cl,%ebx
  802318:	f7 64 24 04          	mull   0x4(%esp)
  80231c:	39 d6                	cmp    %edx,%esi
  80231e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802322:	89 d1                	mov    %edx,%ecx
  802324:	89 c3                	mov    %eax,%ebx
  802326:	72 08                	jb     802330 <__umoddi3+0x110>
  802328:	75 11                	jne    80233b <__umoddi3+0x11b>
  80232a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80232e:	73 0b                	jae    80233b <__umoddi3+0x11b>
  802330:	2b 44 24 04          	sub    0x4(%esp),%eax
  802334:	1b 14 24             	sbb    (%esp),%edx
  802337:	89 d1                	mov    %edx,%ecx
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80233f:	29 da                	sub    %ebx,%edx
  802341:	19 ce                	sbb    %ecx,%esi
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e0                	shl    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	d3 ea                	shr    %cl,%edx
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	d3 ee                	shr    %cl,%esi
  802351:	09 d0                	or     %edx,%eax
  802353:	89 f2                	mov    %esi,%edx
  802355:	83 c4 1c             	add    $0x1c,%esp
  802358:	5b                   	pop    %ebx
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 f9                	sub    %edi,%ecx
  802362:	19 d6                	sbb    %edx,%esi
  802364:	89 74 24 04          	mov    %esi,0x4(%esp)
  802368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80236c:	e9 18 ff ff ff       	jmp    802289 <__umoddi3+0x69>
