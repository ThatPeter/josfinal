
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 96 11 00 00       	call   8011e3 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 00 20 80 00       	push   $0x802000
  800060:	6a 0d                	push   $0xd
  800062:	68 1b 20 80 00       	push   $0x80201b
  800067:	e8 6f 01 00 00       	call   8001db <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 8a 10 00 00       	call   801109 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 26 20 80 00       	push   $0x802026
  800098:	6a 0f                	push   $0xf
  80009a:	68 1b 20 80 00       	push   $0x80201b
  80009f:	e8 37 01 00 00       	call   8001db <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 3b 	movl   $0x80203b,0x803000
  8000be:	20 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 3f 20 80 00       	push   $0x80203f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 a7 14 00 00       	call   801594 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 47 20 80 00       	push   $0x802047
  800102:	e8 2b 16 00 00       	call   801732 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 ad 0e 00 00       	call   800fcd <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80013c:	c7 05 20 60 80 00 00 	movl   $0x0,0x806020
  800143:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800146:	e8 b3 0a 00 00       	call   800bfe <sys_getenvid>
  80014b:	8b 3d 20 60 80 00    	mov    0x806020,%edi
  800151:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800156:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800160:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800163:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800169:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80016c:	39 c8                	cmp    %ecx,%eax
  80016e:	0f 44 fb             	cmove  %ebx,%edi
  800171:	b9 01 00 00 00       	mov    $0x1,%ecx
  800176:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800179:	83 c2 01             	add    $0x1,%edx
  80017c:	83 c3 7c             	add    $0x7c,%ebx
  80017f:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800185:	75 d9                	jne    800160 <libmain+0x2d>
  800187:	89 f0                	mov    %esi,%eax
  800189:	84 c0                	test   %al,%al
  80018b:	74 06                	je     800193 <libmain+0x60>
  80018d:	89 3d 20 60 80 00    	mov    %edi,0x806020
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800193:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800197:	7e 0a                	jle    8001a3 <libmain+0x70>
		binaryname = argv[0];
  800199:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019c:	8b 00                	mov    (%eax),%eax
  80019e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001a3:	83 ec 08             	sub    $0x8,%esp
  8001a6:	ff 75 0c             	pushl  0xc(%ebp)
  8001a9:	ff 75 08             	pushl  0x8(%ebp)
  8001ac:	e8 fa fe ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  8001b1:	e8 0b 00 00 00       	call   8001c1 <exit>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bc:	5b                   	pop    %ebx
  8001bd:	5e                   	pop    %esi
  8001be:	5f                   	pop    %edi
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c7:	e8 2c 0e 00 00       	call   800ff8 <close_all>
	sys_env_destroy(0);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	6a 00                	push   $0x0
  8001d1:	e8 e7 09 00 00       	call   800bbd <sys_env_destroy>
}
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001e9:	e8 10 0a 00 00       	call   800bfe <sys_getenvid>
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	ff 75 0c             	pushl  0xc(%ebp)
  8001f4:	ff 75 08             	pushl  0x8(%ebp)
  8001f7:	56                   	push   %esi
  8001f8:	50                   	push   %eax
  8001f9:	68 64 20 80 00       	push   $0x802064
  8001fe:	e8 b1 00 00 00       	call   8002b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800203:	83 c4 18             	add    $0x18,%esp
  800206:	53                   	push   %ebx
  800207:	ff 75 10             	pushl  0x10(%ebp)
  80020a:	e8 54 00 00 00       	call   800263 <vcprintf>
	cprintf("\n");
  80020f:	c7 04 24 87 24 80 00 	movl   $0x802487,(%esp)
  800216:	e8 99 00 00 00       	call   8002b4 <cprintf>
  80021b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021e:	cc                   	int3   
  80021f:	eb fd                	jmp    80021e <_panic+0x43>

00800221 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	53                   	push   %ebx
  800225:	83 ec 04             	sub    $0x4,%esp
  800228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022b:	8b 13                	mov    (%ebx),%edx
  80022d:	8d 42 01             	lea    0x1(%edx),%eax
  800230:	89 03                	mov    %eax,(%ebx)
  800232:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800235:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800239:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023e:	75 1a                	jne    80025a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	68 ff 00 00 00       	push   $0xff
  800248:	8d 43 08             	lea    0x8(%ebx),%eax
  80024b:	50                   	push   %eax
  80024c:	e8 2f 09 00 00       	call   800b80 <sys_cputs>
		b->idx = 0;
  800251:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800257:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80025a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80026c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800273:	00 00 00 
	b.cnt = 0;
  800276:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800280:	ff 75 0c             	pushl  0xc(%ebp)
  800283:	ff 75 08             	pushl  0x8(%ebp)
  800286:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	68 21 02 80 00       	push   $0x800221
  800292:	e8 54 01 00 00       	call   8003eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800297:	83 c4 08             	add    $0x8,%esp
  80029a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 d4 08 00 00       	call   800b80 <sys_cputs>

	return b.cnt;
}
  8002ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 9d ff ff ff       	call   800263 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 1c             	sub    $0x1c,%esp
  8002d1:	89 c7                	mov    %eax,%edi
  8002d3:	89 d6                	mov    %edx,%esi
  8002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ef:	39 d3                	cmp    %edx,%ebx
  8002f1:	72 05                	jb     8002f8 <printnum+0x30>
  8002f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f6:	77 45                	ja     80033d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 75 18             	pushl  0x18(%ebp)
  8002fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800301:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800304:	53                   	push   %ebx
  800305:	ff 75 10             	pushl  0x10(%ebp)
  800308:	83 ec 08             	sub    $0x8,%esp
  80030b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030e:	ff 75 e0             	pushl  -0x20(%ebp)
  800311:	ff 75 dc             	pushl  -0x24(%ebp)
  800314:	ff 75 d8             	pushl  -0x28(%ebp)
  800317:	e8 54 1a 00 00       	call   801d70 <__udivdi3>
  80031c:	83 c4 18             	add    $0x18,%esp
  80031f:	52                   	push   %edx
  800320:	50                   	push   %eax
  800321:	89 f2                	mov    %esi,%edx
  800323:	89 f8                	mov    %edi,%eax
  800325:	e8 9e ff ff ff       	call   8002c8 <printnum>
  80032a:	83 c4 20             	add    $0x20,%esp
  80032d:	eb 18                	jmp    800347 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032f:	83 ec 08             	sub    $0x8,%esp
  800332:	56                   	push   %esi
  800333:	ff 75 18             	pushl  0x18(%ebp)
  800336:	ff d7                	call   *%edi
  800338:	83 c4 10             	add    $0x10,%esp
  80033b:	eb 03                	jmp    800340 <printnum+0x78>
  80033d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800340:	83 eb 01             	sub    $0x1,%ebx
  800343:	85 db                	test   %ebx,%ebx
  800345:	7f e8                	jg     80032f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	56                   	push   %esi
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800351:	ff 75 e0             	pushl  -0x20(%ebp)
  800354:	ff 75 dc             	pushl  -0x24(%ebp)
  800357:	ff 75 d8             	pushl  -0x28(%ebp)
  80035a:	e8 41 1b 00 00       	call   801ea0 <__umoddi3>
  80035f:	83 c4 14             	add    $0x14,%esp
  800362:	0f be 80 87 20 80 00 	movsbl 0x802087(%eax),%eax
  800369:	50                   	push   %eax
  80036a:	ff d7                	call   *%edi
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800372:	5b                   	pop    %ebx
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037a:	83 fa 01             	cmp    $0x1,%edx
  80037d:	7e 0e                	jle    80038d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	8d 4a 08             	lea    0x8(%edx),%ecx
  800384:	89 08                	mov    %ecx,(%eax)
  800386:	8b 02                	mov    (%edx),%eax
  800388:	8b 52 04             	mov    0x4(%edx),%edx
  80038b:	eb 22                	jmp    8003af <getuint+0x38>
	else if (lflag)
  80038d:	85 d2                	test   %edx,%edx
  80038f:	74 10                	je     8003a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800391:	8b 10                	mov    (%eax),%edx
  800393:	8d 4a 04             	lea    0x4(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 02                	mov    (%edx),%eax
  80039a:	ba 00 00 00 00       	mov    $0x0,%edx
  80039f:	eb 0e                	jmp    8003af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a6:	89 08                	mov    %ecx,(%eax)
  8003a8:	8b 02                	mov    (%edx),%eax
  8003aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c0:	73 0a                	jae    8003cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	88 02                	mov    %al,(%edx)
}
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d7:	50                   	push   %eax
  8003d8:	ff 75 10             	pushl  0x10(%ebp)
  8003db:	ff 75 0c             	pushl  0xc(%ebp)
  8003de:	ff 75 08             	pushl  0x8(%ebp)
  8003e1:	e8 05 00 00 00       	call   8003eb <vprintfmt>
	va_end(ap);
}
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	57                   	push   %edi
  8003ef:	56                   	push   %esi
  8003f0:	53                   	push   %ebx
  8003f1:	83 ec 2c             	sub    $0x2c,%esp
  8003f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fd:	eb 12                	jmp    800411 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ff:	85 c0                	test   %eax,%eax
  800401:	0f 84 89 03 00 00    	je     800790 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	53                   	push   %ebx
  80040b:	50                   	push   %eax
  80040c:	ff d6                	call   *%esi
  80040e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800411:	83 c7 01             	add    $0x1,%edi
  800414:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800418:	83 f8 25             	cmp    $0x25,%eax
  80041b:	75 e2                	jne    8003ff <vprintfmt+0x14>
  80041d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800421:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800428:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800436:	ba 00 00 00 00       	mov    $0x0,%edx
  80043b:	eb 07                	jmp    800444 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800440:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8d 47 01             	lea    0x1(%edi),%eax
  800447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044a:	0f b6 07             	movzbl (%edi),%eax
  80044d:	0f b6 c8             	movzbl %al,%ecx
  800450:	83 e8 23             	sub    $0x23,%eax
  800453:	3c 55                	cmp    $0x55,%al
  800455:	0f 87 1a 03 00 00    	ja     800775 <vprintfmt+0x38a>
  80045b:	0f b6 c0             	movzbl %al,%eax
  80045e:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800468:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046c:	eb d6                	jmp    800444 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800479:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800480:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800483:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800486:	83 fa 09             	cmp    $0x9,%edx
  800489:	77 39                	ja     8004c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048e:	eb e9                	jmp    800479 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 48 04             	lea    0x4(%eax),%ecx
  800496:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a1:	eb 27                	jmp    8004ca <vprintfmt+0xdf>
  8004a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a6:	85 c0                	test   %eax,%eax
  8004a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ad:	0f 49 c8             	cmovns %eax,%ecx
  8004b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b6:	eb 8c                	jmp    800444 <vprintfmt+0x59>
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c2:	eb 80                	jmp    800444 <vprintfmt+0x59>
  8004c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ce:	0f 89 70 ff ff ff    	jns    800444 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e1:	e9 5e ff ff ff       	jmp    800444 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ec:	e9 53 ff ff ff       	jmp    800444 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 30                	pushl  (%eax)
  800500:	ff d6                	call   *%esi
			break;
  800502:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800508:	e9 04 ff ff ff       	jmp    800411 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	99                   	cltd   
  800519:	31 d0                	xor    %edx,%eax
  80051b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051d:	83 f8 0f             	cmp    $0xf,%eax
  800520:	7f 0b                	jg     80052d <vprintfmt+0x142>
  800522:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	75 18                	jne    800545 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052d:	50                   	push   %eax
  80052e:	68 9f 20 80 00       	push   $0x80209f
  800533:	53                   	push   %ebx
  800534:	56                   	push   %esi
  800535:	e8 94 fe ff ff       	call   8003ce <printfmt>
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800540:	e9 cc fe ff ff       	jmp    800411 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800545:	52                   	push   %edx
  800546:	68 55 24 80 00       	push   $0x802455
  80054b:	53                   	push   %ebx
  80054c:	56                   	push   %esi
  80054d:	e8 7c fe ff ff       	call   8003ce <printfmt>
  800552:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800558:	e9 b4 fe ff ff       	jmp    800411 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800568:	85 ff                	test   %edi,%edi
  80056a:	b8 98 20 80 00       	mov    $0x802098,%eax
  80056f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800572:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800576:	0f 8e 94 00 00 00    	jle    800610 <vprintfmt+0x225>
  80057c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800580:	0f 84 98 00 00 00    	je     80061e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	ff 75 d0             	pushl  -0x30(%ebp)
  80058c:	57                   	push   %edi
  80058d:	e8 86 02 00 00       	call   800818 <strnlen>
  800592:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800595:	29 c1                	sub    %eax,%ecx
  800597:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a9:	eb 0f                	jmp    8005ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	85 ff                	test   %edi,%edi
  8005bc:	7f ed                	jg     8005ab <vprintfmt+0x1c0>
  8005be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cb:	0f 49 c1             	cmovns %ecx,%eax
  8005ce:	29 c1                	sub    %eax,%ecx
  8005d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d9:	89 cb                	mov    %ecx,%ebx
  8005db:	eb 4d                	jmp    80062a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	74 1b                	je     8005fe <vprintfmt+0x213>
  8005e3:	0f be c0             	movsbl %al,%eax
  8005e6:	83 e8 20             	sub    $0x20,%eax
  8005e9:	83 f8 5e             	cmp    $0x5e,%eax
  8005ec:	76 10                	jbe    8005fe <vprintfmt+0x213>
					putch('?', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	6a 3f                	push   $0x3f
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	eb 0d                	jmp    80060b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	52                   	push   %edx
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060b:	83 eb 01             	sub    $0x1,%ebx
  80060e:	eb 1a                	jmp    80062a <vprintfmt+0x23f>
  800610:	89 75 08             	mov    %esi,0x8(%ebp)
  800613:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800616:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800619:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061c:	eb 0c                	jmp    80062a <vprintfmt+0x23f>
  80061e:	89 75 08             	mov    %esi,0x8(%ebp)
  800621:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800624:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800627:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062a:	83 c7 01             	add    $0x1,%edi
  80062d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800631:	0f be d0             	movsbl %al,%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	74 23                	je     80065b <vprintfmt+0x270>
  800638:	85 f6                	test   %esi,%esi
  80063a:	78 a1                	js     8005dd <vprintfmt+0x1f2>
  80063c:	83 ee 01             	sub    $0x1,%esi
  80063f:	79 9c                	jns    8005dd <vprintfmt+0x1f2>
  800641:	89 df                	mov    %ebx,%edi
  800643:	8b 75 08             	mov    0x8(%ebp),%esi
  800646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800649:	eb 18                	jmp    800663 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 20                	push   $0x20
  800651:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 08                	jmp    800663 <vprintfmt+0x278>
  80065b:	89 df                	mov    %ebx,%edi
  80065d:	8b 75 08             	mov    0x8(%ebp),%esi
  800660:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800663:	85 ff                	test   %edi,%edi
  800665:	7f e4                	jg     80064b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066a:	e9 a2 fd ff ff       	jmp    800411 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 fa 01             	cmp    $0x1,%edx
  800672:	7e 16                	jle    80068a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 08             	lea    0x8(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 50 04             	mov    0x4(%eax),%edx
  800680:	8b 00                	mov    (%eax),%eax
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800688:	eb 32                	jmp    8006bc <vprintfmt+0x2d1>
	else if (lflag)
  80068a:	85 d2                	test   %edx,%edx
  80068c:	74 18                	je     8006a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 50 04             	lea    0x4(%eax),%edx
  800694:	89 55 14             	mov    %edx,0x14(%ebp)
  800697:	8b 00                	mov    (%eax),%eax
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	89 c1                	mov    %eax,%ecx
  80069e:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a4:	eb 16                	jmp    8006bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b4:	89 c1                	mov    %eax,%ecx
  8006b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006cb:	79 74                	jns    800741 <vprintfmt+0x356>
				putch('-', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 2d                	push   $0x2d
  8006d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006db:	f7 d8                	neg    %eax
  8006dd:	83 d2 00             	adc    $0x0,%edx
  8006e0:	f7 da                	neg    %edx
  8006e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ea:	eb 55                	jmp    800741 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 83 fc ff ff       	call   800377 <getuint>
			base = 10;
  8006f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f9:	eb 46                	jmp    800741 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 74 fc ff ff       	call   800377 <getuint>
			base = 8;
  800703:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800708:	eb 37                	jmp    800741 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 30                	push   $0x30
  800710:	ff d6                	call   *%esi
			putch('x', putdat);
  800712:	83 c4 08             	add    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 78                	push   $0x78
  800718:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800723:	8b 00                	mov    (%eax),%eax
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80072a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800732:	eb 0d                	jmp    800741 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800734:	8d 45 14             	lea    0x14(%ebp),%eax
  800737:	e8 3b fc ff ff       	call   800377 <getuint>
			base = 16;
  80073c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800741:	83 ec 0c             	sub    $0xc,%esp
  800744:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800748:	57                   	push   %edi
  800749:	ff 75 e0             	pushl  -0x20(%ebp)
  80074c:	51                   	push   %ecx
  80074d:	52                   	push   %edx
  80074e:	50                   	push   %eax
  80074f:	89 da                	mov    %ebx,%edx
  800751:	89 f0                	mov    %esi,%eax
  800753:	e8 70 fb ff ff       	call   8002c8 <printnum>
			break;
  800758:	83 c4 20             	add    $0x20,%esp
  80075b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075e:	e9 ae fc ff ff       	jmp    800411 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	51                   	push   %ecx
  800768:	ff d6                	call   *%esi
			break;
  80076a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800770:	e9 9c fc ff ff       	jmp    800411 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 25                	push   $0x25
  80077b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb 03                	jmp    800785 <vprintfmt+0x39a>
  800782:	83 ef 01             	sub    $0x1,%edi
  800785:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800789:	75 f7                	jne    800782 <vprintfmt+0x397>
  80078b:	e9 81 fc ff ff       	jmp    800411 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5f                   	pop    %edi
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 18             	sub    $0x18,%esp
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	74 26                	je     8007df <vsnprintf+0x47>
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	7e 22                	jle    8007df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bd:	ff 75 14             	pushl  0x14(%ebp)
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c6:	50                   	push   %eax
  8007c7:	68 b1 03 80 00       	push   $0x8003b1
  8007cc:	e8 1a fc ff ff       	call   8003eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb 05                	jmp    8007e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ef:	50                   	push   %eax
  8007f0:	ff 75 10             	pushl  0x10(%ebp)
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	ff 75 08             	pushl  0x8(%ebp)
  8007f9:	e8 9a ff ff ff       	call   800798 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 03                	jmp    800810 <strlen+0x10>
		n++;
  80080d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800814:	75 f7                	jne    80080d <strlen+0xd>
		n++;
	return n;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	eb 03                	jmp    80082b <strnlen+0x13>
		n++;
  800828:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 08                	je     800837 <strnlen+0x1f>
  80082f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800833:	75 f3                	jne    800828 <strnlen+0x10>
  800835:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	53                   	push   %ebx
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800843:	89 c2                	mov    %eax,%edx
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800852:	84 db                	test   %bl,%bl
  800854:	75 ef                	jne    800845 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800856:	5b                   	pop    %ebx
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800860:	53                   	push   %ebx
  800861:	e8 9a ff ff ff       	call   800800 <strlen>
  800866:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800869:	ff 75 0c             	pushl  0xc(%ebp)
  80086c:	01 d8                	add    %ebx,%eax
  80086e:	50                   	push   %eax
  80086f:	e8 c5 ff ff ff       	call   800839 <strcpy>
	return dst;
}
  800874:	89 d8                	mov    %ebx,%eax
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	8b 75 08             	mov    0x8(%ebp),%esi
  800883:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800886:	89 f3                	mov    %esi,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088b:	89 f2                	mov    %esi,%edx
  80088d:	eb 0f                	jmp    80089e <strncpy+0x23>
		*dst++ = *src;
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	0f b6 01             	movzbl (%ecx),%eax
  800895:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800898:	80 39 01             	cmpb   $0x1,(%ecx)
  80089b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089e:	39 da                	cmp    %ebx,%edx
  8008a0:	75 ed                	jne    80088f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	56                   	push   %esi
  8008ac:	53                   	push   %ebx
  8008ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b8:	85 d2                	test   %edx,%edx
  8008ba:	74 21                	je     8008dd <strlcpy+0x35>
  8008bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c0:	89 f2                	mov    %esi,%edx
  8008c2:	eb 09                	jmp    8008cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c4:	83 c2 01             	add    $0x1,%edx
  8008c7:	83 c1 01             	add    $0x1,%ecx
  8008ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cd:	39 c2                	cmp    %eax,%edx
  8008cf:	74 09                	je     8008da <strlcpy+0x32>
  8008d1:	0f b6 19             	movzbl (%ecx),%ebx
  8008d4:	84 db                	test   %bl,%bl
  8008d6:	75 ec                	jne    8008c4 <strlcpy+0x1c>
  8008d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008dd:	29 f0                	sub    %esi,%eax
}
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ec:	eb 06                	jmp    8008f4 <strcmp+0x11>
		p++, q++;
  8008ee:	83 c1 01             	add    $0x1,%ecx
  8008f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f4:	0f b6 01             	movzbl (%ecx),%eax
  8008f7:	84 c0                	test   %al,%al
  8008f9:	74 04                	je     8008ff <strcmp+0x1c>
  8008fb:	3a 02                	cmp    (%edx),%al
  8008fd:	74 ef                	je     8008ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 c0             	movzbl %al,%eax
  800902:	0f b6 12             	movzbl (%edx),%edx
  800905:	29 d0                	sub    %edx,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	53                   	push   %ebx
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
  800913:	89 c3                	mov    %eax,%ebx
  800915:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800918:	eb 06                	jmp    800920 <strncmp+0x17>
		n--, p++, q++;
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800920:	39 d8                	cmp    %ebx,%eax
  800922:	74 15                	je     800939 <strncmp+0x30>
  800924:	0f b6 08             	movzbl (%eax),%ecx
  800927:	84 c9                	test   %cl,%cl
  800929:	74 04                	je     80092f <strncmp+0x26>
  80092b:	3a 0a                	cmp    (%edx),%cl
  80092d:	74 eb                	je     80091a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092f:	0f b6 00             	movzbl (%eax),%eax
  800932:	0f b6 12             	movzbl (%edx),%edx
  800935:	29 d0                	sub    %edx,%eax
  800937:	eb 05                	jmp    80093e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094b:	eb 07                	jmp    800954 <strchr+0x13>
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 0f                	je     800960 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800951:	83 c0 01             	add    $0x1,%eax
  800954:	0f b6 10             	movzbl (%eax),%edx
  800957:	84 d2                	test   %dl,%dl
  800959:	75 f2                	jne    80094d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096c:	eb 03                	jmp    800971 <strfind+0xf>
  80096e:	83 c0 01             	add    $0x1,%eax
  800971:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800974:	38 ca                	cmp    %cl,%dl
  800976:	74 04                	je     80097c <strfind+0x1a>
  800978:	84 d2                	test   %dl,%dl
  80097a:	75 f2                	jne    80096e <strfind+0xc>
			break;
	return (char *) s;
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 7d 08             	mov    0x8(%ebp),%edi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098a:	85 c9                	test   %ecx,%ecx
  80098c:	74 36                	je     8009c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800994:	75 28                	jne    8009be <memset+0x40>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 23                	jne    8009be <memset+0x40>
		c &= 0xFF;
  80099b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099f:	89 d3                	mov    %edx,%ebx
  8009a1:	c1 e3 08             	shl    $0x8,%ebx
  8009a4:	89 d6                	mov    %edx,%esi
  8009a6:	c1 e6 18             	shl    $0x18,%esi
  8009a9:	89 d0                	mov    %edx,%eax
  8009ab:	c1 e0 10             	shl    $0x10,%eax
  8009ae:	09 f0                	or     %esi,%eax
  8009b0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009b2:	89 d8                	mov    %ebx,%eax
  8009b4:	09 d0                	or     %edx,%eax
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
  8009b9:	fc                   	cld    
  8009ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8009bc:	eb 06                	jmp    8009c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c1:	fc                   	cld    
  8009c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c4:	89 f8                	mov    %edi,%eax
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d9:	39 c6                	cmp    %eax,%esi
  8009db:	73 35                	jae    800a12 <memmove+0x47>
  8009dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e0:	39 d0                	cmp    %edx,%eax
  8009e2:	73 2e                	jae    800a12 <memmove+0x47>
		s += n;
		d += n;
  8009e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e7:	89 d6                	mov    %edx,%esi
  8009e9:	09 fe                	or     %edi,%esi
  8009eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f1:	75 13                	jne    800a06 <memmove+0x3b>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 0e                	jne    800a06 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f8:	83 ef 04             	sub    $0x4,%edi
  8009fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
  800a01:	fd                   	std    
  800a02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a04:	eb 09                	jmp    800a0f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a06:	83 ef 01             	sub    $0x1,%edi
  800a09:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a0c:	fd                   	std    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0f:	fc                   	cld    
  800a10:	eb 1d                	jmp    800a2f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a12:	89 f2                	mov    %esi,%edx
  800a14:	09 c2                	or     %eax,%edx
  800a16:	f6 c2 03             	test   $0x3,%dl
  800a19:	75 0f                	jne    800a2a <memmove+0x5f>
  800a1b:	f6 c1 03             	test   $0x3,%cl
  800a1e:	75 0a                	jne    800a2a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a20:	c1 e9 02             	shr    $0x2,%ecx
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a28:	eb 05                	jmp    800a2f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	fc                   	cld    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a36:	ff 75 10             	pushl  0x10(%ebp)
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	ff 75 08             	pushl  0x8(%ebp)
  800a3f:	e8 87 ff ff ff       	call   8009cb <memmove>
}
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a51:	89 c6                	mov    %eax,%esi
  800a53:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a56:	eb 1a                	jmp    800a72 <memcmp+0x2c>
		if (*s1 != *s2)
  800a58:	0f b6 08             	movzbl (%eax),%ecx
  800a5b:	0f b6 1a             	movzbl (%edx),%ebx
  800a5e:	38 d9                	cmp    %bl,%cl
  800a60:	74 0a                	je     800a6c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a62:	0f b6 c1             	movzbl %cl,%eax
  800a65:	0f b6 db             	movzbl %bl,%ebx
  800a68:	29 d8                	sub    %ebx,%eax
  800a6a:	eb 0f                	jmp    800a7b <memcmp+0x35>
		s1++, s2++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a72:	39 f0                	cmp    %esi,%eax
  800a74:	75 e2                	jne    800a58 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a86:	89 c1                	mov    %eax,%ecx
  800a88:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8f:	eb 0a                	jmp    800a9b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a91:	0f b6 10             	movzbl (%eax),%edx
  800a94:	39 da                	cmp    %ebx,%edx
  800a96:	74 07                	je     800a9f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	39 c8                	cmp    %ecx,%eax
  800a9d:	72 f2                	jb     800a91 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	eb 03                	jmp    800ab3 <strtol+0x11>
		s++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab3:	0f b6 01             	movzbl (%ecx),%eax
  800ab6:	3c 20                	cmp    $0x20,%al
  800ab8:	74 f6                	je     800ab0 <strtol+0xe>
  800aba:	3c 09                	cmp    $0x9,%al
  800abc:	74 f2                	je     800ab0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abe:	3c 2b                	cmp    $0x2b,%al
  800ac0:	75 0a                	jne    800acc <strtol+0x2a>
		s++;
  800ac2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aca:	eb 11                	jmp    800add <strtol+0x3b>
  800acc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad1:	3c 2d                	cmp    $0x2d,%al
  800ad3:	75 08                	jne    800add <strtol+0x3b>
		s++, neg = 1;
  800ad5:	83 c1 01             	add    $0x1,%ecx
  800ad8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800add:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae3:	75 15                	jne    800afa <strtol+0x58>
  800ae5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae8:	75 10                	jne    800afa <strtol+0x58>
  800aea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aee:	75 7c                	jne    800b6c <strtol+0xca>
		s += 2, base = 16;
  800af0:	83 c1 02             	add    $0x2,%ecx
  800af3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af8:	eb 16                	jmp    800b10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800afa:	85 db                	test   %ebx,%ebx
  800afc:	75 12                	jne    800b10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b03:	80 39 30             	cmpb   $0x30,(%ecx)
  800b06:	75 08                	jne    800b10 <strtol+0x6e>
		s++, base = 8;
  800b08:	83 c1 01             	add    $0x1,%ecx
  800b0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b10:	b8 00 00 00 00       	mov    $0x0,%eax
  800b15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b18:	0f b6 11             	movzbl (%ecx),%edx
  800b1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1e:	89 f3                	mov    %esi,%ebx
  800b20:	80 fb 09             	cmp    $0x9,%bl
  800b23:	77 08                	ja     800b2d <strtol+0x8b>
			dig = *s - '0';
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	83 ea 30             	sub    $0x30,%edx
  800b2b:	eb 22                	jmp    800b4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b30:	89 f3                	mov    %esi,%ebx
  800b32:	80 fb 19             	cmp    $0x19,%bl
  800b35:	77 08                	ja     800b3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b37:	0f be d2             	movsbl %dl,%edx
  800b3a:	83 ea 57             	sub    $0x57,%edx
  800b3d:	eb 10                	jmp    800b4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b42:	89 f3                	mov    %esi,%ebx
  800b44:	80 fb 19             	cmp    $0x19,%bl
  800b47:	77 16                	ja     800b5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b49:	0f be d2             	movsbl %dl,%edx
  800b4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b52:	7d 0b                	jge    800b5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5d:	eb b9                	jmp    800b18 <strtol+0x76>

	if (endptr)
  800b5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b63:	74 0d                	je     800b72 <strtol+0xd0>
		*endptr = (char *) s;
  800b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b68:	89 0e                	mov    %ecx,(%esi)
  800b6a:	eb 06                	jmp    800b72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	85 db                	test   %ebx,%ebx
  800b6e:	74 98                	je     800b08 <strtol+0x66>
  800b70:	eb 9e                	jmp    800b10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b72:	89 c2                	mov    %eax,%edx
  800b74:	f7 da                	neg    %edx
  800b76:	85 ff                	test   %edi,%edi
  800b78:	0f 45 c2             	cmovne %edx,%eax
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	89 c6                	mov    %eax,%esi
  800b97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	89 cb                	mov    %ecx,%ebx
  800bd5:	89 cf                	mov    %ecx,%edi
  800bd7:	89 ce                	mov    %ecx,%esi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 03                	push   $0x3
  800be5:	68 7f 23 80 00       	push   $0x80237f
  800bea:	6a 23                	push   $0x23
  800bec:	68 9c 23 80 00       	push   $0x80239c
  800bf1:	e8 e5 f5 ff ff       	call   8001db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_yield>:

void
sys_yield(void)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	ba 00 00 00 00       	mov    $0x0,%edx
  800c28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2d:	89 d1                	mov    %edx,%ecx
  800c2f:	89 d3                	mov    %edx,%ebx
  800c31:	89 d7                	mov    %edx,%edi
  800c33:	89 d6                	mov    %edx,%esi
  800c35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	be 00 00 00 00       	mov    $0x0,%esi
  800c4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	89 f7                	mov    %esi,%edi
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 04                	push   $0x4
  800c66:	68 7f 23 80 00       	push   $0x80237f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 9c 23 80 00       	push   $0x80239c
  800c72:	e8 64 f5 ff ff       	call   8001db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c99:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 05                	push   $0x5
  800ca8:	68 7f 23 80 00       	push   $0x80237f
  800cad:	6a 23                	push   $0x23
  800caf:	68 9c 23 80 00       	push   $0x80239c
  800cb4:	e8 22 f5 ff ff       	call   8001db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 06                	push   $0x6
  800cea:	68 7f 23 80 00       	push   $0x80237f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 9c 23 80 00       	push   $0x80239c
  800cf6:	e8 e0 f4 ff ff       	call   8001db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 08 00 00 00       	mov    $0x8,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 08                	push   $0x8
  800d2c:	68 7f 23 80 00       	push   $0x80237f
  800d31:	6a 23                	push   $0x23
  800d33:	68 9c 23 80 00       	push   $0x80239c
  800d38:	e8 9e f4 ff ff       	call   8001db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d53:	b8 09 00 00 00       	mov    $0x9,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	89 df                	mov    %ebx,%edi
  800d60:	89 de                	mov    %ebx,%esi
  800d62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7e 17                	jle    800d7f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	50                   	push   %eax
  800d6c:	6a 09                	push   $0x9
  800d6e:	68 7f 23 80 00       	push   $0x80237f
  800d73:	6a 23                	push   $0x23
  800d75:	68 9c 23 80 00       	push   $0x80239c
  800d7a:	e8 5c f4 ff ff       	call   8001db <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 df                	mov    %ebx,%edi
  800da2:	89 de                	mov    %ebx,%esi
  800da4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da6:	85 c0                	test   %eax,%eax
  800da8:	7e 17                	jle    800dc1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	50                   	push   %eax
  800dae:	6a 0a                	push   $0xa
  800db0:	68 7f 23 80 00       	push   $0x80237f
  800db5:	6a 23                	push   $0x23
  800db7:	68 9c 23 80 00       	push   $0x80239c
  800dbc:	e8 1a f4 ff ff       	call   8001db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	be 00 00 00 00       	mov    $0x0,%esi
  800dd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	89 cb                	mov    %ecx,%ebx
  800e04:	89 cf                	mov    %ecx,%edi
  800e06:	89 ce                	mov    %ecx,%esi
  800e08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 17                	jle    800e25 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 0d                	push   $0xd
  800e14:	68 7f 23 80 00       	push   $0x80237f
  800e19:	6a 23                	push   $0x23
  800e1b:	68 9c 23 80 00       	push   $0x80239c
  800e20:	e8 b6 f3 ff ff       	call   8001db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	05 00 00 00 30       	add    $0x30000000,%eax
  800e38:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	05 00 00 00 30       	add    $0x30000000,%eax
  800e48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	c1 ea 16             	shr    $0x16,%edx
  800e64:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6b:	f6 c2 01             	test   $0x1,%dl
  800e6e:	74 11                	je     800e81 <fd_alloc+0x2d>
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	c1 ea 0c             	shr    $0xc,%edx
  800e75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	75 09                	jne    800e8a <fd_alloc+0x36>
			*fd_store = fd;
  800e81:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
  800e88:	eb 17                	jmp    800ea1 <fd_alloc+0x4d>
  800e8a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e8f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e94:	75 c9                	jne    800e5f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e96:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea9:	83 f8 1f             	cmp    $0x1f,%eax
  800eac:	77 36                	ja     800ee4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eae:	c1 e0 0c             	shl    $0xc,%eax
  800eb1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	c1 ea 16             	shr    $0x16,%edx
  800ebb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec2:	f6 c2 01             	test   $0x1,%dl
  800ec5:	74 24                	je     800eeb <fd_lookup+0x48>
  800ec7:	89 c2                	mov    %eax,%edx
  800ec9:	c1 ea 0c             	shr    $0xc,%edx
  800ecc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed3:	f6 c2 01             	test   $0x1,%dl
  800ed6:	74 1a                	je     800ef2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edb:	89 02                	mov    %eax,(%edx)
	return 0;
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	eb 13                	jmp    800ef7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee9:	eb 0c                	jmp    800ef7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef0:	eb 05                	jmp    800ef7 <fd_lookup+0x54>
  800ef2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 08             	sub    $0x8,%esp
  800eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f02:	ba 2c 24 80 00       	mov    $0x80242c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f07:	eb 13                	jmp    800f1c <dev_lookup+0x23>
  800f09:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0c:	39 08                	cmp    %ecx,(%eax)
  800f0e:	75 0c                	jne    800f1c <dev_lookup+0x23>
			*dev = devtab[i];
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	eb 2e                	jmp    800f4a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1c:	8b 02                	mov    (%edx),%eax
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	75 e7                	jne    800f09 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f22:	a1 20 60 80 00       	mov    0x806020,%eax
  800f27:	8b 40 48             	mov    0x48(%eax),%eax
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	51                   	push   %ecx
  800f2e:	50                   	push   %eax
  800f2f:	68 ac 23 80 00       	push   $0x8023ac
  800f34:	e8 7b f3 ff ff       	call   8002b4 <cprintf>
	*dev = 0;
  800f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 10             	sub    $0x10,%esp
  800f54:	8b 75 08             	mov    0x8(%ebp),%esi
  800f57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5d:	50                   	push   %eax
  800f5e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f64:	c1 e8 0c             	shr    $0xc,%eax
  800f67:	50                   	push   %eax
  800f68:	e8 36 ff ff ff       	call   800ea3 <fd_lookup>
  800f6d:	83 c4 08             	add    $0x8,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 05                	js     800f79 <fd_close+0x2d>
	    || fd != fd2)
  800f74:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f77:	74 0c                	je     800f85 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f79:	84 db                	test   %bl,%bl
  800f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f80:	0f 44 c2             	cmove  %edx,%eax
  800f83:	eb 41                	jmp    800fc6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	ff 36                	pushl  (%esi)
  800f8e:	e8 66 ff ff ff       	call   800ef9 <dev_lookup>
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 1a                	js     800fb6 <fd_close+0x6a>
		if (dev->dev_close)
  800f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f9f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	74 0b                	je     800fb6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	56                   	push   %esi
  800faf:	ff d0                	call   *%eax
  800fb1:	89 c3                	mov    %eax,%ebx
  800fb3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb6:	83 ec 08             	sub    $0x8,%esp
  800fb9:	56                   	push   %esi
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 00 fd ff ff       	call   800cc1 <sys_page_unmap>
	return r;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	89 d8                	mov    %ebx,%eax
}
  800fc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd6:	50                   	push   %eax
  800fd7:	ff 75 08             	pushl  0x8(%ebp)
  800fda:	e8 c4 fe ff ff       	call   800ea3 <fd_lookup>
  800fdf:	83 c4 08             	add    $0x8,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 10                	js     800ff6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe6:	83 ec 08             	sub    $0x8,%esp
  800fe9:	6a 01                	push   $0x1
  800feb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fee:	e8 59 ff ff ff       	call   800f4c <fd_close>
  800ff3:	83 c4 10             	add    $0x10,%esp
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <close_all>:

void
close_all(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	53                   	push   %ebx
  801008:	e8 c0 ff ff ff       	call   800fcd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80100d:	83 c3 01             	add    $0x1,%ebx
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	83 fb 20             	cmp    $0x20,%ebx
  801016:	75 ec                	jne    801004 <close_all+0xc>
		close(i);
}
  801018:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	57                   	push   %edi
  801021:	56                   	push   %esi
  801022:	53                   	push   %ebx
  801023:	83 ec 2c             	sub    $0x2c,%esp
  801026:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801029:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	ff 75 08             	pushl  0x8(%ebp)
  801030:	e8 6e fe ff ff       	call   800ea3 <fd_lookup>
  801035:	83 c4 08             	add    $0x8,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	0f 88 c1 00 00 00    	js     801101 <dup+0xe4>
		return r;
	close(newfdnum);
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	56                   	push   %esi
  801044:	e8 84 ff ff ff       	call   800fcd <close>

	newfd = INDEX2FD(newfdnum);
  801049:	89 f3                	mov    %esi,%ebx
  80104b:	c1 e3 0c             	shl    $0xc,%ebx
  80104e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801054:	83 c4 04             	add    $0x4,%esp
  801057:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105a:	e8 de fd ff ff       	call   800e3d <fd2data>
  80105f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801061:	89 1c 24             	mov    %ebx,(%esp)
  801064:	e8 d4 fd ff ff       	call   800e3d <fd2data>
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80106f:	89 f8                	mov    %edi,%eax
  801071:	c1 e8 16             	shr    $0x16,%eax
  801074:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107b:	a8 01                	test   $0x1,%al
  80107d:	74 37                	je     8010b6 <dup+0x99>
  80107f:	89 f8                	mov    %edi,%eax
  801081:	c1 e8 0c             	shr    $0xc,%eax
  801084:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108b:	f6 c2 01             	test   $0x1,%dl
  80108e:	74 26                	je     8010b6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801090:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	25 07 0e 00 00       	and    $0xe07,%eax
  80109f:	50                   	push   %eax
  8010a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a3:	6a 00                	push   $0x0
  8010a5:	57                   	push   %edi
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 d2 fb ff ff       	call   800c7f <sys_page_map>
  8010ad:	89 c7                	mov    %eax,%edi
  8010af:	83 c4 20             	add    $0x20,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	78 2e                	js     8010e4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010b9:	89 d0                	mov    %edx,%eax
  8010bb:	c1 e8 0c             	shr    $0xc,%eax
  8010be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cd:	50                   	push   %eax
  8010ce:	53                   	push   %ebx
  8010cf:	6a 00                	push   $0x0
  8010d1:	52                   	push   %edx
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 a6 fb ff ff       	call   800c7f <sys_page_map>
  8010d9:	89 c7                	mov    %eax,%edi
  8010db:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010de:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e0:	85 ff                	test   %edi,%edi
  8010e2:	79 1d                	jns    801101 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	53                   	push   %ebx
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 d2 fb ff ff       	call   800cc1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f5:	6a 00                	push   $0x0
  8010f7:	e8 c5 fb ff ff       	call   800cc1 <sys_page_unmap>
	return r;
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	89 f8                	mov    %edi,%eax
}
  801101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	53                   	push   %ebx
  80110d:	83 ec 14             	sub    $0x14,%esp
  801110:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801113:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	53                   	push   %ebx
  801118:	e8 86 fd ff ff       	call   800ea3 <fd_lookup>
  80111d:	83 c4 08             	add    $0x8,%esp
  801120:	89 c2                	mov    %eax,%edx
  801122:	85 c0                	test   %eax,%eax
  801124:	78 6d                	js     801193 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112c:	50                   	push   %eax
  80112d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801130:	ff 30                	pushl  (%eax)
  801132:	e8 c2 fd ff ff       	call   800ef9 <dev_lookup>
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 4c                	js     80118a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80113e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801141:	8b 42 08             	mov    0x8(%edx),%eax
  801144:	83 e0 03             	and    $0x3,%eax
  801147:	83 f8 01             	cmp    $0x1,%eax
  80114a:	75 21                	jne    80116d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114c:	a1 20 60 80 00       	mov    0x806020,%eax
  801151:	8b 40 48             	mov    0x48(%eax),%eax
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	53                   	push   %ebx
  801158:	50                   	push   %eax
  801159:	68 f0 23 80 00       	push   $0x8023f0
  80115e:	e8 51 f1 ff ff       	call   8002b4 <cprintf>
		return -E_INVAL;
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116b:	eb 26                	jmp    801193 <read+0x8a>
	}
	if (!dev->dev_read)
  80116d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801170:	8b 40 08             	mov    0x8(%eax),%eax
  801173:	85 c0                	test   %eax,%eax
  801175:	74 17                	je     80118e <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	ff 75 10             	pushl  0x10(%ebp)
  80117d:	ff 75 0c             	pushl  0xc(%ebp)
  801180:	52                   	push   %edx
  801181:	ff d0                	call   *%eax
  801183:	89 c2                	mov    %eax,%edx
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	eb 09                	jmp    801193 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	eb 05                	jmp    801193 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80118e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801193:	89 d0                	mov    %edx,%eax
  801195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801198:	c9                   	leave  
  801199:	c3                   	ret    

0080119a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	57                   	push   %edi
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ae:	eb 21                	jmp    8011d1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b0:	83 ec 04             	sub    $0x4,%esp
  8011b3:	89 f0                	mov    %esi,%eax
  8011b5:	29 d8                	sub    %ebx,%eax
  8011b7:	50                   	push   %eax
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	03 45 0c             	add    0xc(%ebp),%eax
  8011bd:	50                   	push   %eax
  8011be:	57                   	push   %edi
  8011bf:	e8 45 ff ff ff       	call   801109 <read>
		if (m < 0)
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 10                	js     8011db <readn+0x41>
			return m;
		if (m == 0)
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	74 0a                	je     8011d9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cf:	01 c3                	add    %eax,%ebx
  8011d1:	39 f3                	cmp    %esi,%ebx
  8011d3:	72 db                	jb     8011b0 <readn+0x16>
  8011d5:	89 d8                	mov    %ebx,%eax
  8011d7:	eb 02                	jmp    8011db <readn+0x41>
  8011d9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 14             	sub    $0x14,%esp
  8011ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	53                   	push   %ebx
  8011f2:	e8 ac fc ff ff       	call   800ea3 <fd_lookup>
  8011f7:	83 c4 08             	add    $0x8,%esp
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 68                	js     801268 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801200:	83 ec 08             	sub    $0x8,%esp
  801203:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	ff 30                	pushl  (%eax)
  80120c:	e8 e8 fc ff ff       	call   800ef9 <dev_lookup>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 47                	js     80125f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121f:	75 21                	jne    801242 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801221:	a1 20 60 80 00       	mov    0x806020,%eax
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	53                   	push   %ebx
  80122d:	50                   	push   %eax
  80122e:	68 0c 24 80 00       	push   $0x80240c
  801233:	e8 7c f0 ff ff       	call   8002b4 <cprintf>
		return -E_INVAL;
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801240:	eb 26                	jmp    801268 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801242:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801245:	8b 52 0c             	mov    0xc(%edx),%edx
  801248:	85 d2                	test   %edx,%edx
  80124a:	74 17                	je     801263 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	ff 75 10             	pushl  0x10(%ebp)
  801252:	ff 75 0c             	pushl  0xc(%ebp)
  801255:	50                   	push   %eax
  801256:	ff d2                	call   *%edx
  801258:	89 c2                	mov    %eax,%edx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	eb 09                	jmp    801268 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	89 c2                	mov    %eax,%edx
  801261:	eb 05                	jmp    801268 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801263:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801268:	89 d0                	mov    %edx,%eax
  80126a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <seek>:

int
seek(int fdnum, off_t offset)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801275:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	ff 75 08             	pushl  0x8(%ebp)
  80127c:	e8 22 fc ff ff       	call   800ea3 <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 0e                	js     801296 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801288:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 14             	sub    $0x14,%esp
  80129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	53                   	push   %ebx
  8012a7:	e8 f7 fb ff ff       	call   800ea3 <fd_lookup>
  8012ac:	83 c4 08             	add    $0x8,%esp
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 65                	js     80131a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	ff 30                	pushl  (%eax)
  8012c1:	e8 33 fc ff ff       	call   800ef9 <dev_lookup>
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 44                	js     801311 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d4:	75 21                	jne    8012f7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d6:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012db:	8b 40 48             	mov    0x48(%eax),%eax
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	53                   	push   %ebx
  8012e2:	50                   	push   %eax
  8012e3:	68 cc 23 80 00       	push   $0x8023cc
  8012e8:	e8 c7 ef ff ff       	call   8002b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f5:	eb 23                	jmp    80131a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fa:	8b 52 18             	mov    0x18(%edx),%edx
  8012fd:	85 d2                	test   %edx,%edx
  8012ff:	74 14                	je     801315 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	ff 75 0c             	pushl  0xc(%ebp)
  801307:	50                   	push   %eax
  801308:	ff d2                	call   *%edx
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	eb 09                	jmp    80131a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801311:	89 c2                	mov    %eax,%edx
  801313:	eb 05                	jmp    80131a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801315:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131a:	89 d0                	mov    %edx,%eax
  80131c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	53                   	push   %ebx
  801325:	83 ec 14             	sub    $0x14,%esp
  801328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 08             	pushl  0x8(%ebp)
  801332:	e8 6c fb ff ff       	call   800ea3 <fd_lookup>
  801337:	83 c4 08             	add    $0x8,%esp
  80133a:	89 c2                	mov    %eax,%edx
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 58                	js     801398 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134a:	ff 30                	pushl  (%eax)
  80134c:	e8 a8 fb ff ff       	call   800ef9 <dev_lookup>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	78 37                	js     80138f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80135f:	74 32                	je     801393 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801361:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801364:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136b:	00 00 00 
	stat->st_isdir = 0;
  80136e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801375:	00 00 00 
	stat->st_dev = dev;
  801378:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	53                   	push   %ebx
  801382:	ff 75 f0             	pushl  -0x10(%ebp)
  801385:	ff 50 14             	call   *0x14(%eax)
  801388:	89 c2                	mov    %eax,%edx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	eb 09                	jmp    801398 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	89 c2                	mov    %eax,%edx
  801391:	eb 05                	jmp    801398 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801393:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801398:	89 d0                	mov    %edx,%eax
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	6a 00                	push   $0x0
  8013a9:	ff 75 08             	pushl  0x8(%ebp)
  8013ac:	e8 e3 01 00 00       	call   801594 <open>
  8013b1:	89 c3                	mov    %eax,%ebx
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 1b                	js     8013d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	ff 75 0c             	pushl  0xc(%ebp)
  8013c0:	50                   	push   %eax
  8013c1:	e8 5b ff ff ff       	call   801321 <fstat>
  8013c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c8:	89 1c 24             	mov    %ebx,(%esp)
  8013cb:	e8 fd fb ff ff       	call   800fcd <close>
	return r;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	89 f0                	mov    %esi,%eax
}
  8013d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	89 c6                	mov    %eax,%esi
  8013e3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ec:	75 12                	jne    801400 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	6a 01                	push   $0x1
  8013f3:	e8 03 09 00 00       	call   801cfb <ipc_find_env>
  8013f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801400:	6a 07                	push   $0x7
  801402:	68 00 70 80 00       	push   $0x807000
  801407:	56                   	push   %esi
  801408:	ff 35 00 40 80 00    	pushl  0x804000
  80140e:	e8 86 08 00 00       	call   801c99 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801413:	83 c4 0c             	add    $0xc,%esp
  801416:	6a 00                	push   $0x0
  801418:	53                   	push   %ebx
  801419:	6a 00                	push   $0x0
  80141b:	e8 07 08 00 00       	call   801c27 <ipc_recv>
}
  801420:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	8b 40 0c             	mov    0xc(%eax),%eax
  801433:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801438:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143b:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801440:	ba 00 00 00 00       	mov    $0x0,%edx
  801445:	b8 02 00 00 00       	mov    $0x2,%eax
  80144a:	e8 8d ff ff ff       	call   8013dc <fsipc>
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	8b 40 0c             	mov    0xc(%eax),%eax
  80145d:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801462:	ba 00 00 00 00       	mov    $0x0,%edx
  801467:	b8 06 00 00 00       	mov    $0x6,%eax
  80146c:	e8 6b ff ff ff       	call   8013dc <fsipc>
}
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	8b 40 0c             	mov    0xc(%eax),%eax
  801483:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801488:	ba 00 00 00 00       	mov    $0x0,%edx
  80148d:	b8 05 00 00 00       	mov    $0x5,%eax
  801492:	e8 45 ff ff ff       	call   8013dc <fsipc>
  801497:	85 c0                	test   %eax,%eax
  801499:	78 2c                	js     8014c7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	68 00 70 80 00       	push   $0x807000
  8014a3:	53                   	push   %ebx
  8014a4:	e8 90 f3 ff ff       	call   800839 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a9:	a1 80 70 80 00       	mov    0x807080,%eax
  8014ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b4:	a1 84 70 80 00       	mov    0x807084,%eax
  8014b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014db:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014e6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014eb:	0f 47 c2             	cmova  %edx,%eax
  8014ee:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014f3:	50                   	push   %eax
  8014f4:	ff 75 0c             	pushl  0xc(%ebp)
  8014f7:	68 08 70 80 00       	push   $0x807008
  8014fc:	e8 ca f4 ff ff       	call   8009cb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801501:	ba 00 00 00 00       	mov    $0x0,%edx
  801506:	b8 04 00 00 00       	mov    $0x4,%eax
  80150b:	e8 cc fe ff ff       	call   8013dc <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	8b 40 0c             	mov    0xc(%eax),%eax
  801520:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801525:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152b:	ba 00 00 00 00       	mov    $0x0,%edx
  801530:	b8 03 00 00 00       	mov    $0x3,%eax
  801535:	e8 a2 fe ff ff       	call   8013dc <fsipc>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 4b                	js     80158b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801540:	39 c6                	cmp    %eax,%esi
  801542:	73 16                	jae    80155a <devfile_read+0x48>
  801544:	68 3c 24 80 00       	push   $0x80243c
  801549:	68 43 24 80 00       	push   $0x802443
  80154e:	6a 7c                	push   $0x7c
  801550:	68 58 24 80 00       	push   $0x802458
  801555:	e8 81 ec ff ff       	call   8001db <_panic>
	assert(r <= PGSIZE);
  80155a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80155f:	7e 16                	jle    801577 <devfile_read+0x65>
  801561:	68 63 24 80 00       	push   $0x802463
  801566:	68 43 24 80 00       	push   $0x802443
  80156b:	6a 7d                	push   $0x7d
  80156d:	68 58 24 80 00       	push   $0x802458
  801572:	e8 64 ec ff ff       	call   8001db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	50                   	push   %eax
  80157b:	68 00 70 80 00       	push   $0x807000
  801580:	ff 75 0c             	pushl  0xc(%ebp)
  801583:	e8 43 f4 ff ff       	call   8009cb <memmove>
	return r;
  801588:	83 c4 10             	add    $0x10,%esp
}
  80158b:	89 d8                	mov    %ebx,%eax
  80158d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801590:	5b                   	pop    %ebx
  801591:	5e                   	pop    %esi
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	53                   	push   %ebx
  801598:	83 ec 20             	sub    $0x20,%esp
  80159b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80159e:	53                   	push   %ebx
  80159f:	e8 5c f2 ff ff       	call   800800 <strlen>
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ac:	7f 67                	jg     801615 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	e8 9a f8 ff ff       	call   800e54 <fd_alloc>
  8015ba:	83 c4 10             	add    $0x10,%esp
		return r;
  8015bd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 57                	js     80161a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	68 00 70 80 00       	push   $0x807000
  8015cc:	e8 68 f2 ff ff       	call   800839 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d4:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e1:	e8 f6 fd ff ff       	call   8013dc <fsipc>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	79 14                	jns    801603 <open+0x6f>
		fd_close(fd, 0);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	6a 00                	push   $0x0
  8015f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f7:	e8 50 f9 ff ff       	call   800f4c <fd_close>
		return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 da                	mov    %ebx,%edx
  801601:	eb 17                	jmp    80161a <open+0x86>
	}

	return fd2num(fd);
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	ff 75 f4             	pushl  -0xc(%ebp)
  801609:	e8 1f f8 ff ff       	call   800e2d <fd2num>
  80160e:	89 c2                	mov    %eax,%edx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	eb 05                	jmp    80161a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801615:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161a:	89 d0                	mov    %edx,%eax
  80161c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801627:	ba 00 00 00 00       	mov    $0x0,%edx
  80162c:	b8 08 00 00 00       	mov    $0x8,%eax
  801631:	e8 a6 fd ff ff       	call   8013dc <fsipc>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801638:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80163c:	7e 37                	jle    801675 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801647:	ff 70 04             	pushl  0x4(%eax)
  80164a:	8d 40 10             	lea    0x10(%eax),%eax
  80164d:	50                   	push   %eax
  80164e:	ff 33                	pushl  (%ebx)
  801650:	e8 8e fb ff ff       	call   8011e3 <write>
		if (result > 0)
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	85 c0                	test   %eax,%eax
  80165a:	7e 03                	jle    80165f <writebuf+0x27>
			b->result += result;
  80165c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80165f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801662:	74 0d                	je     801671 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801664:	85 c0                	test   %eax,%eax
  801666:	ba 00 00 00 00       	mov    $0x0,%edx
  80166b:	0f 4f c2             	cmovg  %edx,%eax
  80166e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801671:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801674:	c9                   	leave  
  801675:	f3 c3                	repz ret 

00801677 <putch>:

static void
putch(int ch, void *thunk)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801681:	8b 53 04             	mov    0x4(%ebx),%edx
  801684:	8d 42 01             	lea    0x1(%edx),%eax
  801687:	89 43 04             	mov    %eax,0x4(%ebx)
  80168a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168d:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801691:	3d 00 01 00 00       	cmp    $0x100,%eax
  801696:	75 0e                	jne    8016a6 <putch+0x2f>
		writebuf(b);
  801698:	89 d8                	mov    %ebx,%eax
  80169a:	e8 99 ff ff ff       	call   801638 <writebuf>
		b->idx = 0;
  80169f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016a6:	83 c4 04             	add    $0x4,%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016be:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016c5:	00 00 00 
	b.result = 0;
  8016c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016cf:	00 00 00 
	b.error = 1;
  8016d2:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016d9:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016dc:	ff 75 10             	pushl  0x10(%ebp)
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	68 77 16 80 00       	push   $0x801677
  8016ee:	e8 f8 ec ff ff       	call   8003eb <vprintfmt>
	if (b.idx > 0)
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016fd:	7e 0b                	jle    80170a <vfprintf+0x5e>
		writebuf(&b);
  8016ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801705:	e8 2e ff ff ff       	call   801638 <writebuf>

	return (b.result ? b.result : b.error);
  80170a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801710:	85 c0                	test   %eax,%eax
  801712:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801721:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801724:	50                   	push   %eax
  801725:	ff 75 0c             	pushl  0xc(%ebp)
  801728:	ff 75 08             	pushl  0x8(%ebp)
  80172b:	e8 7c ff ff ff       	call   8016ac <vfprintf>
	va_end(ap);

	return cnt;
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <printf>:

int
printf(const char *fmt, ...)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801738:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80173b:	50                   	push   %eax
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	6a 01                	push   $0x1
  801741:	e8 66 ff ff ff       	call   8016ac <vfprintf>
	va_end(ap);

	return cnt;
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	56                   	push   %esi
  80174c:	53                   	push   %ebx
  80174d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	ff 75 08             	pushl  0x8(%ebp)
  801756:	e8 e2 f6 ff ff       	call   800e3d <fd2data>
  80175b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80175d:	83 c4 08             	add    $0x8,%esp
  801760:	68 6f 24 80 00       	push   $0x80246f
  801765:	53                   	push   %ebx
  801766:	e8 ce f0 ff ff       	call   800839 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80176b:	8b 46 04             	mov    0x4(%esi),%eax
  80176e:	2b 06                	sub    (%esi),%eax
  801770:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801776:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80177d:	00 00 00 
	stat->st_dev = &devpipe;
  801780:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801787:	30 80 00 
	return 0;
}
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
  80178f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 0c             	sub    $0xc,%esp
  80179d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017a0:	53                   	push   %ebx
  8017a1:	6a 00                	push   $0x0
  8017a3:	e8 19 f5 ff ff       	call   800cc1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017a8:	89 1c 24             	mov    %ebx,(%esp)
  8017ab:	e8 8d f6 ff ff       	call   800e3d <fd2data>
  8017b0:	83 c4 08             	add    $0x8,%esp
  8017b3:	50                   	push   %eax
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 06 f5 ff ff       	call   800cc1 <sys_page_unmap>
}
  8017bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	57                   	push   %edi
  8017c4:	56                   	push   %esi
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 1c             	sub    $0x1c,%esp
  8017c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017cc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017ce:	a1 20 60 80 00       	mov    0x806020,%eax
  8017d3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017d6:	83 ec 0c             	sub    $0xc,%esp
  8017d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8017dc:	e8 53 05 00 00       	call   801d34 <pageref>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	89 3c 24             	mov    %edi,(%esp)
  8017e6:	e8 49 05 00 00       	call   801d34 <pageref>
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	39 c3                	cmp    %eax,%ebx
  8017f0:	0f 94 c1             	sete   %cl
  8017f3:	0f b6 c9             	movzbl %cl,%ecx
  8017f6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017f9:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8017ff:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801802:	39 ce                	cmp    %ecx,%esi
  801804:	74 1b                	je     801821 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801806:	39 c3                	cmp    %eax,%ebx
  801808:	75 c4                	jne    8017ce <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80180a:	8b 42 58             	mov    0x58(%edx),%eax
  80180d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801810:	50                   	push   %eax
  801811:	56                   	push   %esi
  801812:	68 76 24 80 00       	push   $0x802476
  801817:	e8 98 ea ff ff       	call   8002b4 <cprintf>
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	eb ad                	jmp    8017ce <_pipeisclosed+0xe>
	}
}
  801821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801824:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801827:	5b                   	pop    %ebx
  801828:	5e                   	pop    %esi
  801829:	5f                   	pop    %edi
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	57                   	push   %edi
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
  801832:	83 ec 28             	sub    $0x28,%esp
  801835:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801838:	56                   	push   %esi
  801839:	e8 ff f5 ff ff       	call   800e3d <fd2data>
  80183e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	bf 00 00 00 00       	mov    $0x0,%edi
  801848:	eb 4b                	jmp    801895 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80184a:	89 da                	mov    %ebx,%edx
  80184c:	89 f0                	mov    %esi,%eax
  80184e:	e8 6d ff ff ff       	call   8017c0 <_pipeisclosed>
  801853:	85 c0                	test   %eax,%eax
  801855:	75 48                	jne    80189f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801857:	e8 c1 f3 ff ff       	call   800c1d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80185c:	8b 43 04             	mov    0x4(%ebx),%eax
  80185f:	8b 0b                	mov    (%ebx),%ecx
  801861:	8d 51 20             	lea    0x20(%ecx),%edx
  801864:	39 d0                	cmp    %edx,%eax
  801866:	73 e2                	jae    80184a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80186f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801872:	89 c2                	mov    %eax,%edx
  801874:	c1 fa 1f             	sar    $0x1f,%edx
  801877:	89 d1                	mov    %edx,%ecx
  801879:	c1 e9 1b             	shr    $0x1b,%ecx
  80187c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80187f:	83 e2 1f             	and    $0x1f,%edx
  801882:	29 ca                	sub    %ecx,%edx
  801884:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801888:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80188c:	83 c0 01             	add    $0x1,%eax
  80188f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801892:	83 c7 01             	add    $0x1,%edi
  801895:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801898:	75 c2                	jne    80185c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80189a:	8b 45 10             	mov    0x10(%ebp),%eax
  80189d:	eb 05                	jmp    8018a4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5e                   	pop    %esi
  8018a9:	5f                   	pop    %edi
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    

008018ac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	57                   	push   %edi
  8018b0:	56                   	push   %esi
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 18             	sub    $0x18,%esp
  8018b5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018b8:	57                   	push   %edi
  8018b9:	e8 7f f5 ff ff       	call   800e3d <fd2data>
  8018be:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018c8:	eb 3d                	jmp    801907 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018ca:	85 db                	test   %ebx,%ebx
  8018cc:	74 04                	je     8018d2 <devpipe_read+0x26>
				return i;
  8018ce:	89 d8                	mov    %ebx,%eax
  8018d0:	eb 44                	jmp    801916 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018d2:	89 f2                	mov    %esi,%edx
  8018d4:	89 f8                	mov    %edi,%eax
  8018d6:	e8 e5 fe ff ff       	call   8017c0 <_pipeisclosed>
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	75 32                	jne    801911 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018df:	e8 39 f3 ff ff       	call   800c1d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018e4:	8b 06                	mov    (%esi),%eax
  8018e6:	3b 46 04             	cmp    0x4(%esi),%eax
  8018e9:	74 df                	je     8018ca <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018eb:	99                   	cltd   
  8018ec:	c1 ea 1b             	shr    $0x1b,%edx
  8018ef:	01 d0                	add    %edx,%eax
  8018f1:	83 e0 1f             	and    $0x1f,%eax
  8018f4:	29 d0                	sub    %edx,%eax
  8018f6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018fe:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801901:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801904:	83 c3 01             	add    $0x1,%ebx
  801907:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80190a:	75 d8                	jne    8018e4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80190c:	8b 45 10             	mov    0x10(%ebp),%eax
  80190f:	eb 05                	jmp    801916 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801916:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5f                   	pop    %edi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	56                   	push   %esi
  801922:	53                   	push   %ebx
  801923:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801926:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801929:	50                   	push   %eax
  80192a:	e8 25 f5 ff ff       	call   800e54 <fd_alloc>
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	89 c2                	mov    %eax,%edx
  801934:	85 c0                	test   %eax,%eax
  801936:	0f 88 2c 01 00 00    	js     801a68 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80193c:	83 ec 04             	sub    $0x4,%esp
  80193f:	68 07 04 00 00       	push   $0x407
  801944:	ff 75 f4             	pushl  -0xc(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 ee f2 ff ff       	call   800c3c <sys_page_alloc>
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	89 c2                	mov    %eax,%edx
  801953:	85 c0                	test   %eax,%eax
  801955:	0f 88 0d 01 00 00    	js     801a68 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	e8 ed f4 ff ff       	call   800e54 <fd_alloc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	0f 88 e2 00 00 00    	js     801a56 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801974:	83 ec 04             	sub    $0x4,%esp
  801977:	68 07 04 00 00       	push   $0x407
  80197c:	ff 75 f0             	pushl  -0x10(%ebp)
  80197f:	6a 00                	push   $0x0
  801981:	e8 b6 f2 ff ff       	call   800c3c <sys_page_alloc>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	0f 88 c3 00 00 00    	js     801a56 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	ff 75 f4             	pushl  -0xc(%ebp)
  801999:	e8 9f f4 ff ff       	call   800e3d <fd2data>
  80199e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a0:	83 c4 0c             	add    $0xc,%esp
  8019a3:	68 07 04 00 00       	push   $0x407
  8019a8:	50                   	push   %eax
  8019a9:	6a 00                	push   $0x0
  8019ab:	e8 8c f2 ff ff       	call   800c3c <sys_page_alloc>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	0f 88 89 00 00 00    	js     801a46 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c3:	e8 75 f4 ff ff       	call   800e3d <fd2data>
  8019c8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019cf:	50                   	push   %eax
  8019d0:	6a 00                	push   $0x0
  8019d2:	56                   	push   %esi
  8019d3:	6a 00                	push   $0x0
  8019d5:	e8 a5 f2 ff ff       	call   800c7f <sys_page_map>
  8019da:	89 c3                	mov    %eax,%ebx
  8019dc:	83 c4 20             	add    $0x20,%esp
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	78 55                	js     801a38 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019e3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ec:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019f8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a01:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a06:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	ff 75 f4             	pushl  -0xc(%ebp)
  801a13:	e8 15 f4 ff ff       	call   800e2d <fd2num>
  801a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a1b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a1d:	83 c4 04             	add    $0x4,%esp
  801a20:	ff 75 f0             	pushl  -0x10(%ebp)
  801a23:	e8 05 f4 ff ff       	call   800e2d <fd2num>
  801a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	eb 30                	jmp    801a68 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	56                   	push   %esi
  801a3c:	6a 00                	push   $0x0
  801a3e:	e8 7e f2 ff ff       	call   800cc1 <sys_page_unmap>
  801a43:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4c:	6a 00                	push   $0x0
  801a4e:	e8 6e f2 ff ff       	call   800cc1 <sys_page_unmap>
  801a53:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a56:	83 ec 08             	sub    $0x8,%esp
  801a59:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 5e f2 ff ff       	call   800cc1 <sys_page_unmap>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a68:	89 d0                	mov    %edx,%eax
  801a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	ff 75 08             	pushl  0x8(%ebp)
  801a7e:	e8 20 f4 ff ff       	call   800ea3 <fd_lookup>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 18                	js     801aa2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a90:	e8 a8 f3 ff ff       	call   800e3d <fd2data>
	return _pipeisclosed(fd, p);
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9a:	e8 21 fd ff ff       	call   8017c0 <_pipeisclosed>
  801a9f:	83 c4 10             	add    $0x10,%esp
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ab4:	68 8e 24 80 00       	push   $0x80248e
  801ab9:	ff 75 0c             	pushl  0xc(%ebp)
  801abc:	e8 78 ed ff ff       	call   800839 <strcpy>
	return 0;
}
  801ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	57                   	push   %edi
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ad4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ad9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801adf:	eb 2d                	jmp    801b0e <devcons_write+0x46>
		m = n - tot;
  801ae1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ae4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ae6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ae9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801aee:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	53                   	push   %ebx
  801af5:	03 45 0c             	add    0xc(%ebp),%eax
  801af8:	50                   	push   %eax
  801af9:	57                   	push   %edi
  801afa:	e8 cc ee ff ff       	call   8009cb <memmove>
		sys_cputs(buf, m);
  801aff:	83 c4 08             	add    $0x8,%esp
  801b02:	53                   	push   %ebx
  801b03:	57                   	push   %edi
  801b04:	e8 77 f0 ff ff       	call   800b80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b09:	01 de                	add    %ebx,%esi
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	89 f0                	mov    %esi,%eax
  801b10:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b13:	72 cc                	jb     801ae1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b28:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b2c:	74 2a                	je     801b58 <devcons_read+0x3b>
  801b2e:	eb 05                	jmp    801b35 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b30:	e8 e8 f0 ff ff       	call   800c1d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b35:	e8 64 f0 ff ff       	call   800b9e <sys_cgetc>
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	74 f2                	je     801b30 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 16                	js     801b58 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b42:	83 f8 04             	cmp    $0x4,%eax
  801b45:	74 0c                	je     801b53 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4a:	88 02                	mov    %al,(%edx)
	return 1;
  801b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801b51:	eb 05                	jmp    801b58 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b66:	6a 01                	push   $0x1
  801b68:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b6b:	50                   	push   %eax
  801b6c:	e8 0f f0 ff ff       	call   800b80 <sys_cputs>
}
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <getchar>:

int
getchar(void)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b7c:	6a 01                	push   $0x1
  801b7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b81:	50                   	push   %eax
  801b82:	6a 00                	push   $0x0
  801b84:	e8 80 f5 ff ff       	call   801109 <read>
	if (r < 0)
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 0f                	js     801b9f <getchar+0x29>
		return r;
	if (r < 1)
  801b90:	85 c0                	test   %eax,%eax
  801b92:	7e 06                	jle    801b9a <getchar+0x24>
		return -E_EOF;
	return c;
  801b94:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b98:	eb 05                	jmp    801b9f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b9a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b9f:	c9                   	leave  
  801ba0:	c3                   	ret    

00801ba1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baa:	50                   	push   %eax
  801bab:	ff 75 08             	pushl  0x8(%ebp)
  801bae:	e8 f0 f2 ff ff       	call   800ea3 <fd_lookup>
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	78 11                	js     801bcb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bc3:	39 10                	cmp    %edx,(%eax)
  801bc5:	0f 94 c0             	sete   %al
  801bc8:	0f b6 c0             	movzbl %al,%eax
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <opencons>:

int
opencons(void)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd6:	50                   	push   %eax
  801bd7:	e8 78 f2 ff ff       	call   800e54 <fd_alloc>
  801bdc:	83 c4 10             	add    $0x10,%esp
		return r;
  801bdf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 3e                	js     801c23 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	68 07 04 00 00       	push   $0x407
  801bed:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf0:	6a 00                	push   $0x0
  801bf2:	e8 45 f0 ff ff       	call   800c3c <sys_page_alloc>
  801bf7:	83 c4 10             	add    $0x10,%esp
		return r;
  801bfa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 23                	js     801c23 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c00:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c09:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	50                   	push   %eax
  801c19:	e8 0f f2 ff ff       	call   800e2d <fd2num>
  801c1e:	89 c2                	mov    %eax,%edx
  801c20:	83 c4 10             	add    $0x10,%esp
}
  801c23:	89 d0                	mov    %edx,%eax
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801c35:	85 c0                	test   %eax,%eax
  801c37:	75 12                	jne    801c4b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	68 00 00 c0 ee       	push   $0xeec00000
  801c41:	e8 a6 f1 ff ff       	call   800dec <sys_ipc_recv>
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	eb 0c                	jmp    801c57 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	50                   	push   %eax
  801c4f:	e8 98 f1 ff ff       	call   800dec <sys_ipc_recv>
  801c54:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801c57:	85 f6                	test   %esi,%esi
  801c59:	0f 95 c1             	setne  %cl
  801c5c:	85 db                	test   %ebx,%ebx
  801c5e:	0f 95 c2             	setne  %dl
  801c61:	84 d1                	test   %dl,%cl
  801c63:	74 09                	je     801c6e <ipc_recv+0x47>
  801c65:	89 c2                	mov    %eax,%edx
  801c67:	c1 ea 1f             	shr    $0x1f,%edx
  801c6a:	84 d2                	test   %dl,%dl
  801c6c:	75 24                	jne    801c92 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801c6e:	85 f6                	test   %esi,%esi
  801c70:	74 0a                	je     801c7c <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801c72:	a1 20 60 80 00       	mov    0x806020,%eax
  801c77:	8b 40 74             	mov    0x74(%eax),%eax
  801c7a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801c7c:	85 db                	test   %ebx,%ebx
  801c7e:	74 0a                	je     801c8a <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801c80:	a1 20 60 80 00       	mov    0x806020,%eax
  801c85:	8b 40 78             	mov    0x78(%eax),%eax
  801c88:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c8a:	a1 20 60 80 00       	mov    0x806020,%eax
  801c8f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c95:	5b                   	pop    %ebx
  801c96:	5e                   	pop    %esi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	57                   	push   %edi
  801c9d:	56                   	push   %esi
  801c9e:	53                   	push   %ebx
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801cab:	85 db                	test   %ebx,%ebx
  801cad:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cb2:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801cb5:	ff 75 14             	pushl  0x14(%ebp)
  801cb8:	53                   	push   %ebx
  801cb9:	56                   	push   %esi
  801cba:	57                   	push   %edi
  801cbb:	e8 09 f1 ff ff       	call   800dc9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801cc0:	89 c2                	mov    %eax,%edx
  801cc2:	c1 ea 1f             	shr    $0x1f,%edx
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	84 d2                	test   %dl,%dl
  801cca:	74 17                	je     801ce3 <ipc_send+0x4a>
  801ccc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ccf:	74 12                	je     801ce3 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801cd1:	50                   	push   %eax
  801cd2:	68 9a 24 80 00       	push   $0x80249a
  801cd7:	6a 47                	push   $0x47
  801cd9:	68 a8 24 80 00       	push   $0x8024a8
  801cde:	e8 f8 e4 ff ff       	call   8001db <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ce3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ce6:	75 07                	jne    801cef <ipc_send+0x56>
			sys_yield();
  801ce8:	e8 30 ef ff ff       	call   800c1d <sys_yield>
  801ced:	eb c6                	jmp    801cb5 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	75 c2                	jne    801cb5 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d06:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d09:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d0f:	8b 52 50             	mov    0x50(%edx),%edx
  801d12:	39 ca                	cmp    %ecx,%edx
  801d14:	75 0d                	jne    801d23 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d16:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d19:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d1e:	8b 40 48             	mov    0x48(%eax),%eax
  801d21:	eb 0f                	jmp    801d32 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d23:	83 c0 01             	add    $0x1,%eax
  801d26:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d2b:	75 d9                	jne    801d06 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	c1 e8 16             	shr    $0x16,%eax
  801d3f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d46:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d4b:	f6 c1 01             	test   $0x1,%cl
  801d4e:	74 1d                	je     801d6d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d50:	c1 ea 0c             	shr    $0xc,%edx
  801d53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d5a:	f6 c2 01             	test   $0x1,%dl
  801d5d:	74 0e                	je     801d6d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d5f:	c1 ea 0c             	shr    $0xc,%edx
  801d62:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d69:	ef 
  801d6a:	0f b7 c0             	movzwl %ax,%eax
}
  801d6d:	5d                   	pop    %ebp
  801d6e:	c3                   	ret    
  801d6f:	90                   	nop

00801d70 <__udivdi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 f6                	test   %esi,%esi
  801d89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d8d:	89 ca                	mov    %ecx,%edx
  801d8f:	89 f8                	mov    %edi,%eax
  801d91:	75 3d                	jne    801dd0 <__udivdi3+0x60>
  801d93:	39 cf                	cmp    %ecx,%edi
  801d95:	0f 87 c5 00 00 00    	ja     801e60 <__udivdi3+0xf0>
  801d9b:	85 ff                	test   %edi,%edi
  801d9d:	89 fd                	mov    %edi,%ebp
  801d9f:	75 0b                	jne    801dac <__udivdi3+0x3c>
  801da1:	b8 01 00 00 00       	mov    $0x1,%eax
  801da6:	31 d2                	xor    %edx,%edx
  801da8:	f7 f7                	div    %edi
  801daa:	89 c5                	mov    %eax,%ebp
  801dac:	89 c8                	mov    %ecx,%eax
  801dae:	31 d2                	xor    %edx,%edx
  801db0:	f7 f5                	div    %ebp
  801db2:	89 c1                	mov    %eax,%ecx
  801db4:	89 d8                	mov    %ebx,%eax
  801db6:	89 cf                	mov    %ecx,%edi
  801db8:	f7 f5                	div    %ebp
  801dba:	89 c3                	mov    %eax,%ebx
  801dbc:	89 d8                	mov    %ebx,%eax
  801dbe:	89 fa                	mov    %edi,%edx
  801dc0:	83 c4 1c             	add    $0x1c,%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    
  801dc8:	90                   	nop
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	39 ce                	cmp    %ecx,%esi
  801dd2:	77 74                	ja     801e48 <__udivdi3+0xd8>
  801dd4:	0f bd fe             	bsr    %esi,%edi
  801dd7:	83 f7 1f             	xor    $0x1f,%edi
  801dda:	0f 84 98 00 00 00    	je     801e78 <__udivdi3+0x108>
  801de0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	89 c5                	mov    %eax,%ebp
  801de9:	29 fb                	sub    %edi,%ebx
  801deb:	d3 e6                	shl    %cl,%esi
  801ded:	89 d9                	mov    %ebx,%ecx
  801def:	d3 ed                	shr    %cl,%ebp
  801df1:	89 f9                	mov    %edi,%ecx
  801df3:	d3 e0                	shl    %cl,%eax
  801df5:	09 ee                	or     %ebp,%esi
  801df7:	89 d9                	mov    %ebx,%ecx
  801df9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dfd:	89 d5                	mov    %edx,%ebp
  801dff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e03:	d3 ed                	shr    %cl,%ebp
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	d3 e2                	shl    %cl,%edx
  801e09:	89 d9                	mov    %ebx,%ecx
  801e0b:	d3 e8                	shr    %cl,%eax
  801e0d:	09 c2                	or     %eax,%edx
  801e0f:	89 d0                	mov    %edx,%eax
  801e11:	89 ea                	mov    %ebp,%edx
  801e13:	f7 f6                	div    %esi
  801e15:	89 d5                	mov    %edx,%ebp
  801e17:	89 c3                	mov    %eax,%ebx
  801e19:	f7 64 24 0c          	mull   0xc(%esp)
  801e1d:	39 d5                	cmp    %edx,%ebp
  801e1f:	72 10                	jb     801e31 <__udivdi3+0xc1>
  801e21:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e25:	89 f9                	mov    %edi,%ecx
  801e27:	d3 e6                	shl    %cl,%esi
  801e29:	39 c6                	cmp    %eax,%esi
  801e2b:	73 07                	jae    801e34 <__udivdi3+0xc4>
  801e2d:	39 d5                	cmp    %edx,%ebp
  801e2f:	75 03                	jne    801e34 <__udivdi3+0xc4>
  801e31:	83 eb 01             	sub    $0x1,%ebx
  801e34:	31 ff                	xor    %edi,%edi
  801e36:	89 d8                	mov    %ebx,%eax
  801e38:	89 fa                	mov    %edi,%edx
  801e3a:	83 c4 1c             	add    $0x1c,%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5f                   	pop    %edi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    
  801e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e48:	31 ff                	xor    %edi,%edi
  801e4a:	31 db                	xor    %ebx,%ebx
  801e4c:	89 d8                	mov    %ebx,%eax
  801e4e:	89 fa                	mov    %edi,%edx
  801e50:	83 c4 1c             	add    $0x1c,%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    
  801e58:	90                   	nop
  801e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e60:	89 d8                	mov    %ebx,%eax
  801e62:	f7 f7                	div    %edi
  801e64:	31 ff                	xor    %edi,%edi
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	89 d8                	mov    %ebx,%eax
  801e6a:	89 fa                	mov    %edi,%edx
  801e6c:	83 c4 1c             	add    $0x1c,%esp
  801e6f:	5b                   	pop    %ebx
  801e70:	5e                   	pop    %esi
  801e71:	5f                   	pop    %edi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    
  801e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e78:	39 ce                	cmp    %ecx,%esi
  801e7a:	72 0c                	jb     801e88 <__udivdi3+0x118>
  801e7c:	31 db                	xor    %ebx,%ebx
  801e7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e82:	0f 87 34 ff ff ff    	ja     801dbc <__udivdi3+0x4c>
  801e88:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e8d:	e9 2a ff ff ff       	jmp    801dbc <__udivdi3+0x4c>
  801e92:	66 90                	xchg   %ax,%ax
  801e94:	66 90                	xchg   %ax,%ax
  801e96:	66 90                	xchg   %ax,%ax
  801e98:	66 90                	xchg   %ax,%ax
  801e9a:	66 90                	xchg   %ax,%ax
  801e9c:	66 90                	xchg   %ax,%ax
  801e9e:	66 90                	xchg   %ax,%ax

00801ea0 <__umoddi3>:
  801ea0:	55                   	push   %ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 1c             	sub    $0x1c,%esp
  801ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801eab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801eaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801eb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eb7:	85 d2                	test   %edx,%edx
  801eb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ec1:	89 f3                	mov    %esi,%ebx
  801ec3:	89 3c 24             	mov    %edi,(%esp)
  801ec6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eca:	75 1c                	jne    801ee8 <__umoddi3+0x48>
  801ecc:	39 f7                	cmp    %esi,%edi
  801ece:	76 50                	jbe    801f20 <__umoddi3+0x80>
  801ed0:	89 c8                	mov    %ecx,%eax
  801ed2:	89 f2                	mov    %esi,%edx
  801ed4:	f7 f7                	div    %edi
  801ed6:	89 d0                	mov    %edx,%eax
  801ed8:	31 d2                	xor    %edx,%edx
  801eda:	83 c4 1c             	add    $0x1c,%esp
  801edd:	5b                   	pop    %ebx
  801ede:	5e                   	pop    %esi
  801edf:	5f                   	pop    %edi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    
  801ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee8:	39 f2                	cmp    %esi,%edx
  801eea:	89 d0                	mov    %edx,%eax
  801eec:	77 52                	ja     801f40 <__umoddi3+0xa0>
  801eee:	0f bd ea             	bsr    %edx,%ebp
  801ef1:	83 f5 1f             	xor    $0x1f,%ebp
  801ef4:	75 5a                	jne    801f50 <__umoddi3+0xb0>
  801ef6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801efa:	0f 82 e0 00 00 00    	jb     801fe0 <__umoddi3+0x140>
  801f00:	39 0c 24             	cmp    %ecx,(%esp)
  801f03:	0f 86 d7 00 00 00    	jbe    801fe0 <__umoddi3+0x140>
  801f09:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f11:	83 c4 1c             	add    $0x1c,%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5f                   	pop    %edi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    
  801f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f20:	85 ff                	test   %edi,%edi
  801f22:	89 fd                	mov    %edi,%ebp
  801f24:	75 0b                	jne    801f31 <__umoddi3+0x91>
  801f26:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	f7 f7                	div    %edi
  801f2f:	89 c5                	mov    %eax,%ebp
  801f31:	89 f0                	mov    %esi,%eax
  801f33:	31 d2                	xor    %edx,%edx
  801f35:	f7 f5                	div    %ebp
  801f37:	89 c8                	mov    %ecx,%eax
  801f39:	f7 f5                	div    %ebp
  801f3b:	89 d0                	mov    %edx,%eax
  801f3d:	eb 99                	jmp    801ed8 <__umoddi3+0x38>
  801f3f:	90                   	nop
  801f40:	89 c8                	mov    %ecx,%eax
  801f42:	89 f2                	mov    %esi,%edx
  801f44:	83 c4 1c             	add    $0x1c,%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    
  801f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f50:	8b 34 24             	mov    (%esp),%esi
  801f53:	bf 20 00 00 00       	mov    $0x20,%edi
  801f58:	89 e9                	mov    %ebp,%ecx
  801f5a:	29 ef                	sub    %ebp,%edi
  801f5c:	d3 e0                	shl    %cl,%eax
  801f5e:	89 f9                	mov    %edi,%ecx
  801f60:	89 f2                	mov    %esi,%edx
  801f62:	d3 ea                	shr    %cl,%edx
  801f64:	89 e9                	mov    %ebp,%ecx
  801f66:	09 c2                	or     %eax,%edx
  801f68:	89 d8                	mov    %ebx,%eax
  801f6a:	89 14 24             	mov    %edx,(%esp)
  801f6d:	89 f2                	mov    %esi,%edx
  801f6f:	d3 e2                	shl    %cl,%edx
  801f71:	89 f9                	mov    %edi,%ecx
  801f73:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f7b:	d3 e8                	shr    %cl,%eax
  801f7d:	89 e9                	mov    %ebp,%ecx
  801f7f:	89 c6                	mov    %eax,%esi
  801f81:	d3 e3                	shl    %cl,%ebx
  801f83:	89 f9                	mov    %edi,%ecx
  801f85:	89 d0                	mov    %edx,%eax
  801f87:	d3 e8                	shr    %cl,%eax
  801f89:	89 e9                	mov    %ebp,%ecx
  801f8b:	09 d8                	or     %ebx,%eax
  801f8d:	89 d3                	mov    %edx,%ebx
  801f8f:	89 f2                	mov    %esi,%edx
  801f91:	f7 34 24             	divl   (%esp)
  801f94:	89 d6                	mov    %edx,%esi
  801f96:	d3 e3                	shl    %cl,%ebx
  801f98:	f7 64 24 04          	mull   0x4(%esp)
  801f9c:	39 d6                	cmp    %edx,%esi
  801f9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa2:	89 d1                	mov    %edx,%ecx
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	72 08                	jb     801fb0 <__umoddi3+0x110>
  801fa8:	75 11                	jne    801fbb <__umoddi3+0x11b>
  801faa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fae:	73 0b                	jae    801fbb <__umoddi3+0x11b>
  801fb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801fb4:	1b 14 24             	sbb    (%esp),%edx
  801fb7:	89 d1                	mov    %edx,%ecx
  801fb9:	89 c3                	mov    %eax,%ebx
  801fbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fbf:	29 da                	sub    %ebx,%edx
  801fc1:	19 ce                	sbb    %ecx,%esi
  801fc3:	89 f9                	mov    %edi,%ecx
  801fc5:	89 f0                	mov    %esi,%eax
  801fc7:	d3 e0                	shl    %cl,%eax
  801fc9:	89 e9                	mov    %ebp,%ecx
  801fcb:	d3 ea                	shr    %cl,%edx
  801fcd:	89 e9                	mov    %ebp,%ecx
  801fcf:	d3 ee                	shr    %cl,%esi
  801fd1:	09 d0                	or     %edx,%eax
  801fd3:	89 f2                	mov    %esi,%edx
  801fd5:	83 c4 1c             	add    $0x1c,%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    
  801fdd:	8d 76 00             	lea    0x0(%esi),%esi
  801fe0:	29 f9                	sub    %edi,%ecx
  801fe2:	19 d6                	sbb    %edx,%esi
  801fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fec:	e9 18 ff ff ff       	jmp    801f09 <__umoddi3+0x69>
