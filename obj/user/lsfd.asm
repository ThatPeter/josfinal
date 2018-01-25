
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
  800039:	68 e0 24 80 00       	push   $0x8024e0
  80003e:	e8 e1 01 00 00       	call   800224 <cprintf>
	exit();
  800043:	e8 2f 01 00 00       	call   800177 <exit>
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
  800067:	e8 63 10 00 00       	call   8010cf <argstart>
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
  800091:	e8 69 10 00 00       	call   8010ff <argnext>
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
  8000ad:	e8 65 16 00 00       	call   801717 <fstat>
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
  8000ce:	68 f4 24 80 00       	push   $0x8024f4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 37 1a 00 00       	call   801b11 <fprintf>
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
  8000f0:	68 f4 24 80 00       	push   $0x8024f4
  8000f5:	e8 2a 01 00 00       	call   800224 <cprintf>
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
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800118:	e8 51 0a 00 00       	call   800b6e <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	89 c2                	mov    %eax,%edx
  800124:	c1 e2 07             	shl    $0x7,%edx
  800127:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80012e:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800133:	85 db                	test   %ebx,%ebx
  800135:	7e 07                	jle    80013e <libmain+0x31>
		binaryname = argv[0];
  800137:	8b 06                	mov    (%esi),%eax
  800139:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013e:	83 ec 08             	sub    $0x8,%esp
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
  800143:	e8 05 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800148:	e8 2a 00 00 00       	call   800177 <exit>
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80015d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800162:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800164:	e8 05 0a 00 00       	call   800b6e <sys_getenvid>
  800169:	83 ec 0c             	sub    $0xc,%esp
  80016c:	50                   	push   %eax
  80016d:	e8 4b 0c 00 00       	call   800dbd <sys_thread_free>
}
  800172:	83 c4 10             	add    $0x10,%esp
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017d:	e8 6c 12 00 00       	call   8013ee <close_all>
	sys_env_destroy(0);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	6a 00                	push   $0x0
  800187:	e8 a1 09 00 00       	call   800b2d <sys_env_destroy>
}
  80018c:	83 c4 10             	add    $0x10,%esp
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	53                   	push   %ebx
  800195:	83 ec 04             	sub    $0x4,%esp
  800198:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019b:	8b 13                	mov    (%ebx),%edx
  80019d:	8d 42 01             	lea    0x1(%edx),%eax
  8001a0:	89 03                	mov    %eax,(%ebx)
  8001a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ae:	75 1a                	jne    8001ca <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	68 ff 00 00 00       	push   $0xff
  8001b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bb:	50                   	push   %eax
  8001bc:	e8 2f 09 00 00       	call   800af0 <sys_cputs>
		b->idx = 0;
  8001c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e3:	00 00 00 
	b.cnt = 0;
  8001e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	68 91 01 80 00       	push   $0x800191
  800202:	e8 54 01 00 00       	call   80035b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800207:	83 c4 08             	add    $0x8,%esp
  80020a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800210:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800216:	50                   	push   %eax
  800217:	e8 d4 08 00 00       	call   800af0 <sys_cputs>

	return b.cnt;
}
  80021c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022d:	50                   	push   %eax
  80022e:	ff 75 08             	pushl  0x8(%ebp)
  800231:	e8 9d ff ff ff       	call   8001d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 1c             	sub    $0x1c,%esp
  800241:	89 c7                	mov    %eax,%edi
  800243:	89 d6                	mov    %edx,%esi
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800251:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025f:	39 d3                	cmp    %edx,%ebx
  800261:	72 05                	jb     800268 <printnum+0x30>
  800263:	39 45 10             	cmp    %eax,0x10(%ebp)
  800266:	77 45                	ja     8002ad <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	ff 75 18             	pushl  0x18(%ebp)
  80026e:	8b 45 14             	mov    0x14(%ebp),%eax
  800271:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800274:	53                   	push   %ebx
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027e:	ff 75 e0             	pushl  -0x20(%ebp)
  800281:	ff 75 dc             	pushl  -0x24(%ebp)
  800284:	ff 75 d8             	pushl  -0x28(%ebp)
  800287:	e8 c4 1f 00 00       	call   802250 <__udivdi3>
  80028c:	83 c4 18             	add    $0x18,%esp
  80028f:	52                   	push   %edx
  800290:	50                   	push   %eax
  800291:	89 f2                	mov    %esi,%edx
  800293:	89 f8                	mov    %edi,%eax
  800295:	e8 9e ff ff ff       	call   800238 <printnum>
  80029a:	83 c4 20             	add    $0x20,%esp
  80029d:	eb 18                	jmp    8002b7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	56                   	push   %esi
  8002a3:	ff 75 18             	pushl  0x18(%ebp)
  8002a6:	ff d7                	call   *%edi
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	eb 03                	jmp    8002b0 <printnum+0x78>
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b0:	83 eb 01             	sub    $0x1,%ebx
  8002b3:	85 db                	test   %ebx,%ebx
  8002b5:	7f e8                	jg     80029f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	56                   	push   %esi
  8002bb:	83 ec 04             	sub    $0x4,%esp
  8002be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ca:	e8 b1 20 00 00       	call   802380 <__umoddi3>
  8002cf:	83 c4 14             	add    $0x14,%esp
  8002d2:	0f be 80 26 25 80 00 	movsbl 0x802526(%eax),%eax
  8002d9:	50                   	push   %eax
  8002da:	ff d7                	call   *%edi
}
  8002dc:	83 c4 10             	add    $0x10,%esp
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ea:	83 fa 01             	cmp    $0x1,%edx
  8002ed:	7e 0e                	jle    8002fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	8b 52 04             	mov    0x4(%edx),%edx
  8002fb:	eb 22                	jmp    80031f <getuint+0x38>
	else if (lflag)
  8002fd:	85 d2                	test   %edx,%edx
  8002ff:	74 10                	je     800311 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 04             	lea    0x4(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	eb 0e                	jmp    80031f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800311:	8b 10                	mov    (%eax),%edx
  800313:	8d 4a 04             	lea    0x4(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 02                	mov    (%edx),%eax
  80031a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800327:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	3b 50 04             	cmp    0x4(%eax),%edx
  800330:	73 0a                	jae    80033c <sprintputch+0x1b>
		*b->buf++ = ch;
  800332:	8d 4a 01             	lea    0x1(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	88 02                	mov    %al,(%edx)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	50                   	push   %eax
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	ff 75 0c             	pushl  0xc(%ebp)
  80034e:	ff 75 08             	pushl  0x8(%ebp)
  800351:	e8 05 00 00 00       	call   80035b <vprintfmt>
	va_end(ap);
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	c9                   	leave  
  80035a:	c3                   	ret    

0080035b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
  800361:	83 ec 2c             	sub    $0x2c,%esp
  800364:	8b 75 08             	mov    0x8(%ebp),%esi
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036d:	eb 12                	jmp    800381 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036f:	85 c0                	test   %eax,%eax
  800371:	0f 84 89 03 00 00    	je     800700 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	53                   	push   %ebx
  80037b:	50                   	push   %eax
  80037c:	ff d6                	call   *%esi
  80037e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	83 c7 01             	add    $0x1,%edi
  800384:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800388:	83 f8 25             	cmp    $0x25,%eax
  80038b:	75 e2                	jne    80036f <vprintfmt+0x14>
  80038d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800391:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800398:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ab:	eb 07                	jmp    8003b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8d 47 01             	lea    0x1(%edi),%eax
  8003b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ba:	0f b6 07             	movzbl (%edi),%eax
  8003bd:	0f b6 c8             	movzbl %al,%ecx
  8003c0:	83 e8 23             	sub    $0x23,%eax
  8003c3:	3c 55                	cmp    $0x55,%al
  8003c5:	0f 87 1a 03 00 00    	ja     8006e5 <vprintfmt+0x38a>
  8003cb:	0f b6 c0             	movzbl %al,%eax
  8003ce:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003dc:	eb d6                	jmp    8003b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ec:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f6:	83 fa 09             	cmp    $0x9,%edx
  8003f9:	77 39                	ja     800434 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fe:	eb e9                	jmp    8003e9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 48 04             	lea    0x4(%eax),%ecx
  800406:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800411:	eb 27                	jmp    80043a <vprintfmt+0xdf>
  800413:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800416:	85 c0                	test   %eax,%eax
  800418:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041d:	0f 49 c8             	cmovns %eax,%ecx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800426:	eb 8c                	jmp    8003b4 <vprintfmt+0x59>
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800432:	eb 80                	jmp    8003b4 <vprintfmt+0x59>
  800434:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800437:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043e:	0f 89 70 ff ff ff    	jns    8003b4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800444:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800451:	e9 5e ff ff ff       	jmp    8003b4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800456:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045c:	e9 53 ff ff ff       	jmp    8003b4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 30                	pushl  (%eax)
  800470:	ff d6                	call   *%esi
			break;
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800478:	e9 04 ff ff ff       	jmp    800381 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 00                	mov    (%eax),%eax
  800488:	99                   	cltd   
  800489:	31 d0                	xor    %edx,%eax
  80048b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048d:	83 f8 0f             	cmp    $0xf,%eax
  800490:	7f 0b                	jg     80049d <vprintfmt+0x142>
  800492:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800499:	85 d2                	test   %edx,%edx
  80049b:	75 18                	jne    8004b5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049d:	50                   	push   %eax
  80049e:	68 3e 25 80 00       	push   $0x80253e
  8004a3:	53                   	push   %ebx
  8004a4:	56                   	push   %esi
  8004a5:	e8 94 fe ff ff       	call   80033e <printfmt>
  8004aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b0:	e9 cc fe ff ff       	jmp    800381 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b5:	52                   	push   %edx
  8004b6:	68 6d 29 80 00       	push   $0x80296d
  8004bb:	53                   	push   %ebx
  8004bc:	56                   	push   %esi
  8004bd:	e8 7c fe ff ff       	call   80033e <printfmt>
  8004c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c8:	e9 b4 fe ff ff       	jmp    800381 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	b8 37 25 80 00       	mov    $0x802537,%eax
  8004df:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e6:	0f 8e 94 00 00 00    	jle    800580 <vprintfmt+0x225>
  8004ec:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f0:	0f 84 98 00 00 00    	je     80058e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fc:	57                   	push   %edi
  8004fd:	e8 86 02 00 00       	call   800788 <strnlen>
  800502:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800505:	29 c1                	sub    %eax,%ecx
  800507:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800511:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800514:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800517:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	eb 0f                	jmp    80052a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	ff 75 e0             	pushl  -0x20(%ebp)
  800522:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 ef 01             	sub    $0x1,%edi
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	85 ff                	test   %edi,%edi
  80052c:	7f ed                	jg     80051b <vprintfmt+0x1c0>
  80052e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800531:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800534:	85 c9                	test   %ecx,%ecx
  800536:	b8 00 00 00 00       	mov    $0x0,%eax
  80053b:	0f 49 c1             	cmovns %ecx,%eax
  80053e:	29 c1                	sub    %eax,%ecx
  800540:	89 75 08             	mov    %esi,0x8(%ebp)
  800543:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800546:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800549:	89 cb                	mov    %ecx,%ebx
  80054b:	eb 4d                	jmp    80059a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800551:	74 1b                	je     80056e <vprintfmt+0x213>
  800553:	0f be c0             	movsbl %al,%eax
  800556:	83 e8 20             	sub    $0x20,%eax
  800559:	83 f8 5e             	cmp    $0x5e,%eax
  80055c:	76 10                	jbe    80056e <vprintfmt+0x213>
					putch('?', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	6a 3f                	push   $0x3f
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	eb 0d                	jmp    80057b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	52                   	push   %edx
  800575:	ff 55 08             	call   *0x8(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057b:	83 eb 01             	sub    $0x1,%ebx
  80057e:	eb 1a                	jmp    80059a <vprintfmt+0x23f>
  800580:	89 75 08             	mov    %esi,0x8(%ebp)
  800583:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800586:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800589:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058c:	eb 0c                	jmp    80059a <vprintfmt+0x23f>
  80058e:	89 75 08             	mov    %esi,0x8(%ebp)
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800594:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800597:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059a:	83 c7 01             	add    $0x1,%edi
  80059d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a1:	0f be d0             	movsbl %al,%edx
  8005a4:	85 d2                	test   %edx,%edx
  8005a6:	74 23                	je     8005cb <vprintfmt+0x270>
  8005a8:	85 f6                	test   %esi,%esi
  8005aa:	78 a1                	js     80054d <vprintfmt+0x1f2>
  8005ac:	83 ee 01             	sub    $0x1,%esi
  8005af:	79 9c                	jns    80054d <vprintfmt+0x1f2>
  8005b1:	89 df                	mov    %ebx,%edi
  8005b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b9:	eb 18                	jmp    8005d3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	53                   	push   %ebx
  8005bf:	6a 20                	push   $0x20
  8005c1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c3:	83 ef 01             	sub    $0x1,%edi
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	eb 08                	jmp    8005d3 <vprintfmt+0x278>
  8005cb:	89 df                	mov    %ebx,%edi
  8005cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d3:	85 ff                	test   %edi,%edi
  8005d5:	7f e4                	jg     8005bb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005da:	e9 a2 fd ff ff       	jmp    800381 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005df:	83 fa 01             	cmp    $0x1,%edx
  8005e2:	7e 16                	jle    8005fa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 50 04             	mov    0x4(%eax),%edx
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f8:	eb 32                	jmp    80062c <vprintfmt+0x2d1>
	else if (lflag)
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	74 18                	je     800616 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	89 c1                	mov    %eax,%ecx
  80060e:	c1 f9 1f             	sar    $0x1f,%ecx
  800611:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800614:	eb 16                	jmp    80062c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800624:	89 c1                	mov    %eax,%ecx
  800626:	c1 f9 1f             	sar    $0x1f,%ecx
  800629:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800632:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800637:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063b:	79 74                	jns    8006b1 <vprintfmt+0x356>
				putch('-', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 2d                	push   $0x2d
  800643:	ff d6                	call   *%esi
				num = -(long long) num;
  800645:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800648:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064b:	f7 d8                	neg    %eax
  80064d:	83 d2 00             	adc    $0x0,%edx
  800650:	f7 da                	neg    %edx
  800652:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800655:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065a:	eb 55                	jmp    8006b1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 83 fc ff ff       	call   8002e7 <getuint>
			base = 10;
  800664:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800669:	eb 46                	jmp    8006b1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 74 fc ff ff       	call   8002e7 <getuint>
			base = 8;
  800673:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800678:	eb 37                	jmp    8006b1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	6a 30                	push   $0x30
  800680:	ff d6                	call   *%esi
			putch('x', putdat);
  800682:	83 c4 08             	add    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	6a 78                	push   $0x78
  800688:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a2:	eb 0d                	jmp    8006b1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 3b fc ff ff       	call   8002e7 <getuint>
			base = 16;
  8006ac:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b1:	83 ec 0c             	sub    $0xc,%esp
  8006b4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b8:	57                   	push   %edi
  8006b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bc:	51                   	push   %ecx
  8006bd:	52                   	push   %edx
  8006be:	50                   	push   %eax
  8006bf:	89 da                	mov    %ebx,%edx
  8006c1:	89 f0                	mov    %esi,%eax
  8006c3:	e8 70 fb ff ff       	call   800238 <printnum>
			break;
  8006c8:	83 c4 20             	add    $0x20,%esp
  8006cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ce:	e9 ae fc ff ff       	jmp    800381 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	51                   	push   %ecx
  8006d8:	ff d6                	call   *%esi
			break;
  8006da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e0:	e9 9c fc ff ff       	jmp    800381 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	6a 25                	push   $0x25
  8006eb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	eb 03                	jmp    8006f5 <vprintfmt+0x39a>
  8006f2:	83 ef 01             	sub    $0x1,%edi
  8006f5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f9:	75 f7                	jne    8006f2 <vprintfmt+0x397>
  8006fb:	e9 81 fc ff ff       	jmp    800381 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 18             	sub    $0x18,%esp
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800714:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800717:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 26                	je     80074f <vsnprintf+0x47>
  800729:	85 d2                	test   %edx,%edx
  80072b:	7e 22                	jle    80074f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072d:	ff 75 14             	pushl  0x14(%ebp)
  800730:	ff 75 10             	pushl  0x10(%ebp)
  800733:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	68 21 03 80 00       	push   $0x800321
  80073c:	e8 1a fc ff ff       	call   80035b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800741:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800744:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 05                	jmp    800754 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075f:	50                   	push   %eax
  800760:	ff 75 10             	pushl  0x10(%ebp)
  800763:	ff 75 0c             	pushl  0xc(%ebp)
  800766:	ff 75 08             	pushl  0x8(%ebp)
  800769:	e8 9a ff ff ff       	call   800708 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	eb 03                	jmp    800780 <strlen+0x10>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800780:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800784:	75 f7                	jne    80077d <strlen+0xd>
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	ba 00 00 00 00       	mov    $0x0,%edx
  800796:	eb 03                	jmp    80079b <strnlen+0x13>
		n++;
  800798:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 c2                	cmp    %eax,%edx
  80079d:	74 08                	je     8007a7 <strnlen+0x1f>
  80079f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a3:	75 f3                	jne    800798 <strnlen+0x10>
  8007a5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	53                   	push   %ebx
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b3:	89 c2                	mov    %eax,%edx
  8007b5:	83 c2 01             	add    $0x1,%edx
  8007b8:	83 c1 01             	add    $0x1,%ecx
  8007bb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c2:	84 db                	test   %bl,%bl
  8007c4:	75 ef                	jne    8007b5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c6:	5b                   	pop    %ebx
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d0:	53                   	push   %ebx
  8007d1:	e8 9a ff ff ff       	call   800770 <strlen>
  8007d6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d9:	ff 75 0c             	pushl  0xc(%ebp)
  8007dc:	01 d8                	add    %ebx,%eax
  8007de:	50                   	push   %eax
  8007df:	e8 c5 ff ff ff       	call   8007a9 <strcpy>
	return dst;
}
  8007e4:	89 d8                	mov    %ebx,%eax
  8007e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    

008007eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f6:	89 f3                	mov    %esi,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	89 f2                	mov    %esi,%edx
  8007fd:	eb 0f                	jmp    80080e <strncpy+0x23>
		*dst++ = *src;
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	0f b6 01             	movzbl (%ecx),%eax
  800805:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800808:	80 39 01             	cmpb   $0x1,(%ecx)
  80080b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080e:	39 da                	cmp    %ebx,%edx
  800810:	75 ed                	jne    8007ff <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800812:	89 f0                	mov    %esi,%eax
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	8b 55 10             	mov    0x10(%ebp),%edx
  800826:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800828:	85 d2                	test   %edx,%edx
  80082a:	74 21                	je     80084d <strlcpy+0x35>
  80082c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800830:	89 f2                	mov    %esi,%edx
  800832:	eb 09                	jmp    80083d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800834:	83 c2 01             	add    $0x1,%edx
  800837:	83 c1 01             	add    $0x1,%ecx
  80083a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083d:	39 c2                	cmp    %eax,%edx
  80083f:	74 09                	je     80084a <strlcpy+0x32>
  800841:	0f b6 19             	movzbl (%ecx),%ebx
  800844:	84 db                	test   %bl,%bl
  800846:	75 ec                	jne    800834 <strlcpy+0x1c>
  800848:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084d:	29 f0                	sub    %esi,%eax
}
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085c:	eb 06                	jmp    800864 <strcmp+0x11>
		p++, q++;
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800864:	0f b6 01             	movzbl (%ecx),%eax
  800867:	84 c0                	test   %al,%al
  800869:	74 04                	je     80086f <strcmp+0x1c>
  80086b:	3a 02                	cmp    (%edx),%al
  80086d:	74 ef                	je     80085e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 c0             	movzbl %al,%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
}
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	89 c3                	mov    %eax,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800888:	eb 06                	jmp    800890 <strncmp+0x17>
		n--, p++, q++;
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800890:	39 d8                	cmp    %ebx,%eax
  800892:	74 15                	je     8008a9 <strncmp+0x30>
  800894:	0f b6 08             	movzbl (%eax),%ecx
  800897:	84 c9                	test   %cl,%cl
  800899:	74 04                	je     80089f <strncmp+0x26>
  80089b:	3a 0a                	cmp    (%edx),%cl
  80089d:	74 eb                	je     80088a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089f:	0f b6 00             	movzbl (%eax),%eax
  8008a2:	0f b6 12             	movzbl (%edx),%edx
  8008a5:	29 d0                	sub    %edx,%eax
  8008a7:	eb 05                	jmp    8008ae <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bb:	eb 07                	jmp    8008c4 <strchr+0x13>
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 0f                	je     8008d0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	0f b6 10             	movzbl (%eax),%edx
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f2                	jne    8008bd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dc:	eb 03                	jmp    8008e1 <strfind+0xf>
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	74 04                	je     8008ec <strfind+0x1a>
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f2                	jne    8008de <strfind+0xc>
			break;
	return (char *) s;
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 36                	je     800934 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800904:	75 28                	jne    80092e <memset+0x40>
  800906:	f6 c1 03             	test   $0x3,%cl
  800909:	75 23                	jne    80092e <memset+0x40>
		c &= 0xFF;
  80090b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090f:	89 d3                	mov    %edx,%ebx
  800911:	c1 e3 08             	shl    $0x8,%ebx
  800914:	89 d6                	mov    %edx,%esi
  800916:	c1 e6 18             	shl    $0x18,%esi
  800919:	89 d0                	mov    %edx,%eax
  80091b:	c1 e0 10             	shl    $0x10,%eax
  80091e:	09 f0                	or     %esi,%eax
  800920:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800922:	89 d8                	mov    %ebx,%eax
  800924:	09 d0                	or     %edx,%eax
  800926:	c1 e9 02             	shr    $0x2,%ecx
  800929:	fc                   	cld    
  80092a:	f3 ab                	rep stos %eax,%es:(%edi)
  80092c:	eb 06                	jmp    800934 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800931:	fc                   	cld    
  800932:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800934:	89 f8                	mov    %edi,%eax
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5f                   	pop    %edi
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	57                   	push   %edi
  80093f:	56                   	push   %esi
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 75 0c             	mov    0xc(%ebp),%esi
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800949:	39 c6                	cmp    %eax,%esi
  80094b:	73 35                	jae    800982 <memmove+0x47>
  80094d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800950:	39 d0                	cmp    %edx,%eax
  800952:	73 2e                	jae    800982 <memmove+0x47>
		s += n;
		d += n;
  800954:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800957:	89 d6                	mov    %edx,%esi
  800959:	09 fe                	or     %edi,%esi
  80095b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800961:	75 13                	jne    800976 <memmove+0x3b>
  800963:	f6 c1 03             	test   $0x3,%cl
  800966:	75 0e                	jne    800976 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800968:	83 ef 04             	sub    $0x4,%edi
  80096b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096e:	c1 e9 02             	shr    $0x2,%ecx
  800971:	fd                   	std    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 09                	jmp    80097f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800976:	83 ef 01             	sub    $0x1,%edi
  800979:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097c:	fd                   	std    
  80097d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097f:	fc                   	cld    
  800980:	eb 1d                	jmp    80099f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800982:	89 f2                	mov    %esi,%edx
  800984:	09 c2                	or     %eax,%edx
  800986:	f6 c2 03             	test   $0x3,%dl
  800989:	75 0f                	jne    80099a <memmove+0x5f>
  80098b:	f6 c1 03             	test   $0x3,%cl
  80098e:	75 0a                	jne    80099a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800990:	c1 e9 02             	shr    $0x2,%ecx
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800998:	eb 05                	jmp    80099f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	ff 75 08             	pushl  0x8(%ebp)
  8009af:	e8 87 ff ff ff       	call   80093b <memmove>
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	89 c6                	mov    %eax,%esi
  8009c3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	eb 1a                	jmp    8009e2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c8:	0f b6 08             	movzbl (%eax),%ecx
  8009cb:	0f b6 1a             	movzbl (%edx),%ebx
  8009ce:	38 d9                	cmp    %bl,%cl
  8009d0:	74 0a                	je     8009dc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d2:	0f b6 c1             	movzbl %cl,%eax
  8009d5:	0f b6 db             	movzbl %bl,%ebx
  8009d8:	29 d8                	sub    %ebx,%eax
  8009da:	eb 0f                	jmp    8009eb <memcmp+0x35>
		s1++, s2++;
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	39 f0                	cmp    %esi,%eax
  8009e4:	75 e2                	jne    8009c8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f6:	89 c1                	mov    %eax,%ecx
  8009f8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ff:	eb 0a                	jmp    800a0b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	0f b6 10             	movzbl (%eax),%edx
  800a04:	39 da                	cmp    %ebx,%edx
  800a06:	74 07                	je     800a0f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a08:	83 c0 01             	add    $0x1,%eax
  800a0b:	39 c8                	cmp    %ecx,%eax
  800a0d:	72 f2                	jb     800a01 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0f:	5b                   	pop    %ebx
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1e:	eb 03                	jmp    800a23 <strtol+0x11>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a23:	0f b6 01             	movzbl (%ecx),%eax
  800a26:	3c 20                	cmp    $0x20,%al
  800a28:	74 f6                	je     800a20 <strtol+0xe>
  800a2a:	3c 09                	cmp    $0x9,%al
  800a2c:	74 f2                	je     800a20 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2e:	3c 2b                	cmp    $0x2b,%al
  800a30:	75 0a                	jne    800a3c <strtol+0x2a>
		s++;
  800a32:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a35:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3a:	eb 11                	jmp    800a4d <strtol+0x3b>
  800a3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a41:	3c 2d                	cmp    $0x2d,%al
  800a43:	75 08                	jne    800a4d <strtol+0x3b>
		s++, neg = 1;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a53:	75 15                	jne    800a6a <strtol+0x58>
  800a55:	80 39 30             	cmpb   $0x30,(%ecx)
  800a58:	75 10                	jne    800a6a <strtol+0x58>
  800a5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5e:	75 7c                	jne    800adc <strtol+0xca>
		s += 2, base = 16;
  800a60:	83 c1 02             	add    $0x2,%ecx
  800a63:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a68:	eb 16                	jmp    800a80 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	75 12                	jne    800a80 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a73:	80 39 30             	cmpb   $0x30,(%ecx)
  800a76:	75 08                	jne    800a80 <strtol+0x6e>
		s++, base = 8;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a88:	0f b6 11             	movzbl (%ecx),%edx
  800a8b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 09             	cmp    $0x9,%bl
  800a93:	77 08                	ja     800a9d <strtol+0x8b>
			dig = *s - '0';
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 30             	sub    $0x30,%edx
  800a9b:	eb 22                	jmp    800abf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 57             	sub    $0x57,%edx
  800aad:	eb 10                	jmp    800abf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aaf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 16                	ja     800acf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac2:	7d 0b                	jge    800acf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acd:	eb b9                	jmp    800a88 <strtol+0x76>

	if (endptr)
  800acf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad3:	74 0d                	je     800ae2 <strtol+0xd0>
		*endptr = (char *) s;
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	89 0e                	mov    %ecx,(%esi)
  800ada:	eb 06                	jmp    800ae2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adc:	85 db                	test   %ebx,%ebx
  800ade:	74 98                	je     800a78 <strtol+0x66>
  800ae0:	eb 9e                	jmp    800a80 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	f7 da                	neg    %edx
  800ae6:	85 ff                	test   %edi,%edi
  800ae8:	0f 45 c2             	cmovne %edx,%eax
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	89 c6                	mov    %eax,%esi
  800b07:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	89 cb                	mov    %ecx,%ebx
  800b45:	89 cf                	mov    %ecx,%edi
  800b47:	89 ce                	mov    %ecx,%esi
  800b49:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7e 17                	jle    800b66 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 03                	push   $0x3
  800b55:	68 1f 28 80 00       	push   $0x80281f
  800b5a:	6a 23                	push   $0x23
  800b5c:	68 3c 28 80 00       	push   $0x80283c
  800b61:	e8 b7 14 00 00       	call   80201d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_yield>:

void
sys_yield(void)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9d:	89 d1                	mov    %edx,%ecx
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	89 d7                	mov    %edx,%edi
  800ba3:	89 d6                	mov    %edx,%esi
  800ba5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	be 00 00 00 00       	mov    $0x0,%esi
  800bba:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	89 f7                	mov    %esi,%edi
  800bca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 04                	push   $0x4
  800bd6:	68 1f 28 80 00       	push   $0x80281f
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 3c 28 80 00       	push   $0x80283c
  800be2:	e8 36 14 00 00       	call   80201d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c09:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7e 17                	jle    800c29 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 05                	push   $0x5
  800c18:	68 1f 28 80 00       	push   $0x80281f
  800c1d:	6a 23                	push   $0x23
  800c1f:	68 3c 28 80 00       	push   $0x80283c
  800c24:	e8 f4 13 00 00       	call   80201d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	89 df                	mov    %ebx,%edi
  800c4c:	89 de                	mov    %ebx,%esi
  800c4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7e 17                	jle    800c6b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	6a 06                	push   $0x6
  800c5a:	68 1f 28 80 00       	push   $0x80281f
  800c5f:	6a 23                	push   $0x23
  800c61:	68 3c 28 80 00       	push   $0x80283c
  800c66:	e8 b2 13 00 00       	call   80201d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c81:	b8 08 00 00 00       	mov    $0x8,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	89 df                	mov    %ebx,%edi
  800c8e:	89 de                	mov    %ebx,%esi
  800c90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7e 17                	jle    800cad <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	6a 08                	push   $0x8
  800c9c:	68 1f 28 80 00       	push   $0x80281f
  800ca1:	6a 23                	push   $0x23
  800ca3:	68 3c 28 80 00       	push   $0x80283c
  800ca8:	e8 70 13 00 00       	call   80201d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	89 df                	mov    %ebx,%edi
  800cd0:	89 de                	mov    %ebx,%esi
  800cd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 17                	jle    800cef <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 09                	push   $0x9
  800cde:	68 1f 28 80 00       	push   $0x80281f
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 3c 28 80 00       	push   $0x80283c
  800cea:	e8 2e 13 00 00       	call   80201d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 17                	jle    800d31 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 0a                	push   $0xa
  800d20:	68 1f 28 80 00       	push   $0x80281f
  800d25:	6a 23                	push   $0x23
  800d27:	68 3c 28 80 00       	push   $0x80283c
  800d2c:	e8 ec 12 00 00       	call   80201d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	be 00 00 00 00       	mov    $0x0,%esi
  800d44:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d55:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 cb                	mov    %ecx,%ebx
  800d74:	89 cf                	mov    %ecx,%edi
  800d76:	89 ce                	mov    %ecx,%esi
  800d78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 17                	jle    800d95 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 0d                	push   $0xd
  800d84:	68 1f 28 80 00       	push   $0x80281f
  800d89:	6a 23                	push   $0x23
  800d8b:	68 3c 28 80 00       	push   $0x80283c
  800d90:	e8 88 12 00 00       	call   80201d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 cb                	mov    %ecx,%ebx
  800db2:	89 cf                	mov    %ecx,%edi
  800db4:	89 ce                	mov    %ecx,%esi
  800db6:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 cb                	mov    %ecx,%ebx
  800dd2:	89 cf                	mov    %ecx,%edi
  800dd4:	89 ce                	mov    %ecx,%esi
  800dd6:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	53                   	push   %ebx
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800de9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ded:	74 11                	je     800e00 <pgfault+0x23>
  800def:	89 d8                	mov    %ebx,%eax
  800df1:	c1 e8 0c             	shr    $0xc,%eax
  800df4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dfb:	f6 c4 08             	test   $0x8,%ah
  800dfe:	75 14                	jne    800e14 <pgfault+0x37>
		panic("faulting access");
  800e00:	83 ec 04             	sub    $0x4,%esp
  800e03:	68 4a 28 80 00       	push   $0x80284a
  800e08:	6a 1e                	push   $0x1e
  800e0a:	68 5a 28 80 00       	push   $0x80285a
  800e0f:	e8 09 12 00 00       	call   80201d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	6a 07                	push   $0x7
  800e19:	68 00 f0 7f 00       	push   $0x7ff000
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 87 fd ff ff       	call   800bac <sys_page_alloc>
	if (r < 0) {
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	79 12                	jns    800e3e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e2c:	50                   	push   %eax
  800e2d:	68 65 28 80 00       	push   $0x802865
  800e32:	6a 2c                	push   $0x2c
  800e34:	68 5a 28 80 00       	push   $0x80285a
  800e39:	e8 df 11 00 00       	call   80201d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e3e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e44:	83 ec 04             	sub    $0x4,%esp
  800e47:	68 00 10 00 00       	push   $0x1000
  800e4c:	53                   	push   %ebx
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	e8 4c fb ff ff       	call   8009a3 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e57:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e5e:	53                   	push   %ebx
  800e5f:	6a 00                	push   $0x0
  800e61:	68 00 f0 7f 00       	push   $0x7ff000
  800e66:	6a 00                	push   $0x0
  800e68:	e8 82 fd ff ff       	call   800bef <sys_page_map>
	if (r < 0) {
  800e6d:	83 c4 20             	add    $0x20,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	79 12                	jns    800e86 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e74:	50                   	push   %eax
  800e75:	68 65 28 80 00       	push   $0x802865
  800e7a:	6a 33                	push   $0x33
  800e7c:	68 5a 28 80 00       	push   $0x80285a
  800e81:	e8 97 11 00 00       	call   80201d <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e86:	83 ec 08             	sub    $0x8,%esp
  800e89:	68 00 f0 7f 00       	push   $0x7ff000
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 9c fd ff ff       	call   800c31 <sys_page_unmap>
	if (r < 0) {
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	79 12                	jns    800eae <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e9c:	50                   	push   %eax
  800e9d:	68 65 28 80 00       	push   $0x802865
  800ea2:	6a 37                	push   $0x37
  800ea4:	68 5a 28 80 00       	push   $0x80285a
  800ea9:	e8 6f 11 00 00       	call   80201d <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800eae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ebc:	68 dd 0d 80 00       	push   $0x800ddd
  800ec1:	e8 9d 11 00 00       	call   802063 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ec6:	b8 07 00 00 00       	mov    $0x7,%eax
  800ecb:	cd 30                	int    $0x30
  800ecd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 17                	jns    800eee <fork+0x3b>
		panic("fork fault %e");
  800ed7:	83 ec 04             	sub    $0x4,%esp
  800eda:	68 7e 28 80 00       	push   $0x80287e
  800edf:	68 84 00 00 00       	push   $0x84
  800ee4:	68 5a 28 80 00       	push   $0x80285a
  800ee9:	e8 2f 11 00 00       	call   80201d <_panic>
  800eee:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ef0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef4:	75 25                	jne    800f1b <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef6:	e8 73 fc ff ff       	call   800b6e <sys_getenvid>
  800efb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f00:	89 c2                	mov    %eax,%edx
  800f02:	c1 e2 07             	shl    $0x7,%edx
  800f05:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f0c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
  800f16:	e9 61 01 00 00       	jmp    80107c <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f1b:	83 ec 04             	sub    $0x4,%esp
  800f1e:	6a 07                	push   $0x7
  800f20:	68 00 f0 bf ee       	push   $0xeebff000
  800f25:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f28:	e8 7f fc ff ff       	call   800bac <sys_page_alloc>
  800f2d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f35:	89 d8                	mov    %ebx,%eax
  800f37:	c1 e8 16             	shr    $0x16,%eax
  800f3a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f41:	a8 01                	test   $0x1,%al
  800f43:	0f 84 fc 00 00 00    	je     801045 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f49:	89 d8                	mov    %ebx,%eax
  800f4b:	c1 e8 0c             	shr    $0xc,%eax
  800f4e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	0f 84 e7 00 00 00    	je     801045 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f5e:	89 c6                	mov    %eax,%esi
  800f60:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f63:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f6a:	f6 c6 04             	test   $0x4,%dh
  800f6d:	74 39                	je     800fa8 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f6f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f76:	83 ec 0c             	sub    $0xc,%esp
  800f79:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7e:	50                   	push   %eax
  800f7f:	56                   	push   %esi
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	e8 66 fc ff ff       	call   800bef <sys_page_map>
		if (r < 0) {
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	0f 89 b1 00 00 00    	jns    801045 <fork+0x192>
		    	panic("sys page map fault %e");
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	68 8c 28 80 00       	push   $0x80288c
  800f9c:	6a 54                	push   $0x54
  800f9e:	68 5a 28 80 00       	push   $0x80285a
  800fa3:	e8 75 10 00 00       	call   80201d <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fa8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800faf:	f6 c2 02             	test   $0x2,%dl
  800fb2:	75 0c                	jne    800fc0 <fork+0x10d>
  800fb4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbb:	f6 c4 08             	test   $0x8,%ah
  800fbe:	74 5b                	je     80101b <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	68 05 08 00 00       	push   $0x805
  800fc8:	56                   	push   %esi
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 1d fc ff ff       	call   800bef <sys_page_map>
		if (r < 0) {
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 14                	jns    800fed <fork+0x13a>
		    	panic("sys page map fault %e");
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 8c 28 80 00       	push   $0x80288c
  800fe1:	6a 5b                	push   $0x5b
  800fe3:	68 5a 28 80 00       	push   $0x80285a
  800fe8:	e8 30 10 00 00       	call   80201d <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	68 05 08 00 00       	push   $0x805
  800ff5:	56                   	push   %esi
  800ff6:	6a 00                	push   $0x0
  800ff8:	56                   	push   %esi
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 ef fb ff ff       	call   800bef <sys_page_map>
		if (r < 0) {
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	79 3e                	jns    801045 <fork+0x192>
		    	panic("sys page map fault %e");
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	68 8c 28 80 00       	push   $0x80288c
  80100f:	6a 5f                	push   $0x5f
  801011:	68 5a 28 80 00       	push   $0x80285a
  801016:	e8 02 10 00 00       	call   80201d <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	6a 05                	push   $0x5
  801020:	56                   	push   %esi
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	6a 00                	push   $0x0
  801025:	e8 c5 fb ff ff       	call   800bef <sys_page_map>
		if (r < 0) {
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	79 14                	jns    801045 <fork+0x192>
		    	panic("sys page map fault %e");
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	68 8c 28 80 00       	push   $0x80288c
  801039:	6a 64                	push   $0x64
  80103b:	68 5a 28 80 00       	push   $0x80285a
  801040:	e8 d8 0f 00 00       	call   80201d <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801045:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80104b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801051:	0f 85 de fe ff ff    	jne    800f35 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801057:	a1 04 40 80 00       	mov    0x804004,%eax
  80105c:	8b 40 70             	mov    0x70(%eax),%eax
  80105f:	83 ec 08             	sub    $0x8,%esp
  801062:	50                   	push   %eax
  801063:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801066:	57                   	push   %edi
  801067:	e8 8b fc ff ff       	call   800cf7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80106c:	83 c4 08             	add    $0x8,%esp
  80106f:	6a 02                	push   $0x2
  801071:	57                   	push   %edi
  801072:	e8 fc fb ff ff       	call   800c73 <sys_env_set_status>
	
	return envid;
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80107c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sfork>:

envid_t
sfork(void)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801087:	b8 00 00 00 00       	mov    $0x0,%eax
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801096:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80109c:	83 ec 08             	sub    $0x8,%esp
  80109f:	53                   	push   %ebx
  8010a0:	68 a4 28 80 00       	push   $0x8028a4
  8010a5:	e8 7a f1 ff ff       	call   800224 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010aa:	c7 04 24 57 01 80 00 	movl   $0x800157,(%esp)
  8010b1:	e8 e7 fc ff ff       	call   800d9d <sys_thread_create>
  8010b6:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010b8:	83 c4 08             	add    $0x8,%esp
  8010bb:	53                   	push   %ebx
  8010bc:	68 a4 28 80 00       	push   $0x8028a4
  8010c1:	e8 5e f1 ff ff       	call   800224 <cprintf>
	return id;
	//return 0;
}
  8010c6:	89 f0                	mov    %esi,%eax
  8010c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d8:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8010db:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8010dd:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8010e0:	83 3a 01             	cmpl   $0x1,(%edx)
  8010e3:	7e 09                	jle    8010ee <argstart+0x1f>
  8010e5:	ba f1 24 80 00       	mov    $0x8024f1,%edx
  8010ea:	85 c9                	test   %ecx,%ecx
  8010ec:	75 05                	jne    8010f3 <argstart+0x24>
  8010ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f3:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8010f6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <argnext>:

int
argnext(struct Argstate *args)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	53                   	push   %ebx
  801103:	83 ec 04             	sub    $0x4,%esp
  801106:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801109:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801110:	8b 43 08             	mov    0x8(%ebx),%eax
  801113:	85 c0                	test   %eax,%eax
  801115:	74 6f                	je     801186 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801117:	80 38 00             	cmpb   $0x0,(%eax)
  80111a:	75 4e                	jne    80116a <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80111c:	8b 0b                	mov    (%ebx),%ecx
  80111e:	83 39 01             	cmpl   $0x1,(%ecx)
  801121:	74 55                	je     801178 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801123:	8b 53 04             	mov    0x4(%ebx),%edx
  801126:	8b 42 04             	mov    0x4(%edx),%eax
  801129:	80 38 2d             	cmpb   $0x2d,(%eax)
  80112c:	75 4a                	jne    801178 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80112e:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801132:	74 44                	je     801178 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801134:	83 c0 01             	add    $0x1,%eax
  801137:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	8b 01                	mov    (%ecx),%eax
  80113f:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801146:	50                   	push   %eax
  801147:	8d 42 08             	lea    0x8(%edx),%eax
  80114a:	50                   	push   %eax
  80114b:	83 c2 04             	add    $0x4,%edx
  80114e:	52                   	push   %edx
  80114f:	e8 e7 f7 ff ff       	call   80093b <memmove>
		(*args->argc)--;
  801154:	8b 03                	mov    (%ebx),%eax
  801156:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801159:	8b 43 08             	mov    0x8(%ebx),%eax
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	80 38 2d             	cmpb   $0x2d,(%eax)
  801162:	75 06                	jne    80116a <argnext+0x6b>
  801164:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801168:	74 0e                	je     801178 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80116a:	8b 53 08             	mov    0x8(%ebx),%edx
  80116d:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801170:	83 c2 01             	add    $0x1,%edx
  801173:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801176:	eb 13                	jmp    80118b <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801178:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80117f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801184:	eb 05                	jmp    80118b <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80118b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80119a:	8b 43 08             	mov    0x8(%ebx),%eax
  80119d:	85 c0                	test   %eax,%eax
  80119f:	74 58                	je     8011f9 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8011a1:	80 38 00             	cmpb   $0x0,(%eax)
  8011a4:	74 0c                	je     8011b2 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8011a6:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8011a9:	c7 43 08 f1 24 80 00 	movl   $0x8024f1,0x8(%ebx)
  8011b0:	eb 42                	jmp    8011f4 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8011b2:	8b 13                	mov    (%ebx),%edx
  8011b4:	83 3a 01             	cmpl   $0x1,(%edx)
  8011b7:	7e 2d                	jle    8011e6 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8011b9:	8b 43 04             	mov    0x4(%ebx),%eax
  8011bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8011bf:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	8b 12                	mov    (%edx),%edx
  8011c7:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8011ce:	52                   	push   %edx
  8011cf:	8d 50 08             	lea    0x8(%eax),%edx
  8011d2:	52                   	push   %edx
  8011d3:	83 c0 04             	add    $0x4,%eax
  8011d6:	50                   	push   %eax
  8011d7:	e8 5f f7 ff ff       	call   80093b <memmove>
		(*args->argc)--;
  8011dc:	8b 03                	mov    (%ebx),%eax
  8011de:	83 28 01             	subl   $0x1,(%eax)
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	eb 0e                	jmp    8011f4 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8011e6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8011ed:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8011f4:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011f7:	eb 05                	jmp    8011fe <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8011fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80120c:	8b 51 0c             	mov    0xc(%ecx),%edx
  80120f:	89 d0                	mov    %edx,%eax
  801211:	85 d2                	test   %edx,%edx
  801213:	75 0c                	jne    801221 <argvalue+0x1e>
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	51                   	push   %ecx
  801219:	e8 72 ff ff ff       	call   801190 <argnextvalue>
  80121e:	83 c4 10             	add    $0x10,%esp
}
  801221:	c9                   	leave  
  801222:	c3                   	ret    

00801223 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	05 00 00 00 30       	add    $0x30000000,%eax
  80122e:	c1 e8 0c             	shr    $0xc,%eax
}
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	05 00 00 00 30       	add    $0x30000000,%eax
  80123e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801243:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801250:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801255:	89 c2                	mov    %eax,%edx
  801257:	c1 ea 16             	shr    $0x16,%edx
  80125a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801261:	f6 c2 01             	test   $0x1,%dl
  801264:	74 11                	je     801277 <fd_alloc+0x2d>
  801266:	89 c2                	mov    %eax,%edx
  801268:	c1 ea 0c             	shr    $0xc,%edx
  80126b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801272:	f6 c2 01             	test   $0x1,%dl
  801275:	75 09                	jne    801280 <fd_alloc+0x36>
			*fd_store = fd;
  801277:	89 01                	mov    %eax,(%ecx)
			return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	eb 17                	jmp    801297 <fd_alloc+0x4d>
  801280:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801285:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80128a:	75 c9                	jne    801255 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80128c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801292:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80129f:	83 f8 1f             	cmp    $0x1f,%eax
  8012a2:	77 36                	ja     8012da <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a4:	c1 e0 0c             	shl    $0xc,%eax
  8012a7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	c1 ea 16             	shr    $0x16,%edx
  8012b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b8:	f6 c2 01             	test   $0x1,%dl
  8012bb:	74 24                	je     8012e1 <fd_lookup+0x48>
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	c1 ea 0c             	shr    $0xc,%edx
  8012c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c9:	f6 c2 01             	test   $0x1,%dl
  8012cc:	74 1a                	je     8012e8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d8:	eb 13                	jmp    8012ed <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012df:	eb 0c                	jmp    8012ed <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e6:	eb 05                	jmp    8012ed <fd_lookup+0x54>
  8012e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f8:	ba 44 29 80 00       	mov    $0x802944,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012fd:	eb 13                	jmp    801312 <dev_lookup+0x23>
  8012ff:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801302:	39 08                	cmp    %ecx,(%eax)
  801304:	75 0c                	jne    801312 <dev_lookup+0x23>
			*dev = devtab[i];
  801306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801309:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
  801310:	eb 2e                	jmp    801340 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801312:	8b 02                	mov    (%edx),%eax
  801314:	85 c0                	test   %eax,%eax
  801316:	75 e7                	jne    8012ff <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801318:	a1 04 40 80 00       	mov    0x804004,%eax
  80131d:	8b 40 54             	mov    0x54(%eax),%eax
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	51                   	push   %ecx
  801324:	50                   	push   %eax
  801325:	68 c8 28 80 00       	push   $0x8028c8
  80132a:	e8 f5 ee ff ff       	call   800224 <cprintf>
	*dev = 0;
  80132f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801332:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
  801347:	83 ec 10             	sub    $0x10,%esp
  80134a:	8b 75 08             	mov    0x8(%ebp),%esi
  80134d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80135a:	c1 e8 0c             	shr    $0xc,%eax
  80135d:	50                   	push   %eax
  80135e:	e8 36 ff ff ff       	call   801299 <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 05                	js     80136f <fd_close+0x2d>
	    || fd != fd2)
  80136a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136d:	74 0c                	je     80137b <fd_close+0x39>
		return (must_exist ? r : 0);
  80136f:	84 db                	test   %bl,%bl
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
  801376:	0f 44 c2             	cmove  %edx,%eax
  801379:	eb 41                	jmp    8013bc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801381:	50                   	push   %eax
  801382:	ff 36                	pushl  (%esi)
  801384:	e8 66 ff ff ff       	call   8012ef <dev_lookup>
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 1a                	js     8013ac <fd_close+0x6a>
		if (dev->dev_close)
  801392:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801395:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801398:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	74 0b                	je     8013ac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	56                   	push   %esi
  8013a5:	ff d0                	call   *%eax
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	56                   	push   %esi
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 7a f8 ff ff       	call   800c31 <sys_page_unmap>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 d8                	mov    %ebx,%eax
}
  8013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 c4 fe ff ff       	call   801299 <fd_lookup>
  8013d5:	83 c4 08             	add    $0x8,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 10                	js     8013ec <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	6a 01                	push   $0x1
  8013e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e4:	e8 59 ff ff ff       	call   801342 <fd_close>
  8013e9:	83 c4 10             	add    $0x10,%esp
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <close_all>:

void
close_all(void)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	53                   	push   %ebx
  8013fe:	e8 c0 ff ff ff       	call   8013c3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801403:	83 c3 01             	add    $0x1,%ebx
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	83 fb 20             	cmp    $0x20,%ebx
  80140c:	75 ec                	jne    8013fa <close_all+0xc>
		close(i);
}
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	57                   	push   %edi
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 2c             	sub    $0x2c,%esp
  80141c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801422:	50                   	push   %eax
  801423:	ff 75 08             	pushl  0x8(%ebp)
  801426:	e8 6e fe ff ff       	call   801299 <fd_lookup>
  80142b:	83 c4 08             	add    $0x8,%esp
  80142e:	85 c0                	test   %eax,%eax
  801430:	0f 88 c1 00 00 00    	js     8014f7 <dup+0xe4>
		return r;
	close(newfdnum);
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	56                   	push   %esi
  80143a:	e8 84 ff ff ff       	call   8013c3 <close>

	newfd = INDEX2FD(newfdnum);
  80143f:	89 f3                	mov    %esi,%ebx
  801441:	c1 e3 0c             	shl    $0xc,%ebx
  801444:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80144a:	83 c4 04             	add    $0x4,%esp
  80144d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801450:	e8 de fd ff ff       	call   801233 <fd2data>
  801455:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801457:	89 1c 24             	mov    %ebx,(%esp)
  80145a:	e8 d4 fd ff ff       	call   801233 <fd2data>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801465:	89 f8                	mov    %edi,%eax
  801467:	c1 e8 16             	shr    $0x16,%eax
  80146a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801471:	a8 01                	test   $0x1,%al
  801473:	74 37                	je     8014ac <dup+0x99>
  801475:	89 f8                	mov    %edi,%eax
  801477:	c1 e8 0c             	shr    $0xc,%eax
  80147a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801481:	f6 c2 01             	test   $0x1,%dl
  801484:	74 26                	je     8014ac <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	25 07 0e 00 00       	and    $0xe07,%eax
  801495:	50                   	push   %eax
  801496:	ff 75 d4             	pushl  -0x2c(%ebp)
  801499:	6a 00                	push   $0x0
  80149b:	57                   	push   %edi
  80149c:	6a 00                	push   $0x0
  80149e:	e8 4c f7 ff ff       	call   800bef <sys_page_map>
  8014a3:	89 c7                	mov    %eax,%edi
  8014a5:	83 c4 20             	add    $0x20,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 2e                	js     8014da <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014af:	89 d0                	mov    %edx,%eax
  8014b1:	c1 e8 0c             	shr    $0xc,%eax
  8014b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c3:	50                   	push   %eax
  8014c4:	53                   	push   %ebx
  8014c5:	6a 00                	push   $0x0
  8014c7:	52                   	push   %edx
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 20 f7 ff ff       	call   800bef <sys_page_map>
  8014cf:	89 c7                	mov    %eax,%edi
  8014d1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014d4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d6:	85 ff                	test   %edi,%edi
  8014d8:	79 1d                	jns    8014f7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	53                   	push   %ebx
  8014de:	6a 00                	push   $0x0
  8014e0:	e8 4c f7 ff ff       	call   800c31 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e5:	83 c4 08             	add    $0x8,%esp
  8014e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014eb:	6a 00                	push   $0x0
  8014ed:	e8 3f f7 ff ff       	call   800c31 <sys_page_unmap>
	return r;
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	89 f8                	mov    %edi,%eax
}
  8014f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	5f                   	pop    %edi
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    

008014ff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 14             	sub    $0x14,%esp
  801506:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801509:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	53                   	push   %ebx
  80150e:	e8 86 fd ff ff       	call   801299 <fd_lookup>
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	89 c2                	mov    %eax,%edx
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 6d                	js     801589 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	ff 30                	pushl  (%eax)
  801528:	e8 c2 fd ff ff       	call   8012ef <dev_lookup>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 4c                	js     801580 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801534:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801537:	8b 42 08             	mov    0x8(%edx),%eax
  80153a:	83 e0 03             	and    $0x3,%eax
  80153d:	83 f8 01             	cmp    $0x1,%eax
  801540:	75 21                	jne    801563 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801542:	a1 04 40 80 00       	mov    0x804004,%eax
  801547:	8b 40 54             	mov    0x54(%eax),%eax
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	53                   	push   %ebx
  80154e:	50                   	push   %eax
  80154f:	68 09 29 80 00       	push   $0x802909
  801554:	e8 cb ec ff ff       	call   800224 <cprintf>
		return -E_INVAL;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801561:	eb 26                	jmp    801589 <read+0x8a>
	}
	if (!dev->dev_read)
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801566:	8b 40 08             	mov    0x8(%eax),%eax
  801569:	85 c0                	test   %eax,%eax
  80156b:	74 17                	je     801584 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	ff 75 10             	pushl  0x10(%ebp)
  801573:	ff 75 0c             	pushl  0xc(%ebp)
  801576:	52                   	push   %edx
  801577:	ff d0                	call   *%eax
  801579:	89 c2                	mov    %eax,%edx
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	eb 09                	jmp    801589 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	89 c2                	mov    %eax,%edx
  801582:	eb 05                	jmp    801589 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801584:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801589:	89 d0                	mov    %edx,%eax
  80158b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	eb 21                	jmp    8015c7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	89 f0                	mov    %esi,%eax
  8015ab:	29 d8                	sub    %ebx,%eax
  8015ad:	50                   	push   %eax
  8015ae:	89 d8                	mov    %ebx,%eax
  8015b0:	03 45 0c             	add    0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	57                   	push   %edi
  8015b5:	e8 45 ff ff ff       	call   8014ff <read>
		if (m < 0)
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 10                	js     8015d1 <readn+0x41>
			return m;
		if (m == 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 0a                	je     8015cf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c5:	01 c3                	add    %eax,%ebx
  8015c7:	39 f3                	cmp    %esi,%ebx
  8015c9:	72 db                	jb     8015a6 <readn+0x16>
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	eb 02                	jmp    8015d1 <readn+0x41>
  8015cf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5e                   	pop    %esi
  8015d6:	5f                   	pop    %edi
  8015d7:	5d                   	pop    %ebp
  8015d8:	c3                   	ret    

008015d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 14             	sub    $0x14,%esp
  8015e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	53                   	push   %ebx
  8015e8:	e8 ac fc ff ff       	call   801299 <fd_lookup>
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 68                	js     80165e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	ff 30                	pushl  (%eax)
  801602:	e8 e8 fc ff ff       	call   8012ef <dev_lookup>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 47                	js     801655 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801615:	75 21                	jne    801638 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801617:	a1 04 40 80 00       	mov    0x804004,%eax
  80161c:	8b 40 54             	mov    0x54(%eax),%eax
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	53                   	push   %ebx
  801623:	50                   	push   %eax
  801624:	68 25 29 80 00       	push   $0x802925
  801629:	e8 f6 eb ff ff       	call   800224 <cprintf>
		return -E_INVAL;
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801636:	eb 26                	jmp    80165e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801638:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163b:	8b 52 0c             	mov    0xc(%edx),%edx
  80163e:	85 d2                	test   %edx,%edx
  801640:	74 17                	je     801659 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801642:	83 ec 04             	sub    $0x4,%esp
  801645:	ff 75 10             	pushl  0x10(%ebp)
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	ff d2                	call   *%edx
  80164e:	89 c2                	mov    %eax,%edx
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb 09                	jmp    80165e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801655:	89 c2                	mov    %eax,%edx
  801657:	eb 05                	jmp    80165e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801659:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80165e:	89 d0                	mov    %edx,%eax
  801660:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <seek>:

int
seek(int fdnum, off_t offset)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	ff 75 08             	pushl  0x8(%ebp)
  801672:	e8 22 fc ff ff       	call   801299 <fd_lookup>
  801677:	83 c4 08             	add    $0x8,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 0e                	js     80168c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80167e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801681:	8b 55 0c             	mov    0xc(%ebp),%edx
  801684:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 14             	sub    $0x14,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	53                   	push   %ebx
  80169d:	e8 f7 fb ff ff       	call   801299 <fd_lookup>
  8016a2:	83 c4 08             	add    $0x8,%esp
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 65                	js     801710 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	ff 30                	pushl  (%eax)
  8016b7:	e8 33 fc ff ff       	call   8012ef <dev_lookup>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 44                	js     801707 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ca:	75 21                	jne    8016ed <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016cc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d1:	8b 40 54             	mov    0x54(%eax),%eax
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	53                   	push   %ebx
  8016d8:	50                   	push   %eax
  8016d9:	68 e8 28 80 00       	push   $0x8028e8
  8016de:	e8 41 eb ff ff       	call   800224 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016eb:	eb 23                	jmp    801710 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f0:	8b 52 18             	mov    0x18(%edx),%edx
  8016f3:	85 d2                	test   %edx,%edx
  8016f5:	74 14                	je     80170b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	ff 75 0c             	pushl  0xc(%ebp)
  8016fd:	50                   	push   %eax
  8016fe:	ff d2                	call   *%edx
  801700:	89 c2                	mov    %eax,%edx
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	eb 09                	jmp    801710 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801707:	89 c2                	mov    %eax,%edx
  801709:	eb 05                	jmp    801710 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80170b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801710:	89 d0                	mov    %edx,%eax
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 14             	sub    $0x14,%esp
  80171e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801721:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	ff 75 08             	pushl  0x8(%ebp)
  801728:	e8 6c fb ff ff       	call   801299 <fd_lookup>
  80172d:	83 c4 08             	add    $0x8,%esp
  801730:	89 c2                	mov    %eax,%edx
  801732:	85 c0                	test   %eax,%eax
  801734:	78 58                	js     80178e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173c:	50                   	push   %eax
  80173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801740:	ff 30                	pushl  (%eax)
  801742:	e8 a8 fb ff ff       	call   8012ef <dev_lookup>
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 37                	js     801785 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801751:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801755:	74 32                	je     801789 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801757:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80175a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801761:	00 00 00 
	stat->st_isdir = 0;
  801764:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80176b:	00 00 00 
	stat->st_dev = dev;
  80176e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	53                   	push   %ebx
  801778:	ff 75 f0             	pushl  -0x10(%ebp)
  80177b:	ff 50 14             	call   *0x14(%eax)
  80177e:	89 c2                	mov    %eax,%edx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	eb 09                	jmp    80178e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801785:	89 c2                	mov    %eax,%edx
  801787:	eb 05                	jmp    80178e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801789:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80178e:	89 d0                	mov    %edx,%eax
  801790:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	6a 00                	push   $0x0
  80179f:	ff 75 08             	pushl  0x8(%ebp)
  8017a2:	e8 e3 01 00 00       	call   80198a <open>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 1b                	js     8017cb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	ff 75 0c             	pushl  0xc(%ebp)
  8017b6:	50                   	push   %eax
  8017b7:	e8 5b ff ff ff       	call   801717 <fstat>
  8017bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8017be:	89 1c 24             	mov    %ebx,(%esp)
  8017c1:	e8 fd fb ff ff       	call   8013c3 <close>
	return r;
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	89 f0                	mov    %esi,%eax
}
  8017cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	56                   	push   %esi
  8017d6:	53                   	push   %ebx
  8017d7:	89 c6                	mov    %eax,%esi
  8017d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017db:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e2:	75 12                	jne    8017f6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	6a 01                	push   $0x1
  8017e9:	e8 de 09 00 00       	call   8021cc <ipc_find_env>
  8017ee:	a3 00 40 80 00       	mov    %eax,0x804000
  8017f3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f6:	6a 07                	push   $0x7
  8017f8:	68 00 50 80 00       	push   $0x805000
  8017fd:	56                   	push   %esi
  8017fe:	ff 35 00 40 80 00    	pushl  0x804000
  801804:	e8 61 09 00 00       	call   80216a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801809:	83 c4 0c             	add    $0xc,%esp
  80180c:	6a 00                	push   $0x0
  80180e:	53                   	push   %ebx
  80180f:	6a 00                	push   $0x0
  801811:	e8 dc 08 00 00       	call   8020f2 <ipc_recv>
}
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 40 0c             	mov    0xc(%eax),%eax
  801829:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80182e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801831:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	b8 02 00 00 00       	mov    $0x2,%eax
  801840:	e8 8d ff ff ff       	call   8017d2 <fsipc>
}
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 06 00 00 00       	mov    $0x6,%eax
  801862:	e8 6b ff ff ff       	call   8017d2 <fsipc>
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	8b 40 0c             	mov    0xc(%eax),%eax
  801879:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187e:	ba 00 00 00 00       	mov    $0x0,%edx
  801883:	b8 05 00 00 00       	mov    $0x5,%eax
  801888:	e8 45 ff ff ff       	call   8017d2 <fsipc>
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 2c                	js     8018bd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	68 00 50 80 00       	push   $0x805000
  801899:	53                   	push   %ebx
  80189a:	e8 0a ef ff ff       	call   8007a9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189f:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018aa:	a1 84 50 80 00       	mov    0x805084,%eax
  8018af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 0c             	sub    $0xc,%esp
  8018c8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018d7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018dc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e1:	0f 47 c2             	cmova  %edx,%eax
  8018e4:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018e9:	50                   	push   %eax
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	68 08 50 80 00       	push   $0x805008
  8018f2:	e8 44 f0 ff ff       	call   80093b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801901:	e8 cc fe ff ff       	call   8017d2 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	8b 40 0c             	mov    0xc(%eax),%eax
  801916:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80191b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801921:	ba 00 00 00 00       	mov    $0x0,%edx
  801926:	b8 03 00 00 00       	mov    $0x3,%eax
  80192b:	e8 a2 fe ff ff       	call   8017d2 <fsipc>
  801930:	89 c3                	mov    %eax,%ebx
  801932:	85 c0                	test   %eax,%eax
  801934:	78 4b                	js     801981 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801936:	39 c6                	cmp    %eax,%esi
  801938:	73 16                	jae    801950 <devfile_read+0x48>
  80193a:	68 54 29 80 00       	push   $0x802954
  80193f:	68 5b 29 80 00       	push   $0x80295b
  801944:	6a 7c                	push   $0x7c
  801946:	68 70 29 80 00       	push   $0x802970
  80194b:	e8 cd 06 00 00       	call   80201d <_panic>
	assert(r <= PGSIZE);
  801950:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801955:	7e 16                	jle    80196d <devfile_read+0x65>
  801957:	68 7b 29 80 00       	push   $0x80297b
  80195c:	68 5b 29 80 00       	push   $0x80295b
  801961:	6a 7d                	push   $0x7d
  801963:	68 70 29 80 00       	push   $0x802970
  801968:	e8 b0 06 00 00       	call   80201d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80196d:	83 ec 04             	sub    $0x4,%esp
  801970:	50                   	push   %eax
  801971:	68 00 50 80 00       	push   $0x805000
  801976:	ff 75 0c             	pushl  0xc(%ebp)
  801979:	e8 bd ef ff ff       	call   80093b <memmove>
	return r;
  80197e:	83 c4 10             	add    $0x10,%esp
}
  801981:	89 d8                	mov    %ebx,%eax
  801983:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 20             	sub    $0x20,%esp
  801991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801994:	53                   	push   %ebx
  801995:	e8 d6 ed ff ff       	call   800770 <strlen>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a2:	7f 67                	jg     801a0b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a4:	83 ec 0c             	sub    $0xc,%esp
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	e8 9a f8 ff ff       	call   80124a <fd_alloc>
  8019b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 57                	js     801a10 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	68 00 50 80 00       	push   $0x805000
  8019c2:	e8 e2 ed ff ff       	call   8007a9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d7:	e8 f6 fd ff ff       	call   8017d2 <fsipc>
  8019dc:	89 c3                	mov    %eax,%ebx
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	79 14                	jns    8019f9 <open+0x6f>
		fd_close(fd, 0);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	6a 00                	push   $0x0
  8019ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ed:	e8 50 f9 ff ff       	call   801342 <fd_close>
		return r;
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	89 da                	mov    %ebx,%edx
  8019f7:	eb 17                	jmp    801a10 <open+0x86>
	}

	return fd2num(fd);
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ff:	e8 1f f8 ff ff       	call   801223 <fd2num>
  801a04:	89 c2                	mov    %eax,%edx
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	eb 05                	jmp    801a10 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a0b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a10:	89 d0                	mov    %edx,%eax
  801a12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	b8 08 00 00 00       	mov    $0x8,%eax
  801a27:	e8 a6 fd ff ff       	call   8017d2 <fsipc>
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801a2e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a32:	7e 37                	jle    801a6b <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	53                   	push   %ebx
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a3d:	ff 70 04             	pushl  0x4(%eax)
  801a40:	8d 40 10             	lea    0x10(%eax),%eax
  801a43:	50                   	push   %eax
  801a44:	ff 33                	pushl  (%ebx)
  801a46:	e8 8e fb ff ff       	call   8015d9 <write>
		if (result > 0)
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	7e 03                	jle    801a55 <writebuf+0x27>
			b->result += result;
  801a52:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a55:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a58:	74 0d                	je     801a67 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a61:	0f 4f c2             	cmovg  %edx,%eax
  801a64:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6a:	c9                   	leave  
  801a6b:	f3 c3                	repz ret 

00801a6d <putch>:

static void
putch(int ch, void *thunk)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	53                   	push   %ebx
  801a71:	83 ec 04             	sub    $0x4,%esp
  801a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a77:	8b 53 04             	mov    0x4(%ebx),%edx
  801a7a:	8d 42 01             	lea    0x1(%edx),%eax
  801a7d:	89 43 04             	mov    %eax,0x4(%ebx)
  801a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a83:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a87:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a8c:	75 0e                	jne    801a9c <putch+0x2f>
		writebuf(b);
  801a8e:	89 d8                	mov    %ebx,%eax
  801a90:	e8 99 ff ff ff       	call   801a2e <writebuf>
		b->idx = 0;
  801a95:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a9c:	83 c4 04             	add    $0x4,%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801ab4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801abb:	00 00 00 
	b.result = 0;
  801abe:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ac5:	00 00 00 
	b.error = 1;
  801ac8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801acf:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801ad2:	ff 75 10             	pushl  0x10(%ebp)
  801ad5:	ff 75 0c             	pushl  0xc(%ebp)
  801ad8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	68 6d 1a 80 00       	push   $0x801a6d
  801ae4:	e8 72 e8 ff ff       	call   80035b <vprintfmt>
	if (b.idx > 0)
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801af3:	7e 0b                	jle    801b00 <vfprintf+0x5e>
		writebuf(&b);
  801af5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801afb:	e8 2e ff ff ff       	call   801a2e <writebuf>

	return (b.result ? b.result : b.error);
  801b00:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b06:	85 c0                	test   %eax,%eax
  801b08:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b17:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b1a:	50                   	push   %eax
  801b1b:	ff 75 0c             	pushl  0xc(%ebp)
  801b1e:	ff 75 08             	pushl  0x8(%ebp)
  801b21:	e8 7c ff ff ff       	call   801aa2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <printf>:

int
printf(const char *fmt, ...)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b2e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b31:	50                   	push   %eax
  801b32:	ff 75 08             	pushl  0x8(%ebp)
  801b35:	6a 01                	push   $0x1
  801b37:	e8 66 ff ff ff       	call   801aa2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
  801b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	ff 75 08             	pushl  0x8(%ebp)
  801b4c:	e8 e2 f6 ff ff       	call   801233 <fd2data>
  801b51:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b53:	83 c4 08             	add    $0x8,%esp
  801b56:	68 87 29 80 00       	push   $0x802987
  801b5b:	53                   	push   %ebx
  801b5c:	e8 48 ec ff ff       	call   8007a9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b61:	8b 46 04             	mov    0x4(%esi),%eax
  801b64:	2b 06                	sub    (%esi),%eax
  801b66:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b6c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b73:	00 00 00 
	stat->st_dev = &devpipe;
  801b76:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b7d:	30 80 00 
	return 0;
}
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
  801b85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5e                   	pop    %esi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	53                   	push   %ebx
  801b90:	83 ec 0c             	sub    $0xc,%esp
  801b93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b96:	53                   	push   %ebx
  801b97:	6a 00                	push   $0x0
  801b99:	e8 93 f0 ff ff       	call   800c31 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b9e:	89 1c 24             	mov    %ebx,(%esp)
  801ba1:	e8 8d f6 ff ff       	call   801233 <fd2data>
  801ba6:	83 c4 08             	add    $0x8,%esp
  801ba9:	50                   	push   %eax
  801baa:	6a 00                	push   $0x0
  801bac:	e8 80 f0 ff ff       	call   800c31 <sys_page_unmap>
}
  801bb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	57                   	push   %edi
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 1c             	sub    $0x1c,%esp
  801bbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bc2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bc4:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc9:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	ff 75 e0             	pushl  -0x20(%ebp)
  801bd2:	e8 35 06 00 00       	call   80220c <pageref>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	89 3c 24             	mov    %edi,(%esp)
  801bdc:	e8 2b 06 00 00       	call   80220c <pageref>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	39 c3                	cmp    %eax,%ebx
  801be6:	0f 94 c1             	sete   %cl
  801be9:	0f b6 c9             	movzbl %cl,%ecx
  801bec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bef:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bf5:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801bf8:	39 ce                	cmp    %ecx,%esi
  801bfa:	74 1b                	je     801c17 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bfc:	39 c3                	cmp    %eax,%ebx
  801bfe:	75 c4                	jne    801bc4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c00:	8b 42 64             	mov    0x64(%edx),%eax
  801c03:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c06:	50                   	push   %eax
  801c07:	56                   	push   %esi
  801c08:	68 8e 29 80 00       	push   $0x80298e
  801c0d:	e8 12 e6 ff ff       	call   800224 <cprintf>
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	eb ad                	jmp    801bc4 <_pipeisclosed+0xe>
	}
}
  801c17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	57                   	push   %edi
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	83 ec 28             	sub    $0x28,%esp
  801c2b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c2e:	56                   	push   %esi
  801c2f:	e8 ff f5 ff ff       	call   801233 <fd2data>
  801c34:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	bf 00 00 00 00       	mov    $0x0,%edi
  801c3e:	eb 4b                	jmp    801c8b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c40:	89 da                	mov    %ebx,%edx
  801c42:	89 f0                	mov    %esi,%eax
  801c44:	e8 6d ff ff ff       	call   801bb6 <_pipeisclosed>
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	75 48                	jne    801c95 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c4d:	e8 3b ef ff ff       	call   800b8d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c52:	8b 43 04             	mov    0x4(%ebx),%eax
  801c55:	8b 0b                	mov    (%ebx),%ecx
  801c57:	8d 51 20             	lea    0x20(%ecx),%edx
  801c5a:	39 d0                	cmp    %edx,%eax
  801c5c:	73 e2                	jae    801c40 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c61:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c65:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	c1 fa 1f             	sar    $0x1f,%edx
  801c6d:	89 d1                	mov    %edx,%ecx
  801c6f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c72:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c75:	83 e2 1f             	and    $0x1f,%edx
  801c78:	29 ca                	sub    %ecx,%edx
  801c7a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c82:	83 c0 01             	add    $0x1,%eax
  801c85:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c88:	83 c7 01             	add    $0x1,%edi
  801c8b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c8e:	75 c2                	jne    801c52 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c90:	8b 45 10             	mov    0x10(%ebp),%eax
  801c93:	eb 05                	jmp    801c9a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 18             	sub    $0x18,%esp
  801cab:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cae:	57                   	push   %edi
  801caf:	e8 7f f5 ff ff       	call   801233 <fd2data>
  801cb4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cbe:	eb 3d                	jmp    801cfd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cc0:	85 db                	test   %ebx,%ebx
  801cc2:	74 04                	je     801cc8 <devpipe_read+0x26>
				return i;
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	eb 44                	jmp    801d0c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	89 f8                	mov    %edi,%eax
  801ccc:	e8 e5 fe ff ff       	call   801bb6 <_pipeisclosed>
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	75 32                	jne    801d07 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cd5:	e8 b3 ee ff ff       	call   800b8d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cda:	8b 06                	mov    (%esi),%eax
  801cdc:	3b 46 04             	cmp    0x4(%esi),%eax
  801cdf:	74 df                	je     801cc0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ce1:	99                   	cltd   
  801ce2:	c1 ea 1b             	shr    $0x1b,%edx
  801ce5:	01 d0                	add    %edx,%eax
  801ce7:	83 e0 1f             	and    $0x1f,%eax
  801cea:	29 d0                	sub    %edx,%eax
  801cec:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cf7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfa:	83 c3 01             	add    $0x1,%ebx
  801cfd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d00:	75 d8                	jne    801cda <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d02:	8b 45 10             	mov    0x10(%ebp),%eax
  801d05:	eb 05                	jmp    801d0c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1f:	50                   	push   %eax
  801d20:	e8 25 f5 ff ff       	call   80124a <fd_alloc>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	0f 88 2c 01 00 00    	js     801e5e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d32:	83 ec 04             	sub    $0x4,%esp
  801d35:	68 07 04 00 00       	push   $0x407
  801d3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3d:	6a 00                	push   $0x0
  801d3f:	e8 68 ee ff ff       	call   800bac <sys_page_alloc>
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	89 c2                	mov    %eax,%edx
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	0f 88 0d 01 00 00    	js     801e5e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d51:	83 ec 0c             	sub    $0xc,%esp
  801d54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d57:	50                   	push   %eax
  801d58:	e8 ed f4 ff ff       	call   80124a <fd_alloc>
  801d5d:	89 c3                	mov    %eax,%ebx
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	0f 88 e2 00 00 00    	js     801e4c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6a:	83 ec 04             	sub    $0x4,%esp
  801d6d:	68 07 04 00 00       	push   $0x407
  801d72:	ff 75 f0             	pushl  -0x10(%ebp)
  801d75:	6a 00                	push   $0x0
  801d77:	e8 30 ee ff ff       	call   800bac <sys_page_alloc>
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	0f 88 c3 00 00 00    	js     801e4c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d89:	83 ec 0c             	sub    $0xc,%esp
  801d8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8f:	e8 9f f4 ff ff       	call   801233 <fd2data>
  801d94:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d96:	83 c4 0c             	add    $0xc,%esp
  801d99:	68 07 04 00 00       	push   $0x407
  801d9e:	50                   	push   %eax
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 06 ee ff ff       	call   800bac <sys_page_alloc>
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	0f 88 89 00 00 00    	js     801e3c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff 75 f0             	pushl  -0x10(%ebp)
  801db9:	e8 75 f4 ff ff       	call   801233 <fd2data>
  801dbe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dc5:	50                   	push   %eax
  801dc6:	6a 00                	push   $0x0
  801dc8:	56                   	push   %esi
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 1f ee ff ff       	call   800bef <sys_page_map>
  801dd0:	89 c3                	mov    %eax,%ebx
  801dd2:	83 c4 20             	add    $0x20,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 55                	js     801e2e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dd9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	ff 75 f4             	pushl  -0xc(%ebp)
  801e09:	e8 15 f4 ff ff       	call   801223 <fd2num>
  801e0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e11:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e13:	83 c4 04             	add    $0x4,%esp
  801e16:	ff 75 f0             	pushl  -0x10(%ebp)
  801e19:	e8 05 f4 ff ff       	call   801223 <fd2num>
  801e1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e21:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2c:	eb 30                	jmp    801e5e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e2e:	83 ec 08             	sub    $0x8,%esp
  801e31:	56                   	push   %esi
  801e32:	6a 00                	push   $0x0
  801e34:	e8 f8 ed ff ff       	call   800c31 <sys_page_unmap>
  801e39:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e3c:	83 ec 08             	sub    $0x8,%esp
  801e3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e42:	6a 00                	push   $0x0
  801e44:	e8 e8 ed ff ff       	call   800c31 <sys_page_unmap>
  801e49:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e4c:	83 ec 08             	sub    $0x8,%esp
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	6a 00                	push   $0x0
  801e54:	e8 d8 ed ff ff       	call   800c31 <sys_page_unmap>
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e5e:	89 d0                	mov    %edx,%eax
  801e60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	ff 75 08             	pushl  0x8(%ebp)
  801e74:	e8 20 f4 ff ff       	call   801299 <fd_lookup>
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 18                	js     801e98 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e80:	83 ec 0c             	sub    $0xc,%esp
  801e83:	ff 75 f4             	pushl  -0xc(%ebp)
  801e86:	e8 a8 f3 ff ff       	call   801233 <fd2data>
	return _pipeisclosed(fd, p);
  801e8b:	89 c2                	mov    %eax,%edx
  801e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e90:	e8 21 fd ff ff       	call   801bb6 <_pipeisclosed>
  801e95:	83 c4 10             	add    $0x10,%esp
}
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    

00801e9a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eaa:	68 a6 29 80 00       	push   $0x8029a6
  801eaf:	ff 75 0c             	pushl  0xc(%ebp)
  801eb2:	e8 f2 e8 ff ff       	call   8007a9 <strcpy>
	return 0;
}
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eca:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ecf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed5:	eb 2d                	jmp    801f04 <devcons_write+0x46>
		m = n - tot;
  801ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eda:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801edc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801edf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ee4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee7:	83 ec 04             	sub    $0x4,%esp
  801eea:	53                   	push   %ebx
  801eeb:	03 45 0c             	add    0xc(%ebp),%eax
  801eee:	50                   	push   %eax
  801eef:	57                   	push   %edi
  801ef0:	e8 46 ea ff ff       	call   80093b <memmove>
		sys_cputs(buf, m);
  801ef5:	83 c4 08             	add    $0x8,%esp
  801ef8:	53                   	push   %ebx
  801ef9:	57                   	push   %edi
  801efa:	e8 f1 eb ff ff       	call   800af0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eff:	01 de                	add    %ebx,%esi
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	89 f0                	mov    %esi,%eax
  801f06:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f09:	72 cc                	jb     801ed7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5f                   	pop    %edi
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    

00801f13 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 08             	sub    $0x8,%esp
  801f19:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f22:	74 2a                	je     801f4e <devcons_read+0x3b>
  801f24:	eb 05                	jmp    801f2b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f26:	e8 62 ec ff ff       	call   800b8d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f2b:	e8 de eb ff ff       	call   800b0e <sys_cgetc>
  801f30:	85 c0                	test   %eax,%eax
  801f32:	74 f2                	je     801f26 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 16                	js     801f4e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f38:	83 f8 04             	cmp    $0x4,%eax
  801f3b:	74 0c                	je     801f49 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f40:	88 02                	mov    %al,(%edx)
	return 1;
  801f42:	b8 01 00 00 00       	mov    $0x1,%eax
  801f47:	eb 05                	jmp    801f4e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f49:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f4e:	c9                   	leave  
  801f4f:	c3                   	ret    

00801f50 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f56:	8b 45 08             	mov    0x8(%ebp),%eax
  801f59:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f5c:	6a 01                	push   $0x1
  801f5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f61:	50                   	push   %eax
  801f62:	e8 89 eb ff ff       	call   800af0 <sys_cputs>
}
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    

00801f6c <getchar>:

int
getchar(void)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f72:	6a 01                	push   $0x1
  801f74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f77:	50                   	push   %eax
  801f78:	6a 00                	push   $0x0
  801f7a:	e8 80 f5 ff ff       	call   8014ff <read>
	if (r < 0)
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 0f                	js     801f95 <getchar+0x29>
		return r;
	if (r < 1)
  801f86:	85 c0                	test   %eax,%eax
  801f88:	7e 06                	jle    801f90 <getchar+0x24>
		return -E_EOF;
	return c;
  801f8a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f8e:	eb 05                	jmp    801f95 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f90:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa0:	50                   	push   %eax
  801fa1:	ff 75 08             	pushl  0x8(%ebp)
  801fa4:	e8 f0 f2 ff ff       	call   801299 <fd_lookup>
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 11                	js     801fc1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb9:	39 10                	cmp    %edx,(%eax)
  801fbb:	0f 94 c0             	sete   %al
  801fbe:	0f b6 c0             	movzbl %al,%eax
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <opencons>:

int
opencons(void)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcc:	50                   	push   %eax
  801fcd:	e8 78 f2 ff ff       	call   80124a <fd_alloc>
  801fd2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 3e                	js     802019 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fdb:	83 ec 04             	sub    $0x4,%esp
  801fde:	68 07 04 00 00       	push   $0x407
  801fe3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe6:	6a 00                	push   $0x0
  801fe8:	e8 bf eb ff ff       	call   800bac <sys_page_alloc>
  801fed:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	78 23                	js     802019 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802001:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802004:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	50                   	push   %eax
  80200f:	e8 0f f2 ff ff       	call   801223 <fd2num>
  802014:	89 c2                	mov    %eax,%edx
  802016:	83 c4 10             	add    $0x10,%esp
}
  802019:	89 d0                	mov    %edx,%eax
  80201b:	c9                   	leave  
  80201c:	c3                   	ret    

0080201d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	56                   	push   %esi
  802021:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802022:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802025:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80202b:	e8 3e eb ff ff       	call   800b6e <sys_getenvid>
  802030:	83 ec 0c             	sub    $0xc,%esp
  802033:	ff 75 0c             	pushl  0xc(%ebp)
  802036:	ff 75 08             	pushl  0x8(%ebp)
  802039:	56                   	push   %esi
  80203a:	50                   	push   %eax
  80203b:	68 b4 29 80 00       	push   $0x8029b4
  802040:	e8 df e1 ff ff       	call   800224 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802045:	83 c4 18             	add    $0x18,%esp
  802048:	53                   	push   %ebx
  802049:	ff 75 10             	pushl  0x10(%ebp)
  80204c:	e8 82 e1 ff ff       	call   8001d3 <vcprintf>
	cprintf("\n");
  802051:	c7 04 24 f0 24 80 00 	movl   $0x8024f0,(%esp)
  802058:	e8 c7 e1 ff ff       	call   800224 <cprintf>
  80205d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802060:	cc                   	int3   
  802061:	eb fd                	jmp    802060 <_panic+0x43>

00802063 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802069:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802070:	75 2a                	jne    80209c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802072:	83 ec 04             	sub    $0x4,%esp
  802075:	6a 07                	push   $0x7
  802077:	68 00 f0 bf ee       	push   $0xeebff000
  80207c:	6a 00                	push   $0x0
  80207e:	e8 29 eb ff ff       	call   800bac <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	79 12                	jns    80209c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80208a:	50                   	push   %eax
  80208b:	68 d8 29 80 00       	push   $0x8029d8
  802090:	6a 23                	push   $0x23
  802092:	68 dc 29 80 00       	push   $0x8029dc
  802097:	e8 81 ff ff ff       	call   80201d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020a4:	83 ec 08             	sub    $0x8,%esp
  8020a7:	68 ce 20 80 00       	push   $0x8020ce
  8020ac:	6a 00                	push   $0x0
  8020ae:	e8 44 ec ff ff       	call   800cf7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020b3:	83 c4 10             	add    $0x10,%esp
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	79 12                	jns    8020cc <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020ba:	50                   	push   %eax
  8020bb:	68 d8 29 80 00       	push   $0x8029d8
  8020c0:	6a 2c                	push   $0x2c
  8020c2:	68 dc 29 80 00       	push   $0x8029dc
  8020c7:	e8 51 ff ff ff       	call   80201d <_panic>
	}
}
  8020cc:	c9                   	leave  
  8020cd:	c3                   	ret    

008020ce <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020ce:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020cf:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020d4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020d6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020d9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020dd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020e2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020e6:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020e8:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020eb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020ec:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020ef:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020f0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020f1:	c3                   	ret    

008020f2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	56                   	push   %esi
  8020f6:	53                   	push   %ebx
  8020f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8020fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802100:	85 c0                	test   %eax,%eax
  802102:	75 12                	jne    802116 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802104:	83 ec 0c             	sub    $0xc,%esp
  802107:	68 00 00 c0 ee       	push   $0xeec00000
  80210c:	e8 4b ec ff ff       	call   800d5c <sys_ipc_recv>
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	eb 0c                	jmp    802122 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802116:	83 ec 0c             	sub    $0xc,%esp
  802119:	50                   	push   %eax
  80211a:	e8 3d ec ff ff       	call   800d5c <sys_ipc_recv>
  80211f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802122:	85 f6                	test   %esi,%esi
  802124:	0f 95 c1             	setne  %cl
  802127:	85 db                	test   %ebx,%ebx
  802129:	0f 95 c2             	setne  %dl
  80212c:	84 d1                	test   %dl,%cl
  80212e:	74 09                	je     802139 <ipc_recv+0x47>
  802130:	89 c2                	mov    %eax,%edx
  802132:	c1 ea 1f             	shr    $0x1f,%edx
  802135:	84 d2                	test   %dl,%dl
  802137:	75 2a                	jne    802163 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802139:	85 f6                	test   %esi,%esi
  80213b:	74 0d                	je     80214a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80213d:	a1 04 40 80 00       	mov    0x804004,%eax
  802142:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802148:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80214a:	85 db                	test   %ebx,%ebx
  80214c:	74 0d                	je     80215b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80214e:	a1 04 40 80 00       	mov    0x804004,%eax
  802153:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802159:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80215b:	a1 04 40 80 00       	mov    0x804004,%eax
  802160:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802166:	5b                   	pop    %ebx
  802167:	5e                   	pop    %esi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	57                   	push   %edi
  80216e:	56                   	push   %esi
  80216f:	53                   	push   %ebx
  802170:	83 ec 0c             	sub    $0xc,%esp
  802173:	8b 7d 08             	mov    0x8(%ebp),%edi
  802176:	8b 75 0c             	mov    0xc(%ebp),%esi
  802179:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80217c:	85 db                	test   %ebx,%ebx
  80217e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802183:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802186:	ff 75 14             	pushl  0x14(%ebp)
  802189:	53                   	push   %ebx
  80218a:	56                   	push   %esi
  80218b:	57                   	push   %edi
  80218c:	e8 a8 eb ff ff       	call   800d39 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802191:	89 c2                	mov    %eax,%edx
  802193:	c1 ea 1f             	shr    $0x1f,%edx
  802196:	83 c4 10             	add    $0x10,%esp
  802199:	84 d2                	test   %dl,%dl
  80219b:	74 17                	je     8021b4 <ipc_send+0x4a>
  80219d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021a0:	74 12                	je     8021b4 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021a2:	50                   	push   %eax
  8021a3:	68 ea 29 80 00       	push   $0x8029ea
  8021a8:	6a 47                	push   $0x47
  8021aa:	68 f8 29 80 00       	push   $0x8029f8
  8021af:	e8 69 fe ff ff       	call   80201d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021b4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021b7:	75 07                	jne    8021c0 <ipc_send+0x56>
			sys_yield();
  8021b9:	e8 cf e9 ff ff       	call   800b8d <sys_yield>
  8021be:	eb c6                	jmp    802186 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	75 c2                	jne    802186 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    

008021cc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021d7:	89 c2                	mov    %eax,%edx
  8021d9:	c1 e2 07             	shl    $0x7,%edx
  8021dc:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  8021e3:	8b 52 5c             	mov    0x5c(%edx),%edx
  8021e6:	39 ca                	cmp    %ecx,%edx
  8021e8:	75 11                	jne    8021fb <ipc_find_env+0x2f>
			return envs[i].env_id;
  8021ea:	89 c2                	mov    %eax,%edx
  8021ec:	c1 e2 07             	shl    $0x7,%edx
  8021ef:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8021f6:	8b 40 54             	mov    0x54(%eax),%eax
  8021f9:	eb 0f                	jmp    80220a <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021fb:	83 c0 01             	add    $0x1,%eax
  8021fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802203:	75 d2                	jne    8021d7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802205:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    

0080220c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802212:	89 d0                	mov    %edx,%eax
  802214:	c1 e8 16             	shr    $0x16,%eax
  802217:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80221e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802223:	f6 c1 01             	test   $0x1,%cl
  802226:	74 1d                	je     802245 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802228:	c1 ea 0c             	shr    $0xc,%edx
  80222b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802232:	f6 c2 01             	test   $0x1,%dl
  802235:	74 0e                	je     802245 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802237:	c1 ea 0c             	shr    $0xc,%edx
  80223a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802241:	ef 
  802242:	0f b7 c0             	movzwl %ax,%eax
}
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    
  802247:	66 90                	xchg   %ax,%ax
  802249:	66 90                	xchg   %ax,%ax
  80224b:	66 90                	xchg   %ax,%ax
  80224d:	66 90                	xchg   %ax,%ax
  80224f:	90                   	nop

00802250 <__udivdi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80225b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80225f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 f6                	test   %esi,%esi
  802269:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226d:	89 ca                	mov    %ecx,%edx
  80226f:	89 f8                	mov    %edi,%eax
  802271:	75 3d                	jne    8022b0 <__udivdi3+0x60>
  802273:	39 cf                	cmp    %ecx,%edi
  802275:	0f 87 c5 00 00 00    	ja     802340 <__udivdi3+0xf0>
  80227b:	85 ff                	test   %edi,%edi
  80227d:	89 fd                	mov    %edi,%ebp
  80227f:	75 0b                	jne    80228c <__udivdi3+0x3c>
  802281:	b8 01 00 00 00       	mov    $0x1,%eax
  802286:	31 d2                	xor    %edx,%edx
  802288:	f7 f7                	div    %edi
  80228a:	89 c5                	mov    %eax,%ebp
  80228c:	89 c8                	mov    %ecx,%eax
  80228e:	31 d2                	xor    %edx,%edx
  802290:	f7 f5                	div    %ebp
  802292:	89 c1                	mov    %eax,%ecx
  802294:	89 d8                	mov    %ebx,%eax
  802296:	89 cf                	mov    %ecx,%edi
  802298:	f7 f5                	div    %ebp
  80229a:	89 c3                	mov    %eax,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	39 ce                	cmp    %ecx,%esi
  8022b2:	77 74                	ja     802328 <__udivdi3+0xd8>
  8022b4:	0f bd fe             	bsr    %esi,%edi
  8022b7:	83 f7 1f             	xor    $0x1f,%edi
  8022ba:	0f 84 98 00 00 00    	je     802358 <__udivdi3+0x108>
  8022c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	89 c5                	mov    %eax,%ebp
  8022c9:	29 fb                	sub    %edi,%ebx
  8022cb:	d3 e6                	shl    %cl,%esi
  8022cd:	89 d9                	mov    %ebx,%ecx
  8022cf:	d3 ed                	shr    %cl,%ebp
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	d3 e0                	shl    %cl,%eax
  8022d5:	09 ee                	or     %ebp,%esi
  8022d7:	89 d9                	mov    %ebx,%ecx
  8022d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022dd:	89 d5                	mov    %edx,%ebp
  8022df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022e3:	d3 ed                	shr    %cl,%ebp
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	d3 e2                	shl    %cl,%edx
  8022e9:	89 d9                	mov    %ebx,%ecx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	09 c2                	or     %eax,%edx
  8022ef:	89 d0                	mov    %edx,%eax
  8022f1:	89 ea                	mov    %ebp,%edx
  8022f3:	f7 f6                	div    %esi
  8022f5:	89 d5                	mov    %edx,%ebp
  8022f7:	89 c3                	mov    %eax,%ebx
  8022f9:	f7 64 24 0c          	mull   0xc(%esp)
  8022fd:	39 d5                	cmp    %edx,%ebp
  8022ff:	72 10                	jb     802311 <__udivdi3+0xc1>
  802301:	8b 74 24 08          	mov    0x8(%esp),%esi
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e6                	shl    %cl,%esi
  802309:	39 c6                	cmp    %eax,%esi
  80230b:	73 07                	jae    802314 <__udivdi3+0xc4>
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	75 03                	jne    802314 <__udivdi3+0xc4>
  802311:	83 eb 01             	sub    $0x1,%ebx
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 d8                	mov    %ebx,%eax
  802318:	89 fa                	mov    %edi,%edx
  80231a:	83 c4 1c             	add    $0x1c,%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5f                   	pop    %edi
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    
  802322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802328:	31 ff                	xor    %edi,%edi
  80232a:	31 db                	xor    %ebx,%ebx
  80232c:	89 d8                	mov    %ebx,%eax
  80232e:	89 fa                	mov    %edi,%edx
  802330:	83 c4 1c             	add    $0x1c,%esp
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	90                   	nop
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 d8                	mov    %ebx,%eax
  802342:	f7 f7                	div    %edi
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 c3                	mov    %eax,%ebx
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	89 fa                	mov    %edi,%edx
  80234c:	83 c4 1c             	add    $0x1c,%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5f                   	pop    %edi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	39 ce                	cmp    %ecx,%esi
  80235a:	72 0c                	jb     802368 <__udivdi3+0x118>
  80235c:	31 db                	xor    %ebx,%ebx
  80235e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802362:	0f 87 34 ff ff ff    	ja     80229c <__udivdi3+0x4c>
  802368:	bb 01 00 00 00       	mov    $0x1,%ebx
  80236d:	e9 2a ff ff ff       	jmp    80229c <__udivdi3+0x4c>
  802372:	66 90                	xchg   %ax,%ax
  802374:	66 90                	xchg   %ax,%ax
  802376:	66 90                	xchg   %ax,%ax
  802378:	66 90                	xchg   %ax,%ax
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__umoddi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80238b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80238f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 d2                	test   %edx,%edx
  802399:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80239d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023a1:	89 f3                	mov    %esi,%ebx
  8023a3:	89 3c 24             	mov    %edi,(%esp)
  8023a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023aa:	75 1c                	jne    8023c8 <__umoddi3+0x48>
  8023ac:	39 f7                	cmp    %esi,%edi
  8023ae:	76 50                	jbe    802400 <__umoddi3+0x80>
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	f7 f7                	div    %edi
  8023b6:	89 d0                	mov    %edx,%eax
  8023b8:	31 d2                	xor    %edx,%edx
  8023ba:	83 c4 1c             	add    $0x1c,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    
  8023c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c8:	39 f2                	cmp    %esi,%edx
  8023ca:	89 d0                	mov    %edx,%eax
  8023cc:	77 52                	ja     802420 <__umoddi3+0xa0>
  8023ce:	0f bd ea             	bsr    %edx,%ebp
  8023d1:	83 f5 1f             	xor    $0x1f,%ebp
  8023d4:	75 5a                	jne    802430 <__umoddi3+0xb0>
  8023d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023da:	0f 82 e0 00 00 00    	jb     8024c0 <__umoddi3+0x140>
  8023e0:	39 0c 24             	cmp    %ecx,(%esp)
  8023e3:	0f 86 d7 00 00 00    	jbe    8024c0 <__umoddi3+0x140>
  8023e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023f1:	83 c4 1c             	add    $0x1c,%esp
  8023f4:	5b                   	pop    %ebx
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	5d                   	pop    %ebp
  8023f8:	c3                   	ret    
  8023f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802400:	85 ff                	test   %edi,%edi
  802402:	89 fd                	mov    %edi,%ebp
  802404:	75 0b                	jne    802411 <__umoddi3+0x91>
  802406:	b8 01 00 00 00       	mov    $0x1,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	f7 f7                	div    %edi
  80240f:	89 c5                	mov    %eax,%ebp
  802411:	89 f0                	mov    %esi,%eax
  802413:	31 d2                	xor    %edx,%edx
  802415:	f7 f5                	div    %ebp
  802417:	89 c8                	mov    %ecx,%eax
  802419:	f7 f5                	div    %ebp
  80241b:	89 d0                	mov    %edx,%eax
  80241d:	eb 99                	jmp    8023b8 <__umoddi3+0x38>
  80241f:	90                   	nop
  802420:	89 c8                	mov    %ecx,%eax
  802422:	89 f2                	mov    %esi,%edx
  802424:	83 c4 1c             	add    $0x1c,%esp
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5f                   	pop    %edi
  80242a:	5d                   	pop    %ebp
  80242b:	c3                   	ret    
  80242c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802430:	8b 34 24             	mov    (%esp),%esi
  802433:	bf 20 00 00 00       	mov    $0x20,%edi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	29 ef                	sub    %ebp,%edi
  80243c:	d3 e0                	shl    %cl,%eax
  80243e:	89 f9                	mov    %edi,%ecx
  802440:	89 f2                	mov    %esi,%edx
  802442:	d3 ea                	shr    %cl,%edx
  802444:	89 e9                	mov    %ebp,%ecx
  802446:	09 c2                	or     %eax,%edx
  802448:	89 d8                	mov    %ebx,%eax
  80244a:	89 14 24             	mov    %edx,(%esp)
  80244d:	89 f2                	mov    %esi,%edx
  80244f:	d3 e2                	shl    %cl,%edx
  802451:	89 f9                	mov    %edi,%ecx
  802453:	89 54 24 04          	mov    %edx,0x4(%esp)
  802457:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	89 c6                	mov    %eax,%esi
  802461:	d3 e3                	shl    %cl,%ebx
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 d0                	mov    %edx,%eax
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	09 d8                	or     %ebx,%eax
  80246d:	89 d3                	mov    %edx,%ebx
  80246f:	89 f2                	mov    %esi,%edx
  802471:	f7 34 24             	divl   (%esp)
  802474:	89 d6                	mov    %edx,%esi
  802476:	d3 e3                	shl    %cl,%ebx
  802478:	f7 64 24 04          	mull   0x4(%esp)
  80247c:	39 d6                	cmp    %edx,%esi
  80247e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802482:	89 d1                	mov    %edx,%ecx
  802484:	89 c3                	mov    %eax,%ebx
  802486:	72 08                	jb     802490 <__umoddi3+0x110>
  802488:	75 11                	jne    80249b <__umoddi3+0x11b>
  80248a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80248e:	73 0b                	jae    80249b <__umoddi3+0x11b>
  802490:	2b 44 24 04          	sub    0x4(%esp),%eax
  802494:	1b 14 24             	sbb    (%esp),%edx
  802497:	89 d1                	mov    %edx,%ecx
  802499:	89 c3                	mov    %eax,%ebx
  80249b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80249f:	29 da                	sub    %ebx,%edx
  8024a1:	19 ce                	sbb    %ecx,%esi
  8024a3:	89 f9                	mov    %edi,%ecx
  8024a5:	89 f0                	mov    %esi,%eax
  8024a7:	d3 e0                	shl    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	d3 ea                	shr    %cl,%edx
  8024ad:	89 e9                	mov    %ebp,%ecx
  8024af:	d3 ee                	shr    %cl,%esi
  8024b1:	09 d0                	or     %edx,%eax
  8024b3:	89 f2                	mov    %esi,%edx
  8024b5:	83 c4 1c             	add    $0x1c,%esp
  8024b8:	5b                   	pop    %ebx
  8024b9:	5e                   	pop    %esi
  8024ba:	5f                   	pop    %edi
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    
  8024bd:	8d 76 00             	lea    0x0(%esi),%esi
  8024c0:	29 f9                	sub    %edi,%ecx
  8024c2:	19 d6                	sbb    %edx,%esi
  8024c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024cc:	e9 18 ff ff ff       	jmp    8023e9 <__umoddi3+0x69>
