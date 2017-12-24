
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
  800044:	e8 35 08 00 00       	call   80087e <strcpy>
	exit();
  800049:	e8 b8 01 00 00       	call   800206 <exit>
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
  800074:	e8 08 0c 00 00       	call   800c81 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 cc 28 80 00       	push   $0x8028cc
  800086:	6a 13                	push   $0x13
  800088:	68 df 28 80 00       	push   $0x8028df
  80008d:	e8 8e 01 00 00       	call   800220 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 b1 0e 00 00       	call   800f48 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 f3 28 80 00       	push   $0x8028f3
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 df 28 80 00       	push   $0x8028df
  8000aa:	e8 71 01 00 00       	call   800220 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 b8 07 00 00       	call   80087e <strcpy>
		exit();
  8000c6:	e8 3b 01 00 00       	call   800206 <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 a1 21 00 00       	call   802278 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 3e 08 00 00       	call   800928 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  8000f4:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 fc 28 80 00       	push   $0x8028fc
  800102:	e8 f2 01 00 00       	call   8002f9 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 17 29 80 00       	push   $0x802917
  80010e:	68 1c 29 80 00       	push   $0x80291c
  800113:	68 1b 29 80 00       	push   $0x80291b
  800118:	e8 8c 1d 00 00       	call   801ea9 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 29 29 80 00       	push   $0x802929
  80012a:	6a 21                	push   $0x21
  80012c:	68 df 28 80 00       	push   $0x8028df
  800131:	e8 ea 00 00 00       	call   800220 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 39 21 00 00       	call   802278 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 d6 07 00 00       	call   800928 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  80015c:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 33 29 80 00       	push   $0x802933
  80016a:	e8 8a 01 00 00       	call   8002f9 <cprintf>
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
  80018b:	e8 b3 0a 00 00       	call   800c43 <sys_getenvid>
  800190:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800196:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80019b:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001a0:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8001a5:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8001a8:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8001ae:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8001b1:	39 c8                	cmp    %ecx,%eax
  8001b3:	0f 44 fb             	cmove  %ebx,%edi
  8001b6:	b9 01 00 00 00       	mov    $0x1,%ecx
  8001bb:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001be:	83 c2 01             	add    $0x1,%edx
  8001c1:	83 c3 7c             	add    $0x7c,%ebx
  8001c4:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8001ca:	75 d9                	jne    8001a5 <libmain+0x2d>
  8001cc:	89 f0                	mov    %esi,%eax
  8001ce:	84 c0                	test   %al,%al
  8001d0:	74 06                	je     8001d8 <libmain+0x60>
  8001d2:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8001dc:	7e 0a                	jle    8001e8 <libmain+0x70>
		binaryname = argv[0];
  8001de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e1:	8b 00                	mov    (%eax),%eax
  8001e3:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	e8 5d fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001f6:	e8 0b 00 00 00       	call   800206 <exit>
}
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80020c:	e8 e9 10 00 00       	call   8012fa <close_all>
	sys_env_destroy(0);
  800211:	83 ec 0c             	sub    $0xc,%esp
  800214:	6a 00                	push   $0x0
  800216:	e8 e7 09 00 00       	call   800c02 <sys_env_destroy>
}
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800225:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800228:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80022e:	e8 10 0a 00 00       	call   800c43 <sys_getenvid>
  800233:	83 ec 0c             	sub    $0xc,%esp
  800236:	ff 75 0c             	pushl  0xc(%ebp)
  800239:	ff 75 08             	pushl  0x8(%ebp)
  80023c:	56                   	push   %esi
  80023d:	50                   	push   %eax
  80023e:	68 78 29 80 00       	push   $0x802978
  800243:	e8 b1 00 00 00       	call   8002f9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800248:	83 c4 18             	add    $0x18,%esp
  80024b:	53                   	push   %ebx
  80024c:	ff 75 10             	pushl  0x10(%ebp)
  80024f:	e8 54 00 00 00       	call   8002a8 <vcprintf>
	cprintf("\n");
  800254:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  80025b:	e8 99 00 00 00       	call   8002f9 <cprintf>
  800260:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800263:	cc                   	int3   
  800264:	eb fd                	jmp    800263 <_panic+0x43>

00800266 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	53                   	push   %ebx
  80026a:	83 ec 04             	sub    $0x4,%esp
  80026d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800270:	8b 13                	mov    (%ebx),%edx
  800272:	8d 42 01             	lea    0x1(%edx),%eax
  800275:	89 03                	mov    %eax,(%ebx)
  800277:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80027e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800283:	75 1a                	jne    80029f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	68 ff 00 00 00       	push   $0xff
  80028d:	8d 43 08             	lea    0x8(%ebx),%eax
  800290:	50                   	push   %eax
  800291:	e8 2f 09 00 00       	call   800bc5 <sys_cputs>
		b->idx = 0;
  800296:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80029c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80029f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b8:	00 00 00 
	b.cnt = 0;
  8002bb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c5:	ff 75 0c             	pushl  0xc(%ebp)
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d1:	50                   	push   %eax
  8002d2:	68 66 02 80 00       	push   $0x800266
  8002d7:	e8 54 01 00 00       	call   800430 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002dc:	83 c4 08             	add    $0x8,%esp
  8002df:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002eb:	50                   	push   %eax
  8002ec:	e8 d4 08 00 00       	call   800bc5 <sys_cputs>

	return b.cnt;
}
  8002f1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f7:	c9                   	leave  
  8002f8:	c3                   	ret    

008002f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800302:	50                   	push   %eax
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	e8 9d ff ff ff       	call   8002a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 1c             	sub    $0x1c,%esp
  800316:	89 c7                	mov    %eax,%edi
  800318:	89 d6                	mov    %edx,%esi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800320:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800323:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800326:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800329:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800331:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800334:	39 d3                	cmp    %edx,%ebx
  800336:	72 05                	jb     80033d <printnum+0x30>
  800338:	39 45 10             	cmp    %eax,0x10(%ebp)
  80033b:	77 45                	ja     800382 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	ff 75 18             	pushl  0x18(%ebp)
  800343:	8b 45 14             	mov    0x14(%ebp),%eax
  800346:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800349:	53                   	push   %ebx
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	83 ec 08             	sub    $0x8,%esp
  800350:	ff 75 e4             	pushl  -0x1c(%ebp)
  800353:	ff 75 e0             	pushl  -0x20(%ebp)
  800356:	ff 75 dc             	pushl  -0x24(%ebp)
  800359:	ff 75 d8             	pushl  -0x28(%ebp)
  80035c:	e8 cf 22 00 00       	call   802630 <__udivdi3>
  800361:	83 c4 18             	add    $0x18,%esp
  800364:	52                   	push   %edx
  800365:	50                   	push   %eax
  800366:	89 f2                	mov    %esi,%edx
  800368:	89 f8                	mov    %edi,%eax
  80036a:	e8 9e ff ff ff       	call   80030d <printnum>
  80036f:	83 c4 20             	add    $0x20,%esp
  800372:	eb 18                	jmp    80038c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	56                   	push   %esi
  800378:	ff 75 18             	pushl  0x18(%ebp)
  80037b:	ff d7                	call   *%edi
  80037d:	83 c4 10             	add    $0x10,%esp
  800380:	eb 03                	jmp    800385 <printnum+0x78>
  800382:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800385:	83 eb 01             	sub    $0x1,%ebx
  800388:	85 db                	test   %ebx,%ebx
  80038a:	7f e8                	jg     800374 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	56                   	push   %esi
  800390:	83 ec 04             	sub    $0x4,%esp
  800393:	ff 75 e4             	pushl  -0x1c(%ebp)
  800396:	ff 75 e0             	pushl  -0x20(%ebp)
  800399:	ff 75 dc             	pushl  -0x24(%ebp)
  80039c:	ff 75 d8             	pushl  -0x28(%ebp)
  80039f:	e8 bc 23 00 00       	call   802760 <__umoddi3>
  8003a4:	83 c4 14             	add    $0x14,%esp
  8003a7:	0f be 80 9b 29 80 00 	movsbl 0x80299b(%eax),%eax
  8003ae:	50                   	push   %eax
  8003af:	ff d7                	call   *%edi
}
  8003b1:	83 c4 10             	add    $0x10,%esp
  8003b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b7:	5b                   	pop    %ebx
  8003b8:	5e                   	pop    %esi
  8003b9:	5f                   	pop    %edi
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003bf:	83 fa 01             	cmp    $0x1,%edx
  8003c2:	7e 0e                	jle    8003d2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c9:	89 08                	mov    %ecx,(%eax)
  8003cb:	8b 02                	mov    (%edx),%eax
  8003cd:	8b 52 04             	mov    0x4(%edx),%edx
  8003d0:	eb 22                	jmp    8003f4 <getuint+0x38>
	else if (lflag)
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	74 10                	je     8003e6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003db:	89 08                	mov    %ecx,(%eax)
  8003dd:	8b 02                	mov    (%edx),%eax
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e4:	eb 0e                	jmp    8003f4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e6:	8b 10                	mov    (%eax),%edx
  8003e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003eb:	89 08                	mov    %ecx,(%eax)
  8003ed:	8b 02                	mov    (%edx),%eax
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800400:	8b 10                	mov    (%eax),%edx
  800402:	3b 50 04             	cmp    0x4(%eax),%edx
  800405:	73 0a                	jae    800411 <sprintputch+0x1b>
		*b->buf++ = ch;
  800407:	8d 4a 01             	lea    0x1(%edx),%ecx
  80040a:	89 08                	mov    %ecx,(%eax)
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	88 02                	mov    %al,(%edx)
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800419:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041c:	50                   	push   %eax
  80041d:	ff 75 10             	pushl  0x10(%ebp)
  800420:	ff 75 0c             	pushl  0xc(%ebp)
  800423:	ff 75 08             	pushl  0x8(%ebp)
  800426:	e8 05 00 00 00       	call   800430 <vprintfmt>
	va_end(ap);
}
  80042b:	83 c4 10             	add    $0x10,%esp
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	83 ec 2c             	sub    $0x2c,%esp
  800439:	8b 75 08             	mov    0x8(%ebp),%esi
  80043c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800442:	eb 12                	jmp    800456 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800444:	85 c0                	test   %eax,%eax
  800446:	0f 84 89 03 00 00    	je     8007d5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	53                   	push   %ebx
  800450:	50                   	push   %eax
  800451:	ff d6                	call   *%esi
  800453:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800456:	83 c7 01             	add    $0x1,%edi
  800459:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80045d:	83 f8 25             	cmp    $0x25,%eax
  800460:	75 e2                	jne    800444 <vprintfmt+0x14>
  800462:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800466:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80046d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800474:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
  800480:	eb 07                	jmp    800489 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800485:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8d 47 01             	lea    0x1(%edi),%eax
  80048c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048f:	0f b6 07             	movzbl (%edi),%eax
  800492:	0f b6 c8             	movzbl %al,%ecx
  800495:	83 e8 23             	sub    $0x23,%eax
  800498:	3c 55                	cmp    $0x55,%al
  80049a:	0f 87 1a 03 00 00    	ja     8007ba <vprintfmt+0x38a>
  8004a0:	0f b6 c0             	movzbl %al,%eax
  8004a3:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
  8004aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ad:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004b1:	eb d6                	jmp    800489 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004be:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004c1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004c5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004cb:	83 fa 09             	cmp    $0x9,%edx
  8004ce:	77 39                	ja     800509 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d3:	eb e9                	jmp    8004be <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d8:	8d 48 04             	lea    0x4(%eax),%ecx
  8004db:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004de:	8b 00                	mov    (%eax),%eax
  8004e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e6:	eb 27                	jmp    80050f <vprintfmt+0xdf>
  8004e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f2:	0f 49 c8             	cmovns %eax,%ecx
  8004f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fb:	eb 8c                	jmp    800489 <vprintfmt+0x59>
  8004fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800500:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800507:	eb 80                	jmp    800489 <vprintfmt+0x59>
  800509:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80050f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800513:	0f 89 70 ff ff ff    	jns    800489 <vprintfmt+0x59>
				width = precision, precision = -1;
  800519:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80051c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800526:	e9 5e ff ff ff       	jmp    800489 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800531:	e9 53 ff ff ff       	jmp    800489 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 04             	lea    0x4(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	ff 30                	pushl  (%eax)
  800545:	ff d6                	call   *%esi
			break;
  800547:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80054d:	e9 04 ff ff ff       	jmp    800456 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	99                   	cltd   
  80055e:	31 d0                	xor    %edx,%eax
  800560:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800562:	83 f8 0f             	cmp    $0xf,%eax
  800565:	7f 0b                	jg     800572 <vprintfmt+0x142>
  800567:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	75 18                	jne    80058a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800572:	50                   	push   %eax
  800573:	68 b3 29 80 00       	push   $0x8029b3
  800578:	53                   	push   %ebx
  800579:	56                   	push   %esi
  80057a:	e8 94 fe ff ff       	call   800413 <printfmt>
  80057f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800585:	e9 cc fe ff ff       	jmp    800456 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80058a:	52                   	push   %edx
  80058b:	68 dd 2d 80 00       	push   $0x802ddd
  800590:	53                   	push   %ebx
  800591:	56                   	push   %esi
  800592:	e8 7c fe ff ff       	call   800413 <printfmt>
  800597:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059d:	e9 b4 fe ff ff       	jmp    800456 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ad:	85 ff                	test   %edi,%edi
  8005af:	b8 ac 29 80 00       	mov    $0x8029ac,%eax
  8005b4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bb:	0f 8e 94 00 00 00    	jle    800655 <vprintfmt+0x225>
  8005c1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005c5:	0f 84 98 00 00 00    	je     800663 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8005d1:	57                   	push   %edi
  8005d2:	e8 86 02 00 00       	call   80085d <strnlen>
  8005d7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005da:	29 c1                	sub    %eax,%ecx
  8005dc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005df:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005e2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ec:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ee:	eb 0f                	jmp    8005ff <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f9:	83 ef 01             	sub    $0x1,%edi
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	85 ff                	test   %edi,%edi
  800601:	7f ed                	jg     8005f0 <vprintfmt+0x1c0>
  800603:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800606:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800609:	85 c9                	test   %ecx,%ecx
  80060b:	b8 00 00 00 00       	mov    $0x0,%eax
  800610:	0f 49 c1             	cmovns %ecx,%eax
  800613:	29 c1                	sub    %eax,%ecx
  800615:	89 75 08             	mov    %esi,0x8(%ebp)
  800618:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80061e:	89 cb                	mov    %ecx,%ebx
  800620:	eb 4d                	jmp    80066f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800622:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800626:	74 1b                	je     800643 <vprintfmt+0x213>
  800628:	0f be c0             	movsbl %al,%eax
  80062b:	83 e8 20             	sub    $0x20,%eax
  80062e:	83 f8 5e             	cmp    $0x5e,%eax
  800631:	76 10                	jbe    800643 <vprintfmt+0x213>
					putch('?', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	ff 75 0c             	pushl  0xc(%ebp)
  800639:	6a 3f                	push   $0x3f
  80063b:	ff 55 08             	call   *0x8(%ebp)
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	eb 0d                	jmp    800650 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 0c             	pushl  0xc(%ebp)
  800649:	52                   	push   %edx
  80064a:	ff 55 08             	call   *0x8(%ebp)
  80064d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800650:	83 eb 01             	sub    $0x1,%ebx
  800653:	eb 1a                	jmp    80066f <vprintfmt+0x23f>
  800655:	89 75 08             	mov    %esi,0x8(%ebp)
  800658:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800661:	eb 0c                	jmp    80066f <vprintfmt+0x23f>
  800663:	89 75 08             	mov    %esi,0x8(%ebp)
  800666:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800669:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066f:	83 c7 01             	add    $0x1,%edi
  800672:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800676:	0f be d0             	movsbl %al,%edx
  800679:	85 d2                	test   %edx,%edx
  80067b:	74 23                	je     8006a0 <vprintfmt+0x270>
  80067d:	85 f6                	test   %esi,%esi
  80067f:	78 a1                	js     800622 <vprintfmt+0x1f2>
  800681:	83 ee 01             	sub    $0x1,%esi
  800684:	79 9c                	jns    800622 <vprintfmt+0x1f2>
  800686:	89 df                	mov    %ebx,%edi
  800688:	8b 75 08             	mov    0x8(%ebp),%esi
  80068b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80068e:	eb 18                	jmp    8006a8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 20                	push   $0x20
  800696:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800698:	83 ef 01             	sub    $0x1,%edi
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	eb 08                	jmp    8006a8 <vprintfmt+0x278>
  8006a0:	89 df                	mov    %ebx,%edi
  8006a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a8:	85 ff                	test   %edi,%edi
  8006aa:	7f e4                	jg     800690 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006af:	e9 a2 fd ff ff       	jmp    800456 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b4:	83 fa 01             	cmp    $0x1,%edx
  8006b7:	7e 16                	jle    8006cf <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8d 50 08             	lea    0x8(%eax),%edx
  8006bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c2:	8b 50 04             	mov    0x4(%eax),%edx
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006cd:	eb 32                	jmp    800701 <vprintfmt+0x2d1>
	else if (lflag)
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	74 18                	je     8006eb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e1:	89 c1                	mov    %eax,%ecx
  8006e3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e9:	eb 16                	jmp    800701 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 50 04             	lea    0x4(%eax),%edx
  8006f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f4:	8b 00                	mov    (%eax),%eax
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 c1                	mov    %eax,%ecx
  8006fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800701:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800704:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800707:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80070c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800710:	79 74                	jns    800786 <vprintfmt+0x356>
				putch('-', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 2d                	push   $0x2d
  800718:	ff d6                	call   *%esi
				num = -(long long) num;
  80071a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800720:	f7 d8                	neg    %eax
  800722:	83 d2 00             	adc    $0x0,%edx
  800725:	f7 da                	neg    %edx
  800727:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80072a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072f:	eb 55                	jmp    800786 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
  800734:	e8 83 fc ff ff       	call   8003bc <getuint>
			base = 10;
  800739:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80073e:	eb 46                	jmp    800786 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
  800743:	e8 74 fc ff ff       	call   8003bc <getuint>
			base = 8;
  800748:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80074d:	eb 37                	jmp    800786 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 30                	push   $0x30
  800755:	ff d6                	call   *%esi
			putch('x', putdat);
  800757:	83 c4 08             	add    $0x8,%esp
  80075a:	53                   	push   %ebx
  80075b:	6a 78                	push   $0x78
  80075d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80076f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800772:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800777:	eb 0d                	jmp    800786 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800779:	8d 45 14             	lea    0x14(%ebp),%eax
  80077c:	e8 3b fc ff ff       	call   8003bc <getuint>
			base = 16;
  800781:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800786:	83 ec 0c             	sub    $0xc,%esp
  800789:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80078d:	57                   	push   %edi
  80078e:	ff 75 e0             	pushl  -0x20(%ebp)
  800791:	51                   	push   %ecx
  800792:	52                   	push   %edx
  800793:	50                   	push   %eax
  800794:	89 da                	mov    %ebx,%edx
  800796:	89 f0                	mov    %esi,%eax
  800798:	e8 70 fb ff ff       	call   80030d <printnum>
			break;
  80079d:	83 c4 20             	add    $0x20,%esp
  8007a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a3:	e9 ae fc ff ff       	jmp    800456 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	53                   	push   %ebx
  8007ac:	51                   	push   %ecx
  8007ad:	ff d6                	call   *%esi
			break;
  8007af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b5:	e9 9c fc ff ff       	jmp    800456 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	53                   	push   %ebx
  8007be:	6a 25                	push   $0x25
  8007c0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	eb 03                	jmp    8007ca <vprintfmt+0x39a>
  8007c7:	83 ef 01             	sub    $0x1,%edi
  8007ca:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007ce:	75 f7                	jne    8007c7 <vprintfmt+0x397>
  8007d0:	e9 81 fc ff ff       	jmp    800456 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5f                   	pop    %edi
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 18             	sub    $0x18,%esp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	74 26                	je     800824 <vsnprintf+0x47>
  8007fe:	85 d2                	test   %edx,%edx
  800800:	7e 22                	jle    800824 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800802:	ff 75 14             	pushl  0x14(%ebp)
  800805:	ff 75 10             	pushl  0x10(%ebp)
  800808:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	68 f6 03 80 00       	push   $0x8003f6
  800811:	e8 1a fc ff ff       	call   800430 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800816:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800819:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	eb 05                	jmp    800829 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800824:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800834:	50                   	push   %eax
  800835:	ff 75 10             	pushl  0x10(%ebp)
  800838:	ff 75 0c             	pushl  0xc(%ebp)
  80083b:	ff 75 08             	pushl  0x8(%ebp)
  80083e:	e8 9a ff ff ff       	call   8007dd <vsnprintf>
	va_end(ap);

	return rc;
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	eb 03                	jmp    800855 <strlen+0x10>
		n++;
  800852:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800855:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800859:	75 f7                	jne    800852 <strlen+0xd>
		n++;
	return n;
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800863:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800866:	ba 00 00 00 00       	mov    $0x0,%edx
  80086b:	eb 03                	jmp    800870 <strnlen+0x13>
		n++;
  80086d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800870:	39 c2                	cmp    %eax,%edx
  800872:	74 08                	je     80087c <strnlen+0x1f>
  800874:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800878:	75 f3                	jne    80086d <strnlen+0x10>
  80087a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	53                   	push   %ebx
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800888:	89 c2                	mov    %eax,%edx
  80088a:	83 c2 01             	add    $0x1,%edx
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800894:	88 5a ff             	mov    %bl,-0x1(%edx)
  800897:	84 db                	test   %bl,%bl
  800899:	75 ef                	jne    80088a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80089b:	5b                   	pop    %ebx
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	53                   	push   %ebx
  8008a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a5:	53                   	push   %ebx
  8008a6:	e8 9a ff ff ff       	call   800845 <strlen>
  8008ab:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ae:	ff 75 0c             	pushl  0xc(%ebp)
  8008b1:	01 d8                	add    %ebx,%eax
  8008b3:	50                   	push   %eax
  8008b4:	e8 c5 ff ff ff       	call   80087e <strcpy>
	return dst;
}
  8008b9:	89 d8                	mov    %ebx,%eax
  8008bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cb:	89 f3                	mov    %esi,%ebx
  8008cd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d0:	89 f2                	mov    %esi,%edx
  8008d2:	eb 0f                	jmp    8008e3 <strncpy+0x23>
		*dst++ = *src;
  8008d4:	83 c2 01             	add    $0x1,%edx
  8008d7:	0f b6 01             	movzbl (%ecx),%eax
  8008da:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008dd:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e3:	39 da                	cmp    %ebx,%edx
  8008e5:	75 ed                	jne    8008d4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e7:	89 f0                	mov    %esi,%eax
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f8:	8b 55 10             	mov    0x10(%ebp),%edx
  8008fb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008fd:	85 d2                	test   %edx,%edx
  8008ff:	74 21                	je     800922 <strlcpy+0x35>
  800901:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800905:	89 f2                	mov    %esi,%edx
  800907:	eb 09                	jmp    800912 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800912:	39 c2                	cmp    %eax,%edx
  800914:	74 09                	je     80091f <strlcpy+0x32>
  800916:	0f b6 19             	movzbl (%ecx),%ebx
  800919:	84 db                	test   %bl,%bl
  80091b:	75 ec                	jne    800909 <strlcpy+0x1c>
  80091d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80091f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800922:	29 f0                	sub    %esi,%eax
}
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800931:	eb 06                	jmp    800939 <strcmp+0x11>
		p++, q++;
  800933:	83 c1 01             	add    $0x1,%ecx
  800936:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800939:	0f b6 01             	movzbl (%ecx),%eax
  80093c:	84 c0                	test   %al,%al
  80093e:	74 04                	je     800944 <strcmp+0x1c>
  800940:	3a 02                	cmp    (%edx),%al
  800942:	74 ef                	je     800933 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800944:	0f b6 c0             	movzbl %al,%eax
  800947:	0f b6 12             	movzbl (%edx),%edx
  80094a:	29 d0                	sub    %edx,%eax
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	53                   	push   %ebx
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 55 0c             	mov    0xc(%ebp),%edx
  800958:	89 c3                	mov    %eax,%ebx
  80095a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095d:	eb 06                	jmp    800965 <strncmp+0x17>
		n--, p++, q++;
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800965:	39 d8                	cmp    %ebx,%eax
  800967:	74 15                	je     80097e <strncmp+0x30>
  800969:	0f b6 08             	movzbl (%eax),%ecx
  80096c:	84 c9                	test   %cl,%cl
  80096e:	74 04                	je     800974 <strncmp+0x26>
  800970:	3a 0a                	cmp    (%edx),%cl
  800972:	74 eb                	je     80095f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800974:	0f b6 00             	movzbl (%eax),%eax
  800977:	0f b6 12             	movzbl (%edx),%edx
  80097a:	29 d0                	sub    %edx,%eax
  80097c:	eb 05                	jmp    800983 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80097e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800990:	eb 07                	jmp    800999 <strchr+0x13>
		if (*s == c)
  800992:	38 ca                	cmp    %cl,%dl
  800994:	74 0f                	je     8009a5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	0f b6 10             	movzbl (%eax),%edx
  80099c:	84 d2                	test   %dl,%dl
  80099e:	75 f2                	jne    800992 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b1:	eb 03                	jmp    8009b6 <strfind+0xf>
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b9:	38 ca                	cmp    %cl,%dl
  8009bb:	74 04                	je     8009c1 <strfind+0x1a>
  8009bd:	84 d2                	test   %dl,%dl
  8009bf:	75 f2                	jne    8009b3 <strfind+0xc>
			break;
	return (char *) s;
}
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cf:	85 c9                	test   %ecx,%ecx
  8009d1:	74 36                	je     800a09 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d9:	75 28                	jne    800a03 <memset+0x40>
  8009db:	f6 c1 03             	test   $0x3,%cl
  8009de:	75 23                	jne    800a03 <memset+0x40>
		c &= 0xFF;
  8009e0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e4:	89 d3                	mov    %edx,%ebx
  8009e6:	c1 e3 08             	shl    $0x8,%ebx
  8009e9:	89 d6                	mov    %edx,%esi
  8009eb:	c1 e6 18             	shl    $0x18,%esi
  8009ee:	89 d0                	mov    %edx,%eax
  8009f0:	c1 e0 10             	shl    $0x10,%eax
  8009f3:	09 f0                	or     %esi,%eax
  8009f5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009f7:	89 d8                	mov    %ebx,%eax
  8009f9:	09 d0                	or     %edx,%eax
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	fc                   	cld    
  8009ff:	f3 ab                	rep stos %eax,%es:(%edi)
  800a01:	eb 06                	jmp    800a09 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	fc                   	cld    
  800a07:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a09:	89 f8                	mov    %edi,%eax
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5f                   	pop    %edi
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1e:	39 c6                	cmp    %eax,%esi
  800a20:	73 35                	jae    800a57 <memmove+0x47>
  800a22:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a25:	39 d0                	cmp    %edx,%eax
  800a27:	73 2e                	jae    800a57 <memmove+0x47>
		s += n;
		d += n;
  800a29:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2c:	89 d6                	mov    %edx,%esi
  800a2e:	09 fe                	or     %edi,%esi
  800a30:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a36:	75 13                	jne    800a4b <memmove+0x3b>
  800a38:	f6 c1 03             	test   $0x3,%cl
  800a3b:	75 0e                	jne    800a4b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a3d:	83 ef 04             	sub    $0x4,%edi
  800a40:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a43:	c1 e9 02             	shr    $0x2,%ecx
  800a46:	fd                   	std    
  800a47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a49:	eb 09                	jmp    800a54 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4b:	83 ef 01             	sub    $0x1,%edi
  800a4e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a51:	fd                   	std    
  800a52:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a54:	fc                   	cld    
  800a55:	eb 1d                	jmp    800a74 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a57:	89 f2                	mov    %esi,%edx
  800a59:	09 c2                	or     %eax,%edx
  800a5b:	f6 c2 03             	test   $0x3,%dl
  800a5e:	75 0f                	jne    800a6f <memmove+0x5f>
  800a60:	f6 c1 03             	test   $0x3,%cl
  800a63:	75 0a                	jne    800a6f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a65:	c1 e9 02             	shr    $0x2,%ecx
  800a68:	89 c7                	mov    %eax,%edi
  800a6a:	fc                   	cld    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 05                	jmp    800a74 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6f:	89 c7                	mov    %eax,%edi
  800a71:	fc                   	cld    
  800a72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a74:	5e                   	pop    %esi
  800a75:	5f                   	pop    %edi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a7b:	ff 75 10             	pushl  0x10(%ebp)
  800a7e:	ff 75 0c             	pushl  0xc(%ebp)
  800a81:	ff 75 08             	pushl  0x8(%ebp)
  800a84:	e8 87 ff ff ff       	call   800a10 <memmove>
}
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a96:	89 c6                	mov    %eax,%esi
  800a98:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9b:	eb 1a                	jmp    800ab7 <memcmp+0x2c>
		if (*s1 != *s2)
  800a9d:	0f b6 08             	movzbl (%eax),%ecx
  800aa0:	0f b6 1a             	movzbl (%edx),%ebx
  800aa3:	38 d9                	cmp    %bl,%cl
  800aa5:	74 0a                	je     800ab1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa7:	0f b6 c1             	movzbl %cl,%eax
  800aaa:	0f b6 db             	movzbl %bl,%ebx
  800aad:	29 d8                	sub    %ebx,%eax
  800aaf:	eb 0f                	jmp    800ac0 <memcmp+0x35>
		s1++, s2++;
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab7:	39 f0                	cmp    %esi,%eax
  800ab9:	75 e2                	jne    800a9d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	53                   	push   %ebx
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800acb:	89 c1                	mov    %eax,%ecx
  800acd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad4:	eb 0a                	jmp    800ae0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	0f b6 10             	movzbl (%eax),%edx
  800ad9:	39 da                	cmp    %ebx,%edx
  800adb:	74 07                	je     800ae4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800add:	83 c0 01             	add    $0x1,%eax
  800ae0:	39 c8                	cmp    %ecx,%eax
  800ae2:	72 f2                	jb     800ad6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af3:	eb 03                	jmp    800af8 <strtol+0x11>
		s++;
  800af5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	0f b6 01             	movzbl (%ecx),%eax
  800afb:	3c 20                	cmp    $0x20,%al
  800afd:	74 f6                	je     800af5 <strtol+0xe>
  800aff:	3c 09                	cmp    $0x9,%al
  800b01:	74 f2                	je     800af5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b03:	3c 2b                	cmp    $0x2b,%al
  800b05:	75 0a                	jne    800b11 <strtol+0x2a>
		s++;
  800b07:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0f:	eb 11                	jmp    800b22 <strtol+0x3b>
  800b11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b16:	3c 2d                	cmp    $0x2d,%al
  800b18:	75 08                	jne    800b22 <strtol+0x3b>
		s++, neg = 1;
  800b1a:	83 c1 01             	add    $0x1,%ecx
  800b1d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b28:	75 15                	jne    800b3f <strtol+0x58>
  800b2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2d:	75 10                	jne    800b3f <strtol+0x58>
  800b2f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b33:	75 7c                	jne    800bb1 <strtol+0xca>
		s += 2, base = 16;
  800b35:	83 c1 02             	add    $0x2,%ecx
  800b38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3d:	eb 16                	jmp    800b55 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b3f:	85 db                	test   %ebx,%ebx
  800b41:	75 12                	jne    800b55 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b43:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b48:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4b:	75 08                	jne    800b55 <strtol+0x6e>
		s++, base = 8;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5d:	0f b6 11             	movzbl (%ecx),%edx
  800b60:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b63:	89 f3                	mov    %esi,%ebx
  800b65:	80 fb 09             	cmp    $0x9,%bl
  800b68:	77 08                	ja     800b72 <strtol+0x8b>
			dig = *s - '0';
  800b6a:	0f be d2             	movsbl %dl,%edx
  800b6d:	83 ea 30             	sub    $0x30,%edx
  800b70:	eb 22                	jmp    800b94 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b72:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b75:	89 f3                	mov    %esi,%ebx
  800b77:	80 fb 19             	cmp    $0x19,%bl
  800b7a:	77 08                	ja     800b84 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b7c:	0f be d2             	movsbl %dl,%edx
  800b7f:	83 ea 57             	sub    $0x57,%edx
  800b82:	eb 10                	jmp    800b94 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b84:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 19             	cmp    $0x19,%bl
  800b8c:	77 16                	ja     800ba4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b94:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b97:	7d 0b                	jge    800ba4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b99:	83 c1 01             	add    $0x1,%ecx
  800b9c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ba2:	eb b9                	jmp    800b5d <strtol+0x76>

	if (endptr)
  800ba4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba8:	74 0d                	je     800bb7 <strtol+0xd0>
		*endptr = (char *) s;
  800baa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bad:	89 0e                	mov    %ecx,(%esi)
  800baf:	eb 06                	jmp    800bb7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb1:	85 db                	test   %ebx,%ebx
  800bb3:	74 98                	je     800b4d <strtol+0x66>
  800bb5:	eb 9e                	jmp    800b55 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bb7:	89 c2                	mov    %eax,%edx
  800bb9:	f7 da                	neg    %edx
  800bbb:	85 ff                	test   %edi,%edi
  800bbd:	0f 45 c2             	cmovne %edx,%eax
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	89 c3                	mov    %eax,%ebx
  800bd8:	89 c7                	mov    %eax,%edi
  800bda:	89 c6                	mov    %eax,%esi
  800bdc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bee:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf3:	89 d1                	mov    %edx,%ecx
  800bf5:	89 d3                	mov    %edx,%ebx
  800bf7:	89 d7                	mov    %edx,%edi
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c10:	b8 03 00 00 00       	mov    $0x3,%eax
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 cb                	mov    %ecx,%ebx
  800c1a:	89 cf                	mov    %ecx,%edi
  800c1c:	89 ce                	mov    %ecx,%esi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 03                	push   $0x3
  800c2a:	68 9f 2c 80 00       	push   $0x802c9f
  800c2f:	6a 23                	push   $0x23
  800c31:	68 bc 2c 80 00       	push   $0x802cbc
  800c36:	e8 e5 f5 ff ff       	call   800220 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_yield>:

void
sys_yield(void)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c72:	89 d1                	mov    %edx,%ecx
  800c74:	89 d3                	mov    %edx,%ebx
  800c76:	89 d7                	mov    %edx,%edi
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	be 00 00 00 00       	mov    $0x0,%esi
  800c8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9d:	89 f7                	mov    %esi,%edi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 04                	push   $0x4
  800cab:	68 9f 2c 80 00       	push   $0x802c9f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 bc 2c 80 00       	push   $0x802cbc
  800cb7:	e8 64 f5 ff ff       	call   800220 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cde:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 05                	push   $0x5
  800ced:	68 9f 2c 80 00       	push   $0x802c9f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 bc 2c 80 00       	push   $0x802cbc
  800cf9:	e8 22 f5 ff ff       	call   800220 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 06 00 00 00       	mov    $0x6,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 06                	push   $0x6
  800d2f:	68 9f 2c 80 00       	push   $0x802c9f
  800d34:	6a 23                	push   $0x23
  800d36:	68 bc 2c 80 00       	push   $0x802cbc
  800d3b:	e8 e0 f4 ff ff       	call   800220 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 08                	push   $0x8
  800d71:	68 9f 2c 80 00       	push   $0x802c9f
  800d76:	6a 23                	push   $0x23
  800d78:	68 bc 2c 80 00       	push   $0x802cbc
  800d7d:	e8 9e f4 ff ff       	call   800220 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 09 00 00 00       	mov    $0x9,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 09                	push   $0x9
  800db3:	68 9f 2c 80 00       	push   $0x802c9f
  800db8:	6a 23                	push   $0x23
  800dba:	68 bc 2c 80 00       	push   $0x802cbc
  800dbf:	e8 5c f4 ff ff       	call   800220 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 0a                	push   $0xa
  800df5:	68 9f 2c 80 00       	push   $0x802c9f
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 bc 2c 80 00       	push   $0x802cbc
  800e01:	e8 1a f4 ff ff       	call   800220 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	be 00 00 00 00       	mov    $0x0,%esi
  800e19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 cb                	mov    %ecx,%ebx
  800e49:	89 cf                	mov    %ecx,%edi
  800e4b:	89 ce                	mov    %ecx,%esi
  800e4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 17                	jle    800e6a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 0d                	push   $0xd
  800e59:	68 9f 2c 80 00       	push   $0x802c9f
  800e5e:	6a 23                	push   $0x23
  800e60:	68 bc 2c 80 00       	push   $0x802cbc
  800e65:	e8 b6 f3 ff ff       	call   800220 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	53                   	push   %ebx
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e7c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e7e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e82:	74 11                	je     800e95 <pgfault+0x23>
  800e84:	89 d8                	mov    %ebx,%eax
  800e86:	c1 e8 0c             	shr    $0xc,%eax
  800e89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e90:	f6 c4 08             	test   $0x8,%ah
  800e93:	75 14                	jne    800ea9 <pgfault+0x37>
		panic("faulting access");
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	68 ca 2c 80 00       	push   $0x802cca
  800e9d:	6a 1d                	push   $0x1d
  800e9f:	68 da 2c 80 00       	push   $0x802cda
  800ea4:	e8 77 f3 ff ff       	call   800220 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	6a 07                	push   $0x7
  800eae:	68 00 f0 7f 00       	push   $0x7ff000
  800eb3:	6a 00                	push   $0x0
  800eb5:	e8 c7 fd ff ff       	call   800c81 <sys_page_alloc>
	if (r < 0) {
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	79 12                	jns    800ed3 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ec1:	50                   	push   %eax
  800ec2:	68 e5 2c 80 00       	push   $0x802ce5
  800ec7:	6a 2b                	push   $0x2b
  800ec9:	68 da 2c 80 00       	push   $0x802cda
  800ece:	e8 4d f3 ff ff       	call   800220 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ed3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	68 00 10 00 00       	push   $0x1000
  800ee1:	53                   	push   %ebx
  800ee2:	68 00 f0 7f 00       	push   $0x7ff000
  800ee7:	e8 8c fb ff ff       	call   800a78 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800eec:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef3:	53                   	push   %ebx
  800ef4:	6a 00                	push   $0x0
  800ef6:	68 00 f0 7f 00       	push   $0x7ff000
  800efb:	6a 00                	push   $0x0
  800efd:	e8 c2 fd ff ff       	call   800cc4 <sys_page_map>
	if (r < 0) {
  800f02:	83 c4 20             	add    $0x20,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	79 12                	jns    800f1b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f09:	50                   	push   %eax
  800f0a:	68 e5 2c 80 00       	push   $0x802ce5
  800f0f:	6a 32                	push   $0x32
  800f11:	68 da 2c 80 00       	push   $0x802cda
  800f16:	e8 05 f3 ff ff       	call   800220 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f1b:	83 ec 08             	sub    $0x8,%esp
  800f1e:	68 00 f0 7f 00       	push   $0x7ff000
  800f23:	6a 00                	push   $0x0
  800f25:	e8 dc fd ff ff       	call   800d06 <sys_page_unmap>
	if (r < 0) {
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	79 12                	jns    800f43 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f31:	50                   	push   %eax
  800f32:	68 e5 2c 80 00       	push   $0x802ce5
  800f37:	6a 36                	push   $0x36
  800f39:	68 da 2c 80 00       	push   $0x802cda
  800f3e:	e8 dd f2 ff ff       	call   800220 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f46:	c9                   	leave  
  800f47:	c3                   	ret    

00800f48 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
  800f4e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f51:	68 72 0e 80 00       	push   $0x800e72
  800f56:	e8 ef 14 00 00       	call   80244a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f5b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f60:	cd 30                	int    $0x30
  800f62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	79 17                	jns    800f83 <fork+0x3b>
		panic("fork fault %e");
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 fe 2c 80 00       	push   $0x802cfe
  800f74:	68 83 00 00 00       	push   $0x83
  800f79:	68 da 2c 80 00       	push   $0x802cda
  800f7e:	e8 9d f2 ff ff       	call   800220 <_panic>
  800f83:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f85:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f89:	75 21                	jne    800fac <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f8b:	e8 b3 fc ff ff       	call   800c43 <sys_getenvid>
  800f90:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f95:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f98:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	e9 61 01 00 00       	jmp    80110d <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	6a 07                	push   $0x7
  800fb1:	68 00 f0 bf ee       	push   $0xeebff000
  800fb6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb9:	e8 c3 fc ff ff       	call   800c81 <sys_page_alloc>
  800fbe:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	c1 e8 16             	shr    $0x16,%eax
  800fcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	0f 84 fc 00 00 00    	je     8010d6 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	0f 84 e7 00 00 00    	je     8010d6 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fef:	89 c6                	mov    %eax,%esi
  800ff1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ff4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffb:	f6 c6 04             	test   $0x4,%dh
  800ffe:	74 39                	je     801039 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801000:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	25 07 0e 00 00       	and    $0xe07,%eax
  80100f:	50                   	push   %eax
  801010:	56                   	push   %esi
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	6a 00                	push   $0x0
  801015:	e8 aa fc ff ff       	call   800cc4 <sys_page_map>
		if (r < 0) {
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	0f 89 b1 00 00 00    	jns    8010d6 <fork+0x18e>
		    	panic("sys page map fault %e");
  801025:	83 ec 04             	sub    $0x4,%esp
  801028:	68 0c 2d 80 00       	push   $0x802d0c
  80102d:	6a 53                	push   $0x53
  80102f:	68 da 2c 80 00       	push   $0x802cda
  801034:	e8 e7 f1 ff ff       	call   800220 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801039:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801040:	f6 c2 02             	test   $0x2,%dl
  801043:	75 0c                	jne    801051 <fork+0x109>
  801045:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104c:	f6 c4 08             	test   $0x8,%ah
  80104f:	74 5b                	je     8010ac <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	68 05 08 00 00       	push   $0x805
  801059:	56                   	push   %esi
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	6a 00                	push   $0x0
  80105e:	e8 61 fc ff ff       	call   800cc4 <sys_page_map>
		if (r < 0) {
  801063:	83 c4 20             	add    $0x20,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	79 14                	jns    80107e <fork+0x136>
		    	panic("sys page map fault %e");
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	68 0c 2d 80 00       	push   $0x802d0c
  801072:	6a 5a                	push   $0x5a
  801074:	68 da 2c 80 00       	push   $0x802cda
  801079:	e8 a2 f1 ff ff       	call   800220 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	68 05 08 00 00       	push   $0x805
  801086:	56                   	push   %esi
  801087:	6a 00                	push   $0x0
  801089:	56                   	push   %esi
  80108a:	6a 00                	push   $0x0
  80108c:	e8 33 fc ff ff       	call   800cc4 <sys_page_map>
		if (r < 0) {
  801091:	83 c4 20             	add    $0x20,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	79 3e                	jns    8010d6 <fork+0x18e>
		    	panic("sys page map fault %e");
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	68 0c 2d 80 00       	push   $0x802d0c
  8010a0:	6a 5e                	push   $0x5e
  8010a2:	68 da 2c 80 00       	push   $0x802cda
  8010a7:	e8 74 f1 ff ff       	call   800220 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	6a 05                	push   $0x5
  8010b1:	56                   	push   %esi
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	6a 00                	push   $0x0
  8010b6:	e8 09 fc ff ff       	call   800cc4 <sys_page_map>
		if (r < 0) {
  8010bb:	83 c4 20             	add    $0x20,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	79 14                	jns    8010d6 <fork+0x18e>
		    	panic("sys page map fault %e");
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	68 0c 2d 80 00       	push   $0x802d0c
  8010ca:	6a 63                	push   $0x63
  8010cc:	68 da 2c 80 00       	push   $0x802cda
  8010d1:	e8 4a f1 ff ff       	call   800220 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010d6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010dc:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010e2:	0f 85 de fe ff ff    	jne    800fc6 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ed:	8b 40 64             	mov    0x64(%eax),%eax
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	50                   	push   %eax
  8010f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f7:	57                   	push   %edi
  8010f8:	e8 cf fc ff ff       	call   800dcc <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	6a 02                	push   $0x2
  801102:	57                   	push   %edi
  801103:	e8 40 fc ff ff       	call   800d48 <sys_env_set_status>
	
	return envid;
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80110d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sfork>:

// Challenge!
int
sfork(void)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80111b:	68 22 2d 80 00       	push   $0x802d22
  801120:	68 a1 00 00 00       	push   $0xa1
  801125:	68 da 2c 80 00       	push   $0x802cda
  80112a:	e8 f1 f0 ff ff       	call   800220 <_panic>

0080112f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
  801135:	05 00 00 00 30       	add    $0x30000000,%eax
  80113a:	c1 e8 0c             	shr    $0xc,%eax
}
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	05 00 00 00 30       	add    $0x30000000,%eax
  80114a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801161:	89 c2                	mov    %eax,%edx
  801163:	c1 ea 16             	shr    $0x16,%edx
  801166:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116d:	f6 c2 01             	test   $0x1,%dl
  801170:	74 11                	je     801183 <fd_alloc+0x2d>
  801172:	89 c2                	mov    %eax,%edx
  801174:	c1 ea 0c             	shr    $0xc,%edx
  801177:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117e:	f6 c2 01             	test   $0x1,%dl
  801181:	75 09                	jne    80118c <fd_alloc+0x36>
			*fd_store = fd;
  801183:	89 01                	mov    %eax,(%ecx)
			return 0;
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
  80118a:	eb 17                	jmp    8011a3 <fd_alloc+0x4d>
  80118c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801191:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801196:	75 c9                	jne    801161 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801198:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80119e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ab:	83 f8 1f             	cmp    $0x1f,%eax
  8011ae:	77 36                	ja     8011e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b0:	c1 e0 0c             	shl    $0xc,%eax
  8011b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	c1 ea 16             	shr    $0x16,%edx
  8011bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c4:	f6 c2 01             	test   $0x1,%dl
  8011c7:	74 24                	je     8011ed <fd_lookup+0x48>
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	c1 ea 0c             	shr    $0xc,%edx
  8011ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d5:	f6 c2 01             	test   $0x1,%dl
  8011d8:	74 1a                	je     8011f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8011df:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e4:	eb 13                	jmp    8011f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011eb:	eb 0c                	jmp    8011f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f2:	eb 05                	jmp    8011f9 <fd_lookup+0x54>
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801204:	ba b4 2d 80 00       	mov    $0x802db4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801209:	eb 13                	jmp    80121e <dev_lookup+0x23>
  80120b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80120e:	39 08                	cmp    %ecx,(%eax)
  801210:	75 0c                	jne    80121e <dev_lookup+0x23>
			*dev = devtab[i];
  801212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801215:	89 01                	mov    %eax,(%ecx)
			return 0;
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
  80121c:	eb 2e                	jmp    80124c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80121e:	8b 02                	mov    (%edx),%eax
  801220:	85 c0                	test   %eax,%eax
  801222:	75 e7                	jne    80120b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801224:	a1 04 40 80 00       	mov    0x804004,%eax
  801229:	8b 40 48             	mov    0x48(%eax),%eax
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	51                   	push   %ecx
  801230:	50                   	push   %eax
  801231:	68 38 2d 80 00       	push   $0x802d38
  801236:	e8 be f0 ff ff       	call   8002f9 <cprintf>
	*dev = 0;
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
  801253:	83 ec 10             	sub    $0x10,%esp
  801256:	8b 75 08             	mov    0x8(%ebp),%esi
  801259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801266:	c1 e8 0c             	shr    $0xc,%eax
  801269:	50                   	push   %eax
  80126a:	e8 36 ff ff ff       	call   8011a5 <fd_lookup>
  80126f:	83 c4 08             	add    $0x8,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 05                	js     80127b <fd_close+0x2d>
	    || fd != fd2)
  801276:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801279:	74 0c                	je     801287 <fd_close+0x39>
		return (must_exist ? r : 0);
  80127b:	84 db                	test   %bl,%bl
  80127d:	ba 00 00 00 00       	mov    $0x0,%edx
  801282:	0f 44 c2             	cmove  %edx,%eax
  801285:	eb 41                	jmp    8012c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	ff 36                	pushl  (%esi)
  801290:	e8 66 ff ff ff       	call   8011fb <dev_lookup>
  801295:	89 c3                	mov    %eax,%ebx
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 1a                	js     8012b8 <fd_close+0x6a>
		if (dev->dev_close)
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	74 0b                	je     8012b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	56                   	push   %esi
  8012b1:	ff d0                	call   *%eax
  8012b3:	89 c3                	mov    %eax,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	56                   	push   %esi
  8012bc:	6a 00                	push   $0x0
  8012be:	e8 43 fa ff ff       	call   800d06 <sys_page_unmap>
	return r;
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	89 d8                	mov    %ebx,%eax
}
  8012c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5e                   	pop    %esi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 c4 fe ff ff       	call   8011a5 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 10                	js     8012f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	6a 01                	push   $0x1
  8012ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f0:	e8 59 ff ff ff       	call   80124e <fd_close>
  8012f5:	83 c4 10             	add    $0x10,%esp
}
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <close_all>:

void
close_all(void)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801301:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801306:	83 ec 0c             	sub    $0xc,%esp
  801309:	53                   	push   %ebx
  80130a:	e8 c0 ff ff ff       	call   8012cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80130f:	83 c3 01             	add    $0x1,%ebx
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	83 fb 20             	cmp    $0x20,%ebx
  801318:	75 ec                	jne    801306 <close_all+0xc>
		close(i);
}
  80131a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	57                   	push   %edi
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	83 ec 2c             	sub    $0x2c,%esp
  801328:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80132b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 08             	pushl  0x8(%ebp)
  801332:	e8 6e fe ff ff       	call   8011a5 <fd_lookup>
  801337:	83 c4 08             	add    $0x8,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	0f 88 c1 00 00 00    	js     801403 <dup+0xe4>
		return r;
	close(newfdnum);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	56                   	push   %esi
  801346:	e8 84 ff ff ff       	call   8012cf <close>

	newfd = INDEX2FD(newfdnum);
  80134b:	89 f3                	mov    %esi,%ebx
  80134d:	c1 e3 0c             	shl    $0xc,%ebx
  801350:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801356:	83 c4 04             	add    $0x4,%esp
  801359:	ff 75 e4             	pushl  -0x1c(%ebp)
  80135c:	e8 de fd ff ff       	call   80113f <fd2data>
  801361:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801363:	89 1c 24             	mov    %ebx,(%esp)
  801366:	e8 d4 fd ff ff       	call   80113f <fd2data>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801371:	89 f8                	mov    %edi,%eax
  801373:	c1 e8 16             	shr    $0x16,%eax
  801376:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137d:	a8 01                	test   $0x1,%al
  80137f:	74 37                	je     8013b8 <dup+0x99>
  801381:	89 f8                	mov    %edi,%eax
  801383:	c1 e8 0c             	shr    $0xc,%eax
  801386:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138d:	f6 c2 01             	test   $0x1,%dl
  801390:	74 26                	je     8013b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801392:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a1:	50                   	push   %eax
  8013a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a5:	6a 00                	push   $0x0
  8013a7:	57                   	push   %edi
  8013a8:	6a 00                	push   $0x0
  8013aa:	e8 15 f9 ff ff       	call   800cc4 <sys_page_map>
  8013af:	89 c7                	mov    %eax,%edi
  8013b1:	83 c4 20             	add    $0x20,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 2e                	js     8013e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	c1 e8 0c             	shr    $0xc,%eax
  8013c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8013cf:	50                   	push   %eax
  8013d0:	53                   	push   %ebx
  8013d1:	6a 00                	push   $0x0
  8013d3:	52                   	push   %edx
  8013d4:	6a 00                	push   $0x0
  8013d6:	e8 e9 f8 ff ff       	call   800cc4 <sys_page_map>
  8013db:	89 c7                	mov    %eax,%edi
  8013dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e2:	85 ff                	test   %edi,%edi
  8013e4:	79 1d                	jns    801403 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 15 f9 ff ff       	call   800d06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f1:	83 c4 08             	add    $0x8,%esp
  8013f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 08 f9 ff ff       	call   800d06 <sys_page_unmap>
	return r;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	89 f8                	mov    %edi,%eax
}
  801403:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 14             	sub    $0x14,%esp
  801412:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	53                   	push   %ebx
  80141a:	e8 86 fd ff ff       	call   8011a5 <fd_lookup>
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	89 c2                	mov    %eax,%edx
  801424:	85 c0                	test   %eax,%eax
  801426:	78 6d                	js     801495 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801432:	ff 30                	pushl  (%eax)
  801434:	e8 c2 fd ff ff       	call   8011fb <dev_lookup>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 4c                	js     80148c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801440:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801443:	8b 42 08             	mov    0x8(%edx),%eax
  801446:	83 e0 03             	and    $0x3,%eax
  801449:	83 f8 01             	cmp    $0x1,%eax
  80144c:	75 21                	jne    80146f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80144e:	a1 04 40 80 00       	mov    0x804004,%eax
  801453:	8b 40 48             	mov    0x48(%eax),%eax
  801456:	83 ec 04             	sub    $0x4,%esp
  801459:	53                   	push   %ebx
  80145a:	50                   	push   %eax
  80145b:	68 79 2d 80 00       	push   $0x802d79
  801460:	e8 94 ee ff ff       	call   8002f9 <cprintf>
		return -E_INVAL;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146d:	eb 26                	jmp    801495 <read+0x8a>
	}
	if (!dev->dev_read)
  80146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801472:	8b 40 08             	mov    0x8(%eax),%eax
  801475:	85 c0                	test   %eax,%eax
  801477:	74 17                	je     801490 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	ff 75 10             	pushl  0x10(%ebp)
  80147f:	ff 75 0c             	pushl  0xc(%ebp)
  801482:	52                   	push   %edx
  801483:	ff d0                	call   *%eax
  801485:	89 c2                	mov    %eax,%edx
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	eb 09                	jmp    801495 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	eb 05                	jmp    801495 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801490:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801495:	89 d0                	mov    %edx,%eax
  801497:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	57                   	push   %edi
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b0:	eb 21                	jmp    8014d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b2:	83 ec 04             	sub    $0x4,%esp
  8014b5:	89 f0                	mov    %esi,%eax
  8014b7:	29 d8                	sub    %ebx,%eax
  8014b9:	50                   	push   %eax
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	03 45 0c             	add    0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	57                   	push   %edi
  8014c1:	e8 45 ff ff ff       	call   80140b <read>
		if (m < 0)
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 10                	js     8014dd <readn+0x41>
			return m;
		if (m == 0)
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	74 0a                	je     8014db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d1:	01 c3                	add    %eax,%ebx
  8014d3:	39 f3                	cmp    %esi,%ebx
  8014d5:	72 db                	jb     8014b2 <readn+0x16>
  8014d7:	89 d8                	mov    %ebx,%eax
  8014d9:	eb 02                	jmp    8014dd <readn+0x41>
  8014db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5e                   	pop    %esi
  8014e2:	5f                   	pop    %edi
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 14             	sub    $0x14,%esp
  8014ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	53                   	push   %ebx
  8014f4:	e8 ac fc ff ff       	call   8011a5 <fd_lookup>
  8014f9:	83 c4 08             	add    $0x8,%esp
  8014fc:	89 c2                	mov    %eax,%edx
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 68                	js     80156a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150c:	ff 30                	pushl  (%eax)
  80150e:	e8 e8 fc ff ff       	call   8011fb <dev_lookup>
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 47                	js     801561 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801521:	75 21                	jne    801544 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801523:	a1 04 40 80 00       	mov    0x804004,%eax
  801528:	8b 40 48             	mov    0x48(%eax),%eax
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	53                   	push   %ebx
  80152f:	50                   	push   %eax
  801530:	68 95 2d 80 00       	push   $0x802d95
  801535:	e8 bf ed ff ff       	call   8002f9 <cprintf>
		return -E_INVAL;
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801542:	eb 26                	jmp    80156a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801544:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801547:	8b 52 0c             	mov    0xc(%edx),%edx
  80154a:	85 d2                	test   %edx,%edx
  80154c:	74 17                	je     801565 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	ff 75 10             	pushl  0x10(%ebp)
  801554:	ff 75 0c             	pushl  0xc(%ebp)
  801557:	50                   	push   %eax
  801558:	ff d2                	call   *%edx
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	eb 09                	jmp    80156a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801561:	89 c2                	mov    %eax,%edx
  801563:	eb 05                	jmp    80156a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801565:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80156a:	89 d0                	mov    %edx,%eax
  80156c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <seek>:

int
seek(int fdnum, off_t offset)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801577:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	ff 75 08             	pushl  0x8(%ebp)
  80157e:	e8 22 fc ff ff       	call   8011a5 <fd_lookup>
  801583:	83 c4 08             	add    $0x8,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 0e                	js     801598 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80158a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80158d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801590:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801593:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 14             	sub    $0x14,%esp
  8015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	53                   	push   %ebx
  8015a9:	e8 f7 fb ff ff       	call   8011a5 <fd_lookup>
  8015ae:	83 c4 08             	add    $0x8,%esp
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 65                	js     80161c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	ff 30                	pushl  (%eax)
  8015c3:	e8 33 fc ff ff       	call   8011fb <dev_lookup>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 44                	js     801613 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d6:	75 21                	jne    8015f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015d8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015dd:	8b 40 48             	mov    0x48(%eax),%eax
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	50                   	push   %eax
  8015e5:	68 58 2d 80 00       	push   $0x802d58
  8015ea:	e8 0a ed ff ff       	call   8002f9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f7:	eb 23                	jmp    80161c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fc:	8b 52 18             	mov    0x18(%edx),%edx
  8015ff:	85 d2                	test   %edx,%edx
  801601:	74 14                	je     801617 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	50                   	push   %eax
  80160a:	ff d2                	call   *%edx
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	eb 09                	jmp    80161c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	89 c2                	mov    %eax,%edx
  801615:	eb 05                	jmp    80161c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801617:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	83 ec 14             	sub    $0x14,%esp
  80162a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	ff 75 08             	pushl  0x8(%ebp)
  801634:	e8 6c fb ff ff       	call   8011a5 <fd_lookup>
  801639:	83 c4 08             	add    $0x8,%esp
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 58                	js     80169a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164c:	ff 30                	pushl  (%eax)
  80164e:	e8 a8 fb ff ff       	call   8011fb <dev_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 37                	js     801691 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801661:	74 32                	je     801695 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801663:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801666:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80166d:	00 00 00 
	stat->st_isdir = 0;
  801670:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801677:	00 00 00 
	stat->st_dev = dev;
  80167a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	53                   	push   %ebx
  801684:	ff 75 f0             	pushl  -0x10(%ebp)
  801687:	ff 50 14             	call   *0x14(%eax)
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	eb 09                	jmp    80169a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801691:	89 c2                	mov    %eax,%edx
  801693:	eb 05                	jmp    80169a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801695:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80169a:	89 d0                	mov    %edx,%eax
  80169c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	6a 00                	push   $0x0
  8016ab:	ff 75 08             	pushl  0x8(%ebp)
  8016ae:	e8 e3 01 00 00       	call   801896 <open>
  8016b3:	89 c3                	mov    %eax,%ebx
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 1b                	js     8016d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	ff 75 0c             	pushl  0xc(%ebp)
  8016c2:	50                   	push   %eax
  8016c3:	e8 5b ff ff ff       	call   801623 <fstat>
  8016c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ca:	89 1c 24             	mov    %ebx,(%esp)
  8016cd:	e8 fd fb ff ff       	call   8012cf <close>
	return r;
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	89 f0                	mov    %esi,%eax
}
  8016d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016da:	5b                   	pop    %ebx
  8016db:	5e                   	pop    %esi
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	89 c6                	mov    %eax,%esi
  8016e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ee:	75 12                	jne    801702 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	6a 01                	push   $0x1
  8016f5:	e8 b3 0e 00 00       	call   8025ad <ipc_find_env>
  8016fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801702:	6a 07                	push   $0x7
  801704:	68 00 50 80 00       	push   $0x805000
  801709:	56                   	push   %esi
  80170a:	ff 35 00 40 80 00    	pushl  0x804000
  801710:	e8 36 0e 00 00       	call   80254b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801715:	83 c4 0c             	add    $0xc,%esp
  801718:	6a 00                	push   $0x0
  80171a:	53                   	push   %ebx
  80171b:	6a 00                	push   $0x0
  80171d:	e8 b7 0d 00 00       	call   8024d9 <ipc_recv>
}
  801722:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	8b 40 0c             	mov    0xc(%eax),%eax
  801735:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80173a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801742:	ba 00 00 00 00       	mov    $0x0,%edx
  801747:	b8 02 00 00 00       	mov    $0x2,%eax
  80174c:	e8 8d ff ff ff       	call   8016de <fsipc>
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
  80175c:	8b 40 0c             	mov    0xc(%eax),%eax
  80175f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801764:	ba 00 00 00 00       	mov    $0x0,%edx
  801769:	b8 06 00 00 00       	mov    $0x6,%eax
  80176e:	e8 6b ff ff ff       	call   8016de <fsipc>
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	53                   	push   %ebx
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	8b 40 0c             	mov    0xc(%eax),%eax
  801785:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 05 00 00 00       	mov    $0x5,%eax
  801794:	e8 45 ff ff ff       	call   8016de <fsipc>
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 2c                	js     8017c9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	68 00 50 80 00       	push   $0x805000
  8017a5:	53                   	push   %ebx
  8017a6:	e8 d3 f0 ff ff       	call   80087e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8017bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017da:	8b 52 0c             	mov    0xc(%edx),%edx
  8017dd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017e3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017e8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017ed:	0f 47 c2             	cmova  %edx,%eax
  8017f0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8017f5:	50                   	push   %eax
  8017f6:	ff 75 0c             	pushl  0xc(%ebp)
  8017f9:	68 08 50 80 00       	push   $0x805008
  8017fe:	e8 0d f2 ff ff       	call   800a10 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	b8 04 00 00 00       	mov    $0x4,%eax
  80180d:	e8 cc fe ff ff       	call   8016de <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80181c:	8b 45 08             	mov    0x8(%ebp),%eax
  80181f:	8b 40 0c             	mov    0xc(%eax),%eax
  801822:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801827:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 03 00 00 00       	mov    $0x3,%eax
  801837:	e8 a2 fe ff ff       	call   8016de <fsipc>
  80183c:	89 c3                	mov    %eax,%ebx
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 4b                	js     80188d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801842:	39 c6                	cmp    %eax,%esi
  801844:	73 16                	jae    80185c <devfile_read+0x48>
  801846:	68 c4 2d 80 00       	push   $0x802dc4
  80184b:	68 cb 2d 80 00       	push   $0x802dcb
  801850:	6a 7c                	push   $0x7c
  801852:	68 e0 2d 80 00       	push   $0x802de0
  801857:	e8 c4 e9 ff ff       	call   800220 <_panic>
	assert(r <= PGSIZE);
  80185c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801861:	7e 16                	jle    801879 <devfile_read+0x65>
  801863:	68 eb 2d 80 00       	push   $0x802deb
  801868:	68 cb 2d 80 00       	push   $0x802dcb
  80186d:	6a 7d                	push   $0x7d
  80186f:	68 e0 2d 80 00       	push   $0x802de0
  801874:	e8 a7 e9 ff ff       	call   800220 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801879:	83 ec 04             	sub    $0x4,%esp
  80187c:	50                   	push   %eax
  80187d:	68 00 50 80 00       	push   $0x805000
  801882:	ff 75 0c             	pushl  0xc(%ebp)
  801885:	e8 86 f1 ff ff       	call   800a10 <memmove>
	return r;
  80188a:	83 c4 10             	add    $0x10,%esp
}
  80188d:	89 d8                	mov    %ebx,%eax
  80188f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801892:	5b                   	pop    %ebx
  801893:	5e                   	pop    %esi
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	53                   	push   %ebx
  80189a:	83 ec 20             	sub    $0x20,%esp
  80189d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018a0:	53                   	push   %ebx
  8018a1:	e8 9f ef ff ff       	call   800845 <strlen>
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ae:	7f 67                	jg     801917 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b0:	83 ec 0c             	sub    $0xc,%esp
  8018b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b6:	50                   	push   %eax
  8018b7:	e8 9a f8 ff ff       	call   801156 <fd_alloc>
  8018bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8018bf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 57                	js     80191c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	53                   	push   %ebx
  8018c9:	68 00 50 80 00       	push   $0x805000
  8018ce:	e8 ab ef ff ff       	call   80087e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018de:	b8 01 00 00 00       	mov    $0x1,%eax
  8018e3:	e8 f6 fd ff ff       	call   8016de <fsipc>
  8018e8:	89 c3                	mov    %eax,%ebx
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	79 14                	jns    801905 <open+0x6f>
		fd_close(fd, 0);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	6a 00                	push   $0x0
  8018f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f9:	e8 50 f9 ff ff       	call   80124e <fd_close>
		return r;
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	89 da                	mov    %ebx,%edx
  801903:	eb 17                	jmp    80191c <open+0x86>
	}

	return fd2num(fd);
  801905:	83 ec 0c             	sub    $0xc,%esp
  801908:	ff 75 f4             	pushl  -0xc(%ebp)
  80190b:	e8 1f f8 ff ff       	call   80112f <fd2num>
  801910:	89 c2                	mov    %eax,%edx
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	eb 05                	jmp    80191c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801917:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80191c:	89 d0                	mov    %edx,%eax
  80191e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801929:	ba 00 00 00 00       	mov    $0x0,%edx
  80192e:	b8 08 00 00 00       	mov    $0x8,%eax
  801933:	e8 a6 fd ff ff       	call   8016de <fsipc>
}
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	57                   	push   %edi
  80193e:	56                   	push   %esi
  80193f:	53                   	push   %ebx
  801940:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801946:	6a 00                	push   $0x0
  801948:	ff 75 08             	pushl  0x8(%ebp)
  80194b:	e8 46 ff ff ff       	call   801896 <open>
  801950:	89 c7                	mov    %eax,%edi
  801952:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	85 c0                	test   %eax,%eax
  80195d:	0f 88 89 04 00 00    	js     801dec <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	68 00 02 00 00       	push   $0x200
  80196b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801971:	50                   	push   %eax
  801972:	57                   	push   %edi
  801973:	e8 24 fb ff ff       	call   80149c <readn>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	3d 00 02 00 00       	cmp    $0x200,%eax
  801980:	75 0c                	jne    80198e <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801982:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801989:	45 4c 46 
  80198c:	74 33                	je     8019c1 <spawn+0x87>
		close(fd);
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801997:	e8 33 f9 ff ff       	call   8012cf <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80199c:	83 c4 0c             	add    $0xc,%esp
  80199f:	68 7f 45 4c 46       	push   $0x464c457f
  8019a4:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019aa:	68 f7 2d 80 00       	push   $0x802df7
  8019af:	e8 45 e9 ff ff       	call   8002f9 <cprintf>
		return -E_NOT_EXEC;
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019bc:	e9 de 04 00 00       	jmp    801e9f <spawn+0x565>
  8019c1:	b8 07 00 00 00       	mov    $0x7,%eax
  8019c6:	cd 30                	int    $0x30
  8019c8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019ce:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	0f 88 1b 04 00 00    	js     801df7 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019dc:	89 c6                	mov    %eax,%esi
  8019de:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019e4:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019e7:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019ed:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019f3:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019fa:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a00:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a06:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a0b:	be 00 00 00 00       	mov    $0x0,%esi
  801a10:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a13:	eb 13                	jmp    801a28 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	50                   	push   %eax
  801a19:	e8 27 ee ff ff       	call   800845 <strlen>
  801a1e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a22:	83 c3 01             	add    $0x1,%ebx
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a2f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a32:	85 c0                	test   %eax,%eax
  801a34:	75 df                	jne    801a15 <spawn+0xdb>
  801a36:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a3c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a42:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a47:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a49:	89 fa                	mov    %edi,%edx
  801a4b:	83 e2 fc             	and    $0xfffffffc,%edx
  801a4e:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a55:	29 c2                	sub    %eax,%edx
  801a57:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a5d:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a60:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a65:	0f 86 a2 03 00 00    	jbe    801e0d <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a6b:	83 ec 04             	sub    $0x4,%esp
  801a6e:	6a 07                	push   $0x7
  801a70:	68 00 00 40 00       	push   $0x400000
  801a75:	6a 00                	push   $0x0
  801a77:	e8 05 f2 ff ff       	call   800c81 <sys_page_alloc>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	0f 88 90 03 00 00    	js     801e17 <spawn+0x4dd>
  801a87:	be 00 00 00 00       	mov    $0x0,%esi
  801a8c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a95:	eb 30                	jmp    801ac7 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a97:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a9d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801aa3:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801aac:	57                   	push   %edi
  801aad:	e8 cc ed ff ff       	call   80087e <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ab2:	83 c4 04             	add    $0x4,%esp
  801ab5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ab8:	e8 88 ed ff ff       	call   800845 <strlen>
  801abd:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ac1:	83 c6 01             	add    $0x1,%esi
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801acd:	7f c8                	jg     801a97 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801acf:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ad5:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801adb:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ae2:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801ae8:	74 19                	je     801b03 <spawn+0x1c9>
  801aea:	68 84 2e 80 00       	push   $0x802e84
  801aef:	68 cb 2d 80 00       	push   $0x802dcb
  801af4:	68 f2 00 00 00       	push   $0xf2
  801af9:	68 11 2e 80 00       	push   $0x802e11
  801afe:	e8 1d e7 ff ff       	call   800220 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b03:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b09:	89 f8                	mov    %edi,%eax
  801b0b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b10:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b13:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b19:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b1c:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b22:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	6a 07                	push   $0x7
  801b2d:	68 00 d0 bf ee       	push   $0xeebfd000
  801b32:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b38:	68 00 00 40 00       	push   $0x400000
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 80 f1 ff ff       	call   800cc4 <sys_page_map>
  801b44:	89 c3                	mov    %eax,%ebx
  801b46:	83 c4 20             	add    $0x20,%esp
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	0f 88 3c 03 00 00    	js     801e8d <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b51:	83 ec 08             	sub    $0x8,%esp
  801b54:	68 00 00 40 00       	push   $0x400000
  801b59:	6a 00                	push   $0x0
  801b5b:	e8 a6 f1 ff ff       	call   800d06 <sys_page_unmap>
  801b60:	89 c3                	mov    %eax,%ebx
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	85 c0                	test   %eax,%eax
  801b67:	0f 88 20 03 00 00    	js     801e8d <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b6d:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b73:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b7a:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b80:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b87:	00 00 00 
  801b8a:	e9 88 01 00 00       	jmp    801d17 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801b8f:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b95:	83 38 01             	cmpl   $0x1,(%eax)
  801b98:	0f 85 6b 01 00 00    	jne    801d09 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	8b 40 18             	mov    0x18(%eax),%eax
  801ba3:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ba9:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801bac:	83 f8 01             	cmp    $0x1,%eax
  801baf:	19 c0                	sbb    %eax,%eax
  801bb1:	83 e0 fe             	and    $0xfffffffe,%eax
  801bb4:	83 c0 07             	add    $0x7,%eax
  801bb7:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bbd:	89 d0                	mov    %edx,%eax
  801bbf:	8b 7a 04             	mov    0x4(%edx),%edi
  801bc2:	89 f9                	mov    %edi,%ecx
  801bc4:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801bca:	8b 7a 10             	mov    0x10(%edx),%edi
  801bcd:	8b 52 14             	mov    0x14(%edx),%edx
  801bd0:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801bd6:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bd9:	89 f0                	mov    %esi,%eax
  801bdb:	25 ff 0f 00 00       	and    $0xfff,%eax
  801be0:	74 14                	je     801bf6 <spawn+0x2bc>
		va -= i;
  801be2:	29 c6                	sub    %eax,%esi
		memsz += i;
  801be4:	01 c2                	add    %eax,%edx
  801be6:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801bec:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bee:	29 c1                	sub    %eax,%ecx
  801bf0:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bfb:	e9 f7 00 00 00       	jmp    801cf7 <spawn+0x3bd>
		if (i >= filesz) {
  801c00:	39 fb                	cmp    %edi,%ebx
  801c02:	72 27                	jb     801c2b <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c0d:	56                   	push   %esi
  801c0e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c14:	e8 68 f0 ff ff       	call   800c81 <sys_page_alloc>
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	0f 89 c7 00 00 00    	jns    801ceb <spawn+0x3b1>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	e9 fd 01 00 00       	jmp    801e28 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c2b:	83 ec 04             	sub    $0x4,%esp
  801c2e:	6a 07                	push   $0x7
  801c30:	68 00 00 40 00       	push   $0x400000
  801c35:	6a 00                	push   $0x0
  801c37:	e8 45 f0 ff ff       	call   800c81 <sys_page_alloc>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 d7 01 00 00    	js     801e1e <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c47:	83 ec 08             	sub    $0x8,%esp
  801c4a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c50:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c56:	50                   	push   %eax
  801c57:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c5d:	e8 0f f9 ff ff       	call   801571 <seek>
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	0f 88 b5 01 00 00    	js     801e22 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	89 f8                	mov    %edi,%eax
  801c72:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c78:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c7d:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c82:	0f 47 c2             	cmova  %edx,%eax
  801c85:	50                   	push   %eax
  801c86:	68 00 00 40 00       	push   $0x400000
  801c8b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c91:	e8 06 f8 ff ff       	call   80149c <readn>
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	0f 88 85 01 00 00    	js     801e26 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ca1:	83 ec 0c             	sub    $0xc,%esp
  801ca4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801caa:	56                   	push   %esi
  801cab:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cb1:	68 00 00 40 00       	push   $0x400000
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 07 f0 ff ff       	call   800cc4 <sys_page_map>
  801cbd:	83 c4 20             	add    $0x20,%esp
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	79 15                	jns    801cd9 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801cc4:	50                   	push   %eax
  801cc5:	68 1d 2e 80 00       	push   $0x802e1d
  801cca:	68 25 01 00 00       	push   $0x125
  801ccf:	68 11 2e 80 00       	push   $0x802e11
  801cd4:	e8 47 e5 ff ff       	call   800220 <_panic>
			sys_page_unmap(0, UTEMP);
  801cd9:	83 ec 08             	sub    $0x8,%esp
  801cdc:	68 00 00 40 00       	push   $0x400000
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 1e f0 ff ff       	call   800d06 <sys_page_unmap>
  801ce8:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ceb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cf1:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cf7:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cfd:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d03:	0f 82 f7 fe ff ff    	jb     801c00 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d09:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d10:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d17:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d1e:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d24:	0f 8c 65 fe ff ff    	jl     801b8f <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d2a:	83 ec 0c             	sub    $0xc,%esp
  801d2d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d33:	e8 97 f5 ff ff       	call   8012cf <close>
  801d38:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d40:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	c1 e8 16             	shr    $0x16,%eax
  801d4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d52:	a8 01                	test   $0x1,%al
  801d54:	74 42                	je     801d98 <spawn+0x45e>
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	c1 e8 0c             	shr    $0xc,%eax
  801d5b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d62:	f6 c2 01             	test   $0x1,%dl
  801d65:	74 31                	je     801d98 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  801d67:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  801d6e:	f6 c6 04             	test   $0x4,%dh
  801d71:	74 25                	je     801d98 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  801d73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d7a:	83 ec 0c             	sub    $0xc,%esp
  801d7d:	25 07 0e 00 00       	and    $0xe07,%eax
  801d82:	50                   	push   %eax
  801d83:	53                   	push   %ebx
  801d84:	56                   	push   %esi
  801d85:	53                   	push   %ebx
  801d86:	6a 00                	push   $0x0
  801d88:	e8 37 ef ff ff       	call   800cc4 <sys_page_map>
			if (r < 0) {
  801d8d:	83 c4 20             	add    $0x20,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 b1 00 00 00    	js     801e49 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801d98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d9e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801da4:	75 a0                	jne    801d46 <spawn+0x40c>
  801da6:	e9 b3 00 00 00       	jmp    801e5e <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801dab:	50                   	push   %eax
  801dac:	68 3a 2e 80 00       	push   $0x802e3a
  801db1:	68 86 00 00 00       	push   $0x86
  801db6:	68 11 2e 80 00       	push   $0x802e11
  801dbb:	e8 60 e4 ff ff       	call   800220 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	6a 02                	push   $0x2
  801dc5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dcb:	e8 78 ef ff ff       	call   800d48 <sys_env_set_status>
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	79 2b                	jns    801e02 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801dd7:	50                   	push   %eax
  801dd8:	68 54 2e 80 00       	push   $0x802e54
  801ddd:	68 89 00 00 00       	push   $0x89
  801de2:	68 11 2e 80 00       	push   $0x802e11
  801de7:	e8 34 e4 ff ff       	call   800220 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801dec:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801df2:	e9 a8 00 00 00       	jmp    801e9f <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801df7:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dfd:	e9 9d 00 00 00       	jmp    801e9f <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e02:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e08:	e9 92 00 00 00       	jmp    801e9f <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e0d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e12:	e9 88 00 00 00       	jmp    801e9f <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e17:	89 c3                	mov    %eax,%ebx
  801e19:	e9 81 00 00 00       	jmp    801e9f <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	eb 06                	jmp    801e28 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e22:	89 c3                	mov    %eax,%ebx
  801e24:	eb 02                	jmp    801e28 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e26:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e31:	e8 cc ed ff ff       	call   800c02 <sys_env_destroy>
	close(fd);
  801e36:	83 c4 04             	add    $0x4,%esp
  801e39:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e3f:	e8 8b f4 ff ff       	call   8012cf <close>
	return r;
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	eb 56                	jmp    801e9f <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e49:	50                   	push   %eax
  801e4a:	68 6b 2e 80 00       	push   $0x802e6b
  801e4f:	68 82 00 00 00       	push   $0x82
  801e54:	68 11 2e 80 00       	push   $0x802e11
  801e59:	e8 c2 e3 ff ff       	call   800220 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e5e:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e65:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e71:	50                   	push   %eax
  801e72:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e78:	e8 0d ef ff ff       	call   800d8a <sys_env_set_trapframe>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	85 c0                	test   %eax,%eax
  801e82:	0f 89 38 ff ff ff    	jns    801dc0 <spawn+0x486>
  801e88:	e9 1e ff ff ff       	jmp    801dab <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e8d:	83 ec 08             	sub    $0x8,%esp
  801e90:	68 00 00 40 00       	push   $0x400000
  801e95:	6a 00                	push   $0x0
  801e97:	e8 6a ee ff ff       	call   800d06 <sys_page_unmap>
  801e9c:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e9f:	89 d8                	mov    %ebx,%eax
  801ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eae:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eb6:	eb 03                	jmp    801ebb <spawnl+0x12>
		argc++;
  801eb8:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ebb:	83 c2 04             	add    $0x4,%edx
  801ebe:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ec2:	75 f4                	jne    801eb8 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ec4:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ecb:	83 e2 f0             	and    $0xfffffff0,%edx
  801ece:	29 d4                	sub    %edx,%esp
  801ed0:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ed4:	c1 ea 02             	shr    $0x2,%edx
  801ed7:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ede:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee3:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801eea:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ef1:	00 
  801ef2:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef9:	eb 0a                	jmp    801f05 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801efb:	83 c0 01             	add    $0x1,%eax
  801efe:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f02:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f05:	39 d0                	cmp    %edx,%eax
  801f07:	75 f2                	jne    801efb <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f09:	83 ec 08             	sub    $0x8,%esp
  801f0c:	56                   	push   %esi
  801f0d:	ff 75 08             	pushl  0x8(%ebp)
  801f10:	e8 25 fa ff ff       	call   80193a <spawn>
}
  801f15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	56                   	push   %esi
  801f20:	53                   	push   %ebx
  801f21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f24:	83 ec 0c             	sub    $0xc,%esp
  801f27:	ff 75 08             	pushl  0x8(%ebp)
  801f2a:	e8 10 f2 ff ff       	call   80113f <fd2data>
  801f2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f31:	83 c4 08             	add    $0x8,%esp
  801f34:	68 ac 2e 80 00       	push   $0x802eac
  801f39:	53                   	push   %ebx
  801f3a:	e8 3f e9 ff ff       	call   80087e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f3f:	8b 46 04             	mov    0x4(%esi),%eax
  801f42:	2b 06                	sub    (%esi),%eax
  801f44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f51:	00 00 00 
	stat->st_dev = &devpipe;
  801f54:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f5b:	30 80 00 
	return 0;
}
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f66:	5b                   	pop    %ebx
  801f67:	5e                   	pop    %esi
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	53                   	push   %ebx
  801f6e:	83 ec 0c             	sub    $0xc,%esp
  801f71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f74:	53                   	push   %ebx
  801f75:	6a 00                	push   $0x0
  801f77:	e8 8a ed ff ff       	call   800d06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f7c:	89 1c 24             	mov    %ebx,(%esp)
  801f7f:	e8 bb f1 ff ff       	call   80113f <fd2data>
  801f84:	83 c4 08             	add    $0x8,%esp
  801f87:	50                   	push   %eax
  801f88:	6a 00                	push   $0x0
  801f8a:	e8 77 ed ff ff       	call   800d06 <sys_page_unmap>
}
  801f8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	57                   	push   %edi
  801f98:	56                   	push   %esi
  801f99:	53                   	push   %ebx
  801f9a:	83 ec 1c             	sub    $0x1c,%esp
  801f9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fa0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fa2:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	ff 75 e0             	pushl  -0x20(%ebp)
  801fb0:	e8 31 06 00 00       	call   8025e6 <pageref>
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	89 3c 24             	mov    %edi,(%esp)
  801fba:	e8 27 06 00 00       	call   8025e6 <pageref>
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	39 c3                	cmp    %eax,%ebx
  801fc4:	0f 94 c1             	sete   %cl
  801fc7:	0f b6 c9             	movzbl %cl,%ecx
  801fca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fcd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fd3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fd6:	39 ce                	cmp    %ecx,%esi
  801fd8:	74 1b                	je     801ff5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fda:	39 c3                	cmp    %eax,%ebx
  801fdc:	75 c4                	jne    801fa2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fde:	8b 42 58             	mov    0x58(%edx),%eax
  801fe1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fe4:	50                   	push   %eax
  801fe5:	56                   	push   %esi
  801fe6:	68 b3 2e 80 00       	push   $0x802eb3
  801feb:	e8 09 e3 ff ff       	call   8002f9 <cprintf>
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	eb ad                	jmp    801fa2 <_pipeisclosed+0xe>
	}
}
  801ff5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffb:	5b                   	pop    %ebx
  801ffc:	5e                   	pop    %esi
  801ffd:	5f                   	pop    %edi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	57                   	push   %edi
  802004:	56                   	push   %esi
  802005:	53                   	push   %ebx
  802006:	83 ec 28             	sub    $0x28,%esp
  802009:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80200c:	56                   	push   %esi
  80200d:	e8 2d f1 ff ff       	call   80113f <fd2data>
  802012:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	bf 00 00 00 00       	mov    $0x0,%edi
  80201c:	eb 4b                	jmp    802069 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80201e:	89 da                	mov    %ebx,%edx
  802020:	89 f0                	mov    %esi,%eax
  802022:	e8 6d ff ff ff       	call   801f94 <_pipeisclosed>
  802027:	85 c0                	test   %eax,%eax
  802029:	75 48                	jne    802073 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80202b:	e8 32 ec ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802030:	8b 43 04             	mov    0x4(%ebx),%eax
  802033:	8b 0b                	mov    (%ebx),%ecx
  802035:	8d 51 20             	lea    0x20(%ecx),%edx
  802038:	39 d0                	cmp    %edx,%eax
  80203a:	73 e2                	jae    80201e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80203c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80203f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802043:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802046:	89 c2                	mov    %eax,%edx
  802048:	c1 fa 1f             	sar    $0x1f,%edx
  80204b:	89 d1                	mov    %edx,%ecx
  80204d:	c1 e9 1b             	shr    $0x1b,%ecx
  802050:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802053:	83 e2 1f             	and    $0x1f,%edx
  802056:	29 ca                	sub    %ecx,%edx
  802058:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80205c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802060:	83 c0 01             	add    $0x1,%eax
  802063:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802066:	83 c7 01             	add    $0x1,%edi
  802069:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80206c:	75 c2                	jne    802030 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80206e:	8b 45 10             	mov    0x10(%ebp),%eax
  802071:	eb 05                	jmp    802078 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802078:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207b:	5b                   	pop    %ebx
  80207c:	5e                   	pop    %esi
  80207d:	5f                   	pop    %edi
  80207e:	5d                   	pop    %ebp
  80207f:	c3                   	ret    

00802080 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	57                   	push   %edi
  802084:	56                   	push   %esi
  802085:	53                   	push   %ebx
  802086:	83 ec 18             	sub    $0x18,%esp
  802089:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80208c:	57                   	push   %edi
  80208d:	e8 ad f0 ff ff       	call   80113f <fd2data>
  802092:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802094:	83 c4 10             	add    $0x10,%esp
  802097:	bb 00 00 00 00       	mov    $0x0,%ebx
  80209c:	eb 3d                	jmp    8020db <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80209e:	85 db                	test   %ebx,%ebx
  8020a0:	74 04                	je     8020a6 <devpipe_read+0x26>
				return i;
  8020a2:	89 d8                	mov    %ebx,%eax
  8020a4:	eb 44                	jmp    8020ea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020a6:	89 f2                	mov    %esi,%edx
  8020a8:	89 f8                	mov    %edi,%eax
  8020aa:	e8 e5 fe ff ff       	call   801f94 <_pipeisclosed>
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	75 32                	jne    8020e5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020b3:	e8 aa eb ff ff       	call   800c62 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020b8:	8b 06                	mov    (%esi),%eax
  8020ba:	3b 46 04             	cmp    0x4(%esi),%eax
  8020bd:	74 df                	je     80209e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020bf:	99                   	cltd   
  8020c0:	c1 ea 1b             	shr    $0x1b,%edx
  8020c3:	01 d0                	add    %edx,%eax
  8020c5:	83 e0 1f             	and    $0x1f,%eax
  8020c8:	29 d0                	sub    %edx,%eax
  8020ca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020d5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d8:	83 c3 01             	add    $0x1,%ebx
  8020db:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020de:	75 d8                	jne    8020b8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e3:	eb 05                	jmp    8020ea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020e5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    

008020f2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	56                   	push   %esi
  8020f6:	53                   	push   %ebx
  8020f7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fd:	50                   	push   %eax
  8020fe:	e8 53 f0 ff ff       	call   801156 <fd_alloc>
  802103:	83 c4 10             	add    $0x10,%esp
  802106:	89 c2                	mov    %eax,%edx
  802108:	85 c0                	test   %eax,%eax
  80210a:	0f 88 2c 01 00 00    	js     80223c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802110:	83 ec 04             	sub    $0x4,%esp
  802113:	68 07 04 00 00       	push   $0x407
  802118:	ff 75 f4             	pushl  -0xc(%ebp)
  80211b:	6a 00                	push   $0x0
  80211d:	e8 5f eb ff ff       	call   800c81 <sys_page_alloc>
  802122:	83 c4 10             	add    $0x10,%esp
  802125:	89 c2                	mov    %eax,%edx
  802127:	85 c0                	test   %eax,%eax
  802129:	0f 88 0d 01 00 00    	js     80223c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80212f:	83 ec 0c             	sub    $0xc,%esp
  802132:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802135:	50                   	push   %eax
  802136:	e8 1b f0 ff ff       	call   801156 <fd_alloc>
  80213b:	89 c3                	mov    %eax,%ebx
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	85 c0                	test   %eax,%eax
  802142:	0f 88 e2 00 00 00    	js     80222a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802148:	83 ec 04             	sub    $0x4,%esp
  80214b:	68 07 04 00 00       	push   $0x407
  802150:	ff 75 f0             	pushl  -0x10(%ebp)
  802153:	6a 00                	push   $0x0
  802155:	e8 27 eb ff ff       	call   800c81 <sys_page_alloc>
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	83 c4 10             	add    $0x10,%esp
  80215f:	85 c0                	test   %eax,%eax
  802161:	0f 88 c3 00 00 00    	js     80222a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802167:	83 ec 0c             	sub    $0xc,%esp
  80216a:	ff 75 f4             	pushl  -0xc(%ebp)
  80216d:	e8 cd ef ff ff       	call   80113f <fd2data>
  802172:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802174:	83 c4 0c             	add    $0xc,%esp
  802177:	68 07 04 00 00       	push   $0x407
  80217c:	50                   	push   %eax
  80217d:	6a 00                	push   $0x0
  80217f:	e8 fd ea ff ff       	call   800c81 <sys_page_alloc>
  802184:	89 c3                	mov    %eax,%ebx
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	85 c0                	test   %eax,%eax
  80218b:	0f 88 89 00 00 00    	js     80221a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802191:	83 ec 0c             	sub    $0xc,%esp
  802194:	ff 75 f0             	pushl  -0x10(%ebp)
  802197:	e8 a3 ef ff ff       	call   80113f <fd2data>
  80219c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021a3:	50                   	push   %eax
  8021a4:	6a 00                	push   $0x0
  8021a6:	56                   	push   %esi
  8021a7:	6a 00                	push   $0x0
  8021a9:	e8 16 eb ff ff       	call   800cc4 <sys_page_map>
  8021ae:	89 c3                	mov    %eax,%ebx
  8021b0:	83 c4 20             	add    $0x20,%esp
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	78 55                	js     80220c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021b7:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021cc:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021da:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021e1:	83 ec 0c             	sub    $0xc,%esp
  8021e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e7:	e8 43 ef ff ff       	call   80112f <fd2num>
  8021ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021f1:	83 c4 04             	add    $0x4,%esp
  8021f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f7:	e8 33 ef ff ff       	call   80112f <fd2num>
  8021fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ff:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802202:	83 c4 10             	add    $0x10,%esp
  802205:	ba 00 00 00 00       	mov    $0x0,%edx
  80220a:	eb 30                	jmp    80223c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80220c:	83 ec 08             	sub    $0x8,%esp
  80220f:	56                   	push   %esi
  802210:	6a 00                	push   $0x0
  802212:	e8 ef ea ff ff       	call   800d06 <sys_page_unmap>
  802217:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80221a:	83 ec 08             	sub    $0x8,%esp
  80221d:	ff 75 f0             	pushl  -0x10(%ebp)
  802220:	6a 00                	push   $0x0
  802222:	e8 df ea ff ff       	call   800d06 <sys_page_unmap>
  802227:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80222a:	83 ec 08             	sub    $0x8,%esp
  80222d:	ff 75 f4             	pushl  -0xc(%ebp)
  802230:	6a 00                	push   $0x0
  802232:	e8 cf ea ff ff       	call   800d06 <sys_page_unmap>
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80223c:	89 d0                	mov    %edx,%eax
  80223e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    

00802245 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224e:	50                   	push   %eax
  80224f:	ff 75 08             	pushl  0x8(%ebp)
  802252:	e8 4e ef ff ff       	call   8011a5 <fd_lookup>
  802257:	83 c4 10             	add    $0x10,%esp
  80225a:	85 c0                	test   %eax,%eax
  80225c:	78 18                	js     802276 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80225e:	83 ec 0c             	sub    $0xc,%esp
  802261:	ff 75 f4             	pushl  -0xc(%ebp)
  802264:	e8 d6 ee ff ff       	call   80113f <fd2data>
	return _pipeisclosed(fd, p);
  802269:	89 c2                	mov    %eax,%edx
  80226b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226e:	e8 21 fd ff ff       	call   801f94 <_pipeisclosed>
  802273:	83 c4 10             	add    $0x10,%esp
}
  802276:	c9                   	leave  
  802277:	c3                   	ret    

00802278 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802280:	85 f6                	test   %esi,%esi
  802282:	75 16                	jne    80229a <wait+0x22>
  802284:	68 cb 2e 80 00       	push   $0x802ecb
  802289:	68 cb 2d 80 00       	push   $0x802dcb
  80228e:	6a 09                	push   $0x9
  802290:	68 d6 2e 80 00       	push   $0x802ed6
  802295:	e8 86 df ff ff       	call   800220 <_panic>
	e = &envs[ENVX(envid)];
  80229a:	89 f3                	mov    %esi,%ebx
  80229c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022a2:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022a5:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022ab:	eb 05                	jmp    8022b2 <wait+0x3a>
		sys_yield();
  8022ad:	e8 b0 e9 ff ff       	call   800c62 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022b2:	8b 43 48             	mov    0x48(%ebx),%eax
  8022b5:	39 c6                	cmp    %eax,%esi
  8022b7:	75 07                	jne    8022c0 <wait+0x48>
  8022b9:	8b 43 54             	mov    0x54(%ebx),%eax
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	75 ed                	jne    8022ad <wait+0x35>
		sys_yield();
}
  8022c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    

008022c7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    

008022d1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022d7:	68 e1 2e 80 00       	push   $0x802ee1
  8022dc:	ff 75 0c             	pushl  0xc(%ebp)
  8022df:	e8 9a e5 ff ff       	call   80087e <strcpy>
	return 0;
}
  8022e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e9:	c9                   	leave  
  8022ea:	c3                   	ret    

008022eb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	57                   	push   %edi
  8022ef:	56                   	push   %esi
  8022f0:	53                   	push   %ebx
  8022f1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022fc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802302:	eb 2d                	jmp    802331 <devcons_write+0x46>
		m = n - tot;
  802304:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802307:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802309:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80230c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802311:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802314:	83 ec 04             	sub    $0x4,%esp
  802317:	53                   	push   %ebx
  802318:	03 45 0c             	add    0xc(%ebp),%eax
  80231b:	50                   	push   %eax
  80231c:	57                   	push   %edi
  80231d:	e8 ee e6 ff ff       	call   800a10 <memmove>
		sys_cputs(buf, m);
  802322:	83 c4 08             	add    $0x8,%esp
  802325:	53                   	push   %ebx
  802326:	57                   	push   %edi
  802327:	e8 99 e8 ff ff       	call   800bc5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80232c:	01 de                	add    %ebx,%esi
  80232e:	83 c4 10             	add    $0x10,%esp
  802331:	89 f0                	mov    %esi,%eax
  802333:	3b 75 10             	cmp    0x10(%ebp),%esi
  802336:	72 cc                	jb     802304 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80233b:	5b                   	pop    %ebx
  80233c:	5e                   	pop    %esi
  80233d:	5f                   	pop    %edi
  80233e:	5d                   	pop    %ebp
  80233f:	c3                   	ret    

00802340 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	83 ec 08             	sub    $0x8,%esp
  802346:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80234b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80234f:	74 2a                	je     80237b <devcons_read+0x3b>
  802351:	eb 05                	jmp    802358 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802353:	e8 0a e9 ff ff       	call   800c62 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802358:	e8 86 e8 ff ff       	call   800be3 <sys_cgetc>
  80235d:	85 c0                	test   %eax,%eax
  80235f:	74 f2                	je     802353 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802361:	85 c0                	test   %eax,%eax
  802363:	78 16                	js     80237b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802365:	83 f8 04             	cmp    $0x4,%eax
  802368:	74 0c                	je     802376 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80236a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80236d:	88 02                	mov    %al,(%edx)
	return 1;
  80236f:	b8 01 00 00 00       	mov    $0x1,%eax
  802374:	eb 05                	jmp    80237b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802376:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80237b:	c9                   	leave  
  80237c:	c3                   	ret    

0080237d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802383:	8b 45 08             	mov    0x8(%ebp),%eax
  802386:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802389:	6a 01                	push   $0x1
  80238b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80238e:	50                   	push   %eax
  80238f:	e8 31 e8 ff ff       	call   800bc5 <sys_cputs>
}
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	c9                   	leave  
  802398:	c3                   	ret    

00802399 <getchar>:

int
getchar(void)
{
  802399:	55                   	push   %ebp
  80239a:	89 e5                	mov    %esp,%ebp
  80239c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80239f:	6a 01                	push   $0x1
  8023a1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023a4:	50                   	push   %eax
  8023a5:	6a 00                	push   $0x0
  8023a7:	e8 5f f0 ff ff       	call   80140b <read>
	if (r < 0)
  8023ac:	83 c4 10             	add    $0x10,%esp
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	78 0f                	js     8023c2 <getchar+0x29>
		return r;
	if (r < 1)
  8023b3:	85 c0                	test   %eax,%eax
  8023b5:	7e 06                	jle    8023bd <getchar+0x24>
		return -E_EOF;
	return c;
  8023b7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023bb:	eb 05                	jmp    8023c2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023bd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023c2:	c9                   	leave  
  8023c3:	c3                   	ret    

008023c4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023cd:	50                   	push   %eax
  8023ce:	ff 75 08             	pushl  0x8(%ebp)
  8023d1:	e8 cf ed ff ff       	call   8011a5 <fd_lookup>
  8023d6:	83 c4 10             	add    $0x10,%esp
  8023d9:	85 c0                	test   %eax,%eax
  8023db:	78 11                	js     8023ee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e0:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023e6:	39 10                	cmp    %edx,(%eax)
  8023e8:	0f 94 c0             	sete   %al
  8023eb:	0f b6 c0             	movzbl %al,%eax
}
  8023ee:	c9                   	leave  
  8023ef:	c3                   	ret    

008023f0 <opencons>:

int
opencons(void)
{
  8023f0:	55                   	push   %ebp
  8023f1:	89 e5                	mov    %esp,%ebp
  8023f3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f9:	50                   	push   %eax
  8023fa:	e8 57 ed ff ff       	call   801156 <fd_alloc>
  8023ff:	83 c4 10             	add    $0x10,%esp
		return r;
  802402:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802404:	85 c0                	test   %eax,%eax
  802406:	78 3e                	js     802446 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802408:	83 ec 04             	sub    $0x4,%esp
  80240b:	68 07 04 00 00       	push   $0x407
  802410:	ff 75 f4             	pushl  -0xc(%ebp)
  802413:	6a 00                	push   $0x0
  802415:	e8 67 e8 ff ff       	call   800c81 <sys_page_alloc>
  80241a:	83 c4 10             	add    $0x10,%esp
		return r;
  80241d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80241f:	85 c0                	test   %eax,%eax
  802421:	78 23                	js     802446 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802423:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80242e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802431:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802438:	83 ec 0c             	sub    $0xc,%esp
  80243b:	50                   	push   %eax
  80243c:	e8 ee ec ff ff       	call   80112f <fd2num>
  802441:	89 c2                	mov    %eax,%edx
  802443:	83 c4 10             	add    $0x10,%esp
}
  802446:	89 d0                	mov    %edx,%eax
  802448:	c9                   	leave  
  802449:	c3                   	ret    

0080244a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80244a:	55                   	push   %ebp
  80244b:	89 e5                	mov    %esp,%ebp
  80244d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802450:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802457:	75 2a                	jne    802483 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802459:	83 ec 04             	sub    $0x4,%esp
  80245c:	6a 07                	push   $0x7
  80245e:	68 00 f0 bf ee       	push   $0xeebff000
  802463:	6a 00                	push   $0x0
  802465:	e8 17 e8 ff ff       	call   800c81 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	85 c0                	test   %eax,%eax
  80246f:	79 12                	jns    802483 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802471:	50                   	push   %eax
  802472:	68 ed 2e 80 00       	push   $0x802eed
  802477:	6a 23                	push   $0x23
  802479:	68 f1 2e 80 00       	push   $0x802ef1
  80247e:	e8 9d dd ff ff       	call   800220 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802483:	8b 45 08             	mov    0x8(%ebp),%eax
  802486:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80248b:	83 ec 08             	sub    $0x8,%esp
  80248e:	68 b5 24 80 00       	push   $0x8024b5
  802493:	6a 00                	push   $0x0
  802495:	e8 32 e9 ff ff       	call   800dcc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80249a:	83 c4 10             	add    $0x10,%esp
  80249d:	85 c0                	test   %eax,%eax
  80249f:	79 12                	jns    8024b3 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8024a1:	50                   	push   %eax
  8024a2:	68 ed 2e 80 00       	push   $0x802eed
  8024a7:	6a 2c                	push   $0x2c
  8024a9:	68 f1 2e 80 00       	push   $0x802ef1
  8024ae:	e8 6d dd ff ff       	call   800220 <_panic>
	}
}
  8024b3:	c9                   	leave  
  8024b4:	c3                   	ret    

008024b5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024b5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024b6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8024bb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024bd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8024c0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8024c4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8024c9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8024cd:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8024cf:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8024d2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8024d3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8024d6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8024d7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024d8:	c3                   	ret    

008024d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024d9:	55                   	push   %ebp
  8024da:	89 e5                	mov    %esp,%ebp
  8024dc:	56                   	push   %esi
  8024dd:	53                   	push   %ebx
  8024de:	8b 75 08             	mov    0x8(%ebp),%esi
  8024e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8024e7:	85 c0                	test   %eax,%eax
  8024e9:	75 12                	jne    8024fd <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8024eb:	83 ec 0c             	sub    $0xc,%esp
  8024ee:	68 00 00 c0 ee       	push   $0xeec00000
  8024f3:	e8 39 e9 ff ff       	call   800e31 <sys_ipc_recv>
  8024f8:	83 c4 10             	add    $0x10,%esp
  8024fb:	eb 0c                	jmp    802509 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8024fd:	83 ec 0c             	sub    $0xc,%esp
  802500:	50                   	push   %eax
  802501:	e8 2b e9 ff ff       	call   800e31 <sys_ipc_recv>
  802506:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802509:	85 f6                	test   %esi,%esi
  80250b:	0f 95 c1             	setne  %cl
  80250e:	85 db                	test   %ebx,%ebx
  802510:	0f 95 c2             	setne  %dl
  802513:	84 d1                	test   %dl,%cl
  802515:	74 09                	je     802520 <ipc_recv+0x47>
  802517:	89 c2                	mov    %eax,%edx
  802519:	c1 ea 1f             	shr    $0x1f,%edx
  80251c:	84 d2                	test   %dl,%dl
  80251e:	75 24                	jne    802544 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802520:	85 f6                	test   %esi,%esi
  802522:	74 0a                	je     80252e <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  802524:	a1 04 40 80 00       	mov    0x804004,%eax
  802529:	8b 40 74             	mov    0x74(%eax),%eax
  80252c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80252e:	85 db                	test   %ebx,%ebx
  802530:	74 0a                	je     80253c <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  802532:	a1 04 40 80 00       	mov    0x804004,%eax
  802537:	8b 40 78             	mov    0x78(%eax),%eax
  80253a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80253c:	a1 04 40 80 00       	mov    0x804004,%eax
  802541:	8b 40 70             	mov    0x70(%eax),%eax
}
  802544:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802547:	5b                   	pop    %ebx
  802548:	5e                   	pop    %esi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    

0080254b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80254b:	55                   	push   %ebp
  80254c:	89 e5                	mov    %esp,%ebp
  80254e:	57                   	push   %edi
  80254f:	56                   	push   %esi
  802550:	53                   	push   %ebx
  802551:	83 ec 0c             	sub    $0xc,%esp
  802554:	8b 7d 08             	mov    0x8(%ebp),%edi
  802557:	8b 75 0c             	mov    0xc(%ebp),%esi
  80255a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80255d:	85 db                	test   %ebx,%ebx
  80255f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802564:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802567:	ff 75 14             	pushl  0x14(%ebp)
  80256a:	53                   	push   %ebx
  80256b:	56                   	push   %esi
  80256c:	57                   	push   %edi
  80256d:	e8 9c e8 ff ff       	call   800e0e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802572:	89 c2                	mov    %eax,%edx
  802574:	c1 ea 1f             	shr    $0x1f,%edx
  802577:	83 c4 10             	add    $0x10,%esp
  80257a:	84 d2                	test   %dl,%dl
  80257c:	74 17                	je     802595 <ipc_send+0x4a>
  80257e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802581:	74 12                	je     802595 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802583:	50                   	push   %eax
  802584:	68 ff 2e 80 00       	push   $0x802eff
  802589:	6a 47                	push   $0x47
  80258b:	68 0d 2f 80 00       	push   $0x802f0d
  802590:	e8 8b dc ff ff       	call   800220 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802595:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802598:	75 07                	jne    8025a1 <ipc_send+0x56>
			sys_yield();
  80259a:	e8 c3 e6 ff ff       	call   800c62 <sys_yield>
  80259f:	eb c6                	jmp    802567 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8025a1:	85 c0                	test   %eax,%eax
  8025a3:	75 c2                	jne    802567 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8025a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a8:	5b                   	pop    %ebx
  8025a9:	5e                   	pop    %esi
  8025aa:	5f                   	pop    %edi
  8025ab:	5d                   	pop    %ebp
  8025ac:	c3                   	ret    

008025ad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025ad:	55                   	push   %ebp
  8025ae:	89 e5                	mov    %esp,%ebp
  8025b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025b3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025b8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025bb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025c1:	8b 52 50             	mov    0x50(%edx),%edx
  8025c4:	39 ca                	cmp    %ecx,%edx
  8025c6:	75 0d                	jne    8025d5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025d0:	8b 40 48             	mov    0x48(%eax),%eax
  8025d3:	eb 0f                	jmp    8025e4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025d5:	83 c0 01             	add    $0x1,%eax
  8025d8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025dd:	75 d9                	jne    8025b8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025e4:	5d                   	pop    %ebp
  8025e5:	c3                   	ret    

008025e6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025e6:	55                   	push   %ebp
  8025e7:	89 e5                	mov    %esp,%ebp
  8025e9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025ec:	89 d0                	mov    %edx,%eax
  8025ee:	c1 e8 16             	shr    $0x16,%eax
  8025f1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025f8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025fd:	f6 c1 01             	test   $0x1,%cl
  802600:	74 1d                	je     80261f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802602:	c1 ea 0c             	shr    $0xc,%edx
  802605:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80260c:	f6 c2 01             	test   $0x1,%dl
  80260f:	74 0e                	je     80261f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802611:	c1 ea 0c             	shr    $0xc,%edx
  802614:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80261b:	ef 
  80261c:	0f b7 c0             	movzwl %ax,%eax
}
  80261f:	5d                   	pop    %ebp
  802620:	c3                   	ret    
  802621:	66 90                	xchg   %ax,%ax
  802623:	66 90                	xchg   %ax,%ax
  802625:	66 90                	xchg   %ax,%ax
  802627:	66 90                	xchg   %ax,%ax
  802629:	66 90                	xchg   %ax,%ax
  80262b:	66 90                	xchg   %ax,%ax
  80262d:	66 90                	xchg   %ax,%ax
  80262f:	90                   	nop

00802630 <__udivdi3>:
  802630:	55                   	push   %ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	83 ec 1c             	sub    $0x1c,%esp
  802637:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80263b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80263f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802643:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802647:	85 f6                	test   %esi,%esi
  802649:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80264d:	89 ca                	mov    %ecx,%edx
  80264f:	89 f8                	mov    %edi,%eax
  802651:	75 3d                	jne    802690 <__udivdi3+0x60>
  802653:	39 cf                	cmp    %ecx,%edi
  802655:	0f 87 c5 00 00 00    	ja     802720 <__udivdi3+0xf0>
  80265b:	85 ff                	test   %edi,%edi
  80265d:	89 fd                	mov    %edi,%ebp
  80265f:	75 0b                	jne    80266c <__udivdi3+0x3c>
  802661:	b8 01 00 00 00       	mov    $0x1,%eax
  802666:	31 d2                	xor    %edx,%edx
  802668:	f7 f7                	div    %edi
  80266a:	89 c5                	mov    %eax,%ebp
  80266c:	89 c8                	mov    %ecx,%eax
  80266e:	31 d2                	xor    %edx,%edx
  802670:	f7 f5                	div    %ebp
  802672:	89 c1                	mov    %eax,%ecx
  802674:	89 d8                	mov    %ebx,%eax
  802676:	89 cf                	mov    %ecx,%edi
  802678:	f7 f5                	div    %ebp
  80267a:	89 c3                	mov    %eax,%ebx
  80267c:	89 d8                	mov    %ebx,%eax
  80267e:	89 fa                	mov    %edi,%edx
  802680:	83 c4 1c             	add    $0x1c,%esp
  802683:	5b                   	pop    %ebx
  802684:	5e                   	pop    %esi
  802685:	5f                   	pop    %edi
  802686:	5d                   	pop    %ebp
  802687:	c3                   	ret    
  802688:	90                   	nop
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	39 ce                	cmp    %ecx,%esi
  802692:	77 74                	ja     802708 <__udivdi3+0xd8>
  802694:	0f bd fe             	bsr    %esi,%edi
  802697:	83 f7 1f             	xor    $0x1f,%edi
  80269a:	0f 84 98 00 00 00    	je     802738 <__udivdi3+0x108>
  8026a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026a5:	89 f9                	mov    %edi,%ecx
  8026a7:	89 c5                	mov    %eax,%ebp
  8026a9:	29 fb                	sub    %edi,%ebx
  8026ab:	d3 e6                	shl    %cl,%esi
  8026ad:	89 d9                	mov    %ebx,%ecx
  8026af:	d3 ed                	shr    %cl,%ebp
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	d3 e0                	shl    %cl,%eax
  8026b5:	09 ee                	or     %ebp,%esi
  8026b7:	89 d9                	mov    %ebx,%ecx
  8026b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026bd:	89 d5                	mov    %edx,%ebp
  8026bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026c3:	d3 ed                	shr    %cl,%ebp
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	d3 e2                	shl    %cl,%edx
  8026c9:	89 d9                	mov    %ebx,%ecx
  8026cb:	d3 e8                	shr    %cl,%eax
  8026cd:	09 c2                	or     %eax,%edx
  8026cf:	89 d0                	mov    %edx,%eax
  8026d1:	89 ea                	mov    %ebp,%edx
  8026d3:	f7 f6                	div    %esi
  8026d5:	89 d5                	mov    %edx,%ebp
  8026d7:	89 c3                	mov    %eax,%ebx
  8026d9:	f7 64 24 0c          	mull   0xc(%esp)
  8026dd:	39 d5                	cmp    %edx,%ebp
  8026df:	72 10                	jb     8026f1 <__udivdi3+0xc1>
  8026e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	d3 e6                	shl    %cl,%esi
  8026e9:	39 c6                	cmp    %eax,%esi
  8026eb:	73 07                	jae    8026f4 <__udivdi3+0xc4>
  8026ed:	39 d5                	cmp    %edx,%ebp
  8026ef:	75 03                	jne    8026f4 <__udivdi3+0xc4>
  8026f1:	83 eb 01             	sub    $0x1,%ebx
  8026f4:	31 ff                	xor    %edi,%edi
  8026f6:	89 d8                	mov    %ebx,%eax
  8026f8:	89 fa                	mov    %edi,%edx
  8026fa:	83 c4 1c             	add    $0x1c,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	31 ff                	xor    %edi,%edi
  80270a:	31 db                	xor    %ebx,%ebx
  80270c:	89 d8                	mov    %ebx,%eax
  80270e:	89 fa                	mov    %edi,%edx
  802710:	83 c4 1c             	add    $0x1c,%esp
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    
  802718:	90                   	nop
  802719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802720:	89 d8                	mov    %ebx,%eax
  802722:	f7 f7                	div    %edi
  802724:	31 ff                	xor    %edi,%edi
  802726:	89 c3                	mov    %eax,%ebx
  802728:	89 d8                	mov    %ebx,%eax
  80272a:	89 fa                	mov    %edi,%edx
  80272c:	83 c4 1c             	add    $0x1c,%esp
  80272f:	5b                   	pop    %ebx
  802730:	5e                   	pop    %esi
  802731:	5f                   	pop    %edi
  802732:	5d                   	pop    %ebp
  802733:	c3                   	ret    
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	39 ce                	cmp    %ecx,%esi
  80273a:	72 0c                	jb     802748 <__udivdi3+0x118>
  80273c:	31 db                	xor    %ebx,%ebx
  80273e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802742:	0f 87 34 ff ff ff    	ja     80267c <__udivdi3+0x4c>
  802748:	bb 01 00 00 00       	mov    $0x1,%ebx
  80274d:	e9 2a ff ff ff       	jmp    80267c <__udivdi3+0x4c>
  802752:	66 90                	xchg   %ax,%ax
  802754:	66 90                	xchg   %ax,%ax
  802756:	66 90                	xchg   %ax,%ax
  802758:	66 90                	xchg   %ax,%ax
  80275a:	66 90                	xchg   %ax,%ax
  80275c:	66 90                	xchg   %ax,%ax
  80275e:	66 90                	xchg   %ax,%ax

00802760 <__umoddi3>:
  802760:	55                   	push   %ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	53                   	push   %ebx
  802764:	83 ec 1c             	sub    $0x1c,%esp
  802767:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80276b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80276f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802773:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802777:	85 d2                	test   %edx,%edx
  802779:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80277d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802781:	89 f3                	mov    %esi,%ebx
  802783:	89 3c 24             	mov    %edi,(%esp)
  802786:	89 74 24 04          	mov    %esi,0x4(%esp)
  80278a:	75 1c                	jne    8027a8 <__umoddi3+0x48>
  80278c:	39 f7                	cmp    %esi,%edi
  80278e:	76 50                	jbe    8027e0 <__umoddi3+0x80>
  802790:	89 c8                	mov    %ecx,%eax
  802792:	89 f2                	mov    %esi,%edx
  802794:	f7 f7                	div    %edi
  802796:	89 d0                	mov    %edx,%eax
  802798:	31 d2                	xor    %edx,%edx
  80279a:	83 c4 1c             	add    $0x1c,%esp
  80279d:	5b                   	pop    %ebx
  80279e:	5e                   	pop    %esi
  80279f:	5f                   	pop    %edi
  8027a0:	5d                   	pop    %ebp
  8027a1:	c3                   	ret    
  8027a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a8:	39 f2                	cmp    %esi,%edx
  8027aa:	89 d0                	mov    %edx,%eax
  8027ac:	77 52                	ja     802800 <__umoddi3+0xa0>
  8027ae:	0f bd ea             	bsr    %edx,%ebp
  8027b1:	83 f5 1f             	xor    $0x1f,%ebp
  8027b4:	75 5a                	jne    802810 <__umoddi3+0xb0>
  8027b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027ba:	0f 82 e0 00 00 00    	jb     8028a0 <__umoddi3+0x140>
  8027c0:	39 0c 24             	cmp    %ecx,(%esp)
  8027c3:	0f 86 d7 00 00 00    	jbe    8028a0 <__umoddi3+0x140>
  8027c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027d1:	83 c4 1c             	add    $0x1c,%esp
  8027d4:	5b                   	pop    %ebx
  8027d5:	5e                   	pop    %esi
  8027d6:	5f                   	pop    %edi
  8027d7:	5d                   	pop    %ebp
  8027d8:	c3                   	ret    
  8027d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	85 ff                	test   %edi,%edi
  8027e2:	89 fd                	mov    %edi,%ebp
  8027e4:	75 0b                	jne    8027f1 <__umoddi3+0x91>
  8027e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027eb:	31 d2                	xor    %edx,%edx
  8027ed:	f7 f7                	div    %edi
  8027ef:	89 c5                	mov    %eax,%ebp
  8027f1:	89 f0                	mov    %esi,%eax
  8027f3:	31 d2                	xor    %edx,%edx
  8027f5:	f7 f5                	div    %ebp
  8027f7:	89 c8                	mov    %ecx,%eax
  8027f9:	f7 f5                	div    %ebp
  8027fb:	89 d0                	mov    %edx,%eax
  8027fd:	eb 99                	jmp    802798 <__umoddi3+0x38>
  8027ff:	90                   	nop
  802800:	89 c8                	mov    %ecx,%eax
  802802:	89 f2                	mov    %esi,%edx
  802804:	83 c4 1c             	add    $0x1c,%esp
  802807:	5b                   	pop    %ebx
  802808:	5e                   	pop    %esi
  802809:	5f                   	pop    %edi
  80280a:	5d                   	pop    %ebp
  80280b:	c3                   	ret    
  80280c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802810:	8b 34 24             	mov    (%esp),%esi
  802813:	bf 20 00 00 00       	mov    $0x20,%edi
  802818:	89 e9                	mov    %ebp,%ecx
  80281a:	29 ef                	sub    %ebp,%edi
  80281c:	d3 e0                	shl    %cl,%eax
  80281e:	89 f9                	mov    %edi,%ecx
  802820:	89 f2                	mov    %esi,%edx
  802822:	d3 ea                	shr    %cl,%edx
  802824:	89 e9                	mov    %ebp,%ecx
  802826:	09 c2                	or     %eax,%edx
  802828:	89 d8                	mov    %ebx,%eax
  80282a:	89 14 24             	mov    %edx,(%esp)
  80282d:	89 f2                	mov    %esi,%edx
  80282f:	d3 e2                	shl    %cl,%edx
  802831:	89 f9                	mov    %edi,%ecx
  802833:	89 54 24 04          	mov    %edx,0x4(%esp)
  802837:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	89 e9                	mov    %ebp,%ecx
  80283f:	89 c6                	mov    %eax,%esi
  802841:	d3 e3                	shl    %cl,%ebx
  802843:	89 f9                	mov    %edi,%ecx
  802845:	89 d0                	mov    %edx,%eax
  802847:	d3 e8                	shr    %cl,%eax
  802849:	89 e9                	mov    %ebp,%ecx
  80284b:	09 d8                	or     %ebx,%eax
  80284d:	89 d3                	mov    %edx,%ebx
  80284f:	89 f2                	mov    %esi,%edx
  802851:	f7 34 24             	divl   (%esp)
  802854:	89 d6                	mov    %edx,%esi
  802856:	d3 e3                	shl    %cl,%ebx
  802858:	f7 64 24 04          	mull   0x4(%esp)
  80285c:	39 d6                	cmp    %edx,%esi
  80285e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802862:	89 d1                	mov    %edx,%ecx
  802864:	89 c3                	mov    %eax,%ebx
  802866:	72 08                	jb     802870 <__umoddi3+0x110>
  802868:	75 11                	jne    80287b <__umoddi3+0x11b>
  80286a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80286e:	73 0b                	jae    80287b <__umoddi3+0x11b>
  802870:	2b 44 24 04          	sub    0x4(%esp),%eax
  802874:	1b 14 24             	sbb    (%esp),%edx
  802877:	89 d1                	mov    %edx,%ecx
  802879:	89 c3                	mov    %eax,%ebx
  80287b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80287f:	29 da                	sub    %ebx,%edx
  802881:	19 ce                	sbb    %ecx,%esi
  802883:	89 f9                	mov    %edi,%ecx
  802885:	89 f0                	mov    %esi,%eax
  802887:	d3 e0                	shl    %cl,%eax
  802889:	89 e9                	mov    %ebp,%ecx
  80288b:	d3 ea                	shr    %cl,%edx
  80288d:	89 e9                	mov    %ebp,%ecx
  80288f:	d3 ee                	shr    %cl,%esi
  802891:	09 d0                	or     %edx,%eax
  802893:	89 f2                	mov    %esi,%edx
  802895:	83 c4 1c             	add    $0x1c,%esp
  802898:	5b                   	pop    %ebx
  802899:	5e                   	pop    %esi
  80289a:	5f                   	pop    %edi
  80289b:	5d                   	pop    %ebp
  80289c:	c3                   	ret    
  80289d:	8d 76 00             	lea    0x0(%esi),%esi
  8028a0:	29 f9                	sub    %edi,%ecx
  8028a2:	19 d6                	sbb    %edx,%esi
  8028a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028ac:	e9 18 ff ff ff       	jmp    8027c9 <__umoddi3+0x69>
