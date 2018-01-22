
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
  800039:	68 80 21 80 00       	push   $0x802180
  80003e:	e8 1d 02 00 00       	call   800260 <cprintf>
	exit();
  800043:	e8 6b 01 00 00       	call   8001b3 <exit>
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
  800067:	e8 8d 0d 00 00       	call   800df9 <argstart>
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
  800091:	e8 93 0d 00 00       	call   800e29 <argnext>
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
  8000ad:	e8 8f 13 00 00       	call   801441 <fstat>
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
  8000ce:	68 94 21 80 00       	push   $0x802194
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 61 17 00 00       	call   80183b <fprintf>
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
  8000f0:	68 94 21 80 00       	push   $0x802194
  8000f5:	e8 66 01 00 00       	call   800260 <cprintf>
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
  800120:	e8 85 0a 00 00       	call   800baa <sys_getenvid>
  800125:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800127:	83 ec 08             	sub    $0x8,%esp
  80012a:	50                   	push   %eax
  80012b:	68 bc 21 80 00       	push   $0x8021bc
  800130:	e8 2b 01 00 00       	call   800260 <cprintf>
  800135:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80013b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800148:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80014d:	89 c1                	mov    %eax,%ecx
  80014f:	c1 e1 07             	shl    $0x7,%ecx
  800152:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800159:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80015c:	39 cb                	cmp    %ecx,%ebx
  80015e:	0f 44 fa             	cmove  %edx,%edi
  800161:	b9 01 00 00 00       	mov    $0x1,%ecx
  800166:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800169:	83 c0 01             	add    $0x1,%eax
  80016c:	81 c2 84 00 00 00    	add    $0x84,%edx
  800172:	3d 00 04 00 00       	cmp    $0x400,%eax
  800177:	75 d4                	jne    80014d <libmain+0x40>
  800179:	89 f0                	mov    %esi,%eax
  80017b:	84 c0                	test   %al,%al
  80017d:	74 06                	je     800185 <libmain+0x78>
  80017f:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800185:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800189:	7e 0a                	jle    800195 <libmain+0x88>
		binaryname = argv[0];
  80018b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018e:	8b 00                	mov    (%eax),%eax
  800190:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	e8 aa fe ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  8001a3:	e8 0b 00 00 00       	call   8001b3 <exit>
}
  8001a8:	83 c4 10             	add    $0x10,%esp
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001b9:	e8 5a 0f 00 00       	call   801118 <close_all>
	sys_env_destroy(0);
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	6a 00                	push   $0x0
  8001c3:	e8 a1 09 00 00       	call   800b69 <sys_env_destroy>
}
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 04             	sub    $0x4,%esp
  8001d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d7:	8b 13                	mov    (%ebx),%edx
  8001d9:	8d 42 01             	lea    0x1(%edx),%eax
  8001dc:	89 03                	mov    %eax,(%ebx)
  8001de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ea:	75 1a                	jne    800206 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	68 ff 00 00 00       	push   $0xff
  8001f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 2f 09 00 00       	call   800b2c <sys_cputs>
		b->idx = 0;
  8001fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800203:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800206:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	ff 75 0c             	pushl  0xc(%ebp)
  80022f:	ff 75 08             	pushl  0x8(%ebp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	50                   	push   %eax
  800239:	68 cd 01 80 00       	push   $0x8001cd
  80023e:	e8 54 01 00 00       	call   800397 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800243:	83 c4 08             	add    $0x8,%esp
  800246:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80024c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800252:	50                   	push   %eax
  800253:	e8 d4 08 00 00       	call   800b2c <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	50                   	push   %eax
  80026a:	ff 75 08             	pushl  0x8(%ebp)
  80026d:	e8 9d ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 1c             	sub    $0x1c,%esp
  80027d:	89 c7                	mov    %eax,%edi
  80027f:	89 d6                	mov    %edx,%esi
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800298:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80029b:	39 d3                	cmp    %edx,%ebx
  80029d:	72 05                	jb     8002a4 <printnum+0x30>
  80029f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a2:	77 45                	ja     8002e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	ff 75 18             	pushl  0x18(%ebp)
  8002aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002b0:	53                   	push   %ebx
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c3:	e8 18 1c 00 00       	call   801ee0 <__udivdi3>
  8002c8:	83 c4 18             	add    $0x18,%esp
  8002cb:	52                   	push   %edx
  8002cc:	50                   	push   %eax
  8002cd:	89 f2                	mov    %esi,%edx
  8002cf:	89 f8                	mov    %edi,%eax
  8002d1:	e8 9e ff ff ff       	call   800274 <printnum>
  8002d6:	83 c4 20             	add    $0x20,%esp
  8002d9:	eb 18                	jmp    8002f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002db:	83 ec 08             	sub    $0x8,%esp
  8002de:	56                   	push   %esi
  8002df:	ff 75 18             	pushl  0x18(%ebp)
  8002e2:	ff d7                	call   *%edi
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	eb 03                	jmp    8002ec <printnum+0x78>
  8002e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ec:	83 eb 01             	sub    $0x1,%ebx
  8002ef:	85 db                	test   %ebx,%ebx
  8002f1:	7f e8                	jg     8002db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	56                   	push   %esi
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800300:	ff 75 dc             	pushl  -0x24(%ebp)
  800303:	ff 75 d8             	pushl  -0x28(%ebp)
  800306:	e8 05 1d 00 00       	call   802010 <__umoddi3>
  80030b:	83 c4 14             	add    $0x14,%esp
  80030e:	0f be 80 e5 21 80 00 	movsbl 0x8021e5(%eax),%eax
  800315:	50                   	push   %eax
  800316:	ff d7                	call   *%edi
}
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031e:	5b                   	pop    %ebx
  80031f:	5e                   	pop    %esi
  800320:	5f                   	pop    %edi
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800326:	83 fa 01             	cmp    $0x1,%edx
  800329:	7e 0e                	jle    800339 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 02                	mov    (%edx),%eax
  800334:	8b 52 04             	mov    0x4(%edx),%edx
  800337:	eb 22                	jmp    80035b <getuint+0x38>
	else if (lflag)
  800339:	85 d2                	test   %edx,%edx
  80033b:	74 10                	je     80034d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 02                	mov    (%edx),%eax
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
  80034b:	eb 0e                	jmp    80035b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034d:	8b 10                	mov    (%eax),%edx
  80034f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800352:	89 08                	mov    %ecx,(%eax)
  800354:	8b 02                	mov    (%edx),%eax
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800363:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800367:	8b 10                	mov    (%eax),%edx
  800369:	3b 50 04             	cmp    0x4(%eax),%edx
  80036c:	73 0a                	jae    800378 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	88 02                	mov    %al,(%edx)
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800380:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800383:	50                   	push   %eax
  800384:	ff 75 10             	pushl  0x10(%ebp)
  800387:	ff 75 0c             	pushl  0xc(%ebp)
  80038a:	ff 75 08             	pushl  0x8(%ebp)
  80038d:	e8 05 00 00 00       	call   800397 <vprintfmt>
	va_end(ap);
}
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	c9                   	leave  
  800396:	c3                   	ret    

00800397 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 2c             	sub    $0x2c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a9:	eb 12                	jmp    8003bd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	0f 84 89 03 00 00    	je     80073c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003b3:	83 ec 08             	sub    $0x8,%esp
  8003b6:	53                   	push   %ebx
  8003b7:	50                   	push   %eax
  8003b8:	ff d6                	call   *%esi
  8003ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bd:	83 c7 01             	add    $0x1,%edi
  8003c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003c4:	83 f8 25             	cmp    $0x25,%eax
  8003c7:	75 e2                	jne    8003ab <vprintfmt+0x14>
  8003c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e7:	eb 07                	jmp    8003f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8d 47 01             	lea    0x1(%edi),%eax
  8003f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f6:	0f b6 07             	movzbl (%edi),%eax
  8003f9:	0f b6 c8             	movzbl %al,%ecx
  8003fc:	83 e8 23             	sub    $0x23,%eax
  8003ff:	3c 55                	cmp    $0x55,%al
  800401:	0f 87 1a 03 00 00    	ja     800721 <vprintfmt+0x38a>
  800407:	0f b6 c0             	movzbl %al,%eax
  80040a:	ff 24 85 20 23 80 00 	jmp    *0x802320(,%eax,4)
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800414:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800418:	eb d6                	jmp    8003f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
  800422:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800425:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800428:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80042c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80042f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800432:	83 fa 09             	cmp    $0x9,%edx
  800435:	77 39                	ja     800470 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800437:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043a:	eb e9                	jmp    800425 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 48 04             	lea    0x4(%eax),%ecx
  800442:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800445:	8b 00                	mov    (%eax),%eax
  800447:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044d:	eb 27                	jmp    800476 <vprintfmt+0xdf>
  80044f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800452:	85 c0                	test   %eax,%eax
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
  800459:	0f 49 c8             	cmovns %eax,%ecx
  80045c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800462:	eb 8c                	jmp    8003f0 <vprintfmt+0x59>
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800467:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80046e:	eb 80                	jmp    8003f0 <vprintfmt+0x59>
  800470:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	0f 89 70 ff ff ff    	jns    8003f0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800480:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800486:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048d:	e9 5e ff ff ff       	jmp    8003f0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800492:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800498:	e9 53 ff ff ff       	jmp    8003f0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	53                   	push   %ebx
  8004aa:	ff 30                	pushl  (%eax)
  8004ac:	ff d6                	call   *%esi
			break;
  8004ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b4:	e9 04 ff ff ff       	jmp    8003bd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 50 04             	lea    0x4(%eax),%edx
  8004bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	99                   	cltd   
  8004c5:	31 d0                	xor    %edx,%eax
  8004c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 f8 0f             	cmp    $0xf,%eax
  8004cc:	7f 0b                	jg     8004d9 <vprintfmt+0x142>
  8004ce:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	75 18                	jne    8004f1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004d9:	50                   	push   %eax
  8004da:	68 fd 21 80 00       	push   $0x8021fd
  8004df:	53                   	push   %ebx
  8004e0:	56                   	push   %esi
  8004e1:	e8 94 fe ff ff       	call   80037a <printfmt>
  8004e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ec:	e9 cc fe ff ff       	jmp    8003bd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f1:	52                   	push   %edx
  8004f2:	68 b1 25 80 00       	push   $0x8025b1
  8004f7:	53                   	push   %ebx
  8004f8:	56                   	push   %esi
  8004f9:	e8 7c fe ff ff       	call   80037a <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800504:	e9 b4 fe ff ff       	jmp    8003bd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800514:	85 ff                	test   %edi,%edi
  800516:	b8 f6 21 80 00       	mov    $0x8021f6,%eax
  80051b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800522:	0f 8e 94 00 00 00    	jle    8005bc <vprintfmt+0x225>
  800528:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052c:	0f 84 98 00 00 00    	je     8005ca <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 d0             	pushl  -0x30(%ebp)
  800538:	57                   	push   %edi
  800539:	e8 86 02 00 00       	call   8007c4 <strnlen>
  80053e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800541:	29 c1                	sub    %eax,%ecx
  800543:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800546:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800549:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800550:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800553:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	eb 0f                	jmp    800566 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	ff 75 e0             	pushl  -0x20(%ebp)
  80055e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800560:	83 ef 01             	sub    $0x1,%edi
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	85 ff                	test   %edi,%edi
  800568:	7f ed                	jg     800557 <vprintfmt+0x1c0>
  80056a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800570:	85 c9                	test   %ecx,%ecx
  800572:	b8 00 00 00 00       	mov    $0x0,%eax
  800577:	0f 49 c1             	cmovns %ecx,%eax
  80057a:	29 c1                	sub    %eax,%ecx
  80057c:	89 75 08             	mov    %esi,0x8(%ebp)
  80057f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800582:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800585:	89 cb                	mov    %ecx,%ebx
  800587:	eb 4d                	jmp    8005d6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058d:	74 1b                	je     8005aa <vprintfmt+0x213>
  80058f:	0f be c0             	movsbl %al,%eax
  800592:	83 e8 20             	sub    $0x20,%eax
  800595:	83 f8 5e             	cmp    $0x5e,%eax
  800598:	76 10                	jbe    8005aa <vprintfmt+0x213>
					putch('?', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	ff 75 0c             	pushl  0xc(%ebp)
  8005a0:	6a 3f                	push   $0x3f
  8005a2:	ff 55 08             	call   *0x8(%ebp)
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 0d                	jmp    8005b7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	ff 75 0c             	pushl  0xc(%ebp)
  8005b0:	52                   	push   %edx
  8005b1:	ff 55 08             	call   *0x8(%ebp)
  8005b4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b7:	83 eb 01             	sub    $0x1,%ebx
  8005ba:	eb 1a                	jmp    8005d6 <vprintfmt+0x23f>
  8005bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c8:	eb 0c                	jmp    8005d6 <vprintfmt+0x23f>
  8005ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d6:	83 c7 01             	add    $0x1,%edi
  8005d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005dd:	0f be d0             	movsbl %al,%edx
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	74 23                	je     800607 <vprintfmt+0x270>
  8005e4:	85 f6                	test   %esi,%esi
  8005e6:	78 a1                	js     800589 <vprintfmt+0x1f2>
  8005e8:	83 ee 01             	sub    $0x1,%esi
  8005eb:	79 9c                	jns    800589 <vprintfmt+0x1f2>
  8005ed:	89 df                	mov    %ebx,%edi
  8005ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f5:	eb 18                	jmp    80060f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 20                	push   $0x20
  8005fd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ff:	83 ef 01             	sub    $0x1,%edi
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb 08                	jmp    80060f <vprintfmt+0x278>
  800607:	89 df                	mov    %ebx,%edi
  800609:	8b 75 08             	mov    0x8(%ebp),%esi
  80060c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060f:	85 ff                	test   %edi,%edi
  800611:	7f e4                	jg     8005f7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800616:	e9 a2 fd ff ff       	jmp    8003bd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061b:	83 fa 01             	cmp    $0x1,%edx
  80061e:	7e 16                	jle    800636 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 08             	lea    0x8(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 50 04             	mov    0x4(%eax),%edx
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800634:	eb 32                	jmp    800668 <vprintfmt+0x2d1>
	else if (lflag)
  800636:	85 d2                	test   %edx,%edx
  800638:	74 18                	je     800652 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 c1                	mov    %eax,%ecx
  80064a:	c1 f9 1f             	sar    $0x1f,%ecx
  80064d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800650:	eb 16                	jmp    800668 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800660:	89 c1                	mov    %eax,%ecx
  800662:	c1 f9 1f             	sar    $0x1f,%ecx
  800665:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800668:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80066e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800673:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800677:	79 74                	jns    8006ed <vprintfmt+0x356>
				putch('-', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 2d                	push   $0x2d
  80067f:	ff d6                	call   *%esi
				num = -(long long) num;
  800681:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800684:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800687:	f7 d8                	neg    %eax
  800689:	83 d2 00             	adc    $0x0,%edx
  80068c:	f7 da                	neg    %edx
  80068e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800691:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800696:	eb 55                	jmp    8006ed <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
  80069b:	e8 83 fc ff ff       	call   800323 <getuint>
			base = 10;
  8006a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a5:	eb 46                	jmp    8006ed <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 74 fc ff ff       	call   800323 <getuint>
			base = 8;
  8006af:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b4:	eb 37                	jmp    8006ed <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 30                	push   $0x30
  8006bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 78                	push   $0x78
  8006c4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006de:	eb 0d                	jmp    8006ed <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e3:	e8 3b fc ff ff       	call   800323 <getuint>
			base = 16;
  8006e8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f4:	57                   	push   %edi
  8006f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f8:	51                   	push   %ecx
  8006f9:	52                   	push   %edx
  8006fa:	50                   	push   %eax
  8006fb:	89 da                	mov    %ebx,%edx
  8006fd:	89 f0                	mov    %esi,%eax
  8006ff:	e8 70 fb ff ff       	call   800274 <printnum>
			break;
  800704:	83 c4 20             	add    $0x20,%esp
  800707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070a:	e9 ae fc ff ff       	jmp    8003bd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	51                   	push   %ecx
  800714:	ff d6                	call   *%esi
			break;
  800716:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800719:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071c:	e9 9c fc ff ff       	jmp    8003bd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	6a 25                	push   $0x25
  800727:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 03                	jmp    800731 <vprintfmt+0x39a>
  80072e:	83 ef 01             	sub    $0x1,%edi
  800731:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800735:	75 f7                	jne    80072e <vprintfmt+0x397>
  800737:	e9 81 fc ff ff       	jmp    8003bd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80073c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073f:	5b                   	pop    %ebx
  800740:	5e                   	pop    %esi
  800741:	5f                   	pop    %edi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 18             	sub    $0x18,%esp
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800750:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800753:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800757:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800761:	85 c0                	test   %eax,%eax
  800763:	74 26                	je     80078b <vsnprintf+0x47>
  800765:	85 d2                	test   %edx,%edx
  800767:	7e 22                	jle    80078b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800769:	ff 75 14             	pushl  0x14(%ebp)
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800772:	50                   	push   %eax
  800773:	68 5d 03 80 00       	push   $0x80035d
  800778:	e8 1a fc ff ff       	call   800397 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800780:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	eb 05                	jmp    800790 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079b:	50                   	push   %eax
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	ff 75 08             	pushl  0x8(%ebp)
  8007a5:	e8 9a ff ff ff       	call   800744 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	eb 03                	jmp    8007bc <strlen+0x10>
		n++;
  8007b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c0:	75 f7                	jne    8007b9 <strlen+0xd>
		n++;
	return n;
}
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d2:	eb 03                	jmp    8007d7 <strnlen+0x13>
		n++;
  8007d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d7:	39 c2                	cmp    %eax,%edx
  8007d9:	74 08                	je     8007e3 <strnlen+0x1f>
  8007db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007df:	75 f3                	jne    8007d4 <strnlen+0x10>
  8007e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ef:	89 c2                	mov    %eax,%edx
  8007f1:	83 c2 01             	add    $0x1,%edx
  8007f4:	83 c1 01             	add    $0x1,%ecx
  8007f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007fe:	84 db                	test   %bl,%bl
  800800:	75 ef                	jne    8007f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800802:	5b                   	pop    %ebx
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080c:	53                   	push   %ebx
  80080d:	e8 9a ff ff ff       	call   8007ac <strlen>
  800812:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	01 d8                	add    %ebx,%eax
  80081a:	50                   	push   %eax
  80081b:	e8 c5 ff ff ff       	call   8007e5 <strcpy>
	return dst;
}
  800820:	89 d8                	mov    %ebx,%eax
  800822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	89 f3                	mov    %esi,%ebx
  800834:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800837:	89 f2                	mov    %esi,%edx
  800839:	eb 0f                	jmp    80084a <strncpy+0x23>
		*dst++ = *src;
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	0f b6 01             	movzbl (%ecx),%eax
  800841:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800844:	80 39 01             	cmpb   $0x1,(%ecx)
  800847:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084a:	39 da                	cmp    %ebx,%edx
  80084c:	75 ed                	jne    80083b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084e:	89 f0                	mov    %esi,%eax
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	8b 75 08             	mov    0x8(%ebp),%esi
  80085c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085f:	8b 55 10             	mov    0x10(%ebp),%edx
  800862:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800864:	85 d2                	test   %edx,%edx
  800866:	74 21                	je     800889 <strlcpy+0x35>
  800868:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086c:	89 f2                	mov    %esi,%edx
  80086e:	eb 09                	jmp    800879 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800879:	39 c2                	cmp    %eax,%edx
  80087b:	74 09                	je     800886 <strlcpy+0x32>
  80087d:	0f b6 19             	movzbl (%ecx),%ebx
  800880:	84 db                	test   %bl,%bl
  800882:	75 ec                	jne    800870 <strlcpy+0x1c>
  800884:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800886:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800889:	29 f0                	sub    %esi,%eax
}
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strcmp+0x11>
		p++, q++;
  80089a:	83 c1 01             	add    $0x1,%ecx
  80089d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a0:	0f b6 01             	movzbl (%ecx),%eax
  8008a3:	84 c0                	test   %al,%al
  8008a5:	74 04                	je     8008ab <strcmp+0x1c>
  8008a7:	3a 02                	cmp    (%edx),%al
  8008a9:	74 ef                	je     80089a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 c0             	movzbl %al,%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	89 c3                	mov    %eax,%ebx
  8008c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strncmp+0x17>
		n--, p++, q++;
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cc:	39 d8                	cmp    %ebx,%eax
  8008ce:	74 15                	je     8008e5 <strncmp+0x30>
  8008d0:	0f b6 08             	movzbl (%eax),%ecx
  8008d3:	84 c9                	test   %cl,%cl
  8008d5:	74 04                	je     8008db <strncmp+0x26>
  8008d7:	3a 0a                	cmp    (%edx),%cl
  8008d9:	74 eb                	je     8008c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 00             	movzbl (%eax),%eax
  8008de:	0f b6 12             	movzbl (%edx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
  8008e3:	eb 05                	jmp    8008ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f7:	eb 07                	jmp    800900 <strchr+0x13>
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	74 0f                	je     80090c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	0f b6 10             	movzbl (%eax),%edx
  800903:	84 d2                	test   %dl,%dl
  800905:	75 f2                	jne    8008f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800918:	eb 03                	jmp    80091d <strfind+0xf>
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 04                	je     800928 <strfind+0x1a>
  800924:	84 d2                	test   %dl,%dl
  800926:	75 f2                	jne    80091a <strfind+0xc>
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800936:	85 c9                	test   %ecx,%ecx
  800938:	74 36                	je     800970 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800940:	75 28                	jne    80096a <memset+0x40>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 23                	jne    80096a <memset+0x40>
		c &= 0xFF;
  800947:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094b:	89 d3                	mov    %edx,%ebx
  80094d:	c1 e3 08             	shl    $0x8,%ebx
  800950:	89 d6                	mov    %edx,%esi
  800952:	c1 e6 18             	shl    $0x18,%esi
  800955:	89 d0                	mov    %edx,%eax
  800957:	c1 e0 10             	shl    $0x10,%eax
  80095a:	09 f0                	or     %esi,%eax
  80095c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80095e:	89 d8                	mov    %ebx,%eax
  800960:	09 d0                	or     %edx,%eax
  800962:	c1 e9 02             	shr    $0x2,%ecx
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 06                	jmp    800970 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096d:	fc                   	cld    
  80096e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800970:	89 f8                	mov    %edi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800985:	39 c6                	cmp    %eax,%esi
  800987:	73 35                	jae    8009be <memmove+0x47>
  800989:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098c:	39 d0                	cmp    %edx,%eax
  80098e:	73 2e                	jae    8009be <memmove+0x47>
		s += n;
		d += n;
  800990:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 d6                	mov    %edx,%esi
  800995:	09 fe                	or     %edi,%esi
  800997:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099d:	75 13                	jne    8009b2 <memmove+0x3b>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 0e                	jne    8009b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a4:	83 ef 04             	sub    $0x4,%edi
  8009a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009aa:	c1 e9 02             	shr    $0x2,%ecx
  8009ad:	fd                   	std    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 09                	jmp    8009bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b2:	83 ef 01             	sub    $0x1,%edi
  8009b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b8:	fd                   	std    
  8009b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bb:	fc                   	cld    
  8009bc:	eb 1d                	jmp    8009db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009be:	89 f2                	mov    %esi,%edx
  8009c0:	09 c2                	or     %eax,%edx
  8009c2:	f6 c2 03             	test   $0x3,%dl
  8009c5:	75 0f                	jne    8009d6 <memmove+0x5f>
  8009c7:	f6 c1 03             	test   $0x3,%cl
  8009ca:	75 0a                	jne    8009d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
  8009cf:	89 c7                	mov    %eax,%edi
  8009d1:	fc                   	cld    
  8009d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d4:	eb 05                	jmp    8009db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e2:	ff 75 10             	pushl  0x10(%ebp)
  8009e5:	ff 75 0c             	pushl  0xc(%ebp)
  8009e8:	ff 75 08             	pushl  0x8(%ebp)
  8009eb:	e8 87 ff ff ff       	call   800977 <memmove>
}
  8009f0:	c9                   	leave  
  8009f1:	c3                   	ret    

008009f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fd:	89 c6                	mov    %eax,%esi
  8009ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	eb 1a                	jmp    800a1e <memcmp+0x2c>
		if (*s1 != *s2)
  800a04:	0f b6 08             	movzbl (%eax),%ecx
  800a07:	0f b6 1a             	movzbl (%edx),%ebx
  800a0a:	38 d9                	cmp    %bl,%cl
  800a0c:	74 0a                	je     800a18 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a0e:	0f b6 c1             	movzbl %cl,%eax
  800a11:	0f b6 db             	movzbl %bl,%ebx
  800a14:	29 d8                	sub    %ebx,%eax
  800a16:	eb 0f                	jmp    800a27 <memcmp+0x35>
		s1++, s2++;
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1e:	39 f0                	cmp    %esi,%eax
  800a20:	75 e2                	jne    800a04 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a32:	89 c1                	mov    %eax,%ecx
  800a34:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a37:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3b:	eb 0a                	jmp    800a47 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	39 da                	cmp    %ebx,%edx
  800a42:	74 07                	je     800a4b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	39 c8                	cmp    %ecx,%eax
  800a49:	72 f2                	jb     800a3d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	eb 03                	jmp    800a5f <strtol+0x11>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	3c 20                	cmp    $0x20,%al
  800a64:	74 f6                	je     800a5c <strtol+0xe>
  800a66:	3c 09                	cmp    $0x9,%al
  800a68:	74 f2                	je     800a5c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6a:	3c 2b                	cmp    $0x2b,%al
  800a6c:	75 0a                	jne    800a78 <strtol+0x2a>
		s++;
  800a6e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a71:	bf 00 00 00 00       	mov    $0x0,%edi
  800a76:	eb 11                	jmp    800a89 <strtol+0x3b>
  800a78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a7d:	3c 2d                	cmp    $0x2d,%al
  800a7f:	75 08                	jne    800a89 <strtol+0x3b>
		s++, neg = 1;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a89:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8f:	75 15                	jne    800aa6 <strtol+0x58>
  800a91:	80 39 30             	cmpb   $0x30,(%ecx)
  800a94:	75 10                	jne    800aa6 <strtol+0x58>
  800a96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9a:	75 7c                	jne    800b18 <strtol+0xca>
		s += 2, base = 16;
  800a9c:	83 c1 02             	add    $0x2,%ecx
  800a9f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa4:	eb 16                	jmp    800abc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	75 12                	jne    800abc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aaa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab2:	75 08                	jne    800abc <strtol+0x6e>
		s++, base = 8;
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac4:	0f b6 11             	movzbl (%ecx),%edx
  800ac7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 09             	cmp    $0x9,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0x8b>
			dig = *s - '0';
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 30             	sub    $0x30,%edx
  800ad7:	eb 22                	jmp    800afb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 08                	ja     800aeb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 57             	sub    $0x57,%edx
  800ae9:	eb 10                	jmp    800afb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aeb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aee:	89 f3                	mov    %esi,%ebx
  800af0:	80 fb 19             	cmp    $0x19,%bl
  800af3:	77 16                	ja     800b0b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af5:	0f be d2             	movsbl %dl,%edx
  800af8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800afb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800afe:	7d 0b                	jge    800b0b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b00:	83 c1 01             	add    $0x1,%ecx
  800b03:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b09:	eb b9                	jmp    800ac4 <strtol+0x76>

	if (endptr)
  800b0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0f:	74 0d                	je     800b1e <strtol+0xd0>
		*endptr = (char *) s;
  800b11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b14:	89 0e                	mov    %ecx,(%esi)
  800b16:	eb 06                	jmp    800b1e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b18:	85 db                	test   %ebx,%ebx
  800b1a:	74 98                	je     800ab4 <strtol+0x66>
  800b1c:	eb 9e                	jmp    800abc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	f7 da                	neg    %edx
  800b22:	85 ff                	test   %edi,%edi
  800b24:	0f 45 c2             	cmovne %edx,%eax
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b77:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	89 cb                	mov    %ecx,%ebx
  800b81:	89 cf                	mov    %ecx,%edi
  800b83:	89 ce                	mov    %ecx,%esi
  800b85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 17                	jle    800ba2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 03                	push   $0x3
  800b91:	68 df 24 80 00       	push   $0x8024df
  800b96:	6a 23                	push   $0x23
  800b98:	68 fc 24 80 00       	push   $0x8024fc
  800b9d:	e8 a5 11 00 00       	call   801d47 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_yield>:

void
sys_yield(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd9:	89 d1                	mov    %edx,%ecx
  800bdb:	89 d3                	mov    %edx,%ebx
  800bdd:	89 d7                	mov    %edx,%edi
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	be 00 00 00 00       	mov    $0x0,%esi
  800bf6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c04:	89 f7                	mov    %esi,%edi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 04                	push   $0x4
  800c12:	68 df 24 80 00       	push   $0x8024df
  800c17:	6a 23                	push   $0x23
  800c19:	68 fc 24 80 00       	push   $0x8024fc
  800c1e:	e8 24 11 00 00       	call   801d47 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	b8 05 00 00 00       	mov    $0x5,%eax
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c45:	8b 75 18             	mov    0x18(%ebp),%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 05                	push   $0x5
  800c54:	68 df 24 80 00       	push   $0x8024df
  800c59:	6a 23                	push   $0x23
  800c5b:	68 fc 24 80 00       	push   $0x8024fc
  800c60:	e8 e2 10 00 00       	call   801d47 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 06                	push   $0x6
  800c96:	68 df 24 80 00       	push   $0x8024df
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 fc 24 80 00       	push   $0x8024fc
  800ca2:	e8 a0 10 00 00       	call   801d47 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 08                	push   $0x8
  800cd8:	68 df 24 80 00       	push   $0x8024df
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 fc 24 80 00       	push   $0x8024fc
  800ce4:	e8 5e 10 00 00       	call   801d47 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cff:	b8 09 00 00 00       	mov    $0x9,%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 df                	mov    %ebx,%edi
  800d0c:	89 de                	mov    %ebx,%esi
  800d0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7e 17                	jle    800d2b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 09                	push   $0x9
  800d1a:	68 df 24 80 00       	push   $0x8024df
  800d1f:	6a 23                	push   $0x23
  800d21:	68 fc 24 80 00       	push   $0x8024fc
  800d26:	e8 1c 10 00 00       	call   801d47 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 17                	jle    800d6d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 0a                	push   $0xa
  800d5c:	68 df 24 80 00       	push   $0x8024df
  800d61:	6a 23                	push   $0x23
  800d63:	68 fc 24 80 00       	push   $0x8024fc
  800d68:	e8 da 0f 00 00       	call   801d47 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	be 00 00 00 00       	mov    $0x0,%esi
  800d80:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d91:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	89 cb                	mov    %ecx,%ebx
  800db0:	89 cf                	mov    %ecx,%edi
  800db2:	89 ce                	mov    %ecx,%esi
  800db4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 17                	jle    800dd1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	50                   	push   %eax
  800dbe:	6a 0d                	push   $0xd
  800dc0:	68 df 24 80 00       	push   $0x8024df
  800dc5:	6a 23                	push   $0x23
  800dc7:	68 fc 24 80 00       	push   $0x8024fc
  800dcc:	e8 76 0f 00 00       	call   801d47 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	89 cb                	mov    %ecx,%ebx
  800dee:	89 cf                	mov    %ecx,%edi
  800df0:	89 ce                	mov    %ecx,%esi
  800df2:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e05:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e07:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e0a:	83 3a 01             	cmpl   $0x1,(%edx)
  800e0d:	7e 09                	jle    800e18 <argstart+0x1f>
  800e0f:	ba 91 21 80 00       	mov    $0x802191,%edx
  800e14:	85 c9                	test   %ecx,%ecx
  800e16:	75 05                	jne    800e1d <argstart+0x24>
  800e18:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e20:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <argnext>:

int
argnext(struct Argstate *args)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 04             	sub    $0x4,%esp
  800e30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e33:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e3a:	8b 43 08             	mov    0x8(%ebx),%eax
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	74 6f                	je     800eb0 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e41:	80 38 00             	cmpb   $0x0,(%eax)
  800e44:	75 4e                	jne    800e94 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e46:	8b 0b                	mov    (%ebx),%ecx
  800e48:	83 39 01             	cmpl   $0x1,(%ecx)
  800e4b:	74 55                	je     800ea2 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e4d:	8b 53 04             	mov    0x4(%ebx),%edx
  800e50:	8b 42 04             	mov    0x4(%edx),%eax
  800e53:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e56:	75 4a                	jne    800ea2 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e58:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e5c:	74 44                	je     800ea2 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e5e:	83 c0 01             	add    $0x1,%eax
  800e61:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	8b 01                	mov    (%ecx),%eax
  800e69:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e70:	50                   	push   %eax
  800e71:	8d 42 08             	lea    0x8(%edx),%eax
  800e74:	50                   	push   %eax
  800e75:	83 c2 04             	add    $0x4,%edx
  800e78:	52                   	push   %edx
  800e79:	e8 f9 fa ff ff       	call   800977 <memmove>
		(*args->argc)--;
  800e7e:	8b 03                	mov    (%ebx),%eax
  800e80:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e83:	8b 43 08             	mov    0x8(%ebx),%eax
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e8c:	75 06                	jne    800e94 <argnext+0x6b>
  800e8e:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e92:	74 0e                	je     800ea2 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e94:	8b 53 08             	mov    0x8(%ebx),%edx
  800e97:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e9a:	83 c2 01             	add    $0x1,%edx
  800e9d:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800ea0:	eb 13                	jmp    800eb5 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800ea2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ea9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800eae:	eb 05                	jmp    800eb5 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800eb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800ec4:	8b 43 08             	mov    0x8(%ebx),%eax
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	74 58                	je     800f23 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800ecb:	80 38 00             	cmpb   $0x0,(%eax)
  800ece:	74 0c                	je     800edc <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800ed0:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800ed3:	c7 43 08 91 21 80 00 	movl   $0x802191,0x8(%ebx)
  800eda:	eb 42                	jmp    800f1e <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800edc:	8b 13                	mov    (%ebx),%edx
  800ede:	83 3a 01             	cmpl   $0x1,(%edx)
  800ee1:	7e 2d                	jle    800f10 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800ee3:	8b 43 04             	mov    0x4(%ebx),%eax
  800ee6:	8b 48 04             	mov    0x4(%eax),%ecx
  800ee9:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	8b 12                	mov    (%edx),%edx
  800ef1:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800ef8:	52                   	push   %edx
  800ef9:	8d 50 08             	lea    0x8(%eax),%edx
  800efc:	52                   	push   %edx
  800efd:	83 c0 04             	add    $0x4,%eax
  800f00:	50                   	push   %eax
  800f01:	e8 71 fa ff ff       	call   800977 <memmove>
		(*args->argc)--;
  800f06:	8b 03                	mov    (%ebx),%eax
  800f08:	83 28 01             	subl   $0x1,(%eax)
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	eb 0e                	jmp    800f1e <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800f10:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f17:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f1e:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f21:	eb 05                	jmp    800f28 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f36:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	85 d2                	test   %edx,%edx
  800f3d:	75 0c                	jne    800f4b <argvalue+0x1e>
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	51                   	push   %ecx
  800f43:	e8 72 ff ff ff       	call   800eba <argnextvalue>
  800f48:	83 c4 10             	add    $0x10,%esp
}
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
  800f53:	05 00 00 00 30       	add    $0x30000000,%eax
  800f58:	c1 e8 0c             	shr    $0xc,%eax
}
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
  800f63:	05 00 00 00 30       	add    $0x30000000,%eax
  800f68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f6d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f7f:	89 c2                	mov    %eax,%edx
  800f81:	c1 ea 16             	shr    $0x16,%edx
  800f84:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f8b:	f6 c2 01             	test   $0x1,%dl
  800f8e:	74 11                	je     800fa1 <fd_alloc+0x2d>
  800f90:	89 c2                	mov    %eax,%edx
  800f92:	c1 ea 0c             	shr    $0xc,%edx
  800f95:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9c:	f6 c2 01             	test   $0x1,%dl
  800f9f:	75 09                	jne    800faa <fd_alloc+0x36>
			*fd_store = fd;
  800fa1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	eb 17                	jmp    800fc1 <fd_alloc+0x4d>
  800faa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800faf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fb4:	75 c9                	jne    800f7f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fb6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fbc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fc9:	83 f8 1f             	cmp    $0x1f,%eax
  800fcc:	77 36                	ja     801004 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fce:	c1 e0 0c             	shl    $0xc,%eax
  800fd1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fd6:	89 c2                	mov    %eax,%edx
  800fd8:	c1 ea 16             	shr    $0x16,%edx
  800fdb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fe2:	f6 c2 01             	test   $0x1,%dl
  800fe5:	74 24                	je     80100b <fd_lookup+0x48>
  800fe7:	89 c2                	mov    %eax,%edx
  800fe9:	c1 ea 0c             	shr    $0xc,%edx
  800fec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ff3:	f6 c2 01             	test   $0x1,%dl
  800ff6:	74 1a                	je     801012 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ff8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ffb:	89 02                	mov    %eax,(%edx)
	return 0;
  800ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  801002:	eb 13                	jmp    801017 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801004:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801009:	eb 0c                	jmp    801017 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80100b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801010:	eb 05                	jmp    801017 <fd_lookup+0x54>
  801012:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801022:	ba 88 25 80 00       	mov    $0x802588,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801027:	eb 13                	jmp    80103c <dev_lookup+0x23>
  801029:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80102c:	39 08                	cmp    %ecx,(%eax)
  80102e:	75 0c                	jne    80103c <dev_lookup+0x23>
			*dev = devtab[i];
  801030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801033:	89 01                	mov    %eax,(%ecx)
			return 0;
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
  80103a:	eb 2e                	jmp    80106a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80103c:	8b 02                	mov    (%edx),%eax
  80103e:	85 c0                	test   %eax,%eax
  801040:	75 e7                	jne    801029 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801042:	a1 04 40 80 00       	mov    0x804004,%eax
  801047:	8b 40 50             	mov    0x50(%eax),%eax
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	51                   	push   %ecx
  80104e:	50                   	push   %eax
  80104f:	68 0c 25 80 00       	push   $0x80250c
  801054:	e8 07 f2 ff ff       	call   800260 <cprintf>
	*dev = 0;
  801059:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 10             	sub    $0x10,%esp
  801074:	8b 75 08             	mov    0x8(%ebp),%esi
  801077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80107a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801084:	c1 e8 0c             	shr    $0xc,%eax
  801087:	50                   	push   %eax
  801088:	e8 36 ff ff ff       	call   800fc3 <fd_lookup>
  80108d:	83 c4 08             	add    $0x8,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	78 05                	js     801099 <fd_close+0x2d>
	    || fd != fd2)
  801094:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801097:	74 0c                	je     8010a5 <fd_close+0x39>
		return (must_exist ? r : 0);
  801099:	84 db                	test   %bl,%bl
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	0f 44 c2             	cmove  %edx,%eax
  8010a3:	eb 41                	jmp    8010e6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	ff 36                	pushl  (%esi)
  8010ae:	e8 66 ff ff ff       	call   801019 <dev_lookup>
  8010b3:	89 c3                	mov    %eax,%ebx
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 1a                	js     8010d6 <fd_close+0x6a>
		if (dev->dev_close)
  8010bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	74 0b                	je     8010d6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	56                   	push   %esi
  8010cf:	ff d0                	call   *%eax
  8010d1:	89 c3                	mov    %eax,%ebx
  8010d3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	56                   	push   %esi
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 8c fb ff ff       	call   800c6d <sys_page_unmap>
	return r;
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	89 d8                	mov    %ebx,%eax
}
  8010e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	e8 c4 fe ff ff       	call   800fc3 <fd_lookup>
  8010ff:	83 c4 08             	add    $0x8,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	78 10                	js     801116 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801106:	83 ec 08             	sub    $0x8,%esp
  801109:	6a 01                	push   $0x1
  80110b:	ff 75 f4             	pushl  -0xc(%ebp)
  80110e:	e8 59 ff ff ff       	call   80106c <fd_close>
  801113:	83 c4 10             	add    $0x10,%esp
}
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <close_all>:

void
close_all(void)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	53                   	push   %ebx
  80111c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80111f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	53                   	push   %ebx
  801128:	e8 c0 ff ff ff       	call   8010ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80112d:	83 c3 01             	add    $0x1,%ebx
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	83 fb 20             	cmp    $0x20,%ebx
  801136:	75 ec                	jne    801124 <close_all+0xc>
		close(i);
}
  801138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113b:	c9                   	leave  
  80113c:	c3                   	ret    

0080113d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 2c             	sub    $0x2c,%esp
  801146:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801149:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	ff 75 08             	pushl  0x8(%ebp)
  801150:	e8 6e fe ff ff       	call   800fc3 <fd_lookup>
  801155:	83 c4 08             	add    $0x8,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	0f 88 c1 00 00 00    	js     801221 <dup+0xe4>
		return r;
	close(newfdnum);
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	56                   	push   %esi
  801164:	e8 84 ff ff ff       	call   8010ed <close>

	newfd = INDEX2FD(newfdnum);
  801169:	89 f3                	mov    %esi,%ebx
  80116b:	c1 e3 0c             	shl    $0xc,%ebx
  80116e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801174:	83 c4 04             	add    $0x4,%esp
  801177:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117a:	e8 de fd ff ff       	call   800f5d <fd2data>
  80117f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801181:	89 1c 24             	mov    %ebx,(%esp)
  801184:	e8 d4 fd ff ff       	call   800f5d <fd2data>
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80118f:	89 f8                	mov    %edi,%eax
  801191:	c1 e8 16             	shr    $0x16,%eax
  801194:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80119b:	a8 01                	test   $0x1,%al
  80119d:	74 37                	je     8011d6 <dup+0x99>
  80119f:	89 f8                	mov    %edi,%eax
  8011a1:	c1 e8 0c             	shr    $0xc,%eax
  8011a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ab:	f6 c2 01             	test   $0x1,%dl
  8011ae:	74 26                	je     8011d6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bf:	50                   	push   %eax
  8011c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011c3:	6a 00                	push   $0x0
  8011c5:	57                   	push   %edi
  8011c6:	6a 00                	push   $0x0
  8011c8:	e8 5e fa ff ff       	call   800c2b <sys_page_map>
  8011cd:	89 c7                	mov    %eax,%edi
  8011cf:	83 c4 20             	add    $0x20,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 2e                	js     801204 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011d9:	89 d0                	mov    %edx,%eax
  8011db:	c1 e8 0c             	shr    $0xc,%eax
  8011de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e5:	83 ec 0c             	sub    $0xc,%esp
  8011e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ed:	50                   	push   %eax
  8011ee:	53                   	push   %ebx
  8011ef:	6a 00                	push   $0x0
  8011f1:	52                   	push   %edx
  8011f2:	6a 00                	push   $0x0
  8011f4:	e8 32 fa ff ff       	call   800c2b <sys_page_map>
  8011f9:	89 c7                	mov    %eax,%edi
  8011fb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011fe:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801200:	85 ff                	test   %edi,%edi
  801202:	79 1d                	jns    801221 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	53                   	push   %ebx
  801208:	6a 00                	push   $0x0
  80120a:	e8 5e fa ff ff       	call   800c6d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80120f:	83 c4 08             	add    $0x8,%esp
  801212:	ff 75 d4             	pushl  -0x2c(%ebp)
  801215:	6a 00                	push   $0x0
  801217:	e8 51 fa ff ff       	call   800c6d <sys_page_unmap>
	return r;
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	89 f8                	mov    %edi,%eax
}
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	53                   	push   %ebx
  80122d:	83 ec 14             	sub    $0x14,%esp
  801230:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801233:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	53                   	push   %ebx
  801238:	e8 86 fd ff ff       	call   800fc3 <fd_lookup>
  80123d:	83 c4 08             	add    $0x8,%esp
  801240:	89 c2                	mov    %eax,%edx
  801242:	85 c0                	test   %eax,%eax
  801244:	78 6d                	js     8012b3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	ff 30                	pushl  (%eax)
  801252:	e8 c2 fd ff ff       	call   801019 <dev_lookup>
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 4c                	js     8012aa <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80125e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801261:	8b 42 08             	mov    0x8(%edx),%eax
  801264:	83 e0 03             	and    $0x3,%eax
  801267:	83 f8 01             	cmp    $0x1,%eax
  80126a:	75 21                	jne    80128d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80126c:	a1 04 40 80 00       	mov    0x804004,%eax
  801271:	8b 40 50             	mov    0x50(%eax),%eax
  801274:	83 ec 04             	sub    $0x4,%esp
  801277:	53                   	push   %ebx
  801278:	50                   	push   %eax
  801279:	68 4d 25 80 00       	push   $0x80254d
  80127e:	e8 dd ef ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80128b:	eb 26                	jmp    8012b3 <read+0x8a>
	}
	if (!dev->dev_read)
  80128d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801290:	8b 40 08             	mov    0x8(%eax),%eax
  801293:	85 c0                	test   %eax,%eax
  801295:	74 17                	je     8012ae <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	ff 75 10             	pushl  0x10(%ebp)
  80129d:	ff 75 0c             	pushl  0xc(%ebp)
  8012a0:	52                   	push   %edx
  8012a1:	ff d0                	call   *%eax
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	eb 09                	jmp    8012b3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	eb 05                	jmp    8012b3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8012b3:	89 d0                	mov    %edx,%eax
  8012b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	57                   	push   %edi
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ce:	eb 21                	jmp    8012f1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d0:	83 ec 04             	sub    $0x4,%esp
  8012d3:	89 f0                	mov    %esi,%eax
  8012d5:	29 d8                	sub    %ebx,%eax
  8012d7:	50                   	push   %eax
  8012d8:	89 d8                	mov    %ebx,%eax
  8012da:	03 45 0c             	add    0xc(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	57                   	push   %edi
  8012df:	e8 45 ff ff ff       	call   801229 <read>
		if (m < 0)
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 10                	js     8012fb <readn+0x41>
			return m;
		if (m == 0)
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	74 0a                	je     8012f9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ef:	01 c3                	add    %eax,%ebx
  8012f1:	39 f3                	cmp    %esi,%ebx
  8012f3:	72 db                	jb     8012d0 <readn+0x16>
  8012f5:	89 d8                	mov    %ebx,%eax
  8012f7:	eb 02                	jmp    8012fb <readn+0x41>
  8012f9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5f                   	pop    %edi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 14             	sub    $0x14,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	53                   	push   %ebx
  801312:	e8 ac fc ff ff       	call   800fc3 <fd_lookup>
  801317:	83 c4 08             	add    $0x8,%esp
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 68                	js     801388 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132a:	ff 30                	pushl  (%eax)
  80132c:	e8 e8 fc ff ff       	call   801019 <dev_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 47                	js     80137f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801338:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133f:	75 21                	jne    801362 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801341:	a1 04 40 80 00       	mov    0x804004,%eax
  801346:	8b 40 50             	mov    0x50(%eax),%eax
  801349:	83 ec 04             	sub    $0x4,%esp
  80134c:	53                   	push   %ebx
  80134d:	50                   	push   %eax
  80134e:	68 69 25 80 00       	push   $0x802569
  801353:	e8 08 ef ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801360:	eb 26                	jmp    801388 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801362:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801365:	8b 52 0c             	mov    0xc(%edx),%edx
  801368:	85 d2                	test   %edx,%edx
  80136a:	74 17                	je     801383 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80136c:	83 ec 04             	sub    $0x4,%esp
  80136f:	ff 75 10             	pushl  0x10(%ebp)
  801372:	ff 75 0c             	pushl  0xc(%ebp)
  801375:	50                   	push   %eax
  801376:	ff d2                	call   *%edx
  801378:	89 c2                	mov    %eax,%edx
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	eb 09                	jmp    801388 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137f:	89 c2                	mov    %eax,%edx
  801381:	eb 05                	jmp    801388 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801383:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801388:	89 d0                	mov    %edx,%eax
  80138a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <seek>:

int
seek(int fdnum, off_t offset)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801395:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	pushl  0x8(%ebp)
  80139c:	e8 22 fc ff ff       	call   800fc3 <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 0e                	js     8013b6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ae:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    

008013b8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	53                   	push   %ebx
  8013bc:	83 ec 14             	sub    $0x14,%esp
  8013bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	53                   	push   %ebx
  8013c7:	e8 f7 fb ff ff       	call   800fc3 <fd_lookup>
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	89 c2                	mov    %eax,%edx
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 65                	js     80143a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013df:	ff 30                	pushl  (%eax)
  8013e1:	e8 33 fc ff ff       	call   801019 <dev_lookup>
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 44                	js     801431 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013f4:	75 21                	jne    801417 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013f6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013fb:	8b 40 50             	mov    0x50(%eax),%eax
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	53                   	push   %ebx
  801402:	50                   	push   %eax
  801403:	68 2c 25 80 00       	push   $0x80252c
  801408:	e8 53 ee ff ff       	call   800260 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801415:	eb 23                	jmp    80143a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801417:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141a:	8b 52 18             	mov    0x18(%edx),%edx
  80141d:	85 d2                	test   %edx,%edx
  80141f:	74 14                	je     801435 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	ff 75 0c             	pushl  0xc(%ebp)
  801427:	50                   	push   %eax
  801428:	ff d2                	call   *%edx
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	eb 09                	jmp    80143a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801431:	89 c2                	mov    %eax,%edx
  801433:	eb 05                	jmp    80143a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801435:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80143a:	89 d0                	mov    %edx,%eax
  80143c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	53                   	push   %ebx
  801445:	83 ec 14             	sub    $0x14,%esp
  801448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	ff 75 08             	pushl  0x8(%ebp)
  801452:	e8 6c fb ff ff       	call   800fc3 <fd_lookup>
  801457:	83 c4 08             	add    $0x8,%esp
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 58                	js     8014b8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146a:	ff 30                	pushl  (%eax)
  80146c:	e8 a8 fb ff ff       	call   801019 <dev_lookup>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	78 37                	js     8014af <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80147f:	74 32                	je     8014b3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801481:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801484:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80148b:	00 00 00 
	stat->st_isdir = 0;
  80148e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801495:	00 00 00 
	stat->st_dev = dev;
  801498:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8014a5:	ff 50 14             	call   *0x14(%eax)
  8014a8:	89 c2                	mov    %eax,%edx
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	eb 09                	jmp    8014b8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	eb 05                	jmp    8014b8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014b8:	89 d0                	mov    %edx,%eax
  8014ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	6a 00                	push   $0x0
  8014c9:	ff 75 08             	pushl  0x8(%ebp)
  8014cc:	e8 e3 01 00 00       	call   8016b4 <open>
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 1b                	js     8014f5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	50                   	push   %eax
  8014e1:	e8 5b ff ff ff       	call   801441 <fstat>
  8014e6:	89 c6                	mov    %eax,%esi
	close(fd);
  8014e8:	89 1c 24             	mov    %ebx,(%esp)
  8014eb:	e8 fd fb ff ff       	call   8010ed <close>
	return r;
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	89 f0                	mov    %esi,%eax
}
  8014f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	89 c6                	mov    %eax,%esi
  801503:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801505:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80150c:	75 12                	jne    801520 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	6a 01                	push   $0x1
  801513:	e8 4c 09 00 00       	call   801e64 <ipc_find_env>
  801518:	a3 00 40 80 00       	mov    %eax,0x804000
  80151d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801520:	6a 07                	push   $0x7
  801522:	68 00 50 80 00       	push   $0x805000
  801527:	56                   	push   %esi
  801528:	ff 35 00 40 80 00    	pushl  0x804000
  80152e:	e8 cf 08 00 00       	call   801e02 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801533:	83 c4 0c             	add    $0xc,%esp
  801536:	6a 00                	push   $0x0
  801538:	53                   	push   %ebx
  801539:	6a 00                	push   $0x0
  80153b:	e8 4d 08 00 00       	call   801d8d <ipc_recv>
}
  801540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80154d:	8b 45 08             	mov    0x8(%ebp),%eax
  801550:	8b 40 0c             	mov    0xc(%eax),%eax
  801553:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
  801565:	b8 02 00 00 00       	mov    $0x2,%eax
  80156a:	e8 8d ff ff ff       	call   8014fc <fsipc>
}
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	8b 40 0c             	mov    0xc(%eax),%eax
  80157d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801582:	ba 00 00 00 00       	mov    $0x0,%edx
  801587:	b8 06 00 00 00       	mov    $0x6,%eax
  80158c:	e8 6b ff ff ff       	call   8014fc <fsipc>
}
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 04             	sub    $0x4,%esp
  80159a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80159d:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8015b2:	e8 45 ff ff ff       	call   8014fc <fsipc>
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 2c                	js     8015e7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	68 00 50 80 00       	push   $0x805000
  8015c3:	53                   	push   %ebx
  8015c4:	e8 1c f2 ff ff       	call   8007e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8015ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8015d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015fb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801601:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801606:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80160b:	0f 47 c2             	cmova  %edx,%eax
  80160e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801613:	50                   	push   %eax
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	68 08 50 80 00       	push   $0x805008
  80161c:	e8 56 f3 ff ff       	call   800977 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801621:	ba 00 00 00 00       	mov    $0x0,%edx
  801626:	b8 04 00 00 00       	mov    $0x4,%eax
  80162b:	e8 cc fe ff ff       	call   8014fc <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	8b 40 0c             	mov    0xc(%eax),%eax
  801640:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801645:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80164b:	ba 00 00 00 00       	mov    $0x0,%edx
  801650:	b8 03 00 00 00       	mov    $0x3,%eax
  801655:	e8 a2 fe ff ff       	call   8014fc <fsipc>
  80165a:	89 c3                	mov    %eax,%ebx
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 4b                	js     8016ab <devfile_read+0x79>
		return r;
	assert(r <= n);
  801660:	39 c6                	cmp    %eax,%esi
  801662:	73 16                	jae    80167a <devfile_read+0x48>
  801664:	68 98 25 80 00       	push   $0x802598
  801669:	68 9f 25 80 00       	push   $0x80259f
  80166e:	6a 7c                	push   $0x7c
  801670:	68 b4 25 80 00       	push   $0x8025b4
  801675:	e8 cd 06 00 00       	call   801d47 <_panic>
	assert(r <= PGSIZE);
  80167a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80167f:	7e 16                	jle    801697 <devfile_read+0x65>
  801681:	68 bf 25 80 00       	push   $0x8025bf
  801686:	68 9f 25 80 00       	push   $0x80259f
  80168b:	6a 7d                	push   $0x7d
  80168d:	68 b4 25 80 00       	push   $0x8025b4
  801692:	e8 b0 06 00 00       	call   801d47 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801697:	83 ec 04             	sub    $0x4,%esp
  80169a:	50                   	push   %eax
  80169b:	68 00 50 80 00       	push   $0x805000
  8016a0:	ff 75 0c             	pushl  0xc(%ebp)
  8016a3:	e8 cf f2 ff ff       	call   800977 <memmove>
	return r;
  8016a8:	83 c4 10             	add    $0x10,%esp
}
  8016ab:	89 d8                	mov    %ebx,%eax
  8016ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5e                   	pop    %esi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 20             	sub    $0x20,%esp
  8016bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016be:	53                   	push   %ebx
  8016bf:	e8 e8 f0 ff ff       	call   8007ac <strlen>
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016cc:	7f 67                	jg     801735 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016ce:	83 ec 0c             	sub    $0xc,%esp
  8016d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	e8 9a f8 ff ff       	call   800f74 <fd_alloc>
  8016da:	83 c4 10             	add    $0x10,%esp
		return r;
  8016dd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 57                	js     80173a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	68 00 50 80 00       	push   $0x805000
  8016ec:	e8 f4 f0 ff ff       	call   8007e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801701:	e8 f6 fd ff ff       	call   8014fc <fsipc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	79 14                	jns    801723 <open+0x6f>
		fd_close(fd, 0);
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	6a 00                	push   $0x0
  801714:	ff 75 f4             	pushl  -0xc(%ebp)
  801717:	e8 50 f9 ff ff       	call   80106c <fd_close>
		return r;
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	89 da                	mov    %ebx,%edx
  801721:	eb 17                	jmp    80173a <open+0x86>
	}

	return fd2num(fd);
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	ff 75 f4             	pushl  -0xc(%ebp)
  801729:	e8 1f f8 ff ff       	call   800f4d <fd2num>
  80172e:	89 c2                	mov    %eax,%edx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	eb 05                	jmp    80173a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801735:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80173a:	89 d0                	mov    %edx,%eax
  80173c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	b8 08 00 00 00       	mov    $0x8,%eax
  801751:	e8 a6 fd ff ff       	call   8014fc <fsipc>
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801758:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80175c:	7e 37                	jle    801795 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 08             	sub    $0x8,%esp
  801765:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801767:	ff 70 04             	pushl  0x4(%eax)
  80176a:	8d 40 10             	lea    0x10(%eax),%eax
  80176d:	50                   	push   %eax
  80176e:	ff 33                	pushl  (%ebx)
  801770:	e8 8e fb ff ff       	call   801303 <write>
		if (result > 0)
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	7e 03                	jle    80177f <writebuf+0x27>
			b->result += result;
  80177c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80177f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801782:	74 0d                	je     801791 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801784:	85 c0                	test   %eax,%eax
  801786:	ba 00 00 00 00       	mov    $0x0,%edx
  80178b:	0f 4f c2             	cmovg  %edx,%eax
  80178e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801794:	c9                   	leave  
  801795:	f3 c3                	repz ret 

00801797 <putch>:

static void
putch(int ch, void *thunk)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	53                   	push   %ebx
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017a1:	8b 53 04             	mov    0x4(%ebx),%edx
  8017a4:	8d 42 01             	lea    0x1(%edx),%eax
  8017a7:	89 43 04             	mov    %eax,0x4(%ebx)
  8017aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ad:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017b1:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017b6:	75 0e                	jne    8017c6 <putch+0x2f>
		writebuf(b);
  8017b8:	89 d8                	mov    %ebx,%eax
  8017ba:	e8 99 ff ff ff       	call   801758 <writebuf>
		b->idx = 0;
  8017bf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017c6:	83 c4 04             	add    $0x4,%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017de:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017e5:	00 00 00 
	b.result = 0;
  8017e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017ef:	00 00 00 
	b.error = 1;
  8017f2:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017f9:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017fc:	ff 75 10             	pushl  0x10(%ebp)
  8017ff:	ff 75 0c             	pushl  0xc(%ebp)
  801802:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801808:	50                   	push   %eax
  801809:	68 97 17 80 00       	push   $0x801797
  80180e:	e8 84 eb ff ff       	call   800397 <vprintfmt>
	if (b.idx > 0)
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80181d:	7e 0b                	jle    80182a <vfprintf+0x5e>
		writebuf(&b);
  80181f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801825:	e8 2e ff ff ff       	call   801758 <writebuf>

	return (b.result ? b.result : b.error);
  80182a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801830:	85 c0                	test   %eax,%eax
  801832:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801841:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801844:	50                   	push   %eax
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	ff 75 08             	pushl  0x8(%ebp)
  80184b:	e8 7c ff ff ff       	call   8017cc <vfprintf>
	va_end(ap);

	return cnt;
}
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <printf>:

int
printf(const char *fmt, ...)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801858:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80185b:	50                   	push   %eax
  80185c:	ff 75 08             	pushl  0x8(%ebp)
  80185f:	6a 01                	push   $0x1
  801861:	e8 66 ff ff ff       	call   8017cc <vfprintf>
	va_end(ap);

	return cnt;
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	e8 e2 f6 ff ff       	call   800f5d <fd2data>
  80187b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	68 cb 25 80 00       	push   $0x8025cb
  801885:	53                   	push   %ebx
  801886:	e8 5a ef ff ff       	call   8007e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80188b:	8b 46 04             	mov    0x4(%esi),%eax
  80188e:	2b 06                	sub    (%esi),%eax
  801890:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801896:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189d:	00 00 00 
	stat->st_dev = &devpipe;
  8018a0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018a7:	30 80 00 
	return 0;
}
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8018af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018c0:	53                   	push   %ebx
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 a5 f3 ff ff       	call   800c6d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018c8:	89 1c 24             	mov    %ebx,(%esp)
  8018cb:	e8 8d f6 ff ff       	call   800f5d <fd2data>
  8018d0:	83 c4 08             	add    $0x8,%esp
  8018d3:	50                   	push   %eax
  8018d4:	6a 00                	push   $0x0
  8018d6:	e8 92 f3 ff ff       	call   800c6d <sys_page_unmap>
}
  8018db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	57                   	push   %edi
  8018e4:	56                   	push   %esi
  8018e5:	53                   	push   %ebx
  8018e6:	83 ec 1c             	sub    $0x1c,%esp
  8018e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ec:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f3:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8018fc:	e8 a3 05 00 00       	call   801ea4 <pageref>
  801901:	89 c3                	mov    %eax,%ebx
  801903:	89 3c 24             	mov    %edi,(%esp)
  801906:	e8 99 05 00 00       	call   801ea4 <pageref>
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	39 c3                	cmp    %eax,%ebx
  801910:	0f 94 c1             	sete   %cl
  801913:	0f b6 c9             	movzbl %cl,%ecx
  801916:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801919:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80191f:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801922:	39 ce                	cmp    %ecx,%esi
  801924:	74 1b                	je     801941 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801926:	39 c3                	cmp    %eax,%ebx
  801928:	75 c4                	jne    8018ee <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80192a:	8b 42 60             	mov    0x60(%edx),%eax
  80192d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801930:	50                   	push   %eax
  801931:	56                   	push   %esi
  801932:	68 d2 25 80 00       	push   $0x8025d2
  801937:	e8 24 e9 ff ff       	call   800260 <cprintf>
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	eb ad                	jmp    8018ee <_pipeisclosed+0xe>
	}
}
  801941:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801944:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5f                   	pop    %edi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	57                   	push   %edi
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
  801952:	83 ec 28             	sub    $0x28,%esp
  801955:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801958:	56                   	push   %esi
  801959:	e8 ff f5 ff ff       	call   800f5d <fd2data>
  80195e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	bf 00 00 00 00       	mov    $0x0,%edi
  801968:	eb 4b                	jmp    8019b5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80196a:	89 da                	mov    %ebx,%edx
  80196c:	89 f0                	mov    %esi,%eax
  80196e:	e8 6d ff ff ff       	call   8018e0 <_pipeisclosed>
  801973:	85 c0                	test   %eax,%eax
  801975:	75 48                	jne    8019bf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801977:	e8 4d f2 ff ff       	call   800bc9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80197c:	8b 43 04             	mov    0x4(%ebx),%eax
  80197f:	8b 0b                	mov    (%ebx),%ecx
  801981:	8d 51 20             	lea    0x20(%ecx),%edx
  801984:	39 d0                	cmp    %edx,%eax
  801986:	73 e2                	jae    80196a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80198b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80198f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801992:	89 c2                	mov    %eax,%edx
  801994:	c1 fa 1f             	sar    $0x1f,%edx
  801997:	89 d1                	mov    %edx,%ecx
  801999:	c1 e9 1b             	shr    $0x1b,%ecx
  80199c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80199f:	83 e2 1f             	and    $0x1f,%edx
  8019a2:	29 ca                	sub    %ecx,%edx
  8019a4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ac:	83 c0 01             	add    $0x1,%eax
  8019af:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b2:	83 c7 01             	add    $0x1,%edi
  8019b5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019b8:	75 c2                	jne    80197c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bd:	eb 05                	jmp    8019c4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5f                   	pop    %edi
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	57                   	push   %edi
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 18             	sub    $0x18,%esp
  8019d5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019d8:	57                   	push   %edi
  8019d9:	e8 7f f5 ff ff       	call   800f5d <fd2data>
  8019de:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e8:	eb 3d                	jmp    801a27 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ea:	85 db                	test   %ebx,%ebx
  8019ec:	74 04                	je     8019f2 <devpipe_read+0x26>
				return i;
  8019ee:	89 d8                	mov    %ebx,%eax
  8019f0:	eb 44                	jmp    801a36 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019f2:	89 f2                	mov    %esi,%edx
  8019f4:	89 f8                	mov    %edi,%eax
  8019f6:	e8 e5 fe ff ff       	call   8018e0 <_pipeisclosed>
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	75 32                	jne    801a31 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019ff:	e8 c5 f1 ff ff       	call   800bc9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a04:	8b 06                	mov    (%esi),%eax
  801a06:	3b 46 04             	cmp    0x4(%esi),%eax
  801a09:	74 df                	je     8019ea <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a0b:	99                   	cltd   
  801a0c:	c1 ea 1b             	shr    $0x1b,%edx
  801a0f:	01 d0                	add    %edx,%eax
  801a11:	83 e0 1f             	and    $0x1f,%eax
  801a14:	29 d0                	sub    %edx,%eax
  801a16:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a21:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a24:	83 c3 01             	add    $0x1,%ebx
  801a27:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a2a:	75 d8                	jne    801a04 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2f:	eb 05                	jmp    801a36 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a31:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5f                   	pop    %edi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 25 f5 ff ff       	call   800f74 <fd_alloc>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	89 c2                	mov    %eax,%edx
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 2c 01 00 00    	js     801b88 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5c:	83 ec 04             	sub    $0x4,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	ff 75 f4             	pushl  -0xc(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 7a f1 ff ff       	call   800be8 <sys_page_alloc>
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	89 c2                	mov    %eax,%edx
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 88 0d 01 00 00    	js     801b88 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a81:	50                   	push   %eax
  801a82:	e8 ed f4 ff ff       	call   800f74 <fd_alloc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	0f 88 e2 00 00 00    	js     801b76 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	68 07 04 00 00       	push   $0x407
  801a9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 42 f1 ff ff       	call   800be8 <sys_page_alloc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	85 c0                	test   %eax,%eax
  801aad:	0f 88 c3 00 00 00    	js     801b76 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab9:	e8 9f f4 ff ff       	call   800f5d <fd2data>
  801abe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac0:	83 c4 0c             	add    $0xc,%esp
  801ac3:	68 07 04 00 00       	push   $0x407
  801ac8:	50                   	push   %eax
  801ac9:	6a 00                	push   $0x0
  801acb:	e8 18 f1 ff ff       	call   800be8 <sys_page_alloc>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	0f 88 89 00 00 00    	js     801b66 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae3:	e8 75 f4 ff ff       	call   800f5d <fd2data>
  801ae8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aef:	50                   	push   %eax
  801af0:	6a 00                	push   $0x0
  801af2:	56                   	push   %esi
  801af3:	6a 00                	push   $0x0
  801af5:	e8 31 f1 ff ff       	call   800c2b <sys_page_map>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 20             	add    $0x20,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 55                	js     801b58 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b21:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b26:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	ff 75 f4             	pushl  -0xc(%ebp)
  801b33:	e8 15 f4 ff ff       	call   800f4d <fd2num>
  801b38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b3d:	83 c4 04             	add    $0x4,%esp
  801b40:	ff 75 f0             	pushl  -0x10(%ebp)
  801b43:	e8 05 f4 ff ff       	call   800f4d <fd2num>
  801b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	ba 00 00 00 00       	mov    $0x0,%edx
  801b56:	eb 30                	jmp    801b88 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	56                   	push   %esi
  801b5c:	6a 00                	push   $0x0
  801b5e:	e8 0a f1 ff ff       	call   800c6d <sys_page_unmap>
  801b63:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b66:	83 ec 08             	sub    $0x8,%esp
  801b69:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6c:	6a 00                	push   $0x0
  801b6e:	e8 fa f0 ff ff       	call   800c6d <sys_page_unmap>
  801b73:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b76:	83 ec 08             	sub    $0x8,%esp
  801b79:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7c:	6a 00                	push   $0x0
  801b7e:	e8 ea f0 ff ff       	call   800c6d <sys_page_unmap>
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b88:	89 d0                	mov    %edx,%eax
  801b8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9a:	50                   	push   %eax
  801b9b:	ff 75 08             	pushl  0x8(%ebp)
  801b9e:	e8 20 f4 ff ff       	call   800fc3 <fd_lookup>
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 18                	js     801bc2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb0:	e8 a8 f3 ff ff       	call   800f5d <fd2data>
	return _pipeisclosed(fd, p);
  801bb5:	89 c2                	mov    %eax,%edx
  801bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bba:	e8 21 fd ff ff       	call   8018e0 <_pipeisclosed>
  801bbf:	83 c4 10             	add    $0x10,%esp
}
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bd4:	68 ea 25 80 00       	push   $0x8025ea
  801bd9:	ff 75 0c             	pushl  0xc(%ebp)
  801bdc:	e8 04 ec ff ff       	call   8007e5 <strcpy>
	return 0;
}
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	57                   	push   %edi
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bf9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bff:	eb 2d                	jmp    801c2e <devcons_write+0x46>
		m = n - tot;
  801c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c04:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c06:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c09:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c0e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	53                   	push   %ebx
  801c15:	03 45 0c             	add    0xc(%ebp),%eax
  801c18:	50                   	push   %eax
  801c19:	57                   	push   %edi
  801c1a:	e8 58 ed ff ff       	call   800977 <memmove>
		sys_cputs(buf, m);
  801c1f:	83 c4 08             	add    $0x8,%esp
  801c22:	53                   	push   %ebx
  801c23:	57                   	push   %edi
  801c24:	e8 03 ef ff ff       	call   800b2c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c29:	01 de                	add    %ebx,%esi
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	89 f0                	mov    %esi,%eax
  801c30:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c33:	72 cc                	jb     801c01 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5f                   	pop    %edi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 08             	sub    $0x8,%esp
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c4c:	74 2a                	je     801c78 <devcons_read+0x3b>
  801c4e:	eb 05                	jmp    801c55 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c50:	e8 74 ef ff ff       	call   800bc9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c55:	e8 f0 ee ff ff       	call   800b4a <sys_cgetc>
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	74 f2                	je     801c50 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	78 16                	js     801c78 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c62:	83 f8 04             	cmp    $0x4,%eax
  801c65:	74 0c                	je     801c73 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6a:	88 02                	mov    %al,(%edx)
	return 1;
  801c6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c71:	eb 05                	jmp    801c78 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c86:	6a 01                	push   $0x1
  801c88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c8b:	50                   	push   %eax
  801c8c:	e8 9b ee ff ff       	call   800b2c <sys_cputs>
}
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <getchar>:

int
getchar(void)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c9c:	6a 01                	push   $0x1
  801c9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca1:	50                   	push   %eax
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 80 f5 ff ff       	call   801229 <read>
	if (r < 0)
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 0f                	js     801cbf <getchar+0x29>
		return r;
	if (r < 1)
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	7e 06                	jle    801cba <getchar+0x24>
		return -E_EOF;
	return c;
  801cb4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cb8:	eb 05                	jmp    801cbf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cba:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cca:	50                   	push   %eax
  801ccb:	ff 75 08             	pushl  0x8(%ebp)
  801cce:	e8 f0 f2 ff ff       	call   800fc3 <fd_lookup>
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 11                	js     801ceb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce3:	39 10                	cmp    %edx,(%eax)
  801ce5:	0f 94 c0             	sete   %al
  801ce8:	0f b6 c0             	movzbl %al,%eax
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <opencons>:

int
opencons(void)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf6:	50                   	push   %eax
  801cf7:	e8 78 f2 ff ff       	call   800f74 <fd_alloc>
  801cfc:	83 c4 10             	add    $0x10,%esp
		return r;
  801cff:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 3e                	js     801d43 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	68 07 04 00 00       	push   $0x407
  801d0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 d1 ee ff ff       	call   800be8 <sys_page_alloc>
  801d17:	83 c4 10             	add    $0x10,%esp
		return r;
  801d1a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	78 23                	js     801d43 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d20:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d29:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d35:	83 ec 0c             	sub    $0xc,%esp
  801d38:	50                   	push   %eax
  801d39:	e8 0f f2 ff ff       	call   800f4d <fd2num>
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	83 c4 10             	add    $0x10,%esp
}
  801d43:	89 d0                	mov    %edx,%eax
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d4c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d4f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d55:	e8 50 ee ff ff       	call   800baa <sys_getenvid>
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	ff 75 0c             	pushl  0xc(%ebp)
  801d60:	ff 75 08             	pushl  0x8(%ebp)
  801d63:	56                   	push   %esi
  801d64:	50                   	push   %eax
  801d65:	68 f8 25 80 00       	push   $0x8025f8
  801d6a:	e8 f1 e4 ff ff       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d6f:	83 c4 18             	add    $0x18,%esp
  801d72:	53                   	push   %ebx
  801d73:	ff 75 10             	pushl  0x10(%ebp)
  801d76:	e8 94 e4 ff ff       	call   80020f <vcprintf>
	cprintf("\n");
  801d7b:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  801d82:	e8 d9 e4 ff ff       	call   800260 <cprintf>
  801d87:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d8a:	cc                   	int3   
  801d8b:	eb fd                	jmp    801d8a <_panic+0x43>

00801d8d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	8b 75 08             	mov    0x8(%ebp),%esi
  801d95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	75 12                	jne    801db1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	68 00 00 c0 ee       	push   $0xeec00000
  801da7:	e8 ec ef ff ff       	call   800d98 <sys_ipc_recv>
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	eb 0c                	jmp    801dbd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801db1:	83 ec 0c             	sub    $0xc,%esp
  801db4:	50                   	push   %eax
  801db5:	e8 de ef ff ff       	call   800d98 <sys_ipc_recv>
  801dba:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801dbd:	85 f6                	test   %esi,%esi
  801dbf:	0f 95 c1             	setne  %cl
  801dc2:	85 db                	test   %ebx,%ebx
  801dc4:	0f 95 c2             	setne  %dl
  801dc7:	84 d1                	test   %dl,%cl
  801dc9:	74 09                	je     801dd4 <ipc_recv+0x47>
  801dcb:	89 c2                	mov    %eax,%edx
  801dcd:	c1 ea 1f             	shr    $0x1f,%edx
  801dd0:	84 d2                	test   %dl,%dl
  801dd2:	75 27                	jne    801dfb <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801dd4:	85 f6                	test   %esi,%esi
  801dd6:	74 0a                	je     801de2 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801dd8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ddd:	8b 40 7c             	mov    0x7c(%eax),%eax
  801de0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801de2:	85 db                	test   %ebx,%ebx
  801de4:	74 0d                	je     801df3 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801de6:	a1 04 40 80 00       	mov    0x804004,%eax
  801deb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801df1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801df3:	a1 04 40 80 00       	mov    0x804004,%eax
  801df8:	8b 40 78             	mov    0x78(%eax),%eax
}
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	83 ec 0c             	sub    $0xc,%esp
  801e0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e14:	85 db                	test   %ebx,%ebx
  801e16:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e1b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e1e:	ff 75 14             	pushl  0x14(%ebp)
  801e21:	53                   	push   %ebx
  801e22:	56                   	push   %esi
  801e23:	57                   	push   %edi
  801e24:	e8 4c ef ff ff       	call   800d75 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e29:	89 c2                	mov    %eax,%edx
  801e2b:	c1 ea 1f             	shr    $0x1f,%edx
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	84 d2                	test   %dl,%dl
  801e33:	74 17                	je     801e4c <ipc_send+0x4a>
  801e35:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e38:	74 12                	je     801e4c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e3a:	50                   	push   %eax
  801e3b:	68 1c 26 80 00       	push   $0x80261c
  801e40:	6a 47                	push   $0x47
  801e42:	68 2a 26 80 00       	push   $0x80262a
  801e47:	e8 fb fe ff ff       	call   801d47 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e4c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e4f:	75 07                	jne    801e58 <ipc_send+0x56>
			sys_yield();
  801e51:	e8 73 ed ff ff       	call   800bc9 <sys_yield>
  801e56:	eb c6                	jmp    801e1e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	75 c2                	jne    801e1e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5f:	5b                   	pop    %ebx
  801e60:	5e                   	pop    %esi
  801e61:	5f                   	pop    %edi
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    

00801e64 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e6a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e6f:	89 c2                	mov    %eax,%edx
  801e71:	c1 e2 07             	shl    $0x7,%edx
  801e74:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801e7b:	8b 52 58             	mov    0x58(%edx),%edx
  801e7e:	39 ca                	cmp    %ecx,%edx
  801e80:	75 11                	jne    801e93 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801e82:	89 c2                	mov    %eax,%edx
  801e84:	c1 e2 07             	shl    $0x7,%edx
  801e87:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801e8e:	8b 40 50             	mov    0x50(%eax),%eax
  801e91:	eb 0f                	jmp    801ea2 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e93:	83 c0 01             	add    $0x1,%eax
  801e96:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e9b:	75 d2                	jne    801e6f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eaa:	89 d0                	mov    %edx,%eax
  801eac:	c1 e8 16             	shr    $0x16,%eax
  801eaf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eb6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ebb:	f6 c1 01             	test   $0x1,%cl
  801ebe:	74 1d                	je     801edd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ec0:	c1 ea 0c             	shr    $0xc,%edx
  801ec3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801eca:	f6 c2 01             	test   $0x1,%dl
  801ecd:	74 0e                	je     801edd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ecf:	c1 ea 0c             	shr    $0xc,%edx
  801ed2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ed9:	ef 
  801eda:	0f b7 c0             	movzwl %ax,%eax
}
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    
  801edf:	90                   	nop

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
  801ee7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801eeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801eef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efd:	89 ca                	mov    %ecx,%edx
  801eff:	89 f8                	mov    %edi,%eax
  801f01:	75 3d                	jne    801f40 <__udivdi3+0x60>
  801f03:	39 cf                	cmp    %ecx,%edi
  801f05:	0f 87 c5 00 00 00    	ja     801fd0 <__udivdi3+0xf0>
  801f0b:	85 ff                	test   %edi,%edi
  801f0d:	89 fd                	mov    %edi,%ebp
  801f0f:	75 0b                	jne    801f1c <__udivdi3+0x3c>
  801f11:	b8 01 00 00 00       	mov    $0x1,%eax
  801f16:	31 d2                	xor    %edx,%edx
  801f18:	f7 f7                	div    %edi
  801f1a:	89 c5                	mov    %eax,%ebp
  801f1c:	89 c8                	mov    %ecx,%eax
  801f1e:	31 d2                	xor    %edx,%edx
  801f20:	f7 f5                	div    %ebp
  801f22:	89 c1                	mov    %eax,%ecx
  801f24:	89 d8                	mov    %ebx,%eax
  801f26:	89 cf                	mov    %ecx,%edi
  801f28:	f7 f5                	div    %ebp
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	39 ce                	cmp    %ecx,%esi
  801f42:	77 74                	ja     801fb8 <__udivdi3+0xd8>
  801f44:	0f bd fe             	bsr    %esi,%edi
  801f47:	83 f7 1f             	xor    $0x1f,%edi
  801f4a:	0f 84 98 00 00 00    	je     801fe8 <__udivdi3+0x108>
  801f50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	89 c5                	mov    %eax,%ebp
  801f59:	29 fb                	sub    %edi,%ebx
  801f5b:	d3 e6                	shl    %cl,%esi
  801f5d:	89 d9                	mov    %ebx,%ecx
  801f5f:	d3 ed                	shr    %cl,%ebp
  801f61:	89 f9                	mov    %edi,%ecx
  801f63:	d3 e0                	shl    %cl,%eax
  801f65:	09 ee                	or     %ebp,%esi
  801f67:	89 d9                	mov    %ebx,%ecx
  801f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6d:	89 d5                	mov    %edx,%ebp
  801f6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f73:	d3 ed                	shr    %cl,%ebp
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	d3 e2                	shl    %cl,%edx
  801f79:	89 d9                	mov    %ebx,%ecx
  801f7b:	d3 e8                	shr    %cl,%eax
  801f7d:	09 c2                	or     %eax,%edx
  801f7f:	89 d0                	mov    %edx,%eax
  801f81:	89 ea                	mov    %ebp,%edx
  801f83:	f7 f6                	div    %esi
  801f85:	89 d5                	mov    %edx,%ebp
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	f7 64 24 0c          	mull   0xc(%esp)
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	72 10                	jb     801fa1 <__udivdi3+0xc1>
  801f91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e6                	shl    %cl,%esi
  801f99:	39 c6                	cmp    %eax,%esi
  801f9b:	73 07                	jae    801fa4 <__udivdi3+0xc4>
  801f9d:	39 d5                	cmp    %edx,%ebp
  801f9f:	75 03                	jne    801fa4 <__udivdi3+0xc4>
  801fa1:	83 eb 01             	sub    $0x1,%ebx
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 d8                	mov    %ebx,%eax
  801fa8:	89 fa                	mov    %edi,%edx
  801faa:	83 c4 1c             	add    $0x1c,%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	31 db                	xor    %ebx,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	89 d8                	mov    %ebx,%eax
  801fd2:	f7 f7                	div    %edi
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 c3                	mov    %eax,%ebx
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	89 fa                	mov    %edi,%edx
  801fdc:	83 c4 1c             	add    $0x1c,%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	39 ce                	cmp    %ecx,%esi
  801fea:	72 0c                	jb     801ff8 <__udivdi3+0x118>
  801fec:	31 db                	xor    %ebx,%ebx
  801fee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ff2:	0f 87 34 ff ff ff    	ja     801f2c <__udivdi3+0x4c>
  801ff8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ffd:	e9 2a ff ff ff       	jmp    801f2c <__udivdi3+0x4c>
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80201b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80201f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 d2                	test   %edx,%edx
  802029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f3                	mov    %esi,%ebx
  802033:	89 3c 24             	mov    %edi,(%esp)
  802036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203a:	75 1c                	jne    802058 <__umoddi3+0x48>
  80203c:	39 f7                	cmp    %esi,%edi
  80203e:	76 50                	jbe    802090 <__umoddi3+0x80>
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	f7 f7                	div    %edi
  802046:	89 d0                	mov    %edx,%eax
  802048:	31 d2                	xor    %edx,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	77 52                	ja     8020b0 <__umoddi3+0xa0>
  80205e:	0f bd ea             	bsr    %edx,%ebp
  802061:	83 f5 1f             	xor    $0x1f,%ebp
  802064:	75 5a                	jne    8020c0 <__umoddi3+0xb0>
  802066:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80206a:	0f 82 e0 00 00 00    	jb     802150 <__umoddi3+0x140>
  802070:	39 0c 24             	cmp    %ecx,(%esp)
  802073:	0f 86 d7 00 00 00    	jbe    802150 <__umoddi3+0x140>
  802079:	8b 44 24 08          	mov    0x8(%esp),%eax
  80207d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	85 ff                	test   %edi,%edi
  802092:	89 fd                	mov    %edi,%ebp
  802094:	75 0b                	jne    8020a1 <__umoddi3+0x91>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f7                	div    %edi
  80209f:	89 c5                	mov    %eax,%ebp
  8020a1:	89 f0                	mov    %esi,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  8020a5:	f7 f5                	div    %ebp
  8020a7:	89 c8                	mov    %ecx,%eax
  8020a9:	f7 f5                	div    %ebp
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	eb 99                	jmp    802048 <__umoddi3+0x38>
  8020af:	90                   	nop
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	83 c4 1c             	add    $0x1c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	8b 34 24             	mov    (%esp),%esi
  8020c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	29 ef                	sub    %ebp,%edi
  8020cc:	d3 e0                	shl    %cl,%eax
  8020ce:	89 f9                	mov    %edi,%ecx
  8020d0:	89 f2                	mov    %esi,%edx
  8020d2:	d3 ea                	shr    %cl,%edx
  8020d4:	89 e9                	mov    %ebp,%ecx
  8020d6:	09 c2                	or     %eax,%edx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 14 24             	mov    %edx,(%esp)
  8020dd:	89 f2                	mov    %esi,%edx
  8020df:	d3 e2                	shl    %cl,%edx
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	89 e9                	mov    %ebp,%ecx
  8020ef:	89 c6                	mov    %eax,%esi
  8020f1:	d3 e3                	shl    %cl,%ebx
  8020f3:	89 f9                	mov    %edi,%ecx
  8020f5:	89 d0                	mov    %edx,%eax
  8020f7:	d3 e8                	shr    %cl,%eax
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	09 d8                	or     %ebx,%eax
  8020fd:	89 d3                	mov    %edx,%ebx
  8020ff:	89 f2                	mov    %esi,%edx
  802101:	f7 34 24             	divl   (%esp)
  802104:	89 d6                	mov    %edx,%esi
  802106:	d3 e3                	shl    %cl,%ebx
  802108:	f7 64 24 04          	mull   0x4(%esp)
  80210c:	39 d6                	cmp    %edx,%esi
  80210e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802112:	89 d1                	mov    %edx,%ecx
  802114:	89 c3                	mov    %eax,%ebx
  802116:	72 08                	jb     802120 <__umoddi3+0x110>
  802118:	75 11                	jne    80212b <__umoddi3+0x11b>
  80211a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80211e:	73 0b                	jae    80212b <__umoddi3+0x11b>
  802120:	2b 44 24 04          	sub    0x4(%esp),%eax
  802124:	1b 14 24             	sbb    (%esp),%edx
  802127:	89 d1                	mov    %edx,%ecx
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80212f:	29 da                	sub    %ebx,%edx
  802131:	19 ce                	sbb    %ecx,%esi
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 f0                	mov    %esi,%eax
  802137:	d3 e0                	shl    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	d3 ea                	shr    %cl,%edx
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	d3 ee                	shr    %cl,%esi
  802141:	09 d0                	or     %edx,%eax
  802143:	89 f2                	mov    %esi,%edx
  802145:	83 c4 1c             	add    $0x1c,%esp
  802148:	5b                   	pop    %ebx
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	29 f9                	sub    %edi,%ecx
  802152:	19 d6                	sbb    %edx,%esi
  802154:	89 74 24 04          	mov    %esi,0x4(%esp)
  802158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80215c:	e9 18 ff ff ff       	jmp    802079 <__umoddi3+0x69>
