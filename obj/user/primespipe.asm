
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
  80004c:	e8 0b 18 00 00       	call   80185c <readn>
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
  800068:	68 80 26 80 00       	push   $0x802680
  80006d:	6a 15                	push   $0x15
  80006f:	68 af 26 80 00       	push   $0x8026af
  800074:	e8 42 02 00 00       	call   8002bb <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 3f 2b 80 00       	push   $0x802b3f
  800084:	e8 0b 03 00 00       	call   800394 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 4e 1e 00 00       	call   801edf <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 c1 26 80 00       	push   $0x8026c1
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 af 26 80 00       	push   $0x8026af
  8000a8:	e8 0e 02 00 00       	call   8002bb <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 91 0f 00 00       	call   801043 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 ca 26 80 00       	push   $0x8026ca
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 af 26 80 00       	push   $0x8026af
  8000c3:	e8 f3 01 00 00       	call   8002bb <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 b7 15 00 00       	call   80168c <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 ac 15 00 00       	call   80168c <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 96 15 00 00       	call   80168c <close>
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
  800106:	e8 51 17 00 00       	call   80185c <readn>
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
  800126:	68 d3 26 80 00       	push   $0x8026d3
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 af 26 80 00       	push   $0x8026af
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
  800149:	e8 57 17 00 00       	call   8018a5 <write>
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
  800168:	68 ef 26 80 00       	push   $0x8026ef
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 af 26 80 00       	push   $0x8026af
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
  800180:	c7 05 00 30 80 00 09 	movl   $0x802709,0x803000
  800187:	27 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 4c 1d 00 00       	call   801edf <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 c1 26 80 00       	push   $0x8026c1
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 af 26 80 00       	push   $0x8026af
  8001aa:	e8 0c 01 00 00       	call   8002bb <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 8f 0e 00 00       	call   801043 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 ca 26 80 00       	push   $0x8026ca
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 af 26 80 00       	push   $0x8026af
  8001c5:	e8 f1 00 00 00       	call   8002bb <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 b3 14 00 00       	call   80168c <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 9d 14 00 00       	call   80168c <close>

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
  800205:	e8 9b 16 00 00       	call   8018a5 <write>
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
  800221:	68 14 27 80 00       	push   $0x802714
  800226:	6a 4a                	push   $0x4a
  800228:	68 af 26 80 00       	push   $0x8026af
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
  80024d:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8002a7:	e8 0b 14 00 00       	call   8016b7 <close_all>
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
  8002d9:	68 38 27 80 00       	push   $0x802738
  8002de:	e8 b1 00 00 00       	call   800394 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e3:	83 c4 18             	add    $0x18,%esp
  8002e6:	53                   	push   %ebx
  8002e7:	ff 75 10             	pushl  0x10(%ebp)
  8002ea:	e8 54 00 00 00       	call   800343 <vcprintf>
	cprintf("\n");
  8002ef:	c7 04 24 26 2b 80 00 	movl   $0x802b26,(%esp)
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
  8003f7:	e8 e4 1f 00 00       	call   8023e0 <__udivdi3>
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
  80043a:	e8 d1 20 00 00       	call   802510 <__umoddi3>
  80043f:	83 c4 14             	add    $0x14,%esp
  800442:	0f be 80 5b 27 80 00 	movsbl 0x80275b(%eax),%eax
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
  80053e:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
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
  800602:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  800609:	85 d2                	test   %edx,%edx
  80060b:	75 18                	jne    800625 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80060d:	50                   	push   %eax
  80060e:	68 73 27 80 00       	push   $0x802773
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
  800626:	68 91 2c 80 00       	push   $0x802c91
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
  80064a:	b8 6c 27 80 00       	mov    $0x80276c,%eax
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
  800cc5:	68 5f 2a 80 00       	push   $0x802a5f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 7c 2a 80 00       	push   $0x802a7c
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
  800d46:	68 5f 2a 80 00       	push   $0x802a5f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 7c 2a 80 00       	push   $0x802a7c
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
  800d88:	68 5f 2a 80 00       	push   $0x802a5f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 7c 2a 80 00       	push   $0x802a7c
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
  800dca:	68 5f 2a 80 00       	push   $0x802a5f
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 7c 2a 80 00       	push   $0x802a7c
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
  800e0c:	68 5f 2a 80 00       	push   $0x802a5f
  800e11:	6a 23                	push   $0x23
  800e13:	68 7c 2a 80 00       	push   $0x802a7c
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
  800e4e:	68 5f 2a 80 00       	push   $0x802a5f
  800e53:	6a 23                	push   $0x23
  800e55:	68 7c 2a 80 00       	push   $0x802a7c
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
  800e90:	68 5f 2a 80 00       	push   $0x802a5f
  800e95:	6a 23                	push   $0x23
  800e97:	68 7c 2a 80 00       	push   $0x802a7c
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
  800ef4:	68 5f 2a 80 00       	push   $0x802a5f
  800ef9:	6a 23                	push   $0x23
  800efb:	68 7c 2a 80 00       	push   $0x802a7c
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
  800f93:	68 8a 2a 80 00       	push   $0x802a8a
  800f98:	6a 1f                	push   $0x1f
  800f9a:	68 9a 2a 80 00       	push   $0x802a9a
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
  800fbd:	68 a5 2a 80 00       	push   $0x802aa5
  800fc2:	6a 2d                	push   $0x2d
  800fc4:	68 9a 2a 80 00       	push   $0x802a9a
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
  801005:	68 a5 2a 80 00       	push   $0x802aa5
  80100a:	6a 34                	push   $0x34
  80100c:	68 9a 2a 80 00       	push   $0x802a9a
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
  80102d:	68 a5 2a 80 00       	push   $0x802aa5
  801032:	6a 38                	push   $0x38
  801034:	68 9a 2a 80 00       	push   $0x802a9a
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
  801051:	e8 92 11 00 00       	call   8021e8 <set_pgfault_handler>
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
  80106a:	68 be 2a 80 00       	push   $0x802abe
  80106f:	68 85 00 00 00       	push   $0x85
  801074:	68 9a 2a 80 00       	push   $0x802a9a
  801079:	e8 3d f2 ff ff       	call   8002bb <_panic>
  80107e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801080:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801084:	75 24                	jne    8010aa <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801086:	e8 53 fc ff ff       	call   800cde <sys_getenvid>
  80108b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801090:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  801126:	68 cc 2a 80 00       	push   $0x802acc
  80112b:	6a 55                	push   $0x55
  80112d:	68 9a 2a 80 00       	push   $0x802a9a
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
  80116b:	68 cc 2a 80 00       	push   $0x802acc
  801170:	6a 5c                	push   $0x5c
  801172:	68 9a 2a 80 00       	push   $0x802a9a
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
  801199:	68 cc 2a 80 00       	push   $0x802acc
  80119e:	6a 60                	push   $0x60
  8011a0:	68 9a 2a 80 00       	push   $0x802a9a
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
  8011c3:	68 cc 2a 80 00       	push   $0x802acc
  8011c8:	6a 65                	push   $0x65
  8011ca:	68 9a 2a 80 00       	push   $0x802a9a
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
  8011eb:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801228:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	53                   	push   %ebx
  801232:	68 5c 2b 80 00       	push   $0x802b5c
  801237:	e8 58 f1 ff ff       	call   800394 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80123c:	c7 04 24 81 02 80 00 	movl   $0x800281,(%esp)
  801243:	e8 c5 fc ff ff       	call   800f0d <sys_thread_create>
  801248:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80124a:	83 c4 08             	add    $0x8,%esp
  80124d:	53                   	push   %ebx
  80124e:	68 5c 2b 80 00       	push   $0x802b5c
  801253:	e8 3c f1 ff ff       	call   800394 <cprintf>
	return id;
}
  801258:	89 f0                	mov    %esi,%eax
  80125a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801267:	ff 75 08             	pushl  0x8(%ebp)
  80126a:	e8 be fc ff ff       	call   800f2d <sys_thread_free>
}
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80127a:	ff 75 08             	pushl  0x8(%ebp)
  80127d:	e8 cb fc ff ff       	call   800f4d <sys_thread_join>
}
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	8b 75 08             	mov    0x8(%ebp),%esi
  80128f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801292:	83 ec 04             	sub    $0x4,%esp
  801295:	6a 07                	push   $0x7
  801297:	6a 00                	push   $0x0
  801299:	56                   	push   %esi
  80129a:	e8 7d fa ff ff       	call   800d1c <sys_page_alloc>
	if (r < 0) {
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	79 15                	jns    8012bb <queue_append+0x34>
		panic("%e\n", r);
  8012a6:	50                   	push   %eax
  8012a7:	68 58 2b 80 00       	push   $0x802b58
  8012ac:	68 c4 00 00 00       	push   $0xc4
  8012b1:	68 9a 2a 80 00       	push   $0x802a9a
  8012b6:	e8 00 f0 ff ff       	call   8002bb <_panic>
	}	
	wt->envid = envid;
  8012bb:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	ff 33                	pushl  (%ebx)
  8012c6:	56                   	push   %esi
  8012c7:	68 80 2b 80 00       	push   $0x802b80
  8012cc:	e8 c3 f0 ff ff       	call   800394 <cprintf>
	if (queue->first == NULL) {
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	83 3b 00             	cmpl   $0x0,(%ebx)
  8012d7:	75 29                	jne    801302 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	68 e2 2a 80 00       	push   $0x802ae2
  8012e1:	e8 ae f0 ff ff       	call   800394 <cprintf>
		queue->first = wt;
  8012e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8012ec:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8012f3:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012fa:	00 00 00 
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	eb 2b                	jmp    80132d <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	68 fc 2a 80 00       	push   $0x802afc
  80130a:	e8 85 f0 ff ff       	call   800394 <cprintf>
		queue->last->next = wt;
  80130f:	8b 43 04             	mov    0x4(%ebx),%eax
  801312:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801319:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801320:	00 00 00 
		queue->last = wt;
  801323:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80132a:	83 c4 10             	add    $0x10,%esp
	}
}
  80132d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 04             	sub    $0x4,%esp
  80133b:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80133e:	8b 02                	mov    (%edx),%eax
  801340:	85 c0                	test   %eax,%eax
  801342:	75 17                	jne    80135b <queue_pop+0x27>
		panic("queue empty!\n");
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	68 1a 2b 80 00       	push   $0x802b1a
  80134c:	68 d8 00 00 00       	push   $0xd8
  801351:	68 9a 2a 80 00       	push   $0x802a9a
  801356:	e8 60 ef ff ff       	call   8002bb <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80135b:	8b 48 04             	mov    0x4(%eax),%ecx
  80135e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801360:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	53                   	push   %ebx
  801366:	68 28 2b 80 00       	push   $0x802b28
  80136b:	e8 24 f0 ff ff       	call   800394 <cprintf>
	return envid;
}
  801370:	89 d8                	mov    %ebx,%eax
  801372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 04             	sub    $0x4,%esp
  80137e:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801381:	b8 01 00 00 00       	mov    $0x1,%eax
  801386:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801389:	85 c0                	test   %eax,%eax
  80138b:	74 5a                	je     8013e7 <mutex_lock+0x70>
  80138d:	8b 43 04             	mov    0x4(%ebx),%eax
  801390:	83 38 00             	cmpl   $0x0,(%eax)
  801393:	75 52                	jne    8013e7 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	68 a8 2b 80 00       	push   $0x802ba8
  80139d:	e8 f2 ef ff ff       	call   800394 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8013a2:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8013a5:	e8 34 f9 ff ff       	call   800cde <sys_getenvid>
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	50                   	push   %eax
  8013af:	e8 d3 fe ff ff       	call   801287 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8013b4:	e8 25 f9 ff ff       	call   800cde <sys_getenvid>
  8013b9:	83 c4 08             	add    $0x8,%esp
  8013bc:	6a 04                	push   $0x4
  8013be:	50                   	push   %eax
  8013bf:	e8 1f fa ff ff       	call   800de3 <sys_env_set_status>
		if (r < 0) {
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	79 15                	jns    8013e0 <mutex_lock+0x69>
			panic("%e\n", r);
  8013cb:	50                   	push   %eax
  8013cc:	68 58 2b 80 00       	push   $0x802b58
  8013d1:	68 eb 00 00 00       	push   $0xeb
  8013d6:	68 9a 2a 80 00       	push   $0x802a9a
  8013db:	e8 db ee ff ff       	call   8002bb <_panic>
		}
		sys_yield();
  8013e0:	e8 18 f9 ff ff       	call   800cfd <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8013e5:	eb 18                	jmp    8013ff <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	68 c8 2b 80 00       	push   $0x802bc8
  8013ef:	e8 a0 ef ff ff       	call   800394 <cprintf>
	mtx->owner = sys_getenvid();}
  8013f4:	e8 e5 f8 ff ff       	call   800cde <sys_getenvid>
  8013f9:	89 43 08             	mov    %eax,0x8(%ebx)
  8013fc:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8013ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801402:	c9                   	leave  
  801403:	c3                   	ret    

00801404 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 04             	sub    $0x4,%esp
  80140b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80140e:	b8 00 00 00 00       	mov    $0x0,%eax
  801413:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801416:	8b 43 04             	mov    0x4(%ebx),%eax
  801419:	83 38 00             	cmpl   $0x0,(%eax)
  80141c:	74 33                	je     801451 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80141e:	83 ec 0c             	sub    $0xc,%esp
  801421:	50                   	push   %eax
  801422:	e8 0d ff ff ff       	call   801334 <queue_pop>
  801427:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80142a:	83 c4 08             	add    $0x8,%esp
  80142d:	6a 02                	push   $0x2
  80142f:	50                   	push   %eax
  801430:	e8 ae f9 ff ff       	call   800de3 <sys_env_set_status>
		if (r < 0) {
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	79 15                	jns    801451 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80143c:	50                   	push   %eax
  80143d:	68 58 2b 80 00       	push   $0x802b58
  801442:	68 00 01 00 00       	push   $0x100
  801447:	68 9a 2a 80 00       	push   $0x802a9a
  80144c:	e8 6a ee ff ff       	call   8002bb <_panic>
		}
	}

	asm volatile("pause");
  801451:	f3 90                	pause  
	//sys_yield();
}
  801453:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801456:	c9                   	leave  
  801457:	c3                   	ret    

00801458 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	53                   	push   %ebx
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801462:	e8 77 f8 ff ff       	call   800cde <sys_getenvid>
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	6a 07                	push   $0x7
  80146c:	53                   	push   %ebx
  80146d:	50                   	push   %eax
  80146e:	e8 a9 f8 ff ff       	call   800d1c <sys_page_alloc>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	79 15                	jns    80148f <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80147a:	50                   	push   %eax
  80147b:	68 43 2b 80 00       	push   $0x802b43
  801480:	68 0d 01 00 00       	push   $0x10d
  801485:	68 9a 2a 80 00       	push   $0x802a9a
  80148a:	e8 2c ee ff ff       	call   8002bb <_panic>
	}	
	mtx->locked = 0;
  80148f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801495:	8b 43 04             	mov    0x4(%ebx),%eax
  801498:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80149e:	8b 43 04             	mov    0x4(%ebx),%eax
  8014a1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8014a8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8014af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b2:	c9                   	leave  
  8014b3:	c3                   	ret    

008014b4 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8014ba:	e8 1f f8 ff ff       	call   800cde <sys_getenvid>
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	ff 75 08             	pushl  0x8(%ebp)
  8014c5:	50                   	push   %eax
  8014c6:	e8 d6 f8 ff ff       	call   800da1 <sys_page_unmap>
	if (r < 0) {
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	79 15                	jns    8014e7 <mutex_destroy+0x33>
		panic("%e\n", r);
  8014d2:	50                   	push   %eax
  8014d3:	68 58 2b 80 00       	push   $0x802b58
  8014d8:	68 1a 01 00 00       	push   $0x11a
  8014dd:	68 9a 2a 80 00       	push   $0x802a9a
  8014e2:	e8 d4 ed ff ff       	call   8002bb <_panic>
	}
}
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8014f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ff:	05 00 00 00 30       	add    $0x30000000,%eax
  801504:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801509:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    

00801510 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801516:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	c1 ea 16             	shr    $0x16,%edx
  801520:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801527:	f6 c2 01             	test   $0x1,%dl
  80152a:	74 11                	je     80153d <fd_alloc+0x2d>
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	c1 ea 0c             	shr    $0xc,%edx
  801531:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801538:	f6 c2 01             	test   $0x1,%dl
  80153b:	75 09                	jne    801546 <fd_alloc+0x36>
			*fd_store = fd;
  80153d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80153f:	b8 00 00 00 00       	mov    $0x0,%eax
  801544:	eb 17                	jmp    80155d <fd_alloc+0x4d>
  801546:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80154b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801550:	75 c9                	jne    80151b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801552:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801558:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801565:	83 f8 1f             	cmp    $0x1f,%eax
  801568:	77 36                	ja     8015a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80156a:	c1 e0 0c             	shl    $0xc,%eax
  80156d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801572:	89 c2                	mov    %eax,%edx
  801574:	c1 ea 16             	shr    $0x16,%edx
  801577:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80157e:	f6 c2 01             	test   $0x1,%dl
  801581:	74 24                	je     8015a7 <fd_lookup+0x48>
  801583:	89 c2                	mov    %eax,%edx
  801585:	c1 ea 0c             	shr    $0xc,%edx
  801588:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158f:	f6 c2 01             	test   $0x1,%dl
  801592:	74 1a                	je     8015ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801594:	8b 55 0c             	mov    0xc(%ebp),%edx
  801597:	89 02                	mov    %eax,(%edx)
	return 0;
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
  80159e:	eb 13                	jmp    8015b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a5:	eb 0c                	jmp    8015b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ac:	eb 05                	jmp    8015b3 <fd_lookup+0x54>
  8015ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015be:	ba 68 2c 80 00       	mov    $0x802c68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015c3:	eb 13                	jmp    8015d8 <dev_lookup+0x23>
  8015c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015c8:	39 08                	cmp    %ecx,(%eax)
  8015ca:	75 0c                	jne    8015d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8015cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d6:	eb 31                	jmp    801609 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015d8:	8b 02                	mov    (%edx),%eax
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	75 e7                	jne    8015c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015de:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	51                   	push   %ecx
  8015ed:	50                   	push   %eax
  8015ee:	68 e8 2b 80 00       	push   $0x802be8
  8015f3:	e8 9c ed ff ff       	call   800394 <cprintf>
	*dev = 0;
  8015f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
  801610:	83 ec 10             	sub    $0x10,%esp
  801613:	8b 75 08             	mov    0x8(%ebp),%esi
  801616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	50                   	push   %eax
  80161d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801623:	c1 e8 0c             	shr    $0xc,%eax
  801626:	50                   	push   %eax
  801627:	e8 33 ff ff ff       	call   80155f <fd_lookup>
  80162c:	83 c4 08             	add    $0x8,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 05                	js     801638 <fd_close+0x2d>
	    || fd != fd2)
  801633:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801636:	74 0c                	je     801644 <fd_close+0x39>
		return (must_exist ? r : 0);
  801638:	84 db                	test   %bl,%bl
  80163a:	ba 00 00 00 00       	mov    $0x0,%edx
  80163f:	0f 44 c2             	cmove  %edx,%eax
  801642:	eb 41                	jmp    801685 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	ff 36                	pushl  (%esi)
  80164d:	e8 63 ff ff ff       	call   8015b5 <dev_lookup>
  801652:	89 c3                	mov    %eax,%ebx
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 1a                	js     801675 <fd_close+0x6a>
		if (dev->dev_close)
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801661:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801666:	85 c0                	test   %eax,%eax
  801668:	74 0b                	je     801675 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	56                   	push   %esi
  80166e:	ff d0                	call   *%eax
  801670:	89 c3                	mov    %eax,%ebx
  801672:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	56                   	push   %esi
  801679:	6a 00                	push   $0x0
  80167b:	e8 21 f7 ff ff       	call   800da1 <sys_page_unmap>
	return r;
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	89 d8                	mov    %ebx,%eax
}
  801685:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801688:	5b                   	pop    %ebx
  801689:	5e                   	pop    %esi
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	ff 75 08             	pushl  0x8(%ebp)
  801699:	e8 c1 fe ff ff       	call   80155f <fd_lookup>
  80169e:	83 c4 08             	add    $0x8,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 10                	js     8016b5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	6a 01                	push   $0x1
  8016aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ad:	e8 59 ff ff ff       	call   80160b <fd_close>
  8016b2:	83 c4 10             	add    $0x10,%esp
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <close_all>:

void
close_all(void)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016be:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	53                   	push   %ebx
  8016c7:	e8 c0 ff ff ff       	call   80168c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016cc:	83 c3 01             	add    $0x1,%ebx
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	83 fb 20             	cmp    $0x20,%ebx
  8016d5:	75 ec                	jne    8016c3 <close_all+0xc>
		close(i);
}
  8016d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	57                   	push   %edi
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 2c             	sub    $0x2c,%esp
  8016e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	ff 75 08             	pushl  0x8(%ebp)
  8016ef:	e8 6b fe ff ff       	call   80155f <fd_lookup>
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	0f 88 c1 00 00 00    	js     8017c0 <dup+0xe4>
		return r;
	close(newfdnum);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	56                   	push   %esi
  801703:	e8 84 ff ff ff       	call   80168c <close>

	newfd = INDEX2FD(newfdnum);
  801708:	89 f3                	mov    %esi,%ebx
  80170a:	c1 e3 0c             	shl    $0xc,%ebx
  80170d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801713:	83 c4 04             	add    $0x4,%esp
  801716:	ff 75 e4             	pushl  -0x1c(%ebp)
  801719:	e8 db fd ff ff       	call   8014f9 <fd2data>
  80171e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801720:	89 1c 24             	mov    %ebx,(%esp)
  801723:	e8 d1 fd ff ff       	call   8014f9 <fd2data>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80172e:	89 f8                	mov    %edi,%eax
  801730:	c1 e8 16             	shr    $0x16,%eax
  801733:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80173a:	a8 01                	test   $0x1,%al
  80173c:	74 37                	je     801775 <dup+0x99>
  80173e:	89 f8                	mov    %edi,%eax
  801740:	c1 e8 0c             	shr    $0xc,%eax
  801743:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80174a:	f6 c2 01             	test   $0x1,%dl
  80174d:	74 26                	je     801775 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80174f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	25 07 0e 00 00       	and    $0xe07,%eax
  80175e:	50                   	push   %eax
  80175f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801762:	6a 00                	push   $0x0
  801764:	57                   	push   %edi
  801765:	6a 00                	push   $0x0
  801767:	e8 f3 f5 ff ff       	call   800d5f <sys_page_map>
  80176c:	89 c7                	mov    %eax,%edi
  80176e:	83 c4 20             	add    $0x20,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 2e                	js     8017a3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801775:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801778:	89 d0                	mov    %edx,%eax
  80177a:	c1 e8 0c             	shr    $0xc,%eax
  80177d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801784:	83 ec 0c             	sub    $0xc,%esp
  801787:	25 07 0e 00 00       	and    $0xe07,%eax
  80178c:	50                   	push   %eax
  80178d:	53                   	push   %ebx
  80178e:	6a 00                	push   $0x0
  801790:	52                   	push   %edx
  801791:	6a 00                	push   $0x0
  801793:	e8 c7 f5 ff ff       	call   800d5f <sys_page_map>
  801798:	89 c7                	mov    %eax,%edi
  80179a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80179d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80179f:	85 ff                	test   %edi,%edi
  8017a1:	79 1d                	jns    8017c0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	53                   	push   %ebx
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 f3 f5 ff ff       	call   800da1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ae:	83 c4 08             	add    $0x8,%esp
  8017b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 e6 f5 ff ff       	call   800da1 <sys_page_unmap>
	return r;
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	89 f8                	mov    %edi,%eax
}
  8017c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5f                   	pop    %edi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 14             	sub    $0x14,%esp
  8017cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d5:	50                   	push   %eax
  8017d6:	53                   	push   %ebx
  8017d7:	e8 83 fd ff ff       	call   80155f <fd_lookup>
  8017dc:	83 c4 08             	add    $0x8,%esp
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 70                	js     801855 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017eb:	50                   	push   %eax
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	ff 30                	pushl  (%eax)
  8017f1:	e8 bf fd ff ff       	call   8015b5 <dev_lookup>
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 4f                	js     80184c <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801800:	8b 42 08             	mov    0x8(%edx),%eax
  801803:	83 e0 03             	and    $0x3,%eax
  801806:	83 f8 01             	cmp    $0x1,%eax
  801809:	75 24                	jne    80182f <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180b:	a1 04 40 80 00       	mov    0x804004,%eax
  801810:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	53                   	push   %ebx
  80181a:	50                   	push   %eax
  80181b:	68 2c 2c 80 00       	push   $0x802c2c
  801820:	e8 6f eb ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80182d:	eb 26                	jmp    801855 <read+0x8d>
	}
	if (!dev->dev_read)
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	8b 40 08             	mov    0x8(%eax),%eax
  801835:	85 c0                	test   %eax,%eax
  801837:	74 17                	je     801850 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801839:	83 ec 04             	sub    $0x4,%esp
  80183c:	ff 75 10             	pushl  0x10(%ebp)
  80183f:	ff 75 0c             	pushl  0xc(%ebp)
  801842:	52                   	push   %edx
  801843:	ff d0                	call   *%eax
  801845:	89 c2                	mov    %eax,%edx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	eb 09                	jmp    801855 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184c:	89 c2                	mov    %eax,%edx
  80184e:	eb 05                	jmp    801855 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801850:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801855:	89 d0                	mov    %edx,%eax
  801857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	57                   	push   %edi
  801860:	56                   	push   %esi
  801861:	53                   	push   %ebx
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	8b 7d 08             	mov    0x8(%ebp),%edi
  801868:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80186b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801870:	eb 21                	jmp    801893 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	89 f0                	mov    %esi,%eax
  801877:	29 d8                	sub    %ebx,%eax
  801879:	50                   	push   %eax
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	03 45 0c             	add    0xc(%ebp),%eax
  80187f:	50                   	push   %eax
  801880:	57                   	push   %edi
  801881:	e8 42 ff ff ff       	call   8017c8 <read>
		if (m < 0)
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 10                	js     80189d <readn+0x41>
			return m;
		if (m == 0)
  80188d:	85 c0                	test   %eax,%eax
  80188f:	74 0a                	je     80189b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801891:	01 c3                	add    %eax,%ebx
  801893:	39 f3                	cmp    %esi,%ebx
  801895:	72 db                	jb     801872 <readn+0x16>
  801897:	89 d8                	mov    %ebx,%eax
  801899:	eb 02                	jmp    80189d <readn+0x41>
  80189b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80189d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5f                   	pop    %edi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 14             	sub    $0x14,%esp
  8018ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b2:	50                   	push   %eax
  8018b3:	53                   	push   %ebx
  8018b4:	e8 a6 fc ff ff       	call   80155f <fd_lookup>
  8018b9:	83 c4 08             	add    $0x8,%esp
  8018bc:	89 c2                	mov    %eax,%edx
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 6b                	js     80192d <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cc:	ff 30                	pushl  (%eax)
  8018ce:	e8 e2 fc ff ff       	call   8015b5 <dev_lookup>
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 4a                	js     801924 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e1:	75 24                	jne    801907 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018ee:	83 ec 04             	sub    $0x4,%esp
  8018f1:	53                   	push   %ebx
  8018f2:	50                   	push   %eax
  8018f3:	68 48 2c 80 00       	push   $0x802c48
  8018f8:	e8 97 ea ff ff       	call   800394 <cprintf>
		return -E_INVAL;
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801905:	eb 26                	jmp    80192d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801907:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190a:	8b 52 0c             	mov    0xc(%edx),%edx
  80190d:	85 d2                	test   %edx,%edx
  80190f:	74 17                	je     801928 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801911:	83 ec 04             	sub    $0x4,%esp
  801914:	ff 75 10             	pushl  0x10(%ebp)
  801917:	ff 75 0c             	pushl  0xc(%ebp)
  80191a:	50                   	push   %eax
  80191b:	ff d2                	call   *%edx
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb 09                	jmp    80192d <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801924:	89 c2                	mov    %eax,%edx
  801926:	eb 05                	jmp    80192d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801928:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80192d:	89 d0                	mov    %edx,%eax
  80192f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <seek>:

int
seek(int fdnum, off_t offset)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80193d:	50                   	push   %eax
  80193e:	ff 75 08             	pushl  0x8(%ebp)
  801941:	e8 19 fc ff ff       	call   80155f <fd_lookup>
  801946:	83 c4 08             	add    $0x8,%esp
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 0e                	js     80195b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80194d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801950:	8b 55 0c             	mov    0xc(%ebp),%edx
  801953:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	53                   	push   %ebx
  801961:	83 ec 14             	sub    $0x14,%esp
  801964:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801967:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196a:	50                   	push   %eax
  80196b:	53                   	push   %ebx
  80196c:	e8 ee fb ff ff       	call   80155f <fd_lookup>
  801971:	83 c4 08             	add    $0x8,%esp
  801974:	89 c2                	mov    %eax,%edx
  801976:	85 c0                	test   %eax,%eax
  801978:	78 68                	js     8019e2 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197a:	83 ec 08             	sub    $0x8,%esp
  80197d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801980:	50                   	push   %eax
  801981:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801984:	ff 30                	pushl  (%eax)
  801986:	e8 2a fc ff ff       	call   8015b5 <dev_lookup>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 47                	js     8019d9 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801992:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801995:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801999:	75 24                	jne    8019bf <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80199b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019a0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	53                   	push   %ebx
  8019aa:	50                   	push   %eax
  8019ab:	68 08 2c 80 00       	push   $0x802c08
  8019b0:	e8 df e9 ff ff       	call   800394 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019bd:	eb 23                	jmp    8019e2 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8019bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c2:	8b 52 18             	mov    0x18(%edx),%edx
  8019c5:	85 d2                	test   %edx,%edx
  8019c7:	74 14                	je     8019dd <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	ff 75 0c             	pushl  0xc(%ebp)
  8019cf:	50                   	push   %eax
  8019d0:	ff d2                	call   *%edx
  8019d2:	89 c2                	mov    %eax,%edx
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	eb 09                	jmp    8019e2 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d9:	89 c2                	mov    %eax,%edx
  8019db:	eb 05                	jmp    8019e2 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019e2:	89 d0                	mov    %edx,%eax
  8019e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 14             	sub    $0x14,%esp
  8019f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f6:	50                   	push   %eax
  8019f7:	ff 75 08             	pushl  0x8(%ebp)
  8019fa:	e8 60 fb ff ff       	call   80155f <fd_lookup>
  8019ff:	83 c4 08             	add    $0x8,%esp
  801a02:	89 c2                	mov    %eax,%edx
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 58                	js     801a60 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a08:	83 ec 08             	sub    $0x8,%esp
  801a0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0e:	50                   	push   %eax
  801a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a12:	ff 30                	pushl  (%eax)
  801a14:	e8 9c fb ff ff       	call   8015b5 <dev_lookup>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 37                	js     801a57 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a23:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a27:	74 32                	je     801a5b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a29:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a2c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a33:	00 00 00 
	stat->st_isdir = 0;
  801a36:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3d:	00 00 00 
	stat->st_dev = dev;
  801a40:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	53                   	push   %ebx
  801a4a:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4d:	ff 50 14             	call   *0x14(%eax)
  801a50:	89 c2                	mov    %eax,%edx
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	eb 09                	jmp    801a60 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	eb 05                	jmp    801a60 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a5b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a60:	89 d0                	mov    %edx,%eax
  801a62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	6a 00                	push   $0x0
  801a71:	ff 75 08             	pushl  0x8(%ebp)
  801a74:	e8 e3 01 00 00       	call   801c5c <open>
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	78 1b                	js     801a9d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a82:	83 ec 08             	sub    $0x8,%esp
  801a85:	ff 75 0c             	pushl  0xc(%ebp)
  801a88:	50                   	push   %eax
  801a89:	e8 5b ff ff ff       	call   8019e9 <fstat>
  801a8e:	89 c6                	mov    %eax,%esi
	close(fd);
  801a90:	89 1c 24             	mov    %ebx,(%esp)
  801a93:	e8 f4 fb ff ff       	call   80168c <close>
	return r;
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	89 f0                	mov    %esi,%eax
}
  801a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	89 c6                	mov    %eax,%esi
  801aab:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801aad:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ab4:	75 12                	jne    801ac8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ab6:	83 ec 0c             	sub    $0xc,%esp
  801ab9:	6a 01                	push   $0x1
  801abb:	e8 94 08 00 00       	call   802354 <ipc_find_env>
  801ac0:	a3 00 40 80 00       	mov    %eax,0x804000
  801ac5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ac8:	6a 07                	push   $0x7
  801aca:	68 00 50 80 00       	push   $0x805000
  801acf:	56                   	push   %esi
  801ad0:	ff 35 00 40 80 00    	pushl  0x804000
  801ad6:	e8 17 08 00 00       	call   8022f2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801adb:	83 c4 0c             	add    $0xc,%esp
  801ade:	6a 00                	push   $0x0
  801ae0:	53                   	push   %ebx
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 8f 07 00 00       	call   802277 <ipc_recv>
}
  801ae8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801af5:	8b 45 08             	mov    0x8(%ebp),%eax
  801af8:	8b 40 0c             	mov    0xc(%eax),%eax
  801afb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b03:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b08:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0d:	b8 02 00 00 00       	mov    $0x2,%eax
  801b12:	e8 8d ff ff ff       	call   801aa4 <fsipc>
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	8b 40 0c             	mov    0xc(%eax),%eax
  801b25:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	b8 06 00 00 00       	mov    $0x6,%eax
  801b34:	e8 6b ff ff ff       	call   801aa4 <fsipc>
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 04             	sub    $0x4,%esp
  801b42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b50:	ba 00 00 00 00       	mov    $0x0,%edx
  801b55:	b8 05 00 00 00       	mov    $0x5,%eax
  801b5a:	e8 45 ff ff ff       	call   801aa4 <fsipc>
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 2c                	js     801b8f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b63:	83 ec 08             	sub    $0x8,%esp
  801b66:	68 00 50 80 00       	push   $0x805000
  801b6b:	53                   	push   %ebx
  801b6c:	e8 a8 ed ff ff       	call   800919 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b71:	a1 80 50 80 00       	mov    0x805080,%eax
  801b76:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b7c:	a1 84 50 80 00       	mov    0x805084,%eax
  801b81:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  801ba0:	8b 52 0c             	mov    0xc(%edx),%edx
  801ba3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ba9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bae:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bb3:	0f 47 c2             	cmova  %edx,%eax
  801bb6:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801bbb:	50                   	push   %eax
  801bbc:	ff 75 0c             	pushl  0xc(%ebp)
  801bbf:	68 08 50 80 00       	push   $0x805008
  801bc4:	e8 e2 ee ff ff       	call   800aab <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bce:	b8 04 00 00 00       	mov    $0x4,%eax
  801bd3:	e8 cc fe ff ff       	call   801aa4 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	56                   	push   %esi
  801bde:	53                   	push   %ebx
  801bdf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801be2:	8b 45 08             	mov    0x8(%ebp),%eax
  801be5:	8b 40 0c             	mov    0xc(%eax),%eax
  801be8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bed:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf8:	b8 03 00 00 00       	mov    $0x3,%eax
  801bfd:	e8 a2 fe ff ff       	call   801aa4 <fsipc>
  801c02:	89 c3                	mov    %eax,%ebx
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 4b                	js     801c53 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c08:	39 c6                	cmp    %eax,%esi
  801c0a:	73 16                	jae    801c22 <devfile_read+0x48>
  801c0c:	68 78 2c 80 00       	push   $0x802c78
  801c11:	68 7f 2c 80 00       	push   $0x802c7f
  801c16:	6a 7c                	push   $0x7c
  801c18:	68 94 2c 80 00       	push   $0x802c94
  801c1d:	e8 99 e6 ff ff       	call   8002bb <_panic>
	assert(r <= PGSIZE);
  801c22:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c27:	7e 16                	jle    801c3f <devfile_read+0x65>
  801c29:	68 9f 2c 80 00       	push   $0x802c9f
  801c2e:	68 7f 2c 80 00       	push   $0x802c7f
  801c33:	6a 7d                	push   $0x7d
  801c35:	68 94 2c 80 00       	push   $0x802c94
  801c3a:	e8 7c e6 ff ff       	call   8002bb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	50                   	push   %eax
  801c43:	68 00 50 80 00       	push   $0x805000
  801c48:	ff 75 0c             	pushl  0xc(%ebp)
  801c4b:	e8 5b ee ff ff       	call   800aab <memmove>
	return r;
  801c50:	83 c4 10             	add    $0x10,%esp
}
  801c53:	89 d8                	mov    %ebx,%eax
  801c55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c58:	5b                   	pop    %ebx
  801c59:	5e                   	pop    %esi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	53                   	push   %ebx
  801c60:	83 ec 20             	sub    $0x20,%esp
  801c63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c66:	53                   	push   %ebx
  801c67:	e8 74 ec ff ff       	call   8008e0 <strlen>
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c74:	7f 67                	jg     801cdd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7c:	50                   	push   %eax
  801c7d:	e8 8e f8 ff ff       	call   801510 <fd_alloc>
  801c82:	83 c4 10             	add    $0x10,%esp
		return r;
  801c85:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c87:	85 c0                	test   %eax,%eax
  801c89:	78 57                	js     801ce2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c8b:	83 ec 08             	sub    $0x8,%esp
  801c8e:	53                   	push   %ebx
  801c8f:	68 00 50 80 00       	push   $0x805000
  801c94:	e8 80 ec ff ff       	call   800919 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ca1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca9:	e8 f6 fd ff ff       	call   801aa4 <fsipc>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	79 14                	jns    801ccb <open+0x6f>
		fd_close(fd, 0);
  801cb7:	83 ec 08             	sub    $0x8,%esp
  801cba:	6a 00                	push   $0x0
  801cbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbf:	e8 47 f9 ff ff       	call   80160b <fd_close>
		return r;
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	89 da                	mov    %ebx,%edx
  801cc9:	eb 17                	jmp    801ce2 <open+0x86>
	}

	return fd2num(fd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd1:	e8 13 f8 ff ff       	call   8014e9 <fd2num>
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	eb 05                	jmp    801ce2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cdd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ce2:	89 d0                	mov    %edx,%eax
  801ce4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cef:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf4:	b8 08 00 00 00       	mov    $0x8,%eax
  801cf9:	e8 a6 fd ff ff       	call   801aa4 <fsipc>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d08:	83 ec 0c             	sub    $0xc,%esp
  801d0b:	ff 75 08             	pushl  0x8(%ebp)
  801d0e:	e8 e6 f7 ff ff       	call   8014f9 <fd2data>
  801d13:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d15:	83 c4 08             	add    $0x8,%esp
  801d18:	68 ab 2c 80 00       	push   $0x802cab
  801d1d:	53                   	push   %ebx
  801d1e:	e8 f6 eb ff ff       	call   800919 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d23:	8b 46 04             	mov    0x4(%esi),%eax
  801d26:	2b 06                	sub    (%esi),%eax
  801d28:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d2e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d35:	00 00 00 
	stat->st_dev = &devpipe;
  801d38:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d3f:	30 80 00 
	return 0;
}
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
  801d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	53                   	push   %ebx
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d58:	53                   	push   %ebx
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 41 f0 ff ff       	call   800da1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d60:	89 1c 24             	mov    %ebx,(%esp)
  801d63:	e8 91 f7 ff ff       	call   8014f9 <fd2data>
  801d68:	83 c4 08             	add    $0x8,%esp
  801d6b:	50                   	push   %eax
  801d6c:	6a 00                	push   $0x0
  801d6e:	e8 2e f0 ff ff       	call   800da1 <sys_page_unmap>
}
  801d73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	57                   	push   %edi
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 1c             	sub    $0x1c,%esp
  801d81:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d84:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d86:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8b:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d91:	83 ec 0c             	sub    $0xc,%esp
  801d94:	ff 75 e0             	pushl  -0x20(%ebp)
  801d97:	e8 fd 05 00 00       	call   802399 <pageref>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	89 3c 24             	mov    %edi,(%esp)
  801da1:	e8 f3 05 00 00       	call   802399 <pageref>
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	39 c3                	cmp    %eax,%ebx
  801dab:	0f 94 c1             	sete   %cl
  801dae:	0f b6 c9             	movzbl %cl,%ecx
  801db1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801db4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dba:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801dc0:	39 ce                	cmp    %ecx,%esi
  801dc2:	74 1e                	je     801de2 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801dc4:	39 c3                	cmp    %eax,%ebx
  801dc6:	75 be                	jne    801d86 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dc8:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801dce:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dd1:	50                   	push   %eax
  801dd2:	56                   	push   %esi
  801dd3:	68 b2 2c 80 00       	push   $0x802cb2
  801dd8:	e8 b7 e5 ff ff       	call   800394 <cprintf>
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	eb a4                	jmp    801d86 <_pipeisclosed+0xe>
	}
}
  801de2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    

00801ded <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	57                   	push   %edi
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	83 ec 28             	sub    $0x28,%esp
  801df6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801df9:	56                   	push   %esi
  801dfa:	e8 fa f6 ff ff       	call   8014f9 <fd2data>
  801dff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	bf 00 00 00 00       	mov    $0x0,%edi
  801e09:	eb 4b                	jmp    801e56 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e0b:	89 da                	mov    %ebx,%edx
  801e0d:	89 f0                	mov    %esi,%eax
  801e0f:	e8 64 ff ff ff       	call   801d78 <_pipeisclosed>
  801e14:	85 c0                	test   %eax,%eax
  801e16:	75 48                	jne    801e60 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e18:	e8 e0 ee ff ff       	call   800cfd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801e20:	8b 0b                	mov    (%ebx),%ecx
  801e22:	8d 51 20             	lea    0x20(%ecx),%edx
  801e25:	39 d0                	cmp    %edx,%eax
  801e27:	73 e2                	jae    801e0b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e2c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e30:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e33:	89 c2                	mov    %eax,%edx
  801e35:	c1 fa 1f             	sar    $0x1f,%edx
  801e38:	89 d1                	mov    %edx,%ecx
  801e3a:	c1 e9 1b             	shr    $0x1b,%ecx
  801e3d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e40:	83 e2 1f             	and    $0x1f,%edx
  801e43:	29 ca                	sub    %ecx,%edx
  801e45:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e4d:	83 c0 01             	add    $0x1,%eax
  801e50:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e53:	83 c7 01             	add    $0x1,%edi
  801e56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e59:	75 c2                	jne    801e1d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5e:	eb 05                	jmp    801e65 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e60:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5f                   	pop    %edi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    

00801e6d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	57                   	push   %edi
  801e71:	56                   	push   %esi
  801e72:	53                   	push   %ebx
  801e73:	83 ec 18             	sub    $0x18,%esp
  801e76:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e79:	57                   	push   %edi
  801e7a:	e8 7a f6 ff ff       	call   8014f9 <fd2data>
  801e7f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e81:	83 c4 10             	add    $0x10,%esp
  801e84:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e89:	eb 3d                	jmp    801ec8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	74 04                	je     801e93 <devpipe_read+0x26>
				return i;
  801e8f:	89 d8                	mov    %ebx,%eax
  801e91:	eb 44                	jmp    801ed7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e93:	89 f2                	mov    %esi,%edx
  801e95:	89 f8                	mov    %edi,%eax
  801e97:	e8 dc fe ff ff       	call   801d78 <_pipeisclosed>
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	75 32                	jne    801ed2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ea0:	e8 58 ee ff ff       	call   800cfd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ea5:	8b 06                	mov    (%esi),%eax
  801ea7:	3b 46 04             	cmp    0x4(%esi),%eax
  801eaa:	74 df                	je     801e8b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eac:	99                   	cltd   
  801ead:	c1 ea 1b             	shr    $0x1b,%edx
  801eb0:	01 d0                	add    %edx,%eax
  801eb2:	83 e0 1f             	and    $0x1f,%eax
  801eb5:	29 d0                	sub    %edx,%eax
  801eb7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ebc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ebf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ec2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec5:	83 c3 01             	add    $0x1,%ebx
  801ec8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ecb:	75 d8                	jne    801ea5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ecd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ed0:	eb 05                	jmp    801ed7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ed7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ee7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eea:	50                   	push   %eax
  801eeb:	e8 20 f6 ff ff       	call   801510 <fd_alloc>
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	89 c2                	mov    %eax,%edx
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	0f 88 2c 01 00 00    	js     802029 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efd:	83 ec 04             	sub    $0x4,%esp
  801f00:	68 07 04 00 00       	push   $0x407
  801f05:	ff 75 f4             	pushl  -0xc(%ebp)
  801f08:	6a 00                	push   $0x0
  801f0a:	e8 0d ee ff ff       	call   800d1c <sys_page_alloc>
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	89 c2                	mov    %eax,%edx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	0f 88 0d 01 00 00    	js     802029 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f1c:	83 ec 0c             	sub    $0xc,%esp
  801f1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f22:	50                   	push   %eax
  801f23:	e8 e8 f5 ff ff       	call   801510 <fd_alloc>
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	0f 88 e2 00 00 00    	js     802017 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f35:	83 ec 04             	sub    $0x4,%esp
  801f38:	68 07 04 00 00       	push   $0x407
  801f3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f40:	6a 00                	push   $0x0
  801f42:	e8 d5 ed ff ff       	call   800d1c <sys_page_alloc>
  801f47:	89 c3                	mov    %eax,%ebx
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	0f 88 c3 00 00 00    	js     802017 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f54:	83 ec 0c             	sub    $0xc,%esp
  801f57:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5a:	e8 9a f5 ff ff       	call   8014f9 <fd2data>
  801f5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f61:	83 c4 0c             	add    $0xc,%esp
  801f64:	68 07 04 00 00       	push   $0x407
  801f69:	50                   	push   %eax
  801f6a:	6a 00                	push   $0x0
  801f6c:	e8 ab ed ff ff       	call   800d1c <sys_page_alloc>
  801f71:	89 c3                	mov    %eax,%ebx
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	85 c0                	test   %eax,%eax
  801f78:	0f 88 89 00 00 00    	js     802007 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	ff 75 f0             	pushl  -0x10(%ebp)
  801f84:	e8 70 f5 ff ff       	call   8014f9 <fd2data>
  801f89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f90:	50                   	push   %eax
  801f91:	6a 00                	push   $0x0
  801f93:	56                   	push   %esi
  801f94:	6a 00                	push   $0x0
  801f96:	e8 c4 ed ff ff       	call   800d5f <sys_page_map>
  801f9b:	89 c3                	mov    %eax,%ebx
  801f9d:	83 c4 20             	add    $0x20,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 55                	js     801ff9 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fa4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fb9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd4:	e8 10 f5 ff ff       	call   8014e9 <fd2num>
  801fd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fdc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fde:	83 c4 04             	add    $0x4,%esp
  801fe1:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe4:	e8 00 f5 ff ff       	call   8014e9 <fd2num>
  801fe9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fec:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff7:	eb 30                	jmp    802029 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ff9:	83 ec 08             	sub    $0x8,%esp
  801ffc:	56                   	push   %esi
  801ffd:	6a 00                	push   $0x0
  801fff:	e8 9d ed ff ff       	call   800da1 <sys_page_unmap>
  802004:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802007:	83 ec 08             	sub    $0x8,%esp
  80200a:	ff 75 f0             	pushl  -0x10(%ebp)
  80200d:	6a 00                	push   $0x0
  80200f:	e8 8d ed ff ff       	call   800da1 <sys_page_unmap>
  802014:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802017:	83 ec 08             	sub    $0x8,%esp
  80201a:	ff 75 f4             	pushl  -0xc(%ebp)
  80201d:	6a 00                	push   $0x0
  80201f:	e8 7d ed ff ff       	call   800da1 <sys_page_unmap>
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802029:	89 d0                	mov    %edx,%eax
  80202b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202e:	5b                   	pop    %ebx
  80202f:	5e                   	pop    %esi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802038:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203b:	50                   	push   %eax
  80203c:	ff 75 08             	pushl  0x8(%ebp)
  80203f:	e8 1b f5 ff ff       	call   80155f <fd_lookup>
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	85 c0                	test   %eax,%eax
  802049:	78 18                	js     802063 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80204b:	83 ec 0c             	sub    $0xc,%esp
  80204e:	ff 75 f4             	pushl  -0xc(%ebp)
  802051:	e8 a3 f4 ff ff       	call   8014f9 <fd2data>
	return _pipeisclosed(fd, p);
  802056:	89 c2                	mov    %eax,%edx
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	e8 18 fd ff ff       	call   801d78 <_pipeisclosed>
  802060:	83 c4 10             	add    $0x10,%esp
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802068:	b8 00 00 00 00       	mov    $0x0,%eax
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    

0080206f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802075:	68 c5 2c 80 00       	push   $0x802cc5
  80207a:	ff 75 0c             	pushl  0xc(%ebp)
  80207d:	e8 97 e8 ff ff       	call   800919 <strcpy>
	return 0;
}
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	57                   	push   %edi
  80208d:	56                   	push   %esi
  80208e:	53                   	push   %ebx
  80208f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802095:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80209a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a0:	eb 2d                	jmp    8020cf <devcons_write+0x46>
		m = n - tot;
  8020a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020a5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020a7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020aa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020af:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	53                   	push   %ebx
  8020b6:	03 45 0c             	add    0xc(%ebp),%eax
  8020b9:	50                   	push   %eax
  8020ba:	57                   	push   %edi
  8020bb:	e8 eb e9 ff ff       	call   800aab <memmove>
		sys_cputs(buf, m);
  8020c0:	83 c4 08             	add    $0x8,%esp
  8020c3:	53                   	push   %ebx
  8020c4:	57                   	push   %edi
  8020c5:	e8 96 eb ff ff       	call   800c60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ca:	01 de                	add    %ebx,%esi
  8020cc:	83 c4 10             	add    $0x10,%esp
  8020cf:	89 f0                	mov    %esi,%eax
  8020d1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020d4:	72 cc                	jb     8020a2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d9:	5b                   	pop    %ebx
  8020da:	5e                   	pop    %esi
  8020db:	5f                   	pop    %edi
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	83 ec 08             	sub    $0x8,%esp
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020ed:	74 2a                	je     802119 <devcons_read+0x3b>
  8020ef:	eb 05                	jmp    8020f6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020f1:	e8 07 ec ff ff       	call   800cfd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020f6:	e8 83 eb ff ff       	call   800c7e <sys_cgetc>
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	74 f2                	je     8020f1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 16                	js     802119 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802103:	83 f8 04             	cmp    $0x4,%eax
  802106:	74 0c                	je     802114 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802108:	8b 55 0c             	mov    0xc(%ebp),%edx
  80210b:	88 02                	mov    %al,(%edx)
	return 1;
  80210d:	b8 01 00 00 00       	mov    $0x1,%eax
  802112:	eb 05                	jmp    802119 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802114:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802119:	c9                   	leave  
  80211a:	c3                   	ret    

0080211b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802121:	8b 45 08             	mov    0x8(%ebp),%eax
  802124:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802127:	6a 01                	push   $0x1
  802129:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80212c:	50                   	push   %eax
  80212d:	e8 2e eb ff ff       	call   800c60 <sys_cputs>
}
  802132:	83 c4 10             	add    $0x10,%esp
  802135:	c9                   	leave  
  802136:	c3                   	ret    

00802137 <getchar>:

int
getchar(void)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80213d:	6a 01                	push   $0x1
  80213f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802142:	50                   	push   %eax
  802143:	6a 00                	push   $0x0
  802145:	e8 7e f6 ff ff       	call   8017c8 <read>
	if (r < 0)
  80214a:	83 c4 10             	add    $0x10,%esp
  80214d:	85 c0                	test   %eax,%eax
  80214f:	78 0f                	js     802160 <getchar+0x29>
		return r;
	if (r < 1)
  802151:	85 c0                	test   %eax,%eax
  802153:	7e 06                	jle    80215b <getchar+0x24>
		return -E_EOF;
	return c;
  802155:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802159:	eb 05                	jmp    802160 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80215b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802160:	c9                   	leave  
  802161:	c3                   	ret    

00802162 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802168:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216b:	50                   	push   %eax
  80216c:	ff 75 08             	pushl  0x8(%ebp)
  80216f:	e8 eb f3 ff ff       	call   80155f <fd_lookup>
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	85 c0                	test   %eax,%eax
  802179:	78 11                	js     80218c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80217b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802184:	39 10                	cmp    %edx,(%eax)
  802186:	0f 94 c0             	sete   %al
  802189:	0f b6 c0             	movzbl %al,%eax
}
  80218c:	c9                   	leave  
  80218d:	c3                   	ret    

0080218e <opencons>:

int
opencons(void)
{
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802197:	50                   	push   %eax
  802198:	e8 73 f3 ff ff       	call   801510 <fd_alloc>
  80219d:	83 c4 10             	add    $0x10,%esp
		return r;
  8021a0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	78 3e                	js     8021e4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a6:	83 ec 04             	sub    $0x4,%esp
  8021a9:	68 07 04 00 00       	push   $0x407
  8021ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b1:	6a 00                	push   $0x0
  8021b3:	e8 64 eb ff ff       	call   800d1c <sys_page_alloc>
  8021b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8021bb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021bd:	85 c0                	test   %eax,%eax
  8021bf:	78 23                	js     8021e4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021c1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021d6:	83 ec 0c             	sub    $0xc,%esp
  8021d9:	50                   	push   %eax
  8021da:	e8 0a f3 ff ff       	call   8014e9 <fd2num>
  8021df:	89 c2                	mov    %eax,%edx
  8021e1:	83 c4 10             	add    $0x10,%esp
}
  8021e4:	89 d0                	mov    %edx,%eax
  8021e6:	c9                   	leave  
  8021e7:	c3                   	ret    

008021e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021ee:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021f5:	75 2a                	jne    802221 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8021f7:	83 ec 04             	sub    $0x4,%esp
  8021fa:	6a 07                	push   $0x7
  8021fc:	68 00 f0 bf ee       	push   $0xeebff000
  802201:	6a 00                	push   $0x0
  802203:	e8 14 eb ff ff       	call   800d1c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802208:	83 c4 10             	add    $0x10,%esp
  80220b:	85 c0                	test   %eax,%eax
  80220d:	79 12                	jns    802221 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80220f:	50                   	push   %eax
  802210:	68 58 2b 80 00       	push   $0x802b58
  802215:	6a 23                	push   $0x23
  802217:	68 d1 2c 80 00       	push   $0x802cd1
  80221c:	e8 9a e0 ff ff       	call   8002bb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802221:	8b 45 08             	mov    0x8(%ebp),%eax
  802224:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	68 53 22 80 00       	push   $0x802253
  802231:	6a 00                	push   $0x0
  802233:	e8 2f ec ff ff       	call   800e67 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802238:	83 c4 10             	add    $0x10,%esp
  80223b:	85 c0                	test   %eax,%eax
  80223d:	79 12                	jns    802251 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80223f:	50                   	push   %eax
  802240:	68 58 2b 80 00       	push   $0x802b58
  802245:	6a 2c                	push   $0x2c
  802247:	68 d1 2c 80 00       	push   $0x802cd1
  80224c:	e8 6a e0 ff ff       	call   8002bb <_panic>
	}
}
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802253:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802254:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802259:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80225b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80225e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802262:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802267:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80226b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80226d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802270:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802271:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802274:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802275:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802276:	c3                   	ret    

00802277 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	56                   	push   %esi
  80227b:	53                   	push   %ebx
  80227c:	8b 75 08             	mov    0x8(%ebp),%esi
  80227f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802282:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802285:	85 c0                	test   %eax,%eax
  802287:	75 12                	jne    80229b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802289:	83 ec 0c             	sub    $0xc,%esp
  80228c:	68 00 00 c0 ee       	push   $0xeec00000
  802291:	e8 36 ec ff ff       	call   800ecc <sys_ipc_recv>
  802296:	83 c4 10             	add    $0x10,%esp
  802299:	eb 0c                	jmp    8022a7 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80229b:	83 ec 0c             	sub    $0xc,%esp
  80229e:	50                   	push   %eax
  80229f:	e8 28 ec ff ff       	call   800ecc <sys_ipc_recv>
  8022a4:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8022a7:	85 f6                	test   %esi,%esi
  8022a9:	0f 95 c1             	setne  %cl
  8022ac:	85 db                	test   %ebx,%ebx
  8022ae:	0f 95 c2             	setne  %dl
  8022b1:	84 d1                	test   %dl,%cl
  8022b3:	74 09                	je     8022be <ipc_recv+0x47>
  8022b5:	89 c2                	mov    %eax,%edx
  8022b7:	c1 ea 1f             	shr    $0x1f,%edx
  8022ba:	84 d2                	test   %dl,%dl
  8022bc:	75 2d                	jne    8022eb <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8022be:	85 f6                	test   %esi,%esi
  8022c0:	74 0d                	je     8022cf <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8022c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8022c7:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8022cd:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8022cf:	85 db                	test   %ebx,%ebx
  8022d1:	74 0d                	je     8022e0 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8022d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8022d8:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8022de:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8022e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8022e5:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8022eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ee:	5b                   	pop    %ebx
  8022ef:	5e                   	pop    %esi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    

008022f2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	57                   	push   %edi
  8022f6:	56                   	push   %esi
  8022f7:	53                   	push   %ebx
  8022f8:	83 ec 0c             	sub    $0xc,%esp
  8022fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  802301:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802304:	85 db                	test   %ebx,%ebx
  802306:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80230b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80230e:	ff 75 14             	pushl  0x14(%ebp)
  802311:	53                   	push   %ebx
  802312:	56                   	push   %esi
  802313:	57                   	push   %edi
  802314:	e8 90 eb ff ff       	call   800ea9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802319:	89 c2                	mov    %eax,%edx
  80231b:	c1 ea 1f             	shr    $0x1f,%edx
  80231e:	83 c4 10             	add    $0x10,%esp
  802321:	84 d2                	test   %dl,%dl
  802323:	74 17                	je     80233c <ipc_send+0x4a>
  802325:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802328:	74 12                	je     80233c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80232a:	50                   	push   %eax
  80232b:	68 df 2c 80 00       	push   $0x802cdf
  802330:	6a 47                	push   $0x47
  802332:	68 ed 2c 80 00       	push   $0x802ced
  802337:	e8 7f df ff ff       	call   8002bb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80233c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80233f:	75 07                	jne    802348 <ipc_send+0x56>
			sys_yield();
  802341:	e8 b7 e9 ff ff       	call   800cfd <sys_yield>
  802346:	eb c6                	jmp    80230e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802348:	85 c0                	test   %eax,%eax
  80234a:	75 c2                	jne    80230e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80234c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5f                   	pop    %edi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    

00802354 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80235a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80235f:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802365:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80236b:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802371:	39 ca                	cmp    %ecx,%edx
  802373:	75 13                	jne    802388 <ipc_find_env+0x34>
			return envs[i].env_id;
  802375:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80237b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802380:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802386:	eb 0f                	jmp    802397 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802388:	83 c0 01             	add    $0x1,%eax
  80238b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802390:	75 cd                	jne    80235f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802392:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    

00802399 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802399:	55                   	push   %ebp
  80239a:	89 e5                	mov    %esp,%ebp
  80239c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	c1 e8 16             	shr    $0x16,%eax
  8023a4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023ab:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b0:	f6 c1 01             	test   $0x1,%cl
  8023b3:	74 1d                	je     8023d2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023b5:	c1 ea 0c             	shr    $0xc,%edx
  8023b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023bf:	f6 c2 01             	test   $0x1,%dl
  8023c2:	74 0e                	je     8023d2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c4:	c1 ea 0c             	shr    $0xc,%edx
  8023c7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023ce:	ef 
  8023cf:	0f b7 c0             	movzwl %ax,%eax
}
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    
  8023d4:	66 90                	xchg   %ax,%ax
  8023d6:	66 90                	xchg   %ax,%ax
  8023d8:	66 90                	xchg   %ax,%ax
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	66 90                	xchg   %ax,%ax
  8023de:	66 90                	xchg   %ax,%ax

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	53                   	push   %ebx
  8023e4:	83 ec 1c             	sub    $0x1c,%esp
  8023e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023f7:	85 f6                	test   %esi,%esi
  8023f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fd:	89 ca                	mov    %ecx,%edx
  8023ff:	89 f8                	mov    %edi,%eax
  802401:	75 3d                	jne    802440 <__udivdi3+0x60>
  802403:	39 cf                	cmp    %ecx,%edi
  802405:	0f 87 c5 00 00 00    	ja     8024d0 <__udivdi3+0xf0>
  80240b:	85 ff                	test   %edi,%edi
  80240d:	89 fd                	mov    %edi,%ebp
  80240f:	75 0b                	jne    80241c <__udivdi3+0x3c>
  802411:	b8 01 00 00 00       	mov    $0x1,%eax
  802416:	31 d2                	xor    %edx,%edx
  802418:	f7 f7                	div    %edi
  80241a:	89 c5                	mov    %eax,%ebp
  80241c:	89 c8                	mov    %ecx,%eax
  80241e:	31 d2                	xor    %edx,%edx
  802420:	f7 f5                	div    %ebp
  802422:	89 c1                	mov    %eax,%ecx
  802424:	89 d8                	mov    %ebx,%eax
  802426:	89 cf                	mov    %ecx,%edi
  802428:	f7 f5                	div    %ebp
  80242a:	89 c3                	mov    %eax,%ebx
  80242c:	89 d8                	mov    %ebx,%eax
  80242e:	89 fa                	mov    %edi,%edx
  802430:	83 c4 1c             	add    $0x1c,%esp
  802433:	5b                   	pop    %ebx
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
  802438:	90                   	nop
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	39 ce                	cmp    %ecx,%esi
  802442:	77 74                	ja     8024b8 <__udivdi3+0xd8>
  802444:	0f bd fe             	bsr    %esi,%edi
  802447:	83 f7 1f             	xor    $0x1f,%edi
  80244a:	0f 84 98 00 00 00    	je     8024e8 <__udivdi3+0x108>
  802450:	bb 20 00 00 00       	mov    $0x20,%ebx
  802455:	89 f9                	mov    %edi,%ecx
  802457:	89 c5                	mov    %eax,%ebp
  802459:	29 fb                	sub    %edi,%ebx
  80245b:	d3 e6                	shl    %cl,%esi
  80245d:	89 d9                	mov    %ebx,%ecx
  80245f:	d3 ed                	shr    %cl,%ebp
  802461:	89 f9                	mov    %edi,%ecx
  802463:	d3 e0                	shl    %cl,%eax
  802465:	09 ee                	or     %ebp,%esi
  802467:	89 d9                	mov    %ebx,%ecx
  802469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80246d:	89 d5                	mov    %edx,%ebp
  80246f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802473:	d3 ed                	shr    %cl,%ebp
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e2                	shl    %cl,%edx
  802479:	89 d9                	mov    %ebx,%ecx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	09 c2                	or     %eax,%edx
  80247f:	89 d0                	mov    %edx,%eax
  802481:	89 ea                	mov    %ebp,%edx
  802483:	f7 f6                	div    %esi
  802485:	89 d5                	mov    %edx,%ebp
  802487:	89 c3                	mov    %eax,%ebx
  802489:	f7 64 24 0c          	mull   0xc(%esp)
  80248d:	39 d5                	cmp    %edx,%ebp
  80248f:	72 10                	jb     8024a1 <__udivdi3+0xc1>
  802491:	8b 74 24 08          	mov    0x8(%esp),%esi
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e6                	shl    %cl,%esi
  802499:	39 c6                	cmp    %eax,%esi
  80249b:	73 07                	jae    8024a4 <__udivdi3+0xc4>
  80249d:	39 d5                	cmp    %edx,%ebp
  80249f:	75 03                	jne    8024a4 <__udivdi3+0xc4>
  8024a1:	83 eb 01             	sub    $0x1,%ebx
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 d8                	mov    %ebx,%eax
  8024a8:	89 fa                	mov    %edi,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	31 ff                	xor    %edi,%edi
  8024ba:	31 db                	xor    %ebx,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	89 d8                	mov    %ebx,%eax
  8024d2:	f7 f7                	div    %edi
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 c3                	mov    %eax,%ebx
  8024d8:	89 d8                	mov    %ebx,%eax
  8024da:	89 fa                	mov    %edi,%edx
  8024dc:	83 c4 1c             	add    $0x1c,%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5f                   	pop    %edi
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	39 ce                	cmp    %ecx,%esi
  8024ea:	72 0c                	jb     8024f8 <__udivdi3+0x118>
  8024ec:	31 db                	xor    %ebx,%ebx
  8024ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024f2:	0f 87 34 ff ff ff    	ja     80242c <__udivdi3+0x4c>
  8024f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024fd:	e9 2a ff ff ff       	jmp    80242c <__udivdi3+0x4c>
  802502:	66 90                	xchg   %ax,%ax
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80251b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80251f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802523:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802527:	85 d2                	test   %edx,%edx
  802529:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80252d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802531:	89 f3                	mov    %esi,%ebx
  802533:	89 3c 24             	mov    %edi,(%esp)
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	75 1c                	jne    802558 <__umoddi3+0x48>
  80253c:	39 f7                	cmp    %esi,%edi
  80253e:	76 50                	jbe    802590 <__umoddi3+0x80>
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	f7 f7                	div    %edi
  802546:	89 d0                	mov    %edx,%eax
  802548:	31 d2                	xor    %edx,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	39 f2                	cmp    %esi,%edx
  80255a:	89 d0                	mov    %edx,%eax
  80255c:	77 52                	ja     8025b0 <__umoddi3+0xa0>
  80255e:	0f bd ea             	bsr    %edx,%ebp
  802561:	83 f5 1f             	xor    $0x1f,%ebp
  802564:	75 5a                	jne    8025c0 <__umoddi3+0xb0>
  802566:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80256a:	0f 82 e0 00 00 00    	jb     802650 <__umoddi3+0x140>
  802570:	39 0c 24             	cmp    %ecx,(%esp)
  802573:	0f 86 d7 00 00 00    	jbe    802650 <__umoddi3+0x140>
  802579:	8b 44 24 08          	mov    0x8(%esp),%eax
  80257d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802581:	83 c4 1c             	add    $0x1c,%esp
  802584:	5b                   	pop    %ebx
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	85 ff                	test   %edi,%edi
  802592:	89 fd                	mov    %edi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f7                	div    %edi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	89 f0                	mov    %esi,%eax
  8025a3:	31 d2                	xor    %edx,%edx
  8025a5:	f7 f5                	div    %ebp
  8025a7:	89 c8                	mov    %ecx,%eax
  8025a9:	f7 f5                	div    %ebp
  8025ab:	89 d0                	mov    %edx,%eax
  8025ad:	eb 99                	jmp    802548 <__umoddi3+0x38>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	83 c4 1c             	add    $0x1c,%esp
  8025b7:	5b                   	pop    %ebx
  8025b8:	5e                   	pop    %esi
  8025b9:	5f                   	pop    %edi
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 34 24             	mov    (%esp),%esi
  8025c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ef                	sub    %ebp,%edi
  8025cc:	d3 e0                	shl    %cl,%eax
  8025ce:	89 f9                	mov    %edi,%ecx
  8025d0:	89 f2                	mov    %esi,%edx
  8025d2:	d3 ea                	shr    %cl,%edx
  8025d4:	89 e9                	mov    %ebp,%ecx
  8025d6:	09 c2                	or     %eax,%edx
  8025d8:	89 d8                	mov    %ebx,%eax
  8025da:	89 14 24             	mov    %edx,(%esp)
  8025dd:	89 f2                	mov    %esi,%edx
  8025df:	d3 e2                	shl    %cl,%edx
  8025e1:	89 f9                	mov    %edi,%ecx
  8025e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	89 c6                	mov    %eax,%esi
  8025f1:	d3 e3                	shl    %cl,%ebx
  8025f3:	89 f9                	mov    %edi,%ecx
  8025f5:	89 d0                	mov    %edx,%eax
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	89 e9                	mov    %ebp,%ecx
  8025fb:	09 d8                	or     %ebx,%eax
  8025fd:	89 d3                	mov    %edx,%ebx
  8025ff:	89 f2                	mov    %esi,%edx
  802601:	f7 34 24             	divl   (%esp)
  802604:	89 d6                	mov    %edx,%esi
  802606:	d3 e3                	shl    %cl,%ebx
  802608:	f7 64 24 04          	mull   0x4(%esp)
  80260c:	39 d6                	cmp    %edx,%esi
  80260e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802612:	89 d1                	mov    %edx,%ecx
  802614:	89 c3                	mov    %eax,%ebx
  802616:	72 08                	jb     802620 <__umoddi3+0x110>
  802618:	75 11                	jne    80262b <__umoddi3+0x11b>
  80261a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80261e:	73 0b                	jae    80262b <__umoddi3+0x11b>
  802620:	2b 44 24 04          	sub    0x4(%esp),%eax
  802624:	1b 14 24             	sbb    (%esp),%edx
  802627:	89 d1                	mov    %edx,%ecx
  802629:	89 c3                	mov    %eax,%ebx
  80262b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80262f:	29 da                	sub    %ebx,%edx
  802631:	19 ce                	sbb    %ecx,%esi
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 f0                	mov    %esi,%eax
  802637:	d3 e0                	shl    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	d3 ea                	shr    %cl,%edx
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	d3 ee                	shr    %cl,%esi
  802641:	09 d0                	or     %edx,%eax
  802643:	89 f2                	mov    %esi,%edx
  802645:	83 c4 1c             	add    $0x1c,%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
  802650:	29 f9                	sub    %edi,%ecx
  802652:	19 d6                	sbb    %edx,%esi
  802654:	89 74 24 04          	mov    %esi,0x4(%esp)
  802658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265c:	e9 18 ff ff ff       	jmp    802579 <__umoddi3+0x69>
