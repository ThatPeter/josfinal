
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
  80003e:	68 c0 25 80 00       	push   $0x8025c0
  800043:	e8 12 1b 00 00       	call   801b5a <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 c5 25 80 00       	push   $0x8025c5
  800057:	6a 0c                	push   $0xc
  800059:	68 d3 25 80 00       	push   $0x8025d3
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 c4 17 00 00       	call   801832 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 d9 16 00 00       	call   80175a <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 e8 25 80 00       	push   $0x8025e8
  800090:	6a 0f                	push   $0xf
  800092:	68 d3 25 80 00       	push   $0x8025d3
  800097:	e8 9f 01 00 00       	call   80023b <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 22 0f 00 00       	call   800fc3 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 f2 25 80 00       	push   $0x8025f2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 d3 25 80 00       	push   $0x8025d3
  8000b4:	e8 82 01 00 00       	call   80023b <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 66 17 00 00       	call   801832 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  8000d3:	e8 3c 02 00 00       	call   800314 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 6f 16 00 00       	call   80175a <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 74 26 80 00       	push   $0x802674
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 d3 25 80 00       	push   $0x8025d3
  800103:	e8 33 01 00 00       	call   80023b <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 8b 09 00 00       	call   800aa6 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 a0 26 80 00       	push   $0x8026a0
  80012a:	6a 19                	push   $0x19
  80012c:	68 d3 25 80 00       	push   $0x8025d3
  800131:	e8 05 01 00 00       	call   80023b <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 fb 25 80 00       	push   $0x8025fb
  80013e:	e8 d1 01 00 00       	call   800314 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 e4 16 00 00       	call   801832 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 34 14 00 00       	call   80158a <close>
		exit();
  800156:	e8 c6 00 00 00       	call   800221 <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 fc 1d 00 00       	call   801f63 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 e0 15 00 00       	call   80175a <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 d8 26 80 00       	push   $0x8026d8
  80018b:	6a 21                	push   $0x21
  80018d:	68 d3 25 80 00       	push   $0x8025d3
  800192:	e8 a4 00 00 00       	call   80023b <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 14 26 80 00       	push   $0x802614
  80019f:	e8 70 01 00 00       	call   800314 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 de 13 00 00       	call   80158a <close>
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
  8001c3:	e8 96 0a 00 00       	call   800c5e <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8001d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d8:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7e 07                	jle    8001e8 <libmain+0x30>
		binaryname = argv[0];
  8001e1:	8b 06                	mov    (%esi),%eax
  8001e3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	e8 41 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001f2:	e8 2a 00 00 00       	call   800221 <exit>
}
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5e                   	pop    %esi
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    

00800201 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800207:	a1 24 44 80 00       	mov    0x804424,%eax
	func();
  80020c:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80020e:	e8 4b 0a 00 00       	call   800c5e <sys_getenvid>
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	50                   	push   %eax
  800217:	e8 91 0c 00 00       	call   800ead <sys_thread_free>
}
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 89 13 00 00       	call   8015b5 <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 e7 09 00 00       	call   800c1d <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 10 0a 00 00       	call   800c5e <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 08 27 80 00       	push   $0x802708
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 bb 2a 80 00 	movl   $0x802abb,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 2f 09 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 54 01 00 00       	call   80044b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 d4 08 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 b4 1f 00 00       	call   802330 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 a1 20 00 00       	call   802460 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 2b 27 80 00 	movsbl 0x80272b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003da:	83 fa 01             	cmp    $0x1,%edx
  8003dd:	7e 0e                	jle    8003ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	8b 52 04             	mov    0x4(%edx),%edx
  8003eb:	eb 22                	jmp    80040f <getuint+0x38>
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 10                	je     800401 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	eb 0e                	jmp    80040f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 04             	lea    0x4(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800417:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041b:	8b 10                	mov    (%eax),%edx
  80041d:	3b 50 04             	cmp    0x4(%eax),%edx
  800420:	73 0a                	jae    80042c <sprintputch+0x1b>
		*b->buf++ = ch;
  800422:	8d 4a 01             	lea    0x1(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	88 02                	mov    %al,(%edx)
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 10             	pushl  0x10(%ebp)
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 05 00 00 00       	call   80044b <vprintfmt>
	va_end(ap);
}
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	57                   	push   %edi
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 2c             	sub    $0x2c,%esp
  800454:	8b 75 08             	mov    0x8(%ebp),%esi
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045d:	eb 12                	jmp    800471 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 89 03 00 00    	je     8007f0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	50                   	push   %eax
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 e2                	jne    80045f <vprintfmt+0x14>
  80047d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800481:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800488:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
  80049b:	eb 07                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8d 47 01             	lea    0x1(%edi),%eax
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004aa:	0f b6 07             	movzbl (%edi),%eax
  8004ad:	0f b6 c8             	movzbl %al,%ecx
  8004b0:	83 e8 23             	sub    $0x23,%eax
  8004b3:	3c 55                	cmp    $0x55,%al
  8004b5:	0f 87 1a 03 00 00    	ja     8007d5 <vprintfmt+0x38a>
  8004bb:	0f b6 c0             	movzbl %al,%eax
  8004be:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004cc:	eb d6                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e6:	83 fa 09             	cmp    $0x9,%edx
  8004e9:	77 39                	ja     800524 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ee:	eb e9                	jmp    8004d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800501:	eb 27                	jmp    80052a <vprintfmt+0xdf>
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	85 c0                	test   %eax,%eax
  800508:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050d:	0f 49 c8             	cmovns %eax,%ecx
  800510:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800516:	eb 8c                	jmp    8004a4 <vprintfmt+0x59>
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800522:	eb 80                	jmp    8004a4 <vprintfmt+0x59>
  800524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800527:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 89 70 ff ff ff    	jns    8004a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800534:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800541:	e9 5e ff ff ff       	jmp    8004a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800546:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054c:	e9 53 ff ff ff       	jmp    8004a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	ff 30                	pushl  (%eax)
  800560:	ff d6                	call   *%esi
			break;
  800562:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800568:	e9 04 ff ff ff       	jmp    800471 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	99                   	cltd   
  800579:	31 d0                	xor    %edx,%eax
  80057b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057d:	83 f8 0f             	cmp    $0xf,%eax
  800580:	7f 0b                	jg     80058d <vprintfmt+0x142>
  800582:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800589:	85 d2                	test   %edx,%edx
  80058b:	75 18                	jne    8005a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058d:	50                   	push   %eax
  80058e:	68 43 27 80 00       	push   $0x802743
  800593:	53                   	push   %ebx
  800594:	56                   	push   %esi
  800595:	e8 94 fe ff ff       	call   80042e <printfmt>
  80059a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a0:	e9 cc fe ff ff       	jmp    800471 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a5:	52                   	push   %edx
  8005a6:	68 81 2b 80 00       	push   $0x802b81
  8005ab:	53                   	push   %ebx
  8005ac:	56                   	push   %esi
  8005ad:	e8 7c fe ff ff       	call   80042e <printfmt>
  8005b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b8:	e9 b4 fe ff ff       	jmp    800471 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	b8 3c 27 80 00       	mov    $0x80273c,%eax
  8005cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d6:	0f 8e 94 00 00 00    	jle    800670 <vprintfmt+0x225>
  8005dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e0:	0f 84 98 00 00 00    	je     80067e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ec:	57                   	push   %edi
  8005ed:	e8 86 02 00 00       	call   800878 <strnlen>
  8005f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f5:	29 c1                	sub    %eax,%ecx
  8005f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800604:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800607:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	eb 0f                	jmp    80061a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	83 ef 01             	sub    $0x1,%edi
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	85 ff                	test   %edi,%edi
  80061c:	7f ed                	jg     80060b <vprintfmt+0x1c0>
  80061e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800621:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800624:	85 c9                	test   %ecx,%ecx
  800626:	b8 00 00 00 00       	mov    $0x0,%eax
  80062b:	0f 49 c1             	cmovns %ecx,%eax
  80062e:	29 c1                	sub    %eax,%ecx
  800630:	89 75 08             	mov    %esi,0x8(%ebp)
  800633:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800636:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800639:	89 cb                	mov    %ecx,%ebx
  80063b:	eb 4d                	jmp    80068a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800641:	74 1b                	je     80065e <vprintfmt+0x213>
  800643:	0f be c0             	movsbl %al,%eax
  800646:	83 e8 20             	sub    $0x20,%eax
  800649:	83 f8 5e             	cmp    $0x5e,%eax
  80064c:	76 10                	jbe    80065e <vprintfmt+0x213>
					putch('?', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	6a 3f                	push   $0x3f
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	eb 0d                	jmp    80066b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 0c             	pushl  0xc(%ebp)
  800664:	52                   	push   %edx
  800665:	ff 55 08             	call   *0x8(%ebp)
  800668:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066b:	83 eb 01             	sub    $0x1,%ebx
  80066e:	eb 1a                	jmp    80068a <vprintfmt+0x23f>
  800670:	89 75 08             	mov    %esi,0x8(%ebp)
  800673:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800676:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800679:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067c:	eb 0c                	jmp    80068a <vprintfmt+0x23f>
  80067e:	89 75 08             	mov    %esi,0x8(%ebp)
  800681:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800684:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800687:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068a:	83 c7 01             	add    $0x1,%edi
  80068d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800691:	0f be d0             	movsbl %al,%edx
  800694:	85 d2                	test   %edx,%edx
  800696:	74 23                	je     8006bb <vprintfmt+0x270>
  800698:	85 f6                	test   %esi,%esi
  80069a:	78 a1                	js     80063d <vprintfmt+0x1f2>
  80069c:	83 ee 01             	sub    $0x1,%esi
  80069f:	79 9c                	jns    80063d <vprintfmt+0x1f2>
  8006a1:	89 df                	mov    %ebx,%edi
  8006a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a9:	eb 18                	jmp    8006c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 20                	push   $0x20
  8006b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b3:	83 ef 01             	sub    $0x1,%edi
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 08                	jmp    8006c3 <vprintfmt+0x278>
  8006bb:	89 df                	mov    %ebx,%edi
  8006bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f e4                	jg     8006ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	e9 a2 fd ff ff       	jmp    800471 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cf:	83 fa 01             	cmp    $0x1,%edx
  8006d2:	7e 16                	jle    8006ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 08             	lea    0x8(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 50 04             	mov    0x4(%eax),%edx
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e8:	eb 32                	jmp    80071c <vprintfmt+0x2d1>
	else if (lflag)
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	74 18                	je     800706 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	89 c1                	mov    %eax,%ecx
  8006fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800701:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800704:	eb 16                	jmp    80071c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 c1                	mov    %eax,%ecx
  800716:	c1 f9 1f             	sar    $0x1f,%ecx
  800719:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800727:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072b:	79 74                	jns    8007a1 <vprintfmt+0x356>
				putch('-', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 2d                	push   $0x2d
  800733:	ff d6                	call   *%esi
				num = -(long long) num;
  800735:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800738:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80073b:	f7 d8                	neg    %eax
  80073d:	83 d2 00             	adc    $0x0,%edx
  800740:	f7 da                	neg    %edx
  800742:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800745:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074a:	eb 55                	jmp    8007a1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 83 fc ff ff       	call   8003d7 <getuint>
			base = 10;
  800754:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800759:	eb 46                	jmp    8007a1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 74 fc ff ff       	call   8003d7 <getuint>
			base = 8;
  800763:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800768:	eb 37                	jmp    8007a1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 30                	push   $0x30
  800770:	ff d6                	call   *%esi
			putch('x', putdat);
  800772:	83 c4 08             	add    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 78                	push   $0x78
  800778:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800783:	8b 00                	mov    (%eax),%eax
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800792:	eb 0d                	jmp    8007a1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
  800797:	e8 3b fc ff ff       	call   8003d7 <getuint>
			base = 16;
  80079c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a1:	83 ec 0c             	sub    $0xc,%esp
  8007a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a8:	57                   	push   %edi
  8007a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ac:	51                   	push   %ecx
  8007ad:	52                   	push   %edx
  8007ae:	50                   	push   %eax
  8007af:	89 da                	mov    %ebx,%edx
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	e8 70 fb ff ff       	call   800328 <printnum>
			break;
  8007b8:	83 c4 20             	add    $0x20,%esp
  8007bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007be:	e9 ae fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	51                   	push   %ecx
  8007c8:	ff d6                	call   *%esi
			break;
  8007ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d0:	e9 9c fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	6a 25                	push   $0x25
  8007db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	eb 03                	jmp    8007e5 <vprintfmt+0x39a>
  8007e2:	83 ef 01             	sub    $0x1,%edi
  8007e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e9:	75 f7                	jne    8007e2 <vprintfmt+0x397>
  8007eb:	e9 81 fc ff ff       	jmp    800471 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 18             	sub    $0x18,%esp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800804:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800807:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800815:	85 c0                	test   %eax,%eax
  800817:	74 26                	je     80083f <vsnprintf+0x47>
  800819:	85 d2                	test   %edx,%edx
  80081b:	7e 22                	jle    80083f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081d:	ff 75 14             	pushl  0x14(%ebp)
  800820:	ff 75 10             	pushl  0x10(%ebp)
  800823:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	68 11 04 80 00       	push   $0x800411
  80082c:	e8 1a fc ff ff       	call   80044b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800831:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800834:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 05                	jmp    800844 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084f:	50                   	push   %eax
  800850:	ff 75 10             	pushl  0x10(%ebp)
  800853:	ff 75 0c             	pushl  0xc(%ebp)
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 9a ff ff ff       	call   8007f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	ba 00 00 00 00       	mov    $0x0,%edx
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 c2                	cmp    %eax,%edx
  80088d:	74 08                	je     800897 <strnlen+0x1f>
  80088f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
  800895:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	83 c2 01             	add    $0x1,%edx
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	75 ef                	jne    8008a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c0:	53                   	push   %ebx
  8008c1:	e8 9a ff ff ff       	call   800860 <strlen>
  8008c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c9:	ff 75 0c             	pushl  0xc(%ebp)
  8008cc:	01 d8                	add    %ebx,%eax
  8008ce:	50                   	push   %eax
  8008cf:	e8 c5 ff ff ff       	call   800899 <strcpy>
	return dst;
}
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e6:	89 f3                	mov    %esi,%ebx
  8008e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	eb 0f                	jmp    8008fe <strncpy+0x23>
		*dst++ = *src;
  8008ef:	83 c2 01             	add    $0x1,%edx
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	39 da                	cmp    %ebx,%edx
  800900:	75 ed                	jne    8008ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800902:	89 f0                	mov    %esi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	8b 55 10             	mov    0x10(%ebp),%edx
  800916:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800918:	85 d2                	test   %edx,%edx
  80091a:	74 21                	je     80093d <strlcpy+0x35>
  80091c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800920:	89 f2                	mov    %esi,%edx
  800922:	eb 09                	jmp    80092d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092d:	39 c2                	cmp    %eax,%edx
  80092f:	74 09                	je     80093a <strlcpy+0x32>
  800931:	0f b6 19             	movzbl (%ecx),%ebx
  800934:	84 db                	test   %bl,%bl
  800936:	75 ec                	jne    800924 <strlcpy+0x1c>
  800938:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80093a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093d:	29 f0                	sub    %esi,%eax
}
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094c:	eb 06                	jmp    800954 <strcmp+0x11>
		p++, q++;
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800954:	0f b6 01             	movzbl (%ecx),%eax
  800957:	84 c0                	test   %al,%al
  800959:	74 04                	je     80095f <strcmp+0x1c>
  80095b:	3a 02                	cmp    (%edx),%al
  80095d:	74 ef                	je     80094e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 c0             	movzbl %al,%eax
  800962:	0f b6 12             	movzbl (%edx),%edx
  800965:	29 d0                	sub    %edx,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c3                	mov    %eax,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800978:	eb 06                	jmp    800980 <strncmp+0x17>
		n--, p++, q++;
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800980:	39 d8                	cmp    %ebx,%eax
  800982:	74 15                	je     800999 <strncmp+0x30>
  800984:	0f b6 08             	movzbl (%eax),%ecx
  800987:	84 c9                	test   %cl,%cl
  800989:	74 04                	je     80098f <strncmp+0x26>
  80098b:	3a 0a                	cmp    (%edx),%cl
  80098d:	74 eb                	je     80097a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098f:	0f b6 00             	movzbl (%eax),%eax
  800992:	0f b6 12             	movzbl (%edx),%edx
  800995:	29 d0                	sub    %edx,%eax
  800997:	eb 05                	jmp    80099e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ab:	eb 07                	jmp    8009b4 <strchr+0x13>
		if (*s == c)
  8009ad:	38 ca                	cmp    %cl,%dl
  8009af:	74 0f                	je     8009c0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	0f b6 10             	movzbl (%eax),%edx
  8009b7:	84 d2                	test   %dl,%dl
  8009b9:	75 f2                	jne    8009ad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cc:	eb 03                	jmp    8009d1 <strfind+0xf>
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 04                	je     8009dc <strfind+0x1a>
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f2                	jne    8009ce <strfind+0xc>
			break;
	return (char *) s;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 36                	je     800a24 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f4:	75 28                	jne    800a1e <memset+0x40>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 23                	jne    800a1e <memset+0x40>
		c &= 0xFF;
  8009fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a12:	89 d8                	mov    %ebx,%eax
  800a14:	09 d0                	or     %edx,%eax
  800a16:	c1 e9 02             	shr    $0x2,%ecx
  800a19:	fc                   	cld    
  800a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1c:	eb 06                	jmp    800a24 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a39:	39 c6                	cmp    %eax,%esi
  800a3b:	73 35                	jae    800a72 <memmove+0x47>
  800a3d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	73 2e                	jae    800a72 <memmove+0x47>
		s += n;
		d += n;
  800a44:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	09 fe                	or     %edi,%esi
  800a4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a51:	75 13                	jne    800a66 <memmove+0x3b>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0e                	jne    800a66 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a58:	83 ef 04             	sub    $0x4,%edi
  800a5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
  800a61:	fd                   	std    
  800a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a64:	eb 09                	jmp    800a6f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 1d                	jmp    800a8f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	89 f2                	mov    %esi,%edx
  800a74:	09 c2                	or     %eax,%edx
  800a76:	f6 c2 03             	test   $0x3,%dl
  800a79:	75 0f                	jne    800a8a <memmove+0x5f>
  800a7b:	f6 c1 03             	test   $0x3,%cl
  800a7e:	75 0a                	jne    800a8a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a80:	c1 e9 02             	shr    $0x2,%ecx
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a88:	eb 05                	jmp    800a8f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a96:	ff 75 10             	pushl  0x10(%ebp)
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	ff 75 08             	pushl  0x8(%ebp)
  800a9f:	e8 87 ff ff ff       	call   800a2b <memmove>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab6:	eb 1a                	jmp    800ad2 <memcmp+0x2c>
		if (*s1 != *s2)
  800ab8:	0f b6 08             	movzbl (%eax),%ecx
  800abb:	0f b6 1a             	movzbl (%edx),%ebx
  800abe:	38 d9                	cmp    %bl,%cl
  800ac0:	74 0a                	je     800acc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac2:	0f b6 c1             	movzbl %cl,%eax
  800ac5:	0f b6 db             	movzbl %bl,%ebx
  800ac8:	29 d8                	sub    %ebx,%eax
  800aca:	eb 0f                	jmp    800adb <memcmp+0x35>
		s1++, s2++;
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	39 f0                	cmp    %esi,%eax
  800ad4:	75 e2                	jne    800ab8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	53                   	push   %ebx
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae6:	89 c1                	mov    %eax,%ecx
  800ae8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aeb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	eb 0a                	jmp    800afb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af1:	0f b6 10             	movzbl (%eax),%edx
  800af4:	39 da                	cmp    %ebx,%edx
  800af6:	74 07                	je     800aff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	83 c0 01             	add    $0x1,%eax
  800afb:	39 c8                	cmp    %ecx,%eax
  800afd:	72 f2                	jb     800af1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aff:	5b                   	pop    %ebx
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	eb 03                	jmp    800b13 <strtol+0x11>
		s++;
  800b10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b13:	0f b6 01             	movzbl (%ecx),%eax
  800b16:	3c 20                	cmp    $0x20,%al
  800b18:	74 f6                	je     800b10 <strtol+0xe>
  800b1a:	3c 09                	cmp    $0x9,%al
  800b1c:	74 f2                	je     800b10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1e:	3c 2b                	cmp    $0x2b,%al
  800b20:	75 0a                	jne    800b2c <strtol+0x2a>
		s++;
  800b22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b25:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2a:	eb 11                	jmp    800b3d <strtol+0x3b>
  800b2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b31:	3c 2d                	cmp    $0x2d,%al
  800b33:	75 08                	jne    800b3d <strtol+0x3b>
		s++, neg = 1;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b43:	75 15                	jne    800b5a <strtol+0x58>
  800b45:	80 39 30             	cmpb   $0x30,(%ecx)
  800b48:	75 10                	jne    800b5a <strtol+0x58>
  800b4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4e:	75 7c                	jne    800bcc <strtol+0xca>
		s += 2, base = 16;
  800b50:	83 c1 02             	add    $0x2,%ecx
  800b53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b58:	eb 16                	jmp    800b70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 12                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b63:	80 39 30             	cmpb   $0x30,(%ecx)
  800b66:	75 08                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
  800b68:	83 c1 01             	add    $0x1,%ecx
  800b6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  800b75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b78:	0f b6 11             	movzbl (%ecx),%edx
  800b7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7e:	89 f3                	mov    %esi,%ebx
  800b80:	80 fb 09             	cmp    $0x9,%bl
  800b83:	77 08                	ja     800b8d <strtol+0x8b>
			dig = *s - '0';
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	83 ea 30             	sub    $0x30,%edx
  800b8b:	eb 22                	jmp    800baf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 19             	cmp    $0x19,%bl
  800b95:	77 08                	ja     800b9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b97:	0f be d2             	movsbl %dl,%edx
  800b9a:	83 ea 57             	sub    $0x57,%edx
  800b9d:	eb 10                	jmp    800baf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba2:	89 f3                	mov    %esi,%ebx
  800ba4:	80 fb 19             	cmp    $0x19,%bl
  800ba7:	77 16                	ja     800bbf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba9:	0f be d2             	movsbl %dl,%edx
  800bac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb2:	7d 0b                	jge    800bbf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bbb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bbd:	eb b9                	jmp    800b78 <strtol+0x76>

	if (endptr)
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	74 0d                	je     800bd2 <strtol+0xd0>
		*endptr = (char *) s;
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc8:	89 0e                	mov    %ecx,(%esi)
  800bca:	eb 06                	jmp    800bd2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	74 98                	je     800b68 <strtol+0x66>
  800bd0:	eb 9e                	jmp    800b70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd2:	89 c2                	mov    %eax,%edx
  800bd4:	f7 da                	neg    %edx
  800bd6:	85 ff                	test   %edi,%edi
  800bd8:	0f 45 c2             	cmovne %edx,%eax
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 03                	push   $0x3
  800c45:	68 1f 2a 80 00       	push   $0x802a1f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 3c 2a 80 00       	push   $0x802a3c
  800c51:	e8 e5 f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6e:	89 d1                	mov    %edx,%ecx
  800c70:	89 d3                	mov    %edx,%ebx
  800c72:	89 d7                	mov    %edx,%edi
  800c74:	89 d6                	mov    %edx,%esi
  800c76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_yield>:

void
sys_yield(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	be 00 00 00 00       	mov    $0x0,%esi
  800caa:	b8 04 00 00 00       	mov    $0x4,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	89 f7                	mov    %esi,%edi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 04                	push   $0x4
  800cc6:	68 1f 2a 80 00       	push   $0x802a1f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 3c 2a 80 00       	push   $0x802a3c
  800cd2:	e8 64 f5 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 05                	push   $0x5
  800d08:	68 1f 2a 80 00       	push   $0x802a1f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 3c 2a 80 00       	push   $0x802a3c
  800d14:	e8 22 f5 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 06                	push   $0x6
  800d4a:	68 1f 2a 80 00       	push   $0x802a1f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 3c 2a 80 00       	push   $0x802a3c
  800d56:	e8 e0 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 08                	push   $0x8
  800d8c:	68 1f 2a 80 00       	push   $0x802a1f
  800d91:	6a 23                	push   $0x23
  800d93:	68 3c 2a 80 00       	push   $0x802a3c
  800d98:	e8 9e f4 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 09 00 00 00       	mov    $0x9,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 09                	push   $0x9
  800dce:	68 1f 2a 80 00       	push   $0x802a1f
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 3c 2a 80 00       	push   $0x802a3c
  800dda:	e8 5c f4 ff ff       	call   80023b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0a                	push   $0xa
  800e10:	68 1f 2a 80 00       	push   $0x802a1f
  800e15:	6a 23                	push   $0x23
  800e17:	68 3c 2a 80 00       	push   $0x802a3c
  800e1c:	e8 1a f4 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	be 00 00 00 00       	mov    $0x0,%esi
  800e34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 cb                	mov    %ecx,%ebx
  800e64:	89 cf                	mov    %ecx,%edi
  800e66:	89 ce                	mov    %ecx,%esi
  800e68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 17                	jle    800e85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	6a 0d                	push   $0xd
  800e74:	68 1f 2a 80 00       	push   $0x802a1f
  800e79:	6a 23                	push   $0x23
  800e7b:	68 3c 2a 80 00       	push   $0x802a3c
  800e80:	e8 b6 f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e98:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 cb                	mov    %ecx,%ebx
  800ea2:	89 cf                	mov    %ecx,%edi
  800ea4:	89 ce                	mov    %ecx,%esi
  800ea6:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	89 cb                	mov    %ecx,%ebx
  800ec2:	89 cf                	mov    %ecx,%edi
  800ec4:	89 ce                	mov    %ecx,%esi
  800ec6:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed8:	b8 10 00 00 00       	mov    $0x10,%eax
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 cb                	mov    %ecx,%ebx
  800ee2:	89 cf                	mov    %ecx,%edi
  800ee4:	89 ce                	mov    %ecx,%esi
  800ee6:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 04             	sub    $0x4,%esp
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ef9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800efd:	74 11                	je     800f10 <pgfault+0x23>
  800eff:	89 d8                	mov    %ebx,%eax
  800f01:	c1 e8 0c             	shr    $0xc,%eax
  800f04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0b:	f6 c4 08             	test   $0x8,%ah
  800f0e:	75 14                	jne    800f24 <pgfault+0x37>
		panic("faulting access");
  800f10:	83 ec 04             	sub    $0x4,%esp
  800f13:	68 4a 2a 80 00       	push   $0x802a4a
  800f18:	6a 1f                	push   $0x1f
  800f1a:	68 5a 2a 80 00       	push   $0x802a5a
  800f1f:	e8 17 f3 ff ff       	call   80023b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f24:	83 ec 04             	sub    $0x4,%esp
  800f27:	6a 07                	push   $0x7
  800f29:	68 00 f0 7f 00       	push   $0x7ff000
  800f2e:	6a 00                	push   $0x0
  800f30:	e8 67 fd ff ff       	call   800c9c <sys_page_alloc>
	if (r < 0) {
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	79 12                	jns    800f4e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f3c:	50                   	push   %eax
  800f3d:	68 65 2a 80 00       	push   $0x802a65
  800f42:	6a 2d                	push   $0x2d
  800f44:	68 5a 2a 80 00       	push   $0x802a5a
  800f49:	e8 ed f2 ff ff       	call   80023b <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f4e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 00 10 00 00       	push   $0x1000
  800f5c:	53                   	push   %ebx
  800f5d:	68 00 f0 7f 00       	push   $0x7ff000
  800f62:	e8 2c fb ff ff       	call   800a93 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f67:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f6e:	53                   	push   %ebx
  800f6f:	6a 00                	push   $0x0
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	6a 00                	push   $0x0
  800f78:	e8 62 fd ff ff       	call   800cdf <sys_page_map>
	if (r < 0) {
  800f7d:	83 c4 20             	add    $0x20,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 12                	jns    800f96 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f84:	50                   	push   %eax
  800f85:	68 65 2a 80 00       	push   $0x802a65
  800f8a:	6a 34                	push   $0x34
  800f8c:	68 5a 2a 80 00       	push   $0x802a5a
  800f91:	e8 a5 f2 ff ff       	call   80023b <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	68 00 f0 7f 00       	push   $0x7ff000
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 7c fd ff ff       	call   800d21 <sys_page_unmap>
	if (r < 0) {
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	79 12                	jns    800fbe <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fac:	50                   	push   %eax
  800fad:	68 65 2a 80 00       	push   $0x802a65
  800fb2:	6a 38                	push   $0x38
  800fb4:	68 5a 2a 80 00       	push   $0x802a5a
  800fb9:	e8 7d f2 ff ff       	call   80023b <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fcc:	68 ed 0e 80 00       	push   $0x800eed
  800fd1:	e8 68 11 00 00       	call   80213e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd6:	b8 07 00 00 00       	mov    $0x7,%eax
  800fdb:	cd 30                	int    $0x30
  800fdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 17                	jns    800ffe <fork+0x3b>
		panic("fork fault %e");
  800fe7:	83 ec 04             	sub    $0x4,%esp
  800fea:	68 7e 2a 80 00       	push   $0x802a7e
  800fef:	68 85 00 00 00       	push   $0x85
  800ff4:	68 5a 2a 80 00       	push   $0x802a5a
  800ff9:	e8 3d f2 ff ff       	call   80023b <_panic>
  800ffe:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801000:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801004:	75 24                	jne    80102a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801006:	e8 53 fc ff ff       	call   800c5e <sys_getenvid>
  80100b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801010:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  801016:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80101b:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	e9 64 01 00 00       	jmp    80118e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80102a:	83 ec 04             	sub    $0x4,%esp
  80102d:	6a 07                	push   $0x7
  80102f:	68 00 f0 bf ee       	push   $0xeebff000
  801034:	ff 75 e4             	pushl  -0x1c(%ebp)
  801037:	e8 60 fc ff ff       	call   800c9c <sys_page_alloc>
  80103c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80103f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801044:	89 d8                	mov    %ebx,%eax
  801046:	c1 e8 16             	shr    $0x16,%eax
  801049:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801050:	a8 01                	test   $0x1,%al
  801052:	0f 84 fc 00 00 00    	je     801154 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801058:	89 d8                	mov    %ebx,%eax
  80105a:	c1 e8 0c             	shr    $0xc,%eax
  80105d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801064:	f6 c2 01             	test   $0x1,%dl
  801067:	0f 84 e7 00 00 00    	je     801154 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80106d:	89 c6                	mov    %eax,%esi
  80106f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801072:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801079:	f6 c6 04             	test   $0x4,%dh
  80107c:	74 39                	je     8010b7 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80107e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	25 07 0e 00 00       	and    $0xe07,%eax
  80108d:	50                   	push   %eax
  80108e:	56                   	push   %esi
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	6a 00                	push   $0x0
  801093:	e8 47 fc ff ff       	call   800cdf <sys_page_map>
		if (r < 0) {
  801098:	83 c4 20             	add    $0x20,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	0f 89 b1 00 00 00    	jns    801154 <fork+0x191>
		    	panic("sys page map fault %e");
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	68 8c 2a 80 00       	push   $0x802a8c
  8010ab:	6a 55                	push   $0x55
  8010ad:	68 5a 2a 80 00       	push   $0x802a5a
  8010b2:	e8 84 f1 ff ff       	call   80023b <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010be:	f6 c2 02             	test   $0x2,%dl
  8010c1:	75 0c                	jne    8010cf <fork+0x10c>
  8010c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ca:	f6 c4 08             	test   $0x8,%ah
  8010cd:	74 5b                	je     80112a <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	68 05 08 00 00       	push   $0x805
  8010d7:	56                   	push   %esi
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 fe fb ff ff       	call   800cdf <sys_page_map>
		if (r < 0) {
  8010e1:	83 c4 20             	add    $0x20,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	79 14                	jns    8010fc <fork+0x139>
		    	panic("sys page map fault %e");
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	68 8c 2a 80 00       	push   $0x802a8c
  8010f0:	6a 5c                	push   $0x5c
  8010f2:	68 5a 2a 80 00       	push   $0x802a5a
  8010f7:	e8 3f f1 ff ff       	call   80023b <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	68 05 08 00 00       	push   $0x805
  801104:	56                   	push   %esi
  801105:	6a 00                	push   $0x0
  801107:	56                   	push   %esi
  801108:	6a 00                	push   $0x0
  80110a:	e8 d0 fb ff ff       	call   800cdf <sys_page_map>
		if (r < 0) {
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	79 3e                	jns    801154 <fork+0x191>
		    	panic("sys page map fault %e");
  801116:	83 ec 04             	sub    $0x4,%esp
  801119:	68 8c 2a 80 00       	push   $0x802a8c
  80111e:	6a 60                	push   $0x60
  801120:	68 5a 2a 80 00       	push   $0x802a5a
  801125:	e8 11 f1 ff ff       	call   80023b <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	6a 05                	push   $0x5
  80112f:	56                   	push   %esi
  801130:	57                   	push   %edi
  801131:	56                   	push   %esi
  801132:	6a 00                	push   $0x0
  801134:	e8 a6 fb ff ff       	call   800cdf <sys_page_map>
		if (r < 0) {
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	79 14                	jns    801154 <fork+0x191>
		    	panic("sys page map fault %e");
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	68 8c 2a 80 00       	push   $0x802a8c
  801148:	6a 65                	push   $0x65
  80114a:	68 5a 2a 80 00       	push   $0x802a5a
  80114f:	e8 e7 f0 ff ff       	call   80023b <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801154:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80115a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801160:	0f 85 de fe ff ff    	jne    801044 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801166:	a1 20 44 80 00       	mov    0x804420,%eax
  80116b:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	50                   	push   %eax
  801175:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801178:	57                   	push   %edi
  801179:	e8 69 fc ff ff       	call   800de7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80117e:	83 c4 08             	add    $0x8,%esp
  801181:	6a 02                	push   $0x2
  801183:	57                   	push   %edi
  801184:	e8 da fb ff ff       	call   800d63 <sys_env_set_status>
	
	return envid;
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80118e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <sfork>:

envid_t
sfork(void)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a9:	a3 24 44 80 00       	mov    %eax,0x804424
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011ae:	68 01 02 80 00       	push   $0x800201
  8011b3:	e8 d5 fc ff ff       	call   800e8d <sys_thread_create>

	return id;
}
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8011c0:	ff 75 08             	pushl  0x8(%ebp)
  8011c3:	e8 e5 fc ff ff       	call   800ead <sys_thread_free>
}
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8011d3:	ff 75 08             	pushl  0x8(%ebp)
  8011d6:	e8 f2 fc ff ff       	call   800ecd <sys_thread_join>
}
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
  8011e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	6a 07                	push   $0x7
  8011f0:	6a 00                	push   $0x0
  8011f2:	56                   	push   %esi
  8011f3:	e8 a4 fa ff ff       	call   800c9c <sys_page_alloc>
	if (r < 0) {
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	79 15                	jns    801214 <queue_append+0x34>
		panic("%e\n", r);
  8011ff:	50                   	push   %eax
  801200:	68 d2 2a 80 00       	push   $0x802ad2
  801205:	68 d5 00 00 00       	push   $0xd5
  80120a:	68 5a 2a 80 00       	push   $0x802a5a
  80120f:	e8 27 f0 ff ff       	call   80023b <_panic>
	}	

	wt->envid = envid;
  801214:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80121a:	83 3b 00             	cmpl   $0x0,(%ebx)
  80121d:	75 13                	jne    801232 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80121f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801226:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80122d:	00 00 00 
  801230:	eb 1b                	jmp    80124d <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801232:	8b 43 04             	mov    0x4(%ebx),%eax
  801235:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80123c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801243:	00 00 00 
		queue->last = wt;
  801246:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80124d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80125d:	8b 02                	mov    (%edx),%eax
  80125f:	85 c0                	test   %eax,%eax
  801261:	75 17                	jne    80127a <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801263:	83 ec 04             	sub    $0x4,%esp
  801266:	68 a2 2a 80 00       	push   $0x802aa2
  80126b:	68 ec 00 00 00       	push   $0xec
  801270:	68 5a 2a 80 00       	push   $0x802a5a
  801275:	e8 c1 ef ff ff       	call   80023b <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80127a:	8b 48 04             	mov    0x4(%eax),%ecx
  80127d:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80127f:	8b 00                	mov    (%eax),%eax
}
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80128d:	b8 01 00 00 00       	mov    $0x1,%eax
  801292:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801295:	85 c0                	test   %eax,%eax
  801297:	74 45                	je     8012de <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801299:	e8 c0 f9 ff ff       	call   800c5e <sys_getenvid>
  80129e:	83 ec 08             	sub    $0x8,%esp
  8012a1:	83 c3 04             	add    $0x4,%ebx
  8012a4:	53                   	push   %ebx
  8012a5:	50                   	push   %eax
  8012a6:	e8 35 ff ff ff       	call   8011e0 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012ab:	e8 ae f9 ff ff       	call   800c5e <sys_getenvid>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	6a 04                	push   $0x4
  8012b5:	50                   	push   %eax
  8012b6:	e8 a8 fa ff ff       	call   800d63 <sys_env_set_status>

		if (r < 0) {
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	79 15                	jns    8012d7 <mutex_lock+0x54>
			panic("%e\n", r);
  8012c2:	50                   	push   %eax
  8012c3:	68 d2 2a 80 00       	push   $0x802ad2
  8012c8:	68 02 01 00 00       	push   $0x102
  8012cd:	68 5a 2a 80 00       	push   $0x802a5a
  8012d2:	e8 64 ef ff ff       	call   80023b <_panic>
		}
		sys_yield();
  8012d7:	e8 a1 f9 ff ff       	call   800c7d <sys_yield>
  8012dc:	eb 08                	jmp    8012e6 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8012de:	e8 7b f9 ff ff       	call   800c5e <sys_getenvid>
  8012e3:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8012e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	53                   	push   %ebx
  8012ef:	83 ec 04             	sub    $0x4,%esp
  8012f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8012f5:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012f9:	74 36                	je     801331 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	8d 43 04             	lea    0x4(%ebx),%eax
  801301:	50                   	push   %eax
  801302:	e8 4d ff ff ff       	call   801254 <queue_pop>
  801307:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	6a 02                	push   $0x2
  80130f:	50                   	push   %eax
  801310:	e8 4e fa ff ff       	call   800d63 <sys_env_set_status>
		if (r < 0) {
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	79 1d                	jns    801339 <mutex_unlock+0x4e>
			panic("%e\n", r);
  80131c:	50                   	push   %eax
  80131d:	68 d2 2a 80 00       	push   $0x802ad2
  801322:	68 16 01 00 00       	push   $0x116
  801327:	68 5a 2a 80 00       	push   $0x802a5a
  80132c:	e8 0a ef ff ff       	call   80023b <_panic>
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  801339:	e8 3f f9 ff ff       	call   800c7d <sys_yield>
}
  80133e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	53                   	push   %ebx
  801347:	83 ec 04             	sub    $0x4,%esp
  80134a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80134d:	e8 0c f9 ff ff       	call   800c5e <sys_getenvid>
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	6a 07                	push   $0x7
  801357:	53                   	push   %ebx
  801358:	50                   	push   %eax
  801359:	e8 3e f9 ff ff       	call   800c9c <sys_page_alloc>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	79 15                	jns    80137a <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801365:	50                   	push   %eax
  801366:	68 bd 2a 80 00       	push   $0x802abd
  80136b:	68 23 01 00 00       	push   $0x123
  801370:	68 5a 2a 80 00       	push   $0x802a5a
  801375:	e8 c1 ee ff ff       	call   80023b <_panic>
	}	
	mtx->locked = 0;
  80137a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801380:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801387:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80138e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8013a2:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8013a5:	eb 20                	jmp    8013c7 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	56                   	push   %esi
  8013ab:	e8 a4 fe ff ff       	call   801254 <queue_pop>
  8013b0:	83 c4 08             	add    $0x8,%esp
  8013b3:	6a 02                	push   $0x2
  8013b5:	50                   	push   %eax
  8013b6:	e8 a8 f9 ff ff       	call   800d63 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8013bb:	8b 43 04             	mov    0x4(%ebx),%eax
  8013be:	8b 40 04             	mov    0x4(%eax),%eax
  8013c1:	89 43 04             	mov    %eax,0x4(%ebx)
  8013c4:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8013c7:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8013cb:	75 da                	jne    8013a7 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	68 00 10 00 00       	push   $0x1000
  8013d5:	6a 00                	push   $0x0
  8013d7:	53                   	push   %ebx
  8013d8:	e8 01 f6 ff ff       	call   8009de <memset>
	mtx = NULL;
}
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5d                   	pop    %ebp
  8013e6:	c3                   	ret    

008013e7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ed:	05 00 00 00 30       	add    $0x30000000,%eax
  8013f2:	c1 e8 0c             	shr    $0xc,%eax
}
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fd:	05 00 00 00 30       	add    $0x30000000,%eax
  801402:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801407:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801414:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801419:	89 c2                	mov    %eax,%edx
  80141b:	c1 ea 16             	shr    $0x16,%edx
  80141e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801425:	f6 c2 01             	test   $0x1,%dl
  801428:	74 11                	je     80143b <fd_alloc+0x2d>
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	c1 ea 0c             	shr    $0xc,%edx
  80142f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801436:	f6 c2 01             	test   $0x1,%dl
  801439:	75 09                	jne    801444 <fd_alloc+0x36>
			*fd_store = fd;
  80143b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
  801442:	eb 17                	jmp    80145b <fd_alloc+0x4d>
  801444:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801449:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80144e:	75 c9                	jne    801419 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801450:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801456:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    

0080145d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801463:	83 f8 1f             	cmp    $0x1f,%eax
  801466:	77 36                	ja     80149e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801468:	c1 e0 0c             	shl    $0xc,%eax
  80146b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801470:	89 c2                	mov    %eax,%edx
  801472:	c1 ea 16             	shr    $0x16,%edx
  801475:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147c:	f6 c2 01             	test   $0x1,%dl
  80147f:	74 24                	je     8014a5 <fd_lookup+0x48>
  801481:	89 c2                	mov    %eax,%edx
  801483:	c1 ea 0c             	shr    $0xc,%edx
  801486:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148d:	f6 c2 01             	test   $0x1,%dl
  801490:	74 1a                	je     8014ac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801492:	8b 55 0c             	mov    0xc(%ebp),%edx
  801495:	89 02                	mov    %eax,(%edx)
	return 0;
  801497:	b8 00 00 00 00       	mov    $0x0,%eax
  80149c:	eb 13                	jmp    8014b1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80149e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a3:	eb 0c                	jmp    8014b1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014aa:	eb 05                	jmp    8014b1 <fd_lookup+0x54>
  8014ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014bc:	ba 58 2b 80 00       	mov    $0x802b58,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014c1:	eb 13                	jmp    8014d6 <dev_lookup+0x23>
  8014c3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014c6:	39 08                	cmp    %ecx,(%eax)
  8014c8:	75 0c                	jne    8014d6 <dev_lookup+0x23>
			*dev = devtab[i];
  8014ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014cd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d4:	eb 31                	jmp    801507 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014d6:	8b 02                	mov    (%edx),%eax
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	75 e7                	jne    8014c3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014dc:	a1 20 44 80 00       	mov    0x804420,%eax
  8014e1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	51                   	push   %ecx
  8014eb:	50                   	push   %eax
  8014ec:	68 d8 2a 80 00       	push   $0x802ad8
  8014f1:	e8 1e ee ff ff       	call   800314 <cprintf>
	*dev = 0;
  8014f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 10             	sub    $0x10,%esp
  801511:	8b 75 08             	mov    0x8(%ebp),%esi
  801514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801521:	c1 e8 0c             	shr    $0xc,%eax
  801524:	50                   	push   %eax
  801525:	e8 33 ff ff ff       	call   80145d <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 05                	js     801536 <fd_close+0x2d>
	    || fd != fd2)
  801531:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801534:	74 0c                	je     801542 <fd_close+0x39>
		return (must_exist ? r : 0);
  801536:	84 db                	test   %bl,%bl
  801538:	ba 00 00 00 00       	mov    $0x0,%edx
  80153d:	0f 44 c2             	cmove  %edx,%eax
  801540:	eb 41                	jmp    801583 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	ff 36                	pushl  (%esi)
  80154b:	e8 63 ff ff ff       	call   8014b3 <dev_lookup>
  801550:	89 c3                	mov    %eax,%ebx
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 1a                	js     801573 <fd_close+0x6a>
		if (dev->dev_close)
  801559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80155f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801564:	85 c0                	test   %eax,%eax
  801566:	74 0b                	je     801573 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801568:	83 ec 0c             	sub    $0xc,%esp
  80156b:	56                   	push   %esi
  80156c:	ff d0                	call   *%eax
  80156e:	89 c3                	mov    %eax,%ebx
  801570:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	56                   	push   %esi
  801577:	6a 00                	push   $0x0
  801579:	e8 a3 f7 ff ff       	call   800d21 <sys_page_unmap>
	return r;
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	89 d8                	mov    %ebx,%eax
}
  801583:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    

0080158a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	e8 c1 fe ff ff       	call   80145d <fd_lookup>
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 10                	js     8015b3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	6a 01                	push   $0x1
  8015a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ab:	e8 59 ff ff ff       	call   801509 <fd_close>
  8015b0:	83 c4 10             	add    $0x10,%esp
}
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <close_all>:

void
close_all(void)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	e8 c0 ff ff ff       	call   80158a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ca:	83 c3 01             	add    $0x1,%ebx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	83 fb 20             	cmp    $0x20,%ebx
  8015d3:	75 ec                	jne    8015c1 <close_all+0xc>
		close(i);
}
  8015d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	57                   	push   %edi
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 2c             	sub    $0x2c,%esp
  8015e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 08             	pushl  0x8(%ebp)
  8015ed:	e8 6b fe ff ff       	call   80145d <fd_lookup>
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	0f 88 c1 00 00 00    	js     8016be <dup+0xe4>
		return r;
	close(newfdnum);
  8015fd:	83 ec 0c             	sub    $0xc,%esp
  801600:	56                   	push   %esi
  801601:	e8 84 ff ff ff       	call   80158a <close>

	newfd = INDEX2FD(newfdnum);
  801606:	89 f3                	mov    %esi,%ebx
  801608:	c1 e3 0c             	shl    $0xc,%ebx
  80160b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801611:	83 c4 04             	add    $0x4,%esp
  801614:	ff 75 e4             	pushl  -0x1c(%ebp)
  801617:	e8 db fd ff ff       	call   8013f7 <fd2data>
  80161c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80161e:	89 1c 24             	mov    %ebx,(%esp)
  801621:	e8 d1 fd ff ff       	call   8013f7 <fd2data>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80162c:	89 f8                	mov    %edi,%eax
  80162e:	c1 e8 16             	shr    $0x16,%eax
  801631:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801638:	a8 01                	test   $0x1,%al
  80163a:	74 37                	je     801673 <dup+0x99>
  80163c:	89 f8                	mov    %edi,%eax
  80163e:	c1 e8 0c             	shr    $0xc,%eax
  801641:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801648:	f6 c2 01             	test   $0x1,%dl
  80164b:	74 26                	je     801673 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80164d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801654:	83 ec 0c             	sub    $0xc,%esp
  801657:	25 07 0e 00 00       	and    $0xe07,%eax
  80165c:	50                   	push   %eax
  80165d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801660:	6a 00                	push   $0x0
  801662:	57                   	push   %edi
  801663:	6a 00                	push   $0x0
  801665:	e8 75 f6 ff ff       	call   800cdf <sys_page_map>
  80166a:	89 c7                	mov    %eax,%edi
  80166c:	83 c4 20             	add    $0x20,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 2e                	js     8016a1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801673:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801676:	89 d0                	mov    %edx,%eax
  801678:	c1 e8 0c             	shr    $0xc,%eax
  80167b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801682:	83 ec 0c             	sub    $0xc,%esp
  801685:	25 07 0e 00 00       	and    $0xe07,%eax
  80168a:	50                   	push   %eax
  80168b:	53                   	push   %ebx
  80168c:	6a 00                	push   $0x0
  80168e:	52                   	push   %edx
  80168f:	6a 00                	push   $0x0
  801691:	e8 49 f6 ff ff       	call   800cdf <sys_page_map>
  801696:	89 c7                	mov    %eax,%edi
  801698:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80169b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169d:	85 ff                	test   %edi,%edi
  80169f:	79 1d                	jns    8016be <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	6a 00                	push   $0x0
  8016a7:	e8 75 f6 ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ac:	83 c4 08             	add    $0x8,%esp
  8016af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016b2:	6a 00                	push   $0x0
  8016b4:	e8 68 f6 ff ff       	call   800d21 <sys_page_unmap>
	return r;
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	89 f8                	mov    %edi,%eax
}
  8016be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5f                   	pop    %edi
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 14             	sub    $0x14,%esp
  8016cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	53                   	push   %ebx
  8016d5:	e8 83 fd ff ff       	call   80145d <fd_lookup>
  8016da:	83 c4 08             	add    $0x8,%esp
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 70                	js     801753 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e9:	50                   	push   %eax
  8016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ed:	ff 30                	pushl  (%eax)
  8016ef:	e8 bf fd ff ff       	call   8014b3 <dev_lookup>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 4f                	js     80174a <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016fe:	8b 42 08             	mov    0x8(%edx),%eax
  801701:	83 e0 03             	and    $0x3,%eax
  801704:	83 f8 01             	cmp    $0x1,%eax
  801707:	75 24                	jne    80172d <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801709:	a1 20 44 80 00       	mov    0x804420,%eax
  80170e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	68 1c 2b 80 00       	push   $0x802b1c
  80171e:	e8 f1 eb ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172b:	eb 26                	jmp    801753 <read+0x8d>
	}
	if (!dev->dev_read)
  80172d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801730:	8b 40 08             	mov    0x8(%eax),%eax
  801733:	85 c0                	test   %eax,%eax
  801735:	74 17                	je     80174e <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	52                   	push   %edx
  801741:	ff d0                	call   *%eax
  801743:	89 c2                	mov    %eax,%edx
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	eb 09                	jmp    801753 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	eb 05                	jmp    801753 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80174e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801753:	89 d0                	mov    %edx,%eax
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	57                   	push   %edi
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	83 ec 0c             	sub    $0xc,%esp
  801763:	8b 7d 08             	mov    0x8(%ebp),%edi
  801766:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801769:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176e:	eb 21                	jmp    801791 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801770:	83 ec 04             	sub    $0x4,%esp
  801773:	89 f0                	mov    %esi,%eax
  801775:	29 d8                	sub    %ebx,%eax
  801777:	50                   	push   %eax
  801778:	89 d8                	mov    %ebx,%eax
  80177a:	03 45 0c             	add    0xc(%ebp),%eax
  80177d:	50                   	push   %eax
  80177e:	57                   	push   %edi
  80177f:	e8 42 ff ff ff       	call   8016c6 <read>
		if (m < 0)
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	78 10                	js     80179b <readn+0x41>
			return m;
		if (m == 0)
  80178b:	85 c0                	test   %eax,%eax
  80178d:	74 0a                	je     801799 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178f:	01 c3                	add    %eax,%ebx
  801791:	39 f3                	cmp    %esi,%ebx
  801793:	72 db                	jb     801770 <readn+0x16>
  801795:	89 d8                	mov    %ebx,%eax
  801797:	eb 02                	jmp    80179b <readn+0x41>
  801799:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80179b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5f                   	pop    %edi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 14             	sub    $0x14,%esp
  8017aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	53                   	push   %ebx
  8017b2:	e8 a6 fc ff ff       	call   80145d <fd_lookup>
  8017b7:	83 c4 08             	add    $0x8,%esp
  8017ba:	89 c2                	mov    %eax,%edx
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 6b                	js     80182b <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c6:	50                   	push   %eax
  8017c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ca:	ff 30                	pushl  (%eax)
  8017cc:	e8 e2 fc ff ff       	call   8014b3 <dev_lookup>
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 4a                	js     801822 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017df:	75 24                	jne    801805 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e1:	a1 20 44 80 00       	mov    0x804420,%eax
  8017e6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017ec:	83 ec 04             	sub    $0x4,%esp
  8017ef:	53                   	push   %ebx
  8017f0:	50                   	push   %eax
  8017f1:	68 38 2b 80 00       	push   $0x802b38
  8017f6:	e8 19 eb ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801803:	eb 26                	jmp    80182b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801805:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801808:	8b 52 0c             	mov    0xc(%edx),%edx
  80180b:	85 d2                	test   %edx,%edx
  80180d:	74 17                	je     801826 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	ff 75 10             	pushl  0x10(%ebp)
  801815:	ff 75 0c             	pushl  0xc(%ebp)
  801818:	50                   	push   %eax
  801819:	ff d2                	call   *%edx
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	eb 09                	jmp    80182b <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801822:	89 c2                	mov    %eax,%edx
  801824:	eb 05                	jmp    80182b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801826:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80182b:	89 d0                	mov    %edx,%eax
  80182d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <seek>:

int
seek(int fdnum, off_t offset)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801838:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80183b:	50                   	push   %eax
  80183c:	ff 75 08             	pushl  0x8(%ebp)
  80183f:	e8 19 fc ff ff       	call   80145d <fd_lookup>
  801844:	83 c4 08             	add    $0x8,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	78 0e                	js     801859 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80184b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801851:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	53                   	push   %ebx
  80185f:	83 ec 14             	sub    $0x14,%esp
  801862:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801865:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	53                   	push   %ebx
  80186a:	e8 ee fb ff ff       	call   80145d <fd_lookup>
  80186f:	83 c4 08             	add    $0x8,%esp
  801872:	89 c2                	mov    %eax,%edx
  801874:	85 c0                	test   %eax,%eax
  801876:	78 68                	js     8018e0 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187e:	50                   	push   %eax
  80187f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801882:	ff 30                	pushl  (%eax)
  801884:	e8 2a fc ff ff       	call   8014b3 <dev_lookup>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 47                	js     8018d7 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801893:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801897:	75 24                	jne    8018bd <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801899:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80189e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018a4:	83 ec 04             	sub    $0x4,%esp
  8018a7:	53                   	push   %ebx
  8018a8:	50                   	push   %eax
  8018a9:	68 f8 2a 80 00       	push   $0x802af8
  8018ae:	e8 61 ea ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018bb:	eb 23                	jmp    8018e0 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c0:	8b 52 18             	mov    0x18(%edx),%edx
  8018c3:	85 d2                	test   %edx,%edx
  8018c5:	74 14                	je     8018db <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	ff 75 0c             	pushl  0xc(%ebp)
  8018cd:	50                   	push   %eax
  8018ce:	ff d2                	call   *%edx
  8018d0:	89 c2                	mov    %eax,%edx
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	eb 09                	jmp    8018e0 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d7:	89 c2                	mov    %eax,%edx
  8018d9:	eb 05                	jmp    8018e0 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018e0:	89 d0                	mov    %edx,%eax
  8018e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 14             	sub    $0x14,%esp
  8018ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	ff 75 08             	pushl  0x8(%ebp)
  8018f8:	e8 60 fb ff ff       	call   80145d <fd_lookup>
  8018fd:	83 c4 08             	add    $0x8,%esp
  801900:	89 c2                	mov    %eax,%edx
  801902:	85 c0                	test   %eax,%eax
  801904:	78 58                	js     80195e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190c:	50                   	push   %eax
  80190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801910:	ff 30                	pushl  (%eax)
  801912:	e8 9c fb ff ff       	call   8014b3 <dev_lookup>
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 37                	js     801955 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801921:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801925:	74 32                	je     801959 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801927:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80192a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801931:	00 00 00 
	stat->st_isdir = 0;
  801934:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80193b:	00 00 00 
	stat->st_dev = dev;
  80193e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	53                   	push   %ebx
  801948:	ff 75 f0             	pushl  -0x10(%ebp)
  80194b:	ff 50 14             	call   *0x14(%eax)
  80194e:	89 c2                	mov    %eax,%edx
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb 09                	jmp    80195e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801955:	89 c2                	mov    %eax,%edx
  801957:	eb 05                	jmp    80195e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801959:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80195e:	89 d0                	mov    %edx,%eax
  801960:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801963:	c9                   	leave  
  801964:	c3                   	ret    

00801965 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	6a 00                	push   $0x0
  80196f:	ff 75 08             	pushl  0x8(%ebp)
  801972:	e8 e3 01 00 00       	call   801b5a <open>
  801977:	89 c3                	mov    %eax,%ebx
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 1b                	js     80199b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	ff 75 0c             	pushl  0xc(%ebp)
  801986:	50                   	push   %eax
  801987:	e8 5b ff ff ff       	call   8018e7 <fstat>
  80198c:	89 c6                	mov    %eax,%esi
	close(fd);
  80198e:	89 1c 24             	mov    %ebx,(%esp)
  801991:	e8 f4 fb ff ff       	call   80158a <close>
	return r;
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	89 f0                	mov    %esi,%eax
}
  80199b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	56                   	push   %esi
  8019a6:	53                   	push   %ebx
  8019a7:	89 c6                	mov    %eax,%esi
  8019a9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019ab:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019b2:	75 12                	jne    8019c6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b4:	83 ec 0c             	sub    $0xc,%esp
  8019b7:	6a 01                	push   $0x1
  8019b9:	e8 ec 08 00 00       	call   8022aa <ipc_find_env>
  8019be:	a3 00 40 80 00       	mov    %eax,0x804000
  8019c3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019c6:	6a 07                	push   $0x7
  8019c8:	68 00 50 80 00       	push   $0x805000
  8019cd:	56                   	push   %esi
  8019ce:	ff 35 00 40 80 00    	pushl  0x804000
  8019d4:	e8 6f 08 00 00       	call   802248 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019d9:	83 c4 0c             	add    $0xc,%esp
  8019dc:	6a 00                	push   $0x0
  8019de:	53                   	push   %ebx
  8019df:	6a 00                	push   $0x0
  8019e1:	e8 e7 07 00 00       	call   8021cd <ipc_recv>
}
  8019e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a01:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a06:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0b:	b8 02 00 00 00       	mov    $0x2,%eax
  801a10:	e8 8d ff ff ff       	call   8019a2 <fsipc>
}
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	8b 40 0c             	mov    0xc(%eax),%eax
  801a23:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a28:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2d:	b8 06 00 00 00       	mov    $0x6,%eax
  801a32:	e8 6b ff ff ff       	call   8019a2 <fsipc>
}
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 04             	sub    $0x4,%esp
  801a40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	8b 40 0c             	mov    0xc(%eax),%eax
  801a49:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a53:	b8 05 00 00 00       	mov    $0x5,%eax
  801a58:	e8 45 ff ff ff       	call   8019a2 <fsipc>
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 2c                	js     801a8d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a61:	83 ec 08             	sub    $0x8,%esp
  801a64:	68 00 50 80 00       	push   $0x805000
  801a69:	53                   	push   %ebx
  801a6a:	e8 2a ee ff ff       	call   800899 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a6f:	a1 80 50 80 00       	mov    0x805080,%eax
  801a74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a7a:	a1 84 50 80 00       	mov    0x805084,%eax
  801a7f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a9b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a9e:	8b 52 0c             	mov    0xc(%edx),%edx
  801aa1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aa7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aac:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ab1:	0f 47 c2             	cmova  %edx,%eax
  801ab4:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ab9:	50                   	push   %eax
  801aba:	ff 75 0c             	pushl  0xc(%ebp)
  801abd:	68 08 50 80 00       	push   $0x805008
  801ac2:	e8 64 ef ff ff       	call   800a2b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  801acc:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad1:	e8 cc fe ff ff       	call   8019a2 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	56                   	push   %esi
  801adc:	53                   	push   %ebx
  801add:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aeb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801af1:	ba 00 00 00 00       	mov    $0x0,%edx
  801af6:	b8 03 00 00 00       	mov    $0x3,%eax
  801afb:	e8 a2 fe ff ff       	call   8019a2 <fsipc>
  801b00:	89 c3                	mov    %eax,%ebx
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 4b                	js     801b51 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b06:	39 c6                	cmp    %eax,%esi
  801b08:	73 16                	jae    801b20 <devfile_read+0x48>
  801b0a:	68 68 2b 80 00       	push   $0x802b68
  801b0f:	68 6f 2b 80 00       	push   $0x802b6f
  801b14:	6a 7c                	push   $0x7c
  801b16:	68 84 2b 80 00       	push   $0x802b84
  801b1b:	e8 1b e7 ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  801b20:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b25:	7e 16                	jle    801b3d <devfile_read+0x65>
  801b27:	68 8f 2b 80 00       	push   $0x802b8f
  801b2c:	68 6f 2b 80 00       	push   $0x802b6f
  801b31:	6a 7d                	push   $0x7d
  801b33:	68 84 2b 80 00       	push   $0x802b84
  801b38:	e8 fe e6 ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b3d:	83 ec 04             	sub    $0x4,%esp
  801b40:	50                   	push   %eax
  801b41:	68 00 50 80 00       	push   $0x805000
  801b46:	ff 75 0c             	pushl  0xc(%ebp)
  801b49:	e8 dd ee ff ff       	call   800a2b <memmove>
	return r;
  801b4e:	83 c4 10             	add    $0x10,%esp
}
  801b51:	89 d8                	mov    %ebx,%eax
  801b53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b56:	5b                   	pop    %ebx
  801b57:	5e                   	pop    %esi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	53                   	push   %ebx
  801b5e:	83 ec 20             	sub    $0x20,%esp
  801b61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b64:	53                   	push   %ebx
  801b65:	e8 f6 ec ff ff       	call   800860 <strlen>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b72:	7f 67                	jg     801bdb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7a:	50                   	push   %eax
  801b7b:	e8 8e f8 ff ff       	call   80140e <fd_alloc>
  801b80:	83 c4 10             	add    $0x10,%esp
		return r;
  801b83:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 57                	js     801be0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b89:	83 ec 08             	sub    $0x8,%esp
  801b8c:	53                   	push   %ebx
  801b8d:	68 00 50 80 00       	push   $0x805000
  801b92:	e8 02 ed ff ff       	call   800899 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba7:	e8 f6 fd ff ff       	call   8019a2 <fsipc>
  801bac:	89 c3                	mov    %eax,%ebx
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	79 14                	jns    801bc9 <open+0x6f>
		fd_close(fd, 0);
  801bb5:	83 ec 08             	sub    $0x8,%esp
  801bb8:	6a 00                	push   $0x0
  801bba:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbd:	e8 47 f9 ff ff       	call   801509 <fd_close>
		return r;
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	89 da                	mov    %ebx,%edx
  801bc7:	eb 17                	jmp    801be0 <open+0x86>
	}

	return fd2num(fd);
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcf:	e8 13 f8 ff ff       	call   8013e7 <fd2num>
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	eb 05                	jmp    801be0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bdb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be0:	89 d0                	mov    %edx,%eax
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bed:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf2:	b8 08 00 00 00       	mov    $0x8,%eax
  801bf7:	e8 a6 fd ff ff       	call   8019a2 <fsipc>
}
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    

00801bfe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	56                   	push   %esi
  801c02:	53                   	push   %ebx
  801c03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	ff 75 08             	pushl  0x8(%ebp)
  801c0c:	e8 e6 f7 ff ff       	call   8013f7 <fd2data>
  801c11:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c13:	83 c4 08             	add    $0x8,%esp
  801c16:	68 9b 2b 80 00       	push   $0x802b9b
  801c1b:	53                   	push   %ebx
  801c1c:	e8 78 ec ff ff       	call   800899 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c21:	8b 46 04             	mov    0x4(%esi),%eax
  801c24:	2b 06                	sub    (%esi),%eax
  801c26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c2c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c33:	00 00 00 
	stat->st_dev = &devpipe;
  801c36:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c3d:	30 80 00 
	return 0;
}
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
  801c45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c56:	53                   	push   %ebx
  801c57:	6a 00                	push   $0x0
  801c59:	e8 c3 f0 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c5e:	89 1c 24             	mov    %ebx,(%esp)
  801c61:	e8 91 f7 ff ff       	call   8013f7 <fd2data>
  801c66:	83 c4 08             	add    $0x8,%esp
  801c69:	50                   	push   %eax
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 b0 f0 ff ff       	call   800d21 <sys_page_unmap>
}
  801c71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	57                   	push   %edi
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 1c             	sub    $0x1c,%esp
  801c7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c82:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c84:	a1 20 44 80 00       	mov    0x804420,%eax
  801c89:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	ff 75 e0             	pushl  -0x20(%ebp)
  801c95:	e8 55 06 00 00       	call   8022ef <pageref>
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	89 3c 24             	mov    %edi,(%esp)
  801c9f:	e8 4b 06 00 00       	call   8022ef <pageref>
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	39 c3                	cmp    %eax,%ebx
  801ca9:	0f 94 c1             	sete   %cl
  801cac:	0f b6 c9             	movzbl %cl,%ecx
  801caf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cb2:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801cb8:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801cbe:	39 ce                	cmp    %ecx,%esi
  801cc0:	74 1e                	je     801ce0 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801cc2:	39 c3                	cmp    %eax,%ebx
  801cc4:	75 be                	jne    801c84 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cc6:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801ccc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ccf:	50                   	push   %eax
  801cd0:	56                   	push   %esi
  801cd1:	68 a2 2b 80 00       	push   $0x802ba2
  801cd6:	e8 39 e6 ff ff       	call   800314 <cprintf>
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	eb a4                	jmp    801c84 <_pipeisclosed+0xe>
	}
}
  801ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5f                   	pop    %edi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	57                   	push   %edi
  801cef:	56                   	push   %esi
  801cf0:	53                   	push   %ebx
  801cf1:	83 ec 28             	sub    $0x28,%esp
  801cf4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cf7:	56                   	push   %esi
  801cf8:	e8 fa f6 ff ff       	call   8013f7 <fd2data>
  801cfd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	bf 00 00 00 00       	mov    $0x0,%edi
  801d07:	eb 4b                	jmp    801d54 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d09:	89 da                	mov    %ebx,%edx
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	e8 64 ff ff ff       	call   801c76 <_pipeisclosed>
  801d12:	85 c0                	test   %eax,%eax
  801d14:	75 48                	jne    801d5e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d16:	e8 62 ef ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d1b:	8b 43 04             	mov    0x4(%ebx),%eax
  801d1e:	8b 0b                	mov    (%ebx),%ecx
  801d20:	8d 51 20             	lea    0x20(%ecx),%edx
  801d23:	39 d0                	cmp    %edx,%eax
  801d25:	73 e2                	jae    801d09 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d2e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	c1 fa 1f             	sar    $0x1f,%edx
  801d36:	89 d1                	mov    %edx,%ecx
  801d38:	c1 e9 1b             	shr    $0x1b,%ecx
  801d3b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d3e:	83 e2 1f             	and    $0x1f,%edx
  801d41:	29 ca                	sub    %ecx,%edx
  801d43:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d47:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d4b:	83 c0 01             	add    $0x1,%eax
  801d4e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d51:	83 c7 01             	add    $0x1,%edi
  801d54:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d57:	75 c2                	jne    801d1b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d59:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5c:	eb 05                	jmp    801d63 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	57                   	push   %edi
  801d6f:	56                   	push   %esi
  801d70:	53                   	push   %ebx
  801d71:	83 ec 18             	sub    $0x18,%esp
  801d74:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d77:	57                   	push   %edi
  801d78:	e8 7a f6 ff ff       	call   8013f7 <fd2data>
  801d7d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d87:	eb 3d                	jmp    801dc6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d89:	85 db                	test   %ebx,%ebx
  801d8b:	74 04                	je     801d91 <devpipe_read+0x26>
				return i;
  801d8d:	89 d8                	mov    %ebx,%eax
  801d8f:	eb 44                	jmp    801dd5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d91:	89 f2                	mov    %esi,%edx
  801d93:	89 f8                	mov    %edi,%eax
  801d95:	e8 dc fe ff ff       	call   801c76 <_pipeisclosed>
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	75 32                	jne    801dd0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d9e:	e8 da ee ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801da3:	8b 06                	mov    (%esi),%eax
  801da5:	3b 46 04             	cmp    0x4(%esi),%eax
  801da8:	74 df                	je     801d89 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801daa:	99                   	cltd   
  801dab:	c1 ea 1b             	shr    $0x1b,%edx
  801dae:	01 d0                	add    %edx,%eax
  801db0:	83 e0 1f             	and    $0x1f,%eax
  801db3:	29 d0                	sub    %edx,%eax
  801db5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dbd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dc0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc3:	83 c3 01             	add    $0x1,%ebx
  801dc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc9:	75 d8                	jne    801da3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dcb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dce:	eb 05                	jmp    801dd5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	56                   	push   %esi
  801de1:	53                   	push   %ebx
  801de2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de8:	50                   	push   %eax
  801de9:	e8 20 f6 ff ff       	call   80140e <fd_alloc>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 2c 01 00 00    	js     801f27 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfb:	83 ec 04             	sub    $0x4,%esp
  801dfe:	68 07 04 00 00       	push   $0x407
  801e03:	ff 75 f4             	pushl  -0xc(%ebp)
  801e06:	6a 00                	push   $0x0
  801e08:	e8 8f ee ff ff       	call   800c9c <sys_page_alloc>
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	0f 88 0d 01 00 00    	js     801f27 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	e8 e8 f5 ff ff       	call   80140e <fd_alloc>
  801e26:	89 c3                	mov    %eax,%ebx
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	0f 88 e2 00 00 00    	js     801f15 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e33:	83 ec 04             	sub    $0x4,%esp
  801e36:	68 07 04 00 00       	push   $0x407
  801e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 57 ee ff ff       	call   800c9c <sys_page_alloc>
  801e45:	89 c3                	mov    %eax,%ebx
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	0f 88 c3 00 00 00    	js     801f15 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e52:	83 ec 0c             	sub    $0xc,%esp
  801e55:	ff 75 f4             	pushl  -0xc(%ebp)
  801e58:	e8 9a f5 ff ff       	call   8013f7 <fd2data>
  801e5d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5f:	83 c4 0c             	add    $0xc,%esp
  801e62:	68 07 04 00 00       	push   $0x407
  801e67:	50                   	push   %eax
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 2d ee ff ff       	call   800c9c <sys_page_alloc>
  801e6f:	89 c3                	mov    %eax,%ebx
  801e71:	83 c4 10             	add    $0x10,%esp
  801e74:	85 c0                	test   %eax,%eax
  801e76:	0f 88 89 00 00 00    	js     801f05 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e82:	e8 70 f5 ff ff       	call   8013f7 <fd2data>
  801e87:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e8e:	50                   	push   %eax
  801e8f:	6a 00                	push   $0x0
  801e91:	56                   	push   %esi
  801e92:	6a 00                	push   $0x0
  801e94:	e8 46 ee ff ff       	call   800cdf <sys_page_map>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 20             	add    $0x20,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 55                	js     801ef7 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ea2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eb7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed2:	e8 10 f5 ff ff       	call   8013e7 <fd2num>
  801ed7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eda:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801edc:	83 c4 04             	add    $0x4,%esp
  801edf:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee2:	e8 00 f5 ff ff       	call   8013e7 <fd2num>
  801ee7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eea:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef5:	eb 30                	jmp    801f27 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ef7:	83 ec 08             	sub    $0x8,%esp
  801efa:	56                   	push   %esi
  801efb:	6a 00                	push   $0x0
  801efd:	e8 1f ee ff ff       	call   800d21 <sys_page_unmap>
  801f02:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f05:	83 ec 08             	sub    $0x8,%esp
  801f08:	ff 75 f0             	pushl  -0x10(%ebp)
  801f0b:	6a 00                	push   $0x0
  801f0d:	e8 0f ee ff ff       	call   800d21 <sys_page_unmap>
  801f12:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f15:	83 ec 08             	sub    $0x8,%esp
  801f18:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 ff ed ff ff       	call   800d21 <sys_page_unmap>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f27:	89 d0                	mov    %edx,%eax
  801f29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5d                   	pop    %ebp
  801f2f:	c3                   	ret    

00801f30 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f39:	50                   	push   %eax
  801f3a:	ff 75 08             	pushl  0x8(%ebp)
  801f3d:	e8 1b f5 ff ff       	call   80145d <fd_lookup>
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 18                	js     801f61 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f49:	83 ec 0c             	sub    $0xc,%esp
  801f4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4f:	e8 a3 f4 ff ff       	call   8013f7 <fd2data>
	return _pipeisclosed(fd, p);
  801f54:	89 c2                	mov    %eax,%edx
  801f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f59:	e8 18 fd ff ff       	call   801c76 <_pipeisclosed>
  801f5e:	83 c4 10             	add    $0x10,%esp
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	56                   	push   %esi
  801f67:	53                   	push   %ebx
  801f68:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f6b:	85 f6                	test   %esi,%esi
  801f6d:	75 16                	jne    801f85 <wait+0x22>
  801f6f:	68 ba 2b 80 00       	push   $0x802bba
  801f74:	68 6f 2b 80 00       	push   $0x802b6f
  801f79:	6a 09                	push   $0x9
  801f7b:	68 c5 2b 80 00       	push   $0x802bc5
  801f80:	e8 b6 e2 ff ff       	call   80023b <_panic>
	e = &envs[ENVX(envid)];
  801f85:	89 f3                	mov    %esi,%ebx
  801f87:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f8d:	69 db d4 00 00 00    	imul   $0xd4,%ebx,%ebx
  801f93:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801f99:	eb 05                	jmp    801fa0 <wait+0x3d>
		sys_yield();
  801f9b:	e8 dd ec ff ff       	call   800c7d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801fa0:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
  801fa6:	39 c6                	cmp    %eax,%esi
  801fa8:	75 0a                	jne    801fb4 <wait+0x51>
  801faa:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	75 e7                	jne    801f9b <wait+0x38>
		sys_yield();
}
  801fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    

00801fc5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fcb:	68 d0 2b 80 00       	push   $0x802bd0
  801fd0:	ff 75 0c             	pushl  0xc(%ebp)
  801fd3:	e8 c1 e8 ff ff       	call   800899 <strcpy>
	return 0;
}
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	57                   	push   %edi
  801fe3:	56                   	push   %esi
  801fe4:	53                   	push   %ebx
  801fe5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801feb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff6:	eb 2d                	jmp    802025 <devcons_write+0x46>
		m = n - tot;
  801ff8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ffb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ffd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802000:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802005:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802008:	83 ec 04             	sub    $0x4,%esp
  80200b:	53                   	push   %ebx
  80200c:	03 45 0c             	add    0xc(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	57                   	push   %edi
  802011:	e8 15 ea ff ff       	call   800a2b <memmove>
		sys_cputs(buf, m);
  802016:	83 c4 08             	add    $0x8,%esp
  802019:	53                   	push   %ebx
  80201a:	57                   	push   %edi
  80201b:	e8 c0 eb ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802020:	01 de                	add    %ebx,%esi
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	89 f0                	mov    %esi,%eax
  802027:	3b 75 10             	cmp    0x10(%ebp),%esi
  80202a:	72 cc                	jb     801ff8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80202c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 08             	sub    $0x8,%esp
  80203a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80203f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802043:	74 2a                	je     80206f <devcons_read+0x3b>
  802045:	eb 05                	jmp    80204c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802047:	e8 31 ec ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80204c:	e8 ad eb ff ff       	call   800bfe <sys_cgetc>
  802051:	85 c0                	test   %eax,%eax
  802053:	74 f2                	je     802047 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802055:	85 c0                	test   %eax,%eax
  802057:	78 16                	js     80206f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802059:	83 f8 04             	cmp    $0x4,%eax
  80205c:	74 0c                	je     80206a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80205e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802061:	88 02                	mov    %al,(%edx)
	return 1;
  802063:	b8 01 00 00 00       	mov    $0x1,%eax
  802068:	eb 05                	jmp    80206f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80206f:	c9                   	leave  
  802070:	c3                   	ret    

00802071 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802077:	8b 45 08             	mov    0x8(%ebp),%eax
  80207a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80207d:	6a 01                	push   $0x1
  80207f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802082:	50                   	push   %eax
  802083:	e8 58 eb ff ff       	call   800be0 <sys_cputs>
}
  802088:	83 c4 10             	add    $0x10,%esp
  80208b:	c9                   	leave  
  80208c:	c3                   	ret    

0080208d <getchar>:

int
getchar(void)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802093:	6a 01                	push   $0x1
  802095:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802098:	50                   	push   %eax
  802099:	6a 00                	push   $0x0
  80209b:	e8 26 f6 ff ff       	call   8016c6 <read>
	if (r < 0)
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 0f                	js     8020b6 <getchar+0x29>
		return r;
	if (r < 1)
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	7e 06                	jle    8020b1 <getchar+0x24>
		return -E_EOF;
	return c;
  8020ab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020af:	eb 05                	jmp    8020b6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020b1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020b6:	c9                   	leave  
  8020b7:	c3                   	ret    

008020b8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c1:	50                   	push   %eax
  8020c2:	ff 75 08             	pushl  0x8(%ebp)
  8020c5:	e8 93 f3 ff ff       	call   80145d <fd_lookup>
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 11                	js     8020e2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020da:	39 10                	cmp    %edx,(%eax)
  8020dc:	0f 94 c0             	sete   %al
  8020df:	0f b6 c0             	movzbl %al,%eax
}
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    

008020e4 <opencons>:

int
opencons(void)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ed:	50                   	push   %eax
  8020ee:	e8 1b f3 ff ff       	call   80140e <fd_alloc>
  8020f3:	83 c4 10             	add    $0x10,%esp
		return r;
  8020f6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	78 3e                	js     80213a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020fc:	83 ec 04             	sub    $0x4,%esp
  8020ff:	68 07 04 00 00       	push   $0x407
  802104:	ff 75 f4             	pushl  -0xc(%ebp)
  802107:	6a 00                	push   $0x0
  802109:	e8 8e eb ff ff       	call   800c9c <sys_page_alloc>
  80210e:	83 c4 10             	add    $0x10,%esp
		return r;
  802111:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802113:	85 c0                	test   %eax,%eax
  802115:	78 23                	js     80213a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802117:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80211d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802120:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802122:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802125:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80212c:	83 ec 0c             	sub    $0xc,%esp
  80212f:	50                   	push   %eax
  802130:	e8 b2 f2 ff ff       	call   8013e7 <fd2num>
  802135:	89 c2                	mov    %eax,%edx
  802137:	83 c4 10             	add    $0x10,%esp
}
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802144:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80214b:	75 2a                	jne    802177 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80214d:	83 ec 04             	sub    $0x4,%esp
  802150:	6a 07                	push   $0x7
  802152:	68 00 f0 bf ee       	push   $0xeebff000
  802157:	6a 00                	push   $0x0
  802159:	e8 3e eb ff ff       	call   800c9c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	85 c0                	test   %eax,%eax
  802163:	79 12                	jns    802177 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802165:	50                   	push   %eax
  802166:	68 d2 2a 80 00       	push   $0x802ad2
  80216b:	6a 23                	push   $0x23
  80216d:	68 dc 2b 80 00       	push   $0x802bdc
  802172:	e8 c4 e0 ff ff       	call   80023b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802177:	8b 45 08             	mov    0x8(%ebp),%eax
  80217a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80217f:	83 ec 08             	sub    $0x8,%esp
  802182:	68 a9 21 80 00       	push   $0x8021a9
  802187:	6a 00                	push   $0x0
  802189:	e8 59 ec ff ff       	call   800de7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	85 c0                	test   %eax,%eax
  802193:	79 12                	jns    8021a7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802195:	50                   	push   %eax
  802196:	68 d2 2a 80 00       	push   $0x802ad2
  80219b:	6a 2c                	push   $0x2c
  80219d:	68 dc 2b 80 00       	push   $0x802bdc
  8021a2:	e8 94 e0 ff ff       	call   80023b <_panic>
	}
}
  8021a7:	c9                   	leave  
  8021a8:	c3                   	ret    

008021a9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021a9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021aa:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021af:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021b1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021b4:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021b8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021bd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8021c1:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8021c3:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8021c6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8021c7:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8021ca:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8021cb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021cc:	c3                   	ret    

008021cd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021cd:	55                   	push   %ebp
  8021ce:	89 e5                	mov    %esp,%ebp
  8021d0:	56                   	push   %esi
  8021d1:	53                   	push   %ebx
  8021d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8021d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	75 12                	jne    8021f1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8021df:	83 ec 0c             	sub    $0xc,%esp
  8021e2:	68 00 00 c0 ee       	push   $0xeec00000
  8021e7:	e8 60 ec ff ff       	call   800e4c <sys_ipc_recv>
  8021ec:	83 c4 10             	add    $0x10,%esp
  8021ef:	eb 0c                	jmp    8021fd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8021f1:	83 ec 0c             	sub    $0xc,%esp
  8021f4:	50                   	push   %eax
  8021f5:	e8 52 ec ff ff       	call   800e4c <sys_ipc_recv>
  8021fa:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8021fd:	85 f6                	test   %esi,%esi
  8021ff:	0f 95 c1             	setne  %cl
  802202:	85 db                	test   %ebx,%ebx
  802204:	0f 95 c2             	setne  %dl
  802207:	84 d1                	test   %dl,%cl
  802209:	74 09                	je     802214 <ipc_recv+0x47>
  80220b:	89 c2                	mov    %eax,%edx
  80220d:	c1 ea 1f             	shr    $0x1f,%edx
  802210:	84 d2                	test   %dl,%dl
  802212:	75 2d                	jne    802241 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802214:	85 f6                	test   %esi,%esi
  802216:	74 0d                	je     802225 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802218:	a1 20 44 80 00       	mov    0x804420,%eax
  80221d:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802223:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802225:	85 db                	test   %ebx,%ebx
  802227:	74 0d                	je     802236 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802229:	a1 20 44 80 00       	mov    0x804420,%eax
  80222e:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802234:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802236:	a1 20 44 80 00       	mov    0x804420,%eax
  80223b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802241:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    

00802248 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	57                   	push   %edi
  80224c:	56                   	push   %esi
  80224d:	53                   	push   %ebx
  80224e:	83 ec 0c             	sub    $0xc,%esp
  802251:	8b 7d 08             	mov    0x8(%ebp),%edi
  802254:	8b 75 0c             	mov    0xc(%ebp),%esi
  802257:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80225a:	85 db                	test   %ebx,%ebx
  80225c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802261:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802264:	ff 75 14             	pushl  0x14(%ebp)
  802267:	53                   	push   %ebx
  802268:	56                   	push   %esi
  802269:	57                   	push   %edi
  80226a:	e8 ba eb ff ff       	call   800e29 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80226f:	89 c2                	mov    %eax,%edx
  802271:	c1 ea 1f             	shr    $0x1f,%edx
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	84 d2                	test   %dl,%dl
  802279:	74 17                	je     802292 <ipc_send+0x4a>
  80227b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80227e:	74 12                	je     802292 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802280:	50                   	push   %eax
  802281:	68 ea 2b 80 00       	push   $0x802bea
  802286:	6a 47                	push   $0x47
  802288:	68 f8 2b 80 00       	push   $0x802bf8
  80228d:	e8 a9 df ff ff       	call   80023b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802292:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802295:	75 07                	jne    80229e <ipc_send+0x56>
			sys_yield();
  802297:	e8 e1 e9 ff ff       	call   800c7d <sys_yield>
  80229c:	eb c6                	jmp    802264 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	75 c2                	jne    802264 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8022a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a5:	5b                   	pop    %ebx
  8022a6:	5e                   	pop    %esi
  8022a7:	5f                   	pop    %edi
  8022a8:	5d                   	pop    %ebp
  8022a9:	c3                   	ret    

008022aa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022b0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022b5:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8022bb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022c1:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8022c7:	39 ca                	cmp    %ecx,%edx
  8022c9:	75 13                	jne    8022de <ipc_find_env+0x34>
			return envs[i].env_id;
  8022cb:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8022d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022d6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8022dc:	eb 0f                	jmp    8022ed <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022de:	83 c0 01             	add    $0x1,%eax
  8022e1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022e6:	75 cd                	jne    8022b5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ed:	5d                   	pop    %ebp
  8022ee:	c3                   	ret    

008022ef <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	c1 e8 16             	shr    $0x16,%eax
  8022fa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802301:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802306:	f6 c1 01             	test   $0x1,%cl
  802309:	74 1d                	je     802328 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80230b:	c1 ea 0c             	shr    $0xc,%edx
  80230e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802315:	f6 c2 01             	test   $0x1,%dl
  802318:	74 0e                	je     802328 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80231a:	c1 ea 0c             	shr    $0xc,%edx
  80231d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802324:	ef 
  802325:	0f b7 c0             	movzwl %ax,%eax
}
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80233b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80233f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 f6                	test   %esi,%esi
  802349:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80234d:	89 ca                	mov    %ecx,%edx
  80234f:	89 f8                	mov    %edi,%eax
  802351:	75 3d                	jne    802390 <__udivdi3+0x60>
  802353:	39 cf                	cmp    %ecx,%edi
  802355:	0f 87 c5 00 00 00    	ja     802420 <__udivdi3+0xf0>
  80235b:	85 ff                	test   %edi,%edi
  80235d:	89 fd                	mov    %edi,%ebp
  80235f:	75 0b                	jne    80236c <__udivdi3+0x3c>
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
  802366:	31 d2                	xor    %edx,%edx
  802368:	f7 f7                	div    %edi
  80236a:	89 c5                	mov    %eax,%ebp
  80236c:	89 c8                	mov    %ecx,%eax
  80236e:	31 d2                	xor    %edx,%edx
  802370:	f7 f5                	div    %ebp
  802372:	89 c1                	mov    %eax,%ecx
  802374:	89 d8                	mov    %ebx,%eax
  802376:	89 cf                	mov    %ecx,%edi
  802378:	f7 f5                	div    %ebp
  80237a:	89 c3                	mov    %eax,%ebx
  80237c:	89 d8                	mov    %ebx,%eax
  80237e:	89 fa                	mov    %edi,%edx
  802380:	83 c4 1c             	add    $0x1c,%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5f                   	pop    %edi
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    
  802388:	90                   	nop
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	39 ce                	cmp    %ecx,%esi
  802392:	77 74                	ja     802408 <__udivdi3+0xd8>
  802394:	0f bd fe             	bsr    %esi,%edi
  802397:	83 f7 1f             	xor    $0x1f,%edi
  80239a:	0f 84 98 00 00 00    	je     802438 <__udivdi3+0x108>
  8023a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023a5:	89 f9                	mov    %edi,%ecx
  8023a7:	89 c5                	mov    %eax,%ebp
  8023a9:	29 fb                	sub    %edi,%ebx
  8023ab:	d3 e6                	shl    %cl,%esi
  8023ad:	89 d9                	mov    %ebx,%ecx
  8023af:	d3 ed                	shr    %cl,%ebp
  8023b1:	89 f9                	mov    %edi,%ecx
  8023b3:	d3 e0                	shl    %cl,%eax
  8023b5:	09 ee                	or     %ebp,%esi
  8023b7:	89 d9                	mov    %ebx,%ecx
  8023b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bd:	89 d5                	mov    %edx,%ebp
  8023bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023c3:	d3 ed                	shr    %cl,%ebp
  8023c5:	89 f9                	mov    %edi,%ecx
  8023c7:	d3 e2                	shl    %cl,%edx
  8023c9:	89 d9                	mov    %ebx,%ecx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	09 c2                	or     %eax,%edx
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	89 ea                	mov    %ebp,%edx
  8023d3:	f7 f6                	div    %esi
  8023d5:	89 d5                	mov    %edx,%ebp
  8023d7:	89 c3                	mov    %eax,%ebx
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)
  8023dd:	39 d5                	cmp    %edx,%ebp
  8023df:	72 10                	jb     8023f1 <__udivdi3+0xc1>
  8023e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	d3 e6                	shl    %cl,%esi
  8023e9:	39 c6                	cmp    %eax,%esi
  8023eb:	73 07                	jae    8023f4 <__udivdi3+0xc4>
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	75 03                	jne    8023f4 <__udivdi3+0xc4>
  8023f1:	83 eb 01             	sub    $0x1,%ebx
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 d8                	mov    %ebx,%eax
  8023f8:	89 fa                	mov    %edi,%edx
  8023fa:	83 c4 1c             	add    $0x1c,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5f                   	pop    %edi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    
  802402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802408:	31 ff                	xor    %edi,%edi
  80240a:	31 db                	xor    %ebx,%ebx
  80240c:	89 d8                	mov    %ebx,%eax
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 1c             	add    $0x1c,%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	90                   	nop
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	89 d8                	mov    %ebx,%eax
  802422:	f7 f7                	div    %edi
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 c3                	mov    %eax,%ebx
  802428:	89 d8                	mov    %ebx,%eax
  80242a:	89 fa                	mov    %edi,%edx
  80242c:	83 c4 1c             	add    $0x1c,%esp
  80242f:	5b                   	pop    %ebx
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	39 ce                	cmp    %ecx,%esi
  80243a:	72 0c                	jb     802448 <__udivdi3+0x118>
  80243c:	31 db                	xor    %ebx,%ebx
  80243e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802442:	0f 87 34 ff ff ff    	ja     80237c <__udivdi3+0x4c>
  802448:	bb 01 00 00 00       	mov    $0x1,%ebx
  80244d:	e9 2a ff ff ff       	jmp    80237c <__udivdi3+0x4c>
  802452:	66 90                	xchg   %ax,%ax
  802454:	66 90                	xchg   %ax,%ax
  802456:	66 90                	xchg   %ax,%ax
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80246b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80246f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802477:	85 d2                	test   %edx,%edx
  802479:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 f3                	mov    %esi,%ebx
  802483:	89 3c 24             	mov    %edi,(%esp)
  802486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248a:	75 1c                	jne    8024a8 <__umoddi3+0x48>
  80248c:	39 f7                	cmp    %esi,%edi
  80248e:	76 50                	jbe    8024e0 <__umoddi3+0x80>
  802490:	89 c8                	mov    %ecx,%eax
  802492:	89 f2                	mov    %esi,%edx
  802494:	f7 f7                	div    %edi
  802496:	89 d0                	mov    %edx,%eax
  802498:	31 d2                	xor    %edx,%edx
  80249a:	83 c4 1c             	add    $0x1c,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5f                   	pop    %edi
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    
  8024a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a8:	39 f2                	cmp    %esi,%edx
  8024aa:	89 d0                	mov    %edx,%eax
  8024ac:	77 52                	ja     802500 <__umoddi3+0xa0>
  8024ae:	0f bd ea             	bsr    %edx,%ebp
  8024b1:	83 f5 1f             	xor    $0x1f,%ebp
  8024b4:	75 5a                	jne    802510 <__umoddi3+0xb0>
  8024b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ba:	0f 82 e0 00 00 00    	jb     8025a0 <__umoddi3+0x140>
  8024c0:	39 0c 24             	cmp    %ecx,(%esp)
  8024c3:	0f 86 d7 00 00 00    	jbe    8025a0 <__umoddi3+0x140>
  8024c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024d1:	83 c4 1c             	add    $0x1c,%esp
  8024d4:	5b                   	pop    %ebx
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	85 ff                	test   %edi,%edi
  8024e2:	89 fd                	mov    %edi,%ebp
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f7                	div    %edi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	89 f0                	mov    %esi,%eax
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	f7 f5                	div    %ebp
  8024f7:	89 c8                	mov    %ecx,%eax
  8024f9:	f7 f5                	div    %ebp
  8024fb:	89 d0                	mov    %edx,%eax
  8024fd:	eb 99                	jmp    802498 <__umoddi3+0x38>
  8024ff:	90                   	nop
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 f2                	mov    %esi,%edx
  802504:	83 c4 1c             	add    $0x1c,%esp
  802507:	5b                   	pop    %ebx
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	8b 34 24             	mov    (%esp),%esi
  802513:	bf 20 00 00 00       	mov    $0x20,%edi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	29 ef                	sub    %ebp,%edi
  80251c:	d3 e0                	shl    %cl,%eax
  80251e:	89 f9                	mov    %edi,%ecx
  802520:	89 f2                	mov    %esi,%edx
  802522:	d3 ea                	shr    %cl,%edx
  802524:	89 e9                	mov    %ebp,%ecx
  802526:	09 c2                	or     %eax,%edx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 14 24             	mov    %edx,(%esp)
  80252d:	89 f2                	mov    %esi,%edx
  80252f:	d3 e2                	shl    %cl,%edx
  802531:	89 f9                	mov    %edi,%ecx
  802533:	89 54 24 04          	mov    %edx,0x4(%esp)
  802537:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80253b:	d3 e8                	shr    %cl,%eax
  80253d:	89 e9                	mov    %ebp,%ecx
  80253f:	89 c6                	mov    %eax,%esi
  802541:	d3 e3                	shl    %cl,%ebx
  802543:	89 f9                	mov    %edi,%ecx
  802545:	89 d0                	mov    %edx,%eax
  802547:	d3 e8                	shr    %cl,%eax
  802549:	89 e9                	mov    %ebp,%ecx
  80254b:	09 d8                	or     %ebx,%eax
  80254d:	89 d3                	mov    %edx,%ebx
  80254f:	89 f2                	mov    %esi,%edx
  802551:	f7 34 24             	divl   (%esp)
  802554:	89 d6                	mov    %edx,%esi
  802556:	d3 e3                	shl    %cl,%ebx
  802558:	f7 64 24 04          	mull   0x4(%esp)
  80255c:	39 d6                	cmp    %edx,%esi
  80255e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802562:	89 d1                	mov    %edx,%ecx
  802564:	89 c3                	mov    %eax,%ebx
  802566:	72 08                	jb     802570 <__umoddi3+0x110>
  802568:	75 11                	jne    80257b <__umoddi3+0x11b>
  80256a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80256e:	73 0b                	jae    80257b <__umoddi3+0x11b>
  802570:	2b 44 24 04          	sub    0x4(%esp),%eax
  802574:	1b 14 24             	sbb    (%esp),%edx
  802577:	89 d1                	mov    %edx,%ecx
  802579:	89 c3                	mov    %eax,%ebx
  80257b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80257f:	29 da                	sub    %ebx,%edx
  802581:	19 ce                	sbb    %ecx,%esi
  802583:	89 f9                	mov    %edi,%ecx
  802585:	89 f0                	mov    %esi,%eax
  802587:	d3 e0                	shl    %cl,%eax
  802589:	89 e9                	mov    %ebp,%ecx
  80258b:	d3 ea                	shr    %cl,%edx
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	d3 ee                	shr    %cl,%esi
  802591:	09 d0                	or     %edx,%eax
  802593:	89 f2                	mov    %esi,%edx
  802595:	83 c4 1c             	add    $0x1c,%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5f                   	pop    %edi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	29 f9                	sub    %edi,%ecx
  8025a2:	19 d6                	sbb    %edx,%esi
  8025a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025ac:	e9 18 ff ff ff       	jmp    8024c9 <__umoddi3+0x69>
