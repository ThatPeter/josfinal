
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a4 01 00 00       	call   8001d5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 60 23 80 00       	push   $0x802360
  800041:	e8 28 03 00 00       	call   80036e <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 7f 1b 00 00       	call   801bd0 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 ae 23 80 00       	push   $0x8023ae
  80005e:	6a 0d                	push   $0xd
  800060:	68 b7 23 80 00       	push   $0x8023b7
  800065:	e8 2b 02 00 00       	call   800295 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 6e 0f 00 00       	call   800fdd <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 cc 23 80 00       	push   $0x8023cc
  80007b:	6a 0f                	push   $0xf
  80007d:	68 b7 23 80 00       	push   $0x8023b7
  800082:	e8 0e 02 00 00       	call   800295 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 f9 12 00 00       	call   80138f <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 d5 23 80 00       	push   $0x8023d5
  8000c3:	e8 a6 02 00 00       	call   80036e <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 07 13 00 00       	call   8013df <dup>
			sys_yield();
  8000d8:	e8 fa 0b 00 00       	call   800cd7 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 a6 12 00 00       	call   80138f <close>
			sys_yield();
  8000e9:	e8 e9 0b 00 00       	call   800cd7 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 7a 01 00 00       	call   80027b <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 01 1c 00 00       	call   801d23 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 27                	je     800150 <umain+0x11d>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 d9 23 80 00       	push   $0x8023d9
  800131:	e8 38 02 00 00       	call   80036e <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 39 0b 00 00       	call   800c77 <sys_env_destroy>
			exit();
  80013e:	e8 38 01 00 00       	call   80027b <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800149:	8d 9c 07 00 00 c0 ee 	lea    -0x11400000(%edi,%eax,1),%ebx
  800150:	8b 43 5c             	mov    0x5c(%ebx),%eax
  800153:	83 f8 02             	cmp    $0x2,%eax
  800156:	74 bf                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	68 f5 23 80 00       	push   $0x8023f5
  800160:	e8 09 02 00 00       	call   80036e <cprintf>
	if (pipeisclosed(p[0]))
  800165:	83 c4 04             	add    $0x4,%esp
  800168:	ff 75 e0             	pushl  -0x20(%ebp)
  80016b:	e8 b3 1b 00 00       	call   801d23 <pipeisclosed>
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	85 c0                	test   %eax,%eax
  800175:	74 14                	je     80018b <umain+0x158>
		panic("somehow the other end of p[0] got closed!");
  800177:	83 ec 04             	sub    $0x4,%esp
  80017a:	68 84 23 80 00       	push   $0x802384
  80017f:	6a 40                	push   $0x40
  800181:	68 b7 23 80 00       	push   $0x8023b7
  800186:	e8 0a 01 00 00       	call   800295 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800191:	50                   	push   %eax
  800192:	ff 75 e0             	pushl  -0x20(%ebp)
  800195:	e8 cb 10 00 00       	call   801265 <fd_lookup>
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	85 c0                	test   %eax,%eax
  80019f:	79 12                	jns    8001b3 <umain+0x180>
		panic("cannot look up p[0]: %e", r);
  8001a1:	50                   	push   %eax
  8001a2:	68 0b 24 80 00       	push   $0x80240b
  8001a7:	6a 42                	push   $0x42
  8001a9:	68 b7 23 80 00       	push   $0x8023b7
  8001ae:	e8 e2 00 00 00       	call   800295 <_panic>
	(void) fd2data(fd);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b9:	e8 41 10 00 00       	call   8011ff <fd2data>
	cprintf("race didn't happen\n");
  8001be:	c7 04 24 23 24 80 00 	movl   $0x802423,(%esp)
  8001c5:	e8 a4 01 00 00       	call   80036e <cprintf>
}
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001de:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001e5:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001e8:	e8 cb 0a 00 00       	call   800cb8 <sys_getenvid>
  8001ed:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	50                   	push   %eax
  8001f3:	68 38 24 80 00       	push   $0x802438
  8001f8:	e8 71 01 00 00       	call   80036e <cprintf>
  8001fd:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800203:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800210:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800215:	89 c1                	mov    %eax,%ecx
  800217:	c1 e1 07             	shl    $0x7,%ecx
  80021a:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800221:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800224:	39 cb                	cmp    %ecx,%ebx
  800226:	0f 44 fa             	cmove  %edx,%edi
  800229:	b9 01 00 00 00       	mov    $0x1,%ecx
  80022e:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800231:	83 c0 01             	add    $0x1,%eax
  800234:	81 c2 84 00 00 00    	add    $0x84,%edx
  80023a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80023f:	75 d4                	jne    800215 <libmain+0x40>
  800241:	89 f0                	mov    %esi,%eax
  800243:	84 c0                	test   %al,%al
  800245:	74 06                	je     80024d <libmain+0x78>
  800247:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800251:	7e 0a                	jle    80025d <libmain+0x88>
		binaryname = argv[0];
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
  800256:	8b 00                	mov    (%eax),%eax
  800258:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80025d:	83 ec 08             	sub    $0x8,%esp
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 c8 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80026b:	e8 0b 00 00 00       	call   80027b <exit>
}
  800270:	83 c4 10             	add    $0x10,%esp
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800281:	e8 34 11 00 00       	call   8013ba <close_all>
	sys_env_destroy(0);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	6a 00                	push   $0x0
  80028b:	e8 e7 09 00 00       	call   800c77 <sys_env_destroy>
}
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a3:	e8 10 0a 00 00       	call   800cb8 <sys_getenvid>
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	ff 75 0c             	pushl  0xc(%ebp)
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	56                   	push   %esi
  8002b2:	50                   	push   %eax
  8002b3:	68 64 24 80 00       	push   $0x802464
  8002b8:	e8 b1 00 00 00       	call   80036e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bd:	83 c4 18             	add    $0x18,%esp
  8002c0:	53                   	push   %ebx
  8002c1:	ff 75 10             	pushl  0x10(%ebp)
  8002c4:	e8 54 00 00 00       	call   80031d <vcprintf>
	cprintf("\n");
  8002c9:	c7 04 24 03 29 80 00 	movl   $0x802903,(%esp)
  8002d0:	e8 99 00 00 00       	call   80036e <cprintf>
  8002d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d8:	cc                   	int3   
  8002d9:	eb fd                	jmp    8002d8 <_panic+0x43>

008002db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	53                   	push   %ebx
  8002df:	83 ec 04             	sub    $0x4,%esp
  8002e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e5:	8b 13                	mov    (%ebx),%edx
  8002e7:	8d 42 01             	lea    0x1(%edx),%eax
  8002ea:	89 03                	mov    %eax,(%ebx)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f8:	75 1a                	jne    800314 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fa:	83 ec 08             	sub    $0x8,%esp
  8002fd:	68 ff 00 00 00       	push   $0xff
  800302:	8d 43 08             	lea    0x8(%ebx),%eax
  800305:	50                   	push   %eax
  800306:	e8 2f 09 00 00       	call   800c3a <sys_cputs>
		b->idx = 0;
  80030b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800311:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800314:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800326:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032d:	00 00 00 
	b.cnt = 0;
  800330:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800337:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800346:	50                   	push   %eax
  800347:	68 db 02 80 00       	push   $0x8002db
  80034c:	e8 54 01 00 00       	call   8004a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800351:	83 c4 08             	add    $0x8,%esp
  800354:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800360:	50                   	push   %eax
  800361:	e8 d4 08 00 00       	call   800c3a <sys_cputs>

	return b.cnt;
}
  800366:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800374:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800377:	50                   	push   %eax
  800378:	ff 75 08             	pushl  0x8(%ebp)
  80037b:	e8 9d ff ff ff       	call   80031d <vcprintf>
	va_end(ap);

	return cnt;
}
  800380:	c9                   	leave  
  800381:	c3                   	ret    

00800382 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	57                   	push   %edi
  800386:	56                   	push   %esi
  800387:	53                   	push   %ebx
  800388:	83 ec 1c             	sub    $0x1c,%esp
  80038b:	89 c7                	mov    %eax,%edi
  80038d:	89 d6                	mov    %edx,%esi
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
  800392:	8b 55 0c             	mov    0xc(%ebp),%edx
  800395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800398:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80039e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003a9:	39 d3                	cmp    %edx,%ebx
  8003ab:	72 05                	jb     8003b2 <printnum+0x30>
  8003ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b0:	77 45                	ja     8003f7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b2:	83 ec 0c             	sub    $0xc,%esp
  8003b5:	ff 75 18             	pushl  0x18(%ebp)
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003be:	53                   	push   %ebx
  8003bf:	ff 75 10             	pushl  0x10(%ebp)
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d1:	e8 ea 1c 00 00       	call   8020c0 <__udivdi3>
  8003d6:	83 c4 18             	add    $0x18,%esp
  8003d9:	52                   	push   %edx
  8003da:	50                   	push   %eax
  8003db:	89 f2                	mov    %esi,%edx
  8003dd:	89 f8                	mov    %edi,%eax
  8003df:	e8 9e ff ff ff       	call   800382 <printnum>
  8003e4:	83 c4 20             	add    $0x20,%esp
  8003e7:	eb 18                	jmp    800401 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	56                   	push   %esi
  8003ed:	ff 75 18             	pushl  0x18(%ebp)
  8003f0:	ff d7                	call   *%edi
  8003f2:	83 c4 10             	add    $0x10,%esp
  8003f5:	eb 03                	jmp    8003fa <printnum+0x78>
  8003f7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fa:	83 eb 01             	sub    $0x1,%ebx
  8003fd:	85 db                	test   %ebx,%ebx
  8003ff:	7f e8                	jg     8003e9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	56                   	push   %esi
  800405:	83 ec 04             	sub    $0x4,%esp
  800408:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040b:	ff 75 e0             	pushl  -0x20(%ebp)
  80040e:	ff 75 dc             	pushl  -0x24(%ebp)
  800411:	ff 75 d8             	pushl  -0x28(%ebp)
  800414:	e8 d7 1d 00 00       	call   8021f0 <__umoddi3>
  800419:	83 c4 14             	add    $0x14,%esp
  80041c:	0f be 80 87 24 80 00 	movsbl 0x802487(%eax),%eax
  800423:	50                   	push   %eax
  800424:	ff d7                	call   *%edi
}
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5e                   	pop    %esi
  80042e:	5f                   	pop    %edi
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800434:	83 fa 01             	cmp    $0x1,%edx
  800437:	7e 0e                	jle    800447 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043e:	89 08                	mov    %ecx,(%eax)
  800440:	8b 02                	mov    (%edx),%eax
  800442:	8b 52 04             	mov    0x4(%edx),%edx
  800445:	eb 22                	jmp    800469 <getuint+0x38>
	else if (lflag)
  800447:	85 d2                	test   %edx,%edx
  800449:	74 10                	je     80045b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044b:	8b 10                	mov    (%eax),%edx
  80044d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800450:	89 08                	mov    %ecx,(%eax)
  800452:	8b 02                	mov    (%edx),%eax
  800454:	ba 00 00 00 00       	mov    $0x0,%edx
  800459:	eb 0e                	jmp    800469 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045b:	8b 10                	mov    (%eax),%edx
  80045d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800460:	89 08                	mov    %ecx,(%eax)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800471:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800475:	8b 10                	mov    (%eax),%edx
  800477:	3b 50 04             	cmp    0x4(%eax),%edx
  80047a:	73 0a                	jae    800486 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 45 08             	mov    0x8(%ebp),%eax
  800484:	88 02                	mov    %al,(%edx)
}
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    

00800488 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80048e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800491:	50                   	push   %eax
  800492:	ff 75 10             	pushl  0x10(%ebp)
  800495:	ff 75 0c             	pushl  0xc(%ebp)
  800498:	ff 75 08             	pushl  0x8(%ebp)
  80049b:	e8 05 00 00 00       	call   8004a5 <vprintfmt>
	va_end(ap);
}
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	c9                   	leave  
  8004a4:	c3                   	ret    

008004a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	57                   	push   %edi
  8004a9:	56                   	push   %esi
  8004aa:	53                   	push   %ebx
  8004ab:	83 ec 2c             	sub    $0x2c,%esp
  8004ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004b7:	eb 12                	jmp    8004cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	0f 84 89 03 00 00    	je     80084a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	50                   	push   %eax
  8004c6:	ff d6                	call   *%esi
  8004c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cb:	83 c7 01             	add    $0x1,%edi
  8004ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d2:	83 f8 25             	cmp    $0x25,%eax
  8004d5:	75 e2                	jne    8004b9 <vprintfmt+0x14>
  8004d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f5:	eb 07                	jmp    8004fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8d 47 01             	lea    0x1(%edi),%eax
  800501:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800504:	0f b6 07             	movzbl (%edi),%eax
  800507:	0f b6 c8             	movzbl %al,%ecx
  80050a:	83 e8 23             	sub    $0x23,%eax
  80050d:	3c 55                	cmp    $0x55,%al
  80050f:	0f 87 1a 03 00 00    	ja     80082f <vprintfmt+0x38a>
  800515:	0f b6 c0             	movzbl %al,%eax
  800518:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  80051f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800522:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800526:	eb d6                	jmp    8004fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052b:	b8 00 00 00 00       	mov    $0x0,%eax
  800530:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800533:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800536:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80053d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800540:	83 fa 09             	cmp    $0x9,%edx
  800543:	77 39                	ja     80057e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800545:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800548:	eb e9                	jmp    800533 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 48 04             	lea    0x4(%eax),%ecx
  800550:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055b:	eb 27                	jmp    800584 <vprintfmt+0xdf>
  80055d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800560:	85 c0                	test   %eax,%eax
  800562:	b9 00 00 00 00       	mov    $0x0,%ecx
  800567:	0f 49 c8             	cmovns %eax,%ecx
  80056a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800570:	eb 8c                	jmp    8004fe <vprintfmt+0x59>
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800575:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057c:	eb 80                	jmp    8004fe <vprintfmt+0x59>
  80057e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800581:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800584:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800588:	0f 89 70 ff ff ff    	jns    8004fe <vprintfmt+0x59>
				width = precision, precision = -1;
  80058e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800594:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059b:	e9 5e ff ff ff       	jmp    8004fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a6:	e9 53 ff ff ff       	jmp    8004fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 04             	lea    0x4(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	ff 30                	pushl  (%eax)
  8005ba:	ff d6                	call   *%esi
			break;
  8005bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c2:	e9 04 ff ff ff       	jmp    8004cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	99                   	cltd   
  8005d3:	31 d0                	xor    %edx,%eax
  8005d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d7:	83 f8 0f             	cmp    $0xf,%eax
  8005da:	7f 0b                	jg     8005e7 <vprintfmt+0x142>
  8005dc:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	75 18                	jne    8005ff <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005e7:	50                   	push   %eax
  8005e8:	68 9f 24 80 00       	push   $0x80249f
  8005ed:	53                   	push   %ebx
  8005ee:	56                   	push   %esi
  8005ef:	e8 94 fe ff ff       	call   800488 <printfmt>
  8005f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fa:	e9 cc fe ff ff       	jmp    8004cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ff:	52                   	push   %edx
  800600:	68 d1 28 80 00       	push   $0x8028d1
  800605:	53                   	push   %ebx
  800606:	56                   	push   %esi
  800607:	e8 7c fe ff ff       	call   800488 <printfmt>
  80060c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800612:	e9 b4 fe ff ff       	jmp    8004cb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800622:	85 ff                	test   %edi,%edi
  800624:	b8 98 24 80 00       	mov    $0x802498,%eax
  800629:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800630:	0f 8e 94 00 00 00    	jle    8006ca <vprintfmt+0x225>
  800636:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063a:	0f 84 98 00 00 00    	je     8006d8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	ff 75 d0             	pushl  -0x30(%ebp)
  800646:	57                   	push   %edi
  800647:	e8 86 02 00 00       	call   8008d2 <strnlen>
  80064c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80064f:	29 c1                	sub    %eax,%ecx
  800651:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800657:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80065e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800661:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	eb 0f                	jmp    800674 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066e:	83 ef 01             	sub    $0x1,%edi
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	85 ff                	test   %edi,%edi
  800676:	7f ed                	jg     800665 <vprintfmt+0x1c0>
  800678:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80067e:	85 c9                	test   %ecx,%ecx
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
  800685:	0f 49 c1             	cmovns %ecx,%eax
  800688:	29 c1                	sub    %eax,%ecx
  80068a:	89 75 08             	mov    %esi,0x8(%ebp)
  80068d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800690:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800693:	89 cb                	mov    %ecx,%ebx
  800695:	eb 4d                	jmp    8006e4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800697:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069b:	74 1b                	je     8006b8 <vprintfmt+0x213>
  80069d:	0f be c0             	movsbl %al,%eax
  8006a0:	83 e8 20             	sub    $0x20,%eax
  8006a3:	83 f8 5e             	cmp    $0x5e,%eax
  8006a6:	76 10                	jbe    8006b8 <vprintfmt+0x213>
					putch('?', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	6a 3f                	push   $0x3f
  8006b0:	ff 55 08             	call   *0x8(%ebp)
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 0d                	jmp    8006c5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	ff 75 0c             	pushl  0xc(%ebp)
  8006be:	52                   	push   %edx
  8006bf:	ff 55 08             	call   *0x8(%ebp)
  8006c2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c5:	83 eb 01             	sub    $0x1,%ebx
  8006c8:	eb 1a                	jmp    8006e4 <vprintfmt+0x23f>
  8006ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8006cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d6:	eb 0c                	jmp    8006e4 <vprintfmt+0x23f>
  8006d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e4:	83 c7 01             	add    $0x1,%edi
  8006e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006eb:	0f be d0             	movsbl %al,%edx
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	74 23                	je     800715 <vprintfmt+0x270>
  8006f2:	85 f6                	test   %esi,%esi
  8006f4:	78 a1                	js     800697 <vprintfmt+0x1f2>
  8006f6:	83 ee 01             	sub    $0x1,%esi
  8006f9:	79 9c                	jns    800697 <vprintfmt+0x1f2>
  8006fb:	89 df                	mov    %ebx,%edi
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	eb 18                	jmp    80071d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 20                	push   $0x20
  80070b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80070d:	83 ef 01             	sub    $0x1,%edi
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 08                	jmp    80071d <vprintfmt+0x278>
  800715:	89 df                	mov    %ebx,%edi
  800717:	8b 75 08             	mov    0x8(%ebp),%esi
  80071a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071d:	85 ff                	test   %edi,%edi
  80071f:	7f e4                	jg     800705 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800721:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800724:	e9 a2 fd ff ff       	jmp    8004cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800729:	83 fa 01             	cmp    $0x1,%edx
  80072c:	7e 16                	jle    800744 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 08             	lea    0x8(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)
  800737:	8b 50 04             	mov    0x4(%eax),%edx
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800742:	eb 32                	jmp    800776 <vprintfmt+0x2d1>
	else if (lflag)
  800744:	85 d2                	test   %edx,%edx
  800746:	74 18                	je     800760 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)
  800751:	8b 00                	mov    (%eax),%eax
  800753:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800756:	89 c1                	mov    %eax,%ecx
  800758:	c1 f9 1f             	sar    $0x1f,%ecx
  80075b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80075e:	eb 16                	jmp    800776 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)
  800769:	8b 00                	mov    (%eax),%eax
  80076b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076e:	89 c1                	mov    %eax,%ecx
  800770:	c1 f9 1f             	sar    $0x1f,%ecx
  800773:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800776:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800779:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800781:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800785:	79 74                	jns    8007fb <vprintfmt+0x356>
				putch('-', putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	6a 2d                	push   $0x2d
  80078d:	ff d6                	call   *%esi
				num = -(long long) num;
  80078f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800792:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800795:	f7 d8                	neg    %eax
  800797:	83 d2 00             	adc    $0x0,%edx
  80079a:	f7 da                	neg    %edx
  80079c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80079f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a4:	eb 55                	jmp    8007fb <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	e8 83 fc ff ff       	call   800431 <getuint>
			base = 10;
  8007ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b3:	eb 46                	jmp    8007fb <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b8:	e8 74 fc ff ff       	call   800431 <getuint>
			base = 8;
  8007bd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007c2:	eb 37                	jmp    8007fb <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	6a 30                	push   $0x30
  8007ca:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cc:	83 c4 08             	add    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 78                	push   $0x78
  8007d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 04             	lea    0x4(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ec:	eb 0d                	jmp    8007fb <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f1:	e8 3b fc ff ff       	call   800431 <getuint>
			base = 16;
  8007f6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fb:	83 ec 0c             	sub    $0xc,%esp
  8007fe:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800802:	57                   	push   %edi
  800803:	ff 75 e0             	pushl  -0x20(%ebp)
  800806:	51                   	push   %ecx
  800807:	52                   	push   %edx
  800808:	50                   	push   %eax
  800809:	89 da                	mov    %ebx,%edx
  80080b:	89 f0                	mov    %esi,%eax
  80080d:	e8 70 fb ff ff       	call   800382 <printnum>
			break;
  800812:	83 c4 20             	add    $0x20,%esp
  800815:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800818:	e9 ae fc ff ff       	jmp    8004cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	53                   	push   %ebx
  800821:	51                   	push   %ecx
  800822:	ff d6                	call   *%esi
			break;
  800824:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800827:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082a:	e9 9c fc ff ff       	jmp    8004cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	53                   	push   %ebx
  800833:	6a 25                	push   $0x25
  800835:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	eb 03                	jmp    80083f <vprintfmt+0x39a>
  80083c:	83 ef 01             	sub    $0x1,%edi
  80083f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800843:	75 f7                	jne    80083c <vprintfmt+0x397>
  800845:	e9 81 fc ff ff       	jmp    8004cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5f                   	pop    %edi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 18             	sub    $0x18,%esp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800861:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800865:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800868:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086f:	85 c0                	test   %eax,%eax
  800871:	74 26                	je     800899 <vsnprintf+0x47>
  800873:	85 d2                	test   %edx,%edx
  800875:	7e 22                	jle    800899 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800877:	ff 75 14             	pushl  0x14(%ebp)
  80087a:	ff 75 10             	pushl  0x10(%ebp)
  80087d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800880:	50                   	push   %eax
  800881:	68 6b 04 80 00       	push   $0x80046b
  800886:	e8 1a fc ff ff       	call   8004a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	eb 05                	jmp    80089e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800899:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 10             	pushl  0x10(%ebp)
  8008ad:	ff 75 0c             	pushl  0xc(%ebp)
  8008b0:	ff 75 08             	pushl  0x8(%ebp)
  8008b3:	e8 9a ff ff ff       	call   800852 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	eb 03                	jmp    8008ca <strlen+0x10>
		n++;
  8008c7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ce:	75 f7                	jne    8008c7 <strlen+0xd>
		n++;
	return n;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e0:	eb 03                	jmp    8008e5 <strnlen+0x13>
		n++;
  8008e2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e5:	39 c2                	cmp    %eax,%edx
  8008e7:	74 08                	je     8008f1 <strnlen+0x1f>
  8008e9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ed:	75 f3                	jne    8008e2 <strnlen+0x10>
  8008ef:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fd:	89 c2                	mov    %eax,%edx
  8008ff:	83 c2 01             	add    $0x1,%edx
  800902:	83 c1 01             	add    $0x1,%ecx
  800905:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800909:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090c:	84 db                	test   %bl,%bl
  80090e:	75 ef                	jne    8008ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800910:	5b                   	pop    %ebx
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091a:	53                   	push   %ebx
  80091b:	e8 9a ff ff ff       	call   8008ba <strlen>
  800920:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800923:	ff 75 0c             	pushl  0xc(%ebp)
  800926:	01 d8                	add    %ebx,%eax
  800928:	50                   	push   %eax
  800929:	e8 c5 ff ff ff       	call   8008f3 <strcpy>
	return dst;
}
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 75 08             	mov    0x8(%ebp),%esi
  80093d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800940:	89 f3                	mov    %esi,%ebx
  800942:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800945:	89 f2                	mov    %esi,%edx
  800947:	eb 0f                	jmp    800958 <strncpy+0x23>
		*dst++ = *src;
  800949:	83 c2 01             	add    $0x1,%edx
  80094c:	0f b6 01             	movzbl (%ecx),%eax
  80094f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800952:	80 39 01             	cmpb   $0x1,(%ecx)
  800955:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800958:	39 da                	cmp    %ebx,%edx
  80095a:	75 ed                	jne    800949 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095c:	89 f0                	mov    %esi,%eax
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 75 08             	mov    0x8(%ebp),%esi
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096d:	8b 55 10             	mov    0x10(%ebp),%edx
  800970:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800972:	85 d2                	test   %edx,%edx
  800974:	74 21                	je     800997 <strlcpy+0x35>
  800976:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097a:	89 f2                	mov    %esi,%edx
  80097c:	eb 09                	jmp    800987 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097e:	83 c2 01             	add    $0x1,%edx
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800987:	39 c2                	cmp    %eax,%edx
  800989:	74 09                	je     800994 <strlcpy+0x32>
  80098b:	0f b6 19             	movzbl (%ecx),%ebx
  80098e:	84 db                	test   %bl,%bl
  800990:	75 ec                	jne    80097e <strlcpy+0x1c>
  800992:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800994:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800997:	29 f0                	sub    %esi,%eax
}
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a6:	eb 06                	jmp    8009ae <strcmp+0x11>
		p++, q++;
  8009a8:	83 c1 01             	add    $0x1,%ecx
  8009ab:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ae:	0f b6 01             	movzbl (%ecx),%eax
  8009b1:	84 c0                	test   %al,%al
  8009b3:	74 04                	je     8009b9 <strcmp+0x1c>
  8009b5:	3a 02                	cmp    (%edx),%al
  8009b7:	74 ef                	je     8009a8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b9:	0f b6 c0             	movzbl %al,%eax
  8009bc:	0f b6 12             	movzbl (%edx),%edx
  8009bf:	29 d0                	sub    %edx,%eax
}
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 c3                	mov    %eax,%ebx
  8009cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d2:	eb 06                	jmp    8009da <strncmp+0x17>
		n--, p++, q++;
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009da:	39 d8                	cmp    %ebx,%eax
  8009dc:	74 15                	je     8009f3 <strncmp+0x30>
  8009de:	0f b6 08             	movzbl (%eax),%ecx
  8009e1:	84 c9                	test   %cl,%cl
  8009e3:	74 04                	je     8009e9 <strncmp+0x26>
  8009e5:	3a 0a                	cmp    (%edx),%cl
  8009e7:	74 eb                	je     8009d4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e9:	0f b6 00             	movzbl (%eax),%eax
  8009ec:	0f b6 12             	movzbl (%edx),%edx
  8009ef:	29 d0                	sub    %edx,%eax
  8009f1:	eb 05                	jmp    8009f8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	eb 07                	jmp    800a0e <strchr+0x13>
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	74 0f                	je     800a1a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	84 d2                	test   %dl,%dl
  800a13:	75 f2                	jne    800a07 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a26:	eb 03                	jmp    800a2b <strfind+0xf>
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2e:	38 ca                	cmp    %cl,%dl
  800a30:	74 04                	je     800a36 <strfind+0x1a>
  800a32:	84 d2                	test   %dl,%dl
  800a34:	75 f2                	jne    800a28 <strfind+0xc>
			break;
	return (char *) s;
}
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a44:	85 c9                	test   %ecx,%ecx
  800a46:	74 36                	je     800a7e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a48:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4e:	75 28                	jne    800a78 <memset+0x40>
  800a50:	f6 c1 03             	test   $0x3,%cl
  800a53:	75 23                	jne    800a78 <memset+0x40>
		c &= 0xFF;
  800a55:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a59:	89 d3                	mov    %edx,%ebx
  800a5b:	c1 e3 08             	shl    $0x8,%ebx
  800a5e:	89 d6                	mov    %edx,%esi
  800a60:	c1 e6 18             	shl    $0x18,%esi
  800a63:	89 d0                	mov    %edx,%eax
  800a65:	c1 e0 10             	shl    $0x10,%eax
  800a68:	09 f0                	or     %esi,%eax
  800a6a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6c:	89 d8                	mov    %ebx,%eax
  800a6e:	09 d0                	or     %edx,%eax
  800a70:	c1 e9 02             	shr    $0x2,%ecx
  800a73:	fc                   	cld    
  800a74:	f3 ab                	rep stos %eax,%es:(%edi)
  800a76:	eb 06                	jmp    800a7e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	fc                   	cld    
  800a7c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7e:	89 f8                	mov    %edi,%eax
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a93:	39 c6                	cmp    %eax,%esi
  800a95:	73 35                	jae    800acc <memmove+0x47>
  800a97:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9a:	39 d0                	cmp    %edx,%eax
  800a9c:	73 2e                	jae    800acc <memmove+0x47>
		s += n;
		d += n;
  800a9e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	09 fe                	or     %edi,%esi
  800aa5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aab:	75 13                	jne    800ac0 <memmove+0x3b>
  800aad:	f6 c1 03             	test   $0x3,%cl
  800ab0:	75 0e                	jne    800ac0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab2:	83 ef 04             	sub    $0x4,%edi
  800ab5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab8:	c1 e9 02             	shr    $0x2,%ecx
  800abb:	fd                   	std    
  800abc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abe:	eb 09                	jmp    800ac9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac0:	83 ef 01             	sub    $0x1,%edi
  800ac3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac6:	fd                   	std    
  800ac7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac9:	fc                   	cld    
  800aca:	eb 1d                	jmp    800ae9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acc:	89 f2                	mov    %esi,%edx
  800ace:	09 c2                	or     %eax,%edx
  800ad0:	f6 c2 03             	test   $0x3,%dl
  800ad3:	75 0f                	jne    800ae4 <memmove+0x5f>
  800ad5:	f6 c1 03             	test   $0x3,%cl
  800ad8:	75 0a                	jne    800ae4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ada:	c1 e9 02             	shr    $0x2,%ecx
  800add:	89 c7                	mov    %eax,%edi
  800adf:	fc                   	cld    
  800ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae2:	eb 05                	jmp    800ae9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae4:	89 c7                	mov    %eax,%edi
  800ae6:	fc                   	cld    
  800ae7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af0:	ff 75 10             	pushl  0x10(%ebp)
  800af3:	ff 75 0c             	pushl  0xc(%ebp)
  800af6:	ff 75 08             	pushl  0x8(%ebp)
  800af9:	e8 87 ff ff ff       	call   800a85 <memmove>
}
  800afe:	c9                   	leave  
  800aff:	c3                   	ret    

00800b00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
  800b08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0b:	89 c6                	mov    %eax,%esi
  800b0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b10:	eb 1a                	jmp    800b2c <memcmp+0x2c>
		if (*s1 != *s2)
  800b12:	0f b6 08             	movzbl (%eax),%ecx
  800b15:	0f b6 1a             	movzbl (%edx),%ebx
  800b18:	38 d9                	cmp    %bl,%cl
  800b1a:	74 0a                	je     800b26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1c:	0f b6 c1             	movzbl %cl,%eax
  800b1f:	0f b6 db             	movzbl %bl,%ebx
  800b22:	29 d8                	sub    %ebx,%eax
  800b24:	eb 0f                	jmp    800b35 <memcmp+0x35>
		s1++, s2++;
  800b26:	83 c0 01             	add    $0x1,%eax
  800b29:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2c:	39 f0                	cmp    %esi,%eax
  800b2e:	75 e2                	jne    800b12 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	53                   	push   %ebx
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b40:	89 c1                	mov    %eax,%ecx
  800b42:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b45:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b49:	eb 0a                	jmp    800b55 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4b:	0f b6 10             	movzbl (%eax),%edx
  800b4e:	39 da                	cmp    %ebx,%edx
  800b50:	74 07                	je     800b59 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	39 c8                	cmp    %ecx,%eax
  800b57:	72 f2                	jb     800b4b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b68:	eb 03                	jmp    800b6d <strtol+0x11>
		s++;
  800b6a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6d:	0f b6 01             	movzbl (%ecx),%eax
  800b70:	3c 20                	cmp    $0x20,%al
  800b72:	74 f6                	je     800b6a <strtol+0xe>
  800b74:	3c 09                	cmp    $0x9,%al
  800b76:	74 f2                	je     800b6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b78:	3c 2b                	cmp    $0x2b,%al
  800b7a:	75 0a                	jne    800b86 <strtol+0x2a>
		s++;
  800b7c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b84:	eb 11                	jmp    800b97 <strtol+0x3b>
  800b86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8b:	3c 2d                	cmp    $0x2d,%al
  800b8d:	75 08                	jne    800b97 <strtol+0x3b>
		s++, neg = 1;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9d:	75 15                	jne    800bb4 <strtol+0x58>
  800b9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba2:	75 10                	jne    800bb4 <strtol+0x58>
  800ba4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba8:	75 7c                	jne    800c26 <strtol+0xca>
		s += 2, base = 16;
  800baa:	83 c1 02             	add    $0x2,%ecx
  800bad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb2:	eb 16                	jmp    800bca <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb4:	85 db                	test   %ebx,%ebx
  800bb6:	75 12                	jne    800bca <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc0:	75 08                	jne    800bca <strtol+0x6e>
		s++, base = 8;
  800bc2:	83 c1 01             	add    $0x1,%ecx
  800bc5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd2:	0f b6 11             	movzbl (%ecx),%edx
  800bd5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd8:	89 f3                	mov    %esi,%ebx
  800bda:	80 fb 09             	cmp    $0x9,%bl
  800bdd:	77 08                	ja     800be7 <strtol+0x8b>
			dig = *s - '0';
  800bdf:	0f be d2             	movsbl %dl,%edx
  800be2:	83 ea 30             	sub    $0x30,%edx
  800be5:	eb 22                	jmp    800c09 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bea:	89 f3                	mov    %esi,%ebx
  800bec:	80 fb 19             	cmp    $0x19,%bl
  800bef:	77 08                	ja     800bf9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf1:	0f be d2             	movsbl %dl,%edx
  800bf4:	83 ea 57             	sub    $0x57,%edx
  800bf7:	eb 10                	jmp    800c09 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfc:	89 f3                	mov    %esi,%ebx
  800bfe:	80 fb 19             	cmp    $0x19,%bl
  800c01:	77 16                	ja     800c19 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c03:	0f be d2             	movsbl %dl,%edx
  800c06:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c09:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0c:	7d 0b                	jge    800c19 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c0e:	83 c1 01             	add    $0x1,%ecx
  800c11:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c15:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c17:	eb b9                	jmp    800bd2 <strtol+0x76>

	if (endptr)
  800c19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1d:	74 0d                	je     800c2c <strtol+0xd0>
		*endptr = (char *) s;
  800c1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c22:	89 0e                	mov    %ecx,(%esi)
  800c24:	eb 06                	jmp    800c2c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c26:	85 db                	test   %ebx,%ebx
  800c28:	74 98                	je     800bc2 <strtol+0x66>
  800c2a:	eb 9e                	jmp    800bca <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2c:	89 c2                	mov    %eax,%edx
  800c2e:	f7 da                	neg    %edx
  800c30:	85 ff                	test   %edi,%edi
  800c32:	0f 45 c2             	cmovne %edx,%eax
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 c3                	mov    %eax,%ebx
  800c4d:	89 c7                	mov    %eax,%edi
  800c4f:	89 c6                	mov    %eax,%esi
  800c51:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c63:	b8 01 00 00 00       	mov    $0x1,%eax
  800c68:	89 d1                	mov    %edx,%ecx
  800c6a:	89 d3                	mov    %edx,%ebx
  800c6c:	89 d7                	mov    %edx,%edi
  800c6e:	89 d6                	mov    %edx,%esi
  800c70:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c85:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 cb                	mov    %ecx,%ebx
  800c8f:	89 cf                	mov    %ecx,%edi
  800c91:	89 ce                	mov    %ecx,%esi
  800c93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 17                	jle    800cb0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 03                	push   $0x3
  800c9f:	68 7f 27 80 00       	push   $0x80277f
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 9c 27 80 00       	push   $0x80279c
  800cab:	e8 e5 f5 ff ff       	call   800295 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc3:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc8:	89 d1                	mov    %edx,%ecx
  800cca:	89 d3                	mov    %edx,%ebx
  800ccc:	89 d7                	mov    %edx,%edi
  800cce:	89 d6                	mov    %edx,%esi
  800cd0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_yield>:

void
sys_yield(void)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce7:	89 d1                	mov    %edx,%ecx
  800ce9:	89 d3                	mov    %edx,%ebx
  800ceb:	89 d7                	mov    %edx,%edi
  800ced:	89 d6                	mov    %edx,%esi
  800cef:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	be 00 00 00 00       	mov    $0x0,%esi
  800d04:	b8 04 00 00 00       	mov    $0x4,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d12:	89 f7                	mov    %esi,%edi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 17                	jle    800d31 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 04                	push   $0x4
  800d20:	68 7f 27 80 00       	push   $0x80277f
  800d25:	6a 23                	push   $0x23
  800d27:	68 9c 27 80 00       	push   $0x80279c
  800d2c:	e8 64 f5 ff ff       	call   800295 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b8 05 00 00 00       	mov    $0x5,%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d53:	8b 75 18             	mov    0x18(%ebp),%esi
  800d56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 17                	jle    800d73 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	50                   	push   %eax
  800d60:	6a 05                	push   $0x5
  800d62:	68 7f 27 80 00       	push   $0x80277f
  800d67:	6a 23                	push   $0x23
  800d69:	68 9c 27 80 00       	push   $0x80279c
  800d6e:	e8 22 f5 ff ff       	call   800295 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	b8 06 00 00 00       	mov    $0x6,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7e 17                	jle    800db5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 06                	push   $0x6
  800da4:	68 7f 27 80 00       	push   $0x80277f
  800da9:	6a 23                	push   $0x23
  800dab:	68 9c 27 80 00       	push   $0x80279c
  800db0:	e8 e0 f4 ff ff       	call   800295 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 17                	jle    800df7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 08                	push   $0x8
  800de6:	68 7f 27 80 00       	push   $0x80277f
  800deb:	6a 23                	push   $0x23
  800ded:	68 9c 27 80 00       	push   $0x80279c
  800df2:	e8 9e f4 ff ff       	call   800295 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	89 df                	mov    %ebx,%edi
  800e1a:	89 de                	mov    %ebx,%esi
  800e1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	7e 17                	jle    800e39 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	6a 09                	push   $0x9
  800e28:	68 7f 27 80 00       	push   $0x80277f
  800e2d:	6a 23                	push   $0x23
  800e2f:	68 9c 27 80 00       	push   $0x80279c
  800e34:	e8 5c f4 ff ff       	call   800295 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e57:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5a:	89 df                	mov    %ebx,%edi
  800e5c:	89 de                	mov    %ebx,%esi
  800e5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7e 17                	jle    800e7b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	50                   	push   %eax
  800e68:	6a 0a                	push   $0xa
  800e6a:	68 7f 27 80 00       	push   $0x80277f
  800e6f:	6a 23                	push   $0x23
  800e71:	68 9c 27 80 00       	push   $0x80279c
  800e76:	e8 1a f4 ff ff       	call   800295 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	be 00 00 00 00       	mov    $0x0,%esi
  800e8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 cb                	mov    %ecx,%ebx
  800ebe:	89 cf                	mov    %ecx,%edi
  800ec0:	89 ce                	mov    %ecx,%esi
  800ec2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 17                	jle    800edf <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	50                   	push   %eax
  800ecc:	6a 0d                	push   $0xd
  800ece:	68 7f 27 80 00       	push   $0x80277f
  800ed3:	6a 23                	push   $0x23
  800ed5:	68 9c 27 80 00       	push   $0x80279c
  800eda:	e8 b6 f3 ff ff       	call   800295 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	89 cb                	mov    %ecx,%ebx
  800efc:	89 cf                	mov    %ecx,%edi
  800efe:	89 ce                	mov    %ecx,%esi
  800f00:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f11:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f13:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f17:	74 11                	je     800f2a <pgfault+0x23>
  800f19:	89 d8                	mov    %ebx,%eax
  800f1b:	c1 e8 0c             	shr    $0xc,%eax
  800f1e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f25:	f6 c4 08             	test   $0x8,%ah
  800f28:	75 14                	jne    800f3e <pgfault+0x37>
		panic("faulting access");
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	68 aa 27 80 00       	push   $0x8027aa
  800f32:	6a 1d                	push   $0x1d
  800f34:	68 ba 27 80 00       	push   $0x8027ba
  800f39:	e8 57 f3 ff ff       	call   800295 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	6a 07                	push   $0x7
  800f43:	68 00 f0 7f 00       	push   $0x7ff000
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 a7 fd ff ff       	call   800cf6 <sys_page_alloc>
	if (r < 0) {
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 12                	jns    800f68 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f56:	50                   	push   %eax
  800f57:	68 c5 27 80 00       	push   $0x8027c5
  800f5c:	6a 2b                	push   $0x2b
  800f5e:	68 ba 27 80 00       	push   $0x8027ba
  800f63:	e8 2d f3 ff ff       	call   800295 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f68:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	68 00 10 00 00       	push   $0x1000
  800f76:	53                   	push   %ebx
  800f77:	68 00 f0 7f 00       	push   $0x7ff000
  800f7c:	e8 6c fb ff ff       	call   800aed <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f81:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f88:	53                   	push   %ebx
  800f89:	6a 00                	push   $0x0
  800f8b:	68 00 f0 7f 00       	push   $0x7ff000
  800f90:	6a 00                	push   $0x0
  800f92:	e8 a2 fd ff ff       	call   800d39 <sys_page_map>
	if (r < 0) {
  800f97:	83 c4 20             	add    $0x20,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	79 12                	jns    800fb0 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f9e:	50                   	push   %eax
  800f9f:	68 c5 27 80 00       	push   $0x8027c5
  800fa4:	6a 32                	push   $0x32
  800fa6:	68 ba 27 80 00       	push   $0x8027ba
  800fab:	e8 e5 f2 ff ff       	call   800295 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	68 00 f0 7f 00       	push   $0x7ff000
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 bc fd ff ff       	call   800d7b <sys_page_unmap>
	if (r < 0) {
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	79 12                	jns    800fd8 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fc6:	50                   	push   %eax
  800fc7:	68 c5 27 80 00       	push   $0x8027c5
  800fcc:	6a 36                	push   $0x36
  800fce:	68 ba 27 80 00       	push   $0x8027ba
  800fd3:	e8 bd f2 ff ff       	call   800295 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fe6:	68 07 0f 80 00       	push   $0x800f07
  800feb:	e8 e9 0e 00 00       	call   801ed9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ff0:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff5:	cd 30                	int    $0x30
  800ff7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	79 17                	jns    801018 <fork+0x3b>
		panic("fork fault %e");
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	68 de 27 80 00       	push   $0x8027de
  801009:	68 83 00 00 00       	push   $0x83
  80100e:	68 ba 27 80 00       	push   $0x8027ba
  801013:	e8 7d f2 ff ff       	call   800295 <_panic>
  801018:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80101a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80101e:	75 25                	jne    801045 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801020:	e8 93 fc ff ff       	call   800cb8 <sys_getenvid>
  801025:	25 ff 03 00 00       	and    $0x3ff,%eax
  80102a:	89 c2                	mov    %eax,%edx
  80102c:	c1 e2 07             	shl    $0x7,%edx
  80102f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801036:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80103b:	b8 00 00 00 00       	mov    $0x0,%eax
  801040:	e9 61 01 00 00       	jmp    8011a6 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	6a 07                	push   $0x7
  80104a:	68 00 f0 bf ee       	push   $0xeebff000
  80104f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801052:	e8 9f fc ff ff       	call   800cf6 <sys_page_alloc>
  801057:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80105a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80105f:	89 d8                	mov    %ebx,%eax
  801061:	c1 e8 16             	shr    $0x16,%eax
  801064:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106b:	a8 01                	test   $0x1,%al
  80106d:	0f 84 fc 00 00 00    	je     80116f <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801073:	89 d8                	mov    %ebx,%eax
  801075:	c1 e8 0c             	shr    $0xc,%eax
  801078:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80107f:	f6 c2 01             	test   $0x1,%dl
  801082:	0f 84 e7 00 00 00    	je     80116f <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801088:	89 c6                	mov    %eax,%esi
  80108a:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80108d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801094:	f6 c6 04             	test   $0x4,%dh
  801097:	74 39                	je     8010d2 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801099:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a8:	50                   	push   %eax
  8010a9:	56                   	push   %esi
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 86 fc ff ff       	call   800d39 <sys_page_map>
		if (r < 0) {
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	0f 89 b1 00 00 00    	jns    80116f <fork+0x192>
		    	panic("sys page map fault %e");
  8010be:	83 ec 04             	sub    $0x4,%esp
  8010c1:	68 ec 27 80 00       	push   $0x8027ec
  8010c6:	6a 53                	push   $0x53
  8010c8:	68 ba 27 80 00       	push   $0x8027ba
  8010cd:	e8 c3 f1 ff ff       	call   800295 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d9:	f6 c2 02             	test   $0x2,%dl
  8010dc:	75 0c                	jne    8010ea <fork+0x10d>
  8010de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e5:	f6 c4 08             	test   $0x8,%ah
  8010e8:	74 5b                	je     801145 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	68 05 08 00 00       	push   $0x805
  8010f2:	56                   	push   %esi
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	6a 00                	push   $0x0
  8010f7:	e8 3d fc ff ff       	call   800d39 <sys_page_map>
		if (r < 0) {
  8010fc:	83 c4 20             	add    $0x20,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	79 14                	jns    801117 <fork+0x13a>
		    	panic("sys page map fault %e");
  801103:	83 ec 04             	sub    $0x4,%esp
  801106:	68 ec 27 80 00       	push   $0x8027ec
  80110b:	6a 5a                	push   $0x5a
  80110d:	68 ba 27 80 00       	push   $0x8027ba
  801112:	e8 7e f1 ff ff       	call   800295 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	68 05 08 00 00       	push   $0x805
  80111f:	56                   	push   %esi
  801120:	6a 00                	push   $0x0
  801122:	56                   	push   %esi
  801123:	6a 00                	push   $0x0
  801125:	e8 0f fc ff ff       	call   800d39 <sys_page_map>
		if (r < 0) {
  80112a:	83 c4 20             	add    $0x20,%esp
  80112d:	85 c0                	test   %eax,%eax
  80112f:	79 3e                	jns    80116f <fork+0x192>
		    	panic("sys page map fault %e");
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	68 ec 27 80 00       	push   $0x8027ec
  801139:	6a 5e                	push   $0x5e
  80113b:	68 ba 27 80 00       	push   $0x8027ba
  801140:	e8 50 f1 ff ff       	call   800295 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	6a 05                	push   $0x5
  80114a:	56                   	push   %esi
  80114b:	57                   	push   %edi
  80114c:	56                   	push   %esi
  80114d:	6a 00                	push   $0x0
  80114f:	e8 e5 fb ff ff       	call   800d39 <sys_page_map>
		if (r < 0) {
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	79 14                	jns    80116f <fork+0x192>
		    	panic("sys page map fault %e");
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	68 ec 27 80 00       	push   $0x8027ec
  801163:	6a 63                	push   $0x63
  801165:	68 ba 27 80 00       	push   $0x8027ba
  80116a:	e8 26 f1 ff ff       	call   800295 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80116f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801175:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80117b:	0f 85 de fe ff ff    	jne    80105f <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801181:	a1 04 40 80 00       	mov    0x804004,%eax
  801186:	8b 40 6c             	mov    0x6c(%eax),%eax
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	50                   	push   %eax
  80118d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801190:	57                   	push   %edi
  801191:	e8 ab fc ff ff       	call   800e41 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801196:	83 c4 08             	add    $0x8,%esp
  801199:	6a 02                	push   $0x2
  80119b:	57                   	push   %edi
  80119c:	e8 1c fc ff ff       	call   800dbd <sys_env_set_status>
	
	return envid;
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <sfork>:

envid_t
sfork(void)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	53                   	push   %ebx
  8011c4:	68 04 28 80 00       	push   $0x802804
  8011c9:	e8 a0 f1 ff ff       	call   80036e <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  8011ce:	89 1c 24             	mov    %ebx,(%esp)
  8011d1:	e8 11 fd ff ff       	call   800ee7 <sys_thread_create>
  8011d6:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	53                   	push   %ebx
  8011dc:	68 04 28 80 00       	push   $0x802804
  8011e1:	e8 88 f1 ff ff       	call   80036e <cprintf>
	return id;
}
  8011e6:	89 f0                	mov    %esi,%eax
  8011e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

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
  8012c4:	ba a8 28 80 00       	mov    $0x8028a8,%edx
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
  8012e9:	8b 40 50             	mov    0x50(%eax),%eax
  8012ec:	83 ec 04             	sub    $0x4,%esp
  8012ef:	51                   	push   %ecx
  8012f0:	50                   	push   %eax
  8012f1:	68 28 28 80 00       	push   $0x802828
  8012f6:	e8 73 f0 ff ff       	call   80036e <cprintf>
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
  80137e:	e8 f8 f9 ff ff       	call   800d7b <sys_page_unmap>
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
  80146a:	e8 ca f8 ff ff       	call   800d39 <sys_page_map>
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
  801496:	e8 9e f8 ff ff       	call   800d39 <sys_page_map>
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
  8014ac:	e8 ca f8 ff ff       	call   800d7b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 bd f8 ff ff       	call   800d7b <sys_page_unmap>
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
  801513:	8b 40 50             	mov    0x50(%eax),%eax
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	53                   	push   %ebx
  80151a:	50                   	push   %eax
  80151b:	68 6c 28 80 00       	push   $0x80286c
  801520:	e8 49 ee ff ff       	call   80036e <cprintf>
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
  8015e8:	8b 40 50             	mov    0x50(%eax),%eax
  8015eb:	83 ec 04             	sub    $0x4,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	50                   	push   %eax
  8015f0:	68 88 28 80 00       	push   $0x802888
  8015f5:	e8 74 ed ff ff       	call   80036e <cprintf>
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
  80169d:	8b 40 50             	mov    0x50(%eax),%eax
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	53                   	push   %ebx
  8016a4:	50                   	push   %eax
  8016a5:	68 48 28 80 00       	push   $0x802848
  8016aa:	e8 bf ec ff ff       	call   80036e <cprintf>
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
  8017b5:	e8 85 08 00 00       	call   80203f <ipc_find_env>
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
  8017d0:	e8 08 08 00 00       	call   801fdd <ipc_send>
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
  801866:	e8 88 f0 ff ff       	call   8008f3 <strcpy>
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
  8018be:	e8 c2 f1 ff ff       	call   800a85 <memmove>

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
  801906:	68 b8 28 80 00       	push   $0x8028b8
  80190b:	68 bf 28 80 00       	push   $0x8028bf
  801910:	6a 7c                	push   $0x7c
  801912:	68 d4 28 80 00       	push   $0x8028d4
  801917:	e8 79 e9 ff ff       	call   800295 <_panic>
	assert(r <= PGSIZE);
  80191c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801921:	7e 16                	jle    801939 <devfile_read+0x65>
  801923:	68 df 28 80 00       	push   $0x8028df
  801928:	68 bf 28 80 00       	push   $0x8028bf
  80192d:	6a 7d                	push   $0x7d
  80192f:	68 d4 28 80 00       	push   $0x8028d4
  801934:	e8 5c e9 ff ff       	call   800295 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	50                   	push   %eax
  80193d:	68 00 50 80 00       	push   $0x805000
  801942:	ff 75 0c             	pushl  0xc(%ebp)
  801945:	e8 3b f1 ff ff       	call   800a85 <memmove>
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
  801961:	e8 54 ef ff ff       	call   8008ba <strlen>
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
  80198e:	e8 60 ef ff ff       	call   8008f3 <strcpy>
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
  801a12:	68 eb 28 80 00       	push   $0x8028eb
  801a17:	53                   	push   %ebx
  801a18:	e8 d6 ee ff ff       	call   8008f3 <strcpy>
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
  801a55:	e8 21 f3 ff ff       	call   800d7b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5a:	89 1c 24             	mov    %ebx,(%esp)
  801a5d:	e8 9d f7 ff ff       	call   8011ff <fd2data>
  801a62:	83 c4 08             	add    $0x8,%esp
  801a65:	50                   	push   %eax
  801a66:	6a 00                	push   $0x0
  801a68:	e8 0e f3 ff ff       	call   800d7b <sys_page_unmap>
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
  801a85:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a8e:	e8 ec 05 00 00       	call   80207f <pageref>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	89 3c 24             	mov    %edi,(%esp)
  801a98:	e8 e2 05 00 00       	call   80207f <pageref>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	39 c3                	cmp    %eax,%ebx
  801aa2:	0f 94 c1             	sete   %cl
  801aa5:	0f b6 c9             	movzbl %cl,%ecx
  801aa8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aab:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ab1:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801ab4:	39 ce                	cmp    %ecx,%esi
  801ab6:	74 1b                	je     801ad3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ab8:	39 c3                	cmp    %eax,%ebx
  801aba:	75 c4                	jne    801a80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abc:	8b 42 60             	mov    0x60(%edx),%eax
  801abf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac2:	50                   	push   %eax
  801ac3:	56                   	push   %esi
  801ac4:	68 f2 28 80 00       	push   $0x8028f2
  801ac9:	e8 a0 e8 ff ff       	call   80036e <cprintf>
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
  801b09:	e8 c9 f1 ff ff       	call   800cd7 <sys_yield>
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
  801b91:	e8 41 f1 ff ff       	call   800cd7 <sys_yield>
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
  801bfb:	e8 f6 f0 ff ff       	call   800cf6 <sys_page_alloc>
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
  801c33:	e8 be f0 ff ff       	call   800cf6 <sys_page_alloc>
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
  801c5d:	e8 94 f0 ff ff       	call   800cf6 <sys_page_alloc>
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
  801c87:	e8 ad f0 ff ff       	call   800d39 <sys_page_map>
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
  801cf0:	e8 86 f0 ff ff       	call   800d7b <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 76 f0 ff ff       	call   800d7b <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 66 f0 ff ff       	call   800d7b <sys_page_unmap>
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
  801d66:	68 0a 29 80 00       	push   $0x80290a
  801d6b:	ff 75 0c             	pushl  0xc(%ebp)
  801d6e:	e8 80 eb ff ff       	call   8008f3 <strcpy>
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
  801dac:	e8 d4 ec ff ff       	call   800a85 <memmove>
		sys_cputs(buf, m);
  801db1:	83 c4 08             	add    $0x8,%esp
  801db4:	53                   	push   %ebx
  801db5:	57                   	push   %edi
  801db6:	e8 7f ee ff ff       	call   800c3a <sys_cputs>
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
  801de2:	e8 f0 ee ff ff       	call   800cd7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de7:	e8 6c ee ff ff       	call   800c58 <sys_cgetc>
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
  801e1e:	e8 17 ee ff ff       	call   800c3a <sys_cputs>
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
  801ea4:	e8 4d ee ff ff       	call   800cf6 <sys_page_alloc>
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
  801ef4:	e8 fd ed ff ff       	call   800cf6 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	79 12                	jns    801f12 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f00:	50                   	push   %eax
  801f01:	68 16 29 80 00       	push   $0x802916
  801f06:	6a 23                	push   $0x23
  801f08:	68 1a 29 80 00       	push   $0x80291a
  801f0d:	e8 83 e3 ff ff       	call   800295 <_panic>
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
  801f24:	e8 18 ef ff ff       	call   800e41 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	79 12                	jns    801f42 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f30:	50                   	push   %eax
  801f31:	68 16 29 80 00       	push   $0x802916
  801f36:	6a 2c                	push   $0x2c
  801f38:	68 1a 29 80 00       	push   $0x80291a
  801f3d:	e8 53 e3 ff ff       	call   800295 <_panic>
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
  801f82:	e8 1f ef ff ff       	call   800ea6 <sys_ipc_recv>
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	eb 0c                	jmp    801f98 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f8c:	83 ec 0c             	sub    $0xc,%esp
  801f8f:	50                   	push   %eax
  801f90:	e8 11 ef ff ff       	call   800ea6 <sys_ipc_recv>
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
  801fad:	75 27                	jne    801fd6 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801faf:	85 f6                	test   %esi,%esi
  801fb1:	74 0a                	je     801fbd <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801fb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb8:	8b 40 7c             	mov    0x7c(%eax),%eax
  801fbb:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801fbd:	85 db                	test   %ebx,%ebx
  801fbf:	74 0d                	je     801fce <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801fc1:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801fcc:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fce:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd3:	8b 40 78             	mov    0x78(%eax),%eax
}
  801fd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd9:	5b                   	pop    %ebx
  801fda:	5e                   	pop    %esi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	57                   	push   %edi
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801fef:	85 db                	test   %ebx,%ebx
  801ff1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ff6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ff9:	ff 75 14             	pushl  0x14(%ebp)
  801ffc:	53                   	push   %ebx
  801ffd:	56                   	push   %esi
  801ffe:	57                   	push   %edi
  801fff:	e8 7f ee ff ff       	call   800e83 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802004:	89 c2                	mov    %eax,%edx
  802006:	c1 ea 1f             	shr    $0x1f,%edx
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	84 d2                	test   %dl,%dl
  80200e:	74 17                	je     802027 <ipc_send+0x4a>
  802010:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802013:	74 12                	je     802027 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802015:	50                   	push   %eax
  802016:	68 28 29 80 00       	push   $0x802928
  80201b:	6a 47                	push   $0x47
  80201d:	68 36 29 80 00       	push   $0x802936
  802022:	e8 6e e2 ff ff       	call   800295 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802027:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80202a:	75 07                	jne    802033 <ipc_send+0x56>
			sys_yield();
  80202c:	e8 a6 ec ff ff       	call   800cd7 <sys_yield>
  802031:	eb c6                	jmp    801ff9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802033:	85 c0                	test   %eax,%eax
  802035:	75 c2                	jne    801ff9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80204a:	89 c2                	mov    %eax,%edx
  80204c:	c1 e2 07             	shl    $0x7,%edx
  80204f:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802056:	8b 52 58             	mov    0x58(%edx),%edx
  802059:	39 ca                	cmp    %ecx,%edx
  80205b:	75 11                	jne    80206e <ipc_find_env+0x2f>
			return envs[i].env_id;
  80205d:	89 c2                	mov    %eax,%edx
  80205f:	c1 e2 07             	shl    $0x7,%edx
  802062:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  802069:	8b 40 50             	mov    0x50(%eax),%eax
  80206c:	eb 0f                	jmp    80207d <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80206e:	83 c0 01             	add    $0x1,%eax
  802071:	3d 00 04 00 00       	cmp    $0x400,%eax
  802076:	75 d2                	jne    80204a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802078:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802085:	89 d0                	mov    %edx,%eax
  802087:	c1 e8 16             	shr    $0x16,%eax
  80208a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802091:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802096:	f6 c1 01             	test   $0x1,%cl
  802099:	74 1d                	je     8020b8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80209b:	c1 ea 0c             	shr    $0xc,%edx
  80209e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020a5:	f6 c2 01             	test   $0x1,%dl
  8020a8:	74 0e                	je     8020b8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020aa:	c1 ea 0c             	shr    $0xc,%edx
  8020ad:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020b4:	ef 
  8020b5:	0f b7 c0             	movzwl %ax,%eax
}
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
