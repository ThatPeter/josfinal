
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
  80003e:	68 40 26 80 00       	push   $0x802640
  800043:	e8 94 1b 00 00       	call   801bdc <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 45 26 80 00       	push   $0x802645
  800057:	6a 0c                	push   $0xc
  800059:	68 53 26 80 00       	push   $0x802653
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 46 18 00 00       	call   8018b4 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 5b 17 00 00       	call   8017dc <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 68 26 80 00       	push   $0x802668
  800090:	6a 0f                	push   $0xf
  800092:	68 53 26 80 00       	push   $0x802653
  800097:	e8 9f 01 00 00       	call   80023b <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 22 0f 00 00       	call   800fc3 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 72 26 80 00       	push   $0x802672
  8000ad:	6a 12                	push   $0x12
  8000af:	68 53 26 80 00       	push   $0x802653
  8000b4:	e8 82 01 00 00       	call   80023b <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 e8 17 00 00       	call   8018b4 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 b0 26 80 00 	movl   $0x8026b0,(%esp)
  8000d3:	e8 3c 02 00 00       	call   800314 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 f1 16 00 00       	call   8017dc <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 f4 26 80 00       	push   $0x8026f4
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 53 26 80 00       	push   $0x802653
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
  800125:	68 20 27 80 00       	push   $0x802720
  80012a:	6a 19                	push   $0x19
  80012c:	68 53 26 80 00       	push   $0x802653
  800131:	e8 05 01 00 00       	call   80023b <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 7b 26 80 00       	push   $0x80267b
  80013e:	e8 d1 01 00 00       	call   800314 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 66 17 00 00       	call   8018b4 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 b6 14 00 00       	call   80160c <close>
		exit();
  800156:	e8 c6 00 00 00       	call   800221 <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 7e 1e 00 00       	call   801fe5 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 62 16 00 00       	call   8017dc <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 58 27 80 00       	push   $0x802758
  80018b:	6a 21                	push   $0x21
  80018d:	68 53 26 80 00       	push   $0x802653
  800192:	e8 a4 00 00 00       	call   80023b <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 94 26 80 00       	push   $0x802694
  80019f:	e8 70 01 00 00       	call   800314 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 60 14 00 00       	call   80160c <close>
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
  8001cd:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8001d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d8:	a3 20 44 80 00       	mov    %eax,0x804420
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  800227:	e8 0b 14 00 00       	call   801637 <close_all>
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
  800259:	68 88 27 80 00       	push   $0x802788
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 66 2b 80 00 	movl   $0x802b66,(%esp)
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
  800377:	e8 34 20 00 00       	call   8023b0 <__udivdi3>
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
  8003ba:	e8 21 21 00 00       	call   8024e0 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 ab 27 80 00 	movsbl 0x8027ab(%eax),%eax
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
  8004be:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
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
  800582:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800589:	85 d2                	test   %edx,%edx
  80058b:	75 18                	jne    8005a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058d:	50                   	push   %eax
  80058e:	68 c3 27 80 00       	push   $0x8027c3
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
  8005a6:	68 d1 2c 80 00       	push   $0x802cd1
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
  8005ca:	b8 bc 27 80 00       	mov    $0x8027bc,%eax
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
  800c45:	68 9f 2a 80 00       	push   $0x802a9f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 bc 2a 80 00       	push   $0x802abc
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
  800cc6:	68 9f 2a 80 00       	push   $0x802a9f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 bc 2a 80 00       	push   $0x802abc
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
  800d08:	68 9f 2a 80 00       	push   $0x802a9f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 bc 2a 80 00       	push   $0x802abc
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
  800d4a:	68 9f 2a 80 00       	push   $0x802a9f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 bc 2a 80 00       	push   $0x802abc
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
  800d8c:	68 9f 2a 80 00       	push   $0x802a9f
  800d91:	6a 23                	push   $0x23
  800d93:	68 bc 2a 80 00       	push   $0x802abc
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
  800dce:	68 9f 2a 80 00       	push   $0x802a9f
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 bc 2a 80 00       	push   $0x802abc
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
  800e10:	68 9f 2a 80 00       	push   $0x802a9f
  800e15:	6a 23                	push   $0x23
  800e17:	68 bc 2a 80 00       	push   $0x802abc
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
  800e74:	68 9f 2a 80 00       	push   $0x802a9f
  800e79:	6a 23                	push   $0x23
  800e7b:	68 bc 2a 80 00       	push   $0x802abc
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
  800f13:	68 ca 2a 80 00       	push   $0x802aca
  800f18:	6a 1f                	push   $0x1f
  800f1a:	68 da 2a 80 00       	push   $0x802ada
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
  800f3d:	68 e5 2a 80 00       	push   $0x802ae5
  800f42:	6a 2d                	push   $0x2d
  800f44:	68 da 2a 80 00       	push   $0x802ada
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
  800f85:	68 e5 2a 80 00       	push   $0x802ae5
  800f8a:	6a 34                	push   $0x34
  800f8c:	68 da 2a 80 00       	push   $0x802ada
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
  800fad:	68 e5 2a 80 00       	push   $0x802ae5
  800fb2:	6a 38                	push   $0x38
  800fb4:	68 da 2a 80 00       	push   $0x802ada
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
  800fd1:	e8 ea 11 00 00       	call   8021c0 <set_pgfault_handler>
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
  800fea:	68 fe 2a 80 00       	push   $0x802afe
  800fef:	68 85 00 00 00       	push   $0x85
  800ff4:	68 da 2a 80 00       	push   $0x802ada
  800ff9:	e8 3d f2 ff ff       	call   80023b <_panic>
  800ffe:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801000:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801004:	75 24                	jne    80102a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801006:	e8 53 fc ff ff       	call   800c5e <sys_getenvid>
  80100b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801010:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8010a6:	68 0c 2b 80 00       	push   $0x802b0c
  8010ab:	6a 55                	push   $0x55
  8010ad:	68 da 2a 80 00       	push   $0x802ada
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
  8010eb:	68 0c 2b 80 00       	push   $0x802b0c
  8010f0:	6a 5c                	push   $0x5c
  8010f2:	68 da 2a 80 00       	push   $0x802ada
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
  801119:	68 0c 2b 80 00       	push   $0x802b0c
  80111e:	6a 60                	push   $0x60
  801120:	68 da 2a 80 00       	push   $0x802ada
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
  801143:	68 0c 2b 80 00       	push   $0x802b0c
  801148:	6a 65                	push   $0x65
  80114a:	68 da 2a 80 00       	push   $0x802ada
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
  80116b:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8011a8:	89 1d 24 44 80 00    	mov    %ebx,0x804424
	cprintf("in fork.c thread create. func: %x\n", func);
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	53                   	push   %ebx
  8011b2:	68 9c 2b 80 00       	push   $0x802b9c
  8011b7:	e8 58 f1 ff ff       	call   800314 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011bc:	c7 04 24 01 02 80 00 	movl   $0x800201,(%esp)
  8011c3:	e8 c5 fc ff ff       	call   800e8d <sys_thread_create>
  8011c8:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011ca:	83 c4 08             	add    $0x8,%esp
  8011cd:	53                   	push   %ebx
  8011ce:	68 9c 2b 80 00       	push   $0x802b9c
  8011d3:	e8 3c f1 ff ff       	call   800314 <cprintf>
	return id;
}
  8011d8:	89 f0                	mov    %esi,%eax
  8011da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8011e7:	ff 75 08             	pushl  0x8(%ebp)
  8011ea:	e8 be fc ff ff       	call   800ead <sys_thread_free>
}
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 cb fc ff ff       	call   800ecd <sys_thread_join>
}
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	8b 75 08             	mov    0x8(%ebp),%esi
  80120f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801212:	83 ec 04             	sub    $0x4,%esp
  801215:	6a 07                	push   $0x7
  801217:	6a 00                	push   $0x0
  801219:	56                   	push   %esi
  80121a:	e8 7d fa ff ff       	call   800c9c <sys_page_alloc>
	if (r < 0) {
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	79 15                	jns    80123b <queue_append+0x34>
		panic("%e\n", r);
  801226:	50                   	push   %eax
  801227:	68 98 2b 80 00       	push   $0x802b98
  80122c:	68 c4 00 00 00       	push   $0xc4
  801231:	68 da 2a 80 00       	push   $0x802ada
  801236:	e8 00 f0 ff ff       	call   80023b <_panic>
	}	
	wt->envid = envid;
  80123b:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	ff 33                	pushl  (%ebx)
  801246:	56                   	push   %esi
  801247:	68 c0 2b 80 00       	push   $0x802bc0
  80124c:	e8 c3 f0 ff ff       	call   800314 <cprintf>
	if (queue->first == NULL) {
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	83 3b 00             	cmpl   $0x0,(%ebx)
  801257:	75 29                	jne    801282 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801259:	83 ec 0c             	sub    $0xc,%esp
  80125c:	68 22 2b 80 00       	push   $0x802b22
  801261:	e8 ae f0 ff ff       	call   800314 <cprintf>
		queue->first = wt;
  801266:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80126c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801273:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80127a:	00 00 00 
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	eb 2b                	jmp    8012ad <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801282:	83 ec 0c             	sub    $0xc,%esp
  801285:	68 3c 2b 80 00       	push   $0x802b3c
  80128a:	e8 85 f0 ff ff       	call   800314 <cprintf>
		queue->last->next = wt;
  80128f:	8b 43 04             	mov    0x4(%ebx),%eax
  801292:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801299:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012a0:	00 00 00 
		queue->last = wt;
  8012a3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8012aa:	83 c4 10             	add    $0x10,%esp
	}
}
  8012ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 04             	sub    $0x4,%esp
  8012bb:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8012be:	8b 02                	mov    (%edx),%eax
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	75 17                	jne    8012db <queue_pop+0x27>
		panic("queue empty!\n");
  8012c4:	83 ec 04             	sub    $0x4,%esp
  8012c7:	68 5a 2b 80 00       	push   $0x802b5a
  8012cc:	68 d8 00 00 00       	push   $0xd8
  8012d1:	68 da 2a 80 00       	push   $0x802ada
  8012d6:	e8 60 ef ff ff       	call   80023b <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8012db:	8b 48 04             	mov    0x4(%eax),%ecx
  8012de:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8012e0:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	53                   	push   %ebx
  8012e6:	68 68 2b 80 00       	push   $0x802b68
  8012eb:	e8 24 f0 ff ff       	call   800314 <cprintf>
	return envid;
}
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 04             	sub    $0x4,%esp
  8012fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801301:	b8 01 00 00 00       	mov    $0x1,%eax
  801306:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801309:	85 c0                	test   %eax,%eax
  80130b:	74 5a                	je     801367 <mutex_lock+0x70>
  80130d:	8b 43 04             	mov    0x4(%ebx),%eax
  801310:	83 38 00             	cmpl   $0x0,(%eax)
  801313:	75 52                	jne    801367 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801315:	83 ec 0c             	sub    $0xc,%esp
  801318:	68 e8 2b 80 00       	push   $0x802be8
  80131d:	e8 f2 ef ff ff       	call   800314 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801322:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801325:	e8 34 f9 ff ff       	call   800c5e <sys_getenvid>
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	53                   	push   %ebx
  80132e:	50                   	push   %eax
  80132f:	e8 d3 fe ff ff       	call   801207 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801334:	e8 25 f9 ff ff       	call   800c5e <sys_getenvid>
  801339:	83 c4 08             	add    $0x8,%esp
  80133c:	6a 04                	push   $0x4
  80133e:	50                   	push   %eax
  80133f:	e8 1f fa ff ff       	call   800d63 <sys_env_set_status>
		if (r < 0) {
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	79 15                	jns    801360 <mutex_lock+0x69>
			panic("%e\n", r);
  80134b:	50                   	push   %eax
  80134c:	68 98 2b 80 00       	push   $0x802b98
  801351:	68 eb 00 00 00       	push   $0xeb
  801356:	68 da 2a 80 00       	push   $0x802ada
  80135b:	e8 db ee ff ff       	call   80023b <_panic>
		}
		sys_yield();
  801360:	e8 18 f9 ff ff       	call   800c7d <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801365:	eb 18                	jmp    80137f <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	68 08 2c 80 00       	push   $0x802c08
  80136f:	e8 a0 ef ff ff       	call   800314 <cprintf>
	mtx->owner = sys_getenvid();}
  801374:	e8 e5 f8 ff ff       	call   800c5e <sys_getenvid>
  801379:	89 43 08             	mov    %eax,0x8(%ebx)
  80137c:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80137f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801382:	c9                   	leave  
  801383:	c3                   	ret    

00801384 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	53                   	push   %ebx
  801388:	83 ec 04             	sub    $0x4,%esp
  80138b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801396:	8b 43 04             	mov    0x4(%ebx),%eax
  801399:	83 38 00             	cmpl   $0x0,(%eax)
  80139c:	74 33                	je     8013d1 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	50                   	push   %eax
  8013a2:	e8 0d ff ff ff       	call   8012b4 <queue_pop>
  8013a7:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	6a 02                	push   $0x2
  8013af:	50                   	push   %eax
  8013b0:	e8 ae f9 ff ff       	call   800d63 <sys_env_set_status>
		if (r < 0) {
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	79 15                	jns    8013d1 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8013bc:	50                   	push   %eax
  8013bd:	68 98 2b 80 00       	push   $0x802b98
  8013c2:	68 00 01 00 00       	push   $0x100
  8013c7:	68 da 2a 80 00       	push   $0x802ada
  8013cc:	e8 6a ee ff ff       	call   80023b <_panic>
		}
	}

	asm volatile("pause");
  8013d1:	f3 90                	pause  
	//sys_yield();
}
  8013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 04             	sub    $0x4,%esp
  8013df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8013e2:	e8 77 f8 ff ff       	call   800c5e <sys_getenvid>
  8013e7:	83 ec 04             	sub    $0x4,%esp
  8013ea:	6a 07                	push   $0x7
  8013ec:	53                   	push   %ebx
  8013ed:	50                   	push   %eax
  8013ee:	e8 a9 f8 ff ff       	call   800c9c <sys_page_alloc>
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	79 15                	jns    80140f <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8013fa:	50                   	push   %eax
  8013fb:	68 83 2b 80 00       	push   $0x802b83
  801400:	68 0d 01 00 00       	push   $0x10d
  801405:	68 da 2a 80 00       	push   $0x802ada
  80140a:	e8 2c ee ff ff       	call   80023b <_panic>
	}	
	mtx->locked = 0;
  80140f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801415:	8b 43 04             	mov    0x4(%ebx),%eax
  801418:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80141e:	8b 43 04             	mov    0x4(%ebx),%eax
  801421:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801428:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80142f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80143a:	e8 1f f8 ff ff       	call   800c5e <sys_getenvid>
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	ff 75 08             	pushl  0x8(%ebp)
  801445:	50                   	push   %eax
  801446:	e8 d6 f8 ff ff       	call   800d21 <sys_page_unmap>
	if (r < 0) {
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	79 15                	jns    801467 <mutex_destroy+0x33>
		panic("%e\n", r);
  801452:	50                   	push   %eax
  801453:	68 98 2b 80 00       	push   $0x802b98
  801458:	68 1a 01 00 00       	push   $0x11a
  80145d:	68 da 2a 80 00       	push   $0x802ada
  801462:	e8 d4 ed ff ff       	call   80023b <_panic>
	}
}
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146c:	8b 45 08             	mov    0x8(%ebp),%eax
  80146f:	05 00 00 00 30       	add    $0x30000000,%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
}
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	05 00 00 00 30       	add    $0x30000000,%eax
  801484:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801489:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801496:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	c1 ea 16             	shr    $0x16,%edx
  8014a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a7:	f6 c2 01             	test   $0x1,%dl
  8014aa:	74 11                	je     8014bd <fd_alloc+0x2d>
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	c1 ea 0c             	shr    $0xc,%edx
  8014b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b8:	f6 c2 01             	test   $0x1,%dl
  8014bb:	75 09                	jne    8014c6 <fd_alloc+0x36>
			*fd_store = fd;
  8014bd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c4:	eb 17                	jmp    8014dd <fd_alloc+0x4d>
  8014c6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014d0:	75 c9                	jne    80149b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014d2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e5:	83 f8 1f             	cmp    $0x1f,%eax
  8014e8:	77 36                	ja     801520 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014ea:	c1 e0 0c             	shl    $0xc,%eax
  8014ed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	c1 ea 16             	shr    $0x16,%edx
  8014f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fe:	f6 c2 01             	test   $0x1,%dl
  801501:	74 24                	je     801527 <fd_lookup+0x48>
  801503:	89 c2                	mov    %eax,%edx
  801505:	c1 ea 0c             	shr    $0xc,%edx
  801508:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150f:	f6 c2 01             	test   $0x1,%dl
  801512:	74 1a                	je     80152e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801514:	8b 55 0c             	mov    0xc(%ebp),%edx
  801517:	89 02                	mov    %eax,(%edx)
	return 0;
  801519:	b8 00 00 00 00       	mov    $0x0,%eax
  80151e:	eb 13                	jmp    801533 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801520:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801525:	eb 0c                	jmp    801533 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801527:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152c:	eb 05                	jmp    801533 <fd_lookup+0x54>
  80152e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	ba a8 2c 80 00       	mov    $0x802ca8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801543:	eb 13                	jmp    801558 <dev_lookup+0x23>
  801545:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801548:	39 08                	cmp    %ecx,(%eax)
  80154a:	75 0c                	jne    801558 <dev_lookup+0x23>
			*dev = devtab[i];
  80154c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
  801556:	eb 31                	jmp    801589 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801558:	8b 02                	mov    (%edx),%eax
  80155a:	85 c0                	test   %eax,%eax
  80155c:	75 e7                	jne    801545 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80155e:	a1 20 44 80 00       	mov    0x804420,%eax
  801563:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	51                   	push   %ecx
  80156d:	50                   	push   %eax
  80156e:	68 28 2c 80 00       	push   $0x802c28
  801573:	e8 9c ed ff ff       	call   800314 <cprintf>
	*dev = 0;
  801578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	83 ec 10             	sub    $0x10,%esp
  801593:	8b 75 08             	mov    0x8(%ebp),%esi
  801596:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015a3:	c1 e8 0c             	shr    $0xc,%eax
  8015a6:	50                   	push   %eax
  8015a7:	e8 33 ff ff ff       	call   8014df <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 05                	js     8015b8 <fd_close+0x2d>
	    || fd != fd2)
  8015b3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015b6:	74 0c                	je     8015c4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015b8:	84 db                	test   %bl,%bl
  8015ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bf:	0f 44 c2             	cmove  %edx,%eax
  8015c2:	eb 41                	jmp    801605 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	ff 36                	pushl  (%esi)
  8015cd:	e8 63 ff ff ff       	call   801535 <dev_lookup>
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 1a                	js     8015f5 <fd_close+0x6a>
		if (dev->dev_close)
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015e1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	74 0b                	je     8015f5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	56                   	push   %esi
  8015ee:	ff d0                	call   *%eax
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	56                   	push   %esi
  8015f9:	6a 00                	push   $0x0
  8015fb:	e8 21 f7 ff ff       	call   800d21 <sys_page_unmap>
	return r;
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	89 d8                	mov    %ebx,%eax
}
  801605:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    

0080160c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	ff 75 08             	pushl  0x8(%ebp)
  801619:	e8 c1 fe ff ff       	call   8014df <fd_lookup>
  80161e:	83 c4 08             	add    $0x8,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 10                	js     801635 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	6a 01                	push   $0x1
  80162a:	ff 75 f4             	pushl  -0xc(%ebp)
  80162d:	e8 59 ff ff ff       	call   80158b <fd_close>
  801632:	83 c4 10             	add    $0x10,%esp
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <close_all>:

void
close_all(void)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	53                   	push   %ebx
  801647:	e8 c0 ff ff ff       	call   80160c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80164c:	83 c3 01             	add    $0x1,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	83 fb 20             	cmp    $0x20,%ebx
  801655:	75 ec                	jne    801643 <close_all+0xc>
		close(i);
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	57                   	push   %edi
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	83 ec 2c             	sub    $0x2c,%esp
  801665:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801668:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	ff 75 08             	pushl  0x8(%ebp)
  80166f:	e8 6b fe ff ff       	call   8014df <fd_lookup>
  801674:	83 c4 08             	add    $0x8,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	0f 88 c1 00 00 00    	js     801740 <dup+0xe4>
		return r;
	close(newfdnum);
  80167f:	83 ec 0c             	sub    $0xc,%esp
  801682:	56                   	push   %esi
  801683:	e8 84 ff ff ff       	call   80160c <close>

	newfd = INDEX2FD(newfdnum);
  801688:	89 f3                	mov    %esi,%ebx
  80168a:	c1 e3 0c             	shl    $0xc,%ebx
  80168d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801693:	83 c4 04             	add    $0x4,%esp
  801696:	ff 75 e4             	pushl  -0x1c(%ebp)
  801699:	e8 db fd ff ff       	call   801479 <fd2data>
  80169e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016a0:	89 1c 24             	mov    %ebx,(%esp)
  8016a3:	e8 d1 fd ff ff       	call   801479 <fd2data>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ae:	89 f8                	mov    %edi,%eax
  8016b0:	c1 e8 16             	shr    $0x16,%eax
  8016b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016ba:	a8 01                	test   $0x1,%al
  8016bc:	74 37                	je     8016f5 <dup+0x99>
  8016be:	89 f8                	mov    %edi,%eax
  8016c0:	c1 e8 0c             	shr    $0xc,%eax
  8016c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ca:	f6 c2 01             	test   $0x1,%dl
  8016cd:	74 26                	je     8016f5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d6:	83 ec 0c             	sub    $0xc,%esp
  8016d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016de:	50                   	push   %eax
  8016df:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e2:	6a 00                	push   $0x0
  8016e4:	57                   	push   %edi
  8016e5:	6a 00                	push   $0x0
  8016e7:	e8 f3 f5 ff ff       	call   800cdf <sys_page_map>
  8016ec:	89 c7                	mov    %eax,%edi
  8016ee:	83 c4 20             	add    $0x20,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 2e                	js     801723 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f8:	89 d0                	mov    %edx,%eax
  8016fa:	c1 e8 0c             	shr    $0xc,%eax
  8016fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801704:	83 ec 0c             	sub    $0xc,%esp
  801707:	25 07 0e 00 00       	and    $0xe07,%eax
  80170c:	50                   	push   %eax
  80170d:	53                   	push   %ebx
  80170e:	6a 00                	push   $0x0
  801710:	52                   	push   %edx
  801711:	6a 00                	push   $0x0
  801713:	e8 c7 f5 ff ff       	call   800cdf <sys_page_map>
  801718:	89 c7                	mov    %eax,%edi
  80171a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80171d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171f:	85 ff                	test   %edi,%edi
  801721:	79 1d                	jns    801740 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	53                   	push   %ebx
  801727:	6a 00                	push   $0x0
  801729:	e8 f3 f5 ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80172e:	83 c4 08             	add    $0x8,%esp
  801731:	ff 75 d4             	pushl  -0x2c(%ebp)
  801734:	6a 00                	push   $0x0
  801736:	e8 e6 f5 ff ff       	call   800d21 <sys_page_unmap>
	return r;
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	89 f8                	mov    %edi,%eax
}
  801740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5f                   	pop    %edi
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    

00801748 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	83 ec 14             	sub    $0x14,%esp
  80174f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801752:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	53                   	push   %ebx
  801757:	e8 83 fd ff ff       	call   8014df <fd_lookup>
  80175c:	83 c4 08             	add    $0x8,%esp
  80175f:	89 c2                	mov    %eax,%edx
  801761:	85 c0                	test   %eax,%eax
  801763:	78 70                	js     8017d5 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801765:	83 ec 08             	sub    $0x8,%esp
  801768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176f:	ff 30                	pushl  (%eax)
  801771:	e8 bf fd ff ff       	call   801535 <dev_lookup>
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 4f                	js     8017cc <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801780:	8b 42 08             	mov    0x8(%edx),%eax
  801783:	83 e0 03             	and    $0x3,%eax
  801786:	83 f8 01             	cmp    $0x1,%eax
  801789:	75 24                	jne    8017af <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80178b:	a1 20 44 80 00       	mov    0x804420,%eax
  801790:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	53                   	push   %ebx
  80179a:	50                   	push   %eax
  80179b:	68 6c 2c 80 00       	push   $0x802c6c
  8017a0:	e8 6f eb ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ad:	eb 26                	jmp    8017d5 <read+0x8d>
	}
	if (!dev->dev_read)
  8017af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b2:	8b 40 08             	mov    0x8(%eax),%eax
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	74 17                	je     8017d0 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017b9:	83 ec 04             	sub    $0x4,%esp
  8017bc:	ff 75 10             	pushl  0x10(%ebp)
  8017bf:	ff 75 0c             	pushl  0xc(%ebp)
  8017c2:	52                   	push   %edx
  8017c3:	ff d0                	call   *%eax
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	eb 09                	jmp    8017d5 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cc:	89 c2                	mov    %eax,%edx
  8017ce:	eb 05                	jmp    8017d5 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017d5:	89 d0                	mov    %edx,%eax
  8017d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	57                   	push   %edi
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f0:	eb 21                	jmp    801813 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f2:	83 ec 04             	sub    $0x4,%esp
  8017f5:	89 f0                	mov    %esi,%eax
  8017f7:	29 d8                	sub    %ebx,%eax
  8017f9:	50                   	push   %eax
  8017fa:	89 d8                	mov    %ebx,%eax
  8017fc:	03 45 0c             	add    0xc(%ebp),%eax
  8017ff:	50                   	push   %eax
  801800:	57                   	push   %edi
  801801:	e8 42 ff ff ff       	call   801748 <read>
		if (m < 0)
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 10                	js     80181d <readn+0x41>
			return m;
		if (m == 0)
  80180d:	85 c0                	test   %eax,%eax
  80180f:	74 0a                	je     80181b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801811:	01 c3                	add    %eax,%ebx
  801813:	39 f3                	cmp    %esi,%ebx
  801815:	72 db                	jb     8017f2 <readn+0x16>
  801817:	89 d8                	mov    %ebx,%eax
  801819:	eb 02                	jmp    80181d <readn+0x41>
  80181b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80181d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5f                   	pop    %edi
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	53                   	push   %ebx
  801829:	83 ec 14             	sub    $0x14,%esp
  80182c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	53                   	push   %ebx
  801834:	e8 a6 fc ff ff       	call   8014df <fd_lookup>
  801839:	83 c4 08             	add    $0x8,%esp
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 6b                	js     8018ad <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801848:	50                   	push   %eax
  801849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184c:	ff 30                	pushl  (%eax)
  80184e:	e8 e2 fc ff ff       	call   801535 <dev_lookup>
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	85 c0                	test   %eax,%eax
  801858:	78 4a                	js     8018a4 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801861:	75 24                	jne    801887 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801863:	a1 20 44 80 00       	mov    0x804420,%eax
  801868:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80186e:	83 ec 04             	sub    $0x4,%esp
  801871:	53                   	push   %ebx
  801872:	50                   	push   %eax
  801873:	68 88 2c 80 00       	push   $0x802c88
  801878:	e8 97 ea ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801885:	eb 26                	jmp    8018ad <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801887:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188a:	8b 52 0c             	mov    0xc(%edx),%edx
  80188d:	85 d2                	test   %edx,%edx
  80188f:	74 17                	je     8018a8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	ff 75 10             	pushl  0x10(%ebp)
  801897:	ff 75 0c             	pushl  0xc(%ebp)
  80189a:	50                   	push   %eax
  80189b:	ff d2                	call   *%edx
  80189d:	89 c2                	mov    %eax,%edx
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	eb 09                	jmp    8018ad <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a4:	89 c2                	mov    %eax,%edx
  8018a6:	eb 05                	jmp    8018ad <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018ad:	89 d0                	mov    %edx,%eax
  8018af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018bd:	50                   	push   %eax
  8018be:	ff 75 08             	pushl  0x8(%ebp)
  8018c1:	e8 19 fc ff ff       	call   8014df <fd_lookup>
  8018c6:	83 c4 08             	add    $0x8,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 0e                	js     8018db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 14             	sub    $0x14,%esp
  8018e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ea:	50                   	push   %eax
  8018eb:	53                   	push   %ebx
  8018ec:	e8 ee fb ff ff       	call   8014df <fd_lookup>
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 68                	js     801962 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801904:	ff 30                	pushl  (%eax)
  801906:	e8 2a fc ff ff       	call   801535 <dev_lookup>
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 47                	js     801959 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801915:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801919:	75 24                	jne    80193f <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80191b:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801920:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801926:	83 ec 04             	sub    $0x4,%esp
  801929:	53                   	push   %ebx
  80192a:	50                   	push   %eax
  80192b:	68 48 2c 80 00       	push   $0x802c48
  801930:	e8 df e9 ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80193d:	eb 23                	jmp    801962 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80193f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801942:	8b 52 18             	mov    0x18(%edx),%edx
  801945:	85 d2                	test   %edx,%edx
  801947:	74 14                	je     80195d <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	ff 75 0c             	pushl  0xc(%ebp)
  80194f:	50                   	push   %eax
  801950:	ff d2                	call   *%edx
  801952:	89 c2                	mov    %eax,%edx
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	eb 09                	jmp    801962 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801959:	89 c2                	mov    %eax,%edx
  80195b:	eb 05                	jmp    801962 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80195d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801962:	89 d0                	mov    %edx,%eax
  801964:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	53                   	push   %ebx
  80196d:	83 ec 14             	sub    $0x14,%esp
  801970:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801973:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	ff 75 08             	pushl  0x8(%ebp)
  80197a:	e8 60 fb ff ff       	call   8014df <fd_lookup>
  80197f:	83 c4 08             	add    $0x8,%esp
  801982:	89 c2                	mov    %eax,%edx
  801984:	85 c0                	test   %eax,%eax
  801986:	78 58                	js     8019e0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198e:	50                   	push   %eax
  80198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801992:	ff 30                	pushl  (%eax)
  801994:	e8 9c fb ff ff       	call   801535 <dev_lookup>
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 37                	js     8019d7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a7:	74 32                	je     8019db <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019b3:	00 00 00 
	stat->st_isdir = 0;
  8019b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bd:	00 00 00 
	stat->st_dev = dev;
  8019c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	53                   	push   %ebx
  8019ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8019cd:	ff 50 14             	call   *0x14(%eax)
  8019d0:	89 c2                	mov    %eax,%edx
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	eb 09                	jmp    8019e0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d7:	89 c2                	mov    %eax,%edx
  8019d9:	eb 05                	jmp    8019e0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019e0:	89 d0                	mov    %edx,%eax
  8019e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	6a 00                	push   $0x0
  8019f1:	ff 75 08             	pushl  0x8(%ebp)
  8019f4:	e8 e3 01 00 00       	call   801bdc <open>
  8019f9:	89 c3                	mov    %eax,%ebx
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 1b                	js     801a1d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	ff 75 0c             	pushl  0xc(%ebp)
  801a08:	50                   	push   %eax
  801a09:	e8 5b ff ff ff       	call   801969 <fstat>
  801a0e:	89 c6                	mov    %eax,%esi
	close(fd);
  801a10:	89 1c 24             	mov    %ebx,(%esp)
  801a13:	e8 f4 fb ff ff       	call   80160c <close>
	return r;
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	89 f0                	mov    %esi,%eax
}
  801a1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	89 c6                	mov    %eax,%esi
  801a2b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a2d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a34:	75 12                	jne    801a48 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	6a 01                	push   $0x1
  801a3b:	e8 ec 08 00 00       	call   80232c <ipc_find_env>
  801a40:	a3 00 40 80 00       	mov    %eax,0x804000
  801a45:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a48:	6a 07                	push   $0x7
  801a4a:	68 00 50 80 00       	push   $0x805000
  801a4f:	56                   	push   %esi
  801a50:	ff 35 00 40 80 00    	pushl  0x804000
  801a56:	e8 6f 08 00 00       	call   8022ca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a5b:	83 c4 0c             	add    $0xc,%esp
  801a5e:	6a 00                	push   $0x0
  801a60:	53                   	push   %ebx
  801a61:	6a 00                	push   $0x0
  801a63:	e8 e7 07 00 00       	call   80224f <ipc_recv>
}
  801a68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a75:	8b 45 08             	mov    0x8(%ebp),%eax
  801a78:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a83:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a88:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8d:	b8 02 00 00 00       	mov    $0x2,%eax
  801a92:	e8 8d ff ff ff       	call   801a24 <fsipc>
}
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801aaa:	ba 00 00 00 00       	mov    $0x0,%edx
  801aaf:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab4:	e8 6b ff ff ff       	call   801a24 <fsipc>
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 04             	sub    $0x4,%esp
  801ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac8:	8b 40 0c             	mov    0xc(%eax),%eax
  801acb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad5:	b8 05 00 00 00       	mov    $0x5,%eax
  801ada:	e8 45 ff ff ff       	call   801a24 <fsipc>
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 2c                	js     801b0f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ae3:	83 ec 08             	sub    $0x8,%esp
  801ae6:	68 00 50 80 00       	push   $0x805000
  801aeb:	53                   	push   %ebx
  801aec:	e8 a8 ed ff ff       	call   800899 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801af1:	a1 80 50 80 00       	mov    0x805080,%eax
  801af6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801afc:	a1 84 50 80 00       	mov    0x805084,%eax
  801b01:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b20:	8b 52 0c             	mov    0xc(%edx),%edx
  801b23:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b29:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b2e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b33:	0f 47 c2             	cmova  %edx,%eax
  801b36:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b3b:	50                   	push   %eax
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	68 08 50 80 00       	push   $0x805008
  801b44:	e8 e2 ee ff ff       	call   800a2b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b49:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b53:	e8 cc fe ff ff       	call   801a24 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	56                   	push   %esi
  801b5e:	53                   	push   %ebx
  801b5f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	8b 40 0c             	mov    0xc(%eax),%eax
  801b68:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b6d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	b8 03 00 00 00       	mov    $0x3,%eax
  801b7d:	e8 a2 fe ff ff       	call   801a24 <fsipc>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	85 c0                	test   %eax,%eax
  801b86:	78 4b                	js     801bd3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b88:	39 c6                	cmp    %eax,%esi
  801b8a:	73 16                	jae    801ba2 <devfile_read+0x48>
  801b8c:	68 b8 2c 80 00       	push   $0x802cb8
  801b91:	68 bf 2c 80 00       	push   $0x802cbf
  801b96:	6a 7c                	push   $0x7c
  801b98:	68 d4 2c 80 00       	push   $0x802cd4
  801b9d:	e8 99 e6 ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  801ba2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba7:	7e 16                	jle    801bbf <devfile_read+0x65>
  801ba9:	68 df 2c 80 00       	push   $0x802cdf
  801bae:	68 bf 2c 80 00       	push   $0x802cbf
  801bb3:	6a 7d                	push   $0x7d
  801bb5:	68 d4 2c 80 00       	push   $0x802cd4
  801bba:	e8 7c e6 ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bbf:	83 ec 04             	sub    $0x4,%esp
  801bc2:	50                   	push   %eax
  801bc3:	68 00 50 80 00       	push   $0x805000
  801bc8:	ff 75 0c             	pushl  0xc(%ebp)
  801bcb:	e8 5b ee ff ff       	call   800a2b <memmove>
	return r;
  801bd0:	83 c4 10             	add    $0x10,%esp
}
  801bd3:	89 d8                	mov    %ebx,%eax
  801bd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5e                   	pop    %esi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    

00801bdc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 20             	sub    $0x20,%esp
  801be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801be6:	53                   	push   %ebx
  801be7:	e8 74 ec ff ff       	call   800860 <strlen>
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bf4:	7f 67                	jg     801c5d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfc:	50                   	push   %eax
  801bfd:	e8 8e f8 ff ff       	call   801490 <fd_alloc>
  801c02:	83 c4 10             	add    $0x10,%esp
		return r;
  801c05:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 57                	js     801c62 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c0b:	83 ec 08             	sub    $0x8,%esp
  801c0e:	53                   	push   %ebx
  801c0f:	68 00 50 80 00       	push   $0x805000
  801c14:	e8 80 ec ff ff       	call   800899 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c24:	b8 01 00 00 00       	mov    $0x1,%eax
  801c29:	e8 f6 fd ff ff       	call   801a24 <fsipc>
  801c2e:	89 c3                	mov    %eax,%ebx
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	85 c0                	test   %eax,%eax
  801c35:	79 14                	jns    801c4b <open+0x6f>
		fd_close(fd, 0);
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	6a 00                	push   $0x0
  801c3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3f:	e8 47 f9 ff ff       	call   80158b <fd_close>
		return r;
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	89 da                	mov    %ebx,%edx
  801c49:	eb 17                	jmp    801c62 <open+0x86>
	}

	return fd2num(fd);
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c51:	e8 13 f8 ff ff       	call   801469 <fd2num>
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	eb 05                	jmp    801c62 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c5d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c62:	89 d0                	mov    %edx,%eax
  801c64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c74:	b8 08 00 00 00       	mov    $0x8,%eax
  801c79:	e8 a6 fd ff ff       	call   801a24 <fsipc>
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	56                   	push   %esi
  801c84:	53                   	push   %ebx
  801c85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c88:	83 ec 0c             	sub    $0xc,%esp
  801c8b:	ff 75 08             	pushl  0x8(%ebp)
  801c8e:	e8 e6 f7 ff ff       	call   801479 <fd2data>
  801c93:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c95:	83 c4 08             	add    $0x8,%esp
  801c98:	68 eb 2c 80 00       	push   $0x802ceb
  801c9d:	53                   	push   %ebx
  801c9e:	e8 f6 eb ff ff       	call   800899 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ca3:	8b 46 04             	mov    0x4(%esi),%eax
  801ca6:	2b 06                	sub    (%esi),%eax
  801ca8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cb5:	00 00 00 
	stat->st_dev = &devpipe;
  801cb8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cbf:	30 80 00 
	return 0;
}
  801cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 0c             	sub    $0xc,%esp
  801cd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cd8:	53                   	push   %ebx
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 41 f0 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ce0:	89 1c 24             	mov    %ebx,(%esp)
  801ce3:	e8 91 f7 ff ff       	call   801479 <fd2data>
  801ce8:	83 c4 08             	add    $0x8,%esp
  801ceb:	50                   	push   %eax
  801cec:	6a 00                	push   $0x0
  801cee:	e8 2e f0 ff ff       	call   800d21 <sys_page_unmap>
}
  801cf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf6:	c9                   	leave  
  801cf7:	c3                   	ret    

00801cf8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	57                   	push   %edi
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 1c             	sub    $0x1c,%esp
  801d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d04:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d06:	a1 20 44 80 00       	mov    0x804420,%eax
  801d0b:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	ff 75 e0             	pushl  -0x20(%ebp)
  801d17:	e8 55 06 00 00       	call   802371 <pageref>
  801d1c:	89 c3                	mov    %eax,%ebx
  801d1e:	89 3c 24             	mov    %edi,(%esp)
  801d21:	e8 4b 06 00 00       	call   802371 <pageref>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	39 c3                	cmp    %eax,%ebx
  801d2b:	0f 94 c1             	sete   %cl
  801d2e:	0f b6 c9             	movzbl %cl,%ecx
  801d31:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d34:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801d3a:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801d40:	39 ce                	cmp    %ecx,%esi
  801d42:	74 1e                	je     801d62 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d44:	39 c3                	cmp    %eax,%ebx
  801d46:	75 be                	jne    801d06 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d48:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801d4e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d51:	50                   	push   %eax
  801d52:	56                   	push   %esi
  801d53:	68 f2 2c 80 00       	push   $0x802cf2
  801d58:	e8 b7 e5 ff ff       	call   800314 <cprintf>
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	eb a4                	jmp    801d06 <_pipeisclosed+0xe>
	}
}
  801d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	57                   	push   %edi
  801d71:	56                   	push   %esi
  801d72:	53                   	push   %ebx
  801d73:	83 ec 28             	sub    $0x28,%esp
  801d76:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d79:	56                   	push   %esi
  801d7a:	e8 fa f6 ff ff       	call   801479 <fd2data>
  801d7f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	bf 00 00 00 00       	mov    $0x0,%edi
  801d89:	eb 4b                	jmp    801dd6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d8b:	89 da                	mov    %ebx,%edx
  801d8d:	89 f0                	mov    %esi,%eax
  801d8f:	e8 64 ff ff ff       	call   801cf8 <_pipeisclosed>
  801d94:	85 c0                	test   %eax,%eax
  801d96:	75 48                	jne    801de0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d98:	e8 e0 ee ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d9d:	8b 43 04             	mov    0x4(%ebx),%eax
  801da0:	8b 0b                	mov    (%ebx),%ecx
  801da2:	8d 51 20             	lea    0x20(%ecx),%edx
  801da5:	39 d0                	cmp    %edx,%eax
  801da7:	73 e2                	jae    801d8b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dac:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801db0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801db3:	89 c2                	mov    %eax,%edx
  801db5:	c1 fa 1f             	sar    $0x1f,%edx
  801db8:	89 d1                	mov    %edx,%ecx
  801dba:	c1 e9 1b             	shr    $0x1b,%ecx
  801dbd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dc0:	83 e2 1f             	and    $0x1f,%edx
  801dc3:	29 ca                	sub    %ecx,%edx
  801dc5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dc9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dcd:	83 c0 01             	add    $0x1,%eax
  801dd0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd3:	83 c7 01             	add    $0x1,%edi
  801dd6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dd9:	75 c2                	jne    801d9d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ddb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dde:	eb 05                	jmp    801de5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    

00801ded <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	57                   	push   %edi
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	83 ec 18             	sub    $0x18,%esp
  801df6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801df9:	57                   	push   %edi
  801dfa:	e8 7a f6 ff ff       	call   801479 <fd2data>
  801dff:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e09:	eb 3d                	jmp    801e48 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e0b:	85 db                	test   %ebx,%ebx
  801e0d:	74 04                	je     801e13 <devpipe_read+0x26>
				return i;
  801e0f:	89 d8                	mov    %ebx,%eax
  801e11:	eb 44                	jmp    801e57 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	89 f8                	mov    %edi,%eax
  801e17:	e8 dc fe ff ff       	call   801cf8 <_pipeisclosed>
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	75 32                	jne    801e52 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e20:	e8 58 ee ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e25:	8b 06                	mov    (%esi),%eax
  801e27:	3b 46 04             	cmp    0x4(%esi),%eax
  801e2a:	74 df                	je     801e0b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e2c:	99                   	cltd   
  801e2d:	c1 ea 1b             	shr    $0x1b,%edx
  801e30:	01 d0                	add    %edx,%eax
  801e32:	83 e0 1f             	and    $0x1f,%eax
  801e35:	29 d0                	sub    %edx,%eax
  801e37:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e42:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e45:	83 c3 01             	add    $0x1,%ebx
  801e48:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e4b:	75 d8                	jne    801e25 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e50:	eb 05                	jmp    801e57 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	e8 20 f6 ff ff       	call   801490 <fd_alloc>
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	89 c2                	mov    %eax,%edx
  801e75:	85 c0                	test   %eax,%eax
  801e77:	0f 88 2c 01 00 00    	js     801fa9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7d:	83 ec 04             	sub    $0x4,%esp
  801e80:	68 07 04 00 00       	push   $0x407
  801e85:	ff 75 f4             	pushl  -0xc(%ebp)
  801e88:	6a 00                	push   $0x0
  801e8a:	e8 0d ee ff ff       	call   800c9c <sys_page_alloc>
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	89 c2                	mov    %eax,%edx
  801e94:	85 c0                	test   %eax,%eax
  801e96:	0f 88 0d 01 00 00    	js     801fa9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ea2:	50                   	push   %eax
  801ea3:	e8 e8 f5 ff ff       	call   801490 <fd_alloc>
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	0f 88 e2 00 00 00    	js     801f97 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	68 07 04 00 00       	push   $0x407
  801ebd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 d5 ed ff ff       	call   800c9c <sys_page_alloc>
  801ec7:	89 c3                	mov    %eax,%ebx
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	0f 88 c3 00 00 00    	js     801f97 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	ff 75 f4             	pushl  -0xc(%ebp)
  801eda:	e8 9a f5 ff ff       	call   801479 <fd2data>
  801edf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee1:	83 c4 0c             	add    $0xc,%esp
  801ee4:	68 07 04 00 00       	push   $0x407
  801ee9:	50                   	push   %eax
  801eea:	6a 00                	push   $0x0
  801eec:	e8 ab ed ff ff       	call   800c9c <sys_page_alloc>
  801ef1:	89 c3                	mov    %eax,%ebx
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	0f 88 89 00 00 00    	js     801f87 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efe:	83 ec 0c             	sub    $0xc,%esp
  801f01:	ff 75 f0             	pushl  -0x10(%ebp)
  801f04:	e8 70 f5 ff ff       	call   801479 <fd2data>
  801f09:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f10:	50                   	push   %eax
  801f11:	6a 00                	push   $0x0
  801f13:	56                   	push   %esi
  801f14:	6a 00                	push   $0x0
  801f16:	e8 c4 ed ff ff       	call   800cdf <sys_page_map>
  801f1b:	89 c3                	mov    %eax,%ebx
  801f1d:	83 c4 20             	add    $0x20,%esp
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 55                	js     801f79 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f24:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f42:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f47:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f4e:	83 ec 0c             	sub    $0xc,%esp
  801f51:	ff 75 f4             	pushl  -0xc(%ebp)
  801f54:	e8 10 f5 ff ff       	call   801469 <fd2num>
  801f59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f5c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f5e:	83 c4 04             	add    $0x4,%esp
  801f61:	ff 75 f0             	pushl  -0x10(%ebp)
  801f64:	e8 00 f5 ff ff       	call   801469 <fd2num>
  801f69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f6c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	ba 00 00 00 00       	mov    $0x0,%edx
  801f77:	eb 30                	jmp    801fa9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f79:	83 ec 08             	sub    $0x8,%esp
  801f7c:	56                   	push   %esi
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 9d ed ff ff       	call   800d21 <sys_page_unmap>
  801f84:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f87:	83 ec 08             	sub    $0x8,%esp
  801f8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 8d ed ff ff       	call   800d21 <sys_page_unmap>
  801f94:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f97:	83 ec 08             	sub    $0x8,%esp
  801f9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 7d ed ff ff       	call   800d21 <sys_page_unmap>
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fa9:	89 d0                	mov    %edx,%eax
  801fab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbb:	50                   	push   %eax
  801fbc:	ff 75 08             	pushl  0x8(%ebp)
  801fbf:	e8 1b f5 ff ff       	call   8014df <fd_lookup>
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 18                	js     801fe3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd1:	e8 a3 f4 ff ff       	call   801479 <fd2data>
	return _pipeisclosed(fd, p);
  801fd6:	89 c2                	mov    %eax,%edx
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	e8 18 fd ff ff       	call   801cf8 <_pipeisclosed>
  801fe0:	83 c4 10             	add    $0x10,%esp
}
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    

00801fe5 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801fed:	85 f6                	test   %esi,%esi
  801fef:	75 16                	jne    802007 <wait+0x22>
  801ff1:	68 0a 2d 80 00       	push   $0x802d0a
  801ff6:	68 bf 2c 80 00       	push   $0x802cbf
  801ffb:	6a 09                	push   $0x9
  801ffd:	68 15 2d 80 00       	push   $0x802d15
  802002:	e8 34 e2 ff ff       	call   80023b <_panic>
	e = &envs[ENVX(envid)];
  802007:	89 f3                	mov    %esi,%ebx
  802009:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80200f:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  802015:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80201b:	eb 05                	jmp    802022 <wait+0x3d>
		sys_yield();
  80201d:	e8 5b ec ff ff       	call   800c7d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802022:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
  802028:	39 c6                	cmp    %eax,%esi
  80202a:	75 0a                	jne    802036 <wait+0x51>
  80202c:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  802032:	85 c0                	test   %eax,%eax
  802034:	75 e7                	jne    80201d <wait+0x38>
		sys_yield();
}
  802036:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802039:	5b                   	pop    %ebx
  80203a:	5e                   	pop    %esi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    

00802047 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80204d:	68 20 2d 80 00       	push   $0x802d20
  802052:	ff 75 0c             	pushl  0xc(%ebp)
  802055:	e8 3f e8 ff ff       	call   800899 <strcpy>
	return 0;
}
  80205a:	b8 00 00 00 00       	mov    $0x0,%eax
  80205f:	c9                   	leave  
  802060:	c3                   	ret    

00802061 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	57                   	push   %edi
  802065:	56                   	push   %esi
  802066:	53                   	push   %ebx
  802067:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80206d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802072:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802078:	eb 2d                	jmp    8020a7 <devcons_write+0x46>
		m = n - tot;
  80207a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80207d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80207f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802082:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802087:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80208a:	83 ec 04             	sub    $0x4,%esp
  80208d:	53                   	push   %ebx
  80208e:	03 45 0c             	add    0xc(%ebp),%eax
  802091:	50                   	push   %eax
  802092:	57                   	push   %edi
  802093:	e8 93 e9 ff ff       	call   800a2b <memmove>
		sys_cputs(buf, m);
  802098:	83 c4 08             	add    $0x8,%esp
  80209b:	53                   	push   %ebx
  80209c:	57                   	push   %edi
  80209d:	e8 3e eb ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a2:	01 de                	add    %ebx,%esi
  8020a4:	83 c4 10             	add    $0x10,%esp
  8020a7:	89 f0                	mov    %esi,%eax
  8020a9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020ac:	72 cc                	jb     80207a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b1:	5b                   	pop    %ebx
  8020b2:	5e                   	pop    %esi
  8020b3:	5f                   	pop    %edi
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    

008020b6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 08             	sub    $0x8,%esp
  8020bc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c5:	74 2a                	je     8020f1 <devcons_read+0x3b>
  8020c7:	eb 05                	jmp    8020ce <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020c9:	e8 af eb ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020ce:	e8 2b eb ff ff       	call   800bfe <sys_cgetc>
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	74 f2                	je     8020c9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 16                	js     8020f1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020db:	83 f8 04             	cmp    $0x4,%eax
  8020de:	74 0c                	je     8020ec <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e3:	88 02                	mov    %al,(%edx)
	return 1;
  8020e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ea:	eb 05                	jmp    8020f1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020f1:	c9                   	leave  
  8020f2:	c3                   	ret    

008020f3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020ff:	6a 01                	push   $0x1
  802101:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802104:	50                   	push   %eax
  802105:	e8 d6 ea ff ff       	call   800be0 <sys_cputs>
}
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	c9                   	leave  
  80210e:	c3                   	ret    

0080210f <getchar>:

int
getchar(void)
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802115:	6a 01                	push   $0x1
  802117:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80211a:	50                   	push   %eax
  80211b:	6a 00                	push   $0x0
  80211d:	e8 26 f6 ff ff       	call   801748 <read>
	if (r < 0)
  802122:	83 c4 10             	add    $0x10,%esp
  802125:	85 c0                	test   %eax,%eax
  802127:	78 0f                	js     802138 <getchar+0x29>
		return r;
	if (r < 1)
  802129:	85 c0                	test   %eax,%eax
  80212b:	7e 06                	jle    802133 <getchar+0x24>
		return -E_EOF;
	return c;
  80212d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802131:	eb 05                	jmp    802138 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802133:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802143:	50                   	push   %eax
  802144:	ff 75 08             	pushl  0x8(%ebp)
  802147:	e8 93 f3 ff ff       	call   8014df <fd_lookup>
  80214c:	83 c4 10             	add    $0x10,%esp
  80214f:	85 c0                	test   %eax,%eax
  802151:	78 11                	js     802164 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802156:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80215c:	39 10                	cmp    %edx,(%eax)
  80215e:	0f 94 c0             	sete   %al
  802161:	0f b6 c0             	movzbl %al,%eax
}
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <opencons>:

int
opencons(void)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80216c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216f:	50                   	push   %eax
  802170:	e8 1b f3 ff ff       	call   801490 <fd_alloc>
  802175:	83 c4 10             	add    $0x10,%esp
		return r;
  802178:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217a:	85 c0                	test   %eax,%eax
  80217c:	78 3e                	js     8021bc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80217e:	83 ec 04             	sub    $0x4,%esp
  802181:	68 07 04 00 00       	push   $0x407
  802186:	ff 75 f4             	pushl  -0xc(%ebp)
  802189:	6a 00                	push   $0x0
  80218b:	e8 0c eb ff ff       	call   800c9c <sys_page_alloc>
  802190:	83 c4 10             	add    $0x10,%esp
		return r;
  802193:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802195:	85 c0                	test   %eax,%eax
  802197:	78 23                	js     8021bc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802199:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80219f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021ae:	83 ec 0c             	sub    $0xc,%esp
  8021b1:	50                   	push   %eax
  8021b2:	e8 b2 f2 ff ff       	call   801469 <fd2num>
  8021b7:	89 c2                	mov    %eax,%edx
  8021b9:	83 c4 10             	add    $0x10,%esp
}
  8021bc:	89 d0                	mov    %edx,%eax
  8021be:	c9                   	leave  
  8021bf:	c3                   	ret    

008021c0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021c6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021cd:	75 2a                	jne    8021f9 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8021cf:	83 ec 04             	sub    $0x4,%esp
  8021d2:	6a 07                	push   $0x7
  8021d4:	68 00 f0 bf ee       	push   $0xeebff000
  8021d9:	6a 00                	push   $0x0
  8021db:	e8 bc ea ff ff       	call   800c9c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	79 12                	jns    8021f9 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021e7:	50                   	push   %eax
  8021e8:	68 98 2b 80 00       	push   $0x802b98
  8021ed:	6a 23                	push   $0x23
  8021ef:	68 2c 2d 80 00       	push   $0x802d2c
  8021f4:	e8 42 e0 ff ff       	call   80023b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fc:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802201:	83 ec 08             	sub    $0x8,%esp
  802204:	68 2b 22 80 00       	push   $0x80222b
  802209:	6a 00                	push   $0x0
  80220b:	e8 d7 eb ff ff       	call   800de7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802210:	83 c4 10             	add    $0x10,%esp
  802213:	85 c0                	test   %eax,%eax
  802215:	79 12                	jns    802229 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802217:	50                   	push   %eax
  802218:	68 98 2b 80 00       	push   $0x802b98
  80221d:	6a 2c                	push   $0x2c
  80221f:	68 2c 2d 80 00       	push   $0x802d2c
  802224:	e8 12 e0 ff ff       	call   80023b <_panic>
	}
}
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80222b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80222c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802231:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802233:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802236:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80223a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80223f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802243:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802245:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802248:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802249:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80224c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80224d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80224e:	c3                   	ret    

0080224f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	8b 75 08             	mov    0x8(%ebp),%esi
  802257:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80225d:	85 c0                	test   %eax,%eax
  80225f:	75 12                	jne    802273 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802261:	83 ec 0c             	sub    $0xc,%esp
  802264:	68 00 00 c0 ee       	push   $0xeec00000
  802269:	e8 de eb ff ff       	call   800e4c <sys_ipc_recv>
  80226e:	83 c4 10             	add    $0x10,%esp
  802271:	eb 0c                	jmp    80227f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802273:	83 ec 0c             	sub    $0xc,%esp
  802276:	50                   	push   %eax
  802277:	e8 d0 eb ff ff       	call   800e4c <sys_ipc_recv>
  80227c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80227f:	85 f6                	test   %esi,%esi
  802281:	0f 95 c1             	setne  %cl
  802284:	85 db                	test   %ebx,%ebx
  802286:	0f 95 c2             	setne  %dl
  802289:	84 d1                	test   %dl,%cl
  80228b:	74 09                	je     802296 <ipc_recv+0x47>
  80228d:	89 c2                	mov    %eax,%edx
  80228f:	c1 ea 1f             	shr    $0x1f,%edx
  802292:	84 d2                	test   %dl,%dl
  802294:	75 2d                	jne    8022c3 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802296:	85 f6                	test   %esi,%esi
  802298:	74 0d                	je     8022a7 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80229a:	a1 20 44 80 00       	mov    0x804420,%eax
  80229f:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8022a5:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8022a7:	85 db                	test   %ebx,%ebx
  8022a9:	74 0d                	je     8022b8 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8022ab:	a1 20 44 80 00       	mov    0x804420,%eax
  8022b0:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8022b6:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8022b8:	a1 20 44 80 00       	mov    0x804420,%eax
  8022bd:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8022c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c6:	5b                   	pop    %ebx
  8022c7:	5e                   	pop    %esi
  8022c8:	5d                   	pop    %ebp
  8022c9:	c3                   	ret    

008022ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	57                   	push   %edi
  8022ce:	56                   	push   %esi
  8022cf:	53                   	push   %ebx
  8022d0:	83 ec 0c             	sub    $0xc,%esp
  8022d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8022dc:	85 db                	test   %ebx,%ebx
  8022de:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022e3:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022e6:	ff 75 14             	pushl  0x14(%ebp)
  8022e9:	53                   	push   %ebx
  8022ea:	56                   	push   %esi
  8022eb:	57                   	push   %edi
  8022ec:	e8 38 eb ff ff       	call   800e29 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	c1 ea 1f             	shr    $0x1f,%edx
  8022f6:	83 c4 10             	add    $0x10,%esp
  8022f9:	84 d2                	test   %dl,%dl
  8022fb:	74 17                	je     802314 <ipc_send+0x4a>
  8022fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802300:	74 12                	je     802314 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802302:	50                   	push   %eax
  802303:	68 3a 2d 80 00       	push   $0x802d3a
  802308:	6a 47                	push   $0x47
  80230a:	68 48 2d 80 00       	push   $0x802d48
  80230f:	e8 27 df ff ff       	call   80023b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802314:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802317:	75 07                	jne    802320 <ipc_send+0x56>
			sys_yield();
  802319:	e8 5f e9 ff ff       	call   800c7d <sys_yield>
  80231e:	eb c6                	jmp    8022e6 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802320:	85 c0                	test   %eax,%eax
  802322:	75 c2                	jne    8022e6 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802324:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5f                   	pop    %edi
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    

0080232c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802332:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802337:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80233d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802343:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802349:	39 ca                	cmp    %ecx,%edx
  80234b:	75 13                	jne    802360 <ipc_find_env+0x34>
			return envs[i].env_id;
  80234d:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802353:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802358:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80235e:	eb 0f                	jmp    80236f <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802360:	83 c0 01             	add    $0x1,%eax
  802363:	3d 00 04 00 00       	cmp    $0x400,%eax
  802368:	75 cd                	jne    802337 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80236a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80236f:	5d                   	pop    %ebp
  802370:	c3                   	ret    

00802371 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802371:	55                   	push   %ebp
  802372:	89 e5                	mov    %esp,%ebp
  802374:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802377:	89 d0                	mov    %edx,%eax
  802379:	c1 e8 16             	shr    $0x16,%eax
  80237c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802383:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802388:	f6 c1 01             	test   $0x1,%cl
  80238b:	74 1d                	je     8023aa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80238d:	c1 ea 0c             	shr    $0xc,%edx
  802390:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802397:	f6 c2 01             	test   $0x1,%dl
  80239a:	74 0e                	je     8023aa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80239c:	c1 ea 0c             	shr    $0xc,%edx
  80239f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023a6:	ef 
  8023a7:	0f b7 c0             	movzwl %ax,%eax
}
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__udivdi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 f6                	test   %esi,%esi
  8023c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023cd:	89 ca                	mov    %ecx,%edx
  8023cf:	89 f8                	mov    %edi,%eax
  8023d1:	75 3d                	jne    802410 <__udivdi3+0x60>
  8023d3:	39 cf                	cmp    %ecx,%edi
  8023d5:	0f 87 c5 00 00 00    	ja     8024a0 <__udivdi3+0xf0>
  8023db:	85 ff                	test   %edi,%edi
  8023dd:	89 fd                	mov    %edi,%ebp
  8023df:	75 0b                	jne    8023ec <__udivdi3+0x3c>
  8023e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e6:	31 d2                	xor    %edx,%edx
  8023e8:	f7 f7                	div    %edi
  8023ea:	89 c5                	mov    %eax,%ebp
  8023ec:	89 c8                	mov    %ecx,%eax
  8023ee:	31 d2                	xor    %edx,%edx
  8023f0:	f7 f5                	div    %ebp
  8023f2:	89 c1                	mov    %eax,%ecx
  8023f4:	89 d8                	mov    %ebx,%eax
  8023f6:	89 cf                	mov    %ecx,%edi
  8023f8:	f7 f5                	div    %ebp
  8023fa:	89 c3                	mov    %eax,%ebx
  8023fc:	89 d8                	mov    %ebx,%eax
  8023fe:	89 fa                	mov    %edi,%edx
  802400:	83 c4 1c             	add    $0x1c,%esp
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5f                   	pop    %edi
  802406:	5d                   	pop    %ebp
  802407:	c3                   	ret    
  802408:	90                   	nop
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	39 ce                	cmp    %ecx,%esi
  802412:	77 74                	ja     802488 <__udivdi3+0xd8>
  802414:	0f bd fe             	bsr    %esi,%edi
  802417:	83 f7 1f             	xor    $0x1f,%edi
  80241a:	0f 84 98 00 00 00    	je     8024b8 <__udivdi3+0x108>
  802420:	bb 20 00 00 00       	mov    $0x20,%ebx
  802425:	89 f9                	mov    %edi,%ecx
  802427:	89 c5                	mov    %eax,%ebp
  802429:	29 fb                	sub    %edi,%ebx
  80242b:	d3 e6                	shl    %cl,%esi
  80242d:	89 d9                	mov    %ebx,%ecx
  80242f:	d3 ed                	shr    %cl,%ebp
  802431:	89 f9                	mov    %edi,%ecx
  802433:	d3 e0                	shl    %cl,%eax
  802435:	09 ee                	or     %ebp,%esi
  802437:	89 d9                	mov    %ebx,%ecx
  802439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80243d:	89 d5                	mov    %edx,%ebp
  80243f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802443:	d3 ed                	shr    %cl,%ebp
  802445:	89 f9                	mov    %edi,%ecx
  802447:	d3 e2                	shl    %cl,%edx
  802449:	89 d9                	mov    %ebx,%ecx
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	09 c2                	or     %eax,%edx
  80244f:	89 d0                	mov    %edx,%eax
  802451:	89 ea                	mov    %ebp,%edx
  802453:	f7 f6                	div    %esi
  802455:	89 d5                	mov    %edx,%ebp
  802457:	89 c3                	mov    %eax,%ebx
  802459:	f7 64 24 0c          	mull   0xc(%esp)
  80245d:	39 d5                	cmp    %edx,%ebp
  80245f:	72 10                	jb     802471 <__udivdi3+0xc1>
  802461:	8b 74 24 08          	mov    0x8(%esp),%esi
  802465:	89 f9                	mov    %edi,%ecx
  802467:	d3 e6                	shl    %cl,%esi
  802469:	39 c6                	cmp    %eax,%esi
  80246b:	73 07                	jae    802474 <__udivdi3+0xc4>
  80246d:	39 d5                	cmp    %edx,%ebp
  80246f:	75 03                	jne    802474 <__udivdi3+0xc4>
  802471:	83 eb 01             	sub    $0x1,%ebx
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 d8                	mov    %ebx,%eax
  802478:	89 fa                	mov    %edi,%edx
  80247a:	83 c4 1c             	add    $0x1c,%esp
  80247d:	5b                   	pop    %ebx
  80247e:	5e                   	pop    %esi
  80247f:	5f                   	pop    %edi
  802480:	5d                   	pop    %ebp
  802481:	c3                   	ret    
  802482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802488:	31 ff                	xor    %edi,%edi
  80248a:	31 db                	xor    %ebx,%ebx
  80248c:	89 d8                	mov    %ebx,%eax
  80248e:	89 fa                	mov    %edi,%edx
  802490:	83 c4 1c             	add    $0x1c,%esp
  802493:	5b                   	pop    %ebx
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
  802498:	90                   	nop
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	89 d8                	mov    %ebx,%eax
  8024a2:	f7 f7                	div    %edi
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 c3                	mov    %eax,%ebx
  8024a8:	89 d8                	mov    %ebx,%eax
  8024aa:	89 fa                	mov    %edi,%edx
  8024ac:	83 c4 1c             	add    $0x1c,%esp
  8024af:	5b                   	pop    %ebx
  8024b0:	5e                   	pop    %esi
  8024b1:	5f                   	pop    %edi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    
  8024b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	39 ce                	cmp    %ecx,%esi
  8024ba:	72 0c                	jb     8024c8 <__udivdi3+0x118>
  8024bc:	31 db                	xor    %ebx,%ebx
  8024be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024c2:	0f 87 34 ff ff ff    	ja     8023fc <__udivdi3+0x4c>
  8024c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024cd:	e9 2a ff ff ff       	jmp    8023fc <__udivdi3+0x4c>
  8024d2:	66 90                	xchg   %ax,%ax
  8024d4:	66 90                	xchg   %ax,%ax
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	66 90                	xchg   %ax,%ax
  8024da:	66 90                	xchg   %ax,%ax
  8024dc:	66 90                	xchg   %ax,%ax
  8024de:	66 90                	xchg   %ax,%ax

008024e0 <__umoddi3>:
  8024e0:	55                   	push   %ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	83 ec 1c             	sub    $0x1c,%esp
  8024e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024f7:	85 d2                	test   %edx,%edx
  8024f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802501:	89 f3                	mov    %esi,%ebx
  802503:	89 3c 24             	mov    %edi,(%esp)
  802506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80250a:	75 1c                	jne    802528 <__umoddi3+0x48>
  80250c:	39 f7                	cmp    %esi,%edi
  80250e:	76 50                	jbe    802560 <__umoddi3+0x80>
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	f7 f7                	div    %edi
  802516:	89 d0                	mov    %edx,%eax
  802518:	31 d2                	xor    %edx,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	39 f2                	cmp    %esi,%edx
  80252a:	89 d0                	mov    %edx,%eax
  80252c:	77 52                	ja     802580 <__umoddi3+0xa0>
  80252e:	0f bd ea             	bsr    %edx,%ebp
  802531:	83 f5 1f             	xor    $0x1f,%ebp
  802534:	75 5a                	jne    802590 <__umoddi3+0xb0>
  802536:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80253a:	0f 82 e0 00 00 00    	jb     802620 <__umoddi3+0x140>
  802540:	39 0c 24             	cmp    %ecx,(%esp)
  802543:	0f 86 d7 00 00 00    	jbe    802620 <__umoddi3+0x140>
  802549:	8b 44 24 08          	mov    0x8(%esp),%eax
  80254d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802551:	83 c4 1c             	add    $0x1c,%esp
  802554:	5b                   	pop    %ebx
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	85 ff                	test   %edi,%edi
  802562:	89 fd                	mov    %edi,%ebp
  802564:	75 0b                	jne    802571 <__umoddi3+0x91>
  802566:	b8 01 00 00 00       	mov    $0x1,%eax
  80256b:	31 d2                	xor    %edx,%edx
  80256d:	f7 f7                	div    %edi
  80256f:	89 c5                	mov    %eax,%ebp
  802571:	89 f0                	mov    %esi,%eax
  802573:	31 d2                	xor    %edx,%edx
  802575:	f7 f5                	div    %ebp
  802577:	89 c8                	mov    %ecx,%eax
  802579:	f7 f5                	div    %ebp
  80257b:	89 d0                	mov    %edx,%eax
  80257d:	eb 99                	jmp    802518 <__umoddi3+0x38>
  80257f:	90                   	nop
  802580:	89 c8                	mov    %ecx,%eax
  802582:	89 f2                	mov    %esi,%edx
  802584:	83 c4 1c             	add    $0x1c,%esp
  802587:	5b                   	pop    %ebx
  802588:	5e                   	pop    %esi
  802589:	5f                   	pop    %edi
  80258a:	5d                   	pop    %ebp
  80258b:	c3                   	ret    
  80258c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802590:	8b 34 24             	mov    (%esp),%esi
  802593:	bf 20 00 00 00       	mov    $0x20,%edi
  802598:	89 e9                	mov    %ebp,%ecx
  80259a:	29 ef                	sub    %ebp,%edi
  80259c:	d3 e0                	shl    %cl,%eax
  80259e:	89 f9                	mov    %edi,%ecx
  8025a0:	89 f2                	mov    %esi,%edx
  8025a2:	d3 ea                	shr    %cl,%edx
  8025a4:	89 e9                	mov    %ebp,%ecx
  8025a6:	09 c2                	or     %eax,%edx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 14 24             	mov    %edx,(%esp)
  8025ad:	89 f2                	mov    %esi,%edx
  8025af:	d3 e2                	shl    %cl,%edx
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025bb:	d3 e8                	shr    %cl,%eax
  8025bd:	89 e9                	mov    %ebp,%ecx
  8025bf:	89 c6                	mov    %eax,%esi
  8025c1:	d3 e3                	shl    %cl,%ebx
  8025c3:	89 f9                	mov    %edi,%ecx
  8025c5:	89 d0                	mov    %edx,%eax
  8025c7:	d3 e8                	shr    %cl,%eax
  8025c9:	89 e9                	mov    %ebp,%ecx
  8025cb:	09 d8                	or     %ebx,%eax
  8025cd:	89 d3                	mov    %edx,%ebx
  8025cf:	89 f2                	mov    %esi,%edx
  8025d1:	f7 34 24             	divl   (%esp)
  8025d4:	89 d6                	mov    %edx,%esi
  8025d6:	d3 e3                	shl    %cl,%ebx
  8025d8:	f7 64 24 04          	mull   0x4(%esp)
  8025dc:	39 d6                	cmp    %edx,%esi
  8025de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025e2:	89 d1                	mov    %edx,%ecx
  8025e4:	89 c3                	mov    %eax,%ebx
  8025e6:	72 08                	jb     8025f0 <__umoddi3+0x110>
  8025e8:	75 11                	jne    8025fb <__umoddi3+0x11b>
  8025ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ee:	73 0b                	jae    8025fb <__umoddi3+0x11b>
  8025f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025f4:	1b 14 24             	sbb    (%esp),%edx
  8025f7:	89 d1                	mov    %edx,%ecx
  8025f9:	89 c3                	mov    %eax,%ebx
  8025fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025ff:	29 da                	sub    %ebx,%edx
  802601:	19 ce                	sbb    %ecx,%esi
  802603:	89 f9                	mov    %edi,%ecx
  802605:	89 f0                	mov    %esi,%eax
  802607:	d3 e0                	shl    %cl,%eax
  802609:	89 e9                	mov    %ebp,%ecx
  80260b:	d3 ea                	shr    %cl,%edx
  80260d:	89 e9                	mov    %ebp,%ecx
  80260f:	d3 ee                	shr    %cl,%esi
  802611:	09 d0                	or     %edx,%eax
  802613:	89 f2                	mov    %esi,%edx
  802615:	83 c4 1c             	add    $0x1c,%esp
  802618:	5b                   	pop    %ebx
  802619:	5e                   	pop    %esi
  80261a:	5f                   	pop    %edi
  80261b:	5d                   	pop    %ebp
  80261c:	c3                   	ret    
  80261d:	8d 76 00             	lea    0x0(%esi),%esi
  802620:	29 f9                	sub    %edi,%ecx
  802622:	19 d6                	sbb    %edx,%esi
  802624:	89 74 24 04          	mov    %esi,0x4(%esp)
  802628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80262c:	e9 18 ff ff ff       	jmp    802549 <__umoddi3+0x69>
