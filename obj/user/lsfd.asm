
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
  800039:	68 00 25 80 00       	push   $0x802500
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
  800067:	e8 64 10 00 00       	call   8010d0 <argstart>
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
  800091:	e8 6a 10 00 00       	call   801100 <argnext>
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
  8000ad:	e8 66 16 00 00       	call   801718 <fstat>
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
  8000ce:	68 14 25 80 00       	push   $0x802514
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 38 1a 00 00       	call   801b12 <fprintf>
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
  8000f0:	68 14 25 80 00       	push   $0x802514
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
  800122:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800128:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012d:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80017c:	e8 6e 12 00 00       	call   8013ef <close_all>
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
  800286:	e8 d5 1f 00 00       	call   802260 <__udivdi3>
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
  8002c9:	e8 c2 20 00 00       	call   802390 <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 46 25 80 00 	movsbl 0x802546(%eax),%eax
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
  8003cd:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
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
  800491:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800498:	85 d2                	test   %edx,%edx
  80049a:	75 18                	jne    8004b4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049c:	50                   	push   %eax
  80049d:	68 5e 25 80 00       	push   $0x80255e
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
  8004b5:	68 8d 29 80 00       	push   $0x80298d
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
  8004d9:	b8 57 25 80 00       	mov    $0x802557,%eax
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
  800b54:	68 3f 28 80 00       	push   $0x80283f
  800b59:	6a 23                	push   $0x23
  800b5b:	68 5c 28 80 00       	push   $0x80285c
  800b60:	e8 c2 14 00 00       	call   802027 <_panic>

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
  800bd5:	68 3f 28 80 00       	push   $0x80283f
  800bda:	6a 23                	push   $0x23
  800bdc:	68 5c 28 80 00       	push   $0x80285c
  800be1:	e8 41 14 00 00       	call   802027 <_panic>

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
  800c17:	68 3f 28 80 00       	push   $0x80283f
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 5c 28 80 00       	push   $0x80285c
  800c23:	e8 ff 13 00 00       	call   802027 <_panic>

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
  800c59:	68 3f 28 80 00       	push   $0x80283f
  800c5e:	6a 23                	push   $0x23
  800c60:	68 5c 28 80 00       	push   $0x80285c
  800c65:	e8 bd 13 00 00       	call   802027 <_panic>

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
  800c9b:	68 3f 28 80 00       	push   $0x80283f
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 5c 28 80 00       	push   $0x80285c
  800ca7:	e8 7b 13 00 00       	call   802027 <_panic>

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
  800cdd:	68 3f 28 80 00       	push   $0x80283f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 5c 28 80 00       	push   $0x80285c
  800ce9:	e8 39 13 00 00       	call   802027 <_panic>
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
  800d1f:	68 3f 28 80 00       	push   $0x80283f
  800d24:	6a 23                	push   $0x23
  800d26:	68 5c 28 80 00       	push   $0x80285c
  800d2b:	e8 f7 12 00 00       	call   802027 <_panic>

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
  800d83:	68 3f 28 80 00       	push   $0x80283f
  800d88:	6a 23                	push   $0x23
  800d8a:	68 5c 28 80 00       	push   $0x80285c
  800d8f:	e8 93 12 00 00       	call   802027 <_panic>

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

00800ddc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800de8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dec:	74 11                	je     800dff <pgfault+0x23>
  800dee:	89 d8                	mov    %ebx,%eax
  800df0:	c1 e8 0c             	shr    $0xc,%eax
  800df3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dfa:	f6 c4 08             	test   $0x8,%ah
  800dfd:	75 14                	jne    800e13 <pgfault+0x37>
		panic("faulting access");
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	68 6a 28 80 00       	push   $0x80286a
  800e07:	6a 1e                	push   $0x1e
  800e09:	68 7a 28 80 00       	push   $0x80287a
  800e0e:	e8 14 12 00 00       	call   802027 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	6a 07                	push   $0x7
  800e18:	68 00 f0 7f 00       	push   $0x7ff000
  800e1d:	6a 00                	push   $0x0
  800e1f:	e8 87 fd ff ff       	call   800bab <sys_page_alloc>
	if (r < 0) {
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	79 12                	jns    800e3d <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e2b:	50                   	push   %eax
  800e2c:	68 85 28 80 00       	push   $0x802885
  800e31:	6a 2c                	push   $0x2c
  800e33:	68 7a 28 80 00       	push   $0x80287a
  800e38:	e8 ea 11 00 00       	call   802027 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e3d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e43:	83 ec 04             	sub    $0x4,%esp
  800e46:	68 00 10 00 00       	push   $0x1000
  800e4b:	53                   	push   %ebx
  800e4c:	68 00 f0 7f 00       	push   $0x7ff000
  800e51:	e8 4c fb ff ff       	call   8009a2 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e56:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e5d:	53                   	push   %ebx
  800e5e:	6a 00                	push   $0x0
  800e60:	68 00 f0 7f 00       	push   $0x7ff000
  800e65:	6a 00                	push   $0x0
  800e67:	e8 82 fd ff ff       	call   800bee <sys_page_map>
	if (r < 0) {
  800e6c:	83 c4 20             	add    $0x20,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	79 12                	jns    800e85 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e73:	50                   	push   %eax
  800e74:	68 85 28 80 00       	push   $0x802885
  800e79:	6a 33                	push   $0x33
  800e7b:	68 7a 28 80 00       	push   $0x80287a
  800e80:	e8 a2 11 00 00       	call   802027 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	68 00 f0 7f 00       	push   $0x7ff000
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 9c fd ff ff       	call   800c30 <sys_page_unmap>
	if (r < 0) {
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	79 12                	jns    800ead <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e9b:	50                   	push   %eax
  800e9c:	68 85 28 80 00       	push   $0x802885
  800ea1:	6a 37                	push   $0x37
  800ea3:	68 7a 28 80 00       	push   $0x80287a
  800ea8:	e8 7a 11 00 00       	call   802027 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ebb:	68 dc 0d 80 00       	push   $0x800ddc
  800ec0:	e8 a8 11 00 00       	call   80206d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ec5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eca:	cd 30                	int    $0x30
  800ecc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	79 17                	jns    800eed <fork+0x3b>
		panic("fork fault %e");
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	68 9e 28 80 00       	push   $0x80289e
  800ede:	68 84 00 00 00       	push   $0x84
  800ee3:	68 7a 28 80 00       	push   $0x80287a
  800ee8:	e8 3a 11 00 00       	call   802027 <_panic>
  800eed:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800eef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef3:	75 24                	jne    800f19 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef5:	e8 73 fc ff ff       	call   800b6d <sys_getenvid>
  800efa:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eff:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f05:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f0a:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f14:	e9 64 01 00 00       	jmp    80107d <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	6a 07                	push   $0x7
  800f1e:	68 00 f0 bf ee       	push   $0xeebff000
  800f23:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f26:	e8 80 fc ff ff       	call   800bab <sys_page_alloc>
  800f2b:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f2e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f33:	89 d8                	mov    %ebx,%eax
  800f35:	c1 e8 16             	shr    $0x16,%eax
  800f38:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f3f:	a8 01                	test   $0x1,%al
  800f41:	0f 84 fc 00 00 00    	je     801043 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f47:	89 d8                	mov    %ebx,%eax
  800f49:	c1 e8 0c             	shr    $0xc,%eax
  800f4c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f53:	f6 c2 01             	test   $0x1,%dl
  800f56:	0f 84 e7 00 00 00    	je     801043 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f5c:	89 c6                	mov    %eax,%esi
  800f5e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f61:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f68:	f6 c6 04             	test   $0x4,%dh
  800f6b:	74 39                	je     800fa6 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7c:	50                   	push   %eax
  800f7d:	56                   	push   %esi
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	6a 00                	push   $0x0
  800f82:	e8 67 fc ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  800f87:	83 c4 20             	add    $0x20,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	0f 89 b1 00 00 00    	jns    801043 <fork+0x191>
		    	panic("sys page map fault %e");
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	68 ac 28 80 00       	push   $0x8028ac
  800f9a:	6a 54                	push   $0x54
  800f9c:	68 7a 28 80 00       	push   $0x80287a
  800fa1:	e8 81 10 00 00       	call   802027 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fa6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fad:	f6 c2 02             	test   $0x2,%dl
  800fb0:	75 0c                	jne    800fbe <fork+0x10c>
  800fb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb9:	f6 c4 08             	test   $0x8,%ah
  800fbc:	74 5b                	je     801019 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	68 05 08 00 00       	push   $0x805
  800fc6:	56                   	push   %esi
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 1e fc ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  800fd0:	83 c4 20             	add    $0x20,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	79 14                	jns    800feb <fork+0x139>
		    	panic("sys page map fault %e");
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	68 ac 28 80 00       	push   $0x8028ac
  800fdf:	6a 5b                	push   $0x5b
  800fe1:	68 7a 28 80 00       	push   $0x80287a
  800fe6:	e8 3c 10 00 00       	call   802027 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	68 05 08 00 00       	push   $0x805
  800ff3:	56                   	push   %esi
  800ff4:	6a 00                	push   $0x0
  800ff6:	56                   	push   %esi
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 f0 fb ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  800ffe:	83 c4 20             	add    $0x20,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	79 3e                	jns    801043 <fork+0x191>
		    	panic("sys page map fault %e");
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	68 ac 28 80 00       	push   $0x8028ac
  80100d:	6a 5f                	push   $0x5f
  80100f:	68 7a 28 80 00       	push   $0x80287a
  801014:	e8 0e 10 00 00       	call   802027 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	6a 05                	push   $0x5
  80101e:	56                   	push   %esi
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	6a 00                	push   $0x0
  801023:	e8 c6 fb ff ff       	call   800bee <sys_page_map>
		if (r < 0) {
  801028:	83 c4 20             	add    $0x20,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	79 14                	jns    801043 <fork+0x191>
		    	panic("sys page map fault %e");
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	68 ac 28 80 00       	push   $0x8028ac
  801037:	6a 64                	push   $0x64
  801039:	68 7a 28 80 00       	push   $0x80287a
  80103e:	e8 e4 0f 00 00       	call   802027 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801043:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801049:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80104f:	0f 85 de fe ff ff    	jne    800f33 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801055:	a1 04 40 80 00       	mov    0x804004,%eax
  80105a:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	50                   	push   %eax
  801064:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801067:	57                   	push   %edi
  801068:	e8 89 fc ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	6a 02                	push   $0x2
  801072:	57                   	push   %edi
  801073:	e8 fa fb ff ff       	call   800c72 <sys_env_set_status>
	
	return envid;
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80107d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sfork>:

envid_t
sfork(void)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801097:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	53                   	push   %ebx
  8010a1:	68 c4 28 80 00       	push   $0x8028c4
  8010a6:	e8 78 f1 ff ff       	call   800223 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010ab:	c7 04 24 56 01 80 00 	movl   $0x800156,(%esp)
  8010b2:	e8 e5 fc ff ff       	call   800d9c <sys_thread_create>
  8010b7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010b9:	83 c4 08             	add    $0x8,%esp
  8010bc:	53                   	push   %ebx
  8010bd:	68 c4 28 80 00       	push   $0x8028c4
  8010c2:	e8 5c f1 ff ff       	call   800223 <cprintf>
	return id;
}
  8010c7:	89 f0                	mov    %esi,%eax
  8010c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d9:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8010dc:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8010de:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8010e1:	83 3a 01             	cmpl   $0x1,(%edx)
  8010e4:	7e 09                	jle    8010ef <argstart+0x1f>
  8010e6:	ba 11 25 80 00       	mov    $0x802511,%edx
  8010eb:	85 c9                	test   %ecx,%ecx
  8010ed:	75 05                	jne    8010f4 <argstart+0x24>
  8010ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f4:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8010f7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <argnext>:

int
argnext(struct Argstate *args)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	53                   	push   %ebx
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80110a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801111:	8b 43 08             	mov    0x8(%ebx),%eax
  801114:	85 c0                	test   %eax,%eax
  801116:	74 6f                	je     801187 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801118:	80 38 00             	cmpb   $0x0,(%eax)
  80111b:	75 4e                	jne    80116b <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80111d:	8b 0b                	mov    (%ebx),%ecx
  80111f:	83 39 01             	cmpl   $0x1,(%ecx)
  801122:	74 55                	je     801179 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801124:	8b 53 04             	mov    0x4(%ebx),%edx
  801127:	8b 42 04             	mov    0x4(%edx),%eax
  80112a:	80 38 2d             	cmpb   $0x2d,(%eax)
  80112d:	75 4a                	jne    801179 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80112f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801133:	74 44                	je     801179 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801135:	83 c0 01             	add    $0x1,%eax
  801138:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80113b:	83 ec 04             	sub    $0x4,%esp
  80113e:	8b 01                	mov    (%ecx),%eax
  801140:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801147:	50                   	push   %eax
  801148:	8d 42 08             	lea    0x8(%edx),%eax
  80114b:	50                   	push   %eax
  80114c:	83 c2 04             	add    $0x4,%edx
  80114f:	52                   	push   %edx
  801150:	e8 e5 f7 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  801155:	8b 03                	mov    (%ebx),%eax
  801157:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80115a:	8b 43 08             	mov    0x8(%ebx),%eax
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	80 38 2d             	cmpb   $0x2d,(%eax)
  801163:	75 06                	jne    80116b <argnext+0x6b>
  801165:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801169:	74 0e                	je     801179 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80116b:	8b 53 08             	mov    0x8(%ebx),%edx
  80116e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801171:	83 c2 01             	add    $0x1,%edx
  801174:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801177:	eb 13                	jmp    80118c <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801179:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801185:	eb 05                	jmp    80118c <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80118c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	53                   	push   %ebx
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80119b:	8b 43 08             	mov    0x8(%ebx),%eax
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	74 58                	je     8011fa <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8011a2:	80 38 00             	cmpb   $0x0,(%eax)
  8011a5:	74 0c                	je     8011b3 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8011a7:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8011aa:	c7 43 08 11 25 80 00 	movl   $0x802511,0x8(%ebx)
  8011b1:	eb 42                	jmp    8011f5 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8011b3:	8b 13                	mov    (%ebx),%edx
  8011b5:	83 3a 01             	cmpl   $0x1,(%edx)
  8011b8:	7e 2d                	jle    8011e7 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8011ba:	8b 43 04             	mov    0x4(%ebx),%eax
  8011bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8011c0:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	8b 12                	mov    (%edx),%edx
  8011c8:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8011cf:	52                   	push   %edx
  8011d0:	8d 50 08             	lea    0x8(%eax),%edx
  8011d3:	52                   	push   %edx
  8011d4:	83 c0 04             	add    $0x4,%eax
  8011d7:	50                   	push   %eax
  8011d8:	e8 5d f7 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  8011dd:	8b 03                	mov    (%ebx),%eax
  8011df:	83 28 01             	subl   $0x1,(%eax)
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	eb 0e                	jmp    8011f5 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8011e7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8011ee:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8011f5:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011f8:	eb 05                	jmp    8011ff <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8011ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801202:	c9                   	leave  
  801203:	c3                   	ret    

00801204 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80120d:	8b 51 0c             	mov    0xc(%ecx),%edx
  801210:	89 d0                	mov    %edx,%eax
  801212:	85 d2                	test   %edx,%edx
  801214:	75 0c                	jne    801222 <argvalue+0x1e>
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	51                   	push   %ecx
  80121a:	e8 72 ff ff ff       	call   801191 <argnextvalue>
  80121f:	83 c4 10             	add    $0x10,%esp
}
  801222:	c9                   	leave  
  801223:	c3                   	ret    

00801224 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801227:	8b 45 08             	mov    0x8(%ebp),%eax
  80122a:	05 00 00 00 30       	add    $0x30000000,%eax
  80122f:	c1 e8 0c             	shr    $0xc,%eax
}
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801237:	8b 45 08             	mov    0x8(%ebp),%eax
  80123a:	05 00 00 00 30       	add    $0x30000000,%eax
  80123f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801244:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801251:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801256:	89 c2                	mov    %eax,%edx
  801258:	c1 ea 16             	shr    $0x16,%edx
  80125b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	74 11                	je     801278 <fd_alloc+0x2d>
  801267:	89 c2                	mov    %eax,%edx
  801269:	c1 ea 0c             	shr    $0xc,%edx
  80126c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801273:	f6 c2 01             	test   $0x1,%dl
  801276:	75 09                	jne    801281 <fd_alloc+0x36>
			*fd_store = fd;
  801278:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127a:	b8 00 00 00 00       	mov    $0x0,%eax
  80127f:	eb 17                	jmp    801298 <fd_alloc+0x4d>
  801281:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801286:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80128b:	75 c9                	jne    801256 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80128d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801293:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a0:	83 f8 1f             	cmp    $0x1f,%eax
  8012a3:	77 36                	ja     8012db <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a5:	c1 e0 0c             	shl    $0xc,%eax
  8012a8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	c1 ea 16             	shr    $0x16,%edx
  8012b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	74 24                	je     8012e2 <fd_lookup+0x48>
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	c1 ea 0c             	shr    $0xc,%edx
  8012c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ca:	f6 c2 01             	test   $0x1,%dl
  8012cd:	74 1a                	je     8012e9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d2:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d9:	eb 13                	jmp    8012ee <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb 0c                	jmp    8012ee <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e7:	eb 05                	jmp    8012ee <fd_lookup+0x54>
  8012e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f9:	ba 64 29 80 00       	mov    $0x802964,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012fe:	eb 13                	jmp    801313 <dev_lookup+0x23>
  801300:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801303:	39 08                	cmp    %ecx,(%eax)
  801305:	75 0c                	jne    801313 <dev_lookup+0x23>
			*dev = devtab[i];
  801307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
  801311:	eb 2e                	jmp    801341 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801313:	8b 02                	mov    (%edx),%eax
  801315:	85 c0                	test   %eax,%eax
  801317:	75 e7                	jne    801300 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801319:	a1 04 40 80 00       	mov    0x804004,%eax
  80131e:	8b 40 7c             	mov    0x7c(%eax),%eax
  801321:	83 ec 04             	sub    $0x4,%esp
  801324:	51                   	push   %ecx
  801325:	50                   	push   %eax
  801326:	68 e8 28 80 00       	push   $0x8028e8
  80132b:	e8 f3 ee ff ff       	call   800223 <cprintf>
	*dev = 0;
  801330:	8b 45 0c             	mov    0xc(%ebp),%eax
  801333:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	83 ec 10             	sub    $0x10,%esp
  80134b:	8b 75 08             	mov    0x8(%ebp),%esi
  80134e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80135b:	c1 e8 0c             	shr    $0xc,%eax
  80135e:	50                   	push   %eax
  80135f:	e8 36 ff ff ff       	call   80129a <fd_lookup>
  801364:	83 c4 08             	add    $0x8,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 05                	js     801370 <fd_close+0x2d>
	    || fd != fd2)
  80136b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136e:	74 0c                	je     80137c <fd_close+0x39>
		return (must_exist ? r : 0);
  801370:	84 db                	test   %bl,%bl
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	0f 44 c2             	cmove  %edx,%eax
  80137a:	eb 41                	jmp    8013bd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	ff 36                	pushl  (%esi)
  801385:	e8 66 ff ff ff       	call   8012f0 <dev_lookup>
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 1a                	js     8013ad <fd_close+0x6a>
		if (dev->dev_close)
  801393:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801396:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801399:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	74 0b                	je     8013ad <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	56                   	push   %esi
  8013a6:	ff d0                	call   *%eax
  8013a8:	89 c3                	mov    %eax,%ebx
  8013aa:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	56                   	push   %esi
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 78 f8 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 d8                	mov    %ebx,%eax
}
  8013bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	ff 75 08             	pushl  0x8(%ebp)
  8013d1:	e8 c4 fe ff ff       	call   80129a <fd_lookup>
  8013d6:	83 c4 08             	add    $0x8,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 10                	js     8013ed <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	6a 01                	push   $0x1
  8013e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e5:	e8 59 ff ff ff       	call   801343 <fd_close>
  8013ea:	83 c4 10             	add    $0x10,%esp
}
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <close_all>:

void
close_all(void)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	53                   	push   %ebx
  8013ff:	e8 c0 ff ff ff       	call   8013c4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801404:	83 c3 01             	add    $0x1,%ebx
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	83 fb 20             	cmp    $0x20,%ebx
  80140d:	75 ec                	jne    8013fb <close_all+0xc>
		close(i);
}
  80140f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	57                   	push   %edi
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	83 ec 2c             	sub    $0x2c,%esp
  80141d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801420:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	ff 75 08             	pushl  0x8(%ebp)
  801427:	e8 6e fe ff ff       	call   80129a <fd_lookup>
  80142c:	83 c4 08             	add    $0x8,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	0f 88 c1 00 00 00    	js     8014f8 <dup+0xe4>
		return r;
	close(newfdnum);
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	56                   	push   %esi
  80143b:	e8 84 ff ff ff       	call   8013c4 <close>

	newfd = INDEX2FD(newfdnum);
  801440:	89 f3                	mov    %esi,%ebx
  801442:	c1 e3 0c             	shl    $0xc,%ebx
  801445:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80144b:	83 c4 04             	add    $0x4,%esp
  80144e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801451:	e8 de fd ff ff       	call   801234 <fd2data>
  801456:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801458:	89 1c 24             	mov    %ebx,(%esp)
  80145b:	e8 d4 fd ff ff       	call   801234 <fd2data>
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801466:	89 f8                	mov    %edi,%eax
  801468:	c1 e8 16             	shr    $0x16,%eax
  80146b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801472:	a8 01                	test   $0x1,%al
  801474:	74 37                	je     8014ad <dup+0x99>
  801476:	89 f8                	mov    %edi,%eax
  801478:	c1 e8 0c             	shr    $0xc,%eax
  80147b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801482:	f6 c2 01             	test   $0x1,%dl
  801485:	74 26                	je     8014ad <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801487:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	25 07 0e 00 00       	and    $0xe07,%eax
  801496:	50                   	push   %eax
  801497:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149a:	6a 00                	push   $0x0
  80149c:	57                   	push   %edi
  80149d:	6a 00                	push   $0x0
  80149f:	e8 4a f7 ff ff       	call   800bee <sys_page_map>
  8014a4:	89 c7                	mov    %eax,%edi
  8014a6:	83 c4 20             	add    $0x20,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 2e                	js     8014db <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014b0:	89 d0                	mov    %edx,%eax
  8014b2:	c1 e8 0c             	shr    $0xc,%eax
  8014b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c4:	50                   	push   %eax
  8014c5:	53                   	push   %ebx
  8014c6:	6a 00                	push   $0x0
  8014c8:	52                   	push   %edx
  8014c9:	6a 00                	push   $0x0
  8014cb:	e8 1e f7 ff ff       	call   800bee <sys_page_map>
  8014d0:	89 c7                	mov    %eax,%edi
  8014d2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014d5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d7:	85 ff                	test   %edi,%edi
  8014d9:	79 1d                	jns    8014f8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	53                   	push   %ebx
  8014df:	6a 00                	push   $0x0
  8014e1:	e8 4a f7 ff ff       	call   800c30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e6:	83 c4 08             	add    $0x8,%esp
  8014e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ec:	6a 00                	push   $0x0
  8014ee:	e8 3d f7 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	89 f8                	mov    %edi,%eax
}
  8014f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5e                   	pop    %esi
  8014fd:	5f                   	pop    %edi
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 14             	sub    $0x14,%esp
  801507:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	53                   	push   %ebx
  80150f:	e8 86 fd ff ff       	call   80129a <fd_lookup>
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	89 c2                	mov    %eax,%edx
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 6d                	js     80158a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151d:	83 ec 08             	sub    $0x8,%esp
  801520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801527:	ff 30                	pushl  (%eax)
  801529:	e8 c2 fd ff ff       	call   8012f0 <dev_lookup>
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	78 4c                	js     801581 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801535:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801538:	8b 42 08             	mov    0x8(%edx),%eax
  80153b:	83 e0 03             	and    $0x3,%eax
  80153e:	83 f8 01             	cmp    $0x1,%eax
  801541:	75 21                	jne    801564 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801543:	a1 04 40 80 00       	mov    0x804004,%eax
  801548:	8b 40 7c             	mov    0x7c(%eax),%eax
  80154b:	83 ec 04             	sub    $0x4,%esp
  80154e:	53                   	push   %ebx
  80154f:	50                   	push   %eax
  801550:	68 29 29 80 00       	push   $0x802929
  801555:	e8 c9 ec ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801562:	eb 26                	jmp    80158a <read+0x8a>
	}
	if (!dev->dev_read)
  801564:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801567:	8b 40 08             	mov    0x8(%eax),%eax
  80156a:	85 c0                	test   %eax,%eax
  80156c:	74 17                	je     801585 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	ff 75 10             	pushl  0x10(%ebp)
  801574:	ff 75 0c             	pushl  0xc(%ebp)
  801577:	52                   	push   %edx
  801578:	ff d0                	call   *%eax
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	eb 09                	jmp    80158a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	89 c2                	mov    %eax,%edx
  801583:	eb 05                	jmp    80158a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801585:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80158a:	89 d0                	mov    %edx,%eax
  80158c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	57                   	push   %edi
  801595:	56                   	push   %esi
  801596:	53                   	push   %ebx
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a5:	eb 21                	jmp    8015c8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	89 f0                	mov    %esi,%eax
  8015ac:	29 d8                	sub    %ebx,%eax
  8015ae:	50                   	push   %eax
  8015af:	89 d8                	mov    %ebx,%eax
  8015b1:	03 45 0c             	add    0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	57                   	push   %edi
  8015b6:	e8 45 ff ff ff       	call   801500 <read>
		if (m < 0)
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 10                	js     8015d2 <readn+0x41>
			return m;
		if (m == 0)
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	74 0a                	je     8015d0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c6:	01 c3                	add    %eax,%ebx
  8015c8:	39 f3                	cmp    %esi,%ebx
  8015ca:	72 db                	jb     8015a7 <readn+0x16>
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	eb 02                	jmp    8015d2 <readn+0x41>
  8015d0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	5f                   	pop    %edi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 14             	sub    $0x14,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	53                   	push   %ebx
  8015e9:	e8 ac fc ff ff       	call   80129a <fd_lookup>
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 68                	js     80165f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	ff 30                	pushl  (%eax)
  801603:	e8 e8 fc ff ff       	call   8012f0 <dev_lookup>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 47                	js     801656 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801612:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801616:	75 21                	jne    801639 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801618:	a1 04 40 80 00       	mov    0x804004,%eax
  80161d:	8b 40 7c             	mov    0x7c(%eax),%eax
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	53                   	push   %ebx
  801624:	50                   	push   %eax
  801625:	68 45 29 80 00       	push   $0x802945
  80162a:	e8 f4 eb ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801637:	eb 26                	jmp    80165f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801639:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163c:	8b 52 0c             	mov    0xc(%edx),%edx
  80163f:	85 d2                	test   %edx,%edx
  801641:	74 17                	je     80165a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	ff 75 10             	pushl  0x10(%ebp)
  801649:	ff 75 0c             	pushl  0xc(%ebp)
  80164c:	50                   	push   %eax
  80164d:	ff d2                	call   *%edx
  80164f:	89 c2                	mov    %eax,%edx
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb 09                	jmp    80165f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801656:	89 c2                	mov    %eax,%edx
  801658:	eb 05                	jmp    80165f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80165a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80165f:	89 d0                	mov    %edx,%eax
  801661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <seek>:

int
seek(int fdnum, off_t offset)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	ff 75 08             	pushl  0x8(%ebp)
  801673:	e8 22 fc ff ff       	call   80129a <fd_lookup>
  801678:	83 c4 08             	add    $0x8,%esp
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 0e                	js     80168d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80167f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801682:	8b 55 0c             	mov    0xc(%ebp),%edx
  801685:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801688:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	53                   	push   %ebx
  801693:	83 ec 14             	sub    $0x14,%esp
  801696:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801699:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169c:	50                   	push   %eax
  80169d:	53                   	push   %ebx
  80169e:	e8 f7 fb ff ff       	call   80129a <fd_lookup>
  8016a3:	83 c4 08             	add    $0x8,%esp
  8016a6:	89 c2                	mov    %eax,%edx
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 65                	js     801711 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	50                   	push   %eax
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	ff 30                	pushl  (%eax)
  8016b8:	e8 33 fc ff ff       	call   8012f0 <dev_lookup>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 44                	js     801708 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016cb:	75 21                	jne    8016ee <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016cd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d2:	8b 40 7c             	mov    0x7c(%eax),%eax
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	53                   	push   %ebx
  8016d9:	50                   	push   %eax
  8016da:	68 08 29 80 00       	push   $0x802908
  8016df:	e8 3f eb ff ff       	call   800223 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ec:	eb 23                	jmp    801711 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f1:	8b 52 18             	mov    0x18(%edx),%edx
  8016f4:	85 d2                	test   %edx,%edx
  8016f6:	74 14                	je     80170c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	ff 75 0c             	pushl  0xc(%ebp)
  8016fe:	50                   	push   %eax
  8016ff:	ff d2                	call   *%edx
  801701:	89 c2                	mov    %eax,%edx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	eb 09                	jmp    801711 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801708:	89 c2                	mov    %eax,%edx
  80170a:	eb 05                	jmp    801711 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80170c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801711:	89 d0                	mov    %edx,%eax
  801713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 14             	sub    $0x14,%esp
  80171f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	ff 75 08             	pushl  0x8(%ebp)
  801729:	e8 6c fb ff ff       	call   80129a <fd_lookup>
  80172e:	83 c4 08             	add    $0x8,%esp
  801731:	89 c2                	mov    %eax,%edx
  801733:	85 c0                	test   %eax,%eax
  801735:	78 58                	js     80178f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801741:	ff 30                	pushl  (%eax)
  801743:	e8 a8 fb ff ff       	call   8012f0 <dev_lookup>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 37                	js     801786 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801752:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801756:	74 32                	je     80178a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801758:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80175b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801762:	00 00 00 
	stat->st_isdir = 0;
  801765:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80176c:	00 00 00 
	stat->st_dev = dev;
  80176f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801775:	83 ec 08             	sub    $0x8,%esp
  801778:	53                   	push   %ebx
  801779:	ff 75 f0             	pushl  -0x10(%ebp)
  80177c:	ff 50 14             	call   *0x14(%eax)
  80177f:	89 c2                	mov    %eax,%edx
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	eb 09                	jmp    80178f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801786:	89 c2                	mov    %eax,%edx
  801788:	eb 05                	jmp    80178f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80178a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80178f:	89 d0                	mov    %edx,%eax
  801791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	56                   	push   %esi
  80179a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	6a 00                	push   $0x0
  8017a0:	ff 75 08             	pushl  0x8(%ebp)
  8017a3:	e8 e3 01 00 00       	call   80198b <open>
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 1b                	js     8017cc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	ff 75 0c             	pushl  0xc(%ebp)
  8017b7:	50                   	push   %eax
  8017b8:	e8 5b ff ff ff       	call   801718 <fstat>
  8017bd:	89 c6                	mov    %eax,%esi
	close(fd);
  8017bf:	89 1c 24             	mov    %ebx,(%esp)
  8017c2:	e8 fd fb ff ff       	call   8013c4 <close>
	return r;
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	89 f0                	mov    %esi,%eax
}
  8017cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	89 c6                	mov    %eax,%esi
  8017da:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e3:	75 12                	jne    8017f7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e5:	83 ec 0c             	sub    $0xc,%esp
  8017e8:	6a 01                	push   $0x1
  8017ea:	e8 ea 09 00 00       	call   8021d9 <ipc_find_env>
  8017ef:	a3 00 40 80 00       	mov    %eax,0x804000
  8017f4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f7:	6a 07                	push   $0x7
  8017f9:	68 00 50 80 00       	push   $0x805000
  8017fe:	56                   	push   %esi
  8017ff:	ff 35 00 40 80 00    	pushl  0x804000
  801805:	e8 6d 09 00 00       	call   802177 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80180a:	83 c4 0c             	add    $0xc,%esp
  80180d:	6a 00                	push   $0x0
  80180f:	53                   	push   %ebx
  801810:	6a 00                	push   $0x0
  801812:	e8 e5 08 00 00       	call   8020fc <ipc_recv>
}
  801817:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80182f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801832:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801837:	ba 00 00 00 00       	mov    $0x0,%edx
  80183c:	b8 02 00 00 00       	mov    $0x2,%eax
  801841:	e8 8d ff ff ff       	call   8017d3 <fsipc>
}
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	b8 06 00 00 00       	mov    $0x6,%eax
  801863:	e8 6b ff ff ff       	call   8017d3 <fsipc>
}
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	53                   	push   %ebx
  80186e:	83 ec 04             	sub    $0x4,%esp
  801871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	8b 40 0c             	mov    0xc(%eax),%eax
  80187a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	b8 05 00 00 00       	mov    $0x5,%eax
  801889:	e8 45 ff ff ff       	call   8017d3 <fsipc>
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 2c                	js     8018be <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	68 00 50 80 00       	push   $0x805000
  80189a:	53                   	push   %ebx
  80189b:	e8 08 ef ff ff       	call   8007a8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a0:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ab:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8018cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018d8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018dd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e2:	0f 47 c2             	cmova  %edx,%eax
  8018e5:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018ea:	50                   	push   %eax
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	68 08 50 80 00       	push   $0x805008
  8018f3:	e8 42 f0 ff ff       	call   80093a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801902:	e8 cc fe ff ff       	call   8017d3 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	56                   	push   %esi
  80190d:	53                   	push   %ebx
  80190e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	8b 40 0c             	mov    0xc(%eax),%eax
  801917:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80191c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801922:	ba 00 00 00 00       	mov    $0x0,%edx
  801927:	b8 03 00 00 00       	mov    $0x3,%eax
  80192c:	e8 a2 fe ff ff       	call   8017d3 <fsipc>
  801931:	89 c3                	mov    %eax,%ebx
  801933:	85 c0                	test   %eax,%eax
  801935:	78 4b                	js     801982 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801937:	39 c6                	cmp    %eax,%esi
  801939:	73 16                	jae    801951 <devfile_read+0x48>
  80193b:	68 74 29 80 00       	push   $0x802974
  801940:	68 7b 29 80 00       	push   $0x80297b
  801945:	6a 7c                	push   $0x7c
  801947:	68 90 29 80 00       	push   $0x802990
  80194c:	e8 d6 06 00 00       	call   802027 <_panic>
	assert(r <= PGSIZE);
  801951:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801956:	7e 16                	jle    80196e <devfile_read+0x65>
  801958:	68 9b 29 80 00       	push   $0x80299b
  80195d:	68 7b 29 80 00       	push   $0x80297b
  801962:	6a 7d                	push   $0x7d
  801964:	68 90 29 80 00       	push   $0x802990
  801969:	e8 b9 06 00 00       	call   802027 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80196e:	83 ec 04             	sub    $0x4,%esp
  801971:	50                   	push   %eax
  801972:	68 00 50 80 00       	push   $0x805000
  801977:	ff 75 0c             	pushl  0xc(%ebp)
  80197a:	e8 bb ef ff ff       	call   80093a <memmove>
	return r;
  80197f:	83 c4 10             	add    $0x10,%esp
}
  801982:	89 d8                	mov    %ebx,%eax
  801984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	53                   	push   %ebx
  80198f:	83 ec 20             	sub    $0x20,%esp
  801992:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801995:	53                   	push   %ebx
  801996:	e8 d4 ed ff ff       	call   80076f <strlen>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a3:	7f 67                	jg     801a0c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ab:	50                   	push   %eax
  8019ac:	e8 9a f8 ff ff       	call   80124b <fd_alloc>
  8019b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 57                	js     801a11 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	53                   	push   %ebx
  8019be:	68 00 50 80 00       	push   $0x805000
  8019c3:	e8 e0 ed ff ff       	call   8007a8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d8:	e8 f6 fd ff ff       	call   8017d3 <fsipc>
  8019dd:	89 c3                	mov    %eax,%ebx
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	79 14                	jns    8019fa <open+0x6f>
		fd_close(fd, 0);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	6a 00                	push   $0x0
  8019eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ee:	e8 50 f9 ff ff       	call   801343 <fd_close>
		return r;
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	89 da                	mov    %ebx,%edx
  8019f8:	eb 17                	jmp    801a11 <open+0x86>
	}

	return fd2num(fd);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801a00:	e8 1f f8 ff ff       	call   801224 <fd2num>
  801a05:	89 c2                	mov    %eax,%edx
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	eb 05                	jmp    801a11 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a0c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a11:	89 d0                	mov    %edx,%eax
  801a13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a23:	b8 08 00 00 00       	mov    $0x8,%eax
  801a28:	e8 a6 fd ff ff       	call   8017d3 <fsipc>
}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801a2f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a33:	7e 37                	jle    801a6c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 08             	sub    $0x8,%esp
  801a3c:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a3e:	ff 70 04             	pushl  0x4(%eax)
  801a41:	8d 40 10             	lea    0x10(%eax),%eax
  801a44:	50                   	push   %eax
  801a45:	ff 33                	pushl  (%ebx)
  801a47:	e8 8e fb ff ff       	call   8015da <write>
		if (result > 0)
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	7e 03                	jle    801a56 <writebuf+0x27>
			b->result += result;
  801a53:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a56:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a59:	74 0d                	je     801a68 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a62:	0f 4f c2             	cmovg  %edx,%eax
  801a65:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6b:	c9                   	leave  
  801a6c:	f3 c3                	repz ret 

00801a6e <putch>:

static void
putch(int ch, void *thunk)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	53                   	push   %ebx
  801a72:	83 ec 04             	sub    $0x4,%esp
  801a75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a78:	8b 53 04             	mov    0x4(%ebx),%edx
  801a7b:	8d 42 01             	lea    0x1(%edx),%eax
  801a7e:	89 43 04             	mov    %eax,0x4(%ebx)
  801a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a84:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a88:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a8d:	75 0e                	jne    801a9d <putch+0x2f>
		writebuf(b);
  801a8f:	89 d8                	mov    %ebx,%eax
  801a91:	e8 99 ff ff ff       	call   801a2f <writebuf>
		b->idx = 0;
  801a96:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a9d:	83 c4 04             	add    $0x4,%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801ab5:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801abc:	00 00 00 
	b.result = 0;
  801abf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ac6:	00 00 00 
	b.error = 1;
  801ac9:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801ad0:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801ad3:	ff 75 10             	pushl  0x10(%ebp)
  801ad6:	ff 75 0c             	pushl  0xc(%ebp)
  801ad9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	68 6e 1a 80 00       	push   $0x801a6e
  801ae5:	e8 70 e8 ff ff       	call   80035a <vprintfmt>
	if (b.idx > 0)
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801af4:	7e 0b                	jle    801b01 <vfprintf+0x5e>
		writebuf(&b);
  801af6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801afc:	e8 2e ff ff ff       	call   801a2f <writebuf>

	return (b.result ? b.result : b.error);
  801b01:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b07:	85 c0                	test   %eax,%eax
  801b09:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b18:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b1b:	50                   	push   %eax
  801b1c:	ff 75 0c             	pushl  0xc(%ebp)
  801b1f:	ff 75 08             	pushl  0x8(%ebp)
  801b22:	e8 7c ff ff ff       	call   801aa3 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <printf>:

int
printf(const char *fmt, ...)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b2f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b32:	50                   	push   %eax
  801b33:	ff 75 08             	pushl  0x8(%ebp)
  801b36:	6a 01                	push   $0x1
  801b38:	e8 66 ff ff ff       	call   801aa3 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	ff 75 08             	pushl  0x8(%ebp)
  801b4d:	e8 e2 f6 ff ff       	call   801234 <fd2data>
  801b52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b54:	83 c4 08             	add    $0x8,%esp
  801b57:	68 a7 29 80 00       	push   $0x8029a7
  801b5c:	53                   	push   %ebx
  801b5d:	e8 46 ec ff ff       	call   8007a8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b62:	8b 46 04             	mov    0x4(%esi),%eax
  801b65:	2b 06                	sub    (%esi),%eax
  801b67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b74:	00 00 00 
	stat->st_dev = &devpipe;
  801b77:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b7e:	30 80 00 
	return 0;
}
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	53                   	push   %ebx
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b97:	53                   	push   %ebx
  801b98:	6a 00                	push   $0x0
  801b9a:	e8 91 f0 ff ff       	call   800c30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b9f:	89 1c 24             	mov    %ebx,(%esp)
  801ba2:	e8 8d f6 ff ff       	call   801234 <fd2data>
  801ba7:	83 c4 08             	add    $0x8,%esp
  801baa:	50                   	push   %eax
  801bab:	6a 00                	push   $0x0
  801bad:	e8 7e f0 ff ff       	call   800c30 <sys_page_unmap>
}
  801bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	57                   	push   %edi
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 1c             	sub    $0x1c,%esp
  801bc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bc3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bc5:	a1 04 40 80 00       	mov    0x804004,%eax
  801bca:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	ff 75 e0             	pushl  -0x20(%ebp)
  801bd6:	e8 40 06 00 00       	call   80221b <pageref>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	89 3c 24             	mov    %edi,(%esp)
  801be0:	e8 36 06 00 00       	call   80221b <pageref>
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	39 c3                	cmp    %eax,%ebx
  801bea:	0f 94 c1             	sete   %cl
  801bed:	0f b6 c9             	movzbl %cl,%ecx
  801bf0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bf3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bf9:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801bff:	39 ce                	cmp    %ecx,%esi
  801c01:	74 1e                	je     801c21 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c03:	39 c3                	cmp    %eax,%ebx
  801c05:	75 be                	jne    801bc5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c07:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801c0d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c10:	50                   	push   %eax
  801c11:	56                   	push   %esi
  801c12:	68 ae 29 80 00       	push   $0x8029ae
  801c17:	e8 07 e6 ff ff       	call   800223 <cprintf>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	eb a4                	jmp    801bc5 <_pipeisclosed+0xe>
	}
}
  801c21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5f                   	pop    %edi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	57                   	push   %edi
  801c30:	56                   	push   %esi
  801c31:	53                   	push   %ebx
  801c32:	83 ec 28             	sub    $0x28,%esp
  801c35:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c38:	56                   	push   %esi
  801c39:	e8 f6 f5 ff ff       	call   801234 <fd2data>
  801c3e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	bf 00 00 00 00       	mov    $0x0,%edi
  801c48:	eb 4b                	jmp    801c95 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c4a:	89 da                	mov    %ebx,%edx
  801c4c:	89 f0                	mov    %esi,%eax
  801c4e:	e8 64 ff ff ff       	call   801bb7 <_pipeisclosed>
  801c53:	85 c0                	test   %eax,%eax
  801c55:	75 48                	jne    801c9f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c57:	e8 30 ef ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c5c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c5f:	8b 0b                	mov    (%ebx),%ecx
  801c61:	8d 51 20             	lea    0x20(%ecx),%edx
  801c64:	39 d0                	cmp    %edx,%eax
  801c66:	73 e2                	jae    801c4a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c6f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c72:	89 c2                	mov    %eax,%edx
  801c74:	c1 fa 1f             	sar    $0x1f,%edx
  801c77:	89 d1                	mov    %edx,%ecx
  801c79:	c1 e9 1b             	shr    $0x1b,%ecx
  801c7c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c7f:	83 e2 1f             	and    $0x1f,%edx
  801c82:	29 ca                	sub    %ecx,%edx
  801c84:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c88:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c8c:	83 c0 01             	add    $0x1,%eax
  801c8f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c92:	83 c7 01             	add    $0x1,%edi
  801c95:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c98:	75 c2                	jne    801c5c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c9a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9d:	eb 05                	jmp    801ca4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c9f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5f                   	pop    %edi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	57                   	push   %edi
  801cb0:	56                   	push   %esi
  801cb1:	53                   	push   %ebx
  801cb2:	83 ec 18             	sub    $0x18,%esp
  801cb5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cb8:	57                   	push   %edi
  801cb9:	e8 76 f5 ff ff       	call   801234 <fd2data>
  801cbe:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc8:	eb 3d                	jmp    801d07 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cca:	85 db                	test   %ebx,%ebx
  801ccc:	74 04                	je     801cd2 <devpipe_read+0x26>
				return i;
  801cce:	89 d8                	mov    %ebx,%eax
  801cd0:	eb 44                	jmp    801d16 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	89 f8                	mov    %edi,%eax
  801cd6:	e8 dc fe ff ff       	call   801bb7 <_pipeisclosed>
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	75 32                	jne    801d11 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cdf:	e8 a8 ee ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ce4:	8b 06                	mov    (%esi),%eax
  801ce6:	3b 46 04             	cmp    0x4(%esi),%eax
  801ce9:	74 df                	je     801cca <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ceb:	99                   	cltd   
  801cec:	c1 ea 1b             	shr    $0x1b,%edx
  801cef:	01 d0                	add    %edx,%eax
  801cf1:	83 e0 1f             	and    $0x1f,%eax
  801cf4:	29 d0                	sub    %edx,%eax
  801cf6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfe:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d01:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d04:	83 c3 01             	add    $0x1,%ebx
  801d07:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d0a:	75 d8                	jne    801ce4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0f:	eb 05                	jmp    801d16 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5f                   	pop    %edi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	e8 1c f5 ff ff       	call   80124b <fd_alloc>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	89 c2                	mov    %eax,%edx
  801d34:	85 c0                	test   %eax,%eax
  801d36:	0f 88 2c 01 00 00    	js     801e68 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3c:	83 ec 04             	sub    $0x4,%esp
  801d3f:	68 07 04 00 00       	push   $0x407
  801d44:	ff 75 f4             	pushl  -0xc(%ebp)
  801d47:	6a 00                	push   $0x0
  801d49:	e8 5d ee ff ff       	call   800bab <sys_page_alloc>
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	89 c2                	mov    %eax,%edx
  801d53:	85 c0                	test   %eax,%eax
  801d55:	0f 88 0d 01 00 00    	js     801e68 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d61:	50                   	push   %eax
  801d62:	e8 e4 f4 ff ff       	call   80124b <fd_alloc>
  801d67:	89 c3                	mov    %eax,%ebx
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	0f 88 e2 00 00 00    	js     801e56 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d74:	83 ec 04             	sub    $0x4,%esp
  801d77:	68 07 04 00 00       	push   $0x407
  801d7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 25 ee ff ff       	call   800bab <sys_page_alloc>
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	0f 88 c3 00 00 00    	js     801e56 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d93:	83 ec 0c             	sub    $0xc,%esp
  801d96:	ff 75 f4             	pushl  -0xc(%ebp)
  801d99:	e8 96 f4 ff ff       	call   801234 <fd2data>
  801d9e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da0:	83 c4 0c             	add    $0xc,%esp
  801da3:	68 07 04 00 00       	push   $0x407
  801da8:	50                   	push   %eax
  801da9:	6a 00                	push   $0x0
  801dab:	e8 fb ed ff ff       	call   800bab <sys_page_alloc>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	85 c0                	test   %eax,%eax
  801db7:	0f 88 89 00 00 00    	js     801e46 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbd:	83 ec 0c             	sub    $0xc,%esp
  801dc0:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc3:	e8 6c f4 ff ff       	call   801234 <fd2data>
  801dc8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dcf:	50                   	push   %eax
  801dd0:	6a 00                	push   $0x0
  801dd2:	56                   	push   %esi
  801dd3:	6a 00                	push   $0x0
  801dd5:	e8 14 ee ff ff       	call   800bee <sys_page_map>
  801dda:	89 c3                	mov    %eax,%ebx
  801ddc:	83 c4 20             	add    $0x20,%esp
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 55                	js     801e38 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801df8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e01:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e06:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e0d:	83 ec 0c             	sub    $0xc,%esp
  801e10:	ff 75 f4             	pushl  -0xc(%ebp)
  801e13:	e8 0c f4 ff ff       	call   801224 <fd2num>
  801e18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e1b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e1d:	83 c4 04             	add    $0x4,%esp
  801e20:	ff 75 f0             	pushl  -0x10(%ebp)
  801e23:	e8 fc f3 ff ff       	call   801224 <fd2num>
  801e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e2b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	ba 00 00 00 00       	mov    $0x0,%edx
  801e36:	eb 30                	jmp    801e68 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e38:	83 ec 08             	sub    $0x8,%esp
  801e3b:	56                   	push   %esi
  801e3c:	6a 00                	push   $0x0
  801e3e:	e8 ed ed ff ff       	call   800c30 <sys_page_unmap>
  801e43:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e46:	83 ec 08             	sub    $0x8,%esp
  801e49:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4c:	6a 00                	push   $0x0
  801e4e:	e8 dd ed ff ff       	call   800c30 <sys_page_unmap>
  801e53:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5c:	6a 00                	push   $0x0
  801e5e:	e8 cd ed ff ff       	call   800c30 <sys_page_unmap>
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e68:	89 d0                	mov    %edx,%eax
  801e6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7a:	50                   	push   %eax
  801e7b:	ff 75 08             	pushl  0x8(%ebp)
  801e7e:	e8 17 f4 ff ff       	call   80129a <fd_lookup>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 18                	js     801ea2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e90:	e8 9f f3 ff ff       	call   801234 <fd2data>
	return _pipeisclosed(fd, p);
  801e95:	89 c2                	mov    %eax,%edx
  801e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9a:	e8 18 fd ff ff       	call   801bb7 <_pipeisclosed>
  801e9f:	83 c4 10             	add    $0x10,%esp
}
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb4:	68 c6 29 80 00       	push   $0x8029c6
  801eb9:	ff 75 0c             	pushl  0xc(%ebp)
  801ebc:	e8 e7 e8 ff ff       	call   8007a8 <strcpy>
	return 0;
}
  801ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	57                   	push   %edi
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801edf:	eb 2d                	jmp    801f0e <devcons_write+0x46>
		m = n - tot;
  801ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ee6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eee:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	53                   	push   %ebx
  801ef5:	03 45 0c             	add    0xc(%ebp),%eax
  801ef8:	50                   	push   %eax
  801ef9:	57                   	push   %edi
  801efa:	e8 3b ea ff ff       	call   80093a <memmove>
		sys_cputs(buf, m);
  801eff:	83 c4 08             	add    $0x8,%esp
  801f02:	53                   	push   %ebx
  801f03:	57                   	push   %edi
  801f04:	e8 e6 eb ff ff       	call   800aef <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f09:	01 de                	add    %ebx,%esi
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	89 f0                	mov    %esi,%eax
  801f10:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f13:	72 cc                	jb     801ee1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 08             	sub    $0x8,%esp
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f28:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2c:	74 2a                	je     801f58 <devcons_read+0x3b>
  801f2e:	eb 05                	jmp    801f35 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f30:	e8 57 ec ff ff       	call   800b8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f35:	e8 d3 eb ff ff       	call   800b0d <sys_cgetc>
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	74 f2                	je     801f30 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 16                	js     801f58 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f42:	83 f8 04             	cmp    $0x4,%eax
  801f45:	74 0c                	je     801f53 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4a:	88 02                	mov    %al,(%edx)
	return 1;
  801f4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f51:	eb 05                	jmp    801f58 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f60:	8b 45 08             	mov    0x8(%ebp),%eax
  801f63:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f66:	6a 01                	push   $0x1
  801f68:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6b:	50                   	push   %eax
  801f6c:	e8 7e eb ff ff       	call   800aef <sys_cputs>
}
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    

00801f76 <getchar>:

int
getchar(void)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f7c:	6a 01                	push   $0x1
  801f7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	6a 00                	push   $0x0
  801f84:	e8 77 f5 ff ff       	call   801500 <read>
	if (r < 0)
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 0f                	js     801f9f <getchar+0x29>
		return r;
	if (r < 1)
  801f90:	85 c0                	test   %eax,%eax
  801f92:	7e 06                	jle    801f9a <getchar+0x24>
		return -E_EOF;
	return c;
  801f94:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f98:	eb 05                	jmp    801f9f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f9a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801faa:	50                   	push   %eax
  801fab:	ff 75 08             	pushl  0x8(%ebp)
  801fae:	e8 e7 f2 ff ff       	call   80129a <fd_lookup>
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 11                	js     801fcb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc3:	39 10                	cmp    %edx,(%eax)
  801fc5:	0f 94 c0             	sete   %al
  801fc8:	0f b6 c0             	movzbl %al,%eax
}
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <opencons>:

int
opencons(void)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd6:	50                   	push   %eax
  801fd7:	e8 6f f2 ff ff       	call   80124b <fd_alloc>
  801fdc:	83 c4 10             	add    $0x10,%esp
		return r;
  801fdf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 3e                	js     802023 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe5:	83 ec 04             	sub    $0x4,%esp
  801fe8:	68 07 04 00 00       	push   $0x407
  801fed:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff0:	6a 00                	push   $0x0
  801ff2:	e8 b4 eb ff ff       	call   800bab <sys_page_alloc>
  801ff7:	83 c4 10             	add    $0x10,%esp
		return r;
  801ffa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	78 23                	js     802023 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802000:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802006:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802009:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80200b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	50                   	push   %eax
  802019:	e8 06 f2 ff ff       	call   801224 <fd2num>
  80201e:	89 c2                	mov    %eax,%edx
  802020:	83 c4 10             	add    $0x10,%esp
}
  802023:	89 d0                	mov    %edx,%eax
  802025:	c9                   	leave  
  802026:	c3                   	ret    

00802027 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	56                   	push   %esi
  80202b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80202c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80202f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802035:	e8 33 eb ff ff       	call   800b6d <sys_getenvid>
  80203a:	83 ec 0c             	sub    $0xc,%esp
  80203d:	ff 75 0c             	pushl  0xc(%ebp)
  802040:	ff 75 08             	pushl  0x8(%ebp)
  802043:	56                   	push   %esi
  802044:	50                   	push   %eax
  802045:	68 d4 29 80 00       	push   $0x8029d4
  80204a:	e8 d4 e1 ff ff       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80204f:	83 c4 18             	add    $0x18,%esp
  802052:	53                   	push   %ebx
  802053:	ff 75 10             	pushl  0x10(%ebp)
  802056:	e8 77 e1 ff ff       	call   8001d2 <vcprintf>
	cprintf("\n");
  80205b:	c7 04 24 10 25 80 00 	movl   $0x802510,(%esp)
  802062:	e8 bc e1 ff ff       	call   800223 <cprintf>
  802067:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80206a:	cc                   	int3   
  80206b:	eb fd                	jmp    80206a <_panic+0x43>

0080206d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802073:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80207a:	75 2a                	jne    8020a6 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80207c:	83 ec 04             	sub    $0x4,%esp
  80207f:	6a 07                	push   $0x7
  802081:	68 00 f0 bf ee       	push   $0xeebff000
  802086:	6a 00                	push   $0x0
  802088:	e8 1e eb ff ff       	call   800bab <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	85 c0                	test   %eax,%eax
  802092:	79 12                	jns    8020a6 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802094:	50                   	push   %eax
  802095:	68 f8 29 80 00       	push   $0x8029f8
  80209a:	6a 23                	push   $0x23
  80209c:	68 fc 29 80 00       	push   $0x8029fc
  8020a1:	e8 81 ff ff ff       	call   802027 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a9:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020ae:	83 ec 08             	sub    $0x8,%esp
  8020b1:	68 d8 20 80 00       	push   $0x8020d8
  8020b6:	6a 00                	push   $0x0
  8020b8:	e8 39 ec ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	79 12                	jns    8020d6 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020c4:	50                   	push   %eax
  8020c5:	68 f8 29 80 00       	push   $0x8029f8
  8020ca:	6a 2c                	push   $0x2c
  8020cc:	68 fc 29 80 00       	push   $0x8029fc
  8020d1:	e8 51 ff ff ff       	call   802027 <_panic>
	}
}
  8020d6:	c9                   	leave  
  8020d7:	c3                   	ret    

008020d8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020d9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020e0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020e3:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020e7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020ec:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020f0:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020f2:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020f5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020f6:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020f9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020fa:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020fb:	c3                   	ret    

008020fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	56                   	push   %esi
  802100:	53                   	push   %ebx
  802101:	8b 75 08             	mov    0x8(%ebp),%esi
  802104:	8b 45 0c             	mov    0xc(%ebp),%eax
  802107:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80210a:	85 c0                	test   %eax,%eax
  80210c:	75 12                	jne    802120 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80210e:	83 ec 0c             	sub    $0xc,%esp
  802111:	68 00 00 c0 ee       	push   $0xeec00000
  802116:	e8 40 ec ff ff       	call   800d5b <sys_ipc_recv>
  80211b:	83 c4 10             	add    $0x10,%esp
  80211e:	eb 0c                	jmp    80212c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	50                   	push   %eax
  802124:	e8 32 ec ff ff       	call   800d5b <sys_ipc_recv>
  802129:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80212c:	85 f6                	test   %esi,%esi
  80212e:	0f 95 c1             	setne  %cl
  802131:	85 db                	test   %ebx,%ebx
  802133:	0f 95 c2             	setne  %dl
  802136:	84 d1                	test   %dl,%cl
  802138:	74 09                	je     802143 <ipc_recv+0x47>
  80213a:	89 c2                	mov    %eax,%edx
  80213c:	c1 ea 1f             	shr    $0x1f,%edx
  80213f:	84 d2                	test   %dl,%dl
  802141:	75 2d                	jne    802170 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802143:	85 f6                	test   %esi,%esi
  802145:	74 0d                	je     802154 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802147:	a1 04 40 80 00       	mov    0x804004,%eax
  80214c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802152:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802154:	85 db                	test   %ebx,%ebx
  802156:	74 0d                	je     802165 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802158:	a1 04 40 80 00       	mov    0x804004,%eax
  80215d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802163:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802165:	a1 04 40 80 00       	mov    0x804004,%eax
  80216a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802170:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    

00802177 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	57                   	push   %edi
  80217b:	56                   	push   %esi
  80217c:	53                   	push   %ebx
  80217d:	83 ec 0c             	sub    $0xc,%esp
  802180:	8b 7d 08             	mov    0x8(%ebp),%edi
  802183:	8b 75 0c             	mov    0xc(%ebp),%esi
  802186:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802189:	85 db                	test   %ebx,%ebx
  80218b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802190:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802193:	ff 75 14             	pushl  0x14(%ebp)
  802196:	53                   	push   %ebx
  802197:	56                   	push   %esi
  802198:	57                   	push   %edi
  802199:	e8 9a eb ff ff       	call   800d38 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80219e:	89 c2                	mov    %eax,%edx
  8021a0:	c1 ea 1f             	shr    $0x1f,%edx
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	84 d2                	test   %dl,%dl
  8021a8:	74 17                	je     8021c1 <ipc_send+0x4a>
  8021aa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ad:	74 12                	je     8021c1 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021af:	50                   	push   %eax
  8021b0:	68 0a 2a 80 00       	push   $0x802a0a
  8021b5:	6a 47                	push   $0x47
  8021b7:	68 18 2a 80 00       	push   $0x802a18
  8021bc:	e8 66 fe ff ff       	call   802027 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021c4:	75 07                	jne    8021cd <ipc_send+0x56>
			sys_yield();
  8021c6:	e8 c1 e9 ff ff       	call   800b8c <sys_yield>
  8021cb:	eb c6                	jmp    802193 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021cd:	85 c0                	test   %eax,%eax
  8021cf:	75 c2                	jne    802193 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    

008021d9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021d9:	55                   	push   %ebp
  8021da:	89 e5                	mov    %esp,%ebp
  8021dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021df:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021e4:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  8021ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021f0:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8021f6:	39 ca                	cmp    %ecx,%edx
  8021f8:	75 10                	jne    80220a <ipc_find_env+0x31>
			return envs[i].env_id;
  8021fa:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  802200:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802205:	8b 40 7c             	mov    0x7c(%eax),%eax
  802208:	eb 0f                	jmp    802219 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80220a:	83 c0 01             	add    $0x1,%eax
  80220d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802212:	75 d0                	jne    8021e4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802214:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802221:	89 d0                	mov    %edx,%eax
  802223:	c1 e8 16             	shr    $0x16,%eax
  802226:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802232:	f6 c1 01             	test   $0x1,%cl
  802235:	74 1d                	je     802254 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802237:	c1 ea 0c             	shr    $0xc,%edx
  80223a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802241:	f6 c2 01             	test   $0x1,%dl
  802244:	74 0e                	je     802254 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802246:	c1 ea 0c             	shr    $0xc,%edx
  802249:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802250:	ef 
  802251:	0f b7 c0             	movzwl %ax,%eax
}
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    
  802256:	66 90                	xchg   %ax,%ax
  802258:	66 90                	xchg   %ax,%ax
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__udivdi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80226b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80226f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 f6                	test   %esi,%esi
  802279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227d:	89 ca                	mov    %ecx,%edx
  80227f:	89 f8                	mov    %edi,%eax
  802281:	75 3d                	jne    8022c0 <__udivdi3+0x60>
  802283:	39 cf                	cmp    %ecx,%edi
  802285:	0f 87 c5 00 00 00    	ja     802350 <__udivdi3+0xf0>
  80228b:	85 ff                	test   %edi,%edi
  80228d:	89 fd                	mov    %edi,%ebp
  80228f:	75 0b                	jne    80229c <__udivdi3+0x3c>
  802291:	b8 01 00 00 00       	mov    $0x1,%eax
  802296:	31 d2                	xor    %edx,%edx
  802298:	f7 f7                	div    %edi
  80229a:	89 c5                	mov    %eax,%ebp
  80229c:	89 c8                	mov    %ecx,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	f7 f5                	div    %ebp
  8022a2:	89 c1                	mov    %eax,%ecx
  8022a4:	89 d8                	mov    %ebx,%eax
  8022a6:	89 cf                	mov    %ecx,%edi
  8022a8:	f7 f5                	div    %ebp
  8022aa:	89 c3                	mov    %eax,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	39 ce                	cmp    %ecx,%esi
  8022c2:	77 74                	ja     802338 <__udivdi3+0xd8>
  8022c4:	0f bd fe             	bsr    %esi,%edi
  8022c7:	83 f7 1f             	xor    $0x1f,%edi
  8022ca:	0f 84 98 00 00 00    	je     802368 <__udivdi3+0x108>
  8022d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	89 c5                	mov    %eax,%ebp
  8022d9:	29 fb                	sub    %edi,%ebx
  8022db:	d3 e6                	shl    %cl,%esi
  8022dd:	89 d9                	mov    %ebx,%ecx
  8022df:	d3 ed                	shr    %cl,%ebp
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	d3 e0                	shl    %cl,%eax
  8022e5:	09 ee                	or     %ebp,%esi
  8022e7:	89 d9                	mov    %ebx,%ecx
  8022e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ed:	89 d5                	mov    %edx,%ebp
  8022ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022f3:	d3 ed                	shr    %cl,%ebp
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e2                	shl    %cl,%edx
  8022f9:	89 d9                	mov    %ebx,%ecx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	09 c2                	or     %eax,%edx
  8022ff:	89 d0                	mov    %edx,%eax
  802301:	89 ea                	mov    %ebp,%edx
  802303:	f7 f6                	div    %esi
  802305:	89 d5                	mov    %edx,%ebp
  802307:	89 c3                	mov    %eax,%ebx
  802309:	f7 64 24 0c          	mull   0xc(%esp)
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	72 10                	jb     802321 <__udivdi3+0xc1>
  802311:	8b 74 24 08          	mov    0x8(%esp),%esi
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e6                	shl    %cl,%esi
  802319:	39 c6                	cmp    %eax,%esi
  80231b:	73 07                	jae    802324 <__udivdi3+0xc4>
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	75 03                	jne    802324 <__udivdi3+0xc4>
  802321:	83 eb 01             	sub    $0x1,%ebx
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 d8                	mov    %ebx,%eax
  802328:	89 fa                	mov    %edi,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	31 ff                	xor    %edi,%edi
  80233a:	31 db                	xor    %ebx,%ebx
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	89 fa                	mov    %edi,%edx
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	89 d8                	mov    %ebx,%eax
  802352:	f7 f7                	div    %edi
  802354:	31 ff                	xor    %edi,%edi
  802356:	89 c3                	mov    %eax,%ebx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 fa                	mov    %edi,%edx
  80235c:	83 c4 1c             	add    $0x1c,%esp
  80235f:	5b                   	pop    %ebx
  802360:	5e                   	pop    %esi
  802361:	5f                   	pop    %edi
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    
  802364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802368:	39 ce                	cmp    %ecx,%esi
  80236a:	72 0c                	jb     802378 <__udivdi3+0x118>
  80236c:	31 db                	xor    %ebx,%ebx
  80236e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802372:	0f 87 34 ff ff ff    	ja     8022ac <__udivdi3+0x4c>
  802378:	bb 01 00 00 00       	mov    $0x1,%ebx
  80237d:	e9 2a ff ff ff       	jmp    8022ac <__udivdi3+0x4c>
  802382:	66 90                	xchg   %ax,%ax
  802384:	66 90                	xchg   %ax,%ax
  802386:	66 90                	xchg   %ax,%ax
  802388:	66 90                	xchg   %ax,%ax
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <__umoddi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80239b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80239f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 d2                	test   %edx,%edx
  8023a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023b1:	89 f3                	mov    %esi,%ebx
  8023b3:	89 3c 24             	mov    %edi,(%esp)
  8023b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ba:	75 1c                	jne    8023d8 <__umoddi3+0x48>
  8023bc:	39 f7                	cmp    %esi,%edi
  8023be:	76 50                	jbe    802410 <__umoddi3+0x80>
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	f7 f7                	div    %edi
  8023c6:	89 d0                	mov    %edx,%eax
  8023c8:	31 d2                	xor    %edx,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	39 f2                	cmp    %esi,%edx
  8023da:	89 d0                	mov    %edx,%eax
  8023dc:	77 52                	ja     802430 <__umoddi3+0xa0>
  8023de:	0f bd ea             	bsr    %edx,%ebp
  8023e1:	83 f5 1f             	xor    $0x1f,%ebp
  8023e4:	75 5a                	jne    802440 <__umoddi3+0xb0>
  8023e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ea:	0f 82 e0 00 00 00    	jb     8024d0 <__umoddi3+0x140>
  8023f0:	39 0c 24             	cmp    %ecx,(%esp)
  8023f3:	0f 86 d7 00 00 00    	jbe    8024d0 <__umoddi3+0x140>
  8023f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802401:	83 c4 1c             	add    $0x1c,%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	85 ff                	test   %edi,%edi
  802412:	89 fd                	mov    %edi,%ebp
  802414:	75 0b                	jne    802421 <__umoddi3+0x91>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f7                	div    %edi
  80241f:	89 c5                	mov    %eax,%ebp
  802421:	89 f0                	mov    %esi,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f5                	div    %ebp
  802427:	89 c8                	mov    %ecx,%eax
  802429:	f7 f5                	div    %ebp
  80242b:	89 d0                	mov    %edx,%eax
  80242d:	eb 99                	jmp    8023c8 <__umoddi3+0x38>
  80242f:	90                   	nop
  802430:	89 c8                	mov    %ecx,%eax
  802432:	89 f2                	mov    %esi,%edx
  802434:	83 c4 1c             	add    $0x1c,%esp
  802437:	5b                   	pop    %ebx
  802438:	5e                   	pop    %esi
  802439:	5f                   	pop    %edi
  80243a:	5d                   	pop    %ebp
  80243b:	c3                   	ret    
  80243c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802440:	8b 34 24             	mov    (%esp),%esi
  802443:	bf 20 00 00 00       	mov    $0x20,%edi
  802448:	89 e9                	mov    %ebp,%ecx
  80244a:	29 ef                	sub    %ebp,%edi
  80244c:	d3 e0                	shl    %cl,%eax
  80244e:	89 f9                	mov    %edi,%ecx
  802450:	89 f2                	mov    %esi,%edx
  802452:	d3 ea                	shr    %cl,%edx
  802454:	89 e9                	mov    %ebp,%ecx
  802456:	09 c2                	or     %eax,%edx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 14 24             	mov    %edx,(%esp)
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	d3 e2                	shl    %cl,%edx
  802461:	89 f9                	mov    %edi,%ecx
  802463:	89 54 24 04          	mov    %edx,0x4(%esp)
  802467:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	89 c6                	mov    %eax,%esi
  802471:	d3 e3                	shl    %cl,%ebx
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 d0                	mov    %edx,%eax
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	09 d8                	or     %ebx,%eax
  80247d:	89 d3                	mov    %edx,%ebx
  80247f:	89 f2                	mov    %esi,%edx
  802481:	f7 34 24             	divl   (%esp)
  802484:	89 d6                	mov    %edx,%esi
  802486:	d3 e3                	shl    %cl,%ebx
  802488:	f7 64 24 04          	mull   0x4(%esp)
  80248c:	39 d6                	cmp    %edx,%esi
  80248e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802492:	89 d1                	mov    %edx,%ecx
  802494:	89 c3                	mov    %eax,%ebx
  802496:	72 08                	jb     8024a0 <__umoddi3+0x110>
  802498:	75 11                	jne    8024ab <__umoddi3+0x11b>
  80249a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80249e:	73 0b                	jae    8024ab <__umoddi3+0x11b>
  8024a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024a4:	1b 14 24             	sbb    (%esp),%edx
  8024a7:	89 d1                	mov    %edx,%ecx
  8024a9:	89 c3                	mov    %eax,%ebx
  8024ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024af:	29 da                	sub    %ebx,%edx
  8024b1:	19 ce                	sbb    %ecx,%esi
  8024b3:	89 f9                	mov    %edi,%ecx
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	d3 e0                	shl    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	d3 ea                	shr    %cl,%edx
  8024bd:	89 e9                	mov    %ebp,%ecx
  8024bf:	d3 ee                	shr    %cl,%esi
  8024c1:	09 d0                	or     %edx,%eax
  8024c3:	89 f2                	mov    %esi,%edx
  8024c5:	83 c4 1c             	add    $0x1c,%esp
  8024c8:	5b                   	pop    %ebx
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
  8024d0:	29 f9                	sub    %edi,%ecx
  8024d2:	19 d6                	sbb    %edx,%esi
  8024d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dc:	e9 18 ff ff ff       	jmp    8023f9 <__umoddi3+0x69>
