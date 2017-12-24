
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 40 21 80 00       	push   $0x802140
  80003e:	e8 05 02 00 00       	call   800248 <cprintf>
	exit();
  800043:	e8 53 01 00 00       	call   80019b <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 55 0d 00 00       	call   800dc1 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 5b 0d 00 00       	call   800df1 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 57 13 00 00       	call   801409 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 54 21 80 00       	push   $0x802154
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 29 17 00 00       	call   801803 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 54 21 80 00       	push   $0x802154
  8000f5:	e8 4e 01 00 00       	call   800248 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800116:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80011d:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800120:	e8 6d 0a 00 00       	call   800b92 <sys_getenvid>
  800125:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80012b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800130:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80013a:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80013d:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800143:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800146:	39 c8                	cmp    %ecx,%eax
  800148:	0f 44 fb             	cmove  %ebx,%edi
  80014b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800150:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800153:	83 c2 01             	add    $0x1,%edx
  800156:	83 c3 7c             	add    $0x7c,%ebx
  800159:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80015f:	75 d9                	jne    80013a <libmain+0x2d>
  800161:	89 f0                	mov    %esi,%eax
  800163:	84 c0                	test   %al,%al
  800165:	74 06                	je     80016d <libmain+0x60>
  800167:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800171:	7e 0a                	jle    80017d <libmain+0x70>
		binaryname = argv[0];
  800173:	8b 45 0c             	mov    0xc(%ebp),%eax
  800176:	8b 00                	mov    (%eax),%eax
  800178:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	e8 c2 fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  80018b:	e8 0b 00 00 00       	call   80019b <exit>
}
  800190:	83 c4 10             	add    $0x10,%esp
  800193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800196:	5b                   	pop    %ebx
  800197:	5e                   	pop    %esi
  800198:	5f                   	pop    %edi
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001a1:	e8 3a 0f 00 00       	call   8010e0 <close_all>
	sys_env_destroy(0);
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	6a 00                	push   $0x0
  8001ab:	e8 a1 09 00 00       	call   800b51 <sys_env_destroy>
}
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 04             	sub    $0x4,%esp
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001bf:	8b 13                	mov    (%ebx),%edx
  8001c1:	8d 42 01             	lea    0x1(%edx),%eax
  8001c4:	89 03                	mov    %eax,(%ebx)
  8001c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d2:	75 1a                	jne    8001ee <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	68 ff 00 00 00       	push   $0xff
  8001dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001df:	50                   	push   %eax
  8001e0:	e8 2f 09 00 00       	call   800b14 <sys_cputs>
		b->idx = 0;
  8001e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001eb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	ff 75 0c             	pushl  0xc(%ebp)
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	50                   	push   %eax
  800221:	68 b5 01 80 00       	push   $0x8001b5
  800226:	e8 54 01 00 00       	call   80037f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	83 c4 08             	add    $0x8,%esp
  80022e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800234:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023a:	50                   	push   %eax
  80023b:	e8 d4 08 00 00       	call   800b14 <sys_cputs>

	return b.cnt;
}
  800240:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800251:	50                   	push   %eax
  800252:	ff 75 08             	pushl  0x8(%ebp)
  800255:	e8 9d ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 1c             	sub    $0x1c,%esp
  800265:	89 c7                	mov    %eax,%edi
  800267:	89 d6                	mov    %edx,%esi
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800272:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800275:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800283:	39 d3                	cmp    %edx,%ebx
  800285:	72 05                	jb     80028c <printnum+0x30>
  800287:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028a:	77 45                	ja     8002d1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	ff 75 18             	pushl  0x18(%ebp)
  800292:	8b 45 14             	mov    0x14(%ebp),%eax
  800295:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800298:	53                   	push   %ebx
  800299:	ff 75 10             	pushl  0x10(%ebp)
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ab:	e8 f0 1b 00 00       	call   801ea0 <__udivdi3>
  8002b0:	83 c4 18             	add    $0x18,%esp
  8002b3:	52                   	push   %edx
  8002b4:	50                   	push   %eax
  8002b5:	89 f2                	mov    %esi,%edx
  8002b7:	89 f8                	mov    %edi,%eax
  8002b9:	e8 9e ff ff ff       	call   80025c <printnum>
  8002be:	83 c4 20             	add    $0x20,%esp
  8002c1:	eb 18                	jmp    8002db <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	56                   	push   %esi
  8002c7:	ff 75 18             	pushl  0x18(%ebp)
  8002ca:	ff d7                	call   *%edi
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	eb 03                	jmp    8002d4 <printnum+0x78>
  8002d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d4:	83 eb 01             	sub    $0x1,%ebx
  8002d7:	85 db                	test   %ebx,%ebx
  8002d9:	7f e8                	jg     8002c3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002db:	83 ec 08             	sub    $0x8,%esp
  8002de:	56                   	push   %esi
  8002df:	83 ec 04             	sub    $0x4,%esp
  8002e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ee:	e8 dd 1c 00 00       	call   801fd0 <__umoddi3>
  8002f3:	83 c4 14             	add    $0x14,%esp
  8002f6:	0f be 80 86 21 80 00 	movsbl 0x802186(%eax),%eax
  8002fd:	50                   	push   %eax
  8002fe:	ff d7                	call   *%edi
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030e:	83 fa 01             	cmp    $0x1,%edx
  800311:	7e 0e                	jle    800321 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 08             	lea    0x8(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	8b 52 04             	mov    0x4(%edx),%edx
  80031f:	eb 22                	jmp    800343 <getuint+0x38>
	else if (lflag)
  800321:	85 d2                	test   %edx,%edx
  800323:	74 10                	je     800335 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	eb 0e                	jmp    800343 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800335:	8b 10                	mov    (%eax),%edx
  800337:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033a:	89 08                	mov    %ecx,(%eax)
  80033c:	8b 02                	mov    (%edx),%eax
  80033e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	3b 50 04             	cmp    0x4(%eax),%edx
  800354:	73 0a                	jae    800360 <sprintputch+0x1b>
		*b->buf++ = ch;
  800356:	8d 4a 01             	lea    0x1(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	88 02                	mov    %al,(%edx)
}
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    

00800362 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800368:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036b:	50                   	push   %eax
  80036c:	ff 75 10             	pushl  0x10(%ebp)
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	ff 75 08             	pushl  0x8(%ebp)
  800375:	e8 05 00 00 00       	call   80037f <vprintfmt>
	va_end(ap);
}
  80037a:	83 c4 10             	add    $0x10,%esp
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    

0080037f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 2c             	sub    $0x2c,%esp
  800388:	8b 75 08             	mov    0x8(%ebp),%esi
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80038e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800391:	eb 12                	jmp    8003a5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800393:	85 c0                	test   %eax,%eax
  800395:	0f 84 89 03 00 00    	je     800724 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	53                   	push   %ebx
  80039f:	50                   	push   %eax
  8003a0:	ff d6                	call   *%esi
  8003a2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a5:	83 c7 01             	add    $0x1,%edi
  8003a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003ac:	83 f8 25             	cmp    $0x25,%eax
  8003af:	75 e2                	jne    800393 <vprintfmt+0x14>
  8003b1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003b5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003bc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cf:	eb 07                	jmp    8003d8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8d 47 01             	lea    0x1(%edi),%eax
  8003db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003de:	0f b6 07             	movzbl (%edi),%eax
  8003e1:	0f b6 c8             	movzbl %al,%ecx
  8003e4:	83 e8 23             	sub    $0x23,%eax
  8003e7:	3c 55                	cmp    $0x55,%al
  8003e9:	0f 87 1a 03 00 00    	ja     800709 <vprintfmt+0x38a>
  8003ef:	0f b6 c0             	movzbl %al,%eax
  8003f2:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800400:	eb d6                	jmp    8003d8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800405:	b8 00 00 00 00       	mov    $0x0,%eax
  80040a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800410:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800414:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800417:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80041a:	83 fa 09             	cmp    $0x9,%edx
  80041d:	77 39                	ja     800458 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800422:	eb e9                	jmp    80040d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 48 04             	lea    0x4(%eax),%ecx
  80042a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800435:	eb 27                	jmp    80045e <vprintfmt+0xdf>
  800437:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80043a:	85 c0                	test   %eax,%eax
  80043c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800441:	0f 49 c8             	cmovns %eax,%ecx
  800444:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044a:	eb 8c                	jmp    8003d8 <vprintfmt+0x59>
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80044f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800456:	eb 80                	jmp    8003d8 <vprintfmt+0x59>
  800458:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80045b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	0f 89 70 ff ff ff    	jns    8003d8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800468:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800475:	e9 5e ff ff ff       	jmp    8003d8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800480:	e9 53 ff ff ff       	jmp    8003d8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	ff 30                	pushl  (%eax)
  800494:	ff d6                	call   *%esi
			break;
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80049c:	e9 04 ff ff ff       	jmp    8003a5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	99                   	cltd   
  8004ad:	31 d0                	xor    %edx,%eax
  8004af:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b1:	83 f8 0f             	cmp    $0xf,%eax
  8004b4:	7f 0b                	jg     8004c1 <vprintfmt+0x142>
  8004b6:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	75 18                	jne    8004d9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004c1:	50                   	push   %eax
  8004c2:	68 9e 21 80 00       	push   $0x80219e
  8004c7:	53                   	push   %ebx
  8004c8:	56                   	push   %esi
  8004c9:	e8 94 fe ff ff       	call   800362 <printfmt>
  8004ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d4:	e9 cc fe ff ff       	jmp    8003a5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004d9:	52                   	push   %edx
  8004da:	68 51 25 80 00       	push   $0x802551
  8004df:	53                   	push   %ebx
  8004e0:	56                   	push   %esi
  8004e1:	e8 7c fe ff ff       	call   800362 <printfmt>
  8004e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ec:	e9 b4 fe ff ff       	jmp    8003a5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	b8 97 21 80 00       	mov    $0x802197,%eax
  800503:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800506:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050a:	0f 8e 94 00 00 00    	jle    8005a4 <vprintfmt+0x225>
  800510:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800514:	0f 84 98 00 00 00    	je     8005b2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 d0             	pushl  -0x30(%ebp)
  800520:	57                   	push   %edi
  800521:	e8 86 02 00 00       	call   8007ac <strnlen>
  800526:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800529:	29 c1                	sub    %eax,%ecx
  80052b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800531:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800535:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800538:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	eb 0f                	jmp    80054e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	ff 75 e0             	pushl  -0x20(%ebp)
  800546:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f ed                	jg     80053f <vprintfmt+0x1c0>
  800552:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800555:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
  80055f:	0f 49 c1             	cmovns %ecx,%eax
  800562:	29 c1                	sub    %eax,%ecx
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	89 cb                	mov    %ecx,%ebx
  80056f:	eb 4d                	jmp    8005be <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800571:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800575:	74 1b                	je     800592 <vprintfmt+0x213>
  800577:	0f be c0             	movsbl %al,%eax
  80057a:	83 e8 20             	sub    $0x20,%eax
  80057d:	83 f8 5e             	cmp    $0x5e,%eax
  800580:	76 10                	jbe    800592 <vprintfmt+0x213>
					putch('?', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	ff 75 0c             	pushl  0xc(%ebp)
  800588:	6a 3f                	push   $0x3f
  80058a:	ff 55 08             	call   *0x8(%ebp)
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	eb 0d                	jmp    80059f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	ff 75 0c             	pushl  0xc(%ebp)
  800598:	52                   	push   %edx
  800599:	ff 55 08             	call   *0x8(%ebp)
  80059c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059f:	83 eb 01             	sub    $0x1,%ebx
  8005a2:	eb 1a                	jmp    8005be <vprintfmt+0x23f>
  8005a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b0:	eb 0c                	jmp    8005be <vprintfmt+0x23f>
  8005b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005be:	83 c7 01             	add    $0x1,%edi
  8005c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c5:	0f be d0             	movsbl %al,%edx
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	74 23                	je     8005ef <vprintfmt+0x270>
  8005cc:	85 f6                	test   %esi,%esi
  8005ce:	78 a1                	js     800571 <vprintfmt+0x1f2>
  8005d0:	83 ee 01             	sub    $0x1,%esi
  8005d3:	79 9c                	jns    800571 <vprintfmt+0x1f2>
  8005d5:	89 df                	mov    %ebx,%edi
  8005d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005dd:	eb 18                	jmp    8005f7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 20                	push   $0x20
  8005e5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	83 ef 01             	sub    $0x1,%edi
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	eb 08                	jmp    8005f7 <vprintfmt+0x278>
  8005ef:	89 df                	mov    %ebx,%edi
  8005f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f e4                	jg     8005df <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fe:	e9 a2 fd ff ff       	jmp    8003a5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 fa 01             	cmp    $0x1,%edx
  800606:	7e 16                	jle    80061e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 08             	lea    0x8(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 50 04             	mov    0x4(%eax),%edx
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061c:	eb 32                	jmp    800650 <vprintfmt+0x2d1>
	else if (lflag)
  80061e:	85 d2                	test   %edx,%edx
  800620:	74 18                	je     80063a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	89 c1                	mov    %eax,%ecx
  800632:	c1 f9 1f             	sar    $0x1f,%ecx
  800635:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800638:	eb 16                	jmp    800650 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 c1                	mov    %eax,%ecx
  80064a:	c1 f9 1f             	sar    $0x1f,%ecx
  80064d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800650:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800653:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80065f:	79 74                	jns    8006d5 <vprintfmt+0x356>
				putch('-', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	6a 2d                	push   $0x2d
  800667:	ff d6                	call   *%esi
				num = -(long long) num;
  800669:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80066f:	f7 d8                	neg    %eax
  800671:	83 d2 00             	adc    $0x0,%edx
  800674:	f7 da                	neg    %edx
  800676:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800679:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80067e:	eb 55                	jmp    8006d5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 83 fc ff ff       	call   80030b <getuint>
			base = 10;
  800688:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80068d:	eb 46                	jmp    8006d5 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 74 fc ff ff       	call   80030b <getuint>
			base = 8;
  800697:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80069c:	eb 37                	jmp    8006d5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 30                	push   $0x30
  8006a4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a6:	83 c4 08             	add    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 78                	push   $0x78
  8006ac:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	8b 00                	mov    (%eax),%eax
  8006b9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006be:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c6:	eb 0d                	jmp    8006d5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cb:	e8 3b fc ff ff       	call   80030b <getuint>
			base = 16;
  8006d0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006dc:	57                   	push   %edi
  8006dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e0:	51                   	push   %ecx
  8006e1:	52                   	push   %edx
  8006e2:	50                   	push   %eax
  8006e3:	89 da                	mov    %ebx,%edx
  8006e5:	89 f0                	mov    %esi,%eax
  8006e7:	e8 70 fb ff ff       	call   80025c <printnum>
			break;
  8006ec:	83 c4 20             	add    $0x20,%esp
  8006ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f2:	e9 ae fc ff ff       	jmp    8003a5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	51                   	push   %ecx
  8006fc:	ff d6                	call   *%esi
			break;
  8006fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800704:	e9 9c fc ff ff       	jmp    8003a5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 25                	push   $0x25
  80070f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb 03                	jmp    800719 <vprintfmt+0x39a>
  800716:	83 ef 01             	sub    $0x1,%edi
  800719:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80071d:	75 f7                	jne    800716 <vprintfmt+0x397>
  80071f:	e9 81 fc ff ff       	jmp    8003a5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800727:	5b                   	pop    %ebx
  800728:	5e                   	pop    %esi
  800729:	5f                   	pop    %edi
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	83 ec 18             	sub    $0x18,%esp
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800738:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800742:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800749:	85 c0                	test   %eax,%eax
  80074b:	74 26                	je     800773 <vsnprintf+0x47>
  80074d:	85 d2                	test   %edx,%edx
  80074f:	7e 22                	jle    800773 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800751:	ff 75 14             	pushl  0x14(%ebp)
  800754:	ff 75 10             	pushl  0x10(%ebp)
  800757:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075a:	50                   	push   %eax
  80075b:	68 45 03 80 00       	push   $0x800345
  800760:	e8 1a fc ff ff       	call   80037f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800765:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800768:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	eb 05                	jmp    800778 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800783:	50                   	push   %eax
  800784:	ff 75 10             	pushl  0x10(%ebp)
  800787:	ff 75 0c             	pushl  0xc(%ebp)
  80078a:	ff 75 08             	pushl  0x8(%ebp)
  80078d:	e8 9a ff ff ff       	call   80072c <vsnprintf>
	va_end(ap);

	return rc;
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
  80079f:	eb 03                	jmp    8007a4 <strlen+0x10>
		n++;
  8007a1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a8:	75 f7                	jne    8007a1 <strlen+0xd>
		n++;
	return n;
}
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ba:	eb 03                	jmp    8007bf <strnlen+0x13>
		n++;
  8007bc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	39 c2                	cmp    %eax,%edx
  8007c1:	74 08                	je     8007cb <strnlen+0x1f>
  8007c3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c7:	75 f3                	jne    8007bc <strnlen+0x10>
  8007c9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	53                   	push   %ebx
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d7:	89 c2                	mov    %eax,%edx
  8007d9:	83 c2 01             	add    $0x1,%edx
  8007dc:	83 c1 01             	add    $0x1,%ecx
  8007df:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e6:	84 db                	test   %bl,%bl
  8007e8:	75 ef                	jne    8007d9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f4:	53                   	push   %ebx
  8007f5:	e8 9a ff ff ff       	call   800794 <strlen>
  8007fa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	01 d8                	add    %ebx,%eax
  800802:	50                   	push   %eax
  800803:	e8 c5 ff ff ff       	call   8007cd <strcpy>
	return dst;
}
  800808:	89 d8                	mov    %ebx,%eax
  80080a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	8b 75 08             	mov    0x8(%ebp),%esi
  800817:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081a:	89 f3                	mov    %esi,%ebx
  80081c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081f:	89 f2                	mov    %esi,%edx
  800821:	eb 0f                	jmp    800832 <strncpy+0x23>
		*dst++ = *src;
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	0f b6 01             	movzbl (%ecx),%eax
  800829:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082c:	80 39 01             	cmpb   $0x1,(%ecx)
  80082f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800832:	39 da                	cmp    %ebx,%edx
  800834:	75 ed                	jne    800823 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800836:	89 f0                	mov    %esi,%eax
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 75 08             	mov    0x8(%ebp),%esi
  800844:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800847:	8b 55 10             	mov    0x10(%ebp),%edx
  80084a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	85 d2                	test   %edx,%edx
  80084e:	74 21                	je     800871 <strlcpy+0x35>
  800850:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800854:	89 f2                	mov    %esi,%edx
  800856:	eb 09                	jmp    800861 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800858:	83 c2 01             	add    $0x1,%edx
  80085b:	83 c1 01             	add    $0x1,%ecx
  80085e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800861:	39 c2                	cmp    %eax,%edx
  800863:	74 09                	je     80086e <strlcpy+0x32>
  800865:	0f b6 19             	movzbl (%ecx),%ebx
  800868:	84 db                	test   %bl,%bl
  80086a:	75 ec                	jne    800858 <strlcpy+0x1c>
  80086c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80086e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800871:	29 f0                	sub    %esi,%eax
}
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800880:	eb 06                	jmp    800888 <strcmp+0x11>
		p++, q++;
  800882:	83 c1 01             	add    $0x1,%ecx
  800885:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800888:	0f b6 01             	movzbl (%ecx),%eax
  80088b:	84 c0                	test   %al,%al
  80088d:	74 04                	je     800893 <strcmp+0x1c>
  80088f:	3a 02                	cmp    (%edx),%al
  800891:	74 ef                	je     800882 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 c0             	movzbl %al,%eax
  800896:	0f b6 12             	movzbl (%edx),%edx
  800899:	29 d0                	sub    %edx,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	53                   	push   %ebx
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	89 c3                	mov    %eax,%ebx
  8008a9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ac:	eb 06                	jmp    8008b4 <strncmp+0x17>
		n--, p++, q++;
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b4:	39 d8                	cmp    %ebx,%eax
  8008b6:	74 15                	je     8008cd <strncmp+0x30>
  8008b8:	0f b6 08             	movzbl (%eax),%ecx
  8008bb:	84 c9                	test   %cl,%cl
  8008bd:	74 04                	je     8008c3 <strncmp+0x26>
  8008bf:	3a 0a                	cmp    (%edx),%cl
  8008c1:	74 eb                	je     8008ae <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 00             	movzbl (%eax),%eax
  8008c6:	0f b6 12             	movzbl (%edx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
  8008cb:	eb 05                	jmp    8008d2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008df:	eb 07                	jmp    8008e8 <strchr+0x13>
		if (*s == c)
  8008e1:	38 ca                	cmp    %cl,%dl
  8008e3:	74 0f                	je     8008f4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e5:	83 c0 01             	add    $0x1,%eax
  8008e8:	0f b6 10             	movzbl (%eax),%edx
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	75 f2                	jne    8008e1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800900:	eb 03                	jmp    800905 <strfind+0xf>
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 04                	je     800910 <strfind+0x1a>
  80090c:	84 d2                	test   %dl,%dl
  80090e:	75 f2                	jne    800902 <strfind+0xc>
			break;
	return (char *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 36                	je     800958 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800922:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800928:	75 28                	jne    800952 <memset+0x40>
  80092a:	f6 c1 03             	test   $0x3,%cl
  80092d:	75 23                	jne    800952 <memset+0x40>
		c &= 0xFF;
  80092f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800933:	89 d3                	mov    %edx,%ebx
  800935:	c1 e3 08             	shl    $0x8,%ebx
  800938:	89 d6                	mov    %edx,%esi
  80093a:	c1 e6 18             	shl    $0x18,%esi
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	c1 e0 10             	shl    $0x10,%eax
  800942:	09 f0                	or     %esi,%eax
  800944:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800946:	89 d8                	mov    %ebx,%eax
  800948:	09 d0                	or     %edx,%eax
  80094a:	c1 e9 02             	shr    $0x2,%ecx
  80094d:	fc                   	cld    
  80094e:	f3 ab                	rep stos %eax,%es:(%edi)
  800950:	eb 06                	jmp    800958 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	fc                   	cld    
  800956:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800958:	89 f8                	mov    %edi,%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5f                   	pop    %edi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096d:	39 c6                	cmp    %eax,%esi
  80096f:	73 35                	jae    8009a6 <memmove+0x47>
  800971:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800974:	39 d0                	cmp    %edx,%eax
  800976:	73 2e                	jae    8009a6 <memmove+0x47>
		s += n;
		d += n;
  800978:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097b:	89 d6                	mov    %edx,%esi
  80097d:	09 fe                	or     %edi,%esi
  80097f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800985:	75 13                	jne    80099a <memmove+0x3b>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 0e                	jne    80099a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098c:	83 ef 04             	sub    $0x4,%edi
  80098f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	fd                   	std    
  800996:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800998:	eb 09                	jmp    8009a3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099a:	83 ef 01             	sub    $0x1,%edi
  80099d:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a0:	fd                   	std    
  8009a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a3:	fc                   	cld    
  8009a4:	eb 1d                	jmp    8009c3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	89 f2                	mov    %esi,%edx
  8009a8:	09 c2                	or     %eax,%edx
  8009aa:	f6 c2 03             	test   $0x3,%dl
  8009ad:	75 0f                	jne    8009be <memmove+0x5f>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 0a                	jne    8009be <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
  8009b7:	89 c7                	mov    %eax,%edi
  8009b9:	fc                   	cld    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 05                	jmp    8009c3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009be:	89 c7                	mov    %eax,%edi
  8009c0:	fc                   	cld    
  8009c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ca:	ff 75 10             	pushl  0x10(%ebp)
  8009cd:	ff 75 0c             	pushl  0xc(%ebp)
  8009d0:	ff 75 08             	pushl  0x8(%ebp)
  8009d3:	e8 87 ff ff ff       	call   80095f <memmove>
}
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e5:	89 c6                	mov    %eax,%esi
  8009e7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ea:	eb 1a                	jmp    800a06 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ec:	0f b6 08             	movzbl (%eax),%ecx
  8009ef:	0f b6 1a             	movzbl (%edx),%ebx
  8009f2:	38 d9                	cmp    %bl,%cl
  8009f4:	74 0a                	je     800a00 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f6:	0f b6 c1             	movzbl %cl,%eax
  8009f9:	0f b6 db             	movzbl %bl,%ebx
  8009fc:	29 d8                	sub    %ebx,%eax
  8009fe:	eb 0f                	jmp    800a0f <memcmp+0x35>
		s1++, s2++;
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a06:	39 f0                	cmp    %esi,%eax
  800a08:	75 e2                	jne    8009ec <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	53                   	push   %ebx
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a1a:	89 c1                	mov    %eax,%ecx
  800a1c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a23:	eb 0a                	jmp    800a2f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	39 da                	cmp    %ebx,%edx
  800a2a:	74 07                	je     800a33 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	39 c8                	cmp    %ecx,%eax
  800a31:	72 f2                	jb     800a25 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a33:	5b                   	pop    %ebx
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a42:	eb 03                	jmp    800a47 <strtol+0x11>
		s++;
  800a44:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a47:	0f b6 01             	movzbl (%ecx),%eax
  800a4a:	3c 20                	cmp    $0x20,%al
  800a4c:	74 f6                	je     800a44 <strtol+0xe>
  800a4e:	3c 09                	cmp    $0x9,%al
  800a50:	74 f2                	je     800a44 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a52:	3c 2b                	cmp    $0x2b,%al
  800a54:	75 0a                	jne    800a60 <strtol+0x2a>
		s++;
  800a56:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5e:	eb 11                	jmp    800a71 <strtol+0x3b>
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a65:	3c 2d                	cmp    $0x2d,%al
  800a67:	75 08                	jne    800a71 <strtol+0x3b>
		s++, neg = 1;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a71:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a77:	75 15                	jne    800a8e <strtol+0x58>
  800a79:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7c:	75 10                	jne    800a8e <strtol+0x58>
  800a7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a82:	75 7c                	jne    800b00 <strtol+0xca>
		s += 2, base = 16;
  800a84:	83 c1 02             	add    $0x2,%ecx
  800a87:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8c:	eb 16                	jmp    800aa4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a8e:	85 db                	test   %ebx,%ebx
  800a90:	75 12                	jne    800aa4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a92:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a97:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9a:	75 08                	jne    800aa4 <strtol+0x6e>
		s++, base = 8;
  800a9c:	83 c1 01             	add    $0x1,%ecx
  800a9f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aac:	0f b6 11             	movzbl (%ecx),%edx
  800aaf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 09             	cmp    $0x9,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0x8b>
			dig = *s - '0';
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 30             	sub    $0x30,%edx
  800abf:	eb 22                	jmp    800ae3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 08                	ja     800ad3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 57             	sub    $0x57,%edx
  800ad1:	eb 10                	jmp    800ae3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 19             	cmp    $0x19,%bl
  800adb:	77 16                	ja     800af3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800add:	0f be d2             	movsbl %dl,%edx
  800ae0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae6:	7d 0b                	jge    800af3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae8:	83 c1 01             	add    $0x1,%ecx
  800aeb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aef:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af1:	eb b9                	jmp    800aac <strtol+0x76>

	if (endptr)
  800af3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af7:	74 0d                	je     800b06 <strtol+0xd0>
		*endptr = (char *) s;
  800af9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afc:	89 0e                	mov    %ecx,(%esi)
  800afe:	eb 06                	jmp    800b06 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b00:	85 db                	test   %ebx,%ebx
  800b02:	74 98                	je     800a9c <strtol+0x66>
  800b04:	eb 9e                	jmp    800aa4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b06:	89 c2                	mov    %eax,%edx
  800b08:	f7 da                	neg    %edx
  800b0a:	85 ff                	test   %edi,%edi
  800b0c:	0f 45 c2             	cmovne %edx,%eax
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	89 c7                	mov    %eax,%edi
  800b29:	89 c6                	mov    %eax,%esi
  800b2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 cb                	mov    %ecx,%ebx
  800b69:	89 cf                	mov    %ecx,%edi
  800b6b:	89 ce                	mov    %ecx,%esi
  800b6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 17                	jle    800b8a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	50                   	push   %eax
  800b77:	6a 03                	push   $0x3
  800b79:	68 7f 24 80 00       	push   $0x80247f
  800b7e:	6a 23                	push   $0x23
  800b80:	68 9c 24 80 00       	push   $0x80249c
  800b85:	e8 85 11 00 00       	call   801d0f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_yield>:

void
sys_yield(void)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	89 d7                	mov    %edx,%edi
  800bc7:	89 d6                	mov    %edx,%esi
  800bc9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd9:	be 00 00 00 00       	mov    $0x0,%esi
  800bde:	b8 04 00 00 00       	mov    $0x4,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bec:	89 f7                	mov    %esi,%edi
  800bee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7e 17                	jle    800c0b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	50                   	push   %eax
  800bf8:	6a 04                	push   $0x4
  800bfa:	68 7f 24 80 00       	push   $0x80247f
  800bff:	6a 23                	push   $0x23
  800c01:	68 9c 24 80 00       	push   $0x80249c
  800c06:	e8 04 11 00 00       	call   801d0f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 05                	push   $0x5
  800c3c:	68 7f 24 80 00       	push   $0x80247f
  800c41:	6a 23                	push   $0x23
  800c43:	68 9c 24 80 00       	push   $0x80249c
  800c48:	e8 c2 10 00 00       	call   801d0f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c63:	b8 06 00 00 00       	mov    $0x6,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	89 df                	mov    %ebx,%edi
  800c70:	89 de                	mov    %ebx,%esi
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 06                	push   $0x6
  800c7e:	68 7f 24 80 00       	push   $0x80247f
  800c83:	6a 23                	push   $0x23
  800c85:	68 9c 24 80 00       	push   $0x80249c
  800c8a:	e8 80 10 00 00       	call   801d0f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	b8 08 00 00 00       	mov    $0x8,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 08                	push   $0x8
  800cc0:	68 7f 24 80 00       	push   $0x80247f
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 9c 24 80 00       	push   $0x80249c
  800ccc:	e8 3e 10 00 00       	call   801d0f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800ce7:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800cfa:	7e 17                	jle    800d13 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 09                	push   $0x9
  800d02:	68 7f 24 80 00       	push   $0x80247f
  800d07:	6a 23                	push   $0x23
  800d09:	68 9c 24 80 00       	push   $0x80249c
  800d0e:	e8 fc 0f 00 00       	call   801d0f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d29:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d3c:	7e 17                	jle    800d55 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 0a                	push   $0xa
  800d44:	68 7f 24 80 00       	push   $0x80247f
  800d49:	6a 23                	push   $0x23
  800d4b:	68 9c 24 80 00       	push   $0x80249c
  800d50:	e8 ba 0f 00 00       	call   801d0f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	be 00 00 00 00       	mov    $0x0,%esi
  800d68:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d79:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 cb                	mov    %ecx,%ebx
  800d98:	89 cf                	mov    %ecx,%edi
  800d9a:	89 ce                	mov    %ecx,%esi
  800d9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 17                	jle    800db9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	50                   	push   %eax
  800da6:	6a 0d                	push   $0xd
  800da8:	68 7f 24 80 00       	push   $0x80247f
  800dad:	6a 23                	push   $0x23
  800daf:	68 9c 24 80 00       	push   $0x80249c
  800db4:	e8 56 0f 00 00       	call   801d0f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800dcd:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800dcf:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800dd2:	83 3a 01             	cmpl   $0x1,(%edx)
  800dd5:	7e 09                	jle    800de0 <argstart+0x1f>
  800dd7:	ba 51 21 80 00       	mov    $0x802151,%edx
  800ddc:	85 c9                	test   %ecx,%ecx
  800dde:	75 05                	jne    800de5 <argstart+0x24>
  800de0:	ba 00 00 00 00       	mov    $0x0,%edx
  800de5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800de8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <argnext>:

int
argnext(struct Argstate *args)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	53                   	push   %ebx
  800df5:	83 ec 04             	sub    $0x4,%esp
  800df8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dfb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e02:	8b 43 08             	mov    0x8(%ebx),%eax
  800e05:	85 c0                	test   %eax,%eax
  800e07:	74 6f                	je     800e78 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e09:	80 38 00             	cmpb   $0x0,(%eax)
  800e0c:	75 4e                	jne    800e5c <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e0e:	8b 0b                	mov    (%ebx),%ecx
  800e10:	83 39 01             	cmpl   $0x1,(%ecx)
  800e13:	74 55                	je     800e6a <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e15:	8b 53 04             	mov    0x4(%ebx),%edx
  800e18:	8b 42 04             	mov    0x4(%edx),%eax
  800e1b:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e1e:	75 4a                	jne    800e6a <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e20:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e24:	74 44                	je     800e6a <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e26:	83 c0 01             	add    $0x1,%eax
  800e29:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	8b 01                	mov    (%ecx),%eax
  800e31:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e38:	50                   	push   %eax
  800e39:	8d 42 08             	lea    0x8(%edx),%eax
  800e3c:	50                   	push   %eax
  800e3d:	83 c2 04             	add    $0x4,%edx
  800e40:	52                   	push   %edx
  800e41:	e8 19 fb ff ff       	call   80095f <memmove>
		(*args->argc)--;
  800e46:	8b 03                	mov    (%ebx),%eax
  800e48:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e4b:	8b 43 08             	mov    0x8(%ebx),%eax
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e54:	75 06                	jne    800e5c <argnext+0x6b>
  800e56:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e5a:	74 0e                	je     800e6a <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e5c:	8b 53 08             	mov    0x8(%ebx),%edx
  800e5f:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e62:	83 c2 01             	add    $0x1,%edx
  800e65:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e68:	eb 13                	jmp    800e7d <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e6a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e76:	eb 05                	jmp    800e7d <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	53                   	push   %ebx
  800e86:	83 ec 04             	sub    $0x4,%esp
  800e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e8c:	8b 43 08             	mov    0x8(%ebx),%eax
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	74 58                	je     800eeb <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e93:	80 38 00             	cmpb   $0x0,(%eax)
  800e96:	74 0c                	je     800ea4 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e98:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e9b:	c7 43 08 51 21 80 00 	movl   $0x802151,0x8(%ebx)
  800ea2:	eb 42                	jmp    800ee6 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800ea4:	8b 13                	mov    (%ebx),%edx
  800ea6:	83 3a 01             	cmpl   $0x1,(%edx)
  800ea9:	7e 2d                	jle    800ed8 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800eab:	8b 43 04             	mov    0x4(%ebx),%eax
  800eae:	8b 48 04             	mov    0x4(%eax),%ecx
  800eb1:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800eb4:	83 ec 04             	sub    $0x4,%esp
  800eb7:	8b 12                	mov    (%edx),%edx
  800eb9:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800ec0:	52                   	push   %edx
  800ec1:	8d 50 08             	lea    0x8(%eax),%edx
  800ec4:	52                   	push   %edx
  800ec5:	83 c0 04             	add    $0x4,%eax
  800ec8:	50                   	push   %eax
  800ec9:	e8 91 fa ff ff       	call   80095f <memmove>
		(*args->argc)--;
  800ece:	8b 03                	mov    (%ebx),%eax
  800ed0:	83 28 01             	subl   $0x1,(%eax)
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	eb 0e                	jmp    800ee6 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800ed8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800edf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ee6:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ee9:	eb 05                	jmp    800ef0 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ef0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 08             	sub    $0x8,%esp
  800efb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800efe:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f01:	89 d0                	mov    %edx,%eax
  800f03:	85 d2                	test   %edx,%edx
  800f05:	75 0c                	jne    800f13 <argvalue+0x1e>
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	51                   	push   %ecx
  800f0b:	e8 72 ff ff ff       	call   800e82 <argnextvalue>
  800f10:	83 c4 10             	add    $0x10,%esp
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f18:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1b:	05 00 00 00 30       	add    $0x30000000,%eax
  800f20:	c1 e8 0c             	shr    $0xc,%eax
}
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	05 00 00 00 30       	add    $0x30000000,%eax
  800f30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f35:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f42:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f47:	89 c2                	mov    %eax,%edx
  800f49:	c1 ea 16             	shr    $0x16,%edx
  800f4c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f53:	f6 c2 01             	test   $0x1,%dl
  800f56:	74 11                	je     800f69 <fd_alloc+0x2d>
  800f58:	89 c2                	mov    %eax,%edx
  800f5a:	c1 ea 0c             	shr    $0xc,%edx
  800f5d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f64:	f6 c2 01             	test   $0x1,%dl
  800f67:	75 09                	jne    800f72 <fd_alloc+0x36>
			*fd_store = fd;
  800f69:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f70:	eb 17                	jmp    800f89 <fd_alloc+0x4d>
  800f72:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f77:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f7c:	75 c9                	jne    800f47 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f7e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f84:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f91:	83 f8 1f             	cmp    $0x1f,%eax
  800f94:	77 36                	ja     800fcc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f96:	c1 e0 0c             	shl    $0xc,%eax
  800f99:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f9e:	89 c2                	mov    %eax,%edx
  800fa0:	c1 ea 16             	shr    $0x16,%edx
  800fa3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800faa:	f6 c2 01             	test   $0x1,%dl
  800fad:	74 24                	je     800fd3 <fd_lookup+0x48>
  800faf:	89 c2                	mov    %eax,%edx
  800fb1:	c1 ea 0c             	shr    $0xc,%edx
  800fb4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbb:	f6 c2 01             	test   $0x1,%dl
  800fbe:	74 1a                	je     800fda <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc3:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	eb 13                	jmp    800fdf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd1:	eb 0c                	jmp    800fdf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd8:	eb 05                	jmp    800fdf <fd_lookup+0x54>
  800fda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fea:	ba 28 25 80 00       	mov    $0x802528,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fef:	eb 13                	jmp    801004 <dev_lookup+0x23>
  800ff1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ff4:	39 08                	cmp    %ecx,(%eax)
  800ff6:	75 0c                	jne    801004 <dev_lookup+0x23>
			*dev = devtab[i];
  800ff8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  801002:	eb 2e                	jmp    801032 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801004:	8b 02                	mov    (%edx),%eax
  801006:	85 c0                	test   %eax,%eax
  801008:	75 e7                	jne    800ff1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80100a:	a1 04 40 80 00       	mov    0x804004,%eax
  80100f:	8b 40 48             	mov    0x48(%eax),%eax
  801012:	83 ec 04             	sub    $0x4,%esp
  801015:	51                   	push   %ecx
  801016:	50                   	push   %eax
  801017:	68 ac 24 80 00       	push   $0x8024ac
  80101c:	e8 27 f2 ff ff       	call   800248 <cprintf>
	*dev = 0;
  801021:	8b 45 0c             	mov    0xc(%ebp),%eax
  801024:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 10             	sub    $0x10,%esp
  80103c:	8b 75 08             	mov    0x8(%ebp),%esi
  80103f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801042:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801045:	50                   	push   %eax
  801046:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80104c:	c1 e8 0c             	shr    $0xc,%eax
  80104f:	50                   	push   %eax
  801050:	e8 36 ff ff ff       	call   800f8b <fd_lookup>
  801055:	83 c4 08             	add    $0x8,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 05                	js     801061 <fd_close+0x2d>
	    || fd != fd2)
  80105c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80105f:	74 0c                	je     80106d <fd_close+0x39>
		return (must_exist ? r : 0);
  801061:	84 db                	test   %bl,%bl
  801063:	ba 00 00 00 00       	mov    $0x0,%edx
  801068:	0f 44 c2             	cmove  %edx,%eax
  80106b:	eb 41                	jmp    8010ae <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801073:	50                   	push   %eax
  801074:	ff 36                	pushl  (%esi)
  801076:	e8 66 ff ff ff       	call   800fe1 <dev_lookup>
  80107b:	89 c3                	mov    %eax,%ebx
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	78 1a                	js     80109e <fd_close+0x6a>
		if (dev->dev_close)
  801084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801087:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80108a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80108f:	85 c0                	test   %eax,%eax
  801091:	74 0b                	je     80109e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	56                   	push   %esi
  801097:	ff d0                	call   *%eax
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	56                   	push   %esi
  8010a2:	6a 00                	push   $0x0
  8010a4:	e8 ac fb ff ff       	call   800c55 <sys_page_unmap>
	return r;
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	89 d8                	mov    %ebx,%eax
}
  8010ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	ff 75 08             	pushl  0x8(%ebp)
  8010c2:	e8 c4 fe ff ff       	call   800f8b <fd_lookup>
  8010c7:	83 c4 08             	add    $0x8,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	78 10                	js     8010de <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010ce:	83 ec 08             	sub    $0x8,%esp
  8010d1:	6a 01                	push   $0x1
  8010d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d6:	e8 59 ff ff ff       	call   801034 <fd_close>
  8010db:	83 c4 10             	add    $0x10,%esp
}
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <close_all>:

void
close_all(void)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	53                   	push   %ebx
  8010f0:	e8 c0 ff ff ff       	call   8010b5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f5:	83 c3 01             	add    $0x1,%ebx
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	83 fb 20             	cmp    $0x20,%ebx
  8010fe:	75 ec                	jne    8010ec <close_all+0xc>
		close(i);
}
  801100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 2c             	sub    $0x2c,%esp
  80110e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801111:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	ff 75 08             	pushl  0x8(%ebp)
  801118:	e8 6e fe ff ff       	call   800f8b <fd_lookup>
  80111d:	83 c4 08             	add    $0x8,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	0f 88 c1 00 00 00    	js     8011e9 <dup+0xe4>
		return r;
	close(newfdnum);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	56                   	push   %esi
  80112c:	e8 84 ff ff ff       	call   8010b5 <close>

	newfd = INDEX2FD(newfdnum);
  801131:	89 f3                	mov    %esi,%ebx
  801133:	c1 e3 0c             	shl    $0xc,%ebx
  801136:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80113c:	83 c4 04             	add    $0x4,%esp
  80113f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801142:	e8 de fd ff ff       	call   800f25 <fd2data>
  801147:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801149:	89 1c 24             	mov    %ebx,(%esp)
  80114c:	e8 d4 fd ff ff       	call   800f25 <fd2data>
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801157:	89 f8                	mov    %edi,%eax
  801159:	c1 e8 16             	shr    $0x16,%eax
  80115c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801163:	a8 01                	test   $0x1,%al
  801165:	74 37                	je     80119e <dup+0x99>
  801167:	89 f8                	mov    %edi,%eax
  801169:	c1 e8 0c             	shr    $0xc,%eax
  80116c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801173:	f6 c2 01             	test   $0x1,%dl
  801176:	74 26                	je     80119e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801178:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	25 07 0e 00 00       	and    $0xe07,%eax
  801187:	50                   	push   %eax
  801188:	ff 75 d4             	pushl  -0x2c(%ebp)
  80118b:	6a 00                	push   $0x0
  80118d:	57                   	push   %edi
  80118e:	6a 00                	push   $0x0
  801190:	e8 7e fa ff ff       	call   800c13 <sys_page_map>
  801195:	89 c7                	mov    %eax,%edi
  801197:	83 c4 20             	add    $0x20,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 2e                	js     8011cc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011a1:	89 d0                	mov    %edx,%eax
  8011a3:	c1 e8 0c             	shr    $0xc,%eax
  8011a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ad:	83 ec 0c             	sub    $0xc,%esp
  8011b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b5:	50                   	push   %eax
  8011b6:	53                   	push   %ebx
  8011b7:	6a 00                	push   $0x0
  8011b9:	52                   	push   %edx
  8011ba:	6a 00                	push   $0x0
  8011bc:	e8 52 fa ff ff       	call   800c13 <sys_page_map>
  8011c1:	89 c7                	mov    %eax,%edi
  8011c3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011c6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011c8:	85 ff                	test   %edi,%edi
  8011ca:	79 1d                	jns    8011e9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	53                   	push   %ebx
  8011d0:	6a 00                	push   $0x0
  8011d2:	e8 7e fa ff ff       	call   800c55 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d7:	83 c4 08             	add    $0x8,%esp
  8011da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 71 fa ff ff       	call   800c55 <sys_page_unmap>
	return r;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	89 f8                	mov    %edi,%eax
}
  8011e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 14             	sub    $0x14,%esp
  8011f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	53                   	push   %ebx
  801200:	e8 86 fd ff ff       	call   800f8b <fd_lookup>
  801205:	83 c4 08             	add    $0x8,%esp
  801208:	89 c2                	mov    %eax,%edx
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 6d                	js     80127b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801218:	ff 30                	pushl  (%eax)
  80121a:	e8 c2 fd ff ff       	call   800fe1 <dev_lookup>
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 4c                	js     801272 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801226:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801229:	8b 42 08             	mov    0x8(%edx),%eax
  80122c:	83 e0 03             	and    $0x3,%eax
  80122f:	83 f8 01             	cmp    $0x1,%eax
  801232:	75 21                	jne    801255 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801234:	a1 04 40 80 00       	mov    0x804004,%eax
  801239:	8b 40 48             	mov    0x48(%eax),%eax
  80123c:	83 ec 04             	sub    $0x4,%esp
  80123f:	53                   	push   %ebx
  801240:	50                   	push   %eax
  801241:	68 ed 24 80 00       	push   $0x8024ed
  801246:	e8 fd ef ff ff       	call   800248 <cprintf>
		return -E_INVAL;
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801253:	eb 26                	jmp    80127b <read+0x8a>
	}
	if (!dev->dev_read)
  801255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801258:	8b 40 08             	mov    0x8(%eax),%eax
  80125b:	85 c0                	test   %eax,%eax
  80125d:	74 17                	je     801276 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	ff 75 10             	pushl  0x10(%ebp)
  801265:	ff 75 0c             	pushl  0xc(%ebp)
  801268:	52                   	push   %edx
  801269:	ff d0                	call   *%eax
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	eb 09                	jmp    80127b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	89 c2                	mov    %eax,%edx
  801274:	eb 05                	jmp    80127b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801276:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80127b:	89 d0                	mov    %edx,%eax
  80127d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	57                   	push   %edi
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
  801288:	83 ec 0c             	sub    $0xc,%esp
  80128b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80128e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801291:	bb 00 00 00 00       	mov    $0x0,%ebx
  801296:	eb 21                	jmp    8012b9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801298:	83 ec 04             	sub    $0x4,%esp
  80129b:	89 f0                	mov    %esi,%eax
  80129d:	29 d8                	sub    %ebx,%eax
  80129f:	50                   	push   %eax
  8012a0:	89 d8                	mov    %ebx,%eax
  8012a2:	03 45 0c             	add    0xc(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	57                   	push   %edi
  8012a7:	e8 45 ff ff ff       	call   8011f1 <read>
		if (m < 0)
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 10                	js     8012c3 <readn+0x41>
			return m;
		if (m == 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	74 0a                	je     8012c1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b7:	01 c3                	add    %eax,%ebx
  8012b9:	39 f3                	cmp    %esi,%ebx
  8012bb:	72 db                	jb     801298 <readn+0x16>
  8012bd:	89 d8                	mov    %ebx,%eax
  8012bf:	eb 02                	jmp    8012c3 <readn+0x41>
  8012c1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5f                   	pop    %edi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 14             	sub    $0x14,%esp
  8012d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	53                   	push   %ebx
  8012da:	e8 ac fc ff ff       	call   800f8b <fd_lookup>
  8012df:	83 c4 08             	add    $0x8,%esp
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 68                	js     801350 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f2:	ff 30                	pushl  (%eax)
  8012f4:	e8 e8 fc ff ff       	call   800fe1 <dev_lookup>
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 47                	js     801347 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801307:	75 21                	jne    80132a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801309:	a1 04 40 80 00       	mov    0x804004,%eax
  80130e:	8b 40 48             	mov    0x48(%eax),%eax
  801311:	83 ec 04             	sub    $0x4,%esp
  801314:	53                   	push   %ebx
  801315:	50                   	push   %eax
  801316:	68 09 25 80 00       	push   $0x802509
  80131b:	e8 28 ef ff ff       	call   800248 <cprintf>
		return -E_INVAL;
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801328:	eb 26                	jmp    801350 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132d:	8b 52 0c             	mov    0xc(%edx),%edx
  801330:	85 d2                	test   %edx,%edx
  801332:	74 17                	je     80134b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801334:	83 ec 04             	sub    $0x4,%esp
  801337:	ff 75 10             	pushl  0x10(%ebp)
  80133a:	ff 75 0c             	pushl  0xc(%ebp)
  80133d:	50                   	push   %eax
  80133e:	ff d2                	call   *%edx
  801340:	89 c2                	mov    %eax,%edx
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	eb 09                	jmp    801350 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801347:	89 c2                	mov    %eax,%edx
  801349:	eb 05                	jmp    801350 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80134b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801350:	89 d0                	mov    %edx,%eax
  801352:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <seek>:

int
seek(int fdnum, off_t offset)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	ff 75 08             	pushl  0x8(%ebp)
  801364:	e8 22 fc ff ff       	call   800f8b <fd_lookup>
  801369:	83 c4 08             	add    $0x8,%esp
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 0e                	js     80137e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801370:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801373:	8b 55 0c             	mov    0xc(%ebp),%edx
  801376:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 14             	sub    $0x14,%esp
  801387:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	53                   	push   %ebx
  80138f:	e8 f7 fb ff ff       	call   800f8b <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	89 c2                	mov    %eax,%edx
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 65                	js     801402 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	ff 30                	pushl  (%eax)
  8013a9:	e8 33 fc ff ff       	call   800fe1 <dev_lookup>
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 44                	js     8013f9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013bc:	75 21                	jne    8013df <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013be:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c3:	8b 40 48             	mov    0x48(%eax),%eax
  8013c6:	83 ec 04             	sub    $0x4,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	50                   	push   %eax
  8013cb:	68 cc 24 80 00       	push   $0x8024cc
  8013d0:	e8 73 ee ff ff       	call   800248 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013dd:	eb 23                	jmp    801402 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e2:	8b 52 18             	mov    0x18(%edx),%edx
  8013e5:	85 d2                	test   %edx,%edx
  8013e7:	74 14                	je     8013fd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	ff 75 0c             	pushl  0xc(%ebp)
  8013ef:	50                   	push   %eax
  8013f0:	ff d2                	call   *%edx
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	eb 09                	jmp    801402 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f9:	89 c2                	mov    %eax,%edx
  8013fb:	eb 05                	jmp    801402 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801402:	89 d0                	mov    %edx,%eax
  801404:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	53                   	push   %ebx
  80140d:	83 ec 14             	sub    $0x14,%esp
  801410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801413:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 6c fb ff ff       	call   800f8b <fd_lookup>
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	89 c2                	mov    %eax,%edx
  801424:	85 c0                	test   %eax,%eax
  801426:	78 58                	js     801480 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801432:	ff 30                	pushl  (%eax)
  801434:	e8 a8 fb ff ff       	call   800fe1 <dev_lookup>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 37                	js     801477 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801443:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801447:	74 32                	je     80147b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801449:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80144c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801453:	00 00 00 
	stat->st_isdir = 0;
  801456:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80145d:	00 00 00 
	stat->st_dev = dev;
  801460:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	53                   	push   %ebx
  80146a:	ff 75 f0             	pushl  -0x10(%ebp)
  80146d:	ff 50 14             	call   *0x14(%eax)
  801470:	89 c2                	mov    %eax,%edx
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	eb 09                	jmp    801480 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	89 c2                	mov    %eax,%edx
  801479:	eb 05                	jmp    801480 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80147b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801480:	89 d0                	mov    %edx,%eax
  801482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801485:	c9                   	leave  
  801486:	c3                   	ret    

00801487 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	56                   	push   %esi
  80148b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	6a 00                	push   $0x0
  801491:	ff 75 08             	pushl  0x8(%ebp)
  801494:	e8 e3 01 00 00       	call   80167c <open>
  801499:	89 c3                	mov    %eax,%ebx
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 1b                	js     8014bd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	ff 75 0c             	pushl  0xc(%ebp)
  8014a8:	50                   	push   %eax
  8014a9:	e8 5b ff ff ff       	call   801409 <fstat>
  8014ae:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b0:	89 1c 24             	mov    %ebx,(%esp)
  8014b3:	e8 fd fb ff ff       	call   8010b5 <close>
	return r;
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	89 f0                	mov    %esi,%eax
}
  8014bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	89 c6                	mov    %eax,%esi
  8014cb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014d4:	75 12                	jne    8014e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	6a 01                	push   $0x1
  8014db:	e8 49 09 00 00       	call   801e29 <ipc_find_env>
  8014e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8014e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014e8:	6a 07                	push   $0x7
  8014ea:	68 00 50 80 00       	push   $0x805000
  8014ef:	56                   	push   %esi
  8014f0:	ff 35 00 40 80 00    	pushl  0x804000
  8014f6:	e8 cc 08 00 00       	call   801dc7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014fb:	83 c4 0c             	add    $0xc,%esp
  8014fe:	6a 00                	push   $0x0
  801500:	53                   	push   %ebx
  801501:	6a 00                	push   $0x0
  801503:	e8 4d 08 00 00       	call   801d55 <ipc_recv>
}
  801508:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8b 40 0c             	mov    0xc(%eax),%eax
  80151b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801520:	8b 45 0c             	mov    0xc(%ebp),%eax
  801523:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	b8 02 00 00 00       	mov    $0x2,%eax
  801532:	e8 8d ff ff ff       	call   8014c4 <fsipc>
}
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80153f:	8b 45 08             	mov    0x8(%ebp),%eax
  801542:	8b 40 0c             	mov    0xc(%eax),%eax
  801545:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	b8 06 00 00 00       	mov    $0x6,%eax
  801554:	e8 6b ff ff ff       	call   8014c4 <fsipc>
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801565:	8b 45 08             	mov    0x8(%ebp),%eax
  801568:	8b 40 0c             	mov    0xc(%eax),%eax
  80156b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801570:	ba 00 00 00 00       	mov    $0x0,%edx
  801575:	b8 05 00 00 00       	mov    $0x5,%eax
  80157a:	e8 45 ff ff ff       	call   8014c4 <fsipc>
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 2c                	js     8015af <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	68 00 50 80 00       	push   $0x805000
  80158b:	53                   	push   %ebx
  80158c:	e8 3c f2 ff ff       	call   8007cd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801591:	a1 80 50 80 00       	mov    0x805080,%eax
  801596:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80159c:	a1 84 50 80 00       	mov    0x805084,%eax
  8015a1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 0c             	sub    $0xc,%esp
  8015ba:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8015c9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015ce:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015d3:	0f 47 c2             	cmova  %edx,%eax
  8015d6:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8015db:	50                   	push   %eax
  8015dc:	ff 75 0c             	pushl  0xc(%ebp)
  8015df:	68 08 50 80 00       	push   $0x805008
  8015e4:	e8 76 f3 ff ff       	call   80095f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8015e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8015f3:	e8 cc fe ff ff       	call   8014c4 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	56                   	push   %esi
  8015fe:	53                   	push   %ebx
  8015ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801602:	8b 45 08             	mov    0x8(%ebp),%eax
  801605:	8b 40 0c             	mov    0xc(%eax),%eax
  801608:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80160d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	b8 03 00 00 00       	mov    $0x3,%eax
  80161d:	e8 a2 fe ff ff       	call   8014c4 <fsipc>
  801622:	89 c3                	mov    %eax,%ebx
  801624:	85 c0                	test   %eax,%eax
  801626:	78 4b                	js     801673 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801628:	39 c6                	cmp    %eax,%esi
  80162a:	73 16                	jae    801642 <devfile_read+0x48>
  80162c:	68 38 25 80 00       	push   $0x802538
  801631:	68 3f 25 80 00       	push   $0x80253f
  801636:	6a 7c                	push   $0x7c
  801638:	68 54 25 80 00       	push   $0x802554
  80163d:	e8 cd 06 00 00       	call   801d0f <_panic>
	assert(r <= PGSIZE);
  801642:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801647:	7e 16                	jle    80165f <devfile_read+0x65>
  801649:	68 5f 25 80 00       	push   $0x80255f
  80164e:	68 3f 25 80 00       	push   $0x80253f
  801653:	6a 7d                	push   $0x7d
  801655:	68 54 25 80 00       	push   $0x802554
  80165a:	e8 b0 06 00 00       	call   801d0f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	50                   	push   %eax
  801663:	68 00 50 80 00       	push   $0x805000
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	e8 ef f2 ff ff       	call   80095f <memmove>
	return r;
  801670:	83 c4 10             	add    $0x10,%esp
}
  801673:	89 d8                	mov    %ebx,%eax
  801675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 20             	sub    $0x20,%esp
  801683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801686:	53                   	push   %ebx
  801687:	e8 08 f1 ff ff       	call   800794 <strlen>
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801694:	7f 67                	jg     8016fd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169c:	50                   	push   %eax
  80169d:	e8 9a f8 ff ff       	call   800f3c <fd_alloc>
  8016a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 57                	js     801702 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	53                   	push   %ebx
  8016af:	68 00 50 80 00       	push   $0x805000
  8016b4:	e8 14 f1 ff ff       	call   8007cd <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016bc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c9:	e8 f6 fd ff ff       	call   8014c4 <fsipc>
  8016ce:	89 c3                	mov    %eax,%ebx
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	79 14                	jns    8016eb <open+0x6f>
		fd_close(fd, 0);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	6a 00                	push   $0x0
  8016dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016df:	e8 50 f9 ff ff       	call   801034 <fd_close>
		return r;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	89 da                	mov    %ebx,%edx
  8016e9:	eb 17                	jmp    801702 <open+0x86>
	}

	return fd2num(fd);
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f1:	e8 1f f8 ff ff       	call   800f15 <fd2num>
  8016f6:	89 c2                	mov    %eax,%edx
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	eb 05                	jmp    801702 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016fd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801702:	89 d0                	mov    %edx,%eax
  801704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 08 00 00 00       	mov    $0x8,%eax
  801719:	e8 a6 fd ff ff       	call   8014c4 <fsipc>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801720:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801724:	7e 37                	jle    80175d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	53                   	push   %ebx
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80172f:	ff 70 04             	pushl  0x4(%eax)
  801732:	8d 40 10             	lea    0x10(%eax),%eax
  801735:	50                   	push   %eax
  801736:	ff 33                	pushl  (%ebx)
  801738:	e8 8e fb ff ff       	call   8012cb <write>
		if (result > 0)
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	7e 03                	jle    801747 <writebuf+0x27>
			b->result += result;
  801744:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801747:	3b 43 04             	cmp    0x4(%ebx),%eax
  80174a:	74 0d                	je     801759 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80174c:	85 c0                	test   %eax,%eax
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	0f 4f c2             	cmovg  %edx,%eax
  801756:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	f3 c3                	repz ret 

0080175f <putch>:

static void
putch(int ch, void *thunk)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801769:	8b 53 04             	mov    0x4(%ebx),%edx
  80176c:	8d 42 01             	lea    0x1(%edx),%eax
  80176f:	89 43 04             	mov    %eax,0x4(%ebx)
  801772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801775:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801779:	3d 00 01 00 00       	cmp    $0x100,%eax
  80177e:	75 0e                	jne    80178e <putch+0x2f>
		writebuf(b);
  801780:	89 d8                	mov    %ebx,%eax
  801782:	e8 99 ff ff ff       	call   801720 <writebuf>
		b->idx = 0;
  801787:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80178e:	83 c4 04             	add    $0x4,%esp
  801791:	5b                   	pop    %ebx
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017a6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017ad:	00 00 00 
	b.result = 0;
  8017b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017b7:	00 00 00 
	b.error = 1;
  8017ba:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017c1:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017c4:	ff 75 10             	pushl  0x10(%ebp)
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	68 5f 17 80 00       	push   $0x80175f
  8017d6:	e8 a4 eb ff ff       	call   80037f <vprintfmt>
	if (b.idx > 0)
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017e5:	7e 0b                	jle    8017f2 <vfprintf+0x5e>
		writebuf(&b);
  8017e7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017ed:	e8 2e ff ff ff       	call   801720 <writebuf>

	return (b.result ? b.result : b.error);
  8017f2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801809:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80180c:	50                   	push   %eax
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	ff 75 08             	pushl  0x8(%ebp)
  801813:	e8 7c ff ff ff       	call   801794 <vfprintf>
	va_end(ap);

	return cnt;
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <printf>:

int
printf(const char *fmt, ...)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801820:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801823:	50                   	push   %eax
  801824:	ff 75 08             	pushl  0x8(%ebp)
  801827:	6a 01                	push   $0x1
  801829:	e8 66 ff ff ff       	call   801794 <vfprintf>
	va_end(ap);

	return cnt;
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801838:	83 ec 0c             	sub    $0xc,%esp
  80183b:	ff 75 08             	pushl  0x8(%ebp)
  80183e:	e8 e2 f6 ff ff       	call   800f25 <fd2data>
  801843:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801845:	83 c4 08             	add    $0x8,%esp
  801848:	68 6b 25 80 00       	push   $0x80256b
  80184d:	53                   	push   %ebx
  80184e:	e8 7a ef ff ff       	call   8007cd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801853:	8b 46 04             	mov    0x4(%esi),%eax
  801856:	2b 06                	sub    (%esi),%eax
  801858:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801865:	00 00 00 
	stat->st_dev = &devpipe;
  801868:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186f:	30 80 00 
	return 0;
}
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801888:	53                   	push   %ebx
  801889:	6a 00                	push   $0x0
  80188b:	e8 c5 f3 ff ff       	call   800c55 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801890:	89 1c 24             	mov    %ebx,(%esp)
  801893:	e8 8d f6 ff ff       	call   800f25 <fd2data>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	50                   	push   %eax
  80189c:	6a 00                	push   $0x0
  80189e:	e8 b2 f3 ff ff       	call   800c55 <sys_page_unmap>
}
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 1c             	sub    $0x1c,%esp
  8018b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8018bb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c4:	e8 99 05 00 00       	call   801e62 <pageref>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	89 3c 24             	mov    %edi,(%esp)
  8018ce:	e8 8f 05 00 00       	call   801e62 <pageref>
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	39 c3                	cmp    %eax,%ebx
  8018d8:	0f 94 c1             	sete   %cl
  8018db:	0f b6 c9             	movzbl %cl,%ecx
  8018de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018e1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018ea:	39 ce                	cmp    %ecx,%esi
  8018ec:	74 1b                	je     801909 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018ee:	39 c3                	cmp    %eax,%ebx
  8018f0:	75 c4                	jne    8018b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f2:	8b 42 58             	mov    0x58(%edx),%eax
  8018f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f8:	50                   	push   %eax
  8018f9:	56                   	push   %esi
  8018fa:	68 72 25 80 00       	push   $0x802572
  8018ff:	e8 44 e9 ff ff       	call   800248 <cprintf>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb ad                	jmp    8018b6 <_pipeisclosed+0xe>
	}
}
  801909:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	57                   	push   %edi
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	83 ec 28             	sub    $0x28,%esp
  80191d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801920:	56                   	push   %esi
  801921:	e8 ff f5 ff ff       	call   800f25 <fd2data>
  801926:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	bf 00 00 00 00       	mov    $0x0,%edi
  801930:	eb 4b                	jmp    80197d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801932:	89 da                	mov    %ebx,%edx
  801934:	89 f0                	mov    %esi,%eax
  801936:	e8 6d ff ff ff       	call   8018a8 <_pipeisclosed>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	75 48                	jne    801987 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193f:	e8 6d f2 ff ff       	call   800bb1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801944:	8b 43 04             	mov    0x4(%ebx),%eax
  801947:	8b 0b                	mov    (%ebx),%ecx
  801949:	8d 51 20             	lea    0x20(%ecx),%edx
  80194c:	39 d0                	cmp    %edx,%eax
  80194e:	73 e2                	jae    801932 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801953:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801957:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	c1 fa 1f             	sar    $0x1f,%edx
  80195f:	89 d1                	mov    %edx,%ecx
  801961:	c1 e9 1b             	shr    $0x1b,%ecx
  801964:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801967:	83 e2 1f             	and    $0x1f,%edx
  80196a:	29 ca                	sub    %ecx,%edx
  80196c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801970:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801974:	83 c0 01             	add    $0x1,%eax
  801977:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197a:	83 c7 01             	add    $0x1,%edi
  80197d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801980:	75 c2                	jne    801944 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801982:	8b 45 10             	mov    0x10(%ebp),%eax
  801985:	eb 05                	jmp    80198c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80198c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 18             	sub    $0x18,%esp
  80199d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019a0:	57                   	push   %edi
  8019a1:	e8 7f f5 ff ff       	call   800f25 <fd2data>
  8019a6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b0:	eb 3d                	jmp    8019ef <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019b2:	85 db                	test   %ebx,%ebx
  8019b4:	74 04                	je     8019ba <devpipe_read+0x26>
				return i;
  8019b6:	89 d8                	mov    %ebx,%eax
  8019b8:	eb 44                	jmp    8019fe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019ba:	89 f2                	mov    %esi,%edx
  8019bc:	89 f8                	mov    %edi,%eax
  8019be:	e8 e5 fe ff ff       	call   8018a8 <_pipeisclosed>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	75 32                	jne    8019f9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c7:	e8 e5 f1 ff ff       	call   800bb1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019cc:	8b 06                	mov    (%esi),%eax
  8019ce:	3b 46 04             	cmp    0x4(%esi),%eax
  8019d1:	74 df                	je     8019b2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019d3:	99                   	cltd   
  8019d4:	c1 ea 1b             	shr    $0x1b,%edx
  8019d7:	01 d0                	add    %edx,%eax
  8019d9:	83 e0 1f             	and    $0x1f,%eax
  8019dc:	29 d0                	sub    %edx,%eax
  8019de:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ec:	83 c3 01             	add    $0x1,%ebx
  8019ef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f2:	75 d8                	jne    8019cc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f7:	eb 05                	jmp    8019fe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5f                   	pop    %edi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	e8 25 f5 ff ff       	call   800f3c <fd_alloc>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 2c 01 00 00    	js     801b50 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	68 07 04 00 00       	push   $0x407
  801a2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2f:	6a 00                	push   $0x0
  801a31:	e8 9a f1 ff ff       	call   800bd0 <sys_page_alloc>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	0f 88 0d 01 00 00    	js     801b50 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 ed f4 ff ff       	call   800f3c <fd_alloc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 e2 00 00 00    	js     801b3e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5c:	83 ec 04             	sub    $0x4,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	ff 75 f0             	pushl  -0x10(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 62 f1 ff ff       	call   800bd0 <sys_page_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 88 c3 00 00 00    	js     801b3e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a81:	e8 9f f4 ff ff       	call   800f25 <fd2data>
  801a86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a88:	83 c4 0c             	add    $0xc,%esp
  801a8b:	68 07 04 00 00       	push   $0x407
  801a90:	50                   	push   %eax
  801a91:	6a 00                	push   $0x0
  801a93:	e8 38 f1 ff ff       	call   800bd0 <sys_page_alloc>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	0f 88 89 00 00 00    	js     801b2e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	ff 75 f0             	pushl  -0x10(%ebp)
  801aab:	e8 75 f4 ff ff       	call   800f25 <fd2data>
  801ab0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab7:	50                   	push   %eax
  801ab8:	6a 00                	push   $0x0
  801aba:	56                   	push   %esi
  801abb:	6a 00                	push   $0x0
  801abd:	e8 51 f1 ff ff       	call   800c13 <sys_page_map>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	83 c4 20             	add    $0x20,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 55                	js     801b20 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801acb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	ff 75 f4             	pushl  -0xc(%ebp)
  801afb:	e8 15 f4 ff ff       	call   800f15 <fd2num>
  801b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b03:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b05:	83 c4 04             	add    $0x4,%esp
  801b08:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0b:	e8 05 f4 ff ff       	call   800f15 <fd2num>
  801b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b13:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	eb 30                	jmp    801b50 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b20:	83 ec 08             	sub    $0x8,%esp
  801b23:	56                   	push   %esi
  801b24:	6a 00                	push   $0x0
  801b26:	e8 2a f1 ff ff       	call   800c55 <sys_page_unmap>
  801b2b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	ff 75 f0             	pushl  -0x10(%ebp)
  801b34:	6a 00                	push   $0x0
  801b36:	e8 1a f1 ff ff       	call   800c55 <sys_page_unmap>
  801b3b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b3e:	83 ec 08             	sub    $0x8,%esp
  801b41:	ff 75 f4             	pushl  -0xc(%ebp)
  801b44:	6a 00                	push   $0x0
  801b46:	e8 0a f1 ff ff       	call   800c55 <sys_page_unmap>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b50:	89 d0                	mov    %edx,%eax
  801b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b62:	50                   	push   %eax
  801b63:	ff 75 08             	pushl  0x8(%ebp)
  801b66:	e8 20 f4 ff ff       	call   800f8b <fd_lookup>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 18                	js     801b8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	e8 a8 f3 ff ff       	call   800f25 <fd2data>
	return _pipeisclosed(fd, p);
  801b7d:	89 c2                	mov    %eax,%edx
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	e8 21 fd ff ff       	call   8018a8 <_pipeisclosed>
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b9c:	68 8a 25 80 00       	push   $0x80258a
  801ba1:	ff 75 0c             	pushl  0xc(%ebp)
  801ba4:	e8 24 ec ff ff       	call   8007cd <strcpy>
	return 0;
}
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bbc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc7:	eb 2d                	jmp    801bf6 <devcons_write+0x46>
		m = n - tot;
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bcc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bce:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bd1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	53                   	push   %ebx
  801bdd:	03 45 0c             	add    0xc(%ebp),%eax
  801be0:	50                   	push   %eax
  801be1:	57                   	push   %edi
  801be2:	e8 78 ed ff ff       	call   80095f <memmove>
		sys_cputs(buf, m);
  801be7:	83 c4 08             	add    $0x8,%esp
  801bea:	53                   	push   %ebx
  801beb:	57                   	push   %edi
  801bec:	e8 23 ef ff ff       	call   800b14 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf1:	01 de                	add    %ebx,%esi
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	89 f0                	mov    %esi,%eax
  801bf8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bfb:	72 cc                	jb     801bc9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c14:	74 2a                	je     801c40 <devcons_read+0x3b>
  801c16:	eb 05                	jmp    801c1d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c18:	e8 94 ef ff ff       	call   800bb1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c1d:	e8 10 ef ff ff       	call   800b32 <sys_cgetc>
  801c22:	85 c0                	test   %eax,%eax
  801c24:	74 f2                	je     801c18 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 16                	js     801c40 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c2a:	83 f8 04             	cmp    $0x4,%eax
  801c2d:	74 0c                	je     801c3b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c32:	88 02                	mov    %al,(%edx)
	return 1;
  801c34:	b8 01 00 00 00       	mov    $0x1,%eax
  801c39:	eb 05                	jmp    801c40 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c4e:	6a 01                	push   $0x1
  801c50:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c53:	50                   	push   %eax
  801c54:	e8 bb ee ff ff       	call   800b14 <sys_cputs>
}
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <getchar>:

int
getchar(void)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c64:	6a 01                	push   $0x1
  801c66:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c69:	50                   	push   %eax
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 80 f5 ff ff       	call   8011f1 <read>
	if (r < 0)
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 0f                	js     801c87 <getchar+0x29>
		return r;
	if (r < 1)
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	7e 06                	jle    801c82 <getchar+0x24>
		return -E_EOF;
	return c;
  801c7c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c80:	eb 05                	jmp    801c87 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c82:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c92:	50                   	push   %eax
  801c93:	ff 75 08             	pushl  0x8(%ebp)
  801c96:	e8 f0 f2 ff ff       	call   800f8b <fd_lookup>
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 11                	js     801cb3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cab:	39 10                	cmp    %edx,(%eax)
  801cad:	0f 94 c0             	sete   %al
  801cb0:	0f b6 c0             	movzbl %al,%eax
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <opencons>:

int
opencons(void)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	50                   	push   %eax
  801cbf:	e8 78 f2 ff ff       	call   800f3c <fd_alloc>
  801cc4:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 3e                	js     801d0b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 f1 ee ff ff       	call   800bd0 <sys_page_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 23                	js     801d0b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	50                   	push   %eax
  801d01:	e8 0f f2 ff ff       	call   800f15 <fd2num>
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	83 c4 10             	add    $0x10,%esp
}
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d14:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d17:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d1d:	e8 70 ee ff ff       	call   800b92 <sys_getenvid>
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	ff 75 08             	pushl  0x8(%ebp)
  801d2b:	56                   	push   %esi
  801d2c:	50                   	push   %eax
  801d2d:	68 98 25 80 00       	push   $0x802598
  801d32:	e8 11 e5 ff ff       	call   800248 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d37:	83 c4 18             	add    $0x18,%esp
  801d3a:	53                   	push   %ebx
  801d3b:	ff 75 10             	pushl  0x10(%ebp)
  801d3e:	e8 b4 e4 ff ff       	call   8001f7 <vcprintf>
	cprintf("\n");
  801d43:	c7 04 24 50 21 80 00 	movl   $0x802150,(%esp)
  801d4a:	e8 f9 e4 ff ff       	call   800248 <cprintf>
  801d4f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d52:	cc                   	int3   
  801d53:	eb fd                	jmp    801d52 <_panic+0x43>

00801d55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	56                   	push   %esi
  801d59:	53                   	push   %ebx
  801d5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801d63:	85 c0                	test   %eax,%eax
  801d65:	75 12                	jne    801d79 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801d67:	83 ec 0c             	sub    $0xc,%esp
  801d6a:	68 00 00 c0 ee       	push   $0xeec00000
  801d6f:	e8 0c f0 ff ff       	call   800d80 <sys_ipc_recv>
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	eb 0c                	jmp    801d85 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	50                   	push   %eax
  801d7d:	e8 fe ef ff ff       	call   800d80 <sys_ipc_recv>
  801d82:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801d85:	85 f6                	test   %esi,%esi
  801d87:	0f 95 c1             	setne  %cl
  801d8a:	85 db                	test   %ebx,%ebx
  801d8c:	0f 95 c2             	setne  %dl
  801d8f:	84 d1                	test   %dl,%cl
  801d91:	74 09                	je     801d9c <ipc_recv+0x47>
  801d93:	89 c2                	mov    %eax,%edx
  801d95:	c1 ea 1f             	shr    $0x1f,%edx
  801d98:	84 d2                	test   %dl,%dl
  801d9a:	75 24                	jne    801dc0 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801d9c:	85 f6                	test   %esi,%esi
  801d9e:	74 0a                	je     801daa <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801da0:	a1 04 40 80 00       	mov    0x804004,%eax
  801da5:	8b 40 74             	mov    0x74(%eax),%eax
  801da8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801daa:	85 db                	test   %ebx,%ebx
  801dac:	74 0a                	je     801db8 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801dae:	a1 04 40 80 00       	mov    0x804004,%eax
  801db3:	8b 40 78             	mov    0x78(%eax),%eax
  801db6:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801db8:	a1 04 40 80 00       	mov    0x804004,%eax
  801dbd:	8b 40 70             	mov    0x70(%eax),%eax
}
  801dc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	57                   	push   %edi
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 0c             	sub    $0xc,%esp
  801dd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801dd9:	85 db                	test   %ebx,%ebx
  801ddb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801de0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801de3:	ff 75 14             	pushl  0x14(%ebp)
  801de6:	53                   	push   %ebx
  801de7:	56                   	push   %esi
  801de8:	57                   	push   %edi
  801de9:	e8 6f ef ff ff       	call   800d5d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801dee:	89 c2                	mov    %eax,%edx
  801df0:	c1 ea 1f             	shr    $0x1f,%edx
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	84 d2                	test   %dl,%dl
  801df8:	74 17                	je     801e11 <ipc_send+0x4a>
  801dfa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dfd:	74 12                	je     801e11 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801dff:	50                   	push   %eax
  801e00:	68 bc 25 80 00       	push   $0x8025bc
  801e05:	6a 47                	push   $0x47
  801e07:	68 ca 25 80 00       	push   $0x8025ca
  801e0c:	e8 fe fe ff ff       	call   801d0f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e11:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e14:	75 07                	jne    801e1d <ipc_send+0x56>
			sys_yield();
  801e16:	e8 96 ed ff ff       	call   800bb1 <sys_yield>
  801e1b:	eb c6                	jmp    801de3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	75 c2                	jne    801de3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e34:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e3d:	8b 52 50             	mov    0x50(%edx),%edx
  801e40:	39 ca                	cmp    %ecx,%edx
  801e42:	75 0d                	jne    801e51 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e4c:	8b 40 48             	mov    0x48(%eax),%eax
  801e4f:	eb 0f                	jmp    801e60 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e51:	83 c0 01             	add    $0x1,%eax
  801e54:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e59:	75 d9                	jne    801e34 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    

00801e62 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e68:	89 d0                	mov    %edx,%eax
  801e6a:	c1 e8 16             	shr    $0x16,%eax
  801e6d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e74:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e79:	f6 c1 01             	test   $0x1,%cl
  801e7c:	74 1d                	je     801e9b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e7e:	c1 ea 0c             	shr    $0xc,%edx
  801e81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e88:	f6 c2 01             	test   $0x1,%dl
  801e8b:	74 0e                	je     801e9b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e8d:	c1 ea 0c             	shr    $0xc,%edx
  801e90:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e97:	ef 
  801e98:	0f b7 c0             	movzwl %ax,%eax
}
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    
  801e9d:	66 90                	xchg   %ax,%ax
  801e9f:	90                   	nop

00801ea0 <__udivdi3>:
  801ea0:	55                   	push   %ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 1c             	sub    $0x1c,%esp
  801ea7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801eab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801eaf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801eb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eb7:	85 f6                	test   %esi,%esi
  801eb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ebd:	89 ca                	mov    %ecx,%edx
  801ebf:	89 f8                	mov    %edi,%eax
  801ec1:	75 3d                	jne    801f00 <__udivdi3+0x60>
  801ec3:	39 cf                	cmp    %ecx,%edi
  801ec5:	0f 87 c5 00 00 00    	ja     801f90 <__udivdi3+0xf0>
  801ecb:	85 ff                	test   %edi,%edi
  801ecd:	89 fd                	mov    %edi,%ebp
  801ecf:	75 0b                	jne    801edc <__udivdi3+0x3c>
  801ed1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed6:	31 d2                	xor    %edx,%edx
  801ed8:	f7 f7                	div    %edi
  801eda:	89 c5                	mov    %eax,%ebp
  801edc:	89 c8                	mov    %ecx,%eax
  801ede:	31 d2                	xor    %edx,%edx
  801ee0:	f7 f5                	div    %ebp
  801ee2:	89 c1                	mov    %eax,%ecx
  801ee4:	89 d8                	mov    %ebx,%eax
  801ee6:	89 cf                	mov    %ecx,%edi
  801ee8:	f7 f5                	div    %ebp
  801eea:	89 c3                	mov    %eax,%ebx
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
  801f00:	39 ce                	cmp    %ecx,%esi
  801f02:	77 74                	ja     801f78 <__udivdi3+0xd8>
  801f04:	0f bd fe             	bsr    %esi,%edi
  801f07:	83 f7 1f             	xor    $0x1f,%edi
  801f0a:	0f 84 98 00 00 00    	je     801fa8 <__udivdi3+0x108>
  801f10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	89 c5                	mov    %eax,%ebp
  801f19:	29 fb                	sub    %edi,%ebx
  801f1b:	d3 e6                	shl    %cl,%esi
  801f1d:	89 d9                	mov    %ebx,%ecx
  801f1f:	d3 ed                	shr    %cl,%ebp
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	d3 e0                	shl    %cl,%eax
  801f25:	09 ee                	or     %ebp,%esi
  801f27:	89 d9                	mov    %ebx,%ecx
  801f29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f2d:	89 d5                	mov    %edx,%ebp
  801f2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f33:	d3 ed                	shr    %cl,%ebp
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e2                	shl    %cl,%edx
  801f39:	89 d9                	mov    %ebx,%ecx
  801f3b:	d3 e8                	shr    %cl,%eax
  801f3d:	09 c2                	or     %eax,%edx
  801f3f:	89 d0                	mov    %edx,%eax
  801f41:	89 ea                	mov    %ebp,%edx
  801f43:	f7 f6                	div    %esi
  801f45:	89 d5                	mov    %edx,%ebp
  801f47:	89 c3                	mov    %eax,%ebx
  801f49:	f7 64 24 0c          	mull   0xc(%esp)
  801f4d:	39 d5                	cmp    %edx,%ebp
  801f4f:	72 10                	jb     801f61 <__udivdi3+0xc1>
  801f51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	d3 e6                	shl    %cl,%esi
  801f59:	39 c6                	cmp    %eax,%esi
  801f5b:	73 07                	jae    801f64 <__udivdi3+0xc4>
  801f5d:	39 d5                	cmp    %edx,%ebp
  801f5f:	75 03                	jne    801f64 <__udivdi3+0xc4>
  801f61:	83 eb 01             	sub    $0x1,%ebx
  801f64:	31 ff                	xor    %edi,%edi
  801f66:	89 d8                	mov    %ebx,%eax
  801f68:	89 fa                	mov    %edi,%edx
  801f6a:	83 c4 1c             	add    $0x1c,%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    
  801f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f78:	31 ff                	xor    %edi,%edi
  801f7a:	31 db                	xor    %ebx,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	89 d8                	mov    %ebx,%eax
  801f92:	f7 f7                	div    %edi
  801f94:	31 ff                	xor    %edi,%edi
  801f96:	89 c3                	mov    %eax,%ebx
  801f98:	89 d8                	mov    %ebx,%eax
  801f9a:	89 fa                	mov    %edi,%edx
  801f9c:	83 c4 1c             	add    $0x1c,%esp
  801f9f:	5b                   	pop    %ebx
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	39 ce                	cmp    %ecx,%esi
  801faa:	72 0c                	jb     801fb8 <__udivdi3+0x118>
  801fac:	31 db                	xor    %ebx,%ebx
  801fae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fb2:	0f 87 34 ff ff ff    	ja     801eec <__udivdi3+0x4c>
  801fb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fbd:	e9 2a ff ff ff       	jmp    801eec <__udivdi3+0x4c>
  801fc2:	66 90                	xchg   %ax,%ax
  801fc4:	66 90                	xchg   %ax,%ax
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__umoddi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 d2                	test   %edx,%edx
  801fe9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ff1:	89 f3                	mov    %esi,%ebx
  801ff3:	89 3c 24             	mov    %edi,(%esp)
  801ff6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ffa:	75 1c                	jne    802018 <__umoddi3+0x48>
  801ffc:	39 f7                	cmp    %esi,%edi
  801ffe:	76 50                	jbe    802050 <__umoddi3+0x80>
  802000:	89 c8                	mov    %ecx,%eax
  802002:	89 f2                	mov    %esi,%edx
  802004:	f7 f7                	div    %edi
  802006:	89 d0                	mov    %edx,%eax
  802008:	31 d2                	xor    %edx,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	39 f2                	cmp    %esi,%edx
  80201a:	89 d0                	mov    %edx,%eax
  80201c:	77 52                	ja     802070 <__umoddi3+0xa0>
  80201e:	0f bd ea             	bsr    %edx,%ebp
  802021:	83 f5 1f             	xor    $0x1f,%ebp
  802024:	75 5a                	jne    802080 <__umoddi3+0xb0>
  802026:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80202a:	0f 82 e0 00 00 00    	jb     802110 <__umoddi3+0x140>
  802030:	39 0c 24             	cmp    %ecx,(%esp)
  802033:	0f 86 d7 00 00 00    	jbe    802110 <__umoddi3+0x140>
  802039:	8b 44 24 08          	mov    0x8(%esp),%eax
  80203d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802041:	83 c4 1c             	add    $0x1c,%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	85 ff                	test   %edi,%edi
  802052:	89 fd                	mov    %edi,%ebp
  802054:	75 0b                	jne    802061 <__umoddi3+0x91>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f7                	div    %edi
  80205f:	89 c5                	mov    %eax,%ebp
  802061:	89 f0                	mov    %esi,%eax
  802063:	31 d2                	xor    %edx,%edx
  802065:	f7 f5                	div    %ebp
  802067:	89 c8                	mov    %ecx,%eax
  802069:	f7 f5                	div    %ebp
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	eb 99                	jmp    802008 <__umoddi3+0x38>
  80206f:	90                   	nop
  802070:	89 c8                	mov    %ecx,%eax
  802072:	89 f2                	mov    %esi,%edx
  802074:	83 c4 1c             	add    $0x1c,%esp
  802077:	5b                   	pop    %ebx
  802078:	5e                   	pop    %esi
  802079:	5f                   	pop    %edi
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    
  80207c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802080:	8b 34 24             	mov    (%esp),%esi
  802083:	bf 20 00 00 00       	mov    $0x20,%edi
  802088:	89 e9                	mov    %ebp,%ecx
  80208a:	29 ef                	sub    %ebp,%edi
  80208c:	d3 e0                	shl    %cl,%eax
  80208e:	89 f9                	mov    %edi,%ecx
  802090:	89 f2                	mov    %esi,%edx
  802092:	d3 ea                	shr    %cl,%edx
  802094:	89 e9                	mov    %ebp,%ecx
  802096:	09 c2                	or     %eax,%edx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 14 24             	mov    %edx,(%esp)
  80209d:	89 f2                	mov    %esi,%edx
  80209f:	d3 e2                	shl    %cl,%edx
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020ab:	d3 e8                	shr    %cl,%eax
  8020ad:	89 e9                	mov    %ebp,%ecx
  8020af:	89 c6                	mov    %eax,%esi
  8020b1:	d3 e3                	shl    %cl,%ebx
  8020b3:	89 f9                	mov    %edi,%ecx
  8020b5:	89 d0                	mov    %edx,%eax
  8020b7:	d3 e8                	shr    %cl,%eax
  8020b9:	89 e9                	mov    %ebp,%ecx
  8020bb:	09 d8                	or     %ebx,%eax
  8020bd:	89 d3                	mov    %edx,%ebx
  8020bf:	89 f2                	mov    %esi,%edx
  8020c1:	f7 34 24             	divl   (%esp)
  8020c4:	89 d6                	mov    %edx,%esi
  8020c6:	d3 e3                	shl    %cl,%ebx
  8020c8:	f7 64 24 04          	mull   0x4(%esp)
  8020cc:	39 d6                	cmp    %edx,%esi
  8020ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020d2:	89 d1                	mov    %edx,%ecx
  8020d4:	89 c3                	mov    %eax,%ebx
  8020d6:	72 08                	jb     8020e0 <__umoddi3+0x110>
  8020d8:	75 11                	jne    8020eb <__umoddi3+0x11b>
  8020da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020de:	73 0b                	jae    8020eb <__umoddi3+0x11b>
  8020e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020e4:	1b 14 24             	sbb    (%esp),%edx
  8020e7:	89 d1                	mov    %edx,%ecx
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020ef:	29 da                	sub    %ebx,%edx
  8020f1:	19 ce                	sbb    %ecx,%esi
  8020f3:	89 f9                	mov    %edi,%ecx
  8020f5:	89 f0                	mov    %esi,%eax
  8020f7:	d3 e0                	shl    %cl,%eax
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	d3 ea                	shr    %cl,%edx
  8020fd:	89 e9                	mov    %ebp,%ecx
  8020ff:	d3 ee                	shr    %cl,%esi
  802101:	09 d0                	or     %edx,%eax
  802103:	89 f2                	mov    %esi,%edx
  802105:	83 c4 1c             	add    $0x1c,%esp
  802108:	5b                   	pop    %ebx
  802109:	5e                   	pop    %esi
  80210a:	5f                   	pop    %edi
  80210b:	5d                   	pop    %ebp
  80210c:	c3                   	ret    
  80210d:	8d 76 00             	lea    0x0(%esi),%esi
  802110:	29 f9                	sub    %edi,%ecx
  802112:	19 d6                	sbb    %edx,%esi
  802114:	89 74 24 04          	mov    %esi,0x4(%esp)
  802118:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80211c:	e9 18 ff ff ff       	jmp    802039 <__umoddi3+0x69>
