
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
  800039:	68 40 25 80 00       	push   $0x802540
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
  800067:	e8 aa 10 00 00       	call   801116 <argstart>
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
  800091:	e8 b0 10 00 00       	call   801146 <argnext>
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
  8000ad:	e8 b8 16 00 00       	call   80176a <fstat>
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
  8000ce:	68 54 25 80 00       	push   $0x802554
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 8a 1a 00 00       	call   801b64 <fprintf>
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
  8000f0:	68 54 25 80 00       	push   $0x802554
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
  800122:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  80017c:	e8 b7 12 00 00       	call   801438 <close_all>
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
  800286:	e8 25 20 00 00       	call   8022b0 <__udivdi3>
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
  8002c9:	e8 12 21 00 00       	call   8023e0 <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 86 25 80 00 	movsbl 0x802586(%eax),%eax
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
  8003cd:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
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
  800491:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  800498:	85 d2                	test   %edx,%edx
  80049a:	75 18                	jne    8004b4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049c:	50                   	push   %eax
  80049d:	68 9e 25 80 00       	push   $0x80259e
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
  8004b5:	68 cd 29 80 00       	push   $0x8029cd
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
  8004d9:	b8 97 25 80 00       	mov    $0x802597,%eax
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
  800b54:	68 7f 28 80 00       	push   $0x80287f
  800b59:	6a 23                	push   $0x23
  800b5b:	68 9c 28 80 00       	push   $0x80289c
  800b60:	e8 14 15 00 00       	call   802079 <_panic>

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
  800bd5:	68 7f 28 80 00       	push   $0x80287f
  800bda:	6a 23                	push   $0x23
  800bdc:	68 9c 28 80 00       	push   $0x80289c
  800be1:	e8 93 14 00 00       	call   802079 <_panic>

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
  800c17:	68 7f 28 80 00       	push   $0x80287f
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 9c 28 80 00       	push   $0x80289c
  800c23:	e8 51 14 00 00       	call   802079 <_panic>

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
  800c59:	68 7f 28 80 00       	push   $0x80287f
  800c5e:	6a 23                	push   $0x23
  800c60:	68 9c 28 80 00       	push   $0x80289c
  800c65:	e8 0f 14 00 00       	call   802079 <_panic>

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
  800c9b:	68 7f 28 80 00       	push   $0x80287f
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 9c 28 80 00       	push   $0x80289c
  800ca7:	e8 cd 13 00 00       	call   802079 <_panic>

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
  800cdd:	68 7f 28 80 00       	push   $0x80287f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 9c 28 80 00       	push   $0x80289c
  800ce9:	e8 8b 13 00 00       	call   802079 <_panic>
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
  800d1f:	68 7f 28 80 00       	push   $0x80287f
  800d24:	6a 23                	push   $0x23
  800d26:	68 9c 28 80 00       	push   $0x80289c
  800d2b:	e8 49 13 00 00       	call   802079 <_panic>

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
  800d83:	68 7f 28 80 00       	push   $0x80287f
  800d88:	6a 23                	push   $0x23
  800d8a:	68 9c 28 80 00       	push   $0x80289c
  800d8f:	e8 e5 12 00 00       	call   802079 <_panic>

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
  800e22:	68 aa 28 80 00       	push   $0x8028aa
  800e27:	6a 1e                	push   $0x1e
  800e29:	68 ba 28 80 00       	push   $0x8028ba
  800e2e:	e8 46 12 00 00       	call   802079 <_panic>
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
  800e4c:	68 c5 28 80 00       	push   $0x8028c5
  800e51:	6a 2c                	push   $0x2c
  800e53:	68 ba 28 80 00       	push   $0x8028ba
  800e58:	e8 1c 12 00 00       	call   802079 <_panic>
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
  800e94:	68 c5 28 80 00       	push   $0x8028c5
  800e99:	6a 33                	push   $0x33
  800e9b:	68 ba 28 80 00       	push   $0x8028ba
  800ea0:	e8 d4 11 00 00       	call   802079 <_panic>
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
  800ebc:	68 c5 28 80 00       	push   $0x8028c5
  800ec1:	6a 37                	push   $0x37
  800ec3:	68 ba 28 80 00       	push   $0x8028ba
  800ec8:	e8 ac 11 00 00       	call   802079 <_panic>
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
  800ee0:	e8 da 11 00 00       	call   8020bf <set_pgfault_handler>
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
  800ef9:	68 de 28 80 00       	push   $0x8028de
  800efe:	68 84 00 00 00       	push   $0x84
  800f03:	68 ba 28 80 00       	push   $0x8028ba
  800f08:	e8 6c 11 00 00       	call   802079 <_panic>
  800f0d:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f13:	75 24                	jne    800f39 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f15:	e8 53 fc ff ff       	call   800b6d <sys_getenvid>
  800f1a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800fb5:	68 ec 28 80 00       	push   $0x8028ec
  800fba:	6a 54                	push   $0x54
  800fbc:	68 ba 28 80 00       	push   $0x8028ba
  800fc1:	e8 b3 10 00 00       	call   802079 <_panic>
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
  800ffa:	68 ec 28 80 00       	push   $0x8028ec
  800fff:	6a 5b                	push   $0x5b
  801001:	68 ba 28 80 00       	push   $0x8028ba
  801006:	e8 6e 10 00 00       	call   802079 <_panic>
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
  801028:	68 ec 28 80 00       	push   $0x8028ec
  80102d:	6a 5f                	push   $0x5f
  80102f:	68 ba 28 80 00       	push   $0x8028ba
  801034:	e8 40 10 00 00       	call   802079 <_panic>
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
  801052:	68 ec 28 80 00       	push   $0x8028ec
  801057:	6a 64                	push   $0x64
  801059:	68 ba 28 80 00       	push   $0x8028ba
  80105e:	e8 16 10 00 00       	call   802079 <_panic>
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
  80107a:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010b7:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	53                   	push   %ebx
  8010c1:	68 04 29 80 00       	push   $0x802904
  8010c6:	e8 58 f1 ff ff       	call   800223 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010cb:	c7 04 24 56 01 80 00 	movl   $0x800156,(%esp)
  8010d2:	e8 c5 fc ff ff       	call   800d9c <sys_thread_create>
  8010d7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010d9:	83 c4 08             	add    $0x8,%esp
  8010dc:	53                   	push   %ebx
  8010dd:	68 04 29 80 00       	push   $0x802904
  8010e2:	e8 3c f1 ff ff       	call   800223 <cprintf>
	return id;
}
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8010f6:	ff 75 08             	pushl  0x8(%ebp)
  8010f9:	e8 be fc ff ff       	call   800dbc <sys_thread_free>
}
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801109:	ff 75 08             	pushl  0x8(%ebp)
  80110c:	e8 cb fc ff ff       	call   800ddc <sys_thread_join>
}
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	8b 55 08             	mov    0x8(%ebp),%edx
  80111c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111f:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801122:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801124:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801127:	83 3a 01             	cmpl   $0x1,(%edx)
  80112a:	7e 09                	jle    801135 <argstart+0x1f>
  80112c:	ba 51 25 80 00       	mov    $0x802551,%edx
  801131:	85 c9                	test   %ecx,%ecx
  801133:	75 05                	jne    80113a <argstart+0x24>
  801135:	ba 00 00 00 00       	mov    $0x0,%edx
  80113a:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80113d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <argnext>:

int
argnext(struct Argstate *args)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	53                   	push   %ebx
  80114a:	83 ec 04             	sub    $0x4,%esp
  80114d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801150:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801157:	8b 43 08             	mov    0x8(%ebx),%eax
  80115a:	85 c0                	test   %eax,%eax
  80115c:	74 6f                	je     8011cd <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  80115e:	80 38 00             	cmpb   $0x0,(%eax)
  801161:	75 4e                	jne    8011b1 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801163:	8b 0b                	mov    (%ebx),%ecx
  801165:	83 39 01             	cmpl   $0x1,(%ecx)
  801168:	74 55                	je     8011bf <argnext+0x79>
		    || args->argv[1][0] != '-'
  80116a:	8b 53 04             	mov    0x4(%ebx),%edx
  80116d:	8b 42 04             	mov    0x4(%edx),%eax
  801170:	80 38 2d             	cmpb   $0x2d,(%eax)
  801173:	75 4a                	jne    8011bf <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801175:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801179:	74 44                	je     8011bf <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80117b:	83 c0 01             	add    $0x1,%eax
  80117e:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	8b 01                	mov    (%ecx),%eax
  801186:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80118d:	50                   	push   %eax
  80118e:	8d 42 08             	lea    0x8(%edx),%eax
  801191:	50                   	push   %eax
  801192:	83 c2 04             	add    $0x4,%edx
  801195:	52                   	push   %edx
  801196:	e8 9f f7 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  80119b:	8b 03                	mov    (%ebx),%eax
  80119d:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8011a0:	8b 43 08             	mov    0x8(%ebx),%eax
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	80 38 2d             	cmpb   $0x2d,(%eax)
  8011a9:	75 06                	jne    8011b1 <argnext+0x6b>
  8011ab:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8011af:	74 0e                	je     8011bf <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8011b1:	8b 53 08             	mov    0x8(%ebx),%edx
  8011b4:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8011b7:	83 c2 01             	add    $0x1,%edx
  8011ba:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8011bd:	eb 13                	jmp    8011d2 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  8011bf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8011c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011cb:	eb 05                	jmp    8011d2 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8011cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8011d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	53                   	push   %ebx
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8011e1:	8b 43 08             	mov    0x8(%ebx),%eax
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	74 58                	je     801240 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  8011e8:	80 38 00             	cmpb   $0x0,(%eax)
  8011eb:	74 0c                	je     8011f9 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8011ed:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8011f0:	c7 43 08 51 25 80 00 	movl   $0x802551,0x8(%ebx)
  8011f7:	eb 42                	jmp    80123b <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8011f9:	8b 13                	mov    (%ebx),%edx
  8011fb:	83 3a 01             	cmpl   $0x1,(%edx)
  8011fe:	7e 2d                	jle    80122d <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801200:	8b 43 04             	mov    0x4(%ebx),%eax
  801203:	8b 48 04             	mov    0x4(%eax),%ecx
  801206:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	8b 12                	mov    (%edx),%edx
  80120e:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801215:	52                   	push   %edx
  801216:	8d 50 08             	lea    0x8(%eax),%edx
  801219:	52                   	push   %edx
  80121a:	83 c0 04             	add    $0x4,%eax
  80121d:	50                   	push   %eax
  80121e:	e8 17 f7 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  801223:	8b 03                	mov    (%ebx),%eax
  801225:	83 28 01             	subl   $0x1,(%eax)
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	eb 0e                	jmp    80123b <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80122d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801234:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80123b:	8b 43 0c             	mov    0xc(%ebx),%eax
  80123e:	eb 05                	jmp    801245 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801245:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801248:	c9                   	leave  
  801249:	c3                   	ret    

0080124a <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801253:	8b 51 0c             	mov    0xc(%ecx),%edx
  801256:	89 d0                	mov    %edx,%eax
  801258:	85 d2                	test   %edx,%edx
  80125a:	75 0c                	jne    801268 <argvalue+0x1e>
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	51                   	push   %ecx
  801260:	e8 72 ff ff ff       	call   8011d7 <argnextvalue>
  801265:	83 c4 10             	add    $0x10,%esp
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	05 00 00 00 30       	add    $0x30000000,%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80127d:	8b 45 08             	mov    0x8(%ebp),%eax
  801280:	05 00 00 00 30       	add    $0x30000000,%eax
  801285:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801297:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	c1 ea 16             	shr    $0x16,%edx
  8012a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a8:	f6 c2 01             	test   $0x1,%dl
  8012ab:	74 11                	je     8012be <fd_alloc+0x2d>
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	c1 ea 0c             	shr    $0xc,%edx
  8012b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	75 09                	jne    8012c7 <fd_alloc+0x36>
			*fd_store = fd;
  8012be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c5:	eb 17                	jmp    8012de <fd_alloc+0x4d>
  8012c7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d1:	75 c9                	jne    80129c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e6:	83 f8 1f             	cmp    $0x1f,%eax
  8012e9:	77 36                	ja     801321 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012eb:	c1 e0 0c             	shl    $0xc,%eax
  8012ee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	c1 ea 16             	shr    $0x16,%edx
  8012f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ff:	f6 c2 01             	test   $0x1,%dl
  801302:	74 24                	je     801328 <fd_lookup+0x48>
  801304:	89 c2                	mov    %eax,%edx
  801306:	c1 ea 0c             	shr    $0xc,%edx
  801309:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801310:	f6 c2 01             	test   $0x1,%dl
  801313:	74 1a                	je     80132f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801315:	8b 55 0c             	mov    0xc(%ebp),%edx
  801318:	89 02                	mov    %eax,(%edx)
	return 0;
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
  80131f:	eb 13                	jmp    801334 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801321:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801326:	eb 0c                	jmp    801334 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801328:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132d:	eb 05                	jmp    801334 <fd_lookup+0x54>
  80132f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133f:	ba a4 29 80 00       	mov    $0x8029a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801344:	eb 13                	jmp    801359 <dev_lookup+0x23>
  801346:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801349:	39 08                	cmp    %ecx,(%eax)
  80134b:	75 0c                	jne    801359 <dev_lookup+0x23>
			*dev = devtab[i];
  80134d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801350:	89 01                	mov    %eax,(%ecx)
			return 0;
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
  801357:	eb 31                	jmp    80138a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801359:	8b 02                	mov    (%edx),%eax
  80135b:	85 c0                	test   %eax,%eax
  80135d:	75 e7                	jne    801346 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80135f:	a1 04 40 80 00       	mov    0x804004,%eax
  801364:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80136a:	83 ec 04             	sub    $0x4,%esp
  80136d:	51                   	push   %ecx
  80136e:	50                   	push   %eax
  80136f:	68 28 29 80 00       	push   $0x802928
  801374:	e8 aa ee ff ff       	call   800223 <cprintf>
	*dev = 0;
  801379:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 10             	sub    $0x10,%esp
  801394:	8b 75 08             	mov    0x8(%ebp),%esi
  801397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a4:	c1 e8 0c             	shr    $0xc,%eax
  8013a7:	50                   	push   %eax
  8013a8:	e8 33 ff ff ff       	call   8012e0 <fd_lookup>
  8013ad:	83 c4 08             	add    $0x8,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 05                	js     8013b9 <fd_close+0x2d>
	    || fd != fd2)
  8013b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b7:	74 0c                	je     8013c5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013b9:	84 db                	test   %bl,%bl
  8013bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c0:	0f 44 c2             	cmove  %edx,%eax
  8013c3:	eb 41                	jmp    801406 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 36                	pushl  (%esi)
  8013ce:	e8 63 ff ff ff       	call   801336 <dev_lookup>
  8013d3:	89 c3                	mov    %eax,%ebx
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 1a                	js     8013f6 <fd_close+0x6a>
		if (dev->dev_close)
  8013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013df:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013e2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	74 0b                	je     8013f6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	56                   	push   %esi
  8013ef:	ff d0                	call   *%eax
  8013f1:	89 c3                	mov    %eax,%ebx
  8013f3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	56                   	push   %esi
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 2f f8 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	89 d8                	mov    %ebx,%eax
}
  801406:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 c1 fe ff ff       	call   8012e0 <fd_lookup>
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 10                	js     801436 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	6a 01                	push   $0x1
  80142b:	ff 75 f4             	pushl  -0xc(%ebp)
  80142e:	e8 59 ff ff ff       	call   80138c <fd_close>
  801433:	83 c4 10             	add    $0x10,%esp
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <close_all>:

void
close_all(void)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	53                   	push   %ebx
  801448:	e8 c0 ff ff ff       	call   80140d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144d:	83 c3 01             	add    $0x1,%ebx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	83 fb 20             	cmp    $0x20,%ebx
  801456:	75 ec                	jne    801444 <close_all+0xc>
		close(i);
}
  801458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	57                   	push   %edi
  801461:	56                   	push   %esi
  801462:	53                   	push   %ebx
  801463:	83 ec 2c             	sub    $0x2c,%esp
  801466:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801469:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	ff 75 08             	pushl  0x8(%ebp)
  801470:	e8 6b fe ff ff       	call   8012e0 <fd_lookup>
  801475:	83 c4 08             	add    $0x8,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	0f 88 c1 00 00 00    	js     801541 <dup+0xe4>
		return r;
	close(newfdnum);
  801480:	83 ec 0c             	sub    $0xc,%esp
  801483:	56                   	push   %esi
  801484:	e8 84 ff ff ff       	call   80140d <close>

	newfd = INDEX2FD(newfdnum);
  801489:	89 f3                	mov    %esi,%ebx
  80148b:	c1 e3 0c             	shl    $0xc,%ebx
  80148e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801494:	83 c4 04             	add    $0x4,%esp
  801497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149a:	e8 db fd ff ff       	call   80127a <fd2data>
  80149f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a1:	89 1c 24             	mov    %ebx,(%esp)
  8014a4:	e8 d1 fd ff ff       	call   80127a <fd2data>
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014af:	89 f8                	mov    %edi,%eax
  8014b1:	c1 e8 16             	shr    $0x16,%eax
  8014b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014bb:	a8 01                	test   $0x1,%al
  8014bd:	74 37                	je     8014f6 <dup+0x99>
  8014bf:	89 f8                	mov    %edi,%eax
  8014c1:	c1 e8 0c             	shr    $0xc,%eax
  8014c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014cb:	f6 c2 01             	test   $0x1,%dl
  8014ce:	74 26                	je     8014f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	25 07 0e 00 00       	and    $0xe07,%eax
  8014df:	50                   	push   %eax
  8014e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e3:	6a 00                	push   $0x0
  8014e5:	57                   	push   %edi
  8014e6:	6a 00                	push   $0x0
  8014e8:	e8 01 f7 ff ff       	call   800bee <sys_page_map>
  8014ed:	89 c7                	mov    %eax,%edi
  8014ef:	83 c4 20             	add    $0x20,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 2e                	js     801524 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014f9:	89 d0                	mov    %edx,%eax
  8014fb:	c1 e8 0c             	shr    $0xc,%eax
  8014fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	25 07 0e 00 00       	and    $0xe07,%eax
  80150d:	50                   	push   %eax
  80150e:	53                   	push   %ebx
  80150f:	6a 00                	push   $0x0
  801511:	52                   	push   %edx
  801512:	6a 00                	push   $0x0
  801514:	e8 d5 f6 ff ff       	call   800bee <sys_page_map>
  801519:	89 c7                	mov    %eax,%edi
  80151b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80151e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801520:	85 ff                	test   %edi,%edi
  801522:	79 1d                	jns    801541 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	53                   	push   %ebx
  801528:	6a 00                	push   $0x0
  80152a:	e8 01 f7 ff ff       	call   800c30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152f:	83 c4 08             	add    $0x8,%esp
  801532:	ff 75 d4             	pushl  -0x2c(%ebp)
  801535:	6a 00                	push   $0x0
  801537:	e8 f4 f6 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	89 f8                	mov    %edi,%eax
}
  801541:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 14             	sub    $0x14,%esp
  801550:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801553:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	53                   	push   %ebx
  801558:	e8 83 fd ff ff       	call   8012e0 <fd_lookup>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	89 c2                	mov    %eax,%edx
  801562:	85 c0                	test   %eax,%eax
  801564:	78 70                	js     8015d6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	ff 30                	pushl  (%eax)
  801572:	e8 bf fd ff ff       	call   801336 <dev_lookup>
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 4f                	js     8015cd <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80157e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801581:	8b 42 08             	mov    0x8(%edx),%eax
  801584:	83 e0 03             	and    $0x3,%eax
  801587:	83 f8 01             	cmp    $0x1,%eax
  80158a:	75 24                	jne    8015b0 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158c:	a1 04 40 80 00       	mov    0x804004,%eax
  801591:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801597:	83 ec 04             	sub    $0x4,%esp
  80159a:	53                   	push   %ebx
  80159b:	50                   	push   %eax
  80159c:	68 69 29 80 00       	push   $0x802969
  8015a1:	e8 7d ec ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ae:	eb 26                	jmp    8015d6 <read+0x8d>
	}
	if (!dev->dev_read)
  8015b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b3:	8b 40 08             	mov    0x8(%eax),%eax
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	74 17                	je     8015d1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	ff 75 10             	pushl  0x10(%ebp)
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	52                   	push   %edx
  8015c4:	ff d0                	call   *%eax
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	eb 09                	jmp    8015d6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	eb 05                	jmp    8015d6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015d6:	89 d0                	mov    %edx,%eax
  8015d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	57                   	push   %edi
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f1:	eb 21                	jmp    801614 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	89 f0                	mov    %esi,%eax
  8015f8:	29 d8                	sub    %ebx,%eax
  8015fa:	50                   	push   %eax
  8015fb:	89 d8                	mov    %ebx,%eax
  8015fd:	03 45 0c             	add    0xc(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	57                   	push   %edi
  801602:	e8 42 ff ff ff       	call   801549 <read>
		if (m < 0)
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 10                	js     80161e <readn+0x41>
			return m;
		if (m == 0)
  80160e:	85 c0                	test   %eax,%eax
  801610:	74 0a                	je     80161c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801612:	01 c3                	add    %eax,%ebx
  801614:	39 f3                	cmp    %esi,%ebx
  801616:	72 db                	jb     8015f3 <readn+0x16>
  801618:	89 d8                	mov    %ebx,%eax
  80161a:	eb 02                	jmp    80161e <readn+0x41>
  80161c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80161e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801621:	5b                   	pop    %ebx
  801622:	5e                   	pop    %esi
  801623:	5f                   	pop    %edi
  801624:	5d                   	pop    %ebp
  801625:	c3                   	ret    

00801626 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	53                   	push   %ebx
  80162a:	83 ec 14             	sub    $0x14,%esp
  80162d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801633:	50                   	push   %eax
  801634:	53                   	push   %ebx
  801635:	e8 a6 fc ff ff       	call   8012e0 <fd_lookup>
  80163a:	83 c4 08             	add    $0x8,%esp
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 6b                	js     8016ae <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	ff 30                	pushl  (%eax)
  80164f:	e8 e2 fc ff ff       	call   801336 <dev_lookup>
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 4a                	js     8016a5 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801662:	75 24                	jne    801688 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801664:	a1 04 40 80 00       	mov    0x804004,%eax
  801669:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	53                   	push   %ebx
  801673:	50                   	push   %eax
  801674:	68 85 29 80 00       	push   $0x802985
  801679:	e8 a5 eb ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801686:	eb 26                	jmp    8016ae <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801688:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168b:	8b 52 0c             	mov    0xc(%edx),%edx
  80168e:	85 d2                	test   %edx,%edx
  801690:	74 17                	je     8016a9 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	ff 75 10             	pushl  0x10(%ebp)
  801698:	ff 75 0c             	pushl  0xc(%ebp)
  80169b:	50                   	push   %eax
  80169c:	ff d2                	call   *%edx
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	eb 09                	jmp    8016ae <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	eb 05                	jmp    8016ae <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016ae:	89 d0                	mov    %edx,%eax
  8016b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	ff 75 08             	pushl  0x8(%ebp)
  8016c2:	e8 19 fc ff ff       	call   8012e0 <fd_lookup>
  8016c7:	83 c4 08             	add    $0x8,%esp
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 0e                	js     8016dc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 14             	sub    $0x14,%esp
  8016e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	53                   	push   %ebx
  8016ed:	e8 ee fb ff ff       	call   8012e0 <fd_lookup>
  8016f2:	83 c4 08             	add    $0x8,%esp
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 68                	js     801763 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801705:	ff 30                	pushl  (%eax)
  801707:	e8 2a fc ff ff       	call   801336 <dev_lookup>
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 47                	js     80175a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801716:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171a:	75 24                	jne    801740 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80171c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801721:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801727:	83 ec 04             	sub    $0x4,%esp
  80172a:	53                   	push   %ebx
  80172b:	50                   	push   %eax
  80172c:	68 48 29 80 00       	push   $0x802948
  801731:	e8 ed ea ff ff       	call   800223 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80173e:	eb 23                	jmp    801763 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801740:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801743:	8b 52 18             	mov    0x18(%edx),%edx
  801746:	85 d2                	test   %edx,%edx
  801748:	74 14                	je     80175e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	50                   	push   %eax
  801751:	ff d2                	call   *%edx
  801753:	89 c2                	mov    %eax,%edx
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	eb 09                	jmp    801763 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	eb 05                	jmp    801763 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80175e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801763:	89 d0                	mov    %edx,%eax
  801765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 14             	sub    $0x14,%esp
  801771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	ff 75 08             	pushl  0x8(%ebp)
  80177b:	e8 60 fb ff ff       	call   8012e0 <fd_lookup>
  801780:	83 c4 08             	add    $0x8,%esp
  801783:	89 c2                	mov    %eax,%edx
  801785:	85 c0                	test   %eax,%eax
  801787:	78 58                	js     8017e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178f:	50                   	push   %eax
  801790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801793:	ff 30                	pushl  (%eax)
  801795:	e8 9c fb ff ff       	call   801336 <dev_lookup>
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 37                	js     8017d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a8:	74 32                	je     8017dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b4:	00 00 00 
	stat->st_isdir = 0;
  8017b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017be:	00 00 00 
	stat->st_dev = dev;
  8017c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	53                   	push   %ebx
  8017cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ce:	ff 50 14             	call   *0x14(%eax)
  8017d1:	89 c2                	mov    %eax,%edx
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	eb 09                	jmp    8017e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d8:	89 c2                	mov    %eax,%edx
  8017da:	eb 05                	jmp    8017e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e1:	89 d0                	mov    %edx,%eax
  8017e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	6a 00                	push   $0x0
  8017f2:	ff 75 08             	pushl  0x8(%ebp)
  8017f5:	e8 e3 01 00 00       	call   8019dd <open>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 1b                	js     80181e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	ff 75 0c             	pushl  0xc(%ebp)
  801809:	50                   	push   %eax
  80180a:	e8 5b ff ff ff       	call   80176a <fstat>
  80180f:	89 c6                	mov    %eax,%esi
	close(fd);
  801811:	89 1c 24             	mov    %ebx,(%esp)
  801814:	e8 f4 fb ff ff       	call   80140d <close>
	return r;
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	89 f0                	mov    %esi,%eax
}
  80181e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801821:	5b                   	pop    %ebx
  801822:	5e                   	pop    %esi
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	89 c6                	mov    %eax,%esi
  80182c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80182e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801835:	75 12                	jne    801849 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801837:	83 ec 0c             	sub    $0xc,%esp
  80183a:	6a 01                	push   $0x1
  80183c:	e8 ea 09 00 00       	call   80222b <ipc_find_env>
  801841:	a3 00 40 80 00       	mov    %eax,0x804000
  801846:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801849:	6a 07                	push   $0x7
  80184b:	68 00 50 80 00       	push   $0x805000
  801850:	56                   	push   %esi
  801851:	ff 35 00 40 80 00    	pushl  0x804000
  801857:	e8 6d 09 00 00       	call   8021c9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80185c:	83 c4 0c             	add    $0xc,%esp
  80185f:	6a 00                	push   $0x0
  801861:	53                   	push   %ebx
  801862:	6a 00                	push   $0x0
  801864:	e8 e5 08 00 00       	call   80214e <ipc_recv>
}
  801869:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186c:	5b                   	pop    %ebx
  80186d:	5e                   	pop    %esi
  80186e:	5d                   	pop    %ebp
  80186f:	c3                   	ret    

00801870 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 40 0c             	mov    0xc(%eax),%eax
  80187c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801881:	8b 45 0c             	mov    0xc(%ebp),%eax
  801884:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801889:	ba 00 00 00 00       	mov    $0x0,%edx
  80188e:	b8 02 00 00 00       	mov    $0x2,%eax
  801893:	e8 8d ff ff ff       	call   801825 <fsipc>
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b5:	e8 6b ff ff ff       	call   801825 <fsipc>
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8018db:	e8 45 ff ff ff       	call   801825 <fsipc>
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 2c                	js     801910 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	68 00 50 80 00       	push   $0x805000
  8018ec:	53                   	push   %ebx
  8018ed:	e8 b6 ee ff ff       	call   8007a8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801902:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80191e:	8b 55 08             	mov    0x8(%ebp),%edx
  801921:	8b 52 0c             	mov    0xc(%edx),%edx
  801924:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80192a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80192f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801934:	0f 47 c2             	cmova  %edx,%eax
  801937:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80193c:	50                   	push   %eax
  80193d:	ff 75 0c             	pushl  0xc(%ebp)
  801940:	68 08 50 80 00       	push   $0x805008
  801945:	e8 f0 ef ff ff       	call   80093a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80194a:	ba 00 00 00 00       	mov    $0x0,%edx
  80194f:	b8 04 00 00 00       	mov    $0x4,%eax
  801954:	e8 cc fe ff ff       	call   801825 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	8b 40 0c             	mov    0xc(%eax),%eax
  801969:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80196e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 03 00 00 00       	mov    $0x3,%eax
  80197e:	e8 a2 fe ff ff       	call   801825 <fsipc>
  801983:	89 c3                	mov    %eax,%ebx
  801985:	85 c0                	test   %eax,%eax
  801987:	78 4b                	js     8019d4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801989:	39 c6                	cmp    %eax,%esi
  80198b:	73 16                	jae    8019a3 <devfile_read+0x48>
  80198d:	68 b4 29 80 00       	push   $0x8029b4
  801992:	68 bb 29 80 00       	push   $0x8029bb
  801997:	6a 7c                	push   $0x7c
  801999:	68 d0 29 80 00       	push   $0x8029d0
  80199e:	e8 d6 06 00 00       	call   802079 <_panic>
	assert(r <= PGSIZE);
  8019a3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a8:	7e 16                	jle    8019c0 <devfile_read+0x65>
  8019aa:	68 db 29 80 00       	push   $0x8029db
  8019af:	68 bb 29 80 00       	push   $0x8029bb
  8019b4:	6a 7d                	push   $0x7d
  8019b6:	68 d0 29 80 00       	push   $0x8029d0
  8019bb:	e8 b9 06 00 00       	call   802079 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c0:	83 ec 04             	sub    $0x4,%esp
  8019c3:	50                   	push   %eax
  8019c4:	68 00 50 80 00       	push   $0x805000
  8019c9:	ff 75 0c             	pushl  0xc(%ebp)
  8019cc:	e8 69 ef ff ff       	call   80093a <memmove>
	return r;
  8019d1:	83 c4 10             	add    $0x10,%esp
}
  8019d4:	89 d8                	mov    %ebx,%eax
  8019d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5d                   	pop    %ebp
  8019dc:	c3                   	ret    

008019dd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 20             	sub    $0x20,%esp
  8019e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e7:	53                   	push   %ebx
  8019e8:	e8 82 ed ff ff       	call   80076f <strlen>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f5:	7f 67                	jg     801a5e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fd:	50                   	push   %eax
  8019fe:	e8 8e f8 ff ff       	call   801291 <fd_alloc>
  801a03:	83 c4 10             	add    $0x10,%esp
		return r;
  801a06:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 57                	js     801a63 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	53                   	push   %ebx
  801a10:	68 00 50 80 00       	push   $0x805000
  801a15:	e8 8e ed ff ff       	call   8007a8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a25:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2a:	e8 f6 fd ff ff       	call   801825 <fsipc>
  801a2f:	89 c3                	mov    %eax,%ebx
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	79 14                	jns    801a4c <open+0x6f>
		fd_close(fd, 0);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	6a 00                	push   $0x0
  801a3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a40:	e8 47 f9 ff ff       	call   80138c <fd_close>
		return r;
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	89 da                	mov    %ebx,%edx
  801a4a:	eb 17                	jmp    801a63 <open+0x86>
	}

	return fd2num(fd);
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a52:	e8 13 f8 ff ff       	call   80126a <fd2num>
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	eb 05                	jmp    801a63 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a5e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a63:	89 d0                	mov    %edx,%eax
  801a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a70:	ba 00 00 00 00       	mov    $0x0,%edx
  801a75:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7a:	e8 a6 fd ff ff       	call   801825 <fsipc>
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801a81:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a85:	7e 37                	jle    801abe <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 08             	sub    $0x8,%esp
  801a8e:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a90:	ff 70 04             	pushl  0x4(%eax)
  801a93:	8d 40 10             	lea    0x10(%eax),%eax
  801a96:	50                   	push   %eax
  801a97:	ff 33                	pushl  (%ebx)
  801a99:	e8 88 fb ff ff       	call   801626 <write>
		if (result > 0)
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	7e 03                	jle    801aa8 <writebuf+0x27>
			b->result += result;
  801aa5:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801aa8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aab:	74 0d                	je     801aba <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab4:	0f 4f c2             	cmovg  %edx,%eax
  801ab7:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abd:	c9                   	leave  
  801abe:	f3 c3                	repz ret 

00801ac0 <putch>:

static void
putch(int ch, void *thunk)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 04             	sub    $0x4,%esp
  801ac7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801aca:	8b 53 04             	mov    0x4(%ebx),%edx
  801acd:	8d 42 01             	lea    0x1(%edx),%eax
  801ad0:	89 43 04             	mov    %eax,0x4(%ebx)
  801ad3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad6:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801ada:	3d 00 01 00 00       	cmp    $0x100,%eax
  801adf:	75 0e                	jne    801aef <putch+0x2f>
		writebuf(b);
  801ae1:	89 d8                	mov    %ebx,%eax
  801ae3:	e8 99 ff ff ff       	call   801a81 <writebuf>
		b->idx = 0;
  801ae8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801aef:	83 c4 04             	add    $0x4,%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b07:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b0e:	00 00 00 
	b.result = 0;
  801b11:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b18:	00 00 00 
	b.error = 1;
  801b1b:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b22:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b25:	ff 75 10             	pushl  0x10(%ebp)
  801b28:	ff 75 0c             	pushl  0xc(%ebp)
  801b2b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b31:	50                   	push   %eax
  801b32:	68 c0 1a 80 00       	push   $0x801ac0
  801b37:	e8 1e e8 ff ff       	call   80035a <vprintfmt>
	if (b.idx > 0)
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801b46:	7e 0b                	jle    801b53 <vfprintf+0x5e>
		writebuf(&b);
  801b48:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b4e:	e8 2e ff ff ff       	call   801a81 <writebuf>

	return (b.result ? b.result : b.error);
  801b53:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b6a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b6d:	50                   	push   %eax
  801b6e:	ff 75 0c             	pushl  0xc(%ebp)
  801b71:	ff 75 08             	pushl  0x8(%ebp)
  801b74:	e8 7c ff ff ff       	call   801af5 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <printf>:

int
printf(const char *fmt, ...)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b81:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b84:	50                   	push   %eax
  801b85:	ff 75 08             	pushl  0x8(%ebp)
  801b88:	6a 01                	push   $0x1
  801b8a:	e8 66 ff ff ff       	call   801af5 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	ff 75 08             	pushl  0x8(%ebp)
  801b9f:	e8 d6 f6 ff ff       	call   80127a <fd2data>
  801ba4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ba6:	83 c4 08             	add    $0x8,%esp
  801ba9:	68 e7 29 80 00       	push   $0x8029e7
  801bae:	53                   	push   %ebx
  801baf:	e8 f4 eb ff ff       	call   8007a8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bb4:	8b 46 04             	mov    0x4(%esi),%eax
  801bb7:	2b 06                	sub    (%esi),%eax
  801bb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bbf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bc6:	00 00 00 
	stat->st_dev = &devpipe;
  801bc9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bd0:	30 80 00 
	return 0;
}
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801be9:	53                   	push   %ebx
  801bea:	6a 00                	push   $0x0
  801bec:	e8 3f f0 ff ff       	call   800c30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf1:	89 1c 24             	mov    %ebx,(%esp)
  801bf4:	e8 81 f6 ff ff       	call   80127a <fd2data>
  801bf9:	83 c4 08             	add    $0x8,%esp
  801bfc:	50                   	push   %eax
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 2c f0 ff ff       	call   800c30 <sys_page_unmap>
}
  801c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	57                   	push   %edi
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 1c             	sub    $0x1c,%esp
  801c12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c15:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c17:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1c:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	ff 75 e0             	pushl  -0x20(%ebp)
  801c28:	e8 43 06 00 00       	call   802270 <pageref>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	89 3c 24             	mov    %edi,(%esp)
  801c32:	e8 39 06 00 00       	call   802270 <pageref>
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	39 c3                	cmp    %eax,%ebx
  801c3c:	0f 94 c1             	sete   %cl
  801c3f:	0f b6 c9             	movzbl %cl,%ecx
  801c42:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c45:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c4b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801c51:	39 ce                	cmp    %ecx,%esi
  801c53:	74 1e                	je     801c73 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c55:	39 c3                	cmp    %eax,%ebx
  801c57:	75 be                	jne    801c17 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c59:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801c5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c62:	50                   	push   %eax
  801c63:	56                   	push   %esi
  801c64:	68 ee 29 80 00       	push   $0x8029ee
  801c69:	e8 b5 e5 ff ff       	call   800223 <cprintf>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	eb a4                	jmp    801c17 <_pipeisclosed+0xe>
	}
}
  801c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 28             	sub    $0x28,%esp
  801c87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c8a:	56                   	push   %esi
  801c8b:	e8 ea f5 ff ff       	call   80127a <fd2data>
  801c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	bf 00 00 00 00       	mov    $0x0,%edi
  801c9a:	eb 4b                	jmp    801ce7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c9c:	89 da                	mov    %ebx,%edx
  801c9e:	89 f0                	mov    %esi,%eax
  801ca0:	e8 64 ff ff ff       	call   801c09 <_pipeisclosed>
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	75 48                	jne    801cf1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca9:	e8 de ee ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cae:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb1:	8b 0b                	mov    (%ebx),%ecx
  801cb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb6:	39 d0                	cmp    %edx,%eax
  801cb8:	73 e2                	jae    801c9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	c1 fa 1f             	sar    $0x1f,%edx
  801cc9:	89 d1                	mov    %edx,%ecx
  801ccb:	c1 e9 1b             	shr    $0x1b,%ecx
  801cce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cd1:	83 e2 1f             	and    $0x1f,%edx
  801cd4:	29 ca                	sub    %ecx,%edx
  801cd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cde:	83 c0 01             	add    $0x1,%eax
  801ce1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce4:	83 c7 01             	add    $0x1,%edi
  801ce7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cea:	75 c2                	jne    801cae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cec:	8b 45 10             	mov    0x10(%ebp),%eax
  801cef:	eb 05                	jmp    801cf6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 18             	sub    $0x18,%esp
  801d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d0a:	57                   	push   %edi
  801d0b:	e8 6a f5 ff ff       	call   80127a <fd2data>
  801d10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d1a:	eb 3d                	jmp    801d59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d1c:	85 db                	test   %ebx,%ebx
  801d1e:	74 04                	je     801d24 <devpipe_read+0x26>
				return i;
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	eb 44                	jmp    801d68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	89 f8                	mov    %edi,%eax
  801d28:	e8 dc fe ff ff       	call   801c09 <_pipeisclosed>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	75 32                	jne    801d63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d31:	e8 56 ee ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d36:	8b 06                	mov    (%esi),%eax
  801d38:	3b 46 04             	cmp    0x4(%esi),%eax
  801d3b:	74 df                	je     801d1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3d:	99                   	cltd   
  801d3e:	c1 ea 1b             	shr    $0x1b,%edx
  801d41:	01 d0                	add    %edx,%eax
  801d43:	83 e0 1f             	and    $0x1f,%eax
  801d46:	29 d0                	sub    %edx,%eax
  801d48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d56:	83 c3 01             	add    $0x1,%ebx
  801d59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d5c:	75 d8                	jne    801d36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d61:	eb 05                	jmp    801d68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6b:	5b                   	pop    %ebx
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	56                   	push   %esi
  801d74:	53                   	push   %ebx
  801d75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7b:	50                   	push   %eax
  801d7c:	e8 10 f5 ff ff       	call   801291 <fd_alloc>
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	89 c2                	mov    %eax,%edx
  801d86:	85 c0                	test   %eax,%eax
  801d88:	0f 88 2c 01 00 00    	js     801eba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	68 07 04 00 00       	push   $0x407
  801d96:	ff 75 f4             	pushl  -0xc(%ebp)
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 0b ee ff ff       	call   800bab <sys_page_alloc>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	89 c2                	mov    %eax,%edx
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 0d 01 00 00    	js     801eba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	e8 d8 f4 ff ff       	call   801291 <fd_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 e2 00 00 00    	js     801ea8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc6:	83 ec 04             	sub    $0x4,%esp
  801dc9:	68 07 04 00 00       	push   $0x407
  801dce:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 d3 ed ff ff       	call   800bab <sys_page_alloc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 c3 00 00 00    	js     801ea8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 f4             	pushl  -0xc(%ebp)
  801deb:	e8 8a f4 ff ff       	call   80127a <fd2data>
  801df0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df2:	83 c4 0c             	add    $0xc,%esp
  801df5:	68 07 04 00 00       	push   $0x407
  801dfa:	50                   	push   %eax
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 a9 ed ff ff       	call   800bab <sys_page_alloc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	0f 88 89 00 00 00    	js     801e98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0f:	83 ec 0c             	sub    $0xc,%esp
  801e12:	ff 75 f0             	pushl  -0x10(%ebp)
  801e15:	e8 60 f4 ff ff       	call   80127a <fd2data>
  801e1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e21:	50                   	push   %eax
  801e22:	6a 00                	push   $0x0
  801e24:	56                   	push   %esi
  801e25:	6a 00                	push   $0x0
  801e27:	e8 c2 ed ff ff       	call   800bee <sys_page_map>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	83 c4 20             	add    $0x20,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 55                	js     801e8a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	ff 75 f4             	pushl  -0xc(%ebp)
  801e65:	e8 00 f4 ff ff       	call   80126a <fd2num>
  801e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e6f:	83 c4 04             	add    $0x4,%esp
  801e72:	ff 75 f0             	pushl  -0x10(%ebp)
  801e75:	e8 f0 f3 ff ff       	call   80126a <fd2num>
  801e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	ba 00 00 00 00       	mov    $0x0,%edx
  801e88:	eb 30                	jmp    801eba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e8a:	83 ec 08             	sub    $0x8,%esp
  801e8d:	56                   	push   %esi
  801e8e:	6a 00                	push   $0x0
  801e90:	e8 9b ed ff ff       	call   800c30 <sys_page_unmap>
  801e95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 8b ed ff ff       	call   800c30 <sys_page_unmap>
  801ea5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ea8:	83 ec 08             	sub    $0x8,%esp
  801eab:	ff 75 f4             	pushl  -0xc(%ebp)
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 7b ed ff ff       	call   800c30 <sys_page_unmap>
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eba:	89 d0                	mov    %edx,%eax
  801ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	ff 75 08             	pushl  0x8(%ebp)
  801ed0:	e8 0b f4 ff ff       	call   8012e0 <fd_lookup>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 18                	js     801ef4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801edc:	83 ec 0c             	sub    $0xc,%esp
  801edf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee2:	e8 93 f3 ff ff       	call   80127a <fd2data>
	return _pipeisclosed(fd, p);
  801ee7:	89 c2                	mov    %eax,%edx
  801ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eec:	e8 18 fd ff ff       	call   801c09 <_pipeisclosed>
  801ef1:	83 c4 10             	add    $0x10,%esp
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f06:	68 06 2a 80 00       	push   $0x802a06
  801f0b:	ff 75 0c             	pushl  0xc(%ebp)
  801f0e:	e8 95 e8 ff ff       	call   8007a8 <strcpy>
	return 0;
}
  801f13:	b8 00 00 00 00       	mov    $0x0,%eax
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	57                   	push   %edi
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f31:	eb 2d                	jmp    801f60 <devcons_write+0x46>
		m = n - tot;
  801f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	53                   	push   %ebx
  801f47:	03 45 0c             	add    0xc(%ebp),%eax
  801f4a:	50                   	push   %eax
  801f4b:	57                   	push   %edi
  801f4c:	e8 e9 e9 ff ff       	call   80093a <memmove>
		sys_cputs(buf, m);
  801f51:	83 c4 08             	add    $0x8,%esp
  801f54:	53                   	push   %ebx
  801f55:	57                   	push   %edi
  801f56:	e8 94 eb ff ff       	call   800aef <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5b:	01 de                	add    %ebx,%esi
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	89 f0                	mov    %esi,%eax
  801f62:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f65:	72 cc                	jb     801f33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 08             	sub    $0x8,%esp
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f7e:	74 2a                	je     801faa <devcons_read+0x3b>
  801f80:	eb 05                	jmp    801f87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f82:	e8 05 ec ff ff       	call   800b8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f87:	e8 81 eb ff ff       	call   800b0d <sys_cgetc>
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	74 f2                	je     801f82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 16                	js     801faa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f94:	83 f8 04             	cmp    $0x4,%eax
  801f97:	74 0c                	je     801fa5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f9c:	88 02                	mov    %al,(%edx)
	return 1;
  801f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa3:	eb 05                	jmp    801faa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fb8:	6a 01                	push   $0x1
  801fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	e8 2c eb ff ff       	call   800aef <sys_cputs>
}
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <getchar>:

int
getchar(void)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fce:	6a 01                	push   $0x1
  801fd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd3:	50                   	push   %eax
  801fd4:	6a 00                	push   $0x0
  801fd6:	e8 6e f5 ff ff       	call   801549 <read>
	if (r < 0)
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	78 0f                	js     801ff1 <getchar+0x29>
		return r;
	if (r < 1)
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	7e 06                	jle    801fec <getchar+0x24>
		return -E_EOF;
	return c;
  801fe6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fea:	eb 05                	jmp    801ff1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	ff 75 08             	pushl  0x8(%ebp)
  802000:	e8 db f2 ff ff       	call   8012e0 <fd_lookup>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 11                	js     80201d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802015:	39 10                	cmp    %edx,(%eax)
  802017:	0f 94 c0             	sete   %al
  80201a:	0f b6 c0             	movzbl %al,%eax
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <opencons>:

int
opencons(void)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802028:	50                   	push   %eax
  802029:	e8 63 f2 ff ff       	call   801291 <fd_alloc>
  80202e:	83 c4 10             	add    $0x10,%esp
		return r;
  802031:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802033:	85 c0                	test   %eax,%eax
  802035:	78 3e                	js     802075 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802037:	83 ec 04             	sub    $0x4,%esp
  80203a:	68 07 04 00 00       	push   $0x407
  80203f:	ff 75 f4             	pushl  -0xc(%ebp)
  802042:	6a 00                	push   $0x0
  802044:	e8 62 eb ff ff       	call   800bab <sys_page_alloc>
  802049:	83 c4 10             	add    $0x10,%esp
		return r;
  80204c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 23                	js     802075 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802060:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802067:	83 ec 0c             	sub    $0xc,%esp
  80206a:	50                   	push   %eax
  80206b:	e8 fa f1 ff ff       	call   80126a <fd2num>
  802070:	89 c2                	mov    %eax,%edx
  802072:	83 c4 10             	add    $0x10,%esp
}
  802075:	89 d0                	mov    %edx,%eax
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80207e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802081:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802087:	e8 e1 ea ff ff       	call   800b6d <sys_getenvid>
  80208c:	83 ec 0c             	sub    $0xc,%esp
  80208f:	ff 75 0c             	pushl  0xc(%ebp)
  802092:	ff 75 08             	pushl  0x8(%ebp)
  802095:	56                   	push   %esi
  802096:	50                   	push   %eax
  802097:	68 14 2a 80 00       	push   $0x802a14
  80209c:	e8 82 e1 ff ff       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020a1:	83 c4 18             	add    $0x18,%esp
  8020a4:	53                   	push   %ebx
  8020a5:	ff 75 10             	pushl  0x10(%ebp)
  8020a8:	e8 25 e1 ff ff       	call   8001d2 <vcprintf>
	cprintf("\n");
  8020ad:	c7 04 24 50 25 80 00 	movl   $0x802550,(%esp)
  8020b4:	e8 6a e1 ff ff       	call   800223 <cprintf>
  8020b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020bc:	cc                   	int3   
  8020bd:	eb fd                	jmp    8020bc <_panic+0x43>

008020bf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020c5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020cc:	75 2a                	jne    8020f8 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8020ce:	83 ec 04             	sub    $0x4,%esp
  8020d1:	6a 07                	push   $0x7
  8020d3:	68 00 f0 bf ee       	push   $0xeebff000
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 cc ea ff ff       	call   800bab <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	79 12                	jns    8020f8 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8020e6:	50                   	push   %eax
  8020e7:	68 38 2a 80 00       	push   $0x802a38
  8020ec:	6a 23                	push   $0x23
  8020ee:	68 3c 2a 80 00       	push   $0x802a3c
  8020f3:	e8 81 ff ff ff       	call   802079 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fb:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802100:	83 ec 08             	sub    $0x8,%esp
  802103:	68 2a 21 80 00       	push   $0x80212a
  802108:	6a 00                	push   $0x0
  80210a:	e8 e7 eb ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	85 c0                	test   %eax,%eax
  802114:	79 12                	jns    802128 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802116:	50                   	push   %eax
  802117:	68 38 2a 80 00       	push   $0x802a38
  80211c:	6a 2c                	push   $0x2c
  80211e:	68 3c 2a 80 00       	push   $0x802a3c
  802123:	e8 51 ff ff ff       	call   802079 <_panic>
	}
}
  802128:	c9                   	leave  
  802129:	c3                   	ret    

0080212a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80212a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80212b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802130:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802132:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802135:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802139:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80213e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802142:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802144:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802147:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802148:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80214b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80214c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80214d:	c3                   	ret    

0080214e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	56                   	push   %esi
  802152:	53                   	push   %ebx
  802153:	8b 75 08             	mov    0x8(%ebp),%esi
  802156:	8b 45 0c             	mov    0xc(%ebp),%eax
  802159:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80215c:	85 c0                	test   %eax,%eax
  80215e:	75 12                	jne    802172 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802160:	83 ec 0c             	sub    $0xc,%esp
  802163:	68 00 00 c0 ee       	push   $0xeec00000
  802168:	e8 ee eb ff ff       	call   800d5b <sys_ipc_recv>
  80216d:	83 c4 10             	add    $0x10,%esp
  802170:	eb 0c                	jmp    80217e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802172:	83 ec 0c             	sub    $0xc,%esp
  802175:	50                   	push   %eax
  802176:	e8 e0 eb ff ff       	call   800d5b <sys_ipc_recv>
  80217b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80217e:	85 f6                	test   %esi,%esi
  802180:	0f 95 c1             	setne  %cl
  802183:	85 db                	test   %ebx,%ebx
  802185:	0f 95 c2             	setne  %dl
  802188:	84 d1                	test   %dl,%cl
  80218a:	74 09                	je     802195 <ipc_recv+0x47>
  80218c:	89 c2                	mov    %eax,%edx
  80218e:	c1 ea 1f             	shr    $0x1f,%edx
  802191:	84 d2                	test   %dl,%dl
  802193:	75 2d                	jne    8021c2 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802195:	85 f6                	test   %esi,%esi
  802197:	74 0d                	je     8021a6 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802199:	a1 04 40 80 00       	mov    0x804004,%eax
  80219e:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8021a4:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8021a6:	85 db                	test   %ebx,%ebx
  8021a8:	74 0d                	je     8021b7 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8021aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8021af:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8021b5:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8021b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8021bc:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8021c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c5:	5b                   	pop    %ebx
  8021c6:	5e                   	pop    %esi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    

008021c9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	57                   	push   %edi
  8021cd:	56                   	push   %esi
  8021ce:	53                   	push   %ebx
  8021cf:	83 ec 0c             	sub    $0xc,%esp
  8021d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8021db:	85 db                	test   %ebx,%ebx
  8021dd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021e2:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021e5:	ff 75 14             	pushl  0x14(%ebp)
  8021e8:	53                   	push   %ebx
  8021e9:	56                   	push   %esi
  8021ea:	57                   	push   %edi
  8021eb:	e8 48 eb ff ff       	call   800d38 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021f0:	89 c2                	mov    %eax,%edx
  8021f2:	c1 ea 1f             	shr    $0x1f,%edx
  8021f5:	83 c4 10             	add    $0x10,%esp
  8021f8:	84 d2                	test   %dl,%dl
  8021fa:	74 17                	je     802213 <ipc_send+0x4a>
  8021fc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ff:	74 12                	je     802213 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802201:	50                   	push   %eax
  802202:	68 4a 2a 80 00       	push   $0x802a4a
  802207:	6a 47                	push   $0x47
  802209:	68 58 2a 80 00       	push   $0x802a58
  80220e:	e8 66 fe ff ff       	call   802079 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802213:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802216:	75 07                	jne    80221f <ipc_send+0x56>
			sys_yield();
  802218:	e8 6f e9 ff ff       	call   800b8c <sys_yield>
  80221d:	eb c6                	jmp    8021e5 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80221f:	85 c0                	test   %eax,%eax
  802221:	75 c2                	jne    8021e5 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802226:	5b                   	pop    %ebx
  802227:	5e                   	pop    %esi
  802228:	5f                   	pop    %edi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    

0080222b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802236:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80223c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802242:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802248:	39 ca                	cmp    %ecx,%edx
  80224a:	75 13                	jne    80225f <ipc_find_env+0x34>
			return envs[i].env_id;
  80224c:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802252:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802257:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80225d:	eb 0f                	jmp    80226e <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80225f:	83 c0 01             	add    $0x1,%eax
  802262:	3d 00 04 00 00       	cmp    $0x400,%eax
  802267:	75 cd                	jne    802236 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802276:	89 d0                	mov    %edx,%eax
  802278:	c1 e8 16             	shr    $0x16,%eax
  80227b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802282:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802287:	f6 c1 01             	test   $0x1,%cl
  80228a:	74 1d                	je     8022a9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80228c:	c1 ea 0c             	shr    $0xc,%edx
  80228f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802296:	f6 c2 01             	test   $0x1,%dl
  802299:	74 0e                	je     8022a9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80229b:	c1 ea 0c             	shr    $0xc,%edx
  80229e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022a5:	ef 
  8022a6:	0f b7 c0             	movzwl %ax,%eax
}
  8022a9:	5d                   	pop    %ebp
  8022aa:	c3                   	ret    
  8022ab:	66 90                	xchg   %ax,%ax
  8022ad:	66 90                	xchg   %ax,%ax
  8022af:	90                   	nop

008022b0 <__udivdi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 f6                	test   %esi,%esi
  8022c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022cd:	89 ca                	mov    %ecx,%edx
  8022cf:	89 f8                	mov    %edi,%eax
  8022d1:	75 3d                	jne    802310 <__udivdi3+0x60>
  8022d3:	39 cf                	cmp    %ecx,%edi
  8022d5:	0f 87 c5 00 00 00    	ja     8023a0 <__udivdi3+0xf0>
  8022db:	85 ff                	test   %edi,%edi
  8022dd:	89 fd                	mov    %edi,%ebp
  8022df:	75 0b                	jne    8022ec <__udivdi3+0x3c>
  8022e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e6:	31 d2                	xor    %edx,%edx
  8022e8:	f7 f7                	div    %edi
  8022ea:	89 c5                	mov    %eax,%ebp
  8022ec:	89 c8                	mov    %ecx,%eax
  8022ee:	31 d2                	xor    %edx,%edx
  8022f0:	f7 f5                	div    %ebp
  8022f2:	89 c1                	mov    %eax,%ecx
  8022f4:	89 d8                	mov    %ebx,%eax
  8022f6:	89 cf                	mov    %ecx,%edi
  8022f8:	f7 f5                	div    %ebp
  8022fa:	89 c3                	mov    %eax,%ebx
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	89 fa                	mov    %edi,%edx
  802300:	83 c4 1c             	add    $0x1c,%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	39 ce                	cmp    %ecx,%esi
  802312:	77 74                	ja     802388 <__udivdi3+0xd8>
  802314:	0f bd fe             	bsr    %esi,%edi
  802317:	83 f7 1f             	xor    $0x1f,%edi
  80231a:	0f 84 98 00 00 00    	je     8023b8 <__udivdi3+0x108>
  802320:	bb 20 00 00 00       	mov    $0x20,%ebx
  802325:	89 f9                	mov    %edi,%ecx
  802327:	89 c5                	mov    %eax,%ebp
  802329:	29 fb                	sub    %edi,%ebx
  80232b:	d3 e6                	shl    %cl,%esi
  80232d:	89 d9                	mov    %ebx,%ecx
  80232f:	d3 ed                	shr    %cl,%ebp
  802331:	89 f9                	mov    %edi,%ecx
  802333:	d3 e0                	shl    %cl,%eax
  802335:	09 ee                	or     %ebp,%esi
  802337:	89 d9                	mov    %ebx,%ecx
  802339:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80233d:	89 d5                	mov    %edx,%ebp
  80233f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802343:	d3 ed                	shr    %cl,%ebp
  802345:	89 f9                	mov    %edi,%ecx
  802347:	d3 e2                	shl    %cl,%edx
  802349:	89 d9                	mov    %ebx,%ecx
  80234b:	d3 e8                	shr    %cl,%eax
  80234d:	09 c2                	or     %eax,%edx
  80234f:	89 d0                	mov    %edx,%eax
  802351:	89 ea                	mov    %ebp,%edx
  802353:	f7 f6                	div    %esi
  802355:	89 d5                	mov    %edx,%ebp
  802357:	89 c3                	mov    %eax,%ebx
  802359:	f7 64 24 0c          	mull   0xc(%esp)
  80235d:	39 d5                	cmp    %edx,%ebp
  80235f:	72 10                	jb     802371 <__udivdi3+0xc1>
  802361:	8b 74 24 08          	mov    0x8(%esp),%esi
  802365:	89 f9                	mov    %edi,%ecx
  802367:	d3 e6                	shl    %cl,%esi
  802369:	39 c6                	cmp    %eax,%esi
  80236b:	73 07                	jae    802374 <__udivdi3+0xc4>
  80236d:	39 d5                	cmp    %edx,%ebp
  80236f:	75 03                	jne    802374 <__udivdi3+0xc4>
  802371:	83 eb 01             	sub    $0x1,%ebx
  802374:	31 ff                	xor    %edi,%edi
  802376:	89 d8                	mov    %ebx,%eax
  802378:	89 fa                	mov    %edi,%edx
  80237a:	83 c4 1c             	add    $0x1c,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5f                   	pop    %edi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    
  802382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802388:	31 ff                	xor    %edi,%edi
  80238a:	31 db                	xor    %ebx,%ebx
  80238c:	89 d8                	mov    %ebx,%eax
  80238e:	89 fa                	mov    %edi,%edx
  802390:	83 c4 1c             	add    $0x1c,%esp
  802393:	5b                   	pop    %ebx
  802394:	5e                   	pop    %esi
  802395:	5f                   	pop    %edi
  802396:	5d                   	pop    %ebp
  802397:	c3                   	ret    
  802398:	90                   	nop
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	89 d8                	mov    %ebx,%eax
  8023a2:	f7 f7                	div    %edi
  8023a4:	31 ff                	xor    %edi,%edi
  8023a6:	89 c3                	mov    %eax,%ebx
  8023a8:	89 d8                	mov    %ebx,%eax
  8023aa:	89 fa                	mov    %edi,%edx
  8023ac:	83 c4 1c             	add    $0x1c,%esp
  8023af:	5b                   	pop    %ebx
  8023b0:	5e                   	pop    %esi
  8023b1:	5f                   	pop    %edi
  8023b2:	5d                   	pop    %ebp
  8023b3:	c3                   	ret    
  8023b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	39 ce                	cmp    %ecx,%esi
  8023ba:	72 0c                	jb     8023c8 <__udivdi3+0x118>
  8023bc:	31 db                	xor    %ebx,%ebx
  8023be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023c2:	0f 87 34 ff ff ff    	ja     8022fc <__udivdi3+0x4c>
  8023c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023cd:	e9 2a ff ff ff       	jmp    8022fc <__udivdi3+0x4c>
  8023d2:	66 90                	xchg   %ax,%ax
  8023d4:	66 90                	xchg   %ax,%ax
  8023d6:	66 90                	xchg   %ax,%ax
  8023d8:	66 90                	xchg   %ax,%ax
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	66 90                	xchg   %ax,%ax
  8023de:	66 90                	xchg   %ax,%ax

008023e0 <__umoddi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	53                   	push   %ebx
  8023e4:	83 ec 1c             	sub    $0x1c,%esp
  8023e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023f7:	85 d2                	test   %edx,%edx
  8023f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802401:	89 f3                	mov    %esi,%ebx
  802403:	89 3c 24             	mov    %edi,(%esp)
  802406:	89 74 24 04          	mov    %esi,0x4(%esp)
  80240a:	75 1c                	jne    802428 <__umoddi3+0x48>
  80240c:	39 f7                	cmp    %esi,%edi
  80240e:	76 50                	jbe    802460 <__umoddi3+0x80>
  802410:	89 c8                	mov    %ecx,%eax
  802412:	89 f2                	mov    %esi,%edx
  802414:	f7 f7                	div    %edi
  802416:	89 d0                	mov    %edx,%eax
  802418:	31 d2                	xor    %edx,%edx
  80241a:	83 c4 1c             	add    $0x1c,%esp
  80241d:	5b                   	pop    %ebx
  80241e:	5e                   	pop    %esi
  80241f:	5f                   	pop    %edi
  802420:	5d                   	pop    %ebp
  802421:	c3                   	ret    
  802422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802428:	39 f2                	cmp    %esi,%edx
  80242a:	89 d0                	mov    %edx,%eax
  80242c:	77 52                	ja     802480 <__umoddi3+0xa0>
  80242e:	0f bd ea             	bsr    %edx,%ebp
  802431:	83 f5 1f             	xor    $0x1f,%ebp
  802434:	75 5a                	jne    802490 <__umoddi3+0xb0>
  802436:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80243a:	0f 82 e0 00 00 00    	jb     802520 <__umoddi3+0x140>
  802440:	39 0c 24             	cmp    %ecx,(%esp)
  802443:	0f 86 d7 00 00 00    	jbe    802520 <__umoddi3+0x140>
  802449:	8b 44 24 08          	mov    0x8(%esp),%eax
  80244d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802451:	83 c4 1c             	add    $0x1c,%esp
  802454:	5b                   	pop    %ebx
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	85 ff                	test   %edi,%edi
  802462:	89 fd                	mov    %edi,%ebp
  802464:	75 0b                	jne    802471 <__umoddi3+0x91>
  802466:	b8 01 00 00 00       	mov    $0x1,%eax
  80246b:	31 d2                	xor    %edx,%edx
  80246d:	f7 f7                	div    %edi
  80246f:	89 c5                	mov    %eax,%ebp
  802471:	89 f0                	mov    %esi,%eax
  802473:	31 d2                	xor    %edx,%edx
  802475:	f7 f5                	div    %ebp
  802477:	89 c8                	mov    %ecx,%eax
  802479:	f7 f5                	div    %ebp
  80247b:	89 d0                	mov    %edx,%eax
  80247d:	eb 99                	jmp    802418 <__umoddi3+0x38>
  80247f:	90                   	nop
  802480:	89 c8                	mov    %ecx,%eax
  802482:	89 f2                	mov    %esi,%edx
  802484:	83 c4 1c             	add    $0x1c,%esp
  802487:	5b                   	pop    %ebx
  802488:	5e                   	pop    %esi
  802489:	5f                   	pop    %edi
  80248a:	5d                   	pop    %ebp
  80248b:	c3                   	ret    
  80248c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802490:	8b 34 24             	mov    (%esp),%esi
  802493:	bf 20 00 00 00       	mov    $0x20,%edi
  802498:	89 e9                	mov    %ebp,%ecx
  80249a:	29 ef                	sub    %ebp,%edi
  80249c:	d3 e0                	shl    %cl,%eax
  80249e:	89 f9                	mov    %edi,%ecx
  8024a0:	89 f2                	mov    %esi,%edx
  8024a2:	d3 ea                	shr    %cl,%edx
  8024a4:	89 e9                	mov    %ebp,%ecx
  8024a6:	09 c2                	or     %eax,%edx
  8024a8:	89 d8                	mov    %ebx,%eax
  8024aa:	89 14 24             	mov    %edx,(%esp)
  8024ad:	89 f2                	mov    %esi,%edx
  8024af:	d3 e2                	shl    %cl,%edx
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024bb:	d3 e8                	shr    %cl,%eax
  8024bd:	89 e9                	mov    %ebp,%ecx
  8024bf:	89 c6                	mov    %eax,%esi
  8024c1:	d3 e3                	shl    %cl,%ebx
  8024c3:	89 f9                	mov    %edi,%ecx
  8024c5:	89 d0                	mov    %edx,%eax
  8024c7:	d3 e8                	shr    %cl,%eax
  8024c9:	89 e9                	mov    %ebp,%ecx
  8024cb:	09 d8                	or     %ebx,%eax
  8024cd:	89 d3                	mov    %edx,%ebx
  8024cf:	89 f2                	mov    %esi,%edx
  8024d1:	f7 34 24             	divl   (%esp)
  8024d4:	89 d6                	mov    %edx,%esi
  8024d6:	d3 e3                	shl    %cl,%ebx
  8024d8:	f7 64 24 04          	mull   0x4(%esp)
  8024dc:	39 d6                	cmp    %edx,%esi
  8024de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024e2:	89 d1                	mov    %edx,%ecx
  8024e4:	89 c3                	mov    %eax,%ebx
  8024e6:	72 08                	jb     8024f0 <__umoddi3+0x110>
  8024e8:	75 11                	jne    8024fb <__umoddi3+0x11b>
  8024ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024ee:	73 0b                	jae    8024fb <__umoddi3+0x11b>
  8024f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024f4:	1b 14 24             	sbb    (%esp),%edx
  8024f7:	89 d1                	mov    %edx,%ecx
  8024f9:	89 c3                	mov    %eax,%ebx
  8024fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024ff:	29 da                	sub    %ebx,%edx
  802501:	19 ce                	sbb    %ecx,%esi
  802503:	89 f9                	mov    %edi,%ecx
  802505:	89 f0                	mov    %esi,%eax
  802507:	d3 e0                	shl    %cl,%eax
  802509:	89 e9                	mov    %ebp,%ecx
  80250b:	d3 ea                	shr    %cl,%edx
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	d3 ee                	shr    %cl,%esi
  802511:	09 d0                	or     %edx,%eax
  802513:	89 f2                	mov    %esi,%edx
  802515:	83 c4 1c             	add    $0x1c,%esp
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5f                   	pop    %edi
  80251b:	5d                   	pop    %ebp
  80251c:	c3                   	ret    
  80251d:	8d 76 00             	lea    0x0(%esi),%esi
  802520:	29 f9                	sub    %edi,%ecx
  802522:	19 d6                	sbb    %edx,%esi
  802524:	89 74 24 04          	mov    %esi,0x4(%esp)
  802528:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80252c:	e9 18 ff ff ff       	jmp    802449 <__umoddi3+0x69>
