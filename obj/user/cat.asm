
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
  800048:	e8 ce 11 00 00       	call   80121b <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 60 20 80 00       	push   $0x802060
  800060:	6a 0d                	push   $0xd
  800062:	68 7b 20 80 00       	push   $0x80207b
  800067:	e8 87 01 00 00       	call   8001f3 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 c2 10 00 00       	call   801141 <read>
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
  800093:	68 86 20 80 00       	push   $0x802086
  800098:	6a 0f                	push   $0xf
  80009a:	68 7b 20 80 00       	push   $0x80207b
  80009f:	e8 4f 01 00 00       	call   8001f3 <_panic>
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
  8000b7:	c7 05 00 30 80 00 9b 	movl   $0x80209b,0x803000
  8000be:	20 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 9f 20 80 00       	push   $0x80209f
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
  8000e8:	e8 df 14 00 00       	call   8015cc <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 a7 20 80 00       	push   $0x8020a7
  800102:	e8 63 16 00 00       	call   80176a <printf>
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
  80011b:	e8 e5 0e 00 00       	call   801005 <close>
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
  800146:	e8 cb 0a 00 00       	call   800c16 <sys_getenvid>
  80014b:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80014d:	83 ec 08             	sub    $0x8,%esp
  800150:	50                   	push   %eax
  800151:	68 bc 20 80 00       	push   $0x8020bc
  800156:	e8 71 01 00 00       	call   8002cc <cprintf>
  80015b:	8b 3d 20 60 80 00    	mov    0x806020,%edi
  800161:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80016e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800173:	89 c1                	mov    %eax,%ecx
  800175:	c1 e1 07             	shl    $0x7,%ecx
  800178:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80017f:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800182:	39 cb                	cmp    %ecx,%ebx
  800184:	0f 44 fa             	cmove  %edx,%edi
  800187:	b9 01 00 00 00       	mov    $0x1,%ecx
  80018c:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80018f:	83 c0 01             	add    $0x1,%eax
  800192:	81 c2 84 00 00 00    	add    $0x84,%edx
  800198:	3d 00 04 00 00       	cmp    $0x400,%eax
  80019d:	75 d4                	jne    800173 <libmain+0x40>
  80019f:	89 f0                	mov    %esi,%eax
  8001a1:	84 c0                	test   %al,%al
  8001a3:	74 06                	je     8001ab <libmain+0x78>
  8001a5:	89 3d 20 60 80 00    	mov    %edi,0x806020
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8001af:	7e 0a                	jle    8001bb <libmain+0x88>
		binaryname = argv[0];
  8001b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b4:	8b 00                	mov    (%eax),%eax
  8001b6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001bb:	83 ec 08             	sub    $0x8,%esp
  8001be:	ff 75 0c             	pushl  0xc(%ebp)
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	e8 e2 fe ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  8001c9:	e8 0b 00 00 00       	call   8001d9 <exit>
}
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001df:	e8 4c 0e 00 00       	call   801030 <close_all>
	sys_env_destroy(0);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	6a 00                	push   $0x0
  8001e9:	e8 e7 09 00 00       	call   800bd5 <sys_env_destroy>
}
  8001ee:	83 c4 10             	add    $0x10,%esp
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800201:	e8 10 0a 00 00       	call   800c16 <sys_getenvid>
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	ff 75 0c             	pushl  0xc(%ebp)
  80020c:	ff 75 08             	pushl  0x8(%ebp)
  80020f:	56                   	push   %esi
  800210:	50                   	push   %eax
  800211:	68 e8 20 80 00       	push   $0x8020e8
  800216:	e8 b1 00 00 00       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021b:	83 c4 18             	add    $0x18,%esp
  80021e:	53                   	push   %ebx
  80021f:	ff 75 10             	pushl  0x10(%ebp)
  800222:	e8 54 00 00 00       	call   80027b <vcprintf>
	cprintf("\n");
  800227:	c7 04 24 07 25 80 00 	movl   $0x802507,(%esp)
  80022e:	e8 99 00 00 00       	call   8002cc <cprintf>
  800233:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800236:	cc                   	int3   
  800237:	eb fd                	jmp    800236 <_panic+0x43>

00800239 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	53                   	push   %ebx
  80023d:	83 ec 04             	sub    $0x4,%esp
  800240:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800243:	8b 13                	mov    (%ebx),%edx
  800245:	8d 42 01             	lea    0x1(%edx),%eax
  800248:	89 03                	mov    %eax,(%ebx)
  80024a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800251:	3d ff 00 00 00       	cmp    $0xff,%eax
  800256:	75 1a                	jne    800272 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800258:	83 ec 08             	sub    $0x8,%esp
  80025b:	68 ff 00 00 00       	push   $0xff
  800260:	8d 43 08             	lea    0x8(%ebx),%eax
  800263:	50                   	push   %eax
  800264:	e8 2f 09 00 00       	call   800b98 <sys_cputs>
		b->idx = 0;
  800269:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80026f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800272:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800284:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028b:	00 00 00 
	b.cnt = 0;
  80028e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800295:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a4:	50                   	push   %eax
  8002a5:	68 39 02 80 00       	push   $0x800239
  8002aa:	e8 54 01 00 00       	call   800403 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002af:	83 c4 08             	add    $0x8,%esp
  8002b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002be:	50                   	push   %eax
  8002bf:	e8 d4 08 00 00       	call   800b98 <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	50                   	push   %eax
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 9d ff ff ff       	call   80027b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 1c             	sub    $0x1c,%esp
  8002e9:	89 c7                	mov    %eax,%edi
  8002eb:	89 d6                	mov    %edx,%esi
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800301:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800304:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800307:	39 d3                	cmp    %edx,%ebx
  800309:	72 05                	jb     800310 <printnum+0x30>
  80030b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80030e:	77 45                	ja     800355 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	ff 75 18             	pushl  0x18(%ebp)
  800316:	8b 45 14             	mov    0x14(%ebp),%eax
  800319:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80031c:	53                   	push   %ebx
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	ff 75 e4             	pushl  -0x1c(%ebp)
  800326:	ff 75 e0             	pushl  -0x20(%ebp)
  800329:	ff 75 dc             	pushl  -0x24(%ebp)
  80032c:	ff 75 d8             	pushl  -0x28(%ebp)
  80032f:	e8 8c 1a 00 00       	call   801dc0 <__udivdi3>
  800334:	83 c4 18             	add    $0x18,%esp
  800337:	52                   	push   %edx
  800338:	50                   	push   %eax
  800339:	89 f2                	mov    %esi,%edx
  80033b:	89 f8                	mov    %edi,%eax
  80033d:	e8 9e ff ff ff       	call   8002e0 <printnum>
  800342:	83 c4 20             	add    $0x20,%esp
  800345:	eb 18                	jmp    80035f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	56                   	push   %esi
  80034b:	ff 75 18             	pushl  0x18(%ebp)
  80034e:	ff d7                	call   *%edi
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	eb 03                	jmp    800358 <printnum+0x78>
  800355:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800358:	83 eb 01             	sub    $0x1,%ebx
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	7f e8                	jg     800347 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	56                   	push   %esi
  800363:	83 ec 04             	sub    $0x4,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 79 1b 00 00       	call   801ef0 <__umoddi3>
  800377:	83 c4 14             	add    $0x14,%esp
  80037a:	0f be 80 0b 21 80 00 	movsbl 0x80210b(%eax),%eax
  800381:	50                   	push   %eax
  800382:	ff d7                	call   *%edi
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800392:	83 fa 01             	cmp    $0x1,%edx
  800395:	7e 0e                	jle    8003a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800397:	8b 10                	mov    (%eax),%edx
  800399:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039c:	89 08                	mov    %ecx,(%eax)
  80039e:	8b 02                	mov    (%edx),%eax
  8003a0:	8b 52 04             	mov    0x4(%edx),%edx
  8003a3:	eb 22                	jmp    8003c7 <getuint+0x38>
	else if (lflag)
  8003a5:	85 d2                	test   %edx,%edx
  8003a7:	74 10                	je     8003b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	eb 0e                	jmp    8003c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b9:	8b 10                	mov    (%eax),%edx
  8003bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003be:	89 08                	mov    %ecx,(%eax)
  8003c0:	8b 02                	mov    (%edx),%eax
  8003c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d8:	73 0a                	jae    8003e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003dd:	89 08                	mov    %ecx,(%eax)
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e2:	88 02                	mov    %al,(%edx)
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ef:	50                   	push   %eax
  8003f0:	ff 75 10             	pushl  0x10(%ebp)
  8003f3:	ff 75 0c             	pushl  0xc(%ebp)
  8003f6:	ff 75 08             	pushl  0x8(%ebp)
  8003f9:	e8 05 00 00 00       	call   800403 <vprintfmt>
	va_end(ap);
}
  8003fe:	83 c4 10             	add    $0x10,%esp
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	56                   	push   %esi
  800408:	53                   	push   %ebx
  800409:	83 ec 2c             	sub    $0x2c,%esp
  80040c:	8b 75 08             	mov    0x8(%ebp),%esi
  80040f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800412:	8b 7d 10             	mov    0x10(%ebp),%edi
  800415:	eb 12                	jmp    800429 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800417:	85 c0                	test   %eax,%eax
  800419:	0f 84 89 03 00 00    	je     8007a8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	53                   	push   %ebx
  800423:	50                   	push   %eax
  800424:	ff d6                	call   *%esi
  800426:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800429:	83 c7 01             	add    $0x1,%edi
  80042c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800430:	83 f8 25             	cmp    $0x25,%eax
  800433:	75 e2                	jne    800417 <vprintfmt+0x14>
  800435:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800439:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800440:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800447:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80044e:	ba 00 00 00 00       	mov    $0x0,%edx
  800453:	eb 07                	jmp    80045c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800458:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8d 47 01             	lea    0x1(%edi),%eax
  80045f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800462:	0f b6 07             	movzbl (%edi),%eax
  800465:	0f b6 c8             	movzbl %al,%ecx
  800468:	83 e8 23             	sub    $0x23,%eax
  80046b:	3c 55                	cmp    $0x55,%al
  80046d:	0f 87 1a 03 00 00    	ja     80078d <vprintfmt+0x38a>
  800473:	0f b6 c0             	movzbl %al,%eax
  800476:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800480:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800484:	eb d6                	jmp    80045c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800491:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800494:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800498:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80049b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80049e:	83 fa 09             	cmp    $0x9,%edx
  8004a1:	77 39                	ja     8004dc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004a6:	eb e9                	jmp    800491 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b9:	eb 27                	jmp    8004e2 <vprintfmt+0xdf>
  8004bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004be:	85 c0                	test   %eax,%eax
  8004c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c5:	0f 49 c8             	cmovns %eax,%ecx
  8004c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ce:	eb 8c                	jmp    80045c <vprintfmt+0x59>
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004da:	eb 80                	jmp    80045c <vprintfmt+0x59>
  8004dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004df:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e6:	0f 89 70 ff ff ff    	jns    80045c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004f9:	e9 5e ff ff ff       	jmp    80045c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004fe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800504:	e9 53 ff ff ff       	jmp    80045c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	53                   	push   %ebx
  800516:	ff 30                	pushl  (%eax)
  800518:	ff d6                	call   *%esi
			break;
  80051a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800520:	e9 04 ff ff ff       	jmp    800429 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	99                   	cltd   
  800531:	31 d0                	xor    %edx,%eax
  800533:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800535:	83 f8 0f             	cmp    $0xf,%eax
  800538:	7f 0b                	jg     800545 <vprintfmt+0x142>
  80053a:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  800541:	85 d2                	test   %edx,%edx
  800543:	75 18                	jne    80055d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800545:	50                   	push   %eax
  800546:	68 23 21 80 00       	push   $0x802123
  80054b:	53                   	push   %ebx
  80054c:	56                   	push   %esi
  80054d:	e8 94 fe ff ff       	call   8003e6 <printfmt>
  800552:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800558:	e9 cc fe ff ff       	jmp    800429 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80055d:	52                   	push   %edx
  80055e:	68 d5 24 80 00       	push   $0x8024d5
  800563:	53                   	push   %ebx
  800564:	56                   	push   %esi
  800565:	e8 7c fe ff ff       	call   8003e6 <printfmt>
  80056a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800570:	e9 b4 fe ff ff       	jmp    800429 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 04             	lea    0x4(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800580:	85 ff                	test   %edi,%edi
  800582:	b8 1c 21 80 00       	mov    $0x80211c,%eax
  800587:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80058a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058e:	0f 8e 94 00 00 00    	jle    800628 <vprintfmt+0x225>
  800594:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800598:	0f 84 98 00 00 00    	je     800636 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8005a4:	57                   	push   %edi
  8005a5:	e8 86 02 00 00       	call   800830 <strnlen>
  8005aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ad:	29 c1                	sub    %eax,%ecx
  8005af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	eb 0f                	jmp    8005d2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cc:	83 ef 01             	sub    $0x1,%edi
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	85 ff                	test   %edi,%edi
  8005d4:	7f ed                	jg     8005c3 <vprintfmt+0x1c0>
  8005d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005dc:	85 c9                	test   %ecx,%ecx
  8005de:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e3:	0f 49 c1             	cmovns %ecx,%eax
  8005e6:	29 c1                	sub    %eax,%ecx
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	89 cb                	mov    %ecx,%ebx
  8005f3:	eb 4d                	jmp    800642 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f9:	74 1b                	je     800616 <vprintfmt+0x213>
  8005fb:	0f be c0             	movsbl %al,%eax
  8005fe:	83 e8 20             	sub    $0x20,%eax
  800601:	83 f8 5e             	cmp    $0x5e,%eax
  800604:	76 10                	jbe    800616 <vprintfmt+0x213>
					putch('?', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	ff 75 0c             	pushl  0xc(%ebp)
  80060c:	6a 3f                	push   $0x3f
  80060e:	ff 55 08             	call   *0x8(%ebp)
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	eb 0d                	jmp    800623 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	ff 75 0c             	pushl  0xc(%ebp)
  80061c:	52                   	push   %edx
  80061d:	ff 55 08             	call   *0x8(%ebp)
  800620:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800623:	83 eb 01             	sub    $0x1,%ebx
  800626:	eb 1a                	jmp    800642 <vprintfmt+0x23f>
  800628:	89 75 08             	mov    %esi,0x8(%ebp)
  80062b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800631:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800634:	eb 0c                	jmp    800642 <vprintfmt+0x23f>
  800636:	89 75 08             	mov    %esi,0x8(%ebp)
  800639:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800642:	83 c7 01             	add    $0x1,%edi
  800645:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800649:	0f be d0             	movsbl %al,%edx
  80064c:	85 d2                	test   %edx,%edx
  80064e:	74 23                	je     800673 <vprintfmt+0x270>
  800650:	85 f6                	test   %esi,%esi
  800652:	78 a1                	js     8005f5 <vprintfmt+0x1f2>
  800654:	83 ee 01             	sub    $0x1,%esi
  800657:	79 9c                	jns    8005f5 <vprintfmt+0x1f2>
  800659:	89 df                	mov    %ebx,%edi
  80065b:	8b 75 08             	mov    0x8(%ebp),%esi
  80065e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800661:	eb 18                	jmp    80067b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 20                	push   $0x20
  800669:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066b:	83 ef 01             	sub    $0x1,%edi
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	eb 08                	jmp    80067b <vprintfmt+0x278>
  800673:	89 df                	mov    %ebx,%edi
  800675:	8b 75 08             	mov    0x8(%ebp),%esi
  800678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067b:	85 ff                	test   %edi,%edi
  80067d:	7f e4                	jg     800663 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800682:	e9 a2 fd ff ff       	jmp    800429 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800687:	83 fa 01             	cmp    $0x1,%edx
  80068a:	7e 16                	jle    8006a2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 08             	lea    0x8(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 50 04             	mov    0x4(%eax),%edx
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a0:	eb 32                	jmp    8006d4 <vprintfmt+0x2d1>
	else if (lflag)
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	74 18                	je     8006be <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b4:	89 c1                	mov    %eax,%ecx
  8006b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006bc:	eb 16                	jmp    8006d4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cc:	89 c1                	mov    %eax,%ecx
  8006ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006da:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e3:	79 74                	jns    800759 <vprintfmt+0x356>
				putch('-', putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	6a 2d                	push   $0x2d
  8006eb:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006f3:	f7 d8                	neg    %eax
  8006f5:	83 d2 00             	adc    $0x0,%edx
  8006f8:	f7 da                	neg    %edx
  8006fa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800702:	eb 55                	jmp    800759 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800704:	8d 45 14             	lea    0x14(%ebp),%eax
  800707:	e8 83 fc ff ff       	call   80038f <getuint>
			base = 10;
  80070c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800711:	eb 46                	jmp    800759 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	e8 74 fc ff ff       	call   80038f <getuint>
			base = 8;
  80071b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800720:	eb 37                	jmp    800759 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 30                	push   $0x30
  800728:	ff d6                	call   *%esi
			putch('x', putdat);
  80072a:	83 c4 08             	add    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	6a 78                	push   $0x78
  800730:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 50 04             	lea    0x4(%eax),%edx
  800738:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800742:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800745:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80074a:	eb 0d                	jmp    800759 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 3b fc ff ff       	call   80038f <getuint>
			base = 16;
  800754:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800759:	83 ec 0c             	sub    $0xc,%esp
  80075c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800760:	57                   	push   %edi
  800761:	ff 75 e0             	pushl  -0x20(%ebp)
  800764:	51                   	push   %ecx
  800765:	52                   	push   %edx
  800766:	50                   	push   %eax
  800767:	89 da                	mov    %ebx,%edx
  800769:	89 f0                	mov    %esi,%eax
  80076b:	e8 70 fb ff ff       	call   8002e0 <printnum>
			break;
  800770:	83 c4 20             	add    $0x20,%esp
  800773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800776:	e9 ae fc ff ff       	jmp    800429 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	51                   	push   %ecx
  800780:	ff d6                	call   *%esi
			break;
  800782:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800788:	e9 9c fc ff ff       	jmp    800429 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078d:	83 ec 08             	sub    $0x8,%esp
  800790:	53                   	push   %ebx
  800791:	6a 25                	push   $0x25
  800793:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	eb 03                	jmp    80079d <vprintfmt+0x39a>
  80079a:	83 ef 01             	sub    $0x1,%edi
  80079d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a1:	75 f7                	jne    80079a <vprintfmt+0x397>
  8007a3:	e9 81 fc ff ff       	jmp    800429 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5f                   	pop    %edi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 18             	sub    $0x18,%esp
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 26                	je     8007f7 <vsnprintf+0x47>
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	7e 22                	jle    8007f7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d5:	ff 75 14             	pushl  0x14(%ebp)
  8007d8:	ff 75 10             	pushl  0x10(%ebp)
  8007db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	68 c9 03 80 00       	push   $0x8003c9
  8007e4:	e8 1a fc ff ff       	call   800403 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	eb 05                	jmp    8007fc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800804:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800807:	50                   	push   %eax
  800808:	ff 75 10             	pushl  0x10(%ebp)
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	ff 75 08             	pushl  0x8(%ebp)
  800811:	e8 9a ff ff ff       	call   8007b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
  800823:	eb 03                	jmp    800828 <strlen+0x10>
		n++;
  800825:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800828:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082c:	75 f7                	jne    800825 <strlen+0xd>
		n++;
	return n;
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
  80083e:	eb 03                	jmp    800843 <strnlen+0x13>
		n++;
  800840:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800843:	39 c2                	cmp    %eax,%edx
  800845:	74 08                	je     80084f <strnlen+0x1f>
  800847:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80084b:	75 f3                	jne    800840 <strnlen+0x10>
  80084d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085b:	89 c2                	mov    %eax,%edx
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800867:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086a:	84 db                	test   %bl,%bl
  80086c:	75 ef                	jne    80085d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800878:	53                   	push   %ebx
  800879:	e8 9a ff ff ff       	call   800818 <strlen>
  80087e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800881:	ff 75 0c             	pushl  0xc(%ebp)
  800884:	01 d8                	add    %ebx,%eax
  800886:	50                   	push   %eax
  800887:	e8 c5 ff ff ff       	call   800851 <strcpy>
	return dst;
}
  80088c:	89 d8                	mov    %ebx,%eax
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 75 08             	mov    0x8(%ebp),%esi
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089e:	89 f3                	mov    %esi,%ebx
  8008a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a3:	89 f2                	mov    %esi,%edx
  8008a5:	eb 0f                	jmp    8008b6 <strncpy+0x23>
		*dst++ = *src;
  8008a7:	83 c2 01             	add    $0x1,%edx
  8008aa:	0f b6 01             	movzbl (%ecx),%eax
  8008ad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b6:	39 da                	cmp    %ebx,%edx
  8008b8:	75 ed                	jne    8008a7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cb:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d0:	85 d2                	test   %edx,%edx
  8008d2:	74 21                	je     8008f5 <strlcpy+0x35>
  8008d4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d8:	89 f2                	mov    %esi,%edx
  8008da:	eb 09                	jmp    8008e5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008dc:	83 c2 01             	add    $0x1,%edx
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e5:	39 c2                	cmp    %eax,%edx
  8008e7:	74 09                	je     8008f2 <strlcpy+0x32>
  8008e9:	0f b6 19             	movzbl (%ecx),%ebx
  8008ec:	84 db                	test   %bl,%bl
  8008ee:	75 ec                	jne    8008dc <strlcpy+0x1c>
  8008f0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f5:	29 f0                	sub    %esi,%eax
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800904:	eb 06                	jmp    80090c <strcmp+0x11>
		p++, q++;
  800906:	83 c1 01             	add    $0x1,%ecx
  800909:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090c:	0f b6 01             	movzbl (%ecx),%eax
  80090f:	84 c0                	test   %al,%al
  800911:	74 04                	je     800917 <strcmp+0x1c>
  800913:	3a 02                	cmp    (%edx),%al
  800915:	74 ef                	je     800906 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800917:	0f b6 c0             	movzbl %al,%eax
  80091a:	0f b6 12             	movzbl (%edx),%edx
  80091d:	29 d0                	sub    %edx,%eax
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092b:	89 c3                	mov    %eax,%ebx
  80092d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800930:	eb 06                	jmp    800938 <strncmp+0x17>
		n--, p++, q++;
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800938:	39 d8                	cmp    %ebx,%eax
  80093a:	74 15                	je     800951 <strncmp+0x30>
  80093c:	0f b6 08             	movzbl (%eax),%ecx
  80093f:	84 c9                	test   %cl,%cl
  800941:	74 04                	je     800947 <strncmp+0x26>
  800943:	3a 0a                	cmp    (%edx),%cl
  800945:	74 eb                	je     800932 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800947:	0f b6 00             	movzbl (%eax),%eax
  80094a:	0f b6 12             	movzbl (%edx),%edx
  80094d:	29 d0                	sub    %edx,%eax
  80094f:	eb 05                	jmp    800956 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800956:	5b                   	pop    %ebx
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800963:	eb 07                	jmp    80096c <strchr+0x13>
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 0f                	je     800978 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	0f b6 10             	movzbl (%eax),%edx
  80096f:	84 d2                	test   %dl,%dl
  800971:	75 f2                	jne    800965 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800984:	eb 03                	jmp    800989 <strfind+0xf>
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	74 04                	je     800994 <strfind+0x1a>
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f2                	jne    800986 <strfind+0xc>
			break;
	return (char *) s;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a2:	85 c9                	test   %ecx,%ecx
  8009a4:	74 36                	je     8009dc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ac:	75 28                	jne    8009d6 <memset+0x40>
  8009ae:	f6 c1 03             	test   $0x3,%cl
  8009b1:	75 23                	jne    8009d6 <memset+0x40>
		c &= 0xFF;
  8009b3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b7:	89 d3                	mov    %edx,%ebx
  8009b9:	c1 e3 08             	shl    $0x8,%ebx
  8009bc:	89 d6                	mov    %edx,%esi
  8009be:	c1 e6 18             	shl    $0x18,%esi
  8009c1:	89 d0                	mov    %edx,%eax
  8009c3:	c1 e0 10             	shl    $0x10,%eax
  8009c6:	09 f0                	or     %esi,%eax
  8009c8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ca:	89 d8                	mov    %ebx,%eax
  8009cc:	09 d0                	or     %edx,%eax
  8009ce:	c1 e9 02             	shr    $0x2,%ecx
  8009d1:	fc                   	cld    
  8009d2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d4:	eb 06                	jmp    8009dc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	fc                   	cld    
  8009da:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009dc:	89 f8                	mov    %edi,%eax
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f1:	39 c6                	cmp    %eax,%esi
  8009f3:	73 35                	jae    800a2a <memmove+0x47>
  8009f5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f8:	39 d0                	cmp    %edx,%eax
  8009fa:	73 2e                	jae    800a2a <memmove+0x47>
		s += n;
		d += n;
  8009fc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	09 fe                	or     %edi,%esi
  800a03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a09:	75 13                	jne    800a1e <memmove+0x3b>
  800a0b:	f6 c1 03             	test   $0x3,%cl
  800a0e:	75 0e                	jne    800a1e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a10:	83 ef 04             	sub    $0x4,%edi
  800a13:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a16:	c1 e9 02             	shr    $0x2,%ecx
  800a19:	fd                   	std    
  800a1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1c:	eb 09                	jmp    800a27 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1e:	83 ef 01             	sub    $0x1,%edi
  800a21:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a24:	fd                   	std    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a27:	fc                   	cld    
  800a28:	eb 1d                	jmp    800a47 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	89 f2                	mov    %esi,%edx
  800a2c:	09 c2                	or     %eax,%edx
  800a2e:	f6 c2 03             	test   $0x3,%dl
  800a31:	75 0f                	jne    800a42 <memmove+0x5f>
  800a33:	f6 c1 03             	test   $0x3,%cl
  800a36:	75 0a                	jne    800a42 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a38:	c1 e9 02             	shr    $0x2,%ecx
  800a3b:	89 c7                	mov    %eax,%edi
  800a3d:	fc                   	cld    
  800a3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a40:	eb 05                	jmp    800a47 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a42:	89 c7                	mov    %eax,%edi
  800a44:	fc                   	cld    
  800a45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4e:	ff 75 10             	pushl  0x10(%ebp)
  800a51:	ff 75 0c             	pushl  0xc(%ebp)
  800a54:	ff 75 08             	pushl  0x8(%ebp)
  800a57:	e8 87 ff ff ff       	call   8009e3 <memmove>
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a69:	89 c6                	mov    %eax,%esi
  800a6b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	eb 1a                	jmp    800a8a <memcmp+0x2c>
		if (*s1 != *s2)
  800a70:	0f b6 08             	movzbl (%eax),%ecx
  800a73:	0f b6 1a             	movzbl (%edx),%ebx
  800a76:	38 d9                	cmp    %bl,%cl
  800a78:	74 0a                	je     800a84 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a7a:	0f b6 c1             	movzbl %cl,%eax
  800a7d:	0f b6 db             	movzbl %bl,%ebx
  800a80:	29 d8                	sub    %ebx,%eax
  800a82:	eb 0f                	jmp    800a93 <memcmp+0x35>
		s1++, s2++;
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8a:	39 f0                	cmp    %esi,%eax
  800a8c:	75 e2                	jne    800a70 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	53                   	push   %ebx
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a9e:	89 c1                	mov    %eax,%ecx
  800aa0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa7:	eb 0a                	jmp    800ab3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa9:	0f b6 10             	movzbl (%eax),%edx
  800aac:	39 da                	cmp    %ebx,%edx
  800aae:	74 07                	je     800ab7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab0:	83 c0 01             	add    $0x1,%eax
  800ab3:	39 c8                	cmp    %ecx,%eax
  800ab5:	72 f2                	jb     800aa9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac6:	eb 03                	jmp    800acb <strtol+0x11>
		s++;
  800ac8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acb:	0f b6 01             	movzbl (%ecx),%eax
  800ace:	3c 20                	cmp    $0x20,%al
  800ad0:	74 f6                	je     800ac8 <strtol+0xe>
  800ad2:	3c 09                	cmp    $0x9,%al
  800ad4:	74 f2                	je     800ac8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad6:	3c 2b                	cmp    $0x2b,%al
  800ad8:	75 0a                	jne    800ae4 <strtol+0x2a>
		s++;
  800ada:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800add:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae2:	eb 11                	jmp    800af5 <strtol+0x3b>
  800ae4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae9:	3c 2d                	cmp    $0x2d,%al
  800aeb:	75 08                	jne    800af5 <strtol+0x3b>
		s++, neg = 1;
  800aed:	83 c1 01             	add    $0x1,%ecx
  800af0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afb:	75 15                	jne    800b12 <strtol+0x58>
  800afd:	80 39 30             	cmpb   $0x30,(%ecx)
  800b00:	75 10                	jne    800b12 <strtol+0x58>
  800b02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b06:	75 7c                	jne    800b84 <strtol+0xca>
		s += 2, base = 16;
  800b08:	83 c1 02             	add    $0x2,%ecx
  800b0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b10:	eb 16                	jmp    800b28 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b12:	85 db                	test   %ebx,%ebx
  800b14:	75 12                	jne    800b28 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b16:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1e:	75 08                	jne    800b28 <strtol+0x6e>
		s++, base = 8;
  800b20:	83 c1 01             	add    $0x1,%ecx
  800b23:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b30:	0f b6 11             	movzbl (%ecx),%edx
  800b33:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b36:	89 f3                	mov    %esi,%ebx
  800b38:	80 fb 09             	cmp    $0x9,%bl
  800b3b:	77 08                	ja     800b45 <strtol+0x8b>
			dig = *s - '0';
  800b3d:	0f be d2             	movsbl %dl,%edx
  800b40:	83 ea 30             	sub    $0x30,%edx
  800b43:	eb 22                	jmp    800b67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b45:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b48:	89 f3                	mov    %esi,%ebx
  800b4a:	80 fb 19             	cmp    $0x19,%bl
  800b4d:	77 08                	ja     800b57 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b4f:	0f be d2             	movsbl %dl,%edx
  800b52:	83 ea 57             	sub    $0x57,%edx
  800b55:	eb 10                	jmp    800b67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b57:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5a:	89 f3                	mov    %esi,%ebx
  800b5c:	80 fb 19             	cmp    $0x19,%bl
  800b5f:	77 16                	ja     800b77 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b67:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6a:	7d 0b                	jge    800b77 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b6c:	83 c1 01             	add    $0x1,%ecx
  800b6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b73:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b75:	eb b9                	jmp    800b30 <strtol+0x76>

	if (endptr)
  800b77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7b:	74 0d                	je     800b8a <strtol+0xd0>
		*endptr = (char *) s;
  800b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b80:	89 0e                	mov    %ecx,(%esi)
  800b82:	eb 06                	jmp    800b8a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b84:	85 db                	test   %ebx,%ebx
  800b86:	74 98                	je     800b20 <strtol+0x66>
  800b88:	eb 9e                	jmp    800b28 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	f7 da                	neg    %edx
  800b8e:	85 ff                	test   %edi,%edi
  800b90:	0f 45 c2             	cmovne %edx,%eax
}
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 c3                	mov    %eax,%ebx
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	89 c6                	mov    %eax,%esi
  800baf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be3:	b8 03 00 00 00       	mov    $0x3,%eax
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 cb                	mov    %ecx,%ebx
  800bed:	89 cf                	mov    %ecx,%edi
  800bef:	89 ce                	mov    %ecx,%esi
  800bf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 17                	jle    800c0e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 03                	push   $0x3
  800bfd:	68 ff 23 80 00       	push   $0x8023ff
  800c02:	6a 23                	push   $0x23
  800c04:	68 1c 24 80 00       	push   $0x80241c
  800c09:	e8 e5 f5 ff ff       	call   8001f3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	b8 02 00 00 00       	mov    $0x2,%eax
  800c26:	89 d1                	mov    %edx,%ecx
  800c28:	89 d3                	mov    %edx,%ebx
  800c2a:	89 d7                	mov    %edx,%edi
  800c2c:	89 d6                	mov    %edx,%esi
  800c2e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_yield>:

void
sys_yield(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5d:	be 00 00 00 00       	mov    $0x0,%esi
  800c62:	b8 04 00 00 00       	mov    $0x4,%eax
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c70:	89 f7                	mov    %esi,%edi
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 04                	push   $0x4
  800c7e:	68 ff 23 80 00       	push   $0x8023ff
  800c83:	6a 23                	push   $0x23
  800c85:	68 1c 24 80 00       	push   $0x80241c
  800c8a:	e8 64 f5 ff ff       	call   8001f3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 05                	push   $0x5
  800cc0:	68 ff 23 80 00       	push   $0x8023ff
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 1c 24 80 00       	push   $0x80241c
  800ccc:	e8 22 f5 ff ff       	call   8001f3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 17                	jle    800d13 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 06                	push   $0x6
  800d02:	68 ff 23 80 00       	push   $0x8023ff
  800d07:	6a 23                	push   $0x23
  800d09:	68 1c 24 80 00       	push   $0x80241c
  800d0e:	e8 e0 f4 ff ff       	call   8001f3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d29:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 df                	mov    %ebx,%edi
  800d36:	89 de                	mov    %ebx,%esi
  800d38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 17                	jle    800d55 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 08                	push   $0x8
  800d44:	68 ff 23 80 00       	push   $0x8023ff
  800d49:	6a 23                	push   $0x23
  800d4b:	68 1c 24 80 00       	push   $0x80241c
  800d50:	e8 9e f4 ff ff       	call   8001f3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 df                	mov    %ebx,%edi
  800d78:	89 de                	mov    %ebx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 09                	push   $0x9
  800d86:	68 ff 23 80 00       	push   $0x8023ff
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 1c 24 80 00       	push   $0x80241c
  800d92:	e8 5c f4 ff ff       	call   8001f3 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dad:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 df                	mov    %ebx,%edi
  800dba:	89 de                	mov    %ebx,%esi
  800dbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 17                	jle    800dd9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	6a 0a                	push   $0xa
  800dc8:	68 ff 23 80 00       	push   $0x8023ff
  800dcd:	6a 23                	push   $0x23
  800dcf:	68 1c 24 80 00       	push   $0x80241c
  800dd4:	e8 1a f4 ff ff       	call   8001f3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	be 00 00 00 00       	mov    $0x0,%esi
  800dec:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e12:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 cb                	mov    %ecx,%ebx
  800e1c:	89 cf                	mov    %ecx,%edi
  800e1e:	89 ce                	mov    %ecx,%esi
  800e20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 17                	jle    800e3d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	50                   	push   %eax
  800e2a:	6a 0d                	push   $0xd
  800e2c:	68 ff 23 80 00       	push   $0x8023ff
  800e31:	6a 23                	push   $0x23
  800e33:	68 1c 24 80 00       	push   $0x80241c
  800e38:	e8 b6 f3 ff ff       	call   8001f3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e50:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 cb                	mov    %ecx,%ebx
  800e5a:	89 cf                	mov    %ecx,%edi
  800e5c:	89 ce                	mov    %ecx,%esi
  800e5e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e70:	c1 e8 0c             	shr    $0xc,%eax
}
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e85:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e92:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	c1 ea 16             	shr    $0x16,%edx
  800e9c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea3:	f6 c2 01             	test   $0x1,%dl
  800ea6:	74 11                	je     800eb9 <fd_alloc+0x2d>
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	c1 ea 0c             	shr    $0xc,%edx
  800ead:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	75 09                	jne    800ec2 <fd_alloc+0x36>
			*fd_store = fd;
  800eb9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	eb 17                	jmp    800ed9 <fd_alloc+0x4d>
  800ec2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ecc:	75 c9                	jne    800e97 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ece:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee1:	83 f8 1f             	cmp    $0x1f,%eax
  800ee4:	77 36                	ja     800f1c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee6:	c1 e0 0c             	shl    $0xc,%eax
  800ee9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	c1 ea 16             	shr    $0x16,%edx
  800ef3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efa:	f6 c2 01             	test   $0x1,%dl
  800efd:	74 24                	je     800f23 <fd_lookup+0x48>
  800eff:	89 c2                	mov    %eax,%edx
  800f01:	c1 ea 0c             	shr    $0xc,%edx
  800f04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0b:	f6 c2 01             	test   $0x1,%dl
  800f0e:	74 1a                	je     800f2a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f13:	89 02                	mov    %eax,(%edx)
	return 0;
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	eb 13                	jmp    800f2f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f21:	eb 0c                	jmp    800f2f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f28:	eb 05                	jmp    800f2f <fd_lookup+0x54>
  800f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3a:	ba ac 24 80 00       	mov    $0x8024ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f3f:	eb 13                	jmp    800f54 <dev_lookup+0x23>
  800f41:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f44:	39 08                	cmp    %ecx,(%eax)
  800f46:	75 0c                	jne    800f54 <dev_lookup+0x23>
			*dev = devtab[i];
  800f48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f52:	eb 2e                	jmp    800f82 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f54:	8b 02                	mov    (%edx),%eax
  800f56:	85 c0                	test   %eax,%eax
  800f58:	75 e7                	jne    800f41 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5a:	a1 20 60 80 00       	mov    0x806020,%eax
  800f5f:	8b 40 50             	mov    0x50(%eax),%eax
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	51                   	push   %ecx
  800f66:	50                   	push   %eax
  800f67:	68 2c 24 80 00       	push   $0x80242c
  800f6c:	e8 5b f3 ff ff       	call   8002cc <cprintf>
	*dev = 0;
  800f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 10             	sub    $0x10,%esp
  800f8c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f9c:	c1 e8 0c             	shr    $0xc,%eax
  800f9f:	50                   	push   %eax
  800fa0:	e8 36 ff ff ff       	call   800edb <fd_lookup>
  800fa5:	83 c4 08             	add    $0x8,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 05                	js     800fb1 <fd_close+0x2d>
	    || fd != fd2)
  800fac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800faf:	74 0c                	je     800fbd <fd_close+0x39>
		return (must_exist ? r : 0);
  800fb1:	84 db                	test   %bl,%bl
  800fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb8:	0f 44 c2             	cmove  %edx,%eax
  800fbb:	eb 41                	jmp    800ffe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 36                	pushl  (%esi)
  800fc6:	e8 66 ff ff ff       	call   800f31 <dev_lookup>
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 1a                	js     800fee <fd_close+0x6a>
		if (dev->dev_close)
  800fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fda:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	74 0b                	je     800fee <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	56                   	push   %esi
  800fe7:	ff d0                	call   *%eax
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	56                   	push   %esi
  800ff2:	6a 00                	push   $0x0
  800ff4:	e8 e0 fc ff ff       	call   800cd9 <sys_page_unmap>
	return r;
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	89 d8                	mov    %ebx,%eax
}
  800ffe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100e:	50                   	push   %eax
  80100f:	ff 75 08             	pushl  0x8(%ebp)
  801012:	e8 c4 fe ff ff       	call   800edb <fd_lookup>
  801017:	83 c4 08             	add    $0x8,%esp
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 10                	js     80102e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	6a 01                	push   $0x1
  801023:	ff 75 f4             	pushl  -0xc(%ebp)
  801026:	e8 59 ff ff ff       	call   800f84 <fd_close>
  80102b:	83 c4 10             	add    $0x10,%esp
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <close_all>:

void
close_all(void)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	53                   	push   %ebx
  801034:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	53                   	push   %ebx
  801040:	e8 c0 ff ff ff       	call   801005 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801045:	83 c3 01             	add    $0x1,%ebx
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	83 fb 20             	cmp    $0x20,%ebx
  80104e:	75 ec                	jne    80103c <close_all+0xc>
		close(i);
}
  801050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 2c             	sub    $0x2c,%esp
  80105e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801061:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	ff 75 08             	pushl  0x8(%ebp)
  801068:	e8 6e fe ff ff       	call   800edb <fd_lookup>
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	0f 88 c1 00 00 00    	js     801139 <dup+0xe4>
		return r;
	close(newfdnum);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	56                   	push   %esi
  80107c:	e8 84 ff ff ff       	call   801005 <close>

	newfd = INDEX2FD(newfdnum);
  801081:	89 f3                	mov    %esi,%ebx
  801083:	c1 e3 0c             	shl    $0xc,%ebx
  801086:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80108c:	83 c4 04             	add    $0x4,%esp
  80108f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801092:	e8 de fd ff ff       	call   800e75 <fd2data>
  801097:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801099:	89 1c 24             	mov    %ebx,(%esp)
  80109c:	e8 d4 fd ff ff       	call   800e75 <fd2data>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a7:	89 f8                	mov    %edi,%eax
  8010a9:	c1 e8 16             	shr    $0x16,%eax
  8010ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b3:	a8 01                	test   $0x1,%al
  8010b5:	74 37                	je     8010ee <dup+0x99>
  8010b7:	89 f8                	mov    %edi,%eax
  8010b9:	c1 e8 0c             	shr    $0xc,%eax
  8010bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c3:	f6 c2 01             	test   $0x1,%dl
  8010c6:	74 26                	je     8010ee <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d7:	50                   	push   %eax
  8010d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010db:	6a 00                	push   $0x0
  8010dd:	57                   	push   %edi
  8010de:	6a 00                	push   $0x0
  8010e0:	e8 b2 fb ff ff       	call   800c97 <sys_page_map>
  8010e5:	89 c7                	mov    %eax,%edi
  8010e7:	83 c4 20             	add    $0x20,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 2e                	js     80111c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f1:	89 d0                	mov    %edx,%eax
  8010f3:	c1 e8 0c             	shr    $0xc,%eax
  8010f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	25 07 0e 00 00       	and    $0xe07,%eax
  801105:	50                   	push   %eax
  801106:	53                   	push   %ebx
  801107:	6a 00                	push   $0x0
  801109:	52                   	push   %edx
  80110a:	6a 00                	push   $0x0
  80110c:	e8 86 fb ff ff       	call   800c97 <sys_page_map>
  801111:	89 c7                	mov    %eax,%edi
  801113:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801116:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801118:	85 ff                	test   %edi,%edi
  80111a:	79 1d                	jns    801139 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	53                   	push   %ebx
  801120:	6a 00                	push   $0x0
  801122:	e8 b2 fb ff ff       	call   800cd9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801127:	83 c4 08             	add    $0x8,%esp
  80112a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112d:	6a 00                	push   $0x0
  80112f:	e8 a5 fb ff ff       	call   800cd9 <sys_page_unmap>
	return r;
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	89 f8                	mov    %edi,%eax
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	53                   	push   %ebx
  801145:	83 ec 14             	sub    $0x14,%esp
  801148:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114e:	50                   	push   %eax
  80114f:	53                   	push   %ebx
  801150:	e8 86 fd ff ff       	call   800edb <fd_lookup>
  801155:	83 c4 08             	add    $0x8,%esp
  801158:	89 c2                	mov    %eax,%edx
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 6d                	js     8011cb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801164:	50                   	push   %eax
  801165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801168:	ff 30                	pushl  (%eax)
  80116a:	e8 c2 fd ff ff       	call   800f31 <dev_lookup>
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	78 4c                	js     8011c2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801176:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801179:	8b 42 08             	mov    0x8(%edx),%eax
  80117c:	83 e0 03             	and    $0x3,%eax
  80117f:	83 f8 01             	cmp    $0x1,%eax
  801182:	75 21                	jne    8011a5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801184:	a1 20 60 80 00       	mov    0x806020,%eax
  801189:	8b 40 50             	mov    0x50(%eax),%eax
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	53                   	push   %ebx
  801190:	50                   	push   %eax
  801191:	68 70 24 80 00       	push   $0x802470
  801196:	e8 31 f1 ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a3:	eb 26                	jmp    8011cb <read+0x8a>
	}
	if (!dev->dev_read)
  8011a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a8:	8b 40 08             	mov    0x8(%eax),%eax
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 17                	je     8011c6 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	ff 75 10             	pushl  0x10(%ebp)
  8011b5:	ff 75 0c             	pushl  0xc(%ebp)
  8011b8:	52                   	push   %edx
  8011b9:	ff d0                	call   *%eax
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	eb 09                	jmp    8011cb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	eb 05                	jmp    8011cb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011cb:	89 d0                	mov    %edx,%eax
  8011cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	57                   	push   %edi
  8011d6:	56                   	push   %esi
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 0c             	sub    $0xc,%esp
  8011db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e6:	eb 21                	jmp    801209 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	89 f0                	mov    %esi,%eax
  8011ed:	29 d8                	sub    %ebx,%eax
  8011ef:	50                   	push   %eax
  8011f0:	89 d8                	mov    %ebx,%eax
  8011f2:	03 45 0c             	add    0xc(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	57                   	push   %edi
  8011f7:	e8 45 ff ff ff       	call   801141 <read>
		if (m < 0)
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 10                	js     801213 <readn+0x41>
			return m;
		if (m == 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	74 0a                	je     801211 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801207:	01 c3                	add    %eax,%ebx
  801209:	39 f3                	cmp    %esi,%ebx
  80120b:	72 db                	jb     8011e8 <readn+0x16>
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	eb 02                	jmp    801213 <readn+0x41>
  801211:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	83 ec 14             	sub    $0x14,%esp
  801222:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801225:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	53                   	push   %ebx
  80122a:	e8 ac fc ff ff       	call   800edb <fd_lookup>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	89 c2                	mov    %eax,%edx
  801234:	85 c0                	test   %eax,%eax
  801236:	78 68                	js     8012a0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123e:	50                   	push   %eax
  80123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801242:	ff 30                	pushl  (%eax)
  801244:	e8 e8 fc ff ff       	call   800f31 <dev_lookup>
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 47                	js     801297 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801253:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801257:	75 21                	jne    80127a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801259:	a1 20 60 80 00       	mov    0x806020,%eax
  80125e:	8b 40 50             	mov    0x50(%eax),%eax
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	53                   	push   %ebx
  801265:	50                   	push   %eax
  801266:	68 8c 24 80 00       	push   $0x80248c
  80126b:	e8 5c f0 ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801278:	eb 26                	jmp    8012a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127d:	8b 52 0c             	mov    0xc(%edx),%edx
  801280:	85 d2                	test   %edx,%edx
  801282:	74 17                	je     80129b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801284:	83 ec 04             	sub    $0x4,%esp
  801287:	ff 75 10             	pushl  0x10(%ebp)
  80128a:	ff 75 0c             	pushl  0xc(%ebp)
  80128d:	50                   	push   %eax
  80128e:	ff d2                	call   *%edx
  801290:	89 c2                	mov    %eax,%edx
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	eb 09                	jmp    8012a0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	89 c2                	mov    %eax,%edx
  801299:	eb 05                	jmp    8012a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80129b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012a0:	89 d0                	mov    %edx,%eax
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 75 08             	pushl  0x8(%ebp)
  8012b4:	e8 22 fc ff ff       	call   800edb <fd_lookup>
  8012b9:	83 c4 08             	add    $0x8,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 0e                	js     8012ce <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    

008012d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 14             	sub    $0x14,%esp
  8012d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	53                   	push   %ebx
  8012df:	e8 f7 fb ff ff       	call   800edb <fd_lookup>
  8012e4:	83 c4 08             	add    $0x8,%esp
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 65                	js     801352 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f7:	ff 30                	pushl  (%eax)
  8012f9:	e8 33 fc ff ff       	call   800f31 <dev_lookup>
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 44                	js     801349 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130c:	75 21                	jne    80132f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130e:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801313:	8b 40 50             	mov    0x50(%eax),%eax
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	53                   	push   %ebx
  80131a:	50                   	push   %eax
  80131b:	68 4c 24 80 00       	push   $0x80244c
  801320:	e8 a7 ef ff ff       	call   8002cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132d:	eb 23                	jmp    801352 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80132f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801332:	8b 52 18             	mov    0x18(%edx),%edx
  801335:	85 d2                	test   %edx,%edx
  801337:	74 14                	je     80134d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	50                   	push   %eax
  801340:	ff d2                	call   *%edx
  801342:	89 c2                	mov    %eax,%edx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	eb 09                	jmp    801352 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	89 c2                	mov    %eax,%edx
  80134b:	eb 05                	jmp    801352 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80134d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801352:	89 d0                	mov    %edx,%eax
  801354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	53                   	push   %ebx
  80135d:	83 ec 14             	sub    $0x14,%esp
  801360:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801363:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 6c fb ff ff       	call   800edb <fd_lookup>
  80136f:	83 c4 08             	add    $0x8,%esp
  801372:	89 c2                	mov    %eax,%edx
  801374:	85 c0                	test   %eax,%eax
  801376:	78 58                	js     8013d0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801382:	ff 30                	pushl  (%eax)
  801384:	e8 a8 fb ff ff       	call   800f31 <dev_lookup>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 37                	js     8013c7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801393:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801397:	74 32                	je     8013cb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801399:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80139c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a3:	00 00 00 
	stat->st_isdir = 0;
  8013a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ad:	00 00 00 
	stat->st_dev = dev;
  8013b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	53                   	push   %ebx
  8013ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8013bd:	ff 50 14             	call   *0x14(%eax)
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	eb 09                	jmp    8013d0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c7:	89 c2                	mov    %eax,%edx
  8013c9:	eb 05                	jmp    8013d0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013d0:	89 d0                	mov    %edx,%eax
  8013d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	6a 00                	push   $0x0
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 e3 01 00 00       	call   8015cc <open>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 1b                	js     80140d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	ff 75 0c             	pushl  0xc(%ebp)
  8013f8:	50                   	push   %eax
  8013f9:	e8 5b ff ff ff       	call   801359 <fstat>
  8013fe:	89 c6                	mov    %eax,%esi
	close(fd);
  801400:	89 1c 24             	mov    %ebx,(%esp)
  801403:	e8 fd fb ff ff       	call   801005 <close>
	return r;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	89 f0                	mov    %esi,%eax
}
  80140d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	89 c6                	mov    %eax,%esi
  80141b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801424:	75 12                	jne    801438 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	6a 01                	push   $0x1
  80142b:	e8 06 09 00 00       	call   801d36 <ipc_find_env>
  801430:	a3 00 40 80 00       	mov    %eax,0x804000
  801435:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801438:	6a 07                	push   $0x7
  80143a:	68 00 70 80 00       	push   $0x807000
  80143f:	56                   	push   %esi
  801440:	ff 35 00 40 80 00    	pushl  0x804000
  801446:	e8 89 08 00 00       	call   801cd4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144b:	83 c4 0c             	add    $0xc,%esp
  80144e:	6a 00                	push   $0x0
  801450:	53                   	push   %ebx
  801451:	6a 00                	push   $0x0
  801453:	e8 07 08 00 00       	call   801c5f <ipc_recv>
}
  801458:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    

0080145f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801465:	8b 45 08             	mov    0x8(%ebp),%eax
  801468:	8b 40 0c             	mov    0xc(%eax),%eax
  80146b:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801470:	8b 45 0c             	mov    0xc(%ebp),%eax
  801473:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801478:	ba 00 00 00 00       	mov    $0x0,%edx
  80147d:	b8 02 00 00 00       	mov    $0x2,%eax
  801482:	e8 8d ff ff ff       	call   801414 <fsipc>
}
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	8b 40 0c             	mov    0xc(%eax),%eax
  801495:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80149a:	ba 00 00 00 00       	mov    $0x0,%edx
  80149f:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a4:	e8 6b ff ff ff       	call   801414 <fsipc>
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bb:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ca:	e8 45 ff ff ff       	call   801414 <fsipc>
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 2c                	js     8014ff <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	68 00 70 80 00       	push   $0x807000
  8014db:	53                   	push   %ebx
  8014dc:	e8 70 f3 ff ff       	call   800851 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e1:	a1 80 70 80 00       	mov    0x807080,%eax
  8014e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ec:	a1 84 70 80 00       	mov    0x807084,%eax
  8014f1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80150d:	8b 55 08             	mov    0x8(%ebp),%edx
  801510:	8b 52 0c             	mov    0xc(%edx),%edx
  801513:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801519:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80151e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801523:	0f 47 c2             	cmova  %edx,%eax
  801526:	a3 04 70 80 00       	mov    %eax,0x807004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80152b:	50                   	push   %eax
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	68 08 70 80 00       	push   $0x807008
  801534:	e8 aa f4 ff ff       	call   8009e3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 04 00 00 00       	mov    $0x4,%eax
  801543:	e8 cc fe ff ff       	call   801414 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	8b 40 0c             	mov    0xc(%eax),%eax
  801558:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80155d:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 03 00 00 00       	mov    $0x3,%eax
  80156d:	e8 a2 fe ff ff       	call   801414 <fsipc>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	85 c0                	test   %eax,%eax
  801576:	78 4b                	js     8015c3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801578:	39 c6                	cmp    %eax,%esi
  80157a:	73 16                	jae    801592 <devfile_read+0x48>
  80157c:	68 bc 24 80 00       	push   $0x8024bc
  801581:	68 c3 24 80 00       	push   $0x8024c3
  801586:	6a 7c                	push   $0x7c
  801588:	68 d8 24 80 00       	push   $0x8024d8
  80158d:	e8 61 ec ff ff       	call   8001f3 <_panic>
	assert(r <= PGSIZE);
  801592:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801597:	7e 16                	jle    8015af <devfile_read+0x65>
  801599:	68 e3 24 80 00       	push   $0x8024e3
  80159e:	68 c3 24 80 00       	push   $0x8024c3
  8015a3:	6a 7d                	push   $0x7d
  8015a5:	68 d8 24 80 00       	push   $0x8024d8
  8015aa:	e8 44 ec ff ff       	call   8001f3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	50                   	push   %eax
  8015b3:	68 00 70 80 00       	push   $0x807000
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	e8 23 f4 ff ff       	call   8009e3 <memmove>
	return r;
  8015c0:	83 c4 10             	add    $0x10,%esp
}
  8015c3:	89 d8                	mov    %ebx,%eax
  8015c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 20             	sub    $0x20,%esp
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d6:	53                   	push   %ebx
  8015d7:	e8 3c f2 ff ff       	call   800818 <strlen>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e4:	7f 67                	jg     80164d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	e8 9a f8 ff ff       	call   800e8c <fd_alloc>
  8015f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 57                	js     801652 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	68 00 70 80 00       	push   $0x807000
  801604:	e8 48 f2 ff ff       	call   800851 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801609:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160c:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801614:	b8 01 00 00 00       	mov    $0x1,%eax
  801619:	e8 f6 fd ff ff       	call   801414 <fsipc>
  80161e:	89 c3                	mov    %eax,%ebx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	79 14                	jns    80163b <open+0x6f>
		fd_close(fd, 0);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	6a 00                	push   $0x0
  80162c:	ff 75 f4             	pushl  -0xc(%ebp)
  80162f:	e8 50 f9 ff ff       	call   800f84 <fd_close>
		return r;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	89 da                	mov    %ebx,%edx
  801639:	eb 17                	jmp    801652 <open+0x86>
	}

	return fd2num(fd);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	ff 75 f4             	pushl  -0xc(%ebp)
  801641:	e8 1f f8 ff ff       	call   800e65 <fd2num>
  801646:	89 c2                	mov    %eax,%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 05                	jmp    801652 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801652:	89 d0                	mov    %edx,%eax
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165f:	ba 00 00 00 00       	mov    $0x0,%edx
  801664:	b8 08 00 00 00       	mov    $0x8,%eax
  801669:	e8 a6 fd ff ff       	call   801414 <fsipc>
}
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801670:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801674:	7e 37                	jle    8016ad <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	53                   	push   %ebx
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80167f:	ff 70 04             	pushl  0x4(%eax)
  801682:	8d 40 10             	lea    0x10(%eax),%eax
  801685:	50                   	push   %eax
  801686:	ff 33                	pushl  (%ebx)
  801688:	e8 8e fb ff ff       	call   80121b <write>
		if (result > 0)
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	7e 03                	jle    801697 <writebuf+0x27>
			b->result += result;
  801694:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801697:	3b 43 04             	cmp    0x4(%ebx),%eax
  80169a:	74 0d                	je     8016a9 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80169c:	85 c0                	test   %eax,%eax
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	0f 4f c2             	cmovg  %edx,%eax
  8016a6:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	f3 c3                	repz ret 

008016af <putch>:

static void
putch(int ch, void *thunk)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 04             	sub    $0x4,%esp
  8016b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016b9:	8b 53 04             	mov    0x4(%ebx),%edx
  8016bc:	8d 42 01             	lea    0x1(%edx),%eax
  8016bf:	89 43 04             	mov    %eax,0x4(%ebx)
  8016c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c5:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016c9:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016ce:	75 0e                	jne    8016de <putch+0x2f>
		writebuf(b);
  8016d0:	89 d8                	mov    %ebx,%eax
  8016d2:	e8 99 ff ff ff       	call   801670 <writebuf>
		b->idx = 0;
  8016d7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016de:	83 c4 04             	add    $0x4,%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016f6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016fd:	00 00 00 
	b.result = 0;
  801700:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801707:	00 00 00 
	b.error = 1;
  80170a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801711:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801714:	ff 75 10             	pushl  0x10(%ebp)
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	68 af 16 80 00       	push   $0x8016af
  801726:	e8 d8 ec ff ff       	call   800403 <vprintfmt>
	if (b.idx > 0)
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801735:	7e 0b                	jle    801742 <vfprintf+0x5e>
		writebuf(&b);
  801737:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80173d:	e8 2e ff ff ff       	call   801670 <writebuf>

	return (b.result ? b.result : b.error);
  801742:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801748:	85 c0                	test   %eax,%eax
  80174a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801759:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80175c:	50                   	push   %eax
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	e8 7c ff ff ff       	call   8016e4 <vfprintf>
	va_end(ap);

	return cnt;
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <printf>:

int
printf(const char *fmt, ...)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801770:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801773:	50                   	push   %eax
  801774:	ff 75 08             	pushl  0x8(%ebp)
  801777:	6a 01                	push   $0x1
  801779:	e8 66 ff ff ff       	call   8016e4 <vfprintf>
	va_end(ap);

	return cnt;
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801788:	83 ec 0c             	sub    $0xc,%esp
  80178b:	ff 75 08             	pushl  0x8(%ebp)
  80178e:	e8 e2 f6 ff ff       	call   800e75 <fd2data>
  801793:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801795:	83 c4 08             	add    $0x8,%esp
  801798:	68 ef 24 80 00       	push   $0x8024ef
  80179d:	53                   	push   %ebx
  80179e:	e8 ae f0 ff ff       	call   800851 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017a3:	8b 46 04             	mov    0x4(%esi),%eax
  8017a6:	2b 06                	sub    (%esi),%eax
  8017a8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b5:	00 00 00 
	stat->st_dev = &devpipe;
  8017b8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017bf:	30 80 00 
	return 0;
}
  8017c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d8:	53                   	push   %ebx
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 f9 f4 ff ff       	call   800cd9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017e0:	89 1c 24             	mov    %ebx,(%esp)
  8017e3:	e8 8d f6 ff ff       	call   800e75 <fd2data>
  8017e8:	83 c4 08             	add    $0x8,%esp
  8017eb:	50                   	push   %eax
  8017ec:	6a 00                	push   $0x0
  8017ee:	e8 e6 f4 ff ff       	call   800cd9 <sys_page_unmap>
}
  8017f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	57                   	push   %edi
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 1c             	sub    $0x1c,%esp
  801801:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801804:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801806:	a1 20 60 80 00       	mov    0x806020,%eax
  80180b:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80180e:	83 ec 0c             	sub    $0xc,%esp
  801811:	ff 75 e0             	pushl  -0x20(%ebp)
  801814:	e8 5d 05 00 00       	call   801d76 <pageref>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	89 3c 24             	mov    %edi,(%esp)
  80181e:	e8 53 05 00 00       	call   801d76 <pageref>
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	39 c3                	cmp    %eax,%ebx
  801828:	0f 94 c1             	sete   %cl
  80182b:	0f b6 c9             	movzbl %cl,%ecx
  80182e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801831:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801837:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80183a:	39 ce                	cmp    %ecx,%esi
  80183c:	74 1b                	je     801859 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80183e:	39 c3                	cmp    %eax,%ebx
  801840:	75 c4                	jne    801806 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801842:	8b 42 60             	mov    0x60(%edx),%eax
  801845:	ff 75 e4             	pushl  -0x1c(%ebp)
  801848:	50                   	push   %eax
  801849:	56                   	push   %esi
  80184a:	68 f6 24 80 00       	push   $0x8024f6
  80184f:	e8 78 ea ff ff       	call   8002cc <cprintf>
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	eb ad                	jmp    801806 <_pipeisclosed+0xe>
	}
}
  801859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80185c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5f                   	pop    %edi
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	57                   	push   %edi
  801868:	56                   	push   %esi
  801869:	53                   	push   %ebx
  80186a:	83 ec 28             	sub    $0x28,%esp
  80186d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801870:	56                   	push   %esi
  801871:	e8 ff f5 ff ff       	call   800e75 <fd2data>
  801876:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	bf 00 00 00 00       	mov    $0x0,%edi
  801880:	eb 4b                	jmp    8018cd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801882:	89 da                	mov    %ebx,%edx
  801884:	89 f0                	mov    %esi,%eax
  801886:	e8 6d ff ff ff       	call   8017f8 <_pipeisclosed>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	75 48                	jne    8018d7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80188f:	e8 a1 f3 ff ff       	call   800c35 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801894:	8b 43 04             	mov    0x4(%ebx),%eax
  801897:	8b 0b                	mov    (%ebx),%ecx
  801899:	8d 51 20             	lea    0x20(%ecx),%edx
  80189c:	39 d0                	cmp    %edx,%eax
  80189e:	73 e2                	jae    801882 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018a7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018aa:	89 c2                	mov    %eax,%edx
  8018ac:	c1 fa 1f             	sar    $0x1f,%edx
  8018af:	89 d1                	mov    %edx,%ecx
  8018b1:	c1 e9 1b             	shr    $0x1b,%ecx
  8018b4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018b7:	83 e2 1f             	and    $0x1f,%edx
  8018ba:	29 ca                	sub    %ecx,%edx
  8018bc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018c4:	83 c0 01             	add    $0x1,%eax
  8018c7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ca:	83 c7 01             	add    $0x1,%edi
  8018cd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018d0:	75 c2                	jne    801894 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d5:	eb 05                	jmp    8018dc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018d7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5f                   	pop    %edi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	57                   	push   %edi
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	83 ec 18             	sub    $0x18,%esp
  8018ed:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018f0:	57                   	push   %edi
  8018f1:	e8 7f f5 ff ff       	call   800e75 <fd2data>
  8018f6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801900:	eb 3d                	jmp    80193f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801902:	85 db                	test   %ebx,%ebx
  801904:	74 04                	je     80190a <devpipe_read+0x26>
				return i;
  801906:	89 d8                	mov    %ebx,%eax
  801908:	eb 44                	jmp    80194e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80190a:	89 f2                	mov    %esi,%edx
  80190c:	89 f8                	mov    %edi,%eax
  80190e:	e8 e5 fe ff ff       	call   8017f8 <_pipeisclosed>
  801913:	85 c0                	test   %eax,%eax
  801915:	75 32                	jne    801949 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801917:	e8 19 f3 ff ff       	call   800c35 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80191c:	8b 06                	mov    (%esi),%eax
  80191e:	3b 46 04             	cmp    0x4(%esi),%eax
  801921:	74 df                	je     801902 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801923:	99                   	cltd   
  801924:	c1 ea 1b             	shr    $0x1b,%edx
  801927:	01 d0                	add    %edx,%eax
  801929:	83 e0 1f             	and    $0x1f,%eax
  80192c:	29 d0                	sub    %edx,%eax
  80192e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801933:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801936:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801939:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193c:	83 c3 01             	add    $0x1,%ebx
  80193f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801942:	75 d8                	jne    80191c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801944:	8b 45 10             	mov    0x10(%ebp),%eax
  801947:	eb 05                	jmp    80194e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801949:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80194e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801951:	5b                   	pop    %ebx
  801952:	5e                   	pop    %esi
  801953:	5f                   	pop    %edi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80195e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	e8 25 f5 ff ff       	call   800e8c <fd_alloc>
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	89 c2                	mov    %eax,%edx
  80196c:	85 c0                	test   %eax,%eax
  80196e:	0f 88 2c 01 00 00    	js     801aa0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801974:	83 ec 04             	sub    $0x4,%esp
  801977:	68 07 04 00 00       	push   $0x407
  80197c:	ff 75 f4             	pushl  -0xc(%ebp)
  80197f:	6a 00                	push   $0x0
  801981:	e8 ce f2 ff ff       	call   800c54 <sys_page_alloc>
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	89 c2                	mov    %eax,%edx
  80198b:	85 c0                	test   %eax,%eax
  80198d:	0f 88 0d 01 00 00    	js     801aa0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801999:	50                   	push   %eax
  80199a:	e8 ed f4 ff ff       	call   800e8c <fd_alloc>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	0f 88 e2 00 00 00    	js     801a8e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ac:	83 ec 04             	sub    $0x4,%esp
  8019af:	68 07 04 00 00       	push   $0x407
  8019b4:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b7:	6a 00                	push   $0x0
  8019b9:	e8 96 f2 ff ff       	call   800c54 <sys_page_alloc>
  8019be:	89 c3                	mov    %eax,%ebx
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	0f 88 c3 00 00 00    	js     801a8e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019cb:	83 ec 0c             	sub    $0xc,%esp
  8019ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d1:	e8 9f f4 ff ff       	call   800e75 <fd2data>
  8019d6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d8:	83 c4 0c             	add    $0xc,%esp
  8019db:	68 07 04 00 00       	push   $0x407
  8019e0:	50                   	push   %eax
  8019e1:	6a 00                	push   $0x0
  8019e3:	e8 6c f2 ff ff       	call   800c54 <sys_page_alloc>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	0f 88 89 00 00 00    	js     801a7e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019fb:	e8 75 f4 ff ff       	call   800e75 <fd2data>
  801a00:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a07:	50                   	push   %eax
  801a08:	6a 00                	push   $0x0
  801a0a:	56                   	push   %esi
  801a0b:	6a 00                	push   $0x0
  801a0d:	e8 85 f2 ff ff       	call   800c97 <sys_page_map>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	83 c4 20             	add    $0x20,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 55                	js     801a70 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a1b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a24:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a39:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4b:	e8 15 f4 ff ff       	call   800e65 <fd2num>
  801a50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a53:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a55:	83 c4 04             	add    $0x4,%esp
  801a58:	ff 75 f0             	pushl  -0x10(%ebp)
  801a5b:	e8 05 f4 ff ff       	call   800e65 <fd2num>
  801a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a63:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6e:	eb 30                	jmp    801aa0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	56                   	push   %esi
  801a74:	6a 00                	push   $0x0
  801a76:	e8 5e f2 ff ff       	call   800cd9 <sys_page_unmap>
  801a7b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	ff 75 f0             	pushl  -0x10(%ebp)
  801a84:	6a 00                	push   $0x0
  801a86:	e8 4e f2 ff ff       	call   800cd9 <sys_page_unmap>
  801a8b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	ff 75 f4             	pushl  -0xc(%ebp)
  801a94:	6a 00                	push   $0x0
  801a96:	e8 3e f2 ff ff       	call   800cd9 <sys_page_unmap>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801aa0:	89 d0                	mov    %edx,%eax
  801aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab2:	50                   	push   %eax
  801ab3:	ff 75 08             	pushl  0x8(%ebp)
  801ab6:	e8 20 f4 ff ff       	call   800edb <fd_lookup>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 18                	js     801ada <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac8:	e8 a8 f3 ff ff       	call   800e75 <fd2data>
	return _pipeisclosed(fd, p);
  801acd:	89 c2                	mov    %eax,%edx
  801acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad2:	e8 21 fd ff ff       	call   8017f8 <_pipeisclosed>
  801ad7:	83 c4 10             	add    $0x10,%esp
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801adf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801aec:	68 0e 25 80 00       	push   $0x80250e
  801af1:	ff 75 0c             	pushl  0xc(%ebp)
  801af4:	e8 58 ed ff ff       	call   800851 <strcpy>
	return 0;
}
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	57                   	push   %edi
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b0c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b11:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b17:	eb 2d                	jmp    801b46 <devcons_write+0x46>
		m = n - tot;
  801b19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b1c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b1e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b21:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b26:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b29:	83 ec 04             	sub    $0x4,%esp
  801b2c:	53                   	push   %ebx
  801b2d:	03 45 0c             	add    0xc(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	57                   	push   %edi
  801b32:	e8 ac ee ff ff       	call   8009e3 <memmove>
		sys_cputs(buf, m);
  801b37:	83 c4 08             	add    $0x8,%esp
  801b3a:	53                   	push   %ebx
  801b3b:	57                   	push   %edi
  801b3c:	e8 57 f0 ff ff       	call   800b98 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b41:	01 de                	add    %ebx,%esi
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	89 f0                	mov    %esi,%eax
  801b48:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b4b:	72 cc                	jb     801b19 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b64:	74 2a                	je     801b90 <devcons_read+0x3b>
  801b66:	eb 05                	jmp    801b6d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b68:	e8 c8 f0 ff ff       	call   800c35 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b6d:	e8 44 f0 ff ff       	call   800bb6 <sys_cgetc>
  801b72:	85 c0                	test   %eax,%eax
  801b74:	74 f2                	je     801b68 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 16                	js     801b90 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b7a:	83 f8 04             	cmp    $0x4,%eax
  801b7d:	74 0c                	je     801b8b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b82:	88 02                	mov    %al,(%edx)
	return 1;
  801b84:	b8 01 00 00 00       	mov    $0x1,%eax
  801b89:	eb 05                	jmp    801b90 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b9e:	6a 01                	push   $0x1
  801ba0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 ef ef ff ff       	call   800b98 <sys_cputs>
}
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <getchar>:

int
getchar(void)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bb4:	6a 01                	push   $0x1
  801bb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb9:	50                   	push   %eax
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 80 f5 ff ff       	call   801141 <read>
	if (r < 0)
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 0f                	js     801bd7 <getchar+0x29>
		return r;
	if (r < 1)
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	7e 06                	jle    801bd2 <getchar+0x24>
		return -E_EOF;
	return c;
  801bcc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bd0:	eb 05                	jmp    801bd7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bd2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	50                   	push   %eax
  801be3:	ff 75 08             	pushl  0x8(%ebp)
  801be6:	e8 f0 f2 ff ff       	call   800edb <fd_lookup>
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 11                	js     801c03 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bfb:	39 10                	cmp    %edx,(%eax)
  801bfd:	0f 94 c0             	sete   %al
  801c00:	0f b6 c0             	movzbl %al,%eax
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <opencons>:

int
opencons(void)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0e:	50                   	push   %eax
  801c0f:	e8 78 f2 ff ff       	call   800e8c <fd_alloc>
  801c14:	83 c4 10             	add    $0x10,%esp
		return r;
  801c17:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 3e                	js     801c5b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c1d:	83 ec 04             	sub    $0x4,%esp
  801c20:	68 07 04 00 00       	push   $0x407
  801c25:	ff 75 f4             	pushl  -0xc(%ebp)
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 25 f0 ff ff       	call   800c54 <sys_page_alloc>
  801c2f:	83 c4 10             	add    $0x10,%esp
		return r;
  801c32:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c34:	85 c0                	test   %eax,%eax
  801c36:	78 23                	js     801c5b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c38:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c41:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c46:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	50                   	push   %eax
  801c51:	e8 0f f2 ff ff       	call   800e65 <fd2num>
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	83 c4 10             	add    $0x10,%esp
}
  801c5b:	89 d0                	mov    %edx,%eax
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	8b 75 08             	mov    0x8(%ebp),%esi
  801c67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	75 12                	jne    801c83 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	68 00 00 c0 ee       	push   $0xeec00000
  801c79:	e8 86 f1 ff ff       	call   800e04 <sys_ipc_recv>
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	eb 0c                	jmp    801c8f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	50                   	push   %eax
  801c87:	e8 78 f1 ff ff       	call   800e04 <sys_ipc_recv>
  801c8c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801c8f:	85 f6                	test   %esi,%esi
  801c91:	0f 95 c1             	setne  %cl
  801c94:	85 db                	test   %ebx,%ebx
  801c96:	0f 95 c2             	setne  %dl
  801c99:	84 d1                	test   %dl,%cl
  801c9b:	74 09                	je     801ca6 <ipc_recv+0x47>
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	c1 ea 1f             	shr    $0x1f,%edx
  801ca2:	84 d2                	test   %dl,%dl
  801ca4:	75 27                	jne    801ccd <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ca6:	85 f6                	test   %esi,%esi
  801ca8:	74 0a                	je     801cb4 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801caa:	a1 20 60 80 00       	mov    0x806020,%eax
  801caf:	8b 40 7c             	mov    0x7c(%eax),%eax
  801cb2:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801cb4:	85 db                	test   %ebx,%ebx
  801cb6:	74 0d                	je     801cc5 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801cb8:	a1 20 60 80 00       	mov    0x806020,%eax
  801cbd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801cc3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801cc5:	a1 20 60 80 00       	mov    0x806020,%eax
  801cca:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ccd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	57                   	push   %edi
  801cd8:	56                   	push   %esi
  801cd9:	53                   	push   %ebx
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ce0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ce6:	85 db                	test   %ebx,%ebx
  801ce8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ced:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801cf0:	ff 75 14             	pushl  0x14(%ebp)
  801cf3:	53                   	push   %ebx
  801cf4:	56                   	push   %esi
  801cf5:	57                   	push   %edi
  801cf6:	e8 e6 f0 ff ff       	call   800de1 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801cfb:	89 c2                	mov    %eax,%edx
  801cfd:	c1 ea 1f             	shr    $0x1f,%edx
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	84 d2                	test   %dl,%dl
  801d05:	74 17                	je     801d1e <ipc_send+0x4a>
  801d07:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d0a:	74 12                	je     801d1e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801d0c:	50                   	push   %eax
  801d0d:	68 1a 25 80 00       	push   $0x80251a
  801d12:	6a 47                	push   $0x47
  801d14:	68 28 25 80 00       	push   $0x802528
  801d19:	e8 d5 e4 ff ff       	call   8001f3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801d1e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d21:	75 07                	jne    801d2a <ipc_send+0x56>
			sys_yield();
  801d23:	e8 0d ef ff ff       	call   800c35 <sys_yield>
  801d28:	eb c6                	jmp    801cf0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	75 c2                	jne    801cf0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d31:	5b                   	pop    %ebx
  801d32:	5e                   	pop    %esi
  801d33:	5f                   	pop    %edi
  801d34:	5d                   	pop    %ebp
  801d35:	c3                   	ret    

00801d36 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d41:	89 c2                	mov    %eax,%edx
  801d43:	c1 e2 07             	shl    $0x7,%edx
  801d46:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801d4d:	8b 52 58             	mov    0x58(%edx),%edx
  801d50:	39 ca                	cmp    %ecx,%edx
  801d52:	75 11                	jne    801d65 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801d54:	89 c2                	mov    %eax,%edx
  801d56:	c1 e2 07             	shl    $0x7,%edx
  801d59:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801d60:	8b 40 50             	mov    0x50(%eax),%eax
  801d63:	eb 0f                	jmp    801d74 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d65:	83 c0 01             	add    $0x1,%eax
  801d68:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d6d:	75 d2                	jne    801d41 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d7c:	89 d0                	mov    %edx,%eax
  801d7e:	c1 e8 16             	shr    $0x16,%eax
  801d81:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d88:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d8d:	f6 c1 01             	test   $0x1,%cl
  801d90:	74 1d                	je     801daf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d92:	c1 ea 0c             	shr    $0xc,%edx
  801d95:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d9c:	f6 c2 01             	test   $0x1,%dl
  801d9f:	74 0e                	je     801daf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801da1:	c1 ea 0c             	shr    $0xc,%edx
  801da4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dab:	ef 
  801dac:	0f b7 c0             	movzwl %ax,%eax
}
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    
  801db1:	66 90                	xchg   %ax,%ax
  801db3:	66 90                	xchg   %ax,%ax
  801db5:	66 90                	xchg   %ax,%ax
  801db7:	66 90                	xchg   %ax,%ax
  801db9:	66 90                	xchg   %ax,%ax
  801dbb:	66 90                	xchg   %ax,%ax
  801dbd:	66 90                	xchg   %ax,%ax
  801dbf:	90                   	nop

00801dc0 <__udivdi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 f6                	test   %esi,%esi
  801dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ddd:	89 ca                	mov    %ecx,%edx
  801ddf:	89 f8                	mov    %edi,%eax
  801de1:	75 3d                	jne    801e20 <__udivdi3+0x60>
  801de3:	39 cf                	cmp    %ecx,%edi
  801de5:	0f 87 c5 00 00 00    	ja     801eb0 <__udivdi3+0xf0>
  801deb:	85 ff                	test   %edi,%edi
  801ded:	89 fd                	mov    %edi,%ebp
  801def:	75 0b                	jne    801dfc <__udivdi3+0x3c>
  801df1:	b8 01 00 00 00       	mov    $0x1,%eax
  801df6:	31 d2                	xor    %edx,%edx
  801df8:	f7 f7                	div    %edi
  801dfa:	89 c5                	mov    %eax,%ebp
  801dfc:	89 c8                	mov    %ecx,%eax
  801dfe:	31 d2                	xor    %edx,%edx
  801e00:	f7 f5                	div    %ebp
  801e02:	89 c1                	mov    %eax,%ecx
  801e04:	89 d8                	mov    %ebx,%eax
  801e06:	89 cf                	mov    %ecx,%edi
  801e08:	f7 f5                	div    %ebp
  801e0a:	89 c3                	mov    %eax,%ebx
  801e0c:	89 d8                	mov    %ebx,%eax
  801e0e:	89 fa                	mov    %edi,%edx
  801e10:	83 c4 1c             	add    $0x1c,%esp
  801e13:	5b                   	pop    %ebx
  801e14:	5e                   	pop    %esi
  801e15:	5f                   	pop    %edi
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    
  801e18:	90                   	nop
  801e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e20:	39 ce                	cmp    %ecx,%esi
  801e22:	77 74                	ja     801e98 <__udivdi3+0xd8>
  801e24:	0f bd fe             	bsr    %esi,%edi
  801e27:	83 f7 1f             	xor    $0x1f,%edi
  801e2a:	0f 84 98 00 00 00    	je     801ec8 <__udivdi3+0x108>
  801e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e35:	89 f9                	mov    %edi,%ecx
  801e37:	89 c5                	mov    %eax,%ebp
  801e39:	29 fb                	sub    %edi,%ebx
  801e3b:	d3 e6                	shl    %cl,%esi
  801e3d:	89 d9                	mov    %ebx,%ecx
  801e3f:	d3 ed                	shr    %cl,%ebp
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	d3 e0                	shl    %cl,%eax
  801e45:	09 ee                	or     %ebp,%esi
  801e47:	89 d9                	mov    %ebx,%ecx
  801e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e4d:	89 d5                	mov    %edx,%ebp
  801e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e53:	d3 ed                	shr    %cl,%ebp
  801e55:	89 f9                	mov    %edi,%ecx
  801e57:	d3 e2                	shl    %cl,%edx
  801e59:	89 d9                	mov    %ebx,%ecx
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	09 c2                	or     %eax,%edx
  801e5f:	89 d0                	mov    %edx,%eax
  801e61:	89 ea                	mov    %ebp,%edx
  801e63:	f7 f6                	div    %esi
  801e65:	89 d5                	mov    %edx,%ebp
  801e67:	89 c3                	mov    %eax,%ebx
  801e69:	f7 64 24 0c          	mull   0xc(%esp)
  801e6d:	39 d5                	cmp    %edx,%ebp
  801e6f:	72 10                	jb     801e81 <__udivdi3+0xc1>
  801e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e75:	89 f9                	mov    %edi,%ecx
  801e77:	d3 e6                	shl    %cl,%esi
  801e79:	39 c6                	cmp    %eax,%esi
  801e7b:	73 07                	jae    801e84 <__udivdi3+0xc4>
  801e7d:	39 d5                	cmp    %edx,%ebp
  801e7f:	75 03                	jne    801e84 <__udivdi3+0xc4>
  801e81:	83 eb 01             	sub    $0x1,%ebx
  801e84:	31 ff                	xor    %edi,%edi
  801e86:	89 d8                	mov    %ebx,%eax
  801e88:	89 fa                	mov    %edi,%edx
  801e8a:	83 c4 1c             	add    $0x1c,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	31 ff                	xor    %edi,%edi
  801e9a:	31 db                	xor    %ebx,%ebx
  801e9c:	89 d8                	mov    %ebx,%eax
  801e9e:	89 fa                	mov    %edi,%edx
  801ea0:	83 c4 1c             	add    $0x1c,%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5f                   	pop    %edi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    
  801ea8:	90                   	nop
  801ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	89 d8                	mov    %ebx,%eax
  801eb2:	f7 f7                	div    %edi
  801eb4:	31 ff                	xor    %edi,%edi
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	89 d8                	mov    %ebx,%eax
  801eba:	89 fa                	mov    %edi,%edx
  801ebc:	83 c4 1c             	add    $0x1c,%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    
  801ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ec8:	39 ce                	cmp    %ecx,%esi
  801eca:	72 0c                	jb     801ed8 <__udivdi3+0x118>
  801ecc:	31 db                	xor    %ebx,%ebx
  801ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ed2:	0f 87 34 ff ff ff    	ja     801e0c <__udivdi3+0x4c>
  801ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801edd:	e9 2a ff ff ff       	jmp    801e0c <__udivdi3+0x4c>
  801ee2:	66 90                	xchg   %ax,%ax
  801ee4:	66 90                	xchg   %ax,%ax
  801ee6:	66 90                	xchg   %ax,%ax
  801ee8:	66 90                	xchg   %ax,%ax
  801eea:	66 90                	xchg   %ax,%ax
  801eec:	66 90                	xchg   %ax,%ax
  801eee:	66 90                	xchg   %ax,%ax

00801ef0 <__umoddi3>:
  801ef0:	55                   	push   %ebp
  801ef1:	57                   	push   %edi
  801ef2:	56                   	push   %esi
  801ef3:	53                   	push   %ebx
  801ef4:	83 ec 1c             	sub    $0x1c,%esp
  801ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f07:	85 d2                	test   %edx,%edx
  801f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f11:	89 f3                	mov    %esi,%ebx
  801f13:	89 3c 24             	mov    %edi,(%esp)
  801f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1a:	75 1c                	jne    801f38 <__umoddi3+0x48>
  801f1c:	39 f7                	cmp    %esi,%edi
  801f1e:	76 50                	jbe    801f70 <__umoddi3+0x80>
  801f20:	89 c8                	mov    %ecx,%eax
  801f22:	89 f2                	mov    %esi,%edx
  801f24:	f7 f7                	div    %edi
  801f26:	89 d0                	mov    %edx,%eax
  801f28:	31 d2                	xor    %edx,%edx
  801f2a:	83 c4 1c             	add    $0x1c,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    
  801f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f38:	39 f2                	cmp    %esi,%edx
  801f3a:	89 d0                	mov    %edx,%eax
  801f3c:	77 52                	ja     801f90 <__umoddi3+0xa0>
  801f3e:	0f bd ea             	bsr    %edx,%ebp
  801f41:	83 f5 1f             	xor    $0x1f,%ebp
  801f44:	75 5a                	jne    801fa0 <__umoddi3+0xb0>
  801f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f4a:	0f 82 e0 00 00 00    	jb     802030 <__umoddi3+0x140>
  801f50:	39 0c 24             	cmp    %ecx,(%esp)
  801f53:	0f 86 d7 00 00 00    	jbe    802030 <__umoddi3+0x140>
  801f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f61:	83 c4 1c             	add    $0x1c,%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5f                   	pop    %edi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	85 ff                	test   %edi,%edi
  801f72:	89 fd                	mov    %edi,%ebp
  801f74:	75 0b                	jne    801f81 <__umoddi3+0x91>
  801f76:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	f7 f7                	div    %edi
  801f7f:	89 c5                	mov    %eax,%ebp
  801f81:	89 f0                	mov    %esi,%eax
  801f83:	31 d2                	xor    %edx,%edx
  801f85:	f7 f5                	div    %ebp
  801f87:	89 c8                	mov    %ecx,%eax
  801f89:	f7 f5                	div    %ebp
  801f8b:	89 d0                	mov    %edx,%eax
  801f8d:	eb 99                	jmp    801f28 <__umoddi3+0x38>
  801f8f:	90                   	nop
  801f90:	89 c8                	mov    %ecx,%eax
  801f92:	89 f2                	mov    %esi,%edx
  801f94:	83 c4 1c             	add    $0x1c,%esp
  801f97:	5b                   	pop    %ebx
  801f98:	5e                   	pop    %esi
  801f99:	5f                   	pop    %edi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    
  801f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	8b 34 24             	mov    (%esp),%esi
  801fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  801fa8:	89 e9                	mov    %ebp,%ecx
  801faa:	29 ef                	sub    %ebp,%edi
  801fac:	d3 e0                	shl    %cl,%eax
  801fae:	89 f9                	mov    %edi,%ecx
  801fb0:	89 f2                	mov    %esi,%edx
  801fb2:	d3 ea                	shr    %cl,%edx
  801fb4:	89 e9                	mov    %ebp,%ecx
  801fb6:	09 c2                	or     %eax,%edx
  801fb8:	89 d8                	mov    %ebx,%eax
  801fba:	89 14 24             	mov    %edx,(%esp)
  801fbd:	89 f2                	mov    %esi,%edx
  801fbf:	d3 e2                	shl    %cl,%edx
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	89 e9                	mov    %ebp,%ecx
  801fcf:	89 c6                	mov    %eax,%esi
  801fd1:	d3 e3                	shl    %cl,%ebx
  801fd3:	89 f9                	mov    %edi,%ecx
  801fd5:	89 d0                	mov    %edx,%eax
  801fd7:	d3 e8                	shr    %cl,%eax
  801fd9:	89 e9                	mov    %ebp,%ecx
  801fdb:	09 d8                	or     %ebx,%eax
  801fdd:	89 d3                	mov    %edx,%ebx
  801fdf:	89 f2                	mov    %esi,%edx
  801fe1:	f7 34 24             	divl   (%esp)
  801fe4:	89 d6                	mov    %edx,%esi
  801fe6:	d3 e3                	shl    %cl,%ebx
  801fe8:	f7 64 24 04          	mull   0x4(%esp)
  801fec:	39 d6                	cmp    %edx,%esi
  801fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ff2:	89 d1                	mov    %edx,%ecx
  801ff4:	89 c3                	mov    %eax,%ebx
  801ff6:	72 08                	jb     802000 <__umoddi3+0x110>
  801ff8:	75 11                	jne    80200b <__umoddi3+0x11b>
  801ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ffe:	73 0b                	jae    80200b <__umoddi3+0x11b>
  802000:	2b 44 24 04          	sub    0x4(%esp),%eax
  802004:	1b 14 24             	sbb    (%esp),%edx
  802007:	89 d1                	mov    %edx,%ecx
  802009:	89 c3                	mov    %eax,%ebx
  80200b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80200f:	29 da                	sub    %ebx,%edx
  802011:	19 ce                	sbb    %ecx,%esi
  802013:	89 f9                	mov    %edi,%ecx
  802015:	89 f0                	mov    %esi,%eax
  802017:	d3 e0                	shl    %cl,%eax
  802019:	89 e9                	mov    %ebp,%ecx
  80201b:	d3 ea                	shr    %cl,%edx
  80201d:	89 e9                	mov    %ebp,%ecx
  80201f:	d3 ee                	shr    %cl,%esi
  802021:	09 d0                	or     %edx,%eax
  802023:	89 f2                	mov    %esi,%edx
  802025:	83 c4 1c             	add    $0x1c,%esp
  802028:	5b                   	pop    %ebx
  802029:	5e                   	pop    %esi
  80202a:	5f                   	pop    %edi
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    
  80202d:	8d 76 00             	lea    0x0(%esi),%esi
  802030:	29 f9                	sub    %edi,%ecx
  802032:	19 d6                	sbb    %edx,%esi
  802034:	89 74 24 04          	mov    %esi,0x4(%esp)
  802038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80203c:	e9 18 ff ff ff       	jmp    801f59 <__umoddi3+0x69>
