
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
  80004c:	e8 5d 15 00 00       	call   8015ae <readn>
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
  800074:	e8 42 02 00 00       	call   8002bb <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 01 24 80 00       	push   $0x802401
  800084:	e8 0b 03 00 00       	call   800394 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 9a 1b 00 00       	call   801c2b <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 05 24 80 00       	push   $0x802405
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 ef 23 80 00       	push   $0x8023ef
  8000a8:	e8 0e 02 00 00       	call   8002bb <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 71 0f 00 00       	call   801023 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 0e 24 80 00       	push   $0x80240e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 ef 23 80 00       	push   $0x8023ef
  8000c3:	e8 f3 01 00 00       	call   8002bb <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 0c 13 00 00       	call   8013e1 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 01 13 00 00       	call   8013e1 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 eb 12 00 00       	call   8013e1 <close>
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
  800106:	e8 a3 14 00 00       	call   8015ae <readn>
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
  800132:	e8 84 01 00 00       	call   8002bb <_panic>
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
  800149:	e8 a9 14 00 00       	call   8015f7 <write>
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
  800174:	e8 42 01 00 00       	call   8002bb <_panic>

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
  80018e:	e8 98 1a 00 00       	call   801c2b <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 05 24 80 00       	push   $0x802405
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 ef 23 80 00       	push   $0x8023ef
  8001aa:	e8 0c 01 00 00       	call   8002bb <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 6f 0e 00 00       	call   801023 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 0e 24 80 00       	push   $0x80240e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 ef 23 80 00       	push   $0x8023ef
  8001c5:	e8 f1 00 00 00       	call   8002bb <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 08 12 00 00       	call   8013e1 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 f2 11 00 00       	call   8013e1 <close>

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
  800205:	e8 ed 13 00 00       	call   8015f7 <write>
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
  80022d:	e8 89 00 00 00       	call   8002bb <_panic>
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
  800243:	e8 96 0a 00 00       	call   800cde <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800253:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800258:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025d:	85 db                	test   %ebx,%ebx
  80025f:	7e 07                	jle    800268 <libmain+0x30>
		binaryname = argv[0];
  800261:	8b 06                	mov    (%esi),%eax
  800263:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	e8 07 ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  800272:	e8 2a 00 00 00       	call   8002a1 <exit>
}
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800287:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80028c:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80028e:	e8 4b 0a 00 00       	call   800cde <sys_getenvid>
  800293:	83 ec 0c             	sub    $0xc,%esp
  800296:	50                   	push   %eax
  800297:	e8 91 0c 00 00       	call   800f2d <sys_thread_free>
}
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002a7:	e8 60 11 00 00       	call   80140c <close_all>
	sys_env_destroy(0);
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	6a 00                	push   $0x0
  8002b1:	e8 e7 09 00 00       	call   800c9d <sys_env_destroy>
}
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002c9:	e8 10 0a 00 00       	call   800cde <sys_getenvid>
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	ff 75 0c             	pushl  0xc(%ebp)
  8002d4:	ff 75 08             	pushl  0x8(%ebp)
  8002d7:	56                   	push   %esi
  8002d8:	50                   	push   %eax
  8002d9:	68 7c 24 80 00       	push   $0x80247c
  8002de:	e8 b1 00 00 00       	call   800394 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e3:	83 c4 18             	add    $0x18,%esp
  8002e6:	53                   	push   %ebx
  8002e7:	ff 75 10             	pushl  0x10(%ebp)
  8002ea:	e8 54 00 00 00       	call   800343 <vcprintf>
	cprintf("\n");
  8002ef:	c7 04 24 03 24 80 00 	movl   $0x802403,(%esp)
  8002f6:	e8 99 00 00 00       	call   800394 <cprintf>
  8002fb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002fe:	cc                   	int3   
  8002ff:	eb fd                	jmp    8002fe <_panic+0x43>

00800301 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	53                   	push   %ebx
  800305:	83 ec 04             	sub    $0x4,%esp
  800308:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80030b:	8b 13                	mov    (%ebx),%edx
  80030d:	8d 42 01             	lea    0x1(%edx),%eax
  800310:	89 03                	mov    %eax,(%ebx)
  800312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800315:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800319:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031e:	75 1a                	jne    80033a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	68 ff 00 00 00       	push   $0xff
  800328:	8d 43 08             	lea    0x8(%ebx),%eax
  80032b:	50                   	push   %eax
  80032c:	e8 2f 09 00 00       	call   800c60 <sys_cputs>
		b->idx = 0;
  800331:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800337:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80033a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800341:	c9                   	leave  
  800342:	c3                   	ret    

00800343 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80034c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800353:	00 00 00 
	b.cnt = 0;
  800356:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80035d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800360:	ff 75 0c             	pushl  0xc(%ebp)
  800363:	ff 75 08             	pushl  0x8(%ebp)
  800366:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036c:	50                   	push   %eax
  80036d:	68 01 03 80 00       	push   $0x800301
  800372:	e8 54 01 00 00       	call   8004cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800377:	83 c4 08             	add    $0x8,%esp
  80037a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800380:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800386:	50                   	push   %eax
  800387:	e8 d4 08 00 00       	call   800c60 <sys_cputs>

	return b.cnt;
}
  80038c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80039a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80039d:	50                   	push   %eax
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 9d ff ff ff       	call   800343 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
  8003ae:	83 ec 1c             	sub    $0x1c,%esp
  8003b1:	89 c7                	mov    %eax,%edi
  8003b3:	89 d6                	mov    %edx,%esi
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003cf:	39 d3                	cmp    %edx,%ebx
  8003d1:	72 05                	jb     8003d8 <printnum+0x30>
  8003d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003d6:	77 45                	ja     80041d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d8:	83 ec 0c             	sub    $0xc,%esp
  8003db:	ff 75 18             	pushl  0x18(%ebp)
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003e4:	53                   	push   %ebx
  8003e5:	ff 75 10             	pushl  0x10(%ebp)
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f7:	e8 24 1d 00 00       	call   802120 <__udivdi3>
  8003fc:	83 c4 18             	add    $0x18,%esp
  8003ff:	52                   	push   %edx
  800400:	50                   	push   %eax
  800401:	89 f2                	mov    %esi,%edx
  800403:	89 f8                	mov    %edi,%eax
  800405:	e8 9e ff ff ff       	call   8003a8 <printnum>
  80040a:	83 c4 20             	add    $0x20,%esp
  80040d:	eb 18                	jmp    800427 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	56                   	push   %esi
  800413:	ff 75 18             	pushl  0x18(%ebp)
  800416:	ff d7                	call   *%edi
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	eb 03                	jmp    800420 <printnum+0x78>
  80041d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800420:	83 eb 01             	sub    $0x1,%ebx
  800423:	85 db                	test   %ebx,%ebx
  800425:	7f e8                	jg     80040f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	56                   	push   %esi
  80042b:	83 ec 04             	sub    $0x4,%esp
  80042e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800431:	ff 75 e0             	pushl  -0x20(%ebp)
  800434:	ff 75 dc             	pushl  -0x24(%ebp)
  800437:	ff 75 d8             	pushl  -0x28(%ebp)
  80043a:	e8 11 1e 00 00       	call   802250 <__umoddi3>
  80043f:	83 c4 14             	add    $0x14,%esp
  800442:	0f be 80 9f 24 80 00 	movsbl 0x80249f(%eax),%eax
  800449:	50                   	push   %eax
  80044a:	ff d7                	call   *%edi
}
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800452:	5b                   	pop    %ebx
  800453:	5e                   	pop    %esi
  800454:	5f                   	pop    %edi
  800455:	5d                   	pop    %ebp
  800456:	c3                   	ret    

00800457 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80045a:	83 fa 01             	cmp    $0x1,%edx
  80045d:	7e 0e                	jle    80046d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80045f:	8b 10                	mov    (%eax),%edx
  800461:	8d 4a 08             	lea    0x8(%edx),%ecx
  800464:	89 08                	mov    %ecx,(%eax)
  800466:	8b 02                	mov    (%edx),%eax
  800468:	8b 52 04             	mov    0x4(%edx),%edx
  80046b:	eb 22                	jmp    80048f <getuint+0x38>
	else if (lflag)
  80046d:	85 d2                	test   %edx,%edx
  80046f:	74 10                	je     800481 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800471:	8b 10                	mov    (%eax),%edx
  800473:	8d 4a 04             	lea    0x4(%edx),%ecx
  800476:	89 08                	mov    %ecx,(%eax)
  800478:	8b 02                	mov    (%edx),%eax
  80047a:	ba 00 00 00 00       	mov    $0x0,%edx
  80047f:	eb 0e                	jmp    80048f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800481:	8b 10                	mov    (%eax),%edx
  800483:	8d 4a 04             	lea    0x4(%edx),%ecx
  800486:	89 08                	mov    %ecx,(%eax)
  800488:	8b 02                	mov    (%edx),%eax
  80048a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80048f:	5d                   	pop    %ebp
  800490:	c3                   	ret    

00800491 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800497:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049b:	8b 10                	mov    (%eax),%edx
  80049d:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a0:	73 0a                	jae    8004ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004aa:	88 02                	mov    %al,(%edx)
}
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b7:	50                   	push   %eax
  8004b8:	ff 75 10             	pushl  0x10(%ebp)
  8004bb:	ff 75 0c             	pushl  0xc(%ebp)
  8004be:	ff 75 08             	pushl  0x8(%ebp)
  8004c1:	e8 05 00 00 00       	call   8004cb <vprintfmt>
	va_end(ap);
}
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	c9                   	leave  
  8004ca:	c3                   	ret    

008004cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	57                   	push   %edi
  8004cf:	56                   	push   %esi
  8004d0:	53                   	push   %ebx
  8004d1:	83 ec 2c             	sub    $0x2c,%esp
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004dd:	eb 12                	jmp    8004f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	0f 84 89 03 00 00    	je     800870 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	50                   	push   %eax
  8004ec:	ff d6                	call   *%esi
  8004ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f1:	83 c7 01             	add    $0x1,%edi
  8004f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f8:	83 f8 25             	cmp    $0x25,%eax
  8004fb:	75 e2                	jne    8004df <vprintfmt+0x14>
  8004fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800501:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800508:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800516:	ba 00 00 00 00       	mov    $0x0,%edx
  80051b:	eb 07                	jmp    800524 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800520:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8d 47 01             	lea    0x1(%edi),%eax
  800527:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052a:	0f b6 07             	movzbl (%edi),%eax
  80052d:	0f b6 c8             	movzbl %al,%ecx
  800530:	83 e8 23             	sub    $0x23,%eax
  800533:	3c 55                	cmp    $0x55,%al
  800535:	0f 87 1a 03 00 00    	ja     800855 <vprintfmt+0x38a>
  80053b:	0f b6 c0             	movzbl %al,%eax
  80053e:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800548:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054c:	eb d6                	jmp    800524 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800551:	b8 00 00 00 00       	mov    $0x0,%eax
  800556:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800559:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800560:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800563:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800566:	83 fa 09             	cmp    $0x9,%edx
  800569:	77 39                	ja     8005a4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80056e:	eb e9                	jmp    800559 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 48 04             	lea    0x4(%eax),%ecx
  800576:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800581:	eb 27                	jmp    8005aa <vprintfmt+0xdf>
  800583:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800586:	85 c0                	test   %eax,%eax
  800588:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058d:	0f 49 c8             	cmovns %eax,%ecx
  800590:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800593:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800596:	eb 8c                	jmp    800524 <vprintfmt+0x59>
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005a2:	eb 80                	jmp    800524 <vprintfmt+0x59>
  8005a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ae:	0f 89 70 ff ff ff    	jns    800524 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c1:	e9 5e ff ff ff       	jmp    800524 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005cc:	e9 53 ff ff ff       	jmp    800524 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	53                   	push   %ebx
  8005de:	ff 30                	pushl  (%eax)
  8005e0:	ff d6                	call   *%esi
			break;
  8005e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e8:	e9 04 ff ff ff       	jmp    8004f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	99                   	cltd   
  8005f9:	31 d0                	xor    %edx,%eax
  8005fb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fd:	83 f8 0f             	cmp    $0xf,%eax
  800600:	7f 0b                	jg     80060d <vprintfmt+0x142>
  800602:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800609:	85 d2                	test   %edx,%edx
  80060b:	75 18                	jne    800625 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80060d:	50                   	push   %eax
  80060e:	68 b7 24 80 00       	push   $0x8024b7
  800613:	53                   	push   %ebx
  800614:	56                   	push   %esi
  800615:	e8 94 fe ff ff       	call   8004ae <printfmt>
  80061a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800620:	e9 cc fe ff ff       	jmp    8004f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800625:	52                   	push   %edx
  800626:	68 f1 28 80 00       	push   $0x8028f1
  80062b:	53                   	push   %ebx
  80062c:	56                   	push   %esi
  80062d:	e8 7c fe ff ff       	call   8004ae <printfmt>
  800632:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800638:	e9 b4 fe ff ff       	jmp    8004f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800648:	85 ff                	test   %edi,%edi
  80064a:	b8 b0 24 80 00       	mov    $0x8024b0,%eax
  80064f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800652:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800656:	0f 8e 94 00 00 00    	jle    8006f0 <vprintfmt+0x225>
  80065c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800660:	0f 84 98 00 00 00    	je     8006fe <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	ff 75 d0             	pushl  -0x30(%ebp)
  80066c:	57                   	push   %edi
  80066d:	e8 86 02 00 00       	call   8008f8 <strnlen>
  800672:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800675:	29 c1                	sub    %eax,%ecx
  800677:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80067a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80067d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800681:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800684:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800687:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800689:	eb 0f                	jmp    80069a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	ff 75 e0             	pushl  -0x20(%ebp)
  800692:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800694:	83 ef 01             	sub    $0x1,%edi
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	85 ff                	test   %edi,%edi
  80069c:	7f ed                	jg     80068b <vprintfmt+0x1c0>
  80069e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ab:	0f 49 c1             	cmovns %ecx,%eax
  8006ae:	29 c1                	sub    %eax,%ecx
  8006b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b9:	89 cb                	mov    %ecx,%ebx
  8006bb:	eb 4d                	jmp    80070a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c1:	74 1b                	je     8006de <vprintfmt+0x213>
  8006c3:	0f be c0             	movsbl %al,%eax
  8006c6:	83 e8 20             	sub    $0x20,%eax
  8006c9:	83 f8 5e             	cmp    $0x5e,%eax
  8006cc:	76 10                	jbe    8006de <vprintfmt+0x213>
					putch('?', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	ff 75 0c             	pushl  0xc(%ebp)
  8006d4:	6a 3f                	push   $0x3f
  8006d6:	ff 55 08             	call   *0x8(%ebp)
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	eb 0d                	jmp    8006eb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	ff 75 0c             	pushl  0xc(%ebp)
  8006e4:	52                   	push   %edx
  8006e5:	ff 55 08             	call   *0x8(%ebp)
  8006e8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006eb:	83 eb 01             	sub    $0x1,%ebx
  8006ee:	eb 1a                	jmp    80070a <vprintfmt+0x23f>
  8006f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006fc:	eb 0c                	jmp    80070a <vprintfmt+0x23f>
  8006fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800701:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800704:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800707:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070a:	83 c7 01             	add    $0x1,%edi
  80070d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800711:	0f be d0             	movsbl %al,%edx
  800714:	85 d2                	test   %edx,%edx
  800716:	74 23                	je     80073b <vprintfmt+0x270>
  800718:	85 f6                	test   %esi,%esi
  80071a:	78 a1                	js     8006bd <vprintfmt+0x1f2>
  80071c:	83 ee 01             	sub    $0x1,%esi
  80071f:	79 9c                	jns    8006bd <vprintfmt+0x1f2>
  800721:	89 df                	mov    %ebx,%edi
  800723:	8b 75 08             	mov    0x8(%ebp),%esi
  800726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800729:	eb 18                	jmp    800743 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 20                	push   $0x20
  800731:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800733:	83 ef 01             	sub    $0x1,%edi
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 08                	jmp    800743 <vprintfmt+0x278>
  80073b:	89 df                	mov    %ebx,%edi
  80073d:	8b 75 08             	mov    0x8(%ebp),%esi
  800740:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800743:	85 ff                	test   %edi,%edi
  800745:	7f e4                	jg     80072b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074a:	e9 a2 fd ff ff       	jmp    8004f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074f:	83 fa 01             	cmp    $0x1,%edx
  800752:	7e 16                	jle    80076a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 08             	lea    0x8(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)
  80075d:	8b 50 04             	mov    0x4(%eax),%edx
  800760:	8b 00                	mov    (%eax),%eax
  800762:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800765:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800768:	eb 32                	jmp    80079c <vprintfmt+0x2d1>
	else if (lflag)
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 18                	je     800786 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8d 50 04             	lea    0x4(%eax),%edx
  800774:	89 55 14             	mov    %edx,0x14(%ebp)
  800777:	8b 00                	mov    (%eax),%eax
  800779:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077c:	89 c1                	mov    %eax,%ecx
  80077e:	c1 f9 1f             	sar    $0x1f,%ecx
  800781:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800784:	eb 16                	jmp    80079c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 04             	lea    0x4(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800794:	89 c1                	mov    %eax,%ecx
  800796:	c1 f9 1f             	sar    $0x1f,%ecx
  800799:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80079c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80079f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ab:	79 74                	jns    800821 <vprintfmt+0x356>
				putch('-', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 2d                	push   $0x2d
  8007b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007bb:	f7 d8                	neg    %eax
  8007bd:	83 d2 00             	adc    $0x0,%edx
  8007c0:	f7 da                	neg    %edx
  8007c2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ca:	eb 55                	jmp    800821 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cf:	e8 83 fc ff ff       	call   800457 <getuint>
			base = 10;
  8007d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007d9:	eb 46                	jmp    800821 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 74 fc ff ff       	call   800457 <getuint>
			base = 8;
  8007e3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007e8:	eb 37                	jmp    800821 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 30                	push   $0x30
  8007f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	53                   	push   %ebx
  8007f6:	6a 78                	push   $0x78
  8007f8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800803:	8b 00                	mov    (%eax),%eax
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80080a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800812:	eb 0d                	jmp    800821 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800814:	8d 45 14             	lea    0x14(%ebp),%eax
  800817:	e8 3b fc ff ff       	call   800457 <getuint>
			base = 16;
  80081c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800828:	57                   	push   %edi
  800829:	ff 75 e0             	pushl  -0x20(%ebp)
  80082c:	51                   	push   %ecx
  80082d:	52                   	push   %edx
  80082e:	50                   	push   %eax
  80082f:	89 da                	mov    %ebx,%edx
  800831:	89 f0                	mov    %esi,%eax
  800833:	e8 70 fb ff ff       	call   8003a8 <printnum>
			break;
  800838:	83 c4 20             	add    $0x20,%esp
  80083b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80083e:	e9 ae fc ff ff       	jmp    8004f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	51                   	push   %ecx
  800848:	ff d6                	call   *%esi
			break;
  80084a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800850:	e9 9c fc ff ff       	jmp    8004f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	53                   	push   %ebx
  800859:	6a 25                	push   $0x25
  80085b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	eb 03                	jmp    800865 <vprintfmt+0x39a>
  800862:	83 ef 01             	sub    $0x1,%edi
  800865:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800869:	75 f7                	jne    800862 <vprintfmt+0x397>
  80086b:	e9 81 fc ff ff       	jmp    8004f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800870:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5f                   	pop    %edi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 18             	sub    $0x18,%esp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800884:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800887:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800895:	85 c0                	test   %eax,%eax
  800897:	74 26                	je     8008bf <vsnprintf+0x47>
  800899:	85 d2                	test   %edx,%edx
  80089b:	7e 22                	jle    8008bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089d:	ff 75 14             	pushl  0x14(%ebp)
  8008a0:	ff 75 10             	pushl  0x10(%ebp)
  8008a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a6:	50                   	push   %eax
  8008a7:	68 91 04 80 00       	push   $0x800491
  8008ac:	e8 1a fc ff ff       	call   8004cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	eb 05                	jmp    8008c4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008cf:	50                   	push   %eax
  8008d0:	ff 75 10             	pushl  0x10(%ebp)
  8008d3:	ff 75 0c             	pushl  0xc(%ebp)
  8008d6:	ff 75 08             	pushl  0x8(%ebp)
  8008d9:	e8 9a ff ff ff       	call   800878 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 03                	jmp    8008f0 <strlen+0x10>
		n++;
  8008ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f4:	75 f7                	jne    8008ed <strlen+0xd>
		n++;
	return n;
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800901:	ba 00 00 00 00       	mov    $0x0,%edx
  800906:	eb 03                	jmp    80090b <strnlen+0x13>
		n++;
  800908:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090b:	39 c2                	cmp    %eax,%edx
  80090d:	74 08                	je     800917 <strnlen+0x1f>
  80090f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800913:	75 f3                	jne    800908 <strnlen+0x10>
  800915:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	53                   	push   %ebx
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800923:	89 c2                	mov    %eax,%edx
  800925:	83 c2 01             	add    $0x1,%edx
  800928:	83 c1 01             	add    $0x1,%ecx
  80092b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80092f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800932:	84 db                	test   %bl,%bl
  800934:	75 ef                	jne    800925 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	53                   	push   %ebx
  80093d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800940:	53                   	push   %ebx
  800941:	e8 9a ff ff ff       	call   8008e0 <strlen>
  800946:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800949:	ff 75 0c             	pushl  0xc(%ebp)
  80094c:	01 d8                	add    %ebx,%eax
  80094e:	50                   	push   %eax
  80094f:	e8 c5 ff ff ff       	call   800919 <strcpy>
	return dst;
}
  800954:	89 d8                	mov    %ebx,%eax
  800956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 75 08             	mov    0x8(%ebp),%esi
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800966:	89 f3                	mov    %esi,%ebx
  800968:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096b:	89 f2                	mov    %esi,%edx
  80096d:	eb 0f                	jmp    80097e <strncpy+0x23>
		*dst++ = *src;
  80096f:	83 c2 01             	add    $0x1,%edx
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800978:	80 39 01             	cmpb   $0x1,(%ecx)
  80097b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097e:	39 da                	cmp    %ebx,%edx
  800980:	75 ed                	jne    80096f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800982:	89 f0                	mov    %esi,%eax
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 75 08             	mov    0x8(%ebp),%esi
  800990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800993:	8b 55 10             	mov    0x10(%ebp),%edx
  800996:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800998:	85 d2                	test   %edx,%edx
  80099a:	74 21                	je     8009bd <strlcpy+0x35>
  80099c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a0:	89 f2                	mov    %esi,%edx
  8009a2:	eb 09                	jmp    8009ad <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a4:	83 c2 01             	add    $0x1,%edx
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ad:	39 c2                	cmp    %eax,%edx
  8009af:	74 09                	je     8009ba <strlcpy+0x32>
  8009b1:	0f b6 19             	movzbl (%ecx),%ebx
  8009b4:	84 db                	test   %bl,%bl
  8009b6:	75 ec                	jne    8009a4 <strlcpy+0x1c>
  8009b8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009bd:	29 f0                	sub    %esi,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009cc:	eb 06                	jmp    8009d4 <strcmp+0x11>
		p++, q++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
  8009d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d4:	0f b6 01             	movzbl (%ecx),%eax
  8009d7:	84 c0                	test   %al,%al
  8009d9:	74 04                	je     8009df <strcmp+0x1c>
  8009db:	3a 02                	cmp    (%edx),%al
  8009dd:	74 ef                	je     8009ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009df:	0f b6 c0             	movzbl %al,%eax
  8009e2:	0f b6 12             	movzbl (%edx),%edx
  8009e5:	29 d0                	sub    %edx,%eax
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f3:	89 c3                	mov    %eax,%ebx
  8009f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f8:	eb 06                	jmp    800a00 <strncmp+0x17>
		n--, p++, q++;
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a00:	39 d8                	cmp    %ebx,%eax
  800a02:	74 15                	je     800a19 <strncmp+0x30>
  800a04:	0f b6 08             	movzbl (%eax),%ecx
  800a07:	84 c9                	test   %cl,%cl
  800a09:	74 04                	je     800a0f <strncmp+0x26>
  800a0b:	3a 0a                	cmp    (%edx),%cl
  800a0d:	74 eb                	je     8009fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0f:	0f b6 00             	movzbl (%eax),%eax
  800a12:	0f b6 12             	movzbl (%edx),%edx
  800a15:	29 d0                	sub    %edx,%eax
  800a17:	eb 05                	jmp    800a1e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2b:	eb 07                	jmp    800a34 <strchr+0x13>
		if (*s == c)
  800a2d:	38 ca                	cmp    %cl,%dl
  800a2f:	74 0f                	je     800a40 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a31:	83 c0 01             	add    $0x1,%eax
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	84 d2                	test   %dl,%dl
  800a39:	75 f2                	jne    800a2d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4c:	eb 03                	jmp    800a51 <strfind+0xf>
  800a4e:	83 c0 01             	add    $0x1,%eax
  800a51:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 04                	je     800a5c <strfind+0x1a>
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	75 f2                	jne    800a4e <strfind+0xc>
			break;
	return (char *) s;
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6a:	85 c9                	test   %ecx,%ecx
  800a6c:	74 36                	je     800aa4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a74:	75 28                	jne    800a9e <memset+0x40>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 23                	jne    800a9e <memset+0x40>
		c &= 0xFF;
  800a7b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7f:	89 d3                	mov    %edx,%ebx
  800a81:	c1 e3 08             	shl    $0x8,%ebx
  800a84:	89 d6                	mov    %edx,%esi
  800a86:	c1 e6 18             	shl    $0x18,%esi
  800a89:	89 d0                	mov    %edx,%eax
  800a8b:	c1 e0 10             	shl    $0x10,%eax
  800a8e:	09 f0                	or     %esi,%eax
  800a90:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a92:	89 d8                	mov    %ebx,%eax
  800a94:	09 d0                	or     %edx,%eax
  800a96:	c1 e9 02             	shr    $0x2,%ecx
  800a99:	fc                   	cld    
  800a9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9c:	eb 06                	jmp    800aa4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	fc                   	cld    
  800aa2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa4:	89 f8                	mov    %edi,%eax
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab9:	39 c6                	cmp    %eax,%esi
  800abb:	73 35                	jae    800af2 <memmove+0x47>
  800abd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac0:	39 d0                	cmp    %edx,%eax
  800ac2:	73 2e                	jae    800af2 <memmove+0x47>
		s += n;
		d += n;
  800ac4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac7:	89 d6                	mov    %edx,%esi
  800ac9:	09 fe                	or     %edi,%esi
  800acb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad1:	75 13                	jne    800ae6 <memmove+0x3b>
  800ad3:	f6 c1 03             	test   $0x3,%cl
  800ad6:	75 0e                	jne    800ae6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad8:	83 ef 04             	sub    $0x4,%edi
  800adb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ade:	c1 e9 02             	shr    $0x2,%ecx
  800ae1:	fd                   	std    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb 09                	jmp    800aef <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae6:	83 ef 01             	sub    $0x1,%edi
  800ae9:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aec:	fd                   	std    
  800aed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aef:	fc                   	cld    
  800af0:	eb 1d                	jmp    800b0f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af2:	89 f2                	mov    %esi,%edx
  800af4:	09 c2                	or     %eax,%edx
  800af6:	f6 c2 03             	test   $0x3,%dl
  800af9:	75 0f                	jne    800b0a <memmove+0x5f>
  800afb:	f6 c1 03             	test   $0x3,%cl
  800afe:	75 0a                	jne    800b0a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b00:	c1 e9 02             	shr    $0x2,%ecx
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	fc                   	cld    
  800b06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b08:	eb 05                	jmp    800b0f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0a:	89 c7                	mov    %eax,%edi
  800b0c:	fc                   	cld    
  800b0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b16:	ff 75 10             	pushl  0x10(%ebp)
  800b19:	ff 75 0c             	pushl  0xc(%ebp)
  800b1c:	ff 75 08             	pushl  0x8(%ebp)
  800b1f:	e8 87 ff ff ff       	call   800aab <memmove>
}
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b31:	89 c6                	mov    %eax,%esi
  800b33:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b36:	eb 1a                	jmp    800b52 <memcmp+0x2c>
		if (*s1 != *s2)
  800b38:	0f b6 08             	movzbl (%eax),%ecx
  800b3b:	0f b6 1a             	movzbl (%edx),%ebx
  800b3e:	38 d9                	cmp    %bl,%cl
  800b40:	74 0a                	je     800b4c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b42:	0f b6 c1             	movzbl %cl,%eax
  800b45:	0f b6 db             	movzbl %bl,%ebx
  800b48:	29 d8                	sub    %ebx,%eax
  800b4a:	eb 0f                	jmp    800b5b <memcmp+0x35>
		s1++, s2++;
  800b4c:	83 c0 01             	add    $0x1,%eax
  800b4f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b52:	39 f0                	cmp    %esi,%eax
  800b54:	75 e2                	jne    800b38 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	53                   	push   %ebx
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b66:	89 c1                	mov    %eax,%ecx
  800b68:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6f:	eb 0a                	jmp    800b7b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b71:	0f b6 10             	movzbl (%eax),%edx
  800b74:	39 da                	cmp    %ebx,%edx
  800b76:	74 07                	je     800b7f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b78:	83 c0 01             	add    $0x1,%eax
  800b7b:	39 c8                	cmp    %ecx,%eax
  800b7d:	72 f2                	jb     800b71 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8e:	eb 03                	jmp    800b93 <strtol+0x11>
		s++;
  800b90:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b93:	0f b6 01             	movzbl (%ecx),%eax
  800b96:	3c 20                	cmp    $0x20,%al
  800b98:	74 f6                	je     800b90 <strtol+0xe>
  800b9a:	3c 09                	cmp    $0x9,%al
  800b9c:	74 f2                	je     800b90 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b9e:	3c 2b                	cmp    $0x2b,%al
  800ba0:	75 0a                	jne    800bac <strtol+0x2a>
		s++;
  800ba2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba5:	bf 00 00 00 00       	mov    $0x0,%edi
  800baa:	eb 11                	jmp    800bbd <strtol+0x3b>
  800bac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb1:	3c 2d                	cmp    $0x2d,%al
  800bb3:	75 08                	jne    800bbd <strtol+0x3b>
		s++, neg = 1;
  800bb5:	83 c1 01             	add    $0x1,%ecx
  800bb8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc3:	75 15                	jne    800bda <strtol+0x58>
  800bc5:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc8:	75 10                	jne    800bda <strtol+0x58>
  800bca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bce:	75 7c                	jne    800c4c <strtol+0xca>
		s += 2, base = 16;
  800bd0:	83 c1 02             	add    $0x2,%ecx
  800bd3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd8:	eb 16                	jmp    800bf0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bda:	85 db                	test   %ebx,%ebx
  800bdc:	75 12                	jne    800bf0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bde:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be3:	80 39 30             	cmpb   $0x30,(%ecx)
  800be6:	75 08                	jne    800bf0 <strtol+0x6e>
		s++, base = 8;
  800be8:	83 c1 01             	add    $0x1,%ecx
  800beb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	0f b6 11             	movzbl (%ecx),%edx
  800bfb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bfe:	89 f3                	mov    %esi,%ebx
  800c00:	80 fb 09             	cmp    $0x9,%bl
  800c03:	77 08                	ja     800c0d <strtol+0x8b>
			dig = *s - '0';
  800c05:	0f be d2             	movsbl %dl,%edx
  800c08:	83 ea 30             	sub    $0x30,%edx
  800c0b:	eb 22                	jmp    800c2f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c10:	89 f3                	mov    %esi,%ebx
  800c12:	80 fb 19             	cmp    $0x19,%bl
  800c15:	77 08                	ja     800c1f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c17:	0f be d2             	movsbl %dl,%edx
  800c1a:	83 ea 57             	sub    $0x57,%edx
  800c1d:	eb 10                	jmp    800c2f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c22:	89 f3                	mov    %esi,%ebx
  800c24:	80 fb 19             	cmp    $0x19,%bl
  800c27:	77 16                	ja     800c3f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c29:	0f be d2             	movsbl %dl,%edx
  800c2c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c2f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c32:	7d 0b                	jge    800c3f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c34:	83 c1 01             	add    $0x1,%ecx
  800c37:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c3d:	eb b9                	jmp    800bf8 <strtol+0x76>

	if (endptr)
  800c3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c43:	74 0d                	je     800c52 <strtol+0xd0>
		*endptr = (char *) s;
  800c45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c48:	89 0e                	mov    %ecx,(%esi)
  800c4a:	eb 06                	jmp    800c52 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	85 db                	test   %ebx,%ebx
  800c4e:	74 98                	je     800be8 <strtol+0x66>
  800c50:	eb 9e                	jmp    800bf0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	f7 da                	neg    %edx
  800c56:	85 ff                	test   %edi,%edi
  800c58:	0f 45 c2             	cmovne %edx,%eax
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	89 c7                	mov    %eax,%edi
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_cgetc>:

int
sys_cgetc(void)
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
  800c89:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	89 d3                	mov    %edx,%ebx
  800c92:	89 d7                	mov    %edx,%edi
  800c94:	89 d6                	mov    %edx,%esi
  800c96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800ca6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cab:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 cb                	mov    %ecx,%ebx
  800cb5:	89 cf                	mov    %ecx,%edi
  800cb7:	89 ce                	mov    %ecx,%esi
  800cb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 17                	jle    800cd6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 03                	push   $0x3
  800cc5:	68 9f 27 80 00       	push   $0x80279f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 bc 27 80 00       	push   $0x8027bc
  800cd1:	e8 e5 f5 ff ff       	call   8002bb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cee:	89 d1                	mov    %edx,%ecx
  800cf0:	89 d3                	mov    %edx,%ebx
  800cf2:	89 d7                	mov    %edx,%edi
  800cf4:	89 d6                	mov    %edx,%esi
  800cf6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_yield>:

void
sys_yield(void)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	ba 00 00 00 00       	mov    $0x0,%edx
  800d08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0d:	89 d1                	mov    %edx,%ecx
  800d0f:	89 d3                	mov    %edx,%ebx
  800d11:	89 d7                	mov    %edx,%edi
  800d13:	89 d6                	mov    %edx,%esi
  800d15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d25:	be 00 00 00 00       	mov    $0x0,%esi
  800d2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d38:	89 f7                	mov    %esi,%edi
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 04                	push   $0x4
  800d46:	68 9f 27 80 00       	push   $0x80279f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 bc 27 80 00       	push   $0x8027bc
  800d52:	e8 64 f5 ff ff       	call   8002bb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d79:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 05                	push   $0x5
  800d88:	68 9f 27 80 00       	push   $0x80279f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 bc 27 80 00       	push   $0x8027bc
  800d94:	e8 22 f5 ff ff       	call   8002bb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daf:	b8 06 00 00 00       	mov    $0x6,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 df                	mov    %ebx,%edi
  800dbc:	89 de                	mov    %ebx,%esi
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 17                	jle    800ddb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	50                   	push   %eax
  800dc8:	6a 06                	push   $0x6
  800dca:	68 9f 27 80 00       	push   $0x80279f
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 bc 27 80 00       	push   $0x8027bc
  800dd6:	e8 e0 f4 ff ff       	call   8002bb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df1:	b8 08 00 00 00       	mov    $0x8,%eax
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	89 df                	mov    %ebx,%edi
  800dfe:	89 de                	mov    %ebx,%esi
  800e00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 17                	jle    800e1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	50                   	push   %eax
  800e0a:	6a 08                	push   $0x8
  800e0c:	68 9f 27 80 00       	push   $0x80279f
  800e11:	6a 23                	push   $0x23
  800e13:	68 bc 27 80 00       	push   $0x8027bc
  800e18:	e8 9e f4 ff ff       	call   8002bb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	b8 09 00 00 00       	mov    $0x9,%eax
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	89 de                	mov    %ebx,%esi
  800e42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	7e 17                	jle    800e5f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	50                   	push   %eax
  800e4c:	6a 09                	push   $0x9
  800e4e:	68 9f 27 80 00       	push   $0x80279f
  800e53:	6a 23                	push   $0x23
  800e55:	68 bc 27 80 00       	push   $0x8027bc
  800e5a:	e8 5c f4 ff ff       	call   8002bb <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 df                	mov    %ebx,%edi
  800e82:	89 de                	mov    %ebx,%esi
  800e84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7e 17                	jle    800ea1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	50                   	push   %eax
  800e8e:	6a 0a                	push   $0xa
  800e90:	68 9f 27 80 00       	push   $0x80279f
  800e95:	6a 23                	push   $0x23
  800e97:	68 bc 27 80 00       	push   $0x8027bc
  800e9c:	e8 1a f4 ff ff       	call   8002bb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	be 00 00 00 00       	mov    $0x0,%esi
  800eb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	57                   	push   %edi
  800ed0:	56                   	push   %esi
  800ed1:	53                   	push   %ebx
  800ed2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee2:	89 cb                	mov    %ecx,%ebx
  800ee4:	89 cf                	mov    %ecx,%edi
  800ee6:	89 ce                	mov    %ecx,%esi
  800ee8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 17                	jle    800f05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	50                   	push   %eax
  800ef2:	6a 0d                	push   $0xd
  800ef4:	68 9f 27 80 00       	push   $0x80279f
  800ef9:	6a 23                	push   $0x23
  800efb:	68 bc 27 80 00       	push   $0x8027bc
  800f00:	e8 b6 f3 ff ff       	call   8002bb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f18:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	89 cb                	mov    %ecx,%ebx
  800f22:	89 cf                	mov    %ecx,%edi
  800f24:	89 ce                	mov    %ecx,%esi
  800f26:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f38:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 cb                	mov    %ecx,%ebx
  800f42:	89 cf                	mov    %ecx,%edi
  800f44:	89 ce                	mov    %ecx,%esi
  800f46:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	53                   	push   %ebx
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f57:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f59:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5d:	74 11                	je     800f70 <pgfault+0x23>
  800f5f:	89 d8                	mov    %ebx,%eax
  800f61:	c1 e8 0c             	shr    $0xc,%eax
  800f64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6b:	f6 c4 08             	test   $0x8,%ah
  800f6e:	75 14                	jne    800f84 <pgfault+0x37>
		panic("faulting access");
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	68 ca 27 80 00       	push   $0x8027ca
  800f78:	6a 1e                	push   $0x1e
  800f7a:	68 da 27 80 00       	push   $0x8027da
  800f7f:	e8 37 f3 ff ff       	call   8002bb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	6a 07                	push   $0x7
  800f89:	68 00 f0 7f 00       	push   $0x7ff000
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 87 fd ff ff       	call   800d1c <sys_page_alloc>
	if (r < 0) {
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 12                	jns    800fae <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f9c:	50                   	push   %eax
  800f9d:	68 e5 27 80 00       	push   $0x8027e5
  800fa2:	6a 2c                	push   $0x2c
  800fa4:	68 da 27 80 00       	push   $0x8027da
  800fa9:	e8 0d f3 ff ff       	call   8002bb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800fae:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	68 00 10 00 00       	push   $0x1000
  800fbc:	53                   	push   %ebx
  800fbd:	68 00 f0 7f 00       	push   $0x7ff000
  800fc2:	e8 4c fb ff ff       	call   800b13 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800fc7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fce:	53                   	push   %ebx
  800fcf:	6a 00                	push   $0x0
  800fd1:	68 00 f0 7f 00       	push   $0x7ff000
  800fd6:	6a 00                	push   $0x0
  800fd8:	e8 82 fd ff ff       	call   800d5f <sys_page_map>
	if (r < 0) {
  800fdd:	83 c4 20             	add    $0x20,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	79 12                	jns    800ff6 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800fe4:	50                   	push   %eax
  800fe5:	68 e5 27 80 00       	push   $0x8027e5
  800fea:	6a 33                	push   $0x33
  800fec:	68 da 27 80 00       	push   $0x8027da
  800ff1:	e8 c5 f2 ff ff       	call   8002bb <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ff6:	83 ec 08             	sub    $0x8,%esp
  800ff9:	68 00 f0 7f 00       	push   $0x7ff000
  800ffe:	6a 00                	push   $0x0
  801000:	e8 9c fd ff ff       	call   800da1 <sys_page_unmap>
	if (r < 0) {
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	79 12                	jns    80101e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80100c:	50                   	push   %eax
  80100d:	68 e5 27 80 00       	push   $0x8027e5
  801012:	6a 37                	push   $0x37
  801014:	68 da 27 80 00       	push   $0x8027da
  801019:	e8 9d f2 ff ff       	call   8002bb <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80101e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	57                   	push   %edi
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80102c:	68 4d 0f 80 00       	push   $0x800f4d
  801031:	e8 fe 0e 00 00       	call   801f34 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801036:	b8 07 00 00 00       	mov    $0x7,%eax
  80103b:	cd 30                	int    $0x30
  80103d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	79 17                	jns    80105e <fork+0x3b>
		panic("fork fault %e");
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	68 fe 27 80 00       	push   $0x8027fe
  80104f:	68 84 00 00 00       	push   $0x84
  801054:	68 da 27 80 00       	push   $0x8027da
  801059:	e8 5d f2 ff ff       	call   8002bb <_panic>
  80105e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801060:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801064:	75 24                	jne    80108a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801066:	e8 73 fc ff ff       	call   800cde <sys_getenvid>
  80106b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801070:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80107b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801080:	b8 00 00 00 00       	mov    $0x0,%eax
  801085:	e9 64 01 00 00       	jmp    8011ee <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80108a:	83 ec 04             	sub    $0x4,%esp
  80108d:	6a 07                	push   $0x7
  80108f:	68 00 f0 bf ee       	push   $0xeebff000
  801094:	ff 75 e4             	pushl  -0x1c(%ebp)
  801097:	e8 80 fc ff ff       	call   800d1c <sys_page_alloc>
  80109c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80109f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010a4:	89 d8                	mov    %ebx,%eax
  8010a6:	c1 e8 16             	shr    $0x16,%eax
  8010a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b0:	a8 01                	test   $0x1,%al
  8010b2:	0f 84 fc 00 00 00    	je     8011b4 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	c1 e8 0c             	shr    $0xc,%eax
  8010bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010c4:	f6 c2 01             	test   $0x1,%dl
  8010c7:	0f 84 e7 00 00 00    	je     8011b4 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8010cd:	89 c6                	mov    %eax,%esi
  8010cf:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8010d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d9:	f6 c6 04             	test   $0x4,%dh
  8010dc:	74 39                	je     801117 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ed:	50                   	push   %eax
  8010ee:	56                   	push   %esi
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	6a 00                	push   $0x0
  8010f3:	e8 67 fc ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	0f 89 b1 00 00 00    	jns    8011b4 <fork+0x191>
		    	panic("sys page map fault %e");
  801103:	83 ec 04             	sub    $0x4,%esp
  801106:	68 0c 28 80 00       	push   $0x80280c
  80110b:	6a 54                	push   $0x54
  80110d:	68 da 27 80 00       	push   $0x8027da
  801112:	e8 a4 f1 ff ff       	call   8002bb <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801117:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111e:	f6 c2 02             	test   $0x2,%dl
  801121:	75 0c                	jne    80112f <fork+0x10c>
  801123:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112a:	f6 c4 08             	test   $0x8,%ah
  80112d:	74 5b                	je     80118a <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	68 05 08 00 00       	push   $0x805
  801137:	56                   	push   %esi
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	6a 00                	push   $0x0
  80113c:	e8 1e fc ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  801141:	83 c4 20             	add    $0x20,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	79 14                	jns    80115c <fork+0x139>
		    	panic("sys page map fault %e");
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	68 0c 28 80 00       	push   $0x80280c
  801150:	6a 5b                	push   $0x5b
  801152:	68 da 27 80 00       	push   $0x8027da
  801157:	e8 5f f1 ff ff       	call   8002bb <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	68 05 08 00 00       	push   $0x805
  801164:	56                   	push   %esi
  801165:	6a 00                	push   $0x0
  801167:	56                   	push   %esi
  801168:	6a 00                	push   $0x0
  80116a:	e8 f0 fb ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  80116f:	83 c4 20             	add    $0x20,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	79 3e                	jns    8011b4 <fork+0x191>
		    	panic("sys page map fault %e");
  801176:	83 ec 04             	sub    $0x4,%esp
  801179:	68 0c 28 80 00       	push   $0x80280c
  80117e:	6a 5f                	push   $0x5f
  801180:	68 da 27 80 00       	push   $0x8027da
  801185:	e8 31 f1 ff ff       	call   8002bb <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	6a 05                	push   $0x5
  80118f:	56                   	push   %esi
  801190:	57                   	push   %edi
  801191:	56                   	push   %esi
  801192:	6a 00                	push   $0x0
  801194:	e8 c6 fb ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	79 14                	jns    8011b4 <fork+0x191>
		    	panic("sys page map fault %e");
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	68 0c 28 80 00       	push   $0x80280c
  8011a8:	6a 64                	push   $0x64
  8011aa:	68 da 27 80 00       	push   $0x8027da
  8011af:	e8 07 f1 ff ff       	call   8002bb <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8011b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011ba:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011c0:	0f 85 de fe ff ff    	jne    8010a4 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8011c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cb:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	50                   	push   %eax
  8011d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011d8:	57                   	push   %edi
  8011d9:	e8 89 fc ff ff       	call   800e67 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011de:	83 c4 08             	add    $0x8,%esp
  8011e1:	6a 02                	push   $0x2
  8011e3:	57                   	push   %edi
  8011e4:	e8 fa fb ff ff       	call   800de3 <sys_env_set_status>
	
	return envid;
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <sfork>:

envid_t
sfork(void)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	56                   	push   %esi
  801204:	53                   	push   %ebx
  801205:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801208:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	53                   	push   %ebx
  801212:	68 24 28 80 00       	push   $0x802824
  801217:	e8 78 f1 ff ff       	call   800394 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80121c:	c7 04 24 81 02 80 00 	movl   $0x800281,(%esp)
  801223:	e8 e5 fc ff ff       	call   800f0d <sys_thread_create>
  801228:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	53                   	push   %ebx
  80122e:	68 24 28 80 00       	push   $0x802824
  801233:	e8 5c f1 ff ff       	call   800394 <cprintf>
	return id;
}
  801238:	89 f0                	mov    %esi,%eax
  80123a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	05 00 00 00 30       	add    $0x30000000,%eax
  80124c:	c1 e8 0c             	shr    $0xc,%eax
}
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
  801257:	05 00 00 00 30       	add    $0x30000000,%eax
  80125c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801261:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 16             	shr    $0x16,%edx
  801278:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 11                	je     801295 <fd_alloc+0x2d>
  801284:	89 c2                	mov    %eax,%edx
  801286:	c1 ea 0c             	shr    $0xc,%edx
  801289:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801290:	f6 c2 01             	test   $0x1,%dl
  801293:	75 09                	jne    80129e <fd_alloc+0x36>
			*fd_store = fd;
  801295:	89 01                	mov    %eax,(%ecx)
			return 0;
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
  80129c:	eb 17                	jmp    8012b5 <fd_alloc+0x4d>
  80129e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a8:	75 c9                	jne    801273 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012aa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012b0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012bd:	83 f8 1f             	cmp    $0x1f,%eax
  8012c0:	77 36                	ja     8012f8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c2:	c1 e0 0c             	shl    $0xc,%eax
  8012c5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	c1 ea 16             	shr    $0x16,%edx
  8012cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d6:	f6 c2 01             	test   $0x1,%dl
  8012d9:	74 24                	je     8012ff <fd_lookup+0x48>
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	c1 ea 0c             	shr    $0xc,%edx
  8012e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e7:	f6 c2 01             	test   $0x1,%dl
  8012ea:	74 1a                	je     801306 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ef:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f6:	eb 13                	jmp    80130b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fd:	eb 0c                	jmp    80130b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801304:	eb 05                	jmp    80130b <fd_lookup+0x54>
  801306:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801316:	ba c8 28 80 00       	mov    $0x8028c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80131b:	eb 13                	jmp    801330 <dev_lookup+0x23>
  80131d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801320:	39 08                	cmp    %ecx,(%eax)
  801322:	75 0c                	jne    801330 <dev_lookup+0x23>
			*dev = devtab[i];
  801324:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801327:	89 01                	mov    %eax,(%ecx)
			return 0;
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
  80132e:	eb 2e                	jmp    80135e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801330:	8b 02                	mov    (%edx),%eax
  801332:	85 c0                	test   %eax,%eax
  801334:	75 e7                	jne    80131d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801336:	a1 04 40 80 00       	mov    0x804004,%eax
  80133b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80133e:	83 ec 04             	sub    $0x4,%esp
  801341:	51                   	push   %ecx
  801342:	50                   	push   %eax
  801343:	68 48 28 80 00       	push   $0x802848
  801348:	e8 47 f0 ff ff       	call   800394 <cprintf>
	*dev = 0;
  80134d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801350:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	83 ec 10             	sub    $0x10,%esp
  801368:	8b 75 08             	mov    0x8(%ebp),%esi
  80136b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80136e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801378:	c1 e8 0c             	shr    $0xc,%eax
  80137b:	50                   	push   %eax
  80137c:	e8 36 ff ff ff       	call   8012b7 <fd_lookup>
  801381:	83 c4 08             	add    $0x8,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 05                	js     80138d <fd_close+0x2d>
	    || fd != fd2)
  801388:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80138b:	74 0c                	je     801399 <fd_close+0x39>
		return (must_exist ? r : 0);
  80138d:	84 db                	test   %bl,%bl
  80138f:	ba 00 00 00 00       	mov    $0x0,%edx
  801394:	0f 44 c2             	cmove  %edx,%eax
  801397:	eb 41                	jmp    8013da <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	ff 36                	pushl  (%esi)
  8013a2:	e8 66 ff ff ff       	call   80130d <dev_lookup>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 1a                	js     8013ca <fd_close+0x6a>
		if (dev->dev_close)
  8013b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013b6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	74 0b                	je     8013ca <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	56                   	push   %esi
  8013c3:	ff d0                	call   *%eax
  8013c5:	89 c3                	mov    %eax,%ebx
  8013c7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	56                   	push   %esi
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 cc f9 ff ff       	call   800da1 <sys_page_unmap>
	return r;
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	89 d8                	mov    %ebx,%eax
}
  8013da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	ff 75 08             	pushl  0x8(%ebp)
  8013ee:	e8 c4 fe ff ff       	call   8012b7 <fd_lookup>
  8013f3:	83 c4 08             	add    $0x8,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 10                	js     80140a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	6a 01                	push   $0x1
  8013ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801402:	e8 59 ff ff ff       	call   801360 <fd_close>
  801407:	83 c4 10             	add    $0x10,%esp
}
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <close_all>:

void
close_all(void)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	53                   	push   %ebx
  801410:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801413:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	53                   	push   %ebx
  80141c:	e8 c0 ff ff ff       	call   8013e1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801421:	83 c3 01             	add    $0x1,%ebx
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	83 fb 20             	cmp    $0x20,%ebx
  80142a:	75 ec                	jne    801418 <close_all+0xc>
		close(i);
}
  80142c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 2c             	sub    $0x2c,%esp
  80143a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80143d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	ff 75 08             	pushl  0x8(%ebp)
  801444:	e8 6e fe ff ff       	call   8012b7 <fd_lookup>
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	0f 88 c1 00 00 00    	js     801515 <dup+0xe4>
		return r;
	close(newfdnum);
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	56                   	push   %esi
  801458:	e8 84 ff ff ff       	call   8013e1 <close>

	newfd = INDEX2FD(newfdnum);
  80145d:	89 f3                	mov    %esi,%ebx
  80145f:	c1 e3 0c             	shl    $0xc,%ebx
  801462:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801468:	83 c4 04             	add    $0x4,%esp
  80146b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80146e:	e8 de fd ff ff       	call   801251 <fd2data>
  801473:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801475:	89 1c 24             	mov    %ebx,(%esp)
  801478:	e8 d4 fd ff ff       	call   801251 <fd2data>
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801483:	89 f8                	mov    %edi,%eax
  801485:	c1 e8 16             	shr    $0x16,%eax
  801488:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80148f:	a8 01                	test   $0x1,%al
  801491:	74 37                	je     8014ca <dup+0x99>
  801493:	89 f8                	mov    %edi,%eax
  801495:	c1 e8 0c             	shr    $0xc,%eax
  801498:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80149f:	f6 c2 01             	test   $0x1,%dl
  8014a2:	74 26                	je     8014ca <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b3:	50                   	push   %eax
  8014b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b7:	6a 00                	push   $0x0
  8014b9:	57                   	push   %edi
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 9e f8 ff ff       	call   800d5f <sys_page_map>
  8014c1:	89 c7                	mov    %eax,%edi
  8014c3:	83 c4 20             	add    $0x20,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 2e                	js     8014f8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014cd:	89 d0                	mov    %edx,%eax
  8014cf:	c1 e8 0c             	shr    $0xc,%eax
  8014d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e1:	50                   	push   %eax
  8014e2:	53                   	push   %ebx
  8014e3:	6a 00                	push   $0x0
  8014e5:	52                   	push   %edx
  8014e6:	6a 00                	push   $0x0
  8014e8:	e8 72 f8 ff ff       	call   800d5f <sys_page_map>
  8014ed:	89 c7                	mov    %eax,%edi
  8014ef:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014f2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f4:	85 ff                	test   %edi,%edi
  8014f6:	79 1d                	jns    801515 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	6a 00                	push   $0x0
  8014fe:	e8 9e f8 ff ff       	call   800da1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	ff 75 d4             	pushl  -0x2c(%ebp)
  801509:	6a 00                	push   $0x0
  80150b:	e8 91 f8 ff ff       	call   800da1 <sys_page_unmap>
	return r;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	89 f8                	mov    %edi,%eax
}
  801515:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801518:	5b                   	pop    %ebx
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 14             	sub    $0x14,%esp
  801524:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801527:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	53                   	push   %ebx
  80152c:	e8 86 fd ff ff       	call   8012b7 <fd_lookup>
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	89 c2                	mov    %eax,%edx
  801536:	85 c0                	test   %eax,%eax
  801538:	78 6d                	js     8015a7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801544:	ff 30                	pushl  (%eax)
  801546:	e8 c2 fd ff ff       	call   80130d <dev_lookup>
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 4c                	js     80159e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801552:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801555:	8b 42 08             	mov    0x8(%edx),%eax
  801558:	83 e0 03             	and    $0x3,%eax
  80155b:	83 f8 01             	cmp    $0x1,%eax
  80155e:	75 21                	jne    801581 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801560:	a1 04 40 80 00       	mov    0x804004,%eax
  801565:	8b 40 7c             	mov    0x7c(%eax),%eax
  801568:	83 ec 04             	sub    $0x4,%esp
  80156b:	53                   	push   %ebx
  80156c:	50                   	push   %eax
  80156d:	68 8c 28 80 00       	push   $0x80288c
  801572:	e8 1d ee ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157f:	eb 26                	jmp    8015a7 <read+0x8a>
	}
	if (!dev->dev_read)
  801581:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801584:	8b 40 08             	mov    0x8(%eax),%eax
  801587:	85 c0                	test   %eax,%eax
  801589:	74 17                	je     8015a2 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	ff 75 10             	pushl  0x10(%ebp)
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	52                   	push   %edx
  801595:	ff d0                	call   *%eax
  801597:	89 c2                	mov    %eax,%edx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	eb 09                	jmp    8015a7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	eb 05                	jmp    8015a7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015a7:	89 d0                	mov    %edx,%eax
  8015a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	57                   	push   %edi
  8015b2:	56                   	push   %esi
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c2:	eb 21                	jmp    8015e5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	89 f0                	mov    %esi,%eax
  8015c9:	29 d8                	sub    %ebx,%eax
  8015cb:	50                   	push   %eax
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	03 45 0c             	add    0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	57                   	push   %edi
  8015d3:	e8 45 ff ff ff       	call   80151d <read>
		if (m < 0)
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 10                	js     8015ef <readn+0x41>
			return m;
		if (m == 0)
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	74 0a                	je     8015ed <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e3:	01 c3                	add    %eax,%ebx
  8015e5:	39 f3                	cmp    %esi,%ebx
  8015e7:	72 db                	jb     8015c4 <readn+0x16>
  8015e9:	89 d8                	mov    %ebx,%eax
  8015eb:	eb 02                	jmp    8015ef <readn+0x41>
  8015ed:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f2:	5b                   	pop    %ebx
  8015f3:	5e                   	pop    %esi
  8015f4:	5f                   	pop    %edi
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 14             	sub    $0x14,%esp
  8015fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801601:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	53                   	push   %ebx
  801606:	e8 ac fc ff ff       	call   8012b7 <fd_lookup>
  80160b:	83 c4 08             	add    $0x8,%esp
  80160e:	89 c2                	mov    %eax,%edx
  801610:	85 c0                	test   %eax,%eax
  801612:	78 68                	js     80167c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161e:	ff 30                	pushl  (%eax)
  801620:	e8 e8 fc ff ff       	call   80130d <dev_lookup>
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 47                	js     801673 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801633:	75 21                	jne    801656 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801635:	a1 04 40 80 00       	mov    0x804004,%eax
  80163a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	53                   	push   %ebx
  801641:	50                   	push   %eax
  801642:	68 a8 28 80 00       	push   $0x8028a8
  801647:	e8 48 ed ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801654:	eb 26                	jmp    80167c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801656:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801659:	8b 52 0c             	mov    0xc(%edx),%edx
  80165c:	85 d2                	test   %edx,%edx
  80165e:	74 17                	je     801677 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	ff 75 10             	pushl  0x10(%ebp)
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	50                   	push   %eax
  80166a:	ff d2                	call   *%edx
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 09                	jmp    80167c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	89 c2                	mov    %eax,%edx
  801675:	eb 05                	jmp    80167c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801677:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80167c:	89 d0                	mov    %edx,%eax
  80167e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <seek>:

int
seek(int fdnum, off_t offset)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801689:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	ff 75 08             	pushl  0x8(%ebp)
  801690:	e8 22 fc ff ff       	call   8012b7 <fd_lookup>
  801695:	83 c4 08             	add    $0x8,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 0e                	js     8016aa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80169c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 14             	sub    $0x14,%esp
  8016b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	53                   	push   %ebx
  8016bb:	e8 f7 fb ff ff       	call   8012b7 <fd_lookup>
  8016c0:	83 c4 08             	add    $0x8,%esp
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 65                	js     80172e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d3:	ff 30                	pushl  (%eax)
  8016d5:	e8 33 fc ff ff       	call   80130d <dev_lookup>
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 44                	js     801725 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e8:	75 21                	jne    80170b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ea:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ef:	8b 40 7c             	mov    0x7c(%eax),%eax
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	53                   	push   %ebx
  8016f6:	50                   	push   %eax
  8016f7:	68 68 28 80 00       	push   $0x802868
  8016fc:	e8 93 ec ff ff       	call   800394 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801709:	eb 23                	jmp    80172e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80170b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170e:	8b 52 18             	mov    0x18(%edx),%edx
  801711:	85 d2                	test   %edx,%edx
  801713:	74 14                	je     801729 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	ff d2                	call   *%edx
  80171e:	89 c2                	mov    %eax,%edx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	eb 09                	jmp    80172e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	89 c2                	mov    %eax,%edx
  801727:	eb 05                	jmp    80172e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801729:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80172e:	89 d0                	mov    %edx,%eax
  801730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	83 ec 14             	sub    $0x14,%esp
  80173c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801742:	50                   	push   %eax
  801743:	ff 75 08             	pushl  0x8(%ebp)
  801746:	e8 6c fb ff ff       	call   8012b7 <fd_lookup>
  80174b:	83 c4 08             	add    $0x8,%esp
  80174e:	89 c2                	mov    %eax,%edx
  801750:	85 c0                	test   %eax,%eax
  801752:	78 58                	js     8017ac <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175e:	ff 30                	pushl  (%eax)
  801760:	e8 a8 fb ff ff       	call   80130d <dev_lookup>
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 37                	js     8017a3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801773:	74 32                	je     8017a7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801775:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801778:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177f:	00 00 00 
	stat->st_isdir = 0;
  801782:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801789:	00 00 00 
	stat->st_dev = dev;
  80178c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	53                   	push   %ebx
  801796:	ff 75 f0             	pushl  -0x10(%ebp)
  801799:	ff 50 14             	call   *0x14(%eax)
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	eb 09                	jmp    8017ac <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	89 c2                	mov    %eax,%edx
  8017a5:	eb 05                	jmp    8017ac <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ac:	89 d0                	mov    %edx,%eax
  8017ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	56                   	push   %esi
  8017b7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	6a 00                	push   $0x0
  8017bd:	ff 75 08             	pushl  0x8(%ebp)
  8017c0:	e8 e3 01 00 00       	call   8019a8 <open>
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 1b                	js     8017e9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	ff 75 0c             	pushl  0xc(%ebp)
  8017d4:	50                   	push   %eax
  8017d5:	e8 5b ff ff ff       	call   801735 <fstat>
  8017da:	89 c6                	mov    %eax,%esi
	close(fd);
  8017dc:	89 1c 24             	mov    %ebx,(%esp)
  8017df:	e8 fd fb ff ff       	call   8013e1 <close>
	return r;
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	89 f0                	mov    %esi,%eax
}
  8017e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5e                   	pop    %esi
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	56                   	push   %esi
  8017f4:	53                   	push   %ebx
  8017f5:	89 c6                	mov    %eax,%esi
  8017f7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801800:	75 12                	jne    801814 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	6a 01                	push   $0x1
  801807:	e8 94 08 00 00       	call   8020a0 <ipc_find_env>
  80180c:	a3 00 40 80 00       	mov    %eax,0x804000
  801811:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801814:	6a 07                	push   $0x7
  801816:	68 00 50 80 00       	push   $0x805000
  80181b:	56                   	push   %esi
  80181c:	ff 35 00 40 80 00    	pushl  0x804000
  801822:	e8 17 08 00 00       	call   80203e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801827:	83 c4 0c             	add    $0xc,%esp
  80182a:	6a 00                	push   $0x0
  80182c:	53                   	push   %ebx
  80182d:	6a 00                	push   $0x0
  80182f:	e8 8f 07 00 00       	call   801fc3 <ipc_recv>
}
  801834:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801837:	5b                   	pop    %ebx
  801838:	5e                   	pop    %esi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    

0080183b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	8b 40 0c             	mov    0xc(%eax),%eax
  801847:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80184c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801854:	ba 00 00 00 00       	mov    $0x0,%edx
  801859:	b8 02 00 00 00       	mov    $0x2,%eax
  80185e:	e8 8d ff ff ff       	call   8017f0 <fsipc>
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	8b 40 0c             	mov    0xc(%eax),%eax
  801871:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801876:	ba 00 00 00 00       	mov    $0x0,%edx
  80187b:	b8 06 00 00 00       	mov    $0x6,%eax
  801880:	e8 6b ff ff ff       	call   8017f0 <fsipc>
}
  801885:	c9                   	leave  
  801886:	c3                   	ret    

00801887 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801891:	8b 45 08             	mov    0x8(%ebp),%eax
  801894:	8b 40 0c             	mov    0xc(%eax),%eax
  801897:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80189c:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a6:	e8 45 ff ff ff       	call   8017f0 <fsipc>
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 2c                	js     8018db <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	68 00 50 80 00       	push   $0x805000
  8018b7:	53                   	push   %ebx
  8018b8:	e8 5c f0 ff ff       	call   800919 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ef:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018f5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018fa:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018ff:	0f 47 c2             	cmova  %edx,%eax
  801902:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801907:	50                   	push   %eax
  801908:	ff 75 0c             	pushl  0xc(%ebp)
  80190b:	68 08 50 80 00       	push   $0x805008
  801910:	e8 96 f1 ff ff       	call   800aab <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801915:	ba 00 00 00 00       	mov    $0x0,%edx
  80191a:	b8 04 00 00 00       	mov    $0x4,%eax
  80191f:	e8 cc fe ff ff       	call   8017f0 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801939:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80193f:	ba 00 00 00 00       	mov    $0x0,%edx
  801944:	b8 03 00 00 00       	mov    $0x3,%eax
  801949:	e8 a2 fe ff ff       	call   8017f0 <fsipc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	85 c0                	test   %eax,%eax
  801952:	78 4b                	js     80199f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801954:	39 c6                	cmp    %eax,%esi
  801956:	73 16                	jae    80196e <devfile_read+0x48>
  801958:	68 d8 28 80 00       	push   $0x8028d8
  80195d:	68 df 28 80 00       	push   $0x8028df
  801962:	6a 7c                	push   $0x7c
  801964:	68 f4 28 80 00       	push   $0x8028f4
  801969:	e8 4d e9 ff ff       	call   8002bb <_panic>
	assert(r <= PGSIZE);
  80196e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801973:	7e 16                	jle    80198b <devfile_read+0x65>
  801975:	68 ff 28 80 00       	push   $0x8028ff
  80197a:	68 df 28 80 00       	push   $0x8028df
  80197f:	6a 7d                	push   $0x7d
  801981:	68 f4 28 80 00       	push   $0x8028f4
  801986:	e8 30 e9 ff ff       	call   8002bb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80198b:	83 ec 04             	sub    $0x4,%esp
  80198e:	50                   	push   %eax
  80198f:	68 00 50 80 00       	push   $0x805000
  801994:	ff 75 0c             	pushl  0xc(%ebp)
  801997:	e8 0f f1 ff ff       	call   800aab <memmove>
	return r;
  80199c:	83 c4 10             	add    $0x10,%esp
}
  80199f:	89 d8                	mov    %ebx,%eax
  8019a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 20             	sub    $0x20,%esp
  8019af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b2:	53                   	push   %ebx
  8019b3:	e8 28 ef ff ff       	call   8008e0 <strlen>
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c0:	7f 67                	jg     801a29 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	e8 9a f8 ff ff       	call   801268 <fd_alloc>
  8019ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 57                	js     801a2e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	53                   	push   %ebx
  8019db:	68 00 50 80 00       	push   $0x805000
  8019e0:	e8 34 ef ff ff       	call   800919 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f5:	e8 f6 fd ff ff       	call   8017f0 <fsipc>
  8019fa:	89 c3                	mov    %eax,%ebx
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	79 14                	jns    801a17 <open+0x6f>
		fd_close(fd, 0);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	6a 00                	push   $0x0
  801a08:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0b:	e8 50 f9 ff ff       	call   801360 <fd_close>
		return r;
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	89 da                	mov    %ebx,%edx
  801a15:	eb 17                	jmp    801a2e <open+0x86>
	}

	return fd2num(fd);
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1d:	e8 1f f8 ff ff       	call   801241 <fd2num>
  801a22:	89 c2                	mov    %eax,%edx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	eb 05                	jmp    801a2e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a29:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a2e:	89 d0                	mov    %edx,%eax
  801a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a40:	b8 08 00 00 00       	mov    $0x8,%eax
  801a45:	e8 a6 fd ff ff       	call   8017f0 <fsipc>
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	ff 75 08             	pushl  0x8(%ebp)
  801a5a:	e8 f2 f7 ff ff       	call   801251 <fd2data>
  801a5f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a61:	83 c4 08             	add    $0x8,%esp
  801a64:	68 0b 29 80 00       	push   $0x80290b
  801a69:	53                   	push   %ebx
  801a6a:	e8 aa ee ff ff       	call   800919 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a6f:	8b 46 04             	mov    0x4(%esi),%eax
  801a72:	2b 06                	sub    (%esi),%eax
  801a74:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a7a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a81:	00 00 00 
	stat->st_dev = &devpipe;
  801a84:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a8b:	30 80 00 
	return 0;
}
  801a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa4:	53                   	push   %ebx
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 f5 f2 ff ff       	call   800da1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aac:	89 1c 24             	mov    %ebx,(%esp)
  801aaf:	e8 9d f7 ff ff       	call   801251 <fd2data>
  801ab4:	83 c4 08             	add    $0x8,%esp
  801ab7:	50                   	push   %eax
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 e2 f2 ff ff       	call   800da1 <sys_page_unmap>
}
  801abf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    

00801ac4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	57                   	push   %edi
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 1c             	sub    $0x1c,%esp
  801acd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ad0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ad2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad7:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae3:	e8 fa 05 00 00       	call   8020e2 <pageref>
  801ae8:	89 c3                	mov    %eax,%ebx
  801aea:	89 3c 24             	mov    %edi,(%esp)
  801aed:	e8 f0 05 00 00       	call   8020e2 <pageref>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	39 c3                	cmp    %eax,%ebx
  801af7:	0f 94 c1             	sete   %cl
  801afa:	0f b6 c9             	movzbl %cl,%ecx
  801afd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b00:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b06:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801b0c:	39 ce                	cmp    %ecx,%esi
  801b0e:	74 1e                	je     801b2e <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b10:	39 c3                	cmp    %eax,%ebx
  801b12:	75 be                	jne    801ad2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b14:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801b1a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b1d:	50                   	push   %eax
  801b1e:	56                   	push   %esi
  801b1f:	68 12 29 80 00       	push   $0x802912
  801b24:	e8 6b e8 ff ff       	call   800394 <cprintf>
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	eb a4                	jmp    801ad2 <_pipeisclosed+0xe>
	}
}
  801b2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5f                   	pop    %edi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	57                   	push   %edi
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 28             	sub    $0x28,%esp
  801b42:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b45:	56                   	push   %esi
  801b46:	e8 06 f7 ff ff       	call   801251 <fd2data>
  801b4b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	bf 00 00 00 00       	mov    $0x0,%edi
  801b55:	eb 4b                	jmp    801ba2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b57:	89 da                	mov    %ebx,%edx
  801b59:	89 f0                	mov    %esi,%eax
  801b5b:	e8 64 ff ff ff       	call   801ac4 <_pipeisclosed>
  801b60:	85 c0                	test   %eax,%eax
  801b62:	75 48                	jne    801bac <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b64:	e8 94 f1 ff ff       	call   800cfd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b69:	8b 43 04             	mov    0x4(%ebx),%eax
  801b6c:	8b 0b                	mov    (%ebx),%ecx
  801b6e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b71:	39 d0                	cmp    %edx,%eax
  801b73:	73 e2                	jae    801b57 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b78:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b7c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b7f:	89 c2                	mov    %eax,%edx
  801b81:	c1 fa 1f             	sar    $0x1f,%edx
  801b84:	89 d1                	mov    %edx,%ecx
  801b86:	c1 e9 1b             	shr    $0x1b,%ecx
  801b89:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b8c:	83 e2 1f             	and    $0x1f,%edx
  801b8f:	29 ca                	sub    %ecx,%edx
  801b91:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b95:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b99:	83 c0 01             	add    $0x1,%eax
  801b9c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9f:	83 c7 01             	add    $0x1,%edi
  801ba2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba5:	75 c2                	jne    801b69 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ba7:	8b 45 10             	mov    0x10(%ebp),%eax
  801baa:	eb 05                	jmp    801bb1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5f                   	pop    %edi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	57                   	push   %edi
  801bbd:	56                   	push   %esi
  801bbe:	53                   	push   %ebx
  801bbf:	83 ec 18             	sub    $0x18,%esp
  801bc2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bc5:	57                   	push   %edi
  801bc6:	e8 86 f6 ff ff       	call   801251 <fd2data>
  801bcb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd5:	eb 3d                	jmp    801c14 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bd7:	85 db                	test   %ebx,%ebx
  801bd9:	74 04                	je     801bdf <devpipe_read+0x26>
				return i;
  801bdb:	89 d8                	mov    %ebx,%eax
  801bdd:	eb 44                	jmp    801c23 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bdf:	89 f2                	mov    %esi,%edx
  801be1:	89 f8                	mov    %edi,%eax
  801be3:	e8 dc fe ff ff       	call   801ac4 <_pipeisclosed>
  801be8:	85 c0                	test   %eax,%eax
  801bea:	75 32                	jne    801c1e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bec:	e8 0c f1 ff ff       	call   800cfd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bf1:	8b 06                	mov    (%esi),%eax
  801bf3:	3b 46 04             	cmp    0x4(%esi),%eax
  801bf6:	74 df                	je     801bd7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf8:	99                   	cltd   
  801bf9:	c1 ea 1b             	shr    $0x1b,%edx
  801bfc:	01 d0                	add    %edx,%eax
  801bfe:	83 e0 1f             	and    $0x1f,%eax
  801c01:	29 d0                	sub    %edx,%eax
  801c03:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c0e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c11:	83 c3 01             	add    $0x1,%ebx
  801c14:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c17:	75 d8                	jne    801bf1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c19:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1c:	eb 05                	jmp    801c23 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	56                   	push   %esi
  801c2f:	53                   	push   %ebx
  801c30:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c36:	50                   	push   %eax
  801c37:	e8 2c f6 ff ff       	call   801268 <fd_alloc>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	89 c2                	mov    %eax,%edx
  801c41:	85 c0                	test   %eax,%eax
  801c43:	0f 88 2c 01 00 00    	js     801d75 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c49:	83 ec 04             	sub    $0x4,%esp
  801c4c:	68 07 04 00 00       	push   $0x407
  801c51:	ff 75 f4             	pushl  -0xc(%ebp)
  801c54:	6a 00                	push   $0x0
  801c56:	e8 c1 f0 ff ff       	call   800d1c <sys_page_alloc>
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	89 c2                	mov    %eax,%edx
  801c60:	85 c0                	test   %eax,%eax
  801c62:	0f 88 0d 01 00 00    	js     801d75 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	e8 f4 f5 ff ff       	call   801268 <fd_alloc>
  801c74:	89 c3                	mov    %eax,%ebx
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	0f 88 e2 00 00 00    	js     801d63 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	68 07 04 00 00       	push   $0x407
  801c89:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 89 f0 ff ff       	call   800d1c <sys_page_alloc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	0f 88 c3 00 00 00    	js     801d63 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ca0:	83 ec 0c             	sub    $0xc,%esp
  801ca3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca6:	e8 a6 f5 ff ff       	call   801251 <fd2data>
  801cab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cad:	83 c4 0c             	add    $0xc,%esp
  801cb0:	68 07 04 00 00       	push   $0x407
  801cb5:	50                   	push   %eax
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 5f f0 ff ff       	call   800d1c <sys_page_alloc>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	0f 88 89 00 00 00    	js     801d53 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd0:	e8 7c f5 ff ff       	call   801251 <fd2data>
  801cd5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cdc:	50                   	push   %eax
  801cdd:	6a 00                	push   $0x0
  801cdf:	56                   	push   %esi
  801ce0:	6a 00                	push   $0x0
  801ce2:	e8 78 f0 ff ff       	call   800d5f <sys_page_map>
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	83 c4 20             	add    $0x20,%esp
  801cec:	85 c0                	test   %eax,%eax
  801cee:	78 55                	js     801d45 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cf0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d05:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d13:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d20:	e8 1c f5 ff ff       	call   801241 <fd2num>
  801d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d28:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d2a:	83 c4 04             	add    $0x4,%esp
  801d2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d30:	e8 0c f5 ff ff       	call   801241 <fd2num>
  801d35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d38:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d43:	eb 30                	jmp    801d75 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d45:	83 ec 08             	sub    $0x8,%esp
  801d48:	56                   	push   %esi
  801d49:	6a 00                	push   $0x0
  801d4b:	e8 51 f0 ff ff       	call   800da1 <sys_page_unmap>
  801d50:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d53:	83 ec 08             	sub    $0x8,%esp
  801d56:	ff 75 f0             	pushl  -0x10(%ebp)
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 41 f0 ff ff       	call   800da1 <sys_page_unmap>
  801d60:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d63:	83 ec 08             	sub    $0x8,%esp
  801d66:	ff 75 f4             	pushl  -0xc(%ebp)
  801d69:	6a 00                	push   $0x0
  801d6b:	e8 31 f0 ff ff       	call   800da1 <sys_page_unmap>
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d7a:	5b                   	pop    %ebx
  801d7b:	5e                   	pop    %esi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d87:	50                   	push   %eax
  801d88:	ff 75 08             	pushl  0x8(%ebp)
  801d8b:	e8 27 f5 ff ff       	call   8012b7 <fd_lookup>
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	85 c0                	test   %eax,%eax
  801d95:	78 18                	js     801daf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d97:	83 ec 0c             	sub    $0xc,%esp
  801d9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9d:	e8 af f4 ff ff       	call   801251 <fd2data>
	return _pipeisclosed(fd, p);
  801da2:	89 c2                	mov    %eax,%edx
  801da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da7:	e8 18 fd ff ff       	call   801ac4 <_pipeisclosed>
  801dac:	83 c4 10             	add    $0x10,%esp
}
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801db4:	b8 00 00 00 00       	mov    $0x0,%eax
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dc1:	68 25 29 80 00       	push   $0x802925
  801dc6:	ff 75 0c             	pushl  0xc(%ebp)
  801dc9:	e8 4b eb ff ff       	call   800919 <strcpy>
	return 0;
}
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dec:	eb 2d                	jmp    801e1b <devcons_write+0x46>
		m = n - tot;
  801dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801df3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801df6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dfb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	53                   	push   %ebx
  801e02:	03 45 0c             	add    0xc(%ebp),%eax
  801e05:	50                   	push   %eax
  801e06:	57                   	push   %edi
  801e07:	e8 9f ec ff ff       	call   800aab <memmove>
		sys_cputs(buf, m);
  801e0c:	83 c4 08             	add    $0x8,%esp
  801e0f:	53                   	push   %ebx
  801e10:	57                   	push   %edi
  801e11:	e8 4a ee ff ff       	call   800c60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e16:	01 de                	add    %ebx,%esi
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	89 f0                	mov    %esi,%eax
  801e1d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e20:	72 cc                	jb     801dee <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5f                   	pop    %edi
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e39:	74 2a                	je     801e65 <devcons_read+0x3b>
  801e3b:	eb 05                	jmp    801e42 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e3d:	e8 bb ee ff ff       	call   800cfd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e42:	e8 37 ee ff ff       	call   800c7e <sys_cgetc>
  801e47:	85 c0                	test   %eax,%eax
  801e49:	74 f2                	je     801e3d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 16                	js     801e65 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e4f:	83 f8 04             	cmp    $0x4,%eax
  801e52:	74 0c                	je     801e60 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e54:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e57:	88 02                	mov    %al,(%edx)
	return 1;
  801e59:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5e:	eb 05                	jmp    801e65 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e60:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e70:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e73:	6a 01                	push   $0x1
  801e75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	e8 e2 ed ff ff       	call   800c60 <sys_cputs>
}
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    

00801e83 <getchar>:

int
getchar(void)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e89:	6a 01                	push   $0x1
  801e8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8e:	50                   	push   %eax
  801e8f:	6a 00                	push   $0x0
  801e91:	e8 87 f6 ff ff       	call   80151d <read>
	if (r < 0)
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 0f                	js     801eac <getchar+0x29>
		return r;
	if (r < 1)
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	7e 06                	jle    801ea7 <getchar+0x24>
		return -E_EOF;
	return c;
  801ea1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ea5:	eb 05                	jmp    801eac <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ea7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb7:	50                   	push   %eax
  801eb8:	ff 75 08             	pushl  0x8(%ebp)
  801ebb:	e8 f7 f3 ff ff       	call   8012b7 <fd_lookup>
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	78 11                	js     801ed8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed0:	39 10                	cmp    %edx,(%eax)
  801ed2:	0f 94 c0             	sete   %al
  801ed5:	0f b6 c0             	movzbl %al,%eax
}
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <opencons>:

int
opencons(void)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee3:	50                   	push   %eax
  801ee4:	e8 7f f3 ff ff       	call   801268 <fd_alloc>
  801ee9:	83 c4 10             	add    $0x10,%esp
		return r;
  801eec:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 3e                	js     801f30 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	68 07 04 00 00       	push   $0x407
  801efa:	ff 75 f4             	pushl  -0xc(%ebp)
  801efd:	6a 00                	push   $0x0
  801eff:	e8 18 ee ff ff       	call   800d1c <sys_page_alloc>
  801f04:	83 c4 10             	add    $0x10,%esp
		return r;
  801f07:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	78 23                	js     801f30 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f16:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	50                   	push   %eax
  801f26:	e8 16 f3 ff ff       	call   801241 <fd2num>
  801f2b:	89 c2                	mov    %eax,%edx
  801f2d:	83 c4 10             	add    $0x10,%esp
}
  801f30:	89 d0                	mov    %edx,%eax
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    

00801f34 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f3a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f41:	75 2a                	jne    801f6d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	6a 07                	push   $0x7
  801f48:	68 00 f0 bf ee       	push   $0xeebff000
  801f4d:	6a 00                	push   $0x0
  801f4f:	e8 c8 ed ff ff       	call   800d1c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	79 12                	jns    801f6d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f5b:	50                   	push   %eax
  801f5c:	68 31 29 80 00       	push   $0x802931
  801f61:	6a 23                	push   $0x23
  801f63:	68 35 29 80 00       	push   $0x802935
  801f68:	e8 4e e3 ff ff       	call   8002bb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f70:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f75:	83 ec 08             	sub    $0x8,%esp
  801f78:	68 9f 1f 80 00       	push   $0x801f9f
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 e3 ee ff ff       	call   800e67 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	79 12                	jns    801f9d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f8b:	50                   	push   %eax
  801f8c:	68 31 29 80 00       	push   $0x802931
  801f91:	6a 2c                	push   $0x2c
  801f93:	68 35 29 80 00       	push   $0x802935
  801f98:	e8 1e e3 ff ff       	call   8002bb <_panic>
	}
}
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    

00801f9f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f9f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fa0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fa5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fa7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801faa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fae:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fb3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fb7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801fb9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fbc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801fbd:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fc0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fc1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fc2:	c3                   	ret    

00801fc3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	75 12                	jne    801fe7 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801fd5:	83 ec 0c             	sub    $0xc,%esp
  801fd8:	68 00 00 c0 ee       	push   $0xeec00000
  801fdd:	e8 ea ee ff ff       	call   800ecc <sys_ipc_recv>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	eb 0c                	jmp    801ff3 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801fe7:	83 ec 0c             	sub    $0xc,%esp
  801fea:	50                   	push   %eax
  801feb:	e8 dc ee ff ff       	call   800ecc <sys_ipc_recv>
  801ff0:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ff3:	85 f6                	test   %esi,%esi
  801ff5:	0f 95 c1             	setne  %cl
  801ff8:	85 db                	test   %ebx,%ebx
  801ffa:	0f 95 c2             	setne  %dl
  801ffd:	84 d1                	test   %dl,%cl
  801fff:	74 09                	je     80200a <ipc_recv+0x47>
  802001:	89 c2                	mov    %eax,%edx
  802003:	c1 ea 1f             	shr    $0x1f,%edx
  802006:	84 d2                	test   %dl,%dl
  802008:	75 2d                	jne    802037 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80200a:	85 f6                	test   %esi,%esi
  80200c:	74 0d                	je     80201b <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80200e:	a1 04 40 80 00       	mov    0x804004,%eax
  802013:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802019:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80201b:	85 db                	test   %ebx,%ebx
  80201d:	74 0d                	je     80202c <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80201f:	a1 04 40 80 00       	mov    0x804004,%eax
  802024:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  80202a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80202c:	a1 04 40 80 00       	mov    0x804004,%eax
  802031:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802037:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802050:	85 db                	test   %ebx,%ebx
  802052:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802057:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80205a:	ff 75 14             	pushl  0x14(%ebp)
  80205d:	53                   	push   %ebx
  80205e:	56                   	push   %esi
  80205f:	57                   	push   %edi
  802060:	e8 44 ee ff ff       	call   800ea9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802065:	89 c2                	mov    %eax,%edx
  802067:	c1 ea 1f             	shr    $0x1f,%edx
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	84 d2                	test   %dl,%dl
  80206f:	74 17                	je     802088 <ipc_send+0x4a>
  802071:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802074:	74 12                	je     802088 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802076:	50                   	push   %eax
  802077:	68 43 29 80 00       	push   $0x802943
  80207c:	6a 47                	push   $0x47
  80207e:	68 51 29 80 00       	push   $0x802951
  802083:	e8 33 e2 ff ff       	call   8002bb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802088:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80208b:	75 07                	jne    802094 <ipc_send+0x56>
			sys_yield();
  80208d:	e8 6b ec ff ff       	call   800cfd <sys_yield>
  802092:	eb c6                	jmp    80205a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802094:	85 c0                	test   %eax,%eax
  802096:	75 c2                	jne    80205a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ab:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8020b1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020b7:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8020bd:	39 ca                	cmp    %ecx,%edx
  8020bf:	75 10                	jne    8020d1 <ipc_find_env+0x31>
			return envs[i].env_id;
  8020c1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8020c7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020cc:	8b 40 7c             	mov    0x7c(%eax),%eax
  8020cf:	eb 0f                	jmp    8020e0 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d1:	83 c0 01             	add    $0x1,%eax
  8020d4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d9:	75 d0                	jne    8020ab <ipc_find_env+0xb>
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
