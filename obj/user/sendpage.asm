
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 6b 01 00 00       	call   80019c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 23 0f 00 00       	call   800f61 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 29 13 00 00       	call   801385 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 60 25 80 00       	push   $0x802560
  80006c:	e8 41 02 00 00       	call   8002b2 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 7f 07 00 00       	call   8007fe <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 74 08 00 00       	call   800907 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 74 25 80 00       	push   $0x802574
  8000a2:	e8 0b 02 00 00       	call   8002b2 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 46 07 00 00       	call   8007fe <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 62 09 00 00       	call   800a31 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 20 13 00 00       	call   801400 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 b2 00 00 00       	jmp    80019a <umain+0x167>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8000f3:	83 ec 04             	sub    $0x4,%esp
  8000f6:	6a 07                	push   $0x7
  8000f8:	68 00 00 a0 00       	push   $0xa00000
  8000fd:	50                   	push   %eax
  8000fe:	e8 37 0b 00 00       	call   800c3a <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800103:	83 c4 04             	add    $0x4,%esp
  800106:	ff 35 04 30 80 00    	pushl  0x803004
  80010c:	e8 ed 06 00 00       	call   8007fe <strlen>
  800111:	83 c4 0c             	add    $0xc,%esp
  800114:	83 c0 01             	add    $0x1,%eax
  800117:	50                   	push   %eax
  800118:	ff 35 04 30 80 00    	pushl  0x803004
  80011e:	68 00 00 a0 00       	push   $0xa00000
  800123:	e8 09 09 00 00       	call   800a31 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800128:	6a 07                	push   $0x7
  80012a:	68 00 00 a0 00       	push   $0xa00000
  80012f:	6a 00                	push   $0x0
  800131:	ff 75 f4             	pushl  -0xc(%ebp)
  800134:	e8 c7 12 00 00       	call   801400 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800139:	83 c4 1c             	add    $0x1c,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	68 00 00 a0 00       	push   $0xa00000
  800143:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	e8 39 12 00 00       	call   801385 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80014c:	83 c4 0c             	add    $0xc,%esp
  80014f:	68 00 00 a0 00       	push   $0xa00000
  800154:	ff 75 f4             	pushl  -0xc(%ebp)
  800157:	68 60 25 80 00       	push   $0x802560
  80015c:	e8 51 01 00 00       	call   8002b2 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  800161:	83 c4 04             	add    $0x4,%esp
  800164:	ff 35 00 30 80 00    	pushl  0x803000
  80016a:	e8 8f 06 00 00       	call   8007fe <strlen>
  80016f:	83 c4 0c             	add    $0xc,%esp
  800172:	50                   	push   %eax
  800173:	ff 35 00 30 80 00    	pushl  0x803000
  800179:	68 00 00 a0 00       	push   $0xa00000
  80017e:	e8 84 07 00 00       	call   800907 <strncmp>
  800183:	83 c4 10             	add    $0x10,%esp
  800186:	85 c0                	test   %eax,%eax
  800188:	75 10                	jne    80019a <umain+0x167>
		cprintf("parent received correct message\n");
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	68 94 25 80 00       	push   $0x802594
  800192:	e8 1b 01 00 00       	call   8002b2 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp
	return;
}
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a7:	e8 50 0a 00 00       	call   800bfc <sys_getenvid>
  8001ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b1:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8001b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001bc:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c1:	85 db                	test   %ebx,%ebx
  8001c3:	7e 07                	jle    8001cc <libmain+0x30>
		binaryname = argv[0];
  8001c5:	8b 06                	mov    (%esi),%eax
  8001c7:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	e8 5d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d6:	e8 2a 00 00 00       	call   800205 <exit>
}
  8001db:	83 c4 10             	add    $0x10,%esp
  8001de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8001eb:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8001f0:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8001f2:	e8 05 0a 00 00       	call   800bfc <sys_getenvid>
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	50                   	push   %eax
  8001fb:	e8 4b 0c 00 00       	call   800e4b <sys_thread_free>
}
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80020b:	e8 65 14 00 00       	call   801675 <close_all>
	sys_env_destroy(0);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	6a 00                	push   $0x0
  800215:	e8 a1 09 00 00       	call   800bbb <sys_env_destroy>
}
  80021a:	83 c4 10             	add    $0x10,%esp
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	53                   	push   %ebx
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800229:	8b 13                	mov    (%ebx),%edx
  80022b:	8d 42 01             	lea    0x1(%edx),%eax
  80022e:	89 03                	mov    %eax,(%ebx)
  800230:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800233:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800237:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023c:	75 1a                	jne    800258 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023e:	83 ec 08             	sub    $0x8,%esp
  800241:	68 ff 00 00 00       	push   $0xff
  800246:	8d 43 08             	lea    0x8(%ebx),%eax
  800249:	50                   	push   %eax
  80024a:	e8 2f 09 00 00       	call   800b7e <sys_cputs>
		b->idx = 0;
  80024f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800255:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800258:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025f:	c9                   	leave  
  800260:	c3                   	ret    

00800261 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80026a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800271:	00 00 00 
	b.cnt = 0;
  800274:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027e:	ff 75 0c             	pushl  0xc(%ebp)
  800281:	ff 75 08             	pushl  0x8(%ebp)
  800284:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028a:	50                   	push   %eax
  80028b:	68 1f 02 80 00       	push   $0x80021f
  800290:	e8 54 01 00 00       	call   8003e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800295:	83 c4 08             	add    $0x8,%esp
  800298:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a4:	50                   	push   %eax
  8002a5:	e8 d4 08 00 00       	call   800b7e <sys_cputs>

	return b.cnt;
}
  8002aa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002bb:	50                   	push   %eax
  8002bc:	ff 75 08             	pushl  0x8(%ebp)
  8002bf:	e8 9d ff ff ff       	call   800261 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 1c             	sub    $0x1c,%esp
  8002cf:	89 c7                	mov    %eax,%edi
  8002d1:	89 d6                	mov    %edx,%esi
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ea:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ed:	39 d3                	cmp    %edx,%ebx
  8002ef:	72 05                	jb     8002f6 <printnum+0x30>
  8002f1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f4:	77 45                	ja     80033b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f6:	83 ec 0c             	sub    $0xc,%esp
  8002f9:	ff 75 18             	pushl  0x18(%ebp)
  8002fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ff:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800302:	53                   	push   %ebx
  800303:	ff 75 10             	pushl  0x10(%ebp)
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030c:	ff 75 e0             	pushl  -0x20(%ebp)
  80030f:	ff 75 dc             	pushl  -0x24(%ebp)
  800312:	ff 75 d8             	pushl  -0x28(%ebp)
  800315:	e8 a6 1f 00 00       	call   8022c0 <__udivdi3>
  80031a:	83 c4 18             	add    $0x18,%esp
  80031d:	52                   	push   %edx
  80031e:	50                   	push   %eax
  80031f:	89 f2                	mov    %esi,%edx
  800321:	89 f8                	mov    %edi,%eax
  800323:	e8 9e ff ff ff       	call   8002c6 <printnum>
  800328:	83 c4 20             	add    $0x20,%esp
  80032b:	eb 18                	jmp    800345 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	56                   	push   %esi
  800331:	ff 75 18             	pushl  0x18(%ebp)
  800334:	ff d7                	call   *%edi
  800336:	83 c4 10             	add    $0x10,%esp
  800339:	eb 03                	jmp    80033e <printnum+0x78>
  80033b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033e:	83 eb 01             	sub    $0x1,%ebx
  800341:	85 db                	test   %ebx,%ebx
  800343:	7f e8                	jg     80032d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	56                   	push   %esi
  800349:	83 ec 04             	sub    $0x4,%esp
  80034c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034f:	ff 75 e0             	pushl  -0x20(%ebp)
  800352:	ff 75 dc             	pushl  -0x24(%ebp)
  800355:	ff 75 d8             	pushl  -0x28(%ebp)
  800358:	e8 93 20 00 00       	call   8023f0 <__umoddi3>
  80035d:	83 c4 14             	add    $0x14,%esp
  800360:	0f be 80 0c 26 80 00 	movsbl 0x80260c(%eax),%eax
  800367:	50                   	push   %eax
  800368:	ff d7                	call   *%edi
}
  80036a:	83 c4 10             	add    $0x10,%esp
  80036d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800370:	5b                   	pop    %ebx
  800371:	5e                   	pop    %esi
  800372:	5f                   	pop    %edi
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800378:	83 fa 01             	cmp    $0x1,%edx
  80037b:	7e 0e                	jle    80038b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	8b 52 04             	mov    0x4(%edx),%edx
  800389:	eb 22                	jmp    8003ad <getuint+0x38>
	else if (lflag)
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 10                	je     80039f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	8d 4a 04             	lea    0x4(%edx),%ecx
  800394:	89 08                	mov    %ecx,(%eax)
  800396:	8b 02                	mov    (%edx),%eax
  800398:	ba 00 00 00 00       	mov    $0x0,%edx
  80039d:	eb 0e                	jmp    8003ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b9:	8b 10                	mov    (%eax),%edx
  8003bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003be:	73 0a                	jae    8003ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c3:	89 08                	mov    %ecx,(%eax)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	88 02                	mov    %al,(%edx)
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d5:	50                   	push   %eax
  8003d6:	ff 75 10             	pushl  0x10(%ebp)
  8003d9:	ff 75 0c             	pushl  0xc(%ebp)
  8003dc:	ff 75 08             	pushl  0x8(%ebp)
  8003df:	e8 05 00 00 00       	call   8003e9 <vprintfmt>
	va_end(ap);
}
  8003e4:	83 c4 10             	add    $0x10,%esp
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 2c             	sub    $0x2c,%esp
  8003f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fb:	eb 12                	jmp    80040f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	0f 84 89 03 00 00    	je     80078e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	53                   	push   %ebx
  800409:	50                   	push   %eax
  80040a:	ff d6                	call   *%esi
  80040c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040f:	83 c7 01             	add    $0x1,%edi
  800412:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800416:	83 f8 25             	cmp    $0x25,%eax
  800419:	75 e2                	jne    8003fd <vprintfmt+0x14>
  80041b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800434:	ba 00 00 00 00       	mov    $0x0,%edx
  800439:	eb 07                	jmp    800442 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8d 47 01             	lea    0x1(%edi),%eax
  800445:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800448:	0f b6 07             	movzbl (%edi),%eax
  80044b:	0f b6 c8             	movzbl %al,%ecx
  80044e:	83 e8 23             	sub    $0x23,%eax
  800451:	3c 55                	cmp    $0x55,%al
  800453:	0f 87 1a 03 00 00    	ja     800773 <vprintfmt+0x38a>
  800459:	0f b6 c0             	movzbl %al,%eax
  80045c:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800466:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046a:	eb d6                	jmp    800442 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800477:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800481:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800484:	83 fa 09             	cmp    $0x9,%edx
  800487:	77 39                	ja     8004c2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800489:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048c:	eb e9                	jmp    800477 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 48 04             	lea    0x4(%eax),%ecx
  800494:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800497:	8b 00                	mov    (%eax),%eax
  800499:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049f:	eb 27                	jmp    8004c8 <vprintfmt+0xdf>
  8004a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ab:	0f 49 c8             	cmovns %eax,%ecx
  8004ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b4:	eb 8c                	jmp    800442 <vprintfmt+0x59>
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c0:	eb 80                	jmp    800442 <vprintfmt+0x59>
  8004c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cc:	0f 89 70 ff ff ff    	jns    800442 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004df:	e9 5e ff ff ff       	jmp    800442 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ea:	e9 53 ff ff ff       	jmp    800442 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 50 04             	lea    0x4(%eax),%edx
  8004f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	ff 30                	pushl  (%eax)
  8004fe:	ff d6                	call   *%esi
			break;
  800500:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800506:	e9 04 ff ff ff       	jmp    80040f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 04             	lea    0x4(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 00                	mov    (%eax),%eax
  800516:	99                   	cltd   
  800517:	31 d0                	xor    %edx,%eax
  800519:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051b:	83 f8 0f             	cmp    $0xf,%eax
  80051e:	7f 0b                	jg     80052b <vprintfmt+0x142>
  800520:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	75 18                	jne    800543 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052b:	50                   	push   %eax
  80052c:	68 24 26 80 00       	push   $0x802624
  800531:	53                   	push   %ebx
  800532:	56                   	push   %esi
  800533:	e8 94 fe ff ff       	call   8003cc <printfmt>
  800538:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053e:	e9 cc fe ff ff       	jmp    80040f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800543:	52                   	push   %edx
  800544:	68 75 2a 80 00       	push   $0x802a75
  800549:	53                   	push   %ebx
  80054a:	56                   	push   %esi
  80054b:	e8 7c fe ff ff       	call   8003cc <printfmt>
  800550:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800556:	e9 b4 fe ff ff       	jmp    80040f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 50 04             	lea    0x4(%eax),%edx
  800561:	89 55 14             	mov    %edx,0x14(%ebp)
  800564:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800566:	85 ff                	test   %edi,%edi
  800568:	b8 1d 26 80 00       	mov    $0x80261d,%eax
  80056d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800570:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800574:	0f 8e 94 00 00 00    	jle    80060e <vprintfmt+0x225>
  80057a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057e:	0f 84 98 00 00 00    	je     80061c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	ff 75 d0             	pushl  -0x30(%ebp)
  80058a:	57                   	push   %edi
  80058b:	e8 86 02 00 00       	call   800816 <strnlen>
  800590:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800593:	29 c1                	sub    %eax,%ecx
  800595:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800598:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	eb 0f                	jmp    8005b8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b2:	83 ef 01             	sub    $0x1,%edi
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	85 ff                	test   %edi,%edi
  8005ba:	7f ed                	jg     8005a9 <vprintfmt+0x1c0>
  8005bc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c2:	85 c9                	test   %ecx,%ecx
  8005c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c9:	0f 49 c1             	cmovns %ecx,%eax
  8005cc:	29 c1                	sub    %eax,%ecx
  8005ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d7:	89 cb                	mov    %ecx,%ebx
  8005d9:	eb 4d                	jmp    800628 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005df:	74 1b                	je     8005fc <vprintfmt+0x213>
  8005e1:	0f be c0             	movsbl %al,%eax
  8005e4:	83 e8 20             	sub    $0x20,%eax
  8005e7:	83 f8 5e             	cmp    $0x5e,%eax
  8005ea:	76 10                	jbe    8005fc <vprintfmt+0x213>
					putch('?', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	ff 75 0c             	pushl  0xc(%ebp)
  8005f2:	6a 3f                	push   $0x3f
  8005f4:	ff 55 08             	call   *0x8(%ebp)
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	eb 0d                	jmp    800609 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	52                   	push   %edx
  800603:	ff 55 08             	call   *0x8(%ebp)
  800606:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800609:	83 eb 01             	sub    $0x1,%ebx
  80060c:	eb 1a                	jmp    800628 <vprintfmt+0x23f>
  80060e:	89 75 08             	mov    %esi,0x8(%ebp)
  800611:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800614:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800617:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061a:	eb 0c                	jmp    800628 <vprintfmt+0x23f>
  80061c:	89 75 08             	mov    %esi,0x8(%ebp)
  80061f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800622:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800625:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800628:	83 c7 01             	add    $0x1,%edi
  80062b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062f:	0f be d0             	movsbl %al,%edx
  800632:	85 d2                	test   %edx,%edx
  800634:	74 23                	je     800659 <vprintfmt+0x270>
  800636:	85 f6                	test   %esi,%esi
  800638:	78 a1                	js     8005db <vprintfmt+0x1f2>
  80063a:	83 ee 01             	sub    $0x1,%esi
  80063d:	79 9c                	jns    8005db <vprintfmt+0x1f2>
  80063f:	89 df                	mov    %ebx,%edi
  800641:	8b 75 08             	mov    0x8(%ebp),%esi
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800647:	eb 18                	jmp    800661 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 20                	push   $0x20
  80064f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800651:	83 ef 01             	sub    $0x1,%edi
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 08                	jmp    800661 <vprintfmt+0x278>
  800659:	89 df                	mov    %ebx,%edi
  80065b:	8b 75 08             	mov    0x8(%ebp),%esi
  80065e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800661:	85 ff                	test   %edi,%edi
  800663:	7f e4                	jg     800649 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800668:	e9 a2 fd ff ff       	jmp    80040f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066d:	83 fa 01             	cmp    $0x1,%edx
  800670:	7e 16                	jle    800688 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 08             	lea    0x8(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 50 04             	mov    0x4(%eax),%edx
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800683:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800686:	eb 32                	jmp    8006ba <vprintfmt+0x2d1>
	else if (lflag)
  800688:	85 d2                	test   %edx,%edx
  80068a:	74 18                	je     8006a4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069a:	89 c1                	mov    %eax,%ecx
  80069c:	c1 f9 1f             	sar    $0x1f,%ecx
  80069f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a2:	eb 16                	jmp    8006ba <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b2:	89 c1                	mov    %eax,%ecx
  8006b4:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c9:	79 74                	jns    80073f <vprintfmt+0x356>
				putch('-', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 2d                	push   $0x2d
  8006d1:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d9:	f7 d8                	neg    %eax
  8006db:	83 d2 00             	adc    $0x0,%edx
  8006de:	f7 da                	neg    %edx
  8006e0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e8:	eb 55                	jmp    80073f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 83 fc ff ff       	call   800375 <getuint>
			base = 10;
  8006f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f7:	eb 46                	jmp    80073f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fc:	e8 74 fc ff ff       	call   800375 <getuint>
			base = 8;
  800701:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800706:	eb 37                	jmp    80073f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 30                	push   $0x30
  80070e:	ff d6                	call   *%esi
			putch('x', putdat);
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 78                	push   $0x78
  800716:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800721:	8b 00                	mov    (%eax),%eax
  800723:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800728:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800730:	eb 0d                	jmp    80073f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	e8 3b fc ff ff       	call   800375 <getuint>
			base = 16;
  80073a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073f:	83 ec 0c             	sub    $0xc,%esp
  800742:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800746:	57                   	push   %edi
  800747:	ff 75 e0             	pushl  -0x20(%ebp)
  80074a:	51                   	push   %ecx
  80074b:	52                   	push   %edx
  80074c:	50                   	push   %eax
  80074d:	89 da                	mov    %ebx,%edx
  80074f:	89 f0                	mov    %esi,%eax
  800751:	e8 70 fb ff ff       	call   8002c6 <printnum>
			break;
  800756:	83 c4 20             	add    $0x20,%esp
  800759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075c:	e9 ae fc ff ff       	jmp    80040f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	51                   	push   %ecx
  800766:	ff d6                	call   *%esi
			break;
  800768:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076e:	e9 9c fc ff ff       	jmp    80040f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 25                	push   $0x25
  800779:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	eb 03                	jmp    800783 <vprintfmt+0x39a>
  800780:	83 ef 01             	sub    $0x1,%edi
  800783:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800787:	75 f7                	jne    800780 <vprintfmt+0x397>
  800789:	e9 81 fc ff ff       	jmp    80040f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 18             	sub    $0x18,%esp
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	74 26                	je     8007dd <vsnprintf+0x47>
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	7e 22                	jle    8007dd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bb:	ff 75 14             	pushl  0x14(%ebp)
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	68 af 03 80 00       	push   $0x8003af
  8007ca:	e8 1a fc ff ff       	call   8003e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 05                	jmp    8007e2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 10             	pushl  0x10(%ebp)
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 9a ff ff ff       	call   800796 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
  800809:	eb 03                	jmp    80080e <strlen+0x10>
		n++;
  80080b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800812:	75 f7                	jne    80080b <strlen+0xd>
		n++;
	return n;
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	ba 00 00 00 00       	mov    $0x0,%edx
  800824:	eb 03                	jmp    800829 <strnlen+0x13>
		n++;
  800826:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800829:	39 c2                	cmp    %eax,%edx
  80082b:	74 08                	je     800835 <strnlen+0x1f>
  80082d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800831:	75 f3                	jne    800826 <strnlen+0x10>
  800833:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800841:	89 c2                	mov    %eax,%edx
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800850:	84 db                	test   %bl,%bl
  800852:	75 ef                	jne    800843 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085e:	53                   	push   %ebx
  80085f:	e8 9a ff ff ff       	call   8007fe <strlen>
  800864:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	01 d8                	add    %ebx,%eax
  80086c:	50                   	push   %eax
  80086d:	e8 c5 ff ff ff       	call   800837 <strcpy>
	return dst;
}
  800872:	89 d8                	mov    %ebx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800884:	89 f3                	mov    %esi,%ebx
  800886:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	89 f2                	mov    %esi,%edx
  80088b:	eb 0f                	jmp    80089c <strncpy+0x23>
		*dst++ = *src;
  80088d:	83 c2 01             	add    $0x1,%edx
  800890:	0f b6 01             	movzbl (%ecx),%eax
  800893:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800896:	80 39 01             	cmpb   $0x1,(%ecx)
  800899:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089c:	39 da                	cmp    %ebx,%edx
  80089e:	75 ed                	jne    80088d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	74 21                	je     8008db <strlcpy+0x35>
  8008ba:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008be:	89 f2                	mov    %esi,%edx
  8008c0:	eb 09                	jmp    8008cb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cb:	39 c2                	cmp    %eax,%edx
  8008cd:	74 09                	je     8008d8 <strlcpy+0x32>
  8008cf:	0f b6 19             	movzbl (%ecx),%ebx
  8008d2:	84 db                	test   %bl,%bl
  8008d4:	75 ec                	jne    8008c2 <strlcpy+0x1c>
  8008d6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008db:	29 f0                	sub    %esi,%eax
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ea:	eb 06                	jmp    8008f2 <strcmp+0x11>
		p++, q++;
  8008ec:	83 c1 01             	add    $0x1,%ecx
  8008ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	84 c0                	test   %al,%al
  8008f7:	74 04                	je     8008fd <strcmp+0x1c>
  8008f9:	3a 02                	cmp    (%edx),%al
  8008fb:	74 ef                	je     8008ec <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 c0             	movzbl %al,%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800911:	89 c3                	mov    %eax,%ebx
  800913:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800916:	eb 06                	jmp    80091e <strncmp+0x17>
		n--, p++, q++;
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091e:	39 d8                	cmp    %ebx,%eax
  800920:	74 15                	je     800937 <strncmp+0x30>
  800922:	0f b6 08             	movzbl (%eax),%ecx
  800925:	84 c9                	test   %cl,%cl
  800927:	74 04                	je     80092d <strncmp+0x26>
  800929:	3a 0a                	cmp    (%edx),%cl
  80092b:	74 eb                	je     800918 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092d:	0f b6 00             	movzbl (%eax),%eax
  800930:	0f b6 12             	movzbl (%edx),%edx
  800933:	29 d0                	sub    %edx,%eax
  800935:	eb 05                	jmp    80093c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800949:	eb 07                	jmp    800952 <strchr+0x13>
		if (*s == c)
  80094b:	38 ca                	cmp    %cl,%dl
  80094d:	74 0f                	je     80095e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	0f b6 10             	movzbl (%eax),%edx
  800955:	84 d2                	test   %dl,%dl
  800957:	75 f2                	jne    80094b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096a:	eb 03                	jmp    80096f <strfind+0xf>
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800972:	38 ca                	cmp    %cl,%dl
  800974:	74 04                	je     80097a <strfind+0x1a>
  800976:	84 d2                	test   %dl,%dl
  800978:	75 f2                	jne    80096c <strfind+0xc>
			break;
	return (char *) s;
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 7d 08             	mov    0x8(%ebp),%edi
  800985:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800988:	85 c9                	test   %ecx,%ecx
  80098a:	74 36                	je     8009c2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800992:	75 28                	jne    8009bc <memset+0x40>
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 23                	jne    8009bc <memset+0x40>
		c &= 0xFF;
  800999:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099d:	89 d3                	mov    %edx,%ebx
  80099f:	c1 e3 08             	shl    $0x8,%ebx
  8009a2:	89 d6                	mov    %edx,%esi
  8009a4:	c1 e6 18             	shl    $0x18,%esi
  8009a7:	89 d0                	mov    %edx,%eax
  8009a9:	c1 e0 10             	shl    $0x10,%eax
  8009ac:	09 f0                	or     %esi,%eax
  8009ae:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009b0:	89 d8                	mov    %ebx,%eax
  8009b2:	09 d0                	or     %edx,%eax
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
  8009b7:	fc                   	cld    
  8009b8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ba:	eb 06                	jmp    8009c2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	fc                   	cld    
  8009c0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c2:	89 f8                	mov    %edi,%eax
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d7:	39 c6                	cmp    %eax,%esi
  8009d9:	73 35                	jae    800a10 <memmove+0x47>
  8009db:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009de:	39 d0                	cmp    %edx,%eax
  8009e0:	73 2e                	jae    800a10 <memmove+0x47>
		s += n;
		d += n;
  8009e2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e5:	89 d6                	mov    %edx,%esi
  8009e7:	09 fe                	or     %edi,%esi
  8009e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ef:	75 13                	jne    800a04 <memmove+0x3b>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 0e                	jne    800a04 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f6:	83 ef 04             	sub    $0x4,%edi
  8009f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
  8009ff:	fd                   	std    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb 09                	jmp    800a0d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a04:	83 ef 01             	sub    $0x1,%edi
  800a07:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a0a:	fd                   	std    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0d:	fc                   	cld    
  800a0e:	eb 1d                	jmp    800a2d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a10:	89 f2                	mov    %esi,%edx
  800a12:	09 c2                	or     %eax,%edx
  800a14:	f6 c2 03             	test   $0x3,%dl
  800a17:	75 0f                	jne    800a28 <memmove+0x5f>
  800a19:	f6 c1 03             	test   $0x3,%cl
  800a1c:	75 0a                	jne    800a28 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
  800a21:	89 c7                	mov    %eax,%edi
  800a23:	fc                   	cld    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb 05                	jmp    800a2d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a28:	89 c7                	mov    %eax,%edi
  800a2a:	fc                   	cld    
  800a2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a34:	ff 75 10             	pushl  0x10(%ebp)
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	ff 75 08             	pushl  0x8(%ebp)
  800a3d:	e8 87 ff ff ff       	call   8009c9 <memmove>
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 c6                	mov    %eax,%esi
  800a51:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a54:	eb 1a                	jmp    800a70 <memcmp+0x2c>
		if (*s1 != *s2)
  800a56:	0f b6 08             	movzbl (%eax),%ecx
  800a59:	0f b6 1a             	movzbl (%edx),%ebx
  800a5c:	38 d9                	cmp    %bl,%cl
  800a5e:	74 0a                	je     800a6a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a60:	0f b6 c1             	movzbl %cl,%eax
  800a63:	0f b6 db             	movzbl %bl,%ebx
  800a66:	29 d8                	sub    %ebx,%eax
  800a68:	eb 0f                	jmp    800a79 <memcmp+0x35>
		s1++, s2++;
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a70:	39 f0                	cmp    %esi,%eax
  800a72:	75 e2                	jne    800a56 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a84:	89 c1                	mov    %eax,%ecx
  800a86:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a89:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8d:	eb 0a                	jmp    800a99 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8f:	0f b6 10             	movzbl (%eax),%edx
  800a92:	39 da                	cmp    %ebx,%edx
  800a94:	74 07                	je     800a9d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	39 c8                	cmp    %ecx,%eax
  800a9b:	72 f2                	jb     800a8f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aac:	eb 03                	jmp    800ab1 <strtol+0x11>
		s++;
  800aae:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	0f b6 01             	movzbl (%ecx),%eax
  800ab4:	3c 20                	cmp    $0x20,%al
  800ab6:	74 f6                	je     800aae <strtol+0xe>
  800ab8:	3c 09                	cmp    $0x9,%al
  800aba:	74 f2                	je     800aae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abc:	3c 2b                	cmp    $0x2b,%al
  800abe:	75 0a                	jne    800aca <strtol+0x2a>
		s++;
  800ac0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac8:	eb 11                	jmp    800adb <strtol+0x3b>
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acf:	3c 2d                	cmp    $0x2d,%al
  800ad1:	75 08                	jne    800adb <strtol+0x3b>
		s++, neg = 1;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae1:	75 15                	jne    800af8 <strtol+0x58>
  800ae3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae6:	75 10                	jne    800af8 <strtol+0x58>
  800ae8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aec:	75 7c                	jne    800b6a <strtol+0xca>
		s += 2, base = 16;
  800aee:	83 c1 02             	add    $0x2,%ecx
  800af1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af6:	eb 16                	jmp    800b0e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af8:	85 db                	test   %ebx,%ebx
  800afa:	75 12                	jne    800b0e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b01:	80 39 30             	cmpb   $0x30,(%ecx)
  800b04:	75 08                	jne    800b0e <strtol+0x6e>
		s++, base = 8;
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b16:	0f b6 11             	movzbl (%ecx),%edx
  800b19:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 09             	cmp    $0x9,%bl
  800b21:	77 08                	ja     800b2b <strtol+0x8b>
			dig = *s - '0';
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 30             	sub    $0x30,%edx
  800b29:	eb 22                	jmp    800b4d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2e:	89 f3                	mov    %esi,%ebx
  800b30:	80 fb 19             	cmp    $0x19,%bl
  800b33:	77 08                	ja     800b3d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b35:	0f be d2             	movsbl %dl,%edx
  800b38:	83 ea 57             	sub    $0x57,%edx
  800b3b:	eb 10                	jmp    800b4d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b40:	89 f3                	mov    %esi,%ebx
  800b42:	80 fb 19             	cmp    $0x19,%bl
  800b45:	77 16                	ja     800b5d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b47:	0f be d2             	movsbl %dl,%edx
  800b4a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b50:	7d 0b                	jge    800b5d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b52:	83 c1 01             	add    $0x1,%ecx
  800b55:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b59:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5b:	eb b9                	jmp    800b16 <strtol+0x76>

	if (endptr)
  800b5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b61:	74 0d                	je     800b70 <strtol+0xd0>
		*endptr = (char *) s;
  800b63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b66:	89 0e                	mov    %ecx,(%esi)
  800b68:	eb 06                	jmp    800b70 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6a:	85 db                	test   %ebx,%ebx
  800b6c:	74 98                	je     800b06 <strtol+0x66>
  800b6e:	eb 9e                	jmp    800b0e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	f7 da                	neg    %edx
  800b74:	85 ff                	test   %edi,%edi
  800b76:	0f 45 c2             	cmovne %edx,%eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 c3                	mov    %eax,%ebx
  800b91:	89 c7                	mov    %eax,%edi
  800b93:	89 c6                	mov    %eax,%esi
  800b95:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bac:	89 d1                	mov    %edx,%ecx
  800bae:	89 d3                	mov    %edx,%ebx
  800bb0:	89 d7                	mov    %edx,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	89 cb                	mov    %ecx,%ebx
  800bd3:	89 cf                	mov    %ecx,%edi
  800bd5:	89 ce                	mov    %ecx,%esi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 03                	push   $0x3
  800be3:	68 ff 28 80 00       	push   $0x8028ff
  800be8:	6a 23                	push   $0x23
  800bea:	68 1c 29 80 00       	push   $0x80291c
  800bef:	e8 b2 15 00 00       	call   8021a6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0c:	89 d1                	mov    %edx,%ecx
  800c0e:	89 d3                	mov    %edx,%ebx
  800c10:	89 d7                	mov    %edx,%edi
  800c12:	89 d6                	mov    %edx,%esi
  800c14:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_yield>:

void
sys_yield(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2b:	89 d1                	mov    %edx,%ecx
  800c2d:	89 d3                	mov    %edx,%ebx
  800c2f:	89 d7                	mov    %edx,%edi
  800c31:	89 d6                	mov    %edx,%esi
  800c33:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	be 00 00 00 00       	mov    $0x0,%esi
  800c48:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c56:	89 f7                	mov    %esi,%edi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 04                	push   $0x4
  800c64:	68 ff 28 80 00       	push   $0x8028ff
  800c69:	6a 23                	push   $0x23
  800c6b:	68 1c 29 80 00       	push   $0x80291c
  800c70:	e8 31 15 00 00       	call   8021a6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c97:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 05                	push   $0x5
  800ca6:	68 ff 28 80 00       	push   $0x8028ff
  800cab:	6a 23                	push   $0x23
  800cad:	68 1c 29 80 00       	push   $0x80291c
  800cb2:	e8 ef 14 00 00       	call   8021a6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 17                	jle    800cf9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 06                	push   $0x6
  800ce8:	68 ff 28 80 00       	push   $0x8028ff
  800ced:	6a 23                	push   $0x23
  800cef:	68 1c 29 80 00       	push   $0x80291c
  800cf4:	e8 ad 14 00 00       	call   8021a6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 08                	push   $0x8
  800d2a:	68 ff 28 80 00       	push   $0x8028ff
  800d2f:	6a 23                	push   $0x23
  800d31:	68 1c 29 80 00       	push   $0x80291c
  800d36:	e8 6b 14 00 00       	call   8021a6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	b8 09 00 00 00       	mov    $0x9,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 09                	push   $0x9
  800d6c:	68 ff 28 80 00       	push   $0x8028ff
  800d71:	6a 23                	push   $0x23
  800d73:	68 1c 29 80 00       	push   $0x80291c
  800d78:	e8 29 14 00 00       	call   8021a6 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7e 17                	jle    800dbf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	50                   	push   %eax
  800dac:	6a 0a                	push   $0xa
  800dae:	68 ff 28 80 00       	push   $0x8028ff
  800db3:	6a 23                	push   $0x23
  800db5:	68 1c 29 80 00       	push   $0x80291c
  800dba:	e8 e7 13 00 00       	call   8021a6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	be 00 00 00 00       	mov    $0x0,%esi
  800dd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 cb                	mov    %ecx,%ebx
  800e02:	89 cf                	mov    %ecx,%edi
  800e04:	89 ce                	mov    %ecx,%esi
  800e06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	7e 17                	jle    800e23 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0c:	83 ec 0c             	sub    $0xc,%esp
  800e0f:	50                   	push   %eax
  800e10:	6a 0d                	push   $0xd
  800e12:	68 ff 28 80 00       	push   $0x8028ff
  800e17:	6a 23                	push   $0x23
  800e19:	68 1c 29 80 00       	push   $0x80291c
  800e1e:	e8 83 13 00 00       	call   8021a6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e36:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	89 cb                	mov    %ecx,%ebx
  800e40:	89 cf                	mov    %ecx,%edi
  800e42:	89 ce                	mov    %ecx,%esi
  800e44:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e56:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	89 cb                	mov    %ecx,%ebx
  800e60:	89 cf                	mov    %ecx,%edi
  800e62:	89 ce                	mov    %ecx,%esi
  800e64:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e76:	b8 10 00 00 00       	mov    $0x10,%eax
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 cb                	mov    %ecx,%ebx
  800e80:	89 cf                	mov    %ecx,%edi
  800e82:	89 ce                	mov    %ecx,%esi
  800e84:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e95:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e97:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e9b:	74 11                	je     800eae <pgfault+0x23>
  800e9d:	89 d8                	mov    %ebx,%eax
  800e9f:	c1 e8 0c             	shr    $0xc,%eax
  800ea2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea9:	f6 c4 08             	test   $0x8,%ah
  800eac:	75 14                	jne    800ec2 <pgfault+0x37>
		panic("faulting access");
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	68 2a 29 80 00       	push   $0x80292a
  800eb6:	6a 1f                	push   $0x1f
  800eb8:	68 3a 29 80 00       	push   $0x80293a
  800ebd:	e8 e4 12 00 00       	call   8021a6 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	6a 07                	push   $0x7
  800ec7:	68 00 f0 7f 00       	push   $0x7ff000
  800ecc:	6a 00                	push   $0x0
  800ece:	e8 67 fd ff ff       	call   800c3a <sys_page_alloc>
	if (r < 0) {
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	79 12                	jns    800eec <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800eda:	50                   	push   %eax
  800edb:	68 45 29 80 00       	push   $0x802945
  800ee0:	6a 2d                	push   $0x2d
  800ee2:	68 3a 29 80 00       	push   $0x80293a
  800ee7:	e8 ba 12 00 00       	call   8021a6 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eec:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	68 00 10 00 00       	push   $0x1000
  800efa:	53                   	push   %ebx
  800efb:	68 00 f0 7f 00       	push   $0x7ff000
  800f00:	e8 2c fb ff ff       	call   800a31 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f05:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0c:	53                   	push   %ebx
  800f0d:	6a 00                	push   $0x0
  800f0f:	68 00 f0 7f 00       	push   $0x7ff000
  800f14:	6a 00                	push   $0x0
  800f16:	e8 62 fd ff ff       	call   800c7d <sys_page_map>
	if (r < 0) {
  800f1b:	83 c4 20             	add    $0x20,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	79 12                	jns    800f34 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f22:	50                   	push   %eax
  800f23:	68 45 29 80 00       	push   $0x802945
  800f28:	6a 34                	push   $0x34
  800f2a:	68 3a 29 80 00       	push   $0x80293a
  800f2f:	e8 72 12 00 00       	call   8021a6 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	68 00 f0 7f 00       	push   $0x7ff000
  800f3c:	6a 00                	push   $0x0
  800f3e:	e8 7c fd ff ff       	call   800cbf <sys_page_unmap>
	if (r < 0) {
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	79 12                	jns    800f5c <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f4a:	50                   	push   %eax
  800f4b:	68 45 29 80 00       	push   $0x802945
  800f50:	6a 38                	push   $0x38
  800f52:	68 3a 29 80 00       	push   $0x80293a
  800f57:	e8 4a 12 00 00       	call   8021a6 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f6a:	68 8b 0e 80 00       	push   $0x800e8b
  800f6f:	e8 78 12 00 00       	call   8021ec <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f74:	b8 07 00 00 00       	mov    $0x7,%eax
  800f79:	cd 30                	int    $0x30
  800f7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	79 17                	jns    800f9c <fork+0x3b>
		panic("fork fault %e");
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	68 5e 29 80 00       	push   $0x80295e
  800f8d:	68 85 00 00 00       	push   $0x85
  800f92:	68 3a 29 80 00       	push   $0x80293a
  800f97:	e8 0a 12 00 00       	call   8021a6 <_panic>
  800f9c:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f9e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fa2:	75 24                	jne    800fc8 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa4:	e8 53 fc ff ff       	call   800bfc <sys_getenvid>
  800fa9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fae:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800fb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb9:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	e9 64 01 00 00       	jmp    80112c <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	6a 07                	push   $0x7
  800fcd:	68 00 f0 bf ee       	push   $0xeebff000
  800fd2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd5:	e8 60 fc ff ff       	call   800c3a <sys_page_alloc>
  800fda:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe2:	89 d8                	mov    %ebx,%eax
  800fe4:	c1 e8 16             	shr    $0x16,%eax
  800fe7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fee:	a8 01                	test   $0x1,%al
  800ff0:	0f 84 fc 00 00 00    	je     8010f2 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ff6:	89 d8                	mov    %ebx,%eax
  800ff8:	c1 e8 0c             	shr    $0xc,%eax
  800ffb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801002:	f6 c2 01             	test   $0x1,%dl
  801005:	0f 84 e7 00 00 00    	je     8010f2 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80100b:	89 c6                	mov    %eax,%esi
  80100d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801010:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801017:	f6 c6 04             	test   $0x4,%dh
  80101a:	74 39                	je     801055 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80101c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	25 07 0e 00 00       	and    $0xe07,%eax
  80102b:	50                   	push   %eax
  80102c:	56                   	push   %esi
  80102d:	57                   	push   %edi
  80102e:	56                   	push   %esi
  80102f:	6a 00                	push   $0x0
  801031:	e8 47 fc ff ff       	call   800c7d <sys_page_map>
		if (r < 0) {
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	0f 89 b1 00 00 00    	jns    8010f2 <fork+0x191>
		    	panic("sys page map fault %e");
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	68 6c 29 80 00       	push   $0x80296c
  801049:	6a 55                	push   $0x55
  80104b:	68 3a 29 80 00       	push   $0x80293a
  801050:	e8 51 11 00 00       	call   8021a6 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801055:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105c:	f6 c2 02             	test   $0x2,%dl
  80105f:	75 0c                	jne    80106d <fork+0x10c>
  801061:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801068:	f6 c4 08             	test   $0x8,%ah
  80106b:	74 5b                	je     8010c8 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	68 05 08 00 00       	push   $0x805
  801075:	56                   	push   %esi
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	6a 00                	push   $0x0
  80107a:	e8 fe fb ff ff       	call   800c7d <sys_page_map>
		if (r < 0) {
  80107f:	83 c4 20             	add    $0x20,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	79 14                	jns    80109a <fork+0x139>
		    	panic("sys page map fault %e");
  801086:	83 ec 04             	sub    $0x4,%esp
  801089:	68 6c 29 80 00       	push   $0x80296c
  80108e:	6a 5c                	push   $0x5c
  801090:	68 3a 29 80 00       	push   $0x80293a
  801095:	e8 0c 11 00 00       	call   8021a6 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	68 05 08 00 00       	push   $0x805
  8010a2:	56                   	push   %esi
  8010a3:	6a 00                	push   $0x0
  8010a5:	56                   	push   %esi
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 d0 fb ff ff       	call   800c7d <sys_page_map>
		if (r < 0) {
  8010ad:	83 c4 20             	add    $0x20,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	79 3e                	jns    8010f2 <fork+0x191>
		    	panic("sys page map fault %e");
  8010b4:	83 ec 04             	sub    $0x4,%esp
  8010b7:	68 6c 29 80 00       	push   $0x80296c
  8010bc:	6a 60                	push   $0x60
  8010be:	68 3a 29 80 00       	push   $0x80293a
  8010c3:	e8 de 10 00 00       	call   8021a6 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	6a 05                	push   $0x5
  8010cd:	56                   	push   %esi
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	6a 00                	push   $0x0
  8010d2:	e8 a6 fb ff ff       	call   800c7d <sys_page_map>
		if (r < 0) {
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 14                	jns    8010f2 <fork+0x191>
		    	panic("sys page map fault %e");
  8010de:	83 ec 04             	sub    $0x4,%esp
  8010e1:	68 6c 29 80 00       	push   $0x80296c
  8010e6:	6a 65                	push   $0x65
  8010e8:	68 3a 29 80 00       	push   $0x80293a
  8010ed:	e8 b4 10 00 00       	call   8021a6 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010f2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010fe:	0f 85 de fe ff ff    	jne    800fe2 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801104:	a1 04 40 80 00       	mov    0x804004,%eax
  801109:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  80110f:	83 ec 08             	sub    $0x8,%esp
  801112:	50                   	push   %eax
  801113:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801116:	57                   	push   %edi
  801117:	e8 69 fc ff ff       	call   800d85 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80111c:	83 c4 08             	add    $0x8,%esp
  80111f:	6a 02                	push   $0x2
  801121:	57                   	push   %edi
  801122:	e8 da fb ff ff       	call   800d01 <sys_env_set_status>
	
	return envid;
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80112c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <sfork>:

envid_t
sfork(void)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80114c:	68 e5 01 80 00       	push   $0x8001e5
  801151:	e8 d5 fc ff ff       	call   800e2b <sys_thread_create>

	return id;
}
  801156:	c9                   	leave  
  801157:	c3                   	ret    

00801158 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80115e:	ff 75 08             	pushl  0x8(%ebp)
  801161:	e8 e5 fc ff ff       	call   800e4b <sys_thread_free>
}
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801171:	ff 75 08             	pushl  0x8(%ebp)
  801174:	e8 f2 fc ff ff       	call   800e6b <sys_thread_join>
}
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	56                   	push   %esi
  801182:	53                   	push   %ebx
  801183:	8b 75 08             	mov    0x8(%ebp),%esi
  801186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	6a 07                	push   $0x7
  80118e:	6a 00                	push   $0x0
  801190:	56                   	push   %esi
  801191:	e8 a4 fa ff ff       	call   800c3a <sys_page_alloc>
	if (r < 0) {
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	79 15                	jns    8011b2 <queue_append+0x34>
		panic("%e\n", r);
  80119d:	50                   	push   %eax
  80119e:	68 b2 29 80 00       	push   $0x8029b2
  8011a3:	68 d5 00 00 00       	push   $0xd5
  8011a8:	68 3a 29 80 00       	push   $0x80293a
  8011ad:	e8 f4 0f 00 00       	call   8021a6 <_panic>
	}	

	wt->envid = envid;
  8011b2:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8011b8:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011bb:	75 13                	jne    8011d0 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8011bd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011c4:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011cb:	00 00 00 
  8011ce:	eb 1b                	jmp    8011eb <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8011d0:	8b 43 04             	mov    0x4(%ebx),%eax
  8011d3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011da:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011e1:	00 00 00 
		queue->last = wt;
  8011e4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8011eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8011fb:	8b 02                	mov    (%edx),%eax
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	75 17                	jne    801218 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	68 82 29 80 00       	push   $0x802982
  801209:	68 ec 00 00 00       	push   $0xec
  80120e:	68 3a 29 80 00       	push   $0x80293a
  801213:	e8 8e 0f 00 00       	call   8021a6 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801218:	8b 48 04             	mov    0x4(%eax),%ecx
  80121b:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80121d:	8b 00                	mov    (%eax),%eax
}
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	53                   	push   %ebx
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80122b:	b8 01 00 00 00       	mov    $0x1,%eax
  801230:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801233:	85 c0                	test   %eax,%eax
  801235:	74 45                	je     80127c <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801237:	e8 c0 f9 ff ff       	call   800bfc <sys_getenvid>
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	83 c3 04             	add    $0x4,%ebx
  801242:	53                   	push   %ebx
  801243:	50                   	push   %eax
  801244:	e8 35 ff ff ff       	call   80117e <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801249:	e8 ae f9 ff ff       	call   800bfc <sys_getenvid>
  80124e:	83 c4 08             	add    $0x8,%esp
  801251:	6a 04                	push   $0x4
  801253:	50                   	push   %eax
  801254:	e8 a8 fa ff ff       	call   800d01 <sys_env_set_status>

		if (r < 0) {
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	79 15                	jns    801275 <mutex_lock+0x54>
			panic("%e\n", r);
  801260:	50                   	push   %eax
  801261:	68 b2 29 80 00       	push   $0x8029b2
  801266:	68 02 01 00 00       	push   $0x102
  80126b:	68 3a 29 80 00       	push   $0x80293a
  801270:	e8 31 0f 00 00       	call   8021a6 <_panic>
		}
		sys_yield();
  801275:	e8 a1 f9 ff ff       	call   800c1b <sys_yield>
  80127a:	eb 08                	jmp    801284 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  80127c:	e8 7b f9 ff ff       	call   800bfc <sys_getenvid>
  801281:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	53                   	push   %ebx
  80128d:	83 ec 04             	sub    $0x4,%esp
  801290:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801293:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801297:	74 36                	je     8012cf <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801299:	83 ec 0c             	sub    $0xc,%esp
  80129c:	8d 43 04             	lea    0x4(%ebx),%eax
  80129f:	50                   	push   %eax
  8012a0:	e8 4d ff ff ff       	call   8011f2 <queue_pop>
  8012a5:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012a8:	83 c4 08             	add    $0x8,%esp
  8012ab:	6a 02                	push   $0x2
  8012ad:	50                   	push   %eax
  8012ae:	e8 4e fa ff ff       	call   800d01 <sys_env_set_status>
		if (r < 0) {
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	79 1d                	jns    8012d7 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8012ba:	50                   	push   %eax
  8012bb:	68 b2 29 80 00       	push   $0x8029b2
  8012c0:	68 16 01 00 00       	push   $0x116
  8012c5:	68 3a 29 80 00       	push   $0x80293a
  8012ca:	e8 d7 0e 00 00       	call   8021a6 <_panic>
  8012cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d4:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8012d7:	e8 3f f9 ff ff       	call   800c1b <sys_yield>
}
  8012dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 04             	sub    $0x4,%esp
  8012e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012eb:	e8 0c f9 ff ff       	call   800bfc <sys_getenvid>
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	6a 07                	push   $0x7
  8012f5:	53                   	push   %ebx
  8012f6:	50                   	push   %eax
  8012f7:	e8 3e f9 ff ff       	call   800c3a <sys_page_alloc>
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	79 15                	jns    801318 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801303:	50                   	push   %eax
  801304:	68 9d 29 80 00       	push   $0x80299d
  801309:	68 23 01 00 00       	push   $0x123
  80130e:	68 3a 29 80 00       	push   $0x80293a
  801313:	e8 8e 0e 00 00       	call   8021a6 <_panic>
	}	
	mtx->locked = 0;
  801318:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80131e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801325:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80132c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801333:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	56                   	push   %esi
  80133c:	53                   	push   %ebx
  80133d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801340:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801343:	eb 20                	jmp    801365 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	56                   	push   %esi
  801349:	e8 a4 fe ff ff       	call   8011f2 <queue_pop>
  80134e:	83 c4 08             	add    $0x8,%esp
  801351:	6a 02                	push   $0x2
  801353:	50                   	push   %eax
  801354:	e8 a8 f9 ff ff       	call   800d01 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  801359:	8b 43 04             	mov    0x4(%ebx),%eax
  80135c:	8b 40 04             	mov    0x4(%eax),%eax
  80135f:	89 43 04             	mov    %eax,0x4(%ebx)
  801362:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801365:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801369:	75 da                	jne    801345 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	68 00 10 00 00       	push   $0x1000
  801373:	6a 00                	push   $0x0
  801375:	53                   	push   %ebx
  801376:	e8 01 f6 ff ff       	call   80097c <memset>
	mtx = NULL;
}
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	56                   	push   %esi
  801389:	53                   	push   %ebx
  80138a:	8b 75 08             	mov    0x8(%ebp),%esi
  80138d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801390:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801393:	85 c0                	test   %eax,%eax
  801395:	75 12                	jne    8013a9 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	68 00 00 c0 ee       	push   $0xeec00000
  80139f:	e8 46 fa ff ff       	call   800dea <sys_ipc_recv>
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	eb 0c                	jmp    8013b5 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8013a9:	83 ec 0c             	sub    $0xc,%esp
  8013ac:	50                   	push   %eax
  8013ad:	e8 38 fa ff ff       	call   800dea <sys_ipc_recv>
  8013b2:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8013b5:	85 f6                	test   %esi,%esi
  8013b7:	0f 95 c1             	setne  %cl
  8013ba:	85 db                	test   %ebx,%ebx
  8013bc:	0f 95 c2             	setne  %dl
  8013bf:	84 d1                	test   %dl,%cl
  8013c1:	74 09                	je     8013cc <ipc_recv+0x47>
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	c1 ea 1f             	shr    $0x1f,%edx
  8013c8:	84 d2                	test   %dl,%dl
  8013ca:	75 2d                	jne    8013f9 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8013cc:	85 f6                	test   %esi,%esi
  8013ce:	74 0d                	je     8013dd <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8013d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d5:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8013db:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8013dd:	85 db                	test   %ebx,%ebx
  8013df:	74 0d                	je     8013ee <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8013e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e6:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8013ec:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8013ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f3:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8013f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	57                   	push   %edi
  801404:	56                   	push   %esi
  801405:	53                   	push   %ebx
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	8b 7d 08             	mov    0x8(%ebp),%edi
  80140c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80140f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801412:	85 db                	test   %ebx,%ebx
  801414:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801419:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80141c:	ff 75 14             	pushl  0x14(%ebp)
  80141f:	53                   	push   %ebx
  801420:	56                   	push   %esi
  801421:	57                   	push   %edi
  801422:	e8 a0 f9 ff ff       	call   800dc7 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801427:	89 c2                	mov    %eax,%edx
  801429:	c1 ea 1f             	shr    $0x1f,%edx
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	84 d2                	test   %dl,%dl
  801431:	74 17                	je     80144a <ipc_send+0x4a>
  801433:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801436:	74 12                	je     80144a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801438:	50                   	push   %eax
  801439:	68 b6 29 80 00       	push   $0x8029b6
  80143e:	6a 47                	push   $0x47
  801440:	68 c4 29 80 00       	push   $0x8029c4
  801445:	e8 5c 0d 00 00       	call   8021a6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80144a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80144d:	75 07                	jne    801456 <ipc_send+0x56>
			sys_yield();
  80144f:	e8 c7 f7 ff ff       	call   800c1b <sys_yield>
  801454:	eb c6                	jmp    80141c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801456:	85 c0                	test   %eax,%eax
  801458:	75 c2                	jne    80141c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80145a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5e                   	pop    %esi
  80145f:	5f                   	pop    %edi
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80146d:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  801473:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801479:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80147f:	39 ca                	cmp    %ecx,%edx
  801481:	75 13                	jne    801496 <ipc_find_env+0x34>
			return envs[i].env_id;
  801483:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  801489:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80148e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801494:	eb 0f                	jmp    8014a5 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801496:	83 c0 01             	add    $0x1,%eax
  801499:	3d 00 04 00 00       	cmp    $0x400,%eax
  80149e:	75 cd                	jne    80146d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8014b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	05 00 00 00 30       	add    $0x30000000,%eax
  8014c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    

008014ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	c1 ea 16             	shr    $0x16,%edx
  8014de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e5:	f6 c2 01             	test   $0x1,%dl
  8014e8:	74 11                	je     8014fb <fd_alloc+0x2d>
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	c1 ea 0c             	shr    $0xc,%edx
  8014ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f6:	f6 c2 01             	test   $0x1,%dl
  8014f9:	75 09                	jne    801504 <fd_alloc+0x36>
			*fd_store = fd;
  8014fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801502:	eb 17                	jmp    80151b <fd_alloc+0x4d>
  801504:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801509:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80150e:	75 c9                	jne    8014d9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801510:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801516:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801523:	83 f8 1f             	cmp    $0x1f,%eax
  801526:	77 36                	ja     80155e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801528:	c1 e0 0c             	shl    $0xc,%eax
  80152b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801530:	89 c2                	mov    %eax,%edx
  801532:	c1 ea 16             	shr    $0x16,%edx
  801535:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80153c:	f6 c2 01             	test   $0x1,%dl
  80153f:	74 24                	je     801565 <fd_lookup+0x48>
  801541:	89 c2                	mov    %eax,%edx
  801543:	c1 ea 0c             	shr    $0xc,%edx
  801546:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154d:	f6 c2 01             	test   $0x1,%dl
  801550:	74 1a                	je     80156c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801552:	8b 55 0c             	mov    0xc(%ebp),%edx
  801555:	89 02                	mov    %eax,(%edx)
	return 0;
  801557:	b8 00 00 00 00       	mov    $0x0,%eax
  80155c:	eb 13                	jmp    801571 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80155e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801563:	eb 0c                	jmp    801571 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801565:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156a:	eb 05                	jmp    801571 <fd_lookup+0x54>
  80156c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80157c:	ba 4c 2a 80 00       	mov    $0x802a4c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801581:	eb 13                	jmp    801596 <dev_lookup+0x23>
  801583:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801586:	39 08                	cmp    %ecx,(%eax)
  801588:	75 0c                	jne    801596 <dev_lookup+0x23>
			*dev = devtab[i];
  80158a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80158f:	b8 00 00 00 00       	mov    $0x0,%eax
  801594:	eb 31                	jmp    8015c7 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801596:	8b 02                	mov    (%edx),%eax
  801598:	85 c0                	test   %eax,%eax
  80159a:	75 e7                	jne    801583 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80159c:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	51                   	push   %ecx
  8015ab:	50                   	push   %eax
  8015ac:	68 d0 29 80 00       	push   $0x8029d0
  8015b1:	e8 fc ec ff ff       	call   8002b2 <cprintf>
	*dev = 0;
  8015b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 10             	sub    $0x10,%esp
  8015d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015e1:	c1 e8 0c             	shr    $0xc,%eax
  8015e4:	50                   	push   %eax
  8015e5:	e8 33 ff ff ff       	call   80151d <fd_lookup>
  8015ea:	83 c4 08             	add    $0x8,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 05                	js     8015f6 <fd_close+0x2d>
	    || fd != fd2)
  8015f1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015f4:	74 0c                	je     801602 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015f6:	84 db                	test   %bl,%bl
  8015f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fd:	0f 44 c2             	cmove  %edx,%eax
  801600:	eb 41                	jmp    801643 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	ff 36                	pushl  (%esi)
  80160b:	e8 63 ff ff ff       	call   801573 <dev_lookup>
  801610:	89 c3                	mov    %eax,%ebx
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 1a                	js     801633 <fd_close+0x6a>
		if (dev->dev_close)
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80161f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801624:	85 c0                	test   %eax,%eax
  801626:	74 0b                	je     801633 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	56                   	push   %esi
  80162c:	ff d0                	call   *%eax
  80162e:	89 c3                	mov    %eax,%ebx
  801630:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	56                   	push   %esi
  801637:	6a 00                	push   $0x0
  801639:	e8 81 f6 ff ff       	call   800cbf <sys_page_unmap>
	return r;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	89 d8                	mov    %ebx,%eax
}
  801643:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	ff 75 08             	pushl  0x8(%ebp)
  801657:	e8 c1 fe ff ff       	call   80151d <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 10                	js     801673 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	6a 01                	push   $0x1
  801668:	ff 75 f4             	pushl  -0xc(%ebp)
  80166b:	e8 59 ff ff ff       	call   8015c9 <fd_close>
  801670:	83 c4 10             	add    $0x10,%esp
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <close_all>:

void
close_all(void)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80167c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801681:	83 ec 0c             	sub    $0xc,%esp
  801684:	53                   	push   %ebx
  801685:	e8 c0 ff ff ff       	call   80164a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80168a:	83 c3 01             	add    $0x1,%ebx
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	83 fb 20             	cmp    $0x20,%ebx
  801693:	75 ec                	jne    801681 <close_all+0xc>
		close(i);
}
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	57                   	push   %edi
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 2c             	sub    $0x2c,%esp
  8016a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	ff 75 08             	pushl  0x8(%ebp)
  8016ad:	e8 6b fe ff ff       	call   80151d <fd_lookup>
  8016b2:	83 c4 08             	add    $0x8,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	0f 88 c1 00 00 00    	js     80177e <dup+0xe4>
		return r;
	close(newfdnum);
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	56                   	push   %esi
  8016c1:	e8 84 ff ff ff       	call   80164a <close>

	newfd = INDEX2FD(newfdnum);
  8016c6:	89 f3                	mov    %esi,%ebx
  8016c8:	c1 e3 0c             	shl    $0xc,%ebx
  8016cb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016d1:	83 c4 04             	add    $0x4,%esp
  8016d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016d7:	e8 db fd ff ff       	call   8014b7 <fd2data>
  8016dc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016de:	89 1c 24             	mov    %ebx,(%esp)
  8016e1:	e8 d1 fd ff ff       	call   8014b7 <fd2data>
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ec:	89 f8                	mov    %edi,%eax
  8016ee:	c1 e8 16             	shr    $0x16,%eax
  8016f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016f8:	a8 01                	test   $0x1,%al
  8016fa:	74 37                	je     801733 <dup+0x99>
  8016fc:	89 f8                	mov    %edi,%eax
  8016fe:	c1 e8 0c             	shr    $0xc,%eax
  801701:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801708:	f6 c2 01             	test   $0x1,%dl
  80170b:	74 26                	je     801733 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80170d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	25 07 0e 00 00       	and    $0xe07,%eax
  80171c:	50                   	push   %eax
  80171d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801720:	6a 00                	push   $0x0
  801722:	57                   	push   %edi
  801723:	6a 00                	push   $0x0
  801725:	e8 53 f5 ff ff       	call   800c7d <sys_page_map>
  80172a:	89 c7                	mov    %eax,%edi
  80172c:	83 c4 20             	add    $0x20,%esp
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 2e                	js     801761 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801733:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801736:	89 d0                	mov    %edx,%eax
  801738:	c1 e8 0c             	shr    $0xc,%eax
  80173b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	25 07 0e 00 00       	and    $0xe07,%eax
  80174a:	50                   	push   %eax
  80174b:	53                   	push   %ebx
  80174c:	6a 00                	push   $0x0
  80174e:	52                   	push   %edx
  80174f:	6a 00                	push   $0x0
  801751:	e8 27 f5 ff ff       	call   800c7d <sys_page_map>
  801756:	89 c7                	mov    %eax,%edi
  801758:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80175b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80175d:	85 ff                	test   %edi,%edi
  80175f:	79 1d                	jns    80177e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	53                   	push   %ebx
  801765:	6a 00                	push   $0x0
  801767:	e8 53 f5 ff ff       	call   800cbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801772:	6a 00                	push   $0x0
  801774:	e8 46 f5 ff ff       	call   800cbf <sys_page_unmap>
	return r;
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	89 f8                	mov    %edi,%eax
}
  80177e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801781:	5b                   	pop    %ebx
  801782:	5e                   	pop    %esi
  801783:	5f                   	pop    %edi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	53                   	push   %ebx
  80178a:	83 ec 14             	sub    $0x14,%esp
  80178d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801790:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	53                   	push   %ebx
  801795:	e8 83 fd ff ff       	call   80151d <fd_lookup>
  80179a:	83 c4 08             	add    $0x8,%esp
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 70                	js     801813 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a9:	50                   	push   %eax
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	ff 30                	pushl  (%eax)
  8017af:	e8 bf fd ff ff       	call   801573 <dev_lookup>
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 4f                	js     80180a <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017be:	8b 42 08             	mov    0x8(%edx),%eax
  8017c1:	83 e0 03             	and    $0x3,%eax
  8017c4:	83 f8 01             	cmp    $0x1,%eax
  8017c7:	75 24                	jne    8017ed <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ce:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	53                   	push   %ebx
  8017d8:	50                   	push   %eax
  8017d9:	68 11 2a 80 00       	push   $0x802a11
  8017de:	e8 cf ea ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017eb:	eb 26                	jmp    801813 <read+0x8d>
	}
	if (!dev->dev_read)
  8017ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f0:	8b 40 08             	mov    0x8(%eax),%eax
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	74 17                	je     80180e <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017f7:	83 ec 04             	sub    $0x4,%esp
  8017fa:	ff 75 10             	pushl  0x10(%ebp)
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	52                   	push   %edx
  801801:	ff d0                	call   *%eax
  801803:	89 c2                	mov    %eax,%edx
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	eb 09                	jmp    801813 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	eb 05                	jmp    801813 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80180e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801813:	89 d0                	mov    %edx,%eax
  801815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	57                   	push   %edi
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	8b 7d 08             	mov    0x8(%ebp),%edi
  801826:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801829:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182e:	eb 21                	jmp    801851 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801830:	83 ec 04             	sub    $0x4,%esp
  801833:	89 f0                	mov    %esi,%eax
  801835:	29 d8                	sub    %ebx,%eax
  801837:	50                   	push   %eax
  801838:	89 d8                	mov    %ebx,%eax
  80183a:	03 45 0c             	add    0xc(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	57                   	push   %edi
  80183f:	e8 42 ff ff ff       	call   801786 <read>
		if (m < 0)
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	78 10                	js     80185b <readn+0x41>
			return m;
		if (m == 0)
  80184b:	85 c0                	test   %eax,%eax
  80184d:	74 0a                	je     801859 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80184f:	01 c3                	add    %eax,%ebx
  801851:	39 f3                	cmp    %esi,%ebx
  801853:	72 db                	jb     801830 <readn+0x16>
  801855:	89 d8                	mov    %ebx,%eax
  801857:	eb 02                	jmp    80185b <readn+0x41>
  801859:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80185b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5f                   	pop    %edi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 14             	sub    $0x14,%esp
  80186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801870:	50                   	push   %eax
  801871:	53                   	push   %ebx
  801872:	e8 a6 fc ff ff       	call   80151d <fd_lookup>
  801877:	83 c4 08             	add    $0x8,%esp
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 6b                	js     8018eb <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801886:	50                   	push   %eax
  801887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188a:	ff 30                	pushl  (%eax)
  80188c:	e8 e2 fc ff ff       	call   801573 <dev_lookup>
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	85 c0                	test   %eax,%eax
  801896:	78 4a                	js     8018e2 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80189f:	75 24                	jne    8018c5 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018a6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	53                   	push   %ebx
  8018b0:	50                   	push   %eax
  8018b1:	68 2d 2a 80 00       	push   $0x802a2d
  8018b6:	e8 f7 e9 ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c3:	eb 26                	jmp    8018eb <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018cb:	85 d2                	test   %edx,%edx
  8018cd:	74 17                	je     8018e6 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	ff 75 10             	pushl  0x10(%ebp)
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	50                   	push   %eax
  8018d9:	ff d2                	call   *%edx
  8018db:	89 c2                	mov    %eax,%edx
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	eb 09                	jmp    8018eb <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e2:	89 c2                	mov    %eax,%edx
  8018e4:	eb 05                	jmp    8018eb <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018eb:	89 d0                	mov    %edx,%eax
  8018ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018fb:	50                   	push   %eax
  8018fc:	ff 75 08             	pushl  0x8(%ebp)
  8018ff:	e8 19 fc ff ff       	call   80151d <fd_lookup>
  801904:	83 c4 08             	add    $0x8,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	78 0e                	js     801919 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80190b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80190e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801911:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	53                   	push   %ebx
  80191f:	83 ec 14             	sub    $0x14,%esp
  801922:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801925:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801928:	50                   	push   %eax
  801929:	53                   	push   %ebx
  80192a:	e8 ee fb ff ff       	call   80151d <fd_lookup>
  80192f:	83 c4 08             	add    $0x8,%esp
  801932:	89 c2                	mov    %eax,%edx
  801934:	85 c0                	test   %eax,%eax
  801936:	78 68                	js     8019a0 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193e:	50                   	push   %eax
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	ff 30                	pushl  (%eax)
  801944:	e8 2a fc ff ff       	call   801573 <dev_lookup>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 47                	js     801997 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801950:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801953:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801957:	75 24                	jne    80197d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801959:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80195e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	53                   	push   %ebx
  801968:	50                   	push   %eax
  801969:	68 f0 29 80 00       	push   $0x8029f0
  80196e:	e8 3f e9 ff ff       	call   8002b2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80197b:	eb 23                	jmp    8019a0 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80197d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801980:	8b 52 18             	mov    0x18(%edx),%edx
  801983:	85 d2                	test   %edx,%edx
  801985:	74 14                	je     80199b <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	50                   	push   %eax
  80198e:	ff d2                	call   *%edx
  801990:	89 c2                	mov    %eax,%edx
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	eb 09                	jmp    8019a0 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801997:	89 c2                	mov    %eax,%edx
  801999:	eb 05                	jmp    8019a0 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80199b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019a0:	89 d0                	mov    %edx,%eax
  8019a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 14             	sub    $0x14,%esp
  8019ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	ff 75 08             	pushl  0x8(%ebp)
  8019b8:	e8 60 fb ff ff       	call   80151d <fd_lookup>
  8019bd:	83 c4 08             	add    $0x8,%esp
  8019c0:	89 c2                	mov    %eax,%edx
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 58                	js     801a1e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cc:	50                   	push   %eax
  8019cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d0:	ff 30                	pushl  (%eax)
  8019d2:	e8 9c fb ff ff       	call   801573 <dev_lookup>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 37                	js     801a15 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e5:	74 32                	je     801a19 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019f1:	00 00 00 
	stat->st_isdir = 0;
  8019f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fb:	00 00 00 
	stat->st_dev = dev;
  8019fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	53                   	push   %ebx
  801a08:	ff 75 f0             	pushl  -0x10(%ebp)
  801a0b:	ff 50 14             	call   *0x14(%eax)
  801a0e:	89 c2                	mov    %eax,%edx
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	eb 09                	jmp    801a1e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	eb 05                	jmp    801a1e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a19:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a1e:	89 d0                	mov    %edx,%eax
  801a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2a:	83 ec 08             	sub    $0x8,%esp
  801a2d:	6a 00                	push   $0x0
  801a2f:	ff 75 08             	pushl  0x8(%ebp)
  801a32:	e8 e3 01 00 00       	call   801c1a <open>
  801a37:	89 c3                	mov    %eax,%ebx
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 1b                	js     801a5b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	ff 75 0c             	pushl  0xc(%ebp)
  801a46:	50                   	push   %eax
  801a47:	e8 5b ff ff ff       	call   8019a7 <fstat>
  801a4c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a4e:	89 1c 24             	mov    %ebx,(%esp)
  801a51:	e8 f4 fb ff ff       	call   80164a <close>
	return r;
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	89 f0                	mov    %esi,%eax
}
  801a5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5e:	5b                   	pop    %ebx
  801a5f:	5e                   	pop    %esi
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	89 c6                	mov    %eax,%esi
  801a69:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a6b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a72:	75 12                	jne    801a86 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	6a 01                	push   $0x1
  801a79:	e8 e4 f9 ff ff       	call   801462 <ipc_find_env>
  801a7e:	a3 00 40 80 00       	mov    %eax,0x804000
  801a83:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a86:	6a 07                	push   $0x7
  801a88:	68 00 50 80 00       	push   $0x805000
  801a8d:	56                   	push   %esi
  801a8e:	ff 35 00 40 80 00    	pushl  0x804000
  801a94:	e8 67 f9 ff ff       	call   801400 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a99:	83 c4 0c             	add    $0xc,%esp
  801a9c:	6a 00                	push   $0x0
  801a9e:	53                   	push   %ebx
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 df f8 ff ff       	call   801385 <ipc_recv>
}
  801aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  801acb:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad0:	e8 8d ff ff ff       	call   801a62 <fsipc>
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  801aed:	b8 06 00 00 00       	mov    $0x6,%eax
  801af2:	e8 6b ff ff ff       	call   801a62 <fsipc>
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	53                   	push   %ebx
  801afd:	83 ec 04             	sub    $0x4,%esp
  801b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	8b 40 0c             	mov    0xc(%eax),%eax
  801b09:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b13:	b8 05 00 00 00       	mov    $0x5,%eax
  801b18:	e8 45 ff ff ff       	call   801a62 <fsipc>
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 2c                	js     801b4d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	68 00 50 80 00       	push   $0x805000
  801b29:	53                   	push   %ebx
  801b2a:	e8 08 ed ff ff       	call   800837 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b2f:	a1 80 50 80 00       	mov    0x805080,%eax
  801b34:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b3a:	a1 84 50 80 00       	mov    0x805084,%eax
  801b3f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b5b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b5e:	8b 52 0c             	mov    0xc(%edx),%edx
  801b61:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b67:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b6c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b71:	0f 47 c2             	cmova  %edx,%eax
  801b74:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b79:	50                   	push   %eax
  801b7a:	ff 75 0c             	pushl  0xc(%ebp)
  801b7d:	68 08 50 80 00       	push   $0x805008
  801b82:	e8 42 ee ff ff       	call   8009c9 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b87:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b91:	e8 cc fe ff ff       	call   801a62 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb6:	b8 03 00 00 00       	mov    $0x3,%eax
  801bbb:	e8 a2 fe ff ff       	call   801a62 <fsipc>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 4b                	js     801c11 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bc6:	39 c6                	cmp    %eax,%esi
  801bc8:	73 16                	jae    801be0 <devfile_read+0x48>
  801bca:	68 5c 2a 80 00       	push   $0x802a5c
  801bcf:	68 63 2a 80 00       	push   $0x802a63
  801bd4:	6a 7c                	push   $0x7c
  801bd6:	68 78 2a 80 00       	push   $0x802a78
  801bdb:	e8 c6 05 00 00       	call   8021a6 <_panic>
	assert(r <= PGSIZE);
  801be0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be5:	7e 16                	jle    801bfd <devfile_read+0x65>
  801be7:	68 83 2a 80 00       	push   $0x802a83
  801bec:	68 63 2a 80 00       	push   $0x802a63
  801bf1:	6a 7d                	push   $0x7d
  801bf3:	68 78 2a 80 00       	push   $0x802a78
  801bf8:	e8 a9 05 00 00       	call   8021a6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bfd:	83 ec 04             	sub    $0x4,%esp
  801c00:	50                   	push   %eax
  801c01:	68 00 50 80 00       	push   $0x805000
  801c06:	ff 75 0c             	pushl  0xc(%ebp)
  801c09:	e8 bb ed ff ff       	call   8009c9 <memmove>
	return r;
  801c0e:	83 c4 10             	add    $0x10,%esp
}
  801c11:	89 d8                	mov    %ebx,%eax
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	53                   	push   %ebx
  801c1e:	83 ec 20             	sub    $0x20,%esp
  801c21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c24:	53                   	push   %ebx
  801c25:	e8 d4 eb ff ff       	call   8007fe <strlen>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c32:	7f 67                	jg     801c9b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c34:	83 ec 0c             	sub    $0xc,%esp
  801c37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3a:	50                   	push   %eax
  801c3b:	e8 8e f8 ff ff       	call   8014ce <fd_alloc>
  801c40:	83 c4 10             	add    $0x10,%esp
		return r;
  801c43:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 57                	js     801ca0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	53                   	push   %ebx
  801c4d:	68 00 50 80 00       	push   $0x805000
  801c52:	e8 e0 eb ff ff       	call   800837 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
  801c67:	e8 f6 fd ff ff       	call   801a62 <fsipc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	79 14                	jns    801c89 <open+0x6f>
		fd_close(fd, 0);
  801c75:	83 ec 08             	sub    $0x8,%esp
  801c78:	6a 00                	push   $0x0
  801c7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7d:	e8 47 f9 ff ff       	call   8015c9 <fd_close>
		return r;
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	89 da                	mov    %ebx,%edx
  801c87:	eb 17                	jmp    801ca0 <open+0x86>
	}

	return fd2num(fd);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8f:	e8 13 f8 ff ff       	call   8014a7 <fd2num>
  801c94:	89 c2                	mov    %eax,%edx
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	eb 05                	jmp    801ca0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c9b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ca0:	89 d0                	mov    %edx,%eax
  801ca2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cad:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb2:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb7:	e8 a6 fd ff ff       	call   801a62 <fsipc>
}
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	ff 75 08             	pushl  0x8(%ebp)
  801ccc:	e8 e6 f7 ff ff       	call   8014b7 <fd2data>
  801cd1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cd3:	83 c4 08             	add    $0x8,%esp
  801cd6:	68 8f 2a 80 00       	push   $0x802a8f
  801cdb:	53                   	push   %ebx
  801cdc:	e8 56 eb ff ff       	call   800837 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ce1:	8b 46 04             	mov    0x4(%esi),%eax
  801ce4:	2b 06                	sub    (%esi),%eax
  801ce6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cf3:	00 00 00 
	stat->st_dev = &devpipe;
  801cf6:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801cfd:	30 80 00 
	return 0;
}
  801d00:	b8 00 00 00 00       	mov    $0x0,%eax
  801d05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5e                   	pop    %esi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 0c             	sub    $0xc,%esp
  801d13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d16:	53                   	push   %ebx
  801d17:	6a 00                	push   $0x0
  801d19:	e8 a1 ef ff ff       	call   800cbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d1e:	89 1c 24             	mov    %ebx,(%esp)
  801d21:	e8 91 f7 ff ff       	call   8014b7 <fd2data>
  801d26:	83 c4 08             	add    $0x8,%esp
  801d29:	50                   	push   %eax
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 8e ef ff ff       	call   800cbf <sys_page_unmap>
}
  801d31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    

00801d36 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	57                   	push   %edi
  801d3a:	56                   	push   %esi
  801d3b:	53                   	push   %ebx
  801d3c:	83 ec 1c             	sub    $0x1c,%esp
  801d3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d42:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d44:	a1 04 40 80 00       	mov    0x804004,%eax
  801d49:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	ff 75 e0             	pushl  -0x20(%ebp)
  801d55:	e8 21 05 00 00       	call   80227b <pageref>
  801d5a:	89 c3                	mov    %eax,%ebx
  801d5c:	89 3c 24             	mov    %edi,(%esp)
  801d5f:	e8 17 05 00 00       	call   80227b <pageref>
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	39 c3                	cmp    %eax,%ebx
  801d69:	0f 94 c1             	sete   %cl
  801d6c:	0f b6 c9             	movzbl %cl,%ecx
  801d6f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d72:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d78:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801d7e:	39 ce                	cmp    %ecx,%esi
  801d80:	74 1e                	je     801da0 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d82:	39 c3                	cmp    %eax,%ebx
  801d84:	75 be                	jne    801d44 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d86:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801d8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d8f:	50                   	push   %eax
  801d90:	56                   	push   %esi
  801d91:	68 96 2a 80 00       	push   $0x802a96
  801d96:	e8 17 e5 ff ff       	call   8002b2 <cprintf>
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	eb a4                	jmp    801d44 <_pipeisclosed+0xe>
	}
}
  801da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da6:	5b                   	pop    %ebx
  801da7:	5e                   	pop    %esi
  801da8:	5f                   	pop    %edi
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	57                   	push   %edi
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 28             	sub    $0x28,%esp
  801db4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801db7:	56                   	push   %esi
  801db8:	e8 fa f6 ff ff       	call   8014b7 <fd2data>
  801dbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	bf 00 00 00 00       	mov    $0x0,%edi
  801dc7:	eb 4b                	jmp    801e14 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dc9:	89 da                	mov    %ebx,%edx
  801dcb:	89 f0                	mov    %esi,%eax
  801dcd:	e8 64 ff ff ff       	call   801d36 <_pipeisclosed>
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	75 48                	jne    801e1e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dd6:	e8 40 ee ff ff       	call   800c1b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ddb:	8b 43 04             	mov    0x4(%ebx),%eax
  801dde:	8b 0b                	mov    (%ebx),%ecx
  801de0:	8d 51 20             	lea    0x20(%ecx),%edx
  801de3:	39 d0                	cmp    %edx,%eax
  801de5:	73 e2                	jae    801dc9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	c1 fa 1f             	sar    $0x1f,%edx
  801df6:	89 d1                	mov    %edx,%ecx
  801df8:	c1 e9 1b             	shr    $0x1b,%ecx
  801dfb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dfe:	83 e2 1f             	and    $0x1f,%edx
  801e01:	29 ca                	sub    %ecx,%edx
  801e03:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e07:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e0b:	83 c0 01             	add    $0x1,%eax
  801e0e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e11:	83 c7 01             	add    $0x1,%edi
  801e14:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e17:	75 c2                	jne    801ddb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e19:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1c:	eb 05                	jmp    801e23 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e26:	5b                   	pop    %ebx
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	57                   	push   %edi
  801e2f:	56                   	push   %esi
  801e30:	53                   	push   %ebx
  801e31:	83 ec 18             	sub    $0x18,%esp
  801e34:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e37:	57                   	push   %edi
  801e38:	e8 7a f6 ff ff       	call   8014b7 <fd2data>
  801e3d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e47:	eb 3d                	jmp    801e86 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e49:	85 db                	test   %ebx,%ebx
  801e4b:	74 04                	je     801e51 <devpipe_read+0x26>
				return i;
  801e4d:	89 d8                	mov    %ebx,%eax
  801e4f:	eb 44                	jmp    801e95 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e51:	89 f2                	mov    %esi,%edx
  801e53:	89 f8                	mov    %edi,%eax
  801e55:	e8 dc fe ff ff       	call   801d36 <_pipeisclosed>
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	75 32                	jne    801e90 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e5e:	e8 b8 ed ff ff       	call   800c1b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e63:	8b 06                	mov    (%esi),%eax
  801e65:	3b 46 04             	cmp    0x4(%esi),%eax
  801e68:	74 df                	je     801e49 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e6a:	99                   	cltd   
  801e6b:	c1 ea 1b             	shr    $0x1b,%edx
  801e6e:	01 d0                	add    %edx,%eax
  801e70:	83 e0 1f             	and    $0x1f,%eax
  801e73:	29 d0                	sub    %edx,%eax
  801e75:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e7d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e80:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e83:	83 c3 01             	add    $0x1,%ebx
  801e86:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e89:	75 d8                	jne    801e63 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8e:	eb 05                	jmp    801e95 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	56                   	push   %esi
  801ea1:	53                   	push   %ebx
  801ea2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ea5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea8:	50                   	push   %eax
  801ea9:	e8 20 f6 ff ff       	call   8014ce <fd_alloc>
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	89 c2                	mov    %eax,%edx
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	0f 88 2c 01 00 00    	js     801fe7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebb:	83 ec 04             	sub    $0x4,%esp
  801ebe:	68 07 04 00 00       	push   $0x407
  801ec3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 6d ed ff ff       	call   800c3a <sys_page_alloc>
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	89 c2                	mov    %eax,%edx
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	0f 88 0d 01 00 00    	js     801fe7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ee0:	50                   	push   %eax
  801ee1:	e8 e8 f5 ff ff       	call   8014ce <fd_alloc>
  801ee6:	89 c3                	mov    %eax,%ebx
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	0f 88 e2 00 00 00    	js     801fd5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef3:	83 ec 04             	sub    $0x4,%esp
  801ef6:	68 07 04 00 00       	push   $0x407
  801efb:	ff 75 f0             	pushl  -0x10(%ebp)
  801efe:	6a 00                	push   $0x0
  801f00:	e8 35 ed ff ff       	call   800c3a <sys_page_alloc>
  801f05:	89 c3                	mov    %eax,%ebx
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	0f 88 c3 00 00 00    	js     801fd5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	ff 75 f4             	pushl  -0xc(%ebp)
  801f18:	e8 9a f5 ff ff       	call   8014b7 <fd2data>
  801f1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1f:	83 c4 0c             	add    $0xc,%esp
  801f22:	68 07 04 00 00       	push   $0x407
  801f27:	50                   	push   %eax
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 0b ed ff ff       	call   800c3a <sys_page_alloc>
  801f2f:	89 c3                	mov    %eax,%ebx
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	85 c0                	test   %eax,%eax
  801f36:	0f 88 89 00 00 00    	js     801fc5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f3c:	83 ec 0c             	sub    $0xc,%esp
  801f3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f42:	e8 70 f5 ff ff       	call   8014b7 <fd2data>
  801f47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f4e:	50                   	push   %eax
  801f4f:	6a 00                	push   $0x0
  801f51:	56                   	push   %esi
  801f52:	6a 00                	push   $0x0
  801f54:	e8 24 ed ff ff       	call   800c7d <sys_page_map>
  801f59:	89 c3                	mov    %eax,%ebx
  801f5b:	83 c4 20             	add    $0x20,%esp
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	78 55                	js     801fb7 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f62:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f70:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f77:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f80:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f8c:	83 ec 0c             	sub    $0xc,%esp
  801f8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f92:	e8 10 f5 ff ff       	call   8014a7 <fd2num>
  801f97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f9c:	83 c4 04             	add    $0x4,%esp
  801f9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa2:	e8 00 f5 ff ff       	call   8014a7 <fd2num>
  801fa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801faa:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb5:	eb 30                	jmp    801fe7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fb7:	83 ec 08             	sub    $0x8,%esp
  801fba:	56                   	push   %esi
  801fbb:	6a 00                	push   $0x0
  801fbd:	e8 fd ec ff ff       	call   800cbf <sys_page_unmap>
  801fc2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fc5:	83 ec 08             	sub    $0x8,%esp
  801fc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801fcb:	6a 00                	push   $0x0
  801fcd:	e8 ed ec ff ff       	call   800cbf <sys_page_unmap>
  801fd2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 dd ec ff ff       	call   800cbf <sys_page_unmap>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fe7:	89 d0                	mov    %edx,%eax
  801fe9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fec:	5b                   	pop    %ebx
  801fed:	5e                   	pop    %esi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	ff 75 08             	pushl  0x8(%ebp)
  801ffd:	e8 1b f5 ff ff       	call   80151d <fd_lookup>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 18                	js     802021 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802009:	83 ec 0c             	sub    $0xc,%esp
  80200c:	ff 75 f4             	pushl  -0xc(%ebp)
  80200f:	e8 a3 f4 ff ff       	call   8014b7 <fd2data>
	return _pipeisclosed(fd, p);
  802014:	89 c2                	mov    %eax,%edx
  802016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802019:	e8 18 fd ff ff       	call   801d36 <_pipeisclosed>
  80201e:	83 c4 10             	add    $0x10,%esp
}
  802021:	c9                   	leave  
  802022:	c3                   	ret    

00802023 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802026:	b8 00 00 00 00       	mov    $0x0,%eax
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802033:	68 ae 2a 80 00       	push   $0x802aae
  802038:	ff 75 0c             	pushl  0xc(%ebp)
  80203b:	e8 f7 e7 ff ff       	call   800837 <strcpy>
	return 0;
}
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	57                   	push   %edi
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802053:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802058:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80205e:	eb 2d                	jmp    80208d <devcons_write+0x46>
		m = n - tot;
  802060:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802063:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802065:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802068:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80206d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802070:	83 ec 04             	sub    $0x4,%esp
  802073:	53                   	push   %ebx
  802074:	03 45 0c             	add    0xc(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	57                   	push   %edi
  802079:	e8 4b e9 ff ff       	call   8009c9 <memmove>
		sys_cputs(buf, m);
  80207e:	83 c4 08             	add    $0x8,%esp
  802081:	53                   	push   %ebx
  802082:	57                   	push   %edi
  802083:	e8 f6 ea ff ff       	call   800b7e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802088:	01 de                	add    %ebx,%esi
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	89 f0                	mov    %esi,%eax
  80208f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802092:	72 cc                	jb     802060 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5f                   	pop    %edi
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    

0080209c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	83 ec 08             	sub    $0x8,%esp
  8020a2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020ab:	74 2a                	je     8020d7 <devcons_read+0x3b>
  8020ad:	eb 05                	jmp    8020b4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020af:	e8 67 eb ff ff       	call   800c1b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020b4:	e8 e3 ea ff ff       	call   800b9c <sys_cgetc>
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	74 f2                	je     8020af <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 16                	js     8020d7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020c1:	83 f8 04             	cmp    $0x4,%eax
  8020c4:	74 0c                	je     8020d2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c9:	88 02                	mov    %al,(%edx)
	return 1;
  8020cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d0:	eb 05                	jmp    8020d7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020d2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020d7:	c9                   	leave  
  8020d8:	c3                   	ret    

008020d9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020df:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020e5:	6a 01                	push   $0x1
  8020e7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ea:	50                   	push   %eax
  8020eb:	e8 8e ea ff ff       	call   800b7e <sys_cputs>
}
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    

008020f5 <getchar>:

int
getchar(void)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020fb:	6a 01                	push   $0x1
  8020fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802100:	50                   	push   %eax
  802101:	6a 00                	push   $0x0
  802103:	e8 7e f6 ff ff       	call   801786 <read>
	if (r < 0)
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	78 0f                	js     80211e <getchar+0x29>
		return r;
	if (r < 1)
  80210f:	85 c0                	test   %eax,%eax
  802111:	7e 06                	jle    802119 <getchar+0x24>
		return -E_EOF;
	return c;
  802113:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802117:	eb 05                	jmp    80211e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802119:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80211e:	c9                   	leave  
  80211f:	c3                   	ret    

00802120 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802129:	50                   	push   %eax
  80212a:	ff 75 08             	pushl  0x8(%ebp)
  80212d:	e8 eb f3 ff ff       	call   80151d <fd_lookup>
  802132:	83 c4 10             	add    $0x10,%esp
  802135:	85 c0                	test   %eax,%eax
  802137:	78 11                	js     80214a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213c:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802142:	39 10                	cmp    %edx,(%eax)
  802144:	0f 94 c0             	sete   %al
  802147:	0f b6 c0             	movzbl %al,%eax
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <opencons>:

int
opencons(void)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802155:	50                   	push   %eax
  802156:	e8 73 f3 ff ff       	call   8014ce <fd_alloc>
  80215b:	83 c4 10             	add    $0x10,%esp
		return r;
  80215e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802160:	85 c0                	test   %eax,%eax
  802162:	78 3e                	js     8021a2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802164:	83 ec 04             	sub    $0x4,%esp
  802167:	68 07 04 00 00       	push   $0x407
  80216c:	ff 75 f4             	pushl  -0xc(%ebp)
  80216f:	6a 00                	push   $0x0
  802171:	e8 c4 ea ff ff       	call   800c3a <sys_page_alloc>
  802176:	83 c4 10             	add    $0x10,%esp
		return r;
  802179:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80217b:	85 c0                	test   %eax,%eax
  80217d:	78 23                	js     8021a2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80217f:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802188:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80218a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802194:	83 ec 0c             	sub    $0xc,%esp
  802197:	50                   	push   %eax
  802198:	e8 0a f3 ff ff       	call   8014a7 <fd2num>
  80219d:	89 c2                	mov    %eax,%edx
  80219f:	83 c4 10             	add    $0x10,%esp
}
  8021a2:	89 d0                	mov    %edx,%eax
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	56                   	push   %esi
  8021aa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021ab:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021ae:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8021b4:	e8 43 ea ff ff       	call   800bfc <sys_getenvid>
  8021b9:	83 ec 0c             	sub    $0xc,%esp
  8021bc:	ff 75 0c             	pushl  0xc(%ebp)
  8021bf:	ff 75 08             	pushl  0x8(%ebp)
  8021c2:	56                   	push   %esi
  8021c3:	50                   	push   %eax
  8021c4:	68 bc 2a 80 00       	push   $0x802abc
  8021c9:	e8 e4 e0 ff ff       	call   8002b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021ce:	83 c4 18             	add    $0x18,%esp
  8021d1:	53                   	push   %ebx
  8021d2:	ff 75 10             	pushl  0x10(%ebp)
  8021d5:	e8 87 e0 ff ff       	call   800261 <vcprintf>
	cprintf("\n");
  8021da:	c7 04 24 9b 29 80 00 	movl   $0x80299b,(%esp)
  8021e1:	e8 cc e0 ff ff       	call   8002b2 <cprintf>
  8021e6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021e9:	cc                   	int3   
  8021ea:	eb fd                	jmp    8021e9 <_panic+0x43>

008021ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021f2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021f9:	75 2a                	jne    802225 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8021fb:	83 ec 04             	sub    $0x4,%esp
  8021fe:	6a 07                	push   $0x7
  802200:	68 00 f0 bf ee       	push   $0xeebff000
  802205:	6a 00                	push   $0x0
  802207:	e8 2e ea ff ff       	call   800c3a <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	85 c0                	test   %eax,%eax
  802211:	79 12                	jns    802225 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802213:	50                   	push   %eax
  802214:	68 b2 29 80 00       	push   $0x8029b2
  802219:	6a 23                	push   $0x23
  80221b:	68 e0 2a 80 00       	push   $0x802ae0
  802220:	e8 81 ff ff ff       	call   8021a6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802225:	8b 45 08             	mov    0x8(%ebp),%eax
  802228:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80222d:	83 ec 08             	sub    $0x8,%esp
  802230:	68 57 22 80 00       	push   $0x802257
  802235:	6a 00                	push   $0x0
  802237:	e8 49 eb ff ff       	call   800d85 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	85 c0                	test   %eax,%eax
  802241:	79 12                	jns    802255 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802243:	50                   	push   %eax
  802244:	68 b2 29 80 00       	push   $0x8029b2
  802249:	6a 2c                	push   $0x2c
  80224b:	68 e0 2a 80 00       	push   $0x802ae0
  802250:	e8 51 ff ff ff       	call   8021a6 <_panic>
	}
}
  802255:	c9                   	leave  
  802256:	c3                   	ret    

00802257 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802257:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802258:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80225d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80225f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802262:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802266:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80226b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80226f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802271:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802274:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802275:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802278:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802279:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80227a:	c3                   	ret    

0080227b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802281:	89 d0                	mov    %edx,%eax
  802283:	c1 e8 16             	shr    $0x16,%eax
  802286:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80228d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802292:	f6 c1 01             	test   $0x1,%cl
  802295:	74 1d                	je     8022b4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802297:	c1 ea 0c             	shr    $0xc,%edx
  80229a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022a1:	f6 c2 01             	test   $0x1,%dl
  8022a4:	74 0e                	je     8022b4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022a6:	c1 ea 0c             	shr    $0xc,%edx
  8022a9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022b0:	ef 
  8022b1:	0f b7 c0             	movzwl %ax,%eax
}
  8022b4:	5d                   	pop    %ebp
  8022b5:	c3                   	ret    
  8022b6:	66 90                	xchg   %ax,%ax
  8022b8:	66 90                	xchg   %ax,%ax
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__udivdi3>:
  8022c0:	55                   	push   %ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 1c             	sub    $0x1c,%esp
  8022c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022d7:	85 f6                	test   %esi,%esi
  8022d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022dd:	89 ca                	mov    %ecx,%edx
  8022df:	89 f8                	mov    %edi,%eax
  8022e1:	75 3d                	jne    802320 <__udivdi3+0x60>
  8022e3:	39 cf                	cmp    %ecx,%edi
  8022e5:	0f 87 c5 00 00 00    	ja     8023b0 <__udivdi3+0xf0>
  8022eb:	85 ff                	test   %edi,%edi
  8022ed:	89 fd                	mov    %edi,%ebp
  8022ef:	75 0b                	jne    8022fc <__udivdi3+0x3c>
  8022f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f6:	31 d2                	xor    %edx,%edx
  8022f8:	f7 f7                	div    %edi
  8022fa:	89 c5                	mov    %eax,%ebp
  8022fc:	89 c8                	mov    %ecx,%eax
  8022fe:	31 d2                	xor    %edx,%edx
  802300:	f7 f5                	div    %ebp
  802302:	89 c1                	mov    %eax,%ecx
  802304:	89 d8                	mov    %ebx,%eax
  802306:	89 cf                	mov    %ecx,%edi
  802308:	f7 f5                	div    %ebp
  80230a:	89 c3                	mov    %eax,%ebx
  80230c:	89 d8                	mov    %ebx,%eax
  80230e:	89 fa                	mov    %edi,%edx
  802310:	83 c4 1c             	add    $0x1c,%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5f                   	pop    %edi
  802316:	5d                   	pop    %ebp
  802317:	c3                   	ret    
  802318:	90                   	nop
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	39 ce                	cmp    %ecx,%esi
  802322:	77 74                	ja     802398 <__udivdi3+0xd8>
  802324:	0f bd fe             	bsr    %esi,%edi
  802327:	83 f7 1f             	xor    $0x1f,%edi
  80232a:	0f 84 98 00 00 00    	je     8023c8 <__udivdi3+0x108>
  802330:	bb 20 00 00 00       	mov    $0x20,%ebx
  802335:	89 f9                	mov    %edi,%ecx
  802337:	89 c5                	mov    %eax,%ebp
  802339:	29 fb                	sub    %edi,%ebx
  80233b:	d3 e6                	shl    %cl,%esi
  80233d:	89 d9                	mov    %ebx,%ecx
  80233f:	d3 ed                	shr    %cl,%ebp
  802341:	89 f9                	mov    %edi,%ecx
  802343:	d3 e0                	shl    %cl,%eax
  802345:	09 ee                	or     %ebp,%esi
  802347:	89 d9                	mov    %ebx,%ecx
  802349:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80234d:	89 d5                	mov    %edx,%ebp
  80234f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802353:	d3 ed                	shr    %cl,%ebp
  802355:	89 f9                	mov    %edi,%ecx
  802357:	d3 e2                	shl    %cl,%edx
  802359:	89 d9                	mov    %ebx,%ecx
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	09 c2                	or     %eax,%edx
  80235f:	89 d0                	mov    %edx,%eax
  802361:	89 ea                	mov    %ebp,%edx
  802363:	f7 f6                	div    %esi
  802365:	89 d5                	mov    %edx,%ebp
  802367:	89 c3                	mov    %eax,%ebx
  802369:	f7 64 24 0c          	mull   0xc(%esp)
  80236d:	39 d5                	cmp    %edx,%ebp
  80236f:	72 10                	jb     802381 <__udivdi3+0xc1>
  802371:	8b 74 24 08          	mov    0x8(%esp),%esi
  802375:	89 f9                	mov    %edi,%ecx
  802377:	d3 e6                	shl    %cl,%esi
  802379:	39 c6                	cmp    %eax,%esi
  80237b:	73 07                	jae    802384 <__udivdi3+0xc4>
  80237d:	39 d5                	cmp    %edx,%ebp
  80237f:	75 03                	jne    802384 <__udivdi3+0xc4>
  802381:	83 eb 01             	sub    $0x1,%ebx
  802384:	31 ff                	xor    %edi,%edi
  802386:	89 d8                	mov    %ebx,%eax
  802388:	89 fa                	mov    %edi,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	31 ff                	xor    %edi,%edi
  80239a:	31 db                	xor    %ebx,%ebx
  80239c:	89 d8                	mov    %ebx,%eax
  80239e:	89 fa                	mov    %edi,%edx
  8023a0:	83 c4 1c             	add    $0x1c,%esp
  8023a3:	5b                   	pop    %ebx
  8023a4:	5e                   	pop    %esi
  8023a5:	5f                   	pop    %edi
  8023a6:	5d                   	pop    %ebp
  8023a7:	c3                   	ret    
  8023a8:	90                   	nop
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	89 d8                	mov    %ebx,%eax
  8023b2:	f7 f7                	div    %edi
  8023b4:	31 ff                	xor    %edi,%edi
  8023b6:	89 c3                	mov    %eax,%ebx
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	89 fa                	mov    %edi,%edx
  8023bc:	83 c4 1c             	add    $0x1c,%esp
  8023bf:	5b                   	pop    %ebx
  8023c0:	5e                   	pop    %esi
  8023c1:	5f                   	pop    %edi
  8023c2:	5d                   	pop    %ebp
  8023c3:	c3                   	ret    
  8023c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	39 ce                	cmp    %ecx,%esi
  8023ca:	72 0c                	jb     8023d8 <__udivdi3+0x118>
  8023cc:	31 db                	xor    %ebx,%ebx
  8023ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023d2:	0f 87 34 ff ff ff    	ja     80230c <__udivdi3+0x4c>
  8023d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023dd:	e9 2a ff ff ff       	jmp    80230c <__udivdi3+0x4c>
  8023e2:	66 90                	xchg   %ax,%ax
  8023e4:	66 90                	xchg   %ax,%ax
  8023e6:	66 90                	xchg   %ax,%ax
  8023e8:	66 90                	xchg   %ax,%ax
  8023ea:	66 90                	xchg   %ax,%ax
  8023ec:	66 90                	xchg   %ax,%ax
  8023ee:	66 90                	xchg   %ax,%ax

008023f0 <__umoddi3>:
  8023f0:	55                   	push   %ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	53                   	push   %ebx
  8023f4:	83 ec 1c             	sub    $0x1c,%esp
  8023f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802403:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802407:	85 d2                	test   %edx,%edx
  802409:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80240d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802411:	89 f3                	mov    %esi,%ebx
  802413:	89 3c 24             	mov    %edi,(%esp)
  802416:	89 74 24 04          	mov    %esi,0x4(%esp)
  80241a:	75 1c                	jne    802438 <__umoddi3+0x48>
  80241c:	39 f7                	cmp    %esi,%edi
  80241e:	76 50                	jbe    802470 <__umoddi3+0x80>
  802420:	89 c8                	mov    %ecx,%eax
  802422:	89 f2                	mov    %esi,%edx
  802424:	f7 f7                	div    %edi
  802426:	89 d0                	mov    %edx,%eax
  802428:	31 d2                	xor    %edx,%edx
  80242a:	83 c4 1c             	add    $0x1c,%esp
  80242d:	5b                   	pop    %ebx
  80242e:	5e                   	pop    %esi
  80242f:	5f                   	pop    %edi
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    
  802432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802438:	39 f2                	cmp    %esi,%edx
  80243a:	89 d0                	mov    %edx,%eax
  80243c:	77 52                	ja     802490 <__umoddi3+0xa0>
  80243e:	0f bd ea             	bsr    %edx,%ebp
  802441:	83 f5 1f             	xor    $0x1f,%ebp
  802444:	75 5a                	jne    8024a0 <__umoddi3+0xb0>
  802446:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80244a:	0f 82 e0 00 00 00    	jb     802530 <__umoddi3+0x140>
  802450:	39 0c 24             	cmp    %ecx,(%esp)
  802453:	0f 86 d7 00 00 00    	jbe    802530 <__umoddi3+0x140>
  802459:	8b 44 24 08          	mov    0x8(%esp),%eax
  80245d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802461:	83 c4 1c             	add    $0x1c,%esp
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	85 ff                	test   %edi,%edi
  802472:	89 fd                	mov    %edi,%ebp
  802474:	75 0b                	jne    802481 <__umoddi3+0x91>
  802476:	b8 01 00 00 00       	mov    $0x1,%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	f7 f7                	div    %edi
  80247f:	89 c5                	mov    %eax,%ebp
  802481:	89 f0                	mov    %esi,%eax
  802483:	31 d2                	xor    %edx,%edx
  802485:	f7 f5                	div    %ebp
  802487:	89 c8                	mov    %ecx,%eax
  802489:	f7 f5                	div    %ebp
  80248b:	89 d0                	mov    %edx,%eax
  80248d:	eb 99                	jmp    802428 <__umoddi3+0x38>
  80248f:	90                   	nop
  802490:	89 c8                	mov    %ecx,%eax
  802492:	89 f2                	mov    %esi,%edx
  802494:	83 c4 1c             	add    $0x1c,%esp
  802497:	5b                   	pop    %ebx
  802498:	5e                   	pop    %esi
  802499:	5f                   	pop    %edi
  80249a:	5d                   	pop    %ebp
  80249b:	c3                   	ret    
  80249c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	8b 34 24             	mov    (%esp),%esi
  8024a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024a8:	89 e9                	mov    %ebp,%ecx
  8024aa:	29 ef                	sub    %ebp,%edi
  8024ac:	d3 e0                	shl    %cl,%eax
  8024ae:	89 f9                	mov    %edi,%ecx
  8024b0:	89 f2                	mov    %esi,%edx
  8024b2:	d3 ea                	shr    %cl,%edx
  8024b4:	89 e9                	mov    %ebp,%ecx
  8024b6:	09 c2                	or     %eax,%edx
  8024b8:	89 d8                	mov    %ebx,%eax
  8024ba:	89 14 24             	mov    %edx,(%esp)
  8024bd:	89 f2                	mov    %esi,%edx
  8024bf:	d3 e2                	shl    %cl,%edx
  8024c1:	89 f9                	mov    %edi,%ecx
  8024c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	89 e9                	mov    %ebp,%ecx
  8024cf:	89 c6                	mov    %eax,%esi
  8024d1:	d3 e3                	shl    %cl,%ebx
  8024d3:	89 f9                	mov    %edi,%ecx
  8024d5:	89 d0                	mov    %edx,%eax
  8024d7:	d3 e8                	shr    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	09 d8                	or     %ebx,%eax
  8024dd:	89 d3                	mov    %edx,%ebx
  8024df:	89 f2                	mov    %esi,%edx
  8024e1:	f7 34 24             	divl   (%esp)
  8024e4:	89 d6                	mov    %edx,%esi
  8024e6:	d3 e3                	shl    %cl,%ebx
  8024e8:	f7 64 24 04          	mull   0x4(%esp)
  8024ec:	39 d6                	cmp    %edx,%esi
  8024ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024f2:	89 d1                	mov    %edx,%ecx
  8024f4:	89 c3                	mov    %eax,%ebx
  8024f6:	72 08                	jb     802500 <__umoddi3+0x110>
  8024f8:	75 11                	jne    80250b <__umoddi3+0x11b>
  8024fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024fe:	73 0b                	jae    80250b <__umoddi3+0x11b>
  802500:	2b 44 24 04          	sub    0x4(%esp),%eax
  802504:	1b 14 24             	sbb    (%esp),%edx
  802507:	89 d1                	mov    %edx,%ecx
  802509:	89 c3                	mov    %eax,%ebx
  80250b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80250f:	29 da                	sub    %ebx,%edx
  802511:	19 ce                	sbb    %ecx,%esi
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 f0                	mov    %esi,%eax
  802517:	d3 e0                	shl    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	d3 ea                	shr    %cl,%edx
  80251d:	89 e9                	mov    %ebp,%ecx
  80251f:	d3 ee                	shr    %cl,%esi
  802521:	09 d0                	or     %edx,%eax
  802523:	89 f2                	mov    %esi,%edx
  802525:	83 c4 1c             	add    $0x1c,%esp
  802528:	5b                   	pop    %ebx
  802529:	5e                   	pop    %esi
  80252a:	5f                   	pop    %edi
  80252b:	5d                   	pop    %ebp
  80252c:	c3                   	ret    
  80252d:	8d 76 00             	lea    0x0(%esi),%esi
  802530:	29 f9                	sub    %edi,%ecx
  802532:	19 d6                	sbb    %edx,%esi
  802534:	89 74 24 04          	mov    %esi,0x4(%esp)
  802538:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80253c:	e9 18 ff ff ff       	jmp    802459 <__umoddi3+0x69>
