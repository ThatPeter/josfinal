
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
  800057:	e8 49 11 00 00       	call   8011a5 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 80 23 80 00       	push   $0x802380
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
  80009d:	68 94 23 80 00       	push   $0x802394
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
  8000db:	e8 40 11 00 00       	call   801220 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 b2 00 00 00       	jmp    80019a <umain+0x167>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
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
  800134:	e8 e7 10 00 00       	call   801220 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800139:	83 c4 1c             	add    $0x1c,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	68 00 00 a0 00       	push   $0xa00000
  800143:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	e8 59 10 00 00       	call   8011a5 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80014c:	83 c4 0c             	add    $0xc,%esp
  80014f:	68 00 00 a0 00       	push   $0xa00000
  800154:	ff 75 f4             	pushl  -0xc(%ebp)
  800157:	68 80 23 80 00       	push   $0x802380
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
  80018d:	68 b4 23 80 00       	push   $0x8023b4
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
  8001b1:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8001b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001bc:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80020b:	e8 85 12 00 00       	call   801495 <close_all>
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
  800315:	e8 c6 1d 00 00       	call   8020e0 <__udivdi3>
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
  800358:	e8 b3 1e 00 00       	call   802210 <__umoddi3>
  80035d:	83 c4 14             	add    $0x14,%esp
  800360:	0f be 80 2c 24 80 00 	movsbl 0x80242c(%eax),%eax
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
  80045c:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
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
  800520:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	75 18                	jne    800543 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052b:	50                   	push   %eax
  80052c:	68 44 24 80 00       	push   $0x802444
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
  800544:	68 85 28 80 00       	push   $0x802885
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
  800568:	b8 3d 24 80 00       	mov    $0x80243d,%eax
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
  800be3:	68 1f 27 80 00       	push   $0x80271f
  800be8:	6a 23                	push   $0x23
  800bea:	68 3c 27 80 00       	push   $0x80273c
  800bef:	e8 d2 13 00 00       	call   801fc6 <_panic>

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
  800c64:	68 1f 27 80 00       	push   $0x80271f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 3c 27 80 00       	push   $0x80273c
  800c70:	e8 51 13 00 00       	call   801fc6 <_panic>

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
  800ca6:	68 1f 27 80 00       	push   $0x80271f
  800cab:	6a 23                	push   $0x23
  800cad:	68 3c 27 80 00       	push   $0x80273c
  800cb2:	e8 0f 13 00 00       	call   801fc6 <_panic>

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
  800ce8:	68 1f 27 80 00       	push   $0x80271f
  800ced:	6a 23                	push   $0x23
  800cef:	68 3c 27 80 00       	push   $0x80273c
  800cf4:	e8 cd 12 00 00       	call   801fc6 <_panic>

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
  800d2a:	68 1f 27 80 00       	push   $0x80271f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 3c 27 80 00       	push   $0x80273c
  800d36:	e8 8b 12 00 00       	call   801fc6 <_panic>

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
  800d6c:	68 1f 27 80 00       	push   $0x80271f
  800d71:	6a 23                	push   $0x23
  800d73:	68 3c 27 80 00       	push   $0x80273c
  800d78:	e8 49 12 00 00       	call   801fc6 <_panic>
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
  800dae:	68 1f 27 80 00       	push   $0x80271f
  800db3:	6a 23                	push   $0x23
  800db5:	68 3c 27 80 00       	push   $0x80273c
  800dba:	e8 07 12 00 00       	call   801fc6 <_panic>

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
  800e12:	68 1f 27 80 00       	push   $0x80271f
  800e17:	6a 23                	push   $0x23
  800e19:	68 3c 27 80 00       	push   $0x80273c
  800e1e:	e8 a3 11 00 00       	call   801fc6 <_panic>

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
  800eb1:	68 4a 27 80 00       	push   $0x80274a
  800eb6:	6a 1e                	push   $0x1e
  800eb8:	68 5a 27 80 00       	push   $0x80275a
  800ebd:	e8 04 11 00 00       	call   801fc6 <_panic>
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
  800edb:	68 65 27 80 00       	push   $0x802765
  800ee0:	6a 2c                	push   $0x2c
  800ee2:	68 5a 27 80 00       	push   $0x80275a
  800ee7:	e8 da 10 00 00       	call   801fc6 <_panic>
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
  800f23:	68 65 27 80 00       	push   $0x802765
  800f28:	6a 33                	push   $0x33
  800f2a:	68 5a 27 80 00       	push   $0x80275a
  800f2f:	e8 92 10 00 00       	call   801fc6 <_panic>
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
  800f4b:	68 65 27 80 00       	push   $0x802765
  800f50:	6a 37                	push   $0x37
  800f52:	68 5a 27 80 00       	push   $0x80275a
  800f57:	e8 6a 10 00 00       	call   801fc6 <_panic>
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
  800f6f:	e8 98 10 00 00       	call   80200c <set_pgfault_handler>
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
  800f88:	68 7e 27 80 00       	push   $0x80277e
  800f8d:	68 84 00 00 00       	push   $0x84
  800f92:	68 5a 27 80 00       	push   $0x80275a
  800f97:	e8 2a 10 00 00       	call   801fc6 <_panic>
  800f9c:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f9e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fa2:	75 24                	jne    800fc8 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa4:	e8 53 fc ff ff       	call   800bfc <sys_getenvid>
  800fa9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fae:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  801044:	68 8c 27 80 00       	push   $0x80278c
  801049:	6a 54                	push   $0x54
  80104b:	68 5a 27 80 00       	push   $0x80275a
  801050:	e8 71 0f 00 00       	call   801fc6 <_panic>
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
  801089:	68 8c 27 80 00       	push   $0x80278c
  80108e:	6a 5b                	push   $0x5b
  801090:	68 5a 27 80 00       	push   $0x80275a
  801095:	e8 2c 0f 00 00       	call   801fc6 <_panic>
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
  8010b7:	68 8c 27 80 00       	push   $0x80278c
  8010bc:	6a 5f                	push   $0x5f
  8010be:	68 5a 27 80 00       	push   $0x80275a
  8010c3:	e8 fe 0e 00 00       	call   801fc6 <_panic>
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
  8010e1:	68 8c 27 80 00       	push   $0x80278c
  8010e6:	6a 64                	push   $0x64
  8010e8:	68 5a 27 80 00       	push   $0x80275a
  8010ed:	e8 d4 0e 00 00       	call   801fc6 <_panic>
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
  801109:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801146:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	53                   	push   %ebx
  801150:	68 a4 27 80 00       	push   $0x8027a4
  801155:	e8 58 f1 ff ff       	call   8002b2 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80115a:	c7 04 24 e5 01 80 00 	movl   $0x8001e5,(%esp)
  801161:	e8 c5 fc ff ff       	call   800e2b <sys_thread_create>
  801166:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801168:	83 c4 08             	add    $0x8,%esp
  80116b:	53                   	push   %ebx
  80116c:	68 a4 27 80 00       	push   $0x8027a4
  801171:	e8 3c f1 ff ff       	call   8002b2 <cprintf>
	return id;
}
  801176:	89 f0                	mov    %esi,%eax
  801178:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801185:	ff 75 08             	pushl  0x8(%ebp)
  801188:	e8 be fc ff ff       	call   800e4b <sys_thread_free>
}
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801198:	ff 75 08             	pushl  0x8(%ebp)
  80119b:	e8 cb fc ff ff       	call   800e6b <sys_thread_join>
}
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	75 12                	jne    8011c9 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	68 00 00 c0 ee       	push   $0xeec00000
  8011bf:	e8 26 fc ff ff       	call   800dea <sys_ipc_recv>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	eb 0c                	jmp    8011d5 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	50                   	push   %eax
  8011cd:	e8 18 fc ff ff       	call   800dea <sys_ipc_recv>
  8011d2:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8011d5:	85 f6                	test   %esi,%esi
  8011d7:	0f 95 c1             	setne  %cl
  8011da:	85 db                	test   %ebx,%ebx
  8011dc:	0f 95 c2             	setne  %dl
  8011df:	84 d1                	test   %dl,%cl
  8011e1:	74 09                	je     8011ec <ipc_recv+0x47>
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	c1 ea 1f             	shr    $0x1f,%edx
  8011e8:	84 d2                	test   %dl,%dl
  8011ea:	75 2d                	jne    801219 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8011ec:	85 f6                	test   %esi,%esi
  8011ee:	74 0d                	je     8011fd <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8011f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f5:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8011fb:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8011fd:	85 db                	test   %ebx,%ebx
  8011ff:	74 0d                	je     80120e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801201:	a1 04 40 80 00       	mov    0x804004,%eax
  801206:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80120c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80120e:	a1 04 40 80 00       	mov    0x804004,%eax
  801213:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801219:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80122f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801232:	85 db                	test   %ebx,%ebx
  801234:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801239:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80123c:	ff 75 14             	pushl  0x14(%ebp)
  80123f:	53                   	push   %ebx
  801240:	56                   	push   %esi
  801241:	57                   	push   %edi
  801242:	e8 80 fb ff ff       	call   800dc7 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801247:	89 c2                	mov    %eax,%edx
  801249:	c1 ea 1f             	shr    $0x1f,%edx
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	84 d2                	test   %dl,%dl
  801251:	74 17                	je     80126a <ipc_send+0x4a>
  801253:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801256:	74 12                	je     80126a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801258:	50                   	push   %eax
  801259:	68 c7 27 80 00       	push   $0x8027c7
  80125e:	6a 47                	push   $0x47
  801260:	68 d5 27 80 00       	push   $0x8027d5
  801265:	e8 5c 0d 00 00       	call   801fc6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80126a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80126d:	75 07                	jne    801276 <ipc_send+0x56>
			sys_yield();
  80126f:	e8 a7 f9 ff ff       	call   800c1b <sys_yield>
  801274:	eb c6                	jmp    80123c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801276:	85 c0                	test   %eax,%eax
  801278:	75 c2                	jne    80123c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80128d:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801293:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801299:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80129f:	39 ca                	cmp    %ecx,%edx
  8012a1:	75 13                	jne    8012b6 <ipc_find_env+0x34>
			return envs[i].env_id;
  8012a3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8012a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012ae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8012b4:	eb 0f                	jmp    8012c5 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012b6:	83 c0 01             	add    $0x1,%eax
  8012b9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012be:	75 cd                	jne    80128d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d2:	c1 e8 0c             	shr    $0xc,%eax
}
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dd:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012e7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 ea 16             	shr    $0x16,%edx
  8012fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801305:	f6 c2 01             	test   $0x1,%dl
  801308:	74 11                	je     80131b <fd_alloc+0x2d>
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	c1 ea 0c             	shr    $0xc,%edx
  80130f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	75 09                	jne    801324 <fd_alloc+0x36>
			*fd_store = fd;
  80131b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	eb 17                	jmp    80133b <fd_alloc+0x4d>
  801324:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801329:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80132e:	75 c9                	jne    8012f9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801330:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801336:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801343:	83 f8 1f             	cmp    $0x1f,%eax
  801346:	77 36                	ja     80137e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801348:	c1 e0 0c             	shl    $0xc,%eax
  80134b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801350:	89 c2                	mov    %eax,%edx
  801352:	c1 ea 16             	shr    $0x16,%edx
  801355:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135c:	f6 c2 01             	test   $0x1,%dl
  80135f:	74 24                	je     801385 <fd_lookup+0x48>
  801361:	89 c2                	mov    %eax,%edx
  801363:	c1 ea 0c             	shr    $0xc,%edx
  801366:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136d:	f6 c2 01             	test   $0x1,%dl
  801370:	74 1a                	je     80138c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801372:	8b 55 0c             	mov    0xc(%ebp),%edx
  801375:	89 02                	mov    %eax,(%edx)
	return 0;
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
  80137c:	eb 13                	jmp    801391 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801383:	eb 0c                	jmp    801391 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801385:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138a:	eb 05                	jmp    801391 <fd_lookup+0x54>
  80138c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    

00801393 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139c:	ba 5c 28 80 00       	mov    $0x80285c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a1:	eb 13                	jmp    8013b6 <dev_lookup+0x23>
  8013a3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013a6:	39 08                	cmp    %ecx,(%eax)
  8013a8:	75 0c                	jne    8013b6 <dev_lookup+0x23>
			*dev = devtab[i];
  8013aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ad:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013af:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b4:	eb 31                	jmp    8013e7 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013b6:	8b 02                	mov    (%edx),%eax
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	75 e7                	jne    8013a3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013c7:	83 ec 04             	sub    $0x4,%esp
  8013ca:	51                   	push   %ecx
  8013cb:	50                   	push   %eax
  8013cc:	68 e0 27 80 00       	push   $0x8027e0
  8013d1:	e8 dc ee ff ff       	call   8002b2 <cprintf>
	*dev = 0;
  8013d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 10             	sub    $0x10,%esp
  8013f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801401:	c1 e8 0c             	shr    $0xc,%eax
  801404:	50                   	push   %eax
  801405:	e8 33 ff ff ff       	call   80133d <fd_lookup>
  80140a:	83 c4 08             	add    $0x8,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 05                	js     801416 <fd_close+0x2d>
	    || fd != fd2)
  801411:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801414:	74 0c                	je     801422 <fd_close+0x39>
		return (must_exist ? r : 0);
  801416:	84 db                	test   %bl,%bl
  801418:	ba 00 00 00 00       	mov    $0x0,%edx
  80141d:	0f 44 c2             	cmove  %edx,%eax
  801420:	eb 41                	jmp    801463 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801422:	83 ec 08             	sub    $0x8,%esp
  801425:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	ff 36                	pushl  (%esi)
  80142b:	e8 63 ff ff ff       	call   801393 <dev_lookup>
  801430:	89 c3                	mov    %eax,%ebx
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 1a                	js     801453 <fd_close+0x6a>
		if (dev->dev_close)
  801439:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80143f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801444:	85 c0                	test   %eax,%eax
  801446:	74 0b                	je     801453 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801448:	83 ec 0c             	sub    $0xc,%esp
  80144b:	56                   	push   %esi
  80144c:	ff d0                	call   *%eax
  80144e:	89 c3                	mov    %eax,%ebx
  801450:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	56                   	push   %esi
  801457:	6a 00                	push   $0x0
  801459:	e8 61 f8 ff ff       	call   800cbf <sys_page_unmap>
	return r;
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	89 d8                	mov    %ebx,%eax
}
  801463:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801466:	5b                   	pop    %ebx
  801467:	5e                   	pop    %esi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 75 08             	pushl  0x8(%ebp)
  801477:	e8 c1 fe ff ff       	call   80133d <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 10                	js     801493 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	6a 01                	push   $0x1
  801488:	ff 75 f4             	pushl  -0xc(%ebp)
  80148b:	e8 59 ff ff ff       	call   8013e9 <fd_close>
  801490:	83 c4 10             	add    $0x10,%esp
}
  801493:	c9                   	leave  
  801494:	c3                   	ret    

00801495 <close_all>:

void
close_all(void)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	53                   	push   %ebx
  801499:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80149c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	e8 c0 ff ff ff       	call   80146a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014aa:	83 c3 01             	add    $0x1,%ebx
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	83 fb 20             	cmp    $0x20,%ebx
  8014b3:	75 ec                	jne    8014a1 <close_all+0xc>
		close(i);
}
  8014b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	57                   	push   %edi
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 2c             	sub    $0x2c,%esp
  8014c3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	ff 75 08             	pushl  0x8(%ebp)
  8014cd:	e8 6b fe ff ff       	call   80133d <fd_lookup>
  8014d2:	83 c4 08             	add    $0x8,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	0f 88 c1 00 00 00    	js     80159e <dup+0xe4>
		return r;
	close(newfdnum);
  8014dd:	83 ec 0c             	sub    $0xc,%esp
  8014e0:	56                   	push   %esi
  8014e1:	e8 84 ff ff ff       	call   80146a <close>

	newfd = INDEX2FD(newfdnum);
  8014e6:	89 f3                	mov    %esi,%ebx
  8014e8:	c1 e3 0c             	shl    $0xc,%ebx
  8014eb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f1:	83 c4 04             	add    $0x4,%esp
  8014f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014f7:	e8 db fd ff ff       	call   8012d7 <fd2data>
  8014fc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014fe:	89 1c 24             	mov    %ebx,(%esp)
  801501:	e8 d1 fd ff ff       	call   8012d7 <fd2data>
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80150c:	89 f8                	mov    %edi,%eax
  80150e:	c1 e8 16             	shr    $0x16,%eax
  801511:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801518:	a8 01                	test   $0x1,%al
  80151a:	74 37                	je     801553 <dup+0x99>
  80151c:	89 f8                	mov    %edi,%eax
  80151e:	c1 e8 0c             	shr    $0xc,%eax
  801521:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801528:	f6 c2 01             	test   $0x1,%dl
  80152b:	74 26                	je     801553 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801534:	83 ec 0c             	sub    $0xc,%esp
  801537:	25 07 0e 00 00       	and    $0xe07,%eax
  80153c:	50                   	push   %eax
  80153d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801540:	6a 00                	push   $0x0
  801542:	57                   	push   %edi
  801543:	6a 00                	push   $0x0
  801545:	e8 33 f7 ff ff       	call   800c7d <sys_page_map>
  80154a:	89 c7                	mov    %eax,%edi
  80154c:	83 c4 20             	add    $0x20,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 2e                	js     801581 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801553:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801556:	89 d0                	mov    %edx,%eax
  801558:	c1 e8 0c             	shr    $0xc,%eax
  80155b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	25 07 0e 00 00       	and    $0xe07,%eax
  80156a:	50                   	push   %eax
  80156b:	53                   	push   %ebx
  80156c:	6a 00                	push   $0x0
  80156e:	52                   	push   %edx
  80156f:	6a 00                	push   $0x0
  801571:	e8 07 f7 ff ff       	call   800c7d <sys_page_map>
  801576:	89 c7                	mov    %eax,%edi
  801578:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80157b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157d:	85 ff                	test   %edi,%edi
  80157f:	79 1d                	jns    80159e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	6a 00                	push   $0x0
  801587:	e8 33 f7 ff ff       	call   800cbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801592:	6a 00                	push   $0x0
  801594:	e8 26 f7 ff ff       	call   800cbf <sys_page_unmap>
	return r;
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	89 f8                	mov    %edi,%eax
}
  80159e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5f                   	pop    %edi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    

008015a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 14             	sub    $0x14,%esp
  8015ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	53                   	push   %ebx
  8015b5:	e8 83 fd ff ff       	call   80133d <fd_lookup>
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 70                	js     801633 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cd:	ff 30                	pushl  (%eax)
  8015cf:	e8 bf fd ff ff       	call   801393 <dev_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 4f                	js     80162a <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015de:	8b 42 08             	mov    0x8(%edx),%eax
  8015e1:	83 e0 03             	and    $0x3,%eax
  8015e4:	83 f8 01             	cmp    $0x1,%eax
  8015e7:	75 24                	jne    80160d <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ee:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015f4:	83 ec 04             	sub    $0x4,%esp
  8015f7:	53                   	push   %ebx
  8015f8:	50                   	push   %eax
  8015f9:	68 21 28 80 00       	push   $0x802821
  8015fe:	e8 af ec ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160b:	eb 26                	jmp    801633 <read+0x8d>
	}
	if (!dev->dev_read)
  80160d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801610:	8b 40 08             	mov    0x8(%eax),%eax
  801613:	85 c0                	test   %eax,%eax
  801615:	74 17                	je     80162e <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801617:	83 ec 04             	sub    $0x4,%esp
  80161a:	ff 75 10             	pushl  0x10(%ebp)
  80161d:	ff 75 0c             	pushl  0xc(%ebp)
  801620:	52                   	push   %edx
  801621:	ff d0                	call   *%eax
  801623:	89 c2                	mov    %eax,%edx
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	eb 09                	jmp    801633 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	eb 05                	jmp    801633 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80162e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801633:	89 d0                	mov    %edx,%eax
  801635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	57                   	push   %edi
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
  801640:	83 ec 0c             	sub    $0xc,%esp
  801643:	8b 7d 08             	mov    0x8(%ebp),%edi
  801646:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801649:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164e:	eb 21                	jmp    801671 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801650:	83 ec 04             	sub    $0x4,%esp
  801653:	89 f0                	mov    %esi,%eax
  801655:	29 d8                	sub    %ebx,%eax
  801657:	50                   	push   %eax
  801658:	89 d8                	mov    %ebx,%eax
  80165a:	03 45 0c             	add    0xc(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	57                   	push   %edi
  80165f:	e8 42 ff ff ff       	call   8015a6 <read>
		if (m < 0)
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	78 10                	js     80167b <readn+0x41>
			return m;
		if (m == 0)
  80166b:	85 c0                	test   %eax,%eax
  80166d:	74 0a                	je     801679 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80166f:	01 c3                	add    %eax,%ebx
  801671:	39 f3                	cmp    %esi,%ebx
  801673:	72 db                	jb     801650 <readn+0x16>
  801675:	89 d8                	mov    %ebx,%eax
  801677:	eb 02                	jmp    80167b <readn+0x41>
  801679:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5f                   	pop    %edi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	53                   	push   %ebx
  801692:	e8 a6 fc ff ff       	call   80133d <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 6b                	js     80170b <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	e8 e2 fc ff ff       	call   801393 <dev_lookup>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 4a                	js     801702 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bf:	75 24                	jne    8016e5 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016cc:	83 ec 04             	sub    $0x4,%esp
  8016cf:	53                   	push   %ebx
  8016d0:	50                   	push   %eax
  8016d1:	68 3d 28 80 00       	push   $0x80283d
  8016d6:	e8 d7 eb ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e3:	eb 26                	jmp    80170b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016eb:	85 d2                	test   %edx,%edx
  8016ed:	74 17                	je     801706 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	ff 75 10             	pushl  0x10(%ebp)
  8016f5:	ff 75 0c             	pushl  0xc(%ebp)
  8016f8:	50                   	push   %eax
  8016f9:	ff d2                	call   *%edx
  8016fb:	89 c2                	mov    %eax,%edx
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	eb 09                	jmp    80170b <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801702:	89 c2                	mov    %eax,%edx
  801704:	eb 05                	jmp    80170b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801706:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80170b:	89 d0                	mov    %edx,%eax
  80170d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <seek>:

int
seek(int fdnum, off_t offset)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801718:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	ff 75 08             	pushl  0x8(%ebp)
  80171f:	e8 19 fc ff ff       	call   80133d <fd_lookup>
  801724:	83 c4 08             	add    $0x8,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 0e                	js     801739 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80172e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801731:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801734:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	53                   	push   %ebx
  80173f:	83 ec 14             	sub    $0x14,%esp
  801742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801748:	50                   	push   %eax
  801749:	53                   	push   %ebx
  80174a:	e8 ee fb ff ff       	call   80133d <fd_lookup>
  80174f:	83 c4 08             	add    $0x8,%esp
  801752:	89 c2                	mov    %eax,%edx
  801754:	85 c0                	test   %eax,%eax
  801756:	78 68                	js     8017c0 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801762:	ff 30                	pushl  (%eax)
  801764:	e8 2a fc ff ff       	call   801393 <dev_lookup>
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 47                	js     8017b7 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801777:	75 24                	jne    80179d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801779:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80177e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801784:	83 ec 04             	sub    $0x4,%esp
  801787:	53                   	push   %ebx
  801788:	50                   	push   %eax
  801789:	68 00 28 80 00       	push   $0x802800
  80178e:	e8 1f eb ff ff       	call   8002b2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80179b:	eb 23                	jmp    8017c0 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80179d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a0:	8b 52 18             	mov    0x18(%edx),%edx
  8017a3:	85 d2                	test   %edx,%edx
  8017a5:	74 14                	je     8017bb <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	50                   	push   %eax
  8017ae:	ff d2                	call   *%edx
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb 09                	jmp    8017c0 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	eb 05                	jmp    8017c0 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c0:	89 d0                	mov    %edx,%eax
  8017c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 14             	sub    $0x14,%esp
  8017ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d4:	50                   	push   %eax
  8017d5:	ff 75 08             	pushl  0x8(%ebp)
  8017d8:	e8 60 fb ff ff       	call   80133d <fd_lookup>
  8017dd:	83 c4 08             	add    $0x8,%esp
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 58                	js     80183e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ec:	50                   	push   %eax
  8017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f0:	ff 30                	pushl  (%eax)
  8017f2:	e8 9c fb ff ff       	call   801393 <dev_lookup>
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 37                	js     801835 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801801:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801805:	74 32                	je     801839 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801807:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801811:	00 00 00 
	stat->st_isdir = 0;
  801814:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181b:	00 00 00 
	stat->st_dev = dev;
  80181e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	53                   	push   %ebx
  801828:	ff 75 f0             	pushl  -0x10(%ebp)
  80182b:	ff 50 14             	call   *0x14(%eax)
  80182e:	89 c2                	mov    %eax,%edx
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	eb 09                	jmp    80183e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801835:	89 c2                	mov    %eax,%edx
  801837:	eb 05                	jmp    80183e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801839:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80183e:	89 d0                	mov    %edx,%eax
  801840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	6a 00                	push   $0x0
  80184f:	ff 75 08             	pushl  0x8(%ebp)
  801852:	e8 e3 01 00 00       	call   801a3a <open>
  801857:	89 c3                	mov    %eax,%ebx
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 1b                	js     80187b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	ff 75 0c             	pushl  0xc(%ebp)
  801866:	50                   	push   %eax
  801867:	e8 5b ff ff ff       	call   8017c7 <fstat>
  80186c:	89 c6                	mov    %eax,%esi
	close(fd);
  80186e:	89 1c 24             	mov    %ebx,(%esp)
  801871:	e8 f4 fb ff ff       	call   80146a <close>
	return r;
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	89 f0                	mov    %esi,%eax
}
  80187b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	89 c6                	mov    %eax,%esi
  801889:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80188b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801892:	75 12                	jne    8018a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	6a 01                	push   $0x1
  801899:	e8 e4 f9 ff ff       	call   801282 <ipc_find_env>
  80189e:	a3 00 40 80 00       	mov    %eax,0x804000
  8018a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a6:	6a 07                	push   $0x7
  8018a8:	68 00 50 80 00       	push   $0x805000
  8018ad:	56                   	push   %esi
  8018ae:	ff 35 00 40 80 00    	pushl  0x804000
  8018b4:	e8 67 f9 ff ff       	call   801220 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b9:	83 c4 0c             	add    $0xc,%esp
  8018bc:	6a 00                	push   $0x0
  8018be:	53                   	push   %ebx
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 df f8 ff ff       	call   8011a5 <ipc_recv>
}
  8018c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5e                   	pop    %esi
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f0:	e8 8d ff ff ff       	call   801882 <fsipc>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	8b 40 0c             	mov    0xc(%eax),%eax
  801903:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801908:	ba 00 00 00 00       	mov    $0x0,%edx
  80190d:	b8 06 00 00 00       	mov    $0x6,%eax
  801912:	e8 6b ff ff ff       	call   801882 <fsipc>
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	53                   	push   %ebx
  80191d:	83 ec 04             	sub    $0x4,%esp
  801920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	8b 40 0c             	mov    0xc(%eax),%eax
  801929:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80192e:	ba 00 00 00 00       	mov    $0x0,%edx
  801933:	b8 05 00 00 00       	mov    $0x5,%eax
  801938:	e8 45 ff ff ff       	call   801882 <fsipc>
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 2c                	js     80196d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	68 00 50 80 00       	push   $0x805000
  801949:	53                   	push   %ebx
  80194a:	e8 e8 ee ff ff       	call   800837 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80194f:	a1 80 50 80 00       	mov    0x805080,%eax
  801954:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80195a:	a1 84 50 80 00       	mov    0x805084,%eax
  80195f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80197b:	8b 55 08             	mov    0x8(%ebp),%edx
  80197e:	8b 52 0c             	mov    0xc(%edx),%edx
  801981:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801987:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80198c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801991:	0f 47 c2             	cmova  %edx,%eax
  801994:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801999:	50                   	push   %eax
  80199a:	ff 75 0c             	pushl  0xc(%ebp)
  80199d:	68 08 50 80 00       	push   $0x805008
  8019a2:	e8 22 f0 ff ff       	call   8009c9 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b1:	e8 cc fe ff ff       	call   801882 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019cb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d6:	b8 03 00 00 00       	mov    $0x3,%eax
  8019db:	e8 a2 fe ff ff       	call   801882 <fsipc>
  8019e0:	89 c3                	mov    %eax,%ebx
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 4b                	js     801a31 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019e6:	39 c6                	cmp    %eax,%esi
  8019e8:	73 16                	jae    801a00 <devfile_read+0x48>
  8019ea:	68 6c 28 80 00       	push   $0x80286c
  8019ef:	68 73 28 80 00       	push   $0x802873
  8019f4:	6a 7c                	push   $0x7c
  8019f6:	68 88 28 80 00       	push   $0x802888
  8019fb:	e8 c6 05 00 00       	call   801fc6 <_panic>
	assert(r <= PGSIZE);
  801a00:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a05:	7e 16                	jle    801a1d <devfile_read+0x65>
  801a07:	68 93 28 80 00       	push   $0x802893
  801a0c:	68 73 28 80 00       	push   $0x802873
  801a11:	6a 7d                	push   $0x7d
  801a13:	68 88 28 80 00       	push   $0x802888
  801a18:	e8 a9 05 00 00       	call   801fc6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a1d:	83 ec 04             	sub    $0x4,%esp
  801a20:	50                   	push   %eax
  801a21:	68 00 50 80 00       	push   $0x805000
  801a26:	ff 75 0c             	pushl  0xc(%ebp)
  801a29:	e8 9b ef ff ff       	call   8009c9 <memmove>
	return r;
  801a2e:	83 c4 10             	add    $0x10,%esp
}
  801a31:	89 d8                	mov    %ebx,%eax
  801a33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	53                   	push   %ebx
  801a3e:	83 ec 20             	sub    $0x20,%esp
  801a41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a44:	53                   	push   %ebx
  801a45:	e8 b4 ed ff ff       	call   8007fe <strlen>
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a52:	7f 67                	jg     801abb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5a:	50                   	push   %eax
  801a5b:	e8 8e f8 ff ff       	call   8012ee <fd_alloc>
  801a60:	83 c4 10             	add    $0x10,%esp
		return r;
  801a63:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 57                	js     801ac0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a69:	83 ec 08             	sub    $0x8,%esp
  801a6c:	53                   	push   %ebx
  801a6d:	68 00 50 80 00       	push   $0x805000
  801a72:	e8 c0 ed ff ff       	call   800837 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a82:	b8 01 00 00 00       	mov    $0x1,%eax
  801a87:	e8 f6 fd ff ff       	call   801882 <fsipc>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	79 14                	jns    801aa9 <open+0x6f>
		fd_close(fd, 0);
  801a95:	83 ec 08             	sub    $0x8,%esp
  801a98:	6a 00                	push   $0x0
  801a9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9d:	e8 47 f9 ff ff       	call   8013e9 <fd_close>
		return r;
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	89 da                	mov    %ebx,%edx
  801aa7:	eb 17                	jmp    801ac0 <open+0x86>
	}

	return fd2num(fd);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	ff 75 f4             	pushl  -0xc(%ebp)
  801aaf:	e8 13 f8 ff ff       	call   8012c7 <fd2num>
  801ab4:	89 c2                	mov    %eax,%edx
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	eb 05                	jmp    801ac0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801abb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac0:	89 d0                	mov    %edx,%eax
  801ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801acd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad7:	e8 a6 fd ff ff       	call   801882 <fsipc>
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	ff 75 08             	pushl  0x8(%ebp)
  801aec:	e8 e6 f7 ff ff       	call   8012d7 <fd2data>
  801af1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801af3:	83 c4 08             	add    $0x8,%esp
  801af6:	68 9f 28 80 00       	push   $0x80289f
  801afb:	53                   	push   %ebx
  801afc:	e8 36 ed ff ff       	call   800837 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b01:	8b 46 04             	mov    0x4(%esi),%eax
  801b04:	2b 06                	sub    (%esi),%eax
  801b06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b0c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b13:	00 00 00 
	stat->st_dev = &devpipe;
  801b16:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801b1d:	30 80 00 
	return 0;
}
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
  801b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 0c             	sub    $0xc,%esp
  801b33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b36:	53                   	push   %ebx
  801b37:	6a 00                	push   $0x0
  801b39:	e8 81 f1 ff ff       	call   800cbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b3e:	89 1c 24             	mov    %ebx,(%esp)
  801b41:	e8 91 f7 ff ff       	call   8012d7 <fd2data>
  801b46:	83 c4 08             	add    $0x8,%esp
  801b49:	50                   	push   %eax
  801b4a:	6a 00                	push   $0x0
  801b4c:	e8 6e f1 ff ff       	call   800cbf <sys_page_unmap>
}
  801b51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	57                   	push   %edi
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 1c             	sub    $0x1c,%esp
  801b5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b62:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b64:	a1 04 40 80 00       	mov    0x804004,%eax
  801b69:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	ff 75 e0             	pushl  -0x20(%ebp)
  801b75:	e8 21 05 00 00       	call   80209b <pageref>
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	89 3c 24             	mov    %edi,(%esp)
  801b7f:	e8 17 05 00 00       	call   80209b <pageref>
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	39 c3                	cmp    %eax,%ebx
  801b89:	0f 94 c1             	sete   %cl
  801b8c:	0f b6 c9             	movzbl %cl,%ecx
  801b8f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b92:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b98:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801b9e:	39 ce                	cmp    %ecx,%esi
  801ba0:	74 1e                	je     801bc0 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ba2:	39 c3                	cmp    %eax,%ebx
  801ba4:	75 be                	jne    801b64 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba6:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801bac:	ff 75 e4             	pushl  -0x1c(%ebp)
  801baf:	50                   	push   %eax
  801bb0:	56                   	push   %esi
  801bb1:	68 a6 28 80 00       	push   $0x8028a6
  801bb6:	e8 f7 e6 ff ff       	call   8002b2 <cprintf>
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	eb a4                	jmp    801b64 <_pipeisclosed+0xe>
	}
}
  801bc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc6:	5b                   	pop    %ebx
  801bc7:	5e                   	pop    %esi
  801bc8:	5f                   	pop    %edi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	57                   	push   %edi
  801bcf:	56                   	push   %esi
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 28             	sub    $0x28,%esp
  801bd4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bd7:	56                   	push   %esi
  801bd8:	e8 fa f6 ff ff       	call   8012d7 <fd2data>
  801bdd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	bf 00 00 00 00       	mov    $0x0,%edi
  801be7:	eb 4b                	jmp    801c34 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801be9:	89 da                	mov    %ebx,%edx
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	e8 64 ff ff ff       	call   801b56 <_pipeisclosed>
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	75 48                	jne    801c3e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bf6:	e8 20 f0 ff ff       	call   800c1b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bfb:	8b 43 04             	mov    0x4(%ebx),%eax
  801bfe:	8b 0b                	mov    (%ebx),%ecx
  801c00:	8d 51 20             	lea    0x20(%ecx),%edx
  801c03:	39 d0                	cmp    %edx,%eax
  801c05:	73 e2                	jae    801be9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c0e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c11:	89 c2                	mov    %eax,%edx
  801c13:	c1 fa 1f             	sar    $0x1f,%edx
  801c16:	89 d1                	mov    %edx,%ecx
  801c18:	c1 e9 1b             	shr    $0x1b,%ecx
  801c1b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c1e:	83 e2 1f             	and    $0x1f,%edx
  801c21:	29 ca                	sub    %ecx,%edx
  801c23:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c27:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c2b:	83 c0 01             	add    $0x1,%eax
  801c2e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c31:	83 c7 01             	add    $0x1,%edi
  801c34:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c37:	75 c2                	jne    801bfb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c39:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3c:	eb 05                	jmp    801c43 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	57                   	push   %edi
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	83 ec 18             	sub    $0x18,%esp
  801c54:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c57:	57                   	push   %edi
  801c58:	e8 7a f6 ff ff       	call   8012d7 <fd2data>
  801c5d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c67:	eb 3d                	jmp    801ca6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c69:	85 db                	test   %ebx,%ebx
  801c6b:	74 04                	je     801c71 <devpipe_read+0x26>
				return i;
  801c6d:	89 d8                	mov    %ebx,%eax
  801c6f:	eb 44                	jmp    801cb5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c71:	89 f2                	mov    %esi,%edx
  801c73:	89 f8                	mov    %edi,%eax
  801c75:	e8 dc fe ff ff       	call   801b56 <_pipeisclosed>
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	75 32                	jne    801cb0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c7e:	e8 98 ef ff ff       	call   800c1b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c83:	8b 06                	mov    (%esi),%eax
  801c85:	3b 46 04             	cmp    0x4(%esi),%eax
  801c88:	74 df                	je     801c69 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c8a:	99                   	cltd   
  801c8b:	c1 ea 1b             	shr    $0x1b,%edx
  801c8e:	01 d0                	add    %edx,%eax
  801c90:	83 e0 1f             	and    $0x1f,%eax
  801c93:	29 d0                	sub    %edx,%eax
  801c95:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca3:	83 c3 01             	add    $0x1,%ebx
  801ca6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ca9:	75 d8                	jne    801c83 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cab:	8b 45 10             	mov    0x10(%ebp),%eax
  801cae:	eb 05                	jmp    801cb5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5e                   	pop    %esi
  801cba:	5f                   	pop    %edi
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    

00801cbd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	56                   	push   %esi
  801cc1:	53                   	push   %ebx
  801cc2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc8:	50                   	push   %eax
  801cc9:	e8 20 f6 ff ff       	call   8012ee <fd_alloc>
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	89 c2                	mov    %eax,%edx
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	0f 88 2c 01 00 00    	js     801e07 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdb:	83 ec 04             	sub    $0x4,%esp
  801cde:	68 07 04 00 00       	push   $0x407
  801ce3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 4d ef ff ff       	call   800c3a <sys_page_alloc>
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	89 c2                	mov    %eax,%edx
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	0f 88 0d 01 00 00    	js     801e07 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cfa:	83 ec 0c             	sub    $0xc,%esp
  801cfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d00:	50                   	push   %eax
  801d01:	e8 e8 f5 ff ff       	call   8012ee <fd_alloc>
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	0f 88 e2 00 00 00    	js     801df5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d13:	83 ec 04             	sub    $0x4,%esp
  801d16:	68 07 04 00 00       	push   $0x407
  801d1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 15 ef ff ff       	call   800c3a <sys_page_alloc>
  801d25:	89 c3                	mov    %eax,%ebx
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	0f 88 c3 00 00 00    	js     801df5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d32:	83 ec 0c             	sub    $0xc,%esp
  801d35:	ff 75 f4             	pushl  -0xc(%ebp)
  801d38:	e8 9a f5 ff ff       	call   8012d7 <fd2data>
  801d3d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3f:	83 c4 0c             	add    $0xc,%esp
  801d42:	68 07 04 00 00       	push   $0x407
  801d47:	50                   	push   %eax
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 eb ee ff ff       	call   800c3a <sys_page_alloc>
  801d4f:	89 c3                	mov    %eax,%ebx
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	85 c0                	test   %eax,%eax
  801d56:	0f 88 89 00 00 00    	js     801de5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d62:	e8 70 f5 ff ff       	call   8012d7 <fd2data>
  801d67:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d6e:	50                   	push   %eax
  801d6f:	6a 00                	push   $0x0
  801d71:	56                   	push   %esi
  801d72:	6a 00                	push   $0x0
  801d74:	e8 04 ef ff ff       	call   800c7d <sys_page_map>
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	83 c4 20             	add    $0x20,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 55                	js     801dd7 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d82:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d90:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d97:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dac:	83 ec 0c             	sub    $0xc,%esp
  801daf:	ff 75 f4             	pushl  -0xc(%ebp)
  801db2:	e8 10 f5 ff ff       	call   8012c7 <fd2num>
  801db7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dbc:	83 c4 04             	add    $0x4,%esp
  801dbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc2:	e8 00 f5 ff ff       	call   8012c7 <fd2num>
  801dc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dca:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd5:	eb 30                	jmp    801e07 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	56                   	push   %esi
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 dd ee ff ff       	call   800cbf <sys_page_unmap>
  801de2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801de5:	83 ec 08             	sub    $0x8,%esp
  801de8:	ff 75 f0             	pushl  -0x10(%ebp)
  801deb:	6a 00                	push   $0x0
  801ded:	e8 cd ee ff ff       	call   800cbf <sys_page_unmap>
  801df2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 bd ee ff ff       	call   800cbf <sys_page_unmap>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e07:	89 d0                	mov    %edx,%eax
  801e09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e19:	50                   	push   %eax
  801e1a:	ff 75 08             	pushl  0x8(%ebp)
  801e1d:	e8 1b f5 ff ff       	call   80133d <fd_lookup>
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 18                	js     801e41 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e29:	83 ec 0c             	sub    $0xc,%esp
  801e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2f:	e8 a3 f4 ff ff       	call   8012d7 <fd2data>
	return _pipeisclosed(fd, p);
  801e34:	89 c2                	mov    %eax,%edx
  801e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e39:	e8 18 fd ff ff       	call   801b56 <_pipeisclosed>
  801e3e:	83 c4 10             	add    $0x10,%esp
}
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    

00801e4d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e53:	68 be 28 80 00       	push   $0x8028be
  801e58:	ff 75 0c             	pushl  0xc(%ebp)
  801e5b:	e8 d7 e9 ff ff       	call   800837 <strcpy>
	return 0;
}
  801e60:	b8 00 00 00 00       	mov    $0x0,%eax
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	57                   	push   %edi
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e73:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e78:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7e:	eb 2d                	jmp    801ead <devcons_write+0x46>
		m = n - tot;
  801e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e83:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e85:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e88:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e8d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e90:	83 ec 04             	sub    $0x4,%esp
  801e93:	53                   	push   %ebx
  801e94:	03 45 0c             	add    0xc(%ebp),%eax
  801e97:	50                   	push   %eax
  801e98:	57                   	push   %edi
  801e99:	e8 2b eb ff ff       	call   8009c9 <memmove>
		sys_cputs(buf, m);
  801e9e:	83 c4 08             	add    $0x8,%esp
  801ea1:	53                   	push   %ebx
  801ea2:	57                   	push   %edi
  801ea3:	e8 d6 ec ff ff       	call   800b7e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea8:	01 de                	add    %ebx,%esi
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	89 f0                	mov    %esi,%eax
  801eaf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb2:	72 cc                	jb     801e80 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    

00801ebc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 08             	sub    $0x8,%esp
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ec7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ecb:	74 2a                	je     801ef7 <devcons_read+0x3b>
  801ecd:	eb 05                	jmp    801ed4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ecf:	e8 47 ed ff ff       	call   800c1b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ed4:	e8 c3 ec ff ff       	call   800b9c <sys_cgetc>
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	74 f2                	je     801ecf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801edd:	85 c0                	test   %eax,%eax
  801edf:	78 16                	js     801ef7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee1:	83 f8 04             	cmp    $0x4,%eax
  801ee4:	74 0c                	je     801ef2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ee6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ee9:	88 02                	mov    %al,(%edx)
	return 1;
  801eeb:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef0:	eb 05                	jmp    801ef7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ef7:	c9                   	leave  
  801ef8:	c3                   	ret    

00801ef9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eff:	8b 45 08             	mov    0x8(%ebp),%eax
  801f02:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f05:	6a 01                	push   $0x1
  801f07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0a:	50                   	push   %eax
  801f0b:	e8 6e ec ff ff       	call   800b7e <sys_cputs>
}
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <getchar>:

int
getchar(void)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f1b:	6a 01                	push   $0x1
  801f1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f20:	50                   	push   %eax
  801f21:	6a 00                	push   $0x0
  801f23:	e8 7e f6 ff ff       	call   8015a6 <read>
	if (r < 0)
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 0f                	js     801f3e <getchar+0x29>
		return r;
	if (r < 1)
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	7e 06                	jle    801f39 <getchar+0x24>
		return -E_EOF;
	return c;
  801f33:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f37:	eb 05                	jmp    801f3e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f39:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f3e:	c9                   	leave  
  801f3f:	c3                   	ret    

00801f40 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f49:	50                   	push   %eax
  801f4a:	ff 75 08             	pushl  0x8(%ebp)
  801f4d:	e8 eb f3 ff ff       	call   80133d <fd_lookup>
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 11                	js     801f6a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f62:	39 10                	cmp    %edx,(%eax)
  801f64:	0f 94 c0             	sete   %al
  801f67:	0f b6 c0             	movzbl %al,%eax
}
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    

00801f6c <opencons>:

int
opencons(void)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f75:	50                   	push   %eax
  801f76:	e8 73 f3 ff ff       	call   8012ee <fd_alloc>
  801f7b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f7e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f80:	85 c0                	test   %eax,%eax
  801f82:	78 3e                	js     801fc2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f84:	83 ec 04             	sub    $0x4,%esp
  801f87:	68 07 04 00 00       	push   $0x407
  801f8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8f:	6a 00                	push   $0x0
  801f91:	e8 a4 ec ff ff       	call   800c3a <sys_page_alloc>
  801f96:	83 c4 10             	add    $0x10,%esp
		return r;
  801f99:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 23                	js     801fc2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f9f:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb4:	83 ec 0c             	sub    $0xc,%esp
  801fb7:	50                   	push   %eax
  801fb8:	e8 0a f3 ff ff       	call   8012c7 <fd2num>
  801fbd:	89 c2                	mov    %eax,%edx
  801fbf:	83 c4 10             	add    $0x10,%esp
}
  801fc2:	89 d0                	mov    %edx,%eax
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	56                   	push   %esi
  801fca:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fcb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fce:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801fd4:	e8 23 ec ff ff       	call   800bfc <sys_getenvid>
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	ff 75 0c             	pushl  0xc(%ebp)
  801fdf:	ff 75 08             	pushl  0x8(%ebp)
  801fe2:	56                   	push   %esi
  801fe3:	50                   	push   %eax
  801fe4:	68 cc 28 80 00       	push   $0x8028cc
  801fe9:	e8 c4 e2 ff ff       	call   8002b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fee:	83 c4 18             	add    $0x18,%esp
  801ff1:	53                   	push   %ebx
  801ff2:	ff 75 10             	pushl  0x10(%ebp)
  801ff5:	e8 67 e2 ff ff       	call   800261 <vcprintf>
	cprintf("\n");
  801ffa:	c7 04 24 b7 28 80 00 	movl   $0x8028b7,(%esp)
  802001:	e8 ac e2 ff ff       	call   8002b2 <cprintf>
  802006:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802009:	cc                   	int3   
  80200a:	eb fd                	jmp    802009 <_panic+0x43>

0080200c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802012:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802019:	75 2a                	jne    802045 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	6a 07                	push   $0x7
  802020:	68 00 f0 bf ee       	push   $0xeebff000
  802025:	6a 00                	push   $0x0
  802027:	e8 0e ec ff ff       	call   800c3a <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80202c:	83 c4 10             	add    $0x10,%esp
  80202f:	85 c0                	test   %eax,%eax
  802031:	79 12                	jns    802045 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802033:	50                   	push   %eax
  802034:	68 f0 28 80 00       	push   $0x8028f0
  802039:	6a 23                	push   $0x23
  80203b:	68 f4 28 80 00       	push   $0x8028f4
  802040:	e8 81 ff ff ff       	call   801fc6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802045:	8b 45 08             	mov    0x8(%ebp),%eax
  802048:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80204d:	83 ec 08             	sub    $0x8,%esp
  802050:	68 77 20 80 00       	push   $0x802077
  802055:	6a 00                	push   $0x0
  802057:	e8 29 ed ff ff       	call   800d85 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	79 12                	jns    802075 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802063:	50                   	push   %eax
  802064:	68 f0 28 80 00       	push   $0x8028f0
  802069:	6a 2c                	push   $0x2c
  80206b:	68 f4 28 80 00       	push   $0x8028f4
  802070:	e8 51 ff ff ff       	call   801fc6 <_panic>
	}
}
  802075:	c9                   	leave  
  802076:	c3                   	ret    

00802077 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802077:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802078:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80207d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80207f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802082:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802086:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80208b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80208f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802091:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802094:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802095:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802098:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802099:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80209a:	c3                   	ret    

0080209b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a1:	89 d0                	mov    %edx,%eax
  8020a3:	c1 e8 16             	shr    $0x16,%eax
  8020a6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ad:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b2:	f6 c1 01             	test   $0x1,%cl
  8020b5:	74 1d                	je     8020d4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020b7:	c1 ea 0c             	shr    $0xc,%edx
  8020ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020c1:	f6 c2 01             	test   $0x1,%dl
  8020c4:	74 0e                	je     8020d4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c6:	c1 ea 0c             	shr    $0xc,%edx
  8020c9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020d0:	ef 
  8020d1:	0f b7 c0             	movzwl %ax,%eax
}
  8020d4:	5d                   	pop    %ebp
  8020d5:	c3                   	ret    
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
