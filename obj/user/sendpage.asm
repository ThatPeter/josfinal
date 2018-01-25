
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
  800039:	e8 01 0f 00 00       	call   800f3f <fork>
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
  800057:	e8 ff 10 00 00       	call   80115b <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 23 80 00       	push   $0x802300
  80006c:	e8 3f 02 00 00       	call   8002b0 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 7d 07 00 00       	call   8007fc <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 72 08 00 00       	call   800905 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 14 23 80 00       	push   $0x802314
  8000a2:	e8 09 02 00 00       	call   8002b0 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 44 07 00 00       	call   8007fc <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 60 09 00 00       	call   800a2f <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 f3 10 00 00       	call   8011d3 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 54             	mov    0x54(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 38 0b 00 00       	call   800c38 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 ee 06 00 00       	call   8007fc <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 0a 09 00 00       	call   800a2f <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 9d 10 00 00       	call   8011d3 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 12 10 00 00       	call   80115b <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 23 80 00       	push   $0x802300
  800159:	e8 52 01 00 00       	call   8002b0 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 90 06 00 00       	call   8007fc <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 85 07 00 00       	call   800905 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 34 23 80 00       	push   $0x802334
  80018f:	e8 1c 01 00 00       	call   8002b0 <cprintf>
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
  8001a4:	e8 51 0a 00 00       	call   800bfa <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	89 c2                	mov    %eax,%edx
  8001b0:	c1 e2 07             	shl    $0x7,%edx
  8001b3:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8001ba:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bf:	85 db                	test   %ebx,%ebx
  8001c1:	7e 07                	jle    8001ca <libmain+0x31>
		binaryname = argv[0];
  8001c3:	8b 06                	mov    (%esi),%eax
  8001c5:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001ca:	83 ec 08             	sub    $0x8,%esp
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	e8 5f fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d4:	e8 2a 00 00 00       	call   800203 <exit>
}
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8001e9:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8001ee:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8001f0:	e8 05 0a 00 00       	call   800bfa <sys_getenvid>
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	e8 4b 0c 00 00       	call   800e49 <sys_thread_free>
}
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800209:	e8 32 12 00 00       	call   801440 <close_all>
	sys_env_destroy(0);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	6a 00                	push   $0x0
  800213:	e8 a1 09 00 00       	call   800bb9 <sys_env_destroy>
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	53                   	push   %ebx
  800221:	83 ec 04             	sub    $0x4,%esp
  800224:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800227:	8b 13                	mov    (%ebx),%edx
  800229:	8d 42 01             	lea    0x1(%edx),%eax
  80022c:	89 03                	mov    %eax,(%ebx)
  80022e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800231:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800235:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023a:	75 1a                	jne    800256 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	68 ff 00 00 00       	push   $0xff
  800244:	8d 43 08             	lea    0x8(%ebx),%eax
  800247:	50                   	push   %eax
  800248:	e8 2f 09 00 00       	call   800b7c <sys_cputs>
		b->idx = 0;
  80024d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800253:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800256:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800268:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026f:	00 00 00 
	b.cnt = 0;
  800272:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800279:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	ff 75 08             	pushl  0x8(%ebp)
  800282:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800288:	50                   	push   %eax
  800289:	68 1d 02 80 00       	push   $0x80021d
  80028e:	e8 54 01 00 00       	call   8003e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800293:	83 c4 08             	add    $0x8,%esp
  800296:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a2:	50                   	push   %eax
  8002a3:	e8 d4 08 00 00       	call   800b7c <sys_cputs>

	return b.cnt;
}
  8002a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b9:	50                   	push   %eax
  8002ba:	ff 75 08             	pushl  0x8(%ebp)
  8002bd:	e8 9d ff ff ff       	call   80025f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 1c             	sub    $0x1c,%esp
  8002cd:	89 c7                	mov    %eax,%edi
  8002cf:	89 d6                	mov    %edx,%esi
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002da:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002eb:	39 d3                	cmp    %edx,%ebx
  8002ed:	72 05                	jb     8002f4 <printnum+0x30>
  8002ef:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f2:	77 45                	ja     800339 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	ff 75 18             	pushl  0x18(%ebp)
  8002fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800300:	53                   	push   %ebx
  800301:	ff 75 10             	pushl  0x10(%ebp)
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 58 1d 00 00       	call   802070 <__udivdi3>
  800318:	83 c4 18             	add    $0x18,%esp
  80031b:	52                   	push   %edx
  80031c:	50                   	push   %eax
  80031d:	89 f2                	mov    %esi,%edx
  80031f:	89 f8                	mov    %edi,%eax
  800321:	e8 9e ff ff ff       	call   8002c4 <printnum>
  800326:	83 c4 20             	add    $0x20,%esp
  800329:	eb 18                	jmp    800343 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032b:	83 ec 08             	sub    $0x8,%esp
  80032e:	56                   	push   %esi
  80032f:	ff 75 18             	pushl  0x18(%ebp)
  800332:	ff d7                	call   *%edi
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	eb 03                	jmp    80033c <printnum+0x78>
  800339:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033c:	83 eb 01             	sub    $0x1,%ebx
  80033f:	85 db                	test   %ebx,%ebx
  800341:	7f e8                	jg     80032b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	56                   	push   %esi
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034d:	ff 75 e0             	pushl  -0x20(%ebp)
  800350:	ff 75 dc             	pushl  -0x24(%ebp)
  800353:	ff 75 d8             	pushl  -0x28(%ebp)
  800356:	e8 45 1e 00 00       	call   8021a0 <__umoddi3>
  80035b:	83 c4 14             	add    $0x14,%esp
  80035e:	0f be 80 ac 23 80 00 	movsbl 0x8023ac(%eax),%eax
  800365:	50                   	push   %eax
  800366:	ff d7                	call   *%edi
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800376:	83 fa 01             	cmp    $0x1,%edx
  800379:	7e 0e                	jle    800389 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800380:	89 08                	mov    %ecx,(%eax)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	8b 52 04             	mov    0x4(%edx),%edx
  800387:	eb 22                	jmp    8003ab <getuint+0x38>
	else if (lflag)
  800389:	85 d2                	test   %edx,%edx
  80038b:	74 10                	je     80039d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 0e                	jmp    8003ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 0a                	jae    8003c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	88 02                	mov    %al,(%edx)
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d3:	50                   	push   %eax
  8003d4:	ff 75 10             	pushl  0x10(%ebp)
  8003d7:	ff 75 0c             	pushl  0xc(%ebp)
  8003da:	ff 75 08             	pushl  0x8(%ebp)
  8003dd:	e8 05 00 00 00       	call   8003e7 <vprintfmt>
	va_end(ap);
}
  8003e2:	83 c4 10             	add    $0x10,%esp
  8003e5:	c9                   	leave  
  8003e6:	c3                   	ret    

008003e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	57                   	push   %edi
  8003eb:	56                   	push   %esi
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 2c             	sub    $0x2c,%esp
  8003f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f9:	eb 12                	jmp    80040d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	0f 84 89 03 00 00    	je     80078c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800403:	83 ec 08             	sub    $0x8,%esp
  800406:	53                   	push   %ebx
  800407:	50                   	push   %eax
  800408:	ff d6                	call   *%esi
  80040a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040d:	83 c7 01             	add    $0x1,%edi
  800410:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800414:	83 f8 25             	cmp    $0x25,%eax
  800417:	75 e2                	jne    8003fb <vprintfmt+0x14>
  800419:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800424:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800432:	ba 00 00 00 00       	mov    $0x0,%edx
  800437:	eb 07                	jmp    800440 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8d 47 01             	lea    0x1(%edi),%eax
  800443:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800446:	0f b6 07             	movzbl (%edi),%eax
  800449:	0f b6 c8             	movzbl %al,%ecx
  80044c:	83 e8 23             	sub    $0x23,%eax
  80044f:	3c 55                	cmp    $0x55,%al
  800451:	0f 87 1a 03 00 00    	ja     800771 <vprintfmt+0x38a>
  800457:	0f b6 c0             	movzbl %al,%eax
  80045a:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800464:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800468:	eb d6                	jmp    800440 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800475:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800478:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80047f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800482:	83 fa 09             	cmp    $0x9,%edx
  800485:	77 39                	ja     8004c0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800487:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048a:	eb e9                	jmp    800475 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 48 04             	lea    0x4(%eax),%ecx
  800492:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800495:	8b 00                	mov    (%eax),%eax
  800497:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049d:	eb 27                	jmp    8004c6 <vprintfmt+0xdf>
  80049f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a9:	0f 49 c8             	cmovns %eax,%ecx
  8004ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b2:	eb 8c                	jmp    800440 <vprintfmt+0x59>
  8004b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004be:	eb 80                	jmp    800440 <vprintfmt+0x59>
  8004c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ca:	0f 89 70 ff ff ff    	jns    800440 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004dd:	e9 5e ff ff ff       	jmp    800440 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e8:	e9 53 ff ff ff       	jmp    800440 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	53                   	push   %ebx
  8004fa:	ff 30                	pushl  (%eax)
  8004fc:	ff d6                	call   *%esi
			break;
  8004fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800504:	e9 04 ff ff ff       	jmp    80040d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 00                	mov    (%eax),%eax
  800514:	99                   	cltd   
  800515:	31 d0                	xor    %edx,%eax
  800517:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800519:	83 f8 0f             	cmp    $0xf,%eax
  80051c:	7f 0b                	jg     800529 <vprintfmt+0x142>
  80051e:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  800525:	85 d2                	test   %edx,%edx
  800527:	75 18                	jne    800541 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800529:	50                   	push   %eax
  80052a:	68 c4 23 80 00       	push   $0x8023c4
  80052f:	53                   	push   %ebx
  800530:	56                   	push   %esi
  800531:	e8 94 fe ff ff       	call   8003ca <printfmt>
  800536:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053c:	e9 cc fe ff ff       	jmp    80040d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800541:	52                   	push   %edx
  800542:	68 05 28 80 00       	push   $0x802805
  800547:	53                   	push   %ebx
  800548:	56                   	push   %esi
  800549:	e8 7c fe ff ff       	call   8003ca <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800554:	e9 b4 fe ff ff       	jmp    80040d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800564:	85 ff                	test   %edi,%edi
  800566:	b8 bd 23 80 00       	mov    $0x8023bd,%eax
  80056b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800572:	0f 8e 94 00 00 00    	jle    80060c <vprintfmt+0x225>
  800578:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057c:	0f 84 98 00 00 00    	je     80061a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	ff 75 d0             	pushl  -0x30(%ebp)
  800588:	57                   	push   %edi
  800589:	e8 86 02 00 00       	call   800814 <strnlen>
  80058e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800591:	29 c1                	sub    %eax,%ecx
  800593:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800596:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800599:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	eb 0f                	jmp    8005b6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ae:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b0:	83 ef 01             	sub    $0x1,%edi
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	85 ff                	test   %edi,%edi
  8005b8:	7f ed                	jg     8005a7 <vprintfmt+0x1c0>
  8005ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c0:	85 c9                	test   %ecx,%ecx
  8005c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c7:	0f 49 c1             	cmovns %ecx,%eax
  8005ca:	29 c1                	sub    %eax,%ecx
  8005cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d5:	89 cb                	mov    %ecx,%ebx
  8005d7:	eb 4d                	jmp    800626 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005dd:	74 1b                	je     8005fa <vprintfmt+0x213>
  8005df:	0f be c0             	movsbl %al,%eax
  8005e2:	83 e8 20             	sub    $0x20,%eax
  8005e5:	83 f8 5e             	cmp    $0x5e,%eax
  8005e8:	76 10                	jbe    8005fa <vprintfmt+0x213>
					putch('?', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	ff 75 0c             	pushl  0xc(%ebp)
  8005f0:	6a 3f                	push   $0x3f
  8005f2:	ff 55 08             	call   *0x8(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	eb 0d                	jmp    800607 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	ff 75 0c             	pushl  0xc(%ebp)
  800600:	52                   	push   %edx
  800601:	ff 55 08             	call   *0x8(%ebp)
  800604:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800607:	83 eb 01             	sub    $0x1,%ebx
  80060a:	eb 1a                	jmp    800626 <vprintfmt+0x23f>
  80060c:	89 75 08             	mov    %esi,0x8(%ebp)
  80060f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800612:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800615:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800618:	eb 0c                	jmp    800626 <vprintfmt+0x23f>
  80061a:	89 75 08             	mov    %esi,0x8(%ebp)
  80061d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800620:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800623:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800626:	83 c7 01             	add    $0x1,%edi
  800629:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062d:	0f be d0             	movsbl %al,%edx
  800630:	85 d2                	test   %edx,%edx
  800632:	74 23                	je     800657 <vprintfmt+0x270>
  800634:	85 f6                	test   %esi,%esi
  800636:	78 a1                	js     8005d9 <vprintfmt+0x1f2>
  800638:	83 ee 01             	sub    $0x1,%esi
  80063b:	79 9c                	jns    8005d9 <vprintfmt+0x1f2>
  80063d:	89 df                	mov    %ebx,%edi
  80063f:	8b 75 08             	mov    0x8(%ebp),%esi
  800642:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800645:	eb 18                	jmp    80065f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 20                	push   $0x20
  80064d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064f:	83 ef 01             	sub    $0x1,%edi
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	eb 08                	jmp    80065f <vprintfmt+0x278>
  800657:	89 df                	mov    %ebx,%edi
  800659:	8b 75 08             	mov    0x8(%ebp),%esi
  80065c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80065f:	85 ff                	test   %edi,%edi
  800661:	7f e4                	jg     800647 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800666:	e9 a2 fd ff ff       	jmp    80040d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066b:	83 fa 01             	cmp    $0x1,%edx
  80066e:	7e 16                	jle    800686 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 08             	lea    0x8(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)
  800679:	8b 50 04             	mov    0x4(%eax),%edx
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800681:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800684:	eb 32                	jmp    8006b8 <vprintfmt+0x2d1>
	else if (lflag)
  800686:	85 d2                	test   %edx,%edx
  800688:	74 18                	je     8006a2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800698:	89 c1                	mov    %eax,%ecx
  80069a:	c1 f9 1f             	sar    $0x1f,%ecx
  80069d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a0:	eb 16                	jmp    8006b8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b0:	89 c1                	mov    %eax,%ecx
  8006b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c7:	79 74                	jns    80073d <vprintfmt+0x356>
				putch('-', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 2d                	push   $0x2d
  8006cf:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d7:	f7 d8                	neg    %eax
  8006d9:	83 d2 00             	adc    $0x0,%edx
  8006dc:	f7 da                	neg    %edx
  8006de:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e6:	eb 55                	jmp    80073d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006eb:	e8 83 fc ff ff       	call   800373 <getuint>
			base = 10;
  8006f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f5:	eb 46                	jmp    80073d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	e8 74 fc ff ff       	call   800373 <getuint>
			base = 8;
  8006ff:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800704:	eb 37                	jmp    80073d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	6a 30                	push   $0x30
  80070c:	ff d6                	call   *%esi
			putch('x', putdat);
  80070e:	83 c4 08             	add    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 78                	push   $0x78
  800714:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 50 04             	lea    0x4(%eax),%edx
  80071c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800726:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800729:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072e:	eb 0d                	jmp    80073d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
  800733:	e8 3b fc ff ff       	call   800373 <getuint>
			base = 16;
  800738:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073d:	83 ec 0c             	sub    $0xc,%esp
  800740:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800744:	57                   	push   %edi
  800745:	ff 75 e0             	pushl  -0x20(%ebp)
  800748:	51                   	push   %ecx
  800749:	52                   	push   %edx
  80074a:	50                   	push   %eax
  80074b:	89 da                	mov    %ebx,%edx
  80074d:	89 f0                	mov    %esi,%eax
  80074f:	e8 70 fb ff ff       	call   8002c4 <printnum>
			break;
  800754:	83 c4 20             	add    $0x20,%esp
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	e9 ae fc ff ff       	jmp    80040d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	51                   	push   %ecx
  800764:	ff d6                	call   *%esi
			break;
  800766:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800769:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076c:	e9 9c fc ff ff       	jmp    80040d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 25                	push   $0x25
  800777:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 03                	jmp    800781 <vprintfmt+0x39a>
  80077e:	83 ef 01             	sub    $0x1,%edi
  800781:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800785:	75 f7                	jne    80077e <vprintfmt+0x397>
  800787:	e9 81 fc ff ff       	jmp    80040d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5f                   	pop    %edi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	83 ec 18             	sub    $0x18,%esp
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	74 26                	je     8007db <vsnprintf+0x47>
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	7e 22                	jle    8007db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b9:	ff 75 14             	pushl  0x14(%ebp)
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	68 ad 03 80 00       	push   $0x8003ad
  8007c8:	e8 1a fc ff ff       	call   8003e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 05                	jmp    8007e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007eb:	50                   	push   %eax
  8007ec:	ff 75 10             	pushl  0x10(%ebp)
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	ff 75 08             	pushl  0x8(%ebp)
  8007f5:	e8 9a ff ff ff       	call   800794 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 03                	jmp    80080c <strlen+0x10>
		n++;
  800809:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800810:	75 f7                	jne    800809 <strlen+0xd>
		n++;
	return n;
}
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	eb 03                	jmp    800827 <strnlen+0x13>
		n++;
  800824:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	39 c2                	cmp    %eax,%edx
  800829:	74 08                	je     800833 <strnlen+0x1f>
  80082b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80082f:	75 f3                	jne    800824 <strnlen+0x10>
  800831:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	53                   	push   %ebx
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083f:	89 c2                	mov    %eax,%edx
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084e:	84 db                	test   %bl,%bl
  800850:	75 ef                	jne    800841 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085c:	53                   	push   %ebx
  80085d:	e8 9a ff ff ff       	call   8007fc <strlen>
  800862:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	01 d8                	add    %ebx,%eax
  80086a:	50                   	push   %eax
  80086b:	e8 c5 ff ff ff       	call   800835 <strcpy>
	return dst;
}
  800870:	89 d8                	mov    %ebx,%eax
  800872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	89 f3                	mov    %esi,%ebx
  800884:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800887:	89 f2                	mov    %esi,%edx
  800889:	eb 0f                	jmp    80089a <strncpy+0x23>
		*dst++ = *src;
  80088b:	83 c2 01             	add    $0x1,%edx
  80088e:	0f b6 01             	movzbl (%ecx),%eax
  800891:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800894:	80 39 01             	cmpb   $0x1,(%ecx)
  800897:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089a:	39 da                	cmp    %ebx,%edx
  80089c:	75 ed                	jne    80088b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008af:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b4:	85 d2                	test   %edx,%edx
  8008b6:	74 21                	je     8008d9 <strlcpy+0x35>
  8008b8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bc:	89 f2                	mov    %esi,%edx
  8008be:	eb 09                	jmp    8008c9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	83 c1 01             	add    $0x1,%ecx
  8008c6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c9:	39 c2                	cmp    %eax,%edx
  8008cb:	74 09                	je     8008d6 <strlcpy+0x32>
  8008cd:	0f b6 19             	movzbl (%ecx),%ebx
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	75 ec                	jne    8008c0 <strlcpy+0x1c>
  8008d4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d9:	29 f0                	sub    %esi,%eax
}
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e8:	eb 06                	jmp    8008f0 <strcmp+0x11>
		p++, q++;
  8008ea:	83 c1 01             	add    $0x1,%ecx
  8008ed:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f0:	0f b6 01             	movzbl (%ecx),%eax
  8008f3:	84 c0                	test   %al,%al
  8008f5:	74 04                	je     8008fb <strcmp+0x1c>
  8008f7:	3a 02                	cmp    (%edx),%al
  8008f9:	74 ef                	je     8008ea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 c0             	movzbl %al,%eax
  8008fe:	0f b6 12             	movzbl (%edx),%edx
  800901:	29 d0                	sub    %edx,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	53                   	push   %ebx
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	89 c3                	mov    %eax,%ebx
  800911:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800914:	eb 06                	jmp    80091c <strncmp+0x17>
		n--, p++, q++;
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091c:	39 d8                	cmp    %ebx,%eax
  80091e:	74 15                	je     800935 <strncmp+0x30>
  800920:	0f b6 08             	movzbl (%eax),%ecx
  800923:	84 c9                	test   %cl,%cl
  800925:	74 04                	je     80092b <strncmp+0x26>
  800927:	3a 0a                	cmp    (%edx),%cl
  800929:	74 eb                	je     800916 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092b:	0f b6 00             	movzbl (%eax),%eax
  80092e:	0f b6 12             	movzbl (%edx),%edx
  800931:	29 d0                	sub    %edx,%eax
  800933:	eb 05                	jmp    80093a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800947:	eb 07                	jmp    800950 <strchr+0x13>
		if (*s == c)
  800949:	38 ca                	cmp    %cl,%dl
  80094b:	74 0f                	je     80095c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	84 d2                	test   %dl,%dl
  800955:	75 f2                	jne    800949 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800968:	eb 03                	jmp    80096d <strfind+0xf>
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800970:	38 ca                	cmp    %cl,%dl
  800972:	74 04                	je     800978 <strfind+0x1a>
  800974:	84 d2                	test   %dl,%dl
  800976:	75 f2                	jne    80096a <strfind+0xc>
			break;
	return (char *) s;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 7d 08             	mov    0x8(%ebp),%edi
  800983:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800986:	85 c9                	test   %ecx,%ecx
  800988:	74 36                	je     8009c0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800990:	75 28                	jne    8009ba <memset+0x40>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 23                	jne    8009ba <memset+0x40>
		c &= 0xFF;
  800997:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099b:	89 d3                	mov    %edx,%ebx
  80099d:	c1 e3 08             	shl    $0x8,%ebx
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	c1 e6 18             	shl    $0x18,%esi
  8009a5:	89 d0                	mov    %edx,%eax
  8009a7:	c1 e0 10             	shl    $0x10,%eax
  8009aa:	09 f0                	or     %esi,%eax
  8009ac:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ae:	89 d8                	mov    %ebx,%eax
  8009b0:	09 d0                	or     %edx,%eax
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
  8009b5:	fc                   	cld    
  8009b6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b8:	eb 06                	jmp    8009c0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	fc                   	cld    
  8009be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c0:	89 f8                	mov    %edi,%eax
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d5:	39 c6                	cmp    %eax,%esi
  8009d7:	73 35                	jae    800a0e <memmove+0x47>
  8009d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dc:	39 d0                	cmp    %edx,%eax
  8009de:	73 2e                	jae    800a0e <memmove+0x47>
		s += n;
		d += n;
  8009e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 d6                	mov    %edx,%esi
  8009e5:	09 fe                	or     %edi,%esi
  8009e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ed:	75 13                	jne    800a02 <memmove+0x3b>
  8009ef:	f6 c1 03             	test   $0x3,%cl
  8009f2:	75 0e                	jne    800a02 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f4:	83 ef 04             	sub    $0x4,%edi
  8009f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
  8009fd:	fd                   	std    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 09                	jmp    800a0b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a02:	83 ef 01             	sub    $0x1,%edi
  800a05:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a08:	fd                   	std    
  800a09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0b:	fc                   	cld    
  800a0c:	eb 1d                	jmp    800a2b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0e:	89 f2                	mov    %esi,%edx
  800a10:	09 c2                	or     %eax,%edx
  800a12:	f6 c2 03             	test   $0x3,%dl
  800a15:	75 0f                	jne    800a26 <memmove+0x5f>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 0a                	jne    800a26 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
  800a1f:	89 c7                	mov    %eax,%edi
  800a21:	fc                   	cld    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 05                	jmp    800a2b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a32:	ff 75 10             	pushl  0x10(%ebp)
  800a35:	ff 75 0c             	pushl  0xc(%ebp)
  800a38:	ff 75 08             	pushl  0x8(%ebp)
  800a3b:	e8 87 ff ff ff       	call   8009c7 <memmove>
}
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4d:	89 c6                	mov    %eax,%esi
  800a4f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a52:	eb 1a                	jmp    800a6e <memcmp+0x2c>
		if (*s1 != *s2)
  800a54:	0f b6 08             	movzbl (%eax),%ecx
  800a57:	0f b6 1a             	movzbl (%edx),%ebx
  800a5a:	38 d9                	cmp    %bl,%cl
  800a5c:	74 0a                	je     800a68 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5e:	0f b6 c1             	movzbl %cl,%eax
  800a61:	0f b6 db             	movzbl %bl,%ebx
  800a64:	29 d8                	sub    %ebx,%eax
  800a66:	eb 0f                	jmp    800a77 <memcmp+0x35>
		s1++, s2++;
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	39 f0                	cmp    %esi,%eax
  800a70:	75 e2                	jne    800a54 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a82:	89 c1                	mov    %eax,%ecx
  800a84:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a87:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8b:	eb 0a                	jmp    800a97 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	39 da                	cmp    %ebx,%edx
  800a92:	74 07                	je     800a9b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	39 c8                	cmp    %ecx,%eax
  800a99:	72 f2                	jb     800a8d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaa:	eb 03                	jmp    800aaf <strtol+0x11>
		s++;
  800aac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	0f b6 01             	movzbl (%ecx),%eax
  800ab2:	3c 20                	cmp    $0x20,%al
  800ab4:	74 f6                	je     800aac <strtol+0xe>
  800ab6:	3c 09                	cmp    $0x9,%al
  800ab8:	74 f2                	je     800aac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aba:	3c 2b                	cmp    $0x2b,%al
  800abc:	75 0a                	jne    800ac8 <strtol+0x2a>
		s++;
  800abe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac6:	eb 11                	jmp    800ad9 <strtol+0x3b>
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acd:	3c 2d                	cmp    $0x2d,%al
  800acf:	75 08                	jne    800ad9 <strtol+0x3b>
		s++, neg = 1;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800adf:	75 15                	jne    800af6 <strtol+0x58>
  800ae1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae4:	75 10                	jne    800af6 <strtol+0x58>
  800ae6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aea:	75 7c                	jne    800b68 <strtol+0xca>
		s += 2, base = 16;
  800aec:	83 c1 02             	add    $0x2,%ecx
  800aef:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af4:	eb 16                	jmp    800b0c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af6:	85 db                	test   %ebx,%ebx
  800af8:	75 12                	jne    800b0c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aff:	80 39 30             	cmpb   $0x30,(%ecx)
  800b02:	75 08                	jne    800b0c <strtol+0x6e>
		s++, base = 8;
  800b04:	83 c1 01             	add    $0x1,%ecx
  800b07:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b14:	0f b6 11             	movzbl (%ecx),%edx
  800b17:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 09             	cmp    $0x9,%bl
  800b1f:	77 08                	ja     800b29 <strtol+0x8b>
			dig = *s - '0';
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 30             	sub    $0x30,%edx
  800b27:	eb 22                	jmp    800b4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 08                	ja     800b3b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 57             	sub    $0x57,%edx
  800b39:	eb 10                	jmp    800b4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 19             	cmp    $0x19,%bl
  800b43:	77 16                	ja     800b5b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b45:	0f be d2             	movsbl %dl,%edx
  800b48:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4e:	7d 0b                	jge    800b5b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b50:	83 c1 01             	add    $0x1,%ecx
  800b53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b57:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b59:	eb b9                	jmp    800b14 <strtol+0x76>

	if (endptr)
  800b5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5f:	74 0d                	je     800b6e <strtol+0xd0>
		*endptr = (char *) s;
  800b61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b64:	89 0e                	mov    %ecx,(%esi)
  800b66:	eb 06                	jmp    800b6e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	74 98                	je     800b04 <strtol+0x66>
  800b6c:	eb 9e                	jmp    800b0c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	f7 da                	neg    %edx
  800b72:	85 ff                	test   %edi,%edi
  800b74:	0f 45 c2             	cmovne %edx,%eax
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	89 c3                	mov    %eax,%ebx
  800b8f:	89 c7                	mov    %eax,%edi
  800b91:	89 c6                	mov    %eax,%esi
  800b93:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	89 cb                	mov    %ecx,%ebx
  800bd1:	89 cf                	mov    %ecx,%edi
  800bd3:	89 ce                	mov    %ecx,%esi
  800bd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 17                	jle    800bf2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 03                	push   $0x3
  800be1:	68 9f 26 80 00       	push   $0x80269f
  800be6:	6a 23                	push   $0x23
  800be8:	68 bc 26 80 00       	push   $0x8026bc
  800bed:	e8 6d 13 00 00       	call   801f5f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_yield>:

void
sys_yield(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c29:	89 d1                	mov    %edx,%ecx
  800c2b:	89 d3                	mov    %edx,%ebx
  800c2d:	89 d7                	mov    %edx,%edi
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	be 00 00 00 00       	mov    $0x0,%esi
  800c46:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	89 f7                	mov    %esi,%edi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 04                	push   $0x4
  800c62:	68 9f 26 80 00       	push   $0x80269f
  800c67:	6a 23                	push   $0x23
  800c69:	68 bc 26 80 00       	push   $0x8026bc
  800c6e:	e8 ec 12 00 00       	call   801f5f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	b8 05 00 00 00       	mov    $0x5,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c95:	8b 75 18             	mov    0x18(%ebp),%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 05                	push   $0x5
  800ca4:	68 9f 26 80 00       	push   $0x80269f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 bc 26 80 00       	push   $0x8026bc
  800cb0:	e8 aa 12 00 00       	call   801f5f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccb:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	89 df                	mov    %ebx,%edi
  800cd8:	89 de                	mov    %ebx,%esi
  800cda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 17                	jle    800cf7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 06                	push   $0x6
  800ce6:	68 9f 26 80 00       	push   $0x80269f
  800ceb:	6a 23                	push   $0x23
  800ced:	68 bc 26 80 00       	push   $0x8026bc
  800cf2:	e8 68 12 00 00       	call   801f5f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 17                	jle    800d39 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 08                	push   $0x8
  800d28:	68 9f 26 80 00       	push   $0x80269f
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 bc 26 80 00       	push   $0x8026bc
  800d34:	e8 26 12 00 00       	call   801f5f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 df                	mov    %ebx,%edi
  800d5c:	89 de                	mov    %ebx,%esi
  800d5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 17                	jle    800d7b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 09                	push   $0x9
  800d6a:	68 9f 26 80 00       	push   $0x80269f
  800d6f:	6a 23                	push   $0x23
  800d71:	68 bc 26 80 00       	push   $0x8026bc
  800d76:	e8 e4 11 00 00       	call   801f5f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 17                	jle    800dbd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 0a                	push   $0xa
  800dac:	68 9f 26 80 00       	push   $0x80269f
  800db1:	6a 23                	push   $0x23
  800db3:	68 bc 26 80 00       	push   $0x8026bc
  800db8:	e8 a2 11 00 00       	call   801f5f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 cb                	mov    %ecx,%ebx
  800e00:	89 cf                	mov    %ecx,%edi
  800e02:	89 ce                	mov    %ecx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0d                	push   $0xd
  800e10:	68 9f 26 80 00       	push   $0x80269f
  800e15:	6a 23                	push   $0x23
  800e17:	68 bc 26 80 00       	push   $0x8026bc
  800e1c:	e8 3e 11 00 00       	call   801f5f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e34:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 cb                	mov    %ecx,%ebx
  800e3e:	89 cf                	mov    %ecx,%edi
  800e40:	89 ce                	mov    %ecx,%esi
  800e42:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e54:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 cb                	mov    %ecx,%ebx
  800e5e:	89 cf                	mov    %ecx,%edi
  800e60:	89 ce                	mov    %ecx,%esi
  800e62:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e73:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e75:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e79:	74 11                	je     800e8c <pgfault+0x23>
  800e7b:	89 d8                	mov    %ebx,%eax
  800e7d:	c1 e8 0c             	shr    $0xc,%eax
  800e80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e87:	f6 c4 08             	test   $0x8,%ah
  800e8a:	75 14                	jne    800ea0 <pgfault+0x37>
		panic("faulting access");
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	68 ca 26 80 00       	push   $0x8026ca
  800e94:	6a 1e                	push   $0x1e
  800e96:	68 da 26 80 00       	push   $0x8026da
  800e9b:	e8 bf 10 00 00       	call   801f5f <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ea0:	83 ec 04             	sub    $0x4,%esp
  800ea3:	6a 07                	push   $0x7
  800ea5:	68 00 f0 7f 00       	push   $0x7ff000
  800eaa:	6a 00                	push   $0x0
  800eac:	e8 87 fd ff ff       	call   800c38 <sys_page_alloc>
	if (r < 0) {
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	79 12                	jns    800eca <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800eb8:	50                   	push   %eax
  800eb9:	68 e5 26 80 00       	push   $0x8026e5
  800ebe:	6a 2c                	push   $0x2c
  800ec0:	68 da 26 80 00       	push   $0x8026da
  800ec5:	e8 95 10 00 00       	call   801f5f <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	68 00 10 00 00       	push   $0x1000
  800ed8:	53                   	push   %ebx
  800ed9:	68 00 f0 7f 00       	push   $0x7ff000
  800ede:	e8 4c fb ff ff       	call   800a2f <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ee3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eea:	53                   	push   %ebx
  800eeb:	6a 00                	push   $0x0
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	6a 00                	push   $0x0
  800ef4:	e8 82 fd ff ff       	call   800c7b <sys_page_map>
	if (r < 0) {
  800ef9:	83 c4 20             	add    $0x20,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	79 12                	jns    800f12 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f00:	50                   	push   %eax
  800f01:	68 e5 26 80 00       	push   $0x8026e5
  800f06:	6a 33                	push   $0x33
  800f08:	68 da 26 80 00       	push   $0x8026da
  800f0d:	e8 4d 10 00 00       	call   801f5f <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	68 00 f0 7f 00       	push   $0x7ff000
  800f1a:	6a 00                	push   $0x0
  800f1c:	e8 9c fd ff ff       	call   800cbd <sys_page_unmap>
	if (r < 0) {
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	79 12                	jns    800f3a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f28:	50                   	push   %eax
  800f29:	68 e5 26 80 00       	push   $0x8026e5
  800f2e:	6a 37                	push   $0x37
  800f30:	68 da 26 80 00       	push   $0x8026da
  800f35:	e8 25 10 00 00       	call   801f5f <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	57                   	push   %edi
  800f43:	56                   	push   %esi
  800f44:	53                   	push   %ebx
  800f45:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f48:	68 69 0e 80 00       	push   $0x800e69
  800f4d:	e8 53 10 00 00       	call   801fa5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f52:	b8 07 00 00 00       	mov    $0x7,%eax
  800f57:	cd 30                	int    $0x30
  800f59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 17                	jns    800f7a <fork+0x3b>
		panic("fork fault %e");
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	68 fe 26 80 00       	push   $0x8026fe
  800f6b:	68 84 00 00 00       	push   $0x84
  800f70:	68 da 26 80 00       	push   $0x8026da
  800f75:	e8 e5 0f 00 00       	call   801f5f <_panic>
  800f7a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f80:	75 25                	jne    800fa7 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f82:	e8 73 fc ff ff       	call   800bfa <sys_getenvid>
  800f87:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8c:	89 c2                	mov    %eax,%edx
  800f8e:	c1 e2 07             	shl    $0x7,%edx
  800f91:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f98:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	e9 61 01 00 00       	jmp    801108 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	6a 07                	push   $0x7
  800fac:	68 00 f0 bf ee       	push   $0xeebff000
  800fb1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb4:	e8 7f fc ff ff       	call   800c38 <sys_page_alloc>
  800fb9:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc1:	89 d8                	mov    %ebx,%eax
  800fc3:	c1 e8 16             	shr    $0x16,%eax
  800fc6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcd:	a8 01                	test   $0x1,%al
  800fcf:	0f 84 fc 00 00 00    	je     8010d1 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fd5:	89 d8                	mov    %ebx,%eax
  800fd7:	c1 e8 0c             	shr    $0xc,%eax
  800fda:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe1:	f6 c2 01             	test   $0x1,%dl
  800fe4:	0f 84 e7 00 00 00    	je     8010d1 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fea:	89 c6                	mov    %eax,%esi
  800fec:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff6:	f6 c6 04             	test   $0x4,%dh
  800ff9:	74 39                	je     801034 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ffb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	25 07 0e 00 00       	and    $0xe07,%eax
  80100a:	50                   	push   %eax
  80100b:	56                   	push   %esi
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	6a 00                	push   $0x0
  801010:	e8 66 fc ff ff       	call   800c7b <sys_page_map>
		if (r < 0) {
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	0f 89 b1 00 00 00    	jns    8010d1 <fork+0x192>
		    	panic("sys page map fault %e");
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	68 0c 27 80 00       	push   $0x80270c
  801028:	6a 54                	push   $0x54
  80102a:	68 da 26 80 00       	push   $0x8026da
  80102f:	e8 2b 0f 00 00       	call   801f5f <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801034:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103b:	f6 c2 02             	test   $0x2,%dl
  80103e:	75 0c                	jne    80104c <fork+0x10d>
  801040:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801047:	f6 c4 08             	test   $0x8,%ah
  80104a:	74 5b                	je     8010a7 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	68 05 08 00 00       	push   $0x805
  801054:	56                   	push   %esi
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 1d fc ff ff       	call   800c7b <sys_page_map>
		if (r < 0) {
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 14                	jns    801079 <fork+0x13a>
		    	panic("sys page map fault %e");
  801065:	83 ec 04             	sub    $0x4,%esp
  801068:	68 0c 27 80 00       	push   $0x80270c
  80106d:	6a 5b                	push   $0x5b
  80106f:	68 da 26 80 00       	push   $0x8026da
  801074:	e8 e6 0e 00 00       	call   801f5f <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	68 05 08 00 00       	push   $0x805
  801081:	56                   	push   %esi
  801082:	6a 00                	push   $0x0
  801084:	56                   	push   %esi
  801085:	6a 00                	push   $0x0
  801087:	e8 ef fb ff ff       	call   800c7b <sys_page_map>
		if (r < 0) {
  80108c:	83 c4 20             	add    $0x20,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 3e                	jns    8010d1 <fork+0x192>
		    	panic("sys page map fault %e");
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	68 0c 27 80 00       	push   $0x80270c
  80109b:	6a 5f                	push   $0x5f
  80109d:	68 da 26 80 00       	push   $0x8026da
  8010a2:	e8 b8 0e 00 00       	call   801f5f <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	6a 05                	push   $0x5
  8010ac:	56                   	push   %esi
  8010ad:	57                   	push   %edi
  8010ae:	56                   	push   %esi
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 c5 fb ff ff       	call   800c7b <sys_page_map>
		if (r < 0) {
  8010b6:	83 c4 20             	add    $0x20,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	79 14                	jns    8010d1 <fork+0x192>
		    	panic("sys page map fault %e");
  8010bd:	83 ec 04             	sub    $0x4,%esp
  8010c0:	68 0c 27 80 00       	push   $0x80270c
  8010c5:	6a 64                	push   $0x64
  8010c7:	68 da 26 80 00       	push   $0x8026da
  8010cc:	e8 8e 0e 00 00       	call   801f5f <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d7:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010dd:	0f 85 de fe ff ff    	jne    800fc1 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e8:	8b 40 70             	mov    0x70(%eax),%eax
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	50                   	push   %eax
  8010ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f2:	57                   	push   %edi
  8010f3:	e8 8b fc ff ff       	call   800d83 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010f8:	83 c4 08             	add    $0x8,%esp
  8010fb:	6a 02                	push   $0x2
  8010fd:	57                   	push   %edi
  8010fe:	e8 fc fb ff ff       	call   800cff <sys_env_set_status>
	
	return envid;
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <sfork>:

envid_t
sfork(void)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801122:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	53                   	push   %ebx
  80112c:	68 24 27 80 00       	push   $0x802724
  801131:	e8 7a f1 ff ff       	call   8002b0 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801136:	c7 04 24 e3 01 80 00 	movl   $0x8001e3,(%esp)
  80113d:	e8 e7 fc ff ff       	call   800e29 <sys_thread_create>
  801142:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801144:	83 c4 08             	add    $0x8,%esp
  801147:	53                   	push   %ebx
  801148:	68 24 27 80 00       	push   $0x802724
  80114d:	e8 5e f1 ff ff       	call   8002b0 <cprintf>
	return id;
	//return 0;
}
  801152:	89 f0                	mov    %esi,%eax
  801154:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	8b 75 08             	mov    0x8(%ebp),%esi
  801163:	8b 45 0c             	mov    0xc(%ebp),%eax
  801166:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801169:	85 c0                	test   %eax,%eax
  80116b:	75 12                	jne    80117f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	68 00 00 c0 ee       	push   $0xeec00000
  801175:	e8 6e fc ff ff       	call   800de8 <sys_ipc_recv>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	eb 0c                	jmp    80118b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	50                   	push   %eax
  801183:	e8 60 fc ff ff       	call   800de8 <sys_ipc_recv>
  801188:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80118b:	85 f6                	test   %esi,%esi
  80118d:	0f 95 c1             	setne  %cl
  801190:	85 db                	test   %ebx,%ebx
  801192:	0f 95 c2             	setne  %dl
  801195:	84 d1                	test   %dl,%cl
  801197:	74 09                	je     8011a2 <ipc_recv+0x47>
  801199:	89 c2                	mov    %eax,%edx
  80119b:	c1 ea 1f             	shr    $0x1f,%edx
  80119e:	84 d2                	test   %dl,%dl
  8011a0:	75 2a                	jne    8011cc <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8011a2:	85 f6                	test   %esi,%esi
  8011a4:	74 0d                	je     8011b3 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8011a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ab:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8011b1:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8011b3:	85 db                	test   %ebx,%ebx
  8011b5:	74 0d                	je     8011c4 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8011b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bc:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  8011c2:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c9:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  8011cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8011e5:	85 db                	test   %ebx,%ebx
  8011e7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011ec:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011ef:	ff 75 14             	pushl  0x14(%ebp)
  8011f2:	53                   	push   %ebx
  8011f3:	56                   	push   %esi
  8011f4:	57                   	push   %edi
  8011f5:	e8 cb fb ff ff       	call   800dc5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 1f             	shr    $0x1f,%edx
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	84 d2                	test   %dl,%dl
  801204:	74 17                	je     80121d <ipc_send+0x4a>
  801206:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801209:	74 12                	je     80121d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80120b:	50                   	push   %eax
  80120c:	68 47 27 80 00       	push   $0x802747
  801211:	6a 47                	push   $0x47
  801213:	68 55 27 80 00       	push   $0x802755
  801218:	e8 42 0d 00 00       	call   801f5f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80121d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801220:	75 07                	jne    801229 <ipc_send+0x56>
			sys_yield();
  801222:	e8 f2 f9 ff ff       	call   800c19 <sys_yield>
  801227:	eb c6                	jmp    8011ef <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801229:	85 c0                	test   %eax,%eax
  80122b:	75 c2                	jne    8011ef <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801240:	89 c2                	mov    %eax,%edx
  801242:	c1 e2 07             	shl    $0x7,%edx
  801245:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  80124c:	8b 52 5c             	mov    0x5c(%edx),%edx
  80124f:	39 ca                	cmp    %ecx,%edx
  801251:	75 11                	jne    801264 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801253:	89 c2                	mov    %eax,%edx
  801255:	c1 e2 07             	shl    $0x7,%edx
  801258:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80125f:	8b 40 54             	mov    0x54(%eax),%eax
  801262:	eb 0f                	jmp    801273 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801264:	83 c0 01             	add    $0x1,%eax
  801267:	3d 00 04 00 00       	cmp    $0x400,%eax
  80126c:	75 d2                	jne    801240 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801278:	8b 45 08             	mov    0x8(%ebp),%eax
  80127b:	05 00 00 00 30       	add    $0x30000000,%eax
  801280:	c1 e8 0c             	shr    $0xc,%eax
}
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801288:	8b 45 08             	mov    0x8(%ebp),%eax
  80128b:	05 00 00 00 30       	add    $0x30000000,%eax
  801290:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801295:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	c1 ea 16             	shr    $0x16,%edx
  8012ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b3:	f6 c2 01             	test   $0x1,%dl
  8012b6:	74 11                	je     8012c9 <fd_alloc+0x2d>
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	c1 ea 0c             	shr    $0xc,%edx
  8012bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c4:	f6 c2 01             	test   $0x1,%dl
  8012c7:	75 09                	jne    8012d2 <fd_alloc+0x36>
			*fd_store = fd;
  8012c9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d0:	eb 17                	jmp    8012e9 <fd_alloc+0x4d>
  8012d2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012d7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012dc:	75 c9                	jne    8012a7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012de:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012e4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f1:	83 f8 1f             	cmp    $0x1f,%eax
  8012f4:	77 36                	ja     80132c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012f6:	c1 e0 0c             	shl    $0xc,%eax
  8012f9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 ea 16             	shr    $0x16,%edx
  801303:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130a:	f6 c2 01             	test   $0x1,%dl
  80130d:	74 24                	je     801333 <fd_lookup+0x48>
  80130f:	89 c2                	mov    %eax,%edx
  801311:	c1 ea 0c             	shr    $0xc,%edx
  801314:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131b:	f6 c2 01             	test   $0x1,%dl
  80131e:	74 1a                	je     80133a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801320:	8b 55 0c             	mov    0xc(%ebp),%edx
  801323:	89 02                	mov    %eax,(%edx)
	return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
  80132a:	eb 13                	jmp    80133f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801331:	eb 0c                	jmp    80133f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801333:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801338:	eb 05                	jmp    80133f <fd_lookup+0x54>
  80133a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134a:	ba dc 27 80 00       	mov    $0x8027dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80134f:	eb 13                	jmp    801364 <dev_lookup+0x23>
  801351:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801354:	39 08                	cmp    %ecx,(%eax)
  801356:	75 0c                	jne    801364 <dev_lookup+0x23>
			*dev = devtab[i];
  801358:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80135d:	b8 00 00 00 00       	mov    $0x0,%eax
  801362:	eb 2e                	jmp    801392 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801364:	8b 02                	mov    (%edx),%eax
  801366:	85 c0                	test   %eax,%eax
  801368:	75 e7                	jne    801351 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80136a:	a1 04 40 80 00       	mov    0x804004,%eax
  80136f:	8b 40 54             	mov    0x54(%eax),%eax
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	51                   	push   %ecx
  801376:	50                   	push   %eax
  801377:	68 60 27 80 00       	push   $0x802760
  80137c:	e8 2f ef ff ff       	call   8002b0 <cprintf>
	*dev = 0;
  801381:	8b 45 0c             	mov    0xc(%ebp),%eax
  801384:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
  801399:	83 ec 10             	sub    $0x10,%esp
  80139c:	8b 75 08             	mov    0x8(%ebp),%esi
  80139f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ac:	c1 e8 0c             	shr    $0xc,%eax
  8013af:	50                   	push   %eax
  8013b0:	e8 36 ff ff ff       	call   8012eb <fd_lookup>
  8013b5:	83 c4 08             	add    $0x8,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 05                	js     8013c1 <fd_close+0x2d>
	    || fd != fd2)
  8013bc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013bf:	74 0c                	je     8013cd <fd_close+0x39>
		return (must_exist ? r : 0);
  8013c1:	84 db                	test   %bl,%bl
  8013c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c8:	0f 44 c2             	cmove  %edx,%eax
  8013cb:	eb 41                	jmp    80140e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	ff 36                	pushl  (%esi)
  8013d6:	e8 66 ff ff ff       	call   801341 <dev_lookup>
  8013db:	89 c3                	mov    %eax,%ebx
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 1a                	js     8013fe <fd_close+0x6a>
		if (dev->dev_close)
  8013e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ea:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	74 0b                	je     8013fe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	56                   	push   %esi
  8013f7:	ff d0                	call   *%eax
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	56                   	push   %esi
  801402:	6a 00                	push   $0x0
  801404:	e8 b4 f8 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 d8                	mov    %ebx,%eax
}
  80140e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 c4 fe ff ff       	call   8012eb <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 10                	js     80143e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	6a 01                	push   $0x1
  801433:	ff 75 f4             	pushl  -0xc(%ebp)
  801436:	e8 59 ff ff ff       	call   801394 <fd_close>
  80143b:	83 c4 10             	add    $0x10,%esp
}
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <close_all>:

void
close_all(void)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	53                   	push   %ebx
  801444:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801447:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	53                   	push   %ebx
  801450:	e8 c0 ff ff ff       	call   801415 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801455:	83 c3 01             	add    $0x1,%ebx
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	83 fb 20             	cmp    $0x20,%ebx
  80145e:	75 ec                	jne    80144c <close_all+0xc>
		close(i);
}
  801460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	57                   	push   %edi
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	83 ec 2c             	sub    $0x2c,%esp
  80146e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801471:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	ff 75 08             	pushl  0x8(%ebp)
  801478:	e8 6e fe ff ff       	call   8012eb <fd_lookup>
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	0f 88 c1 00 00 00    	js     801549 <dup+0xe4>
		return r;
	close(newfdnum);
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	56                   	push   %esi
  80148c:	e8 84 ff ff ff       	call   801415 <close>

	newfd = INDEX2FD(newfdnum);
  801491:	89 f3                	mov    %esi,%ebx
  801493:	c1 e3 0c             	shl    $0xc,%ebx
  801496:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80149c:	83 c4 04             	add    $0x4,%esp
  80149f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a2:	e8 de fd ff ff       	call   801285 <fd2data>
  8014a7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a9:	89 1c 24             	mov    %ebx,(%esp)
  8014ac:	e8 d4 fd ff ff       	call   801285 <fd2data>
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b7:	89 f8                	mov    %edi,%eax
  8014b9:	c1 e8 16             	shr    $0x16,%eax
  8014bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c3:	a8 01                	test   $0x1,%al
  8014c5:	74 37                	je     8014fe <dup+0x99>
  8014c7:	89 f8                	mov    %edi,%eax
  8014c9:	c1 e8 0c             	shr    $0xc,%eax
  8014cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d3:	f6 c2 01             	test   $0x1,%dl
  8014d6:	74 26                	je     8014fe <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014df:	83 ec 0c             	sub    $0xc,%esp
  8014e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e7:	50                   	push   %eax
  8014e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014eb:	6a 00                	push   $0x0
  8014ed:	57                   	push   %edi
  8014ee:	6a 00                	push   $0x0
  8014f0:	e8 86 f7 ff ff       	call   800c7b <sys_page_map>
  8014f5:	89 c7                	mov    %eax,%edi
  8014f7:	83 c4 20             	add    $0x20,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 2e                	js     80152c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801501:	89 d0                	mov    %edx,%eax
  801503:	c1 e8 0c             	shr    $0xc,%eax
  801506:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	25 07 0e 00 00       	and    $0xe07,%eax
  801515:	50                   	push   %eax
  801516:	53                   	push   %ebx
  801517:	6a 00                	push   $0x0
  801519:	52                   	push   %edx
  80151a:	6a 00                	push   $0x0
  80151c:	e8 5a f7 ff ff       	call   800c7b <sys_page_map>
  801521:	89 c7                	mov    %eax,%edi
  801523:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801526:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801528:	85 ff                	test   %edi,%edi
  80152a:	79 1d                	jns    801549 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	53                   	push   %ebx
  801530:	6a 00                	push   $0x0
  801532:	e8 86 f7 ff ff       	call   800cbd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80153d:	6a 00                	push   $0x0
  80153f:	e8 79 f7 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	89 f8                	mov    %edi,%eax
}
  801549:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5f                   	pop    %edi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	53                   	push   %ebx
  801555:	83 ec 14             	sub    $0x14,%esp
  801558:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	53                   	push   %ebx
  801560:	e8 86 fd ff ff       	call   8012eb <fd_lookup>
  801565:	83 c4 08             	add    $0x8,%esp
  801568:	89 c2                	mov    %eax,%edx
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 6d                	js     8015db <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	ff 30                	pushl  (%eax)
  80157a:	e8 c2 fd ff ff       	call   801341 <dev_lookup>
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 4c                	js     8015d2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801586:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801589:	8b 42 08             	mov    0x8(%edx),%eax
  80158c:	83 e0 03             	and    $0x3,%eax
  80158f:	83 f8 01             	cmp    $0x1,%eax
  801592:	75 21                	jne    8015b5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801594:	a1 04 40 80 00       	mov    0x804004,%eax
  801599:	8b 40 54             	mov    0x54(%eax),%eax
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	53                   	push   %ebx
  8015a0:	50                   	push   %eax
  8015a1:	68 a1 27 80 00       	push   $0x8027a1
  8015a6:	e8 05 ed ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b3:	eb 26                	jmp    8015db <read+0x8a>
	}
	if (!dev->dev_read)
  8015b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b8:	8b 40 08             	mov    0x8(%eax),%eax
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	74 17                	je     8015d6 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	ff 75 10             	pushl  0x10(%ebp)
  8015c5:	ff 75 0c             	pushl  0xc(%ebp)
  8015c8:	52                   	push   %edx
  8015c9:	ff d0                	call   *%eax
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	eb 09                	jmp    8015db <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	eb 05                	jmp    8015db <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	57                   	push   %edi
  8015e6:	56                   	push   %esi
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f6:	eb 21                	jmp    801619 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	89 f0                	mov    %esi,%eax
  8015fd:	29 d8                	sub    %ebx,%eax
  8015ff:	50                   	push   %eax
  801600:	89 d8                	mov    %ebx,%eax
  801602:	03 45 0c             	add    0xc(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	57                   	push   %edi
  801607:	e8 45 ff ff ff       	call   801551 <read>
		if (m < 0)
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 10                	js     801623 <readn+0x41>
			return m;
		if (m == 0)
  801613:	85 c0                	test   %eax,%eax
  801615:	74 0a                	je     801621 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801617:	01 c3                	add    %eax,%ebx
  801619:	39 f3                	cmp    %esi,%ebx
  80161b:	72 db                	jb     8015f8 <readn+0x16>
  80161d:	89 d8                	mov    %ebx,%eax
  80161f:	eb 02                	jmp    801623 <readn+0x41>
  801621:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5f                   	pop    %edi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 14             	sub    $0x14,%esp
  801632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	53                   	push   %ebx
  80163a:	e8 ac fc ff ff       	call   8012eb <fd_lookup>
  80163f:	83 c4 08             	add    $0x8,%esp
  801642:	89 c2                	mov    %eax,%edx
  801644:	85 c0                	test   %eax,%eax
  801646:	78 68                	js     8016b0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	ff 30                	pushl  (%eax)
  801654:	e8 e8 fc ff ff       	call   801341 <dev_lookup>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 47                	js     8016a7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801667:	75 21                	jne    80168a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801669:	a1 04 40 80 00       	mov    0x804004,%eax
  80166e:	8b 40 54             	mov    0x54(%eax),%eax
  801671:	83 ec 04             	sub    $0x4,%esp
  801674:	53                   	push   %ebx
  801675:	50                   	push   %eax
  801676:	68 bd 27 80 00       	push   $0x8027bd
  80167b:	e8 30 ec ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801688:	eb 26                	jmp    8016b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168d:	8b 52 0c             	mov    0xc(%edx),%edx
  801690:	85 d2                	test   %edx,%edx
  801692:	74 17                	je     8016ab <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801694:	83 ec 04             	sub    $0x4,%esp
  801697:	ff 75 10             	pushl  0x10(%ebp)
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	50                   	push   %eax
  80169e:	ff d2                	call   *%edx
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	eb 09                	jmp    8016b0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	eb 05                	jmp    8016b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016b0:	89 d0                	mov    %edx,%eax
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c0:	50                   	push   %eax
  8016c1:	ff 75 08             	pushl  0x8(%ebp)
  8016c4:	e8 22 fc ff ff       	call   8012eb <fd_lookup>
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 0e                	js     8016de <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 14             	sub    $0x14,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	53                   	push   %ebx
  8016ef:	e8 f7 fb ff ff       	call   8012eb <fd_lookup>
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 65                	js     801762 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	ff 30                	pushl  (%eax)
  801709:	e8 33 fc ff ff       	call   801341 <dev_lookup>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 44                	js     801759 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801718:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171c:	75 21                	jne    80173f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80171e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801723:	8b 40 54             	mov    0x54(%eax),%eax
  801726:	83 ec 04             	sub    $0x4,%esp
  801729:	53                   	push   %ebx
  80172a:	50                   	push   %eax
  80172b:	68 80 27 80 00       	push   $0x802780
  801730:	e8 7b eb ff ff       	call   8002b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80173d:	eb 23                	jmp    801762 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80173f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801742:	8b 52 18             	mov    0x18(%edx),%edx
  801745:	85 d2                	test   %edx,%edx
  801747:	74 14                	je     80175d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	50                   	push   %eax
  801750:	ff d2                	call   *%edx
  801752:	89 c2                	mov    %eax,%edx
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	eb 09                	jmp    801762 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801759:	89 c2                	mov    %eax,%edx
  80175b:	eb 05                	jmp    801762 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80175d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801762:	89 d0                	mov    %edx,%eax
  801764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	53                   	push   %ebx
  80176d:	83 ec 14             	sub    $0x14,%esp
  801770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801773:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	ff 75 08             	pushl  0x8(%ebp)
  80177a:	e8 6c fb ff ff       	call   8012eb <fd_lookup>
  80177f:	83 c4 08             	add    $0x8,%esp
  801782:	89 c2                	mov    %eax,%edx
  801784:	85 c0                	test   %eax,%eax
  801786:	78 58                	js     8017e0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801792:	ff 30                	pushl  (%eax)
  801794:	e8 a8 fb ff ff       	call   801341 <dev_lookup>
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 37                	js     8017d7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a7:	74 32                	je     8017db <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b3:	00 00 00 
	stat->st_isdir = 0;
  8017b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017bd:	00 00 00 
	stat->st_dev = dev;
  8017c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	53                   	push   %ebx
  8017ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cd:	ff 50 14             	call   *0x14(%eax)
  8017d0:	89 c2                	mov    %eax,%edx
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	eb 09                	jmp    8017e0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	eb 05                	jmp    8017e0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e0:	89 d0                	mov    %edx,%eax
  8017e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	6a 00                	push   $0x0
  8017f1:	ff 75 08             	pushl  0x8(%ebp)
  8017f4:	e8 e3 01 00 00       	call   8019dc <open>
  8017f9:	89 c3                	mov    %eax,%ebx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 1b                	js     80181d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	ff 75 0c             	pushl  0xc(%ebp)
  801808:	50                   	push   %eax
  801809:	e8 5b ff ff ff       	call   801769 <fstat>
  80180e:	89 c6                	mov    %eax,%esi
	close(fd);
  801810:	89 1c 24             	mov    %ebx,(%esp)
  801813:	e8 fd fb ff ff       	call   801415 <close>
	return r;
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	89 f0                	mov    %esi,%eax
}
  80181d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	89 c6                	mov    %eax,%esi
  80182b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80182d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801834:	75 12                	jne    801848 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	6a 01                	push   $0x1
  80183b:	e8 f5 f9 ff ff       	call   801235 <ipc_find_env>
  801840:	a3 00 40 80 00       	mov    %eax,0x804000
  801845:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801848:	6a 07                	push   $0x7
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	56                   	push   %esi
  801850:	ff 35 00 40 80 00    	pushl  0x804000
  801856:	e8 78 f9 ff ff       	call   8011d3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80185b:	83 c4 0c             	add    $0xc,%esp
  80185e:	6a 00                	push   $0x0
  801860:	53                   	push   %ebx
  801861:	6a 00                	push   $0x0
  801863:	e8 f3 f8 ff ff       	call   80115b <ipc_recv>
}
  801868:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186b:	5b                   	pop    %ebx
  80186c:	5e                   	pop    %esi
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 40 0c             	mov    0xc(%eax),%eax
  80187b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801880:	8b 45 0c             	mov    0xc(%ebp),%eax
  801883:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801888:	ba 00 00 00 00       	mov    $0x0,%edx
  80188d:	b8 02 00 00 00       	mov    $0x2,%eax
  801892:	e8 8d ff ff ff       	call   801824 <fsipc>
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b4:	e8 6b ff ff ff       	call   801824 <fsipc>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 04             	sub    $0x4,%esp
  8018c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018da:	e8 45 ff ff ff       	call   801824 <fsipc>
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 2c                	js     80190f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	68 00 50 80 00       	push   $0x805000
  8018eb:	53                   	push   %ebx
  8018ec:	e8 44 ef ff ff       	call   800835 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018fc:	a1 84 50 80 00       	mov    0x805084,%eax
  801901:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80191d:	8b 55 08             	mov    0x8(%ebp),%edx
  801920:	8b 52 0c             	mov    0xc(%edx),%edx
  801923:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801929:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80192e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801933:	0f 47 c2             	cmova  %edx,%eax
  801936:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80193b:	50                   	push   %eax
  80193c:	ff 75 0c             	pushl  0xc(%ebp)
  80193f:	68 08 50 80 00       	push   $0x805008
  801944:	e8 7e f0 ff ff       	call   8009c7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801949:	ba 00 00 00 00       	mov    $0x0,%edx
  80194e:	b8 04 00 00 00       	mov    $0x4,%eax
  801953:	e8 cc fe ff ff       	call   801824 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	56                   	push   %esi
  80195e:	53                   	push   %ebx
  80195f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	8b 40 0c             	mov    0xc(%eax),%eax
  801968:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80196d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801973:	ba 00 00 00 00       	mov    $0x0,%edx
  801978:	b8 03 00 00 00       	mov    $0x3,%eax
  80197d:	e8 a2 fe ff ff       	call   801824 <fsipc>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	85 c0                	test   %eax,%eax
  801986:	78 4b                	js     8019d3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801988:	39 c6                	cmp    %eax,%esi
  80198a:	73 16                	jae    8019a2 <devfile_read+0x48>
  80198c:	68 ec 27 80 00       	push   $0x8027ec
  801991:	68 f3 27 80 00       	push   $0x8027f3
  801996:	6a 7c                	push   $0x7c
  801998:	68 08 28 80 00       	push   $0x802808
  80199d:	e8 bd 05 00 00       	call   801f5f <_panic>
	assert(r <= PGSIZE);
  8019a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a7:	7e 16                	jle    8019bf <devfile_read+0x65>
  8019a9:	68 13 28 80 00       	push   $0x802813
  8019ae:	68 f3 27 80 00       	push   $0x8027f3
  8019b3:	6a 7d                	push   $0x7d
  8019b5:	68 08 28 80 00       	push   $0x802808
  8019ba:	e8 a0 05 00 00       	call   801f5f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019bf:	83 ec 04             	sub    $0x4,%esp
  8019c2:	50                   	push   %eax
  8019c3:	68 00 50 80 00       	push   $0x805000
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	e8 f7 ef ff ff       	call   8009c7 <memmove>
	return r;
  8019d0:	83 c4 10             	add    $0x10,%esp
}
  8019d3:	89 d8                	mov    %ebx,%eax
  8019d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 20             	sub    $0x20,%esp
  8019e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e6:	53                   	push   %ebx
  8019e7:	e8 10 ee ff ff       	call   8007fc <strlen>
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f4:	7f 67                	jg     801a5d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fc:	50                   	push   %eax
  8019fd:	e8 9a f8 ff ff       	call   80129c <fd_alloc>
  801a02:	83 c4 10             	add    $0x10,%esp
		return r;
  801a05:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 57                	js     801a62 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	53                   	push   %ebx
  801a0f:	68 00 50 80 00       	push   $0x805000
  801a14:	e8 1c ee ff ff       	call   800835 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a24:	b8 01 00 00 00       	mov    $0x1,%eax
  801a29:	e8 f6 fd ff ff       	call   801824 <fsipc>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	79 14                	jns    801a4b <open+0x6f>
		fd_close(fd, 0);
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	6a 00                	push   $0x0
  801a3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3f:	e8 50 f9 ff ff       	call   801394 <fd_close>
		return r;
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	89 da                	mov    %ebx,%edx
  801a49:	eb 17                	jmp    801a62 <open+0x86>
	}

	return fd2num(fd);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a51:	e8 1f f8 ff ff       	call   801275 <fd2num>
  801a56:	89 c2                	mov    %eax,%edx
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	eb 05                	jmp    801a62 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a5d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a62:	89 d0                	mov    %edx,%eax
  801a64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a74:	b8 08 00 00 00       	mov    $0x8,%eax
  801a79:	e8 a6 fd ff ff       	call   801824 <fsipc>
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 08             	pushl  0x8(%ebp)
  801a8e:	e8 f2 f7 ff ff       	call   801285 <fd2data>
  801a93:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a95:	83 c4 08             	add    $0x8,%esp
  801a98:	68 1f 28 80 00       	push   $0x80281f
  801a9d:	53                   	push   %ebx
  801a9e:	e8 92 ed ff ff       	call   800835 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa3:	8b 46 04             	mov    0x4(%esi),%eax
  801aa6:	2b 06                	sub    (%esi),%eax
  801aa8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab5:	00 00 00 
	stat->st_dev = &devpipe;
  801ab8:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801abf:	30 80 00 
	return 0;
}
  801ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 0c             	sub    $0xc,%esp
  801ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ad8:	53                   	push   %ebx
  801ad9:	6a 00                	push   $0x0
  801adb:	e8 dd f1 ff ff       	call   800cbd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae0:	89 1c 24             	mov    %ebx,(%esp)
  801ae3:	e8 9d f7 ff ff       	call   801285 <fd2data>
  801ae8:	83 c4 08             	add    $0x8,%esp
  801aeb:	50                   	push   %eax
  801aec:	6a 00                	push   $0x0
  801aee:	e8 ca f1 ff ff       	call   800cbd <sys_page_unmap>
}
  801af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	57                   	push   %edi
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	83 ec 1c             	sub    $0x1c,%esp
  801b01:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b04:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b06:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0b:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b0e:	83 ec 0c             	sub    $0xc,%esp
  801b11:	ff 75 e0             	pushl  -0x20(%ebp)
  801b14:	e8 1b 05 00 00       	call   802034 <pageref>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	89 3c 24             	mov    %edi,(%esp)
  801b1e:	e8 11 05 00 00       	call   802034 <pageref>
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	39 c3                	cmp    %eax,%ebx
  801b28:	0f 94 c1             	sete   %cl
  801b2b:	0f b6 c9             	movzbl %cl,%ecx
  801b2e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b31:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b37:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801b3a:	39 ce                	cmp    %ecx,%esi
  801b3c:	74 1b                	je     801b59 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b3e:	39 c3                	cmp    %eax,%ebx
  801b40:	75 c4                	jne    801b06 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b42:	8b 42 64             	mov    0x64(%edx),%eax
  801b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b48:	50                   	push   %eax
  801b49:	56                   	push   %esi
  801b4a:	68 26 28 80 00       	push   $0x802826
  801b4f:	e8 5c e7 ff ff       	call   8002b0 <cprintf>
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	eb ad                	jmp    801b06 <_pipeisclosed+0xe>
	}
}
  801b59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5f                   	pop    %edi
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	57                   	push   %edi
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	83 ec 28             	sub    $0x28,%esp
  801b6d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b70:	56                   	push   %esi
  801b71:	e8 0f f7 ff ff       	call   801285 <fd2data>
  801b76:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b80:	eb 4b                	jmp    801bcd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b82:	89 da                	mov    %ebx,%edx
  801b84:	89 f0                	mov    %esi,%eax
  801b86:	e8 6d ff ff ff       	call   801af8 <_pipeisclosed>
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	75 48                	jne    801bd7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b8f:	e8 85 f0 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b94:	8b 43 04             	mov    0x4(%ebx),%eax
  801b97:	8b 0b                	mov    (%ebx),%ecx
  801b99:	8d 51 20             	lea    0x20(%ecx),%edx
  801b9c:	39 d0                	cmp    %edx,%eax
  801b9e:	73 e2                	jae    801b82 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ba7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	c1 fa 1f             	sar    $0x1f,%edx
  801baf:	89 d1                	mov    %edx,%ecx
  801bb1:	c1 e9 1b             	shr    $0x1b,%ecx
  801bb4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bb7:	83 e2 1f             	and    $0x1f,%edx
  801bba:	29 ca                	sub    %ecx,%edx
  801bbc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bc0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bc4:	83 c0 01             	add    $0x1,%eax
  801bc7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bca:	83 c7 01             	add    $0x1,%edi
  801bcd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bd0:	75 c2                	jne    801b94 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bd2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd5:	eb 05                	jmp    801bdc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdf:	5b                   	pop    %ebx
  801be0:	5e                   	pop    %esi
  801be1:	5f                   	pop    %edi
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    

00801be4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	57                   	push   %edi
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	83 ec 18             	sub    $0x18,%esp
  801bed:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bf0:	57                   	push   %edi
  801bf1:	e8 8f f6 ff ff       	call   801285 <fd2data>
  801bf6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c00:	eb 3d                	jmp    801c3f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c02:	85 db                	test   %ebx,%ebx
  801c04:	74 04                	je     801c0a <devpipe_read+0x26>
				return i;
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	eb 44                	jmp    801c4e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c0a:	89 f2                	mov    %esi,%edx
  801c0c:	89 f8                	mov    %edi,%eax
  801c0e:	e8 e5 fe ff ff       	call   801af8 <_pipeisclosed>
  801c13:	85 c0                	test   %eax,%eax
  801c15:	75 32                	jne    801c49 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c17:	e8 fd ef ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c1c:	8b 06                	mov    (%esi),%eax
  801c1e:	3b 46 04             	cmp    0x4(%esi),%eax
  801c21:	74 df                	je     801c02 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c23:	99                   	cltd   
  801c24:	c1 ea 1b             	shr    $0x1b,%edx
  801c27:	01 d0                	add    %edx,%eax
  801c29:	83 e0 1f             	and    $0x1f,%eax
  801c2c:	29 d0                	sub    %edx,%eax
  801c2e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c36:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c39:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3c:	83 c3 01             	add    $0x1,%ebx
  801c3f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c42:	75 d8                	jne    801c1c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c44:	8b 45 10             	mov    0x10(%ebp),%eax
  801c47:	eb 05                	jmp    801c4e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	e8 35 f6 ff ff       	call   80129c <fd_alloc>
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	89 c2                	mov    %eax,%edx
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	0f 88 2c 01 00 00    	js     801da0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c74:	83 ec 04             	sub    $0x4,%esp
  801c77:	68 07 04 00 00       	push   $0x407
  801c7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 b2 ef ff ff       	call   800c38 <sys_page_alloc>
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	89 c2                	mov    %eax,%edx
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	0f 88 0d 01 00 00    	js     801da0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c99:	50                   	push   %eax
  801c9a:	e8 fd f5 ff ff       	call   80129c <fd_alloc>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	0f 88 e2 00 00 00    	js     801d8e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cac:	83 ec 04             	sub    $0x4,%esp
  801caf:	68 07 04 00 00       	push   $0x407
  801cb4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 7a ef ff ff       	call   800c38 <sys_page_alloc>
  801cbe:	89 c3                	mov    %eax,%ebx
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 88 c3 00 00 00    	js     801d8e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd1:	e8 af f5 ff ff       	call   801285 <fd2data>
  801cd6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd8:	83 c4 0c             	add    $0xc,%esp
  801cdb:	68 07 04 00 00       	push   $0x407
  801ce0:	50                   	push   %eax
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 50 ef ff ff       	call   800c38 <sys_page_alloc>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	0f 88 89 00 00 00    	js     801d7e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfb:	e8 85 f5 ff ff       	call   801285 <fd2data>
  801d00:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d07:	50                   	push   %eax
  801d08:	6a 00                	push   $0x0
  801d0a:	56                   	push   %esi
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 69 ef ff ff       	call   800c7b <sys_page_map>
  801d12:	89 c3                	mov    %eax,%ebx
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 55                	js     801d70 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d1b:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d24:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d30:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d39:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d45:	83 ec 0c             	sub    $0xc,%esp
  801d48:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4b:	e8 25 f5 ff ff       	call   801275 <fd2num>
  801d50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d53:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d55:	83 c4 04             	add    $0x4,%esp
  801d58:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5b:	e8 15 f5 ff ff       	call   801275 <fd2num>
  801d60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d63:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	ba 00 00 00 00       	mov    $0x0,%edx
  801d6e:	eb 30                	jmp    801da0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d70:	83 ec 08             	sub    $0x8,%esp
  801d73:	56                   	push   %esi
  801d74:	6a 00                	push   $0x0
  801d76:	e8 42 ef ff ff       	call   800cbd <sys_page_unmap>
  801d7b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d7e:	83 ec 08             	sub    $0x8,%esp
  801d81:	ff 75 f0             	pushl  -0x10(%ebp)
  801d84:	6a 00                	push   $0x0
  801d86:	e8 32 ef ff ff       	call   800cbd <sys_page_unmap>
  801d8b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d8e:	83 ec 08             	sub    $0x8,%esp
  801d91:	ff 75 f4             	pushl  -0xc(%ebp)
  801d94:	6a 00                	push   $0x0
  801d96:	e8 22 ef ff ff       	call   800cbd <sys_page_unmap>
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801da0:	89 d0                	mov    %edx,%eax
  801da2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801daf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db2:	50                   	push   %eax
  801db3:	ff 75 08             	pushl  0x8(%ebp)
  801db6:	e8 30 f5 ff ff       	call   8012eb <fd_lookup>
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	78 18                	js     801dda <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc8:	e8 b8 f4 ff ff       	call   801285 <fd2data>
	return _pipeisclosed(fd, p);
  801dcd:	89 c2                	mov    %eax,%edx
  801dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd2:	e8 21 fd ff ff       	call   801af8 <_pipeisclosed>
  801dd7:	83 c4 10             	add    $0x10,%esp
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ddf:	b8 00 00 00 00       	mov    $0x0,%eax
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dec:	68 3e 28 80 00       	push   $0x80283e
  801df1:	ff 75 0c             	pushl  0xc(%ebp)
  801df4:	e8 3c ea ff ff       	call   800835 <strcpy>
	return 0;
}
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	57                   	push   %edi
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e11:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e17:	eb 2d                	jmp    801e46 <devcons_write+0x46>
		m = n - tot;
  801e19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e1c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e1e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e21:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e26:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e29:	83 ec 04             	sub    $0x4,%esp
  801e2c:	53                   	push   %ebx
  801e2d:	03 45 0c             	add    0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	57                   	push   %edi
  801e32:	e8 90 eb ff ff       	call   8009c7 <memmove>
		sys_cputs(buf, m);
  801e37:	83 c4 08             	add    $0x8,%esp
  801e3a:	53                   	push   %ebx
  801e3b:	57                   	push   %edi
  801e3c:	e8 3b ed ff ff       	call   800b7c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e41:	01 de                	add    %ebx,%esi
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	89 f0                	mov    %esi,%eax
  801e48:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e4b:	72 cc                	jb     801e19 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    

00801e55 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 08             	sub    $0x8,%esp
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e64:	74 2a                	je     801e90 <devcons_read+0x3b>
  801e66:	eb 05                	jmp    801e6d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e68:	e8 ac ed ff ff       	call   800c19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e6d:	e8 28 ed ff ff       	call   800b9a <sys_cgetc>
  801e72:	85 c0                	test   %eax,%eax
  801e74:	74 f2                	je     801e68 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 16                	js     801e90 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e7a:	83 f8 04             	cmp    $0x4,%eax
  801e7d:	74 0c                	je     801e8b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e82:	88 02                	mov    %al,(%edx)
	return 1;
  801e84:	b8 01 00 00 00       	mov    $0x1,%eax
  801e89:	eb 05                	jmp    801e90 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e8b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e90:	c9                   	leave  
  801e91:	c3                   	ret    

00801e92 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e98:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e9e:	6a 01                	push   $0x1
  801ea0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	e8 d3 ec ff ff       	call   800b7c <sys_cputs>
}
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <getchar>:

int
getchar(void)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eb4:	6a 01                	push   $0x1
  801eb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	6a 00                	push   $0x0
  801ebc:	e8 90 f6 ff ff       	call   801551 <read>
	if (r < 0)
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 0f                	js     801ed7 <getchar+0x29>
		return r;
	if (r < 1)
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	7e 06                	jle    801ed2 <getchar+0x24>
		return -E_EOF;
	return c;
  801ecc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ed0:	eb 05                	jmp    801ed7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ed2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee2:	50                   	push   %eax
  801ee3:	ff 75 08             	pushl  0x8(%ebp)
  801ee6:	e8 00 f4 ff ff       	call   8012eb <fd_lookup>
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 11                	js     801f03 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801efb:	39 10                	cmp    %edx,(%eax)
  801efd:	0f 94 c0             	sete   %al
  801f00:	0f b6 c0             	movzbl %al,%eax
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <opencons>:

int
opencons(void)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0e:	50                   	push   %eax
  801f0f:	e8 88 f3 ff ff       	call   80129c <fd_alloc>
  801f14:	83 c4 10             	add    $0x10,%esp
		return r;
  801f17:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 3e                	js     801f5b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1d:	83 ec 04             	sub    $0x4,%esp
  801f20:	68 07 04 00 00       	push   $0x407
  801f25:	ff 75 f4             	pushl  -0xc(%ebp)
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 09 ed ff ff       	call   800c38 <sys_page_alloc>
  801f2f:	83 c4 10             	add    $0x10,%esp
		return r;
  801f32:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f34:	85 c0                	test   %eax,%eax
  801f36:	78 23                	js     801f5b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f38:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f41:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f46:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f4d:	83 ec 0c             	sub    $0xc,%esp
  801f50:	50                   	push   %eax
  801f51:	e8 1f f3 ff ff       	call   801275 <fd2num>
  801f56:	89 c2                	mov    %eax,%edx
  801f58:	83 c4 10             	add    $0x10,%esp
}
  801f5b:	89 d0                	mov    %edx,%eax
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    

00801f5f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f64:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f67:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f6d:	e8 88 ec ff ff       	call   800bfa <sys_getenvid>
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	ff 75 08             	pushl  0x8(%ebp)
  801f7b:	56                   	push   %esi
  801f7c:	50                   	push   %eax
  801f7d:	68 4c 28 80 00       	push   $0x80284c
  801f82:	e8 29 e3 ff ff       	call   8002b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f87:	83 c4 18             	add    $0x18,%esp
  801f8a:	53                   	push   %ebx
  801f8b:	ff 75 10             	pushl  0x10(%ebp)
  801f8e:	e8 cc e2 ff ff       	call   80025f <vcprintf>
	cprintf("\n");
  801f93:	c7 04 24 37 28 80 00 	movl   $0x802837,(%esp)
  801f9a:	e8 11 e3 ff ff       	call   8002b0 <cprintf>
  801f9f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fa2:	cc                   	int3   
  801fa3:	eb fd                	jmp    801fa2 <_panic+0x43>

00801fa5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fab:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb2:	75 2a                	jne    801fde <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fb4:	83 ec 04             	sub    $0x4,%esp
  801fb7:	6a 07                	push   $0x7
  801fb9:	68 00 f0 bf ee       	push   $0xeebff000
  801fbe:	6a 00                	push   $0x0
  801fc0:	e8 73 ec ff ff       	call   800c38 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	79 12                	jns    801fde <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fcc:	50                   	push   %eax
  801fcd:	68 70 28 80 00       	push   $0x802870
  801fd2:	6a 23                	push   $0x23
  801fd4:	68 74 28 80 00       	push   $0x802874
  801fd9:	e8 81 ff ff ff       	call   801f5f <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fde:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe1:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fe6:	83 ec 08             	sub    $0x8,%esp
  801fe9:	68 10 20 80 00       	push   $0x802010
  801fee:	6a 00                	push   $0x0
  801ff0:	e8 8e ed ff ff       	call   800d83 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	79 12                	jns    80200e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ffc:	50                   	push   %eax
  801ffd:	68 70 28 80 00       	push   $0x802870
  802002:	6a 2c                	push   $0x2c
  802004:	68 74 28 80 00       	push   $0x802874
  802009:	e8 51 ff ff ff       	call   801f5f <_panic>
	}
}
  80200e:	c9                   	leave  
  80200f:	c3                   	ret    

00802010 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802010:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802011:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802016:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802018:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80201b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80201f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802024:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802028:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80202a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80202d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80202e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802031:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802032:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802033:	c3                   	ret    

00802034 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203a:	89 d0                	mov    %edx,%eax
  80203c:	c1 e8 16             	shr    $0x16,%eax
  80203f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802046:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204b:	f6 c1 01             	test   $0x1,%cl
  80204e:	74 1d                	je     80206d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802050:	c1 ea 0c             	shr    $0xc,%edx
  802053:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205a:	f6 c2 01             	test   $0x1,%dl
  80205d:	74 0e                	je     80206d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205f:	c1 ea 0c             	shr    $0xc,%edx
  802062:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802069:	ef 
  80206a:	0f b7 c0             	movzwl %ax,%eax
}
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
