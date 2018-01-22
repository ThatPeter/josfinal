
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 4d 08 00 00       	call   800896 <strcpy>
	exit();
  800049:	e8 d0 01 00 00       	call   80021e <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 20 0c 00 00       	call   800c99 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 2c 29 80 00       	push   $0x80292c
  800086:	6a 13                	push   $0x13
  800088:	68 3f 29 80 00       	push   $0x80293f
  80008d:	e8 a6 01 00 00       	call   800238 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 e9 0e 00 00       	call   800f80 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 53 29 80 00       	push   $0x802953
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 3f 29 80 00       	push   $0x80293f
  8000aa:	e8 89 01 00 00       	call   800238 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 d0 07 00 00       	call   800896 <strcpy>
		exit();
  8000c6:	e8 53 01 00 00       	call   80021e <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 04 22 00 00       	call   8022db <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 56 08 00 00       	call   800940 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 26 29 80 00       	mov    $0x802926,%edx
  8000f4:	b8 20 29 80 00       	mov    $0x802920,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 5c 29 80 00       	push   $0x80295c
  800102:	e8 0a 02 00 00       	call   800311 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 77 29 80 00       	push   $0x802977
  80010e:	68 7c 29 80 00       	push   $0x80297c
  800113:	68 7b 29 80 00       	push   $0x80297b
  800118:	e8 ef 1d 00 00       	call   801f0c <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 89 29 80 00       	push   $0x802989
  80012a:	6a 21                	push   $0x21
  80012c:	68 3f 29 80 00       	push   $0x80293f
  800131:	e8 02 01 00 00       	call   800238 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 9c 21 00 00       	call   8022db <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 ee 07 00 00       	call   800940 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 26 29 80 00       	mov    $0x802926,%edx
  80015c:	b8 20 29 80 00       	mov    $0x802920,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 93 29 80 00       	push   $0x802993
  80016a:	e8 a2 01 00 00       	call   800311 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800181:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800188:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80018b:	e8 cb 0a 00 00       	call   800c5b <sys_getenvid>
  800190:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 d0 29 80 00       	push   $0x8029d0
  80019b:	e8 71 01 00 00       	call   800311 <cprintf>
  8001a0:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8001a6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8001ab:	83 c4 10             	add    $0x10,%esp
  8001ae:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001b3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8001b8:	89 c1                	mov    %eax,%ecx
  8001ba:	c1 e1 07             	shl    $0x7,%ecx
  8001bd:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8001c4:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8001c7:	39 cb                	cmp    %ecx,%ebx
  8001c9:	0f 44 fa             	cmove  %edx,%edi
  8001cc:	b9 01 00 00 00       	mov    $0x1,%ecx
  8001d1:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001d4:	83 c0 01             	add    $0x1,%eax
  8001d7:	81 c2 84 00 00 00    	add    $0x84,%edx
  8001dd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8001e2:	75 d4                	jne    8001b8 <libmain+0x40>
  8001e4:	89 f0                	mov    %esi,%eax
  8001e6:	84 c0                	test   %al,%al
  8001e8:	74 06                	je     8001f0 <libmain+0x78>
  8001ea:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8001f4:	7e 0a                	jle    800200 <libmain+0x88>
		binaryname = argv[0];
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	8b 00                	mov    (%eax),%eax
  8001fb:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 45 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  80020e:	e8 0b 00 00 00       	call   80021e <exit>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800219:	5b                   	pop    %ebx
  80021a:	5e                   	pop    %esi
  80021b:	5f                   	pop    %edi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800224:	e8 34 11 00 00       	call   80135d <close_all>
	sys_env_destroy(0);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	6a 00                	push   $0x0
  80022e:	e8 e7 09 00 00       	call   800c1a <sys_env_destroy>
}
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800240:	8b 35 08 30 80 00    	mov    0x803008,%esi
  800246:	e8 10 0a 00 00       	call   800c5b <sys_getenvid>
  80024b:	83 ec 0c             	sub    $0xc,%esp
  80024e:	ff 75 0c             	pushl  0xc(%ebp)
  800251:	ff 75 08             	pushl  0x8(%ebp)
  800254:	56                   	push   %esi
  800255:	50                   	push   %eax
  800256:	68 fc 29 80 00       	push   $0x8029fc
  80025b:	e8 b1 00 00 00       	call   800311 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	53                   	push   %ebx
  800264:	ff 75 10             	pushl  0x10(%ebp)
  800267:	e8 54 00 00 00       	call   8002c0 <vcprintf>
	cprintf("\n");
  80026c:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  800273:	e8 99 00 00 00       	call   800311 <cprintf>
  800278:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027b:	cc                   	int3   
  80027c:	eb fd                	jmp    80027b <_panic+0x43>

0080027e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	53                   	push   %ebx
  800282:	83 ec 04             	sub    $0x4,%esp
  800285:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800288:	8b 13                	mov    (%ebx),%edx
  80028a:	8d 42 01             	lea    0x1(%edx),%eax
  80028d:	89 03                	mov    %eax,(%ebx)
  80028f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800292:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800296:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029b:	75 1a                	jne    8002b7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	68 ff 00 00 00       	push   $0xff
  8002a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a8:	50                   	push   %eax
  8002a9:	e8 2f 09 00 00       	call   800bdd <sys_cputs>
		b->idx = 0;
  8002ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d0:	00 00 00 
	b.cnt = 0;
  8002d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002dd:	ff 75 0c             	pushl  0xc(%ebp)
  8002e0:	ff 75 08             	pushl  0x8(%ebp)
  8002e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e9:	50                   	push   %eax
  8002ea:	68 7e 02 80 00       	push   $0x80027e
  8002ef:	e8 54 01 00 00       	call   800448 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f4:	83 c4 08             	add    $0x8,%esp
  8002f7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800303:	50                   	push   %eax
  800304:	e8 d4 08 00 00       	call   800bdd <sys_cputs>

	return b.cnt;
}
  800309:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800317:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 9d ff ff ff       	call   8002c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 1c             	sub    $0x1c,%esp
  80032e:	89 c7                	mov    %eax,%edi
  800330:	89 d6                	mov    %edx,%esi
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	8b 55 0c             	mov    0xc(%ebp),%edx
  800338:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800341:	bb 00 00 00 00       	mov    $0x0,%ebx
  800346:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800349:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034c:	39 d3                	cmp    %edx,%ebx
  80034e:	72 05                	jb     800355 <printnum+0x30>
  800350:	39 45 10             	cmp    %eax,0x10(%ebp)
  800353:	77 45                	ja     80039a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800355:	83 ec 0c             	sub    $0xc,%esp
  800358:	ff 75 18             	pushl  0x18(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800361:	53                   	push   %ebx
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	83 ec 08             	sub    $0x8,%esp
  800368:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036b:	ff 75 e0             	pushl  -0x20(%ebp)
  80036e:	ff 75 dc             	pushl  -0x24(%ebp)
  800371:	ff 75 d8             	pushl  -0x28(%ebp)
  800374:	e8 17 23 00 00       	call   802690 <__udivdi3>
  800379:	83 c4 18             	add    $0x18,%esp
  80037c:	52                   	push   %edx
  80037d:	50                   	push   %eax
  80037e:	89 f2                	mov    %esi,%edx
  800380:	89 f8                	mov    %edi,%eax
  800382:	e8 9e ff ff ff       	call   800325 <printnum>
  800387:	83 c4 20             	add    $0x20,%esp
  80038a:	eb 18                	jmp    8003a4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	56                   	push   %esi
  800390:	ff 75 18             	pushl  0x18(%ebp)
  800393:	ff d7                	call   *%edi
  800395:	83 c4 10             	add    $0x10,%esp
  800398:	eb 03                	jmp    80039d <printnum+0x78>
  80039a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039d:	83 eb 01             	sub    $0x1,%ebx
  8003a0:	85 db                	test   %ebx,%ebx
  8003a2:	7f e8                	jg     80038c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	56                   	push   %esi
  8003a8:	83 ec 04             	sub    $0x4,%esp
  8003ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b7:	e8 04 24 00 00       	call   8027c0 <__umoddi3>
  8003bc:	83 c4 14             	add    $0x14,%esp
  8003bf:	0f be 80 1f 2a 80 00 	movsbl 0x802a1f(%eax),%eax
  8003c6:	50                   	push   %eax
  8003c7:	ff d7                	call   *%edi
}
  8003c9:	83 c4 10             	add    $0x10,%esp
  8003cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cf:	5b                   	pop    %ebx
  8003d0:	5e                   	pop    %esi
  8003d1:	5f                   	pop    %edi
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    

008003d4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d7:	83 fa 01             	cmp    $0x1,%edx
  8003da:	7e 0e                	jle    8003ea <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	8b 52 04             	mov    0x4(%edx),%edx
  8003e8:	eb 22                	jmp    80040c <getuint+0x38>
	else if (lflag)
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	74 10                	je     8003fe <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ee:	8b 10                	mov    (%eax),%edx
  8003f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f3:	89 08                	mov    %ecx,(%eax)
  8003f5:	8b 02                	mov    (%edx),%eax
  8003f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fc:	eb 0e                	jmp    80040c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fe:	8b 10                	mov    (%eax),%edx
  800400:	8d 4a 04             	lea    0x4(%edx),%ecx
  800403:	89 08                	mov    %ecx,(%eax)
  800405:	8b 02                	mov    (%edx),%eax
  800407:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800414:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800418:	8b 10                	mov    (%eax),%edx
  80041a:	3b 50 04             	cmp    0x4(%eax),%edx
  80041d:	73 0a                	jae    800429 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800422:	89 08                	mov    %ecx,(%eax)
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	88 02                	mov    %al,(%edx)
}
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    

0080042b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800431:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800434:	50                   	push   %eax
  800435:	ff 75 10             	pushl  0x10(%ebp)
  800438:	ff 75 0c             	pushl  0xc(%ebp)
  80043b:	ff 75 08             	pushl  0x8(%ebp)
  80043e:	e8 05 00 00 00       	call   800448 <vprintfmt>
	va_end(ap);
}
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 2c             	sub    $0x2c,%esp
  800451:	8b 75 08             	mov    0x8(%ebp),%esi
  800454:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800457:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045a:	eb 12                	jmp    80046e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045c:	85 c0                	test   %eax,%eax
  80045e:	0f 84 89 03 00 00    	je     8007ed <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	53                   	push   %ebx
  800468:	50                   	push   %eax
  800469:	ff d6                	call   *%esi
  80046b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046e:	83 c7 01             	add    $0x1,%edi
  800471:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800475:	83 f8 25             	cmp    $0x25,%eax
  800478:	75 e2                	jne    80045c <vprintfmt+0x14>
  80047a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800485:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800493:	ba 00 00 00 00       	mov    $0x0,%edx
  800498:	eb 07                	jmp    8004a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8d 47 01             	lea    0x1(%edi),%eax
  8004a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a7:	0f b6 07             	movzbl (%edi),%eax
  8004aa:	0f b6 c8             	movzbl %al,%ecx
  8004ad:	83 e8 23             	sub    $0x23,%eax
  8004b0:	3c 55                	cmp    $0x55,%al
  8004b2:	0f 87 1a 03 00 00    	ja     8007d2 <vprintfmt+0x38a>
  8004b8:	0f b6 c0             	movzbl %al,%eax
  8004bb:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c9:	eb d6                	jmp    8004a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004dd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e3:	83 fa 09             	cmp    $0x9,%edx
  8004e6:	77 39                	ja     800521 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004eb:	eb e9                	jmp    8004d6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fe:	eb 27                	jmp    800527 <vprintfmt+0xdf>
  800500:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050a:	0f 49 c8             	cmovns %eax,%ecx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800513:	eb 8c                	jmp    8004a1 <vprintfmt+0x59>
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800518:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051f:	eb 80                	jmp    8004a1 <vprintfmt+0x59>
  800521:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800524:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800527:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052b:	0f 89 70 ff ff ff    	jns    8004a1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800531:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800534:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800537:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053e:	e9 5e ff ff ff       	jmp    8004a1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800543:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800549:	e9 53 ff ff ff       	jmp    8004a1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	ff 30                	pushl  (%eax)
  80055d:	ff d6                	call   *%esi
			break;
  80055f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800565:	e9 04 ff ff ff       	jmp    80046e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 04             	lea    0x4(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 00                	mov    (%eax),%eax
  800575:	99                   	cltd   
  800576:	31 d0                	xor    %edx,%eax
  800578:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057a:	83 f8 0f             	cmp    $0xf,%eax
  80057d:	7f 0b                	jg     80058a <vprintfmt+0x142>
  80057f:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	75 18                	jne    8005a2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058a:	50                   	push   %eax
  80058b:	68 37 2a 80 00       	push   $0x802a37
  800590:	53                   	push   %ebx
  800591:	56                   	push   %esi
  800592:	e8 94 fe ff ff       	call   80042b <printfmt>
  800597:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059d:	e9 cc fe ff ff       	jmp    80046e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a2:	52                   	push   %edx
  8005a3:	68 6d 2e 80 00       	push   $0x802e6d
  8005a8:	53                   	push   %ebx
  8005a9:	56                   	push   %esi
  8005aa:	e8 7c fe ff ff       	call   80042b <printfmt>
  8005af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b5:	e9 b4 fe ff ff       	jmp    80046e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c5:	85 ff                	test   %edi,%edi
  8005c7:	b8 30 2a 80 00       	mov    $0x802a30,%eax
  8005cc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d3:	0f 8e 94 00 00 00    	jle    80066d <vprintfmt+0x225>
  8005d9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005dd:	0f 84 98 00 00 00    	je     80067b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e9:	57                   	push   %edi
  8005ea:	e8 86 02 00 00       	call   800875 <strnlen>
  8005ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f2:	29 c1                	sub    %eax,%ecx
  8005f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800601:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800604:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800606:	eb 0f                	jmp    800617 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	ff 75 e0             	pushl  -0x20(%ebp)
  80060f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800611:	83 ef 01             	sub    $0x1,%edi
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	85 ff                	test   %edi,%edi
  800619:	7f ed                	jg     800608 <vprintfmt+0x1c0>
  80061b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800621:	85 c9                	test   %ecx,%ecx
  800623:	b8 00 00 00 00       	mov    $0x0,%eax
  800628:	0f 49 c1             	cmovns %ecx,%eax
  80062b:	29 c1                	sub    %eax,%ecx
  80062d:	89 75 08             	mov    %esi,0x8(%ebp)
  800630:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800633:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800636:	89 cb                	mov    %ecx,%ebx
  800638:	eb 4d                	jmp    800687 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063e:	74 1b                	je     80065b <vprintfmt+0x213>
  800640:	0f be c0             	movsbl %al,%eax
  800643:	83 e8 20             	sub    $0x20,%eax
  800646:	83 f8 5e             	cmp    $0x5e,%eax
  800649:	76 10                	jbe    80065b <vprintfmt+0x213>
					putch('?', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	ff 75 0c             	pushl  0xc(%ebp)
  800651:	6a 3f                	push   $0x3f
  800653:	ff 55 08             	call   *0x8(%ebp)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 0d                	jmp    800668 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	ff 75 0c             	pushl  0xc(%ebp)
  800661:	52                   	push   %edx
  800662:	ff 55 08             	call   *0x8(%ebp)
  800665:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800668:	83 eb 01             	sub    $0x1,%ebx
  80066b:	eb 1a                	jmp    800687 <vprintfmt+0x23f>
  80066d:	89 75 08             	mov    %esi,0x8(%ebp)
  800670:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800673:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800676:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800679:	eb 0c                	jmp    800687 <vprintfmt+0x23f>
  80067b:	89 75 08             	mov    %esi,0x8(%ebp)
  80067e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800681:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800684:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800687:	83 c7 01             	add    $0x1,%edi
  80068a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068e:	0f be d0             	movsbl %al,%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	74 23                	je     8006b8 <vprintfmt+0x270>
  800695:	85 f6                	test   %esi,%esi
  800697:	78 a1                	js     80063a <vprintfmt+0x1f2>
  800699:	83 ee 01             	sub    $0x1,%esi
  80069c:	79 9c                	jns    80063a <vprintfmt+0x1f2>
  80069e:	89 df                	mov    %ebx,%edi
  8006a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a6:	eb 18                	jmp    8006c0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 20                	push   $0x20
  8006ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b0:	83 ef 01             	sub    $0x1,%edi
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 08                	jmp    8006c0 <vprintfmt+0x278>
  8006b8:	89 df                	mov    %ebx,%edi
  8006ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c0:	85 ff                	test   %edi,%edi
  8006c2:	7f e4                	jg     8006a8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	e9 a2 fd ff ff       	jmp    80046e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cc:	83 fa 01             	cmp    $0x1,%edx
  8006cf:	7e 16                	jle    8006e7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 08             	lea    0x8(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	8b 50 04             	mov    0x4(%eax),%edx
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e5:	eb 32                	jmp    800719 <vprintfmt+0x2d1>
	else if (lflag)
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	74 18                	je     800703 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 50 04             	lea    0x4(%eax),%edx
  8006f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f4:	8b 00                	mov    (%eax),%eax
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 c1                	mov    %eax,%ecx
  8006fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800701:	eb 16                	jmp    800719 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800711:	89 c1                	mov    %eax,%ecx
  800713:	c1 f9 1f             	sar    $0x1f,%ecx
  800716:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800719:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800724:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800728:	79 74                	jns    80079e <vprintfmt+0x356>
				putch('-', putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	6a 2d                	push   $0x2d
  800730:	ff d6                	call   *%esi
				num = -(long long) num;
  800732:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800735:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800738:	f7 d8                	neg    %eax
  80073a:	83 d2 00             	adc    $0x0,%edx
  80073d:	f7 da                	neg    %edx
  80073f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800742:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800747:	eb 55                	jmp    80079e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
  80074c:	e8 83 fc ff ff       	call   8003d4 <getuint>
			base = 10;
  800751:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800756:	eb 46                	jmp    80079e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
  80075b:	e8 74 fc ff ff       	call   8003d4 <getuint>
			base = 8;
  800760:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800765:	eb 37                	jmp    80079e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 30                	push   $0x30
  80076d:	ff d6                	call   *%esi
			putch('x', putdat);
  80076f:	83 c4 08             	add    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 78                	push   $0x78
  800775:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 04             	lea    0x4(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800780:	8b 00                	mov    (%eax),%eax
  800782:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800787:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078f:	eb 0d                	jmp    80079e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	e8 3b fc ff ff       	call   8003d4 <getuint>
			base = 16;
  800799:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079e:	83 ec 0c             	sub    $0xc,%esp
  8007a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a5:	57                   	push   %edi
  8007a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a9:	51                   	push   %ecx
  8007aa:	52                   	push   %edx
  8007ab:	50                   	push   %eax
  8007ac:	89 da                	mov    %ebx,%edx
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	e8 70 fb ff ff       	call   800325 <printnum>
			break;
  8007b5:	83 c4 20             	add    $0x20,%esp
  8007b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bb:	e9 ae fc ff ff       	jmp    80046e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	51                   	push   %ecx
  8007c5:	ff d6                	call   *%esi
			break;
  8007c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cd:	e9 9c fc ff ff       	jmp    80046e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	6a 25                	push   $0x25
  8007d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb 03                	jmp    8007e2 <vprintfmt+0x39a>
  8007df:	83 ef 01             	sub    $0x1,%edi
  8007e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e6:	75 f7                	jne    8007df <vprintfmt+0x397>
  8007e8:	e9 81 fc ff ff       	jmp    80046e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 18             	sub    $0x18,%esp
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800801:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800804:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800808:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800812:	85 c0                	test   %eax,%eax
  800814:	74 26                	je     80083c <vsnprintf+0x47>
  800816:	85 d2                	test   %edx,%edx
  800818:	7e 22                	jle    80083c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081a:	ff 75 14             	pushl  0x14(%ebp)
  80081d:	ff 75 10             	pushl  0x10(%ebp)
  800820:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	68 0e 04 80 00       	push   $0x80040e
  800829:	e8 1a fc ff ff       	call   800448 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800831:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	eb 05                	jmp    800841 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084c:	50                   	push   %eax
  80084d:	ff 75 10             	pushl  0x10(%ebp)
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	ff 75 08             	pushl  0x8(%ebp)
  800856:	e8 9a ff ff ff       	call   8007f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb 03                	jmp    80086d <strlen+0x10>
		n++;
  80086a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800871:	75 f7                	jne    80086a <strlen+0xd>
		n++;
	return n;
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087e:	ba 00 00 00 00       	mov    $0x0,%edx
  800883:	eb 03                	jmp    800888 <strnlen+0x13>
		n++;
  800885:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800888:	39 c2                	cmp    %eax,%edx
  80088a:	74 08                	je     800894 <strnlen+0x1f>
  80088c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800890:	75 f3                	jne    800885 <strnlen+0x10>
  800892:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	83 c2 01             	add    $0x1,%edx
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ef                	jne    8008a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bd:	53                   	push   %ebx
  8008be:	e8 9a ff ff ff       	call   80085d <strlen>
  8008c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c6:	ff 75 0c             	pushl  0xc(%ebp)
  8008c9:	01 d8                	add    %ebx,%eax
  8008cb:	50                   	push   %eax
  8008cc:	e8 c5 ff ff ff       	call   800896 <strcpy>
	return dst;
}
  8008d1:	89 d8                	mov    %ebx,%eax
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e3:	89 f3                	mov    %esi,%ebx
  8008e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e8:	89 f2                	mov    %esi,%edx
  8008ea:	eb 0f                	jmp    8008fb <strncpy+0x23>
		*dst++ = *src;
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	0f b6 01             	movzbl (%ecx),%eax
  8008f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	39 da                	cmp    %ebx,%edx
  8008fd:	75 ed                	jne    8008ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ff:	89 f0                	mov    %esi,%eax
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 75 08             	mov    0x8(%ebp),%esi
  80090d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800910:	8b 55 10             	mov    0x10(%ebp),%edx
  800913:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800915:	85 d2                	test   %edx,%edx
  800917:	74 21                	je     80093a <strlcpy+0x35>
  800919:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091d:	89 f2                	mov    %esi,%edx
  80091f:	eb 09                	jmp    80092a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800921:	83 c2 01             	add    $0x1,%edx
  800924:	83 c1 01             	add    $0x1,%ecx
  800927:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092a:	39 c2                	cmp    %eax,%edx
  80092c:	74 09                	je     800937 <strlcpy+0x32>
  80092e:	0f b6 19             	movzbl (%ecx),%ebx
  800931:	84 db                	test   %bl,%bl
  800933:	75 ec                	jne    800921 <strlcpy+0x1c>
  800935:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800937:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093a:	29 f0                	sub    %esi,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800949:	eb 06                	jmp    800951 <strcmp+0x11>
		p++, q++;
  80094b:	83 c1 01             	add    $0x1,%ecx
  80094e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800951:	0f b6 01             	movzbl (%ecx),%eax
  800954:	84 c0                	test   %al,%al
  800956:	74 04                	je     80095c <strcmp+0x1c>
  800958:	3a 02                	cmp    (%edx),%al
  80095a:	74 ef                	je     80094b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	0f b6 c0             	movzbl %al,%eax
  80095f:	0f b6 12             	movzbl (%edx),%edx
  800962:	29 d0                	sub    %edx,%eax
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800970:	89 c3                	mov    %eax,%ebx
  800972:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800975:	eb 06                	jmp    80097d <strncmp+0x17>
		n--, p++, q++;
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097d:	39 d8                	cmp    %ebx,%eax
  80097f:	74 15                	je     800996 <strncmp+0x30>
  800981:	0f b6 08             	movzbl (%eax),%ecx
  800984:	84 c9                	test   %cl,%cl
  800986:	74 04                	je     80098c <strncmp+0x26>
  800988:	3a 0a                	cmp    (%edx),%cl
  80098a:	74 eb                	je     800977 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098c:	0f b6 00             	movzbl (%eax),%eax
  80098f:	0f b6 12             	movzbl (%edx),%edx
  800992:	29 d0                	sub    %edx,%eax
  800994:	eb 05                	jmp    80099b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099b:	5b                   	pop    %ebx
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a8:	eb 07                	jmp    8009b1 <strchr+0x13>
		if (*s == c)
  8009aa:	38 ca                	cmp    %cl,%dl
  8009ac:	74 0f                	je     8009bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	84 d2                	test   %dl,%dl
  8009b6:	75 f2                	jne    8009aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c9:	eb 03                	jmp    8009ce <strfind+0xf>
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d1:	38 ca                	cmp    %cl,%dl
  8009d3:	74 04                	je     8009d9 <strfind+0x1a>
  8009d5:	84 d2                	test   %dl,%dl
  8009d7:	75 f2                	jne    8009cb <strfind+0xc>
			break;
	return (char *) s;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e7:	85 c9                	test   %ecx,%ecx
  8009e9:	74 36                	je     800a21 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f1:	75 28                	jne    800a1b <memset+0x40>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 23                	jne    800a1b <memset+0x40>
		c &= 0xFF;
  8009f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fc:	89 d3                	mov    %edx,%ebx
  8009fe:	c1 e3 08             	shl    $0x8,%ebx
  800a01:	89 d6                	mov    %edx,%esi
  800a03:	c1 e6 18             	shl    $0x18,%esi
  800a06:	89 d0                	mov    %edx,%eax
  800a08:	c1 e0 10             	shl    $0x10,%eax
  800a0b:	09 f0                	or     %esi,%eax
  800a0d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0f:	89 d8                	mov    %ebx,%eax
  800a11:	09 d0                	or     %edx,%eax
  800a13:	c1 e9 02             	shr    $0x2,%ecx
  800a16:	fc                   	cld    
  800a17:	f3 ab                	rep stos %eax,%es:(%edi)
  800a19:	eb 06                	jmp    800a21 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	fc                   	cld    
  800a1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a21:	89 f8                	mov    %edi,%eax
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a36:	39 c6                	cmp    %eax,%esi
  800a38:	73 35                	jae    800a6f <memmove+0x47>
  800a3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	73 2e                	jae    800a6f <memmove+0x47>
		s += n;
		d += n;
  800a41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	09 fe                	or     %edi,%esi
  800a48:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4e:	75 13                	jne    800a63 <memmove+0x3b>
  800a50:	f6 c1 03             	test   $0x3,%cl
  800a53:	75 0e                	jne    800a63 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a55:	83 ef 04             	sub    $0x4,%edi
  800a58:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
  800a5e:	fd                   	std    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 09                	jmp    800a6c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a63:	83 ef 01             	sub    $0x1,%edi
  800a66:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a69:	fd                   	std    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6c:	fc                   	cld    
  800a6d:	eb 1d                	jmp    800a8c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	89 f2                	mov    %esi,%edx
  800a71:	09 c2                	or     %eax,%edx
  800a73:	f6 c2 03             	test   $0x3,%dl
  800a76:	75 0f                	jne    800a87 <memmove+0x5f>
  800a78:	f6 c1 03             	test   $0x3,%cl
  800a7b:	75 0a                	jne    800a87 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
  800a80:	89 c7                	mov    %eax,%edi
  800a82:	fc                   	cld    
  800a83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a85:	eb 05                	jmp    800a8c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	fc                   	cld    
  800a8a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a93:	ff 75 10             	pushl  0x10(%ebp)
  800a96:	ff 75 0c             	pushl  0xc(%ebp)
  800a99:	ff 75 08             	pushl  0x8(%ebp)
  800a9c:	e8 87 ff ff ff       	call   800a28 <memmove>
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	89 c6                	mov    %eax,%esi
  800ab0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab3:	eb 1a                	jmp    800acf <memcmp+0x2c>
		if (*s1 != *s2)
  800ab5:	0f b6 08             	movzbl (%eax),%ecx
  800ab8:	0f b6 1a             	movzbl (%edx),%ebx
  800abb:	38 d9                	cmp    %bl,%cl
  800abd:	74 0a                	je     800ac9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abf:	0f b6 c1             	movzbl %cl,%eax
  800ac2:	0f b6 db             	movzbl %bl,%ebx
  800ac5:	29 d8                	sub    %ebx,%eax
  800ac7:	eb 0f                	jmp    800ad8 <memcmp+0x35>
		s1++, s2++;
  800ac9:	83 c0 01             	add    $0x1,%eax
  800acc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	39 f0                	cmp    %esi,%eax
  800ad1:	75 e2                	jne    800ab5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	53                   	push   %ebx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae3:	89 c1                	mov    %eax,%ecx
  800ae5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aec:	eb 0a                	jmp    800af8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aee:	0f b6 10             	movzbl (%eax),%edx
  800af1:	39 da                	cmp    %ebx,%edx
  800af3:	74 07                	je     800afc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	39 c8                	cmp    %ecx,%eax
  800afa:	72 f2                	jb     800aee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afc:	5b                   	pop    %ebx
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0b:	eb 03                	jmp    800b10 <strtol+0x11>
		s++;
  800b0d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b10:	0f b6 01             	movzbl (%ecx),%eax
  800b13:	3c 20                	cmp    $0x20,%al
  800b15:	74 f6                	je     800b0d <strtol+0xe>
  800b17:	3c 09                	cmp    $0x9,%al
  800b19:	74 f2                	je     800b0d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1b:	3c 2b                	cmp    $0x2b,%al
  800b1d:	75 0a                	jne    800b29 <strtol+0x2a>
		s++;
  800b1f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b22:	bf 00 00 00 00       	mov    $0x0,%edi
  800b27:	eb 11                	jmp    800b3a <strtol+0x3b>
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2e:	3c 2d                	cmp    $0x2d,%al
  800b30:	75 08                	jne    800b3a <strtol+0x3b>
		s++, neg = 1;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b40:	75 15                	jne    800b57 <strtol+0x58>
  800b42:	80 39 30             	cmpb   $0x30,(%ecx)
  800b45:	75 10                	jne    800b57 <strtol+0x58>
  800b47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4b:	75 7c                	jne    800bc9 <strtol+0xca>
		s += 2, base = 16;
  800b4d:	83 c1 02             	add    $0x2,%ecx
  800b50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b55:	eb 16                	jmp    800b6d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b57:	85 db                	test   %ebx,%ebx
  800b59:	75 12                	jne    800b6d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b60:	80 39 30             	cmpb   $0x30,(%ecx)
  800b63:	75 08                	jne    800b6d <strtol+0x6e>
		s++, base = 8;
  800b65:	83 c1 01             	add    $0x1,%ecx
  800b68:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 11             	movzbl (%ecx),%edx
  800b78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7b:	89 f3                	mov    %esi,%ebx
  800b7d:	80 fb 09             	cmp    $0x9,%bl
  800b80:	77 08                	ja     800b8a <strtol+0x8b>
			dig = *s - '0';
  800b82:	0f be d2             	movsbl %dl,%edx
  800b85:	83 ea 30             	sub    $0x30,%edx
  800b88:	eb 22                	jmp    800bac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	80 fb 19             	cmp    $0x19,%bl
  800b92:	77 08                	ja     800b9c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b94:	0f be d2             	movsbl %dl,%edx
  800b97:	83 ea 57             	sub    $0x57,%edx
  800b9a:	eb 10                	jmp    800bac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9f:	89 f3                	mov    %esi,%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 16                	ja     800bbc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba6:	0f be d2             	movsbl %dl,%edx
  800ba9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800baf:	7d 0b                	jge    800bbc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb1:	83 c1 01             	add    $0x1,%ecx
  800bb4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bba:	eb b9                	jmp    800b75 <strtol+0x76>

	if (endptr)
  800bbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc0:	74 0d                	je     800bcf <strtol+0xd0>
		*endptr = (char *) s;
  800bc2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc5:	89 0e                	mov    %ecx,(%esi)
  800bc7:	eb 06                	jmp    800bcf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc9:	85 db                	test   %ebx,%ebx
  800bcb:	74 98                	je     800b65 <strtol+0x66>
  800bcd:	eb 9e                	jmp    800b6d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	f7 da                	neg    %edx
  800bd3:	85 ff                	test   %edi,%edi
  800bd5:	0f 45 c2             	cmovne %edx,%eax
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
  800be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	89 c3                	mov    %eax,%ebx
  800bf0:	89 c7                	mov    %eax,%edi
  800bf2:	89 c6                	mov    %eax,%esi
  800bf4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c28:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	89 cb                	mov    %ecx,%ebx
  800c32:	89 cf                	mov    %ecx,%edi
  800c34:	89 ce                	mov    %ecx,%esi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 03                	push   $0x3
  800c42:	68 1f 2d 80 00       	push   $0x802d1f
  800c47:	6a 23                	push   $0x23
  800c49:	68 3c 2d 80 00       	push   $0x802d3c
  800c4e:	e8 e5 f5 ff ff       	call   800238 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_yield>:

void
sys_yield(void)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	be 00 00 00 00       	mov    $0x0,%esi
  800ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb5:	89 f7                	mov    %esi,%edi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 04                	push   $0x4
  800cc3:	68 1f 2d 80 00       	push   $0x802d1f
  800cc8:	6a 23                	push   $0x23
  800cca:	68 3c 2d 80 00       	push   $0x802d3c
  800ccf:	e8 64 f5 ff ff       	call   800238 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 05                	push   $0x5
  800d05:	68 1f 2d 80 00       	push   $0x802d1f
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 3c 2d 80 00       	push   $0x802d3c
  800d11:	e8 22 f5 ff ff       	call   800238 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 df                	mov    %ebx,%edi
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 06                	push   $0x6
  800d47:	68 1f 2d 80 00       	push   $0x802d1f
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 3c 2d 80 00       	push   $0x802d3c
  800d53:	e8 e0 f4 ff ff       	call   800238 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 df                	mov    %ebx,%edi
  800d7b:	89 de                	mov    %ebx,%esi
  800d7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7e 17                	jle    800d9a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	50                   	push   %eax
  800d87:	6a 08                	push   $0x8
  800d89:	68 1f 2d 80 00       	push   $0x802d1f
  800d8e:	6a 23                	push   $0x23
  800d90:	68 3c 2d 80 00       	push   $0x802d3c
  800d95:	e8 9e f4 ff ff       	call   800238 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800db0:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800dc3:	7e 17                	jle    800ddc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 09                	push   $0x9
  800dcb:	68 1f 2d 80 00       	push   $0x802d1f
  800dd0:	6a 23                	push   $0x23
  800dd2:	68 3c 2d 80 00       	push   $0x802d3c
  800dd7:	e8 5c f4 ff ff       	call   800238 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800df2:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800e05:	7e 17                	jle    800e1e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	50                   	push   %eax
  800e0b:	6a 0a                	push   $0xa
  800e0d:	68 1f 2d 80 00       	push   $0x802d1f
  800e12:	6a 23                	push   $0x23
  800e14:	68 3c 2d 80 00       	push   $0x802d3c
  800e19:	e8 1a f4 ff ff       	call   800238 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	be 00 00 00 00       	mov    $0x0,%esi
  800e31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 cb                	mov    %ecx,%ebx
  800e61:	89 cf                	mov    %ecx,%edi
  800e63:	89 ce                	mov    %ecx,%esi
  800e65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e67:	85 c0                	test   %eax,%eax
  800e69:	7e 17                	jle    800e82 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	50                   	push   %eax
  800e6f:	6a 0d                	push   $0xd
  800e71:	68 1f 2d 80 00       	push   $0x802d1f
  800e76:	6a 23                	push   $0x23
  800e78:	68 3c 2d 80 00       	push   $0x802d3c
  800e7d:	e8 b6 f3 ff ff       	call   800238 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	57                   	push   %edi
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e95:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	89 cb                	mov    %ecx,%ebx
  800e9f:	89 cf                	mov    %ecx,%edi
  800ea1:	89 ce                	mov    %ecx,%esi
  800ea3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	53                   	push   %ebx
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800eb6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eba:	74 11                	je     800ecd <pgfault+0x23>
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	c1 e8 0c             	shr    $0xc,%eax
  800ec1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec8:	f6 c4 08             	test   $0x8,%ah
  800ecb:	75 14                	jne    800ee1 <pgfault+0x37>
		panic("faulting access");
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	68 4a 2d 80 00       	push   $0x802d4a
  800ed5:	6a 1d                	push   $0x1d
  800ed7:	68 5a 2d 80 00       	push   $0x802d5a
  800edc:	e8 57 f3 ff ff       	call   800238 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	6a 07                	push   $0x7
  800ee6:	68 00 f0 7f 00       	push   $0x7ff000
  800eeb:	6a 00                	push   $0x0
  800eed:	e8 a7 fd ff ff       	call   800c99 <sys_page_alloc>
	if (r < 0) {
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	79 12                	jns    800f0b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ef9:	50                   	push   %eax
  800efa:	68 65 2d 80 00       	push   $0x802d65
  800eff:	6a 2b                	push   $0x2b
  800f01:	68 5a 2d 80 00       	push   $0x802d5a
  800f06:	e8 2d f3 ff ff       	call   800238 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f0b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	68 00 10 00 00       	push   $0x1000
  800f19:	53                   	push   %ebx
  800f1a:	68 00 f0 7f 00       	push   $0x7ff000
  800f1f:	e8 6c fb ff ff       	call   800a90 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f24:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2b:	53                   	push   %ebx
  800f2c:	6a 00                	push   $0x0
  800f2e:	68 00 f0 7f 00       	push   $0x7ff000
  800f33:	6a 00                	push   $0x0
  800f35:	e8 a2 fd ff ff       	call   800cdc <sys_page_map>
	if (r < 0) {
  800f3a:	83 c4 20             	add    $0x20,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 12                	jns    800f53 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f41:	50                   	push   %eax
  800f42:	68 65 2d 80 00       	push   $0x802d65
  800f47:	6a 32                	push   $0x32
  800f49:	68 5a 2d 80 00       	push   $0x802d5a
  800f4e:	e8 e5 f2 ff ff       	call   800238 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	68 00 f0 7f 00       	push   $0x7ff000
  800f5b:	6a 00                	push   $0x0
  800f5d:	e8 bc fd ff ff       	call   800d1e <sys_page_unmap>
	if (r < 0) {
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	79 12                	jns    800f7b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f69:	50                   	push   %eax
  800f6a:	68 65 2d 80 00       	push   $0x802d65
  800f6f:	6a 36                	push   $0x36
  800f71:	68 5a 2d 80 00       	push   $0x802d5a
  800f76:	e8 bd f2 ff ff       	call   800238 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f89:	68 aa 0e 80 00       	push   $0x800eaa
  800f8e:	e8 1c 15 00 00       	call   8024af <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f93:	b8 07 00 00 00       	mov    $0x7,%eax
  800f98:	cd 30                	int    $0x30
  800f9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	79 17                	jns    800fbb <fork+0x3b>
		panic("fork fault %e");
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	68 7e 2d 80 00       	push   $0x802d7e
  800fac:	68 83 00 00 00       	push   $0x83
  800fb1:	68 5a 2d 80 00       	push   $0x802d5a
  800fb6:	e8 7d f2 ff ff       	call   800238 <_panic>
  800fbb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fbd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc1:	75 25                	jne    800fe8 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc3:	e8 93 fc ff ff       	call   800c5b <sys_getenvid>
  800fc8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fcd:	89 c2                	mov    %eax,%edx
  800fcf:	c1 e2 07             	shl    $0x7,%edx
  800fd2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800fd9:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe3:	e9 61 01 00 00       	jmp    801149 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fe8:	83 ec 04             	sub    $0x4,%esp
  800feb:	6a 07                	push   $0x7
  800fed:	68 00 f0 bf ee       	push   $0xeebff000
  800ff2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff5:	e8 9f fc ff ff       	call   800c99 <sys_page_alloc>
  800ffa:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801002:	89 d8                	mov    %ebx,%eax
  801004:	c1 e8 16             	shr    $0x16,%eax
  801007:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100e:	a8 01                	test   $0x1,%al
  801010:	0f 84 fc 00 00 00    	je     801112 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801016:	89 d8                	mov    %ebx,%eax
  801018:	c1 e8 0c             	shr    $0xc,%eax
  80101b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801022:	f6 c2 01             	test   $0x1,%dl
  801025:	0f 84 e7 00 00 00    	je     801112 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80102b:	89 c6                	mov    %eax,%esi
  80102d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801030:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801037:	f6 c6 04             	test   $0x4,%dh
  80103a:	74 39                	je     801075 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80103c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	25 07 0e 00 00       	and    $0xe07,%eax
  80104b:	50                   	push   %eax
  80104c:	56                   	push   %esi
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	6a 00                	push   $0x0
  801051:	e8 86 fc ff ff       	call   800cdc <sys_page_map>
		if (r < 0) {
  801056:	83 c4 20             	add    $0x20,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	0f 89 b1 00 00 00    	jns    801112 <fork+0x192>
		    	panic("sys page map fault %e");
  801061:	83 ec 04             	sub    $0x4,%esp
  801064:	68 8c 2d 80 00       	push   $0x802d8c
  801069:	6a 53                	push   $0x53
  80106b:	68 5a 2d 80 00       	push   $0x802d5a
  801070:	e8 c3 f1 ff ff       	call   800238 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801075:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107c:	f6 c2 02             	test   $0x2,%dl
  80107f:	75 0c                	jne    80108d <fork+0x10d>
  801081:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801088:	f6 c4 08             	test   $0x8,%ah
  80108b:	74 5b                	je     8010e8 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	68 05 08 00 00       	push   $0x805
  801095:	56                   	push   %esi
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	6a 00                	push   $0x0
  80109a:	e8 3d fc ff ff       	call   800cdc <sys_page_map>
		if (r < 0) {
  80109f:	83 c4 20             	add    $0x20,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	79 14                	jns    8010ba <fork+0x13a>
		    	panic("sys page map fault %e");
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	68 8c 2d 80 00       	push   $0x802d8c
  8010ae:	6a 5a                	push   $0x5a
  8010b0:	68 5a 2d 80 00       	push   $0x802d5a
  8010b5:	e8 7e f1 ff ff       	call   800238 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	68 05 08 00 00       	push   $0x805
  8010c2:	56                   	push   %esi
  8010c3:	6a 00                	push   $0x0
  8010c5:	56                   	push   %esi
  8010c6:	6a 00                	push   $0x0
  8010c8:	e8 0f fc ff ff       	call   800cdc <sys_page_map>
		if (r < 0) {
  8010cd:	83 c4 20             	add    $0x20,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	79 3e                	jns    801112 <fork+0x192>
		    	panic("sys page map fault %e");
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	68 8c 2d 80 00       	push   $0x802d8c
  8010dc:	6a 5e                	push   $0x5e
  8010de:	68 5a 2d 80 00       	push   $0x802d5a
  8010e3:	e8 50 f1 ff ff       	call   800238 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	6a 05                	push   $0x5
  8010ed:	56                   	push   %esi
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	6a 00                	push   $0x0
  8010f2:	e8 e5 fb ff ff       	call   800cdc <sys_page_map>
		if (r < 0) {
  8010f7:	83 c4 20             	add    $0x20,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 14                	jns    801112 <fork+0x192>
		    	panic("sys page map fault %e");
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	68 8c 2d 80 00       	push   $0x802d8c
  801106:	6a 63                	push   $0x63
  801108:	68 5a 2d 80 00       	push   $0x802d5a
  80110d:	e8 26 f1 ff ff       	call   800238 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801112:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801118:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80111e:	0f 85 de fe ff ff    	jne    801002 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801124:	a1 04 40 80 00       	mov    0x804004,%eax
  801129:	8b 40 6c             	mov    0x6c(%eax),%eax
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	50                   	push   %eax
  801130:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801133:	57                   	push   %edi
  801134:	e8 ab fc ff ff       	call   800de4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801139:	83 c4 08             	add    $0x8,%esp
  80113c:	6a 02                	push   $0x2
  80113e:	57                   	push   %edi
  80113f:	e8 1c fc ff ff       	call   800d60 <sys_env_set_status>
	
	return envid;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sfork>:

envid_t
sfork(void)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	53                   	push   %ebx
  801167:	68 a4 2d 80 00       	push   $0x802da4
  80116c:	e8 a0 f1 ff ff       	call   800311 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  801171:	89 1c 24             	mov    %ebx,(%esp)
  801174:	e8 11 fd ff ff       	call   800e8a <sys_thread_create>
  801179:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80117b:	83 c4 08             	add    $0x8,%esp
  80117e:	53                   	push   %ebx
  80117f:	68 a4 2d 80 00       	push   $0x802da4
  801184:	e8 88 f1 ff ff       	call   800311 <cprintf>
	return id;
}
  801189:	89 f0                	mov    %esi,%eax
  80118b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801195:	8b 45 08             	mov    0x8(%ebp),%eax
  801198:	05 00 00 00 30       	add    $0x30000000,%eax
  80119d:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c4:	89 c2                	mov    %eax,%edx
  8011c6:	c1 ea 16             	shr    $0x16,%edx
  8011c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d0:	f6 c2 01             	test   $0x1,%dl
  8011d3:	74 11                	je     8011e6 <fd_alloc+0x2d>
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	c1 ea 0c             	shr    $0xc,%edx
  8011da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e1:	f6 c2 01             	test   $0x1,%dl
  8011e4:	75 09                	jne    8011ef <fd_alloc+0x36>
			*fd_store = fd;
  8011e6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ed:	eb 17                	jmp    801206 <fd_alloc+0x4d>
  8011ef:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f9:	75 c9                	jne    8011c4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011fb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801201:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120e:	83 f8 1f             	cmp    $0x1f,%eax
  801211:	77 36                	ja     801249 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801213:	c1 e0 0c             	shl    $0xc,%eax
  801216:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	c1 ea 16             	shr    $0x16,%edx
  801220:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801227:	f6 c2 01             	test   $0x1,%dl
  80122a:	74 24                	je     801250 <fd_lookup+0x48>
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	c1 ea 0c             	shr    $0xc,%edx
  801231:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801238:	f6 c2 01             	test   $0x1,%dl
  80123b:	74 1a                	je     801257 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801240:	89 02                	mov    %eax,(%edx)
	return 0;
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
  801247:	eb 13                	jmp    80125c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801249:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124e:	eb 0c                	jmp    80125c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801255:	eb 05                	jmp    80125c <fd_lookup+0x54>
  801257:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801267:	ba 44 2e 80 00       	mov    $0x802e44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80126c:	eb 13                	jmp    801281 <dev_lookup+0x23>
  80126e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801271:	39 08                	cmp    %ecx,(%eax)
  801273:	75 0c                	jne    801281 <dev_lookup+0x23>
			*dev = devtab[i];
  801275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801278:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127a:	b8 00 00 00 00       	mov    $0x0,%eax
  80127f:	eb 2e                	jmp    8012af <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801281:	8b 02                	mov    (%edx),%eax
  801283:	85 c0                	test   %eax,%eax
  801285:	75 e7                	jne    80126e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801287:	a1 04 40 80 00       	mov    0x804004,%eax
  80128c:	8b 40 50             	mov    0x50(%eax),%eax
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	51                   	push   %ecx
  801293:	50                   	push   %eax
  801294:	68 c8 2d 80 00       	push   $0x802dc8
  801299:	e8 73 f0 ff ff       	call   800311 <cprintf>
	*dev = 0;
  80129e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012af:	c9                   	leave  
  8012b0:	c3                   	ret    

008012b1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 10             	sub    $0x10,%esp
  8012b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c2:	50                   	push   %eax
  8012c3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c9:	c1 e8 0c             	shr    $0xc,%eax
  8012cc:	50                   	push   %eax
  8012cd:	e8 36 ff ff ff       	call   801208 <fd_lookup>
  8012d2:	83 c4 08             	add    $0x8,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 05                	js     8012de <fd_close+0x2d>
	    || fd != fd2)
  8012d9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012dc:	74 0c                	je     8012ea <fd_close+0x39>
		return (must_exist ? r : 0);
  8012de:	84 db                	test   %bl,%bl
  8012e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e5:	0f 44 c2             	cmove  %edx,%eax
  8012e8:	eb 41                	jmp    80132b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	ff 36                	pushl  (%esi)
  8012f3:	e8 66 ff ff ff       	call   80125e <dev_lookup>
  8012f8:	89 c3                	mov    %eax,%ebx
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 1a                	js     80131b <fd_close+0x6a>
		if (dev->dev_close)
  801301:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801304:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801307:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80130c:	85 c0                	test   %eax,%eax
  80130e:	74 0b                	je     80131b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	56                   	push   %esi
  801314:	ff d0                	call   *%eax
  801316:	89 c3                	mov    %eax,%ebx
  801318:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	56                   	push   %esi
  80131f:	6a 00                	push   $0x0
  801321:	e8 f8 f9 ff ff       	call   800d1e <sys_page_unmap>
	return r;
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	89 d8                	mov    %ebx,%eax
}
  80132b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 c4 fe ff ff       	call   801208 <fd_lookup>
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 10                	js     80135b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	6a 01                	push   $0x1
  801350:	ff 75 f4             	pushl  -0xc(%ebp)
  801353:	e8 59 ff ff ff       	call   8012b1 <fd_close>
  801358:	83 c4 10             	add    $0x10,%esp
}
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <close_all>:

void
close_all(void)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	53                   	push   %ebx
  801361:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801364:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	53                   	push   %ebx
  80136d:	e8 c0 ff ff ff       	call   801332 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801372:	83 c3 01             	add    $0x1,%ebx
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	83 fb 20             	cmp    $0x20,%ebx
  80137b:	75 ec                	jne    801369 <close_all+0xc>
		close(i);
}
  80137d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 2c             	sub    $0x2c,%esp
  80138b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	ff 75 08             	pushl  0x8(%ebp)
  801395:	e8 6e fe ff ff       	call   801208 <fd_lookup>
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	0f 88 c1 00 00 00    	js     801466 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a5:	83 ec 0c             	sub    $0xc,%esp
  8013a8:	56                   	push   %esi
  8013a9:	e8 84 ff ff ff       	call   801332 <close>

	newfd = INDEX2FD(newfdnum);
  8013ae:	89 f3                	mov    %esi,%ebx
  8013b0:	c1 e3 0c             	shl    $0xc,%ebx
  8013b3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b9:	83 c4 04             	add    $0x4,%esp
  8013bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013bf:	e8 de fd ff ff       	call   8011a2 <fd2data>
  8013c4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c6:	89 1c 24             	mov    %ebx,(%esp)
  8013c9:	e8 d4 fd ff ff       	call   8011a2 <fd2data>
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d4:	89 f8                	mov    %edi,%eax
  8013d6:	c1 e8 16             	shr    $0x16,%eax
  8013d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e0:	a8 01                	test   $0x1,%al
  8013e2:	74 37                	je     80141b <dup+0x99>
  8013e4:	89 f8                	mov    %edi,%eax
  8013e6:	c1 e8 0c             	shr    $0xc,%eax
  8013e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f0:	f6 c2 01             	test   $0x1,%dl
  8013f3:	74 26                	je     80141b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801404:	50                   	push   %eax
  801405:	ff 75 d4             	pushl  -0x2c(%ebp)
  801408:	6a 00                	push   $0x0
  80140a:	57                   	push   %edi
  80140b:	6a 00                	push   $0x0
  80140d:	e8 ca f8 ff ff       	call   800cdc <sys_page_map>
  801412:	89 c7                	mov    %eax,%edi
  801414:	83 c4 20             	add    $0x20,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 2e                	js     801449 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141e:	89 d0                	mov    %edx,%eax
  801420:	c1 e8 0c             	shr    $0xc,%eax
  801423:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	25 07 0e 00 00       	and    $0xe07,%eax
  801432:	50                   	push   %eax
  801433:	53                   	push   %ebx
  801434:	6a 00                	push   $0x0
  801436:	52                   	push   %edx
  801437:	6a 00                	push   $0x0
  801439:	e8 9e f8 ff ff       	call   800cdc <sys_page_map>
  80143e:	89 c7                	mov    %eax,%edi
  801440:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801443:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801445:	85 ff                	test   %edi,%edi
  801447:	79 1d                	jns    801466 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	53                   	push   %ebx
  80144d:	6a 00                	push   $0x0
  80144f:	e8 ca f8 ff ff       	call   800d1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145a:	6a 00                	push   $0x0
  80145c:	e8 bd f8 ff ff       	call   800d1e <sys_page_unmap>
	return r;
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	89 f8                	mov    %edi,%eax
}
  801466:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 14             	sub    $0x14,%esp
  801475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	53                   	push   %ebx
  80147d:	e8 86 fd ff ff       	call   801208 <fd_lookup>
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	89 c2                	mov    %eax,%edx
  801487:	85 c0                	test   %eax,%eax
  801489:	78 6d                	js     8014f8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	ff 30                	pushl  (%eax)
  801497:	e8 c2 fd ff ff       	call   80125e <dev_lookup>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 4c                	js     8014ef <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a6:	8b 42 08             	mov    0x8(%edx),%eax
  8014a9:	83 e0 03             	and    $0x3,%eax
  8014ac:	83 f8 01             	cmp    $0x1,%eax
  8014af:	75 21                	jne    8014d2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b6:	8b 40 50             	mov    0x50(%eax),%eax
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	53                   	push   %ebx
  8014bd:	50                   	push   %eax
  8014be:	68 09 2e 80 00       	push   $0x802e09
  8014c3:	e8 49 ee ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d0:	eb 26                	jmp    8014f8 <read+0x8a>
	}
	if (!dev->dev_read)
  8014d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d5:	8b 40 08             	mov    0x8(%eax),%eax
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	74 17                	je     8014f3 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014dc:	83 ec 04             	sub    $0x4,%esp
  8014df:	ff 75 10             	pushl  0x10(%ebp)
  8014e2:	ff 75 0c             	pushl  0xc(%ebp)
  8014e5:	52                   	push   %edx
  8014e6:	ff d0                	call   *%eax
  8014e8:	89 c2                	mov    %eax,%edx
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	eb 09                	jmp    8014f8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	eb 05                	jmp    8014f8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014f8:	89 d0                	mov    %edx,%eax
  8014fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	57                   	push   %edi
  801503:	56                   	push   %esi
  801504:	53                   	push   %ebx
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801513:	eb 21                	jmp    801536 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801515:	83 ec 04             	sub    $0x4,%esp
  801518:	89 f0                	mov    %esi,%eax
  80151a:	29 d8                	sub    %ebx,%eax
  80151c:	50                   	push   %eax
  80151d:	89 d8                	mov    %ebx,%eax
  80151f:	03 45 0c             	add    0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	57                   	push   %edi
  801524:	e8 45 ff ff ff       	call   80146e <read>
		if (m < 0)
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 10                	js     801540 <readn+0x41>
			return m;
		if (m == 0)
  801530:	85 c0                	test   %eax,%eax
  801532:	74 0a                	je     80153e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801534:	01 c3                	add    %eax,%ebx
  801536:	39 f3                	cmp    %esi,%ebx
  801538:	72 db                	jb     801515 <readn+0x16>
  80153a:	89 d8                	mov    %ebx,%eax
  80153c:	eb 02                	jmp    801540 <readn+0x41>
  80153e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801540:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5f                   	pop    %edi
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    

00801548 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 14             	sub    $0x14,%esp
  80154f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801552:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	53                   	push   %ebx
  801557:	e8 ac fc ff ff       	call   801208 <fd_lookup>
  80155c:	83 c4 08             	add    $0x8,%esp
  80155f:	89 c2                	mov    %eax,%edx
  801561:	85 c0                	test   %eax,%eax
  801563:	78 68                	js     8015cd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156f:	ff 30                	pushl  (%eax)
  801571:	e8 e8 fc ff ff       	call   80125e <dev_lookup>
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 47                	js     8015c4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801580:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801584:	75 21                	jne    8015a7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801586:	a1 04 40 80 00       	mov    0x804004,%eax
  80158b:	8b 40 50             	mov    0x50(%eax),%eax
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	53                   	push   %ebx
  801592:	50                   	push   %eax
  801593:	68 25 2e 80 00       	push   $0x802e25
  801598:	e8 74 ed ff ff       	call   800311 <cprintf>
		return -E_INVAL;
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a5:	eb 26                	jmp    8015cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ad:	85 d2                	test   %edx,%edx
  8015af:	74 17                	je     8015c8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	ff 75 10             	pushl  0x10(%ebp)
  8015b7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ba:	50                   	push   %eax
  8015bb:	ff d2                	call   *%edx
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	eb 09                	jmp    8015cd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	eb 05                	jmp    8015cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015cd:	89 d0                	mov    %edx,%eax
  8015cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	ff 75 08             	pushl  0x8(%ebp)
  8015e1:	e8 22 fc ff ff       	call   801208 <fd_lookup>
  8015e6:	83 c4 08             	add    $0x8,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 0e                	js     8015fb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	53                   	push   %ebx
  801601:	83 ec 14             	sub    $0x14,%esp
  801604:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801607:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	53                   	push   %ebx
  80160c:	e8 f7 fb ff ff       	call   801208 <fd_lookup>
  801611:	83 c4 08             	add    $0x8,%esp
  801614:	89 c2                	mov    %eax,%edx
  801616:	85 c0                	test   %eax,%eax
  801618:	78 65                	js     80167f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	ff 30                	pushl  (%eax)
  801626:	e8 33 fc ff ff       	call   80125e <dev_lookup>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 44                	js     801676 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801639:	75 21                	jne    80165c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801640:	8b 40 50             	mov    0x50(%eax),%eax
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	53                   	push   %ebx
  801647:	50                   	push   %eax
  801648:	68 e8 2d 80 00       	push   $0x802de8
  80164d:	e8 bf ec ff ff       	call   800311 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165a:	eb 23                	jmp    80167f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80165c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165f:	8b 52 18             	mov    0x18(%edx),%edx
  801662:	85 d2                	test   %edx,%edx
  801664:	74 14                	je     80167a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	ff 75 0c             	pushl  0xc(%ebp)
  80166c:	50                   	push   %eax
  80166d:	ff d2                	call   *%edx
  80166f:	89 c2                	mov    %eax,%edx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb 09                	jmp    80167f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801676:	89 c2                	mov    %eax,%edx
  801678:	eb 05                	jmp    80167f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80167a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167f:	89 d0                	mov    %edx,%eax
  801681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	ff 75 08             	pushl  0x8(%ebp)
  801697:	e8 6c fb ff ff       	call   801208 <fd_lookup>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 58                	js     8016fd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016af:	ff 30                	pushl  (%eax)
  8016b1:	e8 a8 fb ff ff       	call   80125e <dev_lookup>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 37                	js     8016f4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c4:	74 32                	je     8016f8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d0:	00 00 00 
	stat->st_isdir = 0;
  8016d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016da:	00 00 00 
	stat->st_dev = dev;
  8016dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ea:	ff 50 14             	call   *0x14(%eax)
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	eb 09                	jmp    8016fd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	eb 05                	jmp    8016fd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016fd:	89 d0                	mov    %edx,%eax
  8016ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	6a 00                	push   $0x0
  80170e:	ff 75 08             	pushl  0x8(%ebp)
  801711:	e8 e3 01 00 00       	call   8018f9 <open>
  801716:	89 c3                	mov    %eax,%ebx
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 1b                	js     80173a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	ff 75 0c             	pushl  0xc(%ebp)
  801725:	50                   	push   %eax
  801726:	e8 5b ff ff ff       	call   801686 <fstat>
  80172b:	89 c6                	mov    %eax,%esi
	close(fd);
  80172d:	89 1c 24             	mov    %ebx,(%esp)
  801730:	e8 fd fb ff ff       	call   801332 <close>
	return r;
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	89 f0                	mov    %esi,%eax
}
  80173a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5e                   	pop    %esi
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	89 c6                	mov    %eax,%esi
  801748:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801751:	75 12                	jne    801765 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	6a 01                	push   $0x1
  801758:	e8 b8 0e 00 00       	call   802615 <ipc_find_env>
  80175d:	a3 00 40 80 00       	mov    %eax,0x804000
  801762:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801765:	6a 07                	push   $0x7
  801767:	68 00 50 80 00       	push   $0x805000
  80176c:	56                   	push   %esi
  80176d:	ff 35 00 40 80 00    	pushl  0x804000
  801773:	e8 3b 0e 00 00       	call   8025b3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801778:	83 c4 0c             	add    $0xc,%esp
  80177b:	6a 00                	push   $0x0
  80177d:	53                   	push   %ebx
  80177e:	6a 00                	push   $0x0
  801780:	e8 b9 0d 00 00       	call   80253e <ipc_recv>
}
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 40 0c             	mov    0xc(%eax),%eax
  801798:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8017af:	e8 8d ff ff ff       	call   801741 <fsipc>
}
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d1:	e8 6b ff ff ff       	call   801741 <fsipc>
}
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    

008017d8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f7:	e8 45 ff ff ff       	call   801741 <fsipc>
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	78 2c                	js     80182c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	68 00 50 80 00       	push   $0x805000
  801808:	53                   	push   %ebx
  801809:	e8 88 f0 ff ff       	call   800896 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180e:	a1 80 50 80 00       	mov    0x805080,%eax
  801813:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801819:	a1 84 50 80 00       	mov    0x805084,%eax
  80181e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	83 ec 0c             	sub    $0xc,%esp
  801837:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80183a:	8b 55 08             	mov    0x8(%ebp),%edx
  80183d:	8b 52 0c             	mov    0xc(%edx),%edx
  801840:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801846:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80184b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801850:	0f 47 c2             	cmova  %edx,%eax
  801853:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801858:	50                   	push   %eax
  801859:	ff 75 0c             	pushl  0xc(%ebp)
  80185c:	68 08 50 80 00       	push   $0x805008
  801861:	e8 c2 f1 ff ff       	call   800a28 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801866:	ba 00 00 00 00       	mov    $0x0,%edx
  80186b:	b8 04 00 00 00       	mov    $0x4,%eax
  801870:	e8 cc fe ff ff       	call   801741 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	56                   	push   %esi
  80187b:	53                   	push   %ebx
  80187c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 40 0c             	mov    0xc(%eax),%eax
  801885:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80188a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801890:	ba 00 00 00 00       	mov    $0x0,%edx
  801895:	b8 03 00 00 00       	mov    $0x3,%eax
  80189a:	e8 a2 fe ff ff       	call   801741 <fsipc>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 4b                	js     8018f0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a5:	39 c6                	cmp    %eax,%esi
  8018a7:	73 16                	jae    8018bf <devfile_read+0x48>
  8018a9:	68 54 2e 80 00       	push   $0x802e54
  8018ae:	68 5b 2e 80 00       	push   $0x802e5b
  8018b3:	6a 7c                	push   $0x7c
  8018b5:	68 70 2e 80 00       	push   $0x802e70
  8018ba:	e8 79 e9 ff ff       	call   800238 <_panic>
	assert(r <= PGSIZE);
  8018bf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c4:	7e 16                	jle    8018dc <devfile_read+0x65>
  8018c6:	68 7b 2e 80 00       	push   $0x802e7b
  8018cb:	68 5b 2e 80 00       	push   $0x802e5b
  8018d0:	6a 7d                	push   $0x7d
  8018d2:	68 70 2e 80 00       	push   $0x802e70
  8018d7:	e8 5c e9 ff ff       	call   800238 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018dc:	83 ec 04             	sub    $0x4,%esp
  8018df:	50                   	push   %eax
  8018e0:	68 00 50 80 00       	push   $0x805000
  8018e5:	ff 75 0c             	pushl  0xc(%ebp)
  8018e8:	e8 3b f1 ff ff       	call   800a28 <memmove>
	return r;
  8018ed:	83 c4 10             	add    $0x10,%esp
}
  8018f0:	89 d8                	mov    %ebx,%eax
  8018f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f5:	5b                   	pop    %ebx
  8018f6:	5e                   	pop    %esi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	53                   	push   %ebx
  8018fd:	83 ec 20             	sub    $0x20,%esp
  801900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801903:	53                   	push   %ebx
  801904:	e8 54 ef ff ff       	call   80085d <strlen>
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801911:	7f 67                	jg     80197a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801913:	83 ec 0c             	sub    $0xc,%esp
  801916:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801919:	50                   	push   %eax
  80191a:	e8 9a f8 ff ff       	call   8011b9 <fd_alloc>
  80191f:	83 c4 10             	add    $0x10,%esp
		return r;
  801922:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801924:	85 c0                	test   %eax,%eax
  801926:	78 57                	js     80197f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	53                   	push   %ebx
  80192c:	68 00 50 80 00       	push   $0x805000
  801931:	e8 60 ef ff ff       	call   800896 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801936:	8b 45 0c             	mov    0xc(%ebp),%eax
  801939:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801941:	b8 01 00 00 00       	mov    $0x1,%eax
  801946:	e8 f6 fd ff ff       	call   801741 <fsipc>
  80194b:	89 c3                	mov    %eax,%ebx
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	85 c0                	test   %eax,%eax
  801952:	79 14                	jns    801968 <open+0x6f>
		fd_close(fd, 0);
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	6a 00                	push   $0x0
  801959:	ff 75 f4             	pushl  -0xc(%ebp)
  80195c:	e8 50 f9 ff ff       	call   8012b1 <fd_close>
		return r;
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	89 da                	mov    %ebx,%edx
  801966:	eb 17                	jmp    80197f <open+0x86>
	}

	return fd2num(fd);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	ff 75 f4             	pushl  -0xc(%ebp)
  80196e:	e8 1f f8 ff ff       	call   801192 <fd2num>
  801973:	89 c2                	mov    %eax,%edx
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	eb 05                	jmp    80197f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80197a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197f:	89 d0                	mov    %edx,%eax
  801981:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80198c:	ba 00 00 00 00       	mov    $0x0,%edx
  801991:	b8 08 00 00 00       	mov    $0x8,%eax
  801996:	e8 a6 fd ff ff       	call   801741 <fsipc>
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	57                   	push   %edi
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019a9:	6a 00                	push   $0x0
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	e8 46 ff ff ff       	call   8018f9 <open>
  8019b3:	89 c7                	mov    %eax,%edi
  8019b5:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 88 89 04 00 00    	js     801e4f <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019c6:	83 ec 04             	sub    $0x4,%esp
  8019c9:	68 00 02 00 00       	push   $0x200
  8019ce:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019d4:	50                   	push   %eax
  8019d5:	57                   	push   %edi
  8019d6:	e8 24 fb ff ff       	call   8014ff <readn>
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019e3:	75 0c                	jne    8019f1 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019e5:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019ec:	45 4c 46 
  8019ef:	74 33                	je     801a24 <spawn+0x87>
		close(fd);
  8019f1:	83 ec 0c             	sub    $0xc,%esp
  8019f4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019fa:	e8 33 f9 ff ff       	call   801332 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019ff:	83 c4 0c             	add    $0xc,%esp
  801a02:	68 7f 45 4c 46       	push   $0x464c457f
  801a07:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a0d:	68 87 2e 80 00       	push   $0x802e87
  801a12:	e8 fa e8 ff ff       	call   800311 <cprintf>
		return -E_NOT_EXEC;
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a1f:	e9 de 04 00 00       	jmp    801f02 <spawn+0x565>
  801a24:	b8 07 00 00 00       	mov    $0x7,%eax
  801a29:	cd 30                	int    $0x30
  801a2b:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a31:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a37:	85 c0                	test   %eax,%eax
  801a39:	0f 88 1b 04 00 00    	js     801e5a <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a3f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a44:	89 c2                	mov    %eax,%edx
  801a46:	c1 e2 07             	shl    $0x7,%edx
  801a49:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a4f:	8d b4 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%esi
  801a56:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a5d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a63:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a69:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a6e:	be 00 00 00 00       	mov    $0x0,%esi
  801a73:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a76:	eb 13                	jmp    801a8b <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	50                   	push   %eax
  801a7c:	e8 dc ed ff ff       	call   80085d <strlen>
  801a81:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a85:	83 c3 01             	add    $0x1,%ebx
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a92:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a95:	85 c0                	test   %eax,%eax
  801a97:	75 df                	jne    801a78 <spawn+0xdb>
  801a99:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a9f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801aa5:	bf 00 10 40 00       	mov    $0x401000,%edi
  801aaa:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801aac:	89 fa                	mov    %edi,%edx
  801aae:	83 e2 fc             	and    $0xfffffffc,%edx
  801ab1:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ab8:	29 c2                	sub    %eax,%edx
  801aba:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ac0:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ac3:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ac8:	0f 86 a2 03 00 00    	jbe    801e70 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ace:	83 ec 04             	sub    $0x4,%esp
  801ad1:	6a 07                	push   $0x7
  801ad3:	68 00 00 40 00       	push   $0x400000
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 ba f1 ff ff       	call   800c99 <sys_page_alloc>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	0f 88 90 03 00 00    	js     801e7a <spawn+0x4dd>
  801aea:	be 00 00 00 00       	mov    $0x0,%esi
  801aef:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801af8:	eb 30                	jmp    801b2a <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801afa:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b00:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b06:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b0f:	57                   	push   %edi
  801b10:	e8 81 ed ff ff       	call   800896 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b15:	83 c4 04             	add    $0x4,%esp
  801b18:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b1b:	e8 3d ed ff ff       	call   80085d <strlen>
  801b20:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b24:	83 c6 01             	add    $0x1,%esi
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b30:	7f c8                	jg     801afa <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b32:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b38:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b3e:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b45:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b4b:	74 19                	je     801b66 <spawn+0x1c9>
  801b4d:	68 14 2f 80 00       	push   $0x802f14
  801b52:	68 5b 2e 80 00       	push   $0x802e5b
  801b57:	68 f2 00 00 00       	push   $0xf2
  801b5c:	68 a1 2e 80 00       	push   $0x802ea1
  801b61:	e8 d2 e6 ff ff       	call   800238 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b66:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b6c:	89 f8                	mov    %edi,%eax
  801b6e:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b73:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b76:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b7c:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b7f:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b85:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b8b:	83 ec 0c             	sub    $0xc,%esp
  801b8e:	6a 07                	push   $0x7
  801b90:	68 00 d0 bf ee       	push   $0xeebfd000
  801b95:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b9b:	68 00 00 40 00       	push   $0x400000
  801ba0:	6a 00                	push   $0x0
  801ba2:	e8 35 f1 ff ff       	call   800cdc <sys_page_map>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 20             	add    $0x20,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 3c 03 00 00    	js     801ef0 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bb4:	83 ec 08             	sub    $0x8,%esp
  801bb7:	68 00 00 40 00       	push   $0x400000
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 5b f1 ff ff       	call   800d1e <sys_page_unmap>
  801bc3:	89 c3                	mov    %eax,%ebx
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	0f 88 20 03 00 00    	js     801ef0 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bd0:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bd6:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bdd:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801be3:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bea:	00 00 00 
  801bed:	e9 88 01 00 00       	jmp    801d7a <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801bf2:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bf8:	83 38 01             	cmpl   $0x1,(%eax)
  801bfb:	0f 85 6b 01 00 00    	jne    801d6c <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	8b 40 18             	mov    0x18(%eax),%eax
  801c06:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c0c:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c0f:	83 f8 01             	cmp    $0x1,%eax
  801c12:	19 c0                	sbb    %eax,%eax
  801c14:	83 e0 fe             	and    $0xfffffffe,%eax
  801c17:	83 c0 07             	add    $0x7,%eax
  801c1a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c20:	89 d0                	mov    %edx,%eax
  801c22:	8b 7a 04             	mov    0x4(%edx),%edi
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c2d:	8b 7a 10             	mov    0x10(%edx),%edi
  801c30:	8b 52 14             	mov    0x14(%edx),%edx
  801c33:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c39:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c3c:	89 f0                	mov    %esi,%eax
  801c3e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c43:	74 14                	je     801c59 <spawn+0x2bc>
		va -= i;
  801c45:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c47:	01 c2                	add    %eax,%edx
  801c49:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c4f:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c51:	29 c1                	sub    %eax,%ecx
  801c53:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c59:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c5e:	e9 f7 00 00 00       	jmp    801d5a <spawn+0x3bd>
		if (i >= filesz) {
  801c63:	39 fb                	cmp    %edi,%ebx
  801c65:	72 27                	jb     801c8e <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c67:	83 ec 04             	sub    $0x4,%esp
  801c6a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c70:	56                   	push   %esi
  801c71:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c77:	e8 1d f0 ff ff       	call   800c99 <sys_page_alloc>
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	0f 89 c7 00 00 00    	jns    801d4e <spawn+0x3b1>
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	e9 fd 01 00 00       	jmp    801e8b <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c8e:	83 ec 04             	sub    $0x4,%esp
  801c91:	6a 07                	push   $0x7
  801c93:	68 00 00 40 00       	push   $0x400000
  801c98:	6a 00                	push   $0x0
  801c9a:	e8 fa ef ff ff       	call   800c99 <sys_page_alloc>
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	0f 88 d7 01 00 00    	js     801e81 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801caa:	83 ec 08             	sub    $0x8,%esp
  801cad:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cb3:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cc0:	e8 0f f9 ff ff       	call   8015d4 <seek>
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	0f 88 b5 01 00 00    	js     801e85 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cd0:	83 ec 04             	sub    $0x4,%esp
  801cd3:	89 f8                	mov    %edi,%eax
  801cd5:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801cdb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ce0:	ba 00 10 00 00       	mov    $0x1000,%edx
  801ce5:	0f 47 c2             	cmova  %edx,%eax
  801ce8:	50                   	push   %eax
  801ce9:	68 00 00 40 00       	push   $0x400000
  801cee:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cf4:	e8 06 f8 ff ff       	call   8014ff <readn>
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	0f 88 85 01 00 00    	js     801e89 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d0d:	56                   	push   %esi
  801d0e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d14:	68 00 00 40 00       	push   $0x400000
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 bc ef ff ff       	call   800cdc <sys_page_map>
  801d20:	83 c4 20             	add    $0x20,%esp
  801d23:	85 c0                	test   %eax,%eax
  801d25:	79 15                	jns    801d3c <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801d27:	50                   	push   %eax
  801d28:	68 ad 2e 80 00       	push   $0x802ead
  801d2d:	68 25 01 00 00       	push   $0x125
  801d32:	68 a1 2e 80 00       	push   $0x802ea1
  801d37:	e8 fc e4 ff ff       	call   800238 <_panic>
			sys_page_unmap(0, UTEMP);
  801d3c:	83 ec 08             	sub    $0x8,%esp
  801d3f:	68 00 00 40 00       	push   $0x400000
  801d44:	6a 00                	push   $0x0
  801d46:	e8 d3 ef ff ff       	call   800d1e <sys_page_unmap>
  801d4b:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d4e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d54:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d5a:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d60:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d66:	0f 82 f7 fe ff ff    	jb     801c63 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d6c:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d73:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d7a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d81:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d87:	0f 8c 65 fe ff ff    	jl     801bf2 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d96:	e8 97 f5 ff ff       	call   801332 <close>
  801d9b:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da3:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801da9:	89 d8                	mov    %ebx,%eax
  801dab:	c1 e8 16             	shr    $0x16,%eax
  801dae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801db5:	a8 01                	test   $0x1,%al
  801db7:	74 42                	je     801dfb <spawn+0x45e>
  801db9:	89 d8                	mov    %ebx,%eax
  801dbb:	c1 e8 0c             	shr    $0xc,%eax
  801dbe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dc5:	f6 c2 01             	test   $0x1,%dl
  801dc8:	74 31                	je     801dfb <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801dca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801dd1:	f6 c6 04             	test   $0x4,%dh
  801dd4:	74 25                	je     801dfb <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801dd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	25 07 0e 00 00       	and    $0xe07,%eax
  801de5:	50                   	push   %eax
  801de6:	53                   	push   %ebx
  801de7:	56                   	push   %esi
  801de8:	53                   	push   %ebx
  801de9:	6a 00                	push   $0x0
  801deb:	e8 ec ee ff ff       	call   800cdc <sys_page_map>
			if (r < 0) {
  801df0:	83 c4 20             	add    $0x20,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 b1 00 00 00    	js     801eac <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801dfb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e01:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801e07:	75 a0                	jne    801da9 <spawn+0x40c>
  801e09:	e9 b3 00 00 00       	jmp    801ec1 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801e0e:	50                   	push   %eax
  801e0f:	68 ca 2e 80 00       	push   $0x802eca
  801e14:	68 86 00 00 00       	push   $0x86
  801e19:	68 a1 2e 80 00       	push   $0x802ea1
  801e1e:	e8 15 e4 ff ff       	call   800238 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	6a 02                	push   $0x2
  801e28:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e2e:	e8 2d ef ff ff       	call   800d60 <sys_env_set_status>
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 c0                	test   %eax,%eax
  801e38:	79 2b                	jns    801e65 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801e3a:	50                   	push   %eax
  801e3b:	68 e4 2e 80 00       	push   $0x802ee4
  801e40:	68 89 00 00 00       	push   $0x89
  801e45:	68 a1 2e 80 00       	push   $0x802ea1
  801e4a:	e8 e9 e3 ff ff       	call   800238 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e4f:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e55:	e9 a8 00 00 00       	jmp    801f02 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e5a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e60:	e9 9d 00 00 00       	jmp    801f02 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e65:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e6b:	e9 92 00 00 00       	jmp    801f02 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e70:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e75:	e9 88 00 00 00       	jmp    801f02 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	e9 81 00 00 00       	jmp    801f02 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e81:	89 c3                	mov    %eax,%ebx
  801e83:	eb 06                	jmp    801e8b <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e85:	89 c3                	mov    %eax,%ebx
  801e87:	eb 02                	jmp    801e8b <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e89:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e94:	e8 81 ed ff ff       	call   800c1a <sys_env_destroy>
	close(fd);
  801e99:	83 c4 04             	add    $0x4,%esp
  801e9c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ea2:	e8 8b f4 ff ff       	call   801332 <close>
	return r;
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	eb 56                	jmp    801f02 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801eac:	50                   	push   %eax
  801ead:	68 fb 2e 80 00       	push   $0x802efb
  801eb2:	68 82 00 00 00       	push   $0x82
  801eb7:	68 a1 2e 80 00       	push   $0x802ea1
  801ebc:	e8 77 e3 ff ff       	call   800238 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ec1:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ec8:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ecb:	83 ec 08             	sub    $0x8,%esp
  801ece:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ed4:	50                   	push   %eax
  801ed5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801edb:	e8 c2 ee ff ff       	call   800da2 <sys_env_set_trapframe>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	0f 89 38 ff ff ff    	jns    801e23 <spawn+0x486>
  801eeb:	e9 1e ff ff ff       	jmp    801e0e <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ef0:	83 ec 08             	sub    $0x8,%esp
  801ef3:	68 00 00 40 00       	push   $0x400000
  801ef8:	6a 00                	push   $0x0
  801efa:	e8 1f ee ff ff       	call   800d1e <sys_page_unmap>
  801eff:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f02:	89 d8                	mov    %ebx,%eax
  801f04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5f                   	pop    %edi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f11:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f19:	eb 03                	jmp    801f1e <spawnl+0x12>
		argc++;
  801f1b:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f1e:	83 c2 04             	add    $0x4,%edx
  801f21:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f25:	75 f4                	jne    801f1b <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f27:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f2e:	83 e2 f0             	and    $0xfffffff0,%edx
  801f31:	29 d4                	sub    %edx,%esp
  801f33:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f37:	c1 ea 02             	shr    $0x2,%edx
  801f3a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f41:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f46:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f4d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f54:	00 
  801f55:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f57:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5c:	eb 0a                	jmp    801f68 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f5e:	83 c0 01             	add    $0x1,%eax
  801f61:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f65:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f68:	39 d0                	cmp    %edx,%eax
  801f6a:	75 f2                	jne    801f5e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f6c:	83 ec 08             	sub    $0x8,%esp
  801f6f:	56                   	push   %esi
  801f70:	ff 75 08             	pushl  0x8(%ebp)
  801f73:	e8 25 fa ff ff       	call   80199d <spawn>
}
  801f78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	ff 75 08             	pushl  0x8(%ebp)
  801f8d:	e8 10 f2 ff ff       	call   8011a2 <fd2data>
  801f92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f94:	83 c4 08             	add    $0x8,%esp
  801f97:	68 3c 2f 80 00       	push   $0x802f3c
  801f9c:	53                   	push   %ebx
  801f9d:	e8 f4 e8 ff ff       	call   800896 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fa2:	8b 46 04             	mov    0x4(%esi),%eax
  801fa5:	2b 06                	sub    (%esi),%eax
  801fa7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fb4:	00 00 00 
	stat->st_dev = &devpipe;
  801fb7:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801fbe:	30 80 00 
	return 0;
}
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc9:	5b                   	pop    %ebx
  801fca:	5e                   	pop    %esi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	53                   	push   %ebx
  801fd1:	83 ec 0c             	sub    $0xc,%esp
  801fd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fd7:	53                   	push   %ebx
  801fd8:	6a 00                	push   $0x0
  801fda:	e8 3f ed ff ff       	call   800d1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fdf:	89 1c 24             	mov    %ebx,(%esp)
  801fe2:	e8 bb f1 ff ff       	call   8011a2 <fd2data>
  801fe7:	83 c4 08             	add    $0x8,%esp
  801fea:	50                   	push   %eax
  801feb:	6a 00                	push   $0x0
  801fed:	e8 2c ed ff ff       	call   800d1e <sys_page_unmap>
}
  801ff2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	57                   	push   %edi
  801ffb:	56                   	push   %esi
  801ffc:	53                   	push   %ebx
  801ffd:	83 ec 1c             	sub    $0x1c,%esp
  802000:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802003:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802005:	a1 04 40 80 00       	mov    0x804004,%eax
  80200a:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80200d:	83 ec 0c             	sub    $0xc,%esp
  802010:	ff 75 e0             	pushl  -0x20(%ebp)
  802013:	e8 3d 06 00 00       	call   802655 <pageref>
  802018:	89 c3                	mov    %eax,%ebx
  80201a:	89 3c 24             	mov    %edi,(%esp)
  80201d:	e8 33 06 00 00       	call   802655 <pageref>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	39 c3                	cmp    %eax,%ebx
  802027:	0f 94 c1             	sete   %cl
  80202a:	0f b6 c9             	movzbl %cl,%ecx
  80202d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802030:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802036:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  802039:	39 ce                	cmp    %ecx,%esi
  80203b:	74 1b                	je     802058 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80203d:	39 c3                	cmp    %eax,%ebx
  80203f:	75 c4                	jne    802005 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802041:	8b 42 60             	mov    0x60(%edx),%eax
  802044:	ff 75 e4             	pushl  -0x1c(%ebp)
  802047:	50                   	push   %eax
  802048:	56                   	push   %esi
  802049:	68 43 2f 80 00       	push   $0x802f43
  80204e:	e8 be e2 ff ff       	call   800311 <cprintf>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	eb ad                	jmp    802005 <_pipeisclosed+0xe>
	}
}
  802058:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80205b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205e:	5b                   	pop    %ebx
  80205f:	5e                   	pop    %esi
  802060:	5f                   	pop    %edi
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    

00802063 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	57                   	push   %edi
  802067:	56                   	push   %esi
  802068:	53                   	push   %ebx
  802069:	83 ec 28             	sub    $0x28,%esp
  80206c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80206f:	56                   	push   %esi
  802070:	e8 2d f1 ff ff       	call   8011a2 <fd2data>
  802075:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	bf 00 00 00 00       	mov    $0x0,%edi
  80207f:	eb 4b                	jmp    8020cc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802081:	89 da                	mov    %ebx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	e8 6d ff ff ff       	call   801ff7 <_pipeisclosed>
  80208a:	85 c0                	test   %eax,%eax
  80208c:	75 48                	jne    8020d6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80208e:	e8 e7 eb ff ff       	call   800c7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802093:	8b 43 04             	mov    0x4(%ebx),%eax
  802096:	8b 0b                	mov    (%ebx),%ecx
  802098:	8d 51 20             	lea    0x20(%ecx),%edx
  80209b:	39 d0                	cmp    %edx,%eax
  80209d:	73 e2                	jae    802081 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80209f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020a6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a9:	89 c2                	mov    %eax,%edx
  8020ab:	c1 fa 1f             	sar    $0x1f,%edx
  8020ae:	89 d1                	mov    %edx,%ecx
  8020b0:	c1 e9 1b             	shr    $0x1b,%ecx
  8020b3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020b6:	83 e2 1f             	and    $0x1f,%edx
  8020b9:	29 ca                	sub    %ecx,%edx
  8020bb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020bf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020c3:	83 c0 01             	add    $0x1,%eax
  8020c6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c9:	83 c7 01             	add    $0x1,%edi
  8020cc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020cf:	75 c2                	jne    802093 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d4:	eb 05                	jmp    8020db <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5f                   	pop    %edi
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    

008020e3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	57                   	push   %edi
  8020e7:	56                   	push   %esi
  8020e8:	53                   	push   %ebx
  8020e9:	83 ec 18             	sub    $0x18,%esp
  8020ec:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020ef:	57                   	push   %edi
  8020f0:	e8 ad f0 ff ff       	call   8011a2 <fd2data>
  8020f5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020ff:	eb 3d                	jmp    80213e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802101:	85 db                	test   %ebx,%ebx
  802103:	74 04                	je     802109 <devpipe_read+0x26>
				return i;
  802105:	89 d8                	mov    %ebx,%eax
  802107:	eb 44                	jmp    80214d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802109:	89 f2                	mov    %esi,%edx
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	e8 e5 fe ff ff       	call   801ff7 <_pipeisclosed>
  802112:	85 c0                	test   %eax,%eax
  802114:	75 32                	jne    802148 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802116:	e8 5f eb ff ff       	call   800c7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80211b:	8b 06                	mov    (%esi),%eax
  80211d:	3b 46 04             	cmp    0x4(%esi),%eax
  802120:	74 df                	je     802101 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802122:	99                   	cltd   
  802123:	c1 ea 1b             	shr    $0x1b,%edx
  802126:	01 d0                	add    %edx,%eax
  802128:	83 e0 1f             	and    $0x1f,%eax
  80212b:	29 d0                	sub    %edx,%eax
  80212d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802135:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802138:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80213b:	83 c3 01             	add    $0x1,%ebx
  80213e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802141:	75 d8                	jne    80211b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802143:	8b 45 10             	mov    0x10(%ebp),%eax
  802146:	eb 05                	jmp    80214d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802148:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80214d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	56                   	push   %esi
  802159:	53                   	push   %ebx
  80215a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80215d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802160:	50                   	push   %eax
  802161:	e8 53 f0 ff ff       	call   8011b9 <fd_alloc>
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	89 c2                	mov    %eax,%edx
  80216b:	85 c0                	test   %eax,%eax
  80216d:	0f 88 2c 01 00 00    	js     80229f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802173:	83 ec 04             	sub    $0x4,%esp
  802176:	68 07 04 00 00       	push   $0x407
  80217b:	ff 75 f4             	pushl  -0xc(%ebp)
  80217e:	6a 00                	push   $0x0
  802180:	e8 14 eb ff ff       	call   800c99 <sys_page_alloc>
  802185:	83 c4 10             	add    $0x10,%esp
  802188:	89 c2                	mov    %eax,%edx
  80218a:	85 c0                	test   %eax,%eax
  80218c:	0f 88 0d 01 00 00    	js     80229f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802192:	83 ec 0c             	sub    $0xc,%esp
  802195:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802198:	50                   	push   %eax
  802199:	e8 1b f0 ff ff       	call   8011b9 <fd_alloc>
  80219e:	89 c3                	mov    %eax,%ebx
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	0f 88 e2 00 00 00    	js     80228d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ab:	83 ec 04             	sub    $0x4,%esp
  8021ae:	68 07 04 00 00       	push   $0x407
  8021b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b6:	6a 00                	push   $0x0
  8021b8:	e8 dc ea ff ff       	call   800c99 <sys_page_alloc>
  8021bd:	89 c3                	mov    %eax,%ebx
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	85 c0                	test   %eax,%eax
  8021c4:	0f 88 c3 00 00 00    	js     80228d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021ca:	83 ec 0c             	sub    $0xc,%esp
  8021cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d0:	e8 cd ef ff ff       	call   8011a2 <fd2data>
  8021d5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d7:	83 c4 0c             	add    $0xc,%esp
  8021da:	68 07 04 00 00       	push   $0x407
  8021df:	50                   	push   %eax
  8021e0:	6a 00                	push   $0x0
  8021e2:	e8 b2 ea ff ff       	call   800c99 <sys_page_alloc>
  8021e7:	89 c3                	mov    %eax,%ebx
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	0f 88 89 00 00 00    	js     80227d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f4:	83 ec 0c             	sub    $0xc,%esp
  8021f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8021fa:	e8 a3 ef ff ff       	call   8011a2 <fd2data>
  8021ff:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802206:	50                   	push   %eax
  802207:	6a 00                	push   $0x0
  802209:	56                   	push   %esi
  80220a:	6a 00                	push   $0x0
  80220c:	e8 cb ea ff ff       	call   800cdc <sys_page_map>
  802211:	89 c3                	mov    %eax,%ebx
  802213:	83 c4 20             	add    $0x20,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	78 55                	js     80226f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80221a:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802228:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80222f:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802238:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80223a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80223d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802244:	83 ec 0c             	sub    $0xc,%esp
  802247:	ff 75 f4             	pushl  -0xc(%ebp)
  80224a:	e8 43 ef ff ff       	call   801192 <fd2num>
  80224f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802252:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802254:	83 c4 04             	add    $0x4,%esp
  802257:	ff 75 f0             	pushl  -0x10(%ebp)
  80225a:	e8 33 ef ff ff       	call   801192 <fd2num>
  80225f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802262:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	ba 00 00 00 00       	mov    $0x0,%edx
  80226d:	eb 30                	jmp    80229f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80226f:	83 ec 08             	sub    $0x8,%esp
  802272:	56                   	push   %esi
  802273:	6a 00                	push   $0x0
  802275:	e8 a4 ea ff ff       	call   800d1e <sys_page_unmap>
  80227a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80227d:	83 ec 08             	sub    $0x8,%esp
  802280:	ff 75 f0             	pushl  -0x10(%ebp)
  802283:	6a 00                	push   $0x0
  802285:	e8 94 ea ff ff       	call   800d1e <sys_page_unmap>
  80228a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80228d:	83 ec 08             	sub    $0x8,%esp
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 84 ea ff ff       	call   800d1e <sys_page_unmap>
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b1:	50                   	push   %eax
  8022b2:	ff 75 08             	pushl  0x8(%ebp)
  8022b5:	e8 4e ef ff ff       	call   801208 <fd_lookup>
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	78 18                	js     8022d9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022c1:	83 ec 0c             	sub    $0xc,%esp
  8022c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c7:	e8 d6 ee ff ff       	call   8011a2 <fd2data>
	return _pipeisclosed(fd, p);
  8022cc:	89 c2                	mov    %eax,%edx
  8022ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d1:	e8 21 fd ff ff       	call   801ff7 <_pipeisclosed>
  8022d6:	83 c4 10             	add    $0x10,%esp
}
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022e3:	85 f6                	test   %esi,%esi
  8022e5:	75 16                	jne    8022fd <wait+0x22>
  8022e7:	68 5b 2f 80 00       	push   $0x802f5b
  8022ec:	68 5b 2e 80 00       	push   $0x802e5b
  8022f1:	6a 09                	push   $0x9
  8022f3:	68 66 2f 80 00       	push   $0x802f66
  8022f8:	e8 3b df ff ff       	call   800238 <_panic>
	e = &envs[ENVX(envid)];
  8022fd:	89 f0                	mov    %esi,%eax
  8022ff:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802304:	89 c2                	mov    %eax,%edx
  802306:	c1 e2 07             	shl    $0x7,%edx
  802309:	8d 9c 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%ebx
  802310:	eb 05                	jmp    802317 <wait+0x3c>
		sys_yield();
  802312:	e8 63 e9 ff ff       	call   800c7a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802317:	8b 43 50             	mov    0x50(%ebx),%eax
  80231a:	39 c6                	cmp    %eax,%esi
  80231c:	75 07                	jne    802325 <wait+0x4a>
  80231e:	8b 43 5c             	mov    0x5c(%ebx),%eax
  802321:	85 c0                	test   %eax,%eax
  802323:	75 ed                	jne    802312 <wait+0x37>
		sys_yield();
}
  802325:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    

0080232c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    

00802336 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80233c:	68 71 2f 80 00       	push   $0x802f71
  802341:	ff 75 0c             	pushl  0xc(%ebp)
  802344:	e8 4d e5 ff ff       	call   800896 <strcpy>
	return 0;
}
  802349:	b8 00 00 00 00       	mov    $0x0,%eax
  80234e:	c9                   	leave  
  80234f:	c3                   	ret    

00802350 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
  802353:	57                   	push   %edi
  802354:	56                   	push   %esi
  802355:	53                   	push   %ebx
  802356:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80235c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802361:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802367:	eb 2d                	jmp    802396 <devcons_write+0x46>
		m = n - tot;
  802369:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80236c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80236e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802371:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802376:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802379:	83 ec 04             	sub    $0x4,%esp
  80237c:	53                   	push   %ebx
  80237d:	03 45 0c             	add    0xc(%ebp),%eax
  802380:	50                   	push   %eax
  802381:	57                   	push   %edi
  802382:	e8 a1 e6 ff ff       	call   800a28 <memmove>
		sys_cputs(buf, m);
  802387:	83 c4 08             	add    $0x8,%esp
  80238a:	53                   	push   %ebx
  80238b:	57                   	push   %edi
  80238c:	e8 4c e8 ff ff       	call   800bdd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802391:	01 de                	add    %ebx,%esi
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	89 f0                	mov    %esi,%eax
  802398:	3b 75 10             	cmp    0x10(%ebp),%esi
  80239b:	72 cc                	jb     802369 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80239d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023a0:	5b                   	pop    %ebx
  8023a1:	5e                   	pop    %esi
  8023a2:	5f                   	pop    %edi
  8023a3:	5d                   	pop    %ebp
  8023a4:	c3                   	ret    

008023a5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	83 ec 08             	sub    $0x8,%esp
  8023ab:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023b4:	74 2a                	je     8023e0 <devcons_read+0x3b>
  8023b6:	eb 05                	jmp    8023bd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023b8:	e8 bd e8 ff ff       	call   800c7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023bd:	e8 39 e8 ff ff       	call   800bfb <sys_cgetc>
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	74 f2                	je     8023b8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	78 16                	js     8023e0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023ca:	83 f8 04             	cmp    $0x4,%eax
  8023cd:	74 0c                	je     8023db <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023d2:	88 02                	mov    %al,(%edx)
	return 1;
  8023d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d9:	eb 05                	jmp    8023e0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023e0:	c9                   	leave  
  8023e1:	c3                   	ret    

008023e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023e2:	55                   	push   %ebp
  8023e3:	89 e5                	mov    %esp,%ebp
  8023e5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023ee:	6a 01                	push   $0x1
  8023f0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023f3:	50                   	push   %eax
  8023f4:	e8 e4 e7 ff ff       	call   800bdd <sys_cputs>
}
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	c9                   	leave  
  8023fd:	c3                   	ret    

008023fe <getchar>:

int
getchar(void)
{
  8023fe:	55                   	push   %ebp
  8023ff:	89 e5                	mov    %esp,%ebp
  802401:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802404:	6a 01                	push   $0x1
  802406:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802409:	50                   	push   %eax
  80240a:	6a 00                	push   $0x0
  80240c:	e8 5d f0 ff ff       	call   80146e <read>
	if (r < 0)
  802411:	83 c4 10             	add    $0x10,%esp
  802414:	85 c0                	test   %eax,%eax
  802416:	78 0f                	js     802427 <getchar+0x29>
		return r;
	if (r < 1)
  802418:	85 c0                	test   %eax,%eax
  80241a:	7e 06                	jle    802422 <getchar+0x24>
		return -E_EOF;
	return c;
  80241c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802420:	eb 05                	jmp    802427 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802422:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802427:	c9                   	leave  
  802428:	c3                   	ret    

00802429 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80242f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802432:	50                   	push   %eax
  802433:	ff 75 08             	pushl  0x8(%ebp)
  802436:	e8 cd ed ff ff       	call   801208 <fd_lookup>
  80243b:	83 c4 10             	add    $0x10,%esp
  80243e:	85 c0                	test   %eax,%eax
  802440:	78 11                	js     802453 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802445:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80244b:	39 10                	cmp    %edx,(%eax)
  80244d:	0f 94 c0             	sete   %al
  802450:	0f b6 c0             	movzbl %al,%eax
}
  802453:	c9                   	leave  
  802454:	c3                   	ret    

00802455 <opencons>:

int
opencons(void)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80245b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245e:	50                   	push   %eax
  80245f:	e8 55 ed ff ff       	call   8011b9 <fd_alloc>
  802464:	83 c4 10             	add    $0x10,%esp
		return r;
  802467:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802469:	85 c0                	test   %eax,%eax
  80246b:	78 3e                	js     8024ab <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80246d:	83 ec 04             	sub    $0x4,%esp
  802470:	68 07 04 00 00       	push   $0x407
  802475:	ff 75 f4             	pushl  -0xc(%ebp)
  802478:	6a 00                	push   $0x0
  80247a:	e8 1a e8 ff ff       	call   800c99 <sys_page_alloc>
  80247f:	83 c4 10             	add    $0x10,%esp
		return r;
  802482:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802484:	85 c0                	test   %eax,%eax
  802486:	78 23                	js     8024ab <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802488:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80248e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802491:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802493:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802496:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80249d:	83 ec 0c             	sub    $0xc,%esp
  8024a0:	50                   	push   %eax
  8024a1:	e8 ec ec ff ff       	call   801192 <fd2num>
  8024a6:	89 c2                	mov    %eax,%edx
  8024a8:	83 c4 10             	add    $0x10,%esp
}
  8024ab:	89 d0                	mov    %edx,%eax
  8024ad:	c9                   	leave  
  8024ae:	c3                   	ret    

008024af <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024af:	55                   	push   %ebp
  8024b0:	89 e5                	mov    %esp,%ebp
  8024b2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024b5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8024bc:	75 2a                	jne    8024e8 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8024be:	83 ec 04             	sub    $0x4,%esp
  8024c1:	6a 07                	push   $0x7
  8024c3:	68 00 f0 bf ee       	push   $0xeebff000
  8024c8:	6a 00                	push   $0x0
  8024ca:	e8 ca e7 ff ff       	call   800c99 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8024cf:	83 c4 10             	add    $0x10,%esp
  8024d2:	85 c0                	test   %eax,%eax
  8024d4:	79 12                	jns    8024e8 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8024d6:	50                   	push   %eax
  8024d7:	68 7d 2f 80 00       	push   $0x802f7d
  8024dc:	6a 23                	push   $0x23
  8024de:	68 81 2f 80 00       	push   $0x802f81
  8024e3:	e8 50 dd ff ff       	call   800238 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024eb:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8024f0:	83 ec 08             	sub    $0x8,%esp
  8024f3:	68 1a 25 80 00       	push   $0x80251a
  8024f8:	6a 00                	push   $0x0
  8024fa:	e8 e5 e8 ff ff       	call   800de4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8024ff:	83 c4 10             	add    $0x10,%esp
  802502:	85 c0                	test   %eax,%eax
  802504:	79 12                	jns    802518 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802506:	50                   	push   %eax
  802507:	68 7d 2f 80 00       	push   $0x802f7d
  80250c:	6a 2c                	push   $0x2c
  80250e:	68 81 2f 80 00       	push   $0x802f81
  802513:	e8 20 dd ff ff       	call   800238 <_panic>
	}
}
  802518:	c9                   	leave  
  802519:	c3                   	ret    

0080251a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80251a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80251b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802520:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802522:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802525:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802529:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80252e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802532:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802534:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802537:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802538:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80253b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80253c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80253d:	c3                   	ret    

0080253e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80253e:	55                   	push   %ebp
  80253f:	89 e5                	mov    %esp,%ebp
  802541:	56                   	push   %esi
  802542:	53                   	push   %ebx
  802543:	8b 75 08             	mov    0x8(%ebp),%esi
  802546:	8b 45 0c             	mov    0xc(%ebp),%eax
  802549:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80254c:	85 c0                	test   %eax,%eax
  80254e:	75 12                	jne    802562 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802550:	83 ec 0c             	sub    $0xc,%esp
  802553:	68 00 00 c0 ee       	push   $0xeec00000
  802558:	e8 ec e8 ff ff       	call   800e49 <sys_ipc_recv>
  80255d:	83 c4 10             	add    $0x10,%esp
  802560:	eb 0c                	jmp    80256e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802562:	83 ec 0c             	sub    $0xc,%esp
  802565:	50                   	push   %eax
  802566:	e8 de e8 ff ff       	call   800e49 <sys_ipc_recv>
  80256b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80256e:	85 f6                	test   %esi,%esi
  802570:	0f 95 c1             	setne  %cl
  802573:	85 db                	test   %ebx,%ebx
  802575:	0f 95 c2             	setne  %dl
  802578:	84 d1                	test   %dl,%cl
  80257a:	74 09                	je     802585 <ipc_recv+0x47>
  80257c:	89 c2                	mov    %eax,%edx
  80257e:	c1 ea 1f             	shr    $0x1f,%edx
  802581:	84 d2                	test   %dl,%dl
  802583:	75 27                	jne    8025ac <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802585:	85 f6                	test   %esi,%esi
  802587:	74 0a                	je     802593 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  802589:	a1 04 40 80 00       	mov    0x804004,%eax
  80258e:	8b 40 7c             	mov    0x7c(%eax),%eax
  802591:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802593:	85 db                	test   %ebx,%ebx
  802595:	74 0d                	je     8025a4 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  802597:	a1 04 40 80 00       	mov    0x804004,%eax
  80259c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8025a2:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8025a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8025a9:	8b 40 78             	mov    0x78(%eax),%eax
}
  8025ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5d                   	pop    %ebp
  8025b2:	c3                   	ret    

008025b3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025b3:	55                   	push   %ebp
  8025b4:	89 e5                	mov    %esp,%ebp
  8025b6:	57                   	push   %edi
  8025b7:	56                   	push   %esi
  8025b8:	53                   	push   %ebx
  8025b9:	83 ec 0c             	sub    $0xc,%esp
  8025bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8025c5:	85 db                	test   %ebx,%ebx
  8025c7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025cc:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8025cf:	ff 75 14             	pushl  0x14(%ebp)
  8025d2:	53                   	push   %ebx
  8025d3:	56                   	push   %esi
  8025d4:	57                   	push   %edi
  8025d5:	e8 4c e8 ff ff       	call   800e26 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8025da:	89 c2                	mov    %eax,%edx
  8025dc:	c1 ea 1f             	shr    $0x1f,%edx
  8025df:	83 c4 10             	add    $0x10,%esp
  8025e2:	84 d2                	test   %dl,%dl
  8025e4:	74 17                	je     8025fd <ipc_send+0x4a>
  8025e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025e9:	74 12                	je     8025fd <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8025eb:	50                   	push   %eax
  8025ec:	68 8f 2f 80 00       	push   $0x802f8f
  8025f1:	6a 47                	push   $0x47
  8025f3:	68 9d 2f 80 00       	push   $0x802f9d
  8025f8:	e8 3b dc ff ff       	call   800238 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8025fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802600:	75 07                	jne    802609 <ipc_send+0x56>
			sys_yield();
  802602:	e8 73 e6 ff ff       	call   800c7a <sys_yield>
  802607:	eb c6                	jmp    8025cf <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802609:	85 c0                	test   %eax,%eax
  80260b:	75 c2                	jne    8025cf <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80260d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802610:	5b                   	pop    %ebx
  802611:	5e                   	pop    %esi
  802612:	5f                   	pop    %edi
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    

00802615 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802615:	55                   	push   %ebp
  802616:	89 e5                	mov    %esp,%ebp
  802618:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80261b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802620:	89 c2                	mov    %eax,%edx
  802622:	c1 e2 07             	shl    $0x7,%edx
  802625:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80262c:	8b 52 58             	mov    0x58(%edx),%edx
  80262f:	39 ca                	cmp    %ecx,%edx
  802631:	75 11                	jne    802644 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802633:	89 c2                	mov    %eax,%edx
  802635:	c1 e2 07             	shl    $0x7,%edx
  802638:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80263f:	8b 40 50             	mov    0x50(%eax),%eax
  802642:	eb 0f                	jmp    802653 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802644:	83 c0 01             	add    $0x1,%eax
  802647:	3d 00 04 00 00       	cmp    $0x400,%eax
  80264c:	75 d2                	jne    802620 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80264e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802653:	5d                   	pop    %ebp
  802654:	c3                   	ret    

00802655 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802655:	55                   	push   %ebp
  802656:	89 e5                	mov    %esp,%ebp
  802658:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80265b:	89 d0                	mov    %edx,%eax
  80265d:	c1 e8 16             	shr    $0x16,%eax
  802660:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802667:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80266c:	f6 c1 01             	test   $0x1,%cl
  80266f:	74 1d                	je     80268e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802671:	c1 ea 0c             	shr    $0xc,%edx
  802674:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80267b:	f6 c2 01             	test   $0x1,%dl
  80267e:	74 0e                	je     80268e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802680:	c1 ea 0c             	shr    $0xc,%edx
  802683:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80268a:	ef 
  80268b:	0f b7 c0             	movzwl %ax,%eax
}
  80268e:	5d                   	pop    %ebp
  80268f:	c3                   	ret    

00802690 <__udivdi3>:
  802690:	55                   	push   %ebp
  802691:	57                   	push   %edi
  802692:	56                   	push   %esi
  802693:	53                   	push   %ebx
  802694:	83 ec 1c             	sub    $0x1c,%esp
  802697:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80269b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80269f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026a7:	85 f6                	test   %esi,%esi
  8026a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026ad:	89 ca                	mov    %ecx,%edx
  8026af:	89 f8                	mov    %edi,%eax
  8026b1:	75 3d                	jne    8026f0 <__udivdi3+0x60>
  8026b3:	39 cf                	cmp    %ecx,%edi
  8026b5:	0f 87 c5 00 00 00    	ja     802780 <__udivdi3+0xf0>
  8026bb:	85 ff                	test   %edi,%edi
  8026bd:	89 fd                	mov    %edi,%ebp
  8026bf:	75 0b                	jne    8026cc <__udivdi3+0x3c>
  8026c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026c6:	31 d2                	xor    %edx,%edx
  8026c8:	f7 f7                	div    %edi
  8026ca:	89 c5                	mov    %eax,%ebp
  8026cc:	89 c8                	mov    %ecx,%eax
  8026ce:	31 d2                	xor    %edx,%edx
  8026d0:	f7 f5                	div    %ebp
  8026d2:	89 c1                	mov    %eax,%ecx
  8026d4:	89 d8                	mov    %ebx,%eax
  8026d6:	89 cf                	mov    %ecx,%edi
  8026d8:	f7 f5                	div    %ebp
  8026da:	89 c3                	mov    %eax,%ebx
  8026dc:	89 d8                	mov    %ebx,%eax
  8026de:	89 fa                	mov    %edi,%edx
  8026e0:	83 c4 1c             	add    $0x1c,%esp
  8026e3:	5b                   	pop    %ebx
  8026e4:	5e                   	pop    %esi
  8026e5:	5f                   	pop    %edi
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    
  8026e8:	90                   	nop
  8026e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	39 ce                	cmp    %ecx,%esi
  8026f2:	77 74                	ja     802768 <__udivdi3+0xd8>
  8026f4:	0f bd fe             	bsr    %esi,%edi
  8026f7:	83 f7 1f             	xor    $0x1f,%edi
  8026fa:	0f 84 98 00 00 00    	je     802798 <__udivdi3+0x108>
  802700:	bb 20 00 00 00       	mov    $0x20,%ebx
  802705:	89 f9                	mov    %edi,%ecx
  802707:	89 c5                	mov    %eax,%ebp
  802709:	29 fb                	sub    %edi,%ebx
  80270b:	d3 e6                	shl    %cl,%esi
  80270d:	89 d9                	mov    %ebx,%ecx
  80270f:	d3 ed                	shr    %cl,%ebp
  802711:	89 f9                	mov    %edi,%ecx
  802713:	d3 e0                	shl    %cl,%eax
  802715:	09 ee                	or     %ebp,%esi
  802717:	89 d9                	mov    %ebx,%ecx
  802719:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80271d:	89 d5                	mov    %edx,%ebp
  80271f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802723:	d3 ed                	shr    %cl,%ebp
  802725:	89 f9                	mov    %edi,%ecx
  802727:	d3 e2                	shl    %cl,%edx
  802729:	89 d9                	mov    %ebx,%ecx
  80272b:	d3 e8                	shr    %cl,%eax
  80272d:	09 c2                	or     %eax,%edx
  80272f:	89 d0                	mov    %edx,%eax
  802731:	89 ea                	mov    %ebp,%edx
  802733:	f7 f6                	div    %esi
  802735:	89 d5                	mov    %edx,%ebp
  802737:	89 c3                	mov    %eax,%ebx
  802739:	f7 64 24 0c          	mull   0xc(%esp)
  80273d:	39 d5                	cmp    %edx,%ebp
  80273f:	72 10                	jb     802751 <__udivdi3+0xc1>
  802741:	8b 74 24 08          	mov    0x8(%esp),%esi
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e6                	shl    %cl,%esi
  802749:	39 c6                	cmp    %eax,%esi
  80274b:	73 07                	jae    802754 <__udivdi3+0xc4>
  80274d:	39 d5                	cmp    %edx,%ebp
  80274f:	75 03                	jne    802754 <__udivdi3+0xc4>
  802751:	83 eb 01             	sub    $0x1,%ebx
  802754:	31 ff                	xor    %edi,%edi
  802756:	89 d8                	mov    %ebx,%eax
  802758:	89 fa                	mov    %edi,%edx
  80275a:	83 c4 1c             	add    $0x1c,%esp
  80275d:	5b                   	pop    %ebx
  80275e:	5e                   	pop    %esi
  80275f:	5f                   	pop    %edi
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    
  802762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802768:	31 ff                	xor    %edi,%edi
  80276a:	31 db                	xor    %ebx,%ebx
  80276c:	89 d8                	mov    %ebx,%eax
  80276e:	89 fa                	mov    %edi,%edx
  802770:	83 c4 1c             	add    $0x1c,%esp
  802773:	5b                   	pop    %ebx
  802774:	5e                   	pop    %esi
  802775:	5f                   	pop    %edi
  802776:	5d                   	pop    %ebp
  802777:	c3                   	ret    
  802778:	90                   	nop
  802779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802780:	89 d8                	mov    %ebx,%eax
  802782:	f7 f7                	div    %edi
  802784:	31 ff                	xor    %edi,%edi
  802786:	89 c3                	mov    %eax,%ebx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 fa                	mov    %edi,%edx
  80278c:	83 c4 1c             	add    $0x1c,%esp
  80278f:	5b                   	pop    %ebx
  802790:	5e                   	pop    %esi
  802791:	5f                   	pop    %edi
  802792:	5d                   	pop    %ebp
  802793:	c3                   	ret    
  802794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802798:	39 ce                	cmp    %ecx,%esi
  80279a:	72 0c                	jb     8027a8 <__udivdi3+0x118>
  80279c:	31 db                	xor    %ebx,%ebx
  80279e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027a2:	0f 87 34 ff ff ff    	ja     8026dc <__udivdi3+0x4c>
  8027a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027ad:	e9 2a ff ff ff       	jmp    8026dc <__udivdi3+0x4c>
  8027b2:	66 90                	xchg   %ax,%ax
  8027b4:	66 90                	xchg   %ax,%ax
  8027b6:	66 90                	xchg   %ax,%ax
  8027b8:	66 90                	xchg   %ax,%ax
  8027ba:	66 90                	xchg   %ax,%ax
  8027bc:	66 90                	xchg   %ax,%ax
  8027be:	66 90                	xchg   %ax,%ax

008027c0 <__umoddi3>:
  8027c0:	55                   	push   %ebp
  8027c1:	57                   	push   %edi
  8027c2:	56                   	push   %esi
  8027c3:	53                   	push   %ebx
  8027c4:	83 ec 1c             	sub    $0x1c,%esp
  8027c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027d7:	85 d2                	test   %edx,%edx
  8027d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027e1:	89 f3                	mov    %esi,%ebx
  8027e3:	89 3c 24             	mov    %edi,(%esp)
  8027e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ea:	75 1c                	jne    802808 <__umoddi3+0x48>
  8027ec:	39 f7                	cmp    %esi,%edi
  8027ee:	76 50                	jbe    802840 <__umoddi3+0x80>
  8027f0:	89 c8                	mov    %ecx,%eax
  8027f2:	89 f2                	mov    %esi,%edx
  8027f4:	f7 f7                	div    %edi
  8027f6:	89 d0                	mov    %edx,%eax
  8027f8:	31 d2                	xor    %edx,%edx
  8027fa:	83 c4 1c             	add    $0x1c,%esp
  8027fd:	5b                   	pop    %ebx
  8027fe:	5e                   	pop    %esi
  8027ff:	5f                   	pop    %edi
  802800:	5d                   	pop    %ebp
  802801:	c3                   	ret    
  802802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802808:	39 f2                	cmp    %esi,%edx
  80280a:	89 d0                	mov    %edx,%eax
  80280c:	77 52                	ja     802860 <__umoddi3+0xa0>
  80280e:	0f bd ea             	bsr    %edx,%ebp
  802811:	83 f5 1f             	xor    $0x1f,%ebp
  802814:	75 5a                	jne    802870 <__umoddi3+0xb0>
  802816:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80281a:	0f 82 e0 00 00 00    	jb     802900 <__umoddi3+0x140>
  802820:	39 0c 24             	cmp    %ecx,(%esp)
  802823:	0f 86 d7 00 00 00    	jbe    802900 <__umoddi3+0x140>
  802829:	8b 44 24 08          	mov    0x8(%esp),%eax
  80282d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802831:	83 c4 1c             	add    $0x1c,%esp
  802834:	5b                   	pop    %ebx
  802835:	5e                   	pop    %esi
  802836:	5f                   	pop    %edi
  802837:	5d                   	pop    %ebp
  802838:	c3                   	ret    
  802839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802840:	85 ff                	test   %edi,%edi
  802842:	89 fd                	mov    %edi,%ebp
  802844:	75 0b                	jne    802851 <__umoddi3+0x91>
  802846:	b8 01 00 00 00       	mov    $0x1,%eax
  80284b:	31 d2                	xor    %edx,%edx
  80284d:	f7 f7                	div    %edi
  80284f:	89 c5                	mov    %eax,%ebp
  802851:	89 f0                	mov    %esi,%eax
  802853:	31 d2                	xor    %edx,%edx
  802855:	f7 f5                	div    %ebp
  802857:	89 c8                	mov    %ecx,%eax
  802859:	f7 f5                	div    %ebp
  80285b:	89 d0                	mov    %edx,%eax
  80285d:	eb 99                	jmp    8027f8 <__umoddi3+0x38>
  80285f:	90                   	nop
  802860:	89 c8                	mov    %ecx,%eax
  802862:	89 f2                	mov    %esi,%edx
  802864:	83 c4 1c             	add    $0x1c,%esp
  802867:	5b                   	pop    %ebx
  802868:	5e                   	pop    %esi
  802869:	5f                   	pop    %edi
  80286a:	5d                   	pop    %ebp
  80286b:	c3                   	ret    
  80286c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802870:	8b 34 24             	mov    (%esp),%esi
  802873:	bf 20 00 00 00       	mov    $0x20,%edi
  802878:	89 e9                	mov    %ebp,%ecx
  80287a:	29 ef                	sub    %ebp,%edi
  80287c:	d3 e0                	shl    %cl,%eax
  80287e:	89 f9                	mov    %edi,%ecx
  802880:	89 f2                	mov    %esi,%edx
  802882:	d3 ea                	shr    %cl,%edx
  802884:	89 e9                	mov    %ebp,%ecx
  802886:	09 c2                	or     %eax,%edx
  802888:	89 d8                	mov    %ebx,%eax
  80288a:	89 14 24             	mov    %edx,(%esp)
  80288d:	89 f2                	mov    %esi,%edx
  80288f:	d3 e2                	shl    %cl,%edx
  802891:	89 f9                	mov    %edi,%ecx
  802893:	89 54 24 04          	mov    %edx,0x4(%esp)
  802897:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80289b:	d3 e8                	shr    %cl,%eax
  80289d:	89 e9                	mov    %ebp,%ecx
  80289f:	89 c6                	mov    %eax,%esi
  8028a1:	d3 e3                	shl    %cl,%ebx
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 d0                	mov    %edx,%eax
  8028a7:	d3 e8                	shr    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	09 d8                	or     %ebx,%eax
  8028ad:	89 d3                	mov    %edx,%ebx
  8028af:	89 f2                	mov    %esi,%edx
  8028b1:	f7 34 24             	divl   (%esp)
  8028b4:	89 d6                	mov    %edx,%esi
  8028b6:	d3 e3                	shl    %cl,%ebx
  8028b8:	f7 64 24 04          	mull   0x4(%esp)
  8028bc:	39 d6                	cmp    %edx,%esi
  8028be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028c2:	89 d1                	mov    %edx,%ecx
  8028c4:	89 c3                	mov    %eax,%ebx
  8028c6:	72 08                	jb     8028d0 <__umoddi3+0x110>
  8028c8:	75 11                	jne    8028db <__umoddi3+0x11b>
  8028ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ce:	73 0b                	jae    8028db <__umoddi3+0x11b>
  8028d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028d4:	1b 14 24             	sbb    (%esp),%edx
  8028d7:	89 d1                	mov    %edx,%ecx
  8028d9:	89 c3                	mov    %eax,%ebx
  8028db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028df:	29 da                	sub    %ebx,%edx
  8028e1:	19 ce                	sbb    %ecx,%esi
  8028e3:	89 f9                	mov    %edi,%ecx
  8028e5:	89 f0                	mov    %esi,%eax
  8028e7:	d3 e0                	shl    %cl,%eax
  8028e9:	89 e9                	mov    %ebp,%ecx
  8028eb:	d3 ea                	shr    %cl,%edx
  8028ed:	89 e9                	mov    %ebp,%ecx
  8028ef:	d3 ee                	shr    %cl,%esi
  8028f1:	09 d0                	or     %edx,%eax
  8028f3:	89 f2                	mov    %esi,%edx
  8028f5:	83 c4 1c             	add    $0x1c,%esp
  8028f8:	5b                   	pop    %ebx
  8028f9:	5e                   	pop    %esi
  8028fa:	5f                   	pop    %edi
  8028fb:	5d                   	pop    %ebp
  8028fc:	c3                   	ret    
  8028fd:	8d 76 00             	lea    0x0(%esi),%esi
  802900:	29 f9                	sub    %edi,%ecx
  802902:	19 d6                	sbb    %edx,%esi
  802904:	89 74 24 04          	mov    %esi,0x4(%esp)
  802908:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80290c:	e9 18 ff ff ff       	jmp    802829 <__umoddi3+0x69>
