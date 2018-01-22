
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
  800039:	e8 1d 0f 00 00       	call   800f5b <fork>
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
  800057:	e8 11 11 00 00       	call   80116d <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 20 23 80 00       	push   $0x802320
  80006c:	e8 7b 02 00 00       	call   8002ec <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 b9 07 00 00       	call   800838 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 ae 08 00 00       	call   800941 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 34 23 80 00       	push   $0x802334
  8000a2:	e8 45 02 00 00       	call   8002ec <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 80 07 00 00       	call   800838 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 9c 09 00 00       	call   800a6b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 02 11 00 00       	call   8011e2 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 50             	mov    0x50(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 74 0b 00 00       	call   800c74 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 2a 07 00 00       	call   800838 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 46 09 00 00       	call   800a6b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 ac 10 00 00       	call   8011e2 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 24 10 00 00       	call   80116d <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 20 23 80 00       	push   $0x802320
  800159:	e8 8e 01 00 00       	call   8002ec <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 cc 06 00 00       	call   800838 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 c1 07 00 00       	call   800941 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 54 23 80 00       	push   $0x802354
  80018f:	e8 58 01 00 00       	call   8002ec <cprintf>
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
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001a2:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001a9:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001ac:	e8 85 0a 00 00       	call   800c36 <sys_getenvid>
  8001b1:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8001b3:	83 ec 08             	sub    $0x8,%esp
  8001b6:	50                   	push   %eax
  8001b7:	68 c4 23 80 00       	push   $0x8023c4
  8001bc:	e8 2b 01 00 00       	call   8002ec <cprintf>
  8001c1:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8001c7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8001d9:	89 c1                	mov    %eax,%ecx
  8001db:	c1 e1 07             	shl    $0x7,%ecx
  8001de:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8001e5:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8001e8:	39 cb                	cmp    %ecx,%ebx
  8001ea:	0f 44 fa             	cmove  %edx,%edi
  8001ed:	b9 01 00 00 00       	mov    $0x1,%ecx
  8001f2:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001f5:	83 c0 01             	add    $0x1,%eax
  8001f8:	81 c2 84 00 00 00    	add    $0x84,%edx
  8001fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  800203:	75 d4                	jne    8001d9 <libmain+0x40>
  800205:	89 f0                	mov    %esi,%eax
  800207:	84 c0                	test   %al,%al
  800209:	74 06                	je     800211 <libmain+0x78>
  80020b:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800211:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800215:	7e 0a                	jle    800221 <libmain+0x88>
		binaryname = argv[0];
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021a:	8b 00                	mov    (%eax),%eax
  80021c:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	ff 75 0c             	pushl  0xc(%ebp)
  800227:	ff 75 08             	pushl  0x8(%ebp)
  80022a:	e8 04 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80022f:	e8 0b 00 00 00       	call   80023f <exit>
}
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5e                   	pop    %esi
  80023c:	5f                   	pop    %edi
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    

0080023f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800245:	e8 05 12 00 00       	call   80144f <close_all>
	sys_env_destroy(0);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	6a 00                	push   $0x0
  80024f:	e8 a1 09 00 00       	call   800bf5 <sys_env_destroy>
}
  800254:	83 c4 10             	add    $0x10,%esp
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	53                   	push   %ebx
  80025d:	83 ec 04             	sub    $0x4,%esp
  800260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800263:	8b 13                	mov    (%ebx),%edx
  800265:	8d 42 01             	lea    0x1(%edx),%eax
  800268:	89 03                	mov    %eax,(%ebx)
  80026a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800271:	3d ff 00 00 00       	cmp    $0xff,%eax
  800276:	75 1a                	jne    800292 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	68 ff 00 00 00       	push   $0xff
  800280:	8d 43 08             	lea    0x8(%ebx),%eax
  800283:	50                   	push   %eax
  800284:	e8 2f 09 00 00       	call   800bb8 <sys_cputs>
		b->idx = 0;
  800289:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80028f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800292:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ab:	00 00 00 
	b.cnt = 0;
  8002ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b8:	ff 75 0c             	pushl  0xc(%ebp)
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c4:	50                   	push   %eax
  8002c5:	68 59 02 80 00       	push   $0x800259
  8002ca:	e8 54 01 00 00       	call   800423 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002cf:	83 c4 08             	add    $0x8,%esp
  8002d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002de:	50                   	push   %eax
  8002df:	e8 d4 08 00 00       	call   800bb8 <sys_cputs>

	return b.cnt;
}
  8002e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ea:	c9                   	leave  
  8002eb:	c3                   	ret    

008002ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f5:	50                   	push   %eax
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	e8 9d ff ff ff       	call   80029b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 1c             	sub    $0x1c,%esp
  800309:	89 c7                	mov    %eax,%edi
  80030b:	89 d6                	mov    %edx,%esi
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	8b 55 0c             	mov    0xc(%ebp),%edx
  800313:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800316:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800319:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80031c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800321:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800324:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800327:	39 d3                	cmp    %edx,%ebx
  800329:	72 05                	jb     800330 <printnum+0x30>
  80032b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80032e:	77 45                	ja     800375 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	ff 75 18             	pushl  0x18(%ebp)
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	83 ec 08             	sub    $0x8,%esp
  800343:	ff 75 e4             	pushl  -0x1c(%ebp)
  800346:	ff 75 e0             	pushl  -0x20(%ebp)
  800349:	ff 75 dc             	pushl  -0x24(%ebp)
  80034c:	ff 75 d8             	pushl  -0x28(%ebp)
  80034f:	e8 2c 1d 00 00       	call   802080 <__udivdi3>
  800354:	83 c4 18             	add    $0x18,%esp
  800357:	52                   	push   %edx
  800358:	50                   	push   %eax
  800359:	89 f2                	mov    %esi,%edx
  80035b:	89 f8                	mov    %edi,%eax
  80035d:	e8 9e ff ff ff       	call   800300 <printnum>
  800362:	83 c4 20             	add    $0x20,%esp
  800365:	eb 18                	jmp    80037f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	56                   	push   %esi
  80036b:	ff 75 18             	pushl  0x18(%ebp)
  80036e:	ff d7                	call   *%edi
  800370:	83 c4 10             	add    $0x10,%esp
  800373:	eb 03                	jmp    800378 <printnum+0x78>
  800375:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800378:	83 eb 01             	sub    $0x1,%ebx
  80037b:	85 db                	test   %ebx,%ebx
  80037d:	7f e8                	jg     800367 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	56                   	push   %esi
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	ff 75 e4             	pushl  -0x1c(%ebp)
  800389:	ff 75 e0             	pushl  -0x20(%ebp)
  80038c:	ff 75 dc             	pushl  -0x24(%ebp)
  80038f:	ff 75 d8             	pushl  -0x28(%ebp)
  800392:	e8 19 1e 00 00       	call   8021b0 <__umoddi3>
  800397:	83 c4 14             	add    $0x14,%esp
  80039a:	0f be 80 ed 23 80 00 	movsbl 0x8023ed(%eax),%eax
  8003a1:	50                   	push   %eax
  8003a2:	ff d7                	call   *%edi
}
  8003a4:	83 c4 10             	add    $0x10,%esp
  8003a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7e 0e                	jle    8003c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bc:	89 08                	mov    %ecx,(%eax)
  8003be:	8b 02                	mov    (%edx),%eax
  8003c0:	8b 52 04             	mov    0x4(%edx),%edx
  8003c3:	eb 22                	jmp    8003e7 <getuint+0x38>
	else if (lflag)
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 10                	je     8003d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 02                	mov    (%edx),%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 0e                	jmp    8003e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f8:	73 0a                	jae    800404 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	88 02                	mov    %al,(%edx)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	50                   	push   %eax
  800410:	ff 75 10             	pushl  0x10(%ebp)
  800413:	ff 75 0c             	pushl  0xc(%ebp)
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	e8 05 00 00 00       	call   800423 <vprintfmt>
	va_end(ap);
}
  80041e:	83 c4 10             	add    $0x10,%esp
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	57                   	push   %edi
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 2c             	sub    $0x2c,%esp
  80042c:	8b 75 08             	mov    0x8(%ebp),%esi
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800432:	8b 7d 10             	mov    0x10(%ebp),%edi
  800435:	eb 12                	jmp    800449 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800437:	85 c0                	test   %eax,%eax
  800439:	0f 84 89 03 00 00    	je     8007c8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	53                   	push   %ebx
  800443:	50                   	push   %eax
  800444:	ff d6                	call   *%esi
  800446:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	83 c7 01             	add    $0x1,%edi
  80044c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800450:	83 f8 25             	cmp    $0x25,%eax
  800453:	75 e2                	jne    800437 <vprintfmt+0x14>
  800455:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800459:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800460:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800467:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	eb 07                	jmp    80047c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800478:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8d 47 01             	lea    0x1(%edi),%eax
  80047f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800482:	0f b6 07             	movzbl (%edi),%eax
  800485:	0f b6 c8             	movzbl %al,%ecx
  800488:	83 e8 23             	sub    $0x23,%eax
  80048b:	3c 55                	cmp    $0x55,%al
  80048d:	0f 87 1a 03 00 00    	ja     8007ad <vprintfmt+0x38a>
  800493:	0f b6 c0             	movzbl %al,%eax
  800496:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a4:	eb d6                	jmp    80047c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004b8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004bb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004be:	83 fa 09             	cmp    $0x9,%edx
  8004c1:	77 39                	ja     8004fc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c6:	eb e9                	jmp    8004b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d9:	eb 27                	jmp    800502 <vprintfmt+0xdf>
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e5:	0f 49 c8             	cmovns %eax,%ecx
  8004e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	eb 8c                	jmp    80047c <vprintfmt+0x59>
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004fa:	eb 80                	jmp    80047c <vprintfmt+0x59>
  8004fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ff:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800502:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800506:	0f 89 70 ff ff ff    	jns    80047c <vprintfmt+0x59>
				width = precision, precision = -1;
  80050c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800512:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800519:	e9 5e ff ff ff       	jmp    80047c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800524:	e9 53 ff ff ff       	jmp    80047c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 50 04             	lea    0x4(%eax),%edx
  80052f:	89 55 14             	mov    %edx,0x14(%ebp)
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	ff 30                	pushl  (%eax)
  800538:	ff d6                	call   *%esi
			break;
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800540:	e9 04 ff ff ff       	jmp    800449 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	99                   	cltd   
  800551:	31 d0                	xor    %edx,%eax
  800553:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800555:	83 f8 0f             	cmp    $0xf,%eax
  800558:	7f 0b                	jg     800565 <vprintfmt+0x142>
  80055a:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	75 18                	jne    80057d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800565:	50                   	push   %eax
  800566:	68 05 24 80 00       	push   $0x802405
  80056b:	53                   	push   %ebx
  80056c:	56                   	push   %esi
  80056d:	e8 94 fe ff ff       	call   800406 <printfmt>
  800572:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800578:	e9 cc fe ff ff       	jmp    800449 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057d:	52                   	push   %edx
  80057e:	68 45 28 80 00       	push   $0x802845
  800583:	53                   	push   %ebx
  800584:	56                   	push   %esi
  800585:	e8 7c fe ff ff       	call   800406 <printfmt>
  80058a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800590:	e9 b4 fe ff ff       	jmp    800449 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	b8 fe 23 80 00       	mov    $0x8023fe,%eax
  8005a7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ae:	0f 8e 94 00 00 00    	jle    800648 <vprintfmt+0x225>
  8005b4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b8:	0f 84 98 00 00 00    	je     800656 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c4:	57                   	push   %edi
  8005c5:	e8 86 02 00 00       	call   800850 <strnlen>
  8005ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005cd:	29 c1                	sub    %eax,%ecx
  8005cf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005df:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	eb 0f                	jmp    8005f2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ea:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ec:	83 ef 01             	sub    $0x1,%edi
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	7f ed                	jg     8005e3 <vprintfmt+0x1c0>
  8005f6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005fc:	85 c9                	test   %ecx,%ecx
  8005fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800603:	0f 49 c1             	cmovns %ecx,%eax
  800606:	29 c1                	sub    %eax,%ecx
  800608:	89 75 08             	mov    %esi,0x8(%ebp)
  80060b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80060e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800611:	89 cb                	mov    %ecx,%ebx
  800613:	eb 4d                	jmp    800662 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800615:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800619:	74 1b                	je     800636 <vprintfmt+0x213>
  80061b:	0f be c0             	movsbl %al,%eax
  80061e:	83 e8 20             	sub    $0x20,%eax
  800621:	83 f8 5e             	cmp    $0x5e,%eax
  800624:	76 10                	jbe    800636 <vprintfmt+0x213>
					putch('?', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	ff 75 0c             	pushl  0xc(%ebp)
  80062c:	6a 3f                	push   $0x3f
  80062e:	ff 55 08             	call   *0x8(%ebp)
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb 0d                	jmp    800643 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	ff 75 0c             	pushl  0xc(%ebp)
  80063c:	52                   	push   %edx
  80063d:	ff 55 08             	call   *0x8(%ebp)
  800640:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800643:	83 eb 01             	sub    $0x1,%ebx
  800646:	eb 1a                	jmp    800662 <vprintfmt+0x23f>
  800648:	89 75 08             	mov    %esi,0x8(%ebp)
  80064b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80064e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800651:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800654:	eb 0c                	jmp    800662 <vprintfmt+0x23f>
  800656:	89 75 08             	mov    %esi,0x8(%ebp)
  800659:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800662:	83 c7 01             	add    $0x1,%edi
  800665:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800669:	0f be d0             	movsbl %al,%edx
  80066c:	85 d2                	test   %edx,%edx
  80066e:	74 23                	je     800693 <vprintfmt+0x270>
  800670:	85 f6                	test   %esi,%esi
  800672:	78 a1                	js     800615 <vprintfmt+0x1f2>
  800674:	83 ee 01             	sub    $0x1,%esi
  800677:	79 9c                	jns    800615 <vprintfmt+0x1f2>
  800679:	89 df                	mov    %ebx,%edi
  80067b:	8b 75 08             	mov    0x8(%ebp),%esi
  80067e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800681:	eb 18                	jmp    80069b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	6a 20                	push   $0x20
  800689:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068b:	83 ef 01             	sub    $0x1,%edi
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb 08                	jmp    80069b <vprintfmt+0x278>
  800693:	89 df                	mov    %ebx,%edi
  800695:	8b 75 08             	mov    0x8(%ebp),%esi
  800698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069b:	85 ff                	test   %edi,%edi
  80069d:	7f e4                	jg     800683 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 a2 fd ff ff       	jmp    800449 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a7:	83 fa 01             	cmp    $0x1,%edx
  8006aa:	7e 16                	jle    8006c2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 08             	lea    0x8(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 50 04             	mov    0x4(%eax),%edx
  8006b8:	8b 00                	mov    (%eax),%eax
  8006ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c0:	eb 32                	jmp    8006f4 <vprintfmt+0x2d1>
	else if (lflag)
  8006c2:	85 d2                	test   %edx,%edx
  8006c4:	74 18                	je     8006de <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d4:	89 c1                	mov    %eax,%ecx
  8006d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006dc:	eb 16                	jmp    8006f4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 c1                	mov    %eax,%ecx
  8006ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800703:	79 74                	jns    800779 <vprintfmt+0x356>
				putch('-', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 2d                	push   $0x2d
  80070b:	ff d6                	call   *%esi
				num = -(long long) num;
  80070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800710:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800713:	f7 d8                	neg    %eax
  800715:	83 d2 00             	adc    $0x0,%edx
  800718:	f7 da                	neg    %edx
  80071a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800722:	eb 55                	jmp    800779 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800724:	8d 45 14             	lea    0x14(%ebp),%eax
  800727:	e8 83 fc ff ff       	call   8003af <getuint>
			base = 10;
  80072c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800731:	eb 46                	jmp    800779 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 74 fc ff ff       	call   8003af <getuint>
			base = 8;
  80073b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800740:	eb 37                	jmp    800779 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	53                   	push   %ebx
  800746:	6a 30                	push   $0x30
  800748:	ff d6                	call   *%esi
			putch('x', putdat);
  80074a:	83 c4 08             	add    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 78                	push   $0x78
  800750:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8d 50 04             	lea    0x4(%eax),%edx
  800758:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075b:	8b 00                	mov    (%eax),%eax
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800762:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800765:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076a:	eb 0d                	jmp    800779 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
  80076f:	e8 3b fc ff ff       	call   8003af <getuint>
			base = 16;
  800774:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800779:	83 ec 0c             	sub    $0xc,%esp
  80077c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800780:	57                   	push   %edi
  800781:	ff 75 e0             	pushl  -0x20(%ebp)
  800784:	51                   	push   %ecx
  800785:	52                   	push   %edx
  800786:	50                   	push   %eax
  800787:	89 da                	mov    %ebx,%edx
  800789:	89 f0                	mov    %esi,%eax
  80078b:	e8 70 fb ff ff       	call   800300 <printnum>
			break;
  800790:	83 c4 20             	add    $0x20,%esp
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800796:	e9 ae fc ff ff       	jmp    800449 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	53                   	push   %ebx
  80079f:	51                   	push   %ecx
  8007a0:	ff d6                	call   *%esi
			break;
  8007a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a8:	e9 9c fc ff ff       	jmp    800449 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 25                	push   $0x25
  8007b3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb 03                	jmp    8007bd <vprintfmt+0x39a>
  8007ba:	83 ef 01             	sub    $0x1,%edi
  8007bd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c1:	75 f7                	jne    8007ba <vprintfmt+0x397>
  8007c3:	e9 81 fc ff ff       	jmp    800449 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5f                   	pop    %edi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 18             	sub    $0x18,%esp
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	74 26                	je     800817 <vsnprintf+0x47>
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	7e 22                	jle    800817 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f5:	ff 75 14             	pushl  0x14(%ebp)
  8007f8:	ff 75 10             	pushl  0x10(%ebp)
  8007fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007fe:	50                   	push   %eax
  8007ff:	68 e9 03 80 00       	push   $0x8003e9
  800804:	e8 1a fc ff ff       	call   800423 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800809:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	eb 05                	jmp    80081c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800817:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800824:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800827:	50                   	push   %eax
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	ff 75 08             	pushl  0x8(%ebp)
  800831:	e8 9a ff ff ff       	call   8007d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
  800843:	eb 03                	jmp    800848 <strlen+0x10>
		n++;
  800845:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800848:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084c:	75 f7                	jne    800845 <strlen+0xd>
		n++;
	return n;
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
  80085e:	eb 03                	jmp    800863 <strnlen+0x13>
		n++;
  800860:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	39 c2                	cmp    %eax,%edx
  800865:	74 08                	je     80086f <strnlen+0x1f>
  800867:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80086b:	75 f3                	jne    800860 <strnlen+0x10>
  80086d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800887:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088a:	84 db                	test   %bl,%bl
  80088c:	75 ef                	jne    80087d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800898:	53                   	push   %ebx
  800899:	e8 9a ff ff ff       	call   800838 <strlen>
  80089e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a1:	ff 75 0c             	pushl  0xc(%ebp)
  8008a4:	01 d8                	add    %ebx,%eax
  8008a6:	50                   	push   %eax
  8008a7:	e8 c5 ff ff ff       	call   800871 <strcpy>
	return dst;
}
  8008ac:	89 d8                	mov    %ebx,%eax
  8008ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008be:	89 f3                	mov    %esi,%ebx
  8008c0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c3:	89 f2                	mov    %esi,%edx
  8008c5:	eb 0f                	jmp    8008d6 <strncpy+0x23>
		*dst++ = *src;
  8008c7:	83 c2 01             	add    $0x1,%edx
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d6:	39 da                	cmp    %ebx,%edx
  8008d8:	75 ed                	jne    8008c7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008da:	89 f0                	mov    %esi,%eax
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	74 21                	je     800915 <strlcpy+0x35>
  8008f4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f8:	89 f2                	mov    %esi,%edx
  8008fa:	eb 09                	jmp    800905 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	83 c1 01             	add    $0x1,%ecx
  800902:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800905:	39 c2                	cmp    %eax,%edx
  800907:	74 09                	je     800912 <strlcpy+0x32>
  800909:	0f b6 19             	movzbl (%ecx),%ebx
  80090c:	84 db                	test   %bl,%bl
  80090e:	75 ec                	jne    8008fc <strlcpy+0x1c>
  800910:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800912:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800915:	29 f0                	sub    %esi,%eax
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800921:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800924:	eb 06                	jmp    80092c <strcmp+0x11>
		p++, q++;
  800926:	83 c1 01             	add    $0x1,%ecx
  800929:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092c:	0f b6 01             	movzbl (%ecx),%eax
  80092f:	84 c0                	test   %al,%al
  800931:	74 04                	je     800937 <strcmp+0x1c>
  800933:	3a 02                	cmp    (%edx),%al
  800935:	74 ef                	je     800926 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800937:	0f b6 c0             	movzbl %al,%eax
  80093a:	0f b6 12             	movzbl (%edx),%edx
  80093d:	29 d0                	sub    %edx,%eax
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094b:	89 c3                	mov    %eax,%ebx
  80094d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800950:	eb 06                	jmp    800958 <strncmp+0x17>
		n--, p++, q++;
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800958:	39 d8                	cmp    %ebx,%eax
  80095a:	74 15                	je     800971 <strncmp+0x30>
  80095c:	0f b6 08             	movzbl (%eax),%ecx
  80095f:	84 c9                	test   %cl,%cl
  800961:	74 04                	je     800967 <strncmp+0x26>
  800963:	3a 0a                	cmp    (%edx),%cl
  800965:	74 eb                	je     800952 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800967:	0f b6 00             	movzbl (%eax),%eax
  80096a:	0f b6 12             	movzbl (%edx),%edx
  80096d:	29 d0                	sub    %edx,%eax
  80096f:	eb 05                	jmp    800976 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800976:	5b                   	pop    %ebx
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800983:	eb 07                	jmp    80098c <strchr+0x13>
		if (*s == c)
  800985:	38 ca                	cmp    %cl,%dl
  800987:	74 0f                	je     800998 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	0f b6 10             	movzbl (%eax),%edx
  80098f:	84 d2                	test   %dl,%dl
  800991:	75 f2                	jne    800985 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a4:	eb 03                	jmp    8009a9 <strfind+0xf>
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	74 04                	je     8009b4 <strfind+0x1a>
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f2                	jne    8009a6 <strfind+0xc>
			break;
	return (char *) s;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c2:	85 c9                	test   %ecx,%ecx
  8009c4:	74 36                	je     8009fc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cc:	75 28                	jne    8009f6 <memset+0x40>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 23                	jne    8009f6 <memset+0x40>
		c &= 0xFF;
  8009d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d7:	89 d3                	mov    %edx,%ebx
  8009d9:	c1 e3 08             	shl    $0x8,%ebx
  8009dc:	89 d6                	mov    %edx,%esi
  8009de:	c1 e6 18             	shl    $0x18,%esi
  8009e1:	89 d0                	mov    %edx,%eax
  8009e3:	c1 e0 10             	shl    $0x10,%eax
  8009e6:	09 f0                	or     %esi,%eax
  8009e8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ea:	89 d8                	mov    %ebx,%eax
  8009ec:	09 d0                	or     %edx,%eax
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
  8009f1:	fc                   	cld    
  8009f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f4:	eb 06                	jmp    8009fc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	fc                   	cld    
  8009fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fc:	89 f8                	mov    %edi,%eax
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a11:	39 c6                	cmp    %eax,%esi
  800a13:	73 35                	jae    800a4a <memmove+0x47>
  800a15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a18:	39 d0                	cmp    %edx,%eax
  800a1a:	73 2e                	jae    800a4a <memmove+0x47>
		s += n;
		d += n;
  800a1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	89 d6                	mov    %edx,%esi
  800a21:	09 fe                	or     %edi,%esi
  800a23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a29:	75 13                	jne    800a3e <memmove+0x3b>
  800a2b:	f6 c1 03             	test   $0x3,%cl
  800a2e:	75 0e                	jne    800a3e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a30:	83 ef 04             	sub    $0x4,%edi
  800a33:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a36:	c1 e9 02             	shr    $0x2,%ecx
  800a39:	fd                   	std    
  800a3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3c:	eb 09                	jmp    800a47 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3e:	83 ef 01             	sub    $0x1,%edi
  800a41:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a44:	fd                   	std    
  800a45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a47:	fc                   	cld    
  800a48:	eb 1d                	jmp    800a67 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4a:	89 f2                	mov    %esi,%edx
  800a4c:	09 c2                	or     %eax,%edx
  800a4e:	f6 c2 03             	test   $0x3,%dl
  800a51:	75 0f                	jne    800a62 <memmove+0x5f>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0a                	jne    800a62 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a58:	c1 e9 02             	shr    $0x2,%ecx
  800a5b:	89 c7                	mov    %eax,%edi
  800a5d:	fc                   	cld    
  800a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a60:	eb 05                	jmp    800a67 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	fc                   	cld    
  800a65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a6e:	ff 75 10             	pushl  0x10(%ebp)
  800a71:	ff 75 0c             	pushl  0xc(%ebp)
  800a74:	ff 75 08             	pushl  0x8(%ebp)
  800a77:	e8 87 ff ff ff       	call   800a03 <memmove>
}
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8e:	eb 1a                	jmp    800aaa <memcmp+0x2c>
		if (*s1 != *s2)
  800a90:	0f b6 08             	movzbl (%eax),%ecx
  800a93:	0f b6 1a             	movzbl (%edx),%ebx
  800a96:	38 d9                	cmp    %bl,%cl
  800a98:	74 0a                	je     800aa4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9a:	0f b6 c1             	movzbl %cl,%eax
  800a9d:	0f b6 db             	movzbl %bl,%ebx
  800aa0:	29 d8                	sub    %ebx,%eax
  800aa2:	eb 0f                	jmp    800ab3 <memcmp+0x35>
		s1++, s2++;
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaa:	39 f0                	cmp    %esi,%eax
  800aac:	75 e2                	jne    800a90 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800abe:	89 c1                	mov    %eax,%ecx
  800ac0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac7:	eb 0a                	jmp    800ad3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac9:	0f b6 10             	movzbl (%eax),%edx
  800acc:	39 da                	cmp    %ebx,%edx
  800ace:	74 07                	je     800ad7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	39 c8                	cmp    %ecx,%eax
  800ad5:	72 f2                	jb     800ac9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae6:	eb 03                	jmp    800aeb <strtol+0x11>
		s++;
  800ae8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	0f b6 01             	movzbl (%ecx),%eax
  800aee:	3c 20                	cmp    $0x20,%al
  800af0:	74 f6                	je     800ae8 <strtol+0xe>
  800af2:	3c 09                	cmp    $0x9,%al
  800af4:	74 f2                	je     800ae8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af6:	3c 2b                	cmp    $0x2b,%al
  800af8:	75 0a                	jne    800b04 <strtol+0x2a>
		s++;
  800afa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afd:	bf 00 00 00 00       	mov    $0x0,%edi
  800b02:	eb 11                	jmp    800b15 <strtol+0x3b>
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b09:	3c 2d                	cmp    $0x2d,%al
  800b0b:	75 08                	jne    800b15 <strtol+0x3b>
		s++, neg = 1;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b15:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b1b:	75 15                	jne    800b32 <strtol+0x58>
  800b1d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b20:	75 10                	jne    800b32 <strtol+0x58>
  800b22:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b26:	75 7c                	jne    800ba4 <strtol+0xca>
		s += 2, base = 16;
  800b28:	83 c1 02             	add    $0x2,%ecx
  800b2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b30:	eb 16                	jmp    800b48 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b32:	85 db                	test   %ebx,%ebx
  800b34:	75 12                	jne    800b48 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b36:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3e:	75 08                	jne    800b48 <strtol+0x6e>
		s++, base = 8;
  800b40:	83 c1 01             	add    $0x1,%ecx
  800b43:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b50:	0f b6 11             	movzbl (%ecx),%edx
  800b53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b56:	89 f3                	mov    %esi,%ebx
  800b58:	80 fb 09             	cmp    $0x9,%bl
  800b5b:	77 08                	ja     800b65 <strtol+0x8b>
			dig = *s - '0';
  800b5d:	0f be d2             	movsbl %dl,%edx
  800b60:	83 ea 30             	sub    $0x30,%edx
  800b63:	eb 22                	jmp    800b87 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b65:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b68:	89 f3                	mov    %esi,%ebx
  800b6a:	80 fb 19             	cmp    $0x19,%bl
  800b6d:	77 08                	ja     800b77 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b6f:	0f be d2             	movsbl %dl,%edx
  800b72:	83 ea 57             	sub    $0x57,%edx
  800b75:	eb 10                	jmp    800b87 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b77:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	80 fb 19             	cmp    $0x19,%bl
  800b7f:	77 16                	ja     800b97 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b81:	0f be d2             	movsbl %dl,%edx
  800b84:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b87:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8a:	7d 0b                	jge    800b97 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b8c:	83 c1 01             	add    $0x1,%ecx
  800b8f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b93:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b95:	eb b9                	jmp    800b50 <strtol+0x76>

	if (endptr)
  800b97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9b:	74 0d                	je     800baa <strtol+0xd0>
		*endptr = (char *) s;
  800b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba0:	89 0e                	mov    %ecx,(%esi)
  800ba2:	eb 06                	jmp    800baa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba4:	85 db                	test   %ebx,%ebx
  800ba6:	74 98                	je     800b40 <strtol+0x66>
  800ba8:	eb 9e                	jmp    800b48 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	f7 da                	neg    %edx
  800bae:	85 ff                	test   %edi,%edi
  800bb0:	0f 45 c2             	cmovne %edx,%eax
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 c3                	mov    %eax,%ebx
  800bcb:	89 c7                	mov    %eax,%edi
  800bcd:	89 c6                	mov    %eax,%esi
  800bcf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	b8 03 00 00 00       	mov    $0x3,%eax
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	89 cb                	mov    %ecx,%ebx
  800c0d:	89 cf                	mov    %ecx,%edi
  800c0f:	89 ce                	mov    %ecx,%esi
  800c11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 17                	jle    800c2e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	50                   	push   %eax
  800c1b:	6a 03                	push   $0x3
  800c1d:	68 df 26 80 00       	push   $0x8026df
  800c22:	6a 23                	push   $0x23
  800c24:	68 fc 26 80 00       	push   $0x8026fc
  800c29:	e8 40 13 00 00       	call   801f6e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 02 00 00 00       	mov    $0x2,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_yield>:

void
sys_yield(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	be 00 00 00 00       	mov    $0x0,%esi
  800c82:	b8 04 00 00 00       	mov    $0x4,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c90:	89 f7                	mov    %esi,%edi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 04                	push   $0x4
  800c9e:	68 df 26 80 00       	push   $0x8026df
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 fc 26 80 00       	push   $0x8026fc
  800caa:	e8 bf 12 00 00       	call   801f6e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 05                	push   $0x5
  800ce0:	68 df 26 80 00       	push   $0x8026df
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 fc 26 80 00       	push   $0x8026fc
  800cec:	e8 7d 12 00 00       	call   801f6e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 06                	push   $0x6
  800d22:	68 df 26 80 00       	push   $0x8026df
  800d27:	6a 23                	push   $0x23
  800d29:	68 fc 26 80 00       	push   $0x8026fc
  800d2e:	e8 3b 12 00 00       	call   801f6e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	b8 08 00 00 00       	mov    $0x8,%eax
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 08                	push   $0x8
  800d64:	68 df 26 80 00       	push   $0x8026df
  800d69:	6a 23                	push   $0x23
  800d6b:	68 fc 26 80 00       	push   $0x8026fc
  800d70:	e8 f9 11 00 00       	call   801f6e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 09                	push   $0x9
  800da6:	68 df 26 80 00       	push   $0x8026df
  800dab:	6a 23                	push   $0x23
  800dad:	68 fc 26 80 00       	push   $0x8026fc
  800db2:	e8 b7 11 00 00       	call   801f6e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 17                	jle    800df9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 0a                	push   $0xa
  800de8:	68 df 26 80 00       	push   $0x8026df
  800ded:	6a 23                	push   $0x23
  800def:	68 fc 26 80 00       	push   $0x8026fc
  800df4:	e8 75 11 00 00       	call   801f6e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	be 00 00 00 00       	mov    $0x0,%esi
  800e0c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e32:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	89 cb                	mov    %ecx,%ebx
  800e3c:	89 cf                	mov    %ecx,%edi
  800e3e:	89 ce                	mov    %ecx,%esi
  800e40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 17                	jle    800e5d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	83 ec 0c             	sub    $0xc,%esp
  800e49:	50                   	push   %eax
  800e4a:	6a 0d                	push   $0xd
  800e4c:	68 df 26 80 00       	push   $0x8026df
  800e51:	6a 23                	push   $0x23
  800e53:	68 fc 26 80 00       	push   $0x8026fc
  800e58:	e8 11 11 00 00       	call   801f6e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e70:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	89 cb                	mov    %ecx,%ebx
  800e7a:	89 cf                	mov    %ecx,%edi
  800e7c:	89 ce                	mov    %ecx,%esi
  800e7e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	53                   	push   %ebx
  800e89:	83 ec 04             	sub    $0x4,%esp
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e8f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e91:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e95:	74 11                	je     800ea8 <pgfault+0x23>
  800e97:	89 d8                	mov    %ebx,%eax
  800e99:	c1 e8 0c             	shr    $0xc,%eax
  800e9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea3:	f6 c4 08             	test   $0x8,%ah
  800ea6:	75 14                	jne    800ebc <pgfault+0x37>
		panic("faulting access");
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	68 0a 27 80 00       	push   $0x80270a
  800eb0:	6a 1d                	push   $0x1d
  800eb2:	68 1a 27 80 00       	push   $0x80271a
  800eb7:	e8 b2 10 00 00       	call   801f6e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	6a 07                	push   $0x7
  800ec1:	68 00 f0 7f 00       	push   $0x7ff000
  800ec6:	6a 00                	push   $0x0
  800ec8:	e8 a7 fd ff ff       	call   800c74 <sys_page_alloc>
	if (r < 0) {
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	79 12                	jns    800ee6 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ed4:	50                   	push   %eax
  800ed5:	68 25 27 80 00       	push   $0x802725
  800eda:	6a 2b                	push   $0x2b
  800edc:	68 1a 27 80 00       	push   $0x80271a
  800ee1:	e8 88 10 00 00       	call   801f6e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ee6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	68 00 10 00 00       	push   $0x1000
  800ef4:	53                   	push   %ebx
  800ef5:	68 00 f0 7f 00       	push   $0x7ff000
  800efa:	e8 6c fb ff ff       	call   800a6b <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800eff:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f06:	53                   	push   %ebx
  800f07:	6a 00                	push   $0x0
  800f09:	68 00 f0 7f 00       	push   $0x7ff000
  800f0e:	6a 00                	push   $0x0
  800f10:	e8 a2 fd ff ff       	call   800cb7 <sys_page_map>
	if (r < 0) {
  800f15:	83 c4 20             	add    $0x20,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	79 12                	jns    800f2e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f1c:	50                   	push   %eax
  800f1d:	68 25 27 80 00       	push   $0x802725
  800f22:	6a 32                	push   $0x32
  800f24:	68 1a 27 80 00       	push   $0x80271a
  800f29:	e8 40 10 00 00       	call   801f6e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	6a 00                	push   $0x0
  800f38:	e8 bc fd ff ff       	call   800cf9 <sys_page_unmap>
	if (r < 0) {
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	79 12                	jns    800f56 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f44:	50                   	push   %eax
  800f45:	68 25 27 80 00       	push   $0x802725
  800f4a:	6a 36                	push   $0x36
  800f4c:	68 1a 27 80 00       	push   $0x80271a
  800f51:	e8 18 10 00 00       	call   801f6e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	53                   	push   %ebx
  800f61:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f64:	68 85 0e 80 00       	push   $0x800e85
  800f69:	e8 46 10 00 00       	call   801fb4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f6e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f73:	cd 30                	int    $0x30
  800f75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	79 17                	jns    800f96 <fork+0x3b>
		panic("fork fault %e");
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	68 3e 27 80 00       	push   $0x80273e
  800f87:	68 83 00 00 00       	push   $0x83
  800f8c:	68 1a 27 80 00       	push   $0x80271a
  800f91:	e8 d8 0f 00 00       	call   801f6e <_panic>
  800f96:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f98:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f9c:	75 25                	jne    800fc3 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f9e:	e8 93 fc ff ff       	call   800c36 <sys_getenvid>
  800fa3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa8:	89 c2                	mov    %eax,%edx
  800faa:	c1 e2 07             	shl    $0x7,%edx
  800fad:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800fb4:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbe:	e9 61 01 00 00       	jmp    801124 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fc3:	83 ec 04             	sub    $0x4,%esp
  800fc6:	6a 07                	push   $0x7
  800fc8:	68 00 f0 bf ee       	push   $0xeebff000
  800fcd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd0:	e8 9f fc ff ff       	call   800c74 <sys_page_alloc>
  800fd5:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fd8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fdd:	89 d8                	mov    %ebx,%eax
  800fdf:	c1 e8 16             	shr    $0x16,%eax
  800fe2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe9:	a8 01                	test   $0x1,%al
  800feb:	0f 84 fc 00 00 00    	je     8010ed <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ff1:	89 d8                	mov    %ebx,%eax
  800ff3:	c1 e8 0c             	shr    $0xc,%eax
  800ff6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ffd:	f6 c2 01             	test   $0x1,%dl
  801000:	0f 84 e7 00 00 00    	je     8010ed <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801006:	89 c6                	mov    %eax,%esi
  801008:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80100b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801012:	f6 c6 04             	test   $0x4,%dh
  801015:	74 39                	je     801050 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801017:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	25 07 0e 00 00       	and    $0xe07,%eax
  801026:	50                   	push   %eax
  801027:	56                   	push   %esi
  801028:	57                   	push   %edi
  801029:	56                   	push   %esi
  80102a:	6a 00                	push   $0x0
  80102c:	e8 86 fc ff ff       	call   800cb7 <sys_page_map>
		if (r < 0) {
  801031:	83 c4 20             	add    $0x20,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	0f 89 b1 00 00 00    	jns    8010ed <fork+0x192>
		    	panic("sys page map fault %e");
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	68 4c 27 80 00       	push   $0x80274c
  801044:	6a 53                	push   $0x53
  801046:	68 1a 27 80 00       	push   $0x80271a
  80104b:	e8 1e 0f 00 00       	call   801f6e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801050:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801057:	f6 c2 02             	test   $0x2,%dl
  80105a:	75 0c                	jne    801068 <fork+0x10d>
  80105c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801063:	f6 c4 08             	test   $0x8,%ah
  801066:	74 5b                	je     8010c3 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	68 05 08 00 00       	push   $0x805
  801070:	56                   	push   %esi
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	6a 00                	push   $0x0
  801075:	e8 3d fc ff ff       	call   800cb7 <sys_page_map>
		if (r < 0) {
  80107a:	83 c4 20             	add    $0x20,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	79 14                	jns    801095 <fork+0x13a>
		    	panic("sys page map fault %e");
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	68 4c 27 80 00       	push   $0x80274c
  801089:	6a 5a                	push   $0x5a
  80108b:	68 1a 27 80 00       	push   $0x80271a
  801090:	e8 d9 0e 00 00       	call   801f6e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	68 05 08 00 00       	push   $0x805
  80109d:	56                   	push   %esi
  80109e:	6a 00                	push   $0x0
  8010a0:	56                   	push   %esi
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 0f fc ff ff       	call   800cb7 <sys_page_map>
		if (r < 0) {
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	79 3e                	jns    8010ed <fork+0x192>
		    	panic("sys page map fault %e");
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	68 4c 27 80 00       	push   $0x80274c
  8010b7:	6a 5e                	push   $0x5e
  8010b9:	68 1a 27 80 00       	push   $0x80271a
  8010be:	e8 ab 0e 00 00       	call   801f6e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	6a 05                	push   $0x5
  8010c8:	56                   	push   %esi
  8010c9:	57                   	push   %edi
  8010ca:	56                   	push   %esi
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 e5 fb ff ff       	call   800cb7 <sys_page_map>
		if (r < 0) {
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 14                	jns    8010ed <fork+0x192>
		    	panic("sys page map fault %e");
  8010d9:	83 ec 04             	sub    $0x4,%esp
  8010dc:	68 4c 27 80 00       	push   $0x80274c
  8010e1:	6a 63                	push   $0x63
  8010e3:	68 1a 27 80 00       	push   $0x80271a
  8010e8:	e8 81 0e 00 00       	call   801f6e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f3:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010f9:	0f 85 de fe ff ff    	jne    800fdd <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010ff:	a1 04 40 80 00       	mov    0x804004,%eax
  801104:	8b 40 6c             	mov    0x6c(%eax),%eax
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	50                   	push   %eax
  80110b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80110e:	57                   	push   %edi
  80110f:	e8 ab fc ff ff       	call   800dbf <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	6a 02                	push   $0x2
  801119:	57                   	push   %edi
  80111a:	e8 1c fc ff ff       	call   800d3b <sys_env_set_status>
	
	return envid;
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sfork>:

envid_t
sfork(void)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	53                   	push   %ebx
  801142:	68 64 27 80 00       	push   $0x802764
  801147:	e8 a0 f1 ff ff       	call   8002ec <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  80114c:	89 1c 24             	mov    %ebx,(%esp)
  80114f:	e8 11 fd ff ff       	call   800e65 <sys_thread_create>
  801154:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801156:	83 c4 08             	add    $0x8,%esp
  801159:	53                   	push   %ebx
  80115a:	68 64 27 80 00       	push   $0x802764
  80115f:	e8 88 f1 ff ff       	call   8002ec <cprintf>
	return id;
}
  801164:	89 f0                	mov    %esi,%eax
  801166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	8b 75 08             	mov    0x8(%ebp),%esi
  801175:	8b 45 0c             	mov    0xc(%ebp),%eax
  801178:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80117b:	85 c0                	test   %eax,%eax
  80117d:	75 12                	jne    801191 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	68 00 00 c0 ee       	push   $0xeec00000
  801187:	e8 98 fc ff ff       	call   800e24 <sys_ipc_recv>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	eb 0c                	jmp    80119d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	50                   	push   %eax
  801195:	e8 8a fc ff ff       	call   800e24 <sys_ipc_recv>
  80119a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80119d:	85 f6                	test   %esi,%esi
  80119f:	0f 95 c1             	setne  %cl
  8011a2:	85 db                	test   %ebx,%ebx
  8011a4:	0f 95 c2             	setne  %dl
  8011a7:	84 d1                	test   %dl,%cl
  8011a9:	74 09                	je     8011b4 <ipc_recv+0x47>
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	c1 ea 1f             	shr    $0x1f,%edx
  8011b0:	84 d2                	test   %dl,%dl
  8011b2:	75 27                	jne    8011db <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8011b4:	85 f6                	test   %esi,%esi
  8011b6:	74 0a                	je     8011c2 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8011b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bd:	8b 40 7c             	mov    0x7c(%eax),%eax
  8011c0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8011c2:	85 db                	test   %ebx,%ebx
  8011c4:	74 0d                	je     8011d3 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  8011c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8011d1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d8:	8b 40 78             	mov    0x78(%eax),%eax
}
  8011db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8011f4:	85 db                	test   %ebx,%ebx
  8011f6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011fb:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011fe:	ff 75 14             	pushl  0x14(%ebp)
  801201:	53                   	push   %ebx
  801202:	56                   	push   %esi
  801203:	57                   	push   %edi
  801204:	e8 f8 fb ff ff       	call   800e01 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 1f             	shr    $0x1f,%edx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	84 d2                	test   %dl,%dl
  801213:	74 17                	je     80122c <ipc_send+0x4a>
  801215:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801218:	74 12                	je     80122c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80121a:	50                   	push   %eax
  80121b:	68 87 27 80 00       	push   $0x802787
  801220:	6a 47                	push   $0x47
  801222:	68 95 27 80 00       	push   $0x802795
  801227:	e8 42 0d 00 00       	call   801f6e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80122c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80122f:	75 07                	jne    801238 <ipc_send+0x56>
			sys_yield();
  801231:	e8 1f fa ff ff       	call   800c55 <sys_yield>
  801236:	eb c6                	jmp    8011fe <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801238:	85 c0                	test   %eax,%eax
  80123a:	75 c2                	jne    8011fe <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80123c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80124f:	89 c2                	mov    %eax,%edx
  801251:	c1 e2 07             	shl    $0x7,%edx
  801254:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80125b:	8b 52 58             	mov    0x58(%edx),%edx
  80125e:	39 ca                	cmp    %ecx,%edx
  801260:	75 11                	jne    801273 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801262:	89 c2                	mov    %eax,%edx
  801264:	c1 e2 07             	shl    $0x7,%edx
  801267:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80126e:	8b 40 50             	mov    0x50(%eax),%eax
  801271:	eb 0f                	jmp    801282 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801273:	83 c0 01             	add    $0x1,%eax
  801276:	3d 00 04 00 00       	cmp    $0x400,%eax
  80127b:	75 d2                	jne    80124f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801287:	8b 45 08             	mov    0x8(%ebp),%eax
  80128a:	05 00 00 00 30       	add    $0x30000000,%eax
  80128f:	c1 e8 0c             	shr    $0xc,%eax
}
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801297:	8b 45 08             	mov    0x8(%ebp),%eax
  80129a:	05 00 00 00 30       	add    $0x30000000,%eax
  80129f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b6:	89 c2                	mov    %eax,%edx
  8012b8:	c1 ea 16             	shr    $0x16,%edx
  8012bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c2:	f6 c2 01             	test   $0x1,%dl
  8012c5:	74 11                	je     8012d8 <fd_alloc+0x2d>
  8012c7:	89 c2                	mov    %eax,%edx
  8012c9:	c1 ea 0c             	shr    $0xc,%edx
  8012cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d3:	f6 c2 01             	test   $0x1,%dl
  8012d6:	75 09                	jne    8012e1 <fd_alloc+0x36>
			*fd_store = fd;
  8012d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
  8012df:	eb 17                	jmp    8012f8 <fd_alloc+0x4d>
  8012e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012eb:	75 c9                	jne    8012b6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ed:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801300:	83 f8 1f             	cmp    $0x1f,%eax
  801303:	77 36                	ja     80133b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801305:	c1 e0 0c             	shl    $0xc,%eax
  801308:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	c1 ea 16             	shr    $0x16,%edx
  801312:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801319:	f6 c2 01             	test   $0x1,%dl
  80131c:	74 24                	je     801342 <fd_lookup+0x48>
  80131e:	89 c2                	mov    %eax,%edx
  801320:	c1 ea 0c             	shr    $0xc,%edx
  801323:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132a:	f6 c2 01             	test   $0x1,%dl
  80132d:	74 1a                	je     801349 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80132f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801332:	89 02                	mov    %eax,(%edx)
	return 0;
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
  801339:	eb 13                	jmp    80134e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80133b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801340:	eb 0c                	jmp    80134e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801342:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801347:	eb 05                	jmp    80134e <fd_lookup+0x54>
  801349:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801359:	ba 1c 28 80 00       	mov    $0x80281c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80135e:	eb 13                	jmp    801373 <dev_lookup+0x23>
  801360:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801363:	39 08                	cmp    %ecx,(%eax)
  801365:	75 0c                	jne    801373 <dev_lookup+0x23>
			*dev = devtab[i];
  801367:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136c:	b8 00 00 00 00       	mov    $0x0,%eax
  801371:	eb 2e                	jmp    8013a1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801373:	8b 02                	mov    (%edx),%eax
  801375:	85 c0                	test   %eax,%eax
  801377:	75 e7                	jne    801360 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801379:	a1 04 40 80 00       	mov    0x804004,%eax
  80137e:	8b 40 50             	mov    0x50(%eax),%eax
  801381:	83 ec 04             	sub    $0x4,%esp
  801384:	51                   	push   %ecx
  801385:	50                   	push   %eax
  801386:	68 a0 27 80 00       	push   $0x8027a0
  80138b:	e8 5c ef ff ff       	call   8002ec <cprintf>
	*dev = 0;
  801390:	8b 45 0c             	mov    0xc(%ebp),%eax
  801393:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 10             	sub    $0x10,%esp
  8013ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013bb:	c1 e8 0c             	shr    $0xc,%eax
  8013be:	50                   	push   %eax
  8013bf:	e8 36 ff ff ff       	call   8012fa <fd_lookup>
  8013c4:	83 c4 08             	add    $0x8,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 05                	js     8013d0 <fd_close+0x2d>
	    || fd != fd2)
  8013cb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ce:	74 0c                	je     8013dc <fd_close+0x39>
		return (must_exist ? r : 0);
  8013d0:	84 db                	test   %bl,%bl
  8013d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d7:	0f 44 c2             	cmove  %edx,%eax
  8013da:	eb 41                	jmp    80141d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	ff 36                	pushl  (%esi)
  8013e5:	e8 66 ff ff ff       	call   801350 <dev_lookup>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 1a                	js     80140d <fd_close+0x6a>
		if (dev->dev_close)
  8013f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013f9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 0b                	je     80140d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	56                   	push   %esi
  801406:	ff d0                	call   *%eax
  801408:	89 c3                	mov    %eax,%ebx
  80140a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	56                   	push   %esi
  801411:	6a 00                	push   $0x0
  801413:	e8 e1 f8 ff ff       	call   800cf9 <sys_page_unmap>
	return r;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	89 d8                	mov    %ebx,%eax
}
  80141d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	ff 75 08             	pushl  0x8(%ebp)
  801431:	e8 c4 fe ff ff       	call   8012fa <fd_lookup>
  801436:	83 c4 08             	add    $0x8,%esp
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 10                	js     80144d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80143d:	83 ec 08             	sub    $0x8,%esp
  801440:	6a 01                	push   $0x1
  801442:	ff 75 f4             	pushl  -0xc(%ebp)
  801445:	e8 59 ff ff ff       	call   8013a3 <fd_close>
  80144a:	83 c4 10             	add    $0x10,%esp
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <close_all>:

void
close_all(void)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801456:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	53                   	push   %ebx
  80145f:	e8 c0 ff ff ff       	call   801424 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801464:	83 c3 01             	add    $0x1,%ebx
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	83 fb 20             	cmp    $0x20,%ebx
  80146d:	75 ec                	jne    80145b <close_all+0xc>
		close(i);
}
  80146f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	57                   	push   %edi
  801478:	56                   	push   %esi
  801479:	53                   	push   %ebx
  80147a:	83 ec 2c             	sub    $0x2c,%esp
  80147d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801480:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	ff 75 08             	pushl  0x8(%ebp)
  801487:	e8 6e fe ff ff       	call   8012fa <fd_lookup>
  80148c:	83 c4 08             	add    $0x8,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	0f 88 c1 00 00 00    	js     801558 <dup+0xe4>
		return r;
	close(newfdnum);
  801497:	83 ec 0c             	sub    $0xc,%esp
  80149a:	56                   	push   %esi
  80149b:	e8 84 ff ff ff       	call   801424 <close>

	newfd = INDEX2FD(newfdnum);
  8014a0:	89 f3                	mov    %esi,%ebx
  8014a2:	c1 e3 0c             	shl    $0xc,%ebx
  8014a5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014ab:	83 c4 04             	add    $0x4,%esp
  8014ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b1:	e8 de fd ff ff       	call   801294 <fd2data>
  8014b6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014b8:	89 1c 24             	mov    %ebx,(%esp)
  8014bb:	e8 d4 fd ff ff       	call   801294 <fd2data>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014c6:	89 f8                	mov    %edi,%eax
  8014c8:	c1 e8 16             	shr    $0x16,%eax
  8014cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d2:	a8 01                	test   $0x1,%al
  8014d4:	74 37                	je     80150d <dup+0x99>
  8014d6:	89 f8                	mov    %edi,%eax
  8014d8:	c1 e8 0c             	shr    $0xc,%eax
  8014db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e2:	f6 c2 01             	test   $0x1,%dl
  8014e5:	74 26                	je     80150d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f6:	50                   	push   %eax
  8014f7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014fa:	6a 00                	push   $0x0
  8014fc:	57                   	push   %edi
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 b3 f7 ff ff       	call   800cb7 <sys_page_map>
  801504:	89 c7                	mov    %eax,%edi
  801506:	83 c4 20             	add    $0x20,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 2e                	js     80153b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801510:	89 d0                	mov    %edx,%eax
  801512:	c1 e8 0c             	shr    $0xc,%eax
  801515:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	25 07 0e 00 00       	and    $0xe07,%eax
  801524:	50                   	push   %eax
  801525:	53                   	push   %ebx
  801526:	6a 00                	push   $0x0
  801528:	52                   	push   %edx
  801529:	6a 00                	push   $0x0
  80152b:	e8 87 f7 ff ff       	call   800cb7 <sys_page_map>
  801530:	89 c7                	mov    %eax,%edi
  801532:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801535:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801537:	85 ff                	test   %edi,%edi
  801539:	79 1d                	jns    801558 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	53                   	push   %ebx
  80153f:	6a 00                	push   $0x0
  801541:	e8 b3 f7 ff ff       	call   800cf9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154c:	6a 00                	push   $0x0
  80154e:	e8 a6 f7 ff ff       	call   800cf9 <sys_page_unmap>
	return r;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	89 f8                	mov    %edi,%eax
}
  801558:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5e                   	pop    %esi
  80155d:	5f                   	pop    %edi
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    

00801560 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	53                   	push   %ebx
  801564:	83 ec 14             	sub    $0x14,%esp
  801567:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	53                   	push   %ebx
  80156f:	e8 86 fd ff ff       	call   8012fa <fd_lookup>
  801574:	83 c4 08             	add    $0x8,%esp
  801577:	89 c2                	mov    %eax,%edx
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 6d                	js     8015ea <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801587:	ff 30                	pushl  (%eax)
  801589:	e8 c2 fd ff ff       	call   801350 <dev_lookup>
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 4c                	js     8015e1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801595:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801598:	8b 42 08             	mov    0x8(%edx),%eax
  80159b:	83 e0 03             	and    $0x3,%eax
  80159e:	83 f8 01             	cmp    $0x1,%eax
  8015a1:	75 21                	jne    8015c4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a8:	8b 40 50             	mov    0x50(%eax),%eax
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	53                   	push   %ebx
  8015af:	50                   	push   %eax
  8015b0:	68 e1 27 80 00       	push   $0x8027e1
  8015b5:	e8 32 ed ff ff       	call   8002ec <cprintf>
		return -E_INVAL;
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c2:	eb 26                	jmp    8015ea <read+0x8a>
	}
	if (!dev->dev_read)
  8015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c7:	8b 40 08             	mov    0x8(%eax),%eax
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	74 17                	je     8015e5 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015ce:	83 ec 04             	sub    $0x4,%esp
  8015d1:	ff 75 10             	pushl  0x10(%ebp)
  8015d4:	ff 75 0c             	pushl  0xc(%ebp)
  8015d7:	52                   	push   %edx
  8015d8:	ff d0                	call   *%eax
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	eb 09                	jmp    8015ea <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	eb 05                	jmp    8015ea <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015ea:	89 d0                	mov    %edx,%eax
  8015ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    

008015f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	57                   	push   %edi
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801600:	bb 00 00 00 00       	mov    $0x0,%ebx
  801605:	eb 21                	jmp    801628 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	89 f0                	mov    %esi,%eax
  80160c:	29 d8                	sub    %ebx,%eax
  80160e:	50                   	push   %eax
  80160f:	89 d8                	mov    %ebx,%eax
  801611:	03 45 0c             	add    0xc(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	57                   	push   %edi
  801616:	e8 45 ff ff ff       	call   801560 <read>
		if (m < 0)
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 10                	js     801632 <readn+0x41>
			return m;
		if (m == 0)
  801622:	85 c0                	test   %eax,%eax
  801624:	74 0a                	je     801630 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801626:	01 c3                	add    %eax,%ebx
  801628:	39 f3                	cmp    %esi,%ebx
  80162a:	72 db                	jb     801607 <readn+0x16>
  80162c:	89 d8                	mov    %ebx,%eax
  80162e:	eb 02                	jmp    801632 <readn+0x41>
  801630:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801632:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5f                   	pop    %edi
  801638:	5d                   	pop    %ebp
  801639:	c3                   	ret    

0080163a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	53                   	push   %ebx
  80163e:	83 ec 14             	sub    $0x14,%esp
  801641:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801644:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	53                   	push   %ebx
  801649:	e8 ac fc ff ff       	call   8012fa <fd_lookup>
  80164e:	83 c4 08             	add    $0x8,%esp
  801651:	89 c2                	mov    %eax,%edx
  801653:	85 c0                	test   %eax,%eax
  801655:	78 68                	js     8016bf <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801661:	ff 30                	pushl  (%eax)
  801663:	e8 e8 fc ff ff       	call   801350 <dev_lookup>
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 47                	js     8016b6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801676:	75 21                	jne    801699 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801678:	a1 04 40 80 00       	mov    0x804004,%eax
  80167d:	8b 40 50             	mov    0x50(%eax),%eax
  801680:	83 ec 04             	sub    $0x4,%esp
  801683:	53                   	push   %ebx
  801684:	50                   	push   %eax
  801685:	68 fd 27 80 00       	push   $0x8027fd
  80168a:	e8 5d ec ff ff       	call   8002ec <cprintf>
		return -E_INVAL;
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801697:	eb 26                	jmp    8016bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801699:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169c:	8b 52 0c             	mov    0xc(%edx),%edx
  80169f:	85 d2                	test   %edx,%edx
  8016a1:	74 17                	je     8016ba <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	ff 75 10             	pushl  0x10(%ebp)
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	50                   	push   %eax
  8016ad:	ff d2                	call   *%edx
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	eb 09                	jmp    8016bf <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	eb 05                	jmp    8016bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016bf:	89 d0                	mov    %edx,%eax
  8016c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	ff 75 08             	pushl  0x8(%ebp)
  8016d3:	e8 22 fc ff ff       	call   8012fa <fd_lookup>
  8016d8:	83 c4 08             	add    $0x8,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 0e                	js     8016ed <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 14             	sub    $0x14,%esp
  8016f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	53                   	push   %ebx
  8016fe:	e8 f7 fb ff ff       	call   8012fa <fd_lookup>
  801703:	83 c4 08             	add    $0x8,%esp
  801706:	89 c2                	mov    %eax,%edx
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 65                	js     801771 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801712:	50                   	push   %eax
  801713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801716:	ff 30                	pushl  (%eax)
  801718:	e8 33 fc ff ff       	call   801350 <dev_lookup>
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	85 c0                	test   %eax,%eax
  801722:	78 44                	js     801768 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801724:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801727:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80172b:	75 21                	jne    80174e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80172d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801732:	8b 40 50             	mov    0x50(%eax),%eax
  801735:	83 ec 04             	sub    $0x4,%esp
  801738:	53                   	push   %ebx
  801739:	50                   	push   %eax
  80173a:	68 c0 27 80 00       	push   $0x8027c0
  80173f:	e8 a8 eb ff ff       	call   8002ec <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80174c:	eb 23                	jmp    801771 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80174e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801751:	8b 52 18             	mov    0x18(%edx),%edx
  801754:	85 d2                	test   %edx,%edx
  801756:	74 14                	je     80176c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	ff 75 0c             	pushl  0xc(%ebp)
  80175e:	50                   	push   %eax
  80175f:	ff d2                	call   *%edx
  801761:	89 c2                	mov    %eax,%edx
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	eb 09                	jmp    801771 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801768:	89 c2                	mov    %eax,%edx
  80176a:	eb 05                	jmp    801771 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80176c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801771:	89 d0                	mov    %edx,%eax
  801773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	83 ec 14             	sub    $0x14,%esp
  80177f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801782:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801785:	50                   	push   %eax
  801786:	ff 75 08             	pushl  0x8(%ebp)
  801789:	e8 6c fb ff ff       	call   8012fa <fd_lookup>
  80178e:	83 c4 08             	add    $0x8,%esp
  801791:	89 c2                	mov    %eax,%edx
  801793:	85 c0                	test   %eax,%eax
  801795:	78 58                	js     8017ef <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801797:	83 ec 08             	sub    $0x8,%esp
  80179a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179d:	50                   	push   %eax
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	ff 30                	pushl  (%eax)
  8017a3:	e8 a8 fb ff ff       	call   801350 <dev_lookup>
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 37                	js     8017e6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017b6:	74 32                	je     8017ea <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c2:	00 00 00 
	stat->st_isdir = 0;
  8017c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017cc:	00 00 00 
	stat->st_dev = dev;
  8017cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	53                   	push   %ebx
  8017d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017dc:	ff 50 14             	call   *0x14(%eax)
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	eb 09                	jmp    8017ef <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e6:	89 c2                	mov    %eax,%edx
  8017e8:	eb 05                	jmp    8017ef <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ef:	89 d0                	mov    %edx,%eax
  8017f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	56                   	push   %esi
  8017fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	6a 00                	push   $0x0
  801800:	ff 75 08             	pushl  0x8(%ebp)
  801803:	e8 e3 01 00 00       	call   8019eb <open>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 1b                	js     80182c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	ff 75 0c             	pushl  0xc(%ebp)
  801817:	50                   	push   %eax
  801818:	e8 5b ff ff ff       	call   801778 <fstat>
  80181d:	89 c6                	mov    %eax,%esi
	close(fd);
  80181f:	89 1c 24             	mov    %ebx,(%esp)
  801822:	e8 fd fb ff ff       	call   801424 <close>
	return r;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	89 f0                	mov    %esi,%eax
}
  80182c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	89 c6                	mov    %eax,%esi
  80183a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80183c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801843:	75 12                	jne    801857 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	6a 01                	push   $0x1
  80184a:	e8 f5 f9 ff ff       	call   801244 <ipc_find_env>
  80184f:	a3 00 40 80 00       	mov    %eax,0x804000
  801854:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801857:	6a 07                	push   $0x7
  801859:	68 00 50 80 00       	push   $0x805000
  80185e:	56                   	push   %esi
  80185f:	ff 35 00 40 80 00    	pushl  0x804000
  801865:	e8 78 f9 ff ff       	call   8011e2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80186a:	83 c4 0c             	add    $0xc,%esp
  80186d:	6a 00                	push   $0x0
  80186f:	53                   	push   %ebx
  801870:	6a 00                	push   $0x0
  801872:	e8 f6 f8 ff ff       	call   80116d <ipc_recv>
}
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 40 0c             	mov    0xc(%eax),%eax
  80188a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80188f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801892:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a1:	e8 8d ff ff ff       	call   801833 <fsipc>
}
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c3:	e8 6b ff ff ff       	call   801833 <fsipc>
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e9:	e8 45 ff ff ff       	call   801833 <fsipc>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 2c                	js     80191e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	68 00 50 80 00       	push   $0x805000
  8018fa:	53                   	push   %ebx
  8018fb:	e8 71 ef ff ff       	call   800871 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801900:	a1 80 50 80 00       	mov    0x805080,%eax
  801905:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80190b:	a1 84 50 80 00       	mov    0x805084,%eax
  801910:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80192c:	8b 55 08             	mov    0x8(%ebp),%edx
  80192f:	8b 52 0c             	mov    0xc(%edx),%edx
  801932:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801938:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80193d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801942:	0f 47 c2             	cmova  %edx,%eax
  801945:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80194a:	50                   	push   %eax
  80194b:	ff 75 0c             	pushl  0xc(%ebp)
  80194e:	68 08 50 80 00       	push   $0x805008
  801953:	e8 ab f0 ff ff       	call   800a03 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801958:	ba 00 00 00 00       	mov    $0x0,%edx
  80195d:	b8 04 00 00 00       	mov    $0x4,%eax
  801962:	e8 cc fe ff ff       	call   801833 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	8b 40 0c             	mov    0xc(%eax),%eax
  801977:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80197c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801982:	ba 00 00 00 00       	mov    $0x0,%edx
  801987:	b8 03 00 00 00       	mov    $0x3,%eax
  80198c:	e8 a2 fe ff ff       	call   801833 <fsipc>
  801991:	89 c3                	mov    %eax,%ebx
  801993:	85 c0                	test   %eax,%eax
  801995:	78 4b                	js     8019e2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801997:	39 c6                	cmp    %eax,%esi
  801999:	73 16                	jae    8019b1 <devfile_read+0x48>
  80199b:	68 2c 28 80 00       	push   $0x80282c
  8019a0:	68 33 28 80 00       	push   $0x802833
  8019a5:	6a 7c                	push   $0x7c
  8019a7:	68 48 28 80 00       	push   $0x802848
  8019ac:	e8 bd 05 00 00       	call   801f6e <_panic>
	assert(r <= PGSIZE);
  8019b1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019b6:	7e 16                	jle    8019ce <devfile_read+0x65>
  8019b8:	68 53 28 80 00       	push   $0x802853
  8019bd:	68 33 28 80 00       	push   $0x802833
  8019c2:	6a 7d                	push   $0x7d
  8019c4:	68 48 28 80 00       	push   $0x802848
  8019c9:	e8 a0 05 00 00       	call   801f6e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	50                   	push   %eax
  8019d2:	68 00 50 80 00       	push   $0x805000
  8019d7:	ff 75 0c             	pushl  0xc(%ebp)
  8019da:	e8 24 f0 ff ff       	call   800a03 <memmove>
	return r;
  8019df:	83 c4 10             	add    $0x10,%esp
}
  8019e2:	89 d8                	mov    %ebx,%eax
  8019e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e7:	5b                   	pop    %ebx
  8019e8:	5e                   	pop    %esi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	53                   	push   %ebx
  8019ef:	83 ec 20             	sub    $0x20,%esp
  8019f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019f5:	53                   	push   %ebx
  8019f6:	e8 3d ee ff ff       	call   800838 <strlen>
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a03:	7f 67                	jg     801a6c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a05:	83 ec 0c             	sub    $0xc,%esp
  801a08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0b:	50                   	push   %eax
  801a0c:	e8 9a f8 ff ff       	call   8012ab <fd_alloc>
  801a11:	83 c4 10             	add    $0x10,%esp
		return r;
  801a14:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 57                	js     801a71 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	53                   	push   %ebx
  801a1e:	68 00 50 80 00       	push   $0x805000
  801a23:	e8 49 ee ff ff       	call   800871 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a33:	b8 01 00 00 00       	mov    $0x1,%eax
  801a38:	e8 f6 fd ff ff       	call   801833 <fsipc>
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	85 c0                	test   %eax,%eax
  801a44:	79 14                	jns    801a5a <open+0x6f>
		fd_close(fd, 0);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	6a 00                	push   $0x0
  801a4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4e:	e8 50 f9 ff ff       	call   8013a3 <fd_close>
		return r;
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	89 da                	mov    %ebx,%edx
  801a58:	eb 17                	jmp    801a71 <open+0x86>
	}

	return fd2num(fd);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a60:	e8 1f f8 ff ff       	call   801284 <fd2num>
  801a65:	89 c2                	mov    %eax,%edx
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	eb 05                	jmp    801a71 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a6c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a71:	89 d0                	mov    %edx,%eax
  801a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a83:	b8 08 00 00 00       	mov    $0x8,%eax
  801a88:	e8 a6 fd ff ff       	call   801833 <fsipc>
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 75 08             	pushl  0x8(%ebp)
  801a9d:	e8 f2 f7 ff ff       	call   801294 <fd2data>
  801aa2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa4:	83 c4 08             	add    $0x8,%esp
  801aa7:	68 5f 28 80 00       	push   $0x80285f
  801aac:	53                   	push   %ebx
  801aad:	e8 bf ed ff ff       	call   800871 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab2:	8b 46 04             	mov    0x4(%esi),%eax
  801ab5:	2b 06                	sub    (%esi),%eax
  801ab7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801abd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac4:	00 00 00 
	stat->st_dev = &devpipe;
  801ac7:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ace:	30 80 00 
	return 0;
}
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae7:	53                   	push   %ebx
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 0a f2 ff ff       	call   800cf9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aef:	89 1c 24             	mov    %ebx,(%esp)
  801af2:	e8 9d f7 ff ff       	call   801294 <fd2data>
  801af7:	83 c4 08             	add    $0x8,%esp
  801afa:	50                   	push   %eax
  801afb:	6a 00                	push   $0x0
  801afd:	e8 f7 f1 ff ff       	call   800cf9 <sys_page_unmap>
}
  801b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 1c             	sub    $0x1c,%esp
  801b10:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b13:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b15:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1a:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	ff 75 e0             	pushl  -0x20(%ebp)
  801b23:	e8 1b 05 00 00       	call   802043 <pageref>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	89 3c 24             	mov    %edi,(%esp)
  801b2d:	e8 11 05 00 00       	call   802043 <pageref>
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	39 c3                	cmp    %eax,%ebx
  801b37:	0f 94 c1             	sete   %cl
  801b3a:	0f b6 c9             	movzbl %cl,%ecx
  801b3d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b40:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b46:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801b49:	39 ce                	cmp    %ecx,%esi
  801b4b:	74 1b                	je     801b68 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b4d:	39 c3                	cmp    %eax,%ebx
  801b4f:	75 c4                	jne    801b15 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b51:	8b 42 60             	mov    0x60(%edx),%eax
  801b54:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b57:	50                   	push   %eax
  801b58:	56                   	push   %esi
  801b59:	68 66 28 80 00       	push   $0x802866
  801b5e:	e8 89 e7 ff ff       	call   8002ec <cprintf>
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	eb ad                	jmp    801b15 <_pipeisclosed+0xe>
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
  801b80:	e8 0f f7 ff ff       	call   801294 <fd2data>
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
  801b95:	e8 6d ff ff ff       	call   801b07 <_pipeisclosed>
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	75 48                	jne    801be6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b9e:	e8 b2 f0 ff ff       	call   800c55 <sys_yield>
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
  801c00:	e8 8f f6 ff ff       	call   801294 <fd2data>
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
  801c1d:	e8 e5 fe ff ff       	call   801b07 <_pipeisclosed>
  801c22:	85 c0                	test   %eax,%eax
  801c24:	75 32                	jne    801c58 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c26:	e8 2a f0 ff ff       	call   800c55 <sys_yield>
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
  801c71:	e8 35 f6 ff ff       	call   8012ab <fd_alloc>
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	89 c2                	mov    %eax,%edx
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	0f 88 2c 01 00 00    	js     801daf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c83:	83 ec 04             	sub    $0x4,%esp
  801c86:	68 07 04 00 00       	push   $0x407
  801c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 df ef ff ff       	call   800c74 <sys_page_alloc>
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	89 c2                	mov    %eax,%edx
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	0f 88 0d 01 00 00    	js     801daf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca8:	50                   	push   %eax
  801ca9:	e8 fd f5 ff ff       	call   8012ab <fd_alloc>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 e2 00 00 00    	js     801d9d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	68 07 04 00 00       	push   $0x407
  801cc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 a7 ef ff ff       	call   800c74 <sys_page_alloc>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 c3 00 00 00    	js     801d9d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce0:	e8 af f5 ff ff       	call   801294 <fd2data>
  801ce5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce7:	83 c4 0c             	add    $0xc,%esp
  801cea:	68 07 04 00 00       	push   $0x407
  801cef:	50                   	push   %eax
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 7d ef ff ff       	call   800c74 <sys_page_alloc>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	0f 88 89 00 00 00    	js     801d8d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0a:	e8 85 f5 ff ff       	call   801294 <fd2data>
  801d0f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d16:	50                   	push   %eax
  801d17:	6a 00                	push   $0x0
  801d19:	56                   	push   %esi
  801d1a:	6a 00                	push   $0x0
  801d1c:	e8 96 ef ff ff       	call   800cb7 <sys_page_map>
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
  801d5a:	e8 25 f5 ff ff       	call   801284 <fd2num>
  801d5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d62:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d64:	83 c4 04             	add    $0x4,%esp
  801d67:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6a:	e8 15 f5 ff ff       	call   801284 <fd2num>
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
  801d85:	e8 6f ef ff ff       	call   800cf9 <sys_page_unmap>
  801d8a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d8d:	83 ec 08             	sub    $0x8,%esp
  801d90:	ff 75 f0             	pushl  -0x10(%ebp)
  801d93:	6a 00                	push   $0x0
  801d95:	e8 5f ef ff ff       	call   800cf9 <sys_page_unmap>
  801d9a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d9d:	83 ec 08             	sub    $0x8,%esp
  801da0:	ff 75 f4             	pushl  -0xc(%ebp)
  801da3:	6a 00                	push   $0x0
  801da5:	e8 4f ef ff ff       	call   800cf9 <sys_page_unmap>
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
  801dc5:	e8 30 f5 ff ff       	call   8012fa <fd_lookup>
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 18                	js     801de9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	e8 b8 f4 ff ff       	call   801294 <fd2data>
	return _pipeisclosed(fd, p);
  801ddc:	89 c2                	mov    %eax,%edx
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	e8 21 fd ff ff       	call   801b07 <_pipeisclosed>
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
  801dfb:	68 7e 28 80 00       	push   $0x80287e
  801e00:	ff 75 0c             	pushl  0xc(%ebp)
  801e03:	e8 69 ea ff ff       	call   800871 <strcpy>
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
  801e41:	e8 bd eb ff ff       	call   800a03 <memmove>
		sys_cputs(buf, m);
  801e46:	83 c4 08             	add    $0x8,%esp
  801e49:	53                   	push   %ebx
  801e4a:	57                   	push   %edi
  801e4b:	e8 68 ed ff ff       	call   800bb8 <sys_cputs>
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
  801e77:	e8 d9 ed ff ff       	call   800c55 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e7c:	e8 55 ed ff ff       	call   800bd6 <sys_cgetc>
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
  801eb3:	e8 00 ed ff ff       	call   800bb8 <sys_cputs>
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
  801ecb:	e8 90 f6 ff ff       	call   801560 <read>
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
  801ef5:	e8 00 f4 ff ff       	call   8012fa <fd_lookup>
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
  801f1e:	e8 88 f3 ff ff       	call   8012ab <fd_alloc>
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
  801f39:	e8 36 ed ff ff       	call   800c74 <sys_page_alloc>
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
  801f60:	e8 1f f3 ff ff       	call   801284 <fd2num>
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
  801f7c:	e8 b5 ec ff ff       	call   800c36 <sys_getenvid>
  801f81:	83 ec 0c             	sub    $0xc,%esp
  801f84:	ff 75 0c             	pushl  0xc(%ebp)
  801f87:	ff 75 08             	pushl  0x8(%ebp)
  801f8a:	56                   	push   %esi
  801f8b:	50                   	push   %eax
  801f8c:	68 8c 28 80 00       	push   $0x80288c
  801f91:	e8 56 e3 ff ff       	call   8002ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f96:	83 c4 18             	add    $0x18,%esp
  801f99:	53                   	push   %ebx
  801f9a:	ff 75 10             	pushl  0x10(%ebp)
  801f9d:	e8 f9 e2 ff ff       	call   80029b <vcprintf>
	cprintf("\n");
  801fa2:	c7 04 24 77 28 80 00 	movl   $0x802877,(%esp)
  801fa9:	e8 3e e3 ff ff       	call   8002ec <cprintf>
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
  801fcf:	e8 a0 ec ff ff       	call   800c74 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	79 12                	jns    801fed <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fdb:	50                   	push   %eax
  801fdc:	68 b0 28 80 00       	push   $0x8028b0
  801fe1:	6a 23                	push   $0x23
  801fe3:	68 b4 28 80 00       	push   $0x8028b4
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
  801fff:	e8 bb ed ff ff       	call   800dbf <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	79 12                	jns    80201d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80200b:	50                   	push   %eax
  80200c:	68 b0 28 80 00       	push   $0x8028b0
  802011:	6a 2c                	push   $0x2c
  802013:	68 b4 28 80 00       	push   $0x8028b4
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
