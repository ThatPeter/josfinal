
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
  80005d:	68 60 20 80 00       	push   $0x802060
  800062:	e8 1d 17 00 00       	call   801784 <printf>
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
  80007c:	e8 b4 11 00 00       	call   801235 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 65 20 80 00       	push   $0x802065
  800095:	6a 13                	push   $0x13
  800097:	68 80 20 80 00       	push   $0x802080
  80009c:	e8 8c 01 00 00       	call   80022d <_panic>
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
  8000b8:	e8 9e 10 00 00       	call   80115b <read>
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
  8000d3:	68 8b 20 80 00       	push   $0x80208b
  8000d8:	6a 18                	push   $0x18
  8000da:	68 80 20 80 00       	push   $0x802080
  8000df:	e8 49 01 00 00       	call   80022d <_panic>
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
  8000f4:	c7 05 04 30 80 00 a0 	movl   $0x8020a0,0x803004
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
  800114:	68 a4 20 80 00       	push   $0x8020a4
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
  80012f:	e8 b2 14 00 00       	call   8015e6 <open>
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
  800146:	68 ac 20 80 00       	push   $0x8020ac
  80014b:	6a 27                	push   $0x27
  80014d:	68 80 20 80 00       	push   $0x802080
  800152:	e8 d6 00 00 00       	call   80022d <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 b5 0e 00 00       	call   80101f <close>

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
  800178:	e8 96 00 00 00       	call   800213 <exit>
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
  800198:	e8 b3 0a 00 00       	call   800c50 <sys_getenvid>
  80019d:	8b 3d 08 40 80 00    	mov    0x804008,%edi
  8001a3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8001a8:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001ad:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8001b2:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8001b5:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8001bb:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8001be:	39 c8                	cmp    %ecx,%eax
  8001c0:	0f 44 fb             	cmove  %ebx,%edi
  8001c3:	b9 01 00 00 00       	mov    $0x1,%ecx
  8001c8:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001cb:	83 c2 01             	add    $0x1,%edx
  8001ce:	83 c3 7c             	add    $0x7c,%ebx
  8001d1:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8001d7:	75 d9                	jne    8001b2 <libmain+0x2d>
  8001d9:	89 f0                	mov    %esi,%eax
  8001db:	84 c0                	test   %al,%al
  8001dd:	74 06                	je     8001e5 <libmain+0x60>
  8001df:	89 3d 08 40 80 00    	mov    %edi,0x804008
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8001e9:	7e 0a                	jle    8001f5 <libmain+0x70>
		binaryname = argv[0];
  8001eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ee:	8b 00                	mov    (%eax),%eax
  8001f0:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	ff 75 0c             	pushl  0xc(%ebp)
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 e8 fe ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800203:	e8 0b 00 00 00       	call   800213 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800219:	e8 2c 0e 00 00       	call   80104a <close_all>
	sys_env_destroy(0);
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	6a 00                	push   $0x0
  800223:	e8 e7 09 00 00       	call   800c0f <sys_env_destroy>
}
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800232:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800235:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80023b:	e8 10 0a 00 00       	call   800c50 <sys_getenvid>
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	56                   	push   %esi
  80024a:	50                   	push   %eax
  80024b:	68 c8 20 80 00       	push   $0x8020c8
  800250:	e8 b1 00 00 00       	call   800306 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800255:	83 c4 18             	add    $0x18,%esp
  800258:	53                   	push   %ebx
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	e8 54 00 00 00       	call   8002b5 <vcprintf>
	cprintf("\n");
  800261:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  800268:	e8 99 00 00 00       	call   800306 <cprintf>
  80026d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800270:	cc                   	int3   
  800271:	eb fd                	jmp    800270 <_panic+0x43>

00800273 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	53                   	push   %ebx
  800277:	83 ec 04             	sub    $0x4,%esp
  80027a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027d:	8b 13                	mov    (%ebx),%edx
  80027f:	8d 42 01             	lea    0x1(%edx),%eax
  800282:	89 03                	mov    %eax,(%ebx)
  800284:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800287:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800290:	75 1a                	jne    8002ac <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	68 ff 00 00 00       	push   $0xff
  80029a:	8d 43 08             	lea    0x8(%ebx),%eax
  80029d:	50                   	push   %eax
  80029e:	e8 2f 09 00 00       	call   800bd2 <sys_cputs>
		b->idx = 0;
  8002a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ac:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c5:	00 00 00 
	b.cnt = 0;
  8002c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d2:	ff 75 0c             	pushl  0xc(%ebp)
  8002d5:	ff 75 08             	pushl  0x8(%ebp)
  8002d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002de:	50                   	push   %eax
  8002df:	68 73 02 80 00       	push   $0x800273
  8002e4:	e8 54 01 00 00       	call   80043d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e9:	83 c4 08             	add    $0x8,%esp
  8002ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f8:	50                   	push   %eax
  8002f9:	e8 d4 08 00 00       	call   800bd2 <sys_cputs>

	return b.cnt;
}
  8002fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 08             	pushl  0x8(%ebp)
  800313:	e8 9d ff ff ff       	call   8002b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 1c             	sub    $0x1c,%esp
  800323:	89 c7                	mov    %eax,%edi
  800325:	89 d6                	mov    %edx,%esi
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800330:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800333:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800336:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800341:	39 d3                	cmp    %edx,%ebx
  800343:	72 05                	jb     80034a <printnum+0x30>
  800345:	39 45 10             	cmp    %eax,0x10(%ebp)
  800348:	77 45                	ja     80038f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034a:	83 ec 0c             	sub    $0xc,%esp
  80034d:	ff 75 18             	pushl  0x18(%ebp)
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800356:	53                   	push   %ebx
  800357:	ff 75 10             	pushl  0x10(%ebp)
  80035a:	83 ec 08             	sub    $0x8,%esp
  80035d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800360:	ff 75 e0             	pushl  -0x20(%ebp)
  800363:	ff 75 dc             	pushl  -0x24(%ebp)
  800366:	ff 75 d8             	pushl  -0x28(%ebp)
  800369:	e8 62 1a 00 00       	call   801dd0 <__udivdi3>
  80036e:	83 c4 18             	add    $0x18,%esp
  800371:	52                   	push   %edx
  800372:	50                   	push   %eax
  800373:	89 f2                	mov    %esi,%edx
  800375:	89 f8                	mov    %edi,%eax
  800377:	e8 9e ff ff ff       	call   80031a <printnum>
  80037c:	83 c4 20             	add    $0x20,%esp
  80037f:	eb 18                	jmp    800399 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	56                   	push   %esi
  800385:	ff 75 18             	pushl  0x18(%ebp)
  800388:	ff d7                	call   *%edi
  80038a:	83 c4 10             	add    $0x10,%esp
  80038d:	eb 03                	jmp    800392 <printnum+0x78>
  80038f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800392:	83 eb 01             	sub    $0x1,%ebx
  800395:	85 db                	test   %ebx,%ebx
  800397:	7f e8                	jg     800381 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	83 ec 04             	sub    $0x4,%esp
  8003a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ac:	e8 4f 1b 00 00       	call   801f00 <__umoddi3>
  8003b1:	83 c4 14             	add    $0x14,%esp
  8003b4:	0f be 80 eb 20 80 00 	movsbl 0x8020eb(%eax),%eax
  8003bb:	50                   	push   %eax
  8003bc:	ff d7                	call   *%edi
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5e                   	pop    %esi
  8003c6:	5f                   	pop    %edi
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cc:	83 fa 01             	cmp    $0x1,%edx
  8003cf:	7e 0e                	jle    8003df <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d1:	8b 10                	mov    (%eax),%edx
  8003d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d6:	89 08                	mov    %ecx,(%eax)
  8003d8:	8b 02                	mov    (%edx),%eax
  8003da:	8b 52 04             	mov    0x4(%edx),%edx
  8003dd:	eb 22                	jmp    800401 <getuint+0x38>
	else if (lflag)
  8003df:	85 d2                	test   %edx,%edx
  8003e1:	74 10                	je     8003f3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e3:	8b 10                	mov    (%eax),%edx
  8003e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e8:	89 08                	mov    %ecx,(%eax)
  8003ea:	8b 02                	mov    (%edx),%eax
  8003ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f1:	eb 0e                	jmp    800401 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800409:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040d:	8b 10                	mov    (%eax),%edx
  80040f:	3b 50 04             	cmp    0x4(%eax),%edx
  800412:	73 0a                	jae    80041e <sprintputch+0x1b>
		*b->buf++ = ch;
  800414:	8d 4a 01             	lea    0x1(%edx),%ecx
  800417:	89 08                	mov    %ecx,(%eax)
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	88 02                	mov    %al,(%edx)
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800426:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800429:	50                   	push   %eax
  80042a:	ff 75 10             	pushl  0x10(%ebp)
  80042d:	ff 75 0c             	pushl  0xc(%ebp)
  800430:	ff 75 08             	pushl  0x8(%ebp)
  800433:	e8 05 00 00 00       	call   80043d <vprintfmt>
	va_end(ap);
}
  800438:	83 c4 10             	add    $0x10,%esp
  80043b:	c9                   	leave  
  80043c:	c3                   	ret    

0080043d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043d:	55                   	push   %ebp
  80043e:	89 e5                	mov    %esp,%ebp
  800440:	57                   	push   %edi
  800441:	56                   	push   %esi
  800442:	53                   	push   %ebx
  800443:	83 ec 2c             	sub    $0x2c,%esp
  800446:	8b 75 08             	mov    0x8(%ebp),%esi
  800449:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80044f:	eb 12                	jmp    800463 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800451:	85 c0                	test   %eax,%eax
  800453:	0f 84 89 03 00 00    	je     8007e2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	53                   	push   %ebx
  80045d:	50                   	push   %eax
  80045e:	ff d6                	call   *%esi
  800460:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800463:	83 c7 01             	add    $0x1,%edi
  800466:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046a:	83 f8 25             	cmp    $0x25,%eax
  80046d:	75 e2                	jne    800451 <vprintfmt+0x14>
  80046f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800473:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80047a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800481:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800488:	ba 00 00 00 00       	mov    $0x0,%edx
  80048d:	eb 07                	jmp    800496 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800492:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8d 47 01             	lea    0x1(%edi),%eax
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	0f b6 07             	movzbl (%edi),%eax
  80049f:	0f b6 c8             	movzbl %al,%ecx
  8004a2:	83 e8 23             	sub    $0x23,%eax
  8004a5:	3c 55                	cmp    $0x55,%al
  8004a7:	0f 87 1a 03 00 00    	ja     8007c7 <vprintfmt+0x38a>
  8004ad:	0f b6 c0             	movzbl %al,%eax
  8004b0:	ff 24 85 20 22 80 00 	jmp    *0x802220(,%eax,4)
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ba:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004be:	eb d6                	jmp    800496 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ce:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d8:	83 fa 09             	cmp    $0x9,%edx
  8004db:	77 39                	ja     800516 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e0:	eb e9                	jmp    8004cb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f3:	eb 27                	jmp    80051c <vprintfmt+0xdf>
  8004f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ff:	0f 49 c8             	cmovns %eax,%ecx
  800502:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800508:	eb 8c                	jmp    800496 <vprintfmt+0x59>
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800514:	eb 80                	jmp    800496 <vprintfmt+0x59>
  800516:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800519:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	0f 89 70 ff ff ff    	jns    800496 <vprintfmt+0x59>
				width = precision, precision = -1;
  800526:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800529:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800533:	e9 5e ff ff ff       	jmp    800496 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800538:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053e:	e9 53 ff ff ff       	jmp    800496 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	ff 30                	pushl  (%eax)
  800552:	ff d6                	call   *%esi
			break;
  800554:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055a:	e9 04 ff ff ff       	jmp    800463 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	99                   	cltd   
  80056b:	31 d0                	xor    %edx,%eax
  80056d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056f:	83 f8 0f             	cmp    $0xf,%eax
  800572:	7f 0b                	jg     80057f <vprintfmt+0x142>
  800574:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  80057b:	85 d2                	test   %edx,%edx
  80057d:	75 18                	jne    800597 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80057f:	50                   	push   %eax
  800580:	68 03 21 80 00       	push   $0x802103
  800585:	53                   	push   %ebx
  800586:	56                   	push   %esi
  800587:	e8 94 fe ff ff       	call   800420 <printfmt>
  80058c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800592:	e9 cc fe ff ff       	jmp    800463 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800597:	52                   	push   %edx
  800598:	68 b5 24 80 00       	push   $0x8024b5
  80059d:	53                   	push   %ebx
  80059e:	56                   	push   %esi
  80059f:	e8 7c fe ff ff       	call   800420 <printfmt>
  8005a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005aa:	e9 b4 fe ff ff       	jmp    800463 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ba:	85 ff                	test   %edi,%edi
  8005bc:	b8 fc 20 80 00       	mov    $0x8020fc,%eax
  8005c1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c8:	0f 8e 94 00 00 00    	jle    800662 <vprintfmt+0x225>
  8005ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d2:	0f 84 98 00 00 00    	je     800670 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	ff 75 d0             	pushl  -0x30(%ebp)
  8005de:	57                   	push   %edi
  8005df:	e8 86 02 00 00       	call   80086a <strnlen>
  8005e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e7:	29 c1                	sub    %eax,%ecx
  8005e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fb:	eb 0f                	jmp    80060c <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	ff 75 e0             	pushl  -0x20(%ebp)
  800604:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800606:	83 ef 01             	sub    $0x1,%edi
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	85 ff                	test   %edi,%edi
  80060e:	7f ed                	jg     8005fd <vprintfmt+0x1c0>
  800610:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800613:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800616:	85 c9                	test   %ecx,%ecx
  800618:	b8 00 00 00 00       	mov    $0x0,%eax
  80061d:	0f 49 c1             	cmovns %ecx,%eax
  800620:	29 c1                	sub    %eax,%ecx
  800622:	89 75 08             	mov    %esi,0x8(%ebp)
  800625:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800628:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062b:	89 cb                	mov    %ecx,%ebx
  80062d:	eb 4d                	jmp    80067c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800633:	74 1b                	je     800650 <vprintfmt+0x213>
  800635:	0f be c0             	movsbl %al,%eax
  800638:	83 e8 20             	sub    $0x20,%eax
  80063b:	83 f8 5e             	cmp    $0x5e,%eax
  80063e:	76 10                	jbe    800650 <vprintfmt+0x213>
					putch('?', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	ff 75 0c             	pushl  0xc(%ebp)
  800646:	6a 3f                	push   $0x3f
  800648:	ff 55 08             	call   *0x8(%ebp)
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb 0d                	jmp    80065d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	ff 75 0c             	pushl  0xc(%ebp)
  800656:	52                   	push   %edx
  800657:	ff 55 08             	call   *0x8(%ebp)
  80065a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	83 eb 01             	sub    $0x1,%ebx
  800660:	eb 1a                	jmp    80067c <vprintfmt+0x23f>
  800662:	89 75 08             	mov    %esi,0x8(%ebp)
  800665:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800668:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066e:	eb 0c                	jmp    80067c <vprintfmt+0x23f>
  800670:	89 75 08             	mov    %esi,0x8(%ebp)
  800673:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800676:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800679:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067c:	83 c7 01             	add    $0x1,%edi
  80067f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800683:	0f be d0             	movsbl %al,%edx
  800686:	85 d2                	test   %edx,%edx
  800688:	74 23                	je     8006ad <vprintfmt+0x270>
  80068a:	85 f6                	test   %esi,%esi
  80068c:	78 a1                	js     80062f <vprintfmt+0x1f2>
  80068e:	83 ee 01             	sub    $0x1,%esi
  800691:	79 9c                	jns    80062f <vprintfmt+0x1f2>
  800693:	89 df                	mov    %ebx,%edi
  800695:	8b 75 08             	mov    0x8(%ebp),%esi
  800698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069b:	eb 18                	jmp    8006b5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 20                	push   $0x20
  8006a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb 08                	jmp    8006b5 <vprintfmt+0x278>
  8006ad:	89 df                	mov    %ebx,%edi
  8006af:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	7f e4                	jg     80069d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bc:	e9 a2 fd ff ff       	jmp    800463 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c1:	83 fa 01             	cmp    $0x1,%edx
  8006c4:	7e 16                	jle    8006dc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 08             	lea    0x8(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 50 04             	mov    0x4(%eax),%edx
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006da:	eb 32                	jmp    80070e <vprintfmt+0x2d1>
	else if (lflag)
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	74 18                	je     8006f8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 c1                	mov    %eax,%ecx
  8006f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f6:	eb 16                	jmp    80070e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800706:	89 c1                	mov    %eax,%ecx
  800708:	c1 f9 1f             	sar    $0x1f,%ecx
  80070b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800711:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800714:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800719:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071d:	79 74                	jns    800793 <vprintfmt+0x356>
				putch('-', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	6a 2d                	push   $0x2d
  800725:	ff d6                	call   *%esi
				num = -(long long) num;
  800727:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80072d:	f7 d8                	neg    %eax
  80072f:	83 d2 00             	adc    $0x0,%edx
  800732:	f7 da                	neg    %edx
  800734:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800737:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073c:	eb 55                	jmp    800793 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 83 fc ff ff       	call   8003c9 <getuint>
			base = 10;
  800746:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80074b:	eb 46                	jmp    800793 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
  800750:	e8 74 fc ff ff       	call   8003c9 <getuint>
			base = 8;
  800755:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80075a:	eb 37                	jmp    800793 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	53                   	push   %ebx
  800760:	6a 30                	push   $0x30
  800762:	ff d6                	call   *%esi
			putch('x', putdat);
  800764:	83 c4 08             	add    $0x8,%esp
  800767:	53                   	push   %ebx
  800768:	6a 78                	push   $0x78
  80076a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 04             	lea    0x4(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800775:	8b 00                	mov    (%eax),%eax
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80077c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800784:	eb 0d                	jmp    800793 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 3b fc ff ff       	call   8003c9 <getuint>
			base = 16;
  80078e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800793:	83 ec 0c             	sub    $0xc,%esp
  800796:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80079a:	57                   	push   %edi
  80079b:	ff 75 e0             	pushl  -0x20(%ebp)
  80079e:	51                   	push   %ecx
  80079f:	52                   	push   %edx
  8007a0:	50                   	push   %eax
  8007a1:	89 da                	mov    %ebx,%edx
  8007a3:	89 f0                	mov    %esi,%eax
  8007a5:	e8 70 fb ff ff       	call   80031a <printnum>
			break;
  8007aa:	83 c4 20             	add    $0x20,%esp
  8007ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b0:	e9 ae fc ff ff       	jmp    800463 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	51                   	push   %ecx
  8007ba:	ff d6                	call   *%esi
			break;
  8007bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c2:	e9 9c fc ff ff       	jmp    800463 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 25                	push   $0x25
  8007cd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	eb 03                	jmp    8007d7 <vprintfmt+0x39a>
  8007d4:	83 ef 01             	sub    $0x1,%edi
  8007d7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007db:	75 f7                	jne    8007d4 <vprintfmt+0x397>
  8007dd:	e9 81 fc ff ff       	jmp    800463 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5f                   	pop    %edi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 18             	sub    $0x18,%esp
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800800:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800807:	85 c0                	test   %eax,%eax
  800809:	74 26                	je     800831 <vsnprintf+0x47>
  80080b:	85 d2                	test   %edx,%edx
  80080d:	7e 22                	jle    800831 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080f:	ff 75 14             	pushl  0x14(%ebp)
  800812:	ff 75 10             	pushl  0x10(%ebp)
  800815:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	68 03 04 80 00       	push   $0x800403
  80081e:	e8 1a fc ff ff       	call   80043d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800823:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800826:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	eb 05                	jmp    800836 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	50                   	push   %eax
  800842:	ff 75 10             	pushl  0x10(%ebp)
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 9a ff ff ff       	call   8007ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	eb 03                	jmp    800862 <strlen+0x10>
		n++;
  80085f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800862:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800866:	75 f7                	jne    80085f <strlen+0xd>
		n++;
	return n;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800873:	ba 00 00 00 00       	mov    $0x0,%edx
  800878:	eb 03                	jmp    80087d <strnlen+0x13>
		n++;
  80087a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087d:	39 c2                	cmp    %eax,%edx
  80087f:	74 08                	je     800889 <strnlen+0x1f>
  800881:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800885:	75 f3                	jne    80087a <strnlen+0x10>
  800887:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800895:	89 c2                	mov    %eax,%edx
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	83 c1 01             	add    $0x1,%ecx
  80089d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	75 ef                	jne    800897 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b2:	53                   	push   %ebx
  8008b3:	e8 9a ff ff ff       	call   800852 <strlen>
  8008b8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008bb:	ff 75 0c             	pushl  0xc(%ebp)
  8008be:	01 d8                	add    %ebx,%eax
  8008c0:	50                   	push   %eax
  8008c1:	e8 c5 ff ff ff       	call   80088b <strcpy>
	return dst;
}
  8008c6:	89 d8                	mov    %ebx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d8:	89 f3                	mov    %esi,%ebx
  8008da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dd:	89 f2                	mov    %esi,%edx
  8008df:	eb 0f                	jmp    8008f0 <strncpy+0x23>
		*dst++ = *src;
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	0f b6 01             	movzbl (%ecx),%eax
  8008e7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ea:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ed:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f0:	39 da                	cmp    %ebx,%edx
  8008f2:	75 ed                	jne    8008e1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800905:	8b 55 10             	mov    0x10(%ebp),%edx
  800908:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090a:	85 d2                	test   %edx,%edx
  80090c:	74 21                	je     80092f <strlcpy+0x35>
  80090e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 09                	jmp    80091f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091f:	39 c2                	cmp    %eax,%edx
  800921:	74 09                	je     80092c <strlcpy+0x32>
  800923:	0f b6 19             	movzbl (%ecx),%ebx
  800926:	84 db                	test   %bl,%bl
  800928:	75 ec                	jne    800916 <strlcpy+0x1c>
  80092a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092f:	29 f0                	sub    %esi,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093e:	eb 06                	jmp    800946 <strcmp+0x11>
		p++, q++;
  800940:	83 c1 01             	add    $0x1,%ecx
  800943:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800946:	0f b6 01             	movzbl (%ecx),%eax
  800949:	84 c0                	test   %al,%al
  80094b:	74 04                	je     800951 <strcmp+0x1c>
  80094d:	3a 02                	cmp    (%edx),%al
  80094f:	74 ef                	je     800940 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 c0             	movzbl %al,%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	89 c3                	mov    %eax,%ebx
  800967:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096a:	eb 06                	jmp    800972 <strncmp+0x17>
		n--, p++, q++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800972:	39 d8                	cmp    %ebx,%eax
  800974:	74 15                	je     80098b <strncmp+0x30>
  800976:	0f b6 08             	movzbl (%eax),%ecx
  800979:	84 c9                	test   %cl,%cl
  80097b:	74 04                	je     800981 <strncmp+0x26>
  80097d:	3a 0a                	cmp    (%edx),%cl
  80097f:	74 eb                	je     80096c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800981:	0f b6 00             	movzbl (%eax),%eax
  800984:	0f b6 12             	movzbl (%edx),%edx
  800987:	29 d0                	sub    %edx,%eax
  800989:	eb 05                	jmp    800990 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800990:	5b                   	pop    %ebx
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099d:	eb 07                	jmp    8009a6 <strchr+0x13>
		if (*s == c)
  80099f:	38 ca                	cmp    %cl,%dl
  8009a1:	74 0f                	je     8009b2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	0f b6 10             	movzbl (%eax),%edx
  8009a9:	84 d2                	test   %dl,%dl
  8009ab:	75 f2                	jne    80099f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009be:	eb 03                	jmp    8009c3 <strfind+0xf>
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c6:	38 ca                	cmp    %cl,%dl
  8009c8:	74 04                	je     8009ce <strfind+0x1a>
  8009ca:	84 d2                	test   %dl,%dl
  8009cc:	75 f2                	jne    8009c0 <strfind+0xc>
			break;
	return (char *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009dc:	85 c9                	test   %ecx,%ecx
  8009de:	74 36                	je     800a16 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e6:	75 28                	jne    800a10 <memset+0x40>
  8009e8:	f6 c1 03             	test   $0x3,%cl
  8009eb:	75 23                	jne    800a10 <memset+0x40>
		c &= 0xFF;
  8009ed:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f1:	89 d3                	mov    %edx,%ebx
  8009f3:	c1 e3 08             	shl    $0x8,%ebx
  8009f6:	89 d6                	mov    %edx,%esi
  8009f8:	c1 e6 18             	shl    $0x18,%esi
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	c1 e0 10             	shl    $0x10,%eax
  800a00:	09 f0                	or     %esi,%eax
  800a02:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a04:	89 d8                	mov    %ebx,%eax
  800a06:	09 d0                	or     %edx,%eax
  800a08:	c1 e9 02             	shr    $0x2,%ecx
  800a0b:	fc                   	cld    
  800a0c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0e:	eb 06                	jmp    800a16 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a13:	fc                   	cld    
  800a14:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a16:	89 f8                	mov    %edi,%eax
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2b:	39 c6                	cmp    %eax,%esi
  800a2d:	73 35                	jae    800a64 <memmove+0x47>
  800a2f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a32:	39 d0                	cmp    %edx,%eax
  800a34:	73 2e                	jae    800a64 <memmove+0x47>
		s += n;
		d += n;
  800a36:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a39:	89 d6                	mov    %edx,%esi
  800a3b:	09 fe                	or     %edi,%esi
  800a3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a43:	75 13                	jne    800a58 <memmove+0x3b>
  800a45:	f6 c1 03             	test   $0x3,%cl
  800a48:	75 0e                	jne    800a58 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a4a:	83 ef 04             	sub    $0x4,%edi
  800a4d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a50:	c1 e9 02             	shr    $0x2,%ecx
  800a53:	fd                   	std    
  800a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a56:	eb 09                	jmp    800a61 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a58:	83 ef 01             	sub    $0x1,%edi
  800a5b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a5e:	fd                   	std    
  800a5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a61:	fc                   	cld    
  800a62:	eb 1d                	jmp    800a81 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a64:	89 f2                	mov    %esi,%edx
  800a66:	09 c2                	or     %eax,%edx
  800a68:	f6 c2 03             	test   $0x3,%dl
  800a6b:	75 0f                	jne    800a7c <memmove+0x5f>
  800a6d:	f6 c1 03             	test   $0x3,%cl
  800a70:	75 0a                	jne    800a7c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	fc                   	cld    
  800a78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7a:	eb 05                	jmp    800a81 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	fc                   	cld    
  800a7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a88:	ff 75 10             	pushl  0x10(%ebp)
  800a8b:	ff 75 0c             	pushl  0xc(%ebp)
  800a8e:	ff 75 08             	pushl  0x8(%ebp)
  800a91:	e8 87 ff ff ff       	call   800a1d <memmove>
}
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	89 c6                	mov    %eax,%esi
  800aa5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa8:	eb 1a                	jmp    800ac4 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaa:	0f b6 08             	movzbl (%eax),%ecx
  800aad:	0f b6 1a             	movzbl (%edx),%ebx
  800ab0:	38 d9                	cmp    %bl,%cl
  800ab2:	74 0a                	je     800abe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab4:	0f b6 c1             	movzbl %cl,%eax
  800ab7:	0f b6 db             	movzbl %bl,%ebx
  800aba:	29 d8                	sub    %ebx,%eax
  800abc:	eb 0f                	jmp    800acd <memcmp+0x35>
		s1++, s2++;
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac4:	39 f0                	cmp    %esi,%eax
  800ac6:	75 e2                	jne    800aaa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	53                   	push   %ebx
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad8:	89 c1                	mov    %eax,%ecx
  800ada:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800add:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae1:	eb 0a                	jmp    800aed <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae3:	0f b6 10             	movzbl (%eax),%edx
  800ae6:	39 da                	cmp    %ebx,%edx
  800ae8:	74 07                	je     800af1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 c8                	cmp    %ecx,%eax
  800aef:	72 f2                	jb     800ae3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af1:	5b                   	pop    %ebx
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b00:	eb 03                	jmp    800b05 <strtol+0x11>
		s++;
  800b02:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	0f b6 01             	movzbl (%ecx),%eax
  800b08:	3c 20                	cmp    $0x20,%al
  800b0a:	74 f6                	je     800b02 <strtol+0xe>
  800b0c:	3c 09                	cmp    $0x9,%al
  800b0e:	74 f2                	je     800b02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b10:	3c 2b                	cmp    $0x2b,%al
  800b12:	75 0a                	jne    800b1e <strtol+0x2a>
		s++;
  800b14:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b17:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1c:	eb 11                	jmp    800b2f <strtol+0x3b>
  800b1e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b23:	3c 2d                	cmp    $0x2d,%al
  800b25:	75 08                	jne    800b2f <strtol+0x3b>
		s++, neg = 1;
  800b27:	83 c1 01             	add    $0x1,%ecx
  800b2a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b35:	75 15                	jne    800b4c <strtol+0x58>
  800b37:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3a:	75 10                	jne    800b4c <strtol+0x58>
  800b3c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b40:	75 7c                	jne    800bbe <strtol+0xca>
		s += 2, base = 16;
  800b42:	83 c1 02             	add    $0x2,%ecx
  800b45:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4a:	eb 16                	jmp    800b62 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b4c:	85 db                	test   %ebx,%ebx
  800b4e:	75 12                	jne    800b62 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b50:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b55:	80 39 30             	cmpb   $0x30,(%ecx)
  800b58:	75 08                	jne    800b62 <strtol+0x6e>
		s++, base = 8;
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6a:	0f b6 11             	movzbl (%ecx),%edx
  800b6d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b70:	89 f3                	mov    %esi,%ebx
  800b72:	80 fb 09             	cmp    $0x9,%bl
  800b75:	77 08                	ja     800b7f <strtol+0x8b>
			dig = *s - '0';
  800b77:	0f be d2             	movsbl %dl,%edx
  800b7a:	83 ea 30             	sub    $0x30,%edx
  800b7d:	eb 22                	jmp    800ba1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b7f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b82:	89 f3                	mov    %esi,%ebx
  800b84:	80 fb 19             	cmp    $0x19,%bl
  800b87:	77 08                	ja     800b91 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b89:	0f be d2             	movsbl %dl,%edx
  800b8c:	83 ea 57             	sub    $0x57,%edx
  800b8f:	eb 10                	jmp    800ba1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b91:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b94:	89 f3                	mov    %esi,%ebx
  800b96:	80 fb 19             	cmp    $0x19,%bl
  800b99:	77 16                	ja     800bb1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b9b:	0f be d2             	movsbl %dl,%edx
  800b9e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba4:	7d 0b                	jge    800bb1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ba6:	83 c1 01             	add    $0x1,%ecx
  800ba9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bad:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800baf:	eb b9                	jmp    800b6a <strtol+0x76>

	if (endptr)
  800bb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb5:	74 0d                	je     800bc4 <strtol+0xd0>
		*endptr = (char *) s;
  800bb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bba:	89 0e                	mov    %ecx,(%esi)
  800bbc:	eb 06                	jmp    800bc4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbe:	85 db                	test   %ebx,%ebx
  800bc0:	74 98                	je     800b5a <strtol+0x66>
  800bc2:	eb 9e                	jmp    800b62 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc4:	89 c2                	mov    %eax,%edx
  800bc6:	f7 da                	neg    %edx
  800bc8:	85 ff                	test   %edi,%edi
  800bca:	0f 45 c2             	cmovne %edx,%eax
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	89 c3                	mov    %eax,%ebx
  800be5:	89 c7                	mov    %eax,%edi
  800be7:	89 c6                	mov    %eax,%esi
  800be9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800c00:	89 d1                	mov    %edx,%ecx
  800c02:	89 d3                	mov    %edx,%ebx
  800c04:	89 d7                	mov    %edx,%edi
  800c06:	89 d6                	mov    %edx,%esi
  800c08:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	89 cb                	mov    %ecx,%ebx
  800c27:	89 cf                	mov    %ecx,%edi
  800c29:	89 ce                	mov    %ecx,%esi
  800c2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	7e 17                	jle    800c48 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	50                   	push   %eax
  800c35:	6a 03                	push   $0x3
  800c37:	68 df 23 80 00       	push   $0x8023df
  800c3c:	6a 23                	push   $0x23
  800c3e:	68 fc 23 80 00       	push   $0x8023fc
  800c43:	e8 e5 f5 ff ff       	call   80022d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c60:	89 d1                	mov    %edx,%ecx
  800c62:	89 d3                	mov    %edx,%ebx
  800c64:	89 d7                	mov    %edx,%edi
  800c66:	89 d6                	mov    %edx,%esi
  800c68:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_yield>:

void
sys_yield(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	be 00 00 00 00       	mov    $0x0,%esi
  800c9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caa:	89 f7                	mov    %esi,%edi
  800cac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 04                	push   $0x4
  800cb8:	68 df 23 80 00       	push   $0x8023df
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 fc 23 80 00       	push   $0x8023fc
  800cc4:	e8 64 f5 ff ff       	call   80022d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ceb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 05                	push   $0x5
  800cfa:	68 df 23 80 00       	push   $0x8023df
  800cff:	6a 23                	push   $0x23
  800d01:	68 fc 23 80 00       	push   $0x8023fc
  800d06:	e8 22 f5 ff ff       	call   80022d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 06 00 00 00       	mov    $0x6,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 06                	push   $0x6
  800d3c:	68 df 23 80 00       	push   $0x8023df
  800d41:	6a 23                	push   $0x23
  800d43:	68 fc 23 80 00       	push   $0x8023fc
  800d48:	e8 e0 f4 ff ff       	call   80022d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 08 00 00 00       	mov    $0x8,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 08                	push   $0x8
  800d7e:	68 df 23 80 00       	push   $0x8023df
  800d83:	6a 23                	push   $0x23
  800d85:	68 fc 23 80 00       	push   $0x8023fc
  800d8a:	e8 9e f4 ff ff       	call   80022d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	b8 09 00 00 00       	mov    $0x9,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 17                	jle    800dd1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	50                   	push   %eax
  800dbe:	6a 09                	push   $0x9
  800dc0:	68 df 23 80 00       	push   $0x8023df
  800dc5:	6a 23                	push   $0x23
  800dc7:	68 fc 23 80 00       	push   $0x8023fc
  800dcc:	e8 5c f4 ff ff       	call   80022d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	89 df                	mov    %ebx,%edi
  800df4:	89 de                	mov    %ebx,%esi
  800df6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	7e 17                	jle    800e13 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	50                   	push   %eax
  800e00:	6a 0a                	push   $0xa
  800e02:	68 df 23 80 00       	push   $0x8023df
  800e07:	6a 23                	push   $0x23
  800e09:	68 fc 23 80 00       	push   $0x8023fc
  800e0e:	e8 1a f4 ff ff       	call   80022d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e21:	be 00 00 00 00       	mov    $0x0,%esi
  800e26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e37:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	89 cb                	mov    %ecx,%ebx
  800e56:	89 cf                	mov    %ecx,%edi
  800e58:	89 ce                	mov    %ecx,%esi
  800e5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	7e 17                	jle    800e77 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e60:	83 ec 0c             	sub    $0xc,%esp
  800e63:	50                   	push   %eax
  800e64:	6a 0d                	push   $0xd
  800e66:	68 df 23 80 00       	push   $0x8023df
  800e6b:	6a 23                	push   $0x23
  800e6d:	68 fc 23 80 00       	push   $0x8023fc
  800e72:	e8 b6 f3 ff ff       	call   80022d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e82:	8b 45 08             	mov    0x8(%ebp),%eax
  800e85:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e9f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eac:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	c1 ea 16             	shr    $0x16,%edx
  800eb6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebd:	f6 c2 01             	test   $0x1,%dl
  800ec0:	74 11                	je     800ed3 <fd_alloc+0x2d>
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	c1 ea 0c             	shr    $0xc,%edx
  800ec7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ece:	f6 c2 01             	test   $0x1,%dl
  800ed1:	75 09                	jne    800edc <fd_alloc+0x36>
			*fd_store = fd;
  800ed3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	eb 17                	jmp    800ef3 <fd_alloc+0x4d>
  800edc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ee1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee6:	75 c9                	jne    800eb1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efb:	83 f8 1f             	cmp    $0x1f,%eax
  800efe:	77 36                	ja     800f36 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f00:	c1 e0 0c             	shl    $0xc,%eax
  800f03:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f08:	89 c2                	mov    %eax,%edx
  800f0a:	c1 ea 16             	shr    $0x16,%edx
  800f0d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f14:	f6 c2 01             	test   $0x1,%dl
  800f17:	74 24                	je     800f3d <fd_lookup+0x48>
  800f19:	89 c2                	mov    %eax,%edx
  800f1b:	c1 ea 0c             	shr    $0xc,%edx
  800f1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f25:	f6 c2 01             	test   $0x1,%dl
  800f28:	74 1a                	je     800f44 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2d:	89 02                	mov    %eax,(%edx)
	return 0;
  800f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f34:	eb 13                	jmp    800f49 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3b:	eb 0c                	jmp    800f49 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f42:	eb 05                	jmp    800f49 <fd_lookup+0x54>
  800f44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f54:	ba 8c 24 80 00       	mov    $0x80248c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f59:	eb 13                	jmp    800f6e <dev_lookup+0x23>
  800f5b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f5e:	39 08                	cmp    %ecx,(%eax)
  800f60:	75 0c                	jne    800f6e <dev_lookup+0x23>
			*dev = devtab[i];
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f67:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6c:	eb 2e                	jmp    800f9c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f6e:	8b 02                	mov    (%edx),%eax
  800f70:	85 c0                	test   %eax,%eax
  800f72:	75 e7                	jne    800f5b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f74:	a1 08 40 80 00       	mov    0x804008,%eax
  800f79:	8b 40 48             	mov    0x48(%eax),%eax
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	51                   	push   %ecx
  800f80:	50                   	push   %eax
  800f81:	68 0c 24 80 00       	push   $0x80240c
  800f86:	e8 7b f3 ff ff       	call   800306 <cprintf>
	*dev = 0;
  800f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 10             	sub    $0x10,%esp
  800fa6:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fb6:	c1 e8 0c             	shr    $0xc,%eax
  800fb9:	50                   	push   %eax
  800fba:	e8 36 ff ff ff       	call   800ef5 <fd_lookup>
  800fbf:	83 c4 08             	add    $0x8,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 05                	js     800fcb <fd_close+0x2d>
	    || fd != fd2)
  800fc6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fc9:	74 0c                	je     800fd7 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fcb:	84 db                	test   %bl,%bl
  800fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd2:	0f 44 c2             	cmove  %edx,%eax
  800fd5:	eb 41                	jmp    801018 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fd7:	83 ec 08             	sub    $0x8,%esp
  800fda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fdd:	50                   	push   %eax
  800fde:	ff 36                	pushl  (%esi)
  800fe0:	e8 66 ff ff ff       	call   800f4b <dev_lookup>
  800fe5:	89 c3                	mov    %eax,%ebx
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 1a                	js     801008 <fd_close+0x6a>
		if (dev->dev_close)
  800fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ff4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	74 0b                	je     801008 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ffd:	83 ec 0c             	sub    $0xc,%esp
  801000:	56                   	push   %esi
  801001:	ff d0                	call   *%eax
  801003:	89 c3                	mov    %eax,%ebx
  801005:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801008:	83 ec 08             	sub    $0x8,%esp
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	e8 00 fd ff ff       	call   800d13 <sys_page_unmap>
	return r;
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	89 d8                	mov    %ebx,%eax
}
  801018:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101b:	5b                   	pop    %ebx
  80101c:	5e                   	pop    %esi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	ff 75 08             	pushl  0x8(%ebp)
  80102c:	e8 c4 fe ff ff       	call   800ef5 <fd_lookup>
  801031:	83 c4 08             	add    $0x8,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	78 10                	js     801048 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	6a 01                	push   $0x1
  80103d:	ff 75 f4             	pushl  -0xc(%ebp)
  801040:	e8 59 ff ff ff       	call   800f9e <fd_close>
  801045:	83 c4 10             	add    $0x10,%esp
}
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <close_all>:

void
close_all(void)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	53                   	push   %ebx
  80104e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801051:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	53                   	push   %ebx
  80105a:	e8 c0 ff ff ff       	call   80101f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80105f:	83 c3 01             	add    $0x1,%ebx
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	83 fb 20             	cmp    $0x20,%ebx
  801068:	75 ec                	jne    801056 <close_all+0xc>
		close(i);
}
  80106a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	83 ec 2c             	sub    $0x2c,%esp
  801078:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80107e:	50                   	push   %eax
  80107f:	ff 75 08             	pushl  0x8(%ebp)
  801082:	e8 6e fe ff ff       	call   800ef5 <fd_lookup>
  801087:	83 c4 08             	add    $0x8,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	0f 88 c1 00 00 00    	js     801153 <dup+0xe4>
		return r;
	close(newfdnum);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	56                   	push   %esi
  801096:	e8 84 ff ff ff       	call   80101f <close>

	newfd = INDEX2FD(newfdnum);
  80109b:	89 f3                	mov    %esi,%ebx
  80109d:	c1 e3 0c             	shl    $0xc,%ebx
  8010a0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010a6:	83 c4 04             	add    $0x4,%esp
  8010a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ac:	e8 de fd ff ff       	call   800e8f <fd2data>
  8010b1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010b3:	89 1c 24             	mov    %ebx,(%esp)
  8010b6:	e8 d4 fd ff ff       	call   800e8f <fd2data>
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c1:	89 f8                	mov    %edi,%eax
  8010c3:	c1 e8 16             	shr    $0x16,%eax
  8010c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010cd:	a8 01                	test   $0x1,%al
  8010cf:	74 37                	je     801108 <dup+0x99>
  8010d1:	89 f8                	mov    %edi,%eax
  8010d3:	c1 e8 0c             	shr    $0xc,%eax
  8010d6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010dd:	f6 c2 01             	test   $0x1,%dl
  8010e0:	74 26                	je     801108 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f1:	50                   	push   %eax
  8010f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f5:	6a 00                	push   $0x0
  8010f7:	57                   	push   %edi
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 d2 fb ff ff       	call   800cd1 <sys_page_map>
  8010ff:	89 c7                	mov    %eax,%edi
  801101:	83 c4 20             	add    $0x20,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	78 2e                	js     801136 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801108:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80110b:	89 d0                	mov    %edx,%eax
  80110d:	c1 e8 0c             	shr    $0xc,%eax
  801110:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	25 07 0e 00 00       	and    $0xe07,%eax
  80111f:	50                   	push   %eax
  801120:	53                   	push   %ebx
  801121:	6a 00                	push   $0x0
  801123:	52                   	push   %edx
  801124:	6a 00                	push   $0x0
  801126:	e8 a6 fb ff ff       	call   800cd1 <sys_page_map>
  80112b:	89 c7                	mov    %eax,%edi
  80112d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801130:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801132:	85 ff                	test   %edi,%edi
  801134:	79 1d                	jns    801153 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	53                   	push   %ebx
  80113a:	6a 00                	push   $0x0
  80113c:	e8 d2 fb ff ff       	call   800d13 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	ff 75 d4             	pushl  -0x2c(%ebp)
  801147:	6a 00                	push   $0x0
  801149:	e8 c5 fb ff ff       	call   800d13 <sys_page_unmap>
	return r;
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	89 f8                	mov    %edi,%eax
}
  801153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	53                   	push   %ebx
  80115f:	83 ec 14             	sub    $0x14,%esp
  801162:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801165:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	53                   	push   %ebx
  80116a:	e8 86 fd ff ff       	call   800ef5 <fd_lookup>
  80116f:	83 c4 08             	add    $0x8,%esp
  801172:	89 c2                	mov    %eax,%edx
  801174:	85 c0                	test   %eax,%eax
  801176:	78 6d                	js     8011e5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801182:	ff 30                	pushl  (%eax)
  801184:	e8 c2 fd ff ff       	call   800f4b <dev_lookup>
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 4c                	js     8011dc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801190:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801193:	8b 42 08             	mov    0x8(%edx),%eax
  801196:	83 e0 03             	and    $0x3,%eax
  801199:	83 f8 01             	cmp    $0x1,%eax
  80119c:	75 21                	jne    8011bf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80119e:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a3:	8b 40 48             	mov    0x48(%eax),%eax
  8011a6:	83 ec 04             	sub    $0x4,%esp
  8011a9:	53                   	push   %ebx
  8011aa:	50                   	push   %eax
  8011ab:	68 50 24 80 00       	push   $0x802450
  8011b0:	e8 51 f1 ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011bd:	eb 26                	jmp    8011e5 <read+0x8a>
	}
	if (!dev->dev_read)
  8011bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c2:	8b 40 08             	mov    0x8(%eax),%eax
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	74 17                	je     8011e0 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8011c9:	83 ec 04             	sub    $0x4,%esp
  8011cc:	ff 75 10             	pushl  0x10(%ebp)
  8011cf:	ff 75 0c             	pushl  0xc(%ebp)
  8011d2:	52                   	push   %edx
  8011d3:	ff d0                	call   *%eax
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	eb 09                	jmp    8011e5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	eb 05                	jmp    8011e5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011e5:	89 d0                	mov    %edx,%eax
  8011e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	57                   	push   %edi
  8011f0:	56                   	push   %esi
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 0c             	sub    $0xc,%esp
  8011f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801200:	eb 21                	jmp    801223 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	89 f0                	mov    %esi,%eax
  801207:	29 d8                	sub    %ebx,%eax
  801209:	50                   	push   %eax
  80120a:	89 d8                	mov    %ebx,%eax
  80120c:	03 45 0c             	add    0xc(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	57                   	push   %edi
  801211:	e8 45 ff ff ff       	call   80115b <read>
		if (m < 0)
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 10                	js     80122d <readn+0x41>
			return m;
		if (m == 0)
  80121d:	85 c0                	test   %eax,%eax
  80121f:	74 0a                	je     80122b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801221:	01 c3                	add    %eax,%ebx
  801223:	39 f3                	cmp    %esi,%ebx
  801225:	72 db                	jb     801202 <readn+0x16>
  801227:	89 d8                	mov    %ebx,%eax
  801229:	eb 02                	jmp    80122d <readn+0x41>
  80122b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	83 ec 14             	sub    $0x14,%esp
  80123c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	53                   	push   %ebx
  801244:	e8 ac fc ff ff       	call   800ef5 <fd_lookup>
  801249:	83 c4 08             	add    $0x8,%esp
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 68                	js     8012ba <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125c:	ff 30                	pushl  (%eax)
  80125e:	e8 e8 fc ff ff       	call   800f4b <dev_lookup>
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 47                	js     8012b1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801271:	75 21                	jne    801294 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801273:	a1 08 40 80 00       	mov    0x804008,%eax
  801278:	8b 40 48             	mov    0x48(%eax),%eax
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	53                   	push   %ebx
  80127f:	50                   	push   %eax
  801280:	68 6c 24 80 00       	push   $0x80246c
  801285:	e8 7c f0 ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801292:	eb 26                	jmp    8012ba <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	8b 52 0c             	mov    0xc(%edx),%edx
  80129a:	85 d2                	test   %edx,%edx
  80129c:	74 17                	je     8012b5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	ff 75 10             	pushl  0x10(%ebp)
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	ff d2                	call   *%edx
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	eb 09                	jmp    8012ba <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	eb 05                	jmp    8012ba <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012ba:	89 d0                	mov    %edx,%eax
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	ff 75 08             	pushl  0x8(%ebp)
  8012ce:	e8 22 fc ff ff       	call   800ef5 <fd_lookup>
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 0e                	js     8012e8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 14             	sub    $0x14,%esp
  8012f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	53                   	push   %ebx
  8012f9:	e8 f7 fb ff ff       	call   800ef5 <fd_lookup>
  8012fe:	83 c4 08             	add    $0x8,%esp
  801301:	89 c2                	mov    %eax,%edx
  801303:	85 c0                	test   %eax,%eax
  801305:	78 65                	js     80136c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801311:	ff 30                	pushl  (%eax)
  801313:	e8 33 fc ff ff       	call   800f4b <dev_lookup>
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 44                	js     801363 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801326:	75 21                	jne    801349 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801328:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80132d:	8b 40 48             	mov    0x48(%eax),%eax
  801330:	83 ec 04             	sub    $0x4,%esp
  801333:	53                   	push   %ebx
  801334:	50                   	push   %eax
  801335:	68 2c 24 80 00       	push   $0x80242c
  80133a:	e8 c7 ef ff ff       	call   800306 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801347:	eb 23                	jmp    80136c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801349:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134c:	8b 52 18             	mov    0x18(%edx),%edx
  80134f:	85 d2                	test   %edx,%edx
  801351:	74 14                	je     801367 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	ff 75 0c             	pushl  0xc(%ebp)
  801359:	50                   	push   %eax
  80135a:	ff d2                	call   *%edx
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	eb 09                	jmp    80136c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801363:	89 c2                	mov    %eax,%edx
  801365:	eb 05                	jmp    80136c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801367:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80136c:	89 d0                	mov    %edx,%eax
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	83 ec 14             	sub    $0x14,%esp
  80137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 6c fb ff ff       	call   800ef5 <fd_lookup>
  801389:	83 c4 08             	add    $0x8,%esp
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 58                	js     8013ea <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139c:	ff 30                	pushl  (%eax)
  80139e:	e8 a8 fb ff ff       	call   800f4b <dev_lookup>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	78 37                	js     8013e1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b1:	74 32                	je     8013e5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013bd:	00 00 00 
	stat->st_isdir = 0;
  8013c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c7:	00 00 00 
	stat->st_dev = dev;
  8013ca:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	53                   	push   %ebx
  8013d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d7:	ff 50 14             	call   *0x14(%eax)
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	eb 09                	jmp    8013ea <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	eb 05                	jmp    8013ea <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ea:	89 d0                	mov    %edx,%eax
  8013ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	56                   	push   %esi
  8013f5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	6a 00                	push   $0x0
  8013fb:	ff 75 08             	pushl  0x8(%ebp)
  8013fe:	e8 e3 01 00 00       	call   8015e6 <open>
  801403:	89 c3                	mov    %eax,%ebx
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 1b                	js     801427 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	ff 75 0c             	pushl  0xc(%ebp)
  801412:	50                   	push   %eax
  801413:	e8 5b ff ff ff       	call   801373 <fstat>
  801418:	89 c6                	mov    %eax,%esi
	close(fd);
  80141a:	89 1c 24             	mov    %ebx,(%esp)
  80141d:	e8 fd fb ff ff       	call   80101f <close>
	return r;
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	89 f0                	mov    %esi,%eax
}
  801427:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	56                   	push   %esi
  801432:	53                   	push   %ebx
  801433:	89 c6                	mov    %eax,%esi
  801435:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801437:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80143e:	75 12                	jne    801452 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	6a 01                	push   $0x1
  801445:	e8 03 09 00 00       	call   801d4d <ipc_find_env>
  80144a:	a3 04 40 80 00       	mov    %eax,0x804004
  80144f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801452:	6a 07                	push   $0x7
  801454:	68 00 50 80 00       	push   $0x805000
  801459:	56                   	push   %esi
  80145a:	ff 35 04 40 80 00    	pushl  0x804004
  801460:	e8 86 08 00 00       	call   801ceb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801465:	83 c4 0c             	add    $0xc,%esp
  801468:	6a 00                	push   $0x0
  80146a:	53                   	push   %ebx
  80146b:	6a 00                	push   $0x0
  80146d:	e8 07 08 00 00       	call   801c79 <ipc_recv>
}
  801472:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	8b 40 0c             	mov    0xc(%eax),%eax
  801485:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80148a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 02 00 00 00       	mov    $0x2,%eax
  80149c:	e8 8d ff ff ff       	call   80142e <fsipc>
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8014af:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8014be:	e8 6b ff ff ff       	call   80142e <fsipc>
}
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014da:	ba 00 00 00 00       	mov    $0x0,%edx
  8014df:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e4:	e8 45 ff ff ff       	call   80142e <fsipc>
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 2c                	js     801519 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	68 00 50 80 00       	push   $0x805000
  8014f5:	53                   	push   %ebx
  8014f6:	e8 90 f3 ff ff       	call   80088b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014fb:	a1 80 50 80 00       	mov    0x805080,%eax
  801500:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801506:	a1 84 50 80 00       	mov    0x805084,%eax
  80150b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801519:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151c:	c9                   	leave  
  80151d:	c3                   	ret    

0080151e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801527:	8b 55 08             	mov    0x8(%ebp),%edx
  80152a:	8b 52 0c             	mov    0xc(%edx),%edx
  80152d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801533:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801538:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80153d:	0f 47 c2             	cmova  %edx,%eax
  801540:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801545:	50                   	push   %eax
  801546:	ff 75 0c             	pushl  0xc(%ebp)
  801549:	68 08 50 80 00       	push   $0x805008
  80154e:	e8 ca f4 ff ff       	call   800a1d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	b8 04 00 00 00       	mov    $0x4,%eax
  80155d:	e8 cc fe ff ff       	call   80142e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156c:	8b 45 08             	mov    0x8(%ebp),%eax
  80156f:	8b 40 0c             	mov    0xc(%eax),%eax
  801572:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801577:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	b8 03 00 00 00       	mov    $0x3,%eax
  801587:	e8 a2 fe ff ff       	call   80142e <fsipc>
  80158c:	89 c3                	mov    %eax,%ebx
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 4b                	js     8015dd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801592:	39 c6                	cmp    %eax,%esi
  801594:	73 16                	jae    8015ac <devfile_read+0x48>
  801596:	68 9c 24 80 00       	push   $0x80249c
  80159b:	68 a3 24 80 00       	push   $0x8024a3
  8015a0:	6a 7c                	push   $0x7c
  8015a2:	68 b8 24 80 00       	push   $0x8024b8
  8015a7:	e8 81 ec ff ff       	call   80022d <_panic>
	assert(r <= PGSIZE);
  8015ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015b1:	7e 16                	jle    8015c9 <devfile_read+0x65>
  8015b3:	68 c3 24 80 00       	push   $0x8024c3
  8015b8:	68 a3 24 80 00       	push   $0x8024a3
  8015bd:	6a 7d                	push   $0x7d
  8015bf:	68 b8 24 80 00       	push   $0x8024b8
  8015c4:	e8 64 ec ff ff       	call   80022d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	50                   	push   %eax
  8015cd:	68 00 50 80 00       	push   $0x805000
  8015d2:	ff 75 0c             	pushl  0xc(%ebp)
  8015d5:	e8 43 f4 ff ff       	call   800a1d <memmove>
	return r;
  8015da:	83 c4 10             	add    $0x10,%esp
}
  8015dd:	89 d8                	mov    %ebx,%eax
  8015df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 20             	sub    $0x20,%esp
  8015ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015f0:	53                   	push   %ebx
  8015f1:	e8 5c f2 ff ff       	call   800852 <strlen>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fe:	7f 67                	jg     801667 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801600:	83 ec 0c             	sub    $0xc,%esp
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	e8 9a f8 ff ff       	call   800ea6 <fd_alloc>
  80160c:	83 c4 10             	add    $0x10,%esp
		return r;
  80160f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801611:	85 c0                	test   %eax,%eax
  801613:	78 57                	js     80166c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	53                   	push   %ebx
  801619:	68 00 50 80 00       	push   $0x805000
  80161e:	e8 68 f2 ff ff       	call   80088b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801623:	8b 45 0c             	mov    0xc(%ebp),%eax
  801626:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80162b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162e:	b8 01 00 00 00       	mov    $0x1,%eax
  801633:	e8 f6 fd ff ff       	call   80142e <fsipc>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	79 14                	jns    801655 <open+0x6f>
		fd_close(fd, 0);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	6a 00                	push   $0x0
  801646:	ff 75 f4             	pushl  -0xc(%ebp)
  801649:	e8 50 f9 ff ff       	call   800f9e <fd_close>
		return r;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	89 da                	mov    %ebx,%edx
  801653:	eb 17                	jmp    80166c <open+0x86>
	}

	return fd2num(fd);
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	ff 75 f4             	pushl  -0xc(%ebp)
  80165b:	e8 1f f8 ff ff       	call   800e7f <fd2num>
  801660:	89 c2                	mov    %eax,%edx
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 05                	jmp    80166c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801667:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80166c:	89 d0                	mov    %edx,%eax
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801679:	ba 00 00 00 00       	mov    $0x0,%edx
  80167e:	b8 08 00 00 00       	mov    $0x8,%eax
  801683:	e8 a6 fd ff ff       	call   80142e <fsipc>
}
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80168a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80168e:	7e 37                	jle    8016c7 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	53                   	push   %ebx
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801699:	ff 70 04             	pushl  0x4(%eax)
  80169c:	8d 40 10             	lea    0x10(%eax),%eax
  80169f:	50                   	push   %eax
  8016a0:	ff 33                	pushl  (%ebx)
  8016a2:	e8 8e fb ff ff       	call   801235 <write>
		if (result > 0)
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	7e 03                	jle    8016b1 <writebuf+0x27>
			b->result += result;
  8016ae:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016b1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016b4:	74 0d                	je     8016c3 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bd:	0f 4f c2             	cmovg  %edx,%eax
  8016c0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c6:	c9                   	leave  
  8016c7:	f3 c3                	repz ret 

008016c9 <putch>:

static void
putch(int ch, void *thunk)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016d3:	8b 53 04             	mov    0x4(%ebx),%edx
  8016d6:	8d 42 01             	lea    0x1(%edx),%eax
  8016d9:	89 43 04             	mov    %eax,0x4(%ebx)
  8016dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016df:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016e3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016e8:	75 0e                	jne    8016f8 <putch+0x2f>
		writebuf(b);
  8016ea:	89 d8                	mov    %ebx,%eax
  8016ec:	e8 99 ff ff ff       	call   80168a <writebuf>
		b->idx = 0;
  8016f1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016f8:	83 c4 04             	add    $0x4,%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801707:	8b 45 08             	mov    0x8(%ebp),%eax
  80170a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801710:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801717:	00 00 00 
	b.result = 0;
  80171a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801721:	00 00 00 
	b.error = 1;
  801724:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80172b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80172e:	ff 75 10             	pushl  0x10(%ebp)
  801731:	ff 75 0c             	pushl  0xc(%ebp)
  801734:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	68 c9 16 80 00       	push   $0x8016c9
  801740:	e8 f8 ec ff ff       	call   80043d <vprintfmt>
	if (b.idx > 0)
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80174f:	7e 0b                	jle    80175c <vfprintf+0x5e>
		writebuf(&b);
  801751:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801757:	e8 2e ff ff ff       	call   80168a <writebuf>

	return (b.result ? b.result : b.error);
  80175c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801762:	85 c0                	test   %eax,%eax
  801764:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801773:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801776:	50                   	push   %eax
  801777:	ff 75 0c             	pushl  0xc(%ebp)
  80177a:	ff 75 08             	pushl  0x8(%ebp)
  80177d:	e8 7c ff ff ff       	call   8016fe <vfprintf>
	va_end(ap);

	return cnt;
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <printf>:

int
printf(const char *fmt, ...)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80178a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80178d:	50                   	push   %eax
  80178e:	ff 75 08             	pushl  0x8(%ebp)
  801791:	6a 01                	push   $0x1
  801793:	e8 66 ff ff ff       	call   8016fe <vfprintf>
	va_end(ap);

	return cnt;
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
  80179f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	ff 75 08             	pushl  0x8(%ebp)
  8017a8:	e8 e2 f6 ff ff       	call   800e8f <fd2data>
  8017ad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017af:	83 c4 08             	add    $0x8,%esp
  8017b2:	68 cf 24 80 00       	push   $0x8024cf
  8017b7:	53                   	push   %ebx
  8017b8:	e8 ce f0 ff ff       	call   80088b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017bd:	8b 46 04             	mov    0x4(%esi),%eax
  8017c0:	2b 06                	sub    (%esi),%eax
  8017c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017cf:	00 00 00 
	stat->st_dev = &devpipe;
  8017d2:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017d9:	30 80 00 
	return 0;
}
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5e                   	pop    %esi
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017f2:	53                   	push   %ebx
  8017f3:	6a 00                	push   $0x0
  8017f5:	e8 19 f5 ff ff       	call   800d13 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017fa:	89 1c 24             	mov    %ebx,(%esp)
  8017fd:	e8 8d f6 ff ff       	call   800e8f <fd2data>
  801802:	83 c4 08             	add    $0x8,%esp
  801805:	50                   	push   %eax
  801806:	6a 00                	push   $0x0
  801808:	e8 06 f5 ff ff       	call   800d13 <sys_page_unmap>
}
  80180d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	57                   	push   %edi
  801816:	56                   	push   %esi
  801817:	53                   	push   %ebx
  801818:	83 ec 1c             	sub    $0x1c,%esp
  80181b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80181e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801820:	a1 08 40 80 00       	mov    0x804008,%eax
  801825:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	ff 75 e0             	pushl  -0x20(%ebp)
  80182e:	e8 53 05 00 00       	call   801d86 <pageref>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	89 3c 24             	mov    %edi,(%esp)
  801838:	e8 49 05 00 00       	call   801d86 <pageref>
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	39 c3                	cmp    %eax,%ebx
  801842:	0f 94 c1             	sete   %cl
  801845:	0f b6 c9             	movzbl %cl,%ecx
  801848:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80184b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801851:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801854:	39 ce                	cmp    %ecx,%esi
  801856:	74 1b                	je     801873 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801858:	39 c3                	cmp    %eax,%ebx
  80185a:	75 c4                	jne    801820 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80185c:	8b 42 58             	mov    0x58(%edx),%eax
  80185f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801862:	50                   	push   %eax
  801863:	56                   	push   %esi
  801864:	68 d6 24 80 00       	push   $0x8024d6
  801869:	e8 98 ea ff ff       	call   800306 <cprintf>
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	eb ad                	jmp    801820 <_pipeisclosed+0xe>
	}
}
  801873:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801876:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5f                   	pop    %edi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	83 ec 28             	sub    $0x28,%esp
  801887:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80188a:	56                   	push   %esi
  80188b:	e8 ff f5 ff ff       	call   800e8f <fd2data>
  801890:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	bf 00 00 00 00       	mov    $0x0,%edi
  80189a:	eb 4b                	jmp    8018e7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80189c:	89 da                	mov    %ebx,%edx
  80189e:	89 f0                	mov    %esi,%eax
  8018a0:	e8 6d ff ff ff       	call   801812 <_pipeisclosed>
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	75 48                	jne    8018f1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018a9:	e8 c1 f3 ff ff       	call   800c6f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8018b1:	8b 0b                	mov    (%ebx),%ecx
  8018b3:	8d 51 20             	lea    0x20(%ecx),%edx
  8018b6:	39 d0                	cmp    %edx,%eax
  8018b8:	73 e2                	jae    80189c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018bd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018c1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	c1 fa 1f             	sar    $0x1f,%edx
  8018c9:	89 d1                	mov    %edx,%ecx
  8018cb:	c1 e9 1b             	shr    $0x1b,%ecx
  8018ce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018d1:	83 e2 1f             	and    $0x1f,%edx
  8018d4:	29 ca                	sub    %ecx,%edx
  8018d6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018de:	83 c0 01             	add    $0x1,%eax
  8018e1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e4:	83 c7 01             	add    $0x1,%edi
  8018e7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018ea:	75 c2                	jne    8018ae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ef:	eb 05                	jmp    8018f6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5e                   	pop    %esi
  8018fb:	5f                   	pop    %edi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	57                   	push   %edi
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	83 ec 18             	sub    $0x18,%esp
  801907:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80190a:	57                   	push   %edi
  80190b:	e8 7f f5 ff ff       	call   800e8f <fd2data>
  801910:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191a:	eb 3d                	jmp    801959 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80191c:	85 db                	test   %ebx,%ebx
  80191e:	74 04                	je     801924 <devpipe_read+0x26>
				return i;
  801920:	89 d8                	mov    %ebx,%eax
  801922:	eb 44                	jmp    801968 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801924:	89 f2                	mov    %esi,%edx
  801926:	89 f8                	mov    %edi,%eax
  801928:	e8 e5 fe ff ff       	call   801812 <_pipeisclosed>
  80192d:	85 c0                	test   %eax,%eax
  80192f:	75 32                	jne    801963 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801931:	e8 39 f3 ff ff       	call   800c6f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801936:	8b 06                	mov    (%esi),%eax
  801938:	3b 46 04             	cmp    0x4(%esi),%eax
  80193b:	74 df                	je     80191c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80193d:	99                   	cltd   
  80193e:	c1 ea 1b             	shr    $0x1b,%edx
  801941:	01 d0                	add    %edx,%eax
  801943:	83 e0 1f             	and    $0x1f,%eax
  801946:	29 d0                	sub    %edx,%eax
  801948:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80194d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801950:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801953:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801956:	83 c3 01             	add    $0x1,%ebx
  801959:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80195c:	75 d8                	jne    801936 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80195e:	8b 45 10             	mov    0x10(%ebp),%eax
  801961:	eb 05                	jmp    801968 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801963:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801968:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5f                   	pop    %edi
  80196e:	5d                   	pop    %ebp
  80196f:	c3                   	ret    

00801970 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	56                   	push   %esi
  801974:	53                   	push   %ebx
  801975:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	e8 25 f5 ff ff       	call   800ea6 <fd_alloc>
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	89 c2                	mov    %eax,%edx
  801986:	85 c0                	test   %eax,%eax
  801988:	0f 88 2c 01 00 00    	js     801aba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80198e:	83 ec 04             	sub    $0x4,%esp
  801991:	68 07 04 00 00       	push   $0x407
  801996:	ff 75 f4             	pushl  -0xc(%ebp)
  801999:	6a 00                	push   $0x0
  80199b:	e8 ee f2 ff ff       	call   800c8e <sys_page_alloc>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	89 c2                	mov    %eax,%edx
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	0f 88 0d 01 00 00    	js     801aba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	e8 ed f4 ff ff       	call   800ea6 <fd_alloc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 88 e2 00 00 00    	js     801aa8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c6:	83 ec 04             	sub    $0x4,%esp
  8019c9:	68 07 04 00 00       	push   $0x407
  8019ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d1:	6a 00                	push   $0x0
  8019d3:	e8 b6 f2 ff ff       	call   800c8e <sys_page_alloc>
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	0f 88 c3 00 00 00    	js     801aa8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019eb:	e8 9f f4 ff ff       	call   800e8f <fd2data>
  8019f0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f2:	83 c4 0c             	add    $0xc,%esp
  8019f5:	68 07 04 00 00       	push   $0x407
  8019fa:	50                   	push   %eax
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 8c f2 ff ff       	call   800c8e <sys_page_alloc>
  801a02:	89 c3                	mov    %eax,%ebx
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	85 c0                	test   %eax,%eax
  801a09:	0f 88 89 00 00 00    	js     801a98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a0f:	83 ec 0c             	sub    $0xc,%esp
  801a12:	ff 75 f0             	pushl  -0x10(%ebp)
  801a15:	e8 75 f4 ff ff       	call   800e8f <fd2data>
  801a1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a21:	50                   	push   %eax
  801a22:	6a 00                	push   $0x0
  801a24:	56                   	push   %esi
  801a25:	6a 00                	push   $0x0
  801a27:	e8 a5 f2 ff ff       	call   800cd1 <sys_page_map>
  801a2c:	89 c3                	mov    %eax,%ebx
  801a2e:	83 c4 20             	add    $0x20,%esp
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 55                	js     801a8a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a35:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a4a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	ff 75 f4             	pushl  -0xc(%ebp)
  801a65:	e8 15 f4 ff ff       	call   800e7f <fd2num>
  801a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a6f:	83 c4 04             	add    $0x4,%esp
  801a72:	ff 75 f0             	pushl  -0x10(%ebp)
  801a75:	e8 05 f4 ff ff       	call   800e7f <fd2num>
  801a7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a7d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	ba 00 00 00 00       	mov    $0x0,%edx
  801a88:	eb 30                	jmp    801aba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a8a:	83 ec 08             	sub    $0x8,%esp
  801a8d:	56                   	push   %esi
  801a8e:	6a 00                	push   $0x0
  801a90:	e8 7e f2 ff ff       	call   800d13 <sys_page_unmap>
  801a95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a98:	83 ec 08             	sub    $0x8,%esp
  801a9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a9e:	6a 00                	push   $0x0
  801aa0:	e8 6e f2 ff ff       	call   800d13 <sys_page_unmap>
  801aa5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801aa8:	83 ec 08             	sub    $0x8,%esp
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 5e f2 ff ff       	call   800d13 <sys_page_unmap>
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801aba:	89 d0                	mov    %edx,%eax
  801abc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acc:	50                   	push   %eax
  801acd:	ff 75 08             	pushl  0x8(%ebp)
  801ad0:	e8 20 f4 ff ff       	call   800ef5 <fd_lookup>
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 18                	js     801af4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae2:	e8 a8 f3 ff ff       	call   800e8f <fd2data>
	return _pipeisclosed(fd, p);
  801ae7:	89 c2                	mov    %eax,%edx
  801ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aec:	e8 21 fd ff ff       	call   801812 <_pipeisclosed>
  801af1:	83 c4 10             	add    $0x10,%esp
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b06:	68 ee 24 80 00       	push   $0x8024ee
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	e8 78 ed ff ff       	call   80088b <strcpy>
	return 0;
}
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	57                   	push   %edi
  801b1e:	56                   	push   %esi
  801b1f:	53                   	push   %ebx
  801b20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b31:	eb 2d                	jmp    801b60 <devcons_write+0x46>
		m = n - tot;
  801b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b43:	83 ec 04             	sub    $0x4,%esp
  801b46:	53                   	push   %ebx
  801b47:	03 45 0c             	add    0xc(%ebp),%eax
  801b4a:	50                   	push   %eax
  801b4b:	57                   	push   %edi
  801b4c:	e8 cc ee ff ff       	call   800a1d <memmove>
		sys_cputs(buf, m);
  801b51:	83 c4 08             	add    $0x8,%esp
  801b54:	53                   	push   %ebx
  801b55:	57                   	push   %edi
  801b56:	e8 77 f0 ff ff       	call   800bd2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b5b:	01 de                	add    %ebx,%esi
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	89 f0                	mov    %esi,%eax
  801b62:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b65:	72 cc                	jb     801b33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5f                   	pop    %edi
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b7e:	74 2a                	je     801baa <devcons_read+0x3b>
  801b80:	eb 05                	jmp    801b87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b82:	e8 e8 f0 ff ff       	call   800c6f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b87:	e8 64 f0 ff ff       	call   800bf0 <sys_cgetc>
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	74 f2                	je     801b82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 16                	js     801baa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b94:	83 f8 04             	cmp    $0x4,%eax
  801b97:	74 0c                	je     801ba5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b9c:	88 02                	mov    %al,(%edx)
	return 1;
  801b9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba3:	eb 05                	jmp    801baa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bb8:	6a 01                	push   $0x1
  801bba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bbd:	50                   	push   %eax
  801bbe:	e8 0f f0 ff ff       	call   800bd2 <sys_cputs>
}
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <getchar>:

int
getchar(void)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bce:	6a 01                	push   $0x1
  801bd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bd3:	50                   	push   %eax
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 80 f5 ff ff       	call   80115b <read>
	if (r < 0)
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 0f                	js     801bf1 <getchar+0x29>
		return r;
	if (r < 1)
  801be2:	85 c0                	test   %eax,%eax
  801be4:	7e 06                	jle    801bec <getchar+0x24>
		return -E_EOF;
	return c;
  801be6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bea:	eb 05                	jmp    801bf1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfc:	50                   	push   %eax
  801bfd:	ff 75 08             	pushl  0x8(%ebp)
  801c00:	e8 f0 f2 ff ff       	call   800ef5 <fd_lookup>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 11                	js     801c1d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0f:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c15:	39 10                	cmp    %edx,(%eax)
  801c17:	0f 94 c0             	sete   %al
  801c1a:	0f b6 c0             	movzbl %al,%eax
}
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    

00801c1f <opencons>:

int
opencons(void)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c28:	50                   	push   %eax
  801c29:	e8 78 f2 ff ff       	call   800ea6 <fd_alloc>
  801c2e:	83 c4 10             	add    $0x10,%esp
		return r;
  801c31:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 3e                	js     801c75 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c37:	83 ec 04             	sub    $0x4,%esp
  801c3a:	68 07 04 00 00       	push   $0x407
  801c3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c42:	6a 00                	push   $0x0
  801c44:	e8 45 f0 ff ff       	call   800c8e <sys_page_alloc>
  801c49:	83 c4 10             	add    $0x10,%esp
		return r;
  801c4c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 23                	js     801c75 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c52:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c60:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	50                   	push   %eax
  801c6b:	e8 0f f2 ff ff       	call   800e7f <fd2num>
  801c70:	89 c2                	mov    %eax,%edx
  801c72:	83 c4 10             	add    $0x10,%esp
}
  801c75:	89 d0                	mov    %edx,%eax
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801c87:	85 c0                	test   %eax,%eax
  801c89:	75 12                	jne    801c9d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	68 00 00 c0 ee       	push   $0xeec00000
  801c93:	e8 a6 f1 ff ff       	call   800e3e <sys_ipc_recv>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	eb 0c                	jmp    801ca9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	50                   	push   %eax
  801ca1:	e8 98 f1 ff ff       	call   800e3e <sys_ipc_recv>
  801ca6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ca9:	85 f6                	test   %esi,%esi
  801cab:	0f 95 c1             	setne  %cl
  801cae:	85 db                	test   %ebx,%ebx
  801cb0:	0f 95 c2             	setne  %dl
  801cb3:	84 d1                	test   %dl,%cl
  801cb5:	74 09                	je     801cc0 <ipc_recv+0x47>
  801cb7:	89 c2                	mov    %eax,%edx
  801cb9:	c1 ea 1f             	shr    $0x1f,%edx
  801cbc:	84 d2                	test   %dl,%dl
  801cbe:	75 24                	jne    801ce4 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801cc0:	85 f6                	test   %esi,%esi
  801cc2:	74 0a                	je     801cce <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801cc4:	a1 08 40 80 00       	mov    0x804008,%eax
  801cc9:	8b 40 74             	mov    0x74(%eax),%eax
  801ccc:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801cce:	85 db                	test   %ebx,%ebx
  801cd0:	74 0a                	je     801cdc <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801cd2:	a1 08 40 80 00       	mov    0x804008,%eax
  801cd7:	8b 40 78             	mov    0x78(%eax),%eax
  801cda:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801cdc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ce1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ce4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	57                   	push   %edi
  801cef:	56                   	push   %esi
  801cf0:	53                   	push   %ebx
  801cf1:	83 ec 0c             	sub    $0xc,%esp
  801cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cf7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801cfd:	85 db                	test   %ebx,%ebx
  801cff:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d04:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801d07:	ff 75 14             	pushl  0x14(%ebp)
  801d0a:	53                   	push   %ebx
  801d0b:	56                   	push   %esi
  801d0c:	57                   	push   %edi
  801d0d:	e8 09 f1 ff ff       	call   800e1b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	c1 ea 1f             	shr    $0x1f,%edx
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	84 d2                	test   %dl,%dl
  801d1c:	74 17                	je     801d35 <ipc_send+0x4a>
  801d1e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d21:	74 12                	je     801d35 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801d23:	50                   	push   %eax
  801d24:	68 fa 24 80 00       	push   $0x8024fa
  801d29:	6a 47                	push   $0x47
  801d2b:	68 08 25 80 00       	push   $0x802508
  801d30:	e8 f8 e4 ff ff       	call   80022d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801d35:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d38:	75 07                	jne    801d41 <ipc_send+0x56>
			sys_yield();
  801d3a:	e8 30 ef ff ff       	call   800c6f <sys_yield>
  801d3f:	eb c6                	jmp    801d07 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801d41:	85 c0                	test   %eax,%eax
  801d43:	75 c2                	jne    801d07 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5e                   	pop    %esi
  801d4a:	5f                   	pop    %edi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d58:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d5b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d61:	8b 52 50             	mov    0x50(%edx),%edx
  801d64:	39 ca                	cmp    %ecx,%edx
  801d66:	75 0d                	jne    801d75 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d68:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d6b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d70:	8b 40 48             	mov    0x48(%eax),%eax
  801d73:	eb 0f                	jmp    801d84 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d75:	83 c0 01             	add    $0x1,%eax
  801d78:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d7d:	75 d9                	jne    801d58 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d8c:	89 d0                	mov    %edx,%eax
  801d8e:	c1 e8 16             	shr    $0x16,%eax
  801d91:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d98:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d9d:	f6 c1 01             	test   $0x1,%cl
  801da0:	74 1d                	je     801dbf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801da2:	c1 ea 0c             	shr    $0xc,%edx
  801da5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dac:	f6 c2 01             	test   $0x1,%dl
  801daf:	74 0e                	je     801dbf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801db1:	c1 ea 0c             	shr    $0xc,%edx
  801db4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dbb:	ef 
  801dbc:	0f b7 c0             	movzwl %ax,%eax
}
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    
  801dc1:	66 90                	xchg   %ax,%ax
  801dc3:	66 90                	xchg   %ax,%ax
  801dc5:	66 90                	xchg   %ax,%ax
  801dc7:	66 90                	xchg   %ax,%ax
  801dc9:	66 90                	xchg   %ax,%ax
  801dcb:	66 90                	xchg   %ax,%ax
  801dcd:	66 90                	xchg   %ax,%ax
  801dcf:	90                   	nop

00801dd0 <__udivdi3>:
  801dd0:	55                   	push   %ebp
  801dd1:	57                   	push   %edi
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 1c             	sub    $0x1c,%esp
  801dd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ddb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ddf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801de7:	85 f6                	test   %esi,%esi
  801de9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ded:	89 ca                	mov    %ecx,%edx
  801def:	89 f8                	mov    %edi,%eax
  801df1:	75 3d                	jne    801e30 <__udivdi3+0x60>
  801df3:	39 cf                	cmp    %ecx,%edi
  801df5:	0f 87 c5 00 00 00    	ja     801ec0 <__udivdi3+0xf0>
  801dfb:	85 ff                	test   %edi,%edi
  801dfd:	89 fd                	mov    %edi,%ebp
  801dff:	75 0b                	jne    801e0c <__udivdi3+0x3c>
  801e01:	b8 01 00 00 00       	mov    $0x1,%eax
  801e06:	31 d2                	xor    %edx,%edx
  801e08:	f7 f7                	div    %edi
  801e0a:	89 c5                	mov    %eax,%ebp
  801e0c:	89 c8                	mov    %ecx,%eax
  801e0e:	31 d2                	xor    %edx,%edx
  801e10:	f7 f5                	div    %ebp
  801e12:	89 c1                	mov    %eax,%ecx
  801e14:	89 d8                	mov    %ebx,%eax
  801e16:	89 cf                	mov    %ecx,%edi
  801e18:	f7 f5                	div    %ebp
  801e1a:	89 c3                	mov    %eax,%ebx
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	89 fa                	mov    %edi,%edx
  801e20:	83 c4 1c             	add    $0x1c,%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5f                   	pop    %edi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    
  801e28:	90                   	nop
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	39 ce                	cmp    %ecx,%esi
  801e32:	77 74                	ja     801ea8 <__udivdi3+0xd8>
  801e34:	0f bd fe             	bsr    %esi,%edi
  801e37:	83 f7 1f             	xor    $0x1f,%edi
  801e3a:	0f 84 98 00 00 00    	je     801ed8 <__udivdi3+0x108>
  801e40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	89 c5                	mov    %eax,%ebp
  801e49:	29 fb                	sub    %edi,%ebx
  801e4b:	d3 e6                	shl    %cl,%esi
  801e4d:	89 d9                	mov    %ebx,%ecx
  801e4f:	d3 ed                	shr    %cl,%ebp
  801e51:	89 f9                	mov    %edi,%ecx
  801e53:	d3 e0                	shl    %cl,%eax
  801e55:	09 ee                	or     %ebp,%esi
  801e57:	89 d9                	mov    %ebx,%ecx
  801e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e5d:	89 d5                	mov    %edx,%ebp
  801e5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e63:	d3 ed                	shr    %cl,%ebp
  801e65:	89 f9                	mov    %edi,%ecx
  801e67:	d3 e2                	shl    %cl,%edx
  801e69:	89 d9                	mov    %ebx,%ecx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	09 c2                	or     %eax,%edx
  801e6f:	89 d0                	mov    %edx,%eax
  801e71:	89 ea                	mov    %ebp,%edx
  801e73:	f7 f6                	div    %esi
  801e75:	89 d5                	mov    %edx,%ebp
  801e77:	89 c3                	mov    %eax,%ebx
  801e79:	f7 64 24 0c          	mull   0xc(%esp)
  801e7d:	39 d5                	cmp    %edx,%ebp
  801e7f:	72 10                	jb     801e91 <__udivdi3+0xc1>
  801e81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e85:	89 f9                	mov    %edi,%ecx
  801e87:	d3 e6                	shl    %cl,%esi
  801e89:	39 c6                	cmp    %eax,%esi
  801e8b:	73 07                	jae    801e94 <__udivdi3+0xc4>
  801e8d:	39 d5                	cmp    %edx,%ebp
  801e8f:	75 03                	jne    801e94 <__udivdi3+0xc4>
  801e91:	83 eb 01             	sub    $0x1,%ebx
  801e94:	31 ff                	xor    %edi,%edi
  801e96:	89 d8                	mov    %ebx,%eax
  801e98:	89 fa                	mov    %edi,%edx
  801e9a:	83 c4 1c             	add    $0x1c,%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    
  801ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ea8:	31 ff                	xor    %edi,%edi
  801eaa:	31 db                	xor    %ebx,%ebx
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	89 fa                	mov    %edi,%edx
  801eb0:	83 c4 1c             	add    $0x1c,%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	90                   	nop
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	89 d8                	mov    %ebx,%eax
  801ec2:	f7 f7                	div    %edi
  801ec4:	31 ff                	xor    %edi,%edi
  801ec6:	89 c3                	mov    %eax,%ebx
  801ec8:	89 d8                	mov    %ebx,%eax
  801eca:	89 fa                	mov    %edi,%edx
  801ecc:	83 c4 1c             	add    $0x1c,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    
  801ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ed8:	39 ce                	cmp    %ecx,%esi
  801eda:	72 0c                	jb     801ee8 <__udivdi3+0x118>
  801edc:	31 db                	xor    %ebx,%ebx
  801ede:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ee2:	0f 87 34 ff ff ff    	ja     801e1c <__udivdi3+0x4c>
  801ee8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801eed:	e9 2a ff ff ff       	jmp    801e1c <__udivdi3+0x4c>
  801ef2:	66 90                	xchg   %ax,%ax
  801ef4:	66 90                	xchg   %ax,%ax
  801ef6:	66 90                	xchg   %ax,%ax
  801ef8:	66 90                	xchg   %ax,%ax
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	66 90                	xchg   %ax,%ax
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <__umoddi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f17:	85 d2                	test   %edx,%edx
  801f19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f21:	89 f3                	mov    %esi,%ebx
  801f23:	89 3c 24             	mov    %edi,(%esp)
  801f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f2a:	75 1c                	jne    801f48 <__umoddi3+0x48>
  801f2c:	39 f7                	cmp    %esi,%edi
  801f2e:	76 50                	jbe    801f80 <__umoddi3+0x80>
  801f30:	89 c8                	mov    %ecx,%eax
  801f32:	89 f2                	mov    %esi,%edx
  801f34:	f7 f7                	div    %edi
  801f36:	89 d0                	mov    %edx,%eax
  801f38:	31 d2                	xor    %edx,%edx
  801f3a:	83 c4 1c             	add    $0x1c,%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    
  801f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f48:	39 f2                	cmp    %esi,%edx
  801f4a:	89 d0                	mov    %edx,%eax
  801f4c:	77 52                	ja     801fa0 <__umoddi3+0xa0>
  801f4e:	0f bd ea             	bsr    %edx,%ebp
  801f51:	83 f5 1f             	xor    $0x1f,%ebp
  801f54:	75 5a                	jne    801fb0 <__umoddi3+0xb0>
  801f56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f5a:	0f 82 e0 00 00 00    	jb     802040 <__umoddi3+0x140>
  801f60:	39 0c 24             	cmp    %ecx,(%esp)
  801f63:	0f 86 d7 00 00 00    	jbe    802040 <__umoddi3+0x140>
  801f69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f71:	83 c4 1c             	add    $0x1c,%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	85 ff                	test   %edi,%edi
  801f82:	89 fd                	mov    %edi,%ebp
  801f84:	75 0b                	jne    801f91 <__umoddi3+0x91>
  801f86:	b8 01 00 00 00       	mov    $0x1,%eax
  801f8b:	31 d2                	xor    %edx,%edx
  801f8d:	f7 f7                	div    %edi
  801f8f:	89 c5                	mov    %eax,%ebp
  801f91:	89 f0                	mov    %esi,%eax
  801f93:	31 d2                	xor    %edx,%edx
  801f95:	f7 f5                	div    %ebp
  801f97:	89 c8                	mov    %ecx,%eax
  801f99:	f7 f5                	div    %ebp
  801f9b:	89 d0                	mov    %edx,%eax
  801f9d:	eb 99                	jmp    801f38 <__umoddi3+0x38>
  801f9f:	90                   	nop
  801fa0:	89 c8                	mov    %ecx,%eax
  801fa2:	89 f2                	mov    %esi,%edx
  801fa4:	83 c4 1c             	add    $0x1c,%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    
  801fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	8b 34 24             	mov    (%esp),%esi
  801fb3:	bf 20 00 00 00       	mov    $0x20,%edi
  801fb8:	89 e9                	mov    %ebp,%ecx
  801fba:	29 ef                	sub    %ebp,%edi
  801fbc:	d3 e0                	shl    %cl,%eax
  801fbe:	89 f9                	mov    %edi,%ecx
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	d3 ea                	shr    %cl,%edx
  801fc4:	89 e9                	mov    %ebp,%ecx
  801fc6:	09 c2                	or     %eax,%edx
  801fc8:	89 d8                	mov    %ebx,%eax
  801fca:	89 14 24             	mov    %edx,(%esp)
  801fcd:	89 f2                	mov    %esi,%edx
  801fcf:	d3 e2                	shl    %cl,%edx
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	89 e9                	mov    %ebp,%ecx
  801fdf:	89 c6                	mov    %eax,%esi
  801fe1:	d3 e3                	shl    %cl,%ebx
  801fe3:	89 f9                	mov    %edi,%ecx
  801fe5:	89 d0                	mov    %edx,%eax
  801fe7:	d3 e8                	shr    %cl,%eax
  801fe9:	89 e9                	mov    %ebp,%ecx
  801feb:	09 d8                	or     %ebx,%eax
  801fed:	89 d3                	mov    %edx,%ebx
  801fef:	89 f2                	mov    %esi,%edx
  801ff1:	f7 34 24             	divl   (%esp)
  801ff4:	89 d6                	mov    %edx,%esi
  801ff6:	d3 e3                	shl    %cl,%ebx
  801ff8:	f7 64 24 04          	mull   0x4(%esp)
  801ffc:	39 d6                	cmp    %edx,%esi
  801ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802002:	89 d1                	mov    %edx,%ecx
  802004:	89 c3                	mov    %eax,%ebx
  802006:	72 08                	jb     802010 <__umoddi3+0x110>
  802008:	75 11                	jne    80201b <__umoddi3+0x11b>
  80200a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80200e:	73 0b                	jae    80201b <__umoddi3+0x11b>
  802010:	2b 44 24 04          	sub    0x4(%esp),%eax
  802014:	1b 14 24             	sbb    (%esp),%edx
  802017:	89 d1                	mov    %edx,%ecx
  802019:	89 c3                	mov    %eax,%ebx
  80201b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80201f:	29 da                	sub    %ebx,%edx
  802021:	19 ce                	sbb    %ecx,%esi
  802023:	89 f9                	mov    %edi,%ecx
  802025:	89 f0                	mov    %esi,%eax
  802027:	d3 e0                	shl    %cl,%eax
  802029:	89 e9                	mov    %ebp,%ecx
  80202b:	d3 ea                	shr    %cl,%edx
  80202d:	89 e9                	mov    %ebp,%ecx
  80202f:	d3 ee                	shr    %cl,%esi
  802031:	09 d0                	or     %edx,%eax
  802033:	89 f2                	mov    %esi,%edx
  802035:	83 c4 1c             	add    $0x1c,%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    
  80203d:	8d 76 00             	lea    0x0(%esi),%esi
  802040:	29 f9                	sub    %edi,%ecx
  802042:	19 d6                	sbb    %edx,%esi
  802044:	89 74 24 04          	mov    %esi,0x4(%esp)
  802048:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80204c:	e9 18 ff ff ff       	jmp    801f69 <__umoddi3+0x69>
