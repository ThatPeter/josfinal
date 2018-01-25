
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
  800043:	e8 df 18 00 00       	call   801927 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 85 23 80 00       	push   $0x802385
  800057:	6a 0c                	push   $0xc
  800059:	68 93 23 80 00       	push   $0x802393
  80005e:	e8 d9 01 00 00       	call   80023c <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 94 15 00 00       	call   801602 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 ac 14 00 00       	call   80152d <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 a8 23 80 00       	push   $0x8023a8
  800090:	6a 0f                	push   $0xf
  800092:	68 93 23 80 00       	push   $0x802393
  800097:	e8 a0 01 00 00       	call   80023c <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 03 0f 00 00       	call   800fa4 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 b2 23 80 00       	push   $0x8023b2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 93 23 80 00       	push   $0x802393
  8000b4:	e8 83 01 00 00       	call   80023c <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 36 15 00 00       	call   801602 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  8000d3:	e8 3d 02 00 00       	call   800315 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 42 14 00 00       	call   80152d <readn>
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
  800103:	e8 34 01 00 00       	call   80023c <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 8c 09 00 00       	call   800aa7 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 60 24 80 00       	push   $0x802460
  80012a:	6a 19                	push   $0x19
  80012c:	68 93 23 80 00       	push   $0x802393
  800131:	e8 06 01 00 00       	call   80023c <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 bb 23 80 00       	push   $0x8023bb
  80013e:	e8 d2 01 00 00       	call   800315 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 b4 14 00 00       	call   801602 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 0a 12 00 00       	call   801360 <close>
		exit();
  800156:	e8 c7 00 00 00       	call   800222 <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 c0 1b 00 00       	call   801d27 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 b3 13 00 00       	call   80152d <readn>
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
  800192:	e8 a5 00 00 00       	call   80023c <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 d4 23 80 00       	push   $0x8023d4
  80019f:	e8 71 01 00 00       	call   800315 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 b4 11 00 00       	call   801360 <close>
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
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 97 0a 00 00       	call   800c5f <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	89 c2                	mov    %eax,%edx
  8001cf:	c1 e2 07             	shl    $0x7,%edx
  8001d2:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8001d9:	a3 20 44 80 00       	mov    %eax,0x804420
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001de:	85 db                	test   %ebx,%ebx
  8001e0:	7e 07                	jle    8001e9 <libmain+0x31>
		binaryname = argv[0];
  8001e2:	8b 06                	mov    (%esi),%eax
  8001e4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	e8 40 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001f3:	e8 2a 00 00 00       	call   800222 <exit>
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800208:	a1 24 44 80 00       	mov    0x804424,%eax
	func();
  80020d:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80020f:	e8 4b 0a 00 00       	call   800c5f <sys_getenvid>
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	50                   	push   %eax
  800218:	e8 91 0c 00 00       	call   800eae <sys_thread_free>
}
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800228:	e8 5e 11 00 00       	call   80138b <close_all>
	sys_env_destroy(0);
  80022d:	83 ec 0c             	sub    $0xc,%esp
  800230:	6a 00                	push   $0x0
  800232:	e8 e7 09 00 00       	call   800c1e <sys_env_destroy>
}
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800241:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800244:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80024a:	e8 10 0a 00 00       	call   800c5f <sys_getenvid>
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	ff 75 0c             	pushl  0xc(%ebp)
  800255:	ff 75 08             	pushl  0x8(%ebp)
  800258:	56                   	push   %esi
  800259:	50                   	push   %eax
  80025a:	68 c8 24 80 00       	push   $0x8024c8
  80025f:	e8 b1 00 00 00       	call   800315 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800264:	83 c4 18             	add    $0x18,%esp
  800267:	53                   	push   %ebx
  800268:	ff 75 10             	pushl  0x10(%ebp)
  80026b:	e8 54 00 00 00       	call   8002c4 <vcprintf>
	cprintf("\n");
  800270:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  800277:	e8 99 00 00 00       	call   800315 <cprintf>
  80027c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027f:	cc                   	int3   
  800280:	eb fd                	jmp    80027f <_panic+0x43>

00800282 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	53                   	push   %ebx
  800286:	83 ec 04             	sub    $0x4,%esp
  800289:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028c:	8b 13                	mov    (%ebx),%edx
  80028e:	8d 42 01             	lea    0x1(%edx),%eax
  800291:	89 03                	mov    %eax,(%ebx)
  800293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800296:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80029a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029f:	75 1a                	jne    8002bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	68 ff 00 00 00       	push   $0xff
  8002a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 2f 09 00 00       	call   800be1 <sys_cputs>
		b->idx = 0;
  8002b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d4:	00 00 00 
	b.cnt = 0;
  8002d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e1:	ff 75 0c             	pushl  0xc(%ebp)
  8002e4:	ff 75 08             	pushl  0x8(%ebp)
  8002e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ed:	50                   	push   %eax
  8002ee:	68 82 02 80 00       	push   $0x800282
  8002f3:	e8 54 01 00 00       	call   80044c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f8:	83 c4 08             	add    $0x8,%esp
  8002fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800301:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800307:	50                   	push   %eax
  800308:	e8 d4 08 00 00       	call   800be1 <sys_cputs>

	return b.cnt;
}
  80030d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 08             	pushl  0x8(%ebp)
  800322:	e8 9d ff ff ff       	call   8002c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 1c             	sub    $0x1c,%esp
  800332:	89 c7                	mov    %eax,%edi
  800334:	89 d6                	mov    %edx,%esi
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800342:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800345:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800350:	39 d3                	cmp    %edx,%ebx
  800352:	72 05                	jb     800359 <printnum+0x30>
  800354:	39 45 10             	cmp    %eax,0x10(%ebp)
  800357:	77 45                	ja     80039e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800359:	83 ec 0c             	sub    $0xc,%esp
  80035c:	ff 75 18             	pushl  0x18(%ebp)
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800365:	53                   	push   %ebx
  800366:	ff 75 10             	pushl  0x10(%ebp)
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036f:	ff 75 e0             	pushl  -0x20(%ebp)
  800372:	ff 75 dc             	pushl  -0x24(%ebp)
  800375:	ff 75 d8             	pushl  -0x28(%ebp)
  800378:	e8 63 1d 00 00       	call   8020e0 <__udivdi3>
  80037d:	83 c4 18             	add    $0x18,%esp
  800380:	52                   	push   %edx
  800381:	50                   	push   %eax
  800382:	89 f2                	mov    %esi,%edx
  800384:	89 f8                	mov    %edi,%eax
  800386:	e8 9e ff ff ff       	call   800329 <printnum>
  80038b:	83 c4 20             	add    $0x20,%esp
  80038e:	eb 18                	jmp    8003a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800390:	83 ec 08             	sub    $0x8,%esp
  800393:	56                   	push   %esi
  800394:	ff 75 18             	pushl  0x18(%ebp)
  800397:	ff d7                	call   *%edi
  800399:	83 c4 10             	add    $0x10,%esp
  80039c:	eb 03                	jmp    8003a1 <printnum+0x78>
  80039e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a1:	83 eb 01             	sub    $0x1,%ebx
  8003a4:	85 db                	test   %ebx,%ebx
  8003a6:	7f e8                	jg     800390 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	56                   	push   %esi
  8003ac:	83 ec 04             	sub    $0x4,%esp
  8003af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bb:	e8 50 1e 00 00       	call   802210 <__umoddi3>
  8003c0:	83 c4 14             	add    $0x14,%esp
  8003c3:	0f be 80 eb 24 80 00 	movsbl 0x8024eb(%eax),%eax
  8003ca:	50                   	push   %eax
  8003cb:	ff d7                	call   *%edi
}
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5f                   	pop    %edi
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003db:	83 fa 01             	cmp    $0x1,%edx
  8003de:	7e 0e                	jle    8003ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	8b 52 04             	mov    0x4(%edx),%edx
  8003ec:	eb 22                	jmp    800410 <getuint+0x38>
	else if (lflag)
  8003ee:	85 d2                	test   %edx,%edx
  8003f0:	74 10                	je     800402 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f7:	89 08                	mov    %ecx,(%eax)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800400:	eb 0e                	jmp    800410 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800402:	8b 10                	mov    (%eax),%edx
  800404:	8d 4a 04             	lea    0x4(%edx),%ecx
  800407:	89 08                	mov    %ecx,(%eax)
  800409:	8b 02                	mov    (%edx),%eax
  80040b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800418:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	3b 50 04             	cmp    0x4(%eax),%edx
  800421:	73 0a                	jae    80042d <sprintputch+0x1b>
		*b->buf++ = ch;
  800423:	8d 4a 01             	lea    0x1(%edx),%ecx
  800426:	89 08                	mov    %ecx,(%eax)
  800428:	8b 45 08             	mov    0x8(%ebp),%eax
  80042b:	88 02                	mov    %al,(%edx)
}
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800435:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800438:	50                   	push   %eax
  800439:	ff 75 10             	pushl  0x10(%ebp)
  80043c:	ff 75 0c             	pushl  0xc(%ebp)
  80043f:	ff 75 08             	pushl  0x8(%ebp)
  800442:	e8 05 00 00 00       	call   80044c <vprintfmt>
	va_end(ap);
}
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	c9                   	leave  
  80044b:	c3                   	ret    

0080044c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 2c             	sub    $0x2c,%esp
  800455:	8b 75 08             	mov    0x8(%ebp),%esi
  800458:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045e:	eb 12                	jmp    800472 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800460:	85 c0                	test   %eax,%eax
  800462:	0f 84 89 03 00 00    	je     8007f1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	53                   	push   %ebx
  80046c:	50                   	push   %eax
  80046d:	ff d6                	call   *%esi
  80046f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800472:	83 c7 01             	add    $0x1,%edi
  800475:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800479:	83 f8 25             	cmp    $0x25,%eax
  80047c:	75 e2                	jne    800460 <vprintfmt+0x14>
  80047e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800482:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800489:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800490:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800497:	ba 00 00 00 00       	mov    $0x0,%edx
  80049c:	eb 07                	jmp    8004a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8d 47 01             	lea    0x1(%edi),%eax
  8004a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ab:	0f b6 07             	movzbl (%edi),%eax
  8004ae:	0f b6 c8             	movzbl %al,%ecx
  8004b1:	83 e8 23             	sub    $0x23,%eax
  8004b4:	3c 55                	cmp    $0x55,%al
  8004b6:	0f 87 1a 03 00 00    	ja     8007d6 <vprintfmt+0x38a>
  8004bc:	0f b6 c0             	movzbl %al,%eax
  8004bf:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004cd:	eb d6                	jmp    8004a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e7:	83 fa 09             	cmp    $0x9,%edx
  8004ea:	77 39                	ja     800525 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ef:	eb e9                	jmp    8004da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800502:	eb 27                	jmp    80052b <vprintfmt+0xdf>
  800504:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800507:	85 c0                	test   %eax,%eax
  800509:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050e:	0f 49 c8             	cmovns %eax,%ecx
  800511:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800517:	eb 8c                	jmp    8004a5 <vprintfmt+0x59>
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800523:	eb 80                	jmp    8004a5 <vprintfmt+0x59>
  800525:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800528:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052f:	0f 89 70 ff ff ff    	jns    8004a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800535:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800538:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800542:	e9 5e ff ff ff       	jmp    8004a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800547:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054d:	e9 53 ff ff ff       	jmp    8004a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	53                   	push   %ebx
  80055f:	ff 30                	pushl  (%eax)
  800561:	ff d6                	call   *%esi
			break;
  800563:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800569:	e9 04 ff ff ff       	jmp    800472 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	99                   	cltd   
  80057a:	31 d0                	xor    %edx,%eax
  80057c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057e:	83 f8 0f             	cmp    $0xf,%eax
  800581:	7f 0b                	jg     80058e <vprintfmt+0x142>
  800583:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  80058a:	85 d2                	test   %edx,%edx
  80058c:	75 18                	jne    8005a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058e:	50                   	push   %eax
  80058f:	68 03 25 80 00       	push   $0x802503
  800594:	53                   	push   %ebx
  800595:	56                   	push   %esi
  800596:	e8 94 fe ff ff       	call   80042f <printfmt>
  80059b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a1:	e9 cc fe ff ff       	jmp    800472 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a6:	52                   	push   %edx
  8005a7:	68 31 29 80 00       	push   $0x802931
  8005ac:	53                   	push   %ebx
  8005ad:	56                   	push   %esi
  8005ae:	e8 7c fe ff ff       	call   80042f <printfmt>
  8005b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 b4 fe ff ff       	jmp    800472 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	b8 fc 24 80 00       	mov    $0x8024fc,%eax
  8005d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d7:	0f 8e 94 00 00 00    	jle    800671 <vprintfmt+0x225>
  8005dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e1:	0f 84 98 00 00 00    	je     80067f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ed:	57                   	push   %edi
  8005ee:	e8 86 02 00 00       	call   800879 <strnlen>
  8005f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f6:	29 c1                	sub    %eax,%ecx
  8005f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800602:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800605:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800608:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060a:	eb 0f                	jmp    80061b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	ff 75 e0             	pushl  -0x20(%ebp)
  800613:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	83 ef 01             	sub    $0x1,%edi
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	85 ff                	test   %edi,%edi
  80061d:	7f ed                	jg     80060c <vprintfmt+0x1c0>
  80061f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800622:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800625:	85 c9                	test   %ecx,%ecx
  800627:	b8 00 00 00 00       	mov    $0x0,%eax
  80062c:	0f 49 c1             	cmovns %ecx,%eax
  80062f:	29 c1                	sub    %eax,%ecx
  800631:	89 75 08             	mov    %esi,0x8(%ebp)
  800634:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800637:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063a:	89 cb                	mov    %ecx,%ebx
  80063c:	eb 4d                	jmp    80068b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800642:	74 1b                	je     80065f <vprintfmt+0x213>
  800644:	0f be c0             	movsbl %al,%eax
  800647:	83 e8 20             	sub    $0x20,%eax
  80064a:	83 f8 5e             	cmp    $0x5e,%eax
  80064d:	76 10                	jbe    80065f <vprintfmt+0x213>
					putch('?', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	6a 3f                	push   $0x3f
  800657:	ff 55 08             	call   *0x8(%ebp)
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	eb 0d                	jmp    80066c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	ff 75 0c             	pushl  0xc(%ebp)
  800665:	52                   	push   %edx
  800666:	ff 55 08             	call   *0x8(%ebp)
  800669:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066c:	83 eb 01             	sub    $0x1,%ebx
  80066f:	eb 1a                	jmp    80068b <vprintfmt+0x23f>
  800671:	89 75 08             	mov    %esi,0x8(%ebp)
  800674:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800677:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067d:	eb 0c                	jmp    80068b <vprintfmt+0x23f>
  80067f:	89 75 08             	mov    %esi,0x8(%ebp)
  800682:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800685:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800688:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068b:	83 c7 01             	add    $0x1,%edi
  80068e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800692:	0f be d0             	movsbl %al,%edx
  800695:	85 d2                	test   %edx,%edx
  800697:	74 23                	je     8006bc <vprintfmt+0x270>
  800699:	85 f6                	test   %esi,%esi
  80069b:	78 a1                	js     80063e <vprintfmt+0x1f2>
  80069d:	83 ee 01             	sub    $0x1,%esi
  8006a0:	79 9c                	jns    80063e <vprintfmt+0x1f2>
  8006a2:	89 df                	mov    %ebx,%edi
  8006a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006aa:	eb 18                	jmp    8006c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 20                	push   $0x20
  8006b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b4:	83 ef 01             	sub    $0x1,%edi
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 08                	jmp    8006c4 <vprintfmt+0x278>
  8006bc:	89 df                	mov    %ebx,%edi
  8006be:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c4:	85 ff                	test   %edi,%edi
  8006c6:	7f e4                	jg     8006ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cb:	e9 a2 fd ff ff       	jmp    800472 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d0:	83 fa 01             	cmp    $0x1,%edx
  8006d3:	7e 16                	jle    8006eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 08             	lea    0x8(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 50 04             	mov    0x4(%eax),%edx
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e9:	eb 32                	jmp    80071d <vprintfmt+0x2d1>
	else if (lflag)
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	74 18                	je     800707 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fd:	89 c1                	mov    %eax,%ecx
  8006ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800702:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800705:	eb 16                	jmp    80071d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800715:	89 c1                	mov    %eax,%ecx
  800717:	c1 f9 1f             	sar    $0x1f,%ecx
  80071a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800720:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800723:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800728:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072c:	79 74                	jns    8007a2 <vprintfmt+0x356>
				putch('-', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 2d                	push   $0x2d
  800734:	ff d6                	call   *%esi
				num = -(long long) num;
  800736:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800739:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80073c:	f7 d8                	neg    %eax
  80073e:	83 d2 00             	adc    $0x0,%edx
  800741:	f7 da                	neg    %edx
  800743:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800746:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074b:	eb 55                	jmp    8007a2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
  800750:	e8 83 fc ff ff       	call   8003d8 <getuint>
			base = 10;
  800755:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80075a:	eb 46                	jmp    8007a2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
  80075f:	e8 74 fc ff ff       	call   8003d8 <getuint>
			base = 8;
  800764:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800769:	eb 37                	jmp    8007a2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 30                	push   $0x30
  800771:	ff d6                	call   *%esi
			putch('x', putdat);
  800773:	83 c4 08             	add    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 78                	push   $0x78
  800779:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 50 04             	lea    0x4(%eax),%edx
  800781:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800784:	8b 00                	mov    (%eax),%eax
  800786:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800793:	eb 0d                	jmp    8007a2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800795:	8d 45 14             	lea    0x14(%ebp),%eax
  800798:	e8 3b fc ff ff       	call   8003d8 <getuint>
			base = 16;
  80079d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a2:	83 ec 0c             	sub    $0xc,%esp
  8007a5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a9:	57                   	push   %edi
  8007aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ad:	51                   	push   %ecx
  8007ae:	52                   	push   %edx
  8007af:	50                   	push   %eax
  8007b0:	89 da                	mov    %ebx,%edx
  8007b2:	89 f0                	mov    %esi,%eax
  8007b4:	e8 70 fb ff ff       	call   800329 <printnum>
			break;
  8007b9:	83 c4 20             	add    $0x20,%esp
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	e9 ae fc ff ff       	jmp    800472 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	51                   	push   %ecx
  8007c9:	ff d6                	call   *%esi
			break;
  8007cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d1:	e9 9c fc ff ff       	jmp    800472 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 25                	push   $0x25
  8007dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	eb 03                	jmp    8007e6 <vprintfmt+0x39a>
  8007e3:	83 ef 01             	sub    $0x1,%edi
  8007e6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007ea:	75 f7                	jne    8007e3 <vprintfmt+0x397>
  8007ec:	e9 81 fc ff ff       	jmp    800472 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5f                   	pop    %edi
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 18             	sub    $0x18,%esp
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800805:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800808:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800816:	85 c0                	test   %eax,%eax
  800818:	74 26                	je     800840 <vsnprintf+0x47>
  80081a:	85 d2                	test   %edx,%edx
  80081c:	7e 22                	jle    800840 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081e:	ff 75 14             	pushl  0x14(%ebp)
  800821:	ff 75 10             	pushl  0x10(%ebp)
  800824:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800827:	50                   	push   %eax
  800828:	68 12 04 80 00       	push   $0x800412
  80082d:	e8 1a fc ff ff       	call   80044c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800832:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800835:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800838:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	eb 05                	jmp    800845 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800840:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800850:	50                   	push   %eax
  800851:	ff 75 10             	pushl  0x10(%ebp)
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	ff 75 08             	pushl  0x8(%ebp)
  80085a:	e8 9a ff ff ff       	call   8007f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
  80086c:	eb 03                	jmp    800871 <strlen+0x10>
		n++;
  80086e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800871:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800875:	75 f7                	jne    80086e <strlen+0xd>
		n++;
	return n;
}
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	ba 00 00 00 00       	mov    $0x0,%edx
  800887:	eb 03                	jmp    80088c <strnlen+0x13>
		n++;
  800889:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088c:	39 c2                	cmp    %eax,%edx
  80088e:	74 08                	je     800898 <strnlen+0x1f>
  800890:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800894:	75 f3                	jne    800889 <strnlen+0x10>
  800896:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a4:	89 c2                	mov    %eax,%edx
  8008a6:	83 c2 01             	add    $0x1,%edx
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b3:	84 db                	test   %bl,%bl
  8008b5:	75 ef                	jne    8008a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c1:	53                   	push   %ebx
  8008c2:	e8 9a ff ff ff       	call   800861 <strlen>
  8008c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ca:	ff 75 0c             	pushl  0xc(%ebp)
  8008cd:	01 d8                	add    %ebx,%eax
  8008cf:	50                   	push   %eax
  8008d0:	e8 c5 ff ff ff       	call   80089a <strcpy>
	return dst;
}
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e7:	89 f3                	mov    %esi,%ebx
  8008e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ec:	89 f2                	mov    %esi,%edx
  8008ee:	eb 0f                	jmp    8008ff <strncpy+0x23>
		*dst++ = *src;
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	0f b6 01             	movzbl (%ecx),%eax
  8008f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8008fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ff:	39 da                	cmp    %ebx,%edx
  800901:	75 ed                	jne    8008f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800903:	89 f0                	mov    %esi,%eax
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	56                   	push   %esi
  80090d:	53                   	push   %ebx
  80090e:	8b 75 08             	mov    0x8(%ebp),%esi
  800911:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800914:	8b 55 10             	mov    0x10(%ebp),%edx
  800917:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800919:	85 d2                	test   %edx,%edx
  80091b:	74 21                	je     80093e <strlcpy+0x35>
  80091d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800921:	89 f2                	mov    %esi,%edx
  800923:	eb 09                	jmp    80092e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800925:	83 c2 01             	add    $0x1,%edx
  800928:	83 c1 01             	add    $0x1,%ecx
  80092b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092e:	39 c2                	cmp    %eax,%edx
  800930:	74 09                	je     80093b <strlcpy+0x32>
  800932:	0f b6 19             	movzbl (%ecx),%ebx
  800935:	84 db                	test   %bl,%bl
  800937:	75 ec                	jne    800925 <strlcpy+0x1c>
  800939:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80093b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093e:	29 f0                	sub    %esi,%eax
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094d:	eb 06                	jmp    800955 <strcmp+0x11>
		p++, q++;
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800955:	0f b6 01             	movzbl (%ecx),%eax
  800958:	84 c0                	test   %al,%al
  80095a:	74 04                	je     800960 <strcmp+0x1c>
  80095c:	3a 02                	cmp    (%edx),%al
  80095e:	74 ef                	je     80094f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800960:	0f b6 c0             	movzbl %al,%eax
  800963:	0f b6 12             	movzbl (%edx),%edx
  800966:	29 d0                	sub    %edx,%eax
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
  800974:	89 c3                	mov    %eax,%ebx
  800976:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800979:	eb 06                	jmp    800981 <strncmp+0x17>
		n--, p++, q++;
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800981:	39 d8                	cmp    %ebx,%eax
  800983:	74 15                	je     80099a <strncmp+0x30>
  800985:	0f b6 08             	movzbl (%eax),%ecx
  800988:	84 c9                	test   %cl,%cl
  80098a:	74 04                	je     800990 <strncmp+0x26>
  80098c:	3a 0a                	cmp    (%edx),%cl
  80098e:	74 eb                	je     80097b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800990:	0f b6 00             	movzbl (%eax),%eax
  800993:	0f b6 12             	movzbl (%edx),%edx
  800996:	29 d0                	sub    %edx,%eax
  800998:	eb 05                	jmp    80099f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ac:	eb 07                	jmp    8009b5 <strchr+0x13>
		if (*s == c)
  8009ae:	38 ca                	cmp    %cl,%dl
  8009b0:	74 0f                	je     8009c1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	75 f2                	jne    8009ae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cd:	eb 03                	jmp    8009d2 <strfind+0xf>
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d5:	38 ca                	cmp    %cl,%dl
  8009d7:	74 04                	je     8009dd <strfind+0x1a>
  8009d9:	84 d2                	test   %dl,%dl
  8009db:	75 f2                	jne    8009cf <strfind+0xc>
			break;
	return (char *) s;
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009eb:	85 c9                	test   %ecx,%ecx
  8009ed:	74 36                	je     800a25 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f5:	75 28                	jne    800a1f <memset+0x40>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 23                	jne    800a1f <memset+0x40>
		c &= 0xFF;
  8009fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a00:	89 d3                	mov    %edx,%ebx
  800a02:	c1 e3 08             	shl    $0x8,%ebx
  800a05:	89 d6                	mov    %edx,%esi
  800a07:	c1 e6 18             	shl    $0x18,%esi
  800a0a:	89 d0                	mov    %edx,%eax
  800a0c:	c1 e0 10             	shl    $0x10,%eax
  800a0f:	09 f0                	or     %esi,%eax
  800a11:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a13:	89 d8                	mov    %ebx,%eax
  800a15:	09 d0                	or     %edx,%eax
  800a17:	c1 e9 02             	shr    $0x2,%ecx
  800a1a:	fc                   	cld    
  800a1b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1d:	eb 06                	jmp    800a25 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a22:	fc                   	cld    
  800a23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a25:	89 f8                	mov    %edi,%eax
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3a:	39 c6                	cmp    %eax,%esi
  800a3c:	73 35                	jae    800a73 <memmove+0x47>
  800a3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a41:	39 d0                	cmp    %edx,%eax
  800a43:	73 2e                	jae    800a73 <memmove+0x47>
		s += n;
		d += n;
  800a45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a48:	89 d6                	mov    %edx,%esi
  800a4a:	09 fe                	or     %edi,%esi
  800a4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a52:	75 13                	jne    800a67 <memmove+0x3b>
  800a54:	f6 c1 03             	test   $0x3,%cl
  800a57:	75 0e                	jne    800a67 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a59:	83 ef 04             	sub    $0x4,%edi
  800a5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
  800a62:	fd                   	std    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 09                	jmp    800a70 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a67:	83 ef 01             	sub    $0x1,%edi
  800a6a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6d:	fd                   	std    
  800a6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a70:	fc                   	cld    
  800a71:	eb 1d                	jmp    800a90 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a73:	89 f2                	mov    %esi,%edx
  800a75:	09 c2                	or     %eax,%edx
  800a77:	f6 c2 03             	test   $0x3,%dl
  800a7a:	75 0f                	jne    800a8b <memmove+0x5f>
  800a7c:	f6 c1 03             	test   $0x3,%cl
  800a7f:	75 0a                	jne    800a8b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a81:	c1 e9 02             	shr    $0x2,%ecx
  800a84:	89 c7                	mov    %eax,%edi
  800a86:	fc                   	cld    
  800a87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a89:	eb 05                	jmp    800a90 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8b:	89 c7                	mov    %eax,%edi
  800a8d:	fc                   	cld    
  800a8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a97:	ff 75 10             	pushl  0x10(%ebp)
  800a9a:	ff 75 0c             	pushl  0xc(%ebp)
  800a9d:	ff 75 08             	pushl  0x8(%ebp)
  800aa0:	e8 87 ff ff ff       	call   800a2c <memmove>
}
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab2:	89 c6                	mov    %eax,%esi
  800ab4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab7:	eb 1a                	jmp    800ad3 <memcmp+0x2c>
		if (*s1 != *s2)
  800ab9:	0f b6 08             	movzbl (%eax),%ecx
  800abc:	0f b6 1a             	movzbl (%edx),%ebx
  800abf:	38 d9                	cmp    %bl,%cl
  800ac1:	74 0a                	je     800acd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac3:	0f b6 c1             	movzbl %cl,%eax
  800ac6:	0f b6 db             	movzbl %bl,%ebx
  800ac9:	29 d8                	sub    %ebx,%eax
  800acb:	eb 0f                	jmp    800adc <memcmp+0x35>
		s1++, s2++;
  800acd:	83 c0 01             	add    $0x1,%eax
  800ad0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad3:	39 f0                	cmp    %esi,%eax
  800ad5:	75 e2                	jne    800ab9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	53                   	push   %ebx
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae7:	89 c1                	mov    %eax,%ecx
  800ae9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af0:	eb 0a                	jmp    800afc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af2:	0f b6 10             	movzbl (%eax),%edx
  800af5:	39 da                	cmp    %ebx,%edx
  800af7:	74 07                	je     800b00 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af9:	83 c0 01             	add    $0x1,%eax
  800afc:	39 c8                	cmp    %ecx,%eax
  800afe:	72 f2                	jb     800af2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b00:	5b                   	pop    %ebx
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0f:	eb 03                	jmp    800b14 <strtol+0x11>
		s++;
  800b11:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b14:	0f b6 01             	movzbl (%ecx),%eax
  800b17:	3c 20                	cmp    $0x20,%al
  800b19:	74 f6                	je     800b11 <strtol+0xe>
  800b1b:	3c 09                	cmp    $0x9,%al
  800b1d:	74 f2                	je     800b11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1f:	3c 2b                	cmp    $0x2b,%al
  800b21:	75 0a                	jne    800b2d <strtol+0x2a>
		s++;
  800b23:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b26:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2b:	eb 11                	jmp    800b3e <strtol+0x3b>
  800b2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b32:	3c 2d                	cmp    $0x2d,%al
  800b34:	75 08                	jne    800b3e <strtol+0x3b>
		s++, neg = 1;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b44:	75 15                	jne    800b5b <strtol+0x58>
  800b46:	80 39 30             	cmpb   $0x30,(%ecx)
  800b49:	75 10                	jne    800b5b <strtol+0x58>
  800b4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4f:	75 7c                	jne    800bcd <strtol+0xca>
		s += 2, base = 16;
  800b51:	83 c1 02             	add    $0x2,%ecx
  800b54:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b59:	eb 16                	jmp    800b71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b5b:	85 db                	test   %ebx,%ebx
  800b5d:	75 12                	jne    800b71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b64:	80 39 30             	cmpb   $0x30,(%ecx)
  800b67:	75 08                	jne    800b71 <strtol+0x6e>
		s++, base = 8;
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b79:	0f b6 11             	movzbl (%ecx),%edx
  800b7c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 09             	cmp    $0x9,%bl
  800b84:	77 08                	ja     800b8e <strtol+0x8b>
			dig = *s - '0';
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 30             	sub    $0x30,%edx
  800b8c:	eb 22                	jmp    800bb0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b91:	89 f3                	mov    %esi,%ebx
  800b93:	80 fb 19             	cmp    $0x19,%bl
  800b96:	77 08                	ja     800ba0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b98:	0f be d2             	movsbl %dl,%edx
  800b9b:	83 ea 57             	sub    $0x57,%edx
  800b9e:	eb 10                	jmp    800bb0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	80 fb 19             	cmp    $0x19,%bl
  800ba8:	77 16                	ja     800bc0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800baa:	0f be d2             	movsbl %dl,%edx
  800bad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb3:	7d 0b                	jge    800bc0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb5:	83 c1 01             	add    $0x1,%ecx
  800bb8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bbc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bbe:	eb b9                	jmp    800b79 <strtol+0x76>

	if (endptr)
  800bc0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc4:	74 0d                	je     800bd3 <strtol+0xd0>
		*endptr = (char *) s;
  800bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc9:	89 0e                	mov    %ecx,(%esi)
  800bcb:	eb 06                	jmp    800bd3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcd:	85 db                	test   %ebx,%ebx
  800bcf:	74 98                	je     800b69 <strtol+0x66>
  800bd1:	eb 9e                	jmp    800b71 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd3:	89 c2                	mov    %eax,%edx
  800bd5:	f7 da                	neg    %edx
  800bd7:	85 ff                	test   %edi,%edi
  800bd9:	0f 45 c2             	cmovne %edx,%eax
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	89 c3                	mov    %eax,%ebx
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	89 c6                	mov    %eax,%esi
  800bf8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_cgetc>:

int
sys_cgetc(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 cb                	mov    %ecx,%ebx
  800c36:	89 cf                	mov    %ecx,%edi
  800c38:	89 ce                	mov    %ecx,%esi
  800c3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 03                	push   $0x3
  800c46:	68 df 27 80 00       	push   $0x8027df
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 fc 27 80 00       	push   $0x8027fc
  800c52:	e8 e5 f5 ff ff       	call   80023c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6f:	89 d1                	mov    %edx,%ecx
  800c71:	89 d3                	mov    %edx,%ebx
  800c73:	89 d7                	mov    %edx,%edi
  800c75:	89 d6                	mov    %edx,%esi
  800c77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_yield>:

void
sys_yield(void)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	89 d3                	mov    %edx,%ebx
  800c92:	89 d7                	mov    %edx,%edi
  800c94:	89 d6                	mov    %edx,%esi
  800c96:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	be 00 00 00 00       	mov    $0x0,%esi
  800cab:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb9:	89 f7                	mov    %esi,%edi
  800cbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 04                	push   $0x4
  800cc7:	68 df 27 80 00       	push   $0x8027df
  800ccc:	6a 23                	push   $0x23
  800cce:	68 fc 27 80 00       	push   $0x8027fc
  800cd3:	e8 64 f5 ff ff       	call   80023c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfa:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 05                	push   $0x5
  800d09:	68 df 27 80 00       	push   $0x8027df
  800d0e:	6a 23                	push   $0x23
  800d10:	68 fc 27 80 00       	push   $0x8027fc
  800d15:	e8 22 f5 ff ff       	call   80023c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	b8 06 00 00 00       	mov    $0x6,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 06                	push   $0x6
  800d4b:	68 df 27 80 00       	push   $0x8027df
  800d50:	6a 23                	push   $0x23
  800d52:	68 fc 27 80 00       	push   $0x8027fc
  800d57:	e8 e0 f4 ff ff       	call   80023c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 08 00 00 00       	mov    $0x8,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 17                	jle    800d9e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 08                	push   $0x8
  800d8d:	68 df 27 80 00       	push   $0x8027df
  800d92:	6a 23                	push   $0x23
  800d94:	68 fc 27 80 00       	push   $0x8027fc
  800d99:	e8 9e f4 ff ff       	call   80023c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 09 00 00 00       	mov    $0x9,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 17                	jle    800de0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	50                   	push   %eax
  800dcd:	6a 09                	push   $0x9
  800dcf:	68 df 27 80 00       	push   $0x8027df
  800dd4:	6a 23                	push   $0x23
  800dd6:	68 fc 27 80 00       	push   $0x8027fc
  800ddb:	e8 5c f4 ff ff       	call   80023c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0a                	push   $0xa
  800e11:	68 df 27 80 00       	push   $0x8027df
  800e16:	6a 23                	push   $0x23
  800e18:	68 fc 27 80 00       	push   $0x8027fc
  800e1d:	e8 1a f4 ff ff       	call   80023c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	be 00 00 00 00       	mov    $0x0,%esi
  800e35:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e46:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 cb                	mov    %ecx,%ebx
  800e65:	89 cf                	mov    %ecx,%edi
  800e67:	89 ce                	mov    %ecx,%esi
  800e69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 0d                	push   $0xd
  800e75:	68 df 27 80 00       	push   $0x8027df
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 fc 27 80 00       	push   $0x8027fc
  800e81:	e8 b6 f3 ff ff       	call   80023c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e99:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea1:	89 cb                	mov    %ecx,%ebx
  800ea3:	89 cf                	mov    %ecx,%edi
  800ea5:	89 ce                	mov    %ecx,%esi
  800ea7:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	89 cb                	mov    %ecx,%ebx
  800ec3:	89 cf                	mov    %ecx,%edi
  800ec5:	89 ce                	mov    %ecx,%esi
  800ec7:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	53                   	push   %ebx
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ed8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800eda:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ede:	74 11                	je     800ef1 <pgfault+0x23>
  800ee0:	89 d8                	mov    %ebx,%eax
  800ee2:	c1 e8 0c             	shr    $0xc,%eax
  800ee5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eec:	f6 c4 08             	test   $0x8,%ah
  800eef:	75 14                	jne    800f05 <pgfault+0x37>
		panic("faulting access");
  800ef1:	83 ec 04             	sub    $0x4,%esp
  800ef4:	68 0a 28 80 00       	push   $0x80280a
  800ef9:	6a 1e                	push   $0x1e
  800efb:	68 1a 28 80 00       	push   $0x80281a
  800f00:	e8 37 f3 ff ff       	call   80023c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	6a 07                	push   $0x7
  800f0a:	68 00 f0 7f 00       	push   $0x7ff000
  800f0f:	6a 00                	push   $0x0
  800f11:	e8 87 fd ff ff       	call   800c9d <sys_page_alloc>
	if (r < 0) {
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	79 12                	jns    800f2f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f1d:	50                   	push   %eax
  800f1e:	68 25 28 80 00       	push   $0x802825
  800f23:	6a 2c                	push   $0x2c
  800f25:	68 1a 28 80 00       	push   $0x80281a
  800f2a:	e8 0d f3 ff ff       	call   80023c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f2f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	68 00 10 00 00       	push   $0x1000
  800f3d:	53                   	push   %ebx
  800f3e:	68 00 f0 7f 00       	push   $0x7ff000
  800f43:	e8 4c fb ff ff       	call   800a94 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f48:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f4f:	53                   	push   %ebx
  800f50:	6a 00                	push   $0x0
  800f52:	68 00 f0 7f 00       	push   $0x7ff000
  800f57:	6a 00                	push   $0x0
  800f59:	e8 82 fd ff ff       	call   800ce0 <sys_page_map>
	if (r < 0) {
  800f5e:	83 c4 20             	add    $0x20,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 12                	jns    800f77 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f65:	50                   	push   %eax
  800f66:	68 25 28 80 00       	push   $0x802825
  800f6b:	6a 33                	push   $0x33
  800f6d:	68 1a 28 80 00       	push   $0x80281a
  800f72:	e8 c5 f2 ff ff       	call   80023c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f77:	83 ec 08             	sub    $0x8,%esp
  800f7a:	68 00 f0 7f 00       	push   $0x7ff000
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 9c fd ff ff       	call   800d22 <sys_page_unmap>
	if (r < 0) {
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 12                	jns    800f9f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f8d:	50                   	push   %eax
  800f8e:	68 25 28 80 00       	push   $0x802825
  800f93:	6a 37                	push   $0x37
  800f95:	68 1a 28 80 00       	push   $0x80281a
  800f9a:	e8 9d f2 ff ff       	call   80023c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fad:	68 ce 0e 80 00       	push   $0x800ece
  800fb2:	e8 44 0f 00 00       	call   801efb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbc:	cd 30                	int    $0x30
  800fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 17                	jns    800fdf <fork+0x3b>
		panic("fork fault %e");
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	68 3e 28 80 00       	push   $0x80283e
  800fd0:	68 84 00 00 00       	push   $0x84
  800fd5:	68 1a 28 80 00       	push   $0x80281a
  800fda:	e8 5d f2 ff ff       	call   80023c <_panic>
  800fdf:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fe1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fe5:	75 25                	jne    80100c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe7:	e8 73 fc ff ff       	call   800c5f <sys_getenvid>
  800fec:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff1:	89 c2                	mov    %eax,%edx
  800ff3:	c1 e2 07             	shl    $0x7,%edx
  800ff6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800ffd:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  801002:	b8 00 00 00 00       	mov    $0x0,%eax
  801007:	e9 61 01 00 00       	jmp    80116d <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80100c:	83 ec 04             	sub    $0x4,%esp
  80100f:	6a 07                	push   $0x7
  801011:	68 00 f0 bf ee       	push   $0xeebff000
  801016:	ff 75 e4             	pushl  -0x1c(%ebp)
  801019:	e8 7f fc ff ff       	call   800c9d <sys_page_alloc>
  80101e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801021:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801026:	89 d8                	mov    %ebx,%eax
  801028:	c1 e8 16             	shr    $0x16,%eax
  80102b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801032:	a8 01                	test   $0x1,%al
  801034:	0f 84 fc 00 00 00    	je     801136 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	c1 e8 0c             	shr    $0xc,%eax
  80103f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801046:	f6 c2 01             	test   $0x1,%dl
  801049:	0f 84 e7 00 00 00    	je     801136 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80104f:	89 c6                	mov    %eax,%esi
  801051:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801054:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105b:	f6 c6 04             	test   $0x4,%dh
  80105e:	74 39                	je     801099 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801060:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	25 07 0e 00 00       	and    $0xe07,%eax
  80106f:	50                   	push   %eax
  801070:	56                   	push   %esi
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	6a 00                	push   $0x0
  801075:	e8 66 fc ff ff       	call   800ce0 <sys_page_map>
		if (r < 0) {
  80107a:	83 c4 20             	add    $0x20,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	0f 89 b1 00 00 00    	jns    801136 <fork+0x192>
		    	panic("sys page map fault %e");
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	68 4c 28 80 00       	push   $0x80284c
  80108d:	6a 54                	push   $0x54
  80108f:	68 1a 28 80 00       	push   $0x80281a
  801094:	e8 a3 f1 ff ff       	call   80023c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801099:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a0:	f6 c2 02             	test   $0x2,%dl
  8010a3:	75 0c                	jne    8010b1 <fork+0x10d>
  8010a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ac:	f6 c4 08             	test   $0x8,%ah
  8010af:	74 5b                	je     80110c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	68 05 08 00 00       	push   $0x805
  8010b9:	56                   	push   %esi
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 1d fc ff ff       	call   800ce0 <sys_page_map>
		if (r < 0) {
  8010c3:	83 c4 20             	add    $0x20,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 14                	jns    8010de <fork+0x13a>
		    	panic("sys page map fault %e");
  8010ca:	83 ec 04             	sub    $0x4,%esp
  8010cd:	68 4c 28 80 00       	push   $0x80284c
  8010d2:	6a 5b                	push   $0x5b
  8010d4:	68 1a 28 80 00       	push   $0x80281a
  8010d9:	e8 5e f1 ff ff       	call   80023c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	68 05 08 00 00       	push   $0x805
  8010e6:	56                   	push   %esi
  8010e7:	6a 00                	push   $0x0
  8010e9:	56                   	push   %esi
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 ef fb ff ff       	call   800ce0 <sys_page_map>
		if (r < 0) {
  8010f1:	83 c4 20             	add    $0x20,%esp
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	79 3e                	jns    801136 <fork+0x192>
		    	panic("sys page map fault %e");
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	68 4c 28 80 00       	push   $0x80284c
  801100:	6a 5f                	push   $0x5f
  801102:	68 1a 28 80 00       	push   $0x80281a
  801107:	e8 30 f1 ff ff       	call   80023c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	6a 05                	push   $0x5
  801111:	56                   	push   %esi
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	6a 00                	push   $0x0
  801116:	e8 c5 fb ff ff       	call   800ce0 <sys_page_map>
		if (r < 0) {
  80111b:	83 c4 20             	add    $0x20,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	79 14                	jns    801136 <fork+0x192>
		    	panic("sys page map fault %e");
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	68 4c 28 80 00       	push   $0x80284c
  80112a:	6a 64                	push   $0x64
  80112c:	68 1a 28 80 00       	push   $0x80281a
  801131:	e8 06 f1 ff ff       	call   80023c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801136:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80113c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801142:	0f 85 de fe ff ff    	jne    801026 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801148:	a1 20 44 80 00       	mov    0x804420,%eax
  80114d:	8b 40 70             	mov    0x70(%eax),%eax
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	50                   	push   %eax
  801154:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801157:	57                   	push   %edi
  801158:	e8 8b fc ff ff       	call   800de8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80115d:	83 c4 08             	add    $0x8,%esp
  801160:	6a 02                	push   $0x2
  801162:	57                   	push   %edi
  801163:	e8 fc fb ff ff       	call   800d64 <sys_env_set_status>
	
	return envid;
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80116d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <sfork>:

envid_t
sfork(void)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801187:	89 1d 24 44 80 00    	mov    %ebx,0x804424
	cprintf("in fork.c thread create. func: %x\n", func);
  80118d:	83 ec 08             	sub    $0x8,%esp
  801190:	53                   	push   %ebx
  801191:	68 64 28 80 00       	push   $0x802864
  801196:	e8 7a f1 ff ff       	call   800315 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80119b:	c7 04 24 02 02 80 00 	movl   $0x800202,(%esp)
  8011a2:	e8 e7 fc ff ff       	call   800e8e <sys_thread_create>
  8011a7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011a9:	83 c4 08             	add    $0x8,%esp
  8011ac:	53                   	push   %ebx
  8011ad:	68 64 28 80 00       	push   $0x802864
  8011b2:	e8 5e f1 ff ff       	call   800315 <cprintf>
	return id;
	//return 0;
}
  8011b7:	89 f0                	mov    %esi,%eax
  8011b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	c1 ea 16             	shr    $0x16,%edx
  8011f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fe:	f6 c2 01             	test   $0x1,%dl
  801201:	74 11                	je     801214 <fd_alloc+0x2d>
  801203:	89 c2                	mov    %eax,%edx
  801205:	c1 ea 0c             	shr    $0xc,%edx
  801208:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120f:	f6 c2 01             	test   $0x1,%dl
  801212:	75 09                	jne    80121d <fd_alloc+0x36>
			*fd_store = fd;
  801214:	89 01                	mov    %eax,(%ecx)
			return 0;
  801216:	b8 00 00 00 00       	mov    $0x0,%eax
  80121b:	eb 17                	jmp    801234 <fd_alloc+0x4d>
  80121d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801222:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801227:	75 c9                	jne    8011f2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801229:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123c:	83 f8 1f             	cmp    $0x1f,%eax
  80123f:	77 36                	ja     801277 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801241:	c1 e0 0c             	shl    $0xc,%eax
  801244:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801249:	89 c2                	mov    %eax,%edx
  80124b:	c1 ea 16             	shr    $0x16,%edx
  80124e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801255:	f6 c2 01             	test   $0x1,%dl
  801258:	74 24                	je     80127e <fd_lookup+0x48>
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 0c             	shr    $0xc,%edx
  80125f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	74 1a                	je     801285 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126e:	89 02                	mov    %eax,(%edx)
	return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	eb 13                	jmp    80128a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127c:	eb 0c                	jmp    80128a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb 05                	jmp    80128a <fd_lookup+0x54>
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801295:	ba 08 29 80 00       	mov    $0x802908,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80129a:	eb 13                	jmp    8012af <dev_lookup+0x23>
  80129c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129f:	39 08                	cmp    %ecx,(%eax)
  8012a1:	75 0c                	jne    8012af <dev_lookup+0x23>
			*dev = devtab[i];
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	eb 2e                	jmp    8012dd <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012af:	8b 02                	mov    (%edx),%eax
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	75 e7                	jne    80129c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b5:	a1 20 44 80 00       	mov    0x804420,%eax
  8012ba:	8b 40 54             	mov    0x54(%eax),%eax
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	51                   	push   %ecx
  8012c1:	50                   	push   %eax
  8012c2:	68 88 28 80 00       	push   $0x802888
  8012c7:	e8 49 f0 ff ff       	call   800315 <cprintf>
	*dev = 0;
  8012cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	56                   	push   %esi
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 10             	sub    $0x10,%esp
  8012e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f7:	c1 e8 0c             	shr    $0xc,%eax
  8012fa:	50                   	push   %eax
  8012fb:	e8 36 ff ff ff       	call   801236 <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 05                	js     80130c <fd_close+0x2d>
	    || fd != fd2)
  801307:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80130a:	74 0c                	je     801318 <fd_close+0x39>
		return (must_exist ? r : 0);
  80130c:	84 db                	test   %bl,%bl
  80130e:	ba 00 00 00 00       	mov    $0x0,%edx
  801313:	0f 44 c2             	cmove  %edx,%eax
  801316:	eb 41                	jmp    801359 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	ff 36                	pushl  (%esi)
  801321:	e8 66 ff ff ff       	call   80128c <dev_lookup>
  801326:	89 c3                	mov    %eax,%ebx
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 1a                	js     801349 <fd_close+0x6a>
		if (dev->dev_close)
  80132f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801332:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801335:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80133a:	85 c0                	test   %eax,%eax
  80133c:	74 0b                	je     801349 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80133e:	83 ec 0c             	sub    $0xc,%esp
  801341:	56                   	push   %esi
  801342:	ff d0                	call   *%eax
  801344:	89 c3                	mov    %eax,%ebx
  801346:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	56                   	push   %esi
  80134d:	6a 00                	push   $0x0
  80134f:	e8 ce f9 ff ff       	call   800d22 <sys_page_unmap>
	return r;
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	89 d8                	mov    %ebx,%eax
}
  801359:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135c:	5b                   	pop    %ebx
  80135d:	5e                   	pop    %esi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801366:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801369:	50                   	push   %eax
  80136a:	ff 75 08             	pushl  0x8(%ebp)
  80136d:	e8 c4 fe ff ff       	call   801236 <fd_lookup>
  801372:	83 c4 08             	add    $0x8,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	78 10                	js     801389 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	6a 01                	push   $0x1
  80137e:	ff 75 f4             	pushl  -0xc(%ebp)
  801381:	e8 59 ff ff ff       	call   8012df <fd_close>
  801386:	83 c4 10             	add    $0x10,%esp
}
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <close_all>:

void
close_all(void)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	53                   	push   %ebx
  80138f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801392:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	53                   	push   %ebx
  80139b:	e8 c0 ff ff ff       	call   801360 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a0:	83 c3 01             	add    $0x1,%ebx
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	83 fb 20             	cmp    $0x20,%ebx
  8013a9:	75 ec                	jne    801397 <close_all+0xc>
		close(i);
}
  8013ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ae:	c9                   	leave  
  8013af:	c3                   	ret    

008013b0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	57                   	push   %edi
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 2c             	sub    $0x2c,%esp
  8013b9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 75 08             	pushl  0x8(%ebp)
  8013c3:	e8 6e fe ff ff       	call   801236 <fd_lookup>
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	0f 88 c1 00 00 00    	js     801494 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	56                   	push   %esi
  8013d7:	e8 84 ff ff ff       	call   801360 <close>

	newfd = INDEX2FD(newfdnum);
  8013dc:	89 f3                	mov    %esi,%ebx
  8013de:	c1 e3 0c             	shl    $0xc,%ebx
  8013e1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e7:	83 c4 04             	add    $0x4,%esp
  8013ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ed:	e8 de fd ff ff       	call   8011d0 <fd2data>
  8013f2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 d4 fd ff ff       	call   8011d0 <fd2data>
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801402:	89 f8                	mov    %edi,%eax
  801404:	c1 e8 16             	shr    $0x16,%eax
  801407:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140e:	a8 01                	test   $0x1,%al
  801410:	74 37                	je     801449 <dup+0x99>
  801412:	89 f8                	mov    %edi,%eax
  801414:	c1 e8 0c             	shr    $0xc,%eax
  801417:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141e:	f6 c2 01             	test   $0x1,%dl
  801421:	74 26                	je     801449 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801423:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	25 07 0e 00 00       	and    $0xe07,%eax
  801432:	50                   	push   %eax
  801433:	ff 75 d4             	pushl  -0x2c(%ebp)
  801436:	6a 00                	push   $0x0
  801438:	57                   	push   %edi
  801439:	6a 00                	push   $0x0
  80143b:	e8 a0 f8 ff ff       	call   800ce0 <sys_page_map>
  801440:	89 c7                	mov    %eax,%edi
  801442:	83 c4 20             	add    $0x20,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 2e                	js     801477 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801449:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144c:	89 d0                	mov    %edx,%eax
  80144e:	c1 e8 0c             	shr    $0xc,%eax
  801451:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801458:	83 ec 0c             	sub    $0xc,%esp
  80145b:	25 07 0e 00 00       	and    $0xe07,%eax
  801460:	50                   	push   %eax
  801461:	53                   	push   %ebx
  801462:	6a 00                	push   $0x0
  801464:	52                   	push   %edx
  801465:	6a 00                	push   $0x0
  801467:	e8 74 f8 ff ff       	call   800ce0 <sys_page_map>
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801471:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801473:	85 ff                	test   %edi,%edi
  801475:	79 1d                	jns    801494 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	53                   	push   %ebx
  80147b:	6a 00                	push   $0x0
  80147d:	e8 a0 f8 ff ff       	call   800d22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	ff 75 d4             	pushl  -0x2c(%ebp)
  801488:	6a 00                	push   $0x0
  80148a:	e8 93 f8 ff ff       	call   800d22 <sys_page_unmap>
	return r;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	89 f8                	mov    %edi,%eax
}
  801494:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5f                   	pop    %edi
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 14             	sub    $0x14,%esp
  8014a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	53                   	push   %ebx
  8014ab:	e8 86 fd ff ff       	call   801236 <fd_lookup>
  8014b0:	83 c4 08             	add    $0x8,%esp
  8014b3:	89 c2                	mov    %eax,%edx
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 6d                	js     801526 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c3:	ff 30                	pushl  (%eax)
  8014c5:	e8 c2 fd ff ff       	call   80128c <dev_lookup>
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 4c                	js     80151d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d4:	8b 42 08             	mov    0x8(%edx),%eax
  8014d7:	83 e0 03             	and    $0x3,%eax
  8014da:	83 f8 01             	cmp    $0x1,%eax
  8014dd:	75 21                	jne    801500 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014df:	a1 20 44 80 00       	mov    0x804420,%eax
  8014e4:	8b 40 54             	mov    0x54(%eax),%eax
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	53                   	push   %ebx
  8014eb:	50                   	push   %eax
  8014ec:	68 cc 28 80 00       	push   $0x8028cc
  8014f1:	e8 1f ee ff ff       	call   800315 <cprintf>
		return -E_INVAL;
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fe:	eb 26                	jmp    801526 <read+0x8a>
	}
	if (!dev->dev_read)
  801500:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801503:	8b 40 08             	mov    0x8(%eax),%eax
  801506:	85 c0                	test   %eax,%eax
  801508:	74 17                	je     801521 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	ff 75 10             	pushl  0x10(%ebp)
  801510:	ff 75 0c             	pushl  0xc(%ebp)
  801513:	52                   	push   %edx
  801514:	ff d0                	call   *%eax
  801516:	89 c2                	mov    %eax,%edx
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	eb 09                	jmp    801526 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	eb 05                	jmp    801526 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801521:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801526:	89 d0                	mov    %edx,%eax
  801528:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	57                   	push   %edi
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	8b 7d 08             	mov    0x8(%ebp),%edi
  801539:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801541:	eb 21                	jmp    801564 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801543:	83 ec 04             	sub    $0x4,%esp
  801546:	89 f0                	mov    %esi,%eax
  801548:	29 d8                	sub    %ebx,%eax
  80154a:	50                   	push   %eax
  80154b:	89 d8                	mov    %ebx,%eax
  80154d:	03 45 0c             	add    0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	57                   	push   %edi
  801552:	e8 45 ff ff ff       	call   80149c <read>
		if (m < 0)
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 10                	js     80156e <readn+0x41>
			return m;
		if (m == 0)
  80155e:	85 c0                	test   %eax,%eax
  801560:	74 0a                	je     80156c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801562:	01 c3                	add    %eax,%ebx
  801564:	39 f3                	cmp    %esi,%ebx
  801566:	72 db                	jb     801543 <readn+0x16>
  801568:	89 d8                	mov    %ebx,%eax
  80156a:	eb 02                	jmp    80156e <readn+0x41>
  80156c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80156e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5f                   	pop    %edi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 14             	sub    $0x14,%esp
  80157d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801580:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	53                   	push   %ebx
  801585:	e8 ac fc ff ff       	call   801236 <fd_lookup>
  80158a:	83 c4 08             	add    $0x8,%esp
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 68                	js     8015fb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159d:	ff 30                	pushl  (%eax)
  80159f:	e8 e8 fc ff ff       	call   80128c <dev_lookup>
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 47                	js     8015f2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b2:	75 21                	jne    8015d5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b4:	a1 20 44 80 00       	mov    0x804420,%eax
  8015b9:	8b 40 54             	mov    0x54(%eax),%eax
  8015bc:	83 ec 04             	sub    $0x4,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	50                   	push   %eax
  8015c1:	68 e8 28 80 00       	push   $0x8028e8
  8015c6:	e8 4a ed ff ff       	call   800315 <cprintf>
		return -E_INVAL;
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d3:	eb 26                	jmp    8015fb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015db:	85 d2                	test   %edx,%edx
  8015dd:	74 17                	je     8015f6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015df:	83 ec 04             	sub    $0x4,%esp
  8015e2:	ff 75 10             	pushl  0x10(%ebp)
  8015e5:	ff 75 0c             	pushl  0xc(%ebp)
  8015e8:	50                   	push   %eax
  8015e9:	ff d2                	call   *%edx
  8015eb:	89 c2                	mov    %eax,%edx
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	eb 09                	jmp    8015fb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	eb 05                	jmp    8015fb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015fb:	89 d0                	mov    %edx,%eax
  8015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <seek>:

int
seek(int fdnum, off_t offset)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801608:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	ff 75 08             	pushl  0x8(%ebp)
  80160f:	e8 22 fc ff ff       	call   801236 <fd_lookup>
  801614:	83 c4 08             	add    $0x8,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 0e                	js     801629 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80161b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801621:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 14             	sub    $0x14,%esp
  801632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	53                   	push   %ebx
  80163a:	e8 f7 fb ff ff       	call   801236 <fd_lookup>
  80163f:	83 c4 08             	add    $0x8,%esp
  801642:	89 c2                	mov    %eax,%edx
  801644:	85 c0                	test   %eax,%eax
  801646:	78 65                	js     8016ad <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	ff 30                	pushl  (%eax)
  801654:	e8 33 fc ff ff       	call   80128c <dev_lookup>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 44                	js     8016a4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801667:	75 21                	jne    80168a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801669:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80166e:	8b 40 54             	mov    0x54(%eax),%eax
  801671:	83 ec 04             	sub    $0x4,%esp
  801674:	53                   	push   %ebx
  801675:	50                   	push   %eax
  801676:	68 a8 28 80 00       	push   $0x8028a8
  80167b:	e8 95 ec ff ff       	call   800315 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801688:	eb 23                	jmp    8016ad <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168d:	8b 52 18             	mov    0x18(%edx),%edx
  801690:	85 d2                	test   %edx,%edx
  801692:	74 14                	je     8016a8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	ff 75 0c             	pushl  0xc(%ebp)
  80169a:	50                   	push   %eax
  80169b:	ff d2                	call   *%edx
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	eb 09                	jmp    8016ad <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	89 c2                	mov    %eax,%edx
  8016a6:	eb 05                	jmp    8016ad <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ad:	89 d0                	mov    %edx,%eax
  8016af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 14             	sub    $0x14,%esp
  8016bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	ff 75 08             	pushl  0x8(%ebp)
  8016c5:	e8 6c fb ff ff       	call   801236 <fd_lookup>
  8016ca:	83 c4 08             	add    $0x8,%esp
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 58                	js     80172b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	ff 30                	pushl  (%eax)
  8016df:	e8 a8 fb ff ff       	call   80128c <dev_lookup>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 37                	js     801722 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f2:	74 32                	je     801726 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fe:	00 00 00 
	stat->st_isdir = 0;
  801701:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801708:	00 00 00 
	stat->st_dev = dev;
  80170b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	53                   	push   %ebx
  801715:	ff 75 f0             	pushl  -0x10(%ebp)
  801718:	ff 50 14             	call   *0x14(%eax)
  80171b:	89 c2                	mov    %eax,%edx
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	eb 09                	jmp    80172b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801722:	89 c2                	mov    %eax,%edx
  801724:	eb 05                	jmp    80172b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801726:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80172b:	89 d0                	mov    %edx,%eax
  80172d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	6a 00                	push   $0x0
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	e8 e3 01 00 00       	call   801927 <open>
  801744:	89 c3                	mov    %eax,%ebx
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 1b                	js     801768 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80174d:	83 ec 08             	sub    $0x8,%esp
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	50                   	push   %eax
  801754:	e8 5b ff ff ff       	call   8016b4 <fstat>
  801759:	89 c6                	mov    %eax,%esi
	close(fd);
  80175b:	89 1c 24             	mov    %ebx,(%esp)
  80175e:	e8 fd fb ff ff       	call   801360 <close>
	return r;
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	89 f0                	mov    %esi,%eax
}
  801768:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
  801774:	89 c6                	mov    %eax,%esi
  801776:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801778:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177f:	75 12                	jne    801793 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801781:	83 ec 0c             	sub    $0xc,%esp
  801784:	6a 01                	push   $0x1
  801786:	e8 d9 08 00 00       	call   802064 <ipc_find_env>
  80178b:	a3 00 40 80 00       	mov    %eax,0x804000
  801790:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801793:	6a 07                	push   $0x7
  801795:	68 00 50 80 00       	push   $0x805000
  80179a:	56                   	push   %esi
  80179b:	ff 35 00 40 80 00    	pushl  0x804000
  8017a1:	e8 5c 08 00 00       	call   802002 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a6:	83 c4 0c             	add    $0xc,%esp
  8017a9:	6a 00                	push   $0x0
  8017ab:	53                   	push   %ebx
  8017ac:	6a 00                	push   $0x0
  8017ae:	e8 d7 07 00 00       	call   801f8a <ipc_recv>
}
  8017b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b6:	5b                   	pop    %ebx
  8017b7:	5e                   	pop    %esi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ce:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017dd:	e8 8d ff ff ff       	call   80176f <fsipc>
}
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ff:	e8 6b ff ff ff       	call   80176f <fsipc>
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	53                   	push   %ebx
  80180a:	83 ec 04             	sub    $0x4,%esp
  80180d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	8b 40 0c             	mov    0xc(%eax),%eax
  801816:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80181b:	ba 00 00 00 00       	mov    $0x0,%edx
  801820:	b8 05 00 00 00       	mov    $0x5,%eax
  801825:	e8 45 ff ff ff       	call   80176f <fsipc>
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 2c                	js     80185a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	68 00 50 80 00       	push   $0x805000
  801836:	53                   	push   %ebx
  801837:	e8 5e f0 ff ff       	call   80089a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183c:	a1 80 50 80 00       	mov    0x805080,%eax
  801841:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801847:	a1 84 50 80 00       	mov    0x805084,%eax
  80184c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801868:	8b 55 08             	mov    0x8(%ebp),%edx
  80186b:	8b 52 0c             	mov    0xc(%edx),%edx
  80186e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801874:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801879:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80187e:	0f 47 c2             	cmova  %edx,%eax
  801881:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801886:	50                   	push   %eax
  801887:	ff 75 0c             	pushl  0xc(%ebp)
  80188a:	68 08 50 80 00       	push   $0x805008
  80188f:	e8 98 f1 ff ff       	call   800a2c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 04 00 00 00       	mov    $0x4,%eax
  80189e:	e8 cc fe ff ff       	call   80176f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c8:	e8 a2 fe ff ff       	call   80176f <fsipc>
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 4b                	js     80191e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d3:	39 c6                	cmp    %eax,%esi
  8018d5:	73 16                	jae    8018ed <devfile_read+0x48>
  8018d7:	68 18 29 80 00       	push   $0x802918
  8018dc:	68 1f 29 80 00       	push   $0x80291f
  8018e1:	6a 7c                	push   $0x7c
  8018e3:	68 34 29 80 00       	push   $0x802934
  8018e8:	e8 4f e9 ff ff       	call   80023c <_panic>
	assert(r <= PGSIZE);
  8018ed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f2:	7e 16                	jle    80190a <devfile_read+0x65>
  8018f4:	68 3f 29 80 00       	push   $0x80293f
  8018f9:	68 1f 29 80 00       	push   $0x80291f
  8018fe:	6a 7d                	push   $0x7d
  801900:	68 34 29 80 00       	push   $0x802934
  801905:	e8 32 e9 ff ff       	call   80023c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190a:	83 ec 04             	sub    $0x4,%esp
  80190d:	50                   	push   %eax
  80190e:	68 00 50 80 00       	push   $0x805000
  801913:	ff 75 0c             	pushl  0xc(%ebp)
  801916:	e8 11 f1 ff ff       	call   800a2c <memmove>
	return r;
  80191b:	83 c4 10             	add    $0x10,%esp
}
  80191e:	89 d8                	mov    %ebx,%eax
  801920:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801923:	5b                   	pop    %ebx
  801924:	5e                   	pop    %esi
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	53                   	push   %ebx
  80192b:	83 ec 20             	sub    $0x20,%esp
  80192e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801931:	53                   	push   %ebx
  801932:	e8 2a ef ff ff       	call   800861 <strlen>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193f:	7f 67                	jg     8019a8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	e8 9a f8 ff ff       	call   8011e7 <fd_alloc>
  80194d:	83 c4 10             	add    $0x10,%esp
		return r;
  801950:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801952:	85 c0                	test   %eax,%eax
  801954:	78 57                	js     8019ad <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801956:	83 ec 08             	sub    $0x8,%esp
  801959:	53                   	push   %ebx
  80195a:	68 00 50 80 00       	push   $0x805000
  80195f:	e8 36 ef ff ff       	call   80089a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801964:	8b 45 0c             	mov    0xc(%ebp),%eax
  801967:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196f:	b8 01 00 00 00       	mov    $0x1,%eax
  801974:	e8 f6 fd ff ff       	call   80176f <fsipc>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	85 c0                	test   %eax,%eax
  801980:	79 14                	jns    801996 <open+0x6f>
		fd_close(fd, 0);
  801982:	83 ec 08             	sub    $0x8,%esp
  801985:	6a 00                	push   $0x0
  801987:	ff 75 f4             	pushl  -0xc(%ebp)
  80198a:	e8 50 f9 ff ff       	call   8012df <fd_close>
		return r;
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	89 da                	mov    %ebx,%edx
  801994:	eb 17                	jmp    8019ad <open+0x86>
	}

	return fd2num(fd);
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	ff 75 f4             	pushl  -0xc(%ebp)
  80199c:	e8 1f f8 ff ff       	call   8011c0 <fd2num>
  8019a1:	89 c2                	mov    %eax,%edx
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	eb 05                	jmp    8019ad <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ad:	89 d0                	mov    %edx,%eax
  8019af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c4:	e8 a6 fd ff ff       	call   80176f <fsipc>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	ff 75 08             	pushl  0x8(%ebp)
  8019d9:	e8 f2 f7 ff ff       	call   8011d0 <fd2data>
  8019de:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e0:	83 c4 08             	add    $0x8,%esp
  8019e3:	68 4b 29 80 00       	push   $0x80294b
  8019e8:	53                   	push   %ebx
  8019e9:	e8 ac ee ff ff       	call   80089a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ee:	8b 46 04             	mov    0x4(%esi),%eax
  8019f1:	2b 06                	sub    (%esi),%eax
  8019f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a00:	00 00 00 
	stat->st_dev = &devpipe;
  801a03:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a0a:	30 80 00 
	return 0;
}
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a23:	53                   	push   %ebx
  801a24:	6a 00                	push   $0x0
  801a26:	e8 f7 f2 ff ff       	call   800d22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2b:	89 1c 24             	mov    %ebx,(%esp)
  801a2e:	e8 9d f7 ff ff       	call   8011d0 <fd2data>
  801a33:	83 c4 08             	add    $0x8,%esp
  801a36:	50                   	push   %eax
  801a37:	6a 00                	push   $0x0
  801a39:	e8 e4 f2 ff ff       	call   800d22 <sys_page_unmap>
}
  801a3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	57                   	push   %edi
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	83 ec 1c             	sub    $0x1c,%esp
  801a4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a4f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a51:	a1 20 44 80 00       	mov    0x804420,%eax
  801a56:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5f:	e8 40 06 00 00       	call   8020a4 <pageref>
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	89 3c 24             	mov    %edi,(%esp)
  801a69:	e8 36 06 00 00       	call   8020a4 <pageref>
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	39 c3                	cmp    %eax,%ebx
  801a73:	0f 94 c1             	sete   %cl
  801a76:	0f b6 c9             	movzbl %cl,%ecx
  801a79:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a7c:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a82:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801a85:	39 ce                	cmp    %ecx,%esi
  801a87:	74 1b                	je     801aa4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a89:	39 c3                	cmp    %eax,%ebx
  801a8b:	75 c4                	jne    801a51 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a8d:	8b 42 64             	mov    0x64(%edx),%eax
  801a90:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a93:	50                   	push   %eax
  801a94:	56                   	push   %esi
  801a95:	68 52 29 80 00       	push   $0x802952
  801a9a:	e8 76 e8 ff ff       	call   800315 <cprintf>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	eb ad                	jmp    801a51 <_pipeisclosed+0xe>
	}
}
  801aa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5f                   	pop    %edi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	57                   	push   %edi
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 28             	sub    $0x28,%esp
  801ab8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801abb:	56                   	push   %esi
  801abc:	e8 0f f7 ff ff       	call   8011d0 <fd2data>
  801ac1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	bf 00 00 00 00       	mov    $0x0,%edi
  801acb:	eb 4b                	jmp    801b18 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801acd:	89 da                	mov    %ebx,%edx
  801acf:	89 f0                	mov    %esi,%eax
  801ad1:	e8 6d ff ff ff       	call   801a43 <_pipeisclosed>
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	75 48                	jne    801b22 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ada:	e8 9f f1 ff ff       	call   800c7e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801adf:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae2:	8b 0b                	mov    (%ebx),%ecx
  801ae4:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae7:	39 d0                	cmp    %edx,%eax
  801ae9:	73 e2                	jae    801acd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aee:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	c1 fa 1f             	sar    $0x1f,%edx
  801afa:	89 d1                	mov    %edx,%ecx
  801afc:	c1 e9 1b             	shr    $0x1b,%ecx
  801aff:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b02:	83 e2 1f             	and    $0x1f,%edx
  801b05:	29 ca                	sub    %ecx,%edx
  801b07:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b0b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b15:	83 c7 01             	add    $0x1,%edi
  801b18:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b1b:	75 c2                	jne    801adf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b1d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b20:	eb 05                	jmp    801b27 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5f                   	pop    %edi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	57                   	push   %edi
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	83 ec 18             	sub    $0x18,%esp
  801b38:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b3b:	57                   	push   %edi
  801b3c:	e8 8f f6 ff ff       	call   8011d0 <fd2data>
  801b41:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b4b:	eb 3d                	jmp    801b8a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b4d:	85 db                	test   %ebx,%ebx
  801b4f:	74 04                	je     801b55 <devpipe_read+0x26>
				return i;
  801b51:	89 d8                	mov    %ebx,%eax
  801b53:	eb 44                	jmp    801b99 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b55:	89 f2                	mov    %esi,%edx
  801b57:	89 f8                	mov    %edi,%eax
  801b59:	e8 e5 fe ff ff       	call   801a43 <_pipeisclosed>
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	75 32                	jne    801b94 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b62:	e8 17 f1 ff ff       	call   800c7e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b67:	8b 06                	mov    (%esi),%eax
  801b69:	3b 46 04             	cmp    0x4(%esi),%eax
  801b6c:	74 df                	je     801b4d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6e:	99                   	cltd   
  801b6f:	c1 ea 1b             	shr    $0x1b,%edx
  801b72:	01 d0                	add    %edx,%eax
  801b74:	83 e0 1f             	and    $0x1f,%eax
  801b77:	29 d0                	sub    %edx,%eax
  801b79:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b81:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b84:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b87:	83 c3 01             	add    $0x1,%ebx
  801b8a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b8d:	75 d8                	jne    801b67 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b92:	eb 05                	jmp    801b99 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bac:	50                   	push   %eax
  801bad:	e8 35 f6 ff ff       	call   8011e7 <fd_alloc>
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	89 c2                	mov    %eax,%edx
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 2c 01 00 00    	js     801ceb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbf:	83 ec 04             	sub    $0x4,%esp
  801bc2:	68 07 04 00 00       	push   $0x407
  801bc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bca:	6a 00                	push   $0x0
  801bcc:	e8 cc f0 ff ff       	call   800c9d <sys_page_alloc>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	0f 88 0d 01 00 00    	js     801ceb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be4:	50                   	push   %eax
  801be5:	e8 fd f5 ff ff       	call   8011e7 <fd_alloc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 88 e2 00 00 00    	js     801cd9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf7:	83 ec 04             	sub    $0x4,%esp
  801bfa:	68 07 04 00 00       	push   $0x407
  801bff:	ff 75 f0             	pushl  -0x10(%ebp)
  801c02:	6a 00                	push   $0x0
  801c04:	e8 94 f0 ff ff       	call   800c9d <sys_page_alloc>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	0f 88 c3 00 00 00    	js     801cd9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c16:	83 ec 0c             	sub    $0xc,%esp
  801c19:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1c:	e8 af f5 ff ff       	call   8011d0 <fd2data>
  801c21:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c23:	83 c4 0c             	add    $0xc,%esp
  801c26:	68 07 04 00 00       	push   $0x407
  801c2b:	50                   	push   %eax
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 6a f0 ff ff       	call   800c9d <sys_page_alloc>
  801c33:	89 c3                	mov    %eax,%ebx
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	0f 88 89 00 00 00    	js     801cc9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	ff 75 f0             	pushl  -0x10(%ebp)
  801c46:	e8 85 f5 ff ff       	call   8011d0 <fd2data>
  801c4b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c52:	50                   	push   %eax
  801c53:	6a 00                	push   $0x0
  801c55:	56                   	push   %esi
  801c56:	6a 00                	push   $0x0
  801c58:	e8 83 f0 ff ff       	call   800ce0 <sys_page_map>
  801c5d:	89 c3                	mov    %eax,%ebx
  801c5f:	83 c4 20             	add    $0x20,%esp
  801c62:	85 c0                	test   %eax,%eax
  801c64:	78 55                	js     801cbb <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c66:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c74:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c7b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c84:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c89:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c90:	83 ec 0c             	sub    $0xc,%esp
  801c93:	ff 75 f4             	pushl  -0xc(%ebp)
  801c96:	e8 25 f5 ff ff       	call   8011c0 <fd2num>
  801c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca0:	83 c4 04             	add    $0x4,%esp
  801ca3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca6:	e8 15 f5 ff ff       	call   8011c0 <fd2num>
  801cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cae:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb9:	eb 30                	jmp    801ceb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	56                   	push   %esi
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 5c f0 ff ff       	call   800d22 <sys_page_unmap>
  801cc6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc9:	83 ec 08             	sub    $0x8,%esp
  801ccc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 4c f0 ff ff       	call   800d22 <sys_page_unmap>
  801cd6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd9:	83 ec 08             	sub    $0x8,%esp
  801cdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdf:	6a 00                	push   $0x0
  801ce1:	e8 3c f0 ff ff       	call   800d22 <sys_page_unmap>
  801ce6:	83 c4 10             	add    $0x10,%esp
  801ce9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	ff 75 08             	pushl  0x8(%ebp)
  801d01:	e8 30 f5 ff ff       	call   801236 <fd_lookup>
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 18                	js     801d25 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d0d:	83 ec 0c             	sub    $0xc,%esp
  801d10:	ff 75 f4             	pushl  -0xc(%ebp)
  801d13:	e8 b8 f4 ff ff       	call   8011d0 <fd2data>
	return _pipeisclosed(fd, p);
  801d18:	89 c2                	mov    %eax,%edx
  801d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1d:	e8 21 fd ff ff       	call   801a43 <_pipeisclosed>
  801d22:	83 c4 10             	add    $0x10,%esp
}
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	56                   	push   %esi
  801d2b:	53                   	push   %ebx
  801d2c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d2f:	85 f6                	test   %esi,%esi
  801d31:	75 16                	jne    801d49 <wait+0x22>
  801d33:	68 6a 29 80 00       	push   $0x80296a
  801d38:	68 1f 29 80 00       	push   $0x80291f
  801d3d:	6a 09                	push   $0x9
  801d3f:	68 75 29 80 00       	push   $0x802975
  801d44:	e8 f3 e4 ff ff       	call   80023c <_panic>
	e = &envs[ENVX(envid)];
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d50:	89 c2                	mov    %eax,%edx
  801d52:	c1 e2 07             	shl    $0x7,%edx
  801d55:	8d 9c c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%ebx
  801d5c:	eb 05                	jmp    801d63 <wait+0x3c>
		sys_yield();
  801d5e:	e8 1b ef ff ff       	call   800c7e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d63:	8b 43 54             	mov    0x54(%ebx),%eax
  801d66:	39 c6                	cmp    %eax,%esi
  801d68:	75 07                	jne    801d71 <wait+0x4a>
  801d6a:	8b 43 60             	mov    0x60(%ebx),%eax
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	75 ed                	jne    801d5e <wait+0x37>
		sys_yield();
}
  801d71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    

00801d82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d88:	68 80 29 80 00       	push   $0x802980
  801d8d:	ff 75 0c             	pushl  0xc(%ebp)
  801d90:	e8 05 eb ff ff       	call   80089a <strcpy>
	return 0;
}
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	57                   	push   %edi
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db3:	eb 2d                	jmp    801de2 <devcons_write+0x46>
		m = n - tot;
  801db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dbd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dc2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc5:	83 ec 04             	sub    $0x4,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	03 45 0c             	add    0xc(%ebp),%eax
  801dcc:	50                   	push   %eax
  801dcd:	57                   	push   %edi
  801dce:	e8 59 ec ff ff       	call   800a2c <memmove>
		sys_cputs(buf, m);
  801dd3:	83 c4 08             	add    $0x8,%esp
  801dd6:	53                   	push   %ebx
  801dd7:	57                   	push   %edi
  801dd8:	e8 04 ee ff ff       	call   800be1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ddd:	01 de                	add    %ebx,%esi
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	89 f0                	mov    %esi,%eax
  801de4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de7:	72 cc                	jb     801db5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e00:	74 2a                	je     801e2c <devcons_read+0x3b>
  801e02:	eb 05                	jmp    801e09 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e04:	e8 75 ee ff ff       	call   800c7e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e09:	e8 f1 ed ff ff       	call   800bff <sys_cgetc>
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	74 f2                	je     801e04 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 16                	js     801e2c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e16:	83 f8 04             	cmp    $0x4,%eax
  801e19:	74 0c                	je     801e27 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1e:	88 02                	mov    %al,(%edx)
	return 1;
  801e20:	b8 01 00 00 00       	mov    $0x1,%eax
  801e25:	eb 05                	jmp    801e2c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e3a:	6a 01                	push   $0x1
  801e3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3f:	50                   	push   %eax
  801e40:	e8 9c ed ff ff       	call   800be1 <sys_cputs>
}
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <getchar>:

int
getchar(void)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e50:	6a 01                	push   $0x1
  801e52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	6a 00                	push   $0x0
  801e58:	e8 3f f6 ff ff       	call   80149c <read>
	if (r < 0)
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 0f                	js     801e73 <getchar+0x29>
		return r;
	if (r < 1)
  801e64:	85 c0                	test   %eax,%eax
  801e66:	7e 06                	jle    801e6e <getchar+0x24>
		return -E_EOF;
	return c;
  801e68:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e6c:	eb 05                	jmp    801e73 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e6e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    

00801e75 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7e:	50                   	push   %eax
  801e7f:	ff 75 08             	pushl  0x8(%ebp)
  801e82:	e8 af f3 ff ff       	call   801236 <fd_lookup>
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	78 11                	js     801e9f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e97:	39 10                	cmp    %edx,(%eax)
  801e99:	0f 94 c0             	sete   %al
  801e9c:	0f b6 c0             	movzbl %al,%eax
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <opencons>:

int
opencons(void)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaa:	50                   	push   %eax
  801eab:	e8 37 f3 ff ff       	call   8011e7 <fd_alloc>
  801eb0:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 3e                	js     801ef7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb9:	83 ec 04             	sub    $0x4,%esp
  801ebc:	68 07 04 00 00       	push   $0x407
  801ec1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 d2 ed ff ff       	call   800c9d <sys_page_alloc>
  801ecb:	83 c4 10             	add    $0x10,%esp
		return r;
  801ece:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 23                	js     801ef7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee9:	83 ec 0c             	sub    $0xc,%esp
  801eec:	50                   	push   %eax
  801eed:	e8 ce f2 ff ff       	call   8011c0 <fd2num>
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	83 c4 10             	add    $0x10,%esp
}
  801ef7:	89 d0                	mov    %edx,%eax
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f01:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f08:	75 2a                	jne    801f34 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f0a:	83 ec 04             	sub    $0x4,%esp
  801f0d:	6a 07                	push   $0x7
  801f0f:	68 00 f0 bf ee       	push   $0xeebff000
  801f14:	6a 00                	push   $0x0
  801f16:	e8 82 ed ff ff       	call   800c9d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	79 12                	jns    801f34 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f22:	50                   	push   %eax
  801f23:	68 8c 29 80 00       	push   $0x80298c
  801f28:	6a 23                	push   $0x23
  801f2a:	68 90 29 80 00       	push   $0x802990
  801f2f:	e8 08 e3 ff ff       	call   80023c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f34:	8b 45 08             	mov    0x8(%ebp),%eax
  801f37:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f3c:	83 ec 08             	sub    $0x8,%esp
  801f3f:	68 66 1f 80 00       	push   $0x801f66
  801f44:	6a 00                	push   $0x0
  801f46:	e8 9d ee ff ff       	call   800de8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	79 12                	jns    801f64 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f52:	50                   	push   %eax
  801f53:	68 8c 29 80 00       	push   $0x80298c
  801f58:	6a 2c                	push   $0x2c
  801f5a:	68 90 29 80 00       	push   $0x802990
  801f5f:	e8 d8 e2 ff ff       	call   80023c <_panic>
	}
}
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    

00801f66 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f66:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f67:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f6c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f6e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f71:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f75:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f7a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f7e:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f80:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f83:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f84:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f87:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f88:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f89:	c3                   	ret    

00801f8a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	56                   	push   %esi
  801f8e:	53                   	push   %ebx
  801f8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	75 12                	jne    801fae <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	68 00 00 c0 ee       	push   $0xeec00000
  801fa4:	e8 a4 ee ff ff       	call   800e4d <sys_ipc_recv>
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	eb 0c                	jmp    801fba <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801fae:	83 ec 0c             	sub    $0xc,%esp
  801fb1:	50                   	push   %eax
  801fb2:	e8 96 ee ff ff       	call   800e4d <sys_ipc_recv>
  801fb7:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801fba:	85 f6                	test   %esi,%esi
  801fbc:	0f 95 c1             	setne  %cl
  801fbf:	85 db                	test   %ebx,%ebx
  801fc1:	0f 95 c2             	setne  %dl
  801fc4:	84 d1                	test   %dl,%cl
  801fc6:	74 09                	je     801fd1 <ipc_recv+0x47>
  801fc8:	89 c2                	mov    %eax,%edx
  801fca:	c1 ea 1f             	shr    $0x1f,%edx
  801fcd:	84 d2                	test   %dl,%dl
  801fcf:	75 2a                	jne    801ffb <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801fd1:	85 f6                	test   %esi,%esi
  801fd3:	74 0d                	je     801fe2 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801fd5:	a1 20 44 80 00       	mov    0x804420,%eax
  801fda:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801fe0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801fe2:	85 db                	test   %ebx,%ebx
  801fe4:	74 0d                	je     801ff3 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801fe6:	a1 20 44 80 00       	mov    0x804420,%eax
  801feb:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801ff1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ff3:	a1 20 44 80 00       	mov    0x804420,%eax
  801ff8:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ffb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffe:	5b                   	pop    %ebx
  801fff:	5e                   	pop    %esi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 0c             	sub    $0xc,%esp
  80200b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80200e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802011:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802014:	85 db                	test   %ebx,%ebx
  802016:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80201b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80201e:	ff 75 14             	pushl  0x14(%ebp)
  802021:	53                   	push   %ebx
  802022:	56                   	push   %esi
  802023:	57                   	push   %edi
  802024:	e8 01 ee ff ff       	call   800e2a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802029:	89 c2                	mov    %eax,%edx
  80202b:	c1 ea 1f             	shr    $0x1f,%edx
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	84 d2                	test   %dl,%dl
  802033:	74 17                	je     80204c <ipc_send+0x4a>
  802035:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802038:	74 12                	je     80204c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80203a:	50                   	push   %eax
  80203b:	68 9e 29 80 00       	push   $0x80299e
  802040:	6a 47                	push   $0x47
  802042:	68 ac 29 80 00       	push   $0x8029ac
  802047:	e8 f0 e1 ff ff       	call   80023c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80204c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80204f:	75 07                	jne    802058 <ipc_send+0x56>
			sys_yield();
  802051:	e8 28 ec ff ff       	call   800c7e <sys_yield>
  802056:	eb c6                	jmp    80201e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802058:	85 c0                	test   %eax,%eax
  80205a:	75 c2                	jne    80201e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80205c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80206f:	89 c2                	mov    %eax,%edx
  802071:	c1 e2 07             	shl    $0x7,%edx
  802074:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80207b:	8b 52 5c             	mov    0x5c(%edx),%edx
  80207e:	39 ca                	cmp    %ecx,%edx
  802080:	75 11                	jne    802093 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802082:	89 c2                	mov    %eax,%edx
  802084:	c1 e2 07             	shl    $0x7,%edx
  802087:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80208e:	8b 40 54             	mov    0x54(%eax),%eax
  802091:	eb 0f                	jmp    8020a2 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802093:	83 c0 01             	add    $0x1,%eax
  802096:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209b:	75 d2                	jne    80206f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80209d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	c1 e8 16             	shr    $0x16,%eax
  8020af:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020b6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020bb:	f6 c1 01             	test   $0x1,%cl
  8020be:	74 1d                	je     8020dd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020c0:	c1 ea 0c             	shr    $0xc,%edx
  8020c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ca:	f6 c2 01             	test   $0x1,%dl
  8020cd:	74 0e                	je     8020dd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020cf:	c1 ea 0c             	shr    $0xc,%edx
  8020d2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020d9:	ef 
  8020da:	0f b7 c0             	movzwl %ax,%eax
}
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    
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
