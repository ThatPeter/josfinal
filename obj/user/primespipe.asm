
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
  80004c:	e8 6e 15 00 00       	call   8015bf <readn>
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
  800068:	68 c0 23 80 00       	push   $0x8023c0
  80006d:	6a 15                	push   $0x15
  80006f:	68 ef 23 80 00       	push   $0x8023ef
  800074:	e8 7f 02 00 00       	call   8002f8 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 01 24 80 00       	push   $0x802401
  800084:	e8 48 03 00 00       	call   8003d1 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 a2 1b 00 00       	call   801c33 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 05 24 80 00       	push   $0x802405
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 ef 23 80 00       	push   $0x8023ef
  8000a8:	e8 4b 02 00 00       	call   8002f8 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 8e 0f 00 00       	call   801040 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 0e 24 80 00       	push   $0x80240e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 ef 23 80 00       	push   $0x8023ef
  8000c3:	e8 30 02 00 00       	call   8002f8 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 1d 13 00 00       	call   8013f2 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 12 13 00 00       	call   8013f2 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 fc 12 00 00       	call   8013f2 <close>
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
  800106:	e8 b4 14 00 00       	call   8015bf <readn>
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
  800126:	68 17 24 80 00       	push   $0x802417
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 ef 23 80 00       	push   $0x8023ef
  800132:	e8 c1 01 00 00       	call   8002f8 <_panic>
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
  800149:	e8 ba 14 00 00       	call   801608 <write>
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
  800168:	68 33 24 80 00       	push   $0x802433
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 ef 23 80 00       	push   $0x8023ef
  800174:	e8 7f 01 00 00       	call   8002f8 <_panic>

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
  800180:	c7 05 00 30 80 00 4d 	movl   $0x80244d,0x803000
  800187:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 a0 1a 00 00       	call   801c33 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 05 24 80 00       	push   $0x802405
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 ef 23 80 00       	push   $0x8023ef
  8001aa:	e8 49 01 00 00       	call   8002f8 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 8c 0e 00 00       	call   801040 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 0e 24 80 00       	push   $0x80240e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 ef 23 80 00       	push   $0x8023ef
  8001c5:	e8 2e 01 00 00       	call   8002f8 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 19 12 00 00       	call   8013f2 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 03 12 00 00       	call   8013f2 <close>

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
  800205:	e8 fe 13 00 00       	call   801608 <write>
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
  800221:	68 58 24 80 00       	push   $0x802458
  800226:	6a 4a                	push   $0x4a
  800228:	68 ef 23 80 00       	push   $0x8023ef
  80022d:	e8 c6 00 00 00       	call   8002f8 <_panic>
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
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800241:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800248:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80024b:	e8 cb 0a 00 00       	call   800d1b <sys_getenvid>
  800250:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	50                   	push   %eax
  800256:	68 70 24 80 00       	push   $0x802470
  80025b:	e8 71 01 00 00       	call   8003d1 <cprintf>
  800260:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800266:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800273:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800278:	89 c1                	mov    %eax,%ecx
  80027a:	c1 e1 07             	shl    $0x7,%ecx
  80027d:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800284:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800287:	39 cb                	cmp    %ecx,%ebx
  800289:	0f 44 fa             	cmove  %edx,%edi
  80028c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800291:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800294:	83 c0 01             	add    $0x1,%eax
  800297:	81 c2 84 00 00 00    	add    $0x84,%edx
  80029d:	3d 00 04 00 00       	cmp    $0x400,%eax
  8002a2:	75 d4                	jne    800278 <libmain+0x40>
  8002a4:	89 f0                	mov    %esi,%eax
  8002a6:	84 c0                	test   %al,%al
  8002a8:	74 06                	je     8002b0 <libmain+0x78>
  8002aa:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8002b4:	7e 0a                	jle    8002c0 <libmain+0x88>
		binaryname = argv[0];
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b9:	8b 00                	mov    (%eax),%eax
  8002bb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 0c             	pushl  0xc(%ebp)
  8002c6:	ff 75 08             	pushl  0x8(%ebp)
  8002c9:	e8 ab fe ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  8002ce:	e8 0b 00 00 00       	call   8002de <exit>
}
  8002d3:	83 c4 10             	add    $0x10,%esp
  8002d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002e4:	e8 34 11 00 00       	call   80141d <close_all>
	sys_env_destroy(0);
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	6a 00                	push   $0x0
  8002ee:	e8 e7 09 00 00       	call   800cda <sys_env_destroy>
}
  8002f3:	83 c4 10             	add    $0x10,%esp
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002fd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800300:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800306:	e8 10 0a 00 00       	call   800d1b <sys_getenvid>
  80030b:	83 ec 0c             	sub    $0xc,%esp
  80030e:	ff 75 0c             	pushl  0xc(%ebp)
  800311:	ff 75 08             	pushl  0x8(%ebp)
  800314:	56                   	push   %esi
  800315:	50                   	push   %eax
  800316:	68 9c 24 80 00       	push   $0x80249c
  80031b:	e8 b1 00 00 00       	call   8003d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800320:	83 c4 18             	add    $0x18,%esp
  800323:	53                   	push   %ebx
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	e8 54 00 00 00       	call   800380 <vcprintf>
	cprintf("\n");
  80032c:	c7 04 24 03 24 80 00 	movl   $0x802403,(%esp)
  800333:	e8 99 00 00 00       	call   8003d1 <cprintf>
  800338:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033b:	cc                   	int3   
  80033c:	eb fd                	jmp    80033b <_panic+0x43>

0080033e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	53                   	push   %ebx
  800342:	83 ec 04             	sub    $0x4,%esp
  800345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800348:	8b 13                	mov    (%ebx),%edx
  80034a:	8d 42 01             	lea    0x1(%edx),%eax
  80034d:	89 03                	mov    %eax,(%ebx)
  80034f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800352:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800356:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035b:	75 1a                	jne    800377 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	68 ff 00 00 00       	push   $0xff
  800365:	8d 43 08             	lea    0x8(%ebx),%eax
  800368:	50                   	push   %eax
  800369:	e8 2f 09 00 00       	call   800c9d <sys_cputs>
		b->idx = 0;
  80036e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800374:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800377:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800389:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800390:	00 00 00 
	b.cnt = 0;
  800393:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80039d:	ff 75 0c             	pushl  0xc(%ebp)
  8003a0:	ff 75 08             	pushl  0x8(%ebp)
  8003a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a9:	50                   	push   %eax
  8003aa:	68 3e 03 80 00       	push   $0x80033e
  8003af:	e8 54 01 00 00       	call   800508 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b4:	83 c4 08             	add    $0x8,%esp
  8003b7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	e8 d4 08 00 00       	call   800c9d <sys_cputs>

	return b.cnt;
}
  8003c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003cf:	c9                   	leave  
  8003d0:	c3                   	ret    

008003d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 9d ff ff ff       	call   800380 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
  8003eb:	83 ec 1c             	sub    $0x1c,%esp
  8003ee:	89 c7                	mov    %eax,%edi
  8003f0:	89 d6                	mov    %edx,%esi
  8003f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800401:	bb 00 00 00 00       	mov    $0x0,%ebx
  800406:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800409:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80040c:	39 d3                	cmp    %edx,%ebx
  80040e:	72 05                	jb     800415 <printnum+0x30>
  800410:	39 45 10             	cmp    %eax,0x10(%ebp)
  800413:	77 45                	ja     80045a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800415:	83 ec 0c             	sub    $0xc,%esp
  800418:	ff 75 18             	pushl  0x18(%ebp)
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800421:	53                   	push   %ebx
  800422:	ff 75 10             	pushl  0x10(%ebp)
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042b:	ff 75 e0             	pushl  -0x20(%ebp)
  80042e:	ff 75 dc             	pushl  -0x24(%ebp)
  800431:	ff 75 d8             	pushl  -0x28(%ebp)
  800434:	e8 e7 1c 00 00       	call   802120 <__udivdi3>
  800439:	83 c4 18             	add    $0x18,%esp
  80043c:	52                   	push   %edx
  80043d:	50                   	push   %eax
  80043e:	89 f2                	mov    %esi,%edx
  800440:	89 f8                	mov    %edi,%eax
  800442:	e8 9e ff ff ff       	call   8003e5 <printnum>
  800447:	83 c4 20             	add    $0x20,%esp
  80044a:	eb 18                	jmp    800464 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	56                   	push   %esi
  800450:	ff 75 18             	pushl  0x18(%ebp)
  800453:	ff d7                	call   *%edi
  800455:	83 c4 10             	add    $0x10,%esp
  800458:	eb 03                	jmp    80045d <printnum+0x78>
  80045a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80045d:	83 eb 01             	sub    $0x1,%ebx
  800460:	85 db                	test   %ebx,%ebx
  800462:	7f e8                	jg     80044c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	56                   	push   %esi
  800468:	83 ec 04             	sub    $0x4,%esp
  80046b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff 75 dc             	pushl  -0x24(%ebp)
  800474:	ff 75 d8             	pushl  -0x28(%ebp)
  800477:	e8 d4 1d 00 00       	call   802250 <__umoddi3>
  80047c:	83 c4 14             	add    $0x14,%esp
  80047f:	0f be 80 bf 24 80 00 	movsbl 0x8024bf(%eax),%eax
  800486:	50                   	push   %eax
  800487:	ff d7                	call   *%edi
}
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048f:	5b                   	pop    %ebx
  800490:	5e                   	pop    %esi
  800491:	5f                   	pop    %edi
  800492:	5d                   	pop    %ebp
  800493:	c3                   	ret    

00800494 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800497:	83 fa 01             	cmp    $0x1,%edx
  80049a:	7e 0e                	jle    8004aa <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	8b 52 04             	mov    0x4(%edx),%edx
  8004a8:	eb 22                	jmp    8004cc <getuint+0x38>
	else if (lflag)
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	74 10                	je     8004be <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bc:	eb 0e                	jmp    8004cc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	3b 50 04             	cmp    0x4(%eax),%edx
  8004dd:	73 0a                	jae    8004e9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e2:	89 08                	mov    %ecx,(%eax)
  8004e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e7:	88 02                	mov    %al,(%edx)
}
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 10             	pushl  0x10(%ebp)
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	ff 75 08             	pushl  0x8(%ebp)
  8004fe:	e8 05 00 00 00       	call   800508 <vprintfmt>
	va_end(ap);
}
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	c9                   	leave  
  800507:	c3                   	ret    

00800508 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 2c             	sub    $0x2c,%esp
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051a:	eb 12                	jmp    80052e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051c:	85 c0                	test   %eax,%eax
  80051e:	0f 84 89 03 00 00    	je     8008ad <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	50                   	push   %eax
  800529:	ff d6                	call   *%esi
  80052b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052e:	83 c7 01             	add    $0x1,%edi
  800531:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800535:	83 f8 25             	cmp    $0x25,%eax
  800538:	75 e2                	jne    80051c <vprintfmt+0x14>
  80053a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80053e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800545:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800553:	ba 00 00 00 00       	mov    $0x0,%edx
  800558:	eb 07                	jmp    800561 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8d 47 01             	lea    0x1(%edi),%eax
  800564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800567:	0f b6 07             	movzbl (%edi),%eax
  80056a:	0f b6 c8             	movzbl %al,%ecx
  80056d:	83 e8 23             	sub    $0x23,%eax
  800570:	3c 55                	cmp    $0x55,%al
  800572:	0f 87 1a 03 00 00    	ja     800892 <vprintfmt+0x38a>
  800578:	0f b6 c0             	movzbl %al,%eax
  80057b:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800585:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800589:	eb d6                	jmp    800561 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058e:	b8 00 00 00 00       	mov    $0x0,%eax
  800593:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800596:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800599:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80059d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005a3:	83 fa 09             	cmp    $0x9,%edx
  8005a6:	77 39                	ja     8005e1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ab:	eb e9                	jmp    800596 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005be:	eb 27                	jmp    8005e7 <vprintfmt+0xdf>
  8005c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ca:	0f 49 c8             	cmovns %eax,%ecx
  8005cd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d3:	eb 8c                	jmp    800561 <vprintfmt+0x59>
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005df:	eb 80                	jmp    800561 <vprintfmt+0x59>
  8005e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005eb:	0f 89 70 ff ff ff    	jns    800561 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005fe:	e9 5e ff ff ff       	jmp    800561 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800603:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800609:	e9 53 ff ff ff       	jmp    800561 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 30                	pushl  (%eax)
  80061d:	ff d6                	call   *%esi
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800625:	e9 04 ff ff ff       	jmp    80052e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 00                	mov    (%eax),%eax
  800635:	99                   	cltd   
  800636:	31 d0                	xor    %edx,%eax
  800638:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063a:	83 f8 0f             	cmp    $0xf,%eax
  80063d:	7f 0b                	jg     80064a <vprintfmt+0x142>
  80063f:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800646:	85 d2                	test   %edx,%edx
  800648:	75 18                	jne    800662 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80064a:	50                   	push   %eax
  80064b:	68 d7 24 80 00       	push   $0x8024d7
  800650:	53                   	push   %ebx
  800651:	56                   	push   %esi
  800652:	e8 94 fe ff ff       	call   8004eb <printfmt>
  800657:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065d:	e9 cc fe ff ff       	jmp    80052e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800662:	52                   	push   %edx
  800663:	68 11 29 80 00       	push   $0x802911
  800668:	53                   	push   %ebx
  800669:	56                   	push   %esi
  80066a:	e8 7c fe ff ff       	call   8004eb <printfmt>
  80066f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800675:	e9 b4 fe ff ff       	jmp    80052e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800685:	85 ff                	test   %edi,%edi
  800687:	b8 d0 24 80 00       	mov    $0x8024d0,%eax
  80068c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80068f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800693:	0f 8e 94 00 00 00    	jle    80072d <vprintfmt+0x225>
  800699:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80069d:	0f 84 98 00 00 00    	je     80073b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a9:	57                   	push   %edi
  8006aa:	e8 86 02 00 00       	call   800935 <strnlen>
  8006af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b2:	29 c1                	sub    %eax,%ecx
  8006b4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006b7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ba:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c6:	eb 0f                	jmp    8006d7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	53                   	push   %ebx
  8006cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	83 ef 01             	sub    $0x1,%edi
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	85 ff                	test   %edi,%edi
  8006d9:	7f ed                	jg     8006c8 <vprintfmt+0x1c0>
  8006db:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006de:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e1:	85 c9                	test   %ecx,%ecx
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	0f 49 c1             	cmovns %ecx,%eax
  8006eb:	29 c1                	sub    %eax,%ecx
  8006ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f6:	89 cb                	mov    %ecx,%ebx
  8006f8:	eb 4d                	jmp    800747 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fe:	74 1b                	je     80071b <vprintfmt+0x213>
  800700:	0f be c0             	movsbl %al,%eax
  800703:	83 e8 20             	sub    $0x20,%eax
  800706:	83 f8 5e             	cmp    $0x5e,%eax
  800709:	76 10                	jbe    80071b <vprintfmt+0x213>
					putch('?', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	6a 3f                	push   $0x3f
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb 0d                	jmp    800728 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	ff 75 0c             	pushl  0xc(%ebp)
  800721:	52                   	push   %edx
  800722:	ff 55 08             	call   *0x8(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800728:	83 eb 01             	sub    $0x1,%ebx
  80072b:	eb 1a                	jmp    800747 <vprintfmt+0x23f>
  80072d:	89 75 08             	mov    %esi,0x8(%ebp)
  800730:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800733:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800736:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800739:	eb 0c                	jmp    800747 <vprintfmt+0x23f>
  80073b:	89 75 08             	mov    %esi,0x8(%ebp)
  80073e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800741:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800744:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800747:	83 c7 01             	add    $0x1,%edi
  80074a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074e:	0f be d0             	movsbl %al,%edx
  800751:	85 d2                	test   %edx,%edx
  800753:	74 23                	je     800778 <vprintfmt+0x270>
  800755:	85 f6                	test   %esi,%esi
  800757:	78 a1                	js     8006fa <vprintfmt+0x1f2>
  800759:	83 ee 01             	sub    $0x1,%esi
  80075c:	79 9c                	jns    8006fa <vprintfmt+0x1f2>
  80075e:	89 df                	mov    %ebx,%edi
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800766:	eb 18                	jmp    800780 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	53                   	push   %ebx
  80076c:	6a 20                	push   $0x20
  80076e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800770:	83 ef 01             	sub    $0x1,%edi
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 08                	jmp    800780 <vprintfmt+0x278>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	85 ff                	test   %edi,%edi
  800782:	7f e4                	jg     800768 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800787:	e9 a2 fd ff ff       	jmp    80052e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80078c:	83 fa 01             	cmp    $0x1,%edx
  80078f:	7e 16                	jle    8007a7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 08             	lea    0x8(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	8b 50 04             	mov    0x4(%eax),%edx
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a5:	eb 32                	jmp    8007d9 <vprintfmt+0x2d1>
	else if (lflag)
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	74 18                	je     8007c3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 04             	lea    0x4(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b9:	89 c1                	mov    %eax,%ecx
  8007bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c1:	eb 16                	jmp    8007d9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 50 04             	lea    0x4(%eax),%edx
  8007c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cc:	8b 00                	mov    (%eax),%eax
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	89 c1                	mov    %eax,%ecx
  8007d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007df:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e8:	79 74                	jns    80085e <vprintfmt+0x356>
				putch('-', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 2d                	push   $0x2d
  8007f0:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007f8:	f7 d8                	neg    %eax
  8007fa:	83 d2 00             	adc    $0x0,%edx
  8007fd:	f7 da                	neg    %edx
  8007ff:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800802:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800807:	eb 55                	jmp    80085e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800809:	8d 45 14             	lea    0x14(%ebp),%eax
  80080c:	e8 83 fc ff ff       	call   800494 <getuint>
			base = 10;
  800811:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800816:	eb 46                	jmp    80085e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
  80081b:	e8 74 fc ff ff       	call   800494 <getuint>
			base = 8;
  800820:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800825:	eb 37                	jmp    80085e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	6a 30                	push   $0x30
  80082d:	ff d6                	call   *%esi
			putch('x', putdat);
  80082f:	83 c4 08             	add    $0x8,%esp
  800832:	53                   	push   %ebx
  800833:	6a 78                	push   $0x78
  800835:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8d 50 04             	lea    0x4(%eax),%edx
  80083d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800840:	8b 00                	mov    (%eax),%eax
  800842:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800847:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80084a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80084f:	eb 0d                	jmp    80085e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800851:	8d 45 14             	lea    0x14(%ebp),%eax
  800854:	e8 3b fc ff ff       	call   800494 <getuint>
			base = 16;
  800859:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80085e:	83 ec 0c             	sub    $0xc,%esp
  800861:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800865:	57                   	push   %edi
  800866:	ff 75 e0             	pushl  -0x20(%ebp)
  800869:	51                   	push   %ecx
  80086a:	52                   	push   %edx
  80086b:	50                   	push   %eax
  80086c:	89 da                	mov    %ebx,%edx
  80086e:	89 f0                	mov    %esi,%eax
  800870:	e8 70 fb ff ff       	call   8003e5 <printnum>
			break;
  800875:	83 c4 20             	add    $0x20,%esp
  800878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80087b:	e9 ae fc ff ff       	jmp    80052e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	51                   	push   %ecx
  800885:	ff d6                	call   *%esi
			break;
  800887:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80088d:	e9 9c fc ff ff       	jmp    80052e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800892:	83 ec 08             	sub    $0x8,%esp
  800895:	53                   	push   %ebx
  800896:	6a 25                	push   $0x25
  800898:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	eb 03                	jmp    8008a2 <vprintfmt+0x39a>
  80089f:	83 ef 01             	sub    $0x1,%edi
  8008a2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008a6:	75 f7                	jne    80089f <vprintfmt+0x397>
  8008a8:	e9 81 fc ff ff       	jmp    80052e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5f                   	pop    %edi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 18             	sub    $0x18,%esp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d2:	85 c0                	test   %eax,%eax
  8008d4:	74 26                	je     8008fc <vsnprintf+0x47>
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	7e 22                	jle    8008fc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008da:	ff 75 14             	pushl  0x14(%ebp)
  8008dd:	ff 75 10             	pushl  0x10(%ebp)
  8008e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	68 ce 04 80 00       	push   $0x8004ce
  8008e9:	e8 1a fc ff ff       	call   800508 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	eb 05                	jmp    800901 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800909:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80090c:	50                   	push   %eax
  80090d:	ff 75 10             	pushl  0x10(%ebp)
  800910:	ff 75 0c             	pushl  0xc(%ebp)
  800913:	ff 75 08             	pushl  0x8(%ebp)
  800916:	e8 9a ff ff ff       	call   8008b5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
  800928:	eb 03                	jmp    80092d <strlen+0x10>
		n++;
  80092a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80092d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800931:	75 f7                	jne    80092a <strlen+0xd>
		n++;
	return n;
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
  800943:	eb 03                	jmp    800948 <strnlen+0x13>
		n++;
  800945:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800948:	39 c2                	cmp    %eax,%edx
  80094a:	74 08                	je     800954 <strnlen+0x1f>
  80094c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800950:	75 f3                	jne    800945 <strnlen+0x10>
  800952:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	53                   	push   %ebx
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800960:	89 c2                	mov    %eax,%edx
  800962:	83 c2 01             	add    $0x1,%edx
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80096c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80096f:	84 db                	test   %bl,%bl
  800971:	75 ef                	jne    800962 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097d:	53                   	push   %ebx
  80097e:	e8 9a ff ff ff       	call   80091d <strlen>
  800983:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800986:	ff 75 0c             	pushl  0xc(%ebp)
  800989:	01 d8                	add    %ebx,%eax
  80098b:	50                   	push   %eax
  80098c:	e8 c5 ff ff ff       	call   800956 <strcpy>
	return dst;
}
  800991:	89 d8                	mov    %ebx,%eax
  800993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a3:	89 f3                	mov    %esi,%ebx
  8009a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	eb 0f                	jmp    8009bb <strncpy+0x23>
		*dst++ = *src;
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	0f b6 01             	movzbl (%ecx),%eax
  8009b2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b5:	80 39 01             	cmpb   $0x1,(%ecx)
  8009b8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bb:	39 da                	cmp    %ebx,%edx
  8009bd:	75 ed                	jne    8009ac <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009bf:	89 f0                	mov    %esi,%eax
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8009d3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d5:	85 d2                	test   %edx,%edx
  8009d7:	74 21                	je     8009fa <strlcpy+0x35>
  8009d9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009dd:	89 f2                	mov    %esi,%edx
  8009df:	eb 09                	jmp    8009ea <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	83 c1 01             	add    $0x1,%ecx
  8009e7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ea:	39 c2                	cmp    %eax,%edx
  8009ec:	74 09                	je     8009f7 <strlcpy+0x32>
  8009ee:	0f b6 19             	movzbl (%ecx),%ebx
  8009f1:	84 db                	test   %bl,%bl
  8009f3:	75 ec                	jne    8009e1 <strlcpy+0x1c>
  8009f5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009fa:	29 f0                	sub    %esi,%eax
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a09:	eb 06                	jmp    800a11 <strcmp+0x11>
		p++, q++;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	84 c0                	test   %al,%al
  800a16:	74 04                	je     800a1c <strcmp+0x1c>
  800a18:	3a 02                	cmp    (%edx),%al
  800a1a:	74 ef                	je     800a0b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1c:	0f b6 c0             	movzbl %al,%eax
  800a1f:	0f b6 12             	movzbl (%edx),%edx
  800a22:	29 d0                	sub    %edx,%eax
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strncmp+0x17>
		n--, p++, q++;
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3d:	39 d8                	cmp    %ebx,%eax
  800a3f:	74 15                	je     800a56 <strncmp+0x30>
  800a41:	0f b6 08             	movzbl (%eax),%ecx
  800a44:	84 c9                	test   %cl,%cl
  800a46:	74 04                	je     800a4c <strncmp+0x26>
  800a48:	3a 0a                	cmp    (%edx),%cl
  800a4a:	74 eb                	je     800a37 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4c:	0f b6 00             	movzbl (%eax),%eax
  800a4f:	0f b6 12             	movzbl (%edx),%edx
  800a52:	29 d0                	sub    %edx,%eax
  800a54:	eb 05                	jmp    800a5b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a68:	eb 07                	jmp    800a71 <strchr+0x13>
		if (*s == c)
  800a6a:	38 ca                	cmp    %cl,%dl
  800a6c:	74 0f                	je     800a7d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	0f b6 10             	movzbl (%eax),%edx
  800a74:	84 d2                	test   %dl,%dl
  800a76:	75 f2                	jne    800a6a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a89:	eb 03                	jmp    800a8e <strfind+0xf>
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a91:	38 ca                	cmp    %cl,%dl
  800a93:	74 04                	je     800a99 <strfind+0x1a>
  800a95:	84 d2                	test   %dl,%dl
  800a97:	75 f2                	jne    800a8b <strfind+0xc>
			break;
	return (char *) s;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa7:	85 c9                	test   %ecx,%ecx
  800aa9:	74 36                	je     800ae1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab1:	75 28                	jne    800adb <memset+0x40>
  800ab3:	f6 c1 03             	test   $0x3,%cl
  800ab6:	75 23                	jne    800adb <memset+0x40>
		c &= 0xFF;
  800ab8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	c1 e3 08             	shl    $0x8,%ebx
  800ac1:	89 d6                	mov    %edx,%esi
  800ac3:	c1 e6 18             	shl    $0x18,%esi
  800ac6:	89 d0                	mov    %edx,%eax
  800ac8:	c1 e0 10             	shl    $0x10,%eax
  800acb:	09 f0                	or     %esi,%eax
  800acd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800acf:	89 d8                	mov    %ebx,%eax
  800ad1:	09 d0                	or     %edx,%eax
  800ad3:	c1 e9 02             	shr    $0x2,%ecx
  800ad6:	fc                   	cld    
  800ad7:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad9:	eb 06                	jmp    800ae1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	fc                   	cld    
  800adf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae1:	89 f8                	mov    %edi,%eax
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af6:	39 c6                	cmp    %eax,%esi
  800af8:	73 35                	jae    800b2f <memmove+0x47>
  800afa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800afd:	39 d0                	cmp    %edx,%eax
  800aff:	73 2e                	jae    800b2f <memmove+0x47>
		s += n;
		d += n;
  800b01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	09 fe                	or     %edi,%esi
  800b08:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0e:	75 13                	jne    800b23 <memmove+0x3b>
  800b10:	f6 c1 03             	test   $0x3,%cl
  800b13:	75 0e                	jne    800b23 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b15:	83 ef 04             	sub    $0x4,%edi
  800b18:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1b:	c1 e9 02             	shr    $0x2,%ecx
  800b1e:	fd                   	std    
  800b1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b21:	eb 09                	jmp    800b2c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b23:	83 ef 01             	sub    $0x1,%edi
  800b26:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b29:	fd                   	std    
  800b2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b2c:	fc                   	cld    
  800b2d:	eb 1d                	jmp    800b4c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2f:	89 f2                	mov    %esi,%edx
  800b31:	09 c2                	or     %eax,%edx
  800b33:	f6 c2 03             	test   $0x3,%dl
  800b36:	75 0f                	jne    800b47 <memmove+0x5f>
  800b38:	f6 c1 03             	test   $0x3,%cl
  800b3b:	75 0a                	jne    800b47 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b3d:	c1 e9 02             	shr    $0x2,%ecx
  800b40:	89 c7                	mov    %eax,%edi
  800b42:	fc                   	cld    
  800b43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b45:	eb 05                	jmp    800b4c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	fc                   	cld    
  800b4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b53:	ff 75 10             	pushl  0x10(%ebp)
  800b56:	ff 75 0c             	pushl  0xc(%ebp)
  800b59:	ff 75 08             	pushl  0x8(%ebp)
  800b5c:	e8 87 ff ff ff       	call   800ae8 <memmove>
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6e:	89 c6                	mov    %eax,%esi
  800b70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b73:	eb 1a                	jmp    800b8f <memcmp+0x2c>
		if (*s1 != *s2)
  800b75:	0f b6 08             	movzbl (%eax),%ecx
  800b78:	0f b6 1a             	movzbl (%edx),%ebx
  800b7b:	38 d9                	cmp    %bl,%cl
  800b7d:	74 0a                	je     800b89 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b7f:	0f b6 c1             	movzbl %cl,%eax
  800b82:	0f b6 db             	movzbl %bl,%ebx
  800b85:	29 d8                	sub    %ebx,%eax
  800b87:	eb 0f                	jmp    800b98 <memcmp+0x35>
		s1++, s2++;
  800b89:	83 c0 01             	add    $0x1,%eax
  800b8c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	39 f0                	cmp    %esi,%eax
  800b91:	75 e2                	jne    800b75 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	53                   	push   %ebx
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ba3:	89 c1                	mov    %eax,%ecx
  800ba5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bac:	eb 0a                	jmp    800bb8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bae:	0f b6 10             	movzbl (%eax),%edx
  800bb1:	39 da                	cmp    %ebx,%edx
  800bb3:	74 07                	je     800bbc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	39 c8                	cmp    %ecx,%eax
  800bba:	72 f2                	jb     800bae <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcb:	eb 03                	jmp    800bd0 <strtol+0x11>
		s++;
  800bcd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd0:	0f b6 01             	movzbl (%ecx),%eax
  800bd3:	3c 20                	cmp    $0x20,%al
  800bd5:	74 f6                	je     800bcd <strtol+0xe>
  800bd7:	3c 09                	cmp    $0x9,%al
  800bd9:	74 f2                	je     800bcd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bdb:	3c 2b                	cmp    $0x2b,%al
  800bdd:	75 0a                	jne    800be9 <strtol+0x2a>
		s++;
  800bdf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
  800be7:	eb 11                	jmp    800bfa <strtol+0x3b>
  800be9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bee:	3c 2d                	cmp    $0x2d,%al
  800bf0:	75 08                	jne    800bfa <strtol+0x3b>
		s++, neg = 1;
  800bf2:	83 c1 01             	add    $0x1,%ecx
  800bf5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c00:	75 15                	jne    800c17 <strtol+0x58>
  800c02:	80 39 30             	cmpb   $0x30,(%ecx)
  800c05:	75 10                	jne    800c17 <strtol+0x58>
  800c07:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0b:	75 7c                	jne    800c89 <strtol+0xca>
		s += 2, base = 16;
  800c0d:	83 c1 02             	add    $0x2,%ecx
  800c10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c15:	eb 16                	jmp    800c2d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c17:	85 db                	test   %ebx,%ebx
  800c19:	75 12                	jne    800c2d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c1b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c20:	80 39 30             	cmpb   $0x30,(%ecx)
  800c23:	75 08                	jne    800c2d <strtol+0x6e>
		s++, base = 8;
  800c25:	83 c1 01             	add    $0x1,%ecx
  800c28:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c32:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c35:	0f b6 11             	movzbl (%ecx),%edx
  800c38:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c3b:	89 f3                	mov    %esi,%ebx
  800c3d:	80 fb 09             	cmp    $0x9,%bl
  800c40:	77 08                	ja     800c4a <strtol+0x8b>
			dig = *s - '0';
  800c42:	0f be d2             	movsbl %dl,%edx
  800c45:	83 ea 30             	sub    $0x30,%edx
  800c48:	eb 22                	jmp    800c6c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c4a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 19             	cmp    $0x19,%bl
  800c52:	77 08                	ja     800c5c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 57             	sub    $0x57,%edx
  800c5a:	eb 10                	jmp    800c6c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c5c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 19             	cmp    $0x19,%bl
  800c64:	77 16                	ja     800c7c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c6c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c6f:	7d 0b                	jge    800c7c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c71:	83 c1 01             	add    $0x1,%ecx
  800c74:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c78:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c7a:	eb b9                	jmp    800c35 <strtol+0x76>

	if (endptr)
  800c7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c80:	74 0d                	je     800c8f <strtol+0xd0>
		*endptr = (char *) s;
  800c82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c85:	89 0e                	mov    %ecx,(%esi)
  800c87:	eb 06                	jmp    800c8f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c89:	85 db                	test   %ebx,%ebx
  800c8b:	74 98                	je     800c25 <strtol+0x66>
  800c8d:	eb 9e                	jmp    800c2d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c8f:	89 c2                	mov    %eax,%edx
  800c91:	f7 da                	neg    %edx
  800c93:	85 ff                	test   %edi,%edi
  800c95:	0f 45 c2             	cmovne %edx,%eax
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	89 c3                	mov    %eax,%ebx
  800cb0:	89 c7                	mov    %eax,%edi
  800cb2:	89 c6                	mov    %eax,%esi
  800cb4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce8:	b8 03 00 00 00       	mov    $0x3,%eax
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	89 cb                	mov    %ecx,%ebx
  800cf2:	89 cf                	mov    %ecx,%edi
  800cf4:	89 ce                	mov    %ecx,%esi
  800cf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 17                	jle    800d13 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 03                	push   $0x3
  800d02:	68 bf 27 80 00       	push   $0x8027bf
  800d07:	6a 23                	push   $0x23
  800d09:	68 dc 27 80 00       	push   $0x8027dc
  800d0e:	e8 e5 f5 ff ff       	call   8002f8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	ba 00 00 00 00       	mov    $0x0,%edx
  800d26:	b8 02 00 00 00       	mov    $0x2,%eax
  800d2b:	89 d1                	mov    %edx,%ecx
  800d2d:	89 d3                	mov    %edx,%ebx
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 d6                	mov    %edx,%esi
  800d33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_yield>:

void
sys_yield(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4a:	89 d1                	mov    %edx,%ecx
  800d4c:	89 d3                	mov    %edx,%ebx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	be 00 00 00 00       	mov    $0x0,%esi
  800d67:	b8 04 00 00 00       	mov    $0x4,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d75:	89 f7                	mov    %esi,%edi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 04                	push   $0x4
  800d83:	68 bf 27 80 00       	push   $0x8027bf
  800d88:	6a 23                	push   $0x23
  800d8a:	68 dc 27 80 00       	push   $0x8027dc
  800d8f:	e8 64 f5 ff ff       	call   8002f8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	b8 05 00 00 00       	mov    $0x5,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db6:	8b 75 18             	mov    0x18(%ebp),%esi
  800db9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 17                	jle    800dd6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 05                	push   $0x5
  800dc5:	68 bf 27 80 00       	push   $0x8027bf
  800dca:	6a 23                	push   $0x23
  800dcc:	68 dc 27 80 00       	push   $0x8027dc
  800dd1:	e8 22 f5 ff ff       	call   8002f8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 06 00 00 00       	mov    $0x6,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 17                	jle    800e18 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 06                	push   $0x6
  800e07:	68 bf 27 80 00       	push   $0x8027bf
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 dc 27 80 00       	push   $0x8027dc
  800e13:	e8 e0 f4 ff ff       	call   8002f8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 df                	mov    %ebx,%edi
  800e3b:	89 de                	mov    %ebx,%esi
  800e3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	7e 17                	jle    800e5a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	50                   	push   %eax
  800e47:	6a 08                	push   $0x8
  800e49:	68 bf 27 80 00       	push   $0x8027bf
  800e4e:	6a 23                	push   $0x23
  800e50:	68 dc 27 80 00       	push   $0x8027dc
  800e55:	e8 9e f4 ff ff       	call   8002f8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e70:	b8 09 00 00 00       	mov    $0x9,%eax
  800e75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	89 df                	mov    %ebx,%edi
  800e7d:	89 de                	mov    %ebx,%esi
  800e7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7e 17                	jle    800e9c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	50                   	push   %eax
  800e89:	6a 09                	push   $0x9
  800e8b:	68 bf 27 80 00       	push   $0x8027bf
  800e90:	6a 23                	push   $0x23
  800e92:	68 dc 27 80 00       	push   $0x8027dc
  800e97:	e8 5c f4 ff ff       	call   8002f8 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	89 df                	mov    %ebx,%edi
  800ebf:	89 de                	mov    %ebx,%esi
  800ec1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	7e 17                	jle    800ede <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	50                   	push   %eax
  800ecb:	6a 0a                	push   $0xa
  800ecd:	68 bf 27 80 00       	push   $0x8027bf
  800ed2:	6a 23                	push   $0x23
  800ed4:	68 dc 27 80 00       	push   $0x8027dc
  800ed9:	e8 1a f4 ff ff       	call   8002f8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eec:	be 00 00 00 00       	mov    $0x0,%esi
  800ef1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f02:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f17:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 cb                	mov    %ecx,%ebx
  800f21:	89 cf                	mov    %ecx,%edi
  800f23:	89 ce                	mov    %ecx,%esi
  800f25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 17                	jle    800f42 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	50                   	push   %eax
  800f2f:	6a 0d                	push   $0xd
  800f31:	68 bf 27 80 00       	push   $0x8027bf
  800f36:	6a 23                	push   $0x23
  800f38:	68 dc 27 80 00       	push   $0x8027dc
  800f3d:	e8 b6 f3 ff ff       	call   8002f8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f55:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5d:	89 cb                	mov    %ecx,%ebx
  800f5f:	89 cf                	mov    %ecx,%edi
  800f61:	89 ce                	mov    %ecx,%esi
  800f63:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f74:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f76:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f7a:	74 11                	je     800f8d <pgfault+0x23>
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	c1 e8 0c             	shr    $0xc,%eax
  800f81:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f88:	f6 c4 08             	test   $0x8,%ah
  800f8b:	75 14                	jne    800fa1 <pgfault+0x37>
		panic("faulting access");
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	68 ea 27 80 00       	push   $0x8027ea
  800f95:	6a 1d                	push   $0x1d
  800f97:	68 fa 27 80 00       	push   $0x8027fa
  800f9c:	e8 57 f3 ff ff       	call   8002f8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	6a 07                	push   $0x7
  800fa6:	68 00 f0 7f 00       	push   $0x7ff000
  800fab:	6a 00                	push   $0x0
  800fad:	e8 a7 fd ff ff       	call   800d59 <sys_page_alloc>
	if (r < 0) {
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 12                	jns    800fcb <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800fb9:	50                   	push   %eax
  800fba:	68 05 28 80 00       	push   $0x802805
  800fbf:	6a 2b                	push   $0x2b
  800fc1:	68 fa 27 80 00       	push   $0x8027fa
  800fc6:	e8 2d f3 ff ff       	call   8002f8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800fcb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800fd1:	83 ec 04             	sub    $0x4,%esp
  800fd4:	68 00 10 00 00       	push   $0x1000
  800fd9:	53                   	push   %ebx
  800fda:	68 00 f0 7f 00       	push   $0x7ff000
  800fdf:	e8 6c fb ff ff       	call   800b50 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800fe4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800feb:	53                   	push   %ebx
  800fec:	6a 00                	push   $0x0
  800fee:	68 00 f0 7f 00       	push   $0x7ff000
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 a2 fd ff ff       	call   800d9c <sys_page_map>
	if (r < 0) {
  800ffa:	83 c4 20             	add    $0x20,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	79 12                	jns    801013 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801001:	50                   	push   %eax
  801002:	68 05 28 80 00       	push   $0x802805
  801007:	6a 32                	push   $0x32
  801009:	68 fa 27 80 00       	push   $0x8027fa
  80100e:	e8 e5 f2 ff ff       	call   8002f8 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	68 00 f0 7f 00       	push   $0x7ff000
  80101b:	6a 00                	push   $0x0
  80101d:	e8 bc fd ff ff       	call   800dde <sys_page_unmap>
	if (r < 0) {
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	79 12                	jns    80103b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  801029:	50                   	push   %eax
  80102a:	68 05 28 80 00       	push   $0x802805
  80102f:	6a 36                	push   $0x36
  801031:	68 fa 27 80 00       	push   $0x8027fa
  801036:	e8 bd f2 ff ff       	call   8002f8 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80103b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
  801046:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801049:	68 6a 0f 80 00       	push   $0x800f6a
  80104e:	e8 e9 0e 00 00       	call   801f3c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801053:	b8 07 00 00 00       	mov    $0x7,%eax
  801058:	cd 30                	int    $0x30
  80105a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	79 17                	jns    80107b <fork+0x3b>
		panic("fork fault %e");
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	68 1e 28 80 00       	push   $0x80281e
  80106c:	68 83 00 00 00       	push   $0x83
  801071:	68 fa 27 80 00       	push   $0x8027fa
  801076:	e8 7d f2 ff ff       	call   8002f8 <_panic>
  80107b:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80107d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801081:	75 25                	jne    8010a8 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801083:	e8 93 fc ff ff       	call   800d1b <sys_getenvid>
  801088:	25 ff 03 00 00       	and    $0x3ff,%eax
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	c1 e2 07             	shl    $0x7,%edx
  801092:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801099:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80109e:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a3:	e9 61 01 00 00       	jmp    801209 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	6a 07                	push   $0x7
  8010ad:	68 00 f0 bf ee       	push   $0xeebff000
  8010b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b5:	e8 9f fc ff ff       	call   800d59 <sys_page_alloc>
  8010ba:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010c2:	89 d8                	mov    %ebx,%eax
  8010c4:	c1 e8 16             	shr    $0x16,%eax
  8010c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ce:	a8 01                	test   $0x1,%al
  8010d0:	0f 84 fc 00 00 00    	je     8011d2 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	c1 e8 0c             	shr    $0xc,%eax
  8010db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010e2:	f6 c2 01             	test   $0x1,%dl
  8010e5:	0f 84 e7 00 00 00    	je     8011d2 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8010eb:	89 c6                	mov    %eax,%esi
  8010ed:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8010f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f7:	f6 c6 04             	test   $0x4,%dh
  8010fa:	74 39                	je     801135 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	25 07 0e 00 00       	and    $0xe07,%eax
  80110b:	50                   	push   %eax
  80110c:	56                   	push   %esi
  80110d:	57                   	push   %edi
  80110e:	56                   	push   %esi
  80110f:	6a 00                	push   $0x0
  801111:	e8 86 fc ff ff       	call   800d9c <sys_page_map>
		if (r < 0) {
  801116:	83 c4 20             	add    $0x20,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	0f 89 b1 00 00 00    	jns    8011d2 <fork+0x192>
		    	panic("sys page map fault %e");
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	68 2c 28 80 00       	push   $0x80282c
  801129:	6a 53                	push   $0x53
  80112b:	68 fa 27 80 00       	push   $0x8027fa
  801130:	e8 c3 f1 ff ff       	call   8002f8 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801135:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113c:	f6 c2 02             	test   $0x2,%dl
  80113f:	75 0c                	jne    80114d <fork+0x10d>
  801141:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801148:	f6 c4 08             	test   $0x8,%ah
  80114b:	74 5b                	je     8011a8 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80114d:	83 ec 0c             	sub    $0xc,%esp
  801150:	68 05 08 00 00       	push   $0x805
  801155:	56                   	push   %esi
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	6a 00                	push   $0x0
  80115a:	e8 3d fc ff ff       	call   800d9c <sys_page_map>
		if (r < 0) {
  80115f:	83 c4 20             	add    $0x20,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	79 14                	jns    80117a <fork+0x13a>
		    	panic("sys page map fault %e");
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	68 2c 28 80 00       	push   $0x80282c
  80116e:	6a 5a                	push   $0x5a
  801170:	68 fa 27 80 00       	push   $0x8027fa
  801175:	e8 7e f1 ff ff       	call   8002f8 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	68 05 08 00 00       	push   $0x805
  801182:	56                   	push   %esi
  801183:	6a 00                	push   $0x0
  801185:	56                   	push   %esi
  801186:	6a 00                	push   $0x0
  801188:	e8 0f fc ff ff       	call   800d9c <sys_page_map>
		if (r < 0) {
  80118d:	83 c4 20             	add    $0x20,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	79 3e                	jns    8011d2 <fork+0x192>
		    	panic("sys page map fault %e");
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	68 2c 28 80 00       	push   $0x80282c
  80119c:	6a 5e                	push   $0x5e
  80119e:	68 fa 27 80 00       	push   $0x8027fa
  8011a3:	e8 50 f1 ff ff       	call   8002f8 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8011a8:	83 ec 0c             	sub    $0xc,%esp
  8011ab:	6a 05                	push   $0x5
  8011ad:	56                   	push   %esi
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 e5 fb ff ff       	call   800d9c <sys_page_map>
		if (r < 0) {
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	79 14                	jns    8011d2 <fork+0x192>
		    	panic("sys page map fault %e");
  8011be:	83 ec 04             	sub    $0x4,%esp
  8011c1:	68 2c 28 80 00       	push   $0x80282c
  8011c6:	6a 63                	push   $0x63
  8011c8:	68 fa 27 80 00       	push   $0x8027fa
  8011cd:	e8 26 f1 ff ff       	call   8002f8 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8011d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011d8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011de:	0f 85 de fe ff ff    	jne    8010c2 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8011e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e9:	8b 40 6c             	mov    0x6c(%eax),%eax
  8011ec:	83 ec 08             	sub    $0x8,%esp
  8011ef:	50                   	push   %eax
  8011f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011f3:	57                   	push   %edi
  8011f4:	e8 ab fc ff ff       	call   800ea4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011f9:	83 c4 08             	add    $0x8,%esp
  8011fc:	6a 02                	push   $0x2
  8011fe:	57                   	push   %edi
  8011ff:	e8 1c fc ff ff       	call   800e20 <sys_env_set_status>
	
	return envid;
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sfork>:

envid_t
sfork(void)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	53                   	push   %ebx
  801227:	68 44 28 80 00       	push   $0x802844
  80122c:	e8 a0 f1 ff ff       	call   8003d1 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  801231:	89 1c 24             	mov    %ebx,(%esp)
  801234:	e8 11 fd ff ff       	call   800f4a <sys_thread_create>
  801239:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80123b:	83 c4 08             	add    $0x8,%esp
  80123e:	53                   	push   %ebx
  80123f:	68 44 28 80 00       	push   $0x802844
  801244:	e8 88 f1 ff ff       	call   8003d1 <cprintf>
	return id;
}
  801249:	89 f0                	mov    %esi,%eax
  80124b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
  801258:	05 00 00 00 30       	add    $0x30000000,%eax
  80125d:	c1 e8 0c             	shr    $0xc,%eax
}
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	05 00 00 00 30       	add    $0x30000000,%eax
  80126d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801272:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801284:	89 c2                	mov    %eax,%edx
  801286:	c1 ea 16             	shr    $0x16,%edx
  801289:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801290:	f6 c2 01             	test   $0x1,%dl
  801293:	74 11                	je     8012a6 <fd_alloc+0x2d>
  801295:	89 c2                	mov    %eax,%edx
  801297:	c1 ea 0c             	shr    $0xc,%edx
  80129a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a1:	f6 c2 01             	test   $0x1,%dl
  8012a4:	75 09                	jne    8012af <fd_alloc+0x36>
			*fd_store = fd;
  8012a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	eb 17                	jmp    8012c6 <fd_alloc+0x4d>
  8012af:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b9:	75 c9                	jne    801284 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012bb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ce:	83 f8 1f             	cmp    $0x1f,%eax
  8012d1:	77 36                	ja     801309 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d3:	c1 e0 0c             	shl    $0xc,%eax
  8012d6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	c1 ea 16             	shr    $0x16,%edx
  8012e0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e7:	f6 c2 01             	test   $0x1,%dl
  8012ea:	74 24                	je     801310 <fd_lookup+0x48>
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	c1 ea 0c             	shr    $0xc,%edx
  8012f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f8:	f6 c2 01             	test   $0x1,%dl
  8012fb:	74 1a                	je     801317 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801300:	89 02                	mov    %eax,(%edx)
	return 0;
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	eb 13                	jmp    80131c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801309:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130e:	eb 0c                	jmp    80131c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801310:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801315:	eb 05                	jmp    80131c <fd_lookup+0x54>
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801327:	ba e8 28 80 00       	mov    $0x8028e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80132c:	eb 13                	jmp    801341 <dev_lookup+0x23>
  80132e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801331:	39 08                	cmp    %ecx,(%eax)
  801333:	75 0c                	jne    801341 <dev_lookup+0x23>
			*dev = devtab[i];
  801335:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801338:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
  80133f:	eb 2e                	jmp    80136f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801341:	8b 02                	mov    (%edx),%eax
  801343:	85 c0                	test   %eax,%eax
  801345:	75 e7                	jne    80132e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801347:	a1 04 40 80 00       	mov    0x804004,%eax
  80134c:	8b 40 50             	mov    0x50(%eax),%eax
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	51                   	push   %ecx
  801353:	50                   	push   %eax
  801354:	68 68 28 80 00       	push   $0x802868
  801359:	e8 73 f0 ff ff       	call   8003d1 <cprintf>
	*dev = 0;
  80135e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801361:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	56                   	push   %esi
  801375:	53                   	push   %ebx
  801376:	83 ec 10             	sub    $0x10,%esp
  801379:	8b 75 08             	mov    0x8(%ebp),%esi
  80137c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801389:	c1 e8 0c             	shr    $0xc,%eax
  80138c:	50                   	push   %eax
  80138d:	e8 36 ff ff ff       	call   8012c8 <fd_lookup>
  801392:	83 c4 08             	add    $0x8,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 05                	js     80139e <fd_close+0x2d>
	    || fd != fd2)
  801399:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139c:	74 0c                	je     8013aa <fd_close+0x39>
		return (must_exist ? r : 0);
  80139e:	84 db                	test   %bl,%bl
  8013a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a5:	0f 44 c2             	cmove  %edx,%eax
  8013a8:	eb 41                	jmp    8013eb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b0:	50                   	push   %eax
  8013b1:	ff 36                	pushl  (%esi)
  8013b3:	e8 66 ff ff ff       	call   80131e <dev_lookup>
  8013b8:	89 c3                	mov    %eax,%ebx
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 1a                	js     8013db <fd_close+0x6a>
		if (dev->dev_close)
  8013c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	74 0b                	je     8013db <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	56                   	push   %esi
  8013d4:	ff d0                	call   *%eax
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	56                   	push   %esi
  8013df:	6a 00                	push   $0x0
  8013e1:	e8 f8 f9 ff ff       	call   800dde <sys_page_unmap>
	return r;
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	89 d8                	mov    %ebx,%eax
}
  8013eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ee:	5b                   	pop    %ebx
  8013ef:	5e                   	pop    %esi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	ff 75 08             	pushl  0x8(%ebp)
  8013ff:	e8 c4 fe ff ff       	call   8012c8 <fd_lookup>
  801404:	83 c4 08             	add    $0x8,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 10                	js     80141b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	6a 01                	push   $0x1
  801410:	ff 75 f4             	pushl  -0xc(%ebp)
  801413:	e8 59 ff ff ff       	call   801371 <fd_close>
  801418:	83 c4 10             	add    $0x10,%esp
}
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <close_all>:

void
close_all(void)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	53                   	push   %ebx
  801421:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801424:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801429:	83 ec 0c             	sub    $0xc,%esp
  80142c:	53                   	push   %ebx
  80142d:	e8 c0 ff ff ff       	call   8013f2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801432:	83 c3 01             	add    $0x1,%ebx
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	83 fb 20             	cmp    $0x20,%ebx
  80143b:	75 ec                	jne    801429 <close_all+0xc>
		close(i);
}
  80143d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801440:	c9                   	leave  
  801441:	c3                   	ret    

00801442 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	57                   	push   %edi
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	83 ec 2c             	sub    $0x2c,%esp
  80144b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80144e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	ff 75 08             	pushl  0x8(%ebp)
  801455:	e8 6e fe ff ff       	call   8012c8 <fd_lookup>
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	0f 88 c1 00 00 00    	js     801526 <dup+0xe4>
		return r;
	close(newfdnum);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	56                   	push   %esi
  801469:	e8 84 ff ff ff       	call   8013f2 <close>

	newfd = INDEX2FD(newfdnum);
  80146e:	89 f3                	mov    %esi,%ebx
  801470:	c1 e3 0c             	shl    $0xc,%ebx
  801473:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801479:	83 c4 04             	add    $0x4,%esp
  80147c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80147f:	e8 de fd ff ff       	call   801262 <fd2data>
  801484:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801486:	89 1c 24             	mov    %ebx,(%esp)
  801489:	e8 d4 fd ff ff       	call   801262 <fd2data>
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801494:	89 f8                	mov    %edi,%eax
  801496:	c1 e8 16             	shr    $0x16,%eax
  801499:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a0:	a8 01                	test   $0x1,%al
  8014a2:	74 37                	je     8014db <dup+0x99>
  8014a4:	89 f8                	mov    %edi,%eax
  8014a6:	c1 e8 0c             	shr    $0xc,%eax
  8014a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b0:	f6 c2 01             	test   $0x1,%dl
  8014b3:	74 26                	je     8014db <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c4:	50                   	push   %eax
  8014c5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c8:	6a 00                	push   $0x0
  8014ca:	57                   	push   %edi
  8014cb:	6a 00                	push   $0x0
  8014cd:	e8 ca f8 ff ff       	call   800d9c <sys_page_map>
  8014d2:	89 c7                	mov    %eax,%edi
  8014d4:	83 c4 20             	add    $0x20,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 2e                	js     801509 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014de:	89 d0                	mov    %edx,%eax
  8014e0:	c1 e8 0c             	shr    $0xc,%eax
  8014e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f2:	50                   	push   %eax
  8014f3:	53                   	push   %ebx
  8014f4:	6a 00                	push   $0x0
  8014f6:	52                   	push   %edx
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 9e f8 ff ff       	call   800d9c <sys_page_map>
  8014fe:	89 c7                	mov    %eax,%edi
  801500:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801503:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801505:	85 ff                	test   %edi,%edi
  801507:	79 1d                	jns    801526 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	53                   	push   %ebx
  80150d:	6a 00                	push   $0x0
  80150f:	e8 ca f8 ff ff       	call   800dde <sys_page_unmap>
	sys_page_unmap(0, nva);
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151a:	6a 00                	push   $0x0
  80151c:	e8 bd f8 ff ff       	call   800dde <sys_page_unmap>
	return r;
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	89 f8                	mov    %edi,%eax
}
  801526:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5f                   	pop    %edi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 14             	sub    $0x14,%esp
  801535:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801538:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	53                   	push   %ebx
  80153d:	e8 86 fd ff ff       	call   8012c8 <fd_lookup>
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	89 c2                	mov    %eax,%edx
  801547:	85 c0                	test   %eax,%eax
  801549:	78 6d                	js     8015b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801555:	ff 30                	pushl  (%eax)
  801557:	e8 c2 fd ff ff       	call   80131e <dev_lookup>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 4c                	js     8015af <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801563:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801566:	8b 42 08             	mov    0x8(%edx),%eax
  801569:	83 e0 03             	and    $0x3,%eax
  80156c:	83 f8 01             	cmp    $0x1,%eax
  80156f:	75 21                	jne    801592 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801571:	a1 04 40 80 00       	mov    0x804004,%eax
  801576:	8b 40 50             	mov    0x50(%eax),%eax
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	53                   	push   %ebx
  80157d:	50                   	push   %eax
  80157e:	68 ac 28 80 00       	push   $0x8028ac
  801583:	e8 49 ee ff ff       	call   8003d1 <cprintf>
		return -E_INVAL;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801590:	eb 26                	jmp    8015b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801595:	8b 40 08             	mov    0x8(%eax),%eax
  801598:	85 c0                	test   %eax,%eax
  80159a:	74 17                	je     8015b3 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	ff 75 10             	pushl  0x10(%ebp)
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	52                   	push   %edx
  8015a6:	ff d0                	call   *%eax
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb 09                	jmp    8015b8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	eb 05                	jmp    8015b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015b8:	89 d0                	mov    %edx,%eax
  8015ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	57                   	push   %edi
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d3:	eb 21                	jmp    8015f6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	89 f0                	mov    %esi,%eax
  8015da:	29 d8                	sub    %ebx,%eax
  8015dc:	50                   	push   %eax
  8015dd:	89 d8                	mov    %ebx,%eax
  8015df:	03 45 0c             	add    0xc(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	57                   	push   %edi
  8015e4:	e8 45 ff ff ff       	call   80152e <read>
		if (m < 0)
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 10                	js     801600 <readn+0x41>
			return m;
		if (m == 0)
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	74 0a                	je     8015fe <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f4:	01 c3                	add    %eax,%ebx
  8015f6:	39 f3                	cmp    %esi,%ebx
  8015f8:	72 db                	jb     8015d5 <readn+0x16>
  8015fa:	89 d8                	mov    %ebx,%eax
  8015fc:	eb 02                	jmp    801600 <readn+0x41>
  8015fe:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801600:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801603:	5b                   	pop    %ebx
  801604:	5e                   	pop    %esi
  801605:	5f                   	pop    %edi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	53                   	push   %ebx
  80160c:	83 ec 14             	sub    $0x14,%esp
  80160f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801612:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	53                   	push   %ebx
  801617:	e8 ac fc ff ff       	call   8012c8 <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	89 c2                	mov    %eax,%edx
  801621:	85 c0                	test   %eax,%eax
  801623:	78 68                	js     80168d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	ff 30                	pushl  (%eax)
  801631:	e8 e8 fc ff ff       	call   80131e <dev_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 47                	js     801684 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801640:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801644:	75 21                	jne    801667 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801646:	a1 04 40 80 00       	mov    0x804004,%eax
  80164b:	8b 40 50             	mov    0x50(%eax),%eax
  80164e:	83 ec 04             	sub    $0x4,%esp
  801651:	53                   	push   %ebx
  801652:	50                   	push   %eax
  801653:	68 c8 28 80 00       	push   $0x8028c8
  801658:	e8 74 ed ff ff       	call   8003d1 <cprintf>
		return -E_INVAL;
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801665:	eb 26                	jmp    80168d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801667:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166a:	8b 52 0c             	mov    0xc(%edx),%edx
  80166d:	85 d2                	test   %edx,%edx
  80166f:	74 17                	je     801688 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801671:	83 ec 04             	sub    $0x4,%esp
  801674:	ff 75 10             	pushl  0x10(%ebp)
  801677:	ff 75 0c             	pushl  0xc(%ebp)
  80167a:	50                   	push   %eax
  80167b:	ff d2                	call   *%edx
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	eb 09                	jmp    80168d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801684:	89 c2                	mov    %eax,%edx
  801686:	eb 05                	jmp    80168d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801688:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80168d:	89 d0                	mov    %edx,%eax
  80168f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <seek>:

int
seek(int fdnum, off_t offset)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	ff 75 08             	pushl  0x8(%ebp)
  8016a1:	e8 22 fc ff ff       	call   8012c8 <fd_lookup>
  8016a6:	83 c4 08             	add    $0x8,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 0e                	js     8016bb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 14             	sub    $0x14,%esp
  8016c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	53                   	push   %ebx
  8016cc:	e8 f7 fb ff ff       	call   8012c8 <fd_lookup>
  8016d1:	83 c4 08             	add    $0x8,%esp
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 65                	js     80173f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e0:	50                   	push   %eax
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	ff 30                	pushl  (%eax)
  8016e6:	e8 33 fc ff ff       	call   80131e <dev_lookup>
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 44                	js     801736 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f9:	75 21                	jne    80171c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016fb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801700:	8b 40 50             	mov    0x50(%eax),%eax
  801703:	83 ec 04             	sub    $0x4,%esp
  801706:	53                   	push   %ebx
  801707:	50                   	push   %eax
  801708:	68 88 28 80 00       	push   $0x802888
  80170d:	e8 bf ec ff ff       	call   8003d1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80171a:	eb 23                	jmp    80173f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80171c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171f:	8b 52 18             	mov    0x18(%edx),%edx
  801722:	85 d2                	test   %edx,%edx
  801724:	74 14                	je     80173a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	ff 75 0c             	pushl  0xc(%ebp)
  80172c:	50                   	push   %eax
  80172d:	ff d2                	call   *%edx
  80172f:	89 c2                	mov    %eax,%edx
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	eb 09                	jmp    80173f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801736:	89 c2                	mov    %eax,%edx
  801738:	eb 05                	jmp    80173f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80173a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80173f:	89 d0                	mov    %edx,%eax
  801741:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	53                   	push   %ebx
  80174a:	83 ec 14             	sub    $0x14,%esp
  80174d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	ff 75 08             	pushl  0x8(%ebp)
  801757:	e8 6c fb ff ff       	call   8012c8 <fd_lookup>
  80175c:	83 c4 08             	add    $0x8,%esp
  80175f:	89 c2                	mov    %eax,%edx
  801761:	85 c0                	test   %eax,%eax
  801763:	78 58                	js     8017bd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801765:	83 ec 08             	sub    $0x8,%esp
  801768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176f:	ff 30                	pushl  (%eax)
  801771:	e8 a8 fb ff ff       	call   80131e <dev_lookup>
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 37                	js     8017b4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80177d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801780:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801784:	74 32                	je     8017b8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801786:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801789:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801790:	00 00 00 
	stat->st_isdir = 0;
  801793:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179a:	00 00 00 
	stat->st_dev = dev;
  80179d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	53                   	push   %ebx
  8017a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017aa:	ff 50 14             	call   *0x14(%eax)
  8017ad:	89 c2                	mov    %eax,%edx
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	eb 09                	jmp    8017bd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b4:	89 c2                	mov    %eax,%edx
  8017b6:	eb 05                	jmp    8017bd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017bd:	89 d0                	mov    %edx,%eax
  8017bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	56                   	push   %esi
  8017c8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	6a 00                	push   $0x0
  8017ce:	ff 75 08             	pushl  0x8(%ebp)
  8017d1:	e8 e3 01 00 00       	call   8019b9 <open>
  8017d6:	89 c3                	mov    %eax,%ebx
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 1b                	js     8017fa <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	ff 75 0c             	pushl  0xc(%ebp)
  8017e5:	50                   	push   %eax
  8017e6:	e8 5b ff ff ff       	call   801746 <fstat>
  8017eb:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ed:	89 1c 24             	mov    %ebx,(%esp)
  8017f0:	e8 fd fb ff ff       	call   8013f2 <close>
	return r;
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	89 f0                	mov    %esi,%eax
}
  8017fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	89 c6                	mov    %eax,%esi
  801808:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80180a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801811:	75 12                	jne    801825 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801813:	83 ec 0c             	sub    $0xc,%esp
  801816:	6a 01                	push   $0x1
  801818:	e8 85 08 00 00       	call   8020a2 <ipc_find_env>
  80181d:	a3 00 40 80 00       	mov    %eax,0x804000
  801822:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801825:	6a 07                	push   $0x7
  801827:	68 00 50 80 00       	push   $0x805000
  80182c:	56                   	push   %esi
  80182d:	ff 35 00 40 80 00    	pushl  0x804000
  801833:	e8 08 08 00 00       	call   802040 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801838:	83 c4 0c             	add    $0xc,%esp
  80183b:	6a 00                	push   $0x0
  80183d:	53                   	push   %ebx
  80183e:	6a 00                	push   $0x0
  801840:	e8 86 07 00 00       	call   801fcb <ipc_recv>
}
  801845:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801848:	5b                   	pop    %ebx
  801849:	5e                   	pop    %esi
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	8b 40 0c             	mov    0xc(%eax),%eax
  801858:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80185d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801860:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801865:	ba 00 00 00 00       	mov    $0x0,%edx
  80186a:	b8 02 00 00 00       	mov    $0x2,%eax
  80186f:	e8 8d ff ff ff       	call   801801 <fsipc>
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 40 0c             	mov    0xc(%eax),%eax
  801882:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801887:	ba 00 00 00 00       	mov    $0x0,%edx
  80188c:	b8 06 00 00 00       	mov    $0x6,%eax
  801891:	e8 6b ff ff ff       	call   801801 <fsipc>
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b7:	e8 45 ff ff ff       	call   801801 <fsipc>
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 2c                	js     8018ec <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	68 00 50 80 00       	push   $0x805000
  8018c8:	53                   	push   %ebx
  8018c9:	e8 88 f0 ff ff       	call   800956 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ce:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d9:	a1 84 50 80 00       	mov    0x805084,%eax
  8018de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	83 ec 0c             	sub    $0xc,%esp
  8018f7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8018fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801900:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801906:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80190b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801910:	0f 47 c2             	cmova  %edx,%eax
  801913:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801918:	50                   	push   %eax
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	68 08 50 80 00       	push   $0x805008
  801921:	e8 c2 f1 ff ff       	call   800ae8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801926:	ba 00 00 00 00       	mov    $0x0,%edx
  80192b:	b8 04 00 00 00       	mov    $0x4,%eax
  801930:	e8 cc fe ff ff       	call   801801 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	56                   	push   %esi
  80193b:	53                   	push   %ebx
  80193c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	8b 40 0c             	mov    0xc(%eax),%eax
  801945:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80194a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801950:	ba 00 00 00 00       	mov    $0x0,%edx
  801955:	b8 03 00 00 00       	mov    $0x3,%eax
  80195a:	e8 a2 fe ff ff       	call   801801 <fsipc>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	85 c0                	test   %eax,%eax
  801963:	78 4b                	js     8019b0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801965:	39 c6                	cmp    %eax,%esi
  801967:	73 16                	jae    80197f <devfile_read+0x48>
  801969:	68 f8 28 80 00       	push   $0x8028f8
  80196e:	68 ff 28 80 00       	push   $0x8028ff
  801973:	6a 7c                	push   $0x7c
  801975:	68 14 29 80 00       	push   $0x802914
  80197a:	e8 79 e9 ff ff       	call   8002f8 <_panic>
	assert(r <= PGSIZE);
  80197f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801984:	7e 16                	jle    80199c <devfile_read+0x65>
  801986:	68 1f 29 80 00       	push   $0x80291f
  80198b:	68 ff 28 80 00       	push   $0x8028ff
  801990:	6a 7d                	push   $0x7d
  801992:	68 14 29 80 00       	push   $0x802914
  801997:	e8 5c e9 ff ff       	call   8002f8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80199c:	83 ec 04             	sub    $0x4,%esp
  80199f:	50                   	push   %eax
  8019a0:	68 00 50 80 00       	push   $0x805000
  8019a5:	ff 75 0c             	pushl  0xc(%ebp)
  8019a8:	e8 3b f1 ff ff       	call   800ae8 <memmove>
	return r;
  8019ad:	83 c4 10             	add    $0x10,%esp
}
  8019b0:	89 d8                	mov    %ebx,%eax
  8019b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 20             	sub    $0x20,%esp
  8019c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c3:	53                   	push   %ebx
  8019c4:	e8 54 ef ff ff       	call   80091d <strlen>
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d1:	7f 67                	jg     801a3a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	e8 9a f8 ff ff       	call   801279 <fd_alloc>
  8019df:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 57                	js     801a3f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	53                   	push   %ebx
  8019ec:	68 00 50 80 00       	push   $0x805000
  8019f1:	e8 60 ef ff ff       	call   800956 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a01:	b8 01 00 00 00       	mov    $0x1,%eax
  801a06:	e8 f6 fd ff ff       	call   801801 <fsipc>
  801a0b:	89 c3                	mov    %eax,%ebx
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	85 c0                	test   %eax,%eax
  801a12:	79 14                	jns    801a28 <open+0x6f>
		fd_close(fd, 0);
  801a14:	83 ec 08             	sub    $0x8,%esp
  801a17:	6a 00                	push   $0x0
  801a19:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1c:	e8 50 f9 ff ff       	call   801371 <fd_close>
		return r;
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	89 da                	mov    %ebx,%edx
  801a26:	eb 17                	jmp    801a3f <open+0x86>
	}

	return fd2num(fd);
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2e:	e8 1f f8 ff ff       	call   801252 <fd2num>
  801a33:	89 c2                	mov    %eax,%edx
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	eb 05                	jmp    801a3f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a3a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a3f:	89 d0                	mov    %edx,%eax
  801a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a51:	b8 08 00 00 00       	mov    $0x8,%eax
  801a56:	e8 a6 fd ff ff       	call   801801 <fsipc>
}
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	ff 75 08             	pushl  0x8(%ebp)
  801a6b:	e8 f2 f7 ff ff       	call   801262 <fd2data>
  801a70:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a72:	83 c4 08             	add    $0x8,%esp
  801a75:	68 2b 29 80 00       	push   $0x80292b
  801a7a:	53                   	push   %ebx
  801a7b:	e8 d6 ee ff ff       	call   800956 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a80:	8b 46 04             	mov    0x4(%esi),%eax
  801a83:	2b 06                	sub    (%esi),%eax
  801a85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a92:	00 00 00 
	stat->st_dev = &devpipe;
  801a95:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a9c:	30 80 00 
	return 0;
}
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ab5:	53                   	push   %ebx
  801ab6:	6a 00                	push   $0x0
  801ab8:	e8 21 f3 ff ff       	call   800dde <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801abd:	89 1c 24             	mov    %ebx,(%esp)
  801ac0:	e8 9d f7 ff ff       	call   801262 <fd2data>
  801ac5:	83 c4 08             	add    $0x8,%esp
  801ac8:	50                   	push   %eax
  801ac9:	6a 00                	push   $0x0
  801acb:	e8 0e f3 ff ff       	call   800dde <sys_page_unmap>
}
  801ad0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	57                   	push   %edi
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	83 ec 1c             	sub    $0x1c,%esp
  801ade:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae8:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	ff 75 e0             	pushl  -0x20(%ebp)
  801af1:	e8 ec 05 00 00       	call   8020e2 <pageref>
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	89 3c 24             	mov    %edi,(%esp)
  801afb:	e8 e2 05 00 00       	call   8020e2 <pageref>
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	39 c3                	cmp    %eax,%ebx
  801b05:	0f 94 c1             	sete   %cl
  801b08:	0f b6 c9             	movzbl %cl,%ecx
  801b0b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b0e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b14:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801b17:	39 ce                	cmp    %ecx,%esi
  801b19:	74 1b                	je     801b36 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b1b:	39 c3                	cmp    %eax,%ebx
  801b1d:	75 c4                	jne    801ae3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b1f:	8b 42 60             	mov    0x60(%edx),%eax
  801b22:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b25:	50                   	push   %eax
  801b26:	56                   	push   %esi
  801b27:	68 32 29 80 00       	push   $0x802932
  801b2c:	e8 a0 e8 ff ff       	call   8003d1 <cprintf>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	eb ad                	jmp    801ae3 <_pipeisclosed+0xe>
	}
}
  801b36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	57                   	push   %edi
  801b45:	56                   	push   %esi
  801b46:	53                   	push   %ebx
  801b47:	83 ec 28             	sub    $0x28,%esp
  801b4a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b4d:	56                   	push   %esi
  801b4e:	e8 0f f7 ff ff       	call   801262 <fd2data>
  801b53:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	bf 00 00 00 00       	mov    $0x0,%edi
  801b5d:	eb 4b                	jmp    801baa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b5f:	89 da                	mov    %ebx,%edx
  801b61:	89 f0                	mov    %esi,%eax
  801b63:	e8 6d ff ff ff       	call   801ad5 <_pipeisclosed>
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	75 48                	jne    801bb4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b6c:	e8 c9 f1 ff ff       	call   800d3a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b71:	8b 43 04             	mov    0x4(%ebx),%eax
  801b74:	8b 0b                	mov    (%ebx),%ecx
  801b76:	8d 51 20             	lea    0x20(%ecx),%edx
  801b79:	39 d0                	cmp    %edx,%eax
  801b7b:	73 e2                	jae    801b5f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b80:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b84:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b87:	89 c2                	mov    %eax,%edx
  801b89:	c1 fa 1f             	sar    $0x1f,%edx
  801b8c:	89 d1                	mov    %edx,%ecx
  801b8e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b91:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b94:	83 e2 1f             	and    $0x1f,%edx
  801b97:	29 ca                	sub    %ecx,%edx
  801b99:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b9d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba1:	83 c0 01             	add    $0x1,%eax
  801ba4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba7:	83 c7 01             	add    $0x1,%edi
  801baa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bad:	75 c2                	jne    801b71 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801baf:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb2:	eb 05                	jmp    801bb9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbc:	5b                   	pop    %ebx
  801bbd:	5e                   	pop    %esi
  801bbe:	5f                   	pop    %edi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	57                   	push   %edi
  801bc5:	56                   	push   %esi
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 18             	sub    $0x18,%esp
  801bca:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bcd:	57                   	push   %edi
  801bce:	e8 8f f6 ff ff       	call   801262 <fd2data>
  801bd3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bdd:	eb 3d                	jmp    801c1c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bdf:	85 db                	test   %ebx,%ebx
  801be1:	74 04                	je     801be7 <devpipe_read+0x26>
				return i;
  801be3:	89 d8                	mov    %ebx,%eax
  801be5:	eb 44                	jmp    801c2b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801be7:	89 f2                	mov    %esi,%edx
  801be9:	89 f8                	mov    %edi,%eax
  801beb:	e8 e5 fe ff ff       	call   801ad5 <_pipeisclosed>
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	75 32                	jne    801c26 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bf4:	e8 41 f1 ff ff       	call   800d3a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bf9:	8b 06                	mov    (%esi),%eax
  801bfb:	3b 46 04             	cmp    0x4(%esi),%eax
  801bfe:	74 df                	je     801bdf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c00:	99                   	cltd   
  801c01:	c1 ea 1b             	shr    $0x1b,%edx
  801c04:	01 d0                	add    %edx,%eax
  801c06:	83 e0 1f             	and    $0x1f,%eax
  801c09:	29 d0                	sub    %edx,%eax
  801c0b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c13:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c16:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c19:	83 c3 01             	add    $0x1,%ebx
  801c1c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c1f:	75 d8                	jne    801bf9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c21:	8b 45 10             	mov    0x10(%ebp),%eax
  801c24:	eb 05                	jmp    801c2b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5f                   	pop    %edi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3e:	50                   	push   %eax
  801c3f:	e8 35 f6 ff ff       	call   801279 <fd_alloc>
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	89 c2                	mov    %eax,%edx
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	0f 88 2c 01 00 00    	js     801d7d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	68 07 04 00 00       	push   $0x407
  801c59:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 f6 f0 ff ff       	call   800d59 <sys_page_alloc>
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	89 c2                	mov    %eax,%edx
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	0f 88 0d 01 00 00    	js     801d7d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c70:	83 ec 0c             	sub    $0xc,%esp
  801c73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c76:	50                   	push   %eax
  801c77:	e8 fd f5 ff ff       	call   801279 <fd_alloc>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	0f 88 e2 00 00 00    	js     801d6b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c89:	83 ec 04             	sub    $0x4,%esp
  801c8c:	68 07 04 00 00       	push   $0x407
  801c91:	ff 75 f0             	pushl  -0x10(%ebp)
  801c94:	6a 00                	push   $0x0
  801c96:	e8 be f0 ff ff       	call   800d59 <sys_page_alloc>
  801c9b:	89 c3                	mov    %eax,%ebx
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	0f 88 c3 00 00 00    	js     801d6b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ca8:	83 ec 0c             	sub    $0xc,%esp
  801cab:	ff 75 f4             	pushl  -0xc(%ebp)
  801cae:	e8 af f5 ff ff       	call   801262 <fd2data>
  801cb3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb5:	83 c4 0c             	add    $0xc,%esp
  801cb8:	68 07 04 00 00       	push   $0x407
  801cbd:	50                   	push   %eax
  801cbe:	6a 00                	push   $0x0
  801cc0:	e8 94 f0 ff ff       	call   800d59 <sys_page_alloc>
  801cc5:	89 c3                	mov    %eax,%ebx
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	0f 88 89 00 00 00    	js     801d5b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd2:	83 ec 0c             	sub    $0xc,%esp
  801cd5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd8:	e8 85 f5 ff ff       	call   801262 <fd2data>
  801cdd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ce4:	50                   	push   %eax
  801ce5:	6a 00                	push   $0x0
  801ce7:	56                   	push   %esi
  801ce8:	6a 00                	push   $0x0
  801cea:	e8 ad f0 ff ff       	call   800d9c <sys_page_map>
  801cef:	89 c3                	mov    %eax,%ebx
  801cf1:	83 c4 20             	add    $0x20,%esp
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	78 55                	js     801d4d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cf8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d01:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d16:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	ff 75 f4             	pushl  -0xc(%ebp)
  801d28:	e8 25 f5 ff ff       	call   801252 <fd2num>
  801d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d30:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d32:	83 c4 04             	add    $0x4,%esp
  801d35:	ff 75 f0             	pushl  -0x10(%ebp)
  801d38:	e8 15 f5 ff ff       	call   801252 <fd2num>
  801d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d40:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4b:	eb 30                	jmp    801d7d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d4d:	83 ec 08             	sub    $0x8,%esp
  801d50:	56                   	push   %esi
  801d51:	6a 00                	push   $0x0
  801d53:	e8 86 f0 ff ff       	call   800dde <sys_page_unmap>
  801d58:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d5b:	83 ec 08             	sub    $0x8,%esp
  801d5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d61:	6a 00                	push   $0x0
  801d63:	e8 76 f0 ff ff       	call   800dde <sys_page_unmap>
  801d68:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d6b:	83 ec 08             	sub    $0x8,%esp
  801d6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d71:	6a 00                	push   $0x0
  801d73:	e8 66 f0 ff ff       	call   800dde <sys_page_unmap>
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d7d:	89 d0                	mov    %edx,%eax
  801d7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d82:	5b                   	pop    %ebx
  801d83:	5e                   	pop    %esi
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8f:	50                   	push   %eax
  801d90:	ff 75 08             	pushl  0x8(%ebp)
  801d93:	e8 30 f5 ff ff       	call   8012c8 <fd_lookup>
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 18                	js     801db7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	ff 75 f4             	pushl  -0xc(%ebp)
  801da5:	e8 b8 f4 ff ff       	call   801262 <fd2data>
	return _pipeisclosed(fd, p);
  801daa:	89 c2                	mov    %eax,%edx
  801dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801daf:	e8 21 fd ff ff       	call   801ad5 <_pipeisclosed>
  801db4:	83 c4 10             	add    $0x10,%esp
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    

00801dc3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dc9:	68 45 29 80 00       	push   $0x802945
  801dce:	ff 75 0c             	pushl  0xc(%ebp)
  801dd1:	e8 80 eb ff ff       	call   800956 <strcpy>
	return 0;
}
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddb:	c9                   	leave  
  801ddc:	c3                   	ret    

00801ddd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	57                   	push   %edi
  801de1:	56                   	push   %esi
  801de2:	53                   	push   %ebx
  801de3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df4:	eb 2d                	jmp    801e23 <devcons_write+0x46>
		m = n - tot;
  801df6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dfb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dfe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e03:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e06:	83 ec 04             	sub    $0x4,%esp
  801e09:	53                   	push   %ebx
  801e0a:	03 45 0c             	add    0xc(%ebp),%eax
  801e0d:	50                   	push   %eax
  801e0e:	57                   	push   %edi
  801e0f:	e8 d4 ec ff ff       	call   800ae8 <memmove>
		sys_cputs(buf, m);
  801e14:	83 c4 08             	add    $0x8,%esp
  801e17:	53                   	push   %ebx
  801e18:	57                   	push   %edi
  801e19:	e8 7f ee ff ff       	call   800c9d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e1e:	01 de                	add    %ebx,%esi
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	89 f0                	mov    %esi,%eax
  801e25:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e28:	72 cc                	jb     801df6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2d:	5b                   	pop    %ebx
  801e2e:	5e                   	pop    %esi
  801e2f:	5f                   	pop    %edi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 08             	sub    $0x8,%esp
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e41:	74 2a                	je     801e6d <devcons_read+0x3b>
  801e43:	eb 05                	jmp    801e4a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e45:	e8 f0 ee ff ff       	call   800d3a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e4a:	e8 6c ee ff ff       	call   800cbb <sys_cgetc>
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	74 f2                	je     801e45 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 16                	js     801e6d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e57:	83 f8 04             	cmp    $0x4,%eax
  801e5a:	74 0c                	je     801e68 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e5f:	88 02                	mov    %al,(%edx)
	return 1;
  801e61:	b8 01 00 00 00       	mov    $0x1,%eax
  801e66:	eb 05                	jmp    801e6d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e68:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e75:	8b 45 08             	mov    0x8(%ebp),%eax
  801e78:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e7b:	6a 01                	push   $0x1
  801e7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e80:	50                   	push   %eax
  801e81:	e8 17 ee ff ff       	call   800c9d <sys_cputs>
}
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <getchar>:

int
getchar(void)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e91:	6a 01                	push   $0x1
  801e93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e96:	50                   	push   %eax
  801e97:	6a 00                	push   $0x0
  801e99:	e8 90 f6 ff ff       	call   80152e <read>
	if (r < 0)
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 0f                	js     801eb4 <getchar+0x29>
		return r;
	if (r < 1)
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	7e 06                	jle    801eaf <getchar+0x24>
		return -E_EOF;
	return c;
  801ea9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ead:	eb 05                	jmp    801eb4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eaf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ebc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebf:	50                   	push   %eax
  801ec0:	ff 75 08             	pushl  0x8(%ebp)
  801ec3:	e8 00 f4 ff ff       	call   8012c8 <fd_lookup>
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	78 11                	js     801ee0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed8:	39 10                	cmp    %edx,(%eax)
  801eda:	0f 94 c0             	sete   %al
  801edd:	0f b6 c0             	movzbl %al,%eax
}
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <opencons>:

int
opencons(void)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eeb:	50                   	push   %eax
  801eec:	e8 88 f3 ff ff       	call   801279 <fd_alloc>
  801ef1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 3e                	js     801f38 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801efa:	83 ec 04             	sub    $0x4,%esp
  801efd:	68 07 04 00 00       	push   $0x407
  801f02:	ff 75 f4             	pushl  -0xc(%ebp)
  801f05:	6a 00                	push   $0x0
  801f07:	e8 4d ee ff ff       	call   800d59 <sys_page_alloc>
  801f0c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f0f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f11:	85 c0                	test   %eax,%eax
  801f13:	78 23                	js     801f38 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f23:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f2a:	83 ec 0c             	sub    $0xc,%esp
  801f2d:	50                   	push   %eax
  801f2e:	e8 1f f3 ff ff       	call   801252 <fd2num>
  801f33:	89 c2                	mov    %eax,%edx
  801f35:	83 c4 10             	add    $0x10,%esp
}
  801f38:	89 d0                	mov    %edx,%eax
  801f3a:	c9                   	leave  
  801f3b:	c3                   	ret    

00801f3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f42:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f49:	75 2a                	jne    801f75 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f4b:	83 ec 04             	sub    $0x4,%esp
  801f4e:	6a 07                	push   $0x7
  801f50:	68 00 f0 bf ee       	push   $0xeebff000
  801f55:	6a 00                	push   $0x0
  801f57:	e8 fd ed ff ff       	call   800d59 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	79 12                	jns    801f75 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f63:	50                   	push   %eax
  801f64:	68 51 29 80 00       	push   $0x802951
  801f69:	6a 23                	push   $0x23
  801f6b:	68 55 29 80 00       	push   $0x802955
  801f70:	e8 83 e3 ff ff       	call   8002f8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f75:	8b 45 08             	mov    0x8(%ebp),%eax
  801f78:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f7d:	83 ec 08             	sub    $0x8,%esp
  801f80:	68 a7 1f 80 00       	push   $0x801fa7
  801f85:	6a 00                	push   $0x0
  801f87:	e8 18 ef ff ff       	call   800ea4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	79 12                	jns    801fa5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f93:	50                   	push   %eax
  801f94:	68 51 29 80 00       	push   $0x802951
  801f99:	6a 2c                	push   $0x2c
  801f9b:	68 55 29 80 00       	push   $0x802955
  801fa0:	e8 53 e3 ff ff       	call   8002f8 <_panic>
	}
}
  801fa5:	c9                   	leave  
  801fa6:	c3                   	ret    

00801fa7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fa7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fa8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fad:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801faf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fb2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fb6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fbb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fbf:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801fc1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fc4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801fc5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fc8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fc9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fca:	c3                   	ret    

00801fcb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	56                   	push   %esi
  801fcf:	53                   	push   %ebx
  801fd0:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	75 12                	jne    801fef <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801fdd:	83 ec 0c             	sub    $0xc,%esp
  801fe0:	68 00 00 c0 ee       	push   $0xeec00000
  801fe5:	e8 1f ef ff ff       	call   800f09 <sys_ipc_recv>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	eb 0c                	jmp    801ffb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	50                   	push   %eax
  801ff3:	e8 11 ef ff ff       	call   800f09 <sys_ipc_recv>
  801ff8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ffb:	85 f6                	test   %esi,%esi
  801ffd:	0f 95 c1             	setne  %cl
  802000:	85 db                	test   %ebx,%ebx
  802002:	0f 95 c2             	setne  %dl
  802005:	84 d1                	test   %dl,%cl
  802007:	74 09                	je     802012 <ipc_recv+0x47>
  802009:	89 c2                	mov    %eax,%edx
  80200b:	c1 ea 1f             	shr    $0x1f,%edx
  80200e:	84 d2                	test   %dl,%dl
  802010:	75 27                	jne    802039 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802012:	85 f6                	test   %esi,%esi
  802014:	74 0a                	je     802020 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  802016:	a1 04 40 80 00       	mov    0x804004,%eax
  80201b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80201e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802020:	85 db                	test   %ebx,%ebx
  802022:	74 0d                	je     802031 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  802024:	a1 04 40 80 00       	mov    0x804004,%eax
  802029:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80202f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802031:	a1 04 40 80 00       	mov    0x804004,%eax
  802036:	8b 40 78             	mov    0x78(%eax),%eax
}
  802039:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5e                   	pop    %esi
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

00802040 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	57                   	push   %edi
  802044:	56                   	push   %esi
  802045:	53                   	push   %ebx
  802046:	83 ec 0c             	sub    $0xc,%esp
  802049:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802052:	85 db                	test   %ebx,%ebx
  802054:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802059:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80205c:	ff 75 14             	pushl  0x14(%ebp)
  80205f:	53                   	push   %ebx
  802060:	56                   	push   %esi
  802061:	57                   	push   %edi
  802062:	e8 7f ee ff ff       	call   800ee6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802067:	89 c2                	mov    %eax,%edx
  802069:	c1 ea 1f             	shr    $0x1f,%edx
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	84 d2                	test   %dl,%dl
  802071:	74 17                	je     80208a <ipc_send+0x4a>
  802073:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802076:	74 12                	je     80208a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802078:	50                   	push   %eax
  802079:	68 63 29 80 00       	push   $0x802963
  80207e:	6a 47                	push   $0x47
  802080:	68 71 29 80 00       	push   $0x802971
  802085:	e8 6e e2 ff ff       	call   8002f8 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80208a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80208d:	75 07                	jne    802096 <ipc_send+0x56>
			sys_yield();
  80208f:	e8 a6 ec ff ff       	call   800d3a <sys_yield>
  802094:	eb c6                	jmp    80205c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802096:	85 c0                	test   %eax,%eax
  802098:	75 c2                	jne    80205c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80209a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    

008020a2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ad:	89 c2                	mov    %eax,%edx
  8020af:	c1 e2 07             	shl    $0x7,%edx
  8020b2:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8020b9:	8b 52 58             	mov    0x58(%edx),%edx
  8020bc:	39 ca                	cmp    %ecx,%edx
  8020be:	75 11                	jne    8020d1 <ipc_find_env+0x2f>
			return envs[i].env_id;
  8020c0:	89 c2                	mov    %eax,%edx
  8020c2:	c1 e2 07             	shl    $0x7,%edx
  8020c5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8020cc:	8b 40 50             	mov    0x50(%eax),%eax
  8020cf:	eb 0f                	jmp    8020e0 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d1:	83 c0 01             	add    $0x1,%eax
  8020d4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d9:	75 d2                	jne    8020ad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    

008020e2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e8:	89 d0                	mov    %edx,%eax
  8020ea:	c1 e8 16             	shr    $0x16,%eax
  8020ed:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f9:	f6 c1 01             	test   $0x1,%cl
  8020fc:	74 1d                	je     80211b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020fe:	c1 ea 0c             	shr    $0xc,%edx
  802101:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802108:	f6 c2 01             	test   $0x1,%dl
  80210b:	74 0e                	je     80211b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80210d:	c1 ea 0c             	shr    $0xc,%edx
  802110:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802117:	ef 
  802118:	0f b7 c0             	movzwl %ax,%eax
}
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    
  80211d:	66 90                	xchg   %ax,%ax
  80211f:	90                   	nop

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
