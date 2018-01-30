
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
  800039:	68 20 27 80 00       	push   $0x802720
  80003e:	e8 e0 01 00 00       	call   800223 <cprintf>
	exit();
  800043:	e8 2e 01 00 00       	call   800176 <exit>
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
  800067:	e8 8a 12 00 00       	call   8012f6 <argstart>
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
  800091:	e8 90 12 00 00       	call   801326 <argnext>
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
  8000ad:	e8 98 18 00 00       	call   80194a <fstat>
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
  8000ce:	68 34 27 80 00       	push   $0x802734
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 6a 1c 00 00       	call   801d44 <fprintf>
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
  8000f0:	68 34 27 80 00       	push   $0x802734
  8000f5:	e8 29 01 00 00       	call   800223 <cprintf>
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
  800118:	e8 50 0a 00 00       	call   800b6d <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800128:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800132:	85 db                	test   %ebx,%ebx
  800134:	7e 07                	jle    80013d <libmain+0x30>
		binaryname = argv[0];
  800136:	8b 06                	mov    (%esi),%eax
  800138:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
  800142:	e8 06 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800147:	e8 2a 00 00 00       	call   800176 <exit>
}
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80015c:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800161:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800163:	e8 05 0a 00 00       	call   800b6d <sys_getenvid>
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	50                   	push   %eax
  80016c:	e8 4b 0c 00 00       	call   800dbc <sys_thread_free>
}
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017c:	e8 97 14 00 00       	call   801618 <close_all>
	sys_env_destroy(0);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	6a 00                	push   $0x0
  800186:	e8 a1 09 00 00       	call   800b2c <sys_env_destroy>
}
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 04             	sub    $0x4,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 13                	mov    (%ebx),%edx
  80019c:	8d 42 01             	lea    0x1(%edx),%eax
  80019f:	89 03                	mov    %eax,(%ebx)
  8001a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ad:	75 1a                	jne    8001c9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001af:	83 ec 08             	sub    $0x8,%esp
  8001b2:	68 ff 00 00 00       	push   $0xff
  8001b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ba:	50                   	push   %eax
  8001bb:	e8 2f 09 00 00       	call   800aef <sys_cputs>
		b->idx = 0;
  8001c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    

008001d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e2:	00 00 00 
	b.cnt = 0;
  8001e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	68 90 01 80 00       	push   $0x800190
  800201:	e8 54 01 00 00       	call   80035a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800206:	83 c4 08             	add    $0x8,%esp
  800209:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800215:	50                   	push   %eax
  800216:	e8 d4 08 00 00       	call   800aef <sys_cputs>

	return b.cnt;
}
  80021b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800229:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022c:	50                   	push   %eax
  80022d:	ff 75 08             	pushl  0x8(%ebp)
  800230:	e8 9d ff ff ff       	call   8001d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 1c             	sub    $0x1c,%esp
  800240:	89 c7                	mov    %eax,%edi
  800242:	89 d6                	mov    %edx,%esi
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025e:	39 d3                	cmp    %edx,%ebx
  800260:	72 05                	jb     800267 <printnum+0x30>
  800262:	39 45 10             	cmp    %eax,0x10(%ebp)
  800265:	77 45                	ja     8002ac <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	ff 75 18             	pushl  0x18(%ebp)
  80026d:	8b 45 14             	mov    0x14(%ebp),%eax
  800270:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800273:	53                   	push   %ebx
  800274:	ff 75 10             	pushl  0x10(%ebp)
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027d:	ff 75 e0             	pushl  -0x20(%ebp)
  800280:	ff 75 dc             	pushl  -0x24(%ebp)
  800283:	ff 75 d8             	pushl  -0x28(%ebp)
  800286:	e8 05 22 00 00       	call   802490 <__udivdi3>
  80028b:	83 c4 18             	add    $0x18,%esp
  80028e:	52                   	push   %edx
  80028f:	50                   	push   %eax
  800290:	89 f2                	mov    %esi,%edx
  800292:	89 f8                	mov    %edi,%eax
  800294:	e8 9e ff ff ff       	call   800237 <printnum>
  800299:	83 c4 20             	add    $0x20,%esp
  80029c:	eb 18                	jmp    8002b6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	ff 75 18             	pushl  0x18(%ebp)
  8002a5:	ff d7                	call   *%edi
  8002a7:	83 c4 10             	add    $0x10,%esp
  8002aa:	eb 03                	jmp    8002af <printnum+0x78>
  8002ac:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	85 db                	test   %ebx,%ebx
  8002b4:	7f e8                	jg     80029e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	56                   	push   %esi
  8002ba:	83 ec 04             	sub    $0x4,%esp
  8002bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c9:	e8 f2 22 00 00       	call   8025c0 <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 66 27 80 00 	movsbl 0x802766(%eax),%eax
  8002d8:	50                   	push   %eax
  8002d9:	ff d7                	call   *%edi
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800326:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	3b 50 04             	cmp    0x4(%eax),%edx
  80032f:	73 0a                	jae    80033b <sprintputch+0x1b>
		*b->buf++ = ch;
  800331:	8d 4a 01             	lea    0x1(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	88 02                	mov    %al,(%edx)
}
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800343:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800346:	50                   	push   %eax
  800347:	ff 75 10             	pushl  0x10(%ebp)
  80034a:	ff 75 0c             	pushl  0xc(%ebp)
  80034d:	ff 75 08             	pushl  0x8(%ebp)
  800350:	e8 05 00 00 00       	call   80035a <vprintfmt>
	va_end(ap);
}
  800355:	83 c4 10             	add    $0x10,%esp
  800358:	c9                   	leave  
  800359:	c3                   	ret    

0080035a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	57                   	push   %edi
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
  800360:	83 ec 2c             	sub    $0x2c,%esp
  800363:	8b 75 08             	mov    0x8(%ebp),%esi
  800366:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800369:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036c:	eb 12                	jmp    800380 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036e:	85 c0                	test   %eax,%eax
  800370:	0f 84 89 03 00 00    	je     8006ff <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	53                   	push   %ebx
  80037a:	50                   	push   %eax
  80037b:	ff d6                	call   *%esi
  80037d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800380:	83 c7 01             	add    $0x1,%edi
  800383:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800387:	83 f8 25             	cmp    $0x25,%eax
  80038a:	75 e2                	jne    80036e <vprintfmt+0x14>
  80038c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800390:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800397:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003aa:	eb 07                	jmp    8003b3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003af:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8d 47 01             	lea    0x1(%edi),%eax
  8003b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b9:	0f b6 07             	movzbl (%edi),%eax
  8003bc:	0f b6 c8             	movzbl %al,%ecx
  8003bf:	83 e8 23             	sub    $0x23,%eax
  8003c2:	3c 55                	cmp    $0x55,%al
  8003c4:	0f 87 1a 03 00 00    	ja     8006e4 <vprintfmt+0x38a>
  8003ca:	0f b6 c0             	movzbl %al,%eax
  8003cd:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003db:	eb d6                	jmp    8003b3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003eb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ef:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f5:	83 fa 09             	cmp    $0x9,%edx
  8003f8:	77 39                	ja     800433 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fd:	eb e9                	jmp    8003e8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 48 04             	lea    0x4(%eax),%ecx
  800405:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800410:	eb 27                	jmp    800439 <vprintfmt+0xdf>
  800412:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800415:	85 c0                	test   %eax,%eax
  800417:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041c:	0f 49 c8             	cmovns %eax,%ecx
  80041f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800425:	eb 8c                	jmp    8003b3 <vprintfmt+0x59>
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800431:	eb 80                	jmp    8003b3 <vprintfmt+0x59>
  800433:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800436:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800439:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043d:	0f 89 70 ff ff ff    	jns    8003b3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800443:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800446:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800449:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800450:	e9 5e ff ff ff       	jmp    8003b3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800455:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045b:	e9 53 ff ff ff       	jmp    8003b3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	53                   	push   %ebx
  80046d:	ff 30                	pushl  (%eax)
  80046f:	ff d6                	call   *%esi
			break;
  800471:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800477:	e9 04 ff ff ff       	jmp    800380 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	99                   	cltd   
  800488:	31 d0                	xor    %edx,%eax
  80048a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048c:	83 f8 0f             	cmp    $0xf,%eax
  80048f:	7f 0b                	jg     80049c <vprintfmt+0x142>
  800491:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  800498:	85 d2                	test   %edx,%edx
  80049a:	75 18                	jne    8004b4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049c:	50                   	push   %eax
  80049d:	68 7e 27 80 00       	push   $0x80277e
  8004a2:	53                   	push   %ebx
  8004a3:	56                   	push   %esi
  8004a4:	e8 94 fe ff ff       	call   80033d <printfmt>
  8004a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004af:	e9 cc fe ff ff       	jmp    800380 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b4:	52                   	push   %edx
  8004b5:	68 bd 2b 80 00       	push   $0x802bbd
  8004ba:	53                   	push   %ebx
  8004bb:	56                   	push   %esi
  8004bc:	e8 7c fe ff ff       	call   80033d <printfmt>
  8004c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c7:	e9 b4 fe ff ff       	jmp    800380 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d7:	85 ff                	test   %edi,%edi
  8004d9:	b8 77 27 80 00       	mov    $0x802777,%eax
  8004de:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e5:	0f 8e 94 00 00 00    	jle    80057f <vprintfmt+0x225>
  8004eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ef:	0f 84 98 00 00 00    	je     80058d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fb:	57                   	push   %edi
  8004fc:	e8 86 02 00 00       	call   800787 <strnlen>
  800501:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800504:	29 c1                	sub    %eax,%ecx
  800506:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800509:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800510:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800513:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800516:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	eb 0f                	jmp    800529 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	ff 75 e0             	pushl  -0x20(%ebp)
  800521:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	83 ef 01             	sub    $0x1,%edi
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f ed                	jg     80051a <vprintfmt+0x1c0>
  80052d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800530:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800533:	85 c9                	test   %ecx,%ecx
  800535:	b8 00 00 00 00       	mov    $0x0,%eax
  80053a:	0f 49 c1             	cmovns %ecx,%eax
  80053d:	29 c1                	sub    %eax,%ecx
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	89 cb                	mov    %ecx,%ebx
  80054a:	eb 4d                	jmp    800599 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800550:	74 1b                	je     80056d <vprintfmt+0x213>
  800552:	0f be c0             	movsbl %al,%eax
  800555:	83 e8 20             	sub    $0x20,%eax
  800558:	83 f8 5e             	cmp    $0x5e,%eax
  80055b:	76 10                	jbe    80056d <vprintfmt+0x213>
					putch('?', putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	ff 75 0c             	pushl  0xc(%ebp)
  800563:	6a 3f                	push   $0x3f
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	eb 0d                	jmp    80057a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	52                   	push   %edx
  800574:	ff 55 08             	call   *0x8(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	83 eb 01             	sub    $0x1,%ebx
  80057d:	eb 1a                	jmp    800599 <vprintfmt+0x23f>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	eb 0c                	jmp    800599 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	83 c7 01             	add    $0x1,%edi
  80059c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a0:	0f be d0             	movsbl %al,%edx
  8005a3:	85 d2                	test   %edx,%edx
  8005a5:	74 23                	je     8005ca <vprintfmt+0x270>
  8005a7:	85 f6                	test   %esi,%esi
  8005a9:	78 a1                	js     80054c <vprintfmt+0x1f2>
  8005ab:	83 ee 01             	sub    $0x1,%esi
  8005ae:	79 9c                	jns    80054c <vprintfmt+0x1f2>
  8005b0:	89 df                	mov    %ebx,%edi
  8005b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b8:	eb 18                	jmp    8005d2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 20                	push   $0x20
  8005c0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c2:	83 ef 01             	sub    $0x1,%edi
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	eb 08                	jmp    8005d2 <vprintfmt+0x278>
  8005ca:	89 df                	mov    %ebx,%edi
  8005cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d2:	85 ff                	test   %edi,%edi
  8005d4:	7f e4                	jg     8005ba <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d9:	e9 a2 fd ff ff       	jmp    800380 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005de:	83 fa 01             	cmp    $0x1,%edx
  8005e1:	7e 16                	jle    8005f9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 08             	lea    0x8(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 50 04             	mov    0x4(%eax),%edx
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f7:	eb 32                	jmp    80062b <vprintfmt+0x2d1>
	else if (lflag)
  8005f9:	85 d2                	test   %edx,%edx
  8005fb:	74 18                	je     800615 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060b:	89 c1                	mov    %eax,%ecx
  80060d:	c1 f9 1f             	sar    $0x1f,%ecx
  800610:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800613:	eb 16                	jmp    80062b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	89 c1                	mov    %eax,%ecx
  800625:	c1 f9 1f             	sar    $0x1f,%ecx
  800628:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800636:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063a:	79 74                	jns    8006b0 <vprintfmt+0x356>
				putch('-', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 2d                	push   $0x2d
  800642:	ff d6                	call   *%esi
				num = -(long long) num;
  800644:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800647:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064a:	f7 d8                	neg    %eax
  80064c:	83 d2 00             	adc    $0x0,%edx
  80064f:	f7 da                	neg    %edx
  800651:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800654:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800659:	eb 55                	jmp    8006b0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 83 fc ff ff       	call   8002e6 <getuint>
			base = 10;
  800663:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800668:	eb 46                	jmp    8006b0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066a:	8d 45 14             	lea    0x14(%ebp),%eax
  80066d:	e8 74 fc ff ff       	call   8002e6 <getuint>
			base = 8;
  800672:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800677:	eb 37                	jmp    8006b0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 30                	push   $0x30
  80067f:	ff d6                	call   *%esi
			putch('x', putdat);
  800681:	83 c4 08             	add    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 78                	push   $0x78
  800687:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800692:	8b 00                	mov    (%eax),%eax
  800694:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800699:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a1:	eb 0d                	jmp    8006b0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 3b fc ff ff       	call   8002e6 <getuint>
			base = 16;
  8006ab:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b7:	57                   	push   %edi
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	51                   	push   %ecx
  8006bc:	52                   	push   %edx
  8006bd:	50                   	push   %eax
  8006be:	89 da                	mov    %ebx,%edx
  8006c0:	89 f0                	mov    %esi,%eax
  8006c2:	e8 70 fb ff ff       	call   800237 <printnum>
			break;
  8006c7:	83 c4 20             	add    $0x20,%esp
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cd:	e9 ae fc ff ff       	jmp    800380 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	51                   	push   %ecx
  8006d7:	ff d6                	call   *%esi
			break;
  8006d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006df:	e9 9c fc ff ff       	jmp    800380 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	6a 25                	push   $0x25
  8006ea:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 03                	jmp    8006f4 <vprintfmt+0x39a>
  8006f1:	83 ef 01             	sub    $0x1,%edi
  8006f4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f8:	75 f7                	jne    8006f1 <vprintfmt+0x397>
  8006fa:	e9 81 fc ff ff       	jmp    800380 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 26                	je     80074e <vsnprintf+0x47>
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e 22                	jle    80074e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072c:	ff 75 14             	pushl  0x14(%ebp)
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	68 20 03 80 00       	push   $0x800320
  80073b:	e8 1a fc ff ff       	call   80035a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 05                	jmp    800753 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	50                   	push   %eax
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	ff 75 08             	pushl  0x8(%ebp)
  800768:	e8 9a ff ff ff       	call   800707 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	eb 03                	jmp    80077f <strlen+0x10>
		n++;
  80077c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800783:	75 f7                	jne    80077c <strlen+0xd>
		n++;
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800790:	ba 00 00 00 00       	mov    $0x0,%edx
  800795:	eb 03                	jmp    80079a <strnlen+0x13>
		n++;
  800797:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079a:	39 c2                	cmp    %eax,%edx
  80079c:	74 08                	je     8007a6 <strnlen+0x1f>
  80079e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a2:	75 f3                	jne    800797 <strnlen+0x10>
  8007a4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	83 c2 01             	add    $0x1,%edx
  8007b7:	83 c1 01             	add    $0x1,%ecx
  8007ba:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007be:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c1:	84 db                	test   %bl,%bl
  8007c3:	75 ef                	jne    8007b4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cf:	53                   	push   %ebx
  8007d0:	e8 9a ff ff ff       	call   80076f <strlen>
  8007d5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	01 d8                	add    %ebx,%eax
  8007dd:	50                   	push   %eax
  8007de:	e8 c5 ff ff ff       	call   8007a8 <strcpy>
	return dst;
}
  8007e3:	89 d8                	mov    %ebx,%eax
  8007e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f5:	89 f3                	mov    %esi,%ebx
  8007f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 0f                	jmp    80080d <strncpy+0x23>
		*dst++ = *src;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	0f b6 01             	movzbl (%ecx),%eax
  800804:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800807:	80 39 01             	cmpb   $0x1,(%ecx)
  80080a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080d:	39 da                	cmp    %ebx,%edx
  80080f:	75 ed                	jne    8007fe <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800811:	89 f0                	mov    %esi,%eax
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 75 08             	mov    0x8(%ebp),%esi
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	8b 55 10             	mov    0x10(%ebp),%edx
  800825:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800827:	85 d2                	test   %edx,%edx
  800829:	74 21                	je     80084c <strlcpy+0x35>
  80082b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082f:	89 f2                	mov    %esi,%edx
  800831:	eb 09                	jmp    80083c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	83 c1 01             	add    $0x1,%ecx
  800839:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083c:	39 c2                	cmp    %eax,%edx
  80083e:	74 09                	je     800849 <strlcpy+0x32>
  800840:	0f b6 19             	movzbl (%ecx),%ebx
  800843:	84 db                	test   %bl,%bl
  800845:	75 ec                	jne    800833 <strlcpy+0x1c>
  800847:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800849:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084c:	29 f0                	sub    %esi,%eax
}
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085b:	eb 06                	jmp    800863 <strcmp+0x11>
		p++, q++;
  80085d:	83 c1 01             	add    $0x1,%ecx
  800860:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800863:	0f b6 01             	movzbl (%ecx),%eax
  800866:	84 c0                	test   %al,%al
  800868:	74 04                	je     80086e <strcmp+0x1c>
  80086a:	3a 02                	cmp    (%edx),%al
  80086c:	74 ef                	je     80085d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086e:	0f b6 c0             	movzbl %al,%eax
  800871:	0f b6 12             	movzbl (%edx),%edx
  800874:	29 d0                	sub    %edx,%eax
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800882:	89 c3                	mov    %eax,%ebx
  800884:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800887:	eb 06                	jmp    80088f <strncmp+0x17>
		n--, p++, q++;
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088f:	39 d8                	cmp    %ebx,%eax
  800891:	74 15                	je     8008a8 <strncmp+0x30>
  800893:	0f b6 08             	movzbl (%eax),%ecx
  800896:	84 c9                	test   %cl,%cl
  800898:	74 04                	je     80089e <strncmp+0x26>
  80089a:	3a 0a                	cmp    (%edx),%cl
  80089c:	74 eb                	je     800889 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 00             	movzbl (%eax),%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
  8008a6:	eb 05                	jmp    8008ad <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	eb 07                	jmp    8008c3 <strchr+0x13>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 0f                	je     8008cf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c0:	83 c0 01             	add    $0x1,%eax
  8008c3:	0f b6 10             	movzbl (%eax),%edx
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	75 f2                	jne    8008bc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008db:	eb 03                	jmp    8008e0 <strfind+0xf>
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e3:	38 ca                	cmp    %cl,%dl
  8008e5:	74 04                	je     8008eb <strfind+0x1a>
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	75 f2                	jne    8008dd <strfind+0xc>
			break;
	return (char *) s;
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f9:	85 c9                	test   %ecx,%ecx
  8008fb:	74 36                	je     800933 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800903:	75 28                	jne    80092d <memset+0x40>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 23                	jne    80092d <memset+0x40>
		c &= 0xFF;
  80090a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090e:	89 d3                	mov    %edx,%ebx
  800910:	c1 e3 08             	shl    $0x8,%ebx
  800913:	89 d6                	mov    %edx,%esi
  800915:	c1 e6 18             	shl    $0x18,%esi
  800918:	89 d0                	mov    %edx,%eax
  80091a:	c1 e0 10             	shl    $0x10,%eax
  80091d:	09 f0                	or     %esi,%eax
  80091f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800921:	89 d8                	mov    %ebx,%eax
  800923:	09 d0                	or     %edx,%eax
  800925:	c1 e9 02             	shr    $0x2,%ecx
  800928:	fc                   	cld    
  800929:	f3 ab                	rep stos %eax,%es:(%edi)
  80092b:	eb 06                	jmp    800933 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800930:	fc                   	cld    
  800931:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800933:	89 f8                	mov    %edi,%eax
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5f                   	pop    %edi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 75 0c             	mov    0xc(%ebp),%esi
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800948:	39 c6                	cmp    %eax,%esi
  80094a:	73 35                	jae    800981 <memmove+0x47>
  80094c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094f:	39 d0                	cmp    %edx,%eax
  800951:	73 2e                	jae    800981 <memmove+0x47>
		s += n;
		d += n;
  800953:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 d6                	mov    %edx,%esi
  800958:	09 fe                	or     %edi,%esi
  80095a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800960:	75 13                	jne    800975 <memmove+0x3b>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0e                	jne    800975 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800967:	83 ef 04             	sub    $0x4,%edi
  80096a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096d:	c1 e9 02             	shr    $0x2,%ecx
  800970:	fd                   	std    
  800971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800973:	eb 09                	jmp    80097e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800975:	83 ef 01             	sub    $0x1,%edi
  800978:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097b:	fd                   	std    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097e:	fc                   	cld    
  80097f:	eb 1d                	jmp    80099e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	89 f2                	mov    %esi,%edx
  800983:	09 c2                	or     %eax,%edx
  800985:	f6 c2 03             	test   $0x3,%dl
  800988:	75 0f                	jne    800999 <memmove+0x5f>
  80098a:	f6 c1 03             	test   $0x3,%cl
  80098d:	75 0a                	jne    800999 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098f:	c1 e9 02             	shr    $0x2,%ecx
  800992:	89 c7                	mov    %eax,%edi
  800994:	fc                   	cld    
  800995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800997:	eb 05                	jmp    80099e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800999:	89 c7                	mov    %eax,%edi
  80099b:	fc                   	cld    
  80099c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a5:	ff 75 10             	pushl  0x10(%ebp)
  8009a8:	ff 75 0c             	pushl  0xc(%ebp)
  8009ab:	ff 75 08             	pushl  0x8(%ebp)
  8009ae:	e8 87 ff ff ff       	call   80093a <memmove>
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c0:	89 c6                	mov    %eax,%esi
  8009c2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c5:	eb 1a                	jmp    8009e1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c7:	0f b6 08             	movzbl (%eax),%ecx
  8009ca:	0f b6 1a             	movzbl (%edx),%ebx
  8009cd:	38 d9                	cmp    %bl,%cl
  8009cf:	74 0a                	je     8009db <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d1:	0f b6 c1             	movzbl %cl,%eax
  8009d4:	0f b6 db             	movzbl %bl,%ebx
  8009d7:	29 d8                	sub    %ebx,%eax
  8009d9:	eb 0f                	jmp    8009ea <memcmp+0x35>
		s1++, s2++;
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e1:	39 f0                	cmp    %esi,%eax
  8009e3:	75 e2                	jne    8009c7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f5:	89 c1                	mov    %eax,%ecx
  8009f7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fa:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fe:	eb 0a                	jmp    800a0a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a00:	0f b6 10             	movzbl (%eax),%edx
  800a03:	39 da                	cmp    %ebx,%edx
  800a05:	74 07                	je     800a0e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	39 c8                	cmp    %ecx,%eax
  800a0c:	72 f2                	jb     800a00 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	57                   	push   %edi
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1d:	eb 03                	jmp    800a22 <strtol+0x11>
		s++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a22:	0f b6 01             	movzbl (%ecx),%eax
  800a25:	3c 20                	cmp    $0x20,%al
  800a27:	74 f6                	je     800a1f <strtol+0xe>
  800a29:	3c 09                	cmp    $0x9,%al
  800a2b:	74 f2                	je     800a1f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2d:	3c 2b                	cmp    $0x2b,%al
  800a2f:	75 0a                	jne    800a3b <strtol+0x2a>
		s++;
  800a31:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
  800a39:	eb 11                	jmp    800a4c <strtol+0x3b>
  800a3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a40:	3c 2d                	cmp    $0x2d,%al
  800a42:	75 08                	jne    800a4c <strtol+0x3b>
		s++, neg = 1;
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a52:	75 15                	jne    800a69 <strtol+0x58>
  800a54:	80 39 30             	cmpb   $0x30,(%ecx)
  800a57:	75 10                	jne    800a69 <strtol+0x58>
  800a59:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5d:	75 7c                	jne    800adb <strtol+0xca>
		s += 2, base = 16;
  800a5f:	83 c1 02             	add    $0x2,%ecx
  800a62:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a67:	eb 16                	jmp    800a7f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	75 12                	jne    800a7f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a72:	80 39 30             	cmpb   $0x30,(%ecx)
  800a75:	75 08                	jne    800a7f <strtol+0x6e>
		s++, base = 8;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a87:	0f b6 11             	movzbl (%ecx),%edx
  800a8a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 09             	cmp    $0x9,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x8b>
			dig = *s - '0';
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 30             	sub    $0x30,%edx
  800a9a:	eb 22                	jmp    800abe <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 57             	sub    $0x57,%edx
  800aac:	eb 10                	jmp    800abe <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aae:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 16                	ja     800ace <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac1:	7d 0b                	jge    800ace <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac3:	83 c1 01             	add    $0x1,%ecx
  800ac6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aca:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acc:	eb b9                	jmp    800a87 <strtol+0x76>

	if (endptr)
  800ace:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad2:	74 0d                	je     800ae1 <strtol+0xd0>
		*endptr = (char *) s;
  800ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad7:	89 0e                	mov    %ecx,(%esi)
  800ad9:	eb 06                	jmp    800ae1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adb:	85 db                	test   %ebx,%ebx
  800add:	74 98                	je     800a77 <strtol+0x66>
  800adf:	eb 9e                	jmp    800a7f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae1:	89 c2                	mov    %eax,%edx
  800ae3:	f7 da                	neg    %edx
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	0f 45 c2             	cmovne %edx,%eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	89 c6                	mov    %eax,%esi
  800b06:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b13:	ba 00 00 00 00       	mov    $0x0,%edx
  800b18:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1d:	89 d1                	mov    %edx,%ecx
  800b1f:	89 d3                	mov    %edx,%ebx
  800b21:	89 d7                	mov    %edx,%edi
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	89 cb                	mov    %ecx,%ebx
  800b44:	89 cf                	mov    %ecx,%edi
  800b46:	89 ce                	mov    %ecx,%esi
  800b48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	7e 17                	jle    800b65 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	50                   	push   %eax
  800b52:	6a 03                	push   $0x3
  800b54:	68 5f 2a 80 00       	push   $0x802a5f
  800b59:	6a 23                	push   $0x23
  800b5b:	68 7c 2a 80 00       	push   $0x802a7c
  800b60:	e8 f4 16 00 00       	call   802259 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7d:	89 d1                	mov    %edx,%ecx
  800b7f:	89 d3                	mov    %edx,%ebx
  800b81:	89 d7                	mov    %edx,%edi
  800b83:	89 d6                	mov    %edx,%esi
  800b85:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <sys_yield>:

void
sys_yield(void)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9c:	89 d1                	mov    %edx,%ecx
  800b9e:	89 d3                	mov    %edx,%ebx
  800ba0:	89 d7                	mov    %edx,%edi
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	be 00 00 00 00       	mov    $0x0,%esi
  800bb9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc7:	89 f7                	mov    %esi,%edi
  800bc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 17                	jle    800be6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	50                   	push   %eax
  800bd3:	6a 04                	push   $0x4
  800bd5:	68 5f 2a 80 00       	push   $0x802a5f
  800bda:	6a 23                	push   $0x23
  800bdc:	68 7c 2a 80 00       	push   $0x802a7c
  800be1:	e8 73 16 00 00       	call   802259 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c08:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 17                	jle    800c28 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	50                   	push   %eax
  800c15:	6a 05                	push   $0x5
  800c17:	68 5f 2a 80 00       	push   $0x802a5f
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 7c 2a 80 00       	push   $0x802a7c
  800c23:	e8 31 16 00 00       	call   802259 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 df                	mov    %ebx,%edi
  800c4b:	89 de                	mov    %ebx,%esi
  800c4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 17                	jle    800c6a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 06                	push   $0x6
  800c59:	68 5f 2a 80 00       	push   $0x802a5f
  800c5e:	6a 23                	push   $0x23
  800c60:	68 7c 2a 80 00       	push   $0x802a7c
  800c65:	e8 ef 15 00 00       	call   802259 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c80:	b8 08 00 00 00       	mov    $0x8,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 df                	mov    %ebx,%edi
  800c8d:	89 de                	mov    %ebx,%esi
  800c8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 08                	push   $0x8
  800c9b:	68 5f 2a 80 00       	push   $0x802a5f
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 7c 2a 80 00       	push   $0x802a7c
  800ca7:	e8 ad 15 00 00       	call   802259 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 17                	jle    800cee <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 09                	push   $0x9
  800cdd:	68 5f 2a 80 00       	push   $0x802a5f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 7c 2a 80 00       	push   $0x802a7c
  800ce9:	e8 6b 15 00 00       	call   802259 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7e 17                	jle    800d30 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 0a                	push   $0xa
  800d1f:	68 5f 2a 80 00       	push   $0x802a5f
  800d24:	6a 23                	push   $0x23
  800d26:	68 7c 2a 80 00       	push   $0x802a7c
  800d2b:	e8 29 15 00 00       	call   802259 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	be 00 00 00 00       	mov    $0x0,%esi
  800d43:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d51:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d54:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d69:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	89 cb                	mov    %ecx,%ebx
  800d73:	89 cf                	mov    %ecx,%edi
  800d75:	89 ce                	mov    %ecx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 0d                	push   $0xd
  800d83:	68 5f 2a 80 00       	push   $0x802a5f
  800d88:	6a 23                	push   $0x23
  800d8a:	68 7c 2a 80 00       	push   $0x802a7c
  800d8f:	e8 c5 14 00 00       	call   802259 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	89 cb                	mov    %ecx,%ebx
  800db1:	89 cf                	mov    %ecx,%edi
  800db3:	89 ce                	mov    %ecx,%esi
  800db5:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 cb                	mov    %ecx,%ebx
  800dd1:	89 cf                	mov    %ecx,%edi
  800dd3:	89 ce                	mov    %ecx,%esi
  800dd5:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de7:	b8 10 00 00 00       	mov    $0x10,%eax
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	89 cb                	mov    %ecx,%ebx
  800df1:	89 cf                	mov    %ecx,%edi
  800df3:	89 ce                	mov    %ecx,%esi
  800df5:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	53                   	push   %ebx
  800e00:	83 ec 04             	sub    $0x4,%esp
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e06:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e08:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e0c:	74 11                	je     800e1f <pgfault+0x23>
  800e0e:	89 d8                	mov    %ebx,%eax
  800e10:	c1 e8 0c             	shr    $0xc,%eax
  800e13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1a:	f6 c4 08             	test   $0x8,%ah
  800e1d:	75 14                	jne    800e33 <pgfault+0x37>
		panic("faulting access");
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 8a 2a 80 00       	push   $0x802a8a
  800e27:	6a 1f                	push   $0x1f
  800e29:	68 9a 2a 80 00       	push   $0x802a9a
  800e2e:	e8 26 14 00 00       	call   802259 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	6a 07                	push   $0x7
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	6a 00                	push   $0x0
  800e3f:	e8 67 fd ff ff       	call   800bab <sys_page_alloc>
	if (r < 0) {
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	79 12                	jns    800e5d <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e4b:	50                   	push   %eax
  800e4c:	68 a5 2a 80 00       	push   $0x802aa5
  800e51:	6a 2d                	push   $0x2d
  800e53:	68 9a 2a 80 00       	push   $0x802a9a
  800e58:	e8 fc 13 00 00       	call   802259 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e5d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	68 00 10 00 00       	push   $0x1000
  800e6b:	53                   	push   %ebx
  800e6c:	68 00 f0 7f 00       	push   $0x7ff000
  800e71:	e8 2c fb ff ff       	call   8009a2 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e76:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e7d:	53                   	push   %ebx
  800e7e:	6a 00                	push   $0x0
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 62 fd ff ff       	call   800bee <sys_page_map>
	if (r < 0) {
  800e8c:	83 c4 20             	add    $0x20,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	79 12                	jns    800ea5 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e93:	50                   	push   %eax
  800e94:	68 a5 2a 80 00       	push   $0x802aa5
  800e99:	6a 34                	push   $0x34
  800e9b:	68 9a 2a 80 00       	push   $0x802a9a
  800ea0:	e8 b4 13 00 00       	call   802259 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	68 00 f0 7f 00       	push   $0x7ff000
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 7c fd ff ff       	call   800c30 <sys_page_unmap>
	if (r < 0) {
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	79 12                	jns    800ecd <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ebb:	50                   	push   %eax
  800ebc:	68 a5 2a 80 00       	push   $0x802aa5
  800ec1:	6a 38                	push   $0x38
  800ec3:	68 9a 2a 80 00       	push   $0x802a9a
  800ec8:	e8 8c 13 00 00       	call   802259 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800edb:	68 fc 0d 80 00       	push   $0x800dfc
  800ee0:	e8 ba 13 00 00       	call   80229f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eea:	cd 30                	int    $0x30
  800eec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 17                	jns    800f0d <fork+0x3b>
		panic("fork fault %e");
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	68 be 2a 80 00       	push   $0x802abe
  800efe:	68 85 00 00 00       	push   $0x85
  800f03:	68 9a 2a 80 00       	push   $0x802a9a
  800f08:	e8 4c 13 00 00       	call   802259 <_panic>
  800f0d:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f13:	75 24                	jne    800f39 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f15:	e8 53 fc ff ff       	call   800b6d <sys_getenvid>
  800f1a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1f:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800f25:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f2a:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f34:	e9 64 01 00 00       	jmp    80109d <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	6a 07                	push   $0x7
  800f3e:	68 00 f0 bf ee       	push   $0xeebff000
  800f43:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f46:	e8 60 fc ff ff       	call   800bab <sys_page_alloc>
  800f4b:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f53:	89 d8                	mov    %ebx,%eax
  800f55:	c1 e8 16             	shr    $0x16,%eax
  800f58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5f:	a8 01                	test   $0x1,%al
  800f61:	0f 84 fc 00 00 00    	je     801063 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	c1 e8 0c             	shr    $0xc,%eax
  800f6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f73:	f6 c2 01             	test   $0x1,%dl
  800f76:	0f 84 e7 00 00 00    	je     801063 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f7c:	89 c6                	mov    %eax,%esi
  800f7e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f88:	f6 c6 04             	test   $0x4,%dh
  800f8b:	74 39                	je     800fc6 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f8d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	25 07 0e 00 00       	and    $0xe07,%eax
  800f9c:	50                   	push   %eax
  800f9d:	56                   	push   %esi
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 47 fc ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	0f 89 b1 00 00 00    	jns    801063 <fork+0x191>
		    	panic("sys page map fault %e");
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	68 cc 2a 80 00       	push   $0x802acc
  800fba:	6a 55                	push   $0x55
  800fbc:	68 9a 2a 80 00       	push   $0x802a9a
  800fc1:	e8 93 12 00 00       	call   802259 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fc6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcd:	f6 c2 02             	test   $0x2,%dl
  800fd0:	75 0c                	jne    800fde <fork+0x10c>
  800fd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd9:	f6 c4 08             	test   $0x8,%ah
  800fdc:	74 5b                	je     801039 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	68 05 08 00 00       	push   $0x805
  800fe6:	56                   	push   %esi
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 fe fb ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  800ff0:	83 c4 20             	add    $0x20,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	79 14                	jns    80100b <fork+0x139>
		    	panic("sys page map fault %e");
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 cc 2a 80 00       	push   $0x802acc
  800fff:	6a 5c                	push   $0x5c
  801001:	68 9a 2a 80 00       	push   $0x802a9a
  801006:	e8 4e 12 00 00       	call   802259 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	68 05 08 00 00       	push   $0x805
  801013:	56                   	push   %esi
  801014:	6a 00                	push   $0x0
  801016:	56                   	push   %esi
  801017:	6a 00                	push   $0x0
  801019:	e8 d0 fb ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  80101e:	83 c4 20             	add    $0x20,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	79 3e                	jns    801063 <fork+0x191>
		    	panic("sys page map fault %e");
  801025:	83 ec 04             	sub    $0x4,%esp
  801028:	68 cc 2a 80 00       	push   $0x802acc
  80102d:	6a 60                	push   $0x60
  80102f:	68 9a 2a 80 00       	push   $0x802a9a
  801034:	e8 20 12 00 00       	call   802259 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	6a 05                	push   $0x5
  80103e:	56                   	push   %esi
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	6a 00                	push   $0x0
  801043:	e8 a6 fb ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  801048:	83 c4 20             	add    $0x20,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	79 14                	jns    801063 <fork+0x191>
		    	panic("sys page map fault %e");
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	68 cc 2a 80 00       	push   $0x802acc
  801057:	6a 65                	push   $0x65
  801059:	68 9a 2a 80 00       	push   $0x802a9a
  80105e:	e8 f6 11 00 00       	call   802259 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801063:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801069:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80106f:	0f 85 de fe ff ff    	jne    800f53 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801075:	a1 04 40 80 00       	mov    0x804004,%eax
  80107a:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	50                   	push   %eax
  801084:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801087:	57                   	push   %edi
  801088:	e8 69 fc ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80108d:	83 c4 08             	add    $0x8,%esp
  801090:	6a 02                	push   $0x2
  801092:	57                   	push   %edi
  801093:	e8 da fb ff ff       	call   800c72 <sys_env_set_status>
	
	return envid;
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80109d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <sfork>:

envid_t
sfork(void)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8010b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b8:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010bd:	68 56 01 80 00       	push   $0x800156
  8010c2:	e8 d5 fc ff ff       	call   800d9c <sys_thread_create>

	return id;
}
  8010c7:	c9                   	leave  
  8010c8:	c3                   	ret    

008010c9 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8010cf:	ff 75 08             	pushl  0x8(%ebp)
  8010d2:	e8 e5 fc ff ff       	call   800dbc <sys_thread_free>
}
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8010e2:	ff 75 08             	pushl  0x8(%ebp)
  8010e5:	e8 f2 fc ff ff       	call   800ddc <sys_thread_join>
}
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    

008010ef <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	6a 07                	push   $0x7
  8010ff:	6a 00                	push   $0x0
  801101:	56                   	push   %esi
  801102:	e8 a4 fa ff ff       	call   800bab <sys_page_alloc>
	if (r < 0) {
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	79 15                	jns    801123 <queue_append+0x34>
		panic("%e\n", r);
  80110e:	50                   	push   %eax
  80110f:	68 12 2b 80 00       	push   $0x802b12
  801114:	68 d5 00 00 00       	push   $0xd5
  801119:	68 9a 2a 80 00       	push   $0x802a9a
  80111e:	e8 36 11 00 00       	call   802259 <_panic>
	}	

	wt->envid = envid;
  801123:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801129:	83 3b 00             	cmpl   $0x0,(%ebx)
  80112c:	75 13                	jne    801141 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80112e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801135:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80113c:	00 00 00 
  80113f:	eb 1b                	jmp    80115c <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801141:	8b 43 04             	mov    0x4(%ebx),%eax
  801144:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80114b:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801152:	00 00 00 
		queue->last = wt;
  801155:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80115c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80116c:	8b 02                	mov    (%edx),%eax
  80116e:	85 c0                	test   %eax,%eax
  801170:	75 17                	jne    801189 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	68 e2 2a 80 00       	push   $0x802ae2
  80117a:	68 ec 00 00 00       	push   $0xec
  80117f:	68 9a 2a 80 00       	push   $0x802a9a
  801184:	e8 d0 10 00 00       	call   802259 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801189:	8b 48 04             	mov    0x4(%eax),%ecx
  80118c:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80118e:	8b 00                	mov    (%eax),%eax
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	53                   	push   %ebx
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80119c:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a1:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	74 45                	je     8011ed <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8011a8:	e8 c0 f9 ff ff       	call   800b6d <sys_getenvid>
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	83 c3 04             	add    $0x4,%ebx
  8011b3:	53                   	push   %ebx
  8011b4:	50                   	push   %eax
  8011b5:	e8 35 ff ff ff       	call   8010ef <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011ba:	e8 ae f9 ff ff       	call   800b6d <sys_getenvid>
  8011bf:	83 c4 08             	add    $0x8,%esp
  8011c2:	6a 04                	push   $0x4
  8011c4:	50                   	push   %eax
  8011c5:	e8 a8 fa ff ff       	call   800c72 <sys_env_set_status>

		if (r < 0) {
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	79 15                	jns    8011e6 <mutex_lock+0x54>
			panic("%e\n", r);
  8011d1:	50                   	push   %eax
  8011d2:	68 12 2b 80 00       	push   $0x802b12
  8011d7:	68 02 01 00 00       	push   $0x102
  8011dc:	68 9a 2a 80 00       	push   $0x802a9a
  8011e1:	e8 73 10 00 00       	call   802259 <_panic>
		}
		sys_yield();
  8011e6:	e8 a1 f9 ff ff       	call   800b8c <sys_yield>
  8011eb:	eb 08                	jmp    8011f5 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8011ed:	e8 7b f9 ff ff       	call   800b6d <sys_getenvid>
  8011f2:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801204:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801208:	74 36                	je     801240 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	8d 43 04             	lea    0x4(%ebx),%eax
  801210:	50                   	push   %eax
  801211:	e8 4d ff ff ff       	call   801163 <queue_pop>
  801216:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	6a 02                	push   $0x2
  80121e:	50                   	push   %eax
  80121f:	e8 4e fa ff ff       	call   800c72 <sys_env_set_status>
		if (r < 0) {
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	79 1d                	jns    801248 <mutex_unlock+0x4e>
			panic("%e\n", r);
  80122b:	50                   	push   %eax
  80122c:	68 12 2b 80 00       	push   $0x802b12
  801231:	68 16 01 00 00       	push   $0x116
  801236:	68 9a 2a 80 00       	push   $0x802a9a
  80123b:	e8 19 10 00 00       	call   802259 <_panic>
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  801248:	e8 3f f9 ff ff       	call   800b8c <sys_yield>
}
  80124d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80125c:	e8 0c f9 ff ff       	call   800b6d <sys_getenvid>
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	6a 07                	push   $0x7
  801266:	53                   	push   %ebx
  801267:	50                   	push   %eax
  801268:	e8 3e f9 ff ff       	call   800bab <sys_page_alloc>
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	79 15                	jns    801289 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801274:	50                   	push   %eax
  801275:	68 fd 2a 80 00       	push   $0x802afd
  80127a:	68 23 01 00 00       	push   $0x123
  80127f:	68 9a 2a 80 00       	push   $0x802a9a
  801284:	e8 d0 0f 00 00       	call   802259 <_panic>
	}	
	mtx->locked = 0;
  801289:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80128f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801296:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80129d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8012a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    

008012a9 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012b1:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012b4:	eb 20                	jmp    8012d6 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	56                   	push   %esi
  8012ba:	e8 a4 fe ff ff       	call   801163 <queue_pop>
  8012bf:	83 c4 08             	add    $0x8,%esp
  8012c2:	6a 02                	push   $0x2
  8012c4:	50                   	push   %eax
  8012c5:	e8 a8 f9 ff ff       	call   800c72 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8012ca:	8b 43 04             	mov    0x4(%ebx),%eax
  8012cd:	8b 40 04             	mov    0x4(%eax),%eax
  8012d0:	89 43 04             	mov    %eax,0x4(%ebx)
  8012d3:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012d6:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012da:	75 da                	jne    8012b6 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012dc:	83 ec 04             	sub    $0x4,%esp
  8012df:	68 00 10 00 00       	push   $0x1000
  8012e4:	6a 00                	push   $0x0
  8012e6:	53                   	push   %ebx
  8012e7:	e8 01 f6 ff ff       	call   8008ed <memset>
	mtx = NULL;
}
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f2:	5b                   	pop    %ebx
  8012f3:	5e                   	pop    %esi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ff:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801302:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801304:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801307:	83 3a 01             	cmpl   $0x1,(%edx)
  80130a:	7e 09                	jle    801315 <argstart+0x1f>
  80130c:	ba fc 2a 80 00       	mov    $0x802afc,%edx
  801311:	85 c9                	test   %ecx,%ecx
  801313:	75 05                	jne    80131a <argstart+0x24>
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80131d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <argnext>:

int
argnext(struct Argstate *args)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	53                   	push   %ebx
  80132a:	83 ec 04             	sub    $0x4,%esp
  80132d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801330:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801337:	8b 43 08             	mov    0x8(%ebx),%eax
  80133a:	85 c0                	test   %eax,%eax
  80133c:	74 6f                	je     8013ad <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  80133e:	80 38 00             	cmpb   $0x0,(%eax)
  801341:	75 4e                	jne    801391 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801343:	8b 0b                	mov    (%ebx),%ecx
  801345:	83 39 01             	cmpl   $0x1,(%ecx)
  801348:	74 55                	je     80139f <argnext+0x79>
		    || args->argv[1][0] != '-'
  80134a:	8b 53 04             	mov    0x4(%ebx),%edx
  80134d:	8b 42 04             	mov    0x4(%edx),%eax
  801350:	80 38 2d             	cmpb   $0x2d,(%eax)
  801353:	75 4a                	jne    80139f <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801355:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801359:	74 44                	je     80139f <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80135b:	83 c0 01             	add    $0x1,%eax
  80135e:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801361:	83 ec 04             	sub    $0x4,%esp
  801364:	8b 01                	mov    (%ecx),%eax
  801366:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80136d:	50                   	push   %eax
  80136e:	8d 42 08             	lea    0x8(%edx),%eax
  801371:	50                   	push   %eax
  801372:	83 c2 04             	add    $0x4,%edx
  801375:	52                   	push   %edx
  801376:	e8 bf f5 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  80137b:	8b 03                	mov    (%ebx),%eax
  80137d:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801380:	8b 43 08             	mov    0x8(%ebx),%eax
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	80 38 2d             	cmpb   $0x2d,(%eax)
  801389:	75 06                	jne    801391 <argnext+0x6b>
  80138b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80138f:	74 0e                	je     80139f <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801391:	8b 53 08             	mov    0x8(%ebx),%edx
  801394:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801397:	83 c2 01             	add    $0x1,%edx
  80139a:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80139d:	eb 13                	jmp    8013b2 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80139f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8013a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013ab:	eb 05                	jmp    8013b2 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8013ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8013b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 04             	sub    $0x4,%esp
  8013be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8013c1:	8b 43 08             	mov    0x8(%ebx),%eax
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	74 58                	je     801420 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8013c8:	80 38 00             	cmpb   $0x0,(%eax)
  8013cb:	74 0c                	je     8013d9 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8013cd:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8013d0:	c7 43 08 fc 2a 80 00 	movl   $0x802afc,0x8(%ebx)
  8013d7:	eb 42                	jmp    80141b <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8013d9:	8b 13                	mov    (%ebx),%edx
  8013db:	83 3a 01             	cmpl   $0x1,(%edx)
  8013de:	7e 2d                	jle    80140d <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8013e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8013e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8013e6:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8013e9:	83 ec 04             	sub    $0x4,%esp
  8013ec:	8b 12                	mov    (%edx),%edx
  8013ee:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8013f5:	52                   	push   %edx
  8013f6:	8d 50 08             	lea    0x8(%eax),%edx
  8013f9:	52                   	push   %edx
  8013fa:	83 c0 04             	add    $0x4,%eax
  8013fd:	50                   	push   %eax
  8013fe:	e8 37 f5 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  801403:	8b 03                	mov    (%ebx),%eax
  801405:	83 28 01             	subl   $0x1,(%eax)
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	eb 0e                	jmp    80141b <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80140d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801414:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80141b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80141e:	eb 05                	jmp    801425 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801420:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801433:	8b 51 0c             	mov    0xc(%ecx),%edx
  801436:	89 d0                	mov    %edx,%eax
  801438:	85 d2                	test   %edx,%edx
  80143a:	75 0c                	jne    801448 <argvalue+0x1e>
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	51                   	push   %ecx
  801440:	e8 72 ff ff ff       	call   8013b7 <argnextvalue>
  801445:	83 c4 10             	add    $0x10,%esp
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80144d:	8b 45 08             	mov    0x8(%ebp),%eax
  801450:	05 00 00 00 30       	add    $0x30000000,%eax
  801455:	c1 e8 0c             	shr    $0xc,%eax
}
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	05 00 00 00 30       	add    $0x30000000,%eax
  801465:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80146a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801477:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80147c:	89 c2                	mov    %eax,%edx
  80147e:	c1 ea 16             	shr    $0x16,%edx
  801481:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801488:	f6 c2 01             	test   $0x1,%dl
  80148b:	74 11                	je     80149e <fd_alloc+0x2d>
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	c1 ea 0c             	shr    $0xc,%edx
  801492:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801499:	f6 c2 01             	test   $0x1,%dl
  80149c:	75 09                	jne    8014a7 <fd_alloc+0x36>
			*fd_store = fd;
  80149e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a5:	eb 17                	jmp    8014be <fd_alloc+0x4d>
  8014a7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014ac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014b1:	75 c9                	jne    80147c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014b3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014b9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014c6:	83 f8 1f             	cmp    $0x1f,%eax
  8014c9:	77 36                	ja     801501 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014cb:	c1 e0 0c             	shl    $0xc,%eax
  8014ce:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	c1 ea 16             	shr    $0x16,%edx
  8014d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014df:	f6 c2 01             	test   $0x1,%dl
  8014e2:	74 24                	je     801508 <fd_lookup+0x48>
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	c1 ea 0c             	shr    $0xc,%edx
  8014e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f0:	f6 c2 01             	test   $0x1,%dl
  8014f3:	74 1a                	je     80150f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f8:	89 02                	mov    %eax,(%edx)
	return 0;
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ff:	eb 13                	jmp    801514 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801501:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801506:	eb 0c                	jmp    801514 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801508:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150d:	eb 05                	jmp    801514 <fd_lookup+0x54>
  80150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151f:	ba 94 2b 80 00       	mov    $0x802b94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801524:	eb 13                	jmp    801539 <dev_lookup+0x23>
  801526:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801529:	39 08                	cmp    %ecx,(%eax)
  80152b:	75 0c                	jne    801539 <dev_lookup+0x23>
			*dev = devtab[i];
  80152d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801530:	89 01                	mov    %eax,(%ecx)
			return 0;
  801532:	b8 00 00 00 00       	mov    $0x0,%eax
  801537:	eb 31                	jmp    80156a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801539:	8b 02                	mov    (%edx),%eax
  80153b:	85 c0                	test   %eax,%eax
  80153d:	75 e7                	jne    801526 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80153f:	a1 04 40 80 00       	mov    0x804004,%eax
  801544:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	51                   	push   %ecx
  80154e:	50                   	push   %eax
  80154f:	68 18 2b 80 00       	push   $0x802b18
  801554:	e8 ca ec ff ff       	call   800223 <cprintf>
	*dev = 0;
  801559:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	56                   	push   %esi
  801570:	53                   	push   %ebx
  801571:	83 ec 10             	sub    $0x10,%esp
  801574:	8b 75 08             	mov    0x8(%ebp),%esi
  801577:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801584:	c1 e8 0c             	shr    $0xc,%eax
  801587:	50                   	push   %eax
  801588:	e8 33 ff ff ff       	call   8014c0 <fd_lookup>
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 05                	js     801599 <fd_close+0x2d>
	    || fd != fd2)
  801594:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801597:	74 0c                	je     8015a5 <fd_close+0x39>
		return (must_exist ? r : 0);
  801599:	84 db                	test   %bl,%bl
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	0f 44 c2             	cmove  %edx,%eax
  8015a3:	eb 41                	jmp    8015e6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	ff 36                	pushl  (%esi)
  8015ae:	e8 63 ff ff ff       	call   801516 <dev_lookup>
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 1a                	js     8015d6 <fd_close+0x6a>
		if (dev->dev_close)
  8015bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	74 0b                	je     8015d6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015cb:	83 ec 0c             	sub    $0xc,%esp
  8015ce:	56                   	push   %esi
  8015cf:	ff d0                	call   *%eax
  8015d1:	89 c3                	mov    %eax,%ebx
  8015d3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	56                   	push   %esi
  8015da:	6a 00                	push   $0x0
  8015dc:	e8 4f f6 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	89 d8                	mov    %ebx,%eax
}
  8015e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	ff 75 08             	pushl  0x8(%ebp)
  8015fa:	e8 c1 fe ff ff       	call   8014c0 <fd_lookup>
  8015ff:	83 c4 08             	add    $0x8,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 10                	js     801616 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	6a 01                	push   $0x1
  80160b:	ff 75 f4             	pushl  -0xc(%ebp)
  80160e:	e8 59 ff ff ff       	call   80156c <fd_close>
  801613:	83 c4 10             	add    $0x10,%esp
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <close_all>:

void
close_all(void)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	53                   	push   %ebx
  80161c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80161f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801624:	83 ec 0c             	sub    $0xc,%esp
  801627:	53                   	push   %ebx
  801628:	e8 c0 ff ff ff       	call   8015ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80162d:	83 c3 01             	add    $0x1,%ebx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	83 fb 20             	cmp    $0x20,%ebx
  801636:	75 ec                	jne    801624 <close_all+0xc>
		close(i);
}
  801638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	57                   	push   %edi
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	83 ec 2c             	sub    $0x2c,%esp
  801646:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801649:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	ff 75 08             	pushl  0x8(%ebp)
  801650:	e8 6b fe ff ff       	call   8014c0 <fd_lookup>
  801655:	83 c4 08             	add    $0x8,%esp
  801658:	85 c0                	test   %eax,%eax
  80165a:	0f 88 c1 00 00 00    	js     801721 <dup+0xe4>
		return r;
	close(newfdnum);
  801660:	83 ec 0c             	sub    $0xc,%esp
  801663:	56                   	push   %esi
  801664:	e8 84 ff ff ff       	call   8015ed <close>

	newfd = INDEX2FD(newfdnum);
  801669:	89 f3                	mov    %esi,%ebx
  80166b:	c1 e3 0c             	shl    $0xc,%ebx
  80166e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801674:	83 c4 04             	add    $0x4,%esp
  801677:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167a:	e8 db fd ff ff       	call   80145a <fd2data>
  80167f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801681:	89 1c 24             	mov    %ebx,(%esp)
  801684:	e8 d1 fd ff ff       	call   80145a <fd2data>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80168f:	89 f8                	mov    %edi,%eax
  801691:	c1 e8 16             	shr    $0x16,%eax
  801694:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169b:	a8 01                	test   $0x1,%al
  80169d:	74 37                	je     8016d6 <dup+0x99>
  80169f:	89 f8                	mov    %edi,%eax
  8016a1:	c1 e8 0c             	shr    $0xc,%eax
  8016a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ab:	f6 c2 01             	test   $0x1,%dl
  8016ae:	74 26                	je     8016d6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b7:	83 ec 0c             	sub    $0xc,%esp
  8016ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016c3:	6a 00                	push   $0x0
  8016c5:	57                   	push   %edi
  8016c6:	6a 00                	push   $0x0
  8016c8:	e8 21 f5 ff ff       	call   800bee <sys_page_map>
  8016cd:	89 c7                	mov    %eax,%edi
  8016cf:	83 c4 20             	add    $0x20,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 2e                	js     801704 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d9:	89 d0                	mov    %edx,%eax
  8016db:	c1 e8 0c             	shr    $0xc,%eax
  8016de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e5:	83 ec 0c             	sub    $0xc,%esp
  8016e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ed:	50                   	push   %eax
  8016ee:	53                   	push   %ebx
  8016ef:	6a 00                	push   $0x0
  8016f1:	52                   	push   %edx
  8016f2:	6a 00                	push   $0x0
  8016f4:	e8 f5 f4 ff ff       	call   800bee <sys_page_map>
  8016f9:	89 c7                	mov    %eax,%edi
  8016fb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016fe:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801700:	85 ff                	test   %edi,%edi
  801702:	79 1d                	jns    801721 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	53                   	push   %ebx
  801708:	6a 00                	push   $0x0
  80170a:	e8 21 f5 ff ff       	call   800c30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80170f:	83 c4 08             	add    $0x8,%esp
  801712:	ff 75 d4             	pushl  -0x2c(%ebp)
  801715:	6a 00                	push   $0x0
  801717:	e8 14 f5 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	89 f8                	mov    %edi,%eax
}
  801721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801724:	5b                   	pop    %ebx
  801725:	5e                   	pop    %esi
  801726:	5f                   	pop    %edi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	83 ec 14             	sub    $0x14,%esp
  801730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	53                   	push   %ebx
  801738:	e8 83 fd ff ff       	call   8014c0 <fd_lookup>
  80173d:	83 c4 08             	add    $0x8,%esp
  801740:	89 c2                	mov    %eax,%edx
  801742:	85 c0                	test   %eax,%eax
  801744:	78 70                	js     8017b6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801750:	ff 30                	pushl  (%eax)
  801752:	e8 bf fd ff ff       	call   801516 <dev_lookup>
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 4f                	js     8017ad <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80175e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801761:	8b 42 08             	mov    0x8(%edx),%eax
  801764:	83 e0 03             	and    $0x3,%eax
  801767:	83 f8 01             	cmp    $0x1,%eax
  80176a:	75 24                	jne    801790 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80176c:	a1 04 40 80 00       	mov    0x804004,%eax
  801771:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801777:	83 ec 04             	sub    $0x4,%esp
  80177a:	53                   	push   %ebx
  80177b:	50                   	push   %eax
  80177c:	68 59 2b 80 00       	push   $0x802b59
  801781:	e8 9d ea ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80178e:	eb 26                	jmp    8017b6 <read+0x8d>
	}
	if (!dev->dev_read)
  801790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801793:	8b 40 08             	mov    0x8(%eax),%eax
  801796:	85 c0                	test   %eax,%eax
  801798:	74 17                	je     8017b1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	ff 75 10             	pushl  0x10(%ebp)
  8017a0:	ff 75 0c             	pushl  0xc(%ebp)
  8017a3:	52                   	push   %edx
  8017a4:	ff d0                	call   *%eax
  8017a6:	89 c2                	mov    %eax,%edx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	eb 09                	jmp    8017b6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ad:	89 c2                	mov    %eax,%edx
  8017af:	eb 05                	jmp    8017b6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017b6:	89 d0                	mov    %edx,%eax
  8017b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	57                   	push   %edi
  8017c1:	56                   	push   %esi
  8017c2:	53                   	push   %ebx
  8017c3:	83 ec 0c             	sub    $0xc,%esp
  8017c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d1:	eb 21                	jmp    8017f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017d3:	83 ec 04             	sub    $0x4,%esp
  8017d6:	89 f0                	mov    %esi,%eax
  8017d8:	29 d8                	sub    %ebx,%eax
  8017da:	50                   	push   %eax
  8017db:	89 d8                	mov    %ebx,%eax
  8017dd:	03 45 0c             	add    0xc(%ebp),%eax
  8017e0:	50                   	push   %eax
  8017e1:	57                   	push   %edi
  8017e2:	e8 42 ff ff ff       	call   801729 <read>
		if (m < 0)
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 10                	js     8017fe <readn+0x41>
			return m;
		if (m == 0)
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	74 0a                	je     8017fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017f2:	01 c3                	add    %eax,%ebx
  8017f4:	39 f3                	cmp    %esi,%ebx
  8017f6:	72 db                	jb     8017d3 <readn+0x16>
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	eb 02                	jmp    8017fe <readn+0x41>
  8017fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801801:	5b                   	pop    %ebx
  801802:	5e                   	pop    %esi
  801803:	5f                   	pop    %edi
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	53                   	push   %ebx
  80180a:	83 ec 14             	sub    $0x14,%esp
  80180d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801810:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801813:	50                   	push   %eax
  801814:	53                   	push   %ebx
  801815:	e8 a6 fc ff ff       	call   8014c0 <fd_lookup>
  80181a:	83 c4 08             	add    $0x8,%esp
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 6b                	js     80188e <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801829:	50                   	push   %eax
  80182a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182d:	ff 30                	pushl  (%eax)
  80182f:	e8 e2 fc ff ff       	call   801516 <dev_lookup>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	78 4a                	js     801885 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80183b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801842:	75 24                	jne    801868 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801844:	a1 04 40 80 00       	mov    0x804004,%eax
  801849:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80184f:	83 ec 04             	sub    $0x4,%esp
  801852:	53                   	push   %ebx
  801853:	50                   	push   %eax
  801854:	68 75 2b 80 00       	push   $0x802b75
  801859:	e8 c5 e9 ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801866:	eb 26                	jmp    80188e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801868:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186b:	8b 52 0c             	mov    0xc(%edx),%edx
  80186e:	85 d2                	test   %edx,%edx
  801870:	74 17                	je     801889 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	ff 75 10             	pushl  0x10(%ebp)
  801878:	ff 75 0c             	pushl  0xc(%ebp)
  80187b:	50                   	push   %eax
  80187c:	ff d2                	call   *%edx
  80187e:	89 c2                	mov    %eax,%edx
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	eb 09                	jmp    80188e <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801885:	89 c2                	mov    %eax,%edx
  801887:	eb 05                	jmp    80188e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801889:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80188e:	89 d0                	mov    %edx,%eax
  801890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <seek>:

int
seek(int fdnum, off_t offset)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80189b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80189e:	50                   	push   %eax
  80189f:	ff 75 08             	pushl  0x8(%ebp)
  8018a2:	e8 19 fc ff ff       	call   8014c0 <fd_lookup>
  8018a7:	83 c4 08             	add    $0x8,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 0e                	js     8018bc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 14             	sub    $0x14,%esp
  8018c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cb:	50                   	push   %eax
  8018cc:	53                   	push   %ebx
  8018cd:	e8 ee fb ff ff       	call   8014c0 <fd_lookup>
  8018d2:	83 c4 08             	add    $0x8,%esp
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 68                	js     801943 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e5:	ff 30                	pushl  (%eax)
  8018e7:	e8 2a fc ff ff       	call   801516 <dev_lookup>
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 47                	js     80193a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018fa:	75 24                	jne    801920 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018fc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801901:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	53                   	push   %ebx
  80190b:	50                   	push   %eax
  80190c:	68 38 2b 80 00       	push   $0x802b38
  801911:	e8 0d e9 ff ff       	call   800223 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80191e:	eb 23                	jmp    801943 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801920:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801923:	8b 52 18             	mov    0x18(%edx),%edx
  801926:	85 d2                	test   %edx,%edx
  801928:	74 14                	je     80193e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	ff 75 0c             	pushl  0xc(%ebp)
  801930:	50                   	push   %eax
  801931:	ff d2                	call   *%edx
  801933:	89 c2                	mov    %eax,%edx
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	eb 09                	jmp    801943 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193a:	89 c2                	mov    %eax,%edx
  80193c:	eb 05                	jmp    801943 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80193e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801943:	89 d0                	mov    %edx,%eax
  801945:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 14             	sub    $0x14,%esp
  801951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801954:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801957:	50                   	push   %eax
  801958:	ff 75 08             	pushl  0x8(%ebp)
  80195b:	e8 60 fb ff ff       	call   8014c0 <fd_lookup>
  801960:	83 c4 08             	add    $0x8,%esp
  801963:	89 c2                	mov    %eax,%edx
  801965:	85 c0                	test   %eax,%eax
  801967:	78 58                	js     8019c1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196f:	50                   	push   %eax
  801970:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801973:	ff 30                	pushl  (%eax)
  801975:	e8 9c fb ff ff       	call   801516 <dev_lookup>
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 37                	js     8019b8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801981:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801984:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801988:	74 32                	je     8019bc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80198a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80198d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801994:	00 00 00 
	stat->st_isdir = 0;
  801997:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80199e:	00 00 00 
	stat->st_dev = dev;
  8019a1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019a7:	83 ec 08             	sub    $0x8,%esp
  8019aa:	53                   	push   %ebx
  8019ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ae:	ff 50 14             	call   *0x14(%eax)
  8019b1:	89 c2                	mov    %eax,%edx
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	eb 09                	jmp    8019c1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b8:	89 c2                	mov    %eax,%edx
  8019ba:	eb 05                	jmp    8019c1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019c1:	89 d0                	mov    %edx,%eax
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	6a 00                	push   $0x0
  8019d2:	ff 75 08             	pushl  0x8(%ebp)
  8019d5:	e8 e3 01 00 00       	call   801bbd <open>
  8019da:	89 c3                	mov    %eax,%ebx
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	78 1b                	js     8019fe <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019e3:	83 ec 08             	sub    $0x8,%esp
  8019e6:	ff 75 0c             	pushl  0xc(%ebp)
  8019e9:	50                   	push   %eax
  8019ea:	e8 5b ff ff ff       	call   80194a <fstat>
  8019ef:	89 c6                	mov    %eax,%esi
	close(fd);
  8019f1:	89 1c 24             	mov    %ebx,(%esp)
  8019f4:	e8 f4 fb ff ff       	call   8015ed <close>
	return r;
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	89 f0                	mov    %esi,%eax
}
  8019fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	56                   	push   %esi
  801a09:	53                   	push   %ebx
  801a0a:	89 c6                	mov    %eax,%esi
  801a0c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a0e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a15:	75 12                	jne    801a29 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	6a 01                	push   $0x1
  801a1c:	e8 ea 09 00 00       	call   80240b <ipc_find_env>
  801a21:	a3 00 40 80 00       	mov    %eax,0x804000
  801a26:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a29:	6a 07                	push   $0x7
  801a2b:	68 00 50 80 00       	push   $0x805000
  801a30:	56                   	push   %esi
  801a31:	ff 35 00 40 80 00    	pushl  0x804000
  801a37:	e8 6d 09 00 00       	call   8023a9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a3c:	83 c4 0c             	add    $0xc,%esp
  801a3f:	6a 00                	push   $0x0
  801a41:	53                   	push   %ebx
  801a42:	6a 00                	push   $0x0
  801a44:	e8 e5 08 00 00       	call   80232e <ipc_recv>
}
  801a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a64:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a69:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6e:	b8 02 00 00 00       	mov    $0x2,%eax
  801a73:	e8 8d ff ff ff       	call   801a05 <fsipc>
}
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	8b 40 0c             	mov    0xc(%eax),%eax
  801a86:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a90:	b8 06 00 00 00       	mov    $0x6,%eax
  801a95:	e8 6b ff ff ff       	call   801a05 <fsipc>
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 04             	sub    $0x4,%esp
  801aa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	8b 40 0c             	mov    0xc(%eax),%eax
  801aac:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab6:	b8 05 00 00 00       	mov    $0x5,%eax
  801abb:	e8 45 ff ff ff       	call   801a05 <fsipc>
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 2c                	js     801af0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac4:	83 ec 08             	sub    $0x8,%esp
  801ac7:	68 00 50 80 00       	push   $0x805000
  801acc:	53                   	push   %ebx
  801acd:	e8 d6 ec ff ff       	call   8007a8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ad2:	a1 80 50 80 00       	mov    0x805080,%eax
  801ad7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801add:	a1 84 50 80 00       	mov    0x805084,%eax
  801ae2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801afe:	8b 55 08             	mov    0x8(%ebp),%edx
  801b01:	8b 52 0c             	mov    0xc(%edx),%edx
  801b04:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b0a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b0f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b14:	0f 47 c2             	cmova  %edx,%eax
  801b17:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b1c:	50                   	push   %eax
  801b1d:	ff 75 0c             	pushl  0xc(%ebp)
  801b20:	68 08 50 80 00       	push   $0x805008
  801b25:	e8 10 ee ff ff       	call   80093a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	b8 04 00 00 00       	mov    $0x4,%eax
  801b34:	e8 cc fe ff ff       	call   801a05 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b43:	8b 45 08             	mov    0x8(%ebp),%eax
  801b46:	8b 40 0c             	mov    0xc(%eax),%eax
  801b49:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b4e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b54:	ba 00 00 00 00       	mov    $0x0,%edx
  801b59:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5e:	e8 a2 fe ff ff       	call   801a05 <fsipc>
  801b63:	89 c3                	mov    %eax,%ebx
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 4b                	js     801bb4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b69:	39 c6                	cmp    %eax,%esi
  801b6b:	73 16                	jae    801b83 <devfile_read+0x48>
  801b6d:	68 a4 2b 80 00       	push   $0x802ba4
  801b72:	68 ab 2b 80 00       	push   $0x802bab
  801b77:	6a 7c                	push   $0x7c
  801b79:	68 c0 2b 80 00       	push   $0x802bc0
  801b7e:	e8 d6 06 00 00       	call   802259 <_panic>
	assert(r <= PGSIZE);
  801b83:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b88:	7e 16                	jle    801ba0 <devfile_read+0x65>
  801b8a:	68 cb 2b 80 00       	push   $0x802bcb
  801b8f:	68 ab 2b 80 00       	push   $0x802bab
  801b94:	6a 7d                	push   $0x7d
  801b96:	68 c0 2b 80 00       	push   $0x802bc0
  801b9b:	e8 b9 06 00 00       	call   802259 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	50                   	push   %eax
  801ba4:	68 00 50 80 00       	push   $0x805000
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	e8 89 ed ff ff       	call   80093a <memmove>
	return r;
  801bb1:	83 c4 10             	add    $0x10,%esp
}
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 20             	sub    $0x20,%esp
  801bc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bc7:	53                   	push   %ebx
  801bc8:	e8 a2 eb ff ff       	call   80076f <strlen>
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd5:	7f 67                	jg     801c3e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	e8 8e f8 ff ff       	call   801471 <fd_alloc>
  801be3:	83 c4 10             	add    $0x10,%esp
		return r;
  801be6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801be8:	85 c0                	test   %eax,%eax
  801bea:	78 57                	js     801c43 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bec:	83 ec 08             	sub    $0x8,%esp
  801bef:	53                   	push   %ebx
  801bf0:	68 00 50 80 00       	push   $0x805000
  801bf5:	e8 ae eb ff ff       	call   8007a8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c05:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0a:	e8 f6 fd ff ff       	call   801a05 <fsipc>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	85 c0                	test   %eax,%eax
  801c16:	79 14                	jns    801c2c <open+0x6f>
		fd_close(fd, 0);
  801c18:	83 ec 08             	sub    $0x8,%esp
  801c1b:	6a 00                	push   $0x0
  801c1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c20:	e8 47 f9 ff ff       	call   80156c <fd_close>
		return r;
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	89 da                	mov    %ebx,%edx
  801c2a:	eb 17                	jmp    801c43 <open+0x86>
	}

	return fd2num(fd);
  801c2c:	83 ec 0c             	sub    $0xc,%esp
  801c2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c32:	e8 13 f8 ff ff       	call   80144a <fd2num>
  801c37:	89 c2                	mov    %eax,%edx
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	eb 05                	jmp    801c43 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c3e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c43:	89 d0                	mov    %edx,%eax
  801c45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c50:	ba 00 00 00 00       	mov    $0x0,%edx
  801c55:	b8 08 00 00 00       	mov    $0x8,%eax
  801c5a:	e8 a6 fd ff ff       	call   801a05 <fsipc>
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801c61:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801c65:	7e 37                	jle    801c9e <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	53                   	push   %ebx
  801c6b:	83 ec 08             	sub    $0x8,%esp
  801c6e:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801c70:	ff 70 04             	pushl  0x4(%eax)
  801c73:	8d 40 10             	lea    0x10(%eax),%eax
  801c76:	50                   	push   %eax
  801c77:	ff 33                	pushl  (%ebx)
  801c79:	e8 88 fb ff ff       	call   801806 <write>
		if (result > 0)
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	7e 03                	jle    801c88 <writebuf+0x27>
			b->result += result;
  801c85:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801c88:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c8b:	74 0d                	je     801c9a <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c94:	0f 4f c2             	cmovg  %edx,%eax
  801c97:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801c9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9d:	c9                   	leave  
  801c9e:	f3 c3                	repz ret 

00801ca0 <putch>:

static void
putch(int ch, void *thunk)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 04             	sub    $0x4,%esp
  801ca7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801caa:	8b 53 04             	mov    0x4(%ebx),%edx
  801cad:	8d 42 01             	lea    0x1(%edx),%eax
  801cb0:	89 43 04             	mov    %eax,0x4(%ebx)
  801cb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb6:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801cba:	3d 00 01 00 00       	cmp    $0x100,%eax
  801cbf:	75 0e                	jne    801ccf <putch+0x2f>
		writebuf(b);
  801cc1:	89 d8                	mov    %ebx,%eax
  801cc3:	e8 99 ff ff ff       	call   801c61 <writebuf>
		b->idx = 0;
  801cc8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ccf:	83 c4 04             	add    $0x4,%esp
  801cd2:	5b                   	pop    %ebx
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801ce7:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801cee:	00 00 00 
	b.result = 0;
  801cf1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801cf8:	00 00 00 
	b.error = 1;
  801cfb:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801d02:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801d05:	ff 75 10             	pushl  0x10(%ebp)
  801d08:	ff 75 0c             	pushl  0xc(%ebp)
  801d0b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	68 a0 1c 80 00       	push   $0x801ca0
  801d17:	e8 3e e6 ff ff       	call   80035a <vprintfmt>
	if (b.idx > 0)
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801d26:	7e 0b                	jle    801d33 <vfprintf+0x5e>
		writebuf(&b);
  801d28:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801d2e:	e8 2e ff ff ff       	call   801c61 <writebuf>

	return (b.result ? b.result : b.error);
  801d33:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d4a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801d4d:	50                   	push   %eax
  801d4e:	ff 75 0c             	pushl  0xc(%ebp)
  801d51:	ff 75 08             	pushl  0x8(%ebp)
  801d54:	e8 7c ff ff ff       	call   801cd5 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <printf>:

int
printf(const char *fmt, ...)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d61:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801d64:	50                   	push   %eax
  801d65:	ff 75 08             	pushl  0x8(%ebp)
  801d68:	6a 01                	push   $0x1
  801d6a:	e8 66 ff ff ff       	call   801cd5 <vfprintf>
	va_end(ap);

	return cnt;
}
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	56                   	push   %esi
  801d75:	53                   	push   %ebx
  801d76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	ff 75 08             	pushl  0x8(%ebp)
  801d7f:	e8 d6 f6 ff ff       	call   80145a <fd2data>
  801d84:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d86:	83 c4 08             	add    $0x8,%esp
  801d89:	68 d7 2b 80 00       	push   $0x802bd7
  801d8e:	53                   	push   %ebx
  801d8f:	e8 14 ea ff ff       	call   8007a8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d94:	8b 46 04             	mov    0x4(%esi),%eax
  801d97:	2b 06                	sub    (%esi),%eax
  801d99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d9f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801da6:	00 00 00 
	stat->st_dev = &devpipe;
  801da9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801db0:	30 80 00 
	return 0;
}
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
  801db8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	53                   	push   %ebx
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc9:	53                   	push   %ebx
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 5f ee ff ff       	call   800c30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dd1:	89 1c 24             	mov    %ebx,(%esp)
  801dd4:	e8 81 f6 ff ff       	call   80145a <fd2data>
  801dd9:	83 c4 08             	add    $0x8,%esp
  801ddc:	50                   	push   %eax
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 4c ee ff ff       	call   800c30 <sys_page_unmap>
}
  801de4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	57                   	push   %edi
  801ded:	56                   	push   %esi
  801dee:	53                   	push   %ebx
  801def:	83 ec 1c             	sub    $0x1c,%esp
  801df2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801df5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801df7:	a1 04 40 80 00       	mov    0x804004,%eax
  801dfc:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	ff 75 e0             	pushl  -0x20(%ebp)
  801e08:	e8 43 06 00 00       	call   802450 <pageref>
  801e0d:	89 c3                	mov    %eax,%ebx
  801e0f:	89 3c 24             	mov    %edi,(%esp)
  801e12:	e8 39 06 00 00       	call   802450 <pageref>
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	39 c3                	cmp    %eax,%ebx
  801e1c:	0f 94 c1             	sete   %cl
  801e1f:	0f b6 c9             	movzbl %cl,%ecx
  801e22:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e25:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e2b:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801e31:	39 ce                	cmp    %ecx,%esi
  801e33:	74 1e                	je     801e53 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801e35:	39 c3                	cmp    %eax,%ebx
  801e37:	75 be                	jne    801df7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e39:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801e3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e42:	50                   	push   %eax
  801e43:	56                   	push   %esi
  801e44:	68 de 2b 80 00       	push   $0x802bde
  801e49:	e8 d5 e3 ff ff       	call   800223 <cprintf>
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	eb a4                	jmp    801df7 <_pipeisclosed+0xe>
	}
}
  801e53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e59:	5b                   	pop    %ebx
  801e5a:	5e                   	pop    %esi
  801e5b:	5f                   	pop    %edi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 28             	sub    $0x28,%esp
  801e67:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e6a:	56                   	push   %esi
  801e6b:	e8 ea f5 ff ff       	call   80145a <fd2data>
  801e70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	bf 00 00 00 00       	mov    $0x0,%edi
  801e7a:	eb 4b                	jmp    801ec7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e7c:	89 da                	mov    %ebx,%edx
  801e7e:	89 f0                	mov    %esi,%eax
  801e80:	e8 64 ff ff ff       	call   801de9 <_pipeisclosed>
  801e85:	85 c0                	test   %eax,%eax
  801e87:	75 48                	jne    801ed1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e89:	e8 fe ec ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e8e:	8b 43 04             	mov    0x4(%ebx),%eax
  801e91:	8b 0b                	mov    (%ebx),%ecx
  801e93:	8d 51 20             	lea    0x20(%ecx),%edx
  801e96:	39 d0                	cmp    %edx,%eax
  801e98:	73 e2                	jae    801e7c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e9d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ea1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ea4:	89 c2                	mov    %eax,%edx
  801ea6:	c1 fa 1f             	sar    $0x1f,%edx
  801ea9:	89 d1                	mov    %edx,%ecx
  801eab:	c1 e9 1b             	shr    $0x1b,%ecx
  801eae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801eb1:	83 e2 1f             	and    $0x1f,%edx
  801eb4:	29 ca                	sub    %ecx,%edx
  801eb6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ebe:	83 c0 01             	add    $0x1,%eax
  801ec1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec4:	83 c7 01             	add    $0x1,%edi
  801ec7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eca:	75 c2                	jne    801e8e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ecc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecf:	eb 05                	jmp    801ed6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ed1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	5f                   	pop    %edi
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 18             	sub    $0x18,%esp
  801ee7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801eea:	57                   	push   %edi
  801eeb:	e8 6a f5 ff ff       	call   80145a <fd2data>
  801ef0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801efa:	eb 3d                	jmp    801f39 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801efc:	85 db                	test   %ebx,%ebx
  801efe:	74 04                	je     801f04 <devpipe_read+0x26>
				return i;
  801f00:	89 d8                	mov    %ebx,%eax
  801f02:	eb 44                	jmp    801f48 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f04:	89 f2                	mov    %esi,%edx
  801f06:	89 f8                	mov    %edi,%eax
  801f08:	e8 dc fe ff ff       	call   801de9 <_pipeisclosed>
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	75 32                	jne    801f43 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f11:	e8 76 ec ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f16:	8b 06                	mov    (%esi),%eax
  801f18:	3b 46 04             	cmp    0x4(%esi),%eax
  801f1b:	74 df                	je     801efc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f1d:	99                   	cltd   
  801f1e:	c1 ea 1b             	shr    $0x1b,%edx
  801f21:	01 d0                	add    %edx,%eax
  801f23:	83 e0 1f             	and    $0x1f,%eax
  801f26:	29 d0                	sub    %edx,%eax
  801f28:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f30:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f33:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f36:	83 c3 01             	add    $0x1,%ebx
  801f39:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f3c:	75 d8                	jne    801f16 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801f41:	eb 05                	jmp    801f48 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f43:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4b:	5b                   	pop    %ebx
  801f4c:	5e                   	pop    %esi
  801f4d:	5f                   	pop    %edi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	56                   	push   %esi
  801f54:	53                   	push   %ebx
  801f55:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5b:	50                   	push   %eax
  801f5c:	e8 10 f5 ff ff       	call   801471 <fd_alloc>
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	89 c2                	mov    %eax,%edx
  801f66:	85 c0                	test   %eax,%eax
  801f68:	0f 88 2c 01 00 00    	js     80209a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f6e:	83 ec 04             	sub    $0x4,%esp
  801f71:	68 07 04 00 00       	push   $0x407
  801f76:	ff 75 f4             	pushl  -0xc(%ebp)
  801f79:	6a 00                	push   $0x0
  801f7b:	e8 2b ec ff ff       	call   800bab <sys_page_alloc>
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	89 c2                	mov    %eax,%edx
  801f85:	85 c0                	test   %eax,%eax
  801f87:	0f 88 0d 01 00 00    	js     80209a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f8d:	83 ec 0c             	sub    $0xc,%esp
  801f90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f93:	50                   	push   %eax
  801f94:	e8 d8 f4 ff ff       	call   801471 <fd_alloc>
  801f99:	89 c3                	mov    %eax,%ebx
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	0f 88 e2 00 00 00    	js     802088 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa6:	83 ec 04             	sub    $0x4,%esp
  801fa9:	68 07 04 00 00       	push   $0x407
  801fae:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb1:	6a 00                	push   $0x0
  801fb3:	e8 f3 eb ff ff       	call   800bab <sys_page_alloc>
  801fb8:	89 c3                	mov    %eax,%ebx
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	0f 88 c3 00 00 00    	js     802088 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcb:	e8 8a f4 ff ff       	call   80145a <fd2data>
  801fd0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd2:	83 c4 0c             	add    $0xc,%esp
  801fd5:	68 07 04 00 00       	push   $0x407
  801fda:	50                   	push   %eax
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 c9 eb ff ff       	call   800bab <sys_page_alloc>
  801fe2:	89 c3                	mov    %eax,%ebx
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	0f 88 89 00 00 00    	js     802078 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff5:	e8 60 f4 ff ff       	call   80145a <fd2data>
  801ffa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802001:	50                   	push   %eax
  802002:	6a 00                	push   $0x0
  802004:	56                   	push   %esi
  802005:	6a 00                	push   $0x0
  802007:	e8 e2 eb ff ff       	call   800bee <sys_page_map>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	83 c4 20             	add    $0x20,%esp
  802011:	85 c0                	test   %eax,%eax
  802013:	78 55                	js     80206a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802015:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80201b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802023:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80202a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802030:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802033:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802035:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802038:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80203f:	83 ec 0c             	sub    $0xc,%esp
  802042:	ff 75 f4             	pushl  -0xc(%ebp)
  802045:	e8 00 f4 ff ff       	call   80144a <fd2num>
  80204a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80204d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80204f:	83 c4 04             	add    $0x4,%esp
  802052:	ff 75 f0             	pushl  -0x10(%ebp)
  802055:	e8 f0 f3 ff ff       	call   80144a <fd2num>
  80205a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80205d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	ba 00 00 00 00       	mov    $0x0,%edx
  802068:	eb 30                	jmp    80209a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80206a:	83 ec 08             	sub    $0x8,%esp
  80206d:	56                   	push   %esi
  80206e:	6a 00                	push   $0x0
  802070:	e8 bb eb ff ff       	call   800c30 <sys_page_unmap>
  802075:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802078:	83 ec 08             	sub    $0x8,%esp
  80207b:	ff 75 f0             	pushl  -0x10(%ebp)
  80207e:	6a 00                	push   $0x0
  802080:	e8 ab eb ff ff       	call   800c30 <sys_page_unmap>
  802085:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802088:	83 ec 08             	sub    $0x8,%esp
  80208b:	ff 75 f4             	pushl  -0xc(%ebp)
  80208e:	6a 00                	push   $0x0
  802090:	e8 9b eb ff ff       	call   800c30 <sys_page_unmap>
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ac:	50                   	push   %eax
  8020ad:	ff 75 08             	pushl  0x8(%ebp)
  8020b0:	e8 0b f4 ff ff       	call   8014c0 <fd_lookup>
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 18                	js     8020d4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020bc:	83 ec 0c             	sub    $0xc,%esp
  8020bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c2:	e8 93 f3 ff ff       	call   80145a <fd2data>
	return _pipeisclosed(fd, p);
  8020c7:	89 c2                	mov    %eax,%edx
  8020c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cc:	e8 18 fd ff ff       	call   801de9 <_pipeisclosed>
  8020d1:	83 c4 10             	add    $0x10,%esp
}
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    

008020e0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020e6:	68 f6 2b 80 00       	push   $0x802bf6
  8020eb:	ff 75 0c             	pushl  0xc(%ebp)
  8020ee:	e8 b5 e6 ff ff       	call   8007a8 <strcpy>
	return 0;
}
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f8:	c9                   	leave  
  8020f9:	c3                   	ret    

008020fa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	57                   	push   %edi
  8020fe:	56                   	push   %esi
  8020ff:	53                   	push   %ebx
  802100:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802106:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80210b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802111:	eb 2d                	jmp    802140 <devcons_write+0x46>
		m = n - tot;
  802113:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802116:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802118:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80211b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802120:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802123:	83 ec 04             	sub    $0x4,%esp
  802126:	53                   	push   %ebx
  802127:	03 45 0c             	add    0xc(%ebp),%eax
  80212a:	50                   	push   %eax
  80212b:	57                   	push   %edi
  80212c:	e8 09 e8 ff ff       	call   80093a <memmove>
		sys_cputs(buf, m);
  802131:	83 c4 08             	add    $0x8,%esp
  802134:	53                   	push   %ebx
  802135:	57                   	push   %edi
  802136:	e8 b4 e9 ff ff       	call   800aef <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80213b:	01 de                	add    %ebx,%esi
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	89 f0                	mov    %esi,%eax
  802142:	3b 75 10             	cmp    0x10(%ebp),%esi
  802145:	72 cc                	jb     802113 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214a:	5b                   	pop    %ebx
  80214b:	5e                   	pop    %esi
  80214c:	5f                   	pop    %edi
  80214d:	5d                   	pop    %ebp
  80214e:	c3                   	ret    

0080214f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	83 ec 08             	sub    $0x8,%esp
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80215a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80215e:	74 2a                	je     80218a <devcons_read+0x3b>
  802160:	eb 05                	jmp    802167 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802162:	e8 25 ea ff ff       	call   800b8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802167:	e8 a1 e9 ff ff       	call   800b0d <sys_cgetc>
  80216c:	85 c0                	test   %eax,%eax
  80216e:	74 f2                	je     802162 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802170:	85 c0                	test   %eax,%eax
  802172:	78 16                	js     80218a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802174:	83 f8 04             	cmp    $0x4,%eax
  802177:	74 0c                	je     802185 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80217c:	88 02                	mov    %al,(%edx)
	return 1;
  80217e:	b8 01 00 00 00       	mov    $0x1,%eax
  802183:	eb 05                	jmp    80218a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802185:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802192:	8b 45 08             	mov    0x8(%ebp),%eax
  802195:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802198:	6a 01                	push   $0x1
  80219a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80219d:	50                   	push   %eax
  80219e:	e8 4c e9 ff ff       	call   800aef <sys_cputs>
}
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	c9                   	leave  
  8021a7:	c3                   	ret    

008021a8 <getchar>:

int
getchar(void)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021ae:	6a 01                	push   $0x1
  8021b0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021b3:	50                   	push   %eax
  8021b4:	6a 00                	push   $0x0
  8021b6:	e8 6e f5 ff ff       	call   801729 <read>
	if (r < 0)
  8021bb:	83 c4 10             	add    $0x10,%esp
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	78 0f                	js     8021d1 <getchar+0x29>
		return r;
	if (r < 1)
  8021c2:	85 c0                	test   %eax,%eax
  8021c4:	7e 06                	jle    8021cc <getchar+0x24>
		return -E_EOF;
	return c;
  8021c6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021ca:	eb 05                	jmp    8021d1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021cc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    

008021d3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021dc:	50                   	push   %eax
  8021dd:	ff 75 08             	pushl  0x8(%ebp)
  8021e0:	e8 db f2 ff ff       	call   8014c0 <fd_lookup>
  8021e5:	83 c4 10             	add    $0x10,%esp
  8021e8:	85 c0                	test   %eax,%eax
  8021ea:	78 11                	js     8021fd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021f5:	39 10                	cmp    %edx,(%eax)
  8021f7:	0f 94 c0             	sete   %al
  8021fa:	0f b6 c0             	movzbl %al,%eax
}
  8021fd:	c9                   	leave  
  8021fe:	c3                   	ret    

008021ff <opencons>:

int
opencons(void)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  802202:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802205:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802208:	50                   	push   %eax
  802209:	e8 63 f2 ff ff       	call   801471 <fd_alloc>
  80220e:	83 c4 10             	add    $0x10,%esp
		return r;
  802211:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802213:	85 c0                	test   %eax,%eax
  802215:	78 3e                	js     802255 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802217:	83 ec 04             	sub    $0x4,%esp
  80221a:	68 07 04 00 00       	push   $0x407
  80221f:	ff 75 f4             	pushl  -0xc(%ebp)
  802222:	6a 00                	push   $0x0
  802224:	e8 82 e9 ff ff       	call   800bab <sys_page_alloc>
  802229:	83 c4 10             	add    $0x10,%esp
		return r;
  80222c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80222e:	85 c0                	test   %eax,%eax
  802230:	78 23                	js     802255 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802232:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802238:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80223d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802240:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802247:	83 ec 0c             	sub    $0xc,%esp
  80224a:	50                   	push   %eax
  80224b:	e8 fa f1 ff ff       	call   80144a <fd2num>
  802250:	89 c2                	mov    %eax,%edx
  802252:	83 c4 10             	add    $0x10,%esp
}
  802255:	89 d0                	mov    %edx,%eax
  802257:	c9                   	leave  
  802258:	c3                   	ret    

00802259 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	56                   	push   %esi
  80225d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80225e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802261:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802267:	e8 01 e9 ff ff       	call   800b6d <sys_getenvid>
  80226c:	83 ec 0c             	sub    $0xc,%esp
  80226f:	ff 75 0c             	pushl  0xc(%ebp)
  802272:	ff 75 08             	pushl  0x8(%ebp)
  802275:	56                   	push   %esi
  802276:	50                   	push   %eax
  802277:	68 04 2c 80 00       	push   $0x802c04
  80227c:	e8 a2 df ff ff       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802281:	83 c4 18             	add    $0x18,%esp
  802284:	53                   	push   %ebx
  802285:	ff 75 10             	pushl  0x10(%ebp)
  802288:	e8 45 df ff ff       	call   8001d2 <vcprintf>
	cprintf("\n");
  80228d:	c7 04 24 fb 2a 80 00 	movl   $0x802afb,(%esp)
  802294:	e8 8a df ff ff       	call   800223 <cprintf>
  802299:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80229c:	cc                   	int3   
  80229d:	eb fd                	jmp    80229c <_panic+0x43>

0080229f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022a5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022ac:	75 2a                	jne    8022d8 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8022ae:	83 ec 04             	sub    $0x4,%esp
  8022b1:	6a 07                	push   $0x7
  8022b3:	68 00 f0 bf ee       	push   $0xeebff000
  8022b8:	6a 00                	push   $0x0
  8022ba:	e8 ec e8 ff ff       	call   800bab <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8022bf:	83 c4 10             	add    $0x10,%esp
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	79 12                	jns    8022d8 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8022c6:	50                   	push   %eax
  8022c7:	68 12 2b 80 00       	push   $0x802b12
  8022cc:	6a 23                	push   $0x23
  8022ce:	68 28 2c 80 00       	push   $0x802c28
  8022d3:	e8 81 ff ff ff       	call   802259 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8022e0:	83 ec 08             	sub    $0x8,%esp
  8022e3:	68 0a 23 80 00       	push   $0x80230a
  8022e8:	6a 00                	push   $0x0
  8022ea:	e8 07 ea ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8022ef:	83 c4 10             	add    $0x10,%esp
  8022f2:	85 c0                	test   %eax,%eax
  8022f4:	79 12                	jns    802308 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8022f6:	50                   	push   %eax
  8022f7:	68 12 2b 80 00       	push   $0x802b12
  8022fc:	6a 2c                	push   $0x2c
  8022fe:	68 28 2c 80 00       	push   $0x802c28
  802303:	e8 51 ff ff ff       	call   802259 <_panic>
	}
}
  802308:	c9                   	leave  
  802309:	c3                   	ret    

0080230a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80230a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80230b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802310:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802312:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802315:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802319:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80231e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802322:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802324:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802327:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802328:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80232b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80232c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80232d:	c3                   	ret    

0080232e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	56                   	push   %esi
  802332:	53                   	push   %ebx
  802333:	8b 75 08             	mov    0x8(%ebp),%esi
  802336:	8b 45 0c             	mov    0xc(%ebp),%eax
  802339:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80233c:	85 c0                	test   %eax,%eax
  80233e:	75 12                	jne    802352 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802340:	83 ec 0c             	sub    $0xc,%esp
  802343:	68 00 00 c0 ee       	push   $0xeec00000
  802348:	e8 0e ea ff ff       	call   800d5b <sys_ipc_recv>
  80234d:	83 c4 10             	add    $0x10,%esp
  802350:	eb 0c                	jmp    80235e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802352:	83 ec 0c             	sub    $0xc,%esp
  802355:	50                   	push   %eax
  802356:	e8 00 ea ff ff       	call   800d5b <sys_ipc_recv>
  80235b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80235e:	85 f6                	test   %esi,%esi
  802360:	0f 95 c1             	setne  %cl
  802363:	85 db                	test   %ebx,%ebx
  802365:	0f 95 c2             	setne  %dl
  802368:	84 d1                	test   %dl,%cl
  80236a:	74 09                	je     802375 <ipc_recv+0x47>
  80236c:	89 c2                	mov    %eax,%edx
  80236e:	c1 ea 1f             	shr    $0x1f,%edx
  802371:	84 d2                	test   %dl,%dl
  802373:	75 2d                	jne    8023a2 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802375:	85 f6                	test   %esi,%esi
  802377:	74 0d                	je     802386 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802379:	a1 04 40 80 00       	mov    0x804004,%eax
  80237e:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802384:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802386:	85 db                	test   %ebx,%ebx
  802388:	74 0d                	je     802397 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80238a:	a1 04 40 80 00       	mov    0x804004,%eax
  80238f:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802395:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802397:	a1 04 40 80 00       	mov    0x804004,%eax
  80239c:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8023a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a5:	5b                   	pop    %ebx
  8023a6:	5e                   	pop    %esi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    

008023a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a9:	55                   	push   %ebp
  8023aa:	89 e5                	mov    %esp,%ebp
  8023ac:	57                   	push   %edi
  8023ad:	56                   	push   %esi
  8023ae:	53                   	push   %ebx
  8023af:	83 ec 0c             	sub    $0xc,%esp
  8023b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8023bb:	85 db                	test   %ebx,%ebx
  8023bd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023c2:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8023c5:	ff 75 14             	pushl  0x14(%ebp)
  8023c8:	53                   	push   %ebx
  8023c9:	56                   	push   %esi
  8023ca:	57                   	push   %edi
  8023cb:	e8 68 e9 ff ff       	call   800d38 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8023d0:	89 c2                	mov    %eax,%edx
  8023d2:	c1 ea 1f             	shr    $0x1f,%edx
  8023d5:	83 c4 10             	add    $0x10,%esp
  8023d8:	84 d2                	test   %dl,%dl
  8023da:	74 17                	je     8023f3 <ipc_send+0x4a>
  8023dc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023df:	74 12                	je     8023f3 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8023e1:	50                   	push   %eax
  8023e2:	68 36 2c 80 00       	push   $0x802c36
  8023e7:	6a 47                	push   $0x47
  8023e9:	68 44 2c 80 00       	push   $0x802c44
  8023ee:	e8 66 fe ff ff       	call   802259 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8023f3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023f6:	75 07                	jne    8023ff <ipc_send+0x56>
			sys_yield();
  8023f8:	e8 8f e7 ff ff       	call   800b8c <sys_yield>
  8023fd:	eb c6                	jmp    8023c5 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8023ff:	85 c0                	test   %eax,%eax
  802401:	75 c2                	jne    8023c5 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802403:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802406:	5b                   	pop    %ebx
  802407:	5e                   	pop    %esi
  802408:	5f                   	pop    %edi
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    

0080240b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802411:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802416:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80241c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802422:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802428:	39 ca                	cmp    %ecx,%edx
  80242a:	75 13                	jne    80243f <ipc_find_env+0x34>
			return envs[i].env_id;
  80242c:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802432:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802437:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80243d:	eb 0f                	jmp    80244e <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80243f:	83 c0 01             	add    $0x1,%eax
  802442:	3d 00 04 00 00       	cmp    $0x400,%eax
  802447:	75 cd                	jne    802416 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802449:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    

00802450 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802456:	89 d0                	mov    %edx,%eax
  802458:	c1 e8 16             	shr    $0x16,%eax
  80245b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802462:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802467:	f6 c1 01             	test   $0x1,%cl
  80246a:	74 1d                	je     802489 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80246c:	c1 ea 0c             	shr    $0xc,%edx
  80246f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802476:	f6 c2 01             	test   $0x1,%dl
  802479:	74 0e                	je     802489 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80247b:	c1 ea 0c             	shr    $0xc,%edx
  80247e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802485:	ef 
  802486:	0f b7 c0             	movzwl %ax,%eax
}
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    
  80248b:	66 90                	xchg   %ax,%ax
  80248d:	66 90                	xchg   %ax,%ax
  80248f:	90                   	nop

00802490 <__udivdi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
  802494:	83 ec 1c             	sub    $0x1c,%esp
  802497:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80249b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80249f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024a7:	85 f6                	test   %esi,%esi
  8024a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ad:	89 ca                	mov    %ecx,%edx
  8024af:	89 f8                	mov    %edi,%eax
  8024b1:	75 3d                	jne    8024f0 <__udivdi3+0x60>
  8024b3:	39 cf                	cmp    %ecx,%edi
  8024b5:	0f 87 c5 00 00 00    	ja     802580 <__udivdi3+0xf0>
  8024bb:	85 ff                	test   %edi,%edi
  8024bd:	89 fd                	mov    %edi,%ebp
  8024bf:	75 0b                	jne    8024cc <__udivdi3+0x3c>
  8024c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c6:	31 d2                	xor    %edx,%edx
  8024c8:	f7 f7                	div    %edi
  8024ca:	89 c5                	mov    %eax,%ebp
  8024cc:	89 c8                	mov    %ecx,%eax
  8024ce:	31 d2                	xor    %edx,%edx
  8024d0:	f7 f5                	div    %ebp
  8024d2:	89 c1                	mov    %eax,%ecx
  8024d4:	89 d8                	mov    %ebx,%eax
  8024d6:	89 cf                	mov    %ecx,%edi
  8024d8:	f7 f5                	div    %ebp
  8024da:	89 c3                	mov    %eax,%ebx
  8024dc:	89 d8                	mov    %ebx,%eax
  8024de:	89 fa                	mov    %edi,%edx
  8024e0:	83 c4 1c             	add    $0x1c,%esp
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    
  8024e8:	90                   	nop
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	39 ce                	cmp    %ecx,%esi
  8024f2:	77 74                	ja     802568 <__udivdi3+0xd8>
  8024f4:	0f bd fe             	bsr    %esi,%edi
  8024f7:	83 f7 1f             	xor    $0x1f,%edi
  8024fa:	0f 84 98 00 00 00    	je     802598 <__udivdi3+0x108>
  802500:	bb 20 00 00 00       	mov    $0x20,%ebx
  802505:	89 f9                	mov    %edi,%ecx
  802507:	89 c5                	mov    %eax,%ebp
  802509:	29 fb                	sub    %edi,%ebx
  80250b:	d3 e6                	shl    %cl,%esi
  80250d:	89 d9                	mov    %ebx,%ecx
  80250f:	d3 ed                	shr    %cl,%ebp
  802511:	89 f9                	mov    %edi,%ecx
  802513:	d3 e0                	shl    %cl,%eax
  802515:	09 ee                	or     %ebp,%esi
  802517:	89 d9                	mov    %ebx,%ecx
  802519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251d:	89 d5                	mov    %edx,%ebp
  80251f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802523:	d3 ed                	shr    %cl,%ebp
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e2                	shl    %cl,%edx
  802529:	89 d9                	mov    %ebx,%ecx
  80252b:	d3 e8                	shr    %cl,%eax
  80252d:	09 c2                	or     %eax,%edx
  80252f:	89 d0                	mov    %edx,%eax
  802531:	89 ea                	mov    %ebp,%edx
  802533:	f7 f6                	div    %esi
  802535:	89 d5                	mov    %edx,%ebp
  802537:	89 c3                	mov    %eax,%ebx
  802539:	f7 64 24 0c          	mull   0xc(%esp)
  80253d:	39 d5                	cmp    %edx,%ebp
  80253f:	72 10                	jb     802551 <__udivdi3+0xc1>
  802541:	8b 74 24 08          	mov    0x8(%esp),%esi
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e6                	shl    %cl,%esi
  802549:	39 c6                	cmp    %eax,%esi
  80254b:	73 07                	jae    802554 <__udivdi3+0xc4>
  80254d:	39 d5                	cmp    %edx,%ebp
  80254f:	75 03                	jne    802554 <__udivdi3+0xc4>
  802551:	83 eb 01             	sub    $0x1,%ebx
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 d8                	mov    %ebx,%eax
  802558:	89 fa                	mov    %edi,%edx
  80255a:	83 c4 1c             	add    $0x1c,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5f                   	pop    %edi
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	31 ff                	xor    %edi,%edi
  80256a:	31 db                	xor    %ebx,%ebx
  80256c:	89 d8                	mov    %ebx,%eax
  80256e:	89 fa                	mov    %edi,%edx
  802570:	83 c4 1c             	add    $0x1c,%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    
  802578:	90                   	nop
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 d8                	mov    %ebx,%eax
  802582:	f7 f7                	div    %edi
  802584:	31 ff                	xor    %edi,%edi
  802586:	89 c3                	mov    %eax,%ebx
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	89 fa                	mov    %edi,%edx
  80258c:	83 c4 1c             	add    $0x1c,%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	5d                   	pop    %ebp
  802593:	c3                   	ret    
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	39 ce                	cmp    %ecx,%esi
  80259a:	72 0c                	jb     8025a8 <__udivdi3+0x118>
  80259c:	31 db                	xor    %ebx,%ebx
  80259e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025a2:	0f 87 34 ff ff ff    	ja     8024dc <__udivdi3+0x4c>
  8025a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025ad:	e9 2a ff ff ff       	jmp    8024dc <__udivdi3+0x4c>
  8025b2:	66 90                	xchg   %ax,%ax
  8025b4:	66 90                	xchg   %ax,%ax
  8025b6:	66 90                	xchg   %ax,%ax
  8025b8:	66 90                	xchg   %ax,%ax
  8025ba:	66 90                	xchg   %ax,%ax
  8025bc:	66 90                	xchg   %ax,%ax
  8025be:	66 90                	xchg   %ax,%ax

008025c0 <__umoddi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	53                   	push   %ebx
  8025c4:	83 ec 1c             	sub    $0x1c,%esp
  8025c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025d7:	85 d2                	test   %edx,%edx
  8025d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025e1:	89 f3                	mov    %esi,%ebx
  8025e3:	89 3c 24             	mov    %edi,(%esp)
  8025e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ea:	75 1c                	jne    802608 <__umoddi3+0x48>
  8025ec:	39 f7                	cmp    %esi,%edi
  8025ee:	76 50                	jbe    802640 <__umoddi3+0x80>
  8025f0:	89 c8                	mov    %ecx,%eax
  8025f2:	89 f2                	mov    %esi,%edx
  8025f4:	f7 f7                	div    %edi
  8025f6:	89 d0                	mov    %edx,%eax
  8025f8:	31 d2                	xor    %edx,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	39 f2                	cmp    %esi,%edx
  80260a:	89 d0                	mov    %edx,%eax
  80260c:	77 52                	ja     802660 <__umoddi3+0xa0>
  80260e:	0f bd ea             	bsr    %edx,%ebp
  802611:	83 f5 1f             	xor    $0x1f,%ebp
  802614:	75 5a                	jne    802670 <__umoddi3+0xb0>
  802616:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80261a:	0f 82 e0 00 00 00    	jb     802700 <__umoddi3+0x140>
  802620:	39 0c 24             	cmp    %ecx,(%esp)
  802623:	0f 86 d7 00 00 00    	jbe    802700 <__umoddi3+0x140>
  802629:	8b 44 24 08          	mov    0x8(%esp),%eax
  80262d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802631:	83 c4 1c             	add    $0x1c,%esp
  802634:	5b                   	pop    %ebx
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	85 ff                	test   %edi,%edi
  802642:	89 fd                	mov    %edi,%ebp
  802644:	75 0b                	jne    802651 <__umoddi3+0x91>
  802646:	b8 01 00 00 00       	mov    $0x1,%eax
  80264b:	31 d2                	xor    %edx,%edx
  80264d:	f7 f7                	div    %edi
  80264f:	89 c5                	mov    %eax,%ebp
  802651:	89 f0                	mov    %esi,%eax
  802653:	31 d2                	xor    %edx,%edx
  802655:	f7 f5                	div    %ebp
  802657:	89 c8                	mov    %ecx,%eax
  802659:	f7 f5                	div    %ebp
  80265b:	89 d0                	mov    %edx,%eax
  80265d:	eb 99                	jmp    8025f8 <__umoddi3+0x38>
  80265f:	90                   	nop
  802660:	89 c8                	mov    %ecx,%eax
  802662:	89 f2                	mov    %esi,%edx
  802664:	83 c4 1c             	add    $0x1c,%esp
  802667:	5b                   	pop    %ebx
  802668:	5e                   	pop    %esi
  802669:	5f                   	pop    %edi
  80266a:	5d                   	pop    %ebp
  80266b:	c3                   	ret    
  80266c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802670:	8b 34 24             	mov    (%esp),%esi
  802673:	bf 20 00 00 00       	mov    $0x20,%edi
  802678:	89 e9                	mov    %ebp,%ecx
  80267a:	29 ef                	sub    %ebp,%edi
  80267c:	d3 e0                	shl    %cl,%eax
  80267e:	89 f9                	mov    %edi,%ecx
  802680:	89 f2                	mov    %esi,%edx
  802682:	d3 ea                	shr    %cl,%edx
  802684:	89 e9                	mov    %ebp,%ecx
  802686:	09 c2                	or     %eax,%edx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 14 24             	mov    %edx,(%esp)
  80268d:	89 f2                	mov    %esi,%edx
  80268f:	d3 e2                	shl    %cl,%edx
  802691:	89 f9                	mov    %edi,%ecx
  802693:	89 54 24 04          	mov    %edx,0x4(%esp)
  802697:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	89 c6                	mov    %eax,%esi
  8026a1:	d3 e3                	shl    %cl,%ebx
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 d0                	mov    %edx,%eax
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	09 d8                	or     %ebx,%eax
  8026ad:	89 d3                	mov    %edx,%ebx
  8026af:	89 f2                	mov    %esi,%edx
  8026b1:	f7 34 24             	divl   (%esp)
  8026b4:	89 d6                	mov    %edx,%esi
  8026b6:	d3 e3                	shl    %cl,%ebx
  8026b8:	f7 64 24 04          	mull   0x4(%esp)
  8026bc:	39 d6                	cmp    %edx,%esi
  8026be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026c2:	89 d1                	mov    %edx,%ecx
  8026c4:	89 c3                	mov    %eax,%ebx
  8026c6:	72 08                	jb     8026d0 <__umoddi3+0x110>
  8026c8:	75 11                	jne    8026db <__umoddi3+0x11b>
  8026ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ce:	73 0b                	jae    8026db <__umoddi3+0x11b>
  8026d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026d4:	1b 14 24             	sbb    (%esp),%edx
  8026d7:	89 d1                	mov    %edx,%ecx
  8026d9:	89 c3                	mov    %eax,%ebx
  8026db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026df:	29 da                	sub    %ebx,%edx
  8026e1:	19 ce                	sbb    %ecx,%esi
  8026e3:	89 f9                	mov    %edi,%ecx
  8026e5:	89 f0                	mov    %esi,%eax
  8026e7:	d3 e0                	shl    %cl,%eax
  8026e9:	89 e9                	mov    %ebp,%ecx
  8026eb:	d3 ea                	shr    %cl,%edx
  8026ed:	89 e9                	mov    %ebp,%ecx
  8026ef:	d3 ee                	shr    %cl,%esi
  8026f1:	09 d0                	or     %edx,%eax
  8026f3:	89 f2                	mov    %esi,%edx
  8026f5:	83 c4 1c             	add    $0x1c,%esp
  8026f8:	5b                   	pop    %ebx
  8026f9:	5e                   	pop    %esi
  8026fa:	5f                   	pop    %edi
  8026fb:	5d                   	pop    %ebp
  8026fc:	c3                   	ret    
  8026fd:	8d 76 00             	lea    0x0(%esi),%esi
  802700:	29 f9                	sub    %edi,%ecx
  802702:	19 d6                	sbb    %edx,%esi
  802704:	89 74 24 04          	mov    %esi,0x4(%esp)
  802708:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80270c:	e9 18 ff ff ff       	jmp    802629 <__umoddi3+0x69>
