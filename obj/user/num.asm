
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 a0 20 80 00       	push   $0x8020a0
  800062:	e8 55 17 00 00       	call   8017bc <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 ec 11 00 00       	call   80126d <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 a5 20 80 00       	push   $0x8020a5
  800095:	6a 13                	push   $0x13
  800097:	68 c0 20 80 00       	push   $0x8020c0
  80009c:	e8 a4 01 00 00       	call   800245 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 d6 10 00 00       	call   801193 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 cb 20 80 00       	push   $0x8020cb
  8000d8:	6a 18                	push   $0x18
  8000da:	68 c0 20 80 00       	push   $0x8020c0
  8000df:	e8 61 01 00 00       	call   800245 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 e0 	movl   $0x8020e0,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 e4 20 80 00       	push   $0x8020e4
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 ea 14 00 00       	call   80161e <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 ec 20 80 00       	push   $0x8020ec
  80014b:	6a 27                	push   $0x27
  80014d:	68 c0 20 80 00       	push   $0x8020c0
  800152:	e8 ee 00 00 00       	call   800245 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 ed 0e 00 00       	call   801057 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 ae 00 00 00       	call   80022b <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80018e:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800195:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800198:	e8 cb 0a 00 00       	call   800c68 <sys_getenvid>
  80019d:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	50                   	push   %eax
  8001a3:	68 00 21 80 00       	push   $0x802100
  8001a8:	e8 71 01 00 00       	call   80031e <cprintf>
  8001ad:	8b 3d 08 40 80 00    	mov    0x804008,%edi
  8001b3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8001b8:	83 c4 10             	add    $0x10,%esp
  8001bb:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001c0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8001c5:	89 c1                	mov    %eax,%ecx
  8001c7:	c1 e1 07             	shl    $0x7,%ecx
  8001ca:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8001d1:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8001d4:	39 cb                	cmp    %ecx,%ebx
  8001d6:	0f 44 fa             	cmove  %edx,%edi
  8001d9:	b9 01 00 00 00       	mov    $0x1,%ecx
  8001de:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001e1:	83 c0 01             	add    $0x1,%eax
  8001e4:	81 c2 84 00 00 00    	add    $0x84,%edx
  8001ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8001ef:	75 d4                	jne    8001c5 <libmain+0x40>
  8001f1:	89 f0                	mov    %esi,%eax
  8001f3:	84 c0                	test   %al,%al
  8001f5:	74 06                	je     8001fd <libmain+0x78>
  8001f7:	89 3d 08 40 80 00    	mov    %edi,0x804008
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800201:	7e 0a                	jle    80020d <libmain+0x88>
		binaryname = argv[0];
  800203:	8b 45 0c             	mov    0xc(%ebp),%eax
  800206:	8b 00                	mov    (%eax),%eax
  800208:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 0c             	pushl  0xc(%ebp)
  800213:	ff 75 08             	pushl  0x8(%ebp)
  800216:	e8 d0 fe ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  80021b:	e8 0b 00 00 00       	call   80022b <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5f                   	pop    %edi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800231:	e8 4c 0e 00 00       	call   801082 <close_all>
	sys_env_destroy(0);
  800236:	83 ec 0c             	sub    $0xc,%esp
  800239:	6a 00                	push   $0x0
  80023b:	e8 e7 09 00 00       	call   800c27 <sys_env_destroy>
}
  800240:	83 c4 10             	add    $0x10,%esp
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80024a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024d:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800253:	e8 10 0a 00 00       	call   800c68 <sys_getenvid>
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	ff 75 08             	pushl  0x8(%ebp)
  800261:	56                   	push   %esi
  800262:	50                   	push   %eax
  800263:	68 2c 21 80 00       	push   $0x80212c
  800268:	e8 b1 00 00 00       	call   80031e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	53                   	push   %ebx
  800271:	ff 75 10             	pushl  0x10(%ebp)
  800274:	e8 54 00 00 00       	call   8002cd <vcprintf>
	cprintf("\n");
  800279:	c7 04 24 67 25 80 00 	movl   $0x802567,(%esp)
  800280:	e8 99 00 00 00       	call   80031e <cprintf>
  800285:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800288:	cc                   	int3   
  800289:	eb fd                	jmp    800288 <_panic+0x43>

0080028b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	53                   	push   %ebx
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800295:	8b 13                	mov    (%ebx),%edx
  800297:	8d 42 01             	lea    0x1(%edx),%eax
  80029a:	89 03                	mov    %eax,(%ebx)
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a8:	75 1a                	jne    8002c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	68 ff 00 00 00       	push   $0xff
  8002b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b5:	50                   	push   %eax
  8002b6:	e8 2f 09 00 00       	call   800bea <sys_cputs>
		b->idx = 0;
  8002bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dd:	00 00 00 
	b.cnt = 0;
  8002e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ea:	ff 75 0c             	pushl  0xc(%ebp)
  8002ed:	ff 75 08             	pushl  0x8(%ebp)
  8002f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f6:	50                   	push   %eax
  8002f7:	68 8b 02 80 00       	push   $0x80028b
  8002fc:	e8 54 01 00 00       	call   800455 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80030a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800310:	50                   	push   %eax
  800311:	e8 d4 08 00 00       	call   800bea <sys_cputs>

	return b.cnt;
}
  800316:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800324:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800327:	50                   	push   %eax
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 9d ff ff ff       	call   8002cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 1c             	sub    $0x1c,%esp
  80033b:	89 c7                	mov    %eax,%edi
  80033d:	89 d6                	mov    %edx,%esi
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	8b 55 0c             	mov    0xc(%ebp),%edx
  800345:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800348:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800353:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800356:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800359:	39 d3                	cmp    %edx,%ebx
  80035b:	72 05                	jb     800362 <printnum+0x30>
  80035d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800360:	77 45                	ja     8003a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800362:	83 ec 0c             	sub    $0xc,%esp
  800365:	ff 75 18             	pushl  0x18(%ebp)
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036e:	53                   	push   %ebx
  80036f:	ff 75 10             	pushl  0x10(%ebp)
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	ff 75 e4             	pushl  -0x1c(%ebp)
  800378:	ff 75 e0             	pushl  -0x20(%ebp)
  80037b:	ff 75 dc             	pushl  -0x24(%ebp)
  80037e:	ff 75 d8             	pushl  -0x28(%ebp)
  800381:	e8 8a 1a 00 00       	call   801e10 <__udivdi3>
  800386:	83 c4 18             	add    $0x18,%esp
  800389:	52                   	push   %edx
  80038a:	50                   	push   %eax
  80038b:	89 f2                	mov    %esi,%edx
  80038d:	89 f8                	mov    %edi,%eax
  80038f:	e8 9e ff ff ff       	call   800332 <printnum>
  800394:	83 c4 20             	add    $0x20,%esp
  800397:	eb 18                	jmp    8003b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	ff 75 18             	pushl  0x18(%ebp)
  8003a0:	ff d7                	call   *%edi
  8003a2:	83 c4 10             	add    $0x10,%esp
  8003a5:	eb 03                	jmp    8003aa <printnum+0x78>
  8003a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003aa:	83 eb 01             	sub    $0x1,%ebx
  8003ad:	85 db                	test   %ebx,%ebx
  8003af:	7f e8                	jg     800399 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	56                   	push   %esi
  8003b5:	83 ec 04             	sub    $0x4,%esp
  8003b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003be:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c4:	e8 77 1b 00 00       	call   801f40 <__umoddi3>
  8003c9:	83 c4 14             	add    $0x14,%esp
  8003cc:	0f be 80 4f 21 80 00 	movsbl 0x80214f(%eax),%eax
  8003d3:	50                   	push   %eax
  8003d4:	ff d7                	call   *%edi
}
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003dc:	5b                   	pop    %ebx
  8003dd:	5e                   	pop    %esi
  8003de:	5f                   	pop    %edi
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e4:	83 fa 01             	cmp    $0x1,%edx
  8003e7:	7e 0e                	jle    8003f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	8b 52 04             	mov    0x4(%edx),%edx
  8003f5:	eb 22                	jmp    800419 <getuint+0x38>
	else if (lflag)
  8003f7:	85 d2                	test   %edx,%edx
  8003f9:	74 10                	je     80040b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fb:	8b 10                	mov    (%eax),%edx
  8003fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800400:	89 08                	mov    %ecx,(%eax)
  800402:	8b 02                	mov    (%edx),%eax
  800404:	ba 00 00 00 00       	mov    $0x0,%edx
  800409:	eb 0e                	jmp    800419 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040b:	8b 10                	mov    (%eax),%edx
  80040d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800410:	89 08                	mov    %ecx,(%eax)
  800412:	8b 02                	mov    (%edx),%eax
  800414:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800421:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800425:	8b 10                	mov    (%eax),%edx
  800427:	3b 50 04             	cmp    0x4(%eax),%edx
  80042a:	73 0a                	jae    800436 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042f:	89 08                	mov    %ecx,(%eax)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	88 02                	mov    %al,(%edx)
}
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800441:	50                   	push   %eax
  800442:	ff 75 10             	pushl  0x10(%ebp)
  800445:	ff 75 0c             	pushl  0xc(%ebp)
  800448:	ff 75 08             	pushl  0x8(%ebp)
  80044b:	e8 05 00 00 00       	call   800455 <vprintfmt>
	va_end(ap);
}
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	c9                   	leave  
  800454:	c3                   	ret    

00800455 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	57                   	push   %edi
  800459:	56                   	push   %esi
  80045a:	53                   	push   %ebx
  80045b:	83 ec 2c             	sub    $0x2c,%esp
  80045e:	8b 75 08             	mov    0x8(%ebp),%esi
  800461:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800464:	8b 7d 10             	mov    0x10(%ebp),%edi
  800467:	eb 12                	jmp    80047b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800469:	85 c0                	test   %eax,%eax
  80046b:	0f 84 89 03 00 00    	je     8007fa <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	50                   	push   %eax
  800476:	ff d6                	call   *%esi
  800478:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047b:	83 c7 01             	add    $0x1,%edi
  80047e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800482:	83 f8 25             	cmp    $0x25,%eax
  800485:	75 e2                	jne    800469 <vprintfmt+0x14>
  800487:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800492:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800499:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a5:	eb 07                	jmp    8004ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8d 47 01             	lea    0x1(%edi),%eax
  8004b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b4:	0f b6 07             	movzbl (%edi),%eax
  8004b7:	0f b6 c8             	movzbl %al,%ecx
  8004ba:	83 e8 23             	sub    $0x23,%eax
  8004bd:	3c 55                	cmp    $0x55,%al
  8004bf:	0f 87 1a 03 00 00    	ja     8007df <vprintfmt+0x38a>
  8004c5:	0f b6 c0             	movzbl %al,%eax
  8004c8:	ff 24 85 a0 22 80 00 	jmp    *0x8022a0(,%eax,4)
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d6:	eb d6                	jmp    8004ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004db:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004ea:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ed:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004f0:	83 fa 09             	cmp    $0x9,%edx
  8004f3:	77 39                	ja     80052e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f8:	eb e9                	jmp    8004e3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800500:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050b:	eb 27                	jmp    800534 <vprintfmt+0xdf>
  80050d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800510:	85 c0                	test   %eax,%eax
  800512:	b9 00 00 00 00       	mov    $0x0,%ecx
  800517:	0f 49 c8             	cmovns %eax,%ecx
  80051a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800520:	eb 8c                	jmp    8004ae <vprintfmt+0x59>
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800525:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052c:	eb 80                	jmp    8004ae <vprintfmt+0x59>
  80052e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800531:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800534:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800538:	0f 89 70 ff ff ff    	jns    8004ae <vprintfmt+0x59>
				width = precision, precision = -1;
  80053e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800541:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800544:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054b:	e9 5e ff ff ff       	jmp    8004ae <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800550:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800556:	e9 53 ff ff ff       	jmp    8004ae <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 50 04             	lea    0x4(%eax),%edx
  800561:	89 55 14             	mov    %edx,0x14(%ebp)
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 30                	pushl  (%eax)
  80056a:	ff d6                	call   *%esi
			break;
  80056c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800572:	e9 04 ff ff ff       	jmp    80047b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	99                   	cltd   
  800583:	31 d0                	xor    %edx,%eax
  800585:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800587:	83 f8 0f             	cmp    $0xf,%eax
  80058a:	7f 0b                	jg     800597 <vprintfmt+0x142>
  80058c:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	75 18                	jne    8005af <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800597:	50                   	push   %eax
  800598:	68 67 21 80 00       	push   $0x802167
  80059d:	53                   	push   %ebx
  80059e:	56                   	push   %esi
  80059f:	e8 94 fe ff ff       	call   800438 <printfmt>
  8005a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005aa:	e9 cc fe ff ff       	jmp    80047b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005af:	52                   	push   %edx
  8005b0:	68 35 25 80 00       	push   $0x802535
  8005b5:	53                   	push   %ebx
  8005b6:	56                   	push   %esi
  8005b7:	e8 7c fe ff ff       	call   800438 <printfmt>
  8005bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	e9 b4 fe ff ff       	jmp    80047b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d2:	85 ff                	test   %edi,%edi
  8005d4:	b8 60 21 80 00       	mov    $0x802160,%eax
  8005d9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e0:	0f 8e 94 00 00 00    	jle    80067a <vprintfmt+0x225>
  8005e6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ea:	0f 84 98 00 00 00    	je     800688 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f6:	57                   	push   %edi
  8005f7:	e8 86 02 00 00       	call   800882 <strnlen>
  8005fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ff:	29 c1                	sub    %eax,%ecx
  800601:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800604:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800607:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800611:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800613:	eb 0f                	jmp    800624 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	ff 75 e0             	pushl  -0x20(%ebp)
  80061c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	83 ef 01             	sub    $0x1,%edi
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	85 ff                	test   %edi,%edi
  800626:	7f ed                	jg     800615 <vprintfmt+0x1c0>
  800628:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	b8 00 00 00 00       	mov    $0x0,%eax
  800635:	0f 49 c1             	cmovns %ecx,%eax
  800638:	29 c1                	sub    %eax,%ecx
  80063a:	89 75 08             	mov    %esi,0x8(%ebp)
  80063d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800640:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800643:	89 cb                	mov    %ecx,%ebx
  800645:	eb 4d                	jmp    800694 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800647:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064b:	74 1b                	je     800668 <vprintfmt+0x213>
  80064d:	0f be c0             	movsbl %al,%eax
  800650:	83 e8 20             	sub    $0x20,%eax
  800653:	83 f8 5e             	cmp    $0x5e,%eax
  800656:	76 10                	jbe    800668 <vprintfmt+0x213>
					putch('?', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	6a 3f                	push   $0x3f
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 0d                	jmp    800675 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	ff 75 0c             	pushl  0xc(%ebp)
  80066e:	52                   	push   %edx
  80066f:	ff 55 08             	call   *0x8(%ebp)
  800672:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	83 eb 01             	sub    $0x1,%ebx
  800678:	eb 1a                	jmp    800694 <vprintfmt+0x23f>
  80067a:	89 75 08             	mov    %esi,0x8(%ebp)
  80067d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800680:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800683:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800686:	eb 0c                	jmp    800694 <vprintfmt+0x23f>
  800688:	89 75 08             	mov    %esi,0x8(%ebp)
  80068b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800691:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800694:	83 c7 01             	add    $0x1,%edi
  800697:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069b:	0f be d0             	movsbl %al,%edx
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	74 23                	je     8006c5 <vprintfmt+0x270>
  8006a2:	85 f6                	test   %esi,%esi
  8006a4:	78 a1                	js     800647 <vprintfmt+0x1f2>
  8006a6:	83 ee 01             	sub    $0x1,%esi
  8006a9:	79 9c                	jns    800647 <vprintfmt+0x1f2>
  8006ab:	89 df                	mov    %ebx,%edi
  8006ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b3:	eb 18                	jmp    8006cd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 20                	push   $0x20
  8006bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 08                	jmp    8006cd <vprintfmt+0x278>
  8006c5:	89 df                	mov    %ebx,%edi
  8006c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cd:	85 ff                	test   %edi,%edi
  8006cf:	7f e4                	jg     8006b5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d4:	e9 a2 fd ff ff       	jmp    80047b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d9:	83 fa 01             	cmp    $0x1,%edx
  8006dc:	7e 16                	jle    8006f4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 08             	lea    0x8(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 50 04             	mov    0x4(%eax),%edx
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f2:	eb 32                	jmp    800726 <vprintfmt+0x2d1>
	else if (lflag)
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	74 18                	je     800710 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800706:	89 c1                	mov    %eax,%ecx
  800708:	c1 f9 1f             	sar    $0x1f,%ecx
  80070b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070e:	eb 16                	jmp    800726 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 04             	lea    0x4(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	8b 00                	mov    (%eax),%eax
  80071b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071e:	89 c1                	mov    %eax,%ecx
  800720:	c1 f9 1f             	sar    $0x1f,%ecx
  800723:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800726:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800729:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800731:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800735:	79 74                	jns    8007ab <vprintfmt+0x356>
				putch('-', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 2d                	push   $0x2d
  80073d:	ff d6                	call   *%esi
				num = -(long long) num;
  80073f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800742:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800745:	f7 d8                	neg    %eax
  800747:	83 d2 00             	adc    $0x0,%edx
  80074a:	f7 da                	neg    %edx
  80074c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800754:	eb 55                	jmp    8007ab <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 83 fc ff ff       	call   8003e1 <getuint>
			base = 10;
  80075e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800763:	eb 46                	jmp    8007ab <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800765:	8d 45 14             	lea    0x14(%ebp),%eax
  800768:	e8 74 fc ff ff       	call   8003e1 <getuint>
			base = 8;
  80076d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800772:	eb 37                	jmp    8007ab <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 30                	push   $0x30
  80077a:	ff d6                	call   *%esi
			putch('x', putdat);
  80077c:	83 c4 08             	add    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 78                	push   $0x78
  800782:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 50 04             	lea    0x4(%eax),%edx
  80078a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078d:	8b 00                	mov    (%eax),%eax
  80078f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800794:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079c:	eb 0d                	jmp    8007ab <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 3b fc ff ff       	call   8003e1 <getuint>
			base = 16;
  8007a6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ab:	83 ec 0c             	sub    $0xc,%esp
  8007ae:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b2:	57                   	push   %edi
  8007b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b6:	51                   	push   %ecx
  8007b7:	52                   	push   %edx
  8007b8:	50                   	push   %eax
  8007b9:	89 da                	mov    %ebx,%edx
  8007bb:	89 f0                	mov    %esi,%eax
  8007bd:	e8 70 fb ff ff       	call   800332 <printnum>
			break;
  8007c2:	83 c4 20             	add    $0x20,%esp
  8007c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c8:	e9 ae fc ff ff       	jmp    80047b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	53                   	push   %ebx
  8007d1:	51                   	push   %ecx
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007da:	e9 9c fc ff ff       	jmp    80047b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 25                	push   $0x25
  8007e5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	eb 03                	jmp    8007ef <vprintfmt+0x39a>
  8007ec:	83 ef 01             	sub    $0x1,%edi
  8007ef:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f3:	75 f7                	jne    8007ec <vprintfmt+0x397>
  8007f5:	e9 81 fc ff ff       	jmp    80047b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 18             	sub    $0x18,%esp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800811:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800815:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800818:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 26                	je     800849 <vsnprintf+0x47>
  800823:	85 d2                	test   %edx,%edx
  800825:	7e 22                	jle    800849 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800827:	ff 75 14             	pushl  0x14(%ebp)
  80082a:	ff 75 10             	pushl  0x10(%ebp)
  80082d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800830:	50                   	push   %eax
  800831:	68 1b 04 80 00       	push   $0x80041b
  800836:	e8 1a fc ff ff       	call   800455 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 05                	jmp    80084e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800849:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800859:	50                   	push   %eax
  80085a:	ff 75 10             	pushl  0x10(%ebp)
  80085d:	ff 75 0c             	pushl  0xc(%ebp)
  800860:	ff 75 08             	pushl  0x8(%ebp)
  800863:	e8 9a ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
  800875:	eb 03                	jmp    80087a <strlen+0x10>
		n++;
  800877:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80087a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087e:	75 f7                	jne    800877 <strlen+0xd>
		n++;
	return n;
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	ba 00 00 00 00       	mov    $0x0,%edx
  800890:	eb 03                	jmp    800895 <strnlen+0x13>
		n++;
  800892:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	39 c2                	cmp    %eax,%edx
  800897:	74 08                	je     8008a1 <strnlen+0x1f>
  800899:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089d:	75 f3                	jne    800892 <strnlen+0x10>
  80089f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	83 c2 01             	add    $0x1,%edx
  8008b2:	83 c1 01             	add    $0x1,%ecx
  8008b5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bc:	84 db                	test   %bl,%bl
  8008be:	75 ef                	jne    8008af <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ca:	53                   	push   %ebx
  8008cb:	e8 9a ff ff ff       	call   80086a <strlen>
  8008d0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d3:	ff 75 0c             	pushl  0xc(%ebp)
  8008d6:	01 d8                	add    %ebx,%eax
  8008d8:	50                   	push   %eax
  8008d9:	e8 c5 ff ff ff       	call   8008a3 <strcpy>
	return dst;
}
  8008de:	89 d8                	mov    %ebx,%eax
  8008e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	89 f3                	mov    %esi,%ebx
  8008f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	89 f2                	mov    %esi,%edx
  8008f7:	eb 0f                	jmp    800908 <strncpy+0x23>
		*dst++ = *src;
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	0f b6 01             	movzbl (%ecx),%eax
  8008ff:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800902:	80 39 01             	cmpb   $0x1,(%ecx)
  800905:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800908:	39 da                	cmp    %ebx,%edx
  80090a:	75 ed                	jne    8008f9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090c:	89 f0                	mov    %esi,%eax
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	8b 55 10             	mov    0x10(%ebp),%edx
  800920:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800922:	85 d2                	test   %edx,%edx
  800924:	74 21                	je     800947 <strlcpy+0x35>
  800926:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092a:	89 f2                	mov    %esi,%edx
  80092c:	eb 09                	jmp    800937 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092e:	83 c2 01             	add    $0x1,%edx
  800931:	83 c1 01             	add    $0x1,%ecx
  800934:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800937:	39 c2                	cmp    %eax,%edx
  800939:	74 09                	je     800944 <strlcpy+0x32>
  80093b:	0f b6 19             	movzbl (%ecx),%ebx
  80093e:	84 db                	test   %bl,%bl
  800940:	75 ec                	jne    80092e <strlcpy+0x1c>
  800942:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800944:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800947:	29 f0                	sub    %esi,%eax
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800956:	eb 06                	jmp    80095e <strcmp+0x11>
		p++, q++;
  800958:	83 c1 01             	add    $0x1,%ecx
  80095b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095e:	0f b6 01             	movzbl (%ecx),%eax
  800961:	84 c0                	test   %al,%al
  800963:	74 04                	je     800969 <strcmp+0x1c>
  800965:	3a 02                	cmp    (%edx),%al
  800967:	74 ef                	je     800958 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800969:	0f b6 c0             	movzbl %al,%eax
  80096c:	0f b6 12             	movzbl (%edx),%edx
  80096f:	29 d0                	sub    %edx,%eax
}
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097d:	89 c3                	mov    %eax,%ebx
  80097f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800982:	eb 06                	jmp    80098a <strncmp+0x17>
		n--, p++, q++;
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098a:	39 d8                	cmp    %ebx,%eax
  80098c:	74 15                	je     8009a3 <strncmp+0x30>
  80098e:	0f b6 08             	movzbl (%eax),%ecx
  800991:	84 c9                	test   %cl,%cl
  800993:	74 04                	je     800999 <strncmp+0x26>
  800995:	3a 0a                	cmp    (%edx),%cl
  800997:	74 eb                	je     800984 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800999:	0f b6 00             	movzbl (%eax),%eax
  80099c:	0f b6 12             	movzbl (%edx),%edx
  80099f:	29 d0                	sub    %edx,%eax
  8009a1:	eb 05                	jmp    8009a8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	eb 07                	jmp    8009be <strchr+0x13>
		if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	74 0f                	je     8009ca <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	0f b6 10             	movzbl (%eax),%edx
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f2                	jne    8009b7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d6:	eb 03                	jmp    8009db <strfind+0xf>
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009de:	38 ca                	cmp    %cl,%dl
  8009e0:	74 04                	je     8009e6 <strfind+0x1a>
  8009e2:	84 d2                	test   %dl,%dl
  8009e4:	75 f2                	jne    8009d8 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 36                	je     800a2e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fe:	75 28                	jne    800a28 <memset+0x40>
  800a00:	f6 c1 03             	test   $0x3,%cl
  800a03:	75 23                	jne    800a28 <memset+0x40>
		c &= 0xFF;
  800a05:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a09:	89 d3                	mov    %edx,%ebx
  800a0b:	c1 e3 08             	shl    $0x8,%ebx
  800a0e:	89 d6                	mov    %edx,%esi
  800a10:	c1 e6 18             	shl    $0x18,%esi
  800a13:	89 d0                	mov    %edx,%eax
  800a15:	c1 e0 10             	shl    $0x10,%eax
  800a18:	09 f0                	or     %esi,%eax
  800a1a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1c:	89 d8                	mov    %ebx,%eax
  800a1e:	09 d0                	or     %edx,%eax
  800a20:	c1 e9 02             	shr    $0x2,%ecx
  800a23:	fc                   	cld    
  800a24:	f3 ab                	rep stos %eax,%es:(%edi)
  800a26:	eb 06                	jmp    800a2e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2b:	fc                   	cld    
  800a2c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2e:	89 f8                	mov    %edi,%eax
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a43:	39 c6                	cmp    %eax,%esi
  800a45:	73 35                	jae    800a7c <memmove+0x47>
  800a47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	73 2e                	jae    800a7c <memmove+0x47>
		s += n;
		d += n;
  800a4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a51:	89 d6                	mov    %edx,%esi
  800a53:	09 fe                	or     %edi,%esi
  800a55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5b:	75 13                	jne    800a70 <memmove+0x3b>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	75 0e                	jne    800a70 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a62:	83 ef 04             	sub    $0x4,%edi
  800a65:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a68:	c1 e9 02             	shr    $0x2,%ecx
  800a6b:	fd                   	std    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb 09                	jmp    800a79 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a70:	83 ef 01             	sub    $0x1,%edi
  800a73:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a76:	fd                   	std    
  800a77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a79:	fc                   	cld    
  800a7a:	eb 1d                	jmp    800a99 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	89 f2                	mov    %esi,%edx
  800a7e:	09 c2                	or     %eax,%edx
  800a80:	f6 c2 03             	test   $0x3,%dl
  800a83:	75 0f                	jne    800a94 <memmove+0x5f>
  800a85:	f6 c1 03             	test   $0x3,%cl
  800a88:	75 0a                	jne    800a94 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a8a:	c1 e9 02             	shr    $0x2,%ecx
  800a8d:	89 c7                	mov    %eax,%edi
  800a8f:	fc                   	cld    
  800a90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a92:	eb 05                	jmp    800a99 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	fc                   	cld    
  800a97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa0:	ff 75 10             	pushl  0x10(%ebp)
  800aa3:	ff 75 0c             	pushl  0xc(%ebp)
  800aa6:	ff 75 08             	pushl  0x8(%ebp)
  800aa9:	e8 87 ff ff ff       	call   800a35 <memmove>
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abb:	89 c6                	mov    %eax,%esi
  800abd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac0:	eb 1a                	jmp    800adc <memcmp+0x2c>
		if (*s1 != *s2)
  800ac2:	0f b6 08             	movzbl (%eax),%ecx
  800ac5:	0f b6 1a             	movzbl (%edx),%ebx
  800ac8:	38 d9                	cmp    %bl,%cl
  800aca:	74 0a                	je     800ad6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acc:	0f b6 c1             	movzbl %cl,%eax
  800acf:	0f b6 db             	movzbl %bl,%ebx
  800ad2:	29 d8                	sub    %ebx,%eax
  800ad4:	eb 0f                	jmp    800ae5 <memcmp+0x35>
		s1++, s2++;
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adc:	39 f0                	cmp    %esi,%eax
  800ade:	75 e2                	jne    800ac2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	53                   	push   %ebx
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800af0:	89 c1                	mov    %eax,%ecx
  800af2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af9:	eb 0a                	jmp    800b05 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afb:	0f b6 10             	movzbl (%eax),%edx
  800afe:	39 da                	cmp    %ebx,%edx
  800b00:	74 07                	je     800b09 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	39 c8                	cmp    %ecx,%eax
  800b07:	72 f2                	jb     800afb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	eb 03                	jmp    800b1d <strtol+0x11>
		s++;
  800b1a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1d:	0f b6 01             	movzbl (%ecx),%eax
  800b20:	3c 20                	cmp    $0x20,%al
  800b22:	74 f6                	je     800b1a <strtol+0xe>
  800b24:	3c 09                	cmp    $0x9,%al
  800b26:	74 f2                	je     800b1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b28:	3c 2b                	cmp    $0x2b,%al
  800b2a:	75 0a                	jne    800b36 <strtol+0x2a>
		s++;
  800b2c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b34:	eb 11                	jmp    800b47 <strtol+0x3b>
  800b36:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3b:	3c 2d                	cmp    $0x2d,%al
  800b3d:	75 08                	jne    800b47 <strtol+0x3b>
		s++, neg = 1;
  800b3f:	83 c1 01             	add    $0x1,%ecx
  800b42:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4d:	75 15                	jne    800b64 <strtol+0x58>
  800b4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b52:	75 10                	jne    800b64 <strtol+0x58>
  800b54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b58:	75 7c                	jne    800bd6 <strtol+0xca>
		s += 2, base = 16;
  800b5a:	83 c1 02             	add    $0x2,%ecx
  800b5d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b62:	eb 16                	jmp    800b7a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	75 12                	jne    800b7a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b68:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	75 08                	jne    800b7a <strtol+0x6e>
		s++, base = 8;
  800b72:	83 c1 01             	add    $0x1,%ecx
  800b75:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b82:	0f b6 11             	movzbl (%ecx),%edx
  800b85:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b88:	89 f3                	mov    %esi,%ebx
  800b8a:	80 fb 09             	cmp    $0x9,%bl
  800b8d:	77 08                	ja     800b97 <strtol+0x8b>
			dig = *s - '0';
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	83 ea 30             	sub    $0x30,%edx
  800b95:	eb 22                	jmp    800bb9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 19             	cmp    $0x19,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 57             	sub    $0x57,%edx
  800ba7:	eb 10                	jmp    800bb9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 16                	ja     800bc9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbc:	7d 0b                	jge    800bc9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c1 01             	add    $0x1,%ecx
  800bc1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc7:	eb b9                	jmp    800b82 <strtol+0x76>

	if (endptr)
  800bc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcd:	74 0d                	je     800bdc <strtol+0xd0>
		*endptr = (char *) s;
  800bcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd2:	89 0e                	mov    %ecx,(%esi)
  800bd4:	eb 06                	jmp    800bdc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd6:	85 db                	test   %ebx,%ebx
  800bd8:	74 98                	je     800b72 <strtol+0x66>
  800bda:	eb 9e                	jmp    800b7a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bdc:	89 c2                	mov    %eax,%edx
  800bde:	f7 da                	neg    %edx
  800be0:	85 ff                	test   %edi,%edi
  800be2:	0f 45 c2             	cmovne %edx,%eax
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 c3                	mov    %eax,%ebx
  800bfd:	89 c7                	mov    %eax,%edi
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 01 00 00 00       	mov    $0x1,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c35:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 cb                	mov    %ecx,%ebx
  800c3f:	89 cf                	mov    %ecx,%edi
  800c41:	89 ce                	mov    %ecx,%esi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 03                	push   $0x3
  800c4f:	68 5f 24 80 00       	push   $0x80245f
  800c54:	6a 23                	push   $0x23
  800c56:	68 7c 24 80 00       	push   $0x80247c
  800c5b:	e8 e5 f5 ff ff       	call   800245 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	b8 02 00 00 00       	mov    $0x2,%eax
  800c78:	89 d1                	mov    %edx,%ecx
  800c7a:	89 d3                	mov    %edx,%ebx
  800c7c:	89 d7                	mov    %edx,%edi
  800c7e:	89 d6                	mov    %edx,%esi
  800c80:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_yield>:

void
sys_yield(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	89 f7                	mov    %esi,%edi
  800cc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 04                	push   $0x4
  800cd0:	68 5f 24 80 00       	push   $0x80245f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 7c 24 80 00       	push   $0x80247c
  800cdc:	e8 64 f5 ff ff       	call   800245 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d03:	8b 75 18             	mov    0x18(%ebp),%esi
  800d06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 05                	push   $0x5
  800d12:	68 5f 24 80 00       	push   $0x80245f
  800d17:	6a 23                	push   $0x23
  800d19:	68 7c 24 80 00       	push   $0x80247c
  800d1e:	e8 22 f5 ff ff       	call   800245 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d39:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 df                	mov    %ebx,%edi
  800d46:	89 de                	mov    %ebx,%esi
  800d48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 06                	push   $0x6
  800d54:	68 5f 24 80 00       	push   $0x80245f
  800d59:	6a 23                	push   $0x23
  800d5b:	68 7c 24 80 00       	push   $0x80247c
  800d60:	e8 e0 f4 ff ff       	call   800245 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 08                	push   $0x8
  800d96:	68 5f 24 80 00       	push   $0x80245f
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 7c 24 80 00       	push   $0x80247c
  800da2:	e8 9e f4 ff ff       	call   800245 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbd:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	89 df                	mov    %ebx,%edi
  800dca:	89 de                	mov    %ebx,%esi
  800dcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 17                	jle    800de9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	50                   	push   %eax
  800dd6:	6a 09                	push   $0x9
  800dd8:	68 5f 24 80 00       	push   $0x80245f
  800ddd:	6a 23                	push   $0x23
  800ddf:	68 7c 24 80 00       	push   $0x80247c
  800de4:	e8 5c f4 ff ff       	call   800245 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 df                	mov    %ebx,%edi
  800e0c:	89 de                	mov    %ebx,%esi
  800e0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e10:	85 c0                	test   %eax,%eax
  800e12:	7e 17                	jle    800e2b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	50                   	push   %eax
  800e18:	6a 0a                	push   $0xa
  800e1a:	68 5f 24 80 00       	push   $0x80245f
  800e1f:	6a 23                	push   $0x23
  800e21:	68 7c 24 80 00       	push   $0x80247c
  800e26:	e8 1a f4 ff ff       	call   800245 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e39:	be 00 00 00 00       	mov    $0x0,%esi
  800e3e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e64:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 cb                	mov    %ecx,%ebx
  800e6e:	89 cf                	mov    %ecx,%edi
  800e70:	89 ce                	mov    %ecx,%esi
  800e72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e74:	85 c0                	test   %eax,%eax
  800e76:	7e 17                	jle    800e8f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	50                   	push   %eax
  800e7c:	6a 0d                	push   $0xd
  800e7e:	68 5f 24 80 00       	push   $0x80245f
  800e83:	6a 23                	push   $0x23
  800e85:	68 7c 24 80 00       	push   $0x80247c
  800e8a:	e8 b6 f3 ff ff       	call   800245 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	89 cb                	mov    %ecx,%ebx
  800eac:	89 cf                	mov    %ecx,%edi
  800eae:	89 ce                	mov    %ecx,%esi
  800eb0:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebd:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec2:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee9:	89 c2                	mov    %eax,%edx
  800eeb:	c1 ea 16             	shr    $0x16,%edx
  800eee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef5:	f6 c2 01             	test   $0x1,%dl
  800ef8:	74 11                	je     800f0b <fd_alloc+0x2d>
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	c1 ea 0c             	shr    $0xc,%edx
  800eff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f06:	f6 c2 01             	test   $0x1,%dl
  800f09:	75 09                	jne    800f14 <fd_alloc+0x36>
			*fd_store = fd;
  800f0b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f12:	eb 17                	jmp    800f2b <fd_alloc+0x4d>
  800f14:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f19:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f1e:	75 c9                	jne    800ee9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f20:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f26:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f33:	83 f8 1f             	cmp    $0x1f,%eax
  800f36:	77 36                	ja     800f6e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f38:	c1 e0 0c             	shl    $0xc,%eax
  800f3b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f40:	89 c2                	mov    %eax,%edx
  800f42:	c1 ea 16             	shr    $0x16,%edx
  800f45:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4c:	f6 c2 01             	test   $0x1,%dl
  800f4f:	74 24                	je     800f75 <fd_lookup+0x48>
  800f51:	89 c2                	mov    %eax,%edx
  800f53:	c1 ea 0c             	shr    $0xc,%edx
  800f56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5d:	f6 c2 01             	test   $0x1,%dl
  800f60:	74 1a                	je     800f7c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f65:	89 02                	mov    %eax,(%edx)
	return 0;
  800f67:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6c:	eb 13                	jmp    800f81 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f73:	eb 0c                	jmp    800f81 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7a:	eb 05                	jmp    800f81 <fd_lookup+0x54>
  800f7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8c:	ba 0c 25 80 00       	mov    $0x80250c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f91:	eb 13                	jmp    800fa6 <dev_lookup+0x23>
  800f93:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f96:	39 08                	cmp    %ecx,(%eax)
  800f98:	75 0c                	jne    800fa6 <dev_lookup+0x23>
			*dev = devtab[i];
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa4:	eb 2e                	jmp    800fd4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fa6:	8b 02                	mov    (%edx),%eax
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	75 e7                	jne    800f93 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fac:	a1 08 40 80 00       	mov    0x804008,%eax
  800fb1:	8b 40 50             	mov    0x50(%eax),%eax
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	51                   	push   %ecx
  800fb8:	50                   	push   %eax
  800fb9:	68 8c 24 80 00       	push   $0x80248c
  800fbe:	e8 5b f3 ff ff       	call   80031e <cprintf>
	*dev = 0;
  800fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
  800fdb:	83 ec 10             	sub    $0x10,%esp
  800fde:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fee:	c1 e8 0c             	shr    $0xc,%eax
  800ff1:	50                   	push   %eax
  800ff2:	e8 36 ff ff ff       	call   800f2d <fd_lookup>
  800ff7:	83 c4 08             	add    $0x8,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	78 05                	js     801003 <fd_close+0x2d>
	    || fd != fd2)
  800ffe:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801001:	74 0c                	je     80100f <fd_close+0x39>
		return (must_exist ? r : 0);
  801003:	84 db                	test   %bl,%bl
  801005:	ba 00 00 00 00       	mov    $0x0,%edx
  80100a:	0f 44 c2             	cmove  %edx,%eax
  80100d:	eb 41                	jmp    801050 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801015:	50                   	push   %eax
  801016:	ff 36                	pushl  (%esi)
  801018:	e8 66 ff ff ff       	call   800f83 <dev_lookup>
  80101d:	89 c3                	mov    %eax,%ebx
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	78 1a                	js     801040 <fd_close+0x6a>
		if (dev->dev_close)
  801026:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801029:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80102c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801031:	85 c0                	test   %eax,%eax
  801033:	74 0b                	je     801040 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	56                   	push   %esi
  801039:	ff d0                	call   *%eax
  80103b:	89 c3                	mov    %eax,%ebx
  80103d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801040:	83 ec 08             	sub    $0x8,%esp
  801043:	56                   	push   %esi
  801044:	6a 00                	push   $0x0
  801046:	e8 e0 fc ff ff       	call   800d2b <sys_page_unmap>
	return r;
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	89 d8                	mov    %ebx,%eax
}
  801050:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	ff 75 08             	pushl  0x8(%ebp)
  801064:	e8 c4 fe ff ff       	call   800f2d <fd_lookup>
  801069:	83 c4 08             	add    $0x8,%esp
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 10                	js     801080 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	6a 01                	push   $0x1
  801075:	ff 75 f4             	pushl  -0xc(%ebp)
  801078:	e8 59 ff ff ff       	call   800fd6 <fd_close>
  80107d:	83 c4 10             	add    $0x10,%esp
}
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <close_all>:

void
close_all(void)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	53                   	push   %ebx
  801086:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801089:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	53                   	push   %ebx
  801092:	e8 c0 ff ff ff       	call   801057 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801097:	83 c3 01             	add    $0x1,%ebx
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	83 fb 20             	cmp    $0x20,%ebx
  8010a0:	75 ec                	jne    80108e <close_all+0xc>
		close(i);
}
  8010a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a5:	c9                   	leave  
  8010a6:	c3                   	ret    

008010a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 2c             	sub    $0x2c,%esp
  8010b0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	ff 75 08             	pushl  0x8(%ebp)
  8010ba:	e8 6e fe ff ff       	call   800f2d <fd_lookup>
  8010bf:	83 c4 08             	add    $0x8,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	0f 88 c1 00 00 00    	js     80118b <dup+0xe4>
		return r;
	close(newfdnum);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	56                   	push   %esi
  8010ce:	e8 84 ff ff ff       	call   801057 <close>

	newfd = INDEX2FD(newfdnum);
  8010d3:	89 f3                	mov    %esi,%ebx
  8010d5:	c1 e3 0c             	shl    $0xc,%ebx
  8010d8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010de:	83 c4 04             	add    $0x4,%esp
  8010e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e4:	e8 de fd ff ff       	call   800ec7 <fd2data>
  8010e9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010eb:	89 1c 24             	mov    %ebx,(%esp)
  8010ee:	e8 d4 fd ff ff       	call   800ec7 <fd2data>
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f9:	89 f8                	mov    %edi,%eax
  8010fb:	c1 e8 16             	shr    $0x16,%eax
  8010fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801105:	a8 01                	test   $0x1,%al
  801107:	74 37                	je     801140 <dup+0x99>
  801109:	89 f8                	mov    %edi,%eax
  80110b:	c1 e8 0c             	shr    $0xc,%eax
  80110e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801115:	f6 c2 01             	test   $0x1,%dl
  801118:	74 26                	je     801140 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80111a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	25 07 0e 00 00       	and    $0xe07,%eax
  801129:	50                   	push   %eax
  80112a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112d:	6a 00                	push   $0x0
  80112f:	57                   	push   %edi
  801130:	6a 00                	push   $0x0
  801132:	e8 b2 fb ff ff       	call   800ce9 <sys_page_map>
  801137:	89 c7                	mov    %eax,%edi
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 2e                	js     80116e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801140:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801143:	89 d0                	mov    %edx,%eax
  801145:	c1 e8 0c             	shr    $0xc,%eax
  801148:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	25 07 0e 00 00       	and    $0xe07,%eax
  801157:	50                   	push   %eax
  801158:	53                   	push   %ebx
  801159:	6a 00                	push   $0x0
  80115b:	52                   	push   %edx
  80115c:	6a 00                	push   $0x0
  80115e:	e8 86 fb ff ff       	call   800ce9 <sys_page_map>
  801163:	89 c7                	mov    %eax,%edi
  801165:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801168:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80116a:	85 ff                	test   %edi,%edi
  80116c:	79 1d                	jns    80118b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	53                   	push   %ebx
  801172:	6a 00                	push   $0x0
  801174:	e8 b2 fb ff ff       	call   800d2b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801179:	83 c4 08             	add    $0x8,%esp
  80117c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80117f:	6a 00                	push   $0x0
  801181:	e8 a5 fb ff ff       	call   800d2b <sys_page_unmap>
	return r;
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	89 f8                	mov    %edi,%eax
}
  80118b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	53                   	push   %ebx
  801197:	83 ec 14             	sub    $0x14,%esp
  80119a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	53                   	push   %ebx
  8011a2:	e8 86 fd ff ff       	call   800f2d <fd_lookup>
  8011a7:	83 c4 08             	add    $0x8,%esp
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	78 6d                	js     80121d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ba:	ff 30                	pushl  (%eax)
  8011bc:	e8 c2 fd ff ff       	call   800f83 <dev_lookup>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 4c                	js     801214 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011cb:	8b 42 08             	mov    0x8(%edx),%eax
  8011ce:	83 e0 03             	and    $0x3,%eax
  8011d1:	83 f8 01             	cmp    $0x1,%eax
  8011d4:	75 21                	jne    8011f7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d6:	a1 08 40 80 00       	mov    0x804008,%eax
  8011db:	8b 40 50             	mov    0x50(%eax),%eax
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	53                   	push   %ebx
  8011e2:	50                   	push   %eax
  8011e3:	68 d0 24 80 00       	push   $0x8024d0
  8011e8:	e8 31 f1 ff ff       	call   80031e <cprintf>
		return -E_INVAL;
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f5:	eb 26                	jmp    80121d <read+0x8a>
	}
	if (!dev->dev_read)
  8011f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fa:	8b 40 08             	mov    0x8(%eax),%eax
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	74 17                	je     801218 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	ff 75 10             	pushl  0x10(%ebp)
  801207:	ff 75 0c             	pushl  0xc(%ebp)
  80120a:	52                   	push   %edx
  80120b:	ff d0                	call   *%eax
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	eb 09                	jmp    80121d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801214:	89 c2                	mov    %eax,%edx
  801216:	eb 05                	jmp    80121d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801218:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80121d:	89 d0                	mov    %edx,%eax
  80121f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801222:	c9                   	leave  
  801223:	c3                   	ret    

00801224 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	57                   	push   %edi
  801228:	56                   	push   %esi
  801229:	53                   	push   %ebx
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801230:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801233:	bb 00 00 00 00       	mov    $0x0,%ebx
  801238:	eb 21                	jmp    80125b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	89 f0                	mov    %esi,%eax
  80123f:	29 d8                	sub    %ebx,%eax
  801241:	50                   	push   %eax
  801242:	89 d8                	mov    %ebx,%eax
  801244:	03 45 0c             	add    0xc(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	57                   	push   %edi
  801249:	e8 45 ff ff ff       	call   801193 <read>
		if (m < 0)
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 10                	js     801265 <readn+0x41>
			return m;
		if (m == 0)
  801255:	85 c0                	test   %eax,%eax
  801257:	74 0a                	je     801263 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801259:	01 c3                	add    %eax,%ebx
  80125b:	39 f3                	cmp    %esi,%ebx
  80125d:	72 db                	jb     80123a <readn+0x16>
  80125f:	89 d8                	mov    %ebx,%eax
  801261:	eb 02                	jmp    801265 <readn+0x41>
  801263:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	53                   	push   %ebx
  801271:	83 ec 14             	sub    $0x14,%esp
  801274:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801277:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	53                   	push   %ebx
  80127c:	e8 ac fc ff ff       	call   800f2d <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	89 c2                	mov    %eax,%edx
  801286:	85 c0                	test   %eax,%eax
  801288:	78 68                	js     8012f2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801294:	ff 30                	pushl  (%eax)
  801296:	e8 e8 fc ff ff       	call   800f83 <dev_lookup>
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 47                	js     8012e9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a9:	75 21                	jne    8012cc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8012b0:	8b 40 50             	mov    0x50(%eax),%eax
  8012b3:	83 ec 04             	sub    $0x4,%esp
  8012b6:	53                   	push   %ebx
  8012b7:	50                   	push   %eax
  8012b8:	68 ec 24 80 00       	push   $0x8024ec
  8012bd:	e8 5c f0 ff ff       	call   80031e <cprintf>
		return -E_INVAL;
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ca:	eb 26                	jmp    8012f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d2:	85 d2                	test   %edx,%edx
  8012d4:	74 17                	je     8012ed <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d6:	83 ec 04             	sub    $0x4,%esp
  8012d9:	ff 75 10             	pushl  0x10(%ebp)
  8012dc:	ff 75 0c             	pushl  0xc(%ebp)
  8012df:	50                   	push   %eax
  8012e0:	ff d2                	call   *%edx
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	eb 09                	jmp    8012f2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	eb 05                	jmp    8012f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012f2:	89 d0                	mov    %edx,%eax
  8012f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ff:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	ff 75 08             	pushl  0x8(%ebp)
  801306:	e8 22 fc ff ff       	call   800f2d <fd_lookup>
  80130b:	83 c4 08             	add    $0x8,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 0e                	js     801320 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801312:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801315:	8b 55 0c             	mov    0xc(%ebp),%edx
  801318:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	53                   	push   %ebx
  801326:	83 ec 14             	sub    $0x14,%esp
  801329:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	53                   	push   %ebx
  801331:	e8 f7 fb ff ff       	call   800f2d <fd_lookup>
  801336:	83 c4 08             	add    $0x8,%esp
  801339:	89 c2                	mov    %eax,%edx
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 65                	js     8013a4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	ff 30                	pushl  (%eax)
  80134b:	e8 33 fc ff ff       	call   800f83 <dev_lookup>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 44                	js     80139b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801357:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135e:	75 21                	jne    801381 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801360:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801365:	8b 40 50             	mov    0x50(%eax),%eax
  801368:	83 ec 04             	sub    $0x4,%esp
  80136b:	53                   	push   %ebx
  80136c:	50                   	push   %eax
  80136d:	68 ac 24 80 00       	push   $0x8024ac
  801372:	e8 a7 ef ff ff       	call   80031e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80137f:	eb 23                	jmp    8013a4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801381:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801384:	8b 52 18             	mov    0x18(%edx),%edx
  801387:	85 d2                	test   %edx,%edx
  801389:	74 14                	je     80139f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	ff 75 0c             	pushl  0xc(%ebp)
  801391:	50                   	push   %eax
  801392:	ff d2                	call   *%edx
  801394:	89 c2                	mov    %eax,%edx
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	eb 09                	jmp    8013a4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139b:	89 c2                	mov    %eax,%edx
  80139d:	eb 05                	jmp    8013a4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80139f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013a4:	89 d0                	mov    %edx,%eax
  8013a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 14             	sub    $0x14,%esp
  8013b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	ff 75 08             	pushl  0x8(%ebp)
  8013bc:	e8 6c fb ff ff       	call   800f2d <fd_lookup>
  8013c1:	83 c4 08             	add    $0x8,%esp
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 58                	js     801422 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	ff 30                	pushl  (%eax)
  8013d6:	e8 a8 fb ff ff       	call   800f83 <dev_lookup>
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 37                	js     801419 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e9:	74 32                	je     80141d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013eb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ee:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f5:	00 00 00 
	stat->st_isdir = 0;
  8013f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ff:	00 00 00 
	stat->st_dev = dev;
  801402:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	53                   	push   %ebx
  80140c:	ff 75 f0             	pushl  -0x10(%ebp)
  80140f:	ff 50 14             	call   *0x14(%eax)
  801412:	89 c2                	mov    %eax,%edx
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	eb 09                	jmp    801422 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801419:	89 c2                	mov    %eax,%edx
  80141b:	eb 05                	jmp    801422 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80141d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801422:	89 d0                	mov    %edx,%eax
  801424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	56                   	push   %esi
  80142d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	6a 00                	push   $0x0
  801433:	ff 75 08             	pushl  0x8(%ebp)
  801436:	e8 e3 01 00 00       	call   80161e <open>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 1b                	js     80145f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	50                   	push   %eax
  80144b:	e8 5b ff ff ff       	call   8013ab <fstat>
  801450:	89 c6                	mov    %eax,%esi
	close(fd);
  801452:	89 1c 24             	mov    %ebx,(%esp)
  801455:	e8 fd fb ff ff       	call   801057 <close>
	return r;
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	89 f0                	mov    %esi,%eax
}
  80145f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801462:	5b                   	pop    %ebx
  801463:	5e                   	pop    %esi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	89 c6                	mov    %eax,%esi
  80146d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80146f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801476:	75 12                	jne    80148a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	6a 01                	push   $0x1
  80147d:	e8 06 09 00 00       	call   801d88 <ipc_find_env>
  801482:	a3 04 40 80 00       	mov    %eax,0x804004
  801487:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80148a:	6a 07                	push   $0x7
  80148c:	68 00 50 80 00       	push   $0x805000
  801491:	56                   	push   %esi
  801492:	ff 35 04 40 80 00    	pushl  0x804004
  801498:	e8 89 08 00 00       	call   801d26 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80149d:	83 c4 0c             	add    $0xc,%esp
  8014a0:	6a 00                	push   $0x0
  8014a2:	53                   	push   %ebx
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 07 08 00 00       	call   801cb1 <ipc_recv>
}
  8014aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d4:	e8 8d ff ff ff       	call   801466 <fsipc>
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8014f6:	e8 6b ff ff ff       	call   801466 <fsipc>
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
  80150a:	8b 40 0c             	mov    0xc(%eax),%eax
  80150d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	b8 05 00 00 00       	mov    $0x5,%eax
  80151c:	e8 45 ff ff ff       	call   801466 <fsipc>
  801521:	85 c0                	test   %eax,%eax
  801523:	78 2c                	js     801551 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	68 00 50 80 00       	push   $0x805000
  80152d:	53                   	push   %ebx
  80152e:	e8 70 f3 ff ff       	call   8008a3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801533:	a1 80 50 80 00       	mov    0x805080,%eax
  801538:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80153e:	a1 84 50 80 00       	mov    0x805084,%eax
  801543:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 0c             	sub    $0xc,%esp
  80155c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80155f:	8b 55 08             	mov    0x8(%ebp),%edx
  801562:	8b 52 0c             	mov    0xc(%edx),%edx
  801565:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80156b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801570:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801575:	0f 47 c2             	cmova  %edx,%eax
  801578:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80157d:	50                   	push   %eax
  80157e:	ff 75 0c             	pushl  0xc(%ebp)
  801581:	68 08 50 80 00       	push   $0x805008
  801586:	e8 aa f4 ff ff       	call   800a35 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80158b:	ba 00 00 00 00       	mov    $0x0,%edx
  801590:	b8 04 00 00 00       	mov    $0x4,%eax
  801595:	e8 cc fe ff ff       	call   801466 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015af:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	b8 03 00 00 00       	mov    $0x3,%eax
  8015bf:	e8 a2 fe ff ff       	call   801466 <fsipc>
  8015c4:	89 c3                	mov    %eax,%ebx
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 4b                	js     801615 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015ca:	39 c6                	cmp    %eax,%esi
  8015cc:	73 16                	jae    8015e4 <devfile_read+0x48>
  8015ce:	68 1c 25 80 00       	push   $0x80251c
  8015d3:	68 23 25 80 00       	push   $0x802523
  8015d8:	6a 7c                	push   $0x7c
  8015da:	68 38 25 80 00       	push   $0x802538
  8015df:	e8 61 ec ff ff       	call   800245 <_panic>
	assert(r <= PGSIZE);
  8015e4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e9:	7e 16                	jle    801601 <devfile_read+0x65>
  8015eb:	68 43 25 80 00       	push   $0x802543
  8015f0:	68 23 25 80 00       	push   $0x802523
  8015f5:	6a 7d                	push   $0x7d
  8015f7:	68 38 25 80 00       	push   $0x802538
  8015fc:	e8 44 ec ff ff       	call   800245 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801601:	83 ec 04             	sub    $0x4,%esp
  801604:	50                   	push   %eax
  801605:	68 00 50 80 00       	push   $0x805000
  80160a:	ff 75 0c             	pushl  0xc(%ebp)
  80160d:	e8 23 f4 ff ff       	call   800a35 <memmove>
	return r;
  801612:	83 c4 10             	add    $0x10,%esp
}
  801615:	89 d8                	mov    %ebx,%eax
  801617:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	53                   	push   %ebx
  801622:	83 ec 20             	sub    $0x20,%esp
  801625:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801628:	53                   	push   %ebx
  801629:	e8 3c f2 ff ff       	call   80086a <strlen>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801636:	7f 67                	jg     80169f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	e8 9a f8 ff ff       	call   800ede <fd_alloc>
  801644:	83 c4 10             	add    $0x10,%esp
		return r;
  801647:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 57                	js     8016a4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	53                   	push   %ebx
  801651:	68 00 50 80 00       	push   $0x805000
  801656:	e8 48 f2 ff ff       	call   8008a3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80165b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801663:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801666:	b8 01 00 00 00       	mov    $0x1,%eax
  80166b:	e8 f6 fd ff ff       	call   801466 <fsipc>
  801670:	89 c3                	mov    %eax,%ebx
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	79 14                	jns    80168d <open+0x6f>
		fd_close(fd, 0);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	6a 00                	push   $0x0
  80167e:	ff 75 f4             	pushl  -0xc(%ebp)
  801681:	e8 50 f9 ff ff       	call   800fd6 <fd_close>
		return r;
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	89 da                	mov    %ebx,%edx
  80168b:	eb 17                	jmp    8016a4 <open+0x86>
	}

	return fd2num(fd);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	ff 75 f4             	pushl  -0xc(%ebp)
  801693:	e8 1f f8 ff ff       	call   800eb7 <fd2num>
  801698:	89 c2                	mov    %eax,%edx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	eb 05                	jmp    8016a4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80169f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a4:	89 d0                	mov    %edx,%eax
  8016a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8016bb:	e8 a6 fd ff ff       	call   801466 <fsipc>
}
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016c2:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016c6:	7e 37                	jle    8016ff <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016d1:	ff 70 04             	pushl  0x4(%eax)
  8016d4:	8d 40 10             	lea    0x10(%eax),%eax
  8016d7:	50                   	push   %eax
  8016d8:	ff 33                	pushl  (%ebx)
  8016da:	e8 8e fb ff ff       	call   80126d <write>
		if (result > 0)
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	7e 03                	jle    8016e9 <writebuf+0x27>
			b->result += result;
  8016e6:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016e9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016ec:	74 0d                	je     8016fb <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f5:	0f 4f c2             	cmovg  %edx,%eax
  8016f8:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fe:	c9                   	leave  
  8016ff:	f3 c3                	repz ret 

00801701 <putch>:

static void
putch(int ch, void *thunk)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	53                   	push   %ebx
  801705:	83 ec 04             	sub    $0x4,%esp
  801708:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80170b:	8b 53 04             	mov    0x4(%ebx),%edx
  80170e:	8d 42 01             	lea    0x1(%edx),%eax
  801711:	89 43 04             	mov    %eax,0x4(%ebx)
  801714:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801717:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80171b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801720:	75 0e                	jne    801730 <putch+0x2f>
		writebuf(b);
  801722:	89 d8                	mov    %ebx,%eax
  801724:	e8 99 ff ff ff       	call   8016c2 <writebuf>
		b->idx = 0;
  801729:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801730:	83 c4 04             	add    $0x4,%esp
  801733:	5b                   	pop    %ebx
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801748:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80174f:	00 00 00 
	b.result = 0;
  801752:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801759:	00 00 00 
	b.error = 1;
  80175c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801763:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801766:	ff 75 10             	pushl  0x10(%ebp)
  801769:	ff 75 0c             	pushl  0xc(%ebp)
  80176c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801772:	50                   	push   %eax
  801773:	68 01 17 80 00       	push   $0x801701
  801778:	e8 d8 ec ff ff       	call   800455 <vprintfmt>
	if (b.idx > 0)
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801787:	7e 0b                	jle    801794 <vfprintf+0x5e>
		writebuf(&b);
  801789:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80178f:	e8 2e ff ff ff       	call   8016c2 <writebuf>

	return (b.result ? b.result : b.error);
  801794:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80179a:	85 c0                	test   %eax,%eax
  80179c:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    

008017a5 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ab:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017ae:	50                   	push   %eax
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	ff 75 08             	pushl  0x8(%ebp)
  8017b5:	e8 7c ff ff ff       	call   801736 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <printf>:

int
printf(const char *fmt, ...)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017c5:	50                   	push   %eax
  8017c6:	ff 75 08             	pushl  0x8(%ebp)
  8017c9:	6a 01                	push   $0x1
  8017cb:	e8 66 ff ff ff       	call   801736 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	ff 75 08             	pushl  0x8(%ebp)
  8017e0:	e8 e2 f6 ff ff       	call   800ec7 <fd2data>
  8017e5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017e7:	83 c4 08             	add    $0x8,%esp
  8017ea:	68 4f 25 80 00       	push   $0x80254f
  8017ef:	53                   	push   %ebx
  8017f0:	e8 ae f0 ff ff       	call   8008a3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017f5:	8b 46 04             	mov    0x4(%esi),%eax
  8017f8:	2b 06                	sub    (%esi),%eax
  8017fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801800:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801807:	00 00 00 
	stat->st_dev = &devpipe;
  80180a:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801811:	30 80 00 
	return 0;
}
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
  801819:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80182a:	53                   	push   %ebx
  80182b:	6a 00                	push   $0x0
  80182d:	e8 f9 f4 ff ff       	call   800d2b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801832:	89 1c 24             	mov    %ebx,(%esp)
  801835:	e8 8d f6 ff ff       	call   800ec7 <fd2data>
  80183a:	83 c4 08             	add    $0x8,%esp
  80183d:	50                   	push   %eax
  80183e:	6a 00                	push   $0x0
  801840:	e8 e6 f4 ff ff       	call   800d2b <sys_page_unmap>
}
  801845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	57                   	push   %edi
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	83 ec 1c             	sub    $0x1c,%esp
  801853:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801856:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801858:	a1 08 40 80 00       	mov    0x804008,%eax
  80185d:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	ff 75 e0             	pushl  -0x20(%ebp)
  801866:	e8 5d 05 00 00       	call   801dc8 <pageref>
  80186b:	89 c3                	mov    %eax,%ebx
  80186d:	89 3c 24             	mov    %edi,(%esp)
  801870:	e8 53 05 00 00       	call   801dc8 <pageref>
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	39 c3                	cmp    %eax,%ebx
  80187a:	0f 94 c1             	sete   %cl
  80187d:	0f b6 c9             	movzbl %cl,%ecx
  801880:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801883:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801889:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80188c:	39 ce                	cmp    %ecx,%esi
  80188e:	74 1b                	je     8018ab <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801890:	39 c3                	cmp    %eax,%ebx
  801892:	75 c4                	jne    801858 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801894:	8b 42 60             	mov    0x60(%edx),%eax
  801897:	ff 75 e4             	pushl  -0x1c(%ebp)
  80189a:	50                   	push   %eax
  80189b:	56                   	push   %esi
  80189c:	68 56 25 80 00       	push   $0x802556
  8018a1:	e8 78 ea ff ff       	call   80031e <cprintf>
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	eb ad                	jmp    801858 <_pipeisclosed+0xe>
	}
}
  8018ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	57                   	push   %edi
  8018ba:	56                   	push   %esi
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 28             	sub    $0x28,%esp
  8018bf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018c2:	56                   	push   %esi
  8018c3:	e8 ff f5 ff ff       	call   800ec7 <fd2data>
  8018c8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	bf 00 00 00 00       	mov    $0x0,%edi
  8018d2:	eb 4b                	jmp    80191f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018d4:	89 da                	mov    %ebx,%edx
  8018d6:	89 f0                	mov    %esi,%eax
  8018d8:	e8 6d ff ff ff       	call   80184a <_pipeisclosed>
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	75 48                	jne    801929 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018e1:	e8 a1 f3 ff ff       	call   800c87 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018e6:	8b 43 04             	mov    0x4(%ebx),%eax
  8018e9:	8b 0b                	mov    (%ebx),%ecx
  8018eb:	8d 51 20             	lea    0x20(%ecx),%edx
  8018ee:	39 d0                	cmp    %edx,%eax
  8018f0:	73 e2                	jae    8018d4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018f9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018fc:	89 c2                	mov    %eax,%edx
  8018fe:	c1 fa 1f             	sar    $0x1f,%edx
  801901:	89 d1                	mov    %edx,%ecx
  801903:	c1 e9 1b             	shr    $0x1b,%ecx
  801906:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801909:	83 e2 1f             	and    $0x1f,%edx
  80190c:	29 ca                	sub    %ecx,%edx
  80190e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801912:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801916:	83 c0 01             	add    $0x1,%eax
  801919:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80191c:	83 c7 01             	add    $0x1,%edi
  80191f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801922:	75 c2                	jne    8018e6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801924:	8b 45 10             	mov    0x10(%ebp),%eax
  801927:	eb 05                	jmp    80192e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80192e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5f                   	pop    %edi
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	57                   	push   %edi
  80193a:	56                   	push   %esi
  80193b:	53                   	push   %ebx
  80193c:	83 ec 18             	sub    $0x18,%esp
  80193f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801942:	57                   	push   %edi
  801943:	e8 7f f5 ff ff       	call   800ec7 <fd2data>
  801948:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801952:	eb 3d                	jmp    801991 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801954:	85 db                	test   %ebx,%ebx
  801956:	74 04                	je     80195c <devpipe_read+0x26>
				return i;
  801958:	89 d8                	mov    %ebx,%eax
  80195a:	eb 44                	jmp    8019a0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80195c:	89 f2                	mov    %esi,%edx
  80195e:	89 f8                	mov    %edi,%eax
  801960:	e8 e5 fe ff ff       	call   80184a <_pipeisclosed>
  801965:	85 c0                	test   %eax,%eax
  801967:	75 32                	jne    80199b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801969:	e8 19 f3 ff ff       	call   800c87 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80196e:	8b 06                	mov    (%esi),%eax
  801970:	3b 46 04             	cmp    0x4(%esi),%eax
  801973:	74 df                	je     801954 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801975:	99                   	cltd   
  801976:	c1 ea 1b             	shr    $0x1b,%edx
  801979:	01 d0                	add    %edx,%eax
  80197b:	83 e0 1f             	and    $0x1f,%eax
  80197e:	29 d0                	sub    %edx,%eax
  801980:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801985:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801988:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80198b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198e:	83 c3 01             	add    $0x1,%ebx
  801991:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801994:	75 d8                	jne    80196e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801996:	8b 45 10             	mov    0x10(%ebp),%eax
  801999:	eb 05                	jmp    8019a0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80199b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	56                   	push   %esi
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	e8 25 f5 ff ff       	call   800ede <fd_alloc>
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	89 c2                	mov    %eax,%edx
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 88 2c 01 00 00    	js     801af2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c6:	83 ec 04             	sub    $0x4,%esp
  8019c9:	68 07 04 00 00       	push   $0x407
  8019ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d1:	6a 00                	push   $0x0
  8019d3:	e8 ce f2 ff ff       	call   800ca6 <sys_page_alloc>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	89 c2                	mov    %eax,%edx
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	0f 88 0d 01 00 00    	js     801af2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019eb:	50                   	push   %eax
  8019ec:	e8 ed f4 ff ff       	call   800ede <fd_alloc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	0f 88 e2 00 00 00    	js     801ae0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fe:	83 ec 04             	sub    $0x4,%esp
  801a01:	68 07 04 00 00       	push   $0x407
  801a06:	ff 75 f0             	pushl  -0x10(%ebp)
  801a09:	6a 00                	push   $0x0
  801a0b:	e8 96 f2 ff ff       	call   800ca6 <sys_page_alloc>
  801a10:	89 c3                	mov    %eax,%ebx
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	85 c0                	test   %eax,%eax
  801a17:	0f 88 c3 00 00 00    	js     801ae0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	ff 75 f4             	pushl  -0xc(%ebp)
  801a23:	e8 9f f4 ff ff       	call   800ec7 <fd2data>
  801a28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a2a:	83 c4 0c             	add    $0xc,%esp
  801a2d:	68 07 04 00 00       	push   $0x407
  801a32:	50                   	push   %eax
  801a33:	6a 00                	push   $0x0
  801a35:	e8 6c f2 ff ff       	call   800ca6 <sys_page_alloc>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	0f 88 89 00 00 00    	js     801ad0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4d:	e8 75 f4 ff ff       	call   800ec7 <fd2data>
  801a52:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a59:	50                   	push   %eax
  801a5a:	6a 00                	push   $0x0
  801a5c:	56                   	push   %esi
  801a5d:	6a 00                	push   $0x0
  801a5f:	e8 85 f2 ff ff       	call   800ce9 <sys_page_map>
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	83 c4 20             	add    $0x20,%esp
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 55                	js     801ac2 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a6d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a76:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a82:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a90:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9d:	e8 15 f4 ff ff       	call   800eb7 <fd2num>
  801aa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aa7:	83 c4 04             	add    $0x4,%esp
  801aaa:	ff 75 f0             	pushl  -0x10(%ebp)
  801aad:	e8 05 f4 ff ff       	call   800eb7 <fd2num>
  801ab2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab5:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac0:	eb 30                	jmp    801af2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	56                   	push   %esi
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 5e f2 ff ff       	call   800d2b <sys_page_unmap>
  801acd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ad0:	83 ec 08             	sub    $0x8,%esp
  801ad3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 4e f2 ff ff       	call   800d2b <sys_page_unmap>
  801add:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 3e f2 ff ff       	call   800d2b <sys_page_unmap>
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801af2:	89 d0                	mov    %edx,%eax
  801af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b04:	50                   	push   %eax
  801b05:	ff 75 08             	pushl  0x8(%ebp)
  801b08:	e8 20 f4 ff ff       	call   800f2d <fd_lookup>
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 18                	js     801b2c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1a:	e8 a8 f3 ff ff       	call   800ec7 <fd2data>
	return _pipeisclosed(fd, p);
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b24:	e8 21 fd ff ff       	call   80184a <_pipeisclosed>
  801b29:	83 c4 10             	add    $0x10,%esp
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b3e:	68 6e 25 80 00       	push   $0x80256e
  801b43:	ff 75 0c             	pushl  0xc(%ebp)
  801b46:	e8 58 ed ff ff       	call   8008a3 <strcpy>
	return 0;
}
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	57                   	push   %edi
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b5e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b63:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b69:	eb 2d                	jmp    801b98 <devcons_write+0x46>
		m = n - tot;
  801b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b6e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b70:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b73:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b78:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	53                   	push   %ebx
  801b7f:	03 45 0c             	add    0xc(%ebp),%eax
  801b82:	50                   	push   %eax
  801b83:	57                   	push   %edi
  801b84:	e8 ac ee ff ff       	call   800a35 <memmove>
		sys_cputs(buf, m);
  801b89:	83 c4 08             	add    $0x8,%esp
  801b8c:	53                   	push   %ebx
  801b8d:	57                   	push   %edi
  801b8e:	e8 57 f0 ff ff       	call   800bea <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b93:	01 de                	add    %ebx,%esi
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	89 f0                	mov    %esi,%eax
  801b9a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b9d:	72 cc                	jb     801b6b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba2:	5b                   	pop    %ebx
  801ba3:	5e                   	pop    %esi
  801ba4:	5f                   	pop    %edi
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    

00801ba7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	83 ec 08             	sub    $0x8,%esp
  801bad:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb6:	74 2a                	je     801be2 <devcons_read+0x3b>
  801bb8:	eb 05                	jmp    801bbf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bba:	e8 c8 f0 ff ff       	call   800c87 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bbf:	e8 44 f0 ff ff       	call   800c08 <sys_cgetc>
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	74 f2                	je     801bba <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 16                	js     801be2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bcc:	83 f8 04             	cmp    $0x4,%eax
  801bcf:	74 0c                	je     801bdd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd4:	88 02                	mov    %al,(%edx)
	return 1;
  801bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdb:	eb 05                	jmp    801be2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bdd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bf0:	6a 01                	push   $0x1
  801bf2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bf5:	50                   	push   %eax
  801bf6:	e8 ef ef ff ff       	call   800bea <sys_cputs>
}
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <getchar>:

int
getchar(void)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c06:	6a 01                	push   $0x1
  801c08:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	6a 00                	push   $0x0
  801c0e:	e8 80 f5 ff ff       	call   801193 <read>
	if (r < 0)
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 0f                	js     801c29 <getchar+0x29>
		return r;
	if (r < 1)
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	7e 06                	jle    801c24 <getchar+0x24>
		return -E_EOF;
	return c;
  801c1e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c22:	eb 05                	jmp    801c29 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c24:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	ff 75 08             	pushl  0x8(%ebp)
  801c38:	e8 f0 f2 ff ff       	call   800f2d <fd_lookup>
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 11                	js     801c55 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c47:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c4d:	39 10                	cmp    %edx,(%eax)
  801c4f:	0f 94 c0             	sete   %al
  801c52:	0f b6 c0             	movzbl %al,%eax
}
  801c55:	c9                   	leave  
  801c56:	c3                   	ret    

00801c57 <opencons>:

int
opencons(void)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c60:	50                   	push   %eax
  801c61:	e8 78 f2 ff ff       	call   800ede <fd_alloc>
  801c66:	83 c4 10             	add    $0x10,%esp
		return r;
  801c69:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	78 3e                	js     801cad <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c6f:	83 ec 04             	sub    $0x4,%esp
  801c72:	68 07 04 00 00       	push   $0x407
  801c77:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7a:	6a 00                	push   $0x0
  801c7c:	e8 25 f0 ff ff       	call   800ca6 <sys_page_alloc>
  801c81:	83 c4 10             	add    $0x10,%esp
		return r;
  801c84:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c86:	85 c0                	test   %eax,%eax
  801c88:	78 23                	js     801cad <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c8a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c93:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c98:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	50                   	push   %eax
  801ca3:	e8 0f f2 ff ff       	call   800eb7 <fd2num>
  801ca8:	89 c2                	mov    %eax,%edx
  801caa:	83 c4 10             	add    $0x10,%esp
}
  801cad:	89 d0                	mov    %edx,%eax
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	56                   	push   %esi
  801cb5:	53                   	push   %ebx
  801cb6:	8b 75 08             	mov    0x8(%ebp),%esi
  801cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	75 12                	jne    801cd5 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	68 00 00 c0 ee       	push   $0xeec00000
  801ccb:	e8 86 f1 ff ff       	call   800e56 <sys_ipc_recv>
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	eb 0c                	jmp    801ce1 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	50                   	push   %eax
  801cd9:	e8 78 f1 ff ff       	call   800e56 <sys_ipc_recv>
  801cde:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ce1:	85 f6                	test   %esi,%esi
  801ce3:	0f 95 c1             	setne  %cl
  801ce6:	85 db                	test   %ebx,%ebx
  801ce8:	0f 95 c2             	setne  %dl
  801ceb:	84 d1                	test   %dl,%cl
  801ced:	74 09                	je     801cf8 <ipc_recv+0x47>
  801cef:	89 c2                	mov    %eax,%edx
  801cf1:	c1 ea 1f             	shr    $0x1f,%edx
  801cf4:	84 d2                	test   %dl,%dl
  801cf6:	75 27                	jne    801d1f <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801cf8:	85 f6                	test   %esi,%esi
  801cfa:	74 0a                	je     801d06 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801cfc:	a1 08 40 80 00       	mov    0x804008,%eax
  801d01:	8b 40 7c             	mov    0x7c(%eax),%eax
  801d04:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801d06:	85 db                	test   %ebx,%ebx
  801d08:	74 0d                	je     801d17 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801d0a:	a1 08 40 80 00       	mov    0x804008,%eax
  801d0f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801d15:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d17:	a1 08 40 80 00       	mov    0x804008,%eax
  801d1c:	8b 40 78             	mov    0x78(%eax),%eax
}
  801d1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	57                   	push   %edi
  801d2a:	56                   	push   %esi
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 0c             	sub    $0xc,%esp
  801d2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d32:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801d38:	85 db                	test   %ebx,%ebx
  801d3a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d3f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801d42:	ff 75 14             	pushl  0x14(%ebp)
  801d45:	53                   	push   %ebx
  801d46:	56                   	push   %esi
  801d47:	57                   	push   %edi
  801d48:	e8 e6 f0 ff ff       	call   800e33 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801d4d:	89 c2                	mov    %eax,%edx
  801d4f:	c1 ea 1f             	shr    $0x1f,%edx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	84 d2                	test   %dl,%dl
  801d57:	74 17                	je     801d70 <ipc_send+0x4a>
  801d59:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d5c:	74 12                	je     801d70 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801d5e:	50                   	push   %eax
  801d5f:	68 7a 25 80 00       	push   $0x80257a
  801d64:	6a 47                	push   $0x47
  801d66:	68 88 25 80 00       	push   $0x802588
  801d6b:	e8 d5 e4 ff ff       	call   800245 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801d70:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d73:	75 07                	jne    801d7c <ipc_send+0x56>
			sys_yield();
  801d75:	e8 0d ef ff ff       	call   800c87 <sys_yield>
  801d7a:	eb c6                	jmp    801d42 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	75 c2                	jne    801d42 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d8e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d93:	89 c2                	mov    %eax,%edx
  801d95:	c1 e2 07             	shl    $0x7,%edx
  801d98:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801d9f:	8b 52 58             	mov    0x58(%edx),%edx
  801da2:	39 ca                	cmp    %ecx,%edx
  801da4:	75 11                	jne    801db7 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801da6:	89 c2                	mov    %eax,%edx
  801da8:	c1 e2 07             	shl    $0x7,%edx
  801dab:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801db2:	8b 40 50             	mov    0x50(%eax),%eax
  801db5:	eb 0f                	jmp    801dc6 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801db7:	83 c0 01             	add    $0x1,%eax
  801dba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dbf:	75 d2                	jne    801d93 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dce:	89 d0                	mov    %edx,%eax
  801dd0:	c1 e8 16             	shr    $0x16,%eax
  801dd3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dda:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ddf:	f6 c1 01             	test   $0x1,%cl
  801de2:	74 1d                	je     801e01 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801de4:	c1 ea 0c             	shr    $0xc,%edx
  801de7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dee:	f6 c2 01             	test   $0x1,%dl
  801df1:	74 0e                	je     801e01 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801df3:	c1 ea 0c             	shr    $0xc,%edx
  801df6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dfd:	ef 
  801dfe:	0f b7 c0             	movzwl %ax,%eax
}
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
  801e03:	66 90                	xchg   %ax,%ax
  801e05:	66 90                	xchg   %ax,%ax
  801e07:	66 90                	xchg   %ax,%ax
  801e09:	66 90                	xchg   %ax,%ax
  801e0b:	66 90                	xchg   %ax,%ax
  801e0d:	66 90                	xchg   %ax,%ax
  801e0f:	90                   	nop

00801e10 <__udivdi3>:
  801e10:	55                   	push   %ebp
  801e11:	57                   	push   %edi
  801e12:	56                   	push   %esi
  801e13:	53                   	push   %ebx
  801e14:	83 ec 1c             	sub    $0x1c,%esp
  801e17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e27:	85 f6                	test   %esi,%esi
  801e29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e2d:	89 ca                	mov    %ecx,%edx
  801e2f:	89 f8                	mov    %edi,%eax
  801e31:	75 3d                	jne    801e70 <__udivdi3+0x60>
  801e33:	39 cf                	cmp    %ecx,%edi
  801e35:	0f 87 c5 00 00 00    	ja     801f00 <__udivdi3+0xf0>
  801e3b:	85 ff                	test   %edi,%edi
  801e3d:	89 fd                	mov    %edi,%ebp
  801e3f:	75 0b                	jne    801e4c <__udivdi3+0x3c>
  801e41:	b8 01 00 00 00       	mov    $0x1,%eax
  801e46:	31 d2                	xor    %edx,%edx
  801e48:	f7 f7                	div    %edi
  801e4a:	89 c5                	mov    %eax,%ebp
  801e4c:	89 c8                	mov    %ecx,%eax
  801e4e:	31 d2                	xor    %edx,%edx
  801e50:	f7 f5                	div    %ebp
  801e52:	89 c1                	mov    %eax,%ecx
  801e54:	89 d8                	mov    %ebx,%eax
  801e56:	89 cf                	mov    %ecx,%edi
  801e58:	f7 f5                	div    %ebp
  801e5a:	89 c3                	mov    %eax,%ebx
  801e5c:	89 d8                	mov    %ebx,%eax
  801e5e:	89 fa                	mov    %edi,%edx
  801e60:	83 c4 1c             	add    $0x1c,%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    
  801e68:	90                   	nop
  801e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e70:	39 ce                	cmp    %ecx,%esi
  801e72:	77 74                	ja     801ee8 <__udivdi3+0xd8>
  801e74:	0f bd fe             	bsr    %esi,%edi
  801e77:	83 f7 1f             	xor    $0x1f,%edi
  801e7a:	0f 84 98 00 00 00    	je     801f18 <__udivdi3+0x108>
  801e80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e85:	89 f9                	mov    %edi,%ecx
  801e87:	89 c5                	mov    %eax,%ebp
  801e89:	29 fb                	sub    %edi,%ebx
  801e8b:	d3 e6                	shl    %cl,%esi
  801e8d:	89 d9                	mov    %ebx,%ecx
  801e8f:	d3 ed                	shr    %cl,%ebp
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	d3 e0                	shl    %cl,%eax
  801e95:	09 ee                	or     %ebp,%esi
  801e97:	89 d9                	mov    %ebx,%ecx
  801e99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9d:	89 d5                	mov    %edx,%ebp
  801e9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ea3:	d3 ed                	shr    %cl,%ebp
  801ea5:	89 f9                	mov    %edi,%ecx
  801ea7:	d3 e2                	shl    %cl,%edx
  801ea9:	89 d9                	mov    %ebx,%ecx
  801eab:	d3 e8                	shr    %cl,%eax
  801ead:	09 c2                	or     %eax,%edx
  801eaf:	89 d0                	mov    %edx,%eax
  801eb1:	89 ea                	mov    %ebp,%edx
  801eb3:	f7 f6                	div    %esi
  801eb5:	89 d5                	mov    %edx,%ebp
  801eb7:	89 c3                	mov    %eax,%ebx
  801eb9:	f7 64 24 0c          	mull   0xc(%esp)
  801ebd:	39 d5                	cmp    %edx,%ebp
  801ebf:	72 10                	jb     801ed1 <__udivdi3+0xc1>
  801ec1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ec5:	89 f9                	mov    %edi,%ecx
  801ec7:	d3 e6                	shl    %cl,%esi
  801ec9:	39 c6                	cmp    %eax,%esi
  801ecb:	73 07                	jae    801ed4 <__udivdi3+0xc4>
  801ecd:	39 d5                	cmp    %edx,%ebp
  801ecf:	75 03                	jne    801ed4 <__udivdi3+0xc4>
  801ed1:	83 eb 01             	sub    $0x1,%ebx
  801ed4:	31 ff                	xor    %edi,%edi
  801ed6:	89 d8                	mov    %ebx,%eax
  801ed8:	89 fa                	mov    %edi,%edx
  801eda:	83 c4 1c             	add    $0x1c,%esp
  801edd:	5b                   	pop    %ebx
  801ede:	5e                   	pop    %esi
  801edf:	5f                   	pop    %edi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    
  801ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee8:	31 ff                	xor    %edi,%edi
  801eea:	31 db                	xor    %ebx,%ebx
  801eec:	89 d8                	mov    %ebx,%eax
  801eee:	89 fa                	mov    %edi,%edx
  801ef0:	83 c4 1c             	add    $0x1c,%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    
  801ef8:	90                   	nop
  801ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f00:	89 d8                	mov    %ebx,%eax
  801f02:	f7 f7                	div    %edi
  801f04:	31 ff                	xor    %edi,%edi
  801f06:	89 c3                	mov    %eax,%ebx
  801f08:	89 d8                	mov    %ebx,%eax
  801f0a:	89 fa                	mov    %edi,%edx
  801f0c:	83 c4 1c             	add    $0x1c,%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    
  801f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f18:	39 ce                	cmp    %ecx,%esi
  801f1a:	72 0c                	jb     801f28 <__udivdi3+0x118>
  801f1c:	31 db                	xor    %ebx,%ebx
  801f1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f22:	0f 87 34 ff ff ff    	ja     801e5c <__udivdi3+0x4c>
  801f28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f2d:	e9 2a ff ff ff       	jmp    801e5c <__udivdi3+0x4c>
  801f32:	66 90                	xchg   %ax,%ax
  801f34:	66 90                	xchg   %ax,%ax
  801f36:	66 90                	xchg   %ax,%ax
  801f38:	66 90                	xchg   %ax,%ax
  801f3a:	66 90                	xchg   %ax,%ax
  801f3c:	66 90                	xchg   %ax,%ax
  801f3e:	66 90                	xchg   %ax,%ax

00801f40 <__umoddi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 d2                	test   %edx,%edx
  801f59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f61:	89 f3                	mov    %esi,%ebx
  801f63:	89 3c 24             	mov    %edi,(%esp)
  801f66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6a:	75 1c                	jne    801f88 <__umoddi3+0x48>
  801f6c:	39 f7                	cmp    %esi,%edi
  801f6e:	76 50                	jbe    801fc0 <__umoddi3+0x80>
  801f70:	89 c8                	mov    %ecx,%eax
  801f72:	89 f2                	mov    %esi,%edx
  801f74:	f7 f7                	div    %edi
  801f76:	89 d0                	mov    %edx,%eax
  801f78:	31 d2                	xor    %edx,%edx
  801f7a:	83 c4 1c             	add    $0x1c,%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
  801f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f88:	39 f2                	cmp    %esi,%edx
  801f8a:	89 d0                	mov    %edx,%eax
  801f8c:	77 52                	ja     801fe0 <__umoddi3+0xa0>
  801f8e:	0f bd ea             	bsr    %edx,%ebp
  801f91:	83 f5 1f             	xor    $0x1f,%ebp
  801f94:	75 5a                	jne    801ff0 <__umoddi3+0xb0>
  801f96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f9a:	0f 82 e0 00 00 00    	jb     802080 <__umoddi3+0x140>
  801fa0:	39 0c 24             	cmp    %ecx,(%esp)
  801fa3:	0f 86 d7 00 00 00    	jbe    802080 <__umoddi3+0x140>
  801fa9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fb1:	83 c4 1c             	add    $0x1c,%esp
  801fb4:	5b                   	pop    %ebx
  801fb5:	5e                   	pop    %esi
  801fb6:	5f                   	pop    %edi
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	85 ff                	test   %edi,%edi
  801fc2:	89 fd                	mov    %edi,%ebp
  801fc4:	75 0b                	jne    801fd1 <__umoddi3+0x91>
  801fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcb:	31 d2                	xor    %edx,%edx
  801fcd:	f7 f7                	div    %edi
  801fcf:	89 c5                	mov    %eax,%ebp
  801fd1:	89 f0                	mov    %esi,%eax
  801fd3:	31 d2                	xor    %edx,%edx
  801fd5:	f7 f5                	div    %ebp
  801fd7:	89 c8                	mov    %ecx,%eax
  801fd9:	f7 f5                	div    %ebp
  801fdb:	89 d0                	mov    %edx,%eax
  801fdd:	eb 99                	jmp    801f78 <__umoddi3+0x38>
  801fdf:	90                   	nop
  801fe0:	89 c8                	mov    %ecx,%eax
  801fe2:	89 f2                	mov    %esi,%edx
  801fe4:	83 c4 1c             	add    $0x1c,%esp
  801fe7:	5b                   	pop    %ebx
  801fe8:	5e                   	pop    %esi
  801fe9:	5f                   	pop    %edi
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    
  801fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	8b 34 24             	mov    (%esp),%esi
  801ff3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ff8:	89 e9                	mov    %ebp,%ecx
  801ffa:	29 ef                	sub    %ebp,%edi
  801ffc:	d3 e0                	shl    %cl,%eax
  801ffe:	89 f9                	mov    %edi,%ecx
  802000:	89 f2                	mov    %esi,%edx
  802002:	d3 ea                	shr    %cl,%edx
  802004:	89 e9                	mov    %ebp,%ecx
  802006:	09 c2                	or     %eax,%edx
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	89 14 24             	mov    %edx,(%esp)
  80200d:	89 f2                	mov    %esi,%edx
  80200f:	d3 e2                	shl    %cl,%edx
  802011:	89 f9                	mov    %edi,%ecx
  802013:	89 54 24 04          	mov    %edx,0x4(%esp)
  802017:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	89 e9                	mov    %ebp,%ecx
  80201f:	89 c6                	mov    %eax,%esi
  802021:	d3 e3                	shl    %cl,%ebx
  802023:	89 f9                	mov    %edi,%ecx
  802025:	89 d0                	mov    %edx,%eax
  802027:	d3 e8                	shr    %cl,%eax
  802029:	89 e9                	mov    %ebp,%ecx
  80202b:	09 d8                	or     %ebx,%eax
  80202d:	89 d3                	mov    %edx,%ebx
  80202f:	89 f2                	mov    %esi,%edx
  802031:	f7 34 24             	divl   (%esp)
  802034:	89 d6                	mov    %edx,%esi
  802036:	d3 e3                	shl    %cl,%ebx
  802038:	f7 64 24 04          	mull   0x4(%esp)
  80203c:	39 d6                	cmp    %edx,%esi
  80203e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802042:	89 d1                	mov    %edx,%ecx
  802044:	89 c3                	mov    %eax,%ebx
  802046:	72 08                	jb     802050 <__umoddi3+0x110>
  802048:	75 11                	jne    80205b <__umoddi3+0x11b>
  80204a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80204e:	73 0b                	jae    80205b <__umoddi3+0x11b>
  802050:	2b 44 24 04          	sub    0x4(%esp),%eax
  802054:	1b 14 24             	sbb    (%esp),%edx
  802057:	89 d1                	mov    %edx,%ecx
  802059:	89 c3                	mov    %eax,%ebx
  80205b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80205f:	29 da                	sub    %ebx,%edx
  802061:	19 ce                	sbb    %ecx,%esi
  802063:	89 f9                	mov    %edi,%ecx
  802065:	89 f0                	mov    %esi,%eax
  802067:	d3 e0                	shl    %cl,%eax
  802069:	89 e9                	mov    %ebp,%ecx
  80206b:	d3 ea                	shr    %cl,%edx
  80206d:	89 e9                	mov    %ebp,%ecx
  80206f:	d3 ee                	shr    %cl,%esi
  802071:	09 d0                	or     %edx,%eax
  802073:	89 f2                	mov    %esi,%edx
  802075:	83 c4 1c             	add    $0x1c,%esp
  802078:	5b                   	pop    %ebx
  802079:	5e                   	pop    %esi
  80207a:	5f                   	pop    %edi
  80207b:	5d                   	pop    %ebp
  80207c:	c3                   	ret    
  80207d:	8d 76 00             	lea    0x0(%esi),%esi
  802080:	29 f9                	sub    %edi,%ecx
  802082:	19 d6                	sbb    %edx,%esi
  802084:	89 74 24 04          	mov    %esi,0x4(%esp)
  802088:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80208c:	e9 18 ff ff ff       	jmp    801fa9 <__umoddi3+0x69>
