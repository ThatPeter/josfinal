
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
  80003e:	68 20 23 80 00       	push   $0x802320
  800043:	e8 8e 18 00 00       	call   8018d6 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 25 23 80 00       	push   $0x802325
  800057:	6a 0c                	push   $0xc
  800059:	68 33 23 80 00       	push   $0x802333
  80005e:	e8 fd 01 00 00       	call   800260 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 43 15 00 00       	call   8015b1 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 5b 14 00 00       	call   8014dc <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 48 23 80 00       	push   $0x802348
  800090:	6a 0f                	push   $0xf
  800092:	68 33 23 80 00       	push   $0x802333
  800097:	e8 c4 01 00 00       	call   800260 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 e7 0e 00 00       	call   800f88 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 52 23 80 00       	push   $0x802352
  8000ad:	6a 12                	push   $0x12
  8000af:	68 33 23 80 00       	push   $0x802333
  8000b4:	e8 a7 01 00 00       	call   800260 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 e5 14 00 00       	call   8015b1 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 90 23 80 00 	movl   $0x802390,(%esp)
  8000d3:	e8 61 02 00 00       	call   800339 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 f1 13 00 00       	call   8014dc <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 d4 23 80 00       	push   $0x8023d4
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 33 23 80 00       	push   $0x802333
  800103:	e8 58 01 00 00       	call   800260 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 b0 09 00 00       	call   800acb <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 00 24 80 00       	push   $0x802400
  80012a:	6a 19                	push   $0x19
  80012c:	68 33 23 80 00       	push   $0x802333
  800131:	e8 2a 01 00 00       	call   800260 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 5b 23 80 00       	push   $0x80235b
  80013e:	e8 f6 01 00 00       	call   800339 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 63 14 00 00       	call   8015b1 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 b9 11 00 00       	call   80130f <close>
		exit();
  800156:	e8 eb 00 00 00       	call   800246 <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 6f 1b 00 00       	call   801cd6 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 62 13 00 00       	call   8014dc <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 38 24 80 00       	push   $0x802438
  80018b:	6a 21                	push   $0x21
  80018d:	68 33 23 80 00       	push   $0x802333
  800192:	e8 c9 00 00 00       	call   800260 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 74 23 80 00       	push   $0x802374
  80019f:	e8 95 01 00 00       	call   800339 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 63 11 00 00       	call   80130f <close>
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
  8001cb:	e8 b3 0a 00 00       	call   800c83 <sys_getenvid>
  8001d0:	8b 3d 20 44 80 00    	mov    0x804420,%edi
  8001d6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8001db:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001e0:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8001e5:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8001e8:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8001ee:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8001f1:	39 c8                	cmp    %ecx,%eax
  8001f3:	0f 44 fb             	cmove  %ebx,%edi
  8001f6:	b9 01 00 00 00       	mov    $0x1,%ecx
  8001fb:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001fe:	83 c2 01             	add    $0x1,%edx
  800201:	83 c3 7c             	add    $0x7c,%ebx
  800204:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80020a:	75 d9                	jne    8001e5 <libmain+0x2d>
  80020c:	89 f0                	mov    %esi,%eax
  80020e:	84 c0                	test   %al,%al
  800210:	74 06                	je     800218 <libmain+0x60>
  800212:	89 3d 20 44 80 00    	mov    %edi,0x804420
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800218:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80021c:	7e 0a                	jle    800228 <libmain+0x70>
		binaryname = argv[0];
  80021e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800221:	8b 00                	mov    (%eax),%eax
  800223:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 0c             	pushl  0xc(%ebp)
  80022e:	ff 75 08             	pushl  0x8(%ebp)
  800231:	e8 fd fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800236:	e8 0b 00 00 00       	call   800246 <exit>
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80024c:	e8 e9 10 00 00       	call   80133a <close_all>
	sys_env_destroy(0);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	6a 00                	push   $0x0
  800256:	e8 e7 09 00 00       	call   800c42 <sys_env_destroy>
}
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800265:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800268:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80026e:	e8 10 0a 00 00       	call   800c83 <sys_getenvid>
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	ff 75 0c             	pushl  0xc(%ebp)
  800279:	ff 75 08             	pushl  0x8(%ebp)
  80027c:	56                   	push   %esi
  80027d:	50                   	push   %eax
  80027e:	68 68 24 80 00       	push   $0x802468
  800283:	e8 b1 00 00 00       	call   800339 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800288:	83 c4 18             	add    $0x18,%esp
  80028b:	53                   	push   %ebx
  80028c:	ff 75 10             	pushl  0x10(%ebp)
  80028f:	e8 54 00 00 00       	call   8002e8 <vcprintf>
	cprintf("\n");
  800294:	c7 04 24 72 23 80 00 	movl   $0x802372,(%esp)
  80029b:	e8 99 00 00 00       	call   800339 <cprintf>
  8002a0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a3:	cc                   	int3   
  8002a4:	eb fd                	jmp    8002a3 <_panic+0x43>

008002a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 04             	sub    $0x4,%esp
  8002ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b0:	8b 13                	mov    (%ebx),%edx
  8002b2:	8d 42 01             	lea    0x1(%edx),%eax
  8002b5:	89 03                	mov    %eax,(%ebx)
  8002b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c3:	75 1a                	jne    8002df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	68 ff 00 00 00       	push   $0xff
  8002cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d0:	50                   	push   %eax
  8002d1:	e8 2f 09 00 00       	call   800c05 <sys_cputs>
		b->idx = 0;
  8002d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f8:	00 00 00 
	b.cnt = 0;
  8002fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800302:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800305:	ff 75 0c             	pushl  0xc(%ebp)
  800308:	ff 75 08             	pushl  0x8(%ebp)
  80030b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800311:	50                   	push   %eax
  800312:	68 a6 02 80 00       	push   $0x8002a6
  800317:	e8 54 01 00 00       	call   800470 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031c:	83 c4 08             	add    $0x8,%esp
  80031f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800325:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80032b:	50                   	push   %eax
  80032c:	e8 d4 08 00 00       	call   800c05 <sys_cputs>

	return b.cnt;
}
  800331:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800337:	c9                   	leave  
  800338:	c3                   	ret    

00800339 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80033f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800342:	50                   	push   %eax
  800343:	ff 75 08             	pushl  0x8(%ebp)
  800346:	e8 9d ff ff ff       	call   8002e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80034b:	c9                   	leave  
  80034c:	c3                   	ret    

0080034d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
  800353:	83 ec 1c             	sub    $0x1c,%esp
  800356:	89 c7                	mov    %eax,%edi
  800358:	89 d6                	mov    %edx,%esi
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800360:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800363:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800366:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800369:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800371:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800374:	39 d3                	cmp    %edx,%ebx
  800376:	72 05                	jb     80037d <printnum+0x30>
  800378:	39 45 10             	cmp    %eax,0x10(%ebp)
  80037b:	77 45                	ja     8003c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037d:	83 ec 0c             	sub    $0xc,%esp
  800380:	ff 75 18             	pushl  0x18(%ebp)
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800389:	53                   	push   %ebx
  80038a:	ff 75 10             	pushl  0x10(%ebp)
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	ff 75 e4             	pushl  -0x1c(%ebp)
  800393:	ff 75 e0             	pushl  -0x20(%ebp)
  800396:	ff 75 dc             	pushl  -0x24(%ebp)
  800399:	ff 75 d8             	pushl  -0x28(%ebp)
  80039c:	e8 df 1c 00 00       	call   802080 <__udivdi3>
  8003a1:	83 c4 18             	add    $0x18,%esp
  8003a4:	52                   	push   %edx
  8003a5:	50                   	push   %eax
  8003a6:	89 f2                	mov    %esi,%edx
  8003a8:	89 f8                	mov    %edi,%eax
  8003aa:	e8 9e ff ff ff       	call   80034d <printnum>
  8003af:	83 c4 20             	add    $0x20,%esp
  8003b2:	eb 18                	jmp    8003cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b4:	83 ec 08             	sub    $0x8,%esp
  8003b7:	56                   	push   %esi
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	ff d7                	call   *%edi
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	eb 03                	jmp    8003c5 <printnum+0x78>
  8003c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c5:	83 eb 01             	sub    $0x1,%ebx
  8003c8:	85 db                	test   %ebx,%ebx
  8003ca:	7f e8                	jg     8003b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	83 ec 04             	sub    $0x4,%esp
  8003d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003df:	e8 cc 1d 00 00       	call   8021b0 <__umoddi3>
  8003e4:	83 c4 14             	add    $0x14,%esp
  8003e7:	0f be 80 8b 24 80 00 	movsbl 0x80248b(%eax),%eax
  8003ee:	50                   	push   %eax
  8003ef:	ff d7                	call   *%edi
}
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f7:	5b                   	pop    %ebx
  8003f8:	5e                   	pop    %esi
  8003f9:	5f                   	pop    %edi
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ff:	83 fa 01             	cmp    $0x1,%edx
  800402:	7e 0e                	jle    800412 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 4a 08             	lea    0x8(%edx),%ecx
  800409:	89 08                	mov    %ecx,(%eax)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	8b 52 04             	mov    0x4(%edx),%edx
  800410:	eb 22                	jmp    800434 <getuint+0x38>
	else if (lflag)
  800412:	85 d2                	test   %edx,%edx
  800414:	74 10                	je     800426 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	ba 00 00 00 00       	mov    $0x0,%edx
  800424:	eb 0e                	jmp    800434 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800426:	8b 10                	mov    (%eax),%edx
  800428:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042b:	89 08                	mov    %ecx,(%eax)
  80042d:	8b 02                	mov    (%edx),%eax
  80042f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800440:	8b 10                	mov    (%eax),%edx
  800442:	3b 50 04             	cmp    0x4(%eax),%edx
  800445:	73 0a                	jae    800451 <sprintputch+0x1b>
		*b->buf++ = ch;
  800447:	8d 4a 01             	lea    0x1(%edx),%ecx
  80044a:	89 08                	mov    %ecx,(%eax)
  80044c:	8b 45 08             	mov    0x8(%ebp),%eax
  80044f:	88 02                	mov    %al,(%edx)
}
  800451:	5d                   	pop    %ebp
  800452:	c3                   	ret    

00800453 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800459:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045c:	50                   	push   %eax
  80045d:	ff 75 10             	pushl  0x10(%ebp)
  800460:	ff 75 0c             	pushl  0xc(%ebp)
  800463:	ff 75 08             	pushl  0x8(%ebp)
  800466:	e8 05 00 00 00       	call   800470 <vprintfmt>
	va_end(ap);
}
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	c9                   	leave  
  80046f:	c3                   	ret    

00800470 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	57                   	push   %edi
  800474:	56                   	push   %esi
  800475:	53                   	push   %ebx
  800476:	83 ec 2c             	sub    $0x2c,%esp
  800479:	8b 75 08             	mov    0x8(%ebp),%esi
  80047c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800482:	eb 12                	jmp    800496 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800484:	85 c0                	test   %eax,%eax
  800486:	0f 84 89 03 00 00    	je     800815 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	53                   	push   %ebx
  800490:	50                   	push   %eax
  800491:	ff d6                	call   *%esi
  800493:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800496:	83 c7 01             	add    $0x1,%edi
  800499:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049d:	83 f8 25             	cmp    $0x25,%eax
  8004a0:	75 e2                	jne    800484 <vprintfmt+0x14>
  8004a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c0:	eb 07                	jmp    8004c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8d 47 01             	lea    0x1(%edi),%eax
  8004cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cf:	0f b6 07             	movzbl (%edi),%eax
  8004d2:	0f b6 c8             	movzbl %al,%ecx
  8004d5:	83 e8 23             	sub    $0x23,%eax
  8004d8:	3c 55                	cmp    $0x55,%al
  8004da:	0f 87 1a 03 00 00    	ja     8007fa <vprintfmt+0x38a>
  8004e0:	0f b6 c0             	movzbl %al,%eax
  8004e3:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8004ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004f1:	eb d6                	jmp    8004c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800501:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800505:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800508:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80050b:	83 fa 09             	cmp    $0x9,%edx
  80050e:	77 39                	ja     800549 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800510:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800513:	eb e9                	jmp    8004fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 48 04             	lea    0x4(%eax),%ecx
  80051b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800526:	eb 27                	jmp    80054f <vprintfmt+0xdf>
  800528:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052b:	85 c0                	test   %eax,%eax
  80052d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800532:	0f 49 c8             	cmovns %eax,%ecx
  800535:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053b:	eb 8c                	jmp    8004c9 <vprintfmt+0x59>
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800540:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800547:	eb 80                	jmp    8004c9 <vprintfmt+0x59>
  800549:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80054f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800553:	0f 89 70 ff ff ff    	jns    8004c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800559:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80055c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800566:	e9 5e ff ff ff       	jmp    8004c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800571:	e9 53 ff ff ff       	jmp    8004c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	53                   	push   %ebx
  800583:	ff 30                	pushl  (%eax)
  800585:	ff d6                	call   *%esi
			break;
  800587:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80058d:	e9 04 ff ff ff       	jmp    800496 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	99                   	cltd   
  80059e:	31 d0                	xor    %edx,%eax
  8005a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a2:	83 f8 0f             	cmp    $0xf,%eax
  8005a5:	7f 0b                	jg     8005b2 <vprintfmt+0x142>
  8005a7:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	75 18                	jne    8005ca <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005b2:	50                   	push   %eax
  8005b3:	68 a3 24 80 00       	push   $0x8024a3
  8005b8:	53                   	push   %ebx
  8005b9:	56                   	push   %esi
  8005ba:	e8 94 fe ff ff       	call   800453 <printfmt>
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c5:	e9 cc fe ff ff       	jmp    800496 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ca:	52                   	push   %edx
  8005cb:	68 c1 28 80 00       	push   $0x8028c1
  8005d0:	53                   	push   %ebx
  8005d1:	56                   	push   %esi
  8005d2:	e8 7c fe ff ff       	call   800453 <printfmt>
  8005d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dd:	e9 b4 fe ff ff       	jmp    800496 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	b8 9c 24 80 00       	mov    $0x80249c,%eax
  8005f4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fb:	0f 8e 94 00 00 00    	jle    800695 <vprintfmt+0x225>
  800601:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800605:	0f 84 98 00 00 00    	je     8006a3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	ff 75 d0             	pushl  -0x30(%ebp)
  800611:	57                   	push   %edi
  800612:	e8 86 02 00 00       	call   80089d <strnlen>
  800617:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80061a:	29 c1                	sub    %eax,%ecx
  80061c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80061f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800622:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800626:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800629:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80062c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062e:	eb 0f                	jmp    80063f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	ff 75 e0             	pushl  -0x20(%ebp)
  800637:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800639:	83 ef 01             	sub    $0x1,%edi
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	85 ff                	test   %edi,%edi
  800641:	7f ed                	jg     800630 <vprintfmt+0x1c0>
  800643:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800646:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800649:	85 c9                	test   %ecx,%ecx
  80064b:	b8 00 00 00 00       	mov    $0x0,%eax
  800650:	0f 49 c1             	cmovns %ecx,%eax
  800653:	29 c1                	sub    %eax,%ecx
  800655:	89 75 08             	mov    %esi,0x8(%ebp)
  800658:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065e:	89 cb                	mov    %ecx,%ebx
  800660:	eb 4d                	jmp    8006af <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800662:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800666:	74 1b                	je     800683 <vprintfmt+0x213>
  800668:	0f be c0             	movsbl %al,%eax
  80066b:	83 e8 20             	sub    $0x20,%eax
  80066e:	83 f8 5e             	cmp    $0x5e,%eax
  800671:	76 10                	jbe    800683 <vprintfmt+0x213>
					putch('?', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	ff 75 0c             	pushl  0xc(%ebp)
  800679:	6a 3f                	push   $0x3f
  80067b:	ff 55 08             	call   *0x8(%ebp)
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	eb 0d                	jmp    800690 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	ff 75 0c             	pushl  0xc(%ebp)
  800689:	52                   	push   %edx
  80068a:	ff 55 08             	call   *0x8(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800690:	83 eb 01             	sub    $0x1,%ebx
  800693:	eb 1a                	jmp    8006af <vprintfmt+0x23f>
  800695:	89 75 08             	mov    %esi,0x8(%ebp)
  800698:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80069b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a1:	eb 0c                	jmp    8006af <vprintfmt+0x23f>
  8006a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006af:	83 c7 01             	add    $0x1,%edi
  8006b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b6:	0f be d0             	movsbl %al,%edx
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	74 23                	je     8006e0 <vprintfmt+0x270>
  8006bd:	85 f6                	test   %esi,%esi
  8006bf:	78 a1                	js     800662 <vprintfmt+0x1f2>
  8006c1:	83 ee 01             	sub    $0x1,%esi
  8006c4:	79 9c                	jns    800662 <vprintfmt+0x1f2>
  8006c6:	89 df                	mov    %ebx,%edi
  8006c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ce:	eb 18                	jmp    8006e8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 20                	push   $0x20
  8006d6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d8:	83 ef 01             	sub    $0x1,%edi
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	eb 08                	jmp    8006e8 <vprintfmt+0x278>
  8006e0:	89 df                	mov    %ebx,%edi
  8006e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e8:	85 ff                	test   %edi,%edi
  8006ea:	7f e4                	jg     8006d0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ef:	e9 a2 fd ff ff       	jmp    800496 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f4:	83 fa 01             	cmp    $0x1,%edx
  8006f7:	7e 16                	jle    80070f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8d 50 08             	lea    0x8(%eax),%edx
  8006ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800702:	8b 50 04             	mov    0x4(%eax),%edx
  800705:	8b 00                	mov    (%eax),%eax
  800707:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80070d:	eb 32                	jmp    800741 <vprintfmt+0x2d1>
	else if (lflag)
  80070f:	85 d2                	test   %edx,%edx
  800711:	74 18                	je     80072b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8d 50 04             	lea    0x4(%eax),%edx
  800719:	89 55 14             	mov    %edx,0x14(%ebp)
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800721:	89 c1                	mov    %eax,%ecx
  800723:	c1 f9 1f             	sar    $0x1f,%ecx
  800726:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800729:	eb 16                	jmp    800741 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8d 50 04             	lea    0x4(%eax),%edx
  800731:	89 55 14             	mov    %edx,0x14(%ebp)
  800734:	8b 00                	mov    (%eax),%eax
  800736:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800739:	89 c1                	mov    %eax,%ecx
  80073b:	c1 f9 1f             	sar    $0x1f,%ecx
  80073e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800741:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800744:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800747:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80074c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800750:	79 74                	jns    8007c6 <vprintfmt+0x356>
				putch('-', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 2d                	push   $0x2d
  800758:	ff d6                	call   *%esi
				num = -(long long) num;
  80075a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80075d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800760:	f7 d8                	neg    %eax
  800762:	83 d2 00             	adc    $0x0,%edx
  800765:	f7 da                	neg    %edx
  800767:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80076a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80076f:	eb 55                	jmp    8007c6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 83 fc ff ff       	call   8003fc <getuint>
			base = 10;
  800779:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80077e:	eb 46                	jmp    8007c6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
  800783:	e8 74 fc ff ff       	call   8003fc <getuint>
			base = 8;
  800788:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80078d:	eb 37                	jmp    8007c6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	53                   	push   %ebx
  800793:	6a 30                	push   $0x30
  800795:	ff d6                	call   *%esi
			putch('x', putdat);
  800797:	83 c4 08             	add    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 78                	push   $0x78
  80079d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 04             	lea    0x4(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a8:	8b 00                	mov    (%eax),%eax
  8007aa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007af:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b7:	eb 0d                	jmp    8007c6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bc:	e8 3b fc ff ff       	call   8003fc <getuint>
			base = 16;
  8007c1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c6:	83 ec 0c             	sub    $0xc,%esp
  8007c9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007cd:	57                   	push   %edi
  8007ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d1:	51                   	push   %ecx
  8007d2:	52                   	push   %edx
  8007d3:	50                   	push   %eax
  8007d4:	89 da                	mov    %ebx,%edx
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	e8 70 fb ff ff       	call   80034d <printnum>
			break;
  8007dd:	83 c4 20             	add    $0x20,%esp
  8007e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e3:	e9 ae fc ff ff       	jmp    800496 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	53                   	push   %ebx
  8007ec:	51                   	push   %ecx
  8007ed:	ff d6                	call   *%esi
			break;
  8007ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f5:	e9 9c fc ff ff       	jmp    800496 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	53                   	push   %ebx
  8007fe:	6a 25                	push   $0x25
  800800:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	eb 03                	jmp    80080a <vprintfmt+0x39a>
  800807:	83 ef 01             	sub    $0x1,%edi
  80080a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80080e:	75 f7                	jne    800807 <vprintfmt+0x397>
  800810:	e9 81 fc ff ff       	jmp    800496 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800815:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5f                   	pop    %edi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 18             	sub    $0x18,%esp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800829:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800830:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083a:	85 c0                	test   %eax,%eax
  80083c:	74 26                	je     800864 <vsnprintf+0x47>
  80083e:	85 d2                	test   %edx,%edx
  800840:	7e 22                	jle    800864 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800842:	ff 75 14             	pushl  0x14(%ebp)
  800845:	ff 75 10             	pushl  0x10(%ebp)
  800848:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084b:	50                   	push   %eax
  80084c:	68 36 04 80 00       	push   $0x800436
  800851:	e8 1a fc ff ff       	call   800470 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800856:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800859:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	eb 05                	jmp    800869 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800864:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800871:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800874:	50                   	push   %eax
  800875:	ff 75 10             	pushl  0x10(%ebp)
  800878:	ff 75 0c             	pushl  0xc(%ebp)
  80087b:	ff 75 08             	pushl  0x8(%ebp)
  80087e:	e8 9a ff ff ff       	call   80081d <vsnprintf>
	va_end(ap);

	return rc;
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
  800890:	eb 03                	jmp    800895 <strlen+0x10>
		n++;
  800892:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800895:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800899:	75 f7                	jne    800892 <strlen+0xd>
		n++;
	return n;
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ab:	eb 03                	jmp    8008b0 <strnlen+0x13>
		n++;
  8008ad:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b0:	39 c2                	cmp    %eax,%edx
  8008b2:	74 08                	je     8008bc <strnlen+0x1f>
  8008b4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008b8:	75 f3                	jne    8008ad <strnlen+0x10>
  8008ba:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	53                   	push   %ebx
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c8:	89 c2                	mov    %eax,%edx
  8008ca:	83 c2 01             	add    $0x1,%edx
  8008cd:	83 c1 01             	add    $0x1,%ecx
  8008d0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d7:	84 db                	test   %bl,%bl
  8008d9:	75 ef                	jne    8008ca <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008db:	5b                   	pop    %ebx
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	53                   	push   %ebx
  8008e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e5:	53                   	push   %ebx
  8008e6:	e8 9a ff ff ff       	call   800885 <strlen>
  8008eb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ee:	ff 75 0c             	pushl  0xc(%ebp)
  8008f1:	01 d8                	add    %ebx,%eax
  8008f3:	50                   	push   %eax
  8008f4:	e8 c5 ff ff ff       	call   8008be <strcpy>
	return dst;
}
  8008f9:	89 d8                	mov    %ebx,%eax
  8008fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 75 08             	mov    0x8(%ebp),%esi
  800908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090b:	89 f3                	mov    %esi,%ebx
  80090d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800910:	89 f2                	mov    %esi,%edx
  800912:	eb 0f                	jmp    800923 <strncpy+0x23>
		*dst++ = *src;
  800914:	83 c2 01             	add    $0x1,%edx
  800917:	0f b6 01             	movzbl (%ecx),%eax
  80091a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091d:	80 39 01             	cmpb   $0x1,(%ecx)
  800920:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800923:	39 da                	cmp    %ebx,%edx
  800925:	75 ed                	jne    800914 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800927:	89 f0                	mov    %esi,%eax
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	56                   	push   %esi
  800931:	53                   	push   %ebx
  800932:	8b 75 08             	mov    0x8(%ebp),%esi
  800935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800938:	8b 55 10             	mov    0x10(%ebp),%edx
  80093b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 21                	je     800962 <strlcpy+0x35>
  800941:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800945:	89 f2                	mov    %esi,%edx
  800947:	eb 09                	jmp    800952 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800949:	83 c2 01             	add    $0x1,%edx
  80094c:	83 c1 01             	add    $0x1,%ecx
  80094f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800952:	39 c2                	cmp    %eax,%edx
  800954:	74 09                	je     80095f <strlcpy+0x32>
  800956:	0f b6 19             	movzbl (%ecx),%ebx
  800959:	84 db                	test   %bl,%bl
  80095b:	75 ec                	jne    800949 <strlcpy+0x1c>
  80095d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80095f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800962:	29 f0                	sub    %esi,%eax
}
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800971:	eb 06                	jmp    800979 <strcmp+0x11>
		p++, q++;
  800973:	83 c1 01             	add    $0x1,%ecx
  800976:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800979:	0f b6 01             	movzbl (%ecx),%eax
  80097c:	84 c0                	test   %al,%al
  80097e:	74 04                	je     800984 <strcmp+0x1c>
  800980:	3a 02                	cmp    (%edx),%al
  800982:	74 ef                	je     800973 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800984:	0f b6 c0             	movzbl %al,%eax
  800987:	0f b6 12             	movzbl (%edx),%edx
  80098a:	29 d0                	sub    %edx,%eax
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	53                   	push   %ebx
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
  800998:	89 c3                	mov    %eax,%ebx
  80099a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099d:	eb 06                	jmp    8009a5 <strncmp+0x17>
		n--, p++, q++;
  80099f:	83 c0 01             	add    $0x1,%eax
  8009a2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a5:	39 d8                	cmp    %ebx,%eax
  8009a7:	74 15                	je     8009be <strncmp+0x30>
  8009a9:	0f b6 08             	movzbl (%eax),%ecx
  8009ac:	84 c9                	test   %cl,%cl
  8009ae:	74 04                	je     8009b4 <strncmp+0x26>
  8009b0:	3a 0a                	cmp    (%edx),%cl
  8009b2:	74 eb                	je     80099f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b4:	0f b6 00             	movzbl (%eax),%eax
  8009b7:	0f b6 12             	movzbl (%edx),%edx
  8009ba:	29 d0                	sub    %edx,%eax
  8009bc:	eb 05                	jmp    8009c3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d0:	eb 07                	jmp    8009d9 <strchr+0x13>
		if (*s == c)
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	74 0f                	je     8009e5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	0f b6 10             	movzbl (%eax),%edx
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	75 f2                	jne    8009d2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f1:	eb 03                	jmp    8009f6 <strfind+0xf>
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f9:	38 ca                	cmp    %cl,%dl
  8009fb:	74 04                	je     800a01 <strfind+0x1a>
  8009fd:	84 d2                	test   %dl,%dl
  8009ff:	75 f2                	jne    8009f3 <strfind+0xc>
			break;
	return (char *) s;
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0f:	85 c9                	test   %ecx,%ecx
  800a11:	74 36                	je     800a49 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a13:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a19:	75 28                	jne    800a43 <memset+0x40>
  800a1b:	f6 c1 03             	test   $0x3,%cl
  800a1e:	75 23                	jne    800a43 <memset+0x40>
		c &= 0xFF;
  800a20:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a24:	89 d3                	mov    %edx,%ebx
  800a26:	c1 e3 08             	shl    $0x8,%ebx
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	c1 e6 18             	shl    $0x18,%esi
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	c1 e0 10             	shl    $0x10,%eax
  800a33:	09 f0                	or     %esi,%eax
  800a35:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a37:	89 d8                	mov    %ebx,%eax
  800a39:	09 d0                	or     %edx,%eax
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fc                   	cld    
  800a3f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a41:	eb 06                	jmp    800a49 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	fc                   	cld    
  800a47:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a49:	89 f8                	mov    %edi,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5e:	39 c6                	cmp    %eax,%esi
  800a60:	73 35                	jae    800a97 <memmove+0x47>
  800a62:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a65:	39 d0                	cmp    %edx,%eax
  800a67:	73 2e                	jae    800a97 <memmove+0x47>
		s += n;
		d += n;
  800a69:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6c:	89 d6                	mov    %edx,%esi
  800a6e:	09 fe                	or     %edi,%esi
  800a70:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a76:	75 13                	jne    800a8b <memmove+0x3b>
  800a78:	f6 c1 03             	test   $0x3,%cl
  800a7b:	75 0e                	jne    800a8b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a7d:	83 ef 04             	sub    $0x4,%edi
  800a80:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a83:	c1 e9 02             	shr    $0x2,%ecx
  800a86:	fd                   	std    
  800a87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a89:	eb 09                	jmp    800a94 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a91:	fd                   	std    
  800a92:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a94:	fc                   	cld    
  800a95:	eb 1d                	jmp    800ab4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a97:	89 f2                	mov    %esi,%edx
  800a99:	09 c2                	or     %eax,%edx
  800a9b:	f6 c2 03             	test   $0x3,%dl
  800a9e:	75 0f                	jne    800aaf <memmove+0x5f>
  800aa0:	f6 c1 03             	test   $0x3,%cl
  800aa3:	75 0a                	jne    800aaf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa5:	c1 e9 02             	shr    $0x2,%ecx
  800aa8:	89 c7                	mov    %eax,%edi
  800aaa:	fc                   	cld    
  800aab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aad:	eb 05                	jmp    800ab4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aaf:	89 c7                	mov    %eax,%edi
  800ab1:	fc                   	cld    
  800ab2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab4:	5e                   	pop    %esi
  800ab5:	5f                   	pop    %edi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abb:	ff 75 10             	pushl  0x10(%ebp)
  800abe:	ff 75 0c             	pushl  0xc(%ebp)
  800ac1:	ff 75 08             	pushl  0x8(%ebp)
  800ac4:	e8 87 ff ff ff       	call   800a50 <memmove>
}
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad6:	89 c6                	mov    %eax,%esi
  800ad8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adb:	eb 1a                	jmp    800af7 <memcmp+0x2c>
		if (*s1 != *s2)
  800add:	0f b6 08             	movzbl (%eax),%ecx
  800ae0:	0f b6 1a             	movzbl (%edx),%ebx
  800ae3:	38 d9                	cmp    %bl,%cl
  800ae5:	74 0a                	je     800af1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae7:	0f b6 c1             	movzbl %cl,%eax
  800aea:	0f b6 db             	movzbl %bl,%ebx
  800aed:	29 d8                	sub    %ebx,%eax
  800aef:	eb 0f                	jmp    800b00 <memcmp+0x35>
		s1++, s2++;
  800af1:	83 c0 01             	add    $0x1,%eax
  800af4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af7:	39 f0                	cmp    %esi,%eax
  800af9:	75 e2                	jne    800add <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0b:	89 c1                	mov    %eax,%ecx
  800b0d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b10:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b14:	eb 0a                	jmp    800b20 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b16:	0f b6 10             	movzbl (%eax),%edx
  800b19:	39 da                	cmp    %ebx,%edx
  800b1b:	74 07                	je     800b24 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1d:	83 c0 01             	add    $0x1,%eax
  800b20:	39 c8                	cmp    %ecx,%eax
  800b22:	72 f2                	jb     800b16 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b33:	eb 03                	jmp    800b38 <strtol+0x11>
		s++;
  800b35:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	0f b6 01             	movzbl (%ecx),%eax
  800b3b:	3c 20                	cmp    $0x20,%al
  800b3d:	74 f6                	je     800b35 <strtol+0xe>
  800b3f:	3c 09                	cmp    $0x9,%al
  800b41:	74 f2                	je     800b35 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b43:	3c 2b                	cmp    $0x2b,%al
  800b45:	75 0a                	jne    800b51 <strtol+0x2a>
		s++;
  800b47:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4f:	eb 11                	jmp    800b62 <strtol+0x3b>
  800b51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b56:	3c 2d                	cmp    $0x2d,%al
  800b58:	75 08                	jne    800b62 <strtol+0x3b>
		s++, neg = 1;
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b68:	75 15                	jne    800b7f <strtol+0x58>
  800b6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6d:	75 10                	jne    800b7f <strtol+0x58>
  800b6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b73:	75 7c                	jne    800bf1 <strtol+0xca>
		s += 2, base = 16;
  800b75:	83 c1 02             	add    $0x2,%ecx
  800b78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7d:	eb 16                	jmp    800b95 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	75 12                	jne    800b95 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b83:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b88:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8b:	75 08                	jne    800b95 <strtol+0x6e>
		s++, base = 8;
  800b8d:	83 c1 01             	add    $0x1,%ecx
  800b90:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9d:	0f b6 11             	movzbl (%ecx),%edx
  800ba0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	80 fb 09             	cmp    $0x9,%bl
  800ba8:	77 08                	ja     800bb2 <strtol+0x8b>
			dig = *s - '0';
  800baa:	0f be d2             	movsbl %dl,%edx
  800bad:	83 ea 30             	sub    $0x30,%edx
  800bb0:	eb 22                	jmp    800bd4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb5:	89 f3                	mov    %esi,%ebx
  800bb7:	80 fb 19             	cmp    $0x19,%bl
  800bba:	77 08                	ja     800bc4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bbc:	0f be d2             	movsbl %dl,%edx
  800bbf:	83 ea 57             	sub    $0x57,%edx
  800bc2:	eb 10                	jmp    800bd4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc7:	89 f3                	mov    %esi,%ebx
  800bc9:	80 fb 19             	cmp    $0x19,%bl
  800bcc:	77 16                	ja     800be4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bce:	0f be d2             	movsbl %dl,%edx
  800bd1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd7:	7d 0b                	jge    800be4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be2:	eb b9                	jmp    800b9d <strtol+0x76>

	if (endptr)
  800be4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be8:	74 0d                	je     800bf7 <strtol+0xd0>
		*endptr = (char *) s;
  800bea:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bed:	89 0e                	mov    %ecx,(%esi)
  800bef:	eb 06                	jmp    800bf7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf1:	85 db                	test   %ebx,%ebx
  800bf3:	74 98                	je     800b8d <strtol+0x66>
  800bf5:	eb 9e                	jmp    800b95 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf7:	89 c2                	mov    %eax,%edx
  800bf9:	f7 da                	neg    %edx
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	0f 45 c2             	cmovne %edx,%eax
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	89 c3                	mov    %eax,%ebx
  800c18:	89 c7                	mov    %eax,%edi
  800c1a:	89 c6                	mov    %eax,%esi
  800c1c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c33:	89 d1                	mov    %edx,%ecx
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	89 d7                	mov    %edx,%edi
  800c39:	89 d6                	mov    %edx,%esi
  800c3b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c50:	b8 03 00 00 00       	mov    $0x3,%eax
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 cb                	mov    %ecx,%ebx
  800c5a:	89 cf                	mov    %ecx,%edi
  800c5c:	89 ce                	mov    %ecx,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 03                	push   $0x3
  800c6a:	68 7f 27 80 00       	push   $0x80277f
  800c6f:	6a 23                	push   $0x23
  800c71:	68 9c 27 80 00       	push   $0x80279c
  800c76:	e8 e5 f5 ff ff       	call   800260 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	89 d3                	mov    %edx,%ebx
  800c97:	89 d7                	mov    %edx,%edi
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_yield>:

void
sys_yield(void)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	89 d7                	mov    %edx,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdd:	89 f7                	mov    %esi,%edi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 04                	push   $0x4
  800ceb:	68 7f 27 80 00       	push   $0x80277f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 9c 27 80 00       	push   $0x80279c
  800cf7:	e8 64 f5 ff ff       	call   800260 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 05                	push   $0x5
  800d2d:	68 7f 27 80 00       	push   $0x80277f
  800d32:	6a 23                	push   $0x23
  800d34:	68 9c 27 80 00       	push   $0x80279c
  800d39:	e8 22 f5 ff ff       	call   800260 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d54:	b8 06 00 00 00       	mov    $0x6,%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 df                	mov    %ebx,%edi
  800d61:	89 de                	mov    %ebx,%esi
  800d63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 17                	jle    800d80 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 06                	push   $0x6
  800d6f:	68 7f 27 80 00       	push   $0x80277f
  800d74:	6a 23                	push   $0x23
  800d76:	68 9c 27 80 00       	push   $0x80279c
  800d7b:	e8 e0 f4 ff ff       	call   800260 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d96:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 df                	mov    %ebx,%edi
  800da3:	89 de                	mov    %ebx,%esi
  800da5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 08                	push   $0x8
  800db1:	68 7f 27 80 00       	push   $0x80277f
  800db6:	6a 23                	push   $0x23
  800db8:	68 9c 27 80 00       	push   $0x80279c
  800dbd:	e8 9e f4 ff ff       	call   800260 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 17                	jle    800e04 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	50                   	push   %eax
  800df1:	6a 09                	push   $0x9
  800df3:	68 7f 27 80 00       	push   $0x80277f
  800df8:	6a 23                	push   $0x23
  800dfa:	68 9c 27 80 00       	push   $0x80279c
  800dff:	e8 5c f4 ff ff       	call   800260 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 17                	jle    800e46 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	50                   	push   %eax
  800e33:	6a 0a                	push   $0xa
  800e35:	68 7f 27 80 00       	push   $0x80277f
  800e3a:	6a 23                	push   $0x23
  800e3c:	68 9c 27 80 00       	push   $0x80279c
  800e41:	e8 1a f4 ff ff       	call   800260 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	be 00 00 00 00       	mov    $0x0,%esi
  800e59:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	89 cb                	mov    %ecx,%ebx
  800e89:	89 cf                	mov    %ecx,%edi
  800e8b:	89 ce                	mov    %ecx,%esi
  800e8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 17                	jle    800eaa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	50                   	push   %eax
  800e97:	6a 0d                	push   $0xd
  800e99:	68 7f 27 80 00       	push   $0x80277f
  800e9e:	6a 23                	push   $0x23
  800ea0:	68 9c 27 80 00       	push   $0x80279c
  800ea5:	e8 b6 f3 ff ff       	call   800260 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 04             	sub    $0x4,%esp
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ebc:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ebe:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ec2:	74 11                	je     800ed5 <pgfault+0x23>
  800ec4:	89 d8                	mov    %ebx,%eax
  800ec6:	c1 e8 0c             	shr    $0xc,%eax
  800ec9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed0:	f6 c4 08             	test   $0x8,%ah
  800ed3:	75 14                	jne    800ee9 <pgfault+0x37>
		panic("faulting access");
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 aa 27 80 00       	push   $0x8027aa
  800edd:	6a 1d                	push   $0x1d
  800edf:	68 ba 27 80 00       	push   $0x8027ba
  800ee4:	e8 77 f3 ff ff       	call   800260 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	6a 07                	push   $0x7
  800eee:	68 00 f0 7f 00       	push   $0x7ff000
  800ef3:	6a 00                	push   $0x0
  800ef5:	e8 c7 fd ff ff       	call   800cc1 <sys_page_alloc>
	if (r < 0) {
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	85 c0                	test   %eax,%eax
  800eff:	79 12                	jns    800f13 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f01:	50                   	push   %eax
  800f02:	68 c5 27 80 00       	push   $0x8027c5
  800f07:	6a 2b                	push   $0x2b
  800f09:	68 ba 27 80 00       	push   $0x8027ba
  800f0e:	e8 4d f3 ff ff       	call   800260 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f13:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	68 00 10 00 00       	push   $0x1000
  800f21:	53                   	push   %ebx
  800f22:	68 00 f0 7f 00       	push   $0x7ff000
  800f27:	e8 8c fb ff ff       	call   800ab8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f2c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f33:	53                   	push   %ebx
  800f34:	6a 00                	push   $0x0
  800f36:	68 00 f0 7f 00       	push   $0x7ff000
  800f3b:	6a 00                	push   $0x0
  800f3d:	e8 c2 fd ff ff       	call   800d04 <sys_page_map>
	if (r < 0) {
  800f42:	83 c4 20             	add    $0x20,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	79 12                	jns    800f5b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f49:	50                   	push   %eax
  800f4a:	68 c5 27 80 00       	push   $0x8027c5
  800f4f:	6a 32                	push   $0x32
  800f51:	68 ba 27 80 00       	push   $0x8027ba
  800f56:	e8 05 f3 ff ff       	call   800260 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	6a 00                	push   $0x0
  800f65:	e8 dc fd ff ff       	call   800d46 <sys_page_unmap>
	if (r < 0) {
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	79 12                	jns    800f83 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f71:	50                   	push   %eax
  800f72:	68 c5 27 80 00       	push   $0x8027c5
  800f77:	6a 36                	push   $0x36
  800f79:	68 ba 27 80 00       	push   $0x8027ba
  800f7e:	e8 dd f2 ff ff       	call   800260 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f91:	68 b2 0e 80 00       	push   $0x800eb2
  800f96:	e8 0d 0f 00 00       	call   801ea8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f9b:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa0:	cd 30                	int    $0x30
  800fa2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	79 17                	jns    800fc3 <fork+0x3b>
		panic("fork fault %e");
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	68 de 27 80 00       	push   $0x8027de
  800fb4:	68 83 00 00 00       	push   $0x83
  800fb9:	68 ba 27 80 00       	push   $0x8027ba
  800fbe:	e8 9d f2 ff ff       	call   800260 <_panic>
  800fc3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fc5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc9:	75 21                	jne    800fec <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fcb:	e8 b3 fc ff ff       	call   800c83 <sys_getenvid>
  800fd0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdd:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	e9 61 01 00 00       	jmp    80114d <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	6a 07                	push   $0x7
  800ff1:	68 00 f0 bf ee       	push   $0xeebff000
  800ff6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff9:	e8 c3 fc ff ff       	call   800cc1 <sys_page_alloc>
  800ffe:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801006:	89 d8                	mov    %ebx,%eax
  801008:	c1 e8 16             	shr    $0x16,%eax
  80100b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801012:	a8 01                	test   $0x1,%al
  801014:	0f 84 fc 00 00 00    	je     801116 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80101a:	89 d8                	mov    %ebx,%eax
  80101c:	c1 e8 0c             	shr    $0xc,%eax
  80101f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801026:	f6 c2 01             	test   $0x1,%dl
  801029:	0f 84 e7 00 00 00    	je     801116 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80102f:	89 c6                	mov    %eax,%esi
  801031:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801034:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103b:	f6 c6 04             	test   $0x4,%dh
  80103e:	74 39                	je     801079 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801040:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	25 07 0e 00 00       	and    $0xe07,%eax
  80104f:	50                   	push   %eax
  801050:	56                   	push   %esi
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	6a 00                	push   $0x0
  801055:	e8 aa fc ff ff       	call   800d04 <sys_page_map>
		if (r < 0) {
  80105a:	83 c4 20             	add    $0x20,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	0f 89 b1 00 00 00    	jns    801116 <fork+0x18e>
		    	panic("sys page map fault %e");
  801065:	83 ec 04             	sub    $0x4,%esp
  801068:	68 ec 27 80 00       	push   $0x8027ec
  80106d:	6a 53                	push   $0x53
  80106f:	68 ba 27 80 00       	push   $0x8027ba
  801074:	e8 e7 f1 ff ff       	call   800260 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801079:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801080:	f6 c2 02             	test   $0x2,%dl
  801083:	75 0c                	jne    801091 <fork+0x109>
  801085:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108c:	f6 c4 08             	test   $0x8,%ah
  80108f:	74 5b                	je     8010ec <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	68 05 08 00 00       	push   $0x805
  801099:	56                   	push   %esi
  80109a:	57                   	push   %edi
  80109b:	56                   	push   %esi
  80109c:	6a 00                	push   $0x0
  80109e:	e8 61 fc ff ff       	call   800d04 <sys_page_map>
		if (r < 0) {
  8010a3:	83 c4 20             	add    $0x20,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 14                	jns    8010be <fork+0x136>
		    	panic("sys page map fault %e");
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	68 ec 27 80 00       	push   $0x8027ec
  8010b2:	6a 5a                	push   $0x5a
  8010b4:	68 ba 27 80 00       	push   $0x8027ba
  8010b9:	e8 a2 f1 ff ff       	call   800260 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	68 05 08 00 00       	push   $0x805
  8010c6:	56                   	push   %esi
  8010c7:	6a 00                	push   $0x0
  8010c9:	56                   	push   %esi
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 33 fc ff ff       	call   800d04 <sys_page_map>
		if (r < 0) {
  8010d1:	83 c4 20             	add    $0x20,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	79 3e                	jns    801116 <fork+0x18e>
		    	panic("sys page map fault %e");
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	68 ec 27 80 00       	push   $0x8027ec
  8010e0:	6a 5e                	push   $0x5e
  8010e2:	68 ba 27 80 00       	push   $0x8027ba
  8010e7:	e8 74 f1 ff ff       	call   800260 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	6a 05                	push   $0x5
  8010f1:	56                   	push   %esi
  8010f2:	57                   	push   %edi
  8010f3:	56                   	push   %esi
  8010f4:	6a 00                	push   $0x0
  8010f6:	e8 09 fc ff ff       	call   800d04 <sys_page_map>
		if (r < 0) {
  8010fb:	83 c4 20             	add    $0x20,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	79 14                	jns    801116 <fork+0x18e>
		    	panic("sys page map fault %e");
  801102:	83 ec 04             	sub    $0x4,%esp
  801105:	68 ec 27 80 00       	push   $0x8027ec
  80110a:	6a 63                	push   $0x63
  80110c:	68 ba 27 80 00       	push   $0x8027ba
  801111:	e8 4a f1 ff ff       	call   800260 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801116:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80111c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801122:	0f 85 de fe ff ff    	jne    801006 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801128:	a1 20 44 80 00       	mov    0x804420,%eax
  80112d:	8b 40 64             	mov    0x64(%eax),%eax
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	50                   	push   %eax
  801134:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801137:	57                   	push   %edi
  801138:	e8 cf fc ff ff       	call   800e0c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	6a 02                	push   $0x2
  801142:	57                   	push   %edi
  801143:	e8 40 fc ff ff       	call   800d88 <sys_env_set_status>
	
	return envid;
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80114d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sfork>:

// Challenge!
int
sfork(void)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80115b:	68 02 28 80 00       	push   $0x802802
  801160:	68 a1 00 00 00       	push   $0xa1
  801165:	68 ba 27 80 00       	push   $0x8027ba
  80116a:	e8 f1 f0 ff ff       	call   800260 <_panic>

0080116f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
  801175:	05 00 00 00 30       	add    $0x30000000,%eax
  80117a:	c1 e8 0c             	shr    $0xc,%eax
}
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	05 00 00 00 30       	add    $0x30000000,%eax
  80118a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80118f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a1:	89 c2                	mov    %eax,%edx
  8011a3:	c1 ea 16             	shr    $0x16,%edx
  8011a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ad:	f6 c2 01             	test   $0x1,%dl
  8011b0:	74 11                	je     8011c3 <fd_alloc+0x2d>
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	c1 ea 0c             	shr    $0xc,%edx
  8011b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011be:	f6 c2 01             	test   $0x1,%dl
  8011c1:	75 09                	jne    8011cc <fd_alloc+0x36>
			*fd_store = fd;
  8011c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ca:	eb 17                	jmp    8011e3 <fd_alloc+0x4d>
  8011cc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d6:	75 c9                	jne    8011a1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011de:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011eb:	83 f8 1f             	cmp    $0x1f,%eax
  8011ee:	77 36                	ja     801226 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f0:	c1 e0 0c             	shl    $0xc,%eax
  8011f3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 ea 16             	shr    $0x16,%edx
  8011fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	74 24                	je     80122d <fd_lookup+0x48>
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 0c             	shr    $0xc,%edx
  80120e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 1a                	je     801234 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121d:	89 02                	mov    %eax,(%edx)
	return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	eb 13                	jmp    801239 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801226:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122b:	eb 0c                	jmp    801239 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb 05                	jmp    801239 <fd_lookup+0x54>
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801244:	ba 98 28 80 00       	mov    $0x802898,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801249:	eb 13                	jmp    80125e <dev_lookup+0x23>
  80124b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80124e:	39 08                	cmp    %ecx,(%eax)
  801250:	75 0c                	jne    80125e <dev_lookup+0x23>
			*dev = devtab[i];
  801252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801255:	89 01                	mov    %eax,(%ecx)
			return 0;
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	eb 2e                	jmp    80128c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125e:	8b 02                	mov    (%edx),%eax
  801260:	85 c0                	test   %eax,%eax
  801262:	75 e7                	jne    80124b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801264:	a1 20 44 80 00       	mov    0x804420,%eax
  801269:	8b 40 48             	mov    0x48(%eax),%eax
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	51                   	push   %ecx
  801270:	50                   	push   %eax
  801271:	68 18 28 80 00       	push   $0x802818
  801276:	e8 be f0 ff ff       	call   800339 <cprintf>
	*dev = 0;
  80127b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    

0080128e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
  801293:	83 ec 10             	sub    $0x10,%esp
  801296:	8b 75 08             	mov    0x8(%ebp),%esi
  801299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a6:	c1 e8 0c             	shr    $0xc,%eax
  8012a9:	50                   	push   %eax
  8012aa:	e8 36 ff ff ff       	call   8011e5 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 05                	js     8012bb <fd_close+0x2d>
	    || fd != fd2)
  8012b6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b9:	74 0c                	je     8012c7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012bb:	84 db                	test   %bl,%bl
  8012bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c2:	0f 44 c2             	cmove  %edx,%eax
  8012c5:	eb 41                	jmp    801308 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 36                	pushl  (%esi)
  8012d0:	e8 66 ff ff ff       	call   80123b <dev_lookup>
  8012d5:	89 c3                	mov    %eax,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 1a                	js     8012f8 <fd_close+0x6a>
		if (dev->dev_close)
  8012de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	74 0b                	je     8012f8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	56                   	push   %esi
  8012f1:	ff d0                	call   *%eax
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	56                   	push   %esi
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 43 fa ff ff       	call   800d46 <sys_page_unmap>
	return r;
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	89 d8                	mov    %ebx,%eax
}
  801308:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	pushl  0x8(%ebp)
  80131c:	e8 c4 fe ff ff       	call   8011e5 <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 10                	js     801338 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	6a 01                	push   $0x1
  80132d:	ff 75 f4             	pushl  -0xc(%ebp)
  801330:	e8 59 ff ff ff       	call   80128e <fd_close>
  801335:	83 c4 10             	add    $0x10,%esp
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <close_all>:

void
close_all(void)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	53                   	push   %ebx
  80133e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801341:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801346:	83 ec 0c             	sub    $0xc,%esp
  801349:	53                   	push   %ebx
  80134a:	e8 c0 ff ff ff       	call   80130f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80134f:	83 c3 01             	add    $0x1,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	83 fb 20             	cmp    $0x20,%ebx
  801358:	75 ec                	jne    801346 <close_all+0xc>
		close(i);
}
  80135a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	57                   	push   %edi
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	83 ec 2c             	sub    $0x2c,%esp
  801368:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80136b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	ff 75 08             	pushl  0x8(%ebp)
  801372:	e8 6e fe ff ff       	call   8011e5 <fd_lookup>
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	0f 88 c1 00 00 00    	js     801443 <dup+0xe4>
		return r;
	close(newfdnum);
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	56                   	push   %esi
  801386:	e8 84 ff ff ff       	call   80130f <close>

	newfd = INDEX2FD(newfdnum);
  80138b:	89 f3                	mov    %esi,%ebx
  80138d:	c1 e3 0c             	shl    $0xc,%ebx
  801390:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801396:	83 c4 04             	add    $0x4,%esp
  801399:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139c:	e8 de fd ff ff       	call   80117f <fd2data>
  8013a1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a3:	89 1c 24             	mov    %ebx,(%esp)
  8013a6:	e8 d4 fd ff ff       	call   80117f <fd2data>
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b1:	89 f8                	mov    %edi,%eax
  8013b3:	c1 e8 16             	shr    $0x16,%eax
  8013b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013bd:	a8 01                	test   $0x1,%al
  8013bf:	74 37                	je     8013f8 <dup+0x99>
  8013c1:	89 f8                	mov    %edi,%eax
  8013c3:	c1 e8 0c             	shr    $0xc,%eax
  8013c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013cd:	f6 c2 01             	test   $0x1,%dl
  8013d0:	74 26                	je     8013f8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e1:	50                   	push   %eax
  8013e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e5:	6a 00                	push   $0x0
  8013e7:	57                   	push   %edi
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 15 f9 ff ff       	call   800d04 <sys_page_map>
  8013ef:	89 c7                	mov    %eax,%edi
  8013f1:	83 c4 20             	add    $0x20,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 2e                	js     801426 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	c1 e8 0c             	shr    $0xc,%eax
  801400:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	25 07 0e 00 00       	and    $0xe07,%eax
  80140f:	50                   	push   %eax
  801410:	53                   	push   %ebx
  801411:	6a 00                	push   $0x0
  801413:	52                   	push   %edx
  801414:	6a 00                	push   $0x0
  801416:	e8 e9 f8 ff ff       	call   800d04 <sys_page_map>
  80141b:	89 c7                	mov    %eax,%edi
  80141d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801420:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801422:	85 ff                	test   %edi,%edi
  801424:	79 1d                	jns    801443 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	53                   	push   %ebx
  80142a:	6a 00                	push   $0x0
  80142c:	e8 15 f9 ff ff       	call   800d46 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	ff 75 d4             	pushl  -0x2c(%ebp)
  801437:	6a 00                	push   $0x0
  801439:	e8 08 f9 ff ff       	call   800d46 <sys_page_unmap>
	return r;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	89 f8                	mov    %edi,%eax
}
  801443:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 14             	sub    $0x14,%esp
  801452:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801455:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	53                   	push   %ebx
  80145a:	e8 86 fd ff ff       	call   8011e5 <fd_lookup>
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	89 c2                	mov    %eax,%edx
  801464:	85 c0                	test   %eax,%eax
  801466:	78 6d                	js     8014d5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	ff 30                	pushl  (%eax)
  801474:	e8 c2 fd ff ff       	call   80123b <dev_lookup>
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 4c                	js     8014cc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801480:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801483:	8b 42 08             	mov    0x8(%edx),%eax
  801486:	83 e0 03             	and    $0x3,%eax
  801489:	83 f8 01             	cmp    $0x1,%eax
  80148c:	75 21                	jne    8014af <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148e:	a1 20 44 80 00       	mov    0x804420,%eax
  801493:	8b 40 48             	mov    0x48(%eax),%eax
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	53                   	push   %ebx
  80149a:	50                   	push   %eax
  80149b:	68 5c 28 80 00       	push   $0x80285c
  8014a0:	e8 94 ee ff ff       	call   800339 <cprintf>
		return -E_INVAL;
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ad:	eb 26                	jmp    8014d5 <read+0x8a>
	}
	if (!dev->dev_read)
  8014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b2:	8b 40 08             	mov    0x8(%eax),%eax
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	74 17                	je     8014d0 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	ff 75 10             	pushl  0x10(%ebp)
  8014bf:	ff 75 0c             	pushl  0xc(%ebp)
  8014c2:	52                   	push   %edx
  8014c3:	ff d0                	call   *%eax
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	eb 09                	jmp    8014d5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	eb 05                	jmp    8014d5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014d5:	89 d0                	mov    %edx,%eax
  8014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f0:	eb 21                	jmp    801513 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	29 d8                	sub    %ebx,%eax
  8014f9:	50                   	push   %eax
  8014fa:	89 d8                	mov    %ebx,%eax
  8014fc:	03 45 0c             	add    0xc(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	57                   	push   %edi
  801501:	e8 45 ff ff ff       	call   80144b <read>
		if (m < 0)
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 10                	js     80151d <readn+0x41>
			return m;
		if (m == 0)
  80150d:	85 c0                	test   %eax,%eax
  80150f:	74 0a                	je     80151b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801511:	01 c3                	add    %eax,%ebx
  801513:	39 f3                	cmp    %esi,%ebx
  801515:	72 db                	jb     8014f2 <readn+0x16>
  801517:	89 d8                	mov    %ebx,%eax
  801519:	eb 02                	jmp    80151d <readn+0x41>
  80151b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80151d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801520:	5b                   	pop    %ebx
  801521:	5e                   	pop    %esi
  801522:	5f                   	pop    %edi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	53                   	push   %ebx
  801529:	83 ec 14             	sub    $0x14,%esp
  80152c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	53                   	push   %ebx
  801534:	e8 ac fc ff ff       	call   8011e5 <fd_lookup>
  801539:	83 c4 08             	add    $0x8,%esp
  80153c:	89 c2                	mov    %eax,%edx
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 68                	js     8015aa <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154c:	ff 30                	pushl  (%eax)
  80154e:	e8 e8 fc ff ff       	call   80123b <dev_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 47                	js     8015a1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801561:	75 21                	jne    801584 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801563:	a1 20 44 80 00       	mov    0x804420,%eax
  801568:	8b 40 48             	mov    0x48(%eax),%eax
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	53                   	push   %ebx
  80156f:	50                   	push   %eax
  801570:	68 78 28 80 00       	push   $0x802878
  801575:	e8 bf ed ff ff       	call   800339 <cprintf>
		return -E_INVAL;
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801582:	eb 26                	jmp    8015aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801584:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801587:	8b 52 0c             	mov    0xc(%edx),%edx
  80158a:	85 d2                	test   %edx,%edx
  80158c:	74 17                	je     8015a5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	ff 75 10             	pushl  0x10(%ebp)
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	50                   	push   %eax
  801598:	ff d2                	call   *%edx
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	eb 09                	jmp    8015aa <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	eb 05                	jmp    8015aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015aa:	89 d0                	mov    %edx,%eax
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	ff 75 08             	pushl  0x8(%ebp)
  8015be:	e8 22 fc ff ff       	call   8011e5 <fd_lookup>
  8015c3:	83 c4 08             	add    $0x8,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 0e                	js     8015d8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 14             	sub    $0x14,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	53                   	push   %ebx
  8015e9:	e8 f7 fb ff ff       	call   8011e5 <fd_lookup>
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 65                	js     80165c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	ff 30                	pushl  (%eax)
  801603:	e8 33 fc ff ff       	call   80123b <dev_lookup>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 44                	js     801653 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801612:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801616:	75 21                	jne    801639 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801618:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161d:	8b 40 48             	mov    0x48(%eax),%eax
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	53                   	push   %ebx
  801624:	50                   	push   %eax
  801625:	68 38 28 80 00       	push   $0x802838
  80162a:	e8 0a ed ff ff       	call   800339 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801637:	eb 23                	jmp    80165c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801639:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163c:	8b 52 18             	mov    0x18(%edx),%edx
  80163f:	85 d2                	test   %edx,%edx
  801641:	74 14                	je     801657 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	ff 75 0c             	pushl  0xc(%ebp)
  801649:	50                   	push   %eax
  80164a:	ff d2                	call   *%edx
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	eb 09                	jmp    80165c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	89 c2                	mov    %eax,%edx
  801655:	eb 05                	jmp    80165c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801657:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80165c:	89 d0                	mov    %edx,%eax
  80165e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	53                   	push   %ebx
  801667:	83 ec 14             	sub    $0x14,%esp
  80166a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 6c fb ff ff       	call   8011e5 <fd_lookup>
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 58                	js     8016da <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801688:	50                   	push   %eax
  801689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168c:	ff 30                	pushl  (%eax)
  80168e:	e8 a8 fb ff ff       	call   80123b <dev_lookup>
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 37                	js     8016d1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80169a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a1:	74 32                	je     8016d5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ad:	00 00 00 
	stat->st_isdir = 0;
  8016b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b7:	00 00 00 
	stat->st_dev = dev;
  8016ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	53                   	push   %ebx
  8016c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c7:	ff 50 14             	call   *0x14(%eax)
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	eb 09                	jmp    8016da <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	eb 05                	jmp    8016da <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016da:	89 d0                	mov    %edx,%eax
  8016dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	6a 00                	push   $0x0
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 e3 01 00 00       	call   8018d6 <open>
  8016f3:	89 c3                	mov    %eax,%ebx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 1b                	js     801717 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	ff 75 0c             	pushl  0xc(%ebp)
  801702:	50                   	push   %eax
  801703:	e8 5b ff ff ff       	call   801663 <fstat>
  801708:	89 c6                	mov    %eax,%esi
	close(fd);
  80170a:	89 1c 24             	mov    %ebx,(%esp)
  80170d:	e8 fd fb ff ff       	call   80130f <close>
	return r;
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	89 f0                	mov    %esi,%eax
}
  801717:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	89 c6                	mov    %eax,%esi
  801725:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801727:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80172e:	75 12                	jne    801742 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	6a 01                	push   $0x1
  801735:	e8 d1 08 00 00       	call   80200b <ipc_find_env>
  80173a:	a3 00 40 80 00       	mov    %eax,0x804000
  80173f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801742:	6a 07                	push   $0x7
  801744:	68 00 50 80 00       	push   $0x805000
  801749:	56                   	push   %esi
  80174a:	ff 35 00 40 80 00    	pushl  0x804000
  801750:	e8 54 08 00 00       	call   801fa9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801755:	83 c4 0c             	add    $0xc,%esp
  801758:	6a 00                	push   $0x0
  80175a:	53                   	push   %ebx
  80175b:	6a 00                	push   $0x0
  80175d:	e8 d5 07 00 00       	call   801f37 <ipc_recv>
}
  801762:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	8b 40 0c             	mov    0xc(%eax),%eax
  801775:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 02 00 00 00       	mov    $0x2,%eax
  80178c:	e8 8d ff ff ff       	call   80171e <fsipc>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 40 0c             	mov    0xc(%eax),%eax
  80179f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ae:	e8 6b ff ff ff       	call   80171e <fsipc>
}
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 04             	sub    $0x4,%esp
  8017bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d4:	e8 45 ff ff ff       	call   80171e <fsipc>
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 2c                	js     801809 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	68 00 50 80 00       	push   $0x805000
  8017e5:	53                   	push   %ebx
  8017e6:	e8 d3 f0 ff ff       	call   8008be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017eb:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f6:	a1 84 50 80 00       	mov    0x805084,%eax
  8017fb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801817:	8b 55 08             	mov    0x8(%ebp),%edx
  80181a:	8b 52 0c             	mov    0xc(%edx),%edx
  80181d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801823:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801828:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80182d:	0f 47 c2             	cmova  %edx,%eax
  801830:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801835:	50                   	push   %eax
  801836:	ff 75 0c             	pushl  0xc(%ebp)
  801839:	68 08 50 80 00       	push   $0x805008
  80183e:	e8 0d f2 ff ff       	call   800a50 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801843:	ba 00 00 00 00       	mov    $0x0,%edx
  801848:	b8 04 00 00 00       	mov    $0x4,%eax
  80184d:	e8 cc fe ff ff       	call   80171e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	8b 40 0c             	mov    0xc(%eax),%eax
  801862:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801867:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 03 00 00 00       	mov    $0x3,%eax
  801877:	e8 a2 fe ff ff       	call   80171e <fsipc>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 4b                	js     8018cd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801882:	39 c6                	cmp    %eax,%esi
  801884:	73 16                	jae    80189c <devfile_read+0x48>
  801886:	68 a8 28 80 00       	push   $0x8028a8
  80188b:	68 af 28 80 00       	push   $0x8028af
  801890:	6a 7c                	push   $0x7c
  801892:	68 c4 28 80 00       	push   $0x8028c4
  801897:	e8 c4 e9 ff ff       	call   800260 <_panic>
	assert(r <= PGSIZE);
  80189c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a1:	7e 16                	jle    8018b9 <devfile_read+0x65>
  8018a3:	68 cf 28 80 00       	push   $0x8028cf
  8018a8:	68 af 28 80 00       	push   $0x8028af
  8018ad:	6a 7d                	push   $0x7d
  8018af:	68 c4 28 80 00       	push   $0x8028c4
  8018b4:	e8 a7 e9 ff ff       	call   800260 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018b9:	83 ec 04             	sub    $0x4,%esp
  8018bc:	50                   	push   %eax
  8018bd:	68 00 50 80 00       	push   $0x805000
  8018c2:	ff 75 0c             	pushl  0xc(%ebp)
  8018c5:	e8 86 f1 ff ff       	call   800a50 <memmove>
	return r;
  8018ca:	83 c4 10             	add    $0x10,%esp
}
  8018cd:	89 d8                	mov    %ebx,%eax
  8018cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 20             	sub    $0x20,%esp
  8018dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e0:	53                   	push   %ebx
  8018e1:	e8 9f ef ff ff       	call   800885 <strlen>
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ee:	7f 67                	jg     801957 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f0:	83 ec 0c             	sub    $0xc,%esp
  8018f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f6:	50                   	push   %eax
  8018f7:	e8 9a f8 ff ff       	call   801196 <fd_alloc>
  8018fc:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ff:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801901:	85 c0                	test   %eax,%eax
  801903:	78 57                	js     80195c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	53                   	push   %ebx
  801909:	68 00 50 80 00       	push   $0x805000
  80190e:	e8 ab ef ff ff       	call   8008be <strcpy>
	fsipcbuf.open.req_omode = mode;
  801913:	8b 45 0c             	mov    0xc(%ebp),%eax
  801916:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80191b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80191e:	b8 01 00 00 00       	mov    $0x1,%eax
  801923:	e8 f6 fd ff ff       	call   80171e <fsipc>
  801928:	89 c3                	mov    %eax,%ebx
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	85 c0                	test   %eax,%eax
  80192f:	79 14                	jns    801945 <open+0x6f>
		fd_close(fd, 0);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	6a 00                	push   $0x0
  801936:	ff 75 f4             	pushl  -0xc(%ebp)
  801939:	e8 50 f9 ff ff       	call   80128e <fd_close>
		return r;
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	89 da                	mov    %ebx,%edx
  801943:	eb 17                	jmp    80195c <open+0x86>
	}

	return fd2num(fd);
  801945:	83 ec 0c             	sub    $0xc,%esp
  801948:	ff 75 f4             	pushl  -0xc(%ebp)
  80194b:	e8 1f f8 ff ff       	call   80116f <fd2num>
  801950:	89 c2                	mov    %eax,%edx
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	eb 05                	jmp    80195c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801957:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80195c:	89 d0                	mov    %edx,%eax
  80195e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801969:	ba 00 00 00 00       	mov    $0x0,%edx
  80196e:	b8 08 00 00 00       	mov    $0x8,%eax
  801973:	e8 a6 fd ff ff       	call   80171e <fsipc>
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	56                   	push   %esi
  80197e:	53                   	push   %ebx
  80197f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	ff 75 08             	pushl  0x8(%ebp)
  801988:	e8 f2 f7 ff ff       	call   80117f <fd2data>
  80198d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80198f:	83 c4 08             	add    $0x8,%esp
  801992:	68 db 28 80 00       	push   $0x8028db
  801997:	53                   	push   %ebx
  801998:	e8 21 ef ff ff       	call   8008be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80199d:	8b 46 04             	mov    0x4(%esi),%eax
  8019a0:	2b 06                	sub    (%esi),%eax
  8019a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019af:	00 00 00 
	stat->st_dev = &devpipe;
  8019b2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019b9:	30 80 00 
	return 0;
}
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	53                   	push   %ebx
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019d2:	53                   	push   %ebx
  8019d3:	6a 00                	push   $0x0
  8019d5:	e8 6c f3 ff ff       	call   800d46 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019da:	89 1c 24             	mov    %ebx,(%esp)
  8019dd:	e8 9d f7 ff ff       	call   80117f <fd2data>
  8019e2:	83 c4 08             	add    $0x8,%esp
  8019e5:	50                   	push   %eax
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 59 f3 ff ff       	call   800d46 <sys_page_unmap>
}
  8019ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	57                   	push   %edi
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 1c             	sub    $0x1c,%esp
  8019fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019fe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a00:	a1 20 44 80 00       	mov    0x804420,%eax
  801a05:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0e:	e8 31 06 00 00       	call   802044 <pageref>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	89 3c 24             	mov    %edi,(%esp)
  801a18:	e8 27 06 00 00       	call   802044 <pageref>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	39 c3                	cmp    %eax,%ebx
  801a22:	0f 94 c1             	sete   %cl
  801a25:	0f b6 c9             	movzbl %cl,%ecx
  801a28:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a2b:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a34:	39 ce                	cmp    %ecx,%esi
  801a36:	74 1b                	je     801a53 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a38:	39 c3                	cmp    %eax,%ebx
  801a3a:	75 c4                	jne    801a00 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3c:	8b 42 58             	mov    0x58(%edx),%eax
  801a3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a42:	50                   	push   %eax
  801a43:	56                   	push   %esi
  801a44:	68 e2 28 80 00       	push   $0x8028e2
  801a49:	e8 eb e8 ff ff       	call   800339 <cprintf>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	eb ad                	jmp    801a00 <_pipeisclosed+0xe>
	}
}
  801a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5f                   	pop    %edi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	57                   	push   %edi
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 28             	sub    $0x28,%esp
  801a67:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a6a:	56                   	push   %esi
  801a6b:	e8 0f f7 ff ff       	call   80117f <fd2data>
  801a70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	bf 00 00 00 00       	mov    $0x0,%edi
  801a7a:	eb 4b                	jmp    801ac7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7c:	89 da                	mov    %ebx,%edx
  801a7e:	89 f0                	mov    %esi,%eax
  801a80:	e8 6d ff ff ff       	call   8019f2 <_pipeisclosed>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	75 48                	jne    801ad1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a89:	e8 14 f2 ff ff       	call   800ca2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8e:	8b 43 04             	mov    0x4(%ebx),%eax
  801a91:	8b 0b                	mov    (%ebx),%ecx
  801a93:	8d 51 20             	lea    0x20(%ecx),%edx
  801a96:	39 d0                	cmp    %edx,%eax
  801a98:	73 e2                	jae    801a7c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aa1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	c1 fa 1f             	sar    $0x1f,%edx
  801aa9:	89 d1                	mov    %edx,%ecx
  801aab:	c1 e9 1b             	shr    $0x1b,%ecx
  801aae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ab1:	83 e2 1f             	and    $0x1f,%edx
  801ab4:	29 ca                	sub    %ecx,%edx
  801ab6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801abe:	83 c0 01             	add    $0x1,%eax
  801ac1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac4:	83 c7 01             	add    $0x1,%edi
  801ac7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aca:	75 c2                	jne    801a8e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801acc:	8b 45 10             	mov    0x10(%ebp),%eax
  801acf:	eb 05                	jmp    801ad6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 18             	sub    $0x18,%esp
  801ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aea:	57                   	push   %edi
  801aeb:	e8 8f f6 ff ff       	call   80117f <fd2data>
  801af0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afa:	eb 3d                	jmp    801b39 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801afc:	85 db                	test   %ebx,%ebx
  801afe:	74 04                	je     801b04 <devpipe_read+0x26>
				return i;
  801b00:	89 d8                	mov    %ebx,%eax
  801b02:	eb 44                	jmp    801b48 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b04:	89 f2                	mov    %esi,%edx
  801b06:	89 f8                	mov    %edi,%eax
  801b08:	e8 e5 fe ff ff       	call   8019f2 <_pipeisclosed>
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	75 32                	jne    801b43 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b11:	e8 8c f1 ff ff       	call   800ca2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b16:	8b 06                	mov    (%esi),%eax
  801b18:	3b 46 04             	cmp    0x4(%esi),%eax
  801b1b:	74 df                	je     801afc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b1d:	99                   	cltd   
  801b1e:	c1 ea 1b             	shr    $0x1b,%edx
  801b21:	01 d0                	add    %edx,%eax
  801b23:	83 e0 1f             	and    $0x1f,%eax
  801b26:	29 d0                	sub    %edx,%eax
  801b28:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b30:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b33:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b36:	83 c3 01             	add    $0x1,%ebx
  801b39:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b3c:	75 d8                	jne    801b16 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b41:	eb 05                	jmp    801b48 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5b:	50                   	push   %eax
  801b5c:	e8 35 f6 ff ff       	call   801196 <fd_alloc>
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	89 c2                	mov    %eax,%edx
  801b66:	85 c0                	test   %eax,%eax
  801b68:	0f 88 2c 01 00 00    	js     801c9a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	68 07 04 00 00       	push   $0x407
  801b76:	ff 75 f4             	pushl  -0xc(%ebp)
  801b79:	6a 00                	push   $0x0
  801b7b:	e8 41 f1 ff ff       	call   800cc1 <sys_page_alloc>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	89 c2                	mov    %eax,%edx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	0f 88 0d 01 00 00    	js     801c9a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b8d:	83 ec 0c             	sub    $0xc,%esp
  801b90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b93:	50                   	push   %eax
  801b94:	e8 fd f5 ff ff       	call   801196 <fd_alloc>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 e2 00 00 00    	js     801c88 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba6:	83 ec 04             	sub    $0x4,%esp
  801ba9:	68 07 04 00 00       	push   $0x407
  801bae:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 09 f1 ff ff       	call   800cc1 <sys_page_alloc>
  801bb8:	89 c3                	mov    %eax,%ebx
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 c3 00 00 00    	js     801c88 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcb:	e8 af f5 ff ff       	call   80117f <fd2data>
  801bd0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd2:	83 c4 0c             	add    $0xc,%esp
  801bd5:	68 07 04 00 00       	push   $0x407
  801bda:	50                   	push   %eax
  801bdb:	6a 00                	push   $0x0
  801bdd:	e8 df f0 ff ff       	call   800cc1 <sys_page_alloc>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	0f 88 89 00 00 00    	js     801c78 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf5:	e8 85 f5 ff ff       	call   80117f <fd2data>
  801bfa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c01:	50                   	push   %eax
  801c02:	6a 00                	push   $0x0
  801c04:	56                   	push   %esi
  801c05:	6a 00                	push   $0x0
  801c07:	e8 f8 f0 ff ff       	call   800d04 <sys_page_map>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	83 c4 20             	add    $0x20,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 55                	js     801c6a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c2a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c33:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	ff 75 f4             	pushl  -0xc(%ebp)
  801c45:	e8 25 f5 ff ff       	call   80116f <fd2num>
  801c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c4f:	83 c4 04             	add    $0x4,%esp
  801c52:	ff 75 f0             	pushl  -0x10(%ebp)
  801c55:	e8 15 f5 ff ff       	call   80116f <fd2num>
  801c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	ba 00 00 00 00       	mov    $0x0,%edx
  801c68:	eb 30                	jmp    801c9a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c6a:	83 ec 08             	sub    $0x8,%esp
  801c6d:	56                   	push   %esi
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 d1 f0 ff ff       	call   800d46 <sys_page_unmap>
  801c75:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 c1 f0 ff ff       	call   800d46 <sys_page_unmap>
  801c85:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 b1 f0 ff ff       	call   800d46 <sys_page_unmap>
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c9a:	89 d0                	mov    %edx,%eax
  801c9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cac:	50                   	push   %eax
  801cad:	ff 75 08             	pushl  0x8(%ebp)
  801cb0:	e8 30 f5 ff ff       	call   8011e5 <fd_lookup>
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	78 18                	js     801cd4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc2:	e8 b8 f4 ff ff       	call   80117f <fd2data>
	return _pipeisclosed(fd, p);
  801cc7:	89 c2                	mov    %eax,%edx
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	e8 21 fd ff ff       	call   8019f2 <_pipeisclosed>
  801cd1:	83 c4 10             	add    $0x10,%esp
}
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	56                   	push   %esi
  801cda:	53                   	push   %ebx
  801cdb:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801cde:	85 f6                	test   %esi,%esi
  801ce0:	75 16                	jne    801cf8 <wait+0x22>
  801ce2:	68 fa 28 80 00       	push   $0x8028fa
  801ce7:	68 af 28 80 00       	push   $0x8028af
  801cec:	6a 09                	push   $0x9
  801cee:	68 05 29 80 00       	push   $0x802905
  801cf3:	e8 68 e5 ff ff       	call   800260 <_panic>
	e = &envs[ENVX(envid)];
  801cf8:	89 f3                	mov    %esi,%ebx
  801cfa:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d00:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d03:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d09:	eb 05                	jmp    801d10 <wait+0x3a>
		sys_yield();
  801d0b:	e8 92 ef ff ff       	call   800ca2 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d10:	8b 43 48             	mov    0x48(%ebx),%eax
  801d13:	39 c6                	cmp    %eax,%esi
  801d15:	75 07                	jne    801d1e <wait+0x48>
  801d17:	8b 43 54             	mov    0x54(%ebx),%eax
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	75 ed                	jne    801d0b <wait+0x35>
		sys_yield();
}
  801d1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d35:	68 10 29 80 00       	push   $0x802910
  801d3a:	ff 75 0c             	pushl  0xc(%ebp)
  801d3d:	e8 7c eb ff ff       	call   8008be <strcpy>
	return 0;
}
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d55:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d60:	eb 2d                	jmp    801d8f <devcons_write+0x46>
		m = n - tot;
  801d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d65:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d67:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d6a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d6f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	53                   	push   %ebx
  801d76:	03 45 0c             	add    0xc(%ebp),%eax
  801d79:	50                   	push   %eax
  801d7a:	57                   	push   %edi
  801d7b:	e8 d0 ec ff ff       	call   800a50 <memmove>
		sys_cputs(buf, m);
  801d80:	83 c4 08             	add    $0x8,%esp
  801d83:	53                   	push   %ebx
  801d84:	57                   	push   %edi
  801d85:	e8 7b ee ff ff       	call   800c05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8a:	01 de                	add    %ebx,%esi
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	89 f0                	mov    %esi,%eax
  801d91:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d94:	72 cc                	jb     801d62 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5f                   	pop    %edi
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dad:	74 2a                	je     801dd9 <devcons_read+0x3b>
  801daf:	eb 05                	jmp    801db6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db1:	e8 ec ee ff ff       	call   800ca2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db6:	e8 68 ee ff ff       	call   800c23 <sys_cgetc>
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	74 f2                	je     801db1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	78 16                	js     801dd9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc3:	83 f8 04             	cmp    $0x4,%eax
  801dc6:	74 0c                	je     801dd4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcb:	88 02                	mov    %al,(%edx)
	return 1;
  801dcd:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd2:	eb 05                	jmp    801dd9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de1:	8b 45 08             	mov    0x8(%ebp),%eax
  801de4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de7:	6a 01                	push   $0x1
  801de9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	e8 13 ee ff ff       	call   800c05 <sys_cputs>
}
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <getchar>:

int
getchar(void)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dfd:	6a 01                	push   $0x1
  801dff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e02:	50                   	push   %eax
  801e03:	6a 00                	push   $0x0
  801e05:	e8 41 f6 ff ff       	call   80144b <read>
	if (r < 0)
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 0f                	js     801e20 <getchar+0x29>
		return r;
	if (r < 1)
  801e11:	85 c0                	test   %eax,%eax
  801e13:	7e 06                	jle    801e1b <getchar+0x24>
		return -E_EOF;
	return c;
  801e15:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e19:	eb 05                	jmp    801e20 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e1b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	ff 75 08             	pushl  0x8(%ebp)
  801e2f:	e8 b1 f3 ff ff       	call   8011e5 <fd_lookup>
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 11                	js     801e4c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e44:	39 10                	cmp    %edx,(%eax)
  801e46:	0f 94 c0             	sete   %al
  801e49:	0f b6 c0             	movzbl %al,%eax
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <opencons>:

int
opencons(void)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e57:	50                   	push   %eax
  801e58:	e8 39 f3 ff ff       	call   801196 <fd_alloc>
  801e5d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e60:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e62:	85 c0                	test   %eax,%eax
  801e64:	78 3e                	js     801ea4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e66:	83 ec 04             	sub    $0x4,%esp
  801e69:	68 07 04 00 00       	push   $0x407
  801e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e71:	6a 00                	push   $0x0
  801e73:	e8 49 ee ff ff       	call   800cc1 <sys_page_alloc>
  801e78:	83 c4 10             	add    $0x10,%esp
		return r;
  801e7b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 23                	js     801ea4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e96:	83 ec 0c             	sub    $0xc,%esp
  801e99:	50                   	push   %eax
  801e9a:	e8 d0 f2 ff ff       	call   80116f <fd2num>
  801e9f:	89 c2                	mov    %eax,%edx
  801ea1:	83 c4 10             	add    $0x10,%esp
}
  801ea4:	89 d0                	mov    %edx,%eax
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eae:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb5:	75 2a                	jne    801ee1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801eb7:	83 ec 04             	sub    $0x4,%esp
  801eba:	6a 07                	push   $0x7
  801ebc:	68 00 f0 bf ee       	push   $0xeebff000
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 f9 ed ff ff       	call   800cc1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	79 12                	jns    801ee1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ecf:	50                   	push   %eax
  801ed0:	68 1c 29 80 00       	push   $0x80291c
  801ed5:	6a 23                	push   $0x23
  801ed7:	68 20 29 80 00       	push   $0x802920
  801edc:	e8 7f e3 ff ff       	call   800260 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee4:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801ee9:	83 ec 08             	sub    $0x8,%esp
  801eec:	68 13 1f 80 00       	push   $0x801f13
  801ef1:	6a 00                	push   $0x0
  801ef3:	e8 14 ef ff ff       	call   800e0c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	85 c0                	test   %eax,%eax
  801efd:	79 12                	jns    801f11 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801eff:	50                   	push   %eax
  801f00:	68 1c 29 80 00       	push   $0x80291c
  801f05:	6a 2c                	push   $0x2c
  801f07:	68 20 29 80 00       	push   $0x802920
  801f0c:	e8 4f e3 ff ff       	call   800260 <_panic>
	}
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f13:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f14:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f19:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f1b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f1e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f22:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f27:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f2b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f2d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f30:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f31:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f34:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f35:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f36:	c3                   	ret    

00801f37 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	56                   	push   %esi
  801f3b:	53                   	push   %ebx
  801f3c:	8b 75 08             	mov    0x8(%ebp),%esi
  801f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f45:	85 c0                	test   %eax,%eax
  801f47:	75 12                	jne    801f5b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f49:	83 ec 0c             	sub    $0xc,%esp
  801f4c:	68 00 00 c0 ee       	push   $0xeec00000
  801f51:	e8 1b ef ff ff       	call   800e71 <sys_ipc_recv>
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	eb 0c                	jmp    801f67 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	50                   	push   %eax
  801f5f:	e8 0d ef ff ff       	call   800e71 <sys_ipc_recv>
  801f64:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f67:	85 f6                	test   %esi,%esi
  801f69:	0f 95 c1             	setne  %cl
  801f6c:	85 db                	test   %ebx,%ebx
  801f6e:	0f 95 c2             	setne  %dl
  801f71:	84 d1                	test   %dl,%cl
  801f73:	74 09                	je     801f7e <ipc_recv+0x47>
  801f75:	89 c2                	mov    %eax,%edx
  801f77:	c1 ea 1f             	shr    $0x1f,%edx
  801f7a:	84 d2                	test   %dl,%dl
  801f7c:	75 24                	jne    801fa2 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801f7e:	85 f6                	test   %esi,%esi
  801f80:	74 0a                	je     801f8c <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801f82:	a1 20 44 80 00       	mov    0x804420,%eax
  801f87:	8b 40 74             	mov    0x74(%eax),%eax
  801f8a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801f8c:	85 db                	test   %ebx,%ebx
  801f8e:	74 0a                	je     801f9a <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801f90:	a1 20 44 80 00       	mov    0x804420,%eax
  801f95:	8b 40 78             	mov    0x78(%eax),%eax
  801f98:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f9a:	a1 20 44 80 00       	mov    0x804420,%eax
  801f9f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa5:	5b                   	pop    %ebx
  801fa6:	5e                   	pop    %esi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	57                   	push   %edi
  801fad:	56                   	push   %esi
  801fae:	53                   	push   %ebx
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801fbb:	85 db                	test   %ebx,%ebx
  801fbd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fc2:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801fc5:	ff 75 14             	pushl  0x14(%ebp)
  801fc8:	53                   	push   %ebx
  801fc9:	56                   	push   %esi
  801fca:	57                   	push   %edi
  801fcb:	e8 7e ee ff ff       	call   800e4e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801fd0:	89 c2                	mov    %eax,%edx
  801fd2:	c1 ea 1f             	shr    $0x1f,%edx
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	84 d2                	test   %dl,%dl
  801fda:	74 17                	je     801ff3 <ipc_send+0x4a>
  801fdc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fdf:	74 12                	je     801ff3 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801fe1:	50                   	push   %eax
  801fe2:	68 2e 29 80 00       	push   $0x80292e
  801fe7:	6a 47                	push   $0x47
  801fe9:	68 3c 29 80 00       	push   $0x80293c
  801fee:	e8 6d e2 ff ff       	call   800260 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ff3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff6:	75 07                	jne    801fff <ipc_send+0x56>
			sys_yield();
  801ff8:	e8 a5 ec ff ff       	call   800ca2 <sys_yield>
  801ffd:	eb c6                	jmp    801fc5 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801fff:	85 c0                	test   %eax,%eax
  802001:	75 c2                	jne    801fc5 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    

0080200b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802016:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802019:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201f:	8b 52 50             	mov    0x50(%edx),%edx
  802022:	39 ca                	cmp    %ecx,%edx
  802024:	75 0d                	jne    802033 <ipc_find_env+0x28>
			return envs[i].env_id;
  802026:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802029:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80202e:	8b 40 48             	mov    0x48(%eax),%eax
  802031:	eb 0f                	jmp    802042 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802033:	83 c0 01             	add    $0x1,%eax
  802036:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203b:	75 d9                	jne    802016 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204a:	89 d0                	mov    %edx,%eax
  80204c:	c1 e8 16             	shr    $0x16,%eax
  80204f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205b:	f6 c1 01             	test   $0x1,%cl
  80205e:	74 1d                	je     80207d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802060:	c1 ea 0c             	shr    $0xc,%edx
  802063:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80206a:	f6 c2 01             	test   $0x1,%dl
  80206d:	74 0e                	je     80207d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206f:	c1 ea 0c             	shr    $0xc,%edx
  802072:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802079:	ef 
  80207a:	0f b7 c0             	movzwl %ax,%eax
}
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
