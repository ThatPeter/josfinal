
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 5c 15 00 00       	call   8015ad <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 a0 23 80 00       	push   $0x8023a0
  80006d:	6a 15                	push   $0x15
  80006f:	68 cf 23 80 00       	push   $0x8023cf
  800074:	e8 43 02 00 00       	call   8002bc <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 e1 23 80 00       	push   $0x8023e1
  800084:	e8 0c 03 00 00       	call   800395 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 90 1b 00 00       	call   801c21 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 e5 23 80 00       	push   $0x8023e5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 cf 23 80 00       	push   $0x8023cf
  8000a8:	e8 0f 02 00 00       	call   8002bc <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 72 0f 00 00       	call   801024 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 ee 23 80 00       	push   $0x8023ee
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 cf 23 80 00       	push   $0x8023cf
  8000c3:	e8 f4 01 00 00       	call   8002bc <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 0b 13 00 00       	call   8013e0 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 00 13 00 00       	call   8013e0 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 ea 12 00 00       	call   8013e0 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 a2 14 00 00       	call   8015ad <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 f7 23 80 00       	push   $0x8023f7
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 cf 23 80 00       	push   $0x8023cf
  800132:	e8 85 01 00 00       	call   8002bc <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 a8 14 00 00       	call   8015f6 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 13 24 80 00       	push   $0x802413
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 cf 23 80 00       	push   $0x8023cf
  800174:	e8 43 01 00 00       	call   8002bc <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 2d 	movl   $0x80242d,0x803000
  800187:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 8e 1a 00 00       	call   801c21 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 e5 23 80 00       	push   $0x8023e5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 cf 23 80 00       	push   $0x8023cf
  8001aa:	e8 0d 01 00 00       	call   8002bc <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 70 0e 00 00       	call   801024 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 ee 23 80 00       	push   $0x8023ee
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 cf 23 80 00       	push   $0x8023cf
  8001c5:	e8 f2 00 00 00       	call   8002bc <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 07 12 00 00       	call   8013e0 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 f1 11 00 00       	call   8013e0 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 ec 13 00 00       	call   8015f6 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 38 24 80 00       	push   $0x802438
  800226:	6a 4a                	push   $0x4a
  800228:	68 cf 23 80 00       	push   $0x8023cf
  80022d:	e8 8a 00 00 00       	call   8002bc <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 97 0a 00 00       	call   800cdf <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	89 c2                	mov    %eax,%edx
  80024f:	c1 e2 07             	shl    $0x7,%edx
  800252:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800259:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025e:	85 db                	test   %ebx,%ebx
  800260:	7e 07                	jle    800269 <libmain+0x31>
		binaryname = argv[0];
  800262:	8b 06                	mov    (%esi),%eax
  800264:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	e8 06 ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  800273:	e8 2a 00 00 00       	call   8002a2 <exit>
}
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800288:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80028d:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80028f:	e8 4b 0a 00 00       	call   800cdf <sys_getenvid>
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	e8 91 0c 00 00       	call   800f2e <sys_thread_free>
}
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002a8:	e8 5e 11 00 00       	call   80140b <close_all>
	sys_env_destroy(0);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	6a 00                	push   $0x0
  8002b2:	e8 e7 09 00 00       	call   800c9e <sys_env_destroy>
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002ca:	e8 10 0a 00 00       	call   800cdf <sys_getenvid>
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	ff 75 0c             	pushl  0xc(%ebp)
  8002d5:	ff 75 08             	pushl  0x8(%ebp)
  8002d8:	56                   	push   %esi
  8002d9:	50                   	push   %eax
  8002da:	68 5c 24 80 00       	push   $0x80245c
  8002df:	e8 b1 00 00 00       	call   800395 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e4:	83 c4 18             	add    $0x18,%esp
  8002e7:	53                   	push   %ebx
  8002e8:	ff 75 10             	pushl  0x10(%ebp)
  8002eb:	e8 54 00 00 00       	call   800344 <vcprintf>
	cprintf("\n");
  8002f0:	c7 04 24 e3 23 80 00 	movl   $0x8023e3,(%esp)
  8002f7:	e8 99 00 00 00       	call   800395 <cprintf>
  8002fc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ff:	cc                   	int3   
  800300:	eb fd                	jmp    8002ff <_panic+0x43>

00800302 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	53                   	push   %ebx
  800306:	83 ec 04             	sub    $0x4,%esp
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030c:	8b 13                	mov    (%ebx),%edx
  80030e:	8d 42 01             	lea    0x1(%edx),%eax
  800311:	89 03                	mov    %eax,(%ebx)
  800313:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800316:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80031a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031f:	75 1a                	jne    80033b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	68 ff 00 00 00       	push   $0xff
  800329:	8d 43 08             	lea    0x8(%ebx),%eax
  80032c:	50                   	push   %eax
  80032d:	e8 2f 09 00 00       	call   800c61 <sys_cputs>
		b->idx = 0;
  800332:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800338:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80033b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80034d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800354:	00 00 00 
	b.cnt = 0;
  800357:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80035e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800361:	ff 75 0c             	pushl  0xc(%ebp)
  800364:	ff 75 08             	pushl  0x8(%ebp)
  800367:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036d:	50                   	push   %eax
  80036e:	68 02 03 80 00       	push   $0x800302
  800373:	e8 54 01 00 00       	call   8004cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800378:	83 c4 08             	add    $0x8,%esp
  80037b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800381:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800387:	50                   	push   %eax
  800388:	e8 d4 08 00 00       	call   800c61 <sys_cputs>

	return b.cnt;
}
  80038d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80039e:	50                   	push   %eax
  80039f:	ff 75 08             	pushl  0x8(%ebp)
  8003a2:	e8 9d ff ff ff       	call   800344 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a7:	c9                   	leave  
  8003a8:	c3                   	ret    

008003a9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	57                   	push   %edi
  8003ad:	56                   	push   %esi
  8003ae:	53                   	push   %ebx
  8003af:	83 ec 1c             	sub    $0x1c,%esp
  8003b2:	89 c7                	mov    %eax,%edi
  8003b4:	89 d6                	mov    %edx,%esi
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ca:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003cd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003d0:	39 d3                	cmp    %edx,%ebx
  8003d2:	72 05                	jb     8003d9 <printnum+0x30>
  8003d4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003d7:	77 45                	ja     80041e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d9:	83 ec 0c             	sub    $0xc,%esp
  8003dc:	ff 75 18             	pushl  0x18(%ebp)
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003e5:	53                   	push   %ebx
  8003e6:	ff 75 10             	pushl  0x10(%ebp)
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f8:	e8 13 1d 00 00       	call   802110 <__udivdi3>
  8003fd:	83 c4 18             	add    $0x18,%esp
  800400:	52                   	push   %edx
  800401:	50                   	push   %eax
  800402:	89 f2                	mov    %esi,%edx
  800404:	89 f8                	mov    %edi,%eax
  800406:	e8 9e ff ff ff       	call   8003a9 <printnum>
  80040b:	83 c4 20             	add    $0x20,%esp
  80040e:	eb 18                	jmp    800428 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	56                   	push   %esi
  800414:	ff 75 18             	pushl  0x18(%ebp)
  800417:	ff d7                	call   *%edi
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	eb 03                	jmp    800421 <printnum+0x78>
  80041e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800421:	83 eb 01             	sub    $0x1,%ebx
  800424:	85 db                	test   %ebx,%ebx
  800426:	7f e8                	jg     800410 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	56                   	push   %esi
  80042c:	83 ec 04             	sub    $0x4,%esp
  80042f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800432:	ff 75 e0             	pushl  -0x20(%ebp)
  800435:	ff 75 dc             	pushl  -0x24(%ebp)
  800438:	ff 75 d8             	pushl  -0x28(%ebp)
  80043b:	e8 00 1e 00 00       	call   802240 <__umoddi3>
  800440:	83 c4 14             	add    $0x14,%esp
  800443:	0f be 80 7f 24 80 00 	movsbl 0x80247f(%eax),%eax
  80044a:	50                   	push   %eax
  80044b:	ff d7                	call   *%edi
}
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800453:	5b                   	pop    %ebx
  800454:	5e                   	pop    %esi
  800455:	5f                   	pop    %edi
  800456:	5d                   	pop    %ebp
  800457:	c3                   	ret    

00800458 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80045b:	83 fa 01             	cmp    $0x1,%edx
  80045e:	7e 0e                	jle    80046e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800460:	8b 10                	mov    (%eax),%edx
  800462:	8d 4a 08             	lea    0x8(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 02                	mov    (%edx),%eax
  800469:	8b 52 04             	mov    0x4(%edx),%edx
  80046c:	eb 22                	jmp    800490 <getuint+0x38>
	else if (lflag)
  80046e:	85 d2                	test   %edx,%edx
  800470:	74 10                	je     800482 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 04             	lea    0x4(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
  800480:	eb 0e                	jmp    800490 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800490:	5d                   	pop    %ebp
  800491:	c3                   	ret    

00800492 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800498:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a1:	73 0a                	jae    8004ad <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a6:	89 08                	mov    %ecx,(%eax)
  8004a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ab:	88 02                	mov    %al,(%edx)
}
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    

008004af <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b8:	50                   	push   %eax
  8004b9:	ff 75 10             	pushl  0x10(%ebp)
  8004bc:	ff 75 0c             	pushl  0xc(%ebp)
  8004bf:	ff 75 08             	pushl  0x8(%ebp)
  8004c2:	e8 05 00 00 00       	call   8004cc <vprintfmt>
	va_end(ap);
}
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	57                   	push   %edi
  8004d0:	56                   	push   %esi
  8004d1:	53                   	push   %ebx
  8004d2:	83 ec 2c             	sub    $0x2c,%esp
  8004d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004db:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004de:	eb 12                	jmp    8004f2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	0f 84 89 03 00 00    	je     800871 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	50                   	push   %eax
  8004ed:	ff d6                	call   *%esi
  8004ef:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f2:	83 c7 01             	add    $0x1,%edi
  8004f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f9:	83 f8 25             	cmp    $0x25,%eax
  8004fc:	75 e2                	jne    8004e0 <vprintfmt+0x14>
  8004fe:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800502:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800509:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800510:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800517:	ba 00 00 00 00       	mov    $0x0,%edx
  80051c:	eb 07                	jmp    800525 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800521:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8d 47 01             	lea    0x1(%edi),%eax
  800528:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052b:	0f b6 07             	movzbl (%edi),%eax
  80052e:	0f b6 c8             	movzbl %al,%ecx
  800531:	83 e8 23             	sub    $0x23,%eax
  800534:	3c 55                	cmp    $0x55,%al
  800536:	0f 87 1a 03 00 00    	ja     800856 <vprintfmt+0x38a>
  80053c:	0f b6 c0             	movzbl %al,%eax
  80053f:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800549:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054d:	eb d6                	jmp    800525 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800552:	b8 00 00 00 00       	mov    $0x0,%eax
  800557:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80055a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800561:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800564:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800567:	83 fa 09             	cmp    $0x9,%edx
  80056a:	77 39                	ja     8005a5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80056f:	eb e9                	jmp    80055a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 48 04             	lea    0x4(%eax),%ecx
  800577:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800582:	eb 27                	jmp    8005ab <vprintfmt+0xdf>
  800584:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058e:	0f 49 c8             	cmovns %eax,%ecx
  800591:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800597:	eb 8c                	jmp    800525 <vprintfmt+0x59>
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005a3:	eb 80                	jmp    800525 <vprintfmt+0x59>
  8005a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005af:	0f 89 70 ff ff ff    	jns    800525 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c2:	e9 5e ff ff ff       	jmp    800525 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005cd:	e9 53 ff ff ff       	jmp    800525 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	ff 30                	pushl  (%eax)
  8005e1:	ff d6                	call   *%esi
			break;
  8005e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e9:	e9 04 ff ff ff       	jmp    8004f2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	99                   	cltd   
  8005fa:	31 d0                	xor    %edx,%eax
  8005fc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fe:	83 f8 0f             	cmp    $0xf,%eax
  800601:	7f 0b                	jg     80060e <vprintfmt+0x142>
  800603:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  80060a:	85 d2                	test   %edx,%edx
  80060c:	75 18                	jne    800626 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80060e:	50                   	push   %eax
  80060f:	68 97 24 80 00       	push   $0x802497
  800614:	53                   	push   %ebx
  800615:	56                   	push   %esi
  800616:	e8 94 fe ff ff       	call   8004af <printfmt>
  80061b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800621:	e9 cc fe ff ff       	jmp    8004f2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800626:	52                   	push   %edx
  800627:	68 d1 28 80 00       	push   $0x8028d1
  80062c:	53                   	push   %ebx
  80062d:	56                   	push   %esi
  80062e:	e8 7c fe ff ff       	call   8004af <printfmt>
  800633:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800639:	e9 b4 fe ff ff       	jmp    8004f2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800649:	85 ff                	test   %edi,%edi
  80064b:	b8 90 24 80 00       	mov    $0x802490,%eax
  800650:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800653:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800657:	0f 8e 94 00 00 00    	jle    8006f1 <vprintfmt+0x225>
  80065d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800661:	0f 84 98 00 00 00    	je     8006ff <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 d0             	pushl  -0x30(%ebp)
  80066d:	57                   	push   %edi
  80066e:	e8 86 02 00 00       	call   8008f9 <strnlen>
  800673:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800676:	29 c1                	sub    %eax,%ecx
  800678:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80067b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80067e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800682:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800685:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800688:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068a:	eb 0f                	jmp    80069b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	83 ef 01             	sub    $0x1,%edi
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	85 ff                	test   %edi,%edi
  80069d:	7f ed                	jg     80068c <vprintfmt+0x1c0>
  80069f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006a5:	85 c9                	test   %ecx,%ecx
  8006a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ac:	0f 49 c1             	cmovns %ecx,%eax
  8006af:	29 c1                	sub    %eax,%ecx
  8006b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ba:	89 cb                	mov    %ecx,%ebx
  8006bc:	eb 4d                	jmp    80070b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c2:	74 1b                	je     8006df <vprintfmt+0x213>
  8006c4:	0f be c0             	movsbl %al,%eax
  8006c7:	83 e8 20             	sub    $0x20,%eax
  8006ca:	83 f8 5e             	cmp    $0x5e,%eax
  8006cd:	76 10                	jbe    8006df <vprintfmt+0x213>
					putch('?', putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	6a 3f                	push   $0x3f
  8006d7:	ff 55 08             	call   *0x8(%ebp)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 0d                	jmp    8006ec <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	52                   	push   %edx
  8006e6:	ff 55 08             	call   *0x8(%ebp)
  8006e9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ec:	83 eb 01             	sub    $0x1,%ebx
  8006ef:	eb 1a                	jmp    80070b <vprintfmt+0x23f>
  8006f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006fd:	eb 0c                	jmp    80070b <vprintfmt+0x23f>
  8006ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800702:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800705:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800708:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070b:	83 c7 01             	add    $0x1,%edi
  80070e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800712:	0f be d0             	movsbl %al,%edx
  800715:	85 d2                	test   %edx,%edx
  800717:	74 23                	je     80073c <vprintfmt+0x270>
  800719:	85 f6                	test   %esi,%esi
  80071b:	78 a1                	js     8006be <vprintfmt+0x1f2>
  80071d:	83 ee 01             	sub    $0x1,%esi
  800720:	79 9c                	jns    8006be <vprintfmt+0x1f2>
  800722:	89 df                	mov    %ebx,%edi
  800724:	8b 75 08             	mov    0x8(%ebp),%esi
  800727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072a:	eb 18                	jmp    800744 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 20                	push   $0x20
  800732:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800734:	83 ef 01             	sub    $0x1,%edi
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 08                	jmp    800744 <vprintfmt+0x278>
  80073c:	89 df                	mov    %ebx,%edi
  80073e:	8b 75 08             	mov    0x8(%ebp),%esi
  800741:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800744:	85 ff                	test   %edi,%edi
  800746:	7f e4                	jg     80072c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074b:	e9 a2 fd ff ff       	jmp    8004f2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800750:	83 fa 01             	cmp    $0x1,%edx
  800753:	7e 16                	jle    80076b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8d 50 08             	lea    0x8(%eax),%edx
  80075b:	89 55 14             	mov    %edx,0x14(%ebp)
  80075e:	8b 50 04             	mov    0x4(%eax),%edx
  800761:	8b 00                	mov    (%eax),%eax
  800763:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800766:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800769:	eb 32                	jmp    80079d <vprintfmt+0x2d1>
	else if (lflag)
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 18                	je     800787 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 50 04             	lea    0x4(%eax),%edx
  800775:	89 55 14             	mov    %edx,0x14(%ebp)
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077d:	89 c1                	mov    %eax,%ecx
  80077f:	c1 f9 1f             	sar    $0x1f,%ecx
  800782:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800785:	eb 16                	jmp    80079d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8d 50 04             	lea    0x4(%eax),%edx
  80078d:	89 55 14             	mov    %edx,0x14(%ebp)
  800790:	8b 00                	mov    (%eax),%eax
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 c1                	mov    %eax,%ecx
  800797:	c1 f9 1f             	sar    $0x1f,%ecx
  80079a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80079d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ac:	79 74                	jns    800822 <vprintfmt+0x356>
				putch('-', putdat);
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	53                   	push   %ebx
  8007b2:	6a 2d                	push   $0x2d
  8007b4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007bc:	f7 d8                	neg    %eax
  8007be:	83 d2 00             	adc    $0x0,%edx
  8007c1:	f7 da                	neg    %edx
  8007c3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007cb:	eb 55                	jmp    800822 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d0:	e8 83 fc ff ff       	call   800458 <getuint>
			base = 10;
  8007d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007da:	eb 46                	jmp    800822 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007df:	e8 74 fc ff ff       	call   800458 <getuint>
			base = 8;
  8007e4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007e9:	eb 37                	jmp    800822 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	53                   	push   %ebx
  8007ef:	6a 30                	push   $0x30
  8007f1:	ff d6                	call   *%esi
			putch('x', putdat);
  8007f3:	83 c4 08             	add    $0x8,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	6a 78                	push   $0x78
  8007f9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8d 50 04             	lea    0x4(%eax),%edx
  800801:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800804:	8b 00                	mov    (%eax),%eax
  800806:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80080b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800813:	eb 0d                	jmp    800822 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800815:	8d 45 14             	lea    0x14(%ebp),%eax
  800818:	e8 3b fc ff ff       	call   800458 <getuint>
			base = 16;
  80081d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800822:	83 ec 0c             	sub    $0xc,%esp
  800825:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800829:	57                   	push   %edi
  80082a:	ff 75 e0             	pushl  -0x20(%ebp)
  80082d:	51                   	push   %ecx
  80082e:	52                   	push   %edx
  80082f:	50                   	push   %eax
  800830:	89 da                	mov    %ebx,%edx
  800832:	89 f0                	mov    %esi,%eax
  800834:	e8 70 fb ff ff       	call   8003a9 <printnum>
			break;
  800839:	83 c4 20             	add    $0x20,%esp
  80083c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80083f:	e9 ae fc ff ff       	jmp    8004f2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	53                   	push   %ebx
  800848:	51                   	push   %ecx
  800849:	ff d6                	call   *%esi
			break;
  80084b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800851:	e9 9c fc ff ff       	jmp    8004f2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	53                   	push   %ebx
  80085a:	6a 25                	push   $0x25
  80085c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	eb 03                	jmp    800866 <vprintfmt+0x39a>
  800863:	83 ef 01             	sub    $0x1,%edi
  800866:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80086a:	75 f7                	jne    800863 <vprintfmt+0x397>
  80086c:	e9 81 fc ff ff       	jmp    8004f2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800871:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5f                   	pop    %edi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 18             	sub    $0x18,%esp
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800885:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800888:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800896:	85 c0                	test   %eax,%eax
  800898:	74 26                	je     8008c0 <vsnprintf+0x47>
  80089a:	85 d2                	test   %edx,%edx
  80089c:	7e 22                	jle    8008c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089e:	ff 75 14             	pushl  0x14(%ebp)
  8008a1:	ff 75 10             	pushl  0x10(%ebp)
  8008a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a7:	50                   	push   %eax
  8008a8:	68 92 04 80 00       	push   $0x800492
  8008ad:	e8 1a fc ff ff       	call   8004cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	eb 05                	jmp    8008c5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d0:	50                   	push   %eax
  8008d1:	ff 75 10             	pushl  0x10(%ebp)
  8008d4:	ff 75 0c             	pushl  0xc(%ebp)
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 9a ff ff ff       	call   800879 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    

008008e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	eb 03                	jmp    8008f1 <strlen+0x10>
		n++;
  8008ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f5:	75 f7                	jne    8008ee <strlen+0xd>
		n++;
	return n;
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800902:	ba 00 00 00 00       	mov    $0x0,%edx
  800907:	eb 03                	jmp    80090c <strnlen+0x13>
		n++;
  800909:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090c:	39 c2                	cmp    %eax,%edx
  80090e:	74 08                	je     800918 <strnlen+0x1f>
  800910:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800914:	75 f3                	jne    800909 <strnlen+0x10>
  800916:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	53                   	push   %ebx
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800924:	89 c2                	mov    %eax,%edx
  800926:	83 c2 01             	add    $0x1,%edx
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800930:	88 5a ff             	mov    %bl,-0x1(%edx)
  800933:	84 db                	test   %bl,%bl
  800935:	75 ef                	jne    800926 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800941:	53                   	push   %ebx
  800942:	e8 9a ff ff ff       	call   8008e1 <strlen>
  800947:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80094a:	ff 75 0c             	pushl  0xc(%ebp)
  80094d:	01 d8                	add    %ebx,%eax
  80094f:	50                   	push   %eax
  800950:	e8 c5 ff ff ff       	call   80091a <strcpy>
	return dst;
}
  800955:	89 d8                	mov    %ebx,%eax
  800957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	8b 75 08             	mov    0x8(%ebp),%esi
  800964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800967:	89 f3                	mov    %esi,%ebx
  800969:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096c:	89 f2                	mov    %esi,%edx
  80096e:	eb 0f                	jmp    80097f <strncpy+0x23>
		*dst++ = *src;
  800970:	83 c2 01             	add    $0x1,%edx
  800973:	0f b6 01             	movzbl (%ecx),%eax
  800976:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800979:	80 39 01             	cmpb   $0x1,(%ecx)
  80097c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097f:	39 da                	cmp    %ebx,%edx
  800981:	75 ed                	jne    800970 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800983:	89 f0                	mov    %esi,%eax
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 75 08             	mov    0x8(%ebp),%esi
  800991:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800994:	8b 55 10             	mov    0x10(%ebp),%edx
  800997:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800999:	85 d2                	test   %edx,%edx
  80099b:	74 21                	je     8009be <strlcpy+0x35>
  80099d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a1:	89 f2                	mov    %esi,%edx
  8009a3:	eb 09                	jmp    8009ae <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a5:	83 c2 01             	add    $0x1,%edx
  8009a8:	83 c1 01             	add    $0x1,%ecx
  8009ab:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ae:	39 c2                	cmp    %eax,%edx
  8009b0:	74 09                	je     8009bb <strlcpy+0x32>
  8009b2:	0f b6 19             	movzbl (%ecx),%ebx
  8009b5:	84 db                	test   %bl,%bl
  8009b7:	75 ec                	jne    8009a5 <strlcpy+0x1c>
  8009b9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009be:	29 f0                	sub    %esi,%eax
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009cd:	eb 06                	jmp    8009d5 <strcmp+0x11>
		p++, q++;
  8009cf:	83 c1 01             	add    $0x1,%ecx
  8009d2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d5:	0f b6 01             	movzbl (%ecx),%eax
  8009d8:	84 c0                	test   %al,%al
  8009da:	74 04                	je     8009e0 <strcmp+0x1c>
  8009dc:	3a 02                	cmp    (%edx),%al
  8009de:	74 ef                	je     8009cf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e0:	0f b6 c0             	movzbl %al,%eax
  8009e3:	0f b6 12             	movzbl (%edx),%edx
  8009e6:	29 d0                	sub    %edx,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	89 c3                	mov    %eax,%ebx
  8009f6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f9:	eb 06                	jmp    800a01 <strncmp+0x17>
		n--, p++, q++;
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a01:	39 d8                	cmp    %ebx,%eax
  800a03:	74 15                	je     800a1a <strncmp+0x30>
  800a05:	0f b6 08             	movzbl (%eax),%ecx
  800a08:	84 c9                	test   %cl,%cl
  800a0a:	74 04                	je     800a10 <strncmp+0x26>
  800a0c:	3a 0a                	cmp    (%edx),%cl
  800a0e:	74 eb                	je     8009fb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a10:	0f b6 00             	movzbl (%eax),%eax
  800a13:	0f b6 12             	movzbl (%edx),%edx
  800a16:	29 d0                	sub    %edx,%eax
  800a18:	eb 05                	jmp    800a1f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2c:	eb 07                	jmp    800a35 <strchr+0x13>
		if (*s == c)
  800a2e:	38 ca                	cmp    %cl,%dl
  800a30:	74 0f                	je     800a41 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	75 f2                	jne    800a2e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4d:	eb 03                	jmp    800a52 <strfind+0xf>
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a55:	38 ca                	cmp    %cl,%dl
  800a57:	74 04                	je     800a5d <strfind+0x1a>
  800a59:	84 d2                	test   %dl,%dl
  800a5b:	75 f2                	jne    800a4f <strfind+0xc>
			break;
	return (char *) s;
}
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6b:	85 c9                	test   %ecx,%ecx
  800a6d:	74 36                	je     800aa5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a75:	75 28                	jne    800a9f <memset+0x40>
  800a77:	f6 c1 03             	test   $0x3,%cl
  800a7a:	75 23                	jne    800a9f <memset+0x40>
		c &= 0xFF;
  800a7c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a80:	89 d3                	mov    %edx,%ebx
  800a82:	c1 e3 08             	shl    $0x8,%ebx
  800a85:	89 d6                	mov    %edx,%esi
  800a87:	c1 e6 18             	shl    $0x18,%esi
  800a8a:	89 d0                	mov    %edx,%eax
  800a8c:	c1 e0 10             	shl    $0x10,%eax
  800a8f:	09 f0                	or     %esi,%eax
  800a91:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a93:	89 d8                	mov    %ebx,%eax
  800a95:	09 d0                	or     %edx,%eax
  800a97:	c1 e9 02             	shr    $0x2,%ecx
  800a9a:	fc                   	cld    
  800a9b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9d:	eb 06                	jmp    800aa5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa2:	fc                   	cld    
  800aa3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa5:	89 f8                	mov    %edi,%eax
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aba:	39 c6                	cmp    %eax,%esi
  800abc:	73 35                	jae    800af3 <memmove+0x47>
  800abe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac1:	39 d0                	cmp    %edx,%eax
  800ac3:	73 2e                	jae    800af3 <memmove+0x47>
		s += n;
		d += n;
  800ac5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	09 fe                	or     %edi,%esi
  800acc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad2:	75 13                	jne    800ae7 <memmove+0x3b>
  800ad4:	f6 c1 03             	test   $0x3,%cl
  800ad7:	75 0e                	jne    800ae7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad9:	83 ef 04             	sub    $0x4,%edi
  800adc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adf:	c1 e9 02             	shr    $0x2,%ecx
  800ae2:	fd                   	std    
  800ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae5:	eb 09                	jmp    800af0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae7:	83 ef 01             	sub    $0x1,%edi
  800aea:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aed:	fd                   	std    
  800aee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af0:	fc                   	cld    
  800af1:	eb 1d                	jmp    800b10 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af3:	89 f2                	mov    %esi,%edx
  800af5:	09 c2                	or     %eax,%edx
  800af7:	f6 c2 03             	test   $0x3,%dl
  800afa:	75 0f                	jne    800b0b <memmove+0x5f>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 0a                	jne    800b0b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b01:	c1 e9 02             	shr    $0x2,%ecx
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 05                	jmp    800b10 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b17:	ff 75 10             	pushl  0x10(%ebp)
  800b1a:	ff 75 0c             	pushl  0xc(%ebp)
  800b1d:	ff 75 08             	pushl  0x8(%ebp)
  800b20:	e8 87 ff ff ff       	call   800aac <memmove>
}
  800b25:	c9                   	leave  
  800b26:	c3                   	ret    

00800b27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b32:	89 c6                	mov    %eax,%esi
  800b34:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b37:	eb 1a                	jmp    800b53 <memcmp+0x2c>
		if (*s1 != *s2)
  800b39:	0f b6 08             	movzbl (%eax),%ecx
  800b3c:	0f b6 1a             	movzbl (%edx),%ebx
  800b3f:	38 d9                	cmp    %bl,%cl
  800b41:	74 0a                	je     800b4d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b43:	0f b6 c1             	movzbl %cl,%eax
  800b46:	0f b6 db             	movzbl %bl,%ebx
  800b49:	29 d8                	sub    %ebx,%eax
  800b4b:	eb 0f                	jmp    800b5c <memcmp+0x35>
		s1++, s2++;
  800b4d:	83 c0 01             	add    $0x1,%eax
  800b50:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b53:	39 f0                	cmp    %esi,%eax
  800b55:	75 e2                	jne    800b39 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	53                   	push   %ebx
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b67:	89 c1                	mov    %eax,%ecx
  800b69:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b70:	eb 0a                	jmp    800b7c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b72:	0f b6 10             	movzbl (%eax),%edx
  800b75:	39 da                	cmp    %ebx,%edx
  800b77:	74 07                	je     800b80 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b79:	83 c0 01             	add    $0x1,%eax
  800b7c:	39 c8                	cmp    %ecx,%eax
  800b7e:	72 f2                	jb     800b72 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b80:	5b                   	pop    %ebx
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8f:	eb 03                	jmp    800b94 <strtol+0x11>
		s++;
  800b91:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b94:	0f b6 01             	movzbl (%ecx),%eax
  800b97:	3c 20                	cmp    $0x20,%al
  800b99:	74 f6                	je     800b91 <strtol+0xe>
  800b9b:	3c 09                	cmp    $0x9,%al
  800b9d:	74 f2                	je     800b91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b9f:	3c 2b                	cmp    $0x2b,%al
  800ba1:	75 0a                	jne    800bad <strtol+0x2a>
		s++;
  800ba3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bab:	eb 11                	jmp    800bbe <strtol+0x3b>
  800bad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb2:	3c 2d                	cmp    $0x2d,%al
  800bb4:	75 08                	jne    800bbe <strtol+0x3b>
		s++, neg = 1;
  800bb6:	83 c1 01             	add    $0x1,%ecx
  800bb9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc4:	75 15                	jne    800bdb <strtol+0x58>
  800bc6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc9:	75 10                	jne    800bdb <strtol+0x58>
  800bcb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bcf:	75 7c                	jne    800c4d <strtol+0xca>
		s += 2, base = 16;
  800bd1:	83 c1 02             	add    $0x2,%ecx
  800bd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd9:	eb 16                	jmp    800bf1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bdb:	85 db                	test   %ebx,%ebx
  800bdd:	75 12                	jne    800bf1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be4:	80 39 30             	cmpb   $0x30,(%ecx)
  800be7:	75 08                	jne    800bf1 <strtol+0x6e>
		s++, base = 8;
  800be9:	83 c1 01             	add    $0x1,%ecx
  800bec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf9:	0f b6 11             	movzbl (%ecx),%edx
  800bfc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 09             	cmp    $0x9,%bl
  800c04:	77 08                	ja     800c0e <strtol+0x8b>
			dig = *s - '0';
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 30             	sub    $0x30,%edx
  800c0c:	eb 22                	jmp    800c30 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 08                	ja     800c20 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 57             	sub    $0x57,%edx
  800c1e:	eb 10                	jmp    800c30 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c23:	89 f3                	mov    %esi,%ebx
  800c25:	80 fb 19             	cmp    $0x19,%bl
  800c28:	77 16                	ja     800c40 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c2a:	0f be d2             	movsbl %dl,%edx
  800c2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c30:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c33:	7d 0b                	jge    800c40 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c35:	83 c1 01             	add    $0x1,%ecx
  800c38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c3e:	eb b9                	jmp    800bf9 <strtol+0x76>

	if (endptr)
  800c40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c44:	74 0d                	je     800c53 <strtol+0xd0>
		*endptr = (char *) s;
  800c46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c49:	89 0e                	mov    %ecx,(%esi)
  800c4b:	eb 06                	jmp    800c53 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4d:	85 db                	test   %ebx,%ebx
  800c4f:	74 98                	je     800be9 <strtol+0x66>
  800c51:	eb 9e                	jmp    800bf1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c53:	89 c2                	mov    %eax,%edx
  800c55:	f7 da                	neg    %edx
  800c57:	85 ff                	test   %edi,%edi
  800c59:	0f 45 c2             	cmovne %edx,%eax
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	89 c3                	mov    %eax,%ebx
  800c74:	89 c7                	mov    %eax,%edi
  800c76:	89 c6                	mov    %eax,%esi
  800c78:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8f:	89 d1                	mov    %edx,%ecx
  800c91:	89 d3                	mov    %edx,%ebx
  800c93:	89 d7                	mov    %edx,%edi
  800c95:	89 d6                	mov    %edx,%esi
  800c97:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cac:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 cb                	mov    %ecx,%ebx
  800cb6:	89 cf                	mov    %ecx,%edi
  800cb8:	89 ce                	mov    %ecx,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 03                	push   $0x3
  800cc6:	68 7f 27 80 00       	push   $0x80277f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 9c 27 80 00       	push   $0x80279c
  800cd2:	e8 e5 f5 ff ff       	call   8002bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cea:	b8 02 00 00 00       	mov    $0x2,%eax
  800cef:	89 d1                	mov    %edx,%ecx
  800cf1:	89 d3                	mov    %edx,%ebx
  800cf3:	89 d7                	mov    %edx,%edi
  800cf5:	89 d6                	mov    %edx,%esi
  800cf7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_yield>:

void
sys_yield(void)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	ba 00 00 00 00       	mov    $0x0,%edx
  800d09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0e:	89 d1                	mov    %edx,%ecx
  800d10:	89 d3                	mov    %edx,%ebx
  800d12:	89 d7                	mov    %edx,%edi
  800d14:	89 d6                	mov    %edx,%esi
  800d16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	be 00 00 00 00       	mov    $0x0,%esi
  800d2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d39:	89 f7                	mov    %esi,%edi
  800d3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 04                	push   $0x4
  800d47:	68 7f 27 80 00       	push   $0x80277f
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 9c 27 80 00       	push   $0x80279c
  800d53:	e8 64 f5 ff ff       	call   8002bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7e 17                	jle    800d9a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	50                   	push   %eax
  800d87:	6a 05                	push   $0x5
  800d89:	68 7f 27 80 00       	push   $0x80277f
  800d8e:	6a 23                	push   $0x23
  800d90:	68 9c 27 80 00       	push   $0x80279c
  800d95:	e8 22 f5 ff ff       	call   8002bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	b8 06 00 00 00       	mov    $0x6,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 17                	jle    800ddc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 06                	push   $0x6
  800dcb:	68 7f 27 80 00       	push   $0x80277f
  800dd0:	6a 23                	push   $0x23
  800dd2:	68 9c 27 80 00       	push   $0x80279c
  800dd7:	e8 e0 f4 ff ff       	call   8002bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ded:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df2:	b8 08 00 00 00       	mov    $0x8,%eax
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	89 df                	mov    %ebx,%edi
  800dff:	89 de                	mov    %ebx,%esi
  800e01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7e 17                	jle    800e1e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	50                   	push   %eax
  800e0b:	6a 08                	push   $0x8
  800e0d:	68 7f 27 80 00       	push   $0x80277f
  800e12:	6a 23                	push   $0x23
  800e14:	68 9c 27 80 00       	push   $0x80279c
  800e19:	e8 9e f4 ff ff       	call   8002bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e34:	b8 09 00 00 00       	mov    $0x9,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 df                	mov    %ebx,%edi
  800e41:	89 de                	mov    %ebx,%esi
  800e43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7e 17                	jle    800e60 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	50                   	push   %eax
  800e4d:	6a 09                	push   $0x9
  800e4f:	68 7f 27 80 00       	push   $0x80277f
  800e54:	6a 23                	push   $0x23
  800e56:	68 9c 27 80 00       	push   $0x80279c
  800e5b:	e8 5c f4 ff ff       	call   8002bc <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	89 df                	mov    %ebx,%edi
  800e83:	89 de                	mov    %ebx,%esi
  800e85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e87:	85 c0                	test   %eax,%eax
  800e89:	7e 17                	jle    800ea2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8b:	83 ec 0c             	sub    $0xc,%esp
  800e8e:	50                   	push   %eax
  800e8f:	6a 0a                	push   $0xa
  800e91:	68 7f 27 80 00       	push   $0x80277f
  800e96:	6a 23                	push   $0x23
  800e98:	68 9c 27 80 00       	push   $0x80279c
  800e9d:	e8 1a f4 ff ff       	call   8002bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb0:	be 00 00 00 00       	mov    $0x0,%esi
  800eb5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee3:	89 cb                	mov    %ecx,%ebx
  800ee5:	89 cf                	mov    %ecx,%edi
  800ee7:	89 ce                	mov    %ecx,%esi
  800ee9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	7e 17                	jle    800f06 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	50                   	push   %eax
  800ef3:	6a 0d                	push   $0xd
  800ef5:	68 7f 27 80 00       	push   $0x80277f
  800efa:	6a 23                	push   $0x23
  800efc:	68 9c 27 80 00       	push   $0x80279c
  800f01:	e8 b6 f3 ff ff       	call   8002bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f19:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	89 cb                	mov    %ecx,%ebx
  800f23:	89 cf                	mov    %ecx,%edi
  800f25:	89 ce                	mov    %ecx,%esi
  800f27:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f39:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f41:	89 cb                	mov    %ecx,%ebx
  800f43:	89 cf                	mov    %ecx,%edi
  800f45:	89 ce                	mov    %ecx,%esi
  800f47:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	53                   	push   %ebx
  800f52:	83 ec 04             	sub    $0x4,%esp
  800f55:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f58:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f5a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5e:	74 11                	je     800f71 <pgfault+0x23>
  800f60:	89 d8                	mov    %ebx,%eax
  800f62:	c1 e8 0c             	shr    $0xc,%eax
  800f65:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6c:	f6 c4 08             	test   $0x8,%ah
  800f6f:	75 14                	jne    800f85 <pgfault+0x37>
		panic("faulting access");
  800f71:	83 ec 04             	sub    $0x4,%esp
  800f74:	68 aa 27 80 00       	push   $0x8027aa
  800f79:	6a 1e                	push   $0x1e
  800f7b:	68 ba 27 80 00       	push   $0x8027ba
  800f80:	e8 37 f3 ff ff       	call   8002bc <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	6a 07                	push   $0x7
  800f8a:	68 00 f0 7f 00       	push   $0x7ff000
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 87 fd ff ff       	call   800d1d <sys_page_alloc>
	if (r < 0) {
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 12                	jns    800faf <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f9d:	50                   	push   %eax
  800f9e:	68 c5 27 80 00       	push   $0x8027c5
  800fa3:	6a 2c                	push   $0x2c
  800fa5:	68 ba 27 80 00       	push   $0x8027ba
  800faa:	e8 0d f3 ff ff       	call   8002bc <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800faf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800fb5:	83 ec 04             	sub    $0x4,%esp
  800fb8:	68 00 10 00 00       	push   $0x1000
  800fbd:	53                   	push   %ebx
  800fbe:	68 00 f0 7f 00       	push   $0x7ff000
  800fc3:	e8 4c fb ff ff       	call   800b14 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800fc8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fcf:	53                   	push   %ebx
  800fd0:	6a 00                	push   $0x0
  800fd2:	68 00 f0 7f 00       	push   $0x7ff000
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 82 fd ff ff       	call   800d60 <sys_page_map>
	if (r < 0) {
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 12                	jns    800ff7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800fe5:	50                   	push   %eax
  800fe6:	68 c5 27 80 00       	push   $0x8027c5
  800feb:	6a 33                	push   $0x33
  800fed:	68 ba 27 80 00       	push   $0x8027ba
  800ff2:	e8 c5 f2 ff ff       	call   8002bc <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	68 00 f0 7f 00       	push   $0x7ff000
  800fff:	6a 00                	push   $0x0
  801001:	e8 9c fd ff ff       	call   800da2 <sys_page_unmap>
	if (r < 0) {
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 12                	jns    80101f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80100d:	50                   	push   %eax
  80100e:	68 c5 27 80 00       	push   $0x8027c5
  801013:	6a 37                	push   $0x37
  801015:	68 ba 27 80 00       	push   $0x8027ba
  80101a:	e8 9d f2 ff ff       	call   8002bc <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80101f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80102d:	68 4e 0f 80 00       	push   $0x800f4e
  801032:	e8 f3 0e 00 00       	call   801f2a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801037:	b8 07 00 00 00       	mov    $0x7,%eax
  80103c:	cd 30                	int    $0x30
  80103e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 17                	jns    80105f <fork+0x3b>
		panic("fork fault %e");
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	68 de 27 80 00       	push   $0x8027de
  801050:	68 84 00 00 00       	push   $0x84
  801055:	68 ba 27 80 00       	push   $0x8027ba
  80105a:	e8 5d f2 ff ff       	call   8002bc <_panic>
  80105f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801061:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801065:	75 25                	jne    80108c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801067:	e8 73 fc ff ff       	call   800cdf <sys_getenvid>
  80106c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801071:	89 c2                	mov    %eax,%edx
  801073:	c1 e2 07             	shl    $0x7,%edx
  801076:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80107d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801082:	b8 00 00 00 00       	mov    $0x0,%eax
  801087:	e9 61 01 00 00       	jmp    8011ed <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80108c:	83 ec 04             	sub    $0x4,%esp
  80108f:	6a 07                	push   $0x7
  801091:	68 00 f0 bf ee       	push   $0xeebff000
  801096:	ff 75 e4             	pushl  -0x1c(%ebp)
  801099:	e8 7f fc ff ff       	call   800d1d <sys_page_alloc>
  80109e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010a6:	89 d8                	mov    %ebx,%eax
  8010a8:	c1 e8 16             	shr    $0x16,%eax
  8010ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b2:	a8 01                	test   $0x1,%al
  8010b4:	0f 84 fc 00 00 00    	je     8011b6 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8010ba:	89 d8                	mov    %ebx,%eax
  8010bc:	c1 e8 0c             	shr    $0xc,%eax
  8010bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	0f 84 e7 00 00 00    	je     8011b6 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8010cf:	89 c6                	mov    %eax,%esi
  8010d1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8010d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010db:	f6 c6 04             	test   $0x4,%dh
  8010de:	74 39                	je     801119 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ef:	50                   	push   %eax
  8010f0:	56                   	push   %esi
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	6a 00                	push   $0x0
  8010f5:	e8 66 fc ff ff       	call   800d60 <sys_page_map>
		if (r < 0) {
  8010fa:	83 c4 20             	add    $0x20,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	0f 89 b1 00 00 00    	jns    8011b6 <fork+0x192>
		    	panic("sys page map fault %e");
  801105:	83 ec 04             	sub    $0x4,%esp
  801108:	68 ec 27 80 00       	push   $0x8027ec
  80110d:	6a 54                	push   $0x54
  80110f:	68 ba 27 80 00       	push   $0x8027ba
  801114:	e8 a3 f1 ff ff       	call   8002bc <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801119:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801120:	f6 c2 02             	test   $0x2,%dl
  801123:	75 0c                	jne    801131 <fork+0x10d>
  801125:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112c:	f6 c4 08             	test   $0x8,%ah
  80112f:	74 5b                	je     80118c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	68 05 08 00 00       	push   $0x805
  801139:	56                   	push   %esi
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	6a 00                	push   $0x0
  80113e:	e8 1d fc ff ff       	call   800d60 <sys_page_map>
		if (r < 0) {
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	79 14                	jns    80115e <fork+0x13a>
		    	panic("sys page map fault %e");
  80114a:	83 ec 04             	sub    $0x4,%esp
  80114d:	68 ec 27 80 00       	push   $0x8027ec
  801152:	6a 5b                	push   $0x5b
  801154:	68 ba 27 80 00       	push   $0x8027ba
  801159:	e8 5e f1 ff ff       	call   8002bc <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	68 05 08 00 00       	push   $0x805
  801166:	56                   	push   %esi
  801167:	6a 00                	push   $0x0
  801169:	56                   	push   %esi
  80116a:	6a 00                	push   $0x0
  80116c:	e8 ef fb ff ff       	call   800d60 <sys_page_map>
		if (r < 0) {
  801171:	83 c4 20             	add    $0x20,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	79 3e                	jns    8011b6 <fork+0x192>
		    	panic("sys page map fault %e");
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	68 ec 27 80 00       	push   $0x8027ec
  801180:	6a 5f                	push   $0x5f
  801182:	68 ba 27 80 00       	push   $0x8027ba
  801187:	e8 30 f1 ff ff       	call   8002bc <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	6a 05                	push   $0x5
  801191:	56                   	push   %esi
  801192:	57                   	push   %edi
  801193:	56                   	push   %esi
  801194:	6a 00                	push   $0x0
  801196:	e8 c5 fb ff ff       	call   800d60 <sys_page_map>
		if (r < 0) {
  80119b:	83 c4 20             	add    $0x20,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	79 14                	jns    8011b6 <fork+0x192>
		    	panic("sys page map fault %e");
  8011a2:	83 ec 04             	sub    $0x4,%esp
  8011a5:	68 ec 27 80 00       	push   $0x8027ec
  8011aa:	6a 64                	push   $0x64
  8011ac:	68 ba 27 80 00       	push   $0x8027ba
  8011b1:	e8 06 f1 ff ff       	call   8002bc <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8011b6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011bc:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011c2:	0f 85 de fe ff ff    	jne    8010a6 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8011c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cd:	8b 40 70             	mov    0x70(%eax),%eax
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	50                   	push   %eax
  8011d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011d7:	57                   	push   %edi
  8011d8:	e8 8b fc ff ff       	call   800e68 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011dd:	83 c4 08             	add    $0x8,%esp
  8011e0:	6a 02                	push   $0x2
  8011e2:	57                   	push   %edi
  8011e3:	e8 fc fb ff ff       	call   800de4 <sys_env_set_status>
	
	return envid;
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <sfork>:

envid_t
sfork(void)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    

008011ff <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801207:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	53                   	push   %ebx
  801211:	68 04 28 80 00       	push   $0x802804
  801216:	e8 7a f1 ff ff       	call   800395 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80121b:	c7 04 24 82 02 80 00 	movl   $0x800282,(%esp)
  801222:	e8 e7 fc ff ff       	call   800f0e <sys_thread_create>
  801227:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801229:	83 c4 08             	add    $0x8,%esp
  80122c:	53                   	push   %ebx
  80122d:	68 04 28 80 00       	push   $0x802804
  801232:	e8 5e f1 ff ff       	call   800395 <cprintf>
	return id;
	//return 0;
}
  801237:	89 f0                	mov    %esi,%eax
  801239:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	05 00 00 00 30       	add    $0x30000000,%eax
  80124b:	c1 e8 0c             	shr    $0xc,%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	05 00 00 00 30       	add    $0x30000000,%eax
  80125b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801260:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801265:	5d                   	pop    %ebp
  801266:	c3                   	ret    

00801267 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801272:	89 c2                	mov    %eax,%edx
  801274:	c1 ea 16             	shr    $0x16,%edx
  801277:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	74 11                	je     801294 <fd_alloc+0x2d>
  801283:	89 c2                	mov    %eax,%edx
  801285:	c1 ea 0c             	shr    $0xc,%edx
  801288:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	75 09                	jne    80129d <fd_alloc+0x36>
			*fd_store = fd;
  801294:	89 01                	mov    %eax,(%ecx)
			return 0;
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
  80129b:	eb 17                	jmp    8012b4 <fd_alloc+0x4d>
  80129d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a7:	75 c9                	jne    801272 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012bc:	83 f8 1f             	cmp    $0x1f,%eax
  8012bf:	77 36                	ja     8012f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c1:	c1 e0 0c             	shl    $0xc,%eax
  8012c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 16             	shr    $0x16,%edx
  8012ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 24                	je     8012fe <fd_lookup+0x48>
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 0c             	shr    $0xc,%edx
  8012df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	74 1a                	je     801305 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	eb 13                	jmp    80130a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb 0c                	jmp    80130a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801303:	eb 05                	jmp    80130a <fd_lookup+0x54>
  801305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801315:	ba a8 28 80 00       	mov    $0x8028a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80131a:	eb 13                	jmp    80132f <dev_lookup+0x23>
  80131c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80131f:	39 08                	cmp    %ecx,(%eax)
  801321:	75 0c                	jne    80132f <dev_lookup+0x23>
			*dev = devtab[i];
  801323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801326:	89 01                	mov    %eax,(%ecx)
			return 0;
  801328:	b8 00 00 00 00       	mov    $0x0,%eax
  80132d:	eb 2e                	jmp    80135d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80132f:	8b 02                	mov    (%edx),%eax
  801331:	85 c0                	test   %eax,%eax
  801333:	75 e7                	jne    80131c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801335:	a1 04 40 80 00       	mov    0x804004,%eax
  80133a:	8b 40 54             	mov    0x54(%eax),%eax
  80133d:	83 ec 04             	sub    $0x4,%esp
  801340:	51                   	push   %ecx
  801341:	50                   	push   %eax
  801342:	68 28 28 80 00       	push   $0x802828
  801347:	e8 49 f0 ff ff       	call   800395 <cprintf>
	*dev = 0;
  80134c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
  801364:	83 ec 10             	sub    $0x10,%esp
  801367:	8b 75 08             	mov    0x8(%ebp),%esi
  80136a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80136d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801370:	50                   	push   %eax
  801371:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801377:	c1 e8 0c             	shr    $0xc,%eax
  80137a:	50                   	push   %eax
  80137b:	e8 36 ff ff ff       	call   8012b6 <fd_lookup>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 05                	js     80138c <fd_close+0x2d>
	    || fd != fd2)
  801387:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80138a:	74 0c                	je     801398 <fd_close+0x39>
		return (must_exist ? r : 0);
  80138c:	84 db                	test   %bl,%bl
  80138e:	ba 00 00 00 00       	mov    $0x0,%edx
  801393:	0f 44 c2             	cmove  %edx,%eax
  801396:	eb 41                	jmp    8013d9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139e:	50                   	push   %eax
  80139f:	ff 36                	pushl  (%esi)
  8013a1:	e8 66 ff ff ff       	call   80130c <dev_lookup>
  8013a6:	89 c3                	mov    %eax,%ebx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 1a                	js     8013c9 <fd_close+0x6a>
		if (dev->dev_close)
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013b5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	74 0b                	je     8013c9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013be:	83 ec 0c             	sub    $0xc,%esp
  8013c1:	56                   	push   %esi
  8013c2:	ff d0                	call   *%eax
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	56                   	push   %esi
  8013cd:	6a 00                	push   $0x0
  8013cf:	e8 ce f9 ff ff       	call   800da2 <sys_page_unmap>
	return r;
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	89 d8                	mov    %ebx,%eax
}
  8013d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	ff 75 08             	pushl  0x8(%ebp)
  8013ed:	e8 c4 fe ff ff       	call   8012b6 <fd_lookup>
  8013f2:	83 c4 08             	add    $0x8,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 10                	js     801409 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	6a 01                	push   $0x1
  8013fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801401:	e8 59 ff ff ff       	call   80135f <fd_close>
  801406:	83 c4 10             	add    $0x10,%esp
}
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <close_all>:

void
close_all(void)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801412:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801417:	83 ec 0c             	sub    $0xc,%esp
  80141a:	53                   	push   %ebx
  80141b:	e8 c0 ff ff ff       	call   8013e0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801420:	83 c3 01             	add    $0x1,%ebx
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	83 fb 20             	cmp    $0x20,%ebx
  801429:	75 ec                	jne    801417 <close_all+0xc>
		close(i);
}
  80142b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	57                   	push   %edi
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	83 ec 2c             	sub    $0x2c,%esp
  801439:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80143c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	ff 75 08             	pushl  0x8(%ebp)
  801443:	e8 6e fe ff ff       	call   8012b6 <fd_lookup>
  801448:	83 c4 08             	add    $0x8,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	0f 88 c1 00 00 00    	js     801514 <dup+0xe4>
		return r;
	close(newfdnum);
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	56                   	push   %esi
  801457:	e8 84 ff ff ff       	call   8013e0 <close>

	newfd = INDEX2FD(newfdnum);
  80145c:	89 f3                	mov    %esi,%ebx
  80145e:	c1 e3 0c             	shl    $0xc,%ebx
  801461:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801467:	83 c4 04             	add    $0x4,%esp
  80146a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80146d:	e8 de fd ff ff       	call   801250 <fd2data>
  801472:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801474:	89 1c 24             	mov    %ebx,(%esp)
  801477:	e8 d4 fd ff ff       	call   801250 <fd2data>
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801482:	89 f8                	mov    %edi,%eax
  801484:	c1 e8 16             	shr    $0x16,%eax
  801487:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80148e:	a8 01                	test   $0x1,%al
  801490:	74 37                	je     8014c9 <dup+0x99>
  801492:	89 f8                	mov    %edi,%eax
  801494:	c1 e8 0c             	shr    $0xc,%eax
  801497:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80149e:	f6 c2 01             	test   $0x1,%dl
  8014a1:	74 26                	je     8014c9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b2:	50                   	push   %eax
  8014b3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b6:	6a 00                	push   $0x0
  8014b8:	57                   	push   %edi
  8014b9:	6a 00                	push   $0x0
  8014bb:	e8 a0 f8 ff ff       	call   800d60 <sys_page_map>
  8014c0:	89 c7                	mov    %eax,%edi
  8014c2:	83 c4 20             	add    $0x20,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 2e                	js     8014f7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014cc:	89 d0                	mov    %edx,%eax
  8014ce:	c1 e8 0c             	shr    $0xc,%eax
  8014d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e0:	50                   	push   %eax
  8014e1:	53                   	push   %ebx
  8014e2:	6a 00                	push   $0x0
  8014e4:	52                   	push   %edx
  8014e5:	6a 00                	push   $0x0
  8014e7:	e8 74 f8 ff ff       	call   800d60 <sys_page_map>
  8014ec:	89 c7                	mov    %eax,%edi
  8014ee:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014f1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f3:	85 ff                	test   %edi,%edi
  8014f5:	79 1d                	jns    801514 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	53                   	push   %ebx
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 a0 f8 ff ff       	call   800da2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801502:	83 c4 08             	add    $0x8,%esp
  801505:	ff 75 d4             	pushl  -0x2c(%ebp)
  801508:	6a 00                	push   $0x0
  80150a:	e8 93 f8 ff ff       	call   800da2 <sys_page_unmap>
	return r;
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	89 f8                	mov    %edi,%eax
}
  801514:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5f                   	pop    %edi
  80151a:	5d                   	pop    %ebp
  80151b:	c3                   	ret    

0080151c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	53                   	push   %ebx
  801520:	83 ec 14             	sub    $0x14,%esp
  801523:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801526:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	53                   	push   %ebx
  80152b:	e8 86 fd ff ff       	call   8012b6 <fd_lookup>
  801530:	83 c4 08             	add    $0x8,%esp
  801533:	89 c2                	mov    %eax,%edx
  801535:	85 c0                	test   %eax,%eax
  801537:	78 6d                	js     8015a6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801543:	ff 30                	pushl  (%eax)
  801545:	e8 c2 fd ff ff       	call   80130c <dev_lookup>
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 4c                	js     80159d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801551:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801554:	8b 42 08             	mov    0x8(%edx),%eax
  801557:	83 e0 03             	and    $0x3,%eax
  80155a:	83 f8 01             	cmp    $0x1,%eax
  80155d:	75 21                	jne    801580 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155f:	a1 04 40 80 00       	mov    0x804004,%eax
  801564:	8b 40 54             	mov    0x54(%eax),%eax
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	53                   	push   %ebx
  80156b:	50                   	push   %eax
  80156c:	68 6c 28 80 00       	push   $0x80286c
  801571:	e8 1f ee ff ff       	call   800395 <cprintf>
		return -E_INVAL;
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157e:	eb 26                	jmp    8015a6 <read+0x8a>
	}
	if (!dev->dev_read)
  801580:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801583:	8b 40 08             	mov    0x8(%eax),%eax
  801586:	85 c0                	test   %eax,%eax
  801588:	74 17                	je     8015a1 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80158a:	83 ec 04             	sub    $0x4,%esp
  80158d:	ff 75 10             	pushl  0x10(%ebp)
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	52                   	push   %edx
  801594:	ff d0                	call   *%eax
  801596:	89 c2                	mov    %eax,%edx
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	eb 09                	jmp    8015a6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	eb 05                	jmp    8015a6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015a6:	89 d0                	mov    %edx,%eax
  8015a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	57                   	push   %edi
  8015b1:	56                   	push   %esi
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 0c             	sub    $0xc,%esp
  8015b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c1:	eb 21                	jmp    8015e4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	89 f0                	mov    %esi,%eax
  8015c8:	29 d8                	sub    %ebx,%eax
  8015ca:	50                   	push   %eax
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	03 45 0c             	add    0xc(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	57                   	push   %edi
  8015d2:	e8 45 ff ff ff       	call   80151c <read>
		if (m < 0)
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 10                	js     8015ee <readn+0x41>
			return m;
		if (m == 0)
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 0a                	je     8015ec <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e2:	01 c3                	add    %eax,%ebx
  8015e4:	39 f3                	cmp    %esi,%ebx
  8015e6:	72 db                	jb     8015c3 <readn+0x16>
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	eb 02                	jmp    8015ee <readn+0x41>
  8015ec:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5f                   	pop    %edi
  8015f4:	5d                   	pop    %ebp
  8015f5:	c3                   	ret    

008015f6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 14             	sub    $0x14,%esp
  8015fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801600:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	53                   	push   %ebx
  801605:	e8 ac fc ff ff       	call   8012b6 <fd_lookup>
  80160a:	83 c4 08             	add    $0x8,%esp
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 68                	js     80167b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801619:	50                   	push   %eax
  80161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161d:	ff 30                	pushl  (%eax)
  80161f:	e8 e8 fc ff ff       	call   80130c <dev_lookup>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 47                	js     801672 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801632:	75 21                	jne    801655 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801634:	a1 04 40 80 00       	mov    0x804004,%eax
  801639:	8b 40 54             	mov    0x54(%eax),%eax
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	53                   	push   %ebx
  801640:	50                   	push   %eax
  801641:	68 88 28 80 00       	push   $0x802888
  801646:	e8 4a ed ff ff       	call   800395 <cprintf>
		return -E_INVAL;
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801653:	eb 26                	jmp    80167b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801655:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801658:	8b 52 0c             	mov    0xc(%edx),%edx
  80165b:	85 d2                	test   %edx,%edx
  80165d:	74 17                	je     801676 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	50                   	push   %eax
  801669:	ff d2                	call   *%edx
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	eb 09                	jmp    80167b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	89 c2                	mov    %eax,%edx
  801674:	eb 05                	jmp    80167b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801676:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80167b:	89 d0                	mov    %edx,%eax
  80167d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <seek>:

int
seek(int fdnum, off_t offset)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801688:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	ff 75 08             	pushl  0x8(%ebp)
  80168f:	e8 22 fc ff ff       	call   8012b6 <fd_lookup>
  801694:	83 c4 08             	add    $0x8,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 0e                	js     8016a9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80169b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 14             	sub    $0x14,%esp
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b8:	50                   	push   %eax
  8016b9:	53                   	push   %ebx
  8016ba:	e8 f7 fb ff ff       	call   8012b6 <fd_lookup>
  8016bf:	83 c4 08             	add    $0x8,%esp
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 65                	js     80172d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d2:	ff 30                	pushl  (%eax)
  8016d4:	e8 33 fc ff ff       	call   80130c <dev_lookup>
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 44                	js     801724 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e7:	75 21                	jne    80170a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ee:	8b 40 54             	mov    0x54(%eax),%eax
  8016f1:	83 ec 04             	sub    $0x4,%esp
  8016f4:	53                   	push   %ebx
  8016f5:	50                   	push   %eax
  8016f6:	68 48 28 80 00       	push   $0x802848
  8016fb:	e8 95 ec ff ff       	call   800395 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801708:	eb 23                	jmp    80172d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80170a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170d:	8b 52 18             	mov    0x18(%edx),%edx
  801710:	85 d2                	test   %edx,%edx
  801712:	74 14                	je     801728 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	50                   	push   %eax
  80171b:	ff d2                	call   *%edx
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	eb 09                	jmp    80172d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801724:	89 c2                	mov    %eax,%edx
  801726:	eb 05                	jmp    80172d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801728:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80172d:	89 d0                	mov    %edx,%eax
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 14             	sub    $0x14,%esp
  80173b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	ff 75 08             	pushl  0x8(%ebp)
  801745:	e8 6c fb ff ff       	call   8012b6 <fd_lookup>
  80174a:	83 c4 08             	add    $0x8,%esp
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 58                	js     8017ab <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801753:	83 ec 08             	sub    $0x8,%esp
  801756:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175d:	ff 30                	pushl  (%eax)
  80175f:	e8 a8 fb ff ff       	call   80130c <dev_lookup>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 37                	js     8017a2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80176b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801772:	74 32                	je     8017a6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801774:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801777:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177e:	00 00 00 
	stat->st_isdir = 0;
  801781:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801788:	00 00 00 
	stat->st_dev = dev;
  80178b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	53                   	push   %ebx
  801795:	ff 75 f0             	pushl  -0x10(%ebp)
  801798:	ff 50 14             	call   *0x14(%eax)
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	eb 09                	jmp    8017ab <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	eb 05                	jmp    8017ab <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ab:	89 d0                	mov    %edx,%eax
  8017ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	6a 00                	push   $0x0
  8017bc:	ff 75 08             	pushl  0x8(%ebp)
  8017bf:	e8 e3 01 00 00       	call   8019a7 <open>
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 1b                	js     8017e8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017cd:	83 ec 08             	sub    $0x8,%esp
  8017d0:	ff 75 0c             	pushl  0xc(%ebp)
  8017d3:	50                   	push   %eax
  8017d4:	e8 5b ff ff ff       	call   801734 <fstat>
  8017d9:	89 c6                	mov    %eax,%esi
	close(fd);
  8017db:	89 1c 24             	mov    %ebx,(%esp)
  8017de:	e8 fd fb ff ff       	call   8013e0 <close>
	return r;
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	89 f0                	mov    %esi,%eax
}
  8017e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5e                   	pop    %esi
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	56                   	push   %esi
  8017f3:	53                   	push   %ebx
  8017f4:	89 c6                	mov    %eax,%esi
  8017f6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ff:	75 12                	jne    801813 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	6a 01                	push   $0x1
  801806:	e8 88 08 00 00       	call   802093 <ipc_find_env>
  80180b:	a3 00 40 80 00       	mov    %eax,0x804000
  801810:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801813:	6a 07                	push   $0x7
  801815:	68 00 50 80 00       	push   $0x805000
  80181a:	56                   	push   %esi
  80181b:	ff 35 00 40 80 00    	pushl  0x804000
  801821:	e8 0b 08 00 00       	call   802031 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801826:	83 c4 0c             	add    $0xc,%esp
  801829:	6a 00                	push   $0x0
  80182b:	53                   	push   %ebx
  80182c:	6a 00                	push   $0x0
  80182e:	e8 86 07 00 00       	call   801fb9 <ipc_recv>
}
  801833:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	8b 40 0c             	mov    0xc(%eax),%eax
  801846:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80184b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801853:	ba 00 00 00 00       	mov    $0x0,%edx
  801858:	b8 02 00 00 00       	mov    $0x2,%eax
  80185d:	e8 8d ff ff ff       	call   8017ef <fsipc>
}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 06 00 00 00       	mov    $0x6,%eax
  80187f:	e8 6b ff ff ff       	call   8017ef <fsipc>
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	53                   	push   %ebx
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	8b 40 0c             	mov    0xc(%eax),%eax
  801896:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a5:	e8 45 ff ff ff       	call   8017ef <fsipc>
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 2c                	js     8018da <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	68 00 50 80 00       	push   $0x805000
  8018b6:	53                   	push   %ebx
  8018b7:	e8 5e f0 ff ff       	call   80091a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018bc:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c7:	a1 84 50 80 00       	mov    0x805084,%eax
  8018cc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ee:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018f4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018f9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018fe:	0f 47 c2             	cmova  %edx,%eax
  801901:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801906:	50                   	push   %eax
  801907:	ff 75 0c             	pushl  0xc(%ebp)
  80190a:	68 08 50 80 00       	push   $0x805008
  80190f:	e8 98 f1 ff ff       	call   800aac <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801914:	ba 00 00 00 00       	mov    $0x0,%edx
  801919:	b8 04 00 00 00       	mov    $0x4,%eax
  80191e:	e8 cc fe ff ff       	call   8017ef <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801923:	c9                   	leave  
  801924:	c3                   	ret    

00801925 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	8b 40 0c             	mov    0xc(%eax),%eax
  801933:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801938:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80193e:	ba 00 00 00 00       	mov    $0x0,%edx
  801943:	b8 03 00 00 00       	mov    $0x3,%eax
  801948:	e8 a2 fe ff ff       	call   8017ef <fsipc>
  80194d:	89 c3                	mov    %eax,%ebx
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 4b                	js     80199e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801953:	39 c6                	cmp    %eax,%esi
  801955:	73 16                	jae    80196d <devfile_read+0x48>
  801957:	68 b8 28 80 00       	push   $0x8028b8
  80195c:	68 bf 28 80 00       	push   $0x8028bf
  801961:	6a 7c                	push   $0x7c
  801963:	68 d4 28 80 00       	push   $0x8028d4
  801968:	e8 4f e9 ff ff       	call   8002bc <_panic>
	assert(r <= PGSIZE);
  80196d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801972:	7e 16                	jle    80198a <devfile_read+0x65>
  801974:	68 df 28 80 00       	push   $0x8028df
  801979:	68 bf 28 80 00       	push   $0x8028bf
  80197e:	6a 7d                	push   $0x7d
  801980:	68 d4 28 80 00       	push   $0x8028d4
  801985:	e8 32 e9 ff ff       	call   8002bc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	50                   	push   %eax
  80198e:	68 00 50 80 00       	push   $0x805000
  801993:	ff 75 0c             	pushl  0xc(%ebp)
  801996:	e8 11 f1 ff ff       	call   800aac <memmove>
	return r;
  80199b:	83 c4 10             	add    $0x10,%esp
}
  80199e:	89 d8                	mov    %ebx,%eax
  8019a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 20             	sub    $0x20,%esp
  8019ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b1:	53                   	push   %ebx
  8019b2:	e8 2a ef ff ff       	call   8008e1 <strlen>
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019bf:	7f 67                	jg     801a28 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	50                   	push   %eax
  8019c8:	e8 9a f8 ff ff       	call   801267 <fd_alloc>
  8019cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	78 57                	js     801a2d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019d6:	83 ec 08             	sub    $0x8,%esp
  8019d9:	53                   	push   %ebx
  8019da:	68 00 50 80 00       	push   $0x805000
  8019df:	e8 36 ef ff ff       	call   80091a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f4:	e8 f6 fd ff ff       	call   8017ef <fsipc>
  8019f9:	89 c3                	mov    %eax,%ebx
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	79 14                	jns    801a16 <open+0x6f>
		fd_close(fd, 0);
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	6a 00                	push   $0x0
  801a07:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0a:	e8 50 f9 ff ff       	call   80135f <fd_close>
		return r;
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	89 da                	mov    %ebx,%edx
  801a14:	eb 17                	jmp    801a2d <open+0x86>
	}

	return fd2num(fd);
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1c:	e8 1f f8 ff ff       	call   801240 <fd2num>
  801a21:	89 c2                	mov    %eax,%edx
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	eb 05                	jmp    801a2d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a28:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a2d:	89 d0                	mov    %edx,%eax
  801a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a44:	e8 a6 fd ff ff       	call   8017ef <fsipc>
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	ff 75 08             	pushl  0x8(%ebp)
  801a59:	e8 f2 f7 ff ff       	call   801250 <fd2data>
  801a5e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a60:	83 c4 08             	add    $0x8,%esp
  801a63:	68 eb 28 80 00       	push   $0x8028eb
  801a68:	53                   	push   %ebx
  801a69:	e8 ac ee ff ff       	call   80091a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a6e:	8b 46 04             	mov    0x4(%esi),%eax
  801a71:	2b 06                	sub    (%esi),%eax
  801a73:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a79:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a80:	00 00 00 
	stat->st_dev = &devpipe;
  801a83:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a8a:	30 80 00 
	return 0;
}
  801a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa3:	53                   	push   %ebx
  801aa4:	6a 00                	push   $0x0
  801aa6:	e8 f7 f2 ff ff       	call   800da2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aab:	89 1c 24             	mov    %ebx,(%esp)
  801aae:	e8 9d f7 ff ff       	call   801250 <fd2data>
  801ab3:	83 c4 08             	add    $0x8,%esp
  801ab6:	50                   	push   %eax
  801ab7:	6a 00                	push   $0x0
  801ab9:	e8 e4 f2 ff ff       	call   800da2 <sys_page_unmap>
}
  801abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	57                   	push   %edi
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	83 ec 1c             	sub    $0x1c,%esp
  801acc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801acf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ad1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad6:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	ff 75 e0             	pushl  -0x20(%ebp)
  801adf:	e8 ef 05 00 00       	call   8020d3 <pageref>
  801ae4:	89 c3                	mov    %eax,%ebx
  801ae6:	89 3c 24             	mov    %edi,(%esp)
  801ae9:	e8 e5 05 00 00       	call   8020d3 <pageref>
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	39 c3                	cmp    %eax,%ebx
  801af3:	0f 94 c1             	sete   %cl
  801af6:	0f b6 c9             	movzbl %cl,%ecx
  801af9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801afc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b02:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801b05:	39 ce                	cmp    %ecx,%esi
  801b07:	74 1b                	je     801b24 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b09:	39 c3                	cmp    %eax,%ebx
  801b0b:	75 c4                	jne    801ad1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b0d:	8b 42 64             	mov    0x64(%edx),%eax
  801b10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b13:	50                   	push   %eax
  801b14:	56                   	push   %esi
  801b15:	68 f2 28 80 00       	push   $0x8028f2
  801b1a:	e8 76 e8 ff ff       	call   800395 <cprintf>
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	eb ad                	jmp    801ad1 <_pipeisclosed+0xe>
	}
}
  801b24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2a:	5b                   	pop    %ebx
  801b2b:	5e                   	pop    %esi
  801b2c:	5f                   	pop    %edi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	57                   	push   %edi
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	83 ec 28             	sub    $0x28,%esp
  801b38:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b3b:	56                   	push   %esi
  801b3c:	e8 0f f7 ff ff       	call   801250 <fd2data>
  801b41:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	bf 00 00 00 00       	mov    $0x0,%edi
  801b4b:	eb 4b                	jmp    801b98 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b4d:	89 da                	mov    %ebx,%edx
  801b4f:	89 f0                	mov    %esi,%eax
  801b51:	e8 6d ff ff ff       	call   801ac3 <_pipeisclosed>
  801b56:	85 c0                	test   %eax,%eax
  801b58:	75 48                	jne    801ba2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b5a:	e8 9f f1 ff ff       	call   800cfe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b5f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b62:	8b 0b                	mov    (%ebx),%ecx
  801b64:	8d 51 20             	lea    0x20(%ecx),%edx
  801b67:	39 d0                	cmp    %edx,%eax
  801b69:	73 e2                	jae    801b4d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b75:	89 c2                	mov    %eax,%edx
  801b77:	c1 fa 1f             	sar    $0x1f,%edx
  801b7a:	89 d1                	mov    %edx,%ecx
  801b7c:	c1 e9 1b             	shr    $0x1b,%ecx
  801b7f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b82:	83 e2 1f             	and    $0x1f,%edx
  801b85:	29 ca                	sub    %ecx,%edx
  801b87:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b8b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b8f:	83 c0 01             	add    $0x1,%eax
  801b92:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b95:	83 c7 01             	add    $0x1,%edi
  801b98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b9b:	75 c2                	jne    801b5f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba0:	eb 05                	jmp    801ba7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801baa:	5b                   	pop    %ebx
  801bab:	5e                   	pop    %esi
  801bac:	5f                   	pop    %edi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	57                   	push   %edi
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 18             	sub    $0x18,%esp
  801bb8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bbb:	57                   	push   %edi
  801bbc:	e8 8f f6 ff ff       	call   801250 <fd2data>
  801bc1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bcb:	eb 3d                	jmp    801c0a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bcd:	85 db                	test   %ebx,%ebx
  801bcf:	74 04                	je     801bd5 <devpipe_read+0x26>
				return i;
  801bd1:	89 d8                	mov    %ebx,%eax
  801bd3:	eb 44                	jmp    801c19 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bd5:	89 f2                	mov    %esi,%edx
  801bd7:	89 f8                	mov    %edi,%eax
  801bd9:	e8 e5 fe ff ff       	call   801ac3 <_pipeisclosed>
  801bde:	85 c0                	test   %eax,%eax
  801be0:	75 32                	jne    801c14 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801be2:	e8 17 f1 ff ff       	call   800cfe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801be7:	8b 06                	mov    (%esi),%eax
  801be9:	3b 46 04             	cmp    0x4(%esi),%eax
  801bec:	74 df                	je     801bcd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bee:	99                   	cltd   
  801bef:	c1 ea 1b             	shr    $0x1b,%edx
  801bf2:	01 d0                	add    %edx,%eax
  801bf4:	83 e0 1f             	and    $0x1f,%eax
  801bf7:	29 d0                	sub    %edx,%eax
  801bf9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c01:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c04:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c07:	83 c3 01             	add    $0x1,%ebx
  801c0a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c0d:	75 d8                	jne    801be7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c12:	eb 05                	jmp    801c19 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c14:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5f                   	pop    %edi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2c:	50                   	push   %eax
  801c2d:	e8 35 f6 ff ff       	call   801267 <fd_alloc>
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	89 c2                	mov    %eax,%edx
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 2c 01 00 00    	js     801d6b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	68 07 04 00 00       	push   $0x407
  801c47:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 cc f0 ff ff       	call   800d1d <sys_page_alloc>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	85 c0                	test   %eax,%eax
  801c58:	0f 88 0d 01 00 00    	js     801d6b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c64:	50                   	push   %eax
  801c65:	e8 fd f5 ff ff       	call   801267 <fd_alloc>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	0f 88 e2 00 00 00    	js     801d59 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	68 07 04 00 00       	push   $0x407
  801c7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c82:	6a 00                	push   $0x0
  801c84:	e8 94 f0 ff ff       	call   800d1d <sys_page_alloc>
  801c89:	89 c3                	mov    %eax,%ebx
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	0f 88 c3 00 00 00    	js     801d59 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9c:	e8 af f5 ff ff       	call   801250 <fd2data>
  801ca1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca3:	83 c4 0c             	add    $0xc,%esp
  801ca6:	68 07 04 00 00       	push   $0x407
  801cab:	50                   	push   %eax
  801cac:	6a 00                	push   $0x0
  801cae:	e8 6a f0 ff ff       	call   800d1d <sys_page_alloc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	0f 88 89 00 00 00    	js     801d49 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc0:	83 ec 0c             	sub    $0xc,%esp
  801cc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc6:	e8 85 f5 ff ff       	call   801250 <fd2data>
  801ccb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cd2:	50                   	push   %eax
  801cd3:	6a 00                	push   $0x0
  801cd5:	56                   	push   %esi
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 83 f0 ff ff       	call   800d60 <sys_page_map>
  801cdd:	89 c3                	mov    %eax,%ebx
  801cdf:	83 c4 20             	add    $0x20,%esp
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	78 55                	js     801d3b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ce6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cef:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cfb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d04:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d09:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d10:	83 ec 0c             	sub    $0xc,%esp
  801d13:	ff 75 f4             	pushl  -0xc(%ebp)
  801d16:	e8 25 f5 ff ff       	call   801240 <fd2num>
  801d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d20:	83 c4 04             	add    $0x4,%esp
  801d23:	ff 75 f0             	pushl  -0x10(%ebp)
  801d26:	e8 15 f5 ff ff       	call   801240 <fd2num>
  801d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d2e:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	ba 00 00 00 00       	mov    $0x0,%edx
  801d39:	eb 30                	jmp    801d6b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d3b:	83 ec 08             	sub    $0x8,%esp
  801d3e:	56                   	push   %esi
  801d3f:	6a 00                	push   $0x0
  801d41:	e8 5c f0 ff ff       	call   800da2 <sys_page_unmap>
  801d46:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d49:	83 ec 08             	sub    $0x8,%esp
  801d4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 4c f0 ff ff       	call   800da2 <sys_page_unmap>
  801d56:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d59:	83 ec 08             	sub    $0x8,%esp
  801d5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 3c f0 ff ff       	call   800da2 <sys_page_unmap>
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    

00801d74 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7d:	50                   	push   %eax
  801d7e:	ff 75 08             	pushl  0x8(%ebp)
  801d81:	e8 30 f5 ff ff       	call   8012b6 <fd_lookup>
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	78 18                	js     801da5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	ff 75 f4             	pushl  -0xc(%ebp)
  801d93:	e8 b8 f4 ff ff       	call   801250 <fd2data>
	return _pipeisclosed(fd, p);
  801d98:	89 c2                	mov    %eax,%edx
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	e8 21 fd ff ff       	call   801ac3 <_pipeisclosed>
  801da2:	83 c4 10             	add    $0x10,%esp
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801db7:	68 05 29 80 00       	push   $0x802905
  801dbc:	ff 75 0c             	pushl  0xc(%ebp)
  801dbf:	e8 56 eb ff ff       	call   80091a <strcpy>
	return 0;
}
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	57                   	push   %edi
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de2:	eb 2d                	jmp    801e11 <devcons_write+0x46>
		m = n - tot;
  801de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801de7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801de9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dec:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801df1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df4:	83 ec 04             	sub    $0x4,%esp
  801df7:	53                   	push   %ebx
  801df8:	03 45 0c             	add    0xc(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	57                   	push   %edi
  801dfd:	e8 aa ec ff ff       	call   800aac <memmove>
		sys_cputs(buf, m);
  801e02:	83 c4 08             	add    $0x8,%esp
  801e05:	53                   	push   %ebx
  801e06:	57                   	push   %edi
  801e07:	e8 55 ee ff ff       	call   800c61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0c:	01 de                	add    %ebx,%esi
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e16:	72 cc                	jb     801de4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5e                   	pop    %esi
  801e1d:	5f                   	pop    %edi
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e2f:	74 2a                	je     801e5b <devcons_read+0x3b>
  801e31:	eb 05                	jmp    801e38 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e33:	e8 c6 ee ff ff       	call   800cfe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e38:	e8 42 ee ff ff       	call   800c7f <sys_cgetc>
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	74 f2                	je     801e33 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e41:	85 c0                	test   %eax,%eax
  801e43:	78 16                	js     801e5b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e45:	83 f8 04             	cmp    $0x4,%eax
  801e48:	74 0c                	je     801e56 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4d:	88 02                	mov    %al,(%edx)
	return 1;
  801e4f:	b8 01 00 00 00       	mov    $0x1,%eax
  801e54:	eb 05                	jmp    801e5b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e56:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e69:	6a 01                	push   $0x1
  801e6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6e:	50                   	push   %eax
  801e6f:	e8 ed ed ff ff       	call   800c61 <sys_cputs>
}
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <getchar>:

int
getchar(void)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e7f:	6a 01                	push   $0x1
  801e81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	6a 00                	push   $0x0
  801e87:	e8 90 f6 ff ff       	call   80151c <read>
	if (r < 0)
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 0f                	js     801ea2 <getchar+0x29>
		return r;
	if (r < 1)
  801e93:	85 c0                	test   %eax,%eax
  801e95:	7e 06                	jle    801e9d <getchar+0x24>
		return -E_EOF;
	return c;
  801e97:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e9b:	eb 05                	jmp    801ea2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e9d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ead:	50                   	push   %eax
  801eae:	ff 75 08             	pushl  0x8(%ebp)
  801eb1:	e8 00 f4 ff ff       	call   8012b6 <fd_lookup>
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 11                	js     801ece <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec6:	39 10                	cmp    %edx,(%eax)
  801ec8:	0f 94 c0             	sete   %al
  801ecb:	0f b6 c0             	movzbl %al,%eax
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <opencons>:

int
opencons(void)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed9:	50                   	push   %eax
  801eda:	e8 88 f3 ff ff       	call   801267 <fd_alloc>
  801edf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 3e                	js     801f26 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	68 07 04 00 00       	push   $0x407
  801ef0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 23 ee ff ff       	call   800d1d <sys_page_alloc>
  801efa:	83 c4 10             	add    $0x10,%esp
		return r;
  801efd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 23                	js     801f26 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f03:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f11:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	50                   	push   %eax
  801f1c:	e8 1f f3 ff ff       	call   801240 <fd2num>
  801f21:	89 c2                	mov    %eax,%edx
  801f23:	83 c4 10             	add    $0x10,%esp
}
  801f26:	89 d0                	mov    %edx,%eax
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f30:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f37:	75 2a                	jne    801f63 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	6a 07                	push   $0x7
  801f3e:	68 00 f0 bf ee       	push   $0xeebff000
  801f43:	6a 00                	push   $0x0
  801f45:	e8 d3 ed ff ff       	call   800d1d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	79 12                	jns    801f63 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f51:	50                   	push   %eax
  801f52:	68 11 29 80 00       	push   $0x802911
  801f57:	6a 23                	push   $0x23
  801f59:	68 15 29 80 00       	push   $0x802915
  801f5e:	e8 59 e3 ff ff       	call   8002bc <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f63:	8b 45 08             	mov    0x8(%ebp),%eax
  801f66:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f6b:	83 ec 08             	sub    $0x8,%esp
  801f6e:	68 95 1f 80 00       	push   $0x801f95
  801f73:	6a 00                	push   $0x0
  801f75:	e8 ee ee ff ff       	call   800e68 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	79 12                	jns    801f93 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f81:	50                   	push   %eax
  801f82:	68 11 29 80 00       	push   $0x802911
  801f87:	6a 2c                	push   $0x2c
  801f89:	68 15 29 80 00       	push   $0x802915
  801f8e:	e8 29 e3 ff ff       	call   8002bc <_panic>
	}
}
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    

00801f95 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f95:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f96:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f9b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f9d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fa0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fa4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fa9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fad:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801faf:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fb2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801fb3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fb6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fb7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fb8:	c3                   	ret    

00801fb9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	75 12                	jne    801fdd <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	68 00 00 c0 ee       	push   $0xeec00000
  801fd3:	e8 f5 ee ff ff       	call   800ecd <sys_ipc_recv>
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	eb 0c                	jmp    801fe9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801fdd:	83 ec 0c             	sub    $0xc,%esp
  801fe0:	50                   	push   %eax
  801fe1:	e8 e7 ee ff ff       	call   800ecd <sys_ipc_recv>
  801fe6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801fe9:	85 f6                	test   %esi,%esi
  801feb:	0f 95 c1             	setne  %cl
  801fee:	85 db                	test   %ebx,%ebx
  801ff0:	0f 95 c2             	setne  %dl
  801ff3:	84 d1                	test   %dl,%cl
  801ff5:	74 09                	je     802000 <ipc_recv+0x47>
  801ff7:	89 c2                	mov    %eax,%edx
  801ff9:	c1 ea 1f             	shr    $0x1f,%edx
  801ffc:	84 d2                	test   %dl,%dl
  801ffe:	75 2a                	jne    80202a <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802000:	85 f6                	test   %esi,%esi
  802002:	74 0d                	je     802011 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802004:	a1 04 40 80 00       	mov    0x804004,%eax
  802009:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80200f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802011:	85 db                	test   %ebx,%ebx
  802013:	74 0d                	je     802022 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802015:	a1 04 40 80 00       	mov    0x804004,%eax
  80201a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802020:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802022:	a1 04 40 80 00       	mov    0x804004,%eax
  802027:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  80202a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5d                   	pop    %ebp
  802030:	c3                   	ret    

00802031 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	57                   	push   %edi
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	83 ec 0c             	sub    $0xc,%esp
  80203a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80203d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802040:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802043:	85 db                	test   %ebx,%ebx
  802045:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80204a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80204d:	ff 75 14             	pushl  0x14(%ebp)
  802050:	53                   	push   %ebx
  802051:	56                   	push   %esi
  802052:	57                   	push   %edi
  802053:	e8 52 ee ff ff       	call   800eaa <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802058:	89 c2                	mov    %eax,%edx
  80205a:	c1 ea 1f             	shr    $0x1f,%edx
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	84 d2                	test   %dl,%dl
  802062:	74 17                	je     80207b <ipc_send+0x4a>
  802064:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802067:	74 12                	je     80207b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802069:	50                   	push   %eax
  80206a:	68 23 29 80 00       	push   $0x802923
  80206f:	6a 47                	push   $0x47
  802071:	68 31 29 80 00       	push   $0x802931
  802076:	e8 41 e2 ff ff       	call   8002bc <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80207b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207e:	75 07                	jne    802087 <ipc_send+0x56>
			sys_yield();
  802080:	e8 79 ec ff ff       	call   800cfe <sys_yield>
  802085:	eb c6                	jmp    80204d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802087:	85 c0                	test   %eax,%eax
  802089:	75 c2                	jne    80204d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80208b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208e:	5b                   	pop    %ebx
  80208f:	5e                   	pop    %esi
  802090:	5f                   	pop    %edi
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    

00802093 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802099:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80209e:	89 c2                	mov    %eax,%edx
  8020a0:	c1 e2 07             	shl    $0x7,%edx
  8020a3:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8020aa:	8b 52 5c             	mov    0x5c(%edx),%edx
  8020ad:	39 ca                	cmp    %ecx,%edx
  8020af:	75 11                	jne    8020c2 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8020b1:	89 c2                	mov    %eax,%edx
  8020b3:	c1 e2 07             	shl    $0x7,%edx
  8020b6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8020bd:	8b 40 54             	mov    0x54(%eax),%eax
  8020c0:	eb 0f                	jmp    8020d1 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c2:	83 c0 01             	add    $0x1,%eax
  8020c5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020ca:	75 d2                	jne    80209e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d1:	5d                   	pop    %ebp
  8020d2:	c3                   	ret    

008020d3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d9:	89 d0                	mov    %edx,%eax
  8020db:	c1 e8 16             	shr    $0x16,%eax
  8020de:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020e5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ea:	f6 c1 01             	test   $0x1,%cl
  8020ed:	74 1d                	je     80210c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ef:	c1 ea 0c             	shr    $0xc,%edx
  8020f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f9:	f6 c2 01             	test   $0x1,%dl
  8020fc:	74 0e                	je     80210c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020fe:	c1 ea 0c             	shr    $0xc,%edx
  802101:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802108:	ef 
  802109:	0f b7 c0             	movzwl %ax,%eax
}
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
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
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
