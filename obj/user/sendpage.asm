
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
  800057:	e8 ab 13 00 00       	call   801407 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 e0 25 80 00       	push   $0x8025e0
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
  80009d:	68 f4 25 80 00       	push   $0x8025f4
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
  8000db:	e8 a2 13 00 00       	call   801482 <ipc_send>
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
  800134:	e8 49 13 00 00       	call   801482 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800139:	83 c4 1c             	add    $0x1c,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	68 00 00 a0 00       	push   $0xa00000
  800143:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	e8 bb 12 00 00       	call   801407 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80014c:	83 c4 0c             	add    $0xc,%esp
  80014f:	68 00 00 a0 00       	push   $0xa00000
  800154:	ff 75 f4             	pushl  -0xc(%ebp)
  800157:	68 e0 25 80 00       	push   $0x8025e0
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
  80018d:	68 14 26 80 00       	push   $0x802614
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
  80020b:	e8 e7 14 00 00       	call   8016f7 <close_all>
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
  800315:	e8 26 20 00 00       	call   802340 <__udivdi3>
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
  800358:	e8 13 21 00 00       	call   802470 <__umoddi3>
  80035d:	83 c4 14             	add    $0x14,%esp
  800360:	0f be 80 8c 26 80 00 	movsbl 0x80268c(%eax),%eax
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
  80045c:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  800520:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	75 18                	jne    800543 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052b:	50                   	push   %eax
  80052c:	68 a4 26 80 00       	push   $0x8026a4
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
  800544:	68 c5 2b 80 00       	push   $0x802bc5
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
  800568:	b8 9d 26 80 00       	mov    $0x80269d,%eax
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
  800be3:	68 7f 29 80 00       	push   $0x80297f
  800be8:	6a 23                	push   $0x23
  800bea:	68 9c 29 80 00       	push   $0x80299c
  800bef:	e8 34 16 00 00       	call   802228 <_panic>

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
  800c64:	68 7f 29 80 00       	push   $0x80297f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 9c 29 80 00       	push   $0x80299c
  800c70:	e8 b3 15 00 00       	call   802228 <_panic>

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
  800ca6:	68 7f 29 80 00       	push   $0x80297f
  800cab:	6a 23                	push   $0x23
  800cad:	68 9c 29 80 00       	push   $0x80299c
  800cb2:	e8 71 15 00 00       	call   802228 <_panic>

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
  800ce8:	68 7f 29 80 00       	push   $0x80297f
  800ced:	6a 23                	push   $0x23
  800cef:	68 9c 29 80 00       	push   $0x80299c
  800cf4:	e8 2f 15 00 00       	call   802228 <_panic>

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
  800d2a:	68 7f 29 80 00       	push   $0x80297f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 9c 29 80 00       	push   $0x80299c
  800d36:	e8 ed 14 00 00       	call   802228 <_panic>

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
  800d6c:	68 7f 29 80 00       	push   $0x80297f
  800d71:	6a 23                	push   $0x23
  800d73:	68 9c 29 80 00       	push   $0x80299c
  800d78:	e8 ab 14 00 00       	call   802228 <_panic>
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
  800dae:	68 7f 29 80 00       	push   $0x80297f
  800db3:	6a 23                	push   $0x23
  800db5:	68 9c 29 80 00       	push   $0x80299c
  800dba:	e8 69 14 00 00       	call   802228 <_panic>

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
  800e12:	68 7f 29 80 00       	push   $0x80297f
  800e17:	6a 23                	push   $0x23
  800e19:	68 9c 29 80 00       	push   $0x80299c
  800e1e:	e8 05 14 00 00       	call   802228 <_panic>

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
  800eb1:	68 aa 29 80 00       	push   $0x8029aa
  800eb6:	6a 1f                	push   $0x1f
  800eb8:	68 ba 29 80 00       	push   $0x8029ba
  800ebd:	e8 66 13 00 00       	call   802228 <_panic>
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
  800edb:	68 c5 29 80 00       	push   $0x8029c5
  800ee0:	6a 2d                	push   $0x2d
  800ee2:	68 ba 29 80 00       	push   $0x8029ba
  800ee7:	e8 3c 13 00 00       	call   802228 <_panic>
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
  800f23:	68 c5 29 80 00       	push   $0x8029c5
  800f28:	6a 34                	push   $0x34
  800f2a:	68 ba 29 80 00       	push   $0x8029ba
  800f2f:	e8 f4 12 00 00       	call   802228 <_panic>
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
  800f4b:	68 c5 29 80 00       	push   $0x8029c5
  800f50:	6a 38                	push   $0x38
  800f52:	68 ba 29 80 00       	push   $0x8029ba
  800f57:	e8 cc 12 00 00       	call   802228 <_panic>
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
  800f6f:	e8 fa 12 00 00       	call   80226e <set_pgfault_handler>
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
  800f88:	68 de 29 80 00       	push   $0x8029de
  800f8d:	68 85 00 00 00       	push   $0x85
  800f92:	68 ba 29 80 00       	push   $0x8029ba
  800f97:	e8 8c 12 00 00       	call   802228 <_panic>
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
  801044:	68 ec 29 80 00       	push   $0x8029ec
  801049:	6a 55                	push   $0x55
  80104b:	68 ba 29 80 00       	push   $0x8029ba
  801050:	e8 d3 11 00 00       	call   802228 <_panic>
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
  801089:	68 ec 29 80 00       	push   $0x8029ec
  80108e:	6a 5c                	push   $0x5c
  801090:	68 ba 29 80 00       	push   $0x8029ba
  801095:	e8 8e 11 00 00       	call   802228 <_panic>
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
  8010b7:	68 ec 29 80 00       	push   $0x8029ec
  8010bc:	6a 60                	push   $0x60
  8010be:	68 ba 29 80 00       	push   $0x8029ba
  8010c3:	e8 60 11 00 00       	call   802228 <_panic>
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
  8010e1:	68 ec 29 80 00       	push   $0x8029ec
  8010e6:	6a 65                	push   $0x65
  8010e8:	68 ba 29 80 00       	push   $0x8029ba
  8010ed:	e8 36 11 00 00       	call   802228 <_panic>
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
  801150:	68 7c 2a 80 00       	push   $0x802a7c
  801155:	e8 58 f1 ff ff       	call   8002b2 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80115a:	c7 04 24 e5 01 80 00 	movl   $0x8001e5,(%esp)
  801161:	e8 c5 fc ff ff       	call   800e2b <sys_thread_create>
  801166:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801168:	83 c4 08             	add    $0x8,%esp
  80116b:	53                   	push   %ebx
  80116c:	68 7c 2a 80 00       	push   $0x802a7c
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

008011a5 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8011b0:	83 ec 04             	sub    $0x4,%esp
  8011b3:	6a 07                	push   $0x7
  8011b5:	6a 00                	push   $0x0
  8011b7:	56                   	push   %esi
  8011b8:	e8 7d fa ff ff       	call   800c3a <sys_page_alloc>
	if (r < 0) {
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 15                	jns    8011d9 <queue_append+0x34>
		panic("%e\n", r);
  8011c4:	50                   	push   %eax
  8011c5:	68 78 2a 80 00       	push   $0x802a78
  8011ca:	68 c4 00 00 00       	push   $0xc4
  8011cf:	68 ba 29 80 00       	push   $0x8029ba
  8011d4:	e8 4f 10 00 00       	call   802228 <_panic>
	}	
	wt->envid = envid;
  8011d9:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	ff 33                	pushl  (%ebx)
  8011e4:	56                   	push   %esi
  8011e5:	68 a0 2a 80 00       	push   $0x802aa0
  8011ea:	e8 c3 f0 ff ff       	call   8002b2 <cprintf>
	if (queue->first == NULL) {
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011f5:	75 29                	jne    801220 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	68 02 2a 80 00       	push   $0x802a02
  8011ff:	e8 ae f0 ff ff       	call   8002b2 <cprintf>
		queue->first = wt;
  801204:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80120a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801211:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801218:	00 00 00 
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	eb 2b                	jmp    80124b <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	68 1c 2a 80 00       	push   $0x802a1c
  801228:	e8 85 f0 ff ff       	call   8002b2 <cprintf>
		queue->last->next = wt;
  80122d:	8b 43 04             	mov    0x4(%ebx),%eax
  801230:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801237:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80123e:	00 00 00 
		queue->last = wt;
  801241:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801248:	83 c4 10             	add    $0x10,%esp
	}
}
  80124b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80125c:	8b 02                	mov    (%edx),%eax
  80125e:	85 c0                	test   %eax,%eax
  801260:	75 17                	jne    801279 <queue_pop+0x27>
		panic("queue empty!\n");
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	68 3a 2a 80 00       	push   $0x802a3a
  80126a:	68 d8 00 00 00       	push   $0xd8
  80126f:	68 ba 29 80 00       	push   $0x8029ba
  801274:	e8 af 0f 00 00       	call   802228 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801279:	8b 48 04             	mov    0x4(%eax),%ecx
  80127c:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  80127e:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	53                   	push   %ebx
  801284:	68 48 2a 80 00       	push   $0x802a48
  801289:	e8 24 f0 ff ff       	call   8002b2 <cprintf>
	return envid;
}
  80128e:	89 d8                	mov    %ebx,%eax
  801290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	53                   	push   %ebx
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80129f:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a4:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	74 5a                	je     801305 <mutex_lock+0x70>
  8012ab:	8b 43 04             	mov    0x4(%ebx),%eax
  8012ae:	83 38 00             	cmpl   $0x0,(%eax)
  8012b1:	75 52                	jne    801305 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8012b3:	83 ec 0c             	sub    $0xc,%esp
  8012b6:	68 c8 2a 80 00       	push   $0x802ac8
  8012bb:	e8 f2 ef ff ff       	call   8002b2 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8012c0:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8012c3:	e8 34 f9 ff ff       	call   800bfc <sys_getenvid>
  8012c8:	83 c4 08             	add    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	50                   	push   %eax
  8012cd:	e8 d3 fe ff ff       	call   8011a5 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012d2:	e8 25 f9 ff ff       	call   800bfc <sys_getenvid>
  8012d7:	83 c4 08             	add    $0x8,%esp
  8012da:	6a 04                	push   $0x4
  8012dc:	50                   	push   %eax
  8012dd:	e8 1f fa ff ff       	call   800d01 <sys_env_set_status>
		if (r < 0) {
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	79 15                	jns    8012fe <mutex_lock+0x69>
			panic("%e\n", r);
  8012e9:	50                   	push   %eax
  8012ea:	68 78 2a 80 00       	push   $0x802a78
  8012ef:	68 eb 00 00 00       	push   $0xeb
  8012f4:	68 ba 29 80 00       	push   $0x8029ba
  8012f9:	e8 2a 0f 00 00       	call   802228 <_panic>
		}
		sys_yield();
  8012fe:	e8 18 f9 ff ff       	call   800c1b <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801303:	eb 18                	jmp    80131d <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	68 e8 2a 80 00       	push   $0x802ae8
  80130d:	e8 a0 ef ff ff       	call   8002b2 <cprintf>
	mtx->owner = sys_getenvid();}
  801312:	e8 e5 f8 ff ff       	call   800bfc <sys_getenvid>
  801317:	89 43 08             	mov    %eax,0x8(%ebx)
  80131a:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80131d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	53                   	push   %ebx
  801326:	83 ec 04             	sub    $0x4,%esp
  801329:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80132c:	b8 00 00 00 00       	mov    $0x0,%eax
  801331:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801334:	8b 43 04             	mov    0x4(%ebx),%eax
  801337:	83 38 00             	cmpl   $0x0,(%eax)
  80133a:	74 33                	je     80136f <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	50                   	push   %eax
  801340:	e8 0d ff ff ff       	call   801252 <queue_pop>
  801345:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	6a 02                	push   $0x2
  80134d:	50                   	push   %eax
  80134e:	e8 ae f9 ff ff       	call   800d01 <sys_env_set_status>
		if (r < 0) {
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	79 15                	jns    80136f <mutex_unlock+0x4d>
			panic("%e\n", r);
  80135a:	50                   	push   %eax
  80135b:	68 78 2a 80 00       	push   $0x802a78
  801360:	68 00 01 00 00       	push   $0x100
  801365:	68 ba 29 80 00       	push   $0x8029ba
  80136a:	e8 b9 0e 00 00       	call   802228 <_panic>
		}
	}

	asm volatile("pause");
  80136f:	f3 90                	pause  
	//sys_yield();
}
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	53                   	push   %ebx
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801380:	e8 77 f8 ff ff       	call   800bfc <sys_getenvid>
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	6a 07                	push   $0x7
  80138a:	53                   	push   %ebx
  80138b:	50                   	push   %eax
  80138c:	e8 a9 f8 ff ff       	call   800c3a <sys_page_alloc>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	79 15                	jns    8013ad <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801398:	50                   	push   %eax
  801399:	68 63 2a 80 00       	push   $0x802a63
  80139e:	68 0d 01 00 00       	push   $0x10d
  8013a3:	68 ba 29 80 00       	push   $0x8029ba
  8013a8:	e8 7b 0e 00 00       	call   802228 <_panic>
	}	
	mtx->locked = 0;
  8013ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8013b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8013b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8013bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8013bf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013c6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d0:	c9                   	leave  
  8013d1:	c3                   	ret    

008013d2 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8013d8:	e8 1f f8 ff ff       	call   800bfc <sys_getenvid>
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	ff 75 08             	pushl  0x8(%ebp)
  8013e3:	50                   	push   %eax
  8013e4:	e8 d6 f8 ff ff       	call   800cbf <sys_page_unmap>
	if (r < 0) {
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	79 15                	jns    801405 <mutex_destroy+0x33>
		panic("%e\n", r);
  8013f0:	50                   	push   %eax
  8013f1:	68 78 2a 80 00       	push   $0x802a78
  8013f6:	68 1a 01 00 00       	push   $0x11a
  8013fb:	68 ba 29 80 00       	push   $0x8029ba
  801400:	e8 23 0e 00 00       	call   802228 <_panic>
	}
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	56                   	push   %esi
  80140b:	53                   	push   %ebx
  80140c:	8b 75 08             	mov    0x8(%ebp),%esi
  80140f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801412:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801415:	85 c0                	test   %eax,%eax
  801417:	75 12                	jne    80142b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	68 00 00 c0 ee       	push   $0xeec00000
  801421:	e8 c4 f9 ff ff       	call   800dea <sys_ipc_recv>
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	eb 0c                	jmp    801437 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	50                   	push   %eax
  80142f:	e8 b6 f9 ff ff       	call   800dea <sys_ipc_recv>
  801434:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801437:	85 f6                	test   %esi,%esi
  801439:	0f 95 c1             	setne  %cl
  80143c:	85 db                	test   %ebx,%ebx
  80143e:	0f 95 c2             	setne  %dl
  801441:	84 d1                	test   %dl,%cl
  801443:	74 09                	je     80144e <ipc_recv+0x47>
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 1f             	shr    $0x1f,%edx
  80144a:	84 d2                	test   %dl,%dl
  80144c:	75 2d                	jne    80147b <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80144e:	85 f6                	test   %esi,%esi
  801450:	74 0d                	je     80145f <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801452:	a1 04 40 80 00       	mov    0x804004,%eax
  801457:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80145d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80145f:	85 db                	test   %ebx,%ebx
  801461:	74 0d                	je     801470 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801463:	a1 04 40 80 00       	mov    0x804004,%eax
  801468:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80146e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801470:	a1 04 40 80 00       	mov    0x804004,%eax
  801475:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80147b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	57                   	push   %edi
  801486:	56                   	push   %esi
  801487:	53                   	push   %ebx
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801491:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801494:	85 db                	test   %ebx,%ebx
  801496:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80149b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80149e:	ff 75 14             	pushl  0x14(%ebp)
  8014a1:	53                   	push   %ebx
  8014a2:	56                   	push   %esi
  8014a3:	57                   	push   %edi
  8014a4:	e8 1e f9 ff ff       	call   800dc7 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	c1 ea 1f             	shr    $0x1f,%edx
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	84 d2                	test   %dl,%dl
  8014b3:	74 17                	je     8014cc <ipc_send+0x4a>
  8014b5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014b8:	74 12                	je     8014cc <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8014ba:	50                   	push   %eax
  8014bb:	68 08 2b 80 00       	push   $0x802b08
  8014c0:	6a 47                	push   $0x47
  8014c2:	68 16 2b 80 00       	push   $0x802b16
  8014c7:	e8 5c 0d 00 00       	call   802228 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8014cc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014cf:	75 07                	jne    8014d8 <ipc_send+0x56>
			sys_yield();
  8014d1:	e8 45 f7 ff ff       	call   800c1b <sys_yield>
  8014d6:	eb c6                	jmp    80149e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	75 c2                	jne    80149e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8014dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014ef:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8014f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014fb:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801501:	39 ca                	cmp    %ecx,%edx
  801503:	75 13                	jne    801518 <ipc_find_env+0x34>
			return envs[i].env_id;
  801505:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80150b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801510:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801516:	eb 0f                	jmp    801527 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801518:	83 c0 01             	add    $0x1,%eax
  80151b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801520:	75 cd                	jne    8014ef <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801522:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    

00801529 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80152c:	8b 45 08             	mov    0x8(%ebp),%eax
  80152f:	05 00 00 00 30       	add    $0x30000000,%eax
  801534:	c1 e8 0c             	shr    $0xc,%eax
}
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80153c:	8b 45 08             	mov    0x8(%ebp),%eax
  80153f:	05 00 00 00 30       	add    $0x30000000,%eax
  801544:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801549:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801556:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	c1 ea 16             	shr    $0x16,%edx
  801560:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801567:	f6 c2 01             	test   $0x1,%dl
  80156a:	74 11                	je     80157d <fd_alloc+0x2d>
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	c1 ea 0c             	shr    $0xc,%edx
  801571:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801578:	f6 c2 01             	test   $0x1,%dl
  80157b:	75 09                	jne    801586 <fd_alloc+0x36>
			*fd_store = fd;
  80157d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
  801584:	eb 17                	jmp    80159d <fd_alloc+0x4d>
  801586:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80158b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801590:	75 c9                	jne    80155b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801592:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801598:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80159d:	5d                   	pop    %ebp
  80159e:	c3                   	ret    

0080159f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015a5:	83 f8 1f             	cmp    $0x1f,%eax
  8015a8:	77 36                	ja     8015e0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015aa:	c1 e0 0c             	shl    $0xc,%eax
  8015ad:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	c1 ea 16             	shr    $0x16,%edx
  8015b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015be:	f6 c2 01             	test   $0x1,%dl
  8015c1:	74 24                	je     8015e7 <fd_lookup+0x48>
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	c1 ea 0c             	shr    $0xc,%edx
  8015c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015cf:	f6 c2 01             	test   $0x1,%dl
  8015d2:	74 1a                	je     8015ee <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d7:	89 02                	mov    %eax,(%edx)
	return 0;
  8015d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015de:	eb 13                	jmp    8015f3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e5:	eb 0c                	jmp    8015f3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ec:	eb 05                	jmp    8015f3 <fd_lookup+0x54>
  8015ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fe:	ba 9c 2b 80 00       	mov    $0x802b9c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801603:	eb 13                	jmp    801618 <dev_lookup+0x23>
  801605:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801608:	39 08                	cmp    %ecx,(%eax)
  80160a:	75 0c                	jne    801618 <dev_lookup+0x23>
			*dev = devtab[i];
  80160c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801611:	b8 00 00 00 00       	mov    $0x0,%eax
  801616:	eb 31                	jmp    801649 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801618:	8b 02                	mov    (%edx),%eax
  80161a:	85 c0                	test   %eax,%eax
  80161c:	75 e7                	jne    801605 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80161e:	a1 04 40 80 00       	mov    0x804004,%eax
  801623:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	51                   	push   %ecx
  80162d:	50                   	push   %eax
  80162e:	68 20 2b 80 00       	push   $0x802b20
  801633:	e8 7a ec ff ff       	call   8002b2 <cprintf>
	*dev = 0;
  801638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	56                   	push   %esi
  80164f:	53                   	push   %ebx
  801650:	83 ec 10             	sub    $0x10,%esp
  801653:	8b 75 08             	mov    0x8(%ebp),%esi
  801656:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801663:	c1 e8 0c             	shr    $0xc,%eax
  801666:	50                   	push   %eax
  801667:	e8 33 ff ff ff       	call   80159f <fd_lookup>
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 05                	js     801678 <fd_close+0x2d>
	    || fd != fd2)
  801673:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801676:	74 0c                	je     801684 <fd_close+0x39>
		return (must_exist ? r : 0);
  801678:	84 db                	test   %bl,%bl
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	0f 44 c2             	cmove  %edx,%eax
  801682:	eb 41                	jmp    8016c5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801684:	83 ec 08             	sub    $0x8,%esp
  801687:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168a:	50                   	push   %eax
  80168b:	ff 36                	pushl  (%esi)
  80168d:	e8 63 ff ff ff       	call   8015f5 <dev_lookup>
  801692:	89 c3                	mov    %eax,%ebx
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 1a                	js     8016b5 <fd_close+0x6a>
		if (dev->dev_close)
  80169b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8016a1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	74 0b                	je     8016b5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016aa:	83 ec 0c             	sub    $0xc,%esp
  8016ad:	56                   	push   %esi
  8016ae:	ff d0                	call   *%eax
  8016b0:	89 c3                	mov    %eax,%ebx
  8016b2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	56                   	push   %esi
  8016b9:	6a 00                	push   $0x0
  8016bb:	e8 ff f5 ff ff       	call   800cbf <sys_page_unmap>
	return r;
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	89 d8                	mov    %ebx,%eax
}
  8016c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c8:	5b                   	pop    %ebx
  8016c9:	5e                   	pop    %esi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	ff 75 08             	pushl  0x8(%ebp)
  8016d9:	e8 c1 fe ff ff       	call   80159f <fd_lookup>
  8016de:	83 c4 08             	add    $0x8,%esp
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 10                	js     8016f5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	6a 01                	push   $0x1
  8016ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ed:	e8 59 ff ff ff       	call   80164b <fd_close>
  8016f2:	83 c4 10             	add    $0x10,%esp
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <close_all>:

void
close_all(void)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	53                   	push   %ebx
  801707:	e8 c0 ff ff ff       	call   8016cc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80170c:	83 c3 01             	add    $0x1,%ebx
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	83 fb 20             	cmp    $0x20,%ebx
  801715:	75 ec                	jne    801703 <close_all+0xc>
		close(i);
}
  801717:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	57                   	push   %edi
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	83 ec 2c             	sub    $0x2c,%esp
  801725:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801728:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	ff 75 08             	pushl  0x8(%ebp)
  80172f:	e8 6b fe ff ff       	call   80159f <fd_lookup>
  801734:	83 c4 08             	add    $0x8,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	0f 88 c1 00 00 00    	js     801800 <dup+0xe4>
		return r;
	close(newfdnum);
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	56                   	push   %esi
  801743:	e8 84 ff ff ff       	call   8016cc <close>

	newfd = INDEX2FD(newfdnum);
  801748:	89 f3                	mov    %esi,%ebx
  80174a:	c1 e3 0c             	shl    $0xc,%ebx
  80174d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801753:	83 c4 04             	add    $0x4,%esp
  801756:	ff 75 e4             	pushl  -0x1c(%ebp)
  801759:	e8 db fd ff ff       	call   801539 <fd2data>
  80175e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801760:	89 1c 24             	mov    %ebx,(%esp)
  801763:	e8 d1 fd ff ff       	call   801539 <fd2data>
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80176e:	89 f8                	mov    %edi,%eax
  801770:	c1 e8 16             	shr    $0x16,%eax
  801773:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80177a:	a8 01                	test   $0x1,%al
  80177c:	74 37                	je     8017b5 <dup+0x99>
  80177e:	89 f8                	mov    %edi,%eax
  801780:	c1 e8 0c             	shr    $0xc,%eax
  801783:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80178a:	f6 c2 01             	test   $0x1,%dl
  80178d:	74 26                	je     8017b5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80178f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801796:	83 ec 0c             	sub    $0xc,%esp
  801799:	25 07 0e 00 00       	and    $0xe07,%eax
  80179e:	50                   	push   %eax
  80179f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017a2:	6a 00                	push   $0x0
  8017a4:	57                   	push   %edi
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 d1 f4 ff ff       	call   800c7d <sys_page_map>
  8017ac:	89 c7                	mov    %eax,%edi
  8017ae:	83 c4 20             	add    $0x20,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 2e                	js     8017e3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017b8:	89 d0                	mov    %edx,%eax
  8017ba:	c1 e8 0c             	shr    $0xc,%eax
  8017bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017c4:	83 ec 0c             	sub    $0xc,%esp
  8017c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8017cc:	50                   	push   %eax
  8017cd:	53                   	push   %ebx
  8017ce:	6a 00                	push   $0x0
  8017d0:	52                   	push   %edx
  8017d1:	6a 00                	push   $0x0
  8017d3:	e8 a5 f4 ff ff       	call   800c7d <sys_page_map>
  8017d8:	89 c7                	mov    %eax,%edi
  8017da:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8017dd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017df:	85 ff                	test   %edi,%edi
  8017e1:	79 1d                	jns    801800 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	53                   	push   %ebx
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 d1 f4 ff ff       	call   800cbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ee:	83 c4 08             	add    $0x8,%esp
  8017f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017f4:	6a 00                	push   $0x0
  8017f6:	e8 c4 f4 ff ff       	call   800cbf <sys_page_unmap>
	return r;
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	89 f8                	mov    %edi,%eax
}
  801800:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5f                   	pop    %edi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	53                   	push   %ebx
  80180c:	83 ec 14             	sub    $0x14,%esp
  80180f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801812:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	53                   	push   %ebx
  801817:	e8 83 fd ff ff       	call   80159f <fd_lookup>
  80181c:	83 c4 08             	add    $0x8,%esp
  80181f:	89 c2                	mov    %eax,%edx
  801821:	85 c0                	test   %eax,%eax
  801823:	78 70                	js     801895 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801825:	83 ec 08             	sub    $0x8,%esp
  801828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182f:	ff 30                	pushl  (%eax)
  801831:	e8 bf fd ff ff       	call   8015f5 <dev_lookup>
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 4f                	js     80188c <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80183d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801840:	8b 42 08             	mov    0x8(%edx),%eax
  801843:	83 e0 03             	and    $0x3,%eax
  801846:	83 f8 01             	cmp    $0x1,%eax
  801849:	75 24                	jne    80186f <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80184b:	a1 04 40 80 00       	mov    0x804004,%eax
  801850:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	53                   	push   %ebx
  80185a:	50                   	push   %eax
  80185b:	68 61 2b 80 00       	push   $0x802b61
  801860:	e8 4d ea ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80186d:	eb 26                	jmp    801895 <read+0x8d>
	}
	if (!dev->dev_read)
  80186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801872:	8b 40 08             	mov    0x8(%eax),%eax
  801875:	85 c0                	test   %eax,%eax
  801877:	74 17                	je     801890 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801879:	83 ec 04             	sub    $0x4,%esp
  80187c:	ff 75 10             	pushl  0x10(%ebp)
  80187f:	ff 75 0c             	pushl  0xc(%ebp)
  801882:	52                   	push   %edx
  801883:	ff d0                	call   *%eax
  801885:	89 c2                	mov    %eax,%edx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb 09                	jmp    801895 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188c:	89 c2                	mov    %eax,%edx
  80188e:	eb 05                	jmp    801895 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801890:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801895:	89 d0                	mov    %edx,%eax
  801897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	57                   	push   %edi
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b0:	eb 21                	jmp    8018d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	89 f0                	mov    %esi,%eax
  8018b7:	29 d8                	sub    %ebx,%eax
  8018b9:	50                   	push   %eax
  8018ba:	89 d8                	mov    %ebx,%eax
  8018bc:	03 45 0c             	add    0xc(%ebp),%eax
  8018bf:	50                   	push   %eax
  8018c0:	57                   	push   %edi
  8018c1:	e8 42 ff ff ff       	call   801808 <read>
		if (m < 0)
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 10                	js     8018dd <readn+0x41>
			return m;
		if (m == 0)
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	74 0a                	je     8018db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d1:	01 c3                	add    %eax,%ebx
  8018d3:	39 f3                	cmp    %esi,%ebx
  8018d5:	72 db                	jb     8018b2 <readn+0x16>
  8018d7:	89 d8                	mov    %ebx,%eax
  8018d9:	eb 02                	jmp    8018dd <readn+0x41>
  8018db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5f                   	pop    %edi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 14             	sub    $0x14,%esp
  8018ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f2:	50                   	push   %eax
  8018f3:	53                   	push   %ebx
  8018f4:	e8 a6 fc ff ff       	call   80159f <fd_lookup>
  8018f9:	83 c4 08             	add    $0x8,%esp
  8018fc:	89 c2                	mov    %eax,%edx
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 6b                	js     80196d <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801908:	50                   	push   %eax
  801909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190c:	ff 30                	pushl  (%eax)
  80190e:	e8 e2 fc ff ff       	call   8015f5 <dev_lookup>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 4a                	js     801964 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80191a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801921:	75 24                	jne    801947 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801923:	a1 04 40 80 00       	mov    0x804004,%eax
  801928:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80192e:	83 ec 04             	sub    $0x4,%esp
  801931:	53                   	push   %ebx
  801932:	50                   	push   %eax
  801933:	68 7d 2b 80 00       	push   $0x802b7d
  801938:	e8 75 e9 ff ff       	call   8002b2 <cprintf>
		return -E_INVAL;
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801945:	eb 26                	jmp    80196d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801947:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194a:	8b 52 0c             	mov    0xc(%edx),%edx
  80194d:	85 d2                	test   %edx,%edx
  80194f:	74 17                	je     801968 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801951:	83 ec 04             	sub    $0x4,%esp
  801954:	ff 75 10             	pushl  0x10(%ebp)
  801957:	ff 75 0c             	pushl  0xc(%ebp)
  80195a:	50                   	push   %eax
  80195b:	ff d2                	call   *%edx
  80195d:	89 c2                	mov    %eax,%edx
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	eb 09                	jmp    80196d <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801964:	89 c2                	mov    %eax,%edx
  801966:	eb 05                	jmp    80196d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801968:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80196d:	89 d0                	mov    %edx,%eax
  80196f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <seek>:

int
seek(int fdnum, off_t offset)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	ff 75 08             	pushl  0x8(%ebp)
  801981:	e8 19 fc ff ff       	call   80159f <fd_lookup>
  801986:	83 c4 08             	add    $0x8,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 0e                	js     80199b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80198d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801990:	8b 55 0c             	mov    0xc(%ebp),%edx
  801993:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801996:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 14             	sub    $0x14,%esp
  8019a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	53                   	push   %ebx
  8019ac:	e8 ee fb ff ff       	call   80159f <fd_lookup>
  8019b1:	83 c4 08             	add    $0x8,%esp
  8019b4:	89 c2                	mov    %eax,%edx
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 68                	js     801a22 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c0:	50                   	push   %eax
  8019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c4:	ff 30                	pushl  (%eax)
  8019c6:	e8 2a fc ff ff       	call   8015f5 <dev_lookup>
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 47                	js     801a19 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019d9:	75 24                	jne    8019ff <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019db:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019e0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8019e6:	83 ec 04             	sub    $0x4,%esp
  8019e9:	53                   	push   %ebx
  8019ea:	50                   	push   %eax
  8019eb:	68 40 2b 80 00       	push   $0x802b40
  8019f0:	e8 bd e8 ff ff       	call   8002b2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019fd:	eb 23                	jmp    801a22 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8019ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a02:	8b 52 18             	mov    0x18(%edx),%edx
  801a05:	85 d2                	test   %edx,%edx
  801a07:	74 14                	je     801a1d <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	ff 75 0c             	pushl  0xc(%ebp)
  801a0f:	50                   	push   %eax
  801a10:	ff d2                	call   *%edx
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	eb 09                	jmp    801a22 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	eb 05                	jmp    801a22 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a1d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801a22:	89 d0                	mov    %edx,%eax
  801a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 14             	sub    $0x14,%esp
  801a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	ff 75 08             	pushl  0x8(%ebp)
  801a3a:	e8 60 fb ff ff       	call   80159f <fd_lookup>
  801a3f:	83 c4 08             	add    $0x8,%esp
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	85 c0                	test   %eax,%eax
  801a46:	78 58                	js     801aa0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a48:	83 ec 08             	sub    $0x8,%esp
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a52:	ff 30                	pushl  (%eax)
  801a54:	e8 9c fb ff ff       	call   8015f5 <dev_lookup>
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 37                	js     801a97 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a63:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a67:	74 32                	je     801a9b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a69:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a6c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a73:	00 00 00 
	stat->st_isdir = 0;
  801a76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a7d:	00 00 00 
	stat->st_dev = dev;
  801a80:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a86:	83 ec 08             	sub    $0x8,%esp
  801a89:	53                   	push   %ebx
  801a8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801a8d:	ff 50 14             	call   *0x14(%eax)
  801a90:	89 c2                	mov    %eax,%edx
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb 09                	jmp    801aa0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a97:	89 c2                	mov    %eax,%edx
  801a99:	eb 05                	jmp    801aa0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a9b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801aa0:	89 d0                	mov    %edx,%eax
  801aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	6a 00                	push   $0x0
  801ab1:	ff 75 08             	pushl  0x8(%ebp)
  801ab4:	e8 e3 01 00 00       	call   801c9c <open>
  801ab9:	89 c3                	mov    %eax,%ebx
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 1b                	js     801add <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	ff 75 0c             	pushl  0xc(%ebp)
  801ac8:	50                   	push   %eax
  801ac9:	e8 5b ff ff ff       	call   801a29 <fstat>
  801ace:	89 c6                	mov    %eax,%esi
	close(fd);
  801ad0:	89 1c 24             	mov    %ebx,(%esp)
  801ad3:	e8 f4 fb ff ff       	call   8016cc <close>
	return r;
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	89 f0                	mov    %esi,%eax
}
  801add:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	89 c6                	mov    %eax,%esi
  801aeb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801aed:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801af4:	75 12                	jne    801b08 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	6a 01                	push   $0x1
  801afb:	e8 e4 f9 ff ff       	call   8014e4 <ipc_find_env>
  801b00:	a3 00 40 80 00       	mov    %eax,0x804000
  801b05:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b08:	6a 07                	push   $0x7
  801b0a:	68 00 50 80 00       	push   $0x805000
  801b0f:	56                   	push   %esi
  801b10:	ff 35 00 40 80 00    	pushl  0x804000
  801b16:	e8 67 f9 ff ff       	call   801482 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b1b:	83 c4 0c             	add    $0xc,%esp
  801b1e:	6a 00                	push   $0x0
  801b20:	53                   	push   %ebx
  801b21:	6a 00                	push   $0x0
  801b23:	e8 df f8 ff ff       	call   801407 <ipc_recv>
}
  801b28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b43:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b48:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  801b52:	e8 8d ff ff ff       	call   801ae4 <fsipc>
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	8b 40 0c             	mov    0xc(%eax),%eax
  801b65:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6f:	b8 06 00 00 00       	mov    $0x6,%eax
  801b74:	e8 6b ff ff ff       	call   801ae4 <fsipc>
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	53                   	push   %ebx
  801b7f:	83 ec 04             	sub    $0x4,%esp
  801b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b90:	ba 00 00 00 00       	mov    $0x0,%edx
  801b95:	b8 05 00 00 00       	mov    $0x5,%eax
  801b9a:	e8 45 ff ff ff       	call   801ae4 <fsipc>
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 2c                	js     801bcf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ba3:	83 ec 08             	sub    $0x8,%esp
  801ba6:	68 00 50 80 00       	push   $0x805000
  801bab:	53                   	push   %ebx
  801bac:	e8 86 ec ff ff       	call   800837 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bb1:	a1 80 50 80 00       	mov    0x805080,%eax
  801bb6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bbc:	a1 84 50 80 00       	mov    0x805084,%eax
  801bc1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bdd:	8b 55 08             	mov    0x8(%ebp),%edx
  801be0:	8b 52 0c             	mov    0xc(%edx),%edx
  801be3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801be9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801bee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801bf3:	0f 47 c2             	cmova  %edx,%eax
  801bf6:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801bfb:	50                   	push   %eax
  801bfc:	ff 75 0c             	pushl  0xc(%ebp)
  801bff:	68 08 50 80 00       	push   $0x805008
  801c04:	e8 c0 ed ff ff       	call   8009c9 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801c09:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0e:	b8 04 00 00 00       	mov    $0x4,%eax
  801c13:	e8 cc fe ff ff       	call   801ae4 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	56                   	push   %esi
  801c1e:	53                   	push   %ebx
  801c1f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	8b 40 0c             	mov    0xc(%eax),%eax
  801c28:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c2d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c33:	ba 00 00 00 00       	mov    $0x0,%edx
  801c38:	b8 03 00 00 00       	mov    $0x3,%eax
  801c3d:	e8 a2 fe ff ff       	call   801ae4 <fsipc>
  801c42:	89 c3                	mov    %eax,%ebx
  801c44:	85 c0                	test   %eax,%eax
  801c46:	78 4b                	js     801c93 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c48:	39 c6                	cmp    %eax,%esi
  801c4a:	73 16                	jae    801c62 <devfile_read+0x48>
  801c4c:	68 ac 2b 80 00       	push   $0x802bac
  801c51:	68 b3 2b 80 00       	push   $0x802bb3
  801c56:	6a 7c                	push   $0x7c
  801c58:	68 c8 2b 80 00       	push   $0x802bc8
  801c5d:	e8 c6 05 00 00       	call   802228 <_panic>
	assert(r <= PGSIZE);
  801c62:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c67:	7e 16                	jle    801c7f <devfile_read+0x65>
  801c69:	68 d3 2b 80 00       	push   $0x802bd3
  801c6e:	68 b3 2b 80 00       	push   $0x802bb3
  801c73:	6a 7d                	push   $0x7d
  801c75:	68 c8 2b 80 00       	push   $0x802bc8
  801c7a:	e8 a9 05 00 00       	call   802228 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c7f:	83 ec 04             	sub    $0x4,%esp
  801c82:	50                   	push   %eax
  801c83:	68 00 50 80 00       	push   $0x805000
  801c88:	ff 75 0c             	pushl  0xc(%ebp)
  801c8b:	e8 39 ed ff ff       	call   8009c9 <memmove>
	return r;
  801c90:	83 c4 10             	add    $0x10,%esp
}
  801c93:	89 d8                	mov    %ebx,%eax
  801c95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	53                   	push   %ebx
  801ca0:	83 ec 20             	sub    $0x20,%esp
  801ca3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ca6:	53                   	push   %ebx
  801ca7:	e8 52 eb ff ff       	call   8007fe <strlen>
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cb4:	7f 67                	jg     801d1d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	e8 8e f8 ff ff       	call   801550 <fd_alloc>
  801cc2:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 57                	js     801d22 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ccb:	83 ec 08             	sub    $0x8,%esp
  801cce:	53                   	push   %ebx
  801ccf:	68 00 50 80 00       	push   $0x805000
  801cd4:	e8 5e eb ff ff       	call   800837 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ce1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce9:	e8 f6 fd ff ff       	call   801ae4 <fsipc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	79 14                	jns    801d0b <open+0x6f>
		fd_close(fd, 0);
  801cf7:	83 ec 08             	sub    $0x8,%esp
  801cfa:	6a 00                	push   $0x0
  801cfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cff:	e8 47 f9 ff ff       	call   80164b <fd_close>
		return r;
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	89 da                	mov    %ebx,%edx
  801d09:	eb 17                	jmp    801d22 <open+0x86>
	}

	return fd2num(fd);
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d11:	e8 13 f8 ff ff       	call   801529 <fd2num>
  801d16:	89 c2                	mov    %eax,%edx
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	eb 05                	jmp    801d22 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d1d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d22:	89 d0                	mov    %edx,%eax
  801d24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    

00801d29 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d34:	b8 08 00 00 00       	mov    $0x8,%eax
  801d39:	e8 a6 fd ff ff       	call   801ae4 <fsipc>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	56                   	push   %esi
  801d44:	53                   	push   %ebx
  801d45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d48:	83 ec 0c             	sub    $0xc,%esp
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	e8 e6 f7 ff ff       	call   801539 <fd2data>
  801d53:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d55:	83 c4 08             	add    $0x8,%esp
  801d58:	68 df 2b 80 00       	push   $0x802bdf
  801d5d:	53                   	push   %ebx
  801d5e:	e8 d4 ea ff ff       	call   800837 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d63:	8b 46 04             	mov    0x4(%esi),%eax
  801d66:	2b 06                	sub    (%esi),%eax
  801d68:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d6e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d75:	00 00 00 
	stat->st_dev = &devpipe;
  801d78:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801d7f:	30 80 00 
	return 0;
}
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
  801d87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	53                   	push   %ebx
  801d92:	83 ec 0c             	sub    $0xc,%esp
  801d95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d98:	53                   	push   %ebx
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 1f ef ff ff       	call   800cbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801da0:	89 1c 24             	mov    %ebx,(%esp)
  801da3:	e8 91 f7 ff ff       	call   801539 <fd2data>
  801da8:	83 c4 08             	add    $0x8,%esp
  801dab:	50                   	push   %eax
  801dac:	6a 00                	push   $0x0
  801dae:	e8 0c ef ff ff       	call   800cbf <sys_page_unmap>
}
  801db3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	57                   	push   %edi
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
  801dbe:	83 ec 1c             	sub    $0x1c,%esp
  801dc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dc4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801dc6:	a1 04 40 80 00       	mov    0x804004,%eax
  801dcb:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff 75 e0             	pushl  -0x20(%ebp)
  801dd7:	e8 21 05 00 00       	call   8022fd <pageref>
  801ddc:	89 c3                	mov    %eax,%ebx
  801dde:	89 3c 24             	mov    %edi,(%esp)
  801de1:	e8 17 05 00 00       	call   8022fd <pageref>
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	39 c3                	cmp    %eax,%ebx
  801deb:	0f 94 c1             	sete   %cl
  801dee:	0f b6 c9             	movzbl %cl,%ecx
  801df1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801df4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dfa:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801e00:	39 ce                	cmp    %ecx,%esi
  801e02:	74 1e                	je     801e22 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801e04:	39 c3                	cmp    %eax,%ebx
  801e06:	75 be                	jne    801dc6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e08:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801e0e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e11:	50                   	push   %eax
  801e12:	56                   	push   %esi
  801e13:	68 e6 2b 80 00       	push   $0x802be6
  801e18:	e8 95 e4 ff ff       	call   8002b2 <cprintf>
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	eb a4                	jmp    801dc6 <_pipeisclosed+0xe>
	}
}
  801e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	57                   	push   %edi
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	83 ec 28             	sub    $0x28,%esp
  801e36:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e39:	56                   	push   %esi
  801e3a:	e8 fa f6 ff ff       	call   801539 <fd2data>
  801e3f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	bf 00 00 00 00       	mov    $0x0,%edi
  801e49:	eb 4b                	jmp    801e96 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e4b:	89 da                	mov    %ebx,%edx
  801e4d:	89 f0                	mov    %esi,%eax
  801e4f:	e8 64 ff ff ff       	call   801db8 <_pipeisclosed>
  801e54:	85 c0                	test   %eax,%eax
  801e56:	75 48                	jne    801ea0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e58:	e8 be ed ff ff       	call   800c1b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e5d:	8b 43 04             	mov    0x4(%ebx),%eax
  801e60:	8b 0b                	mov    (%ebx),%ecx
  801e62:	8d 51 20             	lea    0x20(%ecx),%edx
  801e65:	39 d0                	cmp    %edx,%eax
  801e67:	73 e2                	jae    801e4b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e6c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e70:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e73:	89 c2                	mov    %eax,%edx
  801e75:	c1 fa 1f             	sar    $0x1f,%edx
  801e78:	89 d1                	mov    %edx,%ecx
  801e7a:	c1 e9 1b             	shr    $0x1b,%ecx
  801e7d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e80:	83 e2 1f             	and    $0x1f,%edx
  801e83:	29 ca                	sub    %ecx,%edx
  801e85:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e89:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e8d:	83 c0 01             	add    $0x1,%eax
  801e90:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e93:	83 c7 01             	add    $0x1,%edi
  801e96:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e99:	75 c2                	jne    801e5d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e9e:	eb 05                	jmp    801ea5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ea0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	57                   	push   %edi
  801eb1:	56                   	push   %esi
  801eb2:	53                   	push   %ebx
  801eb3:	83 ec 18             	sub    $0x18,%esp
  801eb6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801eb9:	57                   	push   %edi
  801eba:	e8 7a f6 ff ff       	call   801539 <fd2data>
  801ebf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec9:	eb 3d                	jmp    801f08 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ecb:	85 db                	test   %ebx,%ebx
  801ecd:	74 04                	je     801ed3 <devpipe_read+0x26>
				return i;
  801ecf:	89 d8                	mov    %ebx,%eax
  801ed1:	eb 44                	jmp    801f17 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ed3:	89 f2                	mov    %esi,%edx
  801ed5:	89 f8                	mov    %edi,%eax
  801ed7:	e8 dc fe ff ff       	call   801db8 <_pipeisclosed>
  801edc:	85 c0                	test   %eax,%eax
  801ede:	75 32                	jne    801f12 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ee0:	e8 36 ed ff ff       	call   800c1b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ee5:	8b 06                	mov    (%esi),%eax
  801ee7:	3b 46 04             	cmp    0x4(%esi),%eax
  801eea:	74 df                	je     801ecb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eec:	99                   	cltd   
  801eed:	c1 ea 1b             	shr    $0x1b,%edx
  801ef0:	01 d0                	add    %edx,%eax
  801ef2:	83 e0 1f             	and    $0x1f,%eax
  801ef5:	29 d0                	sub    %edx,%eax
  801ef7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eff:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f02:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f05:	83 c3 01             	add    $0x1,%ebx
  801f08:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f0b:	75 d8                	jne    801ee5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f0d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f10:	eb 05                	jmp    801f17 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f12:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5f                   	pop    %edi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2a:	50                   	push   %eax
  801f2b:	e8 20 f6 ff ff       	call   801550 <fd_alloc>
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	89 c2                	mov    %eax,%edx
  801f35:	85 c0                	test   %eax,%eax
  801f37:	0f 88 2c 01 00 00    	js     802069 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f3d:	83 ec 04             	sub    $0x4,%esp
  801f40:	68 07 04 00 00       	push   $0x407
  801f45:	ff 75 f4             	pushl  -0xc(%ebp)
  801f48:	6a 00                	push   $0x0
  801f4a:	e8 eb ec ff ff       	call   800c3a <sys_page_alloc>
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	89 c2                	mov    %eax,%edx
  801f54:	85 c0                	test   %eax,%eax
  801f56:	0f 88 0d 01 00 00    	js     802069 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	e8 e8 f5 ff ff       	call   801550 <fd_alloc>
  801f68:	89 c3                	mov    %eax,%ebx
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	0f 88 e2 00 00 00    	js     802057 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f75:	83 ec 04             	sub    $0x4,%esp
  801f78:	68 07 04 00 00       	push   $0x407
  801f7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f80:	6a 00                	push   $0x0
  801f82:	e8 b3 ec ff ff       	call   800c3a <sys_page_alloc>
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	0f 88 c3 00 00 00    	js     802057 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9a:	e8 9a f5 ff ff       	call   801539 <fd2data>
  801f9f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa1:	83 c4 0c             	add    $0xc,%esp
  801fa4:	68 07 04 00 00       	push   $0x407
  801fa9:	50                   	push   %eax
  801faa:	6a 00                	push   $0x0
  801fac:	e8 89 ec ff ff       	call   800c3a <sys_page_alloc>
  801fb1:	89 c3                	mov    %eax,%ebx
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	0f 88 89 00 00 00    	js     802047 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fbe:	83 ec 0c             	sub    $0xc,%esp
  801fc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc4:	e8 70 f5 ff ff       	call   801539 <fd2data>
  801fc9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fd0:	50                   	push   %eax
  801fd1:	6a 00                	push   $0x0
  801fd3:	56                   	push   %esi
  801fd4:	6a 00                	push   $0x0
  801fd6:	e8 a2 ec ff ff       	call   800c7d <sys_page_map>
  801fdb:	89 c3                	mov    %eax,%ebx
  801fdd:	83 c4 20             	add    $0x20,%esp
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	78 55                	js     802039 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fe4:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fed:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ff9:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801fff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802002:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802004:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802007:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80200e:	83 ec 0c             	sub    $0xc,%esp
  802011:	ff 75 f4             	pushl  -0xc(%ebp)
  802014:	e8 10 f5 ff ff       	call   801529 <fd2num>
  802019:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80201c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80201e:	83 c4 04             	add    $0x4,%esp
  802021:	ff 75 f0             	pushl  -0x10(%ebp)
  802024:	e8 00 f5 ff ff       	call   801529 <fd2num>
  802029:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80202c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	ba 00 00 00 00       	mov    $0x0,%edx
  802037:	eb 30                	jmp    802069 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802039:	83 ec 08             	sub    $0x8,%esp
  80203c:	56                   	push   %esi
  80203d:	6a 00                	push   $0x0
  80203f:	e8 7b ec ff ff       	call   800cbf <sys_page_unmap>
  802044:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802047:	83 ec 08             	sub    $0x8,%esp
  80204a:	ff 75 f0             	pushl  -0x10(%ebp)
  80204d:	6a 00                	push   $0x0
  80204f:	e8 6b ec ff ff       	call   800cbf <sys_page_unmap>
  802054:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802057:	83 ec 08             	sub    $0x8,%esp
  80205a:	ff 75 f4             	pushl  -0xc(%ebp)
  80205d:	6a 00                	push   $0x0
  80205f:	e8 5b ec ff ff       	call   800cbf <sys_page_unmap>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802069:	89 d0                	mov    %edx,%eax
  80206b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206e:	5b                   	pop    %ebx
  80206f:	5e                   	pop    %esi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    

00802072 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207b:	50                   	push   %eax
  80207c:	ff 75 08             	pushl  0x8(%ebp)
  80207f:	e8 1b f5 ff ff       	call   80159f <fd_lookup>
  802084:	83 c4 10             	add    $0x10,%esp
  802087:	85 c0                	test   %eax,%eax
  802089:	78 18                	js     8020a3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80208b:	83 ec 0c             	sub    $0xc,%esp
  80208e:	ff 75 f4             	pushl  -0xc(%ebp)
  802091:	e8 a3 f4 ff ff       	call   801539 <fd2data>
	return _pipeisclosed(fd, p);
  802096:	89 c2                	mov    %eax,%edx
  802098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209b:	e8 18 fd ff ff       	call   801db8 <_pipeisclosed>
  8020a0:	83 c4 10             	add    $0x10,%esp
}
  8020a3:	c9                   	leave  
  8020a4:	c3                   	ret    

008020a5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    

008020af <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020b5:	68 fe 2b 80 00       	push   $0x802bfe
  8020ba:	ff 75 0c             	pushl  0xc(%ebp)
  8020bd:	e8 75 e7 ff ff       	call   800837 <strcpy>
	return 0;
}
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c7:	c9                   	leave  
  8020c8:	c3                   	ret    

008020c9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	57                   	push   %edi
  8020cd:	56                   	push   %esi
  8020ce:	53                   	push   %ebx
  8020cf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020d5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020da:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020e0:	eb 2d                	jmp    80210f <devcons_write+0x46>
		m = n - tot;
  8020e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020e5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020e7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020ea:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020ef:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020f2:	83 ec 04             	sub    $0x4,%esp
  8020f5:	53                   	push   %ebx
  8020f6:	03 45 0c             	add    0xc(%ebp),%eax
  8020f9:	50                   	push   %eax
  8020fa:	57                   	push   %edi
  8020fb:	e8 c9 e8 ff ff       	call   8009c9 <memmove>
		sys_cputs(buf, m);
  802100:	83 c4 08             	add    $0x8,%esp
  802103:	53                   	push   %ebx
  802104:	57                   	push   %edi
  802105:	e8 74 ea ff ff       	call   800b7e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80210a:	01 de                	add    %ebx,%esi
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	89 f0                	mov    %esi,%eax
  802111:	3b 75 10             	cmp    0x10(%ebp),%esi
  802114:	72 cc                	jb     8020e2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802119:	5b                   	pop    %ebx
  80211a:	5e                   	pop    %esi
  80211b:	5f                   	pop    %edi
  80211c:	5d                   	pop    %ebp
  80211d:	c3                   	ret    

0080211e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	83 ec 08             	sub    $0x8,%esp
  802124:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802129:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80212d:	74 2a                	je     802159 <devcons_read+0x3b>
  80212f:	eb 05                	jmp    802136 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802131:	e8 e5 ea ff ff       	call   800c1b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802136:	e8 61 ea ff ff       	call   800b9c <sys_cgetc>
  80213b:	85 c0                	test   %eax,%eax
  80213d:	74 f2                	je     802131 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80213f:	85 c0                	test   %eax,%eax
  802141:	78 16                	js     802159 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802143:	83 f8 04             	cmp    $0x4,%eax
  802146:	74 0c                	je     802154 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802148:	8b 55 0c             	mov    0xc(%ebp),%edx
  80214b:	88 02                	mov    %al,(%edx)
	return 1;
  80214d:	b8 01 00 00 00       	mov    $0x1,%eax
  802152:	eb 05                	jmp    802159 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802154:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80215b:	55                   	push   %ebp
  80215c:	89 e5                	mov    %esp,%ebp
  80215e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802161:	8b 45 08             	mov    0x8(%ebp),%eax
  802164:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802167:	6a 01                	push   $0x1
  802169:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80216c:	50                   	push   %eax
  80216d:	e8 0c ea ff ff       	call   800b7e <sys_cputs>
}
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <getchar>:

int
getchar(void)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80217d:	6a 01                	push   $0x1
  80217f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802182:	50                   	push   %eax
  802183:	6a 00                	push   $0x0
  802185:	e8 7e f6 ff ff       	call   801808 <read>
	if (r < 0)
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 0f                	js     8021a0 <getchar+0x29>
		return r;
	if (r < 1)
  802191:	85 c0                	test   %eax,%eax
  802193:	7e 06                	jle    80219b <getchar+0x24>
		return -E_EOF;
	return c;
  802195:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802199:	eb 05                	jmp    8021a0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80219b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    

008021a2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	ff 75 08             	pushl  0x8(%ebp)
  8021af:	e8 eb f3 ff ff       	call   80159f <fd_lookup>
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	78 11                	js     8021cc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021be:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8021c4:	39 10                	cmp    %edx,(%eax)
  8021c6:	0f 94 c0             	sete   %al
  8021c9:	0f b6 c0             	movzbl %al,%eax
}
  8021cc:	c9                   	leave  
  8021cd:	c3                   	ret    

008021ce <opencons>:

int
opencons(void)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d7:	50                   	push   %eax
  8021d8:	e8 73 f3 ff ff       	call   801550 <fd_alloc>
  8021dd:	83 c4 10             	add    $0x10,%esp
		return r;
  8021e0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	78 3e                	js     802224 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021e6:	83 ec 04             	sub    $0x4,%esp
  8021e9:	68 07 04 00 00       	push   $0x407
  8021ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f1:	6a 00                	push   $0x0
  8021f3:	e8 42 ea ff ff       	call   800c3a <sys_page_alloc>
  8021f8:	83 c4 10             	add    $0x10,%esp
		return r;
  8021fb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	78 23                	js     802224 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802201:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802207:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802216:	83 ec 0c             	sub    $0xc,%esp
  802219:	50                   	push   %eax
  80221a:	e8 0a f3 ff ff       	call   801529 <fd2num>
  80221f:	89 c2                	mov    %eax,%edx
  802221:	83 c4 10             	add    $0x10,%esp
}
  802224:	89 d0                	mov    %edx,%eax
  802226:	c9                   	leave  
  802227:	c3                   	ret    

00802228 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	56                   	push   %esi
  80222c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80222d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802230:	8b 35 08 30 80 00    	mov    0x803008,%esi
  802236:	e8 c1 e9 ff ff       	call   800bfc <sys_getenvid>
  80223b:	83 ec 0c             	sub    $0xc,%esp
  80223e:	ff 75 0c             	pushl  0xc(%ebp)
  802241:	ff 75 08             	pushl  0x8(%ebp)
  802244:	56                   	push   %esi
  802245:	50                   	push   %eax
  802246:	68 0c 2c 80 00       	push   $0x802c0c
  80224b:	e8 62 e0 ff ff       	call   8002b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802250:	83 c4 18             	add    $0x18,%esp
  802253:	53                   	push   %ebx
  802254:	ff 75 10             	pushl  0x10(%ebp)
  802257:	e8 05 e0 ff ff       	call   800261 <vcprintf>
	cprintf("\n");
  80225c:	c7 04 24 46 2a 80 00 	movl   $0x802a46,(%esp)
  802263:	e8 4a e0 ff ff       	call   8002b2 <cprintf>
  802268:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80226b:	cc                   	int3   
  80226c:	eb fd                	jmp    80226b <_panic+0x43>

0080226e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802274:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80227b:	75 2a                	jne    8022a7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80227d:	83 ec 04             	sub    $0x4,%esp
  802280:	6a 07                	push   $0x7
  802282:	68 00 f0 bf ee       	push   $0xeebff000
  802287:	6a 00                	push   $0x0
  802289:	e8 ac e9 ff ff       	call   800c3a <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80228e:	83 c4 10             	add    $0x10,%esp
  802291:	85 c0                	test   %eax,%eax
  802293:	79 12                	jns    8022a7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802295:	50                   	push   %eax
  802296:	68 78 2a 80 00       	push   $0x802a78
  80229b:	6a 23                	push   $0x23
  80229d:	68 30 2c 80 00       	push   $0x802c30
  8022a2:	e8 81 ff ff ff       	call   802228 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022aa:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8022af:	83 ec 08             	sub    $0x8,%esp
  8022b2:	68 d9 22 80 00       	push   $0x8022d9
  8022b7:	6a 00                	push   $0x0
  8022b9:	e8 c7 ea ff ff       	call   800d85 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	85 c0                	test   %eax,%eax
  8022c3:	79 12                	jns    8022d7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8022c5:	50                   	push   %eax
  8022c6:	68 78 2a 80 00       	push   $0x802a78
  8022cb:	6a 2c                	push   $0x2c
  8022cd:	68 30 2c 80 00       	push   $0x802c30
  8022d2:	e8 51 ff ff ff       	call   802228 <_panic>
	}
}
  8022d7:	c9                   	leave  
  8022d8:	c3                   	ret    

008022d9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022d9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022da:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022df:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022e1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8022e4:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8022e8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8022ed:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8022f1:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8022f3:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8022f6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8022f7:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8022fa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8022fb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022fc:	c3                   	ret    

008022fd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802303:	89 d0                	mov    %edx,%eax
  802305:	c1 e8 16             	shr    $0x16,%eax
  802308:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80230f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802314:	f6 c1 01             	test   $0x1,%cl
  802317:	74 1d                	je     802336 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802319:	c1 ea 0c             	shr    $0xc,%edx
  80231c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802323:	f6 c2 01             	test   $0x1,%dl
  802326:	74 0e                	je     802336 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802328:	c1 ea 0c             	shr    $0xc,%edx
  80232b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802332:	ef 
  802333:	0f b7 c0             	movzwl %ax,%eax
}
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__udivdi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80234b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80234f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 f6                	test   %esi,%esi
  802359:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80235d:	89 ca                	mov    %ecx,%edx
  80235f:	89 f8                	mov    %edi,%eax
  802361:	75 3d                	jne    8023a0 <__udivdi3+0x60>
  802363:	39 cf                	cmp    %ecx,%edi
  802365:	0f 87 c5 00 00 00    	ja     802430 <__udivdi3+0xf0>
  80236b:	85 ff                	test   %edi,%edi
  80236d:	89 fd                	mov    %edi,%ebp
  80236f:	75 0b                	jne    80237c <__udivdi3+0x3c>
  802371:	b8 01 00 00 00       	mov    $0x1,%eax
  802376:	31 d2                	xor    %edx,%edx
  802378:	f7 f7                	div    %edi
  80237a:	89 c5                	mov    %eax,%ebp
  80237c:	89 c8                	mov    %ecx,%eax
  80237e:	31 d2                	xor    %edx,%edx
  802380:	f7 f5                	div    %ebp
  802382:	89 c1                	mov    %eax,%ecx
  802384:	89 d8                	mov    %ebx,%eax
  802386:	89 cf                	mov    %ecx,%edi
  802388:	f7 f5                	div    %ebp
  80238a:	89 c3                	mov    %eax,%ebx
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
  8023a0:	39 ce                	cmp    %ecx,%esi
  8023a2:	77 74                	ja     802418 <__udivdi3+0xd8>
  8023a4:	0f bd fe             	bsr    %esi,%edi
  8023a7:	83 f7 1f             	xor    $0x1f,%edi
  8023aa:	0f 84 98 00 00 00    	je     802448 <__udivdi3+0x108>
  8023b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	89 c5                	mov    %eax,%ebp
  8023b9:	29 fb                	sub    %edi,%ebx
  8023bb:	d3 e6                	shl    %cl,%esi
  8023bd:	89 d9                	mov    %ebx,%ecx
  8023bf:	d3 ed                	shr    %cl,%ebp
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	d3 e0                	shl    %cl,%eax
  8023c5:	09 ee                	or     %ebp,%esi
  8023c7:	89 d9                	mov    %ebx,%ecx
  8023c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023cd:	89 d5                	mov    %edx,%ebp
  8023cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023d3:	d3 ed                	shr    %cl,%ebp
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	d3 e2                	shl    %cl,%edx
  8023d9:	89 d9                	mov    %ebx,%ecx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	09 c2                	or     %eax,%edx
  8023df:	89 d0                	mov    %edx,%eax
  8023e1:	89 ea                	mov    %ebp,%edx
  8023e3:	f7 f6                	div    %esi
  8023e5:	89 d5                	mov    %edx,%ebp
  8023e7:	89 c3                	mov    %eax,%ebx
  8023e9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	72 10                	jb     802401 <__udivdi3+0xc1>
  8023f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e6                	shl    %cl,%esi
  8023f9:	39 c6                	cmp    %eax,%esi
  8023fb:	73 07                	jae    802404 <__udivdi3+0xc4>
  8023fd:	39 d5                	cmp    %edx,%ebp
  8023ff:	75 03                	jne    802404 <__udivdi3+0xc4>
  802401:	83 eb 01             	sub    $0x1,%ebx
  802404:	31 ff                	xor    %edi,%edi
  802406:	89 d8                	mov    %ebx,%eax
  802408:	89 fa                	mov    %edi,%edx
  80240a:	83 c4 1c             	add    $0x1c,%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	31 ff                	xor    %edi,%edi
  80241a:	31 db                	xor    %ebx,%ebx
  80241c:	89 d8                	mov    %ebx,%eax
  80241e:	89 fa                	mov    %edi,%edx
  802420:	83 c4 1c             	add    $0x1c,%esp
  802423:	5b                   	pop    %ebx
  802424:	5e                   	pop    %esi
  802425:	5f                   	pop    %edi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    
  802428:	90                   	nop
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 d8                	mov    %ebx,%eax
  802432:	f7 f7                	div    %edi
  802434:	31 ff                	xor    %edi,%edi
  802436:	89 c3                	mov    %eax,%ebx
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	89 fa                	mov    %edi,%edx
  80243c:	83 c4 1c             	add    $0x1c,%esp
  80243f:	5b                   	pop    %ebx
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	39 ce                	cmp    %ecx,%esi
  80244a:	72 0c                	jb     802458 <__udivdi3+0x118>
  80244c:	31 db                	xor    %ebx,%ebx
  80244e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802452:	0f 87 34 ff ff ff    	ja     80238c <__udivdi3+0x4c>
  802458:	bb 01 00 00 00       	mov    $0x1,%ebx
  80245d:	e9 2a ff ff ff       	jmp    80238c <__udivdi3+0x4c>
  802462:	66 90                	xchg   %ax,%ax
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__umoddi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80247b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80247f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 d2                	test   %edx,%edx
  802489:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80248d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802491:	89 f3                	mov    %esi,%ebx
  802493:	89 3c 24             	mov    %edi,(%esp)
  802496:	89 74 24 04          	mov    %esi,0x4(%esp)
  80249a:	75 1c                	jne    8024b8 <__umoddi3+0x48>
  80249c:	39 f7                	cmp    %esi,%edi
  80249e:	76 50                	jbe    8024f0 <__umoddi3+0x80>
  8024a0:	89 c8                	mov    %ecx,%eax
  8024a2:	89 f2                	mov    %esi,%edx
  8024a4:	f7 f7                	div    %edi
  8024a6:	89 d0                	mov    %edx,%eax
  8024a8:	31 d2                	xor    %edx,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	39 f2                	cmp    %esi,%edx
  8024ba:	89 d0                	mov    %edx,%eax
  8024bc:	77 52                	ja     802510 <__umoddi3+0xa0>
  8024be:	0f bd ea             	bsr    %edx,%ebp
  8024c1:	83 f5 1f             	xor    $0x1f,%ebp
  8024c4:	75 5a                	jne    802520 <__umoddi3+0xb0>
  8024c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ca:	0f 82 e0 00 00 00    	jb     8025b0 <__umoddi3+0x140>
  8024d0:	39 0c 24             	cmp    %ecx,(%esp)
  8024d3:	0f 86 d7 00 00 00    	jbe    8025b0 <__umoddi3+0x140>
  8024d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024e1:	83 c4 1c             	add    $0x1c,%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	85 ff                	test   %edi,%edi
  8024f2:	89 fd                	mov    %edi,%ebp
  8024f4:	75 0b                	jne    802501 <__umoddi3+0x91>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f7                	div    %edi
  8024ff:	89 c5                	mov    %eax,%ebp
  802501:	89 f0                	mov    %esi,%eax
  802503:	31 d2                	xor    %edx,%edx
  802505:	f7 f5                	div    %ebp
  802507:	89 c8                	mov    %ecx,%eax
  802509:	f7 f5                	div    %ebp
  80250b:	89 d0                	mov    %edx,%eax
  80250d:	eb 99                	jmp    8024a8 <__umoddi3+0x38>
  80250f:	90                   	nop
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	83 c4 1c             	add    $0x1c,%esp
  802517:	5b                   	pop    %ebx
  802518:	5e                   	pop    %esi
  802519:	5f                   	pop    %edi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	8b 34 24             	mov    (%esp),%esi
  802523:	bf 20 00 00 00       	mov    $0x20,%edi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	29 ef                	sub    %ebp,%edi
  80252c:	d3 e0                	shl    %cl,%eax
  80252e:	89 f9                	mov    %edi,%ecx
  802530:	89 f2                	mov    %esi,%edx
  802532:	d3 ea                	shr    %cl,%edx
  802534:	89 e9                	mov    %ebp,%ecx
  802536:	09 c2                	or     %eax,%edx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 14 24             	mov    %edx,(%esp)
  80253d:	89 f2                	mov    %esi,%edx
  80253f:	d3 e2                	shl    %cl,%edx
  802541:	89 f9                	mov    %edi,%ecx
  802543:	89 54 24 04          	mov    %edx,0x4(%esp)
  802547:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	89 e9                	mov    %ebp,%ecx
  80254f:	89 c6                	mov    %eax,%esi
  802551:	d3 e3                	shl    %cl,%ebx
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 d0                	mov    %edx,%eax
  802557:	d3 e8                	shr    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	09 d8                	or     %ebx,%eax
  80255d:	89 d3                	mov    %edx,%ebx
  80255f:	89 f2                	mov    %esi,%edx
  802561:	f7 34 24             	divl   (%esp)
  802564:	89 d6                	mov    %edx,%esi
  802566:	d3 e3                	shl    %cl,%ebx
  802568:	f7 64 24 04          	mull   0x4(%esp)
  80256c:	39 d6                	cmp    %edx,%esi
  80256e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802572:	89 d1                	mov    %edx,%ecx
  802574:	89 c3                	mov    %eax,%ebx
  802576:	72 08                	jb     802580 <__umoddi3+0x110>
  802578:	75 11                	jne    80258b <__umoddi3+0x11b>
  80257a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80257e:	73 0b                	jae    80258b <__umoddi3+0x11b>
  802580:	2b 44 24 04          	sub    0x4(%esp),%eax
  802584:	1b 14 24             	sbb    (%esp),%edx
  802587:	89 d1                	mov    %edx,%ecx
  802589:	89 c3                	mov    %eax,%ebx
  80258b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80258f:	29 da                	sub    %ebx,%edx
  802591:	19 ce                	sbb    %ecx,%esi
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 f0                	mov    %esi,%eax
  802597:	d3 e0                	shl    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	d3 ea                	shr    %cl,%edx
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	d3 ee                	shr    %cl,%esi
  8025a1:	09 d0                	or     %edx,%eax
  8025a3:	89 f2                	mov    %esi,%edx
  8025a5:	83 c4 1c             	add    $0x1c,%esp
  8025a8:	5b                   	pop    %ebx
  8025a9:	5e                   	pop    %esi
  8025aa:	5f                   	pop    %edi
  8025ab:	5d                   	pop    %ebp
  8025ac:	c3                   	ret    
  8025ad:	8d 76 00             	lea    0x0(%esi),%esi
  8025b0:	29 f9                	sub    %edi,%ecx
  8025b2:	19 d6                	sbb    %edx,%esi
  8025b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025bc:	e9 18 ff ff ff       	jmp    8024d9 <__umoddi3+0x69>
