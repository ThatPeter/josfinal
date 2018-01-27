
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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
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
  800039:	e8 00 0f 00 00       	call   800f3e <fork>
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
  800057:	e8 00 11 00 00       	call   80115c <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 20 23 80 00       	push   $0x802320
  80006c:	e8 3e 02 00 00       	call   8002af <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 7c 07 00 00       	call   8007fb <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 71 08 00 00       	call   800904 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 34 23 80 00       	push   $0x802334
  8000a2:	e8 08 02 00 00       	call   8002af <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 43 07 00 00       	call   8007fb <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 5f 09 00 00       	call   800a2e <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 f7 10 00 00       	call   8011d7 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 7c             	mov    0x7c(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 37 0b 00 00       	call   800c37 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 ed 06 00 00       	call   8007fb <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 09 09 00 00       	call   800a2e <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 a1 10 00 00       	call   8011d7 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 13 10 00 00       	call   80115c <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 20 23 80 00       	push   $0x802320
  800159:	e8 51 01 00 00       	call   8002af <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 8f 06 00 00       	call   8007fb <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 84 07 00 00       	call   800904 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 54 23 80 00       	push   $0x802354
  80018f:	e8 1b 01 00 00       	call   8002af <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 50 0a 00 00       	call   800bf9 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8001b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b9:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001be:	85 db                	test   %ebx,%ebx
  8001c0:	7e 07                	jle    8001c9 <libmain+0x30>
		binaryname = argv[0];
  8001c2:	8b 06                	mov    (%esi),%eax
  8001c4:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	e8 60 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d3:	e8 2a 00 00 00       	call   800202 <exit>
}
  8001d8:	83 c4 10             	add    $0x10,%esp
  8001db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8001e8:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8001ed:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8001ef:	e8 05 0a 00 00       	call   800bf9 <sys_getenvid>
  8001f4:	83 ec 0c             	sub    $0xc,%esp
  8001f7:	50                   	push   %eax
  8001f8:	e8 4b 0c 00 00       	call   800e48 <sys_thread_free>
}
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800208:	e8 39 12 00 00       	call   801446 <close_all>
	sys_env_destroy(0);
  80020d:	83 ec 0c             	sub    $0xc,%esp
  800210:	6a 00                	push   $0x0
  800212:	e8 a1 09 00 00       	call   800bb8 <sys_env_destroy>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	83 ec 04             	sub    $0x4,%esp
  800223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800226:	8b 13                	mov    (%ebx),%edx
  800228:	8d 42 01             	lea    0x1(%edx),%eax
  80022b:	89 03                	mov    %eax,(%ebx)
  80022d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800230:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800234:	3d ff 00 00 00       	cmp    $0xff,%eax
  800239:	75 1a                	jne    800255 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	68 ff 00 00 00       	push   $0xff
  800243:	8d 43 08             	lea    0x8(%ebx),%eax
  800246:	50                   	push   %eax
  800247:	e8 2f 09 00 00       	call   800b7b <sys_cputs>
		b->idx = 0;
  80024c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800252:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800255:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800259:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800267:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026e:	00 00 00 
	b.cnt = 0;
  800271:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800278:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	ff 75 08             	pushl  0x8(%ebp)
  800281:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800287:	50                   	push   %eax
  800288:	68 1c 02 80 00       	push   $0x80021c
  80028d:	e8 54 01 00 00       	call   8003e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800292:	83 c4 08             	add    $0x8,%esp
  800295:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a1:	50                   	push   %eax
  8002a2:	e8 d4 08 00 00       	call   800b7b <sys_cputs>

	return b.cnt;
}
  8002a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b8:	50                   	push   %eax
  8002b9:	ff 75 08             	pushl  0x8(%ebp)
  8002bc:	e8 9d ff ff ff       	call   80025e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	57                   	push   %edi
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 1c             	sub    $0x1c,%esp
  8002cc:	89 c7                	mov    %eax,%edi
  8002ce:	89 d6                	mov    %edx,%esi
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ea:	39 d3                	cmp    %edx,%ebx
  8002ec:	72 05                	jb     8002f3 <printnum+0x30>
  8002ee:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f1:	77 45                	ja     800338 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	ff 75 18             	pushl  0x18(%ebp)
  8002f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ff:	53                   	push   %ebx
  800300:	ff 75 10             	pushl  0x10(%ebp)
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 69 1d 00 00       	call   802080 <__udivdi3>
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	52                   	push   %edx
  80031b:	50                   	push   %eax
  80031c:	89 f2                	mov    %esi,%edx
  80031e:	89 f8                	mov    %edi,%eax
  800320:	e8 9e ff ff ff       	call   8002c3 <printnum>
  800325:	83 c4 20             	add    $0x20,%esp
  800328:	eb 18                	jmp    800342 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	56                   	push   %esi
  80032e:	ff 75 18             	pushl  0x18(%ebp)
  800331:	ff d7                	call   *%edi
  800333:	83 c4 10             	add    $0x10,%esp
  800336:	eb 03                	jmp    80033b <printnum+0x78>
  800338:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033b:	83 eb 01             	sub    $0x1,%ebx
  80033e:	85 db                	test   %ebx,%ebx
  800340:	7f e8                	jg     80032a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800342:	83 ec 08             	sub    $0x8,%esp
  800345:	56                   	push   %esi
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034c:	ff 75 e0             	pushl  -0x20(%ebp)
  80034f:	ff 75 dc             	pushl  -0x24(%ebp)
  800352:	ff 75 d8             	pushl  -0x28(%ebp)
  800355:	e8 56 1e 00 00       	call   8021b0 <__umoddi3>
  80035a:	83 c4 14             	add    $0x14,%esp
  80035d:	0f be 80 cc 23 80 00 	movsbl 0x8023cc(%eax),%eax
  800364:	50                   	push   %eax
  800365:	ff d7                	call   *%edi
}
  800367:	83 c4 10             	add    $0x10,%esp
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800375:	83 fa 01             	cmp    $0x1,%edx
  800378:	7e 0e                	jle    800388 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037a:	8b 10                	mov    (%eax),%edx
  80037c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037f:	89 08                	mov    %ecx,(%eax)
  800381:	8b 02                	mov    (%edx),%eax
  800383:	8b 52 04             	mov    0x4(%edx),%edx
  800386:	eb 22                	jmp    8003aa <getuint+0x38>
	else if (lflag)
  800388:	85 d2                	test   %edx,%edx
  80038a:	74 10                	je     80039c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800391:	89 08                	mov    %ecx,(%eax)
  800393:	8b 02                	mov    (%edx),%eax
  800395:	ba 00 00 00 00       	mov    $0x0,%edx
  80039a:	eb 0e                	jmp    8003aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039c:	8b 10                	mov    (%eax),%edx
  80039e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a1:	89 08                	mov    %ecx,(%eax)
  8003a3:	8b 02                	mov    (%edx),%eax
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b6:	8b 10                	mov    (%eax),%edx
  8003b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bb:	73 0a                	jae    8003c7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c0:	89 08                	mov    %ecx,(%eax)
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	88 02                	mov    %al,(%edx)
}
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d2:	50                   	push   %eax
  8003d3:	ff 75 10             	pushl  0x10(%ebp)
  8003d6:	ff 75 0c             	pushl  0xc(%ebp)
  8003d9:	ff 75 08             	pushl  0x8(%ebp)
  8003dc:	e8 05 00 00 00       	call   8003e6 <vprintfmt>
	va_end(ap);
}
  8003e1:	83 c4 10             	add    $0x10,%esp
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	57                   	push   %edi
  8003ea:	56                   	push   %esi
  8003eb:	53                   	push   %ebx
  8003ec:	83 ec 2c             	sub    $0x2c,%esp
  8003ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f8:	eb 12                	jmp    80040c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	0f 84 89 03 00 00    	je     80078b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	53                   	push   %ebx
  800406:	50                   	push   %eax
  800407:	ff d6                	call   *%esi
  800409:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040c:	83 c7 01             	add    $0x1,%edi
  80040f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800413:	83 f8 25             	cmp    $0x25,%eax
  800416:	75 e2                	jne    8003fa <vprintfmt+0x14>
  800418:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800423:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 07                	jmp    80043f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8d 47 01             	lea    0x1(%edi),%eax
  800442:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800445:	0f b6 07             	movzbl (%edi),%eax
  800448:	0f b6 c8             	movzbl %al,%ecx
  80044b:	83 e8 23             	sub    $0x23,%eax
  80044e:	3c 55                	cmp    $0x55,%al
  800450:	0f 87 1a 03 00 00    	ja     800770 <vprintfmt+0x38a>
  800456:	0f b6 c0             	movzbl %al,%eax
  800459:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800463:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800467:	eb d6                	jmp    80043f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800474:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800477:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80047e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800481:	83 fa 09             	cmp    $0x9,%edx
  800484:	77 39                	ja     8004bf <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800486:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800489:	eb e9                	jmp    800474 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 48 04             	lea    0x4(%eax),%ecx
  800491:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800494:	8b 00                	mov    (%eax),%eax
  800496:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049c:	eb 27                	jmp    8004c5 <vprintfmt+0xdf>
  80049e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a1:	85 c0                	test   %eax,%eax
  8004a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a8:	0f 49 c8             	cmovns %eax,%ecx
  8004ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b1:	eb 8c                	jmp    80043f <vprintfmt+0x59>
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bd:	eb 80                	jmp    80043f <vprintfmt+0x59>
  8004bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	0f 89 70 ff ff ff    	jns    80043f <vprintfmt+0x59>
				width = precision, precision = -1;
  8004cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004dc:	e9 5e ff ff ff       	jmp    80043f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e7:	e9 53 ff ff ff       	jmp    80043f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	53                   	push   %ebx
  8004f9:	ff 30                	pushl  (%eax)
  8004fb:	ff d6                	call   *%esi
			break;
  8004fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800503:	e9 04 ff ff ff       	jmp    80040c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	99                   	cltd   
  800514:	31 d0                	xor    %edx,%eax
  800516:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800518:	83 f8 0f             	cmp    $0xf,%eax
  80051b:	7f 0b                	jg     800528 <vprintfmt+0x142>
  80051d:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  800524:	85 d2                	test   %edx,%edx
  800526:	75 18                	jne    800540 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800528:	50                   	push   %eax
  800529:	68 e4 23 80 00       	push   $0x8023e4
  80052e:	53                   	push   %ebx
  80052f:	56                   	push   %esi
  800530:	e8 94 fe ff ff       	call   8003c9 <printfmt>
  800535:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053b:	e9 cc fe ff ff       	jmp    80040c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800540:	52                   	push   %edx
  800541:	68 25 28 80 00       	push   $0x802825
  800546:	53                   	push   %ebx
  800547:	56                   	push   %esi
  800548:	e8 7c fe ff ff       	call   8003c9 <printfmt>
  80054d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800553:	e9 b4 fe ff ff       	jmp    80040c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800563:	85 ff                	test   %edi,%edi
  800565:	b8 dd 23 80 00       	mov    $0x8023dd,%eax
  80056a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800571:	0f 8e 94 00 00 00    	jle    80060b <vprintfmt+0x225>
  800577:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057b:	0f 84 98 00 00 00    	je     800619 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	ff 75 d0             	pushl  -0x30(%ebp)
  800587:	57                   	push   %edi
  800588:	e8 86 02 00 00       	call   800813 <strnlen>
  80058d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800590:	29 c1                	sub    %eax,%ecx
  800592:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800595:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800598:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a4:	eb 0f                	jmp    8005b5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ad:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	83 ef 01             	sub    $0x1,%edi
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	85 ff                	test   %edi,%edi
  8005b7:	7f ed                	jg     8005a6 <vprintfmt+0x1c0>
  8005b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c6:	0f 49 c1             	cmovns %ecx,%eax
  8005c9:	29 c1                	sub    %eax,%ecx
  8005cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d4:	89 cb                	mov    %ecx,%ebx
  8005d6:	eb 4d                	jmp    800625 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005dc:	74 1b                	je     8005f9 <vprintfmt+0x213>
  8005de:	0f be c0             	movsbl %al,%eax
  8005e1:	83 e8 20             	sub    $0x20,%eax
  8005e4:	83 f8 5e             	cmp    $0x5e,%eax
  8005e7:	76 10                	jbe    8005f9 <vprintfmt+0x213>
					putch('?', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	ff 75 0c             	pushl  0xc(%ebp)
  8005ef:	6a 3f                	push   $0x3f
  8005f1:	ff 55 08             	call   *0x8(%ebp)
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	eb 0d                	jmp    800606 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	ff 75 0c             	pushl  0xc(%ebp)
  8005ff:	52                   	push   %edx
  800600:	ff 55 08             	call   *0x8(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	83 eb 01             	sub    $0x1,%ebx
  800609:	eb 1a                	jmp    800625 <vprintfmt+0x23f>
  80060b:	89 75 08             	mov    %esi,0x8(%ebp)
  80060e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800611:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800614:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800617:	eb 0c                	jmp    800625 <vprintfmt+0x23f>
  800619:	89 75 08             	mov    %esi,0x8(%ebp)
  80061c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800622:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800625:	83 c7 01             	add    $0x1,%edi
  800628:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062c:	0f be d0             	movsbl %al,%edx
  80062f:	85 d2                	test   %edx,%edx
  800631:	74 23                	je     800656 <vprintfmt+0x270>
  800633:	85 f6                	test   %esi,%esi
  800635:	78 a1                	js     8005d8 <vprintfmt+0x1f2>
  800637:	83 ee 01             	sub    $0x1,%esi
  80063a:	79 9c                	jns    8005d8 <vprintfmt+0x1f2>
  80063c:	89 df                	mov    %ebx,%edi
  80063e:	8b 75 08             	mov    0x8(%ebp),%esi
  800641:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800644:	eb 18                	jmp    80065e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 20                	push   $0x20
  80064c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064e:	83 ef 01             	sub    $0x1,%edi
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	eb 08                	jmp    80065e <vprintfmt+0x278>
  800656:	89 df                	mov    %ebx,%edi
  800658:	8b 75 08             	mov    0x8(%ebp),%esi
  80065b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80065e:	85 ff                	test   %edi,%edi
  800660:	7f e4                	jg     800646 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800665:	e9 a2 fd ff ff       	jmp    80040c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066a:	83 fa 01             	cmp    $0x1,%edx
  80066d:	7e 16                	jle    800685 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 08             	lea    0x8(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 50 04             	mov    0x4(%eax),%edx
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800680:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800683:	eb 32                	jmp    8006b7 <vprintfmt+0x2d1>
	else if (lflag)
  800685:	85 d2                	test   %edx,%edx
  800687:	74 18                	je     8006a1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)
  800692:	8b 00                	mov    (%eax),%eax
  800694:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800697:	89 c1                	mov    %eax,%ecx
  800699:	c1 f9 1f             	sar    $0x1f,%ecx
  80069c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80069f:	eb 16                	jmp    8006b7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006af:	89 c1                	mov    %eax,%ecx
  8006b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c6:	79 74                	jns    80073c <vprintfmt+0x356>
				putch('-', putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	53                   	push   %ebx
  8006cc:	6a 2d                	push   $0x2d
  8006ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d6:	f7 d8                	neg    %eax
  8006d8:	83 d2 00             	adc    $0x0,%edx
  8006db:	f7 da                	neg    %edx
  8006dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e5:	eb 55                	jmp    80073c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 83 fc ff ff       	call   800372 <getuint>
			base = 10;
  8006ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f4:	eb 46                	jmp    80073c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 74 fc ff ff       	call   800372 <getuint>
			base = 8;
  8006fe:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800703:	eb 37                	jmp    80073c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 30                	push   $0x30
  80070b:	ff d6                	call   *%esi
			putch('x', putdat);
  80070d:	83 c4 08             	add    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 78                	push   $0x78
  800713:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800725:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800728:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072d:	eb 0d                	jmp    80073c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072f:	8d 45 14             	lea    0x14(%ebp),%eax
  800732:	e8 3b fc ff ff       	call   800372 <getuint>
			base = 16;
  800737:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	83 ec 0c             	sub    $0xc,%esp
  80073f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800743:	57                   	push   %edi
  800744:	ff 75 e0             	pushl  -0x20(%ebp)
  800747:	51                   	push   %ecx
  800748:	52                   	push   %edx
  800749:	50                   	push   %eax
  80074a:	89 da                	mov    %ebx,%edx
  80074c:	89 f0                	mov    %esi,%eax
  80074e:	e8 70 fb ff ff       	call   8002c3 <printnum>
			break;
  800753:	83 c4 20             	add    $0x20,%esp
  800756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800759:	e9 ae fc ff ff       	jmp    80040c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	51                   	push   %ecx
  800763:	ff d6                	call   *%esi
			break;
  800765:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800768:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076b:	e9 9c fc ff ff       	jmp    80040c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	53                   	push   %ebx
  800774:	6a 25                	push   $0x25
  800776:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 03                	jmp    800780 <vprintfmt+0x39a>
  80077d:	83 ef 01             	sub    $0x1,%edi
  800780:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800784:	75 f7                	jne    80077d <vprintfmt+0x397>
  800786:	e9 81 fc ff ff       	jmp    80040c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	83 ec 18             	sub    $0x18,%esp
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b0:	85 c0                	test   %eax,%eax
  8007b2:	74 26                	je     8007da <vsnprintf+0x47>
  8007b4:	85 d2                	test   %edx,%edx
  8007b6:	7e 22                	jle    8007da <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b8:	ff 75 14             	pushl  0x14(%ebp)
  8007bb:	ff 75 10             	pushl  0x10(%ebp)
  8007be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	68 ac 03 80 00       	push   $0x8003ac
  8007c7:	e8 1a fc ff ff       	call   8003e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	eb 05                	jmp    8007df <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ea:	50                   	push   %eax
  8007eb:	ff 75 10             	pushl  0x10(%ebp)
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	ff 75 08             	pushl  0x8(%ebp)
  8007f4:	e8 9a ff ff ff       	call   800793 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
  800806:	eb 03                	jmp    80080b <strlen+0x10>
		n++;
  800808:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080f:	75 f7                	jne    800808 <strlen+0xd>
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	ba 00 00 00 00       	mov    $0x0,%edx
  800821:	eb 03                	jmp    800826 <strnlen+0x13>
		n++;
  800823:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	39 c2                	cmp    %eax,%edx
  800828:	74 08                	je     800832 <strnlen+0x1f>
  80082a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80082e:	75 f3                	jne    800823 <strnlen+0x10>
  800830:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083e:	89 c2                	mov    %eax,%edx
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084d:	84 db                	test   %bl,%bl
  80084f:	75 ef                	jne    800840 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800851:	5b                   	pop    %ebx
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	53                   	push   %ebx
  800858:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085b:	53                   	push   %ebx
  80085c:	e8 9a ff ff ff       	call   8007fb <strlen>
  800861:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	01 d8                	add    %ebx,%eax
  800869:	50                   	push   %eax
  80086a:	e8 c5 ff ff ff       	call   800834 <strcpy>
	return dst;
}
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	89 f3                	mov    %esi,%ebx
  800883:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800886:	89 f2                	mov    %esi,%edx
  800888:	eb 0f                	jmp    800899 <strncpy+0x23>
		*dst++ = *src;
  80088a:	83 c2 01             	add    $0x1,%edx
  80088d:	0f b6 01             	movzbl (%ecx),%eax
  800890:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800893:	80 39 01             	cmpb   $0x1,(%ecx)
  800896:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800899:	39 da                	cmp    %ebx,%edx
  80089b:	75 ed                	jne    80088a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 d2                	test   %edx,%edx
  8008b5:	74 21                	je     8008d8 <strlcpy+0x35>
  8008b7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bb:	89 f2                	mov    %esi,%edx
  8008bd:	eb 09                	jmp    8008c8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bf:	83 c2 01             	add    $0x1,%edx
  8008c2:	83 c1 01             	add    $0x1,%ecx
  8008c5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c8:	39 c2                	cmp    %eax,%edx
  8008ca:	74 09                	je     8008d5 <strlcpy+0x32>
  8008cc:	0f b6 19             	movzbl (%ecx),%ebx
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	75 ec                	jne    8008bf <strlcpy+0x1c>
  8008d3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d8:	29 f0                	sub    %esi,%eax
}
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e7:	eb 06                	jmp    8008ef <strcmp+0x11>
		p++, q++;
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ef:	0f b6 01             	movzbl (%ecx),%eax
  8008f2:	84 c0                	test   %al,%al
  8008f4:	74 04                	je     8008fa <strcmp+0x1c>
  8008f6:	3a 02                	cmp    (%edx),%al
  8008f8:	74 ef                	je     8008e9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fa:	0f b6 c0             	movzbl %al,%eax
  8008fd:	0f b6 12             	movzbl (%edx),%edx
  800900:	29 d0                	sub    %edx,%eax
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 c3                	mov    %eax,%ebx
  800910:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800913:	eb 06                	jmp    80091b <strncmp+0x17>
		n--, p++, q++;
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091b:	39 d8                	cmp    %ebx,%eax
  80091d:	74 15                	je     800934 <strncmp+0x30>
  80091f:	0f b6 08             	movzbl (%eax),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	74 04                	je     80092a <strncmp+0x26>
  800926:	3a 0a                	cmp    (%edx),%cl
  800928:	74 eb                	je     800915 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092a:	0f b6 00             	movzbl (%eax),%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
  800932:	eb 05                	jmp    800939 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800939:	5b                   	pop    %ebx
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800946:	eb 07                	jmp    80094f <strchr+0x13>
		if (*s == c)
  800948:	38 ca                	cmp    %cl,%dl
  80094a:	74 0f                	je     80095b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	0f b6 10             	movzbl (%eax),%edx
  800952:	84 d2                	test   %dl,%dl
  800954:	75 f2                	jne    800948 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800967:	eb 03                	jmp    80096c <strfind+0xf>
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096f:	38 ca                	cmp    %cl,%dl
  800971:	74 04                	je     800977 <strfind+0x1a>
  800973:	84 d2                	test   %dl,%dl
  800975:	75 f2                	jne    800969 <strfind+0xc>
			break;
	return (char *) s;
}
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800985:	85 c9                	test   %ecx,%ecx
  800987:	74 36                	je     8009bf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 28                	jne    8009b9 <memset+0x40>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 23                	jne    8009b9 <memset+0x40>
		c &= 0xFF;
  800996:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099a:	89 d3                	mov    %edx,%ebx
  80099c:	c1 e3 08             	shl    $0x8,%ebx
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	c1 e6 18             	shl    $0x18,%esi
  8009a4:	89 d0                	mov    %edx,%eax
  8009a6:	c1 e0 10             	shl    $0x10,%eax
  8009a9:	09 f0                	or     %esi,%eax
  8009ab:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	09 d0                	or     %edx,%eax
  8009b1:	c1 e9 02             	shr    $0x2,%ecx
  8009b4:	fc                   	cld    
  8009b5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b7:	eb 06                	jmp    8009bf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bc:	fc                   	cld    
  8009bd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d4:	39 c6                	cmp    %eax,%esi
  8009d6:	73 35                	jae    800a0d <memmove+0x47>
  8009d8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009db:	39 d0                	cmp    %edx,%eax
  8009dd:	73 2e                	jae    800a0d <memmove+0x47>
		s += n;
		d += n;
  8009df:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e2:	89 d6                	mov    %edx,%esi
  8009e4:	09 fe                	or     %edi,%esi
  8009e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ec:	75 13                	jne    800a01 <memmove+0x3b>
  8009ee:	f6 c1 03             	test   $0x3,%cl
  8009f1:	75 0e                	jne    800a01 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f3:	83 ef 04             	sub    $0x4,%edi
  8009f6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f9:	c1 e9 02             	shr    $0x2,%ecx
  8009fc:	fd                   	std    
  8009fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ff:	eb 09                	jmp    800a0a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a01:	83 ef 01             	sub    $0x1,%edi
  800a04:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a07:	fd                   	std    
  800a08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0a:	fc                   	cld    
  800a0b:	eb 1d                	jmp    800a2a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0d:	89 f2                	mov    %esi,%edx
  800a0f:	09 c2                	or     %eax,%edx
  800a11:	f6 c2 03             	test   $0x3,%dl
  800a14:	75 0f                	jne    800a25 <memmove+0x5f>
  800a16:	f6 c1 03             	test   $0x3,%cl
  800a19:	75 0a                	jne    800a25 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1b:	c1 e9 02             	shr    $0x2,%ecx
  800a1e:	89 c7                	mov    %eax,%edi
  800a20:	fc                   	cld    
  800a21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a23:	eb 05                	jmp    800a2a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a25:	89 c7                	mov    %eax,%edi
  800a27:	fc                   	cld    
  800a28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a31:	ff 75 10             	pushl  0x10(%ebp)
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	ff 75 08             	pushl  0x8(%ebp)
  800a3a:	e8 87 ff ff ff       	call   8009c6 <memmove>
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c6                	mov    %eax,%esi
  800a4e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a51:	eb 1a                	jmp    800a6d <memcmp+0x2c>
		if (*s1 != *s2)
  800a53:	0f b6 08             	movzbl (%eax),%ecx
  800a56:	0f b6 1a             	movzbl (%edx),%ebx
  800a59:	38 d9                	cmp    %bl,%cl
  800a5b:	74 0a                	je     800a67 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5d:	0f b6 c1             	movzbl %cl,%eax
  800a60:	0f b6 db             	movzbl %bl,%ebx
  800a63:	29 d8                	sub    %ebx,%eax
  800a65:	eb 0f                	jmp    800a76 <memcmp+0x35>
		s1++, s2++;
  800a67:	83 c0 01             	add    $0x1,%eax
  800a6a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6d:	39 f0                	cmp    %esi,%eax
  800a6f:	75 e2                	jne    800a53 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a81:	89 c1                	mov    %eax,%ecx
  800a83:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a86:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8a:	eb 0a                	jmp    800a96 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8c:	0f b6 10             	movzbl (%eax),%edx
  800a8f:	39 da                	cmp    %ebx,%edx
  800a91:	74 07                	je     800a9a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	39 c8                	cmp    %ecx,%eax
  800a98:	72 f2                	jb     800a8c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa9:	eb 03                	jmp    800aae <strtol+0x11>
		s++;
  800aab:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	0f b6 01             	movzbl (%ecx),%eax
  800ab1:	3c 20                	cmp    $0x20,%al
  800ab3:	74 f6                	je     800aab <strtol+0xe>
  800ab5:	3c 09                	cmp    $0x9,%al
  800ab7:	74 f2                	je     800aab <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab9:	3c 2b                	cmp    $0x2b,%al
  800abb:	75 0a                	jne    800ac7 <strtol+0x2a>
		s++;
  800abd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	eb 11                	jmp    800ad8 <strtol+0x3b>
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acc:	3c 2d                	cmp    $0x2d,%al
  800ace:	75 08                	jne    800ad8 <strtol+0x3b>
		s++, neg = 1;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ade:	75 15                	jne    800af5 <strtol+0x58>
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	75 10                	jne    800af5 <strtol+0x58>
  800ae5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae9:	75 7c                	jne    800b67 <strtol+0xca>
		s += 2, base = 16;
  800aeb:	83 c1 02             	add    $0x2,%ecx
  800aee:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af3:	eb 16                	jmp    800b0b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af5:	85 db                	test   %ebx,%ebx
  800af7:	75 12                	jne    800b0b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afe:	80 39 30             	cmpb   $0x30,(%ecx)
  800b01:	75 08                	jne    800b0b <strtol+0x6e>
		s++, base = 8;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b13:	0f b6 11             	movzbl (%ecx),%edx
  800b16:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 09             	cmp    $0x9,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0x8b>
			dig = *s - '0';
  800b20:	0f be d2             	movsbl %dl,%edx
  800b23:	83 ea 30             	sub    $0x30,%edx
  800b26:	eb 22                	jmp    800b4a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b28:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2b:	89 f3                	mov    %esi,%ebx
  800b2d:	80 fb 19             	cmp    $0x19,%bl
  800b30:	77 08                	ja     800b3a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b32:	0f be d2             	movsbl %dl,%edx
  800b35:	83 ea 57             	sub    $0x57,%edx
  800b38:	eb 10                	jmp    800b4a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3d:	89 f3                	mov    %esi,%ebx
  800b3f:	80 fb 19             	cmp    $0x19,%bl
  800b42:	77 16                	ja     800b5a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b44:	0f be d2             	movsbl %dl,%edx
  800b47:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4d:	7d 0b                	jge    800b5a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b4f:	83 c1 01             	add    $0x1,%ecx
  800b52:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b56:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b58:	eb b9                	jmp    800b13 <strtol+0x76>

	if (endptr)
  800b5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5e:	74 0d                	je     800b6d <strtol+0xd0>
		*endptr = (char *) s;
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	89 0e                	mov    %ecx,(%esi)
  800b65:	eb 06                	jmp    800b6d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b67:	85 db                	test   %ebx,%ebx
  800b69:	74 98                	je     800b03 <strtol+0x66>
  800b6b:	eb 9e                	jmp    800b0b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6d:	89 c2                	mov    %eax,%edx
  800b6f:	f7 da                	neg    %edx
  800b71:	85 ff                	test   %edi,%edi
  800b73:	0f 45 c2             	cmovne %edx,%eax
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	89 c3                	mov    %eax,%ebx
  800b8e:	89 c7                	mov    %eax,%edi
  800b90:	89 c6                	mov    %eax,%esi
  800b92:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba9:	89 d1                	mov    %edx,%ecx
  800bab:	89 d3                	mov    %edx,%ebx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 cb                	mov    %ecx,%ebx
  800bd0:	89 cf                	mov    %ecx,%edi
  800bd2:	89 ce                	mov    %ecx,%esi
  800bd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	7e 17                	jle    800bf1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 03                	push   $0x3
  800be0:	68 bf 26 80 00       	push   $0x8026bf
  800be5:	6a 23                	push   $0x23
  800be7:	68 dc 26 80 00       	push   $0x8026dc
  800bec:	e8 7d 13 00 00       	call   801f6e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 02 00 00 00       	mov    $0x2,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_yield>:

void
sys_yield(void)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c23:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c28:	89 d1                	mov    %edx,%ecx
  800c2a:	89 d3                	mov    %edx,%ebx
  800c2c:	89 d7                	mov    %edx,%edi
  800c2e:	89 d6                	mov    %edx,%esi
  800c30:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	be 00 00 00 00       	mov    $0x0,%esi
  800c45:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c53:	89 f7                	mov    %esi,%edi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 04                	push   $0x4
  800c61:	68 bf 26 80 00       	push   $0x8026bf
  800c66:	6a 23                	push   $0x23
  800c68:	68 dc 26 80 00       	push   $0x8026dc
  800c6d:	e8 fc 12 00 00       	call   801f6e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	b8 05 00 00 00       	mov    $0x5,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c91:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c94:	8b 75 18             	mov    0x18(%ebp),%esi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 05                	push   $0x5
  800ca3:	68 bf 26 80 00       	push   $0x8026bf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 26 80 00       	push   $0x8026dc
  800caf:	e8 ba 12 00 00       	call   801f6e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 06                	push   $0x6
  800ce5:	68 bf 26 80 00       	push   $0x8026bf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 26 80 00       	push   $0x8026dc
  800cf1:	e8 78 12 00 00       	call   801f6e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 08                	push   $0x8
  800d27:	68 bf 26 80 00       	push   $0x8026bf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 26 80 00       	push   $0x8026dc
  800d33:	e8 36 12 00 00       	call   801f6e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 09                	push   $0x9
  800d69:	68 bf 26 80 00       	push   $0x8026bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 26 80 00       	push   $0x8026dc
  800d75:	e8 f4 11 00 00       	call   801f6e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 0a                	push   $0xa
  800dab:	68 bf 26 80 00       	push   $0x8026bf
  800db0:	6a 23                	push   $0x23
  800db2:	68 dc 26 80 00       	push   $0x8026dc
  800db7:	e8 b2 11 00 00       	call   801f6e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	be 00 00 00 00       	mov    $0x0,%esi
  800dcf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	89 cb                	mov    %ecx,%ebx
  800dff:	89 cf                	mov    %ecx,%edi
  800e01:	89 ce                	mov    %ecx,%esi
  800e03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7e 17                	jle    800e20 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	50                   	push   %eax
  800e0d:	6a 0d                	push   $0xd
  800e0f:	68 bf 26 80 00       	push   $0x8026bf
  800e14:	6a 23                	push   $0x23
  800e16:	68 dc 26 80 00       	push   $0x8026dc
  800e1b:	e8 4e 11 00 00       	call   801f6e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e33:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 cb                	mov    %ecx,%ebx
  800e3d:	89 cf                	mov    %ecx,%edi
  800e3f:	89 ce                	mov    %ecx,%esi
  800e41:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e53:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 cb                	mov    %ecx,%ebx
  800e5d:	89 cf                	mov    %ecx,%edi
  800e5f:	89 ce                	mov    %ecx,%esi
  800e61:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e72:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e78:	74 11                	je     800e8b <pgfault+0x23>
  800e7a:	89 d8                	mov    %ebx,%eax
  800e7c:	c1 e8 0c             	shr    $0xc,%eax
  800e7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e86:	f6 c4 08             	test   $0x8,%ah
  800e89:	75 14                	jne    800e9f <pgfault+0x37>
		panic("faulting access");
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	68 ea 26 80 00       	push   $0x8026ea
  800e93:	6a 1e                	push   $0x1e
  800e95:	68 fa 26 80 00       	push   $0x8026fa
  800e9a:	e8 cf 10 00 00       	call   801f6e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	6a 07                	push   $0x7
  800ea4:	68 00 f0 7f 00       	push   $0x7ff000
  800ea9:	6a 00                	push   $0x0
  800eab:	e8 87 fd ff ff       	call   800c37 <sys_page_alloc>
	if (r < 0) {
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	79 12                	jns    800ec9 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800eb7:	50                   	push   %eax
  800eb8:	68 05 27 80 00       	push   $0x802705
  800ebd:	6a 2c                	push   $0x2c
  800ebf:	68 fa 26 80 00       	push   $0x8026fa
  800ec4:	e8 a5 10 00 00       	call   801f6e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ec9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 00 10 00 00       	push   $0x1000
  800ed7:	53                   	push   %ebx
  800ed8:	68 00 f0 7f 00       	push   $0x7ff000
  800edd:	e8 4c fb ff ff       	call   800a2e <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ee2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ee9:	53                   	push   %ebx
  800eea:	6a 00                	push   $0x0
  800eec:	68 00 f0 7f 00       	push   $0x7ff000
  800ef1:	6a 00                	push   $0x0
  800ef3:	e8 82 fd ff ff       	call   800c7a <sys_page_map>
	if (r < 0) {
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	79 12                	jns    800f11 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800eff:	50                   	push   %eax
  800f00:	68 05 27 80 00       	push   $0x802705
  800f05:	6a 33                	push   $0x33
  800f07:	68 fa 26 80 00       	push   $0x8026fa
  800f0c:	e8 5d 10 00 00       	call   801f6e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 9c fd ff ff       	call   800cbc <sys_page_unmap>
	if (r < 0) {
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	79 12                	jns    800f39 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f27:	50                   	push   %eax
  800f28:	68 05 27 80 00       	push   $0x802705
  800f2d:	6a 37                	push   $0x37
  800f2f:	68 fa 26 80 00       	push   $0x8026fa
  800f34:	e8 35 10 00 00       	call   801f6e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f47:	68 68 0e 80 00       	push   $0x800e68
  800f4c:	e8 63 10 00 00       	call   801fb4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f51:	b8 07 00 00 00       	mov    $0x7,%eax
  800f56:	cd 30                	int    $0x30
  800f58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 17                	jns    800f79 <fork+0x3b>
		panic("fork fault %e");
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	68 1e 27 80 00       	push   $0x80271e
  800f6a:	68 84 00 00 00       	push   $0x84
  800f6f:	68 fa 26 80 00       	push   $0x8026fa
  800f74:	e8 f5 0f 00 00       	call   801f6e <_panic>
  800f79:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f7f:	75 24                	jne    800fa5 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f81:	e8 73 fc ff ff       	call   800bf9 <sys_getenvid>
  800f86:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f96:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa0:	e9 64 01 00 00       	jmp    801109 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	6a 07                	push   $0x7
  800faa:	68 00 f0 bf ee       	push   $0xeebff000
  800faf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb2:	e8 80 fc ff ff       	call   800c37 <sys_page_alloc>
  800fb7:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fba:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fbf:	89 d8                	mov    %ebx,%eax
  800fc1:	c1 e8 16             	shr    $0x16,%eax
  800fc4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcb:	a8 01                	test   $0x1,%al
  800fcd:	0f 84 fc 00 00 00    	je     8010cf <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fd3:	89 d8                	mov    %ebx,%eax
  800fd5:	c1 e8 0c             	shr    $0xc,%eax
  800fd8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fdf:	f6 c2 01             	test   $0x1,%dl
  800fe2:	0f 84 e7 00 00 00    	je     8010cf <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fe8:	89 c6                	mov    %eax,%esi
  800fea:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff4:	f6 c6 04             	test   $0x4,%dh
  800ff7:	74 39                	je     801032 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ff9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	25 07 0e 00 00       	and    $0xe07,%eax
  801008:	50                   	push   %eax
  801009:	56                   	push   %esi
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	e8 67 fc ff ff       	call   800c7a <sys_page_map>
		if (r < 0) {
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	0f 89 b1 00 00 00    	jns    8010cf <fork+0x191>
		    	panic("sys page map fault %e");
  80101e:	83 ec 04             	sub    $0x4,%esp
  801021:	68 2c 27 80 00       	push   $0x80272c
  801026:	6a 54                	push   $0x54
  801028:	68 fa 26 80 00       	push   $0x8026fa
  80102d:	e8 3c 0f 00 00       	call   801f6e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801032:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801039:	f6 c2 02             	test   $0x2,%dl
  80103c:	75 0c                	jne    80104a <fork+0x10c>
  80103e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801045:	f6 c4 08             	test   $0x8,%ah
  801048:	74 5b                	je     8010a5 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	68 05 08 00 00       	push   $0x805
  801052:	56                   	push   %esi
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	6a 00                	push   $0x0
  801057:	e8 1e fc ff ff       	call   800c7a <sys_page_map>
		if (r < 0) {
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 14                	jns    801077 <fork+0x139>
		    	panic("sys page map fault %e");
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 2c 27 80 00       	push   $0x80272c
  80106b:	6a 5b                	push   $0x5b
  80106d:	68 fa 26 80 00       	push   $0x8026fa
  801072:	e8 f7 0e 00 00       	call   801f6e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	68 05 08 00 00       	push   $0x805
  80107f:	56                   	push   %esi
  801080:	6a 00                	push   $0x0
  801082:	56                   	push   %esi
  801083:	6a 00                	push   $0x0
  801085:	e8 f0 fb ff ff       	call   800c7a <sys_page_map>
		if (r < 0) {
  80108a:	83 c4 20             	add    $0x20,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 3e                	jns    8010cf <fork+0x191>
		    	panic("sys page map fault %e");
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	68 2c 27 80 00       	push   $0x80272c
  801099:	6a 5f                	push   $0x5f
  80109b:	68 fa 26 80 00       	push   $0x8026fa
  8010a0:	e8 c9 0e 00 00       	call   801f6e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	6a 05                	push   $0x5
  8010aa:	56                   	push   %esi
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 c6 fb ff ff       	call   800c7a <sys_page_map>
		if (r < 0) {
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	79 14                	jns    8010cf <fork+0x191>
		    	panic("sys page map fault %e");
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	68 2c 27 80 00       	push   $0x80272c
  8010c3:	6a 64                	push   $0x64
  8010c5:	68 fa 26 80 00       	push   $0x8026fa
  8010ca:	e8 9f 0e 00 00       	call   801f6e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d5:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010db:	0f 85 de fe ff ff    	jne    800fbf <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e6:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	50                   	push   %eax
  8010f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f3:	57                   	push   %edi
  8010f4:	e8 89 fc ff ff       	call   800d82 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010f9:	83 c4 08             	add    $0x8,%esp
  8010fc:	6a 02                	push   $0x2
  8010fe:	57                   	push   %edi
  8010ff:	e8 fa fb ff ff       	call   800cfe <sys_env_set_status>
	
	return envid;
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110c:	5b                   	pop    %ebx
  80110d:	5e                   	pop    %esi
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sfork>:

envid_t
sfork(void)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801114:	b8 00 00 00 00       	mov    $0x0,%eax
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801123:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	53                   	push   %ebx
  80112d:	68 44 27 80 00       	push   $0x802744
  801132:	e8 78 f1 ff ff       	call   8002af <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801137:	c7 04 24 e2 01 80 00 	movl   $0x8001e2,(%esp)
  80113e:	e8 e5 fc ff ff       	call   800e28 <sys_thread_create>
  801143:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801145:	83 c4 08             	add    $0x8,%esp
  801148:	53                   	push   %ebx
  801149:	68 44 27 80 00       	push   $0x802744
  80114e:	e8 5c f1 ff ff       	call   8002af <cprintf>
	return id;
}
  801153:	89 f0                	mov    %esi,%eax
  801155:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	8b 75 08             	mov    0x8(%ebp),%esi
  801164:	8b 45 0c             	mov    0xc(%ebp),%eax
  801167:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80116a:	85 c0                	test   %eax,%eax
  80116c:	75 12                	jne    801180 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	68 00 00 c0 ee       	push   $0xeec00000
  801176:	e8 6c fc ff ff       	call   800de7 <sys_ipc_recv>
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	eb 0c                	jmp    80118c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	50                   	push   %eax
  801184:	e8 5e fc ff ff       	call   800de7 <sys_ipc_recv>
  801189:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80118c:	85 f6                	test   %esi,%esi
  80118e:	0f 95 c1             	setne  %cl
  801191:	85 db                	test   %ebx,%ebx
  801193:	0f 95 c2             	setne  %dl
  801196:	84 d1                	test   %dl,%cl
  801198:	74 09                	je     8011a3 <ipc_recv+0x47>
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	c1 ea 1f             	shr    $0x1f,%edx
  80119f:	84 d2                	test   %dl,%dl
  8011a1:	75 2d                	jne    8011d0 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8011a3:	85 f6                	test   %esi,%esi
  8011a5:	74 0d                	je     8011b4 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8011a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ac:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  8011b2:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8011b4:	85 db                	test   %ebx,%ebx
  8011b6:	74 0d                	je     8011c5 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8011b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bd:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  8011c3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ca:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  8011d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	57                   	push   %edi
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 0c             	sub    $0xc,%esp
  8011e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8011e9:	85 db                	test   %ebx,%ebx
  8011eb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011f0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011f3:	ff 75 14             	pushl  0x14(%ebp)
  8011f6:	53                   	push   %ebx
  8011f7:	56                   	push   %esi
  8011f8:	57                   	push   %edi
  8011f9:	e8 c6 fb ff ff       	call   800dc4 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 1f             	shr    $0x1f,%edx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	84 d2                	test   %dl,%dl
  801208:	74 17                	je     801221 <ipc_send+0x4a>
  80120a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80120d:	74 12                	je     801221 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80120f:	50                   	push   %eax
  801210:	68 67 27 80 00       	push   $0x802767
  801215:	6a 47                	push   $0x47
  801217:	68 75 27 80 00       	push   $0x802775
  80121c:	e8 4d 0d 00 00       	call   801f6e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801221:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801224:	75 07                	jne    80122d <ipc_send+0x56>
			sys_yield();
  801226:	e8 ed f9 ff ff       	call   800c18 <sys_yield>
  80122b:	eb c6                	jmp    8011f3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80122d:	85 c0                	test   %eax,%eax
  80122f:	75 c2                	jne    8011f3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5f                   	pop    %edi
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801244:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  80124a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801250:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801256:	39 ca                	cmp    %ecx,%edx
  801258:	75 10                	jne    80126a <ipc_find_env+0x31>
			return envs[i].env_id;
  80125a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801260:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801265:	8b 40 7c             	mov    0x7c(%eax),%eax
  801268:	eb 0f                	jmp    801279 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80126a:	83 c0 01             	add    $0x1,%eax
  80126d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801272:	75 d0                	jne    801244 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801274:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	05 00 00 00 30       	add    $0x30000000,%eax
  801286:	c1 e8 0c             	shr    $0xc,%eax
}
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	05 00 00 00 30       	add    $0x30000000,%eax
  801296:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	c1 ea 16             	shr    $0x16,%edx
  8012b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	74 11                	je     8012cf <fd_alloc+0x2d>
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	c1 ea 0c             	shr    $0xc,%edx
  8012c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ca:	f6 c2 01             	test   $0x1,%dl
  8012cd:	75 09                	jne    8012d8 <fd_alloc+0x36>
			*fd_store = fd;
  8012cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d6:	eb 17                	jmp    8012ef <fd_alloc+0x4d>
  8012d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e2:	75 c9                	jne    8012ad <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f7:	83 f8 1f             	cmp    $0x1f,%eax
  8012fa:	77 36                	ja     801332 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012fc:	c1 e0 0c             	shl    $0xc,%eax
  8012ff:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801304:	89 c2                	mov    %eax,%edx
  801306:	c1 ea 16             	shr    $0x16,%edx
  801309:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801310:	f6 c2 01             	test   $0x1,%dl
  801313:	74 24                	je     801339 <fd_lookup+0x48>
  801315:	89 c2                	mov    %eax,%edx
  801317:	c1 ea 0c             	shr    $0xc,%edx
  80131a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801321:	f6 c2 01             	test   $0x1,%dl
  801324:	74 1a                	je     801340 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801326:	8b 55 0c             	mov    0xc(%ebp),%edx
  801329:	89 02                	mov    %eax,(%edx)
	return 0;
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
  801330:	eb 13                	jmp    801345 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801337:	eb 0c                	jmp    801345 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb 05                	jmp    801345 <fd_lookup+0x54>
  801340:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801350:	ba fc 27 80 00       	mov    $0x8027fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801355:	eb 13                	jmp    80136a <dev_lookup+0x23>
  801357:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80135a:	39 08                	cmp    %ecx,(%eax)
  80135c:	75 0c                	jne    80136a <dev_lookup+0x23>
			*dev = devtab[i];
  80135e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801361:	89 01                	mov    %eax,(%ecx)
			return 0;
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	eb 2e                	jmp    801398 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80136a:	8b 02                	mov    (%edx),%eax
  80136c:	85 c0                	test   %eax,%eax
  80136e:	75 e7                	jne    801357 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801370:	a1 04 40 80 00       	mov    0x804004,%eax
  801375:	8b 40 7c             	mov    0x7c(%eax),%eax
  801378:	83 ec 04             	sub    $0x4,%esp
  80137b:	51                   	push   %ecx
  80137c:	50                   	push   %eax
  80137d:	68 80 27 80 00       	push   $0x802780
  801382:	e8 28 ef ff ff       	call   8002af <cprintf>
	*dev = 0;
  801387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	83 ec 10             	sub    $0x10,%esp
  8013a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8013a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ab:	50                   	push   %eax
  8013ac:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b2:	c1 e8 0c             	shr    $0xc,%eax
  8013b5:	50                   	push   %eax
  8013b6:	e8 36 ff ff ff       	call   8012f1 <fd_lookup>
  8013bb:	83 c4 08             	add    $0x8,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 05                	js     8013c7 <fd_close+0x2d>
	    || fd != fd2)
  8013c2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013c5:	74 0c                	je     8013d3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013c7:	84 db                	test   %bl,%bl
  8013c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ce:	0f 44 c2             	cmove  %edx,%eax
  8013d1:	eb 41                	jmp    801414 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	ff 36                	pushl  (%esi)
  8013dc:	e8 66 ff ff ff       	call   801347 <dev_lookup>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 1a                	js     801404 <fd_close+0x6a>
		if (dev->dev_close)
  8013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ed:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	74 0b                	je     801404 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	56                   	push   %esi
  8013fd:	ff d0                	call   *%eax
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	56                   	push   %esi
  801408:	6a 00                	push   $0x0
  80140a:	e8 ad f8 ff ff       	call   800cbc <sys_page_unmap>
	return r;
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	89 d8                	mov    %ebx,%eax
}
  801414:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801417:	5b                   	pop    %ebx
  801418:	5e                   	pop    %esi
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    

0080141b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801424:	50                   	push   %eax
  801425:	ff 75 08             	pushl  0x8(%ebp)
  801428:	e8 c4 fe ff ff       	call   8012f1 <fd_lookup>
  80142d:	83 c4 08             	add    $0x8,%esp
  801430:	85 c0                	test   %eax,%eax
  801432:	78 10                	js     801444 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	6a 01                	push   $0x1
  801439:	ff 75 f4             	pushl  -0xc(%ebp)
  80143c:	e8 59 ff ff ff       	call   80139a <fd_close>
  801441:	83 c4 10             	add    $0x10,%esp
}
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <close_all>:

void
close_all(void)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	53                   	push   %ebx
  80144a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801452:	83 ec 0c             	sub    $0xc,%esp
  801455:	53                   	push   %ebx
  801456:	e8 c0 ff ff ff       	call   80141b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80145b:	83 c3 01             	add    $0x1,%ebx
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	83 fb 20             	cmp    $0x20,%ebx
  801464:	75 ec                	jne    801452 <close_all+0xc>
		close(i);
}
  801466:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	57                   	push   %edi
  80146f:	56                   	push   %esi
  801470:	53                   	push   %ebx
  801471:	83 ec 2c             	sub    $0x2c,%esp
  801474:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801477:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 75 08             	pushl  0x8(%ebp)
  80147e:	e8 6e fe ff ff       	call   8012f1 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	0f 88 c1 00 00 00    	js     80154f <dup+0xe4>
		return r;
	close(newfdnum);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	56                   	push   %esi
  801492:	e8 84 ff ff ff       	call   80141b <close>

	newfd = INDEX2FD(newfdnum);
  801497:	89 f3                	mov    %esi,%ebx
  801499:	c1 e3 0c             	shl    $0xc,%ebx
  80149c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014a2:	83 c4 04             	add    $0x4,%esp
  8014a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a8:	e8 de fd ff ff       	call   80128b <fd2data>
  8014ad:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014af:	89 1c 24             	mov    %ebx,(%esp)
  8014b2:	e8 d4 fd ff ff       	call   80128b <fd2data>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014bd:	89 f8                	mov    %edi,%eax
  8014bf:	c1 e8 16             	shr    $0x16,%eax
  8014c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c9:	a8 01                	test   $0x1,%al
  8014cb:	74 37                	je     801504 <dup+0x99>
  8014cd:	89 f8                	mov    %edi,%eax
  8014cf:	c1 e8 0c             	shr    $0xc,%eax
  8014d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d9:	f6 c2 01             	test   $0x1,%dl
  8014dc:	74 26                	je     801504 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ed:	50                   	push   %eax
  8014ee:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f1:	6a 00                	push   $0x0
  8014f3:	57                   	push   %edi
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 7f f7 ff ff       	call   800c7a <sys_page_map>
  8014fb:	89 c7                	mov    %eax,%edi
  8014fd:	83 c4 20             	add    $0x20,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 2e                	js     801532 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801504:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801507:	89 d0                	mov    %edx,%eax
  801509:	c1 e8 0c             	shr    $0xc,%eax
  80150c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801513:	83 ec 0c             	sub    $0xc,%esp
  801516:	25 07 0e 00 00       	and    $0xe07,%eax
  80151b:	50                   	push   %eax
  80151c:	53                   	push   %ebx
  80151d:	6a 00                	push   $0x0
  80151f:	52                   	push   %edx
  801520:	6a 00                	push   $0x0
  801522:	e8 53 f7 ff ff       	call   800c7a <sys_page_map>
  801527:	89 c7                	mov    %eax,%edi
  801529:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80152c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80152e:	85 ff                	test   %edi,%edi
  801530:	79 1d                	jns    80154f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	53                   	push   %ebx
  801536:	6a 00                	push   $0x0
  801538:	e8 7f f7 ff ff       	call   800cbc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80153d:	83 c4 08             	add    $0x8,%esp
  801540:	ff 75 d4             	pushl  -0x2c(%ebp)
  801543:	6a 00                	push   $0x0
  801545:	e8 72 f7 ff ff       	call   800cbc <sys_page_unmap>
	return r;
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	89 f8                	mov    %edi,%eax
}
  80154f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	53                   	push   %ebx
  80155b:	83 ec 14             	sub    $0x14,%esp
  80155e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801561:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	53                   	push   %ebx
  801566:	e8 86 fd ff ff       	call   8012f1 <fd_lookup>
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	89 c2                	mov    %eax,%edx
  801570:	85 c0                	test   %eax,%eax
  801572:	78 6d                	js     8015e1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157e:	ff 30                	pushl  (%eax)
  801580:	e8 c2 fd ff ff       	call   801347 <dev_lookup>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 4c                	js     8015d8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80158c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80158f:	8b 42 08             	mov    0x8(%edx),%eax
  801592:	83 e0 03             	and    $0x3,%eax
  801595:	83 f8 01             	cmp    $0x1,%eax
  801598:	75 21                	jne    8015bb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80159a:	a1 04 40 80 00       	mov    0x804004,%eax
  80159f:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	50                   	push   %eax
  8015a7:	68 c1 27 80 00       	push   $0x8027c1
  8015ac:	e8 fe ec ff ff       	call   8002af <cprintf>
		return -E_INVAL;
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b9:	eb 26                	jmp    8015e1 <read+0x8a>
	}
	if (!dev->dev_read)
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	8b 40 08             	mov    0x8(%eax),%eax
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 17                	je     8015dc <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	ff 75 10             	pushl  0x10(%ebp)
  8015cb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ce:	52                   	push   %edx
  8015cf:	ff d0                	call   *%eax
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 09                	jmp    8015e1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	eb 05                	jmp    8015e1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015e1:	89 d0                	mov    %edx,%eax
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	eb 21                	jmp    80161f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	89 f0                	mov    %esi,%eax
  801603:	29 d8                	sub    %ebx,%eax
  801605:	50                   	push   %eax
  801606:	89 d8                	mov    %ebx,%eax
  801608:	03 45 0c             	add    0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	57                   	push   %edi
  80160d:	e8 45 ff ff ff       	call   801557 <read>
		if (m < 0)
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 10                	js     801629 <readn+0x41>
			return m;
		if (m == 0)
  801619:	85 c0                	test   %eax,%eax
  80161b:	74 0a                	je     801627 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161d:	01 c3                	add    %eax,%ebx
  80161f:	39 f3                	cmp    %esi,%ebx
  801621:	72 db                	jb     8015fe <readn+0x16>
  801623:	89 d8                	mov    %ebx,%eax
  801625:	eb 02                	jmp    801629 <readn+0x41>
  801627:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801629:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5f                   	pop    %edi
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    

00801631 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	53                   	push   %ebx
  801635:	83 ec 14             	sub    $0x14,%esp
  801638:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	53                   	push   %ebx
  801640:	e8 ac fc ff ff       	call   8012f1 <fd_lookup>
  801645:	83 c4 08             	add    $0x8,%esp
  801648:	89 c2                	mov    %eax,%edx
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 68                	js     8016b6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	ff 30                	pushl  (%eax)
  80165a:	e8 e8 fc ff ff       	call   801347 <dev_lookup>
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 47                	js     8016ad <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166d:	75 21                	jne    801690 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80166f:	a1 04 40 80 00       	mov    0x804004,%eax
  801674:	8b 40 7c             	mov    0x7c(%eax),%eax
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	53                   	push   %ebx
  80167b:	50                   	push   %eax
  80167c:	68 dd 27 80 00       	push   $0x8027dd
  801681:	e8 29 ec ff ff       	call   8002af <cprintf>
		return -E_INVAL;
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80168e:	eb 26                	jmp    8016b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801690:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801693:	8b 52 0c             	mov    0xc(%edx),%edx
  801696:	85 d2                	test   %edx,%edx
  801698:	74 17                	je     8016b1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	ff 75 10             	pushl  0x10(%ebp)
  8016a0:	ff 75 0c             	pushl  0xc(%ebp)
  8016a3:	50                   	push   %eax
  8016a4:	ff d2                	call   *%edx
  8016a6:	89 c2                	mov    %eax,%edx
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	eb 09                	jmp    8016b6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	eb 05                	jmp    8016b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016b6:	89 d0                	mov    %edx,%eax
  8016b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <seek>:

int
seek(int fdnum, off_t offset)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c6:	50                   	push   %eax
  8016c7:	ff 75 08             	pushl  0x8(%ebp)
  8016ca:	e8 22 fc ff ff       	call   8012f1 <fd_lookup>
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 0e                	js     8016e4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 14             	sub    $0x14,%esp
  8016ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	53                   	push   %ebx
  8016f5:	e8 f7 fb ff ff       	call   8012f1 <fd_lookup>
  8016fa:	83 c4 08             	add    $0x8,%esp
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 65                	js     801768 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	ff 30                	pushl  (%eax)
  80170f:	e8 33 fc ff ff       	call   801347 <dev_lookup>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 44                	js     80175f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801722:	75 21                	jne    801745 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801724:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801729:	8b 40 7c             	mov    0x7c(%eax),%eax
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	53                   	push   %ebx
  801730:	50                   	push   %eax
  801731:	68 a0 27 80 00       	push   $0x8027a0
  801736:	e8 74 eb ff ff       	call   8002af <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801743:	eb 23                	jmp    801768 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801745:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801748:	8b 52 18             	mov    0x18(%edx),%edx
  80174b:	85 d2                	test   %edx,%edx
  80174d:	74 14                	je     801763 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	50                   	push   %eax
  801756:	ff d2                	call   *%edx
  801758:	89 c2                	mov    %eax,%edx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 09                	jmp    801768 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	89 c2                	mov    %eax,%edx
  801761:	eb 05                	jmp    801768 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801763:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801768:	89 d0                	mov    %edx,%eax
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	53                   	push   %ebx
  801773:	83 ec 14             	sub    $0x14,%esp
  801776:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801779:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177c:	50                   	push   %eax
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 6c fb ff ff       	call   8012f1 <fd_lookup>
  801785:	83 c4 08             	add    $0x8,%esp
  801788:	89 c2                	mov    %eax,%edx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 58                	js     8017e6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801794:	50                   	push   %eax
  801795:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801798:	ff 30                	pushl  (%eax)
  80179a:	e8 a8 fb ff ff       	call   801347 <dev_lookup>
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 37                	js     8017dd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ad:	74 32                	je     8017e1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017af:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017b2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b9:	00 00 00 
	stat->st_isdir = 0;
  8017bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c3:	00 00 00 
	stat->st_dev = dev;
  8017c6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	53                   	push   %ebx
  8017d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d3:	ff 50 14             	call   *0x14(%eax)
  8017d6:	89 c2                	mov    %eax,%edx
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	eb 09                	jmp    8017e6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	eb 05                	jmp    8017e6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e6:	89 d0                	mov    %edx,%eax
  8017e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	6a 00                	push   $0x0
  8017f7:	ff 75 08             	pushl  0x8(%ebp)
  8017fa:	e8 e3 01 00 00       	call   8019e2 <open>
  8017ff:	89 c3                	mov    %eax,%ebx
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	85 c0                	test   %eax,%eax
  801806:	78 1b                	js     801823 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	ff 75 0c             	pushl  0xc(%ebp)
  80180e:	50                   	push   %eax
  80180f:	e8 5b ff ff ff       	call   80176f <fstat>
  801814:	89 c6                	mov    %eax,%esi
	close(fd);
  801816:	89 1c 24             	mov    %ebx,(%esp)
  801819:	e8 fd fb ff ff       	call   80141b <close>
	return r;
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	89 f0                	mov    %esi,%eax
}
  801823:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801826:	5b                   	pop    %ebx
  801827:	5e                   	pop    %esi
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	89 c6                	mov    %eax,%esi
  801831:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801833:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80183a:	75 12                	jne    80184e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80183c:	83 ec 0c             	sub    $0xc,%esp
  80183f:	6a 01                	push   $0x1
  801841:	e8 f3 f9 ff ff       	call   801239 <ipc_find_env>
  801846:	a3 00 40 80 00       	mov    %eax,0x804000
  80184b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80184e:	6a 07                	push   $0x7
  801850:	68 00 50 80 00       	push   $0x805000
  801855:	56                   	push   %esi
  801856:	ff 35 00 40 80 00    	pushl  0x804000
  80185c:	e8 76 f9 ff ff       	call   8011d7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801861:	83 c4 0c             	add    $0xc,%esp
  801864:	6a 00                	push   $0x0
  801866:	53                   	push   %ebx
  801867:	6a 00                	push   $0x0
  801869:	e8 ee f8 ff ff       	call   80115c <ipc_recv>
}
  80186e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 40 0c             	mov    0xc(%eax),%eax
  801881:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801886:	8b 45 0c             	mov    0xc(%ebp),%eax
  801889:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 02 00 00 00       	mov    $0x2,%eax
  801898:	e8 8d ff ff ff       	call   80182a <fsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ba:	e8 6b ff ff ff       	call   80182a <fsipc>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 04             	sub    $0x4,%esp
  8018c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018db:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e0:	e8 45 ff ff ff       	call   80182a <fsipc>
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 2c                	js     801915 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e9:	83 ec 08             	sub    $0x8,%esp
  8018ec:	68 00 50 80 00       	push   $0x805000
  8018f1:	53                   	push   %ebx
  8018f2:	e8 3d ef ff ff       	call   800834 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f7:	a1 80 50 80 00       	mov    0x805080,%eax
  8018fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801902:	a1 84 50 80 00       	mov    0x805084,%eax
  801907:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801915:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 0c             	sub    $0xc,%esp
  801920:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801923:	8b 55 08             	mov    0x8(%ebp),%edx
  801926:	8b 52 0c             	mov    0xc(%edx),%edx
  801929:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80192f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801934:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801939:	0f 47 c2             	cmova  %edx,%eax
  80193c:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801941:	50                   	push   %eax
  801942:	ff 75 0c             	pushl  0xc(%ebp)
  801945:	68 08 50 80 00       	push   $0x805008
  80194a:	e8 77 f0 ff ff       	call   8009c6 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 04 00 00 00       	mov    $0x4,%eax
  801959:	e8 cc fe ff ff       	call   80182a <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	8b 40 0c             	mov    0xc(%eax),%eax
  80196e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801973:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
  80197e:	b8 03 00 00 00       	mov    $0x3,%eax
  801983:	e8 a2 fe ff ff       	call   80182a <fsipc>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 4b                	js     8019d9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80198e:	39 c6                	cmp    %eax,%esi
  801990:	73 16                	jae    8019a8 <devfile_read+0x48>
  801992:	68 0c 28 80 00       	push   $0x80280c
  801997:	68 13 28 80 00       	push   $0x802813
  80199c:	6a 7c                	push   $0x7c
  80199e:	68 28 28 80 00       	push   $0x802828
  8019a3:	e8 c6 05 00 00       	call   801f6e <_panic>
	assert(r <= PGSIZE);
  8019a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ad:	7e 16                	jle    8019c5 <devfile_read+0x65>
  8019af:	68 33 28 80 00       	push   $0x802833
  8019b4:	68 13 28 80 00       	push   $0x802813
  8019b9:	6a 7d                	push   $0x7d
  8019bb:	68 28 28 80 00       	push   $0x802828
  8019c0:	e8 a9 05 00 00       	call   801f6e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	50                   	push   %eax
  8019c9:	68 00 50 80 00       	push   $0x805000
  8019ce:	ff 75 0c             	pushl  0xc(%ebp)
  8019d1:	e8 f0 ef ff ff       	call   8009c6 <memmove>
	return r;
  8019d6:	83 c4 10             	add    $0x10,%esp
}
  8019d9:	89 d8                	mov    %ebx,%eax
  8019db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	53                   	push   %ebx
  8019e6:	83 ec 20             	sub    $0x20,%esp
  8019e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019ec:	53                   	push   %ebx
  8019ed:	e8 09 ee ff ff       	call   8007fb <strlen>
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019fa:	7f 67                	jg     801a63 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a02:	50                   	push   %eax
  801a03:	e8 9a f8 ff ff       	call   8012a2 <fd_alloc>
  801a08:	83 c4 10             	add    $0x10,%esp
		return r;
  801a0b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 57                	js     801a68 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	53                   	push   %ebx
  801a15:	68 00 50 80 00       	push   $0x805000
  801a1a:	e8 15 ee ff ff       	call   800834 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a22:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2f:	e8 f6 fd ff ff       	call   80182a <fsipc>
  801a34:	89 c3                	mov    %eax,%ebx
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	79 14                	jns    801a51 <open+0x6f>
		fd_close(fd, 0);
  801a3d:	83 ec 08             	sub    $0x8,%esp
  801a40:	6a 00                	push   $0x0
  801a42:	ff 75 f4             	pushl  -0xc(%ebp)
  801a45:	e8 50 f9 ff ff       	call   80139a <fd_close>
		return r;
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	89 da                	mov    %ebx,%edx
  801a4f:	eb 17                	jmp    801a68 <open+0x86>
	}

	return fd2num(fd);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	ff 75 f4             	pushl  -0xc(%ebp)
  801a57:	e8 1f f8 ff ff       	call   80127b <fd2num>
  801a5c:	89 c2                	mov    %eax,%edx
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	eb 05                	jmp    801a68 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a63:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a68:	89 d0                	mov    %edx,%eax
  801a6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a75:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7a:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7f:	e8 a6 fd ff ff       	call   80182a <fsipc>
}
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	ff 75 08             	pushl  0x8(%ebp)
  801a94:	e8 f2 f7 ff ff       	call   80128b <fd2data>
  801a99:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a9b:	83 c4 08             	add    $0x8,%esp
  801a9e:	68 3f 28 80 00       	push   $0x80283f
  801aa3:	53                   	push   %ebx
  801aa4:	e8 8b ed ff ff       	call   800834 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa9:	8b 46 04             	mov    0x4(%esi),%eax
  801aac:	2b 06                	sub    (%esi),%eax
  801aae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801abb:	00 00 00 
	stat->st_dev = &devpipe;
  801abe:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ac5:	30 80 00 
	return 0;
}
  801ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  801acd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad0:	5b                   	pop    %ebx
  801ad1:	5e                   	pop    %esi
  801ad2:	5d                   	pop    %ebp
  801ad3:	c3                   	ret    

00801ad4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ade:	53                   	push   %ebx
  801adf:	6a 00                	push   $0x0
  801ae1:	e8 d6 f1 ff ff       	call   800cbc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae6:	89 1c 24             	mov    %ebx,(%esp)
  801ae9:	e8 9d f7 ff ff       	call   80128b <fd2data>
  801aee:	83 c4 08             	add    $0x8,%esp
  801af1:	50                   	push   %eax
  801af2:	6a 00                	push   $0x0
  801af4:	e8 c3 f1 ff ff       	call   800cbc <sys_page_unmap>
}
  801af9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 1c             	sub    $0x1c,%esp
  801b07:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b0a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b11:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1d:	e8 21 05 00 00       	call   802043 <pageref>
  801b22:	89 c3                	mov    %eax,%ebx
  801b24:	89 3c 24             	mov    %edi,(%esp)
  801b27:	e8 17 05 00 00       	call   802043 <pageref>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	39 c3                	cmp    %eax,%ebx
  801b31:	0f 94 c1             	sete   %cl
  801b34:	0f b6 c9             	movzbl %cl,%ecx
  801b37:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b3a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b40:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801b46:	39 ce                	cmp    %ecx,%esi
  801b48:	74 1e                	je     801b68 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b4a:	39 c3                	cmp    %eax,%ebx
  801b4c:	75 be                	jne    801b0c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b4e:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801b54:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b57:	50                   	push   %eax
  801b58:	56                   	push   %esi
  801b59:	68 46 28 80 00       	push   $0x802846
  801b5e:	e8 4c e7 ff ff       	call   8002af <cprintf>
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	eb a4                	jmp    801b0c <_pipeisclosed+0xe>
	}
}
  801b68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6e:	5b                   	pop    %ebx
  801b6f:	5e                   	pop    %esi
  801b70:	5f                   	pop    %edi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	57                   	push   %edi
  801b77:	56                   	push   %esi
  801b78:	53                   	push   %ebx
  801b79:	83 ec 28             	sub    $0x28,%esp
  801b7c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b7f:	56                   	push   %esi
  801b80:	e8 06 f7 ff ff       	call   80128b <fd2data>
  801b85:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b8f:	eb 4b                	jmp    801bdc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b91:	89 da                	mov    %ebx,%edx
  801b93:	89 f0                	mov    %esi,%eax
  801b95:	e8 64 ff ff ff       	call   801afe <_pipeisclosed>
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	75 48                	jne    801be6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b9e:	e8 75 f0 ff ff       	call   800c18 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ba3:	8b 43 04             	mov    0x4(%ebx),%eax
  801ba6:	8b 0b                	mov    (%ebx),%ecx
  801ba8:	8d 51 20             	lea    0x20(%ecx),%edx
  801bab:	39 d0                	cmp    %edx,%eax
  801bad:	73 e2                	jae    801b91 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb9:	89 c2                	mov    %eax,%edx
  801bbb:	c1 fa 1f             	sar    $0x1f,%edx
  801bbe:	89 d1                	mov    %edx,%ecx
  801bc0:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc6:	83 e2 1f             	and    $0x1f,%edx
  801bc9:	29 ca                	sub    %ecx,%edx
  801bcb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bcf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd3:	83 c0 01             	add    $0x1,%eax
  801bd6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd9:	83 c7 01             	add    $0x1,%edi
  801bdc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bdf:	75 c2                	jne    801ba3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801be1:	8b 45 10             	mov    0x10(%ebp),%eax
  801be4:	eb 05                	jmp    801beb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	57                   	push   %edi
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 18             	sub    $0x18,%esp
  801bfc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bff:	57                   	push   %edi
  801c00:	e8 86 f6 ff ff       	call   80128b <fd2data>
  801c05:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c0f:	eb 3d                	jmp    801c4e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c11:	85 db                	test   %ebx,%ebx
  801c13:	74 04                	je     801c19 <devpipe_read+0x26>
				return i;
  801c15:	89 d8                	mov    %ebx,%eax
  801c17:	eb 44                	jmp    801c5d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c19:	89 f2                	mov    %esi,%edx
  801c1b:	89 f8                	mov    %edi,%eax
  801c1d:	e8 dc fe ff ff       	call   801afe <_pipeisclosed>
  801c22:	85 c0                	test   %eax,%eax
  801c24:	75 32                	jne    801c58 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c26:	e8 ed ef ff ff       	call   800c18 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c2b:	8b 06                	mov    (%esi),%eax
  801c2d:	3b 46 04             	cmp    0x4(%esi),%eax
  801c30:	74 df                	je     801c11 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c32:	99                   	cltd   
  801c33:	c1 ea 1b             	shr    $0x1b,%edx
  801c36:	01 d0                	add    %edx,%eax
  801c38:	83 e0 1f             	and    $0x1f,%eax
  801c3b:	29 d0                	sub    %edx,%eax
  801c3d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c45:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c48:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4b:	83 c3 01             	add    $0x1,%ebx
  801c4e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c51:	75 d8                	jne    801c2b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c53:	8b 45 10             	mov    0x10(%ebp),%eax
  801c56:	eb 05                	jmp    801c5d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c58:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	e8 2c f6 ff ff       	call   8012a2 <fd_alloc>
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	89 c2                	mov    %eax,%edx
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	0f 88 2c 01 00 00    	js     801daf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c83:	83 ec 04             	sub    $0x4,%esp
  801c86:	68 07 04 00 00       	push   $0x407
  801c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 a2 ef ff ff       	call   800c37 <sys_page_alloc>
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	89 c2                	mov    %eax,%edx
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	0f 88 0d 01 00 00    	js     801daf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca8:	50                   	push   %eax
  801ca9:	e8 f4 f5 ff ff       	call   8012a2 <fd_alloc>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 e2 00 00 00    	js     801d9d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	68 07 04 00 00       	push   $0x407
  801cc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 6a ef ff ff       	call   800c37 <sys_page_alloc>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 c3 00 00 00    	js     801d9d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce0:	e8 a6 f5 ff ff       	call   80128b <fd2data>
  801ce5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce7:	83 c4 0c             	add    $0xc,%esp
  801cea:	68 07 04 00 00       	push   $0x407
  801cef:	50                   	push   %eax
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 40 ef ff ff       	call   800c37 <sys_page_alloc>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	0f 88 89 00 00 00    	js     801d8d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0a:	e8 7c f5 ff ff       	call   80128b <fd2data>
  801d0f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d16:	50                   	push   %eax
  801d17:	6a 00                	push   $0x0
  801d19:	56                   	push   %esi
  801d1a:	6a 00                	push   $0x0
  801d1c:	e8 59 ef ff ff       	call   800c7a <sys_page_map>
  801d21:	89 c3                	mov    %eax,%ebx
  801d23:	83 c4 20             	add    $0x20,%esp
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 55                	js     801d7f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d2a:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d33:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d38:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d3f:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d48:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5a:	e8 1c f5 ff ff       	call   80127b <fd2num>
  801d5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d62:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d64:	83 c4 04             	add    $0x4,%esp
  801d67:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6a:	e8 0c f5 ff ff       	call   80127b <fd2num>
  801d6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d72:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7d:	eb 30                	jmp    801daf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d7f:	83 ec 08             	sub    $0x8,%esp
  801d82:	56                   	push   %esi
  801d83:	6a 00                	push   $0x0
  801d85:	e8 32 ef ff ff       	call   800cbc <sys_page_unmap>
  801d8a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d8d:	83 ec 08             	sub    $0x8,%esp
  801d90:	ff 75 f0             	pushl  -0x10(%ebp)
  801d93:	6a 00                	push   $0x0
  801d95:	e8 22 ef ff ff       	call   800cbc <sys_page_unmap>
  801d9a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d9d:	83 ec 08             	sub    $0x8,%esp
  801da0:	ff 75 f4             	pushl  -0xc(%ebp)
  801da3:	6a 00                	push   $0x0
  801da5:	e8 12 ef ff ff       	call   800cbc <sys_page_unmap>
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801daf:	89 d0                	mov    %edx,%eax
  801db1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc1:	50                   	push   %eax
  801dc2:	ff 75 08             	pushl  0x8(%ebp)
  801dc5:	e8 27 f5 ff ff       	call   8012f1 <fd_lookup>
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 18                	js     801de9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	e8 af f4 ff ff       	call   80128b <fd2data>
	return _pipeisclosed(fd, p);
  801ddc:	89 c2                	mov    %eax,%edx
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	e8 18 fd ff ff       	call   801afe <_pipeisclosed>
  801de6:	83 c4 10             	add    $0x10,%esp
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dee:	b8 00 00 00 00       	mov    $0x0,%eax
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dfb:	68 5e 28 80 00       	push   $0x80285e
  801e00:	ff 75 0c             	pushl  0xc(%ebp)
  801e03:	e8 2c ea ff ff       	call   800834 <strcpy>
	return 0;
}
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	57                   	push   %edi
  801e13:	56                   	push   %esi
  801e14:	53                   	push   %ebx
  801e15:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e1b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e20:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e26:	eb 2d                	jmp    801e55 <devcons_write+0x46>
		m = n - tot;
  801e28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e2b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e2d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e30:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e35:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e38:	83 ec 04             	sub    $0x4,%esp
  801e3b:	53                   	push   %ebx
  801e3c:	03 45 0c             	add    0xc(%ebp),%eax
  801e3f:	50                   	push   %eax
  801e40:	57                   	push   %edi
  801e41:	e8 80 eb ff ff       	call   8009c6 <memmove>
		sys_cputs(buf, m);
  801e46:	83 c4 08             	add    $0x8,%esp
  801e49:	53                   	push   %ebx
  801e4a:	57                   	push   %edi
  801e4b:	e8 2b ed ff ff       	call   800b7b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e50:	01 de                	add    %ebx,%esi
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5a:	72 cc                	jb     801e28 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5f:	5b                   	pop    %ebx
  801e60:	5e                   	pop    %esi
  801e61:	5f                   	pop    %edi
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    

00801e64 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	83 ec 08             	sub    $0x8,%esp
  801e6a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e73:	74 2a                	je     801e9f <devcons_read+0x3b>
  801e75:	eb 05                	jmp    801e7c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e77:	e8 9c ed ff ff       	call   800c18 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e7c:	e8 18 ed ff ff       	call   800b99 <sys_cgetc>
  801e81:	85 c0                	test   %eax,%eax
  801e83:	74 f2                	je     801e77 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 16                	js     801e9f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e89:	83 f8 04             	cmp    $0x4,%eax
  801e8c:	74 0c                	je     801e9a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e91:	88 02                	mov    %al,(%edx)
	return 1;
  801e93:	b8 01 00 00 00       	mov    $0x1,%eax
  801e98:	eb 05                	jmp    801e9f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e9a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ead:	6a 01                	push   $0x1
  801eaf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb2:	50                   	push   %eax
  801eb3:	e8 c3 ec ff ff       	call   800b7b <sys_cputs>
}
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	c9                   	leave  
  801ebc:	c3                   	ret    

00801ebd <getchar>:

int
getchar(void)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ec3:	6a 01                	push   $0x1
  801ec5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec8:	50                   	push   %eax
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 87 f6 ff ff       	call   801557 <read>
	if (r < 0)
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 0f                	js     801ee6 <getchar+0x29>
		return r;
	if (r < 1)
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	7e 06                	jle    801ee1 <getchar+0x24>
		return -E_EOF;
	return c;
  801edb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801edf:	eb 05                	jmp    801ee6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ee1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef1:	50                   	push   %eax
  801ef2:	ff 75 08             	pushl  0x8(%ebp)
  801ef5:	e8 f7 f3 ff ff       	call   8012f1 <fd_lookup>
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	85 c0                	test   %eax,%eax
  801eff:	78 11                	js     801f12 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f04:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f0a:	39 10                	cmp    %edx,(%eax)
  801f0c:	0f 94 c0             	sete   %al
  801f0f:	0f b6 c0             	movzbl %al,%eax
}
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <opencons>:

int
opencons(void)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1d:	50                   	push   %eax
  801f1e:	e8 7f f3 ff ff       	call   8012a2 <fd_alloc>
  801f23:	83 c4 10             	add    $0x10,%esp
		return r;
  801f26:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 3e                	js     801f6a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f2c:	83 ec 04             	sub    $0x4,%esp
  801f2f:	68 07 04 00 00       	push   $0x407
  801f34:	ff 75 f4             	pushl  -0xc(%ebp)
  801f37:	6a 00                	push   $0x0
  801f39:	e8 f9 ec ff ff       	call   800c37 <sys_page_alloc>
  801f3e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f41:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f43:	85 c0                	test   %eax,%eax
  801f45:	78 23                	js     801f6a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f47:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f50:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f55:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	50                   	push   %eax
  801f60:	e8 16 f3 ff ff       	call   80127b <fd2num>
  801f65:	89 c2                	mov    %eax,%edx
  801f67:	83 c4 10             	add    $0x10,%esp
}
  801f6a:	89 d0                	mov    %edx,%eax
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	56                   	push   %esi
  801f72:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f73:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f76:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f7c:	e8 78 ec ff ff       	call   800bf9 <sys_getenvid>
  801f81:	83 ec 0c             	sub    $0xc,%esp
  801f84:	ff 75 0c             	pushl  0xc(%ebp)
  801f87:	ff 75 08             	pushl  0x8(%ebp)
  801f8a:	56                   	push   %esi
  801f8b:	50                   	push   %eax
  801f8c:	68 6c 28 80 00       	push   $0x80286c
  801f91:	e8 19 e3 ff ff       	call   8002af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f96:	83 c4 18             	add    $0x18,%esp
  801f99:	53                   	push   %ebx
  801f9a:	ff 75 10             	pushl  0x10(%ebp)
  801f9d:	e8 bc e2 ff ff       	call   80025e <vcprintf>
	cprintf("\n");
  801fa2:	c7 04 24 57 28 80 00 	movl   $0x802857,(%esp)
  801fa9:	e8 01 e3 ff ff       	call   8002af <cprintf>
  801fae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fb1:	cc                   	int3   
  801fb2:	eb fd                	jmp    801fb1 <_panic+0x43>

00801fb4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fba:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fc1:	75 2a                	jne    801fed <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fc3:	83 ec 04             	sub    $0x4,%esp
  801fc6:	6a 07                	push   $0x7
  801fc8:	68 00 f0 bf ee       	push   $0xeebff000
  801fcd:	6a 00                	push   $0x0
  801fcf:	e8 63 ec ff ff       	call   800c37 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	79 12                	jns    801fed <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fdb:	50                   	push   %eax
  801fdc:	68 90 28 80 00       	push   $0x802890
  801fe1:	6a 23                	push   $0x23
  801fe3:	68 94 28 80 00       	push   $0x802894
  801fe8:	e8 81 ff ff ff       	call   801f6e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff0:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801ff5:	83 ec 08             	sub    $0x8,%esp
  801ff8:	68 1f 20 80 00       	push   $0x80201f
  801ffd:	6a 00                	push   $0x0
  801fff:	e8 7e ed ff ff       	call   800d82 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	79 12                	jns    80201d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80200b:	50                   	push   %eax
  80200c:	68 90 28 80 00       	push   $0x802890
  802011:	6a 2c                	push   $0x2c
  802013:	68 94 28 80 00       	push   $0x802894
  802018:	e8 51 ff ff ff       	call   801f6e <_panic>
	}
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80201f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802020:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802025:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802027:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80202a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80202e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802033:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802037:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802039:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80203c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80203d:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802040:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802041:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802042:	c3                   	ret    

00802043 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802049:	89 d0                	mov    %edx,%eax
  80204b:	c1 e8 16             	shr    $0x16,%eax
  80204e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802055:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205a:	f6 c1 01             	test   $0x1,%cl
  80205d:	74 1d                	je     80207c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80205f:	c1 ea 0c             	shr    $0xc,%edx
  802062:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802069:	f6 c2 01             	test   $0x1,%dl
  80206c:	74 0e                	je     80207c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206e:	c1 ea 0c             	shr    $0xc,%edx
  802071:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802078:	ef 
  802079:	0f b7 c0             	movzwl %ax,%eax
}
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
