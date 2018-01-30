
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
  800039:	68 a0 27 80 00       	push   $0x8027a0
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
  800067:	e8 0c 13 00 00       	call   801378 <argstart>
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
  800091:	e8 12 13 00 00       	call   8013a8 <argnext>
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
  8000ad:	e8 1a 19 00 00       	call   8019cc <fstat>
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
  8000ce:	68 b4 27 80 00       	push   $0x8027b4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 ec 1c 00 00       	call   801dc6 <fprintf>
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
  8000f0:	68 b4 27 80 00       	push   $0x8027b4
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
  80017c:	e8 19 15 00 00       	call   80169a <close_all>
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
  800286:	e8 85 22 00 00       	call   802510 <__udivdi3>
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
  8002c9:	e8 72 23 00 00       	call   802640 <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 e6 27 80 00 	movsbl 0x8027e6(%eax),%eax
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
  8003cd:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
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
  800491:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  800498:	85 d2                	test   %edx,%edx
  80049a:	75 18                	jne    8004b4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049c:	50                   	push   %eax
  80049d:	68 fe 27 80 00       	push   $0x8027fe
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
  8004b5:	68 0d 2d 80 00       	push   $0x802d0d
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
  8004d9:	b8 f7 27 80 00       	mov    $0x8027f7,%eax
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
  800b54:	68 df 2a 80 00       	push   $0x802adf
  800b59:	6a 23                	push   $0x23
  800b5b:	68 fc 2a 80 00       	push   $0x802afc
  800b60:	e8 76 17 00 00       	call   8022db <_panic>

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
  800bd5:	68 df 2a 80 00       	push   $0x802adf
  800bda:	6a 23                	push   $0x23
  800bdc:	68 fc 2a 80 00       	push   $0x802afc
  800be1:	e8 f5 16 00 00       	call   8022db <_panic>

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
  800c17:	68 df 2a 80 00       	push   $0x802adf
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 fc 2a 80 00       	push   $0x802afc
  800c23:	e8 b3 16 00 00       	call   8022db <_panic>

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
  800c59:	68 df 2a 80 00       	push   $0x802adf
  800c5e:	6a 23                	push   $0x23
  800c60:	68 fc 2a 80 00       	push   $0x802afc
  800c65:	e8 71 16 00 00       	call   8022db <_panic>

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
  800c9b:	68 df 2a 80 00       	push   $0x802adf
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 fc 2a 80 00       	push   $0x802afc
  800ca7:	e8 2f 16 00 00       	call   8022db <_panic>

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
  800cdd:	68 df 2a 80 00       	push   $0x802adf
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 fc 2a 80 00       	push   $0x802afc
  800ce9:	e8 ed 15 00 00       	call   8022db <_panic>
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
  800d1f:	68 df 2a 80 00       	push   $0x802adf
  800d24:	6a 23                	push   $0x23
  800d26:	68 fc 2a 80 00       	push   $0x802afc
  800d2b:	e8 ab 15 00 00       	call   8022db <_panic>

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
  800d83:	68 df 2a 80 00       	push   $0x802adf
  800d88:	6a 23                	push   $0x23
  800d8a:	68 fc 2a 80 00       	push   $0x802afc
  800d8f:	e8 47 15 00 00       	call   8022db <_panic>

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
  800e22:	68 0a 2b 80 00       	push   $0x802b0a
  800e27:	6a 1f                	push   $0x1f
  800e29:	68 1a 2b 80 00       	push   $0x802b1a
  800e2e:	e8 a8 14 00 00       	call   8022db <_panic>
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
  800e4c:	68 25 2b 80 00       	push   $0x802b25
  800e51:	6a 2d                	push   $0x2d
  800e53:	68 1a 2b 80 00       	push   $0x802b1a
  800e58:	e8 7e 14 00 00       	call   8022db <_panic>
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
  800e94:	68 25 2b 80 00       	push   $0x802b25
  800e99:	6a 34                	push   $0x34
  800e9b:	68 1a 2b 80 00       	push   $0x802b1a
  800ea0:	e8 36 14 00 00       	call   8022db <_panic>
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
  800ebc:	68 25 2b 80 00       	push   $0x802b25
  800ec1:	6a 38                	push   $0x38
  800ec3:	68 1a 2b 80 00       	push   $0x802b1a
  800ec8:	e8 0e 14 00 00       	call   8022db <_panic>
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
  800ee0:	e8 3c 14 00 00       	call   802321 <set_pgfault_handler>
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
  800ef9:	68 3e 2b 80 00       	push   $0x802b3e
  800efe:	68 85 00 00 00       	push   $0x85
  800f03:	68 1a 2b 80 00       	push   $0x802b1a
  800f08:	e8 ce 13 00 00       	call   8022db <_panic>
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
  800fb5:	68 4c 2b 80 00       	push   $0x802b4c
  800fba:	6a 55                	push   $0x55
  800fbc:	68 1a 2b 80 00       	push   $0x802b1a
  800fc1:	e8 15 13 00 00       	call   8022db <_panic>
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
  800ffa:	68 4c 2b 80 00       	push   $0x802b4c
  800fff:	6a 5c                	push   $0x5c
  801001:	68 1a 2b 80 00       	push   $0x802b1a
  801006:	e8 d0 12 00 00       	call   8022db <_panic>
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
  801028:	68 4c 2b 80 00       	push   $0x802b4c
  80102d:	6a 60                	push   $0x60
  80102f:	68 1a 2b 80 00       	push   $0x802b1a
  801034:	e8 a2 12 00 00       	call   8022db <_panic>
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
  801052:	68 4c 2b 80 00       	push   $0x802b4c
  801057:	6a 65                	push   $0x65
  801059:	68 1a 2b 80 00       	push   $0x802b1a
  80105e:	e8 78 12 00 00       	call   8022db <_panic>
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
  8010c1:	68 dc 2b 80 00       	push   $0x802bdc
  8010c6:	e8 58 f1 ff ff       	call   800223 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010cb:	c7 04 24 56 01 80 00 	movl   $0x800156,(%esp)
  8010d2:	e8 c5 fc ff ff       	call   800d9c <sys_thread_create>
  8010d7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010d9:	83 c4 08             	add    $0x8,%esp
  8010dc:	53                   	push   %ebx
  8010dd:	68 dc 2b 80 00       	push   $0x802bdc
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

00801116 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	8b 75 08             	mov    0x8(%ebp),%esi
  80111e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	6a 07                	push   $0x7
  801126:	6a 00                	push   $0x0
  801128:	56                   	push   %esi
  801129:	e8 7d fa ff ff       	call   800bab <sys_page_alloc>
	if (r < 0) {
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	79 15                	jns    80114a <queue_append+0x34>
		panic("%e\n", r);
  801135:	50                   	push   %eax
  801136:	68 d8 2b 80 00       	push   $0x802bd8
  80113b:	68 c4 00 00 00       	push   $0xc4
  801140:	68 1a 2b 80 00       	push   $0x802b1a
  801145:	e8 91 11 00 00       	call   8022db <_panic>
	}	
	wt->envid = envid;
  80114a:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801150:	83 ec 04             	sub    $0x4,%esp
  801153:	ff 33                	pushl  (%ebx)
  801155:	56                   	push   %esi
  801156:	68 00 2c 80 00       	push   $0x802c00
  80115b:	e8 c3 f0 ff ff       	call   800223 <cprintf>
	if (queue->first == NULL) {
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	83 3b 00             	cmpl   $0x0,(%ebx)
  801166:	75 29                	jne    801191 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  801168:	83 ec 0c             	sub    $0xc,%esp
  80116b:	68 62 2b 80 00       	push   $0x802b62
  801170:	e8 ae f0 ff ff       	call   800223 <cprintf>
		queue->first = wt;
  801175:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80117b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801182:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801189:	00 00 00 
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	eb 2b                	jmp    8011bc <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	68 7c 2b 80 00       	push   $0x802b7c
  801199:	e8 85 f0 ff ff       	call   800223 <cprintf>
		queue->last->next = wt;
  80119e:	8b 43 04             	mov    0x4(%ebx),%eax
  8011a1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011a8:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011af:	00 00 00 
		queue->last = wt;
  8011b2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8011b9:	83 c4 10             	add    $0x10,%esp
	}
}
  8011bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8011cd:	8b 02                	mov    (%edx),%eax
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	75 17                	jne    8011ea <queue_pop+0x27>
		panic("queue empty!\n");
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	68 9a 2b 80 00       	push   $0x802b9a
  8011db:	68 d8 00 00 00       	push   $0xd8
  8011e0:	68 1a 2b 80 00       	push   $0x802b1a
  8011e5:	e8 f1 10 00 00       	call   8022db <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8011ed:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8011ef:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	53                   	push   %ebx
  8011f5:	68 a8 2b 80 00       	push   $0x802ba8
  8011fa:	e8 24 f0 ff ff       	call   800223 <cprintf>
	return envid;
}
  8011ff:	89 d8                	mov    %ebx,%eax
  801201:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	53                   	push   %ebx
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801210:	b8 01 00 00 00       	mov    $0x1,%eax
  801215:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801218:	85 c0                	test   %eax,%eax
  80121a:	74 5a                	je     801276 <mutex_lock+0x70>
  80121c:	8b 43 04             	mov    0x4(%ebx),%eax
  80121f:	83 38 00             	cmpl   $0x0,(%eax)
  801222:	75 52                	jne    801276 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	68 28 2c 80 00       	push   $0x802c28
  80122c:	e8 f2 ef ff ff       	call   800223 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801231:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801234:	e8 34 f9 ff ff       	call   800b6d <sys_getenvid>
  801239:	83 c4 08             	add    $0x8,%esp
  80123c:	53                   	push   %ebx
  80123d:	50                   	push   %eax
  80123e:	e8 d3 fe ff ff       	call   801116 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801243:	e8 25 f9 ff ff       	call   800b6d <sys_getenvid>
  801248:	83 c4 08             	add    $0x8,%esp
  80124b:	6a 04                	push   $0x4
  80124d:	50                   	push   %eax
  80124e:	e8 1f fa ff ff       	call   800c72 <sys_env_set_status>
		if (r < 0) {
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	79 15                	jns    80126f <mutex_lock+0x69>
			panic("%e\n", r);
  80125a:	50                   	push   %eax
  80125b:	68 d8 2b 80 00       	push   $0x802bd8
  801260:	68 eb 00 00 00       	push   $0xeb
  801265:	68 1a 2b 80 00       	push   $0x802b1a
  80126a:	e8 6c 10 00 00       	call   8022db <_panic>
		}
		sys_yield();
  80126f:	e8 18 f9 ff ff       	call   800b8c <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801274:	eb 18                	jmp    80128e <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	68 48 2c 80 00       	push   $0x802c48
  80127e:	e8 a0 ef ff ff       	call   800223 <cprintf>
	mtx->owner = sys_getenvid();}
  801283:	e8 e5 f8 ff ff       	call   800b6d <sys_getenvid>
  801288:	89 43 08             	mov    %eax,0x8(%ebx)
  80128b:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80128e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	53                   	push   %ebx
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80129d:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a2:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8012a5:	8b 43 04             	mov    0x4(%ebx),%eax
  8012a8:	83 38 00             	cmpl   $0x0,(%eax)
  8012ab:	74 33                	je     8012e0 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	50                   	push   %eax
  8012b1:	e8 0d ff ff ff       	call   8011c3 <queue_pop>
  8012b6:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012b9:	83 c4 08             	add    $0x8,%esp
  8012bc:	6a 02                	push   $0x2
  8012be:	50                   	push   %eax
  8012bf:	e8 ae f9 ff ff       	call   800c72 <sys_env_set_status>
		if (r < 0) {
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	79 15                	jns    8012e0 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012cb:	50                   	push   %eax
  8012cc:	68 d8 2b 80 00       	push   $0x802bd8
  8012d1:	68 00 01 00 00       	push   $0x100
  8012d6:	68 1a 2b 80 00       	push   $0x802b1a
  8012db:	e8 fb 0f 00 00       	call   8022db <_panic>
		}
	}

	asm volatile("pause");
  8012e0:	f3 90                	pause  
	//sys_yield();
}
  8012e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 04             	sub    $0x4,%esp
  8012ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012f1:	e8 77 f8 ff ff       	call   800b6d <sys_getenvid>
  8012f6:	83 ec 04             	sub    $0x4,%esp
  8012f9:	6a 07                	push   $0x7
  8012fb:	53                   	push   %ebx
  8012fc:	50                   	push   %eax
  8012fd:	e8 a9 f8 ff ff       	call   800bab <sys_page_alloc>
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	79 15                	jns    80131e <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801309:	50                   	push   %eax
  80130a:	68 c3 2b 80 00       	push   $0x802bc3
  80130f:	68 0d 01 00 00       	push   $0x10d
  801314:	68 1a 2b 80 00       	push   $0x802b1a
  801319:	e8 bd 0f 00 00       	call   8022db <_panic>
	}	
	mtx->locked = 0;
  80131e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801324:	8b 43 04             	mov    0x4(%ebx),%eax
  801327:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80132d:	8b 43 04             	mov    0x4(%ebx),%eax
  801330:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801337:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80133e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801349:	e8 1f f8 ff ff       	call   800b6d <sys_getenvid>
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	ff 75 08             	pushl  0x8(%ebp)
  801354:	50                   	push   %eax
  801355:	e8 d6 f8 ff ff       	call   800c30 <sys_page_unmap>
	if (r < 0) {
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	79 15                	jns    801376 <mutex_destroy+0x33>
		panic("%e\n", r);
  801361:	50                   	push   %eax
  801362:	68 d8 2b 80 00       	push   $0x802bd8
  801367:	68 1a 01 00 00       	push   $0x11a
  80136c:	68 1a 2b 80 00       	push   $0x802b1a
  801371:	e8 65 0f 00 00       	call   8022db <_panic>
	}
}
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	8b 55 08             	mov    0x8(%ebp),%edx
  80137e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801381:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801384:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801386:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801389:	83 3a 01             	cmpl   $0x1,(%edx)
  80138c:	7e 09                	jle    801397 <argstart+0x1f>
  80138e:	ba a7 2b 80 00       	mov    $0x802ba7,%edx
  801393:	85 c9                	test   %ecx,%ecx
  801395:	75 05                	jne    80139c <argstart+0x24>
  801397:	ba 00 00 00 00       	mov    $0x0,%edx
  80139c:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80139f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <argnext>:

int
argnext(struct Argstate *args)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 04             	sub    $0x4,%esp
  8013af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8013b2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8013b9:	8b 43 08             	mov    0x8(%ebx),%eax
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	74 6f                	je     80142f <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  8013c0:	80 38 00             	cmpb   $0x0,(%eax)
  8013c3:	75 4e                	jne    801413 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8013c5:	8b 0b                	mov    (%ebx),%ecx
  8013c7:	83 39 01             	cmpl   $0x1,(%ecx)
  8013ca:	74 55                	je     801421 <argnext+0x79>
		    || args->argv[1][0] != '-'
  8013cc:	8b 53 04             	mov    0x4(%ebx),%edx
  8013cf:	8b 42 04             	mov    0x4(%edx),%eax
  8013d2:	80 38 2d             	cmpb   $0x2d,(%eax)
  8013d5:	75 4a                	jne    801421 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  8013d7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8013db:	74 44                	je     801421 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8013dd:	83 c0 01             	add    $0x1,%eax
  8013e0:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8013e3:	83 ec 04             	sub    $0x4,%esp
  8013e6:	8b 01                	mov    (%ecx),%eax
  8013e8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8013ef:	50                   	push   %eax
  8013f0:	8d 42 08             	lea    0x8(%edx),%eax
  8013f3:	50                   	push   %eax
  8013f4:	83 c2 04             	add    $0x4,%edx
  8013f7:	52                   	push   %edx
  8013f8:	e8 3d f5 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  8013fd:	8b 03                	mov    (%ebx),%eax
  8013ff:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801402:	8b 43 08             	mov    0x8(%ebx),%eax
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	80 38 2d             	cmpb   $0x2d,(%eax)
  80140b:	75 06                	jne    801413 <argnext+0x6b>
  80140d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801411:	74 0e                	je     801421 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801413:	8b 53 08             	mov    0x8(%ebx),%edx
  801416:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801419:	83 c2 01             	add    $0x1,%edx
  80141c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80141f:	eb 13                	jmp    801434 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801421:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801428:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80142d:	eb 05                	jmp    801434 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80142f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801434:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	53                   	push   %ebx
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801443:	8b 43 08             	mov    0x8(%ebx),%eax
  801446:	85 c0                	test   %eax,%eax
  801448:	74 58                	je     8014a2 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  80144a:	80 38 00             	cmpb   $0x0,(%eax)
  80144d:	74 0c                	je     80145b <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80144f:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801452:	c7 43 08 a7 2b 80 00 	movl   $0x802ba7,0x8(%ebx)
  801459:	eb 42                	jmp    80149d <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  80145b:	8b 13                	mov    (%ebx),%edx
  80145d:	83 3a 01             	cmpl   $0x1,(%edx)
  801460:	7e 2d                	jle    80148f <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801462:	8b 43 04             	mov    0x4(%ebx),%eax
  801465:	8b 48 04             	mov    0x4(%eax),%ecx
  801468:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	8b 12                	mov    (%edx),%edx
  801470:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801477:	52                   	push   %edx
  801478:	8d 50 08             	lea    0x8(%eax),%edx
  80147b:	52                   	push   %edx
  80147c:	83 c0 04             	add    $0x4,%eax
  80147f:	50                   	push   %eax
  801480:	e8 b5 f4 ff ff       	call   80093a <memmove>
		(*args->argc)--;
  801485:	8b 03                	mov    (%ebx),%eax
  801487:	83 28 01             	subl   $0x1,(%eax)
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	eb 0e                	jmp    80149d <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  80148f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801496:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80149d:	8b 43 0c             	mov    0xc(%ebx),%eax
  8014a0:	eb 05                	jmp    8014a7 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8014a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8014b5:	8b 51 0c             	mov    0xc(%ecx),%edx
  8014b8:	89 d0                	mov    %edx,%eax
  8014ba:	85 d2                	test   %edx,%edx
  8014bc:	75 0c                	jne    8014ca <argvalue+0x1e>
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	51                   	push   %ecx
  8014c2:	e8 72 ff ff ff       	call   801439 <argnextvalue>
  8014c7:	83 c4 10             	add    $0x10,%esp
}
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8014d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014df:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8014e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014ec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	c1 ea 16             	shr    $0x16,%edx
  801503:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80150a:	f6 c2 01             	test   $0x1,%dl
  80150d:	74 11                	je     801520 <fd_alloc+0x2d>
  80150f:	89 c2                	mov    %eax,%edx
  801511:	c1 ea 0c             	shr    $0xc,%edx
  801514:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151b:	f6 c2 01             	test   $0x1,%dl
  80151e:	75 09                	jne    801529 <fd_alloc+0x36>
			*fd_store = fd;
  801520:	89 01                	mov    %eax,(%ecx)
			return 0;
  801522:	b8 00 00 00 00       	mov    $0x0,%eax
  801527:	eb 17                	jmp    801540 <fd_alloc+0x4d>
  801529:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80152e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801533:	75 c9                	jne    8014fe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801535:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80153b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    

00801542 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801548:	83 f8 1f             	cmp    $0x1f,%eax
  80154b:	77 36                	ja     801583 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80154d:	c1 e0 0c             	shl    $0xc,%eax
  801550:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801555:	89 c2                	mov    %eax,%edx
  801557:	c1 ea 16             	shr    $0x16,%edx
  80155a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801561:	f6 c2 01             	test   $0x1,%dl
  801564:	74 24                	je     80158a <fd_lookup+0x48>
  801566:	89 c2                	mov    %eax,%edx
  801568:	c1 ea 0c             	shr    $0xc,%edx
  80156b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801572:	f6 c2 01             	test   $0x1,%dl
  801575:	74 1a                	je     801591 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801577:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157a:	89 02                	mov    %eax,(%edx)
	return 0;
  80157c:	b8 00 00 00 00       	mov    $0x0,%eax
  801581:	eb 13                	jmp    801596 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801583:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801588:	eb 0c                	jmp    801596 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80158a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158f:	eb 05                	jmp    801596 <fd_lookup+0x54>
  801591:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015a1:	ba e4 2c 80 00       	mov    $0x802ce4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015a6:	eb 13                	jmp    8015bb <dev_lookup+0x23>
  8015a8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015ab:	39 08                	cmp    %ecx,(%eax)
  8015ad:	75 0c                	jne    8015bb <dev_lookup+0x23>
			*dev = devtab[i];
  8015af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b9:	eb 31                	jmp    8015ec <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015bb:	8b 02                	mov    (%edx),%eax
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	75 e7                	jne    8015a8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	51                   	push   %ecx
  8015d0:	50                   	push   %eax
  8015d1:	68 68 2c 80 00       	push   $0x802c68
  8015d6:	e8 48 ec ff ff       	call   800223 <cprintf>
	*dev = 0;
  8015db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 10             	sub    $0x10,%esp
  8015f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801606:	c1 e8 0c             	shr    $0xc,%eax
  801609:	50                   	push   %eax
  80160a:	e8 33 ff ff ff       	call   801542 <fd_lookup>
  80160f:	83 c4 08             	add    $0x8,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 05                	js     80161b <fd_close+0x2d>
	    || fd != fd2)
  801616:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801619:	74 0c                	je     801627 <fd_close+0x39>
		return (must_exist ? r : 0);
  80161b:	84 db                	test   %bl,%bl
  80161d:	ba 00 00 00 00       	mov    $0x0,%edx
  801622:	0f 44 c2             	cmove  %edx,%eax
  801625:	eb 41                	jmp    801668 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	ff 36                	pushl  (%esi)
  801630:	e8 63 ff ff ff       	call   801598 <dev_lookup>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 1a                	js     801658 <fd_close+0x6a>
		if (dev->dev_close)
  80163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801641:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801644:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801649:	85 c0                	test   %eax,%eax
  80164b:	74 0b                	je     801658 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	56                   	push   %esi
  801651:	ff d0                	call   *%eax
  801653:	89 c3                	mov    %eax,%ebx
  801655:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	56                   	push   %esi
  80165c:	6a 00                	push   $0x0
  80165e:	e8 cd f5 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	89 d8                	mov    %ebx,%eax
}
  801668:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 c1 fe ff ff       	call   801542 <fd_lookup>
  801681:	83 c4 08             	add    $0x8,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 10                	js     801698 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	6a 01                	push   $0x1
  80168d:	ff 75 f4             	pushl  -0xc(%ebp)
  801690:	e8 59 ff ff ff       	call   8015ee <fd_close>
  801695:	83 c4 10             	add    $0x10,%esp
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <close_all>:

void
close_all(void)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	53                   	push   %ebx
  80169e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016a6:	83 ec 0c             	sub    $0xc,%esp
  8016a9:	53                   	push   %ebx
  8016aa:	e8 c0 ff ff ff       	call   80166f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016af:	83 c3 01             	add    $0x1,%ebx
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	83 fb 20             	cmp    $0x20,%ebx
  8016b8:	75 ec                	jne    8016a6 <close_all+0xc>
		close(i);
}
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	57                   	push   %edi
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 2c             	sub    $0x2c,%esp
  8016c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 08             	pushl  0x8(%ebp)
  8016d2:	e8 6b fe ff ff       	call   801542 <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	0f 88 c1 00 00 00    	js     8017a3 <dup+0xe4>
		return r;
	close(newfdnum);
  8016e2:	83 ec 0c             	sub    $0xc,%esp
  8016e5:	56                   	push   %esi
  8016e6:	e8 84 ff ff ff       	call   80166f <close>

	newfd = INDEX2FD(newfdnum);
  8016eb:	89 f3                	mov    %esi,%ebx
  8016ed:	c1 e3 0c             	shl    $0xc,%ebx
  8016f0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016f6:	83 c4 04             	add    $0x4,%esp
  8016f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fc:	e8 db fd ff ff       	call   8014dc <fd2data>
  801701:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801703:	89 1c 24             	mov    %ebx,(%esp)
  801706:	e8 d1 fd ff ff       	call   8014dc <fd2data>
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801711:	89 f8                	mov    %edi,%eax
  801713:	c1 e8 16             	shr    $0x16,%eax
  801716:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80171d:	a8 01                	test   $0x1,%al
  80171f:	74 37                	je     801758 <dup+0x99>
  801721:	89 f8                	mov    %edi,%eax
  801723:	c1 e8 0c             	shr    $0xc,%eax
  801726:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80172d:	f6 c2 01             	test   $0x1,%dl
  801730:	74 26                	je     801758 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801732:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	25 07 0e 00 00       	and    $0xe07,%eax
  801741:	50                   	push   %eax
  801742:	ff 75 d4             	pushl  -0x2c(%ebp)
  801745:	6a 00                	push   $0x0
  801747:	57                   	push   %edi
  801748:	6a 00                	push   $0x0
  80174a:	e8 9f f4 ff ff       	call   800bee <sys_page_map>
  80174f:	89 c7                	mov    %eax,%edi
  801751:	83 c4 20             	add    $0x20,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 2e                	js     801786 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801758:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	c1 e8 0c             	shr    $0xc,%eax
  801760:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	25 07 0e 00 00       	and    $0xe07,%eax
  80176f:	50                   	push   %eax
  801770:	53                   	push   %ebx
  801771:	6a 00                	push   $0x0
  801773:	52                   	push   %edx
  801774:	6a 00                	push   $0x0
  801776:	e8 73 f4 ff ff       	call   800bee <sys_page_map>
  80177b:	89 c7                	mov    %eax,%edi
  80177d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801780:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801782:	85 ff                	test   %edi,%edi
  801784:	79 1d                	jns    8017a3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	53                   	push   %ebx
  80178a:	6a 00                	push   $0x0
  80178c:	e8 9f f4 ff ff       	call   800c30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801791:	83 c4 08             	add    $0x8,%esp
  801794:	ff 75 d4             	pushl  -0x2c(%ebp)
  801797:	6a 00                	push   $0x0
  801799:	e8 92 f4 ff ff       	call   800c30 <sys_page_unmap>
	return r;
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	89 f8                	mov    %edi,%eax
}
  8017a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5f                   	pop    %edi
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 14             	sub    $0x14,%esp
  8017b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	53                   	push   %ebx
  8017ba:	e8 83 fd ff ff       	call   801542 <fd_lookup>
  8017bf:	83 c4 08             	add    $0x8,%esp
  8017c2:	89 c2                	mov    %eax,%edx
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 70                	js     801838 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ce:	50                   	push   %eax
  8017cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d2:	ff 30                	pushl  (%eax)
  8017d4:	e8 bf fd ff ff       	call   801598 <dev_lookup>
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 4f                	js     80182f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e3:	8b 42 08             	mov    0x8(%edx),%eax
  8017e6:	83 e0 03             	and    $0x3,%eax
  8017e9:	83 f8 01             	cmp    $0x1,%eax
  8017ec:	75 24                	jne    801812 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	53                   	push   %ebx
  8017fd:	50                   	push   %eax
  8017fe:	68 a9 2c 80 00       	push   $0x802ca9
  801803:	e8 1b ea ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801810:	eb 26                	jmp    801838 <read+0x8d>
	}
	if (!dev->dev_read)
  801812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801815:	8b 40 08             	mov    0x8(%eax),%eax
  801818:	85 c0                	test   %eax,%eax
  80181a:	74 17                	je     801833 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	ff 75 10             	pushl  0x10(%ebp)
  801822:	ff 75 0c             	pushl  0xc(%ebp)
  801825:	52                   	push   %edx
  801826:	ff d0                	call   *%eax
  801828:	89 c2                	mov    %eax,%edx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	eb 09                	jmp    801838 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	89 c2                	mov    %eax,%edx
  801831:	eb 05                	jmp    801838 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801838:	89 d0                	mov    %edx,%eax
  80183a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	57                   	push   %edi
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	8b 7d 08             	mov    0x8(%ebp),%edi
  80184b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80184e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801853:	eb 21                	jmp    801876 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	89 f0                	mov    %esi,%eax
  80185a:	29 d8                	sub    %ebx,%eax
  80185c:	50                   	push   %eax
  80185d:	89 d8                	mov    %ebx,%eax
  80185f:	03 45 0c             	add    0xc(%ebp),%eax
  801862:	50                   	push   %eax
  801863:	57                   	push   %edi
  801864:	e8 42 ff ff ff       	call   8017ab <read>
		if (m < 0)
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 10                	js     801880 <readn+0x41>
			return m;
		if (m == 0)
  801870:	85 c0                	test   %eax,%eax
  801872:	74 0a                	je     80187e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801874:	01 c3                	add    %eax,%ebx
  801876:	39 f3                	cmp    %esi,%ebx
  801878:	72 db                	jb     801855 <readn+0x16>
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	eb 02                	jmp    801880 <readn+0x41>
  80187e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801880:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801883:	5b                   	pop    %ebx
  801884:	5e                   	pop    %esi
  801885:	5f                   	pop    %edi
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	53                   	push   %ebx
  80188c:	83 ec 14             	sub    $0x14,%esp
  80188f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801892:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	53                   	push   %ebx
  801897:	e8 a6 fc ff ff       	call   801542 <fd_lookup>
  80189c:	83 c4 08             	add    $0x8,%esp
  80189f:	89 c2                	mov    %eax,%edx
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 6b                	js     801910 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018af:	ff 30                	pushl  (%eax)
  8018b1:	e8 e2 fc ff ff       	call   801598 <dev_lookup>
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 4a                	js     801907 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c4:	75 24                	jne    8018ea <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8018cb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018d1:	83 ec 04             	sub    $0x4,%esp
  8018d4:	53                   	push   %ebx
  8018d5:	50                   	push   %eax
  8018d6:	68 c5 2c 80 00       	push   $0x802cc5
  8018db:	e8 43 e9 ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e8:	eb 26                	jmp    801910 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8018f0:	85 d2                	test   %edx,%edx
  8018f2:	74 17                	je     80190b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018f4:	83 ec 04             	sub    $0x4,%esp
  8018f7:	ff 75 10             	pushl  0x10(%ebp)
  8018fa:	ff 75 0c             	pushl  0xc(%ebp)
  8018fd:	50                   	push   %eax
  8018fe:	ff d2                	call   *%edx
  801900:	89 c2                	mov    %eax,%edx
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	eb 09                	jmp    801910 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801907:	89 c2                	mov    %eax,%edx
  801909:	eb 05                	jmp    801910 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80190b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801910:	89 d0                	mov    %edx,%eax
  801912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <seek>:

int
seek(int fdnum, off_t offset)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80191d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801920:	50                   	push   %eax
  801921:	ff 75 08             	pushl  0x8(%ebp)
  801924:	e8 19 fc ff ff       	call   801542 <fd_lookup>
  801929:	83 c4 08             	add    $0x8,%esp
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 0e                	js     80193e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801930:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801933:	8b 55 0c             	mov    0xc(%ebp),%edx
  801936:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	53                   	push   %ebx
  801944:	83 ec 14             	sub    $0x14,%esp
  801947:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80194a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80194d:	50                   	push   %eax
  80194e:	53                   	push   %ebx
  80194f:	e8 ee fb ff ff       	call   801542 <fd_lookup>
  801954:	83 c4 08             	add    $0x8,%esp
  801957:	89 c2                	mov    %eax,%edx
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 68                	js     8019c5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801963:	50                   	push   %eax
  801964:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801967:	ff 30                	pushl  (%eax)
  801969:	e8 2a fc ff ff       	call   801598 <dev_lookup>
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	85 c0                	test   %eax,%eax
  801973:	78 47                	js     8019bc <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801975:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801978:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80197c:	75 24                	jne    8019a2 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80197e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801983:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801989:	83 ec 04             	sub    $0x4,%esp
  80198c:	53                   	push   %ebx
  80198d:	50                   	push   %eax
  80198e:	68 88 2c 80 00       	push   $0x802c88
  801993:	e8 8b e8 ff ff       	call   800223 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019a0:	eb 23                	jmp    8019c5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8019a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a5:	8b 52 18             	mov    0x18(%edx),%edx
  8019a8:	85 d2                	test   %edx,%edx
  8019aa:	74 14                	je     8019c0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019ac:	83 ec 08             	sub    $0x8,%esp
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	50                   	push   %eax
  8019b3:	ff d2                	call   *%edx
  8019b5:	89 c2                	mov    %eax,%edx
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	eb 09                	jmp    8019c5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019bc:	89 c2                	mov    %eax,%edx
  8019be:	eb 05                	jmp    8019c5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019c5:	89 d0                	mov    %edx,%eax
  8019c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 14             	sub    $0x14,%esp
  8019d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	ff 75 08             	pushl  0x8(%ebp)
  8019dd:	e8 60 fb ff ff       	call   801542 <fd_lookup>
  8019e2:	83 c4 08             	add    $0x8,%esp
  8019e5:	89 c2                	mov    %eax,%edx
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 58                	js     801a43 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f5:	ff 30                	pushl  (%eax)
  8019f7:	e8 9c fb ff ff       	call   801598 <dev_lookup>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 37                	js     801a3a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a0a:	74 32                	je     801a3e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a0c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a0f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a16:	00 00 00 
	stat->st_isdir = 0;
  801a19:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a20:	00 00 00 
	stat->st_dev = dev;
  801a23:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	53                   	push   %ebx
  801a2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a30:	ff 50 14             	call   *0x14(%eax)
  801a33:	89 c2                	mov    %eax,%edx
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	eb 09                	jmp    801a43 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a3a:	89 c2                	mov    %eax,%edx
  801a3c:	eb 05                	jmp    801a43 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a3e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a43:	89 d0                	mov    %edx,%eax
  801a45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	56                   	push   %esi
  801a4e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a4f:	83 ec 08             	sub    $0x8,%esp
  801a52:	6a 00                	push   $0x0
  801a54:	ff 75 08             	pushl  0x8(%ebp)
  801a57:	e8 e3 01 00 00       	call   801c3f <open>
  801a5c:	89 c3                	mov    %eax,%ebx
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 1b                	js     801a80 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	ff 75 0c             	pushl  0xc(%ebp)
  801a6b:	50                   	push   %eax
  801a6c:	e8 5b ff ff ff       	call   8019cc <fstat>
  801a71:	89 c6                	mov    %eax,%esi
	close(fd);
  801a73:	89 1c 24             	mov    %ebx,(%esp)
  801a76:	e8 f4 fb ff ff       	call   80166f <close>
	return r;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	89 f0                	mov    %esi,%eax
}
  801a80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	89 c6                	mov    %eax,%esi
  801a8e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a90:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a97:	75 12                	jne    801aab <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	6a 01                	push   $0x1
  801a9e:	e8 ea 09 00 00       	call   80248d <ipc_find_env>
  801aa3:	a3 00 40 80 00       	mov    %eax,0x804000
  801aa8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aab:	6a 07                	push   $0x7
  801aad:	68 00 50 80 00       	push   $0x805000
  801ab2:	56                   	push   %esi
  801ab3:	ff 35 00 40 80 00    	pushl  0x804000
  801ab9:	e8 6d 09 00 00       	call   80242b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801abe:	83 c4 0c             	add    $0xc,%esp
  801ac1:	6a 00                	push   $0x0
  801ac3:	53                   	push   %ebx
  801ac4:	6a 00                	push   $0x0
  801ac6:	e8 e5 08 00 00       	call   8023b0 <ipc_recv>
}
  801acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	8b 40 0c             	mov    0xc(%eax),%eax
  801ade:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801af0:	b8 02 00 00 00       	mov    $0x2,%eax
  801af5:	e8 8d ff ff ff       	call   801a87 <fsipc>
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
  801b05:	8b 40 0c             	mov    0xc(%eax),%eax
  801b08:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b12:	b8 06 00 00 00       	mov    $0x6,%eax
  801b17:	e8 6b ff ff ff       	call   801a87 <fsipc>
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	53                   	push   %ebx
  801b22:	83 ec 04             	sub    $0x4,%esp
  801b25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	b8 05 00 00 00       	mov    $0x5,%eax
  801b3d:	e8 45 ff ff ff       	call   801a87 <fsipc>
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 2c                	js     801b72 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b46:	83 ec 08             	sub    $0x8,%esp
  801b49:	68 00 50 80 00       	push   $0x805000
  801b4e:	53                   	push   %ebx
  801b4f:	e8 54 ec ff ff       	call   8007a8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b54:	a1 80 50 80 00       	mov    0x805080,%eax
  801b59:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b5f:	a1 84 50 80 00       	mov    0x805084,%eax
  801b64:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b80:	8b 55 08             	mov    0x8(%ebp),%edx
  801b83:	8b 52 0c             	mov    0xc(%edx),%edx
  801b86:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b8c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b91:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b96:	0f 47 c2             	cmova  %edx,%eax
  801b99:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b9e:	50                   	push   %eax
  801b9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ba2:	68 08 50 80 00       	push   $0x805008
  801ba7:	e8 8e ed ff ff       	call   80093a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801bac:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb1:	b8 04 00 00 00       	mov    $0x4,%eax
  801bb6:	e8 cc fe ff ff       	call   801a87 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc8:	8b 40 0c             	mov    0xc(%eax),%eax
  801bcb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bd0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdb:	b8 03 00 00 00       	mov    $0x3,%eax
  801be0:	e8 a2 fe ff ff       	call   801a87 <fsipc>
  801be5:	89 c3                	mov    %eax,%ebx
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 4b                	js     801c36 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801beb:	39 c6                	cmp    %eax,%esi
  801bed:	73 16                	jae    801c05 <devfile_read+0x48>
  801bef:	68 f4 2c 80 00       	push   $0x802cf4
  801bf4:	68 fb 2c 80 00       	push   $0x802cfb
  801bf9:	6a 7c                	push   $0x7c
  801bfb:	68 10 2d 80 00       	push   $0x802d10
  801c00:	e8 d6 06 00 00       	call   8022db <_panic>
	assert(r <= PGSIZE);
  801c05:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c0a:	7e 16                	jle    801c22 <devfile_read+0x65>
  801c0c:	68 1b 2d 80 00       	push   $0x802d1b
  801c11:	68 fb 2c 80 00       	push   $0x802cfb
  801c16:	6a 7d                	push   $0x7d
  801c18:	68 10 2d 80 00       	push   $0x802d10
  801c1d:	e8 b9 06 00 00       	call   8022db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c22:	83 ec 04             	sub    $0x4,%esp
  801c25:	50                   	push   %eax
  801c26:	68 00 50 80 00       	push   $0x805000
  801c2b:	ff 75 0c             	pushl  0xc(%ebp)
  801c2e:	e8 07 ed ff ff       	call   80093a <memmove>
	return r;
  801c33:	83 c4 10             	add    $0x10,%esp
}
  801c36:	89 d8                	mov    %ebx,%eax
  801c38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	53                   	push   %ebx
  801c43:	83 ec 20             	sub    $0x20,%esp
  801c46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c49:	53                   	push   %ebx
  801c4a:	e8 20 eb ff ff       	call   80076f <strlen>
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c57:	7f 67                	jg     801cc0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5f:	50                   	push   %eax
  801c60:	e8 8e f8 ff ff       	call   8014f3 <fd_alloc>
  801c65:	83 c4 10             	add    $0x10,%esp
		return r;
  801c68:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	78 57                	js     801cc5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c6e:	83 ec 08             	sub    $0x8,%esp
  801c71:	53                   	push   %ebx
  801c72:	68 00 50 80 00       	push   $0x805000
  801c77:	e8 2c eb ff ff       	call   8007a8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c87:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8c:	e8 f6 fd ff ff       	call   801a87 <fsipc>
  801c91:	89 c3                	mov    %eax,%ebx
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	85 c0                	test   %eax,%eax
  801c98:	79 14                	jns    801cae <open+0x6f>
		fd_close(fd, 0);
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	6a 00                	push   $0x0
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	e8 47 f9 ff ff       	call   8015ee <fd_close>
		return r;
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	89 da                	mov    %ebx,%edx
  801cac:	eb 17                	jmp    801cc5 <open+0x86>
	}

	return fd2num(fd);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb4:	e8 13 f8 ff ff       	call   8014cc <fd2num>
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	83 c4 10             	add    $0x10,%esp
  801cbe:	eb 05                	jmp    801cc5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cc0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd7:	b8 08 00 00 00       	mov    $0x8,%eax
  801cdc:	e8 a6 fd ff ff       	call   801a87 <fsipc>
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801ce3:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801ce7:	7e 37                	jle    801d20 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	53                   	push   %ebx
  801ced:	83 ec 08             	sub    $0x8,%esp
  801cf0:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801cf2:	ff 70 04             	pushl  0x4(%eax)
  801cf5:	8d 40 10             	lea    0x10(%eax),%eax
  801cf8:	50                   	push   %eax
  801cf9:	ff 33                	pushl  (%ebx)
  801cfb:	e8 88 fb ff ff       	call   801888 <write>
		if (result > 0)
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	85 c0                	test   %eax,%eax
  801d05:	7e 03                	jle    801d0a <writebuf+0x27>
			b->result += result;
  801d07:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801d0a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d0d:	74 0d                	je     801d1c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	ba 00 00 00 00       	mov    $0x0,%edx
  801d16:	0f 4f c2             	cmovg  %edx,%eax
  801d19:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801d1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1f:	c9                   	leave  
  801d20:	f3 c3                	repz ret 

00801d22 <putch>:

static void
putch(int ch, void *thunk)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	53                   	push   %ebx
  801d26:	83 ec 04             	sub    $0x4,%esp
  801d29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801d2c:	8b 53 04             	mov    0x4(%ebx),%edx
  801d2f:	8d 42 01             	lea    0x1(%edx),%eax
  801d32:	89 43 04             	mov    %eax,0x4(%ebx)
  801d35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d38:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801d3c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801d41:	75 0e                	jne    801d51 <putch+0x2f>
		writebuf(b);
  801d43:	89 d8                	mov    %ebx,%eax
  801d45:	e8 99 ff ff ff       	call   801ce3 <writebuf>
		b->idx = 0;
  801d4a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801d51:	83 c4 04             	add    $0x4,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801d60:	8b 45 08             	mov    0x8(%ebp),%eax
  801d63:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801d69:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801d70:	00 00 00 
	b.result = 0;
  801d73:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d7a:	00 00 00 
	b.error = 1;
  801d7d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801d84:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801d87:	ff 75 10             	pushl  0x10(%ebp)
  801d8a:	ff 75 0c             	pushl  0xc(%ebp)
  801d8d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801d93:	50                   	push   %eax
  801d94:	68 22 1d 80 00       	push   $0x801d22
  801d99:	e8 bc e5 ff ff       	call   80035a <vprintfmt>
	if (b.idx > 0)
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801da8:	7e 0b                	jle    801db5 <vfprintf+0x5e>
		writebuf(&b);
  801daa:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801db0:	e8 2e ff ff ff       	call   801ce3 <writebuf>

	return (b.result ? b.result : b.error);
  801db5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801dcc:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801dcf:	50                   	push   %eax
  801dd0:	ff 75 0c             	pushl  0xc(%ebp)
  801dd3:	ff 75 08             	pushl  0x8(%ebp)
  801dd6:	e8 7c ff ff ff       	call   801d57 <vfprintf>
	va_end(ap);

	return cnt;
}
  801ddb:	c9                   	leave  
  801ddc:	c3                   	ret    

00801ddd <printf>:

int
printf(const char *fmt, ...)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801de3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801de6:	50                   	push   %eax
  801de7:	ff 75 08             	pushl  0x8(%ebp)
  801dea:	6a 01                	push   $0x1
  801dec:	e8 66 ff ff ff       	call   801d57 <vfprintf>
	va_end(ap);

	return cnt;
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	ff 75 08             	pushl  0x8(%ebp)
  801e01:	e8 d6 f6 ff ff       	call   8014dc <fd2data>
  801e06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e08:	83 c4 08             	add    $0x8,%esp
  801e0b:	68 27 2d 80 00       	push   $0x802d27
  801e10:	53                   	push   %ebx
  801e11:	e8 92 e9 ff ff       	call   8007a8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e16:	8b 46 04             	mov    0x4(%esi),%eax
  801e19:	2b 06                	sub    (%esi),%eax
  801e1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e28:	00 00 00 
	stat->st_dev = &devpipe;
  801e2b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801e32:	30 80 00 
	return 0;
}
  801e35:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	53                   	push   %ebx
  801e45:	83 ec 0c             	sub    $0xc,%esp
  801e48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e4b:	53                   	push   %ebx
  801e4c:	6a 00                	push   $0x0
  801e4e:	e8 dd ed ff ff       	call   800c30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e53:	89 1c 24             	mov    %ebx,(%esp)
  801e56:	e8 81 f6 ff ff       	call   8014dc <fd2data>
  801e5b:	83 c4 08             	add    $0x8,%esp
  801e5e:	50                   	push   %eax
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 ca ed ff ff       	call   800c30 <sys_page_unmap>
}
  801e66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	57                   	push   %edi
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	83 ec 1c             	sub    $0x1c,%esp
  801e74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e77:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e79:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7e:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	ff 75 e0             	pushl  -0x20(%ebp)
  801e8a:	e8 43 06 00 00       	call   8024d2 <pageref>
  801e8f:	89 c3                	mov    %eax,%ebx
  801e91:	89 3c 24             	mov    %edi,(%esp)
  801e94:	e8 39 06 00 00       	call   8024d2 <pageref>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	39 c3                	cmp    %eax,%ebx
  801e9e:	0f 94 c1             	sete   %cl
  801ea1:	0f b6 c9             	movzbl %cl,%ecx
  801ea4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ea7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ead:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801eb3:	39 ce                	cmp    %ecx,%esi
  801eb5:	74 1e                	je     801ed5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801eb7:	39 c3                	cmp    %eax,%ebx
  801eb9:	75 be                	jne    801e79 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ebb:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801ec1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ec4:	50                   	push   %eax
  801ec5:	56                   	push   %esi
  801ec6:	68 2e 2d 80 00       	push   $0x802d2e
  801ecb:	e8 53 e3 ff ff       	call   800223 <cprintf>
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	eb a4                	jmp    801e79 <_pipeisclosed+0xe>
	}
}
  801ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	57                   	push   %edi
  801ee4:	56                   	push   %esi
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 28             	sub    $0x28,%esp
  801ee9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801eec:	56                   	push   %esi
  801eed:	e8 ea f5 ff ff       	call   8014dc <fd2data>
  801ef2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	bf 00 00 00 00       	mov    $0x0,%edi
  801efc:	eb 4b                	jmp    801f49 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801efe:	89 da                	mov    %ebx,%edx
  801f00:	89 f0                	mov    %esi,%eax
  801f02:	e8 64 ff ff ff       	call   801e6b <_pipeisclosed>
  801f07:	85 c0                	test   %eax,%eax
  801f09:	75 48                	jne    801f53 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f0b:	e8 7c ec ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f10:	8b 43 04             	mov    0x4(%ebx),%eax
  801f13:	8b 0b                	mov    (%ebx),%ecx
  801f15:	8d 51 20             	lea    0x20(%ecx),%edx
  801f18:	39 d0                	cmp    %edx,%eax
  801f1a:	73 e2                	jae    801efe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f1f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f23:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f26:	89 c2                	mov    %eax,%edx
  801f28:	c1 fa 1f             	sar    $0x1f,%edx
  801f2b:	89 d1                	mov    %edx,%ecx
  801f2d:	c1 e9 1b             	shr    $0x1b,%ecx
  801f30:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f33:	83 e2 1f             	and    $0x1f,%edx
  801f36:	29 ca                	sub    %ecx,%edx
  801f38:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f3c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f40:	83 c0 01             	add    $0x1,%eax
  801f43:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f46:	83 c7 01             	add    $0x1,%edi
  801f49:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f4c:	75 c2                	jne    801f10 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801f51:	eb 05                	jmp    801f58 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	57                   	push   %edi
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
  801f66:	83 ec 18             	sub    $0x18,%esp
  801f69:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f6c:	57                   	push   %edi
  801f6d:	e8 6a f5 ff ff       	call   8014dc <fd2data>
  801f72:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f7c:	eb 3d                	jmp    801fbb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f7e:	85 db                	test   %ebx,%ebx
  801f80:	74 04                	je     801f86 <devpipe_read+0x26>
				return i;
  801f82:	89 d8                	mov    %ebx,%eax
  801f84:	eb 44                	jmp    801fca <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f86:	89 f2                	mov    %esi,%edx
  801f88:	89 f8                	mov    %edi,%eax
  801f8a:	e8 dc fe ff ff       	call   801e6b <_pipeisclosed>
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	75 32                	jne    801fc5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f93:	e8 f4 eb ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f98:	8b 06                	mov    (%esi),%eax
  801f9a:	3b 46 04             	cmp    0x4(%esi),%eax
  801f9d:	74 df                	je     801f7e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f9f:	99                   	cltd   
  801fa0:	c1 ea 1b             	shr    $0x1b,%edx
  801fa3:	01 d0                	add    %edx,%eax
  801fa5:	83 e0 1f             	and    $0x1f,%eax
  801fa8:	29 d0                	sub    %edx,%eax
  801faa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801faf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fb5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb8:	83 c3 01             	add    $0x1,%ebx
  801fbb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fbe:	75 d8                	jne    801f98 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc3:	eb 05                	jmp    801fca <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
  801fd7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdd:	50                   	push   %eax
  801fde:	e8 10 f5 ff ff       	call   8014f3 <fd_alloc>
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	89 c2                	mov    %eax,%edx
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	0f 88 2c 01 00 00    	js     80211c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff0:	83 ec 04             	sub    $0x4,%esp
  801ff3:	68 07 04 00 00       	push   $0x407
  801ff8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 a9 eb ff ff       	call   800bab <sys_page_alloc>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	89 c2                	mov    %eax,%edx
  802007:	85 c0                	test   %eax,%eax
  802009:	0f 88 0d 01 00 00    	js     80211c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80200f:	83 ec 0c             	sub    $0xc,%esp
  802012:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802015:	50                   	push   %eax
  802016:	e8 d8 f4 ff ff       	call   8014f3 <fd_alloc>
  80201b:	89 c3                	mov    %eax,%ebx
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	85 c0                	test   %eax,%eax
  802022:	0f 88 e2 00 00 00    	js     80210a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802028:	83 ec 04             	sub    $0x4,%esp
  80202b:	68 07 04 00 00       	push   $0x407
  802030:	ff 75 f0             	pushl  -0x10(%ebp)
  802033:	6a 00                	push   $0x0
  802035:	e8 71 eb ff ff       	call   800bab <sys_page_alloc>
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	85 c0                	test   %eax,%eax
  802041:	0f 88 c3 00 00 00    	js     80210a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802047:	83 ec 0c             	sub    $0xc,%esp
  80204a:	ff 75 f4             	pushl  -0xc(%ebp)
  80204d:	e8 8a f4 ff ff       	call   8014dc <fd2data>
  802052:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802054:	83 c4 0c             	add    $0xc,%esp
  802057:	68 07 04 00 00       	push   $0x407
  80205c:	50                   	push   %eax
  80205d:	6a 00                	push   $0x0
  80205f:	e8 47 eb ff ff       	call   800bab <sys_page_alloc>
  802064:	89 c3                	mov    %eax,%ebx
  802066:	83 c4 10             	add    $0x10,%esp
  802069:	85 c0                	test   %eax,%eax
  80206b:	0f 88 89 00 00 00    	js     8020fa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802071:	83 ec 0c             	sub    $0xc,%esp
  802074:	ff 75 f0             	pushl  -0x10(%ebp)
  802077:	e8 60 f4 ff ff       	call   8014dc <fd2data>
  80207c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802083:	50                   	push   %eax
  802084:	6a 00                	push   $0x0
  802086:	56                   	push   %esi
  802087:	6a 00                	push   $0x0
  802089:	e8 60 eb ff ff       	call   800bee <sys_page_map>
  80208e:	89 c3                	mov    %eax,%ebx
  802090:	83 c4 20             	add    $0x20,%esp
  802093:	85 c0                	test   %eax,%eax
  802095:	78 55                	js     8020ec <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802097:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80209d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020ac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020c1:	83 ec 0c             	sub    $0xc,%esp
  8020c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c7:	e8 00 f4 ff ff       	call   8014cc <fd2num>
  8020cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020d1:	83 c4 04             	add    $0x4,%esp
  8020d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d7:	e8 f0 f3 ff ff       	call   8014cc <fd2num>
  8020dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020df:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8020ea:	eb 30                	jmp    80211c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020ec:	83 ec 08             	sub    $0x8,%esp
  8020ef:	56                   	push   %esi
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 39 eb ff ff       	call   800c30 <sys_page_unmap>
  8020f7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020fa:	83 ec 08             	sub    $0x8,%esp
  8020fd:	ff 75 f0             	pushl  -0x10(%ebp)
  802100:	6a 00                	push   $0x0
  802102:	e8 29 eb ff ff       	call   800c30 <sys_page_unmap>
  802107:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80210a:	83 ec 08             	sub    $0x8,%esp
  80210d:	ff 75 f4             	pushl  -0xc(%ebp)
  802110:	6a 00                	push   $0x0
  802112:	e8 19 eb ff ff       	call   800c30 <sys_page_unmap>
  802117:	83 c4 10             	add    $0x10,%esp
  80211a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80211c:	89 d0                	mov    %edx,%eax
  80211e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802121:	5b                   	pop    %ebx
  802122:	5e                   	pop    %esi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80212b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212e:	50                   	push   %eax
  80212f:	ff 75 08             	pushl  0x8(%ebp)
  802132:	e8 0b f4 ff ff       	call   801542 <fd_lookup>
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	85 c0                	test   %eax,%eax
  80213c:	78 18                	js     802156 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80213e:	83 ec 0c             	sub    $0xc,%esp
  802141:	ff 75 f4             	pushl  -0xc(%ebp)
  802144:	e8 93 f3 ff ff       	call   8014dc <fd2data>
	return _pipeisclosed(fd, p);
  802149:	89 c2                	mov    %eax,%edx
  80214b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214e:	e8 18 fd ff ff       	call   801e6b <_pipeisclosed>
  802153:	83 c4 10             	add    $0x10,%esp
}
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    

00802162 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802168:	68 46 2d 80 00       	push   $0x802d46
  80216d:	ff 75 0c             	pushl  0xc(%ebp)
  802170:	e8 33 e6 ff ff       	call   8007a8 <strcpy>
	return 0;
}
  802175:	b8 00 00 00 00       	mov    $0x0,%eax
  80217a:	c9                   	leave  
  80217b:	c3                   	ret    

0080217c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	57                   	push   %edi
  802180:	56                   	push   %esi
  802181:	53                   	push   %ebx
  802182:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802188:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80218d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802193:	eb 2d                	jmp    8021c2 <devcons_write+0x46>
		m = n - tot;
  802195:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802198:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80219a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80219d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021a2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021a5:	83 ec 04             	sub    $0x4,%esp
  8021a8:	53                   	push   %ebx
  8021a9:	03 45 0c             	add    0xc(%ebp),%eax
  8021ac:	50                   	push   %eax
  8021ad:	57                   	push   %edi
  8021ae:	e8 87 e7 ff ff       	call   80093a <memmove>
		sys_cputs(buf, m);
  8021b3:	83 c4 08             	add    $0x8,%esp
  8021b6:	53                   	push   %ebx
  8021b7:	57                   	push   %edi
  8021b8:	e8 32 e9 ff ff       	call   800aef <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021bd:	01 de                	add    %ebx,%esi
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	89 f0                	mov    %esi,%eax
  8021c4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021c7:	72 cc                	jb     802195 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cc:	5b                   	pop    %ebx
  8021cd:	5e                   	pop    %esi
  8021ce:	5f                   	pop    %edi
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    

008021d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	83 ec 08             	sub    $0x8,%esp
  8021d7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021e0:	74 2a                	je     80220c <devcons_read+0x3b>
  8021e2:	eb 05                	jmp    8021e9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021e4:	e8 a3 e9 ff ff       	call   800b8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021e9:	e8 1f e9 ff ff       	call   800b0d <sys_cgetc>
  8021ee:	85 c0                	test   %eax,%eax
  8021f0:	74 f2                	je     8021e4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	78 16                	js     80220c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021f6:	83 f8 04             	cmp    $0x4,%eax
  8021f9:	74 0c                	je     802207 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021fe:	88 02                	mov    %al,(%edx)
	return 1;
  802200:	b8 01 00 00 00       	mov    $0x1,%eax
  802205:	eb 05                	jmp    80220c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802207:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80220c:	c9                   	leave  
  80220d:	c3                   	ret    

0080220e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802214:	8b 45 08             	mov    0x8(%ebp),%eax
  802217:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80221a:	6a 01                	push   $0x1
  80221c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80221f:	50                   	push   %eax
  802220:	e8 ca e8 ff ff       	call   800aef <sys_cputs>
}
  802225:	83 c4 10             	add    $0x10,%esp
  802228:	c9                   	leave  
  802229:	c3                   	ret    

0080222a <getchar>:

int
getchar(void)
{
  80222a:	55                   	push   %ebp
  80222b:	89 e5                	mov    %esp,%ebp
  80222d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802230:	6a 01                	push   $0x1
  802232:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802235:	50                   	push   %eax
  802236:	6a 00                	push   $0x0
  802238:	e8 6e f5 ff ff       	call   8017ab <read>
	if (r < 0)
  80223d:	83 c4 10             	add    $0x10,%esp
  802240:	85 c0                	test   %eax,%eax
  802242:	78 0f                	js     802253 <getchar+0x29>
		return r;
	if (r < 1)
  802244:	85 c0                	test   %eax,%eax
  802246:	7e 06                	jle    80224e <getchar+0x24>
		return -E_EOF;
	return c;
  802248:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80224c:	eb 05                	jmp    802253 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80224e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802253:	c9                   	leave  
  802254:	c3                   	ret    

00802255 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80225b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225e:	50                   	push   %eax
  80225f:	ff 75 08             	pushl  0x8(%ebp)
  802262:	e8 db f2 ff ff       	call   801542 <fd_lookup>
  802267:	83 c4 10             	add    $0x10,%esp
  80226a:	85 c0                	test   %eax,%eax
  80226c:	78 11                	js     80227f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802271:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802277:	39 10                	cmp    %edx,(%eax)
  802279:	0f 94 c0             	sete   %al
  80227c:	0f b6 c0             	movzbl %al,%eax
}
  80227f:	c9                   	leave  
  802280:	c3                   	ret    

00802281 <opencons>:

int
opencons(void)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228a:	50                   	push   %eax
  80228b:	e8 63 f2 ff ff       	call   8014f3 <fd_alloc>
  802290:	83 c4 10             	add    $0x10,%esp
		return r;
  802293:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802295:	85 c0                	test   %eax,%eax
  802297:	78 3e                	js     8022d7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802299:	83 ec 04             	sub    $0x4,%esp
  80229c:	68 07 04 00 00       	push   $0x407
  8022a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a4:	6a 00                	push   $0x0
  8022a6:	e8 00 e9 ff ff       	call   800bab <sys_page_alloc>
  8022ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8022ae:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	78 23                	js     8022d7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022b4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c9:	83 ec 0c             	sub    $0xc,%esp
  8022cc:	50                   	push   %eax
  8022cd:	e8 fa f1 ff ff       	call   8014cc <fd2num>
  8022d2:	89 c2                	mov    %eax,%edx
  8022d4:	83 c4 10             	add    $0x10,%esp
}
  8022d7:	89 d0                	mov    %edx,%eax
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022e9:	e8 7f e8 ff ff       	call   800b6d <sys_getenvid>
  8022ee:	83 ec 0c             	sub    $0xc,%esp
  8022f1:	ff 75 0c             	pushl  0xc(%ebp)
  8022f4:	ff 75 08             	pushl  0x8(%ebp)
  8022f7:	56                   	push   %esi
  8022f8:	50                   	push   %eax
  8022f9:	68 54 2d 80 00       	push   $0x802d54
  8022fe:	e8 20 df ff ff       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802303:	83 c4 18             	add    $0x18,%esp
  802306:	53                   	push   %ebx
  802307:	ff 75 10             	pushl  0x10(%ebp)
  80230a:	e8 c3 de ff ff       	call   8001d2 <vcprintf>
	cprintf("\n");
  80230f:	c7 04 24 a6 2b 80 00 	movl   $0x802ba6,(%esp)
  802316:	e8 08 df ff ff       	call   800223 <cprintf>
  80231b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80231e:	cc                   	int3   
  80231f:	eb fd                	jmp    80231e <_panic+0x43>

00802321 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802327:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80232e:	75 2a                	jne    80235a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802330:	83 ec 04             	sub    $0x4,%esp
  802333:	6a 07                	push   $0x7
  802335:	68 00 f0 bf ee       	push   $0xeebff000
  80233a:	6a 00                	push   $0x0
  80233c:	e8 6a e8 ff ff       	call   800bab <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802341:	83 c4 10             	add    $0x10,%esp
  802344:	85 c0                	test   %eax,%eax
  802346:	79 12                	jns    80235a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802348:	50                   	push   %eax
  802349:	68 d8 2b 80 00       	push   $0x802bd8
  80234e:	6a 23                	push   $0x23
  802350:	68 78 2d 80 00       	push   $0x802d78
  802355:	e8 81 ff ff ff       	call   8022db <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80235a:	8b 45 08             	mov    0x8(%ebp),%eax
  80235d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802362:	83 ec 08             	sub    $0x8,%esp
  802365:	68 8c 23 80 00       	push   $0x80238c
  80236a:	6a 00                	push   $0x0
  80236c:	e8 85 e9 ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802371:	83 c4 10             	add    $0x10,%esp
  802374:	85 c0                	test   %eax,%eax
  802376:	79 12                	jns    80238a <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802378:	50                   	push   %eax
  802379:	68 d8 2b 80 00       	push   $0x802bd8
  80237e:	6a 2c                	push   $0x2c
  802380:	68 78 2d 80 00       	push   $0x802d78
  802385:	e8 51 ff ff ff       	call   8022db <_panic>
	}
}
  80238a:	c9                   	leave  
  80238b:	c3                   	ret    

0080238c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80238c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80238d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802392:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802394:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802397:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80239b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8023a0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8023a4:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8023a6:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8023a9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8023aa:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8023ad:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8023ae:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023af:	c3                   	ret    

008023b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	56                   	push   %esi
  8023b4:	53                   	push   %ebx
  8023b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8023b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8023be:	85 c0                	test   %eax,%eax
  8023c0:	75 12                	jne    8023d4 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8023c2:	83 ec 0c             	sub    $0xc,%esp
  8023c5:	68 00 00 c0 ee       	push   $0xeec00000
  8023ca:	e8 8c e9 ff ff       	call   800d5b <sys_ipc_recv>
  8023cf:	83 c4 10             	add    $0x10,%esp
  8023d2:	eb 0c                	jmp    8023e0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8023d4:	83 ec 0c             	sub    $0xc,%esp
  8023d7:	50                   	push   %eax
  8023d8:	e8 7e e9 ff ff       	call   800d5b <sys_ipc_recv>
  8023dd:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8023e0:	85 f6                	test   %esi,%esi
  8023e2:	0f 95 c1             	setne  %cl
  8023e5:	85 db                	test   %ebx,%ebx
  8023e7:	0f 95 c2             	setne  %dl
  8023ea:	84 d1                	test   %dl,%cl
  8023ec:	74 09                	je     8023f7 <ipc_recv+0x47>
  8023ee:	89 c2                	mov    %eax,%edx
  8023f0:	c1 ea 1f             	shr    $0x1f,%edx
  8023f3:	84 d2                	test   %dl,%dl
  8023f5:	75 2d                	jne    802424 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8023f7:	85 f6                	test   %esi,%esi
  8023f9:	74 0d                	je     802408 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8023fb:	a1 04 40 80 00       	mov    0x804004,%eax
  802400:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802406:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802408:	85 db                	test   %ebx,%ebx
  80240a:	74 0d                	je     802419 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80240c:	a1 04 40 80 00       	mov    0x804004,%eax
  802411:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802417:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802419:	a1 04 40 80 00       	mov    0x804004,%eax
  80241e:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802424:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802427:	5b                   	pop    %ebx
  802428:	5e                   	pop    %esi
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    

0080242b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	57                   	push   %edi
  80242f:	56                   	push   %esi
  802430:	53                   	push   %ebx
  802431:	83 ec 0c             	sub    $0xc,%esp
  802434:	8b 7d 08             	mov    0x8(%ebp),%edi
  802437:	8b 75 0c             	mov    0xc(%ebp),%esi
  80243a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80243d:	85 db                	test   %ebx,%ebx
  80243f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802444:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802447:	ff 75 14             	pushl  0x14(%ebp)
  80244a:	53                   	push   %ebx
  80244b:	56                   	push   %esi
  80244c:	57                   	push   %edi
  80244d:	e8 e6 e8 ff ff       	call   800d38 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802452:	89 c2                	mov    %eax,%edx
  802454:	c1 ea 1f             	shr    $0x1f,%edx
  802457:	83 c4 10             	add    $0x10,%esp
  80245a:	84 d2                	test   %dl,%dl
  80245c:	74 17                	je     802475 <ipc_send+0x4a>
  80245e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802461:	74 12                	je     802475 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802463:	50                   	push   %eax
  802464:	68 86 2d 80 00       	push   $0x802d86
  802469:	6a 47                	push   $0x47
  80246b:	68 94 2d 80 00       	push   $0x802d94
  802470:	e8 66 fe ff ff       	call   8022db <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802475:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802478:	75 07                	jne    802481 <ipc_send+0x56>
			sys_yield();
  80247a:	e8 0d e7 ff ff       	call   800b8c <sys_yield>
  80247f:	eb c6                	jmp    802447 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802481:	85 c0                	test   %eax,%eax
  802483:	75 c2                	jne    802447 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802485:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    

0080248d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80248d:	55                   	push   %ebp
  80248e:	89 e5                	mov    %esp,%ebp
  802490:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802493:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802498:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80249e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024a4:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8024aa:	39 ca                	cmp    %ecx,%edx
  8024ac:	75 13                	jne    8024c1 <ipc_find_env+0x34>
			return envs[i].env_id;
  8024ae:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8024b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024b9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8024bf:	eb 0f                	jmp    8024d0 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024c1:	83 c0 01             	add    $0x1,%eax
  8024c4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024c9:	75 cd                	jne    802498 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    

008024d2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024d2:	55                   	push   %ebp
  8024d3:	89 e5                	mov    %esp,%ebp
  8024d5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024d8:	89 d0                	mov    %edx,%eax
  8024da:	c1 e8 16             	shr    $0x16,%eax
  8024dd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024e4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024e9:	f6 c1 01             	test   $0x1,%cl
  8024ec:	74 1d                	je     80250b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024ee:	c1 ea 0c             	shr    $0xc,%edx
  8024f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024f8:	f6 c2 01             	test   $0x1,%dl
  8024fb:	74 0e                	je     80250b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024fd:	c1 ea 0c             	shr    $0xc,%edx
  802500:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802507:	ef 
  802508:	0f b7 c0             	movzwl %ax,%eax
}
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    
  80250d:	66 90                	xchg   %ax,%ax
  80250f:	90                   	nop

00802510 <__udivdi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80251b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80251f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802523:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802527:	85 f6                	test   %esi,%esi
  802529:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80252d:	89 ca                	mov    %ecx,%edx
  80252f:	89 f8                	mov    %edi,%eax
  802531:	75 3d                	jne    802570 <__udivdi3+0x60>
  802533:	39 cf                	cmp    %ecx,%edi
  802535:	0f 87 c5 00 00 00    	ja     802600 <__udivdi3+0xf0>
  80253b:	85 ff                	test   %edi,%edi
  80253d:	89 fd                	mov    %edi,%ebp
  80253f:	75 0b                	jne    80254c <__udivdi3+0x3c>
  802541:	b8 01 00 00 00       	mov    $0x1,%eax
  802546:	31 d2                	xor    %edx,%edx
  802548:	f7 f7                	div    %edi
  80254a:	89 c5                	mov    %eax,%ebp
  80254c:	89 c8                	mov    %ecx,%eax
  80254e:	31 d2                	xor    %edx,%edx
  802550:	f7 f5                	div    %ebp
  802552:	89 c1                	mov    %eax,%ecx
  802554:	89 d8                	mov    %ebx,%eax
  802556:	89 cf                	mov    %ecx,%edi
  802558:	f7 f5                	div    %ebp
  80255a:	89 c3                	mov    %eax,%ebx
  80255c:	89 d8                	mov    %ebx,%eax
  80255e:	89 fa                	mov    %edi,%edx
  802560:	83 c4 1c             	add    $0x1c,%esp
  802563:	5b                   	pop    %ebx
  802564:	5e                   	pop    %esi
  802565:	5f                   	pop    %edi
  802566:	5d                   	pop    %ebp
  802567:	c3                   	ret    
  802568:	90                   	nop
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	39 ce                	cmp    %ecx,%esi
  802572:	77 74                	ja     8025e8 <__udivdi3+0xd8>
  802574:	0f bd fe             	bsr    %esi,%edi
  802577:	83 f7 1f             	xor    $0x1f,%edi
  80257a:	0f 84 98 00 00 00    	je     802618 <__udivdi3+0x108>
  802580:	bb 20 00 00 00       	mov    $0x20,%ebx
  802585:	89 f9                	mov    %edi,%ecx
  802587:	89 c5                	mov    %eax,%ebp
  802589:	29 fb                	sub    %edi,%ebx
  80258b:	d3 e6                	shl    %cl,%esi
  80258d:	89 d9                	mov    %ebx,%ecx
  80258f:	d3 ed                	shr    %cl,%ebp
  802591:	89 f9                	mov    %edi,%ecx
  802593:	d3 e0                	shl    %cl,%eax
  802595:	09 ee                	or     %ebp,%esi
  802597:	89 d9                	mov    %ebx,%ecx
  802599:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80259d:	89 d5                	mov    %edx,%ebp
  80259f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025a3:	d3 ed                	shr    %cl,%ebp
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	d3 e2                	shl    %cl,%edx
  8025a9:	89 d9                	mov    %ebx,%ecx
  8025ab:	d3 e8                	shr    %cl,%eax
  8025ad:	09 c2                	or     %eax,%edx
  8025af:	89 d0                	mov    %edx,%eax
  8025b1:	89 ea                	mov    %ebp,%edx
  8025b3:	f7 f6                	div    %esi
  8025b5:	89 d5                	mov    %edx,%ebp
  8025b7:	89 c3                	mov    %eax,%ebx
  8025b9:	f7 64 24 0c          	mull   0xc(%esp)
  8025bd:	39 d5                	cmp    %edx,%ebp
  8025bf:	72 10                	jb     8025d1 <__udivdi3+0xc1>
  8025c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	d3 e6                	shl    %cl,%esi
  8025c9:	39 c6                	cmp    %eax,%esi
  8025cb:	73 07                	jae    8025d4 <__udivdi3+0xc4>
  8025cd:	39 d5                	cmp    %edx,%ebp
  8025cf:	75 03                	jne    8025d4 <__udivdi3+0xc4>
  8025d1:	83 eb 01             	sub    $0x1,%ebx
  8025d4:	31 ff                	xor    %edi,%edi
  8025d6:	89 d8                	mov    %ebx,%eax
  8025d8:	89 fa                	mov    %edi,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	31 ff                	xor    %edi,%edi
  8025ea:	31 db                	xor    %ebx,%ebx
  8025ec:	89 d8                	mov    %ebx,%eax
  8025ee:	89 fa                	mov    %edi,%edx
  8025f0:	83 c4 1c             	add    $0x1c,%esp
  8025f3:	5b                   	pop    %ebx
  8025f4:	5e                   	pop    %esi
  8025f5:	5f                   	pop    %edi
  8025f6:	5d                   	pop    %ebp
  8025f7:	c3                   	ret    
  8025f8:	90                   	nop
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	89 d8                	mov    %ebx,%eax
  802602:	f7 f7                	div    %edi
  802604:	31 ff                	xor    %edi,%edi
  802606:	89 c3                	mov    %eax,%ebx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 fa                	mov    %edi,%edx
  80260c:	83 c4 1c             	add    $0x1c,%esp
  80260f:	5b                   	pop    %ebx
  802610:	5e                   	pop    %esi
  802611:	5f                   	pop    %edi
  802612:	5d                   	pop    %ebp
  802613:	c3                   	ret    
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	39 ce                	cmp    %ecx,%esi
  80261a:	72 0c                	jb     802628 <__udivdi3+0x118>
  80261c:	31 db                	xor    %ebx,%ebx
  80261e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802622:	0f 87 34 ff ff ff    	ja     80255c <__udivdi3+0x4c>
  802628:	bb 01 00 00 00       	mov    $0x1,%ebx
  80262d:	e9 2a ff ff ff       	jmp    80255c <__udivdi3+0x4c>
  802632:	66 90                	xchg   %ax,%ax
  802634:	66 90                	xchg   %ax,%ax
  802636:	66 90                	xchg   %ax,%ax
  802638:	66 90                	xchg   %ax,%ax
  80263a:	66 90                	xchg   %ax,%ax
  80263c:	66 90                	xchg   %ax,%ax
  80263e:	66 90                	xchg   %ax,%ax

00802640 <__umoddi3>:
  802640:	55                   	push   %ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	53                   	push   %ebx
  802644:	83 ec 1c             	sub    $0x1c,%esp
  802647:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80264b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80264f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802653:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802657:	85 d2                	test   %edx,%edx
  802659:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80265d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802661:	89 f3                	mov    %esi,%ebx
  802663:	89 3c 24             	mov    %edi,(%esp)
  802666:	89 74 24 04          	mov    %esi,0x4(%esp)
  80266a:	75 1c                	jne    802688 <__umoddi3+0x48>
  80266c:	39 f7                	cmp    %esi,%edi
  80266e:	76 50                	jbe    8026c0 <__umoddi3+0x80>
  802670:	89 c8                	mov    %ecx,%eax
  802672:	89 f2                	mov    %esi,%edx
  802674:	f7 f7                	div    %edi
  802676:	89 d0                	mov    %edx,%eax
  802678:	31 d2                	xor    %edx,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	39 f2                	cmp    %esi,%edx
  80268a:	89 d0                	mov    %edx,%eax
  80268c:	77 52                	ja     8026e0 <__umoddi3+0xa0>
  80268e:	0f bd ea             	bsr    %edx,%ebp
  802691:	83 f5 1f             	xor    $0x1f,%ebp
  802694:	75 5a                	jne    8026f0 <__umoddi3+0xb0>
  802696:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80269a:	0f 82 e0 00 00 00    	jb     802780 <__umoddi3+0x140>
  8026a0:	39 0c 24             	cmp    %ecx,(%esp)
  8026a3:	0f 86 d7 00 00 00    	jbe    802780 <__umoddi3+0x140>
  8026a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026b1:	83 c4 1c             	add    $0x1c,%esp
  8026b4:	5b                   	pop    %ebx
  8026b5:	5e                   	pop    %esi
  8026b6:	5f                   	pop    %edi
  8026b7:	5d                   	pop    %ebp
  8026b8:	c3                   	ret    
  8026b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	85 ff                	test   %edi,%edi
  8026c2:	89 fd                	mov    %edi,%ebp
  8026c4:	75 0b                	jne    8026d1 <__umoddi3+0x91>
  8026c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026cb:	31 d2                	xor    %edx,%edx
  8026cd:	f7 f7                	div    %edi
  8026cf:	89 c5                	mov    %eax,%ebp
  8026d1:	89 f0                	mov    %esi,%eax
  8026d3:	31 d2                	xor    %edx,%edx
  8026d5:	f7 f5                	div    %ebp
  8026d7:	89 c8                	mov    %ecx,%eax
  8026d9:	f7 f5                	div    %ebp
  8026db:	89 d0                	mov    %edx,%eax
  8026dd:	eb 99                	jmp    802678 <__umoddi3+0x38>
  8026df:	90                   	nop
  8026e0:	89 c8                	mov    %ecx,%eax
  8026e2:	89 f2                	mov    %esi,%edx
  8026e4:	83 c4 1c             	add    $0x1c,%esp
  8026e7:	5b                   	pop    %ebx
  8026e8:	5e                   	pop    %esi
  8026e9:	5f                   	pop    %edi
  8026ea:	5d                   	pop    %ebp
  8026eb:	c3                   	ret    
  8026ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	8b 34 24             	mov    (%esp),%esi
  8026f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026f8:	89 e9                	mov    %ebp,%ecx
  8026fa:	29 ef                	sub    %ebp,%edi
  8026fc:	d3 e0                	shl    %cl,%eax
  8026fe:	89 f9                	mov    %edi,%ecx
  802700:	89 f2                	mov    %esi,%edx
  802702:	d3 ea                	shr    %cl,%edx
  802704:	89 e9                	mov    %ebp,%ecx
  802706:	09 c2                	or     %eax,%edx
  802708:	89 d8                	mov    %ebx,%eax
  80270a:	89 14 24             	mov    %edx,(%esp)
  80270d:	89 f2                	mov    %esi,%edx
  80270f:	d3 e2                	shl    %cl,%edx
  802711:	89 f9                	mov    %edi,%ecx
  802713:	89 54 24 04          	mov    %edx,0x4(%esp)
  802717:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80271b:	d3 e8                	shr    %cl,%eax
  80271d:	89 e9                	mov    %ebp,%ecx
  80271f:	89 c6                	mov    %eax,%esi
  802721:	d3 e3                	shl    %cl,%ebx
  802723:	89 f9                	mov    %edi,%ecx
  802725:	89 d0                	mov    %edx,%eax
  802727:	d3 e8                	shr    %cl,%eax
  802729:	89 e9                	mov    %ebp,%ecx
  80272b:	09 d8                	or     %ebx,%eax
  80272d:	89 d3                	mov    %edx,%ebx
  80272f:	89 f2                	mov    %esi,%edx
  802731:	f7 34 24             	divl   (%esp)
  802734:	89 d6                	mov    %edx,%esi
  802736:	d3 e3                	shl    %cl,%ebx
  802738:	f7 64 24 04          	mull   0x4(%esp)
  80273c:	39 d6                	cmp    %edx,%esi
  80273e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802742:	89 d1                	mov    %edx,%ecx
  802744:	89 c3                	mov    %eax,%ebx
  802746:	72 08                	jb     802750 <__umoddi3+0x110>
  802748:	75 11                	jne    80275b <__umoddi3+0x11b>
  80274a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80274e:	73 0b                	jae    80275b <__umoddi3+0x11b>
  802750:	2b 44 24 04          	sub    0x4(%esp),%eax
  802754:	1b 14 24             	sbb    (%esp),%edx
  802757:	89 d1                	mov    %edx,%ecx
  802759:	89 c3                	mov    %eax,%ebx
  80275b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80275f:	29 da                	sub    %ebx,%edx
  802761:	19 ce                	sbb    %ecx,%esi
  802763:	89 f9                	mov    %edi,%ecx
  802765:	89 f0                	mov    %esi,%eax
  802767:	d3 e0                	shl    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	d3 ea                	shr    %cl,%edx
  80276d:	89 e9                	mov    %ebp,%ecx
  80276f:	d3 ee                	shr    %cl,%esi
  802771:	09 d0                	or     %edx,%eax
  802773:	89 f2                	mov    %esi,%edx
  802775:	83 c4 1c             	add    $0x1c,%esp
  802778:	5b                   	pop    %ebx
  802779:	5e                   	pop    %esi
  80277a:	5f                   	pop    %edi
  80277b:	5d                   	pop    %ebp
  80277c:	c3                   	ret    
  80277d:	8d 76 00             	lea    0x0(%esi),%esi
  802780:	29 f9                	sub    %edi,%ecx
  802782:	19 d6                	sbb    %edx,%esi
  802784:	89 74 24 04          	mov    %esi,0x4(%esp)
  802788:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80278c:	e9 18 ff ff ff       	jmp    8026a9 <__umoddi3+0x69>
