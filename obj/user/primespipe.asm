
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
  80004c:	e8 89 17 00 00       	call   8017da <readn>
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
  800068:	68 00 26 80 00       	push   $0x802600
  80006d:	6a 15                	push   $0x15
  80006f:	68 2f 26 80 00       	push   $0x80262f
  800074:	e8 42 02 00 00       	call   8002bb <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 41 26 80 00       	push   $0x802641
  800084:	e8 0b 03 00 00       	call   800394 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 cc 1d 00 00       	call   801e5d <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 45 26 80 00       	push   $0x802645
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 2f 26 80 00       	push   $0x80262f
  8000a8:	e8 0e 02 00 00       	call   8002bb <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 91 0f 00 00       	call   801043 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 4e 26 80 00       	push   $0x80264e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 2f 26 80 00       	push   $0x80262f
  8000c3:	e8 f3 01 00 00       	call   8002bb <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 35 15 00 00       	call   80160a <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 2a 15 00 00       	call   80160a <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 14 15 00 00       	call   80160a <close>
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
  800106:	e8 cf 16 00 00       	call   8017da <readn>
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
  800126:	68 57 26 80 00       	push   $0x802657
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 2f 26 80 00       	push   $0x80262f
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
  800149:	e8 d5 16 00 00       	call   801823 <write>
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
  800168:	68 73 26 80 00       	push   $0x802673
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 2f 26 80 00       	push   $0x80262f
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
  800180:	c7 05 00 30 80 00 8d 	movl   $0x80268d,0x803000
  800187:	26 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 ca 1c 00 00       	call   801e5d <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 45 26 80 00       	push   $0x802645
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 2f 26 80 00       	push   $0x80262f
  8001aa:	e8 0c 01 00 00       	call   8002bb <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 8f 0e 00 00       	call   801043 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 4e 26 80 00       	push   $0x80264e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 2f 26 80 00       	push   $0x80262f
  8001c5:	e8 f1 00 00 00       	call   8002bb <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 31 14 00 00       	call   80160a <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 1b 14 00 00       	call   80160a <close>

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
  800205:	e8 19 16 00 00       	call   801823 <write>
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
  800221:	68 98 26 80 00       	push   $0x802698
  800226:	6a 4a                	push   $0x4a
  800228:	68 2f 26 80 00       	push   $0x80262f
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
  80024d:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800253:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800258:	a3 04 40 80 00       	mov    %eax,0x804004

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 08             	sub    $0x8,%esp
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
  8002a7:	e8 89 13 00 00       	call   801635 <close_all>
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
  8002d9:	68 bc 26 80 00       	push   $0x8026bc
  8002de:	e8 b1 00 00 00       	call   800394 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e3:	83 c4 18             	add    $0x18,%esp
  8002e6:	53                   	push   %ebx
  8002e7:	ff 75 10             	pushl  0x10(%ebp)
  8002ea:	e8 54 00 00 00       	call   800343 <vcprintf>
	cprintf("\n");
  8002ef:	c7 04 24 7b 2a 80 00 	movl   $0x802a7b,(%esp)
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
  8003f7:	e8 64 1f 00 00       	call   802360 <__udivdi3>
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
  80043a:	e8 51 20 00 00       	call   802490 <__umoddi3>
  80043f:	83 c4 14             	add    $0x14,%esp
  800442:	0f be 80 df 26 80 00 	movsbl 0x8026df(%eax),%eax
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
  80053e:	ff 24 85 20 28 80 00 	jmp    *0x802820(,%eax,4)
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
  800602:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  800609:	85 d2                	test   %edx,%edx
  80060b:	75 18                	jne    800625 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80060d:	50                   	push   %eax
  80060e:	68 f7 26 80 00       	push   $0x8026f7
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
  800626:	68 41 2b 80 00       	push   $0x802b41
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
  80064a:	b8 f0 26 80 00       	mov    $0x8026f0,%eax
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
  800cc5:	68 df 29 80 00       	push   $0x8029df
  800cca:	6a 23                	push   $0x23
  800ccc:	68 fc 29 80 00       	push   $0x8029fc
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
  800d46:	68 df 29 80 00       	push   $0x8029df
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 fc 29 80 00       	push   $0x8029fc
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
  800d88:	68 df 29 80 00       	push   $0x8029df
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 fc 29 80 00       	push   $0x8029fc
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
  800dca:	68 df 29 80 00       	push   $0x8029df
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 fc 29 80 00       	push   $0x8029fc
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
  800e0c:	68 df 29 80 00       	push   $0x8029df
  800e11:	6a 23                	push   $0x23
  800e13:	68 fc 29 80 00       	push   $0x8029fc
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
  800e4e:	68 df 29 80 00       	push   $0x8029df
  800e53:	6a 23                	push   $0x23
  800e55:	68 fc 29 80 00       	push   $0x8029fc
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
  800e90:	68 df 29 80 00       	push   $0x8029df
  800e95:	6a 23                	push   $0x23
  800e97:	68 fc 29 80 00       	push   $0x8029fc
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
  800ef4:	68 df 29 80 00       	push   $0x8029df
  800ef9:	6a 23                	push   $0x23
  800efb:	68 fc 29 80 00       	push   $0x8029fc
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

00800f4d <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f58:	b8 10 00 00 00       	mov    $0x10,%eax
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	89 cb                	mov    %ecx,%ebx
  800f62:	89 cf                	mov    %ecx,%edi
  800f64:	89 ce                	mov    %ecx,%esi
  800f66:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	53                   	push   %ebx
  800f71:	83 ec 04             	sub    $0x4,%esp
  800f74:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f77:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f79:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f7d:	74 11                	je     800f90 <pgfault+0x23>
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	c1 e8 0c             	shr    $0xc,%eax
  800f84:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8b:	f6 c4 08             	test   $0x8,%ah
  800f8e:	75 14                	jne    800fa4 <pgfault+0x37>
		panic("faulting access");
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	68 0a 2a 80 00       	push   $0x802a0a
  800f98:	6a 1f                	push   $0x1f
  800f9a:	68 1a 2a 80 00       	push   $0x802a1a
  800f9f:	e8 17 f3 ff ff       	call   8002bb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	6a 07                	push   $0x7
  800fa9:	68 00 f0 7f 00       	push   $0x7ff000
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 67 fd ff ff       	call   800d1c <sys_page_alloc>
	if (r < 0) {
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 12                	jns    800fce <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800fbc:	50                   	push   %eax
  800fbd:	68 25 2a 80 00       	push   $0x802a25
  800fc2:	6a 2d                	push   $0x2d
  800fc4:	68 1a 2a 80 00       	push   $0x802a1a
  800fc9:	e8 ed f2 ff ff       	call   8002bb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800fce:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	68 00 10 00 00       	push   $0x1000
  800fdc:	53                   	push   %ebx
  800fdd:	68 00 f0 7f 00       	push   $0x7ff000
  800fe2:	e8 2c fb ff ff       	call   800b13 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800fe7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fee:	53                   	push   %ebx
  800fef:	6a 00                	push   $0x0
  800ff1:	68 00 f0 7f 00       	push   $0x7ff000
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 62 fd ff ff       	call   800d5f <sys_page_map>
	if (r < 0) {
  800ffd:	83 c4 20             	add    $0x20,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	79 12                	jns    801016 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  801004:	50                   	push   %eax
  801005:	68 25 2a 80 00       	push   $0x802a25
  80100a:	6a 34                	push   $0x34
  80100c:	68 1a 2a 80 00       	push   $0x802a1a
  801011:	e8 a5 f2 ff ff       	call   8002bb <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	68 00 f0 7f 00       	push   $0x7ff000
  80101e:	6a 00                	push   $0x0
  801020:	e8 7c fd ff ff       	call   800da1 <sys_page_unmap>
	if (r < 0) {
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	79 12                	jns    80103e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80102c:	50                   	push   %eax
  80102d:	68 25 2a 80 00       	push   $0x802a25
  801032:	6a 38                	push   $0x38
  801034:	68 1a 2a 80 00       	push   $0x802a1a
  801039:	e8 7d f2 ff ff       	call   8002bb <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80103e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80104c:	68 6d 0f 80 00       	push   $0x800f6d
  801051:	e8 10 11 00 00       	call   802166 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801056:	b8 07 00 00 00       	mov    $0x7,%eax
  80105b:	cd 30                	int    $0x30
  80105d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	79 17                	jns    80107e <fork+0x3b>
		panic("fork fault %e");
  801067:	83 ec 04             	sub    $0x4,%esp
  80106a:	68 3e 2a 80 00       	push   $0x802a3e
  80106f:	68 85 00 00 00       	push   $0x85
  801074:	68 1a 2a 80 00       	push   $0x802a1a
  801079:	e8 3d f2 ff ff       	call   8002bb <_panic>
  80107e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801080:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801084:	75 24                	jne    8010aa <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801086:	e8 53 fc ff ff       	call   800cde <sys_getenvid>
  80108b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801090:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  801096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a5:	e9 64 01 00 00       	jmp    80120e <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	6a 07                	push   $0x7
  8010af:	68 00 f0 bf ee       	push   $0xeebff000
  8010b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b7:	e8 60 fc ff ff       	call   800d1c <sys_page_alloc>
  8010bc:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	c1 e8 16             	shr    $0x16,%eax
  8010c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d0:	a8 01                	test   $0x1,%al
  8010d2:	0f 84 fc 00 00 00    	je     8011d4 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8010d8:	89 d8                	mov    %ebx,%eax
  8010da:	c1 e8 0c             	shr    $0xc,%eax
  8010dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010e4:	f6 c2 01             	test   $0x1,%dl
  8010e7:	0f 84 e7 00 00 00    	je     8011d4 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8010ed:	89 c6                	mov    %eax,%esi
  8010ef:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8010f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f9:	f6 c6 04             	test   $0x4,%dh
  8010fc:	74 39                	je     801137 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	25 07 0e 00 00       	and    $0xe07,%eax
  80110d:	50                   	push   %eax
  80110e:	56                   	push   %esi
  80110f:	57                   	push   %edi
  801110:	56                   	push   %esi
  801111:	6a 00                	push   $0x0
  801113:	e8 47 fc ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  801118:	83 c4 20             	add    $0x20,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	0f 89 b1 00 00 00    	jns    8011d4 <fork+0x191>
		    	panic("sys page map fault %e");
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	68 4c 2a 80 00       	push   $0x802a4c
  80112b:	6a 55                	push   $0x55
  80112d:	68 1a 2a 80 00       	push   $0x802a1a
  801132:	e8 84 f1 ff ff       	call   8002bb <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801137:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113e:	f6 c2 02             	test   $0x2,%dl
  801141:	75 0c                	jne    80114f <fork+0x10c>
  801143:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114a:	f6 c4 08             	test   $0x8,%ah
  80114d:	74 5b                	je     8011aa <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	68 05 08 00 00       	push   $0x805
  801157:	56                   	push   %esi
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	6a 00                	push   $0x0
  80115c:	e8 fe fb ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	79 14                	jns    80117c <fork+0x139>
		    	panic("sys page map fault %e");
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	68 4c 2a 80 00       	push   $0x802a4c
  801170:	6a 5c                	push   $0x5c
  801172:	68 1a 2a 80 00       	push   $0x802a1a
  801177:	e8 3f f1 ff ff       	call   8002bb <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80117c:	83 ec 0c             	sub    $0xc,%esp
  80117f:	68 05 08 00 00       	push   $0x805
  801184:	56                   	push   %esi
  801185:	6a 00                	push   $0x0
  801187:	56                   	push   %esi
  801188:	6a 00                	push   $0x0
  80118a:	e8 d0 fb ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  80118f:	83 c4 20             	add    $0x20,%esp
  801192:	85 c0                	test   %eax,%eax
  801194:	79 3e                	jns    8011d4 <fork+0x191>
		    	panic("sys page map fault %e");
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	68 4c 2a 80 00       	push   $0x802a4c
  80119e:	6a 60                	push   $0x60
  8011a0:	68 1a 2a 80 00       	push   $0x802a1a
  8011a5:	e8 11 f1 ff ff       	call   8002bb <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	6a 05                	push   $0x5
  8011af:	56                   	push   %esi
  8011b0:	57                   	push   %edi
  8011b1:	56                   	push   %esi
  8011b2:	6a 00                	push   $0x0
  8011b4:	e8 a6 fb ff ff       	call   800d5f <sys_page_map>
		if (r < 0) {
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	79 14                	jns    8011d4 <fork+0x191>
		    	panic("sys page map fault %e");
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	68 4c 2a 80 00       	push   $0x802a4c
  8011c8:	6a 65                	push   $0x65
  8011ca:	68 1a 2a 80 00       	push   $0x802a1a
  8011cf:	e8 e7 f0 ff ff       	call   8002bb <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8011d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011da:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011e0:	0f 85 de fe ff ff    	jne    8010c4 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8011e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011eb:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	50                   	push   %eax
  8011f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011f8:	57                   	push   %edi
  8011f9:	e8 69 fc ff ff       	call   800e67 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011fe:	83 c4 08             	add    $0x8,%esp
  801201:	6a 02                	push   $0x2
  801203:	57                   	push   %edi
  801204:	e8 da fb ff ff       	call   800de3 <sys_env_set_status>
	
	return envid;
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80120e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801211:	5b                   	pop    %ebx
  801212:	5e                   	pop    %esi
  801213:	5f                   	pop    %edi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <sfork>:

envid_t
sfork(void)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801219:	b8 00 00 00 00       	mov    $0x0,%eax
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80122e:	68 81 02 80 00       	push   $0x800281
  801233:	e8 d5 fc ff ff       	call   800f0d <sys_thread_create>

	return id;
}
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801240:	ff 75 08             	pushl  0x8(%ebp)
  801243:	e8 e5 fc ff ff       	call   800f2d <sys_thread_free>
}
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801253:	ff 75 08             	pushl  0x8(%ebp)
  801256:	e8 f2 fc ff ff       	call   800f4d <sys_thread_join>
}
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	8b 75 08             	mov    0x8(%ebp),%esi
  801268:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80126b:	83 ec 04             	sub    $0x4,%esp
  80126e:	6a 07                	push   $0x7
  801270:	6a 00                	push   $0x0
  801272:	56                   	push   %esi
  801273:	e8 a4 fa ff ff       	call   800d1c <sys_page_alloc>
	if (r < 0) {
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	79 15                	jns    801294 <queue_append+0x34>
		panic("%e\n", r);
  80127f:	50                   	push   %eax
  801280:	68 92 2a 80 00       	push   $0x802a92
  801285:	68 d5 00 00 00       	push   $0xd5
  80128a:	68 1a 2a 80 00       	push   $0x802a1a
  80128f:	e8 27 f0 ff ff       	call   8002bb <_panic>
	}	

	wt->envid = envid;
  801294:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80129a:	83 3b 00             	cmpl   $0x0,(%ebx)
  80129d:	75 13                	jne    8012b2 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80129f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8012a6:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012ad:	00 00 00 
  8012b0:	eb 1b                	jmp    8012cd <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8012b2:	8b 43 04             	mov    0x4(%ebx),%eax
  8012b5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8012bc:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012c3:	00 00 00 
		queue->last = wt;
  8012c6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8012cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8012dd:	8b 02                	mov    (%edx),%eax
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	75 17                	jne    8012fa <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	68 62 2a 80 00       	push   $0x802a62
  8012eb:	68 ec 00 00 00       	push   $0xec
  8012f0:	68 1a 2a 80 00       	push   $0x802a1a
  8012f5:	e8 c1 ef ff ff       	call   8002bb <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8012fa:	8b 48 04             	mov    0x4(%eax),%ecx
  8012fd:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8012ff:	8b 00                	mov    (%eax),%eax
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80130d:	b8 01 00 00 00       	mov    $0x1,%eax
  801312:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801315:	85 c0                	test   %eax,%eax
  801317:	74 45                	je     80135e <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801319:	e8 c0 f9 ff ff       	call   800cde <sys_getenvid>
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	83 c3 04             	add    $0x4,%ebx
  801324:	53                   	push   %ebx
  801325:	50                   	push   %eax
  801326:	e8 35 ff ff ff       	call   801260 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80132b:	e8 ae f9 ff ff       	call   800cde <sys_getenvid>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	6a 04                	push   $0x4
  801335:	50                   	push   %eax
  801336:	e8 a8 fa ff ff       	call   800de3 <sys_env_set_status>

		if (r < 0) {
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	79 15                	jns    801357 <mutex_lock+0x54>
			panic("%e\n", r);
  801342:	50                   	push   %eax
  801343:	68 92 2a 80 00       	push   $0x802a92
  801348:	68 02 01 00 00       	push   $0x102
  80134d:	68 1a 2a 80 00       	push   $0x802a1a
  801352:	e8 64 ef ff ff       	call   8002bb <_panic>
		}
		sys_yield();
  801357:	e8 a1 f9 ff ff       	call   800cfd <sys_yield>
  80135c:	eb 08                	jmp    801366 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  80135e:	e8 7b f9 ff ff       	call   800cde <sys_getenvid>
  801363:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801375:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801379:	74 36                	je     8013b1 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	8d 43 04             	lea    0x4(%ebx),%eax
  801381:	50                   	push   %eax
  801382:	e8 4d ff ff ff       	call   8012d4 <queue_pop>
  801387:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80138a:	83 c4 08             	add    $0x8,%esp
  80138d:	6a 02                	push   $0x2
  80138f:	50                   	push   %eax
  801390:	e8 4e fa ff ff       	call   800de3 <sys_env_set_status>
		if (r < 0) {
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	79 1d                	jns    8013b9 <mutex_unlock+0x4e>
			panic("%e\n", r);
  80139c:	50                   	push   %eax
  80139d:	68 92 2a 80 00       	push   $0x802a92
  8013a2:	68 16 01 00 00       	push   $0x116
  8013a7:	68 1a 2a 80 00       	push   $0x802a1a
  8013ac:	e8 0a ef ff ff       	call   8002bb <_panic>
  8013b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b6:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8013b9:	e8 3f f9 ff ff       	call   800cfd <sys_yield>
}
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 04             	sub    $0x4,%esp
  8013ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8013cd:	e8 0c f9 ff ff       	call   800cde <sys_getenvid>
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	6a 07                	push   $0x7
  8013d7:	53                   	push   %ebx
  8013d8:	50                   	push   %eax
  8013d9:	e8 3e f9 ff ff       	call   800d1c <sys_page_alloc>
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	79 15                	jns    8013fa <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8013e5:	50                   	push   %eax
  8013e6:	68 7d 2a 80 00       	push   $0x802a7d
  8013eb:	68 23 01 00 00       	push   $0x123
  8013f0:	68 1a 2a 80 00       	push   $0x802a1a
  8013f5:	e8 c1 ee ff ff       	call   8002bb <_panic>
	}	
	mtx->locked = 0;
  8013fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801400:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801407:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80140e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
  80141f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801422:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801425:	eb 20                	jmp    801447 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	56                   	push   %esi
  80142b:	e8 a4 fe ff ff       	call   8012d4 <queue_pop>
  801430:	83 c4 08             	add    $0x8,%esp
  801433:	6a 02                	push   $0x2
  801435:	50                   	push   %eax
  801436:	e8 a8 f9 ff ff       	call   800de3 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  80143b:	8b 43 04             	mov    0x4(%ebx),%eax
  80143e:	8b 40 04             	mov    0x4(%eax),%eax
  801441:	89 43 04             	mov    %eax,0x4(%ebx)
  801444:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801447:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80144b:	75 da                	jne    801427 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	68 00 10 00 00       	push   $0x1000
  801455:	6a 00                	push   $0x0
  801457:	53                   	push   %ebx
  801458:	e8 01 f6 ff ff       	call   800a5e <memset>
	mtx = NULL;
}
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	05 00 00 00 30       	add    $0x30000000,%eax
  801472:	c1 e8 0c             	shr    $0xc,%eax
}
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
  80147d:	05 00 00 00 30       	add    $0x30000000,%eax
  801482:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801487:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801494:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801499:	89 c2                	mov    %eax,%edx
  80149b:	c1 ea 16             	shr    $0x16,%edx
  80149e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a5:	f6 c2 01             	test   $0x1,%dl
  8014a8:	74 11                	je     8014bb <fd_alloc+0x2d>
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 0c             	shr    $0xc,%edx
  8014af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	75 09                	jne    8014c4 <fd_alloc+0x36>
			*fd_store = fd;
  8014bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c2:	eb 17                	jmp    8014db <fd_alloc+0x4d>
  8014c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014ce:	75 c9                	jne    801499 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014d0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e3:	83 f8 1f             	cmp    $0x1f,%eax
  8014e6:	77 36                	ja     80151e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e8:	c1 e0 0c             	shl    $0xc,%eax
  8014eb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	c1 ea 16             	shr    $0x16,%edx
  8014f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fc:	f6 c2 01             	test   $0x1,%dl
  8014ff:	74 24                	je     801525 <fd_lookup+0x48>
  801501:	89 c2                	mov    %eax,%edx
  801503:	c1 ea 0c             	shr    $0xc,%edx
  801506:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150d:	f6 c2 01             	test   $0x1,%dl
  801510:	74 1a                	je     80152c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801512:	8b 55 0c             	mov    0xc(%ebp),%edx
  801515:	89 02                	mov    %eax,(%edx)
	return 0;
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
  80151c:	eb 13                	jmp    801531 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80151e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801523:	eb 0c                	jmp    801531 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152a:	eb 05                	jmp    801531 <fd_lookup+0x54>
  80152c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153c:	ba 18 2b 80 00       	mov    $0x802b18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801541:	eb 13                	jmp    801556 <dev_lookup+0x23>
  801543:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801546:	39 08                	cmp    %ecx,(%eax)
  801548:	75 0c                	jne    801556 <dev_lookup+0x23>
			*dev = devtab[i];
  80154a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80154f:	b8 00 00 00 00       	mov    $0x0,%eax
  801554:	eb 31                	jmp    801587 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801556:	8b 02                	mov    (%edx),%eax
  801558:	85 c0                	test   %eax,%eax
  80155a:	75 e7                	jne    801543 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80155c:	a1 04 40 80 00       	mov    0x804004,%eax
  801561:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	51                   	push   %ecx
  80156b:	50                   	push   %eax
  80156c:	68 98 2a 80 00       	push   $0x802a98
  801571:	e8 1e ee ff ff       	call   800394 <cprintf>
	*dev = 0;
  801576:	8b 45 0c             	mov    0xc(%ebp),%eax
  801579:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801587:	c9                   	leave  
  801588:	c3                   	ret    

00801589 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	83 ec 10             	sub    $0x10,%esp
  801591:	8b 75 08             	mov    0x8(%ebp),%esi
  801594:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015a1:	c1 e8 0c             	shr    $0xc,%eax
  8015a4:	50                   	push   %eax
  8015a5:	e8 33 ff ff ff       	call   8014dd <fd_lookup>
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 05                	js     8015b6 <fd_close+0x2d>
	    || fd != fd2)
  8015b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015b4:	74 0c                	je     8015c2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015b6:	84 db                	test   %bl,%bl
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	0f 44 c2             	cmove  %edx,%eax
  8015c0:	eb 41                	jmp    801603 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 36                	pushl  (%esi)
  8015cb:	e8 63 ff ff ff       	call   801533 <dev_lookup>
  8015d0:	89 c3                	mov    %eax,%ebx
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 1a                	js     8015f3 <fd_close+0x6a>
		if (dev->dev_close)
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015df:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	74 0b                	je     8015f3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	56                   	push   %esi
  8015ec:	ff d0                	call   *%eax
  8015ee:	89 c3                	mov    %eax,%ebx
  8015f0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	56                   	push   %esi
  8015f7:	6a 00                	push   $0x0
  8015f9:	e8 a3 f7 ff ff       	call   800da1 <sys_page_unmap>
	return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	89 d8                	mov    %ebx,%eax
}
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 c1 fe ff ff       	call   8014dd <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 10                	js     801633 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	6a 01                	push   $0x1
  801628:	ff 75 f4             	pushl  -0xc(%ebp)
  80162b:	e8 59 ff ff ff       	call   801589 <fd_close>
  801630:	83 c4 10             	add    $0x10,%esp
}
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <close_all>:

void
close_all(void)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	53                   	push   %ebx
  801645:	e8 c0 ff ff ff       	call   80160a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80164a:	83 c3 01             	add    $0x1,%ebx
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	83 fb 20             	cmp    $0x20,%ebx
  801653:	75 ec                	jne    801641 <close_all+0xc>
		close(i);
}
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	57                   	push   %edi
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
  801660:	83 ec 2c             	sub    $0x2c,%esp
  801663:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801666:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 6b fe ff ff       	call   8014dd <fd_lookup>
  801672:	83 c4 08             	add    $0x8,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	0f 88 c1 00 00 00    	js     80173e <dup+0xe4>
		return r;
	close(newfdnum);
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	56                   	push   %esi
  801681:	e8 84 ff ff ff       	call   80160a <close>

	newfd = INDEX2FD(newfdnum);
  801686:	89 f3                	mov    %esi,%ebx
  801688:	c1 e3 0c             	shl    $0xc,%ebx
  80168b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801691:	83 c4 04             	add    $0x4,%esp
  801694:	ff 75 e4             	pushl  -0x1c(%ebp)
  801697:	e8 db fd ff ff       	call   801477 <fd2data>
  80169c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80169e:	89 1c 24             	mov    %ebx,(%esp)
  8016a1:	e8 d1 fd ff ff       	call   801477 <fd2data>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ac:	89 f8                	mov    %edi,%eax
  8016ae:	c1 e8 16             	shr    $0x16,%eax
  8016b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b8:	a8 01                	test   $0x1,%al
  8016ba:	74 37                	je     8016f3 <dup+0x99>
  8016bc:	89 f8                	mov    %edi,%eax
  8016be:	c1 e8 0c             	shr    $0xc,%eax
  8016c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c8:	f6 c2 01             	test   $0x1,%dl
  8016cb:	74 26                	je     8016f3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016dc:	50                   	push   %eax
  8016dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016e0:	6a 00                	push   $0x0
  8016e2:	57                   	push   %edi
  8016e3:	6a 00                	push   $0x0
  8016e5:	e8 75 f6 ff ff       	call   800d5f <sys_page_map>
  8016ea:	89 c7                	mov    %eax,%edi
  8016ec:	83 c4 20             	add    $0x20,%esp
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 2e                	js     801721 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f6:	89 d0                	mov    %edx,%eax
  8016f8:	c1 e8 0c             	shr    $0xc,%eax
  8016fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801702:	83 ec 0c             	sub    $0xc,%esp
  801705:	25 07 0e 00 00       	and    $0xe07,%eax
  80170a:	50                   	push   %eax
  80170b:	53                   	push   %ebx
  80170c:	6a 00                	push   $0x0
  80170e:	52                   	push   %edx
  80170f:	6a 00                	push   $0x0
  801711:	e8 49 f6 ff ff       	call   800d5f <sys_page_map>
  801716:	89 c7                	mov    %eax,%edi
  801718:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80171b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171d:	85 ff                	test   %edi,%edi
  80171f:	79 1d                	jns    80173e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	53                   	push   %ebx
  801725:	6a 00                	push   $0x0
  801727:	e8 75 f6 ff ff       	call   800da1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80172c:	83 c4 08             	add    $0x8,%esp
  80172f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801732:	6a 00                	push   $0x0
  801734:	e8 68 f6 ff ff       	call   800da1 <sys_page_unmap>
	return r;
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	89 f8                	mov    %edi,%eax
}
  80173e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5f                   	pop    %edi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	53                   	push   %ebx
  80174a:	83 ec 14             	sub    $0x14,%esp
  80174d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	53                   	push   %ebx
  801755:	e8 83 fd ff ff       	call   8014dd <fd_lookup>
  80175a:	83 c4 08             	add    $0x8,%esp
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 70                	js     8017d3 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	ff 30                	pushl  (%eax)
  80176f:	e8 bf fd ff ff       	call   801533 <dev_lookup>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 4f                	js     8017ca <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177e:	8b 42 08             	mov    0x8(%edx),%eax
  801781:	83 e0 03             	and    $0x3,%eax
  801784:	83 f8 01             	cmp    $0x1,%eax
  801787:	75 24                	jne    8017ad <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801789:	a1 04 40 80 00       	mov    0x804004,%eax
  80178e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801794:	83 ec 04             	sub    $0x4,%esp
  801797:	53                   	push   %ebx
  801798:	50                   	push   %eax
  801799:	68 dc 2a 80 00       	push   $0x802adc
  80179e:	e8 f1 eb ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ab:	eb 26                	jmp    8017d3 <read+0x8d>
	}
	if (!dev->dev_read)
  8017ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b0:	8b 40 08             	mov    0x8(%eax),%eax
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	74 17                	je     8017ce <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	ff 75 10             	pushl  0x10(%ebp)
  8017bd:	ff 75 0c             	pushl  0xc(%ebp)
  8017c0:	52                   	push   %edx
  8017c1:	ff d0                	call   *%eax
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	eb 09                	jmp    8017d3 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	eb 05                	jmp    8017d3 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017d3:	89 d0                	mov    %edx,%eax
  8017d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	57                   	push   %edi
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ee:	eb 21                	jmp    801811 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	89 f0                	mov    %esi,%eax
  8017f5:	29 d8                	sub    %ebx,%eax
  8017f7:	50                   	push   %eax
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	03 45 0c             	add    0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	57                   	push   %edi
  8017ff:	e8 42 ff ff ff       	call   801746 <read>
		if (m < 0)
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	78 10                	js     80181b <readn+0x41>
			return m;
		if (m == 0)
  80180b:	85 c0                	test   %eax,%eax
  80180d:	74 0a                	je     801819 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80180f:	01 c3                	add    %eax,%ebx
  801811:	39 f3                	cmp    %esi,%ebx
  801813:	72 db                	jb     8017f0 <readn+0x16>
  801815:	89 d8                	mov    %ebx,%eax
  801817:	eb 02                	jmp    80181b <readn+0x41>
  801819:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80181b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	5f                   	pop    %edi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	83 ec 14             	sub    $0x14,%esp
  80182a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	53                   	push   %ebx
  801832:	e8 a6 fc ff ff       	call   8014dd <fd_lookup>
  801837:	83 c4 08             	add    $0x8,%esp
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 6b                	js     8018ab <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	ff 30                	pushl  (%eax)
  80184c:	e8 e2 fc ff ff       	call   801533 <dev_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 4a                	js     8018a2 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185f:	75 24                	jne    801885 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801861:	a1 04 40 80 00       	mov    0x804004,%eax
  801866:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	53                   	push   %ebx
  801870:	50                   	push   %eax
  801871:	68 f8 2a 80 00       	push   $0x802af8
  801876:	e8 19 eb ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801883:	eb 26                	jmp    8018ab <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801885:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801888:	8b 52 0c             	mov    0xc(%edx),%edx
  80188b:	85 d2                	test   %edx,%edx
  80188d:	74 17                	je     8018a6 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80188f:	83 ec 04             	sub    $0x4,%esp
  801892:	ff 75 10             	pushl  0x10(%ebp)
  801895:	ff 75 0c             	pushl  0xc(%ebp)
  801898:	50                   	push   %eax
  801899:	ff d2                	call   *%edx
  80189b:	89 c2                	mov    %eax,%edx
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	eb 09                	jmp    8018ab <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a2:	89 c2                	mov    %eax,%edx
  8018a4:	eb 05                	jmp    8018ab <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018ab:	89 d0                	mov    %edx,%eax
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018bb:	50                   	push   %eax
  8018bc:	ff 75 08             	pushl  0x8(%ebp)
  8018bf:	e8 19 fc ff ff       	call   8014dd <fd_lookup>
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 0e                	js     8018d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 14             	sub    $0x14,%esp
  8018e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	53                   	push   %ebx
  8018ea:	e8 ee fb ff ff       	call   8014dd <fd_lookup>
  8018ef:	83 c4 08             	add    $0x8,%esp
  8018f2:	89 c2                	mov    %eax,%edx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 68                	js     801960 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fe:	50                   	push   %eax
  8018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801902:	ff 30                	pushl  (%eax)
  801904:	e8 2a fc ff ff       	call   801533 <dev_lookup>
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 47                	js     801957 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801910:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801913:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801917:	75 24                	jne    80193d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801919:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80191e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	53                   	push   %ebx
  801928:	50                   	push   %eax
  801929:	68 b8 2a 80 00       	push   $0x802ab8
  80192e:	e8 61 ea ff ff       	call   800394 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80193b:	eb 23                	jmp    801960 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80193d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801940:	8b 52 18             	mov    0x18(%edx),%edx
  801943:	85 d2                	test   %edx,%edx
  801945:	74 14                	je     80195b <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	ff 75 0c             	pushl  0xc(%ebp)
  80194d:	50                   	push   %eax
  80194e:	ff d2                	call   *%edx
  801950:	89 c2                	mov    %eax,%edx
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	eb 09                	jmp    801960 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801957:	89 c2                	mov    %eax,%edx
  801959:	eb 05                	jmp    801960 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80195b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801960:	89 d0                	mov    %edx,%eax
  801962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 14             	sub    $0x14,%esp
  80196e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801971:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801974:	50                   	push   %eax
  801975:	ff 75 08             	pushl  0x8(%ebp)
  801978:	e8 60 fb ff ff       	call   8014dd <fd_lookup>
  80197d:	83 c4 08             	add    $0x8,%esp
  801980:	89 c2                	mov    %eax,%edx
  801982:	85 c0                	test   %eax,%eax
  801984:	78 58                	js     8019de <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801990:	ff 30                	pushl  (%eax)
  801992:	e8 9c fb ff ff       	call   801533 <dev_lookup>
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 37                	js     8019d5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80199e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a5:	74 32                	je     8019d9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019b1:	00 00 00 
	stat->st_isdir = 0;
  8019b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bb:	00 00 00 
	stat->st_dev = dev;
  8019be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c4:	83 ec 08             	sub    $0x8,%esp
  8019c7:	53                   	push   %ebx
  8019c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019cb:	ff 50 14             	call   *0x14(%eax)
  8019ce:	89 c2                	mov    %eax,%edx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	eb 09                	jmp    8019de <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d5:	89 c2                	mov    %eax,%edx
  8019d7:	eb 05                	jmp    8019de <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019de:	89 d0                	mov    %edx,%eax
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	6a 00                	push   $0x0
  8019ef:	ff 75 08             	pushl  0x8(%ebp)
  8019f2:	e8 e3 01 00 00       	call   801bda <open>
  8019f7:	89 c3                	mov    %eax,%ebx
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 1b                	js     801a1b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	50                   	push   %eax
  801a07:	e8 5b ff ff ff       	call   801967 <fstat>
  801a0c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a0e:	89 1c 24             	mov    %ebx,(%esp)
  801a11:	e8 f4 fb ff ff       	call   80160a <close>
	return r;
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	89 f0                	mov    %esi,%eax
}
  801a1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1e:	5b                   	pop    %ebx
  801a1f:	5e                   	pop    %esi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	89 c6                	mov    %eax,%esi
  801a29:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a2b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a32:	75 12                	jne    801a46 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	6a 01                	push   $0x1
  801a39:	e8 94 08 00 00       	call   8022d2 <ipc_find_env>
  801a3e:	a3 00 40 80 00       	mov    %eax,0x804000
  801a43:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a46:	6a 07                	push   $0x7
  801a48:	68 00 50 80 00       	push   $0x805000
  801a4d:	56                   	push   %esi
  801a4e:	ff 35 00 40 80 00    	pushl  0x804000
  801a54:	e8 17 08 00 00       	call   802270 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a59:	83 c4 0c             	add    $0xc,%esp
  801a5c:	6a 00                	push   $0x0
  801a5e:	53                   	push   %ebx
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 8f 07 00 00       	call   8021f5 <ipc_recv>
}
  801a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	8b 40 0c             	mov    0xc(%eax),%eax
  801a79:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a81:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a86:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8b:	b8 02 00 00 00       	mov    $0x2,%eax
  801a90:	e8 8d ff ff ff       	call   801a22 <fsipc>
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa0:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  801aad:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab2:	e8 6b ff ff ff       	call   801a22 <fsipc>
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	83 ec 04             	sub    $0x4,%esp
  801ac0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ace:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad3:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad8:	e8 45 ff ff ff       	call   801a22 <fsipc>
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 2c                	js     801b0d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	68 00 50 80 00       	push   $0x805000
  801ae9:	53                   	push   %ebx
  801aea:	e8 2a ee ff ff       	call   800919 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aef:	a1 80 50 80 00       	mov    0x805080,%eax
  801af4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801afa:	a1 84 50 80 00       	mov    0x805084,%eax
  801aff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1e:	8b 52 0c             	mov    0xc(%edx),%edx
  801b21:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b27:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b2c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b31:	0f 47 c2             	cmova  %edx,%eax
  801b34:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b39:	50                   	push   %eax
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	68 08 50 80 00       	push   $0x805008
  801b42:	e8 64 ef ff ff       	call   800aab <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b47:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b51:	e8 cc fe ff ff       	call   801a22 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	8b 40 0c             	mov    0xc(%eax),%eax
  801b66:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b6b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	b8 03 00 00 00       	mov    $0x3,%eax
  801b7b:	e8 a2 fe ff ff       	call   801a22 <fsipc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 4b                	js     801bd1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b86:	39 c6                	cmp    %eax,%esi
  801b88:	73 16                	jae    801ba0 <devfile_read+0x48>
  801b8a:	68 28 2b 80 00       	push   $0x802b28
  801b8f:	68 2f 2b 80 00       	push   $0x802b2f
  801b94:	6a 7c                	push   $0x7c
  801b96:	68 44 2b 80 00       	push   $0x802b44
  801b9b:	e8 1b e7 ff ff       	call   8002bb <_panic>
	assert(r <= PGSIZE);
  801ba0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba5:	7e 16                	jle    801bbd <devfile_read+0x65>
  801ba7:	68 4f 2b 80 00       	push   $0x802b4f
  801bac:	68 2f 2b 80 00       	push   $0x802b2f
  801bb1:	6a 7d                	push   $0x7d
  801bb3:	68 44 2b 80 00       	push   $0x802b44
  801bb8:	e8 fe e6 ff ff       	call   8002bb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bbd:	83 ec 04             	sub    $0x4,%esp
  801bc0:	50                   	push   %eax
  801bc1:	68 00 50 80 00       	push   $0x805000
  801bc6:	ff 75 0c             	pushl  0xc(%ebp)
  801bc9:	e8 dd ee ff ff       	call   800aab <memmove>
	return r;
  801bce:	83 c4 10             	add    $0x10,%esp
}
  801bd1:	89 d8                	mov    %ebx,%eax
  801bd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 20             	sub    $0x20,%esp
  801be1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801be4:	53                   	push   %ebx
  801be5:	e8 f6 ec ff ff       	call   8008e0 <strlen>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bf2:	7f 67                	jg     801c5b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfa:	50                   	push   %eax
  801bfb:	e8 8e f8 ff ff       	call   80148e <fd_alloc>
  801c00:	83 c4 10             	add    $0x10,%esp
		return r;
  801c03:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 57                	js     801c60 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	53                   	push   %ebx
  801c0d:	68 00 50 80 00       	push   $0x805000
  801c12:	e8 02 ed ff ff       	call   800919 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c22:	b8 01 00 00 00       	mov    $0x1,%eax
  801c27:	e8 f6 fd ff ff       	call   801a22 <fsipc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	79 14                	jns    801c49 <open+0x6f>
		fd_close(fd, 0);
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	6a 00                	push   $0x0
  801c3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3d:	e8 47 f9 ff ff       	call   801589 <fd_close>
		return r;
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	89 da                	mov    %ebx,%edx
  801c47:	eb 17                	jmp    801c60 <open+0x86>
	}

	return fd2num(fd);
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4f:	e8 13 f8 ff ff       	call   801467 <fd2num>
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	eb 05                	jmp    801c60 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c5b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c60:	89 d0                	mov    %edx,%eax
  801c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c72:	b8 08 00 00 00       	mov    $0x8,%eax
  801c77:	e8 a6 fd ff ff       	call   801a22 <fsipc>
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	56                   	push   %esi
  801c82:	53                   	push   %ebx
  801c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	ff 75 08             	pushl  0x8(%ebp)
  801c8c:	e8 e6 f7 ff ff       	call   801477 <fd2data>
  801c91:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c93:	83 c4 08             	add    $0x8,%esp
  801c96:	68 5b 2b 80 00       	push   $0x802b5b
  801c9b:	53                   	push   %ebx
  801c9c:	e8 78 ec ff ff       	call   800919 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ca1:	8b 46 04             	mov    0x4(%esi),%eax
  801ca4:	2b 06                	sub    (%esi),%eax
  801ca6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cb3:	00 00 00 
	stat->st_dev = &devpipe;
  801cb6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cbd:	30 80 00 
	return 0;
}
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	53                   	push   %ebx
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cd6:	53                   	push   %ebx
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 c3 f0 ff ff       	call   800da1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cde:	89 1c 24             	mov    %ebx,(%esp)
  801ce1:	e8 91 f7 ff ff       	call   801477 <fd2data>
  801ce6:	83 c4 08             	add    $0x8,%esp
  801ce9:	50                   	push   %eax
  801cea:	6a 00                	push   $0x0
  801cec:	e8 b0 f0 ff ff       	call   800da1 <sys_page_unmap>
}
  801cf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	57                   	push   %edi
  801cfa:	56                   	push   %esi
  801cfb:	53                   	push   %ebx
  801cfc:	83 ec 1c             	sub    $0x1c,%esp
  801cff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d02:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d04:	a1 04 40 80 00       	mov    0x804004,%eax
  801d09:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d0f:	83 ec 0c             	sub    $0xc,%esp
  801d12:	ff 75 e0             	pushl  -0x20(%ebp)
  801d15:	e8 fd 05 00 00       	call   802317 <pageref>
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	89 3c 24             	mov    %edi,(%esp)
  801d1f:	e8 f3 05 00 00       	call   802317 <pageref>
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	39 c3                	cmp    %eax,%ebx
  801d29:	0f 94 c1             	sete   %cl
  801d2c:	0f b6 c9             	movzbl %cl,%ecx
  801d2f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d32:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d38:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801d3e:	39 ce                	cmp    %ecx,%esi
  801d40:	74 1e                	je     801d60 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d42:	39 c3                	cmp    %eax,%ebx
  801d44:	75 be                	jne    801d04 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d46:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801d4c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d4f:	50                   	push   %eax
  801d50:	56                   	push   %esi
  801d51:	68 62 2b 80 00       	push   $0x802b62
  801d56:	e8 39 e6 ff ff       	call   800394 <cprintf>
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	eb a4                	jmp    801d04 <_pipeisclosed+0xe>
	}
}
  801d60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	57                   	push   %edi
  801d6f:	56                   	push   %esi
  801d70:	53                   	push   %ebx
  801d71:	83 ec 28             	sub    $0x28,%esp
  801d74:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d77:	56                   	push   %esi
  801d78:	e8 fa f6 ff ff       	call   801477 <fd2data>
  801d7d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	bf 00 00 00 00       	mov    $0x0,%edi
  801d87:	eb 4b                	jmp    801dd4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d89:	89 da                	mov    %ebx,%edx
  801d8b:	89 f0                	mov    %esi,%eax
  801d8d:	e8 64 ff ff ff       	call   801cf6 <_pipeisclosed>
  801d92:	85 c0                	test   %eax,%eax
  801d94:	75 48                	jne    801dde <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d96:	e8 62 ef ff ff       	call   800cfd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d9b:	8b 43 04             	mov    0x4(%ebx),%eax
  801d9e:	8b 0b                	mov    (%ebx),%ecx
  801da0:	8d 51 20             	lea    0x20(%ecx),%edx
  801da3:	39 d0                	cmp    %edx,%eax
  801da5:	73 e2                	jae    801d89 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801daa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801db1:	89 c2                	mov    %eax,%edx
  801db3:	c1 fa 1f             	sar    $0x1f,%edx
  801db6:	89 d1                	mov    %edx,%ecx
  801db8:	c1 e9 1b             	shr    $0x1b,%ecx
  801dbb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dbe:	83 e2 1f             	and    $0x1f,%edx
  801dc1:	29 ca                	sub    %ecx,%edx
  801dc3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dc7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dcb:	83 c0 01             	add    $0x1,%eax
  801dce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd1:	83 c7 01             	add    $0x1,%edi
  801dd4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dd7:	75 c2                	jne    801d9b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dd9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddc:	eb 05                	jmp    801de3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dde:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	83 ec 18             	sub    $0x18,%esp
  801df4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801df7:	57                   	push   %edi
  801df8:	e8 7a f6 ff ff       	call   801477 <fd2data>
  801dfd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e07:	eb 3d                	jmp    801e46 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e09:	85 db                	test   %ebx,%ebx
  801e0b:	74 04                	je     801e11 <devpipe_read+0x26>
				return i;
  801e0d:	89 d8                	mov    %ebx,%eax
  801e0f:	eb 44                	jmp    801e55 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e11:	89 f2                	mov    %esi,%edx
  801e13:	89 f8                	mov    %edi,%eax
  801e15:	e8 dc fe ff ff       	call   801cf6 <_pipeisclosed>
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	75 32                	jne    801e50 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e1e:	e8 da ee ff ff       	call   800cfd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e23:	8b 06                	mov    (%esi),%eax
  801e25:	3b 46 04             	cmp    0x4(%esi),%eax
  801e28:	74 df                	je     801e09 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e2a:	99                   	cltd   
  801e2b:	c1 ea 1b             	shr    $0x1b,%edx
  801e2e:	01 d0                	add    %edx,%eax
  801e30:	83 e0 1f             	and    $0x1f,%eax
  801e33:	29 d0                	sub    %edx,%eax
  801e35:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e40:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e43:	83 c3 01             	add    $0x1,%ebx
  801e46:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e49:	75 d8                	jne    801e23 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e4b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4e:	eb 05                	jmp    801e55 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e50:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    

00801e5d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	56                   	push   %esi
  801e61:	53                   	push   %ebx
  801e62:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e68:	50                   	push   %eax
  801e69:	e8 20 f6 ff ff       	call   80148e <fd_alloc>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	89 c2                	mov    %eax,%edx
  801e73:	85 c0                	test   %eax,%eax
  801e75:	0f 88 2c 01 00 00    	js     801fa7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7b:	83 ec 04             	sub    $0x4,%esp
  801e7e:	68 07 04 00 00       	push   $0x407
  801e83:	ff 75 f4             	pushl  -0xc(%ebp)
  801e86:	6a 00                	push   $0x0
  801e88:	e8 8f ee ff ff       	call   800d1c <sys_page_alloc>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	89 c2                	mov    %eax,%edx
  801e92:	85 c0                	test   %eax,%eax
  801e94:	0f 88 0d 01 00 00    	js     801fa7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ea0:	50                   	push   %eax
  801ea1:	e8 e8 f5 ff ff       	call   80148e <fd_alloc>
  801ea6:	89 c3                	mov    %eax,%ebx
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	85 c0                	test   %eax,%eax
  801ead:	0f 88 e2 00 00 00    	js     801f95 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb3:	83 ec 04             	sub    $0x4,%esp
  801eb6:	68 07 04 00 00       	push   $0x407
  801ebb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 57 ee ff ff       	call   800d1c <sys_page_alloc>
  801ec5:	89 c3                	mov    %eax,%ebx
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	0f 88 c3 00 00 00    	js     801f95 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ed2:	83 ec 0c             	sub    $0xc,%esp
  801ed5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed8:	e8 9a f5 ff ff       	call   801477 <fd2data>
  801edd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edf:	83 c4 0c             	add    $0xc,%esp
  801ee2:	68 07 04 00 00       	push   $0x407
  801ee7:	50                   	push   %eax
  801ee8:	6a 00                	push   $0x0
  801eea:	e8 2d ee ff ff       	call   800d1c <sys_page_alloc>
  801eef:	89 c3                	mov    %eax,%ebx
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	0f 88 89 00 00 00    	js     801f85 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efc:	83 ec 0c             	sub    $0xc,%esp
  801eff:	ff 75 f0             	pushl  -0x10(%ebp)
  801f02:	e8 70 f5 ff ff       	call   801477 <fd2data>
  801f07:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f0e:	50                   	push   %eax
  801f0f:	6a 00                	push   $0x0
  801f11:	56                   	push   %esi
  801f12:	6a 00                	push   $0x0
  801f14:	e8 46 ee ff ff       	call   800d5f <sys_page_map>
  801f19:	89 c3                	mov    %eax,%ebx
  801f1b:	83 c4 20             	add    $0x20,%esp
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 55                	js     801f77 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f30:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f37:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f40:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f45:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f4c:	83 ec 0c             	sub    $0xc,%esp
  801f4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f52:	e8 10 f5 ff ff       	call   801467 <fd2num>
  801f57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f5a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f5c:	83 c4 04             	add    $0x4,%esp
  801f5f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f62:	e8 00 f5 ff ff       	call   801467 <fd2num>
  801f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f6a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f6d:	83 c4 10             	add    $0x10,%esp
  801f70:	ba 00 00 00 00       	mov    $0x0,%edx
  801f75:	eb 30                	jmp    801fa7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f77:	83 ec 08             	sub    $0x8,%esp
  801f7a:	56                   	push   %esi
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 1f ee ff ff       	call   800da1 <sys_page_unmap>
  801f82:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f85:	83 ec 08             	sub    $0x8,%esp
  801f88:	ff 75 f0             	pushl  -0x10(%ebp)
  801f8b:	6a 00                	push   $0x0
  801f8d:	e8 0f ee ff ff       	call   800da1 <sys_page_unmap>
  801f92:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f95:	83 ec 08             	sub    $0x8,%esp
  801f98:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9b:	6a 00                	push   $0x0
  801f9d:	e8 ff ed ff ff       	call   800da1 <sys_page_unmap>
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fa7:	89 d0                	mov    %edx,%eax
  801fa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5e                   	pop    %esi
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

00801fb0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb9:	50                   	push   %eax
  801fba:	ff 75 08             	pushl  0x8(%ebp)
  801fbd:	e8 1b f5 ff ff       	call   8014dd <fd_lookup>
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	78 18                	js     801fe1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fc9:	83 ec 0c             	sub    $0xc,%esp
  801fcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcf:	e8 a3 f4 ff ff       	call   801477 <fd2data>
	return _pipeisclosed(fd, p);
  801fd4:	89 c2                	mov    %eax,%edx
  801fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd9:	e8 18 fd ff ff       	call   801cf6 <_pipeisclosed>
  801fde:	83 c4 10             	add    $0x10,%esp
}
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fe6:	b8 00 00 00 00       	mov    $0x0,%eax
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ff3:	68 75 2b 80 00       	push   $0x802b75
  801ff8:	ff 75 0c             	pushl  0xc(%ebp)
  801ffb:	e8 19 e9 ff ff       	call   800919 <strcpy>
	return 0;
}
  802000:	b8 00 00 00 00       	mov    $0x0,%eax
  802005:	c9                   	leave  
  802006:	c3                   	ret    

00802007 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	57                   	push   %edi
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802013:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802018:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80201e:	eb 2d                	jmp    80204d <devcons_write+0x46>
		m = n - tot;
  802020:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802023:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802025:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802028:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80202d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802030:	83 ec 04             	sub    $0x4,%esp
  802033:	53                   	push   %ebx
  802034:	03 45 0c             	add    0xc(%ebp),%eax
  802037:	50                   	push   %eax
  802038:	57                   	push   %edi
  802039:	e8 6d ea ff ff       	call   800aab <memmove>
		sys_cputs(buf, m);
  80203e:	83 c4 08             	add    $0x8,%esp
  802041:	53                   	push   %ebx
  802042:	57                   	push   %edi
  802043:	e8 18 ec ff ff       	call   800c60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802048:	01 de                	add    %ebx,%esi
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	89 f0                	mov    %esi,%eax
  80204f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802052:	72 cc                	jb     802020 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    

0080205c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	83 ec 08             	sub    $0x8,%esp
  802062:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802067:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80206b:	74 2a                	je     802097 <devcons_read+0x3b>
  80206d:	eb 05                	jmp    802074 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80206f:	e8 89 ec ff ff       	call   800cfd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802074:	e8 05 ec ff ff       	call   800c7e <sys_cgetc>
  802079:	85 c0                	test   %eax,%eax
  80207b:	74 f2                	je     80206f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80207d:	85 c0                	test   %eax,%eax
  80207f:	78 16                	js     802097 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802081:	83 f8 04             	cmp    $0x4,%eax
  802084:	74 0c                	je     802092 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802086:	8b 55 0c             	mov    0xc(%ebp),%edx
  802089:	88 02                	mov    %al,(%edx)
	return 1;
  80208b:	b8 01 00 00 00       	mov    $0x1,%eax
  802090:	eb 05                	jmp    802097 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802092:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802097:	c9                   	leave  
  802098:	c3                   	ret    

00802099 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80209f:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020a5:	6a 01                	push   $0x1
  8020a7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020aa:	50                   	push   %eax
  8020ab:	e8 b0 eb ff ff       	call   800c60 <sys_cputs>
}
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <getchar>:

int
getchar(void)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020bb:	6a 01                	push   $0x1
  8020bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c0:	50                   	push   %eax
  8020c1:	6a 00                	push   $0x0
  8020c3:	e8 7e f6 ff ff       	call   801746 <read>
	if (r < 0)
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	78 0f                	js     8020de <getchar+0x29>
		return r;
	if (r < 1)
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	7e 06                	jle    8020d9 <getchar+0x24>
		return -E_EOF;
	return c;
  8020d3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020d7:	eb 05                	jmp    8020de <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020d9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e9:	50                   	push   %eax
  8020ea:	ff 75 08             	pushl  0x8(%ebp)
  8020ed:	e8 eb f3 ff ff       	call   8014dd <fd_lookup>
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 11                	js     80210a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802102:	39 10                	cmp    %edx,(%eax)
  802104:	0f 94 c0             	sete   %al
  802107:	0f b6 c0             	movzbl %al,%eax
}
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <opencons>:

int
opencons(void)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	e8 73 f3 ff ff       	call   80148e <fd_alloc>
  80211b:	83 c4 10             	add    $0x10,%esp
		return r;
  80211e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802120:	85 c0                	test   %eax,%eax
  802122:	78 3e                	js     802162 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802124:	83 ec 04             	sub    $0x4,%esp
  802127:	68 07 04 00 00       	push   $0x407
  80212c:	ff 75 f4             	pushl  -0xc(%ebp)
  80212f:	6a 00                	push   $0x0
  802131:	e8 e6 eb ff ff       	call   800d1c <sys_page_alloc>
  802136:	83 c4 10             	add    $0x10,%esp
		return r;
  802139:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80213b:	85 c0                	test   %eax,%eax
  80213d:	78 23                	js     802162 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80213f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802148:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80214a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802154:	83 ec 0c             	sub    $0xc,%esp
  802157:	50                   	push   %eax
  802158:	e8 0a f3 ff ff       	call   801467 <fd2num>
  80215d:	89 c2                	mov    %eax,%edx
  80215f:	83 c4 10             	add    $0x10,%esp
}
  802162:	89 d0                	mov    %edx,%eax
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80216c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802173:	75 2a                	jne    80219f <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802175:	83 ec 04             	sub    $0x4,%esp
  802178:	6a 07                	push   $0x7
  80217a:	68 00 f0 bf ee       	push   $0xeebff000
  80217f:	6a 00                	push   $0x0
  802181:	e8 96 eb ff ff       	call   800d1c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	85 c0                	test   %eax,%eax
  80218b:	79 12                	jns    80219f <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80218d:	50                   	push   %eax
  80218e:	68 92 2a 80 00       	push   $0x802a92
  802193:	6a 23                	push   $0x23
  802195:	68 81 2b 80 00       	push   $0x802b81
  80219a:	e8 1c e1 ff ff       	call   8002bb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80219f:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a2:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8021a7:	83 ec 08             	sub    $0x8,%esp
  8021aa:	68 d1 21 80 00       	push   $0x8021d1
  8021af:	6a 00                	push   $0x0
  8021b1:	e8 b1 ec ff ff       	call   800e67 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	79 12                	jns    8021cf <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021bd:	50                   	push   %eax
  8021be:	68 92 2a 80 00       	push   $0x802a92
  8021c3:	6a 2c                	push   $0x2c
  8021c5:	68 81 2b 80 00       	push   $0x802b81
  8021ca:	e8 ec e0 ff ff       	call   8002bb <_panic>
	}
}
  8021cf:	c9                   	leave  
  8021d0:	c3                   	ret    

008021d1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021d1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021d2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021d7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021d9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021dc:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021e0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021e5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8021e9:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8021eb:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8021ee:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8021ef:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8021f2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8021f3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021f4:	c3                   	ret    

008021f5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	56                   	push   %esi
  8021f9:	53                   	push   %ebx
  8021fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8021fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802200:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802203:	85 c0                	test   %eax,%eax
  802205:	75 12                	jne    802219 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802207:	83 ec 0c             	sub    $0xc,%esp
  80220a:	68 00 00 c0 ee       	push   $0xeec00000
  80220f:	e8 b8 ec ff ff       	call   800ecc <sys_ipc_recv>
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	eb 0c                	jmp    802225 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802219:	83 ec 0c             	sub    $0xc,%esp
  80221c:	50                   	push   %eax
  80221d:	e8 aa ec ff ff       	call   800ecc <sys_ipc_recv>
  802222:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802225:	85 f6                	test   %esi,%esi
  802227:	0f 95 c1             	setne  %cl
  80222a:	85 db                	test   %ebx,%ebx
  80222c:	0f 95 c2             	setne  %dl
  80222f:	84 d1                	test   %dl,%cl
  802231:	74 09                	je     80223c <ipc_recv+0x47>
  802233:	89 c2                	mov    %eax,%edx
  802235:	c1 ea 1f             	shr    $0x1f,%edx
  802238:	84 d2                	test   %dl,%dl
  80223a:	75 2d                	jne    802269 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80223c:	85 f6                	test   %esi,%esi
  80223e:	74 0d                	je     80224d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802240:	a1 04 40 80 00       	mov    0x804004,%eax
  802245:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80224b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80224d:	85 db                	test   %ebx,%ebx
  80224f:	74 0d                	je     80225e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802251:	a1 04 40 80 00       	mov    0x804004,%eax
  802256:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80225c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80225e:	a1 04 40 80 00       	mov    0x804004,%eax
  802263:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802269:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226c:	5b                   	pop    %ebx
  80226d:	5e                   	pop    %esi
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	57                   	push   %edi
  802274:	56                   	push   %esi
  802275:	53                   	push   %ebx
  802276:	83 ec 0c             	sub    $0xc,%esp
  802279:	8b 7d 08             	mov    0x8(%ebp),%edi
  80227c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80227f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802282:	85 db                	test   %ebx,%ebx
  802284:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802289:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80228c:	ff 75 14             	pushl  0x14(%ebp)
  80228f:	53                   	push   %ebx
  802290:	56                   	push   %esi
  802291:	57                   	push   %edi
  802292:	e8 12 ec ff ff       	call   800ea9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802297:	89 c2                	mov    %eax,%edx
  802299:	c1 ea 1f             	shr    $0x1f,%edx
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	84 d2                	test   %dl,%dl
  8022a1:	74 17                	je     8022ba <ipc_send+0x4a>
  8022a3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022a6:	74 12                	je     8022ba <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8022a8:	50                   	push   %eax
  8022a9:	68 8f 2b 80 00       	push   $0x802b8f
  8022ae:	6a 47                	push   $0x47
  8022b0:	68 9d 2b 80 00       	push   $0x802b9d
  8022b5:	e8 01 e0 ff ff       	call   8002bb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8022ba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022bd:	75 07                	jne    8022c6 <ipc_send+0x56>
			sys_yield();
  8022bf:	e8 39 ea ff ff       	call   800cfd <sys_yield>
  8022c4:	eb c6                	jmp    80228c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8022c6:	85 c0                	test   %eax,%eax
  8022c8:	75 c2                	jne    80228c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8022ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    

008022d2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022d8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022dd:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8022e3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022e9:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8022ef:	39 ca                	cmp    %ecx,%edx
  8022f1:	75 13                	jne    802306 <ipc_find_env+0x34>
			return envs[i].env_id;
  8022f3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8022f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022fe:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802304:	eb 0f                	jmp    802315 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802306:	83 c0 01             	add    $0x1,%eax
  802309:	3d 00 04 00 00       	cmp    $0x400,%eax
  80230e:	75 cd                	jne    8022dd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802310:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802315:	5d                   	pop    %ebp
  802316:	c3                   	ret    

00802317 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80231d:	89 d0                	mov    %edx,%eax
  80231f:	c1 e8 16             	shr    $0x16,%eax
  802322:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802329:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80232e:	f6 c1 01             	test   $0x1,%cl
  802331:	74 1d                	je     802350 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802333:	c1 ea 0c             	shr    $0xc,%edx
  802336:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80233d:	f6 c2 01             	test   $0x1,%dl
  802340:	74 0e                	je     802350 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802342:	c1 ea 0c             	shr    $0xc,%edx
  802345:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80234c:	ef 
  80234d:	0f b7 c0             	movzwl %ax,%eax
}
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	66 90                	xchg   %ax,%ax
  802354:	66 90                	xchg   %ax,%ax
  802356:	66 90                	xchg   %ax,%ax
  802358:	66 90                	xchg   %ax,%ax
  80235a:	66 90                	xchg   %ax,%ax
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80236b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80236f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802377:	85 f6                	test   %esi,%esi
  802379:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80237d:	89 ca                	mov    %ecx,%edx
  80237f:	89 f8                	mov    %edi,%eax
  802381:	75 3d                	jne    8023c0 <__udivdi3+0x60>
  802383:	39 cf                	cmp    %ecx,%edi
  802385:	0f 87 c5 00 00 00    	ja     802450 <__udivdi3+0xf0>
  80238b:	85 ff                	test   %edi,%edi
  80238d:	89 fd                	mov    %edi,%ebp
  80238f:	75 0b                	jne    80239c <__udivdi3+0x3c>
  802391:	b8 01 00 00 00       	mov    $0x1,%eax
  802396:	31 d2                	xor    %edx,%edx
  802398:	f7 f7                	div    %edi
  80239a:	89 c5                	mov    %eax,%ebp
  80239c:	89 c8                	mov    %ecx,%eax
  80239e:	31 d2                	xor    %edx,%edx
  8023a0:	f7 f5                	div    %ebp
  8023a2:	89 c1                	mov    %eax,%ecx
  8023a4:	89 d8                	mov    %ebx,%eax
  8023a6:	89 cf                	mov    %ecx,%edi
  8023a8:	f7 f5                	div    %ebp
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	89 d8                	mov    %ebx,%eax
  8023ae:	89 fa                	mov    %edi,%edx
  8023b0:	83 c4 1c             	add    $0x1c,%esp
  8023b3:	5b                   	pop    %ebx
  8023b4:	5e                   	pop    %esi
  8023b5:	5f                   	pop    %edi
  8023b6:	5d                   	pop    %ebp
  8023b7:	c3                   	ret    
  8023b8:	90                   	nop
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	39 ce                	cmp    %ecx,%esi
  8023c2:	77 74                	ja     802438 <__udivdi3+0xd8>
  8023c4:	0f bd fe             	bsr    %esi,%edi
  8023c7:	83 f7 1f             	xor    $0x1f,%edi
  8023ca:	0f 84 98 00 00 00    	je     802468 <__udivdi3+0x108>
  8023d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	89 c5                	mov    %eax,%ebp
  8023d9:	29 fb                	sub    %edi,%ebx
  8023db:	d3 e6                	shl    %cl,%esi
  8023dd:	89 d9                	mov    %ebx,%ecx
  8023df:	d3 ed                	shr    %cl,%ebp
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	d3 e0                	shl    %cl,%eax
  8023e5:	09 ee                	or     %ebp,%esi
  8023e7:	89 d9                	mov    %ebx,%ecx
  8023e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ed:	89 d5                	mov    %edx,%ebp
  8023ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023f3:	d3 ed                	shr    %cl,%ebp
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e2                	shl    %cl,%edx
  8023f9:	89 d9                	mov    %ebx,%ecx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	09 c2                	or     %eax,%edx
  8023ff:	89 d0                	mov    %edx,%eax
  802401:	89 ea                	mov    %ebp,%edx
  802403:	f7 f6                	div    %esi
  802405:	89 d5                	mov    %edx,%ebp
  802407:	89 c3                	mov    %eax,%ebx
  802409:	f7 64 24 0c          	mull   0xc(%esp)
  80240d:	39 d5                	cmp    %edx,%ebp
  80240f:	72 10                	jb     802421 <__udivdi3+0xc1>
  802411:	8b 74 24 08          	mov    0x8(%esp),%esi
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e6                	shl    %cl,%esi
  802419:	39 c6                	cmp    %eax,%esi
  80241b:	73 07                	jae    802424 <__udivdi3+0xc4>
  80241d:	39 d5                	cmp    %edx,%ebp
  80241f:	75 03                	jne    802424 <__udivdi3+0xc4>
  802421:	83 eb 01             	sub    $0x1,%ebx
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 d8                	mov    %ebx,%eax
  802428:	89 fa                	mov    %edi,%edx
  80242a:	83 c4 1c             	add    $0x1c,%esp
  80242d:	5b                   	pop    %ebx
  80242e:	5e                   	pop    %esi
  80242f:	5f                   	pop    %edi
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	31 ff                	xor    %edi,%edi
  80243a:	31 db                	xor    %ebx,%ebx
  80243c:	89 d8                	mov    %ebx,%eax
  80243e:	89 fa                	mov    %edi,%edx
  802440:	83 c4 1c             	add    $0x1c,%esp
  802443:	5b                   	pop    %ebx
  802444:	5e                   	pop    %esi
  802445:	5f                   	pop    %edi
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	90                   	nop
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 d8                	mov    %ebx,%eax
  802452:	f7 f7                	div    %edi
  802454:	31 ff                	xor    %edi,%edi
  802456:	89 c3                	mov    %eax,%ebx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 fa                	mov    %edi,%edx
  80245c:	83 c4 1c             	add    $0x1c,%esp
  80245f:	5b                   	pop    %ebx
  802460:	5e                   	pop    %esi
  802461:	5f                   	pop    %edi
  802462:	5d                   	pop    %ebp
  802463:	c3                   	ret    
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	39 ce                	cmp    %ecx,%esi
  80246a:	72 0c                	jb     802478 <__udivdi3+0x118>
  80246c:	31 db                	xor    %ebx,%ebx
  80246e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802472:	0f 87 34 ff ff ff    	ja     8023ac <__udivdi3+0x4c>
  802478:	bb 01 00 00 00       	mov    $0x1,%ebx
  80247d:	e9 2a ff ff ff       	jmp    8023ac <__udivdi3+0x4c>
  802482:	66 90                	xchg   %ax,%ax
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80249b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80249f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 d2                	test   %edx,%edx
  8024a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b1:	89 f3                	mov    %esi,%ebx
  8024b3:	89 3c 24             	mov    %edi,(%esp)
  8024b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ba:	75 1c                	jne    8024d8 <__umoddi3+0x48>
  8024bc:	39 f7                	cmp    %esi,%edi
  8024be:	76 50                	jbe    802510 <__umoddi3+0x80>
  8024c0:	89 c8                	mov    %ecx,%eax
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	f7 f7                	div    %edi
  8024c6:	89 d0                	mov    %edx,%eax
  8024c8:	31 d2                	xor    %edx,%edx
  8024ca:	83 c4 1c             	add    $0x1c,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    
  8024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d8:	39 f2                	cmp    %esi,%edx
  8024da:	89 d0                	mov    %edx,%eax
  8024dc:	77 52                	ja     802530 <__umoddi3+0xa0>
  8024de:	0f bd ea             	bsr    %edx,%ebp
  8024e1:	83 f5 1f             	xor    $0x1f,%ebp
  8024e4:	75 5a                	jne    802540 <__umoddi3+0xb0>
  8024e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ea:	0f 82 e0 00 00 00    	jb     8025d0 <__umoddi3+0x140>
  8024f0:	39 0c 24             	cmp    %ecx,(%esp)
  8024f3:	0f 86 d7 00 00 00    	jbe    8025d0 <__umoddi3+0x140>
  8024f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802501:	83 c4 1c             	add    $0x1c,%esp
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	85 ff                	test   %edi,%edi
  802512:	89 fd                	mov    %edi,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x91>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f7                	div    %edi
  80251f:	89 c5                	mov    %eax,%ebp
  802521:	89 f0                	mov    %esi,%eax
  802523:	31 d2                	xor    %edx,%edx
  802525:	f7 f5                	div    %ebp
  802527:	89 c8                	mov    %ecx,%eax
  802529:	f7 f5                	div    %ebp
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	eb 99                	jmp    8024c8 <__umoddi3+0x38>
  80252f:	90                   	nop
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 f2                	mov    %esi,%edx
  802534:	83 c4 1c             	add    $0x1c,%esp
  802537:	5b                   	pop    %ebx
  802538:	5e                   	pop    %esi
  802539:	5f                   	pop    %edi
  80253a:	5d                   	pop    %ebp
  80253b:	c3                   	ret    
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	8b 34 24             	mov    (%esp),%esi
  802543:	bf 20 00 00 00       	mov    $0x20,%edi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	29 ef                	sub    %ebp,%edi
  80254c:	d3 e0                	shl    %cl,%eax
  80254e:	89 f9                	mov    %edi,%ecx
  802550:	89 f2                	mov    %esi,%edx
  802552:	d3 ea                	shr    %cl,%edx
  802554:	89 e9                	mov    %ebp,%ecx
  802556:	09 c2                	or     %eax,%edx
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	89 14 24             	mov    %edx,(%esp)
  80255d:	89 f2                	mov    %esi,%edx
  80255f:	d3 e2                	shl    %cl,%edx
  802561:	89 f9                	mov    %edi,%ecx
  802563:	89 54 24 04          	mov    %edx,0x4(%esp)
  802567:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	89 e9                	mov    %ebp,%ecx
  80256f:	89 c6                	mov    %eax,%esi
  802571:	d3 e3                	shl    %cl,%ebx
  802573:	89 f9                	mov    %edi,%ecx
  802575:	89 d0                	mov    %edx,%eax
  802577:	d3 e8                	shr    %cl,%eax
  802579:	89 e9                	mov    %ebp,%ecx
  80257b:	09 d8                	or     %ebx,%eax
  80257d:	89 d3                	mov    %edx,%ebx
  80257f:	89 f2                	mov    %esi,%edx
  802581:	f7 34 24             	divl   (%esp)
  802584:	89 d6                	mov    %edx,%esi
  802586:	d3 e3                	shl    %cl,%ebx
  802588:	f7 64 24 04          	mull   0x4(%esp)
  80258c:	39 d6                	cmp    %edx,%esi
  80258e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802592:	89 d1                	mov    %edx,%ecx
  802594:	89 c3                	mov    %eax,%ebx
  802596:	72 08                	jb     8025a0 <__umoddi3+0x110>
  802598:	75 11                	jne    8025ab <__umoddi3+0x11b>
  80259a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80259e:	73 0b                	jae    8025ab <__umoddi3+0x11b>
  8025a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025a4:	1b 14 24             	sbb    (%esp),%edx
  8025a7:	89 d1                	mov    %edx,%ecx
  8025a9:	89 c3                	mov    %eax,%ebx
  8025ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025af:	29 da                	sub    %ebx,%edx
  8025b1:	19 ce                	sbb    %ecx,%esi
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	89 f0                	mov    %esi,%eax
  8025b7:	d3 e0                	shl    %cl,%eax
  8025b9:	89 e9                	mov    %ebp,%ecx
  8025bb:	d3 ea                	shr    %cl,%edx
  8025bd:	89 e9                	mov    %ebp,%ecx
  8025bf:	d3 ee                	shr    %cl,%esi
  8025c1:	09 d0                	or     %edx,%eax
  8025c3:	89 f2                	mov    %esi,%edx
  8025c5:	83 c4 1c             	add    $0x1c,%esp
  8025c8:	5b                   	pop    %ebx
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi
  8025d0:	29 f9                	sub    %edi,%ecx
  8025d2:	19 d6                	sbb    %edx,%esi
  8025d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025dc:	e9 18 ff ff ff       	jmp    8024f9 <__umoddi3+0x69>
