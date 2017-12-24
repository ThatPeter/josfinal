
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
  80004c:	e8 0b 15 00 00       	call   80155c <readn>
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
  800068:	68 40 23 80 00       	push   $0x802340
  80006d:	6a 15                	push   $0x15
  80006f:	68 6f 23 80 00       	push   $0x80236f
  800074:	e8 67 02 00 00       	call   8002e0 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 81 23 80 00       	push   $0x802381
  800084:	e8 30 03 00 00       	call   8003b9 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 3f 1b 00 00       	call   801bd0 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 85 23 80 00       	push   $0x802385
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 6f 23 80 00       	push   $0x80236f
  8000a8:	e8 33 02 00 00       	call   8002e0 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 56 0f 00 00       	call   801008 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 8e 23 80 00       	push   $0x80238e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 6f 23 80 00       	push   $0x80236f
  8000c3:	e8 18 02 00 00       	call   8002e0 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 ba 12 00 00       	call   80138f <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 af 12 00 00       	call   80138f <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 99 12 00 00       	call   80138f <close>
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
  800106:	e8 51 14 00 00       	call   80155c <readn>
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
  800126:	68 97 23 80 00       	push   $0x802397
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 6f 23 80 00       	push   $0x80236f
  800132:	e8 a9 01 00 00       	call   8002e0 <_panic>
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
  800149:	e8 57 14 00 00       	call   8015a5 <write>
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
  800168:	68 b3 23 80 00       	push   $0x8023b3
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 6f 23 80 00       	push   $0x80236f
  800174:	e8 67 01 00 00       	call   8002e0 <_panic>

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
  800180:	c7 05 00 30 80 00 cd 	movl   $0x8023cd,0x803000
  800187:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 3d 1a 00 00       	call   801bd0 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 85 23 80 00       	push   $0x802385
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 6f 23 80 00       	push   $0x80236f
  8001aa:	e8 31 01 00 00       	call   8002e0 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 54 0e 00 00       	call   801008 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 8e 23 80 00       	push   $0x80238e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 6f 23 80 00       	push   $0x80236f
  8001c5:	e8 16 01 00 00       	call   8002e0 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 b6 11 00 00       	call   80138f <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 a0 11 00 00       	call   80138f <close>

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
  800205:	e8 9b 13 00 00       	call   8015a5 <write>
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
  800221:	68 d8 23 80 00       	push   $0x8023d8
  800226:	6a 4a                	push   $0x4a
  800228:	68 6f 23 80 00       	push   $0x80236f
  80022d:	e8 ae 00 00 00       	call   8002e0 <_panic>
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
  80024b:	e8 b3 0a 00 00       	call   800d03 <sys_getenvid>
  800250:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800256:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80025b:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800260:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800265:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800268:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80026e:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800271:	39 c8                	cmp    %ecx,%eax
  800273:	0f 44 fb             	cmove  %ebx,%edi
  800276:	b9 01 00 00 00       	mov    $0x1,%ecx
  80027b:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80027e:	83 c2 01             	add    $0x1,%edx
  800281:	83 c3 7c             	add    $0x7c,%ebx
  800284:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80028a:	75 d9                	jne    800265 <libmain+0x2d>
  80028c:	89 f0                	mov    %esi,%eax
  80028e:	84 c0                	test   %al,%al
  800290:	74 06                	je     800298 <libmain+0x60>
  800292:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800298:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80029c:	7e 0a                	jle    8002a8 <libmain+0x70>
		binaryname = argv[0];
  80029e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a1:	8b 00                	mov    (%eax),%eax
  8002a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	ff 75 0c             	pushl  0xc(%ebp)
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	e8 c3 fe ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  8002b6:	e8 0b 00 00 00       	call   8002c6 <exit>
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002cc:	e8 e9 10 00 00       	call   8013ba <close_all>
	sys_env_destroy(0);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	6a 00                	push   $0x0
  8002d6:	e8 e7 09 00 00       	call   800cc2 <sys_env_destroy>
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002e5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002e8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002ee:	e8 10 0a 00 00       	call   800d03 <sys_getenvid>
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	ff 75 0c             	pushl  0xc(%ebp)
  8002f9:	ff 75 08             	pushl  0x8(%ebp)
  8002fc:	56                   	push   %esi
  8002fd:	50                   	push   %eax
  8002fe:	68 fc 23 80 00       	push   $0x8023fc
  800303:	e8 b1 00 00 00       	call   8003b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800308:	83 c4 18             	add    $0x18,%esp
  80030b:	53                   	push   %ebx
  80030c:	ff 75 10             	pushl  0x10(%ebp)
  80030f:	e8 54 00 00 00       	call   800368 <vcprintf>
	cprintf("\n");
  800314:	c7 04 24 83 23 80 00 	movl   $0x802383,(%esp)
  80031b:	e8 99 00 00 00       	call   8003b9 <cprintf>
  800320:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800323:	cc                   	int3   
  800324:	eb fd                	jmp    800323 <_panic+0x43>

00800326 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	53                   	push   %ebx
  80032a:	83 ec 04             	sub    $0x4,%esp
  80032d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800330:	8b 13                	mov    (%ebx),%edx
  800332:	8d 42 01             	lea    0x1(%edx),%eax
  800335:	89 03                	mov    %eax,(%ebx)
  800337:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80033e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800343:	75 1a                	jne    80035f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	68 ff 00 00 00       	push   $0xff
  80034d:	8d 43 08             	lea    0x8(%ebx),%eax
  800350:	50                   	push   %eax
  800351:	e8 2f 09 00 00       	call   800c85 <sys_cputs>
		b->idx = 0;
  800356:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80035c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80035f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800363:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800371:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800378:	00 00 00 
	b.cnt = 0;
  80037b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800382:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800385:	ff 75 0c             	pushl  0xc(%ebp)
  800388:	ff 75 08             	pushl  0x8(%ebp)
  80038b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800391:	50                   	push   %eax
  800392:	68 26 03 80 00       	push   $0x800326
  800397:	e8 54 01 00 00       	call   8004f0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039c:	83 c4 08             	add    $0x8,%esp
  80039f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 d4 08 00 00       	call   800c85 <sys_cputs>

	return b.cnt;
}
  8003b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003bf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c2:	50                   	push   %eax
  8003c3:	ff 75 08             	pushl  0x8(%ebp)
  8003c6:	e8 9d ff ff ff       	call   800368 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 1c             	sub    $0x1c,%esp
  8003d6:	89 c7                	mov    %eax,%edi
  8003d8:	89 d6                	mov    %edx,%esi
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003f1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003f4:	39 d3                	cmp    %edx,%ebx
  8003f6:	72 05                	jb     8003fd <printnum+0x30>
  8003f8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003fb:	77 45                	ja     800442 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003fd:	83 ec 0c             	sub    $0xc,%esp
  800400:	ff 75 18             	pushl  0x18(%ebp)
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800409:	53                   	push   %ebx
  80040a:	ff 75 10             	pushl  0x10(%ebp)
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	ff 75 e4             	pushl  -0x1c(%ebp)
  800413:	ff 75 e0             	pushl  -0x20(%ebp)
  800416:	ff 75 dc             	pushl  -0x24(%ebp)
  800419:	ff 75 d8             	pushl  -0x28(%ebp)
  80041c:	e8 8f 1c 00 00       	call   8020b0 <__udivdi3>
  800421:	83 c4 18             	add    $0x18,%esp
  800424:	52                   	push   %edx
  800425:	50                   	push   %eax
  800426:	89 f2                	mov    %esi,%edx
  800428:	89 f8                	mov    %edi,%eax
  80042a:	e8 9e ff ff ff       	call   8003cd <printnum>
  80042f:	83 c4 20             	add    $0x20,%esp
  800432:	eb 18                	jmp    80044c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	56                   	push   %esi
  800438:	ff 75 18             	pushl  0x18(%ebp)
  80043b:	ff d7                	call   *%edi
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	eb 03                	jmp    800445 <printnum+0x78>
  800442:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800445:	83 eb 01             	sub    $0x1,%ebx
  800448:	85 db                	test   %ebx,%ebx
  80044a:	7f e8                	jg     800434 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	56                   	push   %esi
  800450:	83 ec 04             	sub    $0x4,%esp
  800453:	ff 75 e4             	pushl  -0x1c(%ebp)
  800456:	ff 75 e0             	pushl  -0x20(%ebp)
  800459:	ff 75 dc             	pushl  -0x24(%ebp)
  80045c:	ff 75 d8             	pushl  -0x28(%ebp)
  80045f:	e8 7c 1d 00 00       	call   8021e0 <__umoddi3>
  800464:	83 c4 14             	add    $0x14,%esp
  800467:	0f be 80 1f 24 80 00 	movsbl 0x80241f(%eax),%eax
  80046e:	50                   	push   %eax
  80046f:	ff d7                	call   *%edi
}
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800477:	5b                   	pop    %ebx
  800478:	5e                   	pop    %esi
  800479:	5f                   	pop    %edi
  80047a:	5d                   	pop    %ebp
  80047b:	c3                   	ret    

0080047c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047f:	83 fa 01             	cmp    $0x1,%edx
  800482:	7e 0e                	jle    800492 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 08             	lea    0x8(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	8b 52 04             	mov    0x4(%edx),%edx
  800490:	eb 22                	jmp    8004b4 <getuint+0x38>
	else if (lflag)
  800492:	85 d2                	test   %edx,%edx
  800494:	74 10                	je     8004a6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800496:	8b 10                	mov    (%eax),%edx
  800498:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049b:	89 08                	mov    %ecx,(%eax)
  80049d:	8b 02                	mov    (%edx),%eax
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 0e                	jmp    8004b4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a6:	8b 10                	mov    (%eax),%edx
  8004a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ab:	89 08                	mov    %ecx,(%eax)
  8004ad:	8b 02                	mov    (%edx),%eax
  8004af:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c5:	73 0a                	jae    8004d1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ca:	89 08                	mov    %ecx,(%eax)
  8004cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cf:	88 02                	mov    %al,(%edx)
}
  8004d1:	5d                   	pop    %ebp
  8004d2:	c3                   	ret    

008004d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004dc:	50                   	push   %eax
  8004dd:	ff 75 10             	pushl  0x10(%ebp)
  8004e0:	ff 75 0c             	pushl  0xc(%ebp)
  8004e3:	ff 75 08             	pushl  0x8(%ebp)
  8004e6:	e8 05 00 00 00       	call   8004f0 <vprintfmt>
	va_end(ap);
}
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	57                   	push   %edi
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 2c             	sub    $0x2c,%esp
  8004f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ff:	8b 7d 10             	mov    0x10(%ebp),%edi
  800502:	eb 12                	jmp    800516 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800504:	85 c0                	test   %eax,%eax
  800506:	0f 84 89 03 00 00    	je     800895 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	50                   	push   %eax
  800511:	ff d6                	call   *%esi
  800513:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051d:	83 f8 25             	cmp    $0x25,%eax
  800520:	75 e2                	jne    800504 <vprintfmt+0x14>
  800522:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800526:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80052d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800534:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80053b:	ba 00 00 00 00       	mov    $0x0,%edx
  800540:	eb 07                	jmp    800549 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800545:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8d 47 01             	lea    0x1(%edi),%eax
  80054c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054f:	0f b6 07             	movzbl (%edi),%eax
  800552:	0f b6 c8             	movzbl %al,%ecx
  800555:	83 e8 23             	sub    $0x23,%eax
  800558:	3c 55                	cmp    $0x55,%al
  80055a:	0f 87 1a 03 00 00    	ja     80087a <vprintfmt+0x38a>
  800560:	0f b6 c0             	movzbl %al,%eax
  800563:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80056d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800571:	eb d6                	jmp    800549 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800576:	b8 00 00 00 00       	mov    $0x0,%eax
  80057b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800581:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800585:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800588:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80058b:	83 fa 09             	cmp    $0x9,%edx
  80058e:	77 39                	ja     8005c9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800590:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800593:	eb e9                	jmp    80057e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 48 04             	lea    0x4(%eax),%ecx
  80059b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a6:	eb 27                	jmp    8005cf <vprintfmt+0xdf>
  8005a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b2:	0f 49 c8             	cmovns %eax,%ecx
  8005b5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	eb 8c                	jmp    800549 <vprintfmt+0x59>
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c7:	eb 80                	jmp    800549 <vprintfmt+0x59>
  8005c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005cc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d3:	0f 89 70 ff ff ff    	jns    800549 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e6:	e9 5e ff ff ff       	jmp    800549 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005eb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f1:	e9 53 ff ff ff       	jmp    800549 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 04             	lea    0x4(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	ff 30                	pushl  (%eax)
  800605:	ff d6                	call   *%esi
			break;
  800607:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060d:	e9 04 ff ff ff       	jmp    800516 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	99                   	cltd   
  80061e:	31 d0                	xor    %edx,%eax
  800620:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800622:	83 f8 0f             	cmp    $0xf,%eax
  800625:	7f 0b                	jg     800632 <vprintfmt+0x142>
  800627:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80062e:	85 d2                	test   %edx,%edx
  800630:	75 18                	jne    80064a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800632:	50                   	push   %eax
  800633:	68 37 24 80 00       	push   $0x802437
  800638:	53                   	push   %ebx
  800639:	56                   	push   %esi
  80063a:	e8 94 fe ff ff       	call   8004d3 <printfmt>
  80063f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800645:	e9 cc fe ff ff       	jmp    800516 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80064a:	52                   	push   %edx
  80064b:	68 61 28 80 00       	push   $0x802861
  800650:	53                   	push   %ebx
  800651:	56                   	push   %esi
  800652:	e8 7c fe ff ff       	call   8004d3 <printfmt>
  800657:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065d:	e9 b4 fe ff ff       	jmp    800516 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80066d:	85 ff                	test   %edi,%edi
  80066f:	b8 30 24 80 00       	mov    $0x802430,%eax
  800674:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800677:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067b:	0f 8e 94 00 00 00    	jle    800715 <vprintfmt+0x225>
  800681:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800685:	0f 84 98 00 00 00    	je     800723 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	ff 75 d0             	pushl  -0x30(%ebp)
  800691:	57                   	push   %edi
  800692:	e8 86 02 00 00       	call   80091d <strnlen>
  800697:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069a:	29 c1                	sub    %eax,%ecx
  80069c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80069f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ac:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ae:	eb 0f                	jmp    8006bf <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b9:	83 ef 01             	sub    $0x1,%edi
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	85 ff                	test   %edi,%edi
  8006c1:	7f ed                	jg     8006b0 <vprintfmt+0x1c0>
  8006c3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006c6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d0:	0f 49 c1             	cmovns %ecx,%eax
  8006d3:	29 c1                	sub    %eax,%ecx
  8006d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006de:	89 cb                	mov    %ecx,%ebx
  8006e0:	eb 4d                	jmp    80072f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e6:	74 1b                	je     800703 <vprintfmt+0x213>
  8006e8:	0f be c0             	movsbl %al,%eax
  8006eb:	83 e8 20             	sub    $0x20,%eax
  8006ee:	83 f8 5e             	cmp    $0x5e,%eax
  8006f1:	76 10                	jbe    800703 <vprintfmt+0x213>
					putch('?', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	6a 3f                	push   $0x3f
  8006fb:	ff 55 08             	call   *0x8(%ebp)
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 0d                	jmp    800710 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	52                   	push   %edx
  80070a:	ff 55 08             	call   *0x8(%ebp)
  80070d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800710:	83 eb 01             	sub    $0x1,%ebx
  800713:	eb 1a                	jmp    80072f <vprintfmt+0x23f>
  800715:	89 75 08             	mov    %esi,0x8(%ebp)
  800718:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800721:	eb 0c                	jmp    80072f <vprintfmt+0x23f>
  800723:	89 75 08             	mov    %esi,0x8(%ebp)
  800726:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800729:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072f:	83 c7 01             	add    $0x1,%edi
  800732:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800736:	0f be d0             	movsbl %al,%edx
  800739:	85 d2                	test   %edx,%edx
  80073b:	74 23                	je     800760 <vprintfmt+0x270>
  80073d:	85 f6                	test   %esi,%esi
  80073f:	78 a1                	js     8006e2 <vprintfmt+0x1f2>
  800741:	83 ee 01             	sub    $0x1,%esi
  800744:	79 9c                	jns    8006e2 <vprintfmt+0x1f2>
  800746:	89 df                	mov    %ebx,%edi
  800748:	8b 75 08             	mov    0x8(%ebp),%esi
  80074b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074e:	eb 18                	jmp    800768 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	6a 20                	push   $0x20
  800756:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800758:	83 ef 01             	sub    $0x1,%edi
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 08                	jmp    800768 <vprintfmt+0x278>
  800760:	89 df                	mov    %ebx,%edi
  800762:	8b 75 08             	mov    0x8(%ebp),%esi
  800765:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800768:	85 ff                	test   %edi,%edi
  80076a:	7f e4                	jg     800750 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076f:	e9 a2 fd ff ff       	jmp    800516 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800774:	83 fa 01             	cmp    $0x1,%edx
  800777:	7e 16                	jle    80078f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 50 08             	lea    0x8(%eax),%edx
  80077f:	89 55 14             	mov    %edx,0x14(%ebp)
  800782:	8b 50 04             	mov    0x4(%eax),%edx
  800785:	8b 00                	mov    (%eax),%eax
  800787:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80078d:	eb 32                	jmp    8007c1 <vprintfmt+0x2d1>
	else if (lflag)
  80078f:	85 d2                	test   %edx,%edx
  800791:	74 18                	je     8007ab <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 50 04             	lea    0x4(%eax),%edx
  800799:	89 55 14             	mov    %edx,0x14(%ebp)
  80079c:	8b 00                	mov    (%eax),%eax
  80079e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a1:	89 c1                	mov    %eax,%ecx
  8007a3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a9:	eb 16                	jmp    8007c1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 04             	lea    0x4(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b9:	89 c1                	mov    %eax,%ecx
  8007bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d0:	79 74                	jns    800846 <vprintfmt+0x356>
				putch('-', putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	6a 2d                	push   $0x2d
  8007d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8007da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e0:	f7 d8                	neg    %eax
  8007e2:	83 d2 00             	adc    $0x0,%edx
  8007e5:	f7 da                	neg    %edx
  8007e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ef:	eb 55                	jmp    800846 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 83 fc ff ff       	call   80047c <getuint>
			base = 10;
  8007f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007fe:	eb 46                	jmp    800846 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
  800803:	e8 74 fc ff ff       	call   80047c <getuint>
			base = 8;
  800808:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80080d:	eb 37                	jmp    800846 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	53                   	push   %ebx
  800813:	6a 30                	push   $0x30
  800815:	ff d6                	call   *%esi
			putch('x', putdat);
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	53                   	push   %ebx
  80081b:	6a 78                	push   $0x78
  80081d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800828:	8b 00                	mov    (%eax),%eax
  80082a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80082f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800832:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800837:	eb 0d                	jmp    800846 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
  80083c:	e8 3b fc ff ff       	call   80047c <getuint>
			base = 16;
  800841:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800846:	83 ec 0c             	sub    $0xc,%esp
  800849:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80084d:	57                   	push   %edi
  80084e:	ff 75 e0             	pushl  -0x20(%ebp)
  800851:	51                   	push   %ecx
  800852:	52                   	push   %edx
  800853:	50                   	push   %eax
  800854:	89 da                	mov    %ebx,%edx
  800856:	89 f0                	mov    %esi,%eax
  800858:	e8 70 fb ff ff       	call   8003cd <printnum>
			break;
  80085d:	83 c4 20             	add    $0x20,%esp
  800860:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800863:	e9 ae fc ff ff       	jmp    800516 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	51                   	push   %ecx
  80086d:	ff d6                	call   *%esi
			break;
  80086f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800875:	e9 9c fc ff ff       	jmp    800516 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	6a 25                	push   $0x25
  800880:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	eb 03                	jmp    80088a <vprintfmt+0x39a>
  800887:	83 ef 01             	sub    $0x1,%edi
  80088a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80088e:	75 f7                	jne    800887 <vprintfmt+0x397>
  800890:	e9 81 fc ff ff       	jmp    800516 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800895:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5f                   	pop    %edi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	83 ec 18             	sub    $0x18,%esp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	74 26                	je     8008e4 <vsnprintf+0x47>
  8008be:	85 d2                	test   %edx,%edx
  8008c0:	7e 22                	jle    8008e4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c2:	ff 75 14             	pushl  0x14(%ebp)
  8008c5:	ff 75 10             	pushl  0x10(%ebp)
  8008c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cb:	50                   	push   %eax
  8008cc:	68 b6 04 80 00       	push   $0x8004b6
  8008d1:	e8 1a fc ff ff       	call   8004f0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	eb 05                	jmp    8008e9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f4:	50                   	push   %eax
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 9a ff ff ff       	call   80089d <vsnprintf>
	va_end(ap);

	return rc;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb 03                	jmp    800915 <strlen+0x10>
		n++;
  800912:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800915:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800919:	75 f7                	jne    800912 <strlen+0xd>
		n++;
	return n;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
  80092b:	eb 03                	jmp    800930 <strnlen+0x13>
		n++;
  80092d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800930:	39 c2                	cmp    %eax,%edx
  800932:	74 08                	je     80093c <strnlen+0x1f>
  800934:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800938:	75 f3                	jne    80092d <strnlen+0x10>
  80093a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800948:	89 c2                	mov    %eax,%edx
  80094a:	83 c2 01             	add    $0x1,%edx
  80094d:	83 c1 01             	add    $0x1,%ecx
  800950:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800954:	88 5a ff             	mov    %bl,-0x1(%edx)
  800957:	84 db                	test   %bl,%bl
  800959:	75 ef                	jne    80094a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	53                   	push   %ebx
  800962:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800965:	53                   	push   %ebx
  800966:	e8 9a ff ff ff       	call   800905 <strlen>
  80096b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096e:	ff 75 0c             	pushl  0xc(%ebp)
  800971:	01 d8                	add    %ebx,%eax
  800973:	50                   	push   %eax
  800974:	e8 c5 ff ff ff       	call   80093e <strcpy>
	return dst;
}
  800979:	89 d8                	mov    %ebx,%eax
  80097b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 75 08             	mov    0x8(%ebp),%esi
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098b:	89 f3                	mov    %esi,%ebx
  80098d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800990:	89 f2                	mov    %esi,%edx
  800992:	eb 0f                	jmp    8009a3 <strncpy+0x23>
		*dst++ = *src;
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099d:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a3:	39 da                	cmp    %ebx,%edx
  8009a5:	75 ed                	jne    800994 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a7:	89 f0                	mov    %esi,%eax
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b8:	8b 55 10             	mov    0x10(%ebp),%edx
  8009bb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bd:	85 d2                	test   %edx,%edx
  8009bf:	74 21                	je     8009e2 <strlcpy+0x35>
  8009c1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c5:	89 f2                	mov    %esi,%edx
  8009c7:	eb 09                	jmp    8009d2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c9:	83 c2 01             	add    $0x1,%edx
  8009cc:	83 c1 01             	add    $0x1,%ecx
  8009cf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d2:	39 c2                	cmp    %eax,%edx
  8009d4:	74 09                	je     8009df <strlcpy+0x32>
  8009d6:	0f b6 19             	movzbl (%ecx),%ebx
  8009d9:	84 db                	test   %bl,%bl
  8009db:	75 ec                	jne    8009c9 <strlcpy+0x1c>
  8009dd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009df:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e2:	29 f0                	sub    %esi,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f1:	eb 06                	jmp    8009f9 <strcmp+0x11>
		p++, q++;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	84 c0                	test   %al,%al
  8009fe:	74 04                	je     800a04 <strcmp+0x1c>
  800a00:	3a 02                	cmp    (%edx),%al
  800a02:	74 ef                	je     8009f3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a04:	0f b6 c0             	movzbl %al,%eax
  800a07:	0f b6 12             	movzbl (%edx),%edx
  800a0a:	29 d0                	sub    %edx,%eax
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a18:	89 c3                	mov    %eax,%ebx
  800a1a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1d:	eb 06                	jmp    800a25 <strncmp+0x17>
		n--, p++, q++;
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a25:	39 d8                	cmp    %ebx,%eax
  800a27:	74 15                	je     800a3e <strncmp+0x30>
  800a29:	0f b6 08             	movzbl (%eax),%ecx
  800a2c:	84 c9                	test   %cl,%cl
  800a2e:	74 04                	je     800a34 <strncmp+0x26>
  800a30:	3a 0a                	cmp    (%edx),%cl
  800a32:	74 eb                	je     800a1f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a34:	0f b6 00             	movzbl (%eax),%eax
  800a37:	0f b6 12             	movzbl (%edx),%edx
  800a3a:	29 d0                	sub    %edx,%eax
  800a3c:	eb 05                	jmp    800a43 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a50:	eb 07                	jmp    800a59 <strchr+0x13>
		if (*s == c)
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	74 0f                	je     800a65 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	0f b6 10             	movzbl (%eax),%edx
  800a5c:	84 d2                	test   %dl,%dl
  800a5e:	75 f2                	jne    800a52 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a71:	eb 03                	jmp    800a76 <strfind+0xf>
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a79:	38 ca                	cmp    %cl,%dl
  800a7b:	74 04                	je     800a81 <strfind+0x1a>
  800a7d:	84 d2                	test   %dl,%dl
  800a7f:	75 f2                	jne    800a73 <strfind+0xc>
			break;
	return (char *) s;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8f:	85 c9                	test   %ecx,%ecx
  800a91:	74 36                	je     800ac9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a93:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a99:	75 28                	jne    800ac3 <memset+0x40>
  800a9b:	f6 c1 03             	test   $0x3,%cl
  800a9e:	75 23                	jne    800ac3 <memset+0x40>
		c &= 0xFF;
  800aa0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	c1 e3 08             	shl    $0x8,%ebx
  800aa9:	89 d6                	mov    %edx,%esi
  800aab:	c1 e6 18             	shl    $0x18,%esi
  800aae:	89 d0                	mov    %edx,%eax
  800ab0:	c1 e0 10             	shl    $0x10,%eax
  800ab3:	09 f0                	or     %esi,%eax
  800ab5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ab7:	89 d8                	mov    %ebx,%eax
  800ab9:	09 d0                	or     %edx,%eax
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fc                   	cld    
  800abf:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac1:	eb 06                	jmp    800ac9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	fc                   	cld    
  800ac7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac9:	89 f8                	mov    %edi,%eax
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ade:	39 c6                	cmp    %eax,%esi
  800ae0:	73 35                	jae    800b17 <memmove+0x47>
  800ae2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae5:	39 d0                	cmp    %edx,%eax
  800ae7:	73 2e                	jae    800b17 <memmove+0x47>
		s += n;
		d += n;
  800ae9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	89 d6                	mov    %edx,%esi
  800aee:	09 fe                	or     %edi,%esi
  800af0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af6:	75 13                	jne    800b0b <memmove+0x3b>
  800af8:	f6 c1 03             	test   $0x3,%cl
  800afb:	75 0e                	jne    800b0b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800afd:	83 ef 04             	sub    $0x4,%edi
  800b00:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b03:	c1 e9 02             	shr    $0x2,%ecx
  800b06:	fd                   	std    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 09                	jmp    800b14 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0b:	83 ef 01             	sub    $0x1,%edi
  800b0e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b11:	fd                   	std    
  800b12:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b14:	fc                   	cld    
  800b15:	eb 1d                	jmp    800b34 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	89 f2                	mov    %esi,%edx
  800b19:	09 c2                	or     %eax,%edx
  800b1b:	f6 c2 03             	test   $0x3,%dl
  800b1e:	75 0f                	jne    800b2f <memmove+0x5f>
  800b20:	f6 c1 03             	test   $0x3,%cl
  800b23:	75 0a                	jne    800b2f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b25:	c1 e9 02             	shr    $0x2,%ecx
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	fc                   	cld    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb 05                	jmp    800b34 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2f:	89 c7                	mov    %eax,%edi
  800b31:	fc                   	cld    
  800b32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3b:	ff 75 10             	pushl  0x10(%ebp)
  800b3e:	ff 75 0c             	pushl  0xc(%ebp)
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	e8 87 ff ff ff       	call   800ad0 <memmove>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5b:	eb 1a                	jmp    800b77 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5d:	0f b6 08             	movzbl (%eax),%ecx
  800b60:	0f b6 1a             	movzbl (%edx),%ebx
  800b63:	38 d9                	cmp    %bl,%cl
  800b65:	74 0a                	je     800b71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b67:	0f b6 c1             	movzbl %cl,%eax
  800b6a:	0f b6 db             	movzbl %bl,%ebx
  800b6d:	29 d8                	sub    %ebx,%eax
  800b6f:	eb 0f                	jmp    800b80 <memcmp+0x35>
		s1++, s2++;
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b77:	39 f0                	cmp    %esi,%eax
  800b79:	75 e2                	jne    800b5d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	53                   	push   %ebx
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b8b:	89 c1                	mov    %eax,%ecx
  800b8d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b90:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b94:	eb 0a                	jmp    800ba0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	0f b6 10             	movzbl (%eax),%edx
  800b99:	39 da                	cmp    %ebx,%edx
  800b9b:	74 07                	je     800ba4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9d:	83 c0 01             	add    $0x1,%eax
  800ba0:	39 c8                	cmp    %ecx,%eax
  800ba2:	72 f2                	jb     800b96 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb3:	eb 03                	jmp    800bb8 <strtol+0x11>
		s++;
  800bb5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	0f b6 01             	movzbl (%ecx),%eax
  800bbb:	3c 20                	cmp    $0x20,%al
  800bbd:	74 f6                	je     800bb5 <strtol+0xe>
  800bbf:	3c 09                	cmp    $0x9,%al
  800bc1:	74 f2                	je     800bb5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc3:	3c 2b                	cmp    $0x2b,%al
  800bc5:	75 0a                	jne    800bd1 <strtol+0x2a>
		s++;
  800bc7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bca:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcf:	eb 11                	jmp    800be2 <strtol+0x3b>
  800bd1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd6:	3c 2d                	cmp    $0x2d,%al
  800bd8:	75 08                	jne    800be2 <strtol+0x3b>
		s++, neg = 1;
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800be8:	75 15                	jne    800bff <strtol+0x58>
  800bea:	80 39 30             	cmpb   $0x30,(%ecx)
  800bed:	75 10                	jne    800bff <strtol+0x58>
  800bef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf3:	75 7c                	jne    800c71 <strtol+0xca>
		s += 2, base = 16;
  800bf5:	83 c1 02             	add    $0x2,%ecx
  800bf8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfd:	eb 16                	jmp    800c15 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bff:	85 db                	test   %ebx,%ebx
  800c01:	75 12                	jne    800c15 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c03:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c08:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0b:	75 08                	jne    800c15 <strtol+0x6e>
		s++, base = 8;
  800c0d:	83 c1 01             	add    $0x1,%ecx
  800c10:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c15:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1d:	0f b6 11             	movzbl (%ecx),%edx
  800c20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c23:	89 f3                	mov    %esi,%ebx
  800c25:	80 fb 09             	cmp    $0x9,%bl
  800c28:	77 08                	ja     800c32 <strtol+0x8b>
			dig = *s - '0';
  800c2a:	0f be d2             	movsbl %dl,%edx
  800c2d:	83 ea 30             	sub    $0x30,%edx
  800c30:	eb 22                	jmp    800c54 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c35:	89 f3                	mov    %esi,%ebx
  800c37:	80 fb 19             	cmp    $0x19,%bl
  800c3a:	77 08                	ja     800c44 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c3c:	0f be d2             	movsbl %dl,%edx
  800c3f:	83 ea 57             	sub    $0x57,%edx
  800c42:	eb 10                	jmp    800c54 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c44:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c47:	89 f3                	mov    %esi,%ebx
  800c49:	80 fb 19             	cmp    $0x19,%bl
  800c4c:	77 16                	ja     800c64 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c4e:	0f be d2             	movsbl %dl,%edx
  800c51:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c54:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c57:	7d 0b                	jge    800c64 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c60:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c62:	eb b9                	jmp    800c1d <strtol+0x76>

	if (endptr)
  800c64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c68:	74 0d                	je     800c77 <strtol+0xd0>
		*endptr = (char *) s;
  800c6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6d:	89 0e                	mov    %ecx,(%esi)
  800c6f:	eb 06                	jmp    800c77 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c71:	85 db                	test   %ebx,%ebx
  800c73:	74 98                	je     800c0d <strtol+0x66>
  800c75:	eb 9e                	jmp    800c15 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c77:	89 c2                	mov    %eax,%edx
  800c79:	f7 da                	neg    %edx
  800c7b:	85 ff                	test   %edi,%edi
  800c7d:	0f 45 c2             	cmovne %edx,%eax
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 c3                	mov    %eax,%ebx
  800c98:	89 c7                	mov    %eax,%edi
  800c9a:	89 c6                	mov    %eax,%esi
  800c9c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd0:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 cb                	mov    %ecx,%ebx
  800cda:	89 cf                	mov    %ecx,%edi
  800cdc:	89 ce                	mov    %ecx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 03                	push   $0x3
  800cea:	68 1f 27 80 00       	push   $0x80271f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 3c 27 80 00       	push   $0x80273c
  800cf6:	e8 e5 f5 ff ff       	call   8002e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	89 d3                	mov    %edx,%ebx
  800d17:	89 d7                	mov    %edx,%edi
  800d19:	89 d6                	mov    %edx,%esi
  800d1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_yield>:

void
sys_yield(void)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	be 00 00 00 00       	mov    $0x0,%esi
  800d4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5d:	89 f7                	mov    %esi,%edi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 04                	push   $0x4
  800d6b:	68 1f 27 80 00       	push   $0x80271f
  800d70:	6a 23                	push   $0x23
  800d72:	68 3c 27 80 00       	push   $0x80273c
  800d77:	e8 64 f5 ff ff       	call   8002e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	8b 75 18             	mov    0x18(%ebp),%esi
  800da1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 05                	push   $0x5
  800dad:	68 1f 27 80 00       	push   $0x80271f
  800db2:	6a 23                	push   $0x23
  800db4:	68 3c 27 80 00       	push   $0x80273c
  800db9:	e8 22 f5 ff ff       	call   8002e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 df                	mov    %ebx,%edi
  800de1:	89 de                	mov    %ebx,%esi
  800de3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7e 17                	jle    800e00 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	50                   	push   %eax
  800ded:	6a 06                	push   $0x6
  800def:	68 1f 27 80 00       	push   $0x80271f
  800df4:	6a 23                	push   $0x23
  800df6:	68 3c 27 80 00       	push   $0x80273c
  800dfb:	e8 e0 f4 ff ff       	call   8002e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e16:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 df                	mov    %ebx,%edi
  800e23:	89 de                	mov    %ebx,%esi
  800e25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7e 17                	jle    800e42 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	50                   	push   %eax
  800e2f:	6a 08                	push   $0x8
  800e31:	68 1f 27 80 00       	push   $0x80271f
  800e36:	6a 23                	push   $0x23
  800e38:	68 3c 27 80 00       	push   $0x80273c
  800e3d:	e8 9e f4 ff ff       	call   8002e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	7e 17                	jle    800e84 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	50                   	push   %eax
  800e71:	6a 09                	push   $0x9
  800e73:	68 1f 27 80 00       	push   $0x80271f
  800e78:	6a 23                	push   $0x23
  800e7a:	68 3c 27 80 00       	push   $0x80273c
  800e7f:	e8 5c f4 ff ff       	call   8002e0 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
  800e92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	89 df                	mov    %ebx,%edi
  800ea7:	89 de                	mov    %ebx,%esi
  800ea9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eab:	85 c0                	test   %eax,%eax
  800ead:	7e 17                	jle    800ec6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	50                   	push   %eax
  800eb3:	6a 0a                	push   $0xa
  800eb5:	68 1f 27 80 00       	push   $0x80271f
  800eba:	6a 23                	push   $0x23
  800ebc:	68 3c 27 80 00       	push   $0x80273c
  800ec1:	e8 1a f4 ff ff       	call   8002e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	be 00 00 00 00       	mov    $0x0,%esi
  800ed9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	89 cb                	mov    %ecx,%ebx
  800f09:	89 cf                	mov    %ecx,%edi
  800f0b:	89 ce                	mov    %ecx,%esi
  800f0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	7e 17                	jle    800f2a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	50                   	push   %eax
  800f17:	6a 0d                	push   $0xd
  800f19:	68 1f 27 80 00       	push   $0x80271f
  800f1e:	6a 23                	push   $0x23
  800f20:	68 3c 27 80 00       	push   $0x80273c
  800f25:	e8 b6 f3 ff ff       	call   8002e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	53                   	push   %ebx
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f3e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f42:	74 11                	je     800f55 <pgfault+0x23>
  800f44:	89 d8                	mov    %ebx,%eax
  800f46:	c1 e8 0c             	shr    $0xc,%eax
  800f49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f50:	f6 c4 08             	test   $0x8,%ah
  800f53:	75 14                	jne    800f69 <pgfault+0x37>
		panic("faulting access");
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	68 4a 27 80 00       	push   $0x80274a
  800f5d:	6a 1d                	push   $0x1d
  800f5f:	68 5a 27 80 00       	push   $0x80275a
  800f64:	e8 77 f3 ff ff       	call   8002e0 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	6a 07                	push   $0x7
  800f6e:	68 00 f0 7f 00       	push   $0x7ff000
  800f73:	6a 00                	push   $0x0
  800f75:	e8 c7 fd ff ff       	call   800d41 <sys_page_alloc>
	if (r < 0) {
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 12                	jns    800f93 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f81:	50                   	push   %eax
  800f82:	68 65 27 80 00       	push   $0x802765
  800f87:	6a 2b                	push   $0x2b
  800f89:	68 5a 27 80 00       	push   $0x80275a
  800f8e:	e8 4d f3 ff ff       	call   8002e0 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f93:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 00 10 00 00       	push   $0x1000
  800fa1:	53                   	push   %ebx
  800fa2:	68 00 f0 7f 00       	push   $0x7ff000
  800fa7:	e8 8c fb ff ff       	call   800b38 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800fac:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fb3:	53                   	push   %ebx
  800fb4:	6a 00                	push   $0x0
  800fb6:	68 00 f0 7f 00       	push   $0x7ff000
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 c2 fd ff ff       	call   800d84 <sys_page_map>
	if (r < 0) {
  800fc2:	83 c4 20             	add    $0x20,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	79 12                	jns    800fdb <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800fc9:	50                   	push   %eax
  800fca:	68 65 27 80 00       	push   $0x802765
  800fcf:	6a 32                	push   $0x32
  800fd1:	68 5a 27 80 00       	push   $0x80275a
  800fd6:	e8 05 f3 ff ff       	call   8002e0 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	68 00 f0 7f 00       	push   $0x7ff000
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 dc fd ff ff       	call   800dc6 <sys_page_unmap>
	if (r < 0) {
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	79 12                	jns    801003 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ff1:	50                   	push   %eax
  800ff2:	68 65 27 80 00       	push   $0x802765
  800ff7:	6a 36                	push   $0x36
  800ff9:	68 5a 27 80 00       	push   $0x80275a
  800ffe:	e8 dd f2 ff ff       	call   8002e0 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  801003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
  80100e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  801011:	68 32 0f 80 00       	push   $0x800f32
  801016:	e8 be 0e 00 00       	call   801ed9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80101b:	b8 07 00 00 00       	mov    $0x7,%eax
  801020:	cd 30                	int    $0x30
  801022:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	79 17                	jns    801043 <fork+0x3b>
		panic("fork fault %e");
  80102c:	83 ec 04             	sub    $0x4,%esp
  80102f:	68 7e 27 80 00       	push   $0x80277e
  801034:	68 83 00 00 00       	push   $0x83
  801039:	68 5a 27 80 00       	push   $0x80275a
  80103e:	e8 9d f2 ff ff       	call   8002e0 <_panic>
  801043:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801045:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801049:	75 21                	jne    80106c <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  80104b:	e8 b3 fc ff ff       	call   800d03 <sys_getenvid>
  801050:	25 ff 03 00 00       	and    $0x3ff,%eax
  801055:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801058:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80105d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
  801067:	e9 61 01 00 00       	jmp    8011cd <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	6a 07                	push   $0x7
  801071:	68 00 f0 bf ee       	push   $0xeebff000
  801076:	ff 75 e4             	pushl  -0x1c(%ebp)
  801079:	e8 c3 fc ff ff       	call   800d41 <sys_page_alloc>
  80107e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801086:	89 d8                	mov    %ebx,%eax
  801088:	c1 e8 16             	shr    $0x16,%eax
  80108b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801092:	a8 01                	test   $0x1,%al
  801094:	0f 84 fc 00 00 00    	je     801196 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80109a:	89 d8                	mov    %ebx,%eax
  80109c:	c1 e8 0c             	shr    $0xc,%eax
  80109f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8010a6:	f6 c2 01             	test   $0x1,%dl
  8010a9:	0f 84 e7 00 00 00    	je     801196 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8010af:	89 c6                	mov    %eax,%esi
  8010b1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8010b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bb:	f6 c6 04             	test   $0x4,%dh
  8010be:	74 39                	je     8010f9 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cf:	50                   	push   %eax
  8010d0:	56                   	push   %esi
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 aa fc ff ff       	call   800d84 <sys_page_map>
		if (r < 0) {
  8010da:	83 c4 20             	add    $0x20,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	0f 89 b1 00 00 00    	jns    801196 <fork+0x18e>
		    	panic("sys page map fault %e");
  8010e5:	83 ec 04             	sub    $0x4,%esp
  8010e8:	68 8c 27 80 00       	push   $0x80278c
  8010ed:	6a 53                	push   $0x53
  8010ef:	68 5a 27 80 00       	push   $0x80275a
  8010f4:	e8 e7 f1 ff ff       	call   8002e0 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801100:	f6 c2 02             	test   $0x2,%dl
  801103:	75 0c                	jne    801111 <fork+0x109>
  801105:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110c:	f6 c4 08             	test   $0x8,%ah
  80110f:	74 5b                	je     80116c <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	68 05 08 00 00       	push   $0x805
  801119:	56                   	push   %esi
  80111a:	57                   	push   %edi
  80111b:	56                   	push   %esi
  80111c:	6a 00                	push   $0x0
  80111e:	e8 61 fc ff ff       	call   800d84 <sys_page_map>
		if (r < 0) {
  801123:	83 c4 20             	add    $0x20,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	79 14                	jns    80113e <fork+0x136>
		    	panic("sys page map fault %e");
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	68 8c 27 80 00       	push   $0x80278c
  801132:	6a 5a                	push   $0x5a
  801134:	68 5a 27 80 00       	push   $0x80275a
  801139:	e8 a2 f1 ff ff       	call   8002e0 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	68 05 08 00 00       	push   $0x805
  801146:	56                   	push   %esi
  801147:	6a 00                	push   $0x0
  801149:	56                   	push   %esi
  80114a:	6a 00                	push   $0x0
  80114c:	e8 33 fc ff ff       	call   800d84 <sys_page_map>
		if (r < 0) {
  801151:	83 c4 20             	add    $0x20,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	79 3e                	jns    801196 <fork+0x18e>
		    	panic("sys page map fault %e");
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	68 8c 27 80 00       	push   $0x80278c
  801160:	6a 5e                	push   $0x5e
  801162:	68 5a 27 80 00       	push   $0x80275a
  801167:	e8 74 f1 ff ff       	call   8002e0 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	6a 05                	push   $0x5
  801171:	56                   	push   %esi
  801172:	57                   	push   %edi
  801173:	56                   	push   %esi
  801174:	6a 00                	push   $0x0
  801176:	e8 09 fc ff ff       	call   800d84 <sys_page_map>
		if (r < 0) {
  80117b:	83 c4 20             	add    $0x20,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	79 14                	jns    801196 <fork+0x18e>
		    	panic("sys page map fault %e");
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	68 8c 27 80 00       	push   $0x80278c
  80118a:	6a 63                	push   $0x63
  80118c:	68 5a 27 80 00       	push   $0x80275a
  801191:	e8 4a f1 ff ff       	call   8002e0 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801196:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80119c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011a2:	0f 85 de fe ff ff    	jne    801086 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8011a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ad:	8b 40 64             	mov    0x64(%eax),%eax
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	50                   	push   %eax
  8011b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011b7:	57                   	push   %edi
  8011b8:	e8 cf fc ff ff       	call   800e8c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011bd:	83 c4 08             	add    $0x8,%esp
  8011c0:	6a 02                	push   $0x2
  8011c2:	57                   	push   %edi
  8011c3:	e8 40 fc ff ff       	call   800e08 <sys_env_set_status>
	
	return envid;
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011db:	68 a2 27 80 00       	push   $0x8027a2
  8011e0:	68 a1 00 00 00       	push   $0xa1
  8011e5:	68 5a 27 80 00       	push   $0x80275a
  8011ea:	e8 f1 f0 ff ff       	call   8002e0 <_panic>

008011ef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fa:	c1 e8 0c             	shr    $0xc,%eax
}
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    

008011ff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801202:	8b 45 08             	mov    0x8(%ebp),%eax
  801205:	05 00 00 00 30       	add    $0x30000000,%eax
  80120a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80120f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801221:	89 c2                	mov    %eax,%edx
  801223:	c1 ea 16             	shr    $0x16,%edx
  801226:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122d:	f6 c2 01             	test   $0x1,%dl
  801230:	74 11                	je     801243 <fd_alloc+0x2d>
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 0c             	shr    $0xc,%edx
  801237:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	75 09                	jne    80124c <fd_alloc+0x36>
			*fd_store = fd;
  801243:	89 01                	mov    %eax,(%ecx)
			return 0;
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	eb 17                	jmp    801263 <fd_alloc+0x4d>
  80124c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801251:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801256:	75 c9                	jne    801221 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801258:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80125e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80126b:	83 f8 1f             	cmp    $0x1f,%eax
  80126e:	77 36                	ja     8012a6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801270:	c1 e0 0c             	shl    $0xc,%eax
  801273:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801278:	89 c2                	mov    %eax,%edx
  80127a:	c1 ea 16             	shr    $0x16,%edx
  80127d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801284:	f6 c2 01             	test   $0x1,%dl
  801287:	74 24                	je     8012ad <fd_lookup+0x48>
  801289:	89 c2                	mov    %eax,%edx
  80128b:	c1 ea 0c             	shr    $0xc,%edx
  80128e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801295:	f6 c2 01             	test   $0x1,%dl
  801298:	74 1a                	je     8012b4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80129a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129d:	89 02                	mov    %eax,(%edx)
	return 0;
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	eb 13                	jmp    8012b9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ab:	eb 0c                	jmp    8012b9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b2:	eb 05                	jmp    8012b9 <fd_lookup+0x54>
  8012b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c4:	ba 38 28 80 00       	mov    $0x802838,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c9:	eb 13                	jmp    8012de <dev_lookup+0x23>
  8012cb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012ce:	39 08                	cmp    %ecx,(%eax)
  8012d0:	75 0c                	jne    8012de <dev_lookup+0x23>
			*dev = devtab[i];
  8012d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dc:	eb 2e                	jmp    80130c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012de:	8b 02                	mov    (%edx),%eax
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	75 e7                	jne    8012cb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e9:	8b 40 48             	mov    0x48(%eax),%eax
  8012ec:	83 ec 04             	sub    $0x4,%esp
  8012ef:	51                   	push   %ecx
  8012f0:	50                   	push   %eax
  8012f1:	68 b8 27 80 00       	push   $0x8027b8
  8012f6:	e8 be f0 ff ff       	call   8003b9 <cprintf>
	*dev = 0;
  8012fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	56                   	push   %esi
  801312:	53                   	push   %ebx
  801313:	83 ec 10             	sub    $0x10,%esp
  801316:	8b 75 08             	mov    0x8(%ebp),%esi
  801319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80131c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801326:	c1 e8 0c             	shr    $0xc,%eax
  801329:	50                   	push   %eax
  80132a:	e8 36 ff ff ff       	call   801265 <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 05                	js     80133b <fd_close+0x2d>
	    || fd != fd2)
  801336:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801339:	74 0c                	je     801347 <fd_close+0x39>
		return (must_exist ? r : 0);
  80133b:	84 db                	test   %bl,%bl
  80133d:	ba 00 00 00 00       	mov    $0x0,%edx
  801342:	0f 44 c2             	cmove  %edx,%eax
  801345:	eb 41                	jmp    801388 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	ff 36                	pushl  (%esi)
  801350:	e8 66 ff ff ff       	call   8012bb <dev_lookup>
  801355:	89 c3                	mov    %eax,%ebx
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	85 c0                	test   %eax,%eax
  80135c:	78 1a                	js     801378 <fd_close+0x6a>
		if (dev->dev_close)
  80135e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801361:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801364:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801369:	85 c0                	test   %eax,%eax
  80136b:	74 0b                	je     801378 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	56                   	push   %esi
  801371:	ff d0                	call   *%eax
  801373:	89 c3                	mov    %eax,%ebx
  801375:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	56                   	push   %esi
  80137c:	6a 00                	push   $0x0
  80137e:	e8 43 fa ff ff       	call   800dc6 <sys_page_unmap>
	return r;
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	89 d8                	mov    %ebx,%eax
}
  801388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	pushl  0x8(%ebp)
  80139c:	e8 c4 fe ff ff       	call   801265 <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 10                	js     8013b8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	6a 01                	push   $0x1
  8013ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b0:	e8 59 ff ff ff       	call   80130e <fd_close>
  8013b5:	83 c4 10             	add    $0x10,%esp
}
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <close_all>:

void
close_all(void)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	e8 c0 ff ff ff       	call   80138f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013cf:	83 c3 01             	add    $0x1,%ebx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	83 fb 20             	cmp    $0x20,%ebx
  8013d8:	75 ec                	jne    8013c6 <close_all+0xc>
		close(i);
}
  8013da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	57                   	push   %edi
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
  8013e5:	83 ec 2c             	sub    $0x2c,%esp
  8013e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 75 08             	pushl  0x8(%ebp)
  8013f2:	e8 6e fe ff ff       	call   801265 <fd_lookup>
  8013f7:	83 c4 08             	add    $0x8,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	0f 88 c1 00 00 00    	js     8014c3 <dup+0xe4>
		return r;
	close(newfdnum);
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	56                   	push   %esi
  801406:	e8 84 ff ff ff       	call   80138f <close>

	newfd = INDEX2FD(newfdnum);
  80140b:	89 f3                	mov    %esi,%ebx
  80140d:	c1 e3 0c             	shl    $0xc,%ebx
  801410:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801416:	83 c4 04             	add    $0x4,%esp
  801419:	ff 75 e4             	pushl  -0x1c(%ebp)
  80141c:	e8 de fd ff ff       	call   8011ff <fd2data>
  801421:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801423:	89 1c 24             	mov    %ebx,(%esp)
  801426:	e8 d4 fd ff ff       	call   8011ff <fd2data>
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801431:	89 f8                	mov    %edi,%eax
  801433:	c1 e8 16             	shr    $0x16,%eax
  801436:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143d:	a8 01                	test   $0x1,%al
  80143f:	74 37                	je     801478 <dup+0x99>
  801441:	89 f8                	mov    %edi,%eax
  801443:	c1 e8 0c             	shr    $0xc,%eax
  801446:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	74 26                	je     801478 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801452:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	25 07 0e 00 00       	and    $0xe07,%eax
  801461:	50                   	push   %eax
  801462:	ff 75 d4             	pushl  -0x2c(%ebp)
  801465:	6a 00                	push   $0x0
  801467:	57                   	push   %edi
  801468:	6a 00                	push   $0x0
  80146a:	e8 15 f9 ff ff       	call   800d84 <sys_page_map>
  80146f:	89 c7                	mov    %eax,%edi
  801471:	83 c4 20             	add    $0x20,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	78 2e                	js     8014a6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801478:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80147b:	89 d0                	mov    %edx,%eax
  80147d:	c1 e8 0c             	shr    $0xc,%eax
  801480:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	25 07 0e 00 00       	and    $0xe07,%eax
  80148f:	50                   	push   %eax
  801490:	53                   	push   %ebx
  801491:	6a 00                	push   $0x0
  801493:	52                   	push   %edx
  801494:	6a 00                	push   $0x0
  801496:	e8 e9 f8 ff ff       	call   800d84 <sys_page_map>
  80149b:	89 c7                	mov    %eax,%edi
  80149d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014a0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a2:	85 ff                	test   %edi,%edi
  8014a4:	79 1d                	jns    8014c3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	53                   	push   %ebx
  8014aa:	6a 00                	push   $0x0
  8014ac:	e8 15 f9 ff ff       	call   800dc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 08 f9 ff ff       	call   800dc6 <sys_page_unmap>
	return r;
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	89 f8                	mov    %edi,%eax
}
  8014c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 14             	sub    $0x14,%esp
  8014d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	53                   	push   %ebx
  8014da:	e8 86 fd ff ff       	call   801265 <fd_lookup>
  8014df:	83 c4 08             	add    $0x8,%esp
  8014e2:	89 c2                	mov    %eax,%edx
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 6d                	js     801555 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f2:	ff 30                	pushl  (%eax)
  8014f4:	e8 c2 fd ff ff       	call   8012bb <dev_lookup>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 4c                	js     80154c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801500:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801503:	8b 42 08             	mov    0x8(%edx),%eax
  801506:	83 e0 03             	and    $0x3,%eax
  801509:	83 f8 01             	cmp    $0x1,%eax
  80150c:	75 21                	jne    80152f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80150e:	a1 04 40 80 00       	mov    0x804004,%eax
  801513:	8b 40 48             	mov    0x48(%eax),%eax
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	53                   	push   %ebx
  80151a:	50                   	push   %eax
  80151b:	68 fc 27 80 00       	push   $0x8027fc
  801520:	e8 94 ee ff ff       	call   8003b9 <cprintf>
		return -E_INVAL;
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152d:	eb 26                	jmp    801555 <read+0x8a>
	}
	if (!dev->dev_read)
  80152f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801532:	8b 40 08             	mov    0x8(%eax),%eax
  801535:	85 c0                	test   %eax,%eax
  801537:	74 17                	je     801550 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	ff 75 10             	pushl  0x10(%ebp)
  80153f:	ff 75 0c             	pushl  0xc(%ebp)
  801542:	52                   	push   %edx
  801543:	ff d0                	call   *%eax
  801545:	89 c2                	mov    %eax,%edx
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	eb 09                	jmp    801555 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154c:	89 c2                	mov    %eax,%edx
  80154e:	eb 05                	jmp    801555 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801550:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801555:	89 d0                	mov    %edx,%eax
  801557:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	57                   	push   %edi
  801560:	56                   	push   %esi
  801561:	53                   	push   %ebx
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	8b 7d 08             	mov    0x8(%ebp),%edi
  801568:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801570:	eb 21                	jmp    801593 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801572:	83 ec 04             	sub    $0x4,%esp
  801575:	89 f0                	mov    %esi,%eax
  801577:	29 d8                	sub    %ebx,%eax
  801579:	50                   	push   %eax
  80157a:	89 d8                	mov    %ebx,%eax
  80157c:	03 45 0c             	add    0xc(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	57                   	push   %edi
  801581:	e8 45 ff ff ff       	call   8014cb <read>
		if (m < 0)
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 10                	js     80159d <readn+0x41>
			return m;
		if (m == 0)
  80158d:	85 c0                	test   %eax,%eax
  80158f:	74 0a                	je     80159b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801591:	01 c3                	add    %eax,%ebx
  801593:	39 f3                	cmp    %esi,%ebx
  801595:	72 db                	jb     801572 <readn+0x16>
  801597:	89 d8                	mov    %ebx,%eax
  801599:	eb 02                	jmp    80159d <readn+0x41>
  80159b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80159d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5f                   	pop    %edi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 14             	sub    $0x14,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	53                   	push   %ebx
  8015b4:	e8 ac fc ff ff       	call   801265 <fd_lookup>
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	89 c2                	mov    %eax,%edx
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 68                	js     80162a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cc:	ff 30                	pushl  (%eax)
  8015ce:	e8 e8 fc ff ff       	call   8012bb <dev_lookup>
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 47                	js     801621 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e1:	75 21                	jne    801604 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e8:	8b 40 48             	mov    0x48(%eax),%eax
  8015eb:	83 ec 04             	sub    $0x4,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	50                   	push   %eax
  8015f0:	68 18 28 80 00       	push   $0x802818
  8015f5:	e8 bf ed ff ff       	call   8003b9 <cprintf>
		return -E_INVAL;
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801602:	eb 26                	jmp    80162a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801604:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801607:	8b 52 0c             	mov    0xc(%edx),%edx
  80160a:	85 d2                	test   %edx,%edx
  80160c:	74 17                	je     801625 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160e:	83 ec 04             	sub    $0x4,%esp
  801611:	ff 75 10             	pushl  0x10(%ebp)
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	50                   	push   %eax
  801618:	ff d2                	call   *%edx
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	eb 09                	jmp    80162a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801621:	89 c2                	mov    %eax,%edx
  801623:	eb 05                	jmp    80162a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801625:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80162a:	89 d0                	mov    %edx,%eax
  80162c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <seek>:

int
seek(int fdnum, off_t offset)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801637:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	ff 75 08             	pushl  0x8(%ebp)
  80163e:	e8 22 fc ff ff       	call   801265 <fd_lookup>
  801643:	83 c4 08             	add    $0x8,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	78 0e                	js     801658 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80164d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801650:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801653:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 14             	sub    $0x14,%esp
  801661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801664:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	53                   	push   %ebx
  801669:	e8 f7 fb ff ff       	call   801265 <fd_lookup>
  80166e:	83 c4 08             	add    $0x8,%esp
  801671:	89 c2                	mov    %eax,%edx
  801673:	85 c0                	test   %eax,%eax
  801675:	78 65                	js     8016dc <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801681:	ff 30                	pushl  (%eax)
  801683:	e8 33 fc ff ff       	call   8012bb <dev_lookup>
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 44                	js     8016d3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80168f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801692:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801696:	75 21                	jne    8016b9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801698:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80169d:	8b 40 48             	mov    0x48(%eax),%eax
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	53                   	push   %ebx
  8016a4:	50                   	push   %eax
  8016a5:	68 d8 27 80 00       	push   $0x8027d8
  8016aa:	e8 0a ed ff ff       	call   8003b9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b7:	eb 23                	jmp    8016dc <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bc:	8b 52 18             	mov    0x18(%edx),%edx
  8016bf:	85 d2                	test   %edx,%edx
  8016c1:	74 14                	je     8016d7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	ff 75 0c             	pushl  0xc(%ebp)
  8016c9:	50                   	push   %eax
  8016ca:	ff d2                	call   *%edx
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	eb 09                	jmp    8016dc <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	eb 05                	jmp    8016dc <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016dc:	89 d0                	mov    %edx,%eax
  8016de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 14             	sub    $0x14,%esp
  8016ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	ff 75 08             	pushl  0x8(%ebp)
  8016f4:	e8 6c fb ff ff       	call   801265 <fd_lookup>
  8016f9:	83 c4 08             	add    $0x8,%esp
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 58                	js     80175a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801702:	83 ec 08             	sub    $0x8,%esp
  801705:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801708:	50                   	push   %eax
  801709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170c:	ff 30                	pushl  (%eax)
  80170e:	e8 a8 fb ff ff       	call   8012bb <dev_lookup>
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	78 37                	js     801751 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801721:	74 32                	je     801755 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801723:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801726:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172d:	00 00 00 
	stat->st_isdir = 0;
  801730:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801737:	00 00 00 
	stat->st_dev = dev;
  80173a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	53                   	push   %ebx
  801744:	ff 75 f0             	pushl  -0x10(%ebp)
  801747:	ff 50 14             	call   *0x14(%eax)
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	eb 09                	jmp    80175a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801751:	89 c2                	mov    %eax,%edx
  801753:	eb 05                	jmp    80175a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801755:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80175a:	89 d0                	mov    %edx,%eax
  80175c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	6a 00                	push   $0x0
  80176b:	ff 75 08             	pushl  0x8(%ebp)
  80176e:	e8 e3 01 00 00       	call   801956 <open>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 1b                	js     801797 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80177c:	83 ec 08             	sub    $0x8,%esp
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	50                   	push   %eax
  801783:	e8 5b ff ff ff       	call   8016e3 <fstat>
  801788:	89 c6                	mov    %eax,%esi
	close(fd);
  80178a:	89 1c 24             	mov    %ebx,(%esp)
  80178d:	e8 fd fb ff ff       	call   80138f <close>
	return r;
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	89 f0                	mov    %esi,%eax
}
  801797:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
  8017a3:	89 c6                	mov    %eax,%esi
  8017a5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017a7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ae:	75 12                	jne    8017c2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b0:	83 ec 0c             	sub    $0xc,%esp
  8017b3:	6a 01                	push   $0x1
  8017b5:	e8 82 08 00 00       	call   80203c <ipc_find_env>
  8017ba:	a3 00 40 80 00       	mov    %eax,0x804000
  8017bf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c2:	6a 07                	push   $0x7
  8017c4:	68 00 50 80 00       	push   $0x805000
  8017c9:	56                   	push   %esi
  8017ca:	ff 35 00 40 80 00    	pushl  0x804000
  8017d0:	e8 05 08 00 00       	call   801fda <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017d5:	83 c4 0c             	add    $0xc,%esp
  8017d8:	6a 00                	push   $0x0
  8017da:	53                   	push   %ebx
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 86 07 00 00       	call   801f68 <ipc_recv>
}
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801802:	ba 00 00 00 00       	mov    $0x0,%edx
  801807:	b8 02 00 00 00       	mov    $0x2,%eax
  80180c:	e8 8d ff ff ff       	call   80179e <fsipc>
}
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	8b 40 0c             	mov    0xc(%eax),%eax
  80181f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801824:	ba 00 00 00 00       	mov    $0x0,%edx
  801829:	b8 06 00 00 00       	mov    $0x6,%eax
  80182e:	e8 6b ff ff ff       	call   80179e <fsipc>
}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	53                   	push   %ebx
  801839:	83 ec 04             	sub    $0x4,%esp
  80183c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	8b 40 0c             	mov    0xc(%eax),%eax
  801845:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80184a:	ba 00 00 00 00       	mov    $0x0,%edx
  80184f:	b8 05 00 00 00       	mov    $0x5,%eax
  801854:	e8 45 ff ff ff       	call   80179e <fsipc>
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 2c                	js     801889 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	68 00 50 80 00       	push   $0x805000
  801865:	53                   	push   %ebx
  801866:	e8 d3 f0 ff ff       	call   80093e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80186b:	a1 80 50 80 00       	mov    0x805080,%eax
  801870:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801876:	a1 84 50 80 00       	mov    0x805084,%eax
  80187b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801897:	8b 55 08             	mov    0x8(%ebp),%edx
  80189a:	8b 52 0c             	mov    0xc(%edx),%edx
  80189d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018a3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018a8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018ad:	0f 47 c2             	cmova  %edx,%eax
  8018b0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018b5:	50                   	push   %eax
  8018b6:	ff 75 0c             	pushl  0xc(%ebp)
  8018b9:	68 08 50 80 00       	push   $0x805008
  8018be:	e8 0d f2 ff ff       	call   800ad0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018cd:	e8 cc fe ff ff       	call   80179e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f7:	e8 a2 fe ff ff       	call   80179e <fsipc>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 4b                	js     80194d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801902:	39 c6                	cmp    %eax,%esi
  801904:	73 16                	jae    80191c <devfile_read+0x48>
  801906:	68 48 28 80 00       	push   $0x802848
  80190b:	68 4f 28 80 00       	push   $0x80284f
  801910:	6a 7c                	push   $0x7c
  801912:	68 64 28 80 00       	push   $0x802864
  801917:	e8 c4 e9 ff ff       	call   8002e0 <_panic>
	assert(r <= PGSIZE);
  80191c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801921:	7e 16                	jle    801939 <devfile_read+0x65>
  801923:	68 6f 28 80 00       	push   $0x80286f
  801928:	68 4f 28 80 00       	push   $0x80284f
  80192d:	6a 7d                	push   $0x7d
  80192f:	68 64 28 80 00       	push   $0x802864
  801934:	e8 a7 e9 ff ff       	call   8002e0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	50                   	push   %eax
  80193d:	68 00 50 80 00       	push   $0x805000
  801942:	ff 75 0c             	pushl  0xc(%ebp)
  801945:	e8 86 f1 ff ff       	call   800ad0 <memmove>
	return r;
  80194a:	83 c4 10             	add    $0x10,%esp
}
  80194d:	89 d8                	mov    %ebx,%eax
  80194f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	53                   	push   %ebx
  80195a:	83 ec 20             	sub    $0x20,%esp
  80195d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801960:	53                   	push   %ebx
  801961:	e8 9f ef ff ff       	call   800905 <strlen>
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80196e:	7f 67                	jg     8019d7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	e8 9a f8 ff ff       	call   801216 <fd_alloc>
  80197c:	83 c4 10             	add    $0x10,%esp
		return r;
  80197f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801981:	85 c0                	test   %eax,%eax
  801983:	78 57                	js     8019dc <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	53                   	push   %ebx
  801989:	68 00 50 80 00       	push   $0x805000
  80198e:	e8 ab ef ff ff       	call   80093e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801993:	8b 45 0c             	mov    0xc(%ebp),%eax
  801996:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80199b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199e:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a3:	e8 f6 fd ff ff       	call   80179e <fsipc>
  8019a8:	89 c3                	mov    %eax,%ebx
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	79 14                	jns    8019c5 <open+0x6f>
		fd_close(fd, 0);
  8019b1:	83 ec 08             	sub    $0x8,%esp
  8019b4:	6a 00                	push   $0x0
  8019b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b9:	e8 50 f9 ff ff       	call   80130e <fd_close>
		return r;
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	89 da                	mov    %ebx,%edx
  8019c3:	eb 17                	jmp    8019dc <open+0x86>
	}

	return fd2num(fd);
  8019c5:	83 ec 0c             	sub    $0xc,%esp
  8019c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cb:	e8 1f f8 ff ff       	call   8011ef <fd2num>
  8019d0:	89 c2                	mov    %eax,%edx
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	eb 05                	jmp    8019dc <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019d7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019dc:	89 d0                	mov    %edx,%eax
  8019de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f3:	e8 a6 fd ff ff       	call   80179e <fsipc>
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 08             	pushl  0x8(%ebp)
  801a08:	e8 f2 f7 ff ff       	call   8011ff <fd2data>
  801a0d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a0f:	83 c4 08             	add    $0x8,%esp
  801a12:	68 7b 28 80 00       	push   $0x80287b
  801a17:	53                   	push   %ebx
  801a18:	e8 21 ef ff ff       	call   80093e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a1d:	8b 46 04             	mov    0x4(%esi),%eax
  801a20:	2b 06                	sub    (%esi),%eax
  801a22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a2f:	00 00 00 
	stat->st_dev = &devpipe;
  801a32:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a39:	30 80 00 
	return 0;
}
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a52:	53                   	push   %ebx
  801a53:	6a 00                	push   $0x0
  801a55:	e8 6c f3 ff ff       	call   800dc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5a:	89 1c 24             	mov    %ebx,(%esp)
  801a5d:	e8 9d f7 ff ff       	call   8011ff <fd2data>
  801a62:	83 c4 08             	add    $0x8,%esp
  801a65:	50                   	push   %eax
  801a66:	6a 00                	push   $0x0
  801a68:	e8 59 f3 ff ff       	call   800dc6 <sys_page_unmap>
}
  801a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	57                   	push   %edi
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	83 ec 1c             	sub    $0x1c,%esp
  801a7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a7e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a80:	a1 04 40 80 00       	mov    0x804004,%eax
  801a85:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a8e:	e8 e2 05 00 00       	call   802075 <pageref>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	89 3c 24             	mov    %edi,(%esp)
  801a98:	e8 d8 05 00 00       	call   802075 <pageref>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	39 c3                	cmp    %eax,%ebx
  801aa2:	0f 94 c1             	sete   %cl
  801aa5:	0f b6 c9             	movzbl %cl,%ecx
  801aa8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aab:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ab1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab4:	39 ce                	cmp    %ecx,%esi
  801ab6:	74 1b                	je     801ad3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ab8:	39 c3                	cmp    %eax,%ebx
  801aba:	75 c4                	jne    801a80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abc:	8b 42 58             	mov    0x58(%edx),%eax
  801abf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac2:	50                   	push   %eax
  801ac3:	56                   	push   %esi
  801ac4:	68 82 28 80 00       	push   $0x802882
  801ac9:	e8 eb e8 ff ff       	call   8003b9 <cprintf>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	eb ad                	jmp    801a80 <_pipeisclosed+0xe>
	}
}
  801ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 28             	sub    $0x28,%esp
  801ae7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aea:	56                   	push   %esi
  801aeb:	e8 0f f7 ff ff       	call   8011ff <fd2data>
  801af0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	bf 00 00 00 00       	mov    $0x0,%edi
  801afa:	eb 4b                	jmp    801b47 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801afc:	89 da                	mov    %ebx,%edx
  801afe:	89 f0                	mov    %esi,%eax
  801b00:	e8 6d ff ff ff       	call   801a72 <_pipeisclosed>
  801b05:	85 c0                	test   %eax,%eax
  801b07:	75 48                	jne    801b51 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b09:	e8 14 f2 ff ff       	call   800d22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b0e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b11:	8b 0b                	mov    (%ebx),%ecx
  801b13:	8d 51 20             	lea    0x20(%ecx),%edx
  801b16:	39 d0                	cmp    %edx,%eax
  801b18:	73 e2                	jae    801afc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b21:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b24:	89 c2                	mov    %eax,%edx
  801b26:	c1 fa 1f             	sar    $0x1f,%edx
  801b29:	89 d1                	mov    %edx,%ecx
  801b2b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b2e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b31:	83 e2 1f             	and    $0x1f,%edx
  801b34:	29 ca                	sub    %ecx,%edx
  801b36:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b3a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b3e:	83 c0 01             	add    $0x1,%eax
  801b41:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b44:	83 c7 01             	add    $0x1,%edi
  801b47:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4a:	75 c2                	jne    801b0e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4f:	eb 05                	jmp    801b56 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 18             	sub    $0x18,%esp
  801b67:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b6a:	57                   	push   %edi
  801b6b:	e8 8f f6 ff ff       	call   8011ff <fd2data>
  801b70:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7a:	eb 3d                	jmp    801bb9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7c:	85 db                	test   %ebx,%ebx
  801b7e:	74 04                	je     801b84 <devpipe_read+0x26>
				return i;
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	eb 44                	jmp    801bc8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b84:	89 f2                	mov    %esi,%edx
  801b86:	89 f8                	mov    %edi,%eax
  801b88:	e8 e5 fe ff ff       	call   801a72 <_pipeisclosed>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	75 32                	jne    801bc3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b91:	e8 8c f1 ff ff       	call   800d22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b96:	8b 06                	mov    (%esi),%eax
  801b98:	3b 46 04             	cmp    0x4(%esi),%eax
  801b9b:	74 df                	je     801b7c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b9d:	99                   	cltd   
  801b9e:	c1 ea 1b             	shr    $0x1b,%edx
  801ba1:	01 d0                	add    %edx,%eax
  801ba3:	83 e0 1f             	and    $0x1f,%eax
  801ba6:	29 d0                	sub    %edx,%eax
  801ba8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bb3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb6:	83 c3 01             	add    $0x1,%ebx
  801bb9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bbc:	75 d8                	jne    801b96 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bbe:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc1:	eb 05                	jmp    801bc8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	e8 35 f6 ff ff       	call   801216 <fd_alloc>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	89 c2                	mov    %eax,%edx
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 2c 01 00 00    	js     801d1a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	68 07 04 00 00       	push   $0x407
  801bf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 41 f1 ff ff       	call   800d41 <sys_page_alloc>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 0d 01 00 00    	js     801d1a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	e8 fd f5 ff ff       	call   801216 <fd_alloc>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	0f 88 e2 00 00 00    	js     801d08 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c26:	83 ec 04             	sub    $0x4,%esp
  801c29:	68 07 04 00 00       	push   $0x407
  801c2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c31:	6a 00                	push   $0x0
  801c33:	e8 09 f1 ff ff       	call   800d41 <sys_page_alloc>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	0f 88 c3 00 00 00    	js     801d08 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4b:	e8 af f5 ff ff       	call   8011ff <fd2data>
  801c50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c52:	83 c4 0c             	add    $0xc,%esp
  801c55:	68 07 04 00 00       	push   $0x407
  801c5a:	50                   	push   %eax
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 df f0 ff ff       	call   800d41 <sys_page_alloc>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	0f 88 89 00 00 00    	js     801cf8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	ff 75 f0             	pushl  -0x10(%ebp)
  801c75:	e8 85 f5 ff ff       	call   8011ff <fd2data>
  801c7a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c81:	50                   	push   %eax
  801c82:	6a 00                	push   $0x0
  801c84:	56                   	push   %esi
  801c85:	6a 00                	push   $0x0
  801c87:	e8 f8 f0 ff ff       	call   800d84 <sys_page_map>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	83 c4 20             	add    $0x20,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 55                	js     801cea <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c95:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801caa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	e8 25 f5 ff ff       	call   8011ef <fd2num>
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ccf:	83 c4 04             	add    $0x4,%esp
  801cd2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd5:	e8 15 f5 ff ff       	call   8011ef <fd2num>
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce8:	eb 30                	jmp    801d1a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	56                   	push   %esi
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 d1 f0 ff ff       	call   800dc6 <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 c1 f0 ff ff       	call   800dc6 <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 b1 f0 ff ff       	call   800dc6 <sys_page_unmap>
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2c:	50                   	push   %eax
  801d2d:	ff 75 08             	pushl  0x8(%ebp)
  801d30:	e8 30 f5 ff ff       	call   801265 <fd_lookup>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 18                	js     801d54 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d42:	e8 b8 f4 ff ff       	call   8011ff <fd2data>
	return _pipeisclosed(fd, p);
  801d47:	89 c2                	mov    %eax,%edx
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	e8 21 fd ff ff       	call   801a72 <_pipeisclosed>
  801d51:	83 c4 10             	add    $0x10,%esp
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d66:	68 95 28 80 00       	push   $0x802895
  801d6b:	ff 75 0c             	pushl  0xc(%ebp)
  801d6e:	e8 cb eb ff ff       	call   80093e <strcpy>
	return 0;
}
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d86:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d91:	eb 2d                	jmp    801dc0 <devcons_write+0x46>
		m = n - tot;
  801d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d96:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d98:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da3:	83 ec 04             	sub    $0x4,%esp
  801da6:	53                   	push   %ebx
  801da7:	03 45 0c             	add    0xc(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	57                   	push   %edi
  801dac:	e8 1f ed ff ff       	call   800ad0 <memmove>
		sys_cputs(buf, m);
  801db1:	83 c4 08             	add    $0x8,%esp
  801db4:	53                   	push   %ebx
  801db5:	57                   	push   %edi
  801db6:	e8 ca ee ff ff       	call   800c85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbb:	01 de                	add    %ebx,%esi
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	89 f0                	mov    %esi,%eax
  801dc2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc5:	72 cc                	jb     801d93 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dca:	5b                   	pop    %ebx
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 08             	sub    $0x8,%esp
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dde:	74 2a                	je     801e0a <devcons_read+0x3b>
  801de0:	eb 05                	jmp    801de7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de2:	e8 3b ef ff ff       	call   800d22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de7:	e8 b7 ee ff ff       	call   800ca3 <sys_cgetc>
  801dec:	85 c0                	test   %eax,%eax
  801dee:	74 f2                	je     801de2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 16                	js     801e0a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df4:	83 f8 04             	cmp    $0x4,%eax
  801df7:	74 0c                	je     801e05 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfc:	88 02                	mov    %al,(%edx)
	return 1;
  801dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801e03:	eb 05                	jmp    801e0a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
  801e15:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e18:	6a 01                	push   $0x1
  801e1a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1d:	50                   	push   %eax
  801e1e:	e8 62 ee ff ff       	call   800c85 <sys_cputs>
}
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <getchar>:

int
getchar(void)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e2e:	6a 01                	push   $0x1
  801e30:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	6a 00                	push   $0x0
  801e36:	e8 90 f6 ff ff       	call   8014cb <read>
	if (r < 0)
  801e3b:	83 c4 10             	add    $0x10,%esp
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 0f                	js     801e51 <getchar+0x29>
		return r;
	if (r < 1)
  801e42:	85 c0                	test   %eax,%eax
  801e44:	7e 06                	jle    801e4c <getchar+0x24>
		return -E_EOF;
	return c;
  801e46:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e4a:	eb 05                	jmp    801e51 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e4c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	ff 75 08             	pushl  0x8(%ebp)
  801e60:	e8 00 f4 ff ff       	call   801265 <fd_lookup>
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 11                	js     801e7d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e75:	39 10                	cmp    %edx,(%eax)
  801e77:	0f 94 c0             	sete   %al
  801e7a:	0f b6 c0             	movzbl %al,%eax
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    

00801e7f <opencons>:

int
opencons(void)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e88:	50                   	push   %eax
  801e89:	e8 88 f3 ff ff       	call   801216 <fd_alloc>
  801e8e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e91:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 3e                	js     801ed5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	68 07 04 00 00       	push   $0x407
  801e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 98 ee ff ff       	call   800d41 <sys_page_alloc>
  801ea9:	83 c4 10             	add    $0x10,%esp
		return r;
  801eac:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 23                	js     801ed5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	50                   	push   %eax
  801ecb:	e8 1f f3 ff ff       	call   8011ef <fd2num>
  801ed0:	89 c2                	mov    %eax,%edx
  801ed2:	83 c4 10             	add    $0x10,%esp
}
  801ed5:	89 d0                	mov    %edx,%eax
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801edf:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee6:	75 2a                	jne    801f12 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	6a 07                	push   $0x7
  801eed:	68 00 f0 bf ee       	push   $0xeebff000
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 48 ee ff ff       	call   800d41 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	79 12                	jns    801f12 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f00:	50                   	push   %eax
  801f01:	68 a1 28 80 00       	push   $0x8028a1
  801f06:	6a 23                	push   $0x23
  801f08:	68 a5 28 80 00       	push   $0x8028a5
  801f0d:	e8 ce e3 ff ff       	call   8002e0 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f12:	8b 45 08             	mov    0x8(%ebp),%eax
  801f15:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	68 44 1f 80 00       	push   $0x801f44
  801f22:	6a 00                	push   $0x0
  801f24:	e8 63 ef ff ff       	call   800e8c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	79 12                	jns    801f42 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f30:	50                   	push   %eax
  801f31:	68 a1 28 80 00       	push   $0x8028a1
  801f36:	6a 2c                	push   $0x2c
  801f38:	68 a5 28 80 00       	push   $0x8028a5
  801f3d:	e8 9e e3 ff ff       	call   8002e0 <_panic>
	}
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f44:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f45:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f4a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f4c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f4f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f53:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f58:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f5c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f5e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f61:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f62:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f65:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f66:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f67:	c3                   	ret    

00801f68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	56                   	push   %esi
  801f6c:	53                   	push   %ebx
  801f6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f76:	85 c0                	test   %eax,%eax
  801f78:	75 12                	jne    801f8c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	68 00 00 c0 ee       	push   $0xeec00000
  801f82:	e8 6a ef ff ff       	call   800ef1 <sys_ipc_recv>
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	eb 0c                	jmp    801f98 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f8c:	83 ec 0c             	sub    $0xc,%esp
  801f8f:	50                   	push   %eax
  801f90:	e8 5c ef ff ff       	call   800ef1 <sys_ipc_recv>
  801f95:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f98:	85 f6                	test   %esi,%esi
  801f9a:	0f 95 c1             	setne  %cl
  801f9d:	85 db                	test   %ebx,%ebx
  801f9f:	0f 95 c2             	setne  %dl
  801fa2:	84 d1                	test   %dl,%cl
  801fa4:	74 09                	je     801faf <ipc_recv+0x47>
  801fa6:	89 c2                	mov    %eax,%edx
  801fa8:	c1 ea 1f             	shr    $0x1f,%edx
  801fab:	84 d2                	test   %dl,%dl
  801fad:	75 24                	jne    801fd3 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801faf:	85 f6                	test   %esi,%esi
  801fb1:	74 0a                	je     801fbd <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801fb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb8:	8b 40 74             	mov    0x74(%eax),%eax
  801fbb:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801fbd:	85 db                	test   %ebx,%ebx
  801fbf:	74 0a                	je     801fcb <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801fc1:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc6:	8b 40 78             	mov    0x78(%eax),%eax
  801fc9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fcb:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd6:	5b                   	pop    %ebx
  801fd7:	5e                   	pop    %esi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	57                   	push   %edi
  801fde:	56                   	push   %esi
  801fdf:	53                   	push   %ebx
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801fec:	85 db                	test   %ebx,%ebx
  801fee:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ff3:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ff6:	ff 75 14             	pushl  0x14(%ebp)
  801ff9:	53                   	push   %ebx
  801ffa:	56                   	push   %esi
  801ffb:	57                   	push   %edi
  801ffc:	e8 cd ee ff ff       	call   800ece <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802001:	89 c2                	mov    %eax,%edx
  802003:	c1 ea 1f             	shr    $0x1f,%edx
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	84 d2                	test   %dl,%dl
  80200b:	74 17                	je     802024 <ipc_send+0x4a>
  80200d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802010:	74 12                	je     802024 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802012:	50                   	push   %eax
  802013:	68 b3 28 80 00       	push   $0x8028b3
  802018:	6a 47                	push   $0x47
  80201a:	68 c1 28 80 00       	push   $0x8028c1
  80201f:	e8 bc e2 ff ff       	call   8002e0 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802024:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802027:	75 07                	jne    802030 <ipc_send+0x56>
			sys_yield();
  802029:	e8 f4 ec ff ff       	call   800d22 <sys_yield>
  80202e:	eb c6                	jmp    801ff6 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802030:	85 c0                	test   %eax,%eax
  802032:	75 c2                	jne    801ff6 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802034:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    

0080203c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802047:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80204a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802050:	8b 52 50             	mov    0x50(%edx),%edx
  802053:	39 ca                	cmp    %ecx,%edx
  802055:	75 0d                	jne    802064 <ipc_find_env+0x28>
			return envs[i].env_id;
  802057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80205a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80205f:	8b 40 48             	mov    0x48(%eax),%eax
  802062:	eb 0f                	jmp    802073 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802064:	83 c0 01             	add    $0x1,%eax
  802067:	3d 00 04 00 00       	cmp    $0x400,%eax
  80206c:	75 d9                	jne    802047 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    

00802075 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207b:	89 d0                	mov    %edx,%eax
  80207d:	c1 e8 16             	shr    $0x16,%eax
  802080:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208c:	f6 c1 01             	test   $0x1,%cl
  80208f:	74 1d                	je     8020ae <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802091:	c1 ea 0c             	shr    $0xc,%edx
  802094:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80209b:	f6 c2 01             	test   $0x1,%dl
  80209e:	74 0e                	je     8020ae <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020a0:	c1 ea 0c             	shr    $0xc,%edx
  8020a3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020aa:	ef 
  8020ab:	0f b7 c0             	movzwl %ax,%eax
}
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
