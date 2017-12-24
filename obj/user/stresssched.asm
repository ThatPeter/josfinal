
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 7b 0b 00 00       	call   800bb8 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 74 0e 00 00       	call   800ebd <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 76 0b 00 00       	call   800bd7 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 4d 0b 00 00       	call   800bd7 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 00 22 80 00       	push   $0x802200
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 28 22 80 00       	push   $0x802228
  8000c4:	e8 cc 00 00 00       	call   800195 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 3b 22 80 00       	push   $0x80223b
  8000de:	e8 8b 01 00 00       	call   80026e <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000f6:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000fd:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800100:	e8 b3 0a 00 00       	call   800bb8 <sys_getenvid>
  800105:	8b 3d 08 40 80 00    	mov    0x804008,%edi
  80010b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800110:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80011a:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80011d:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800123:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800126:	39 c8                	cmp    %ecx,%eax
  800128:	0f 44 fb             	cmove  %ebx,%edi
  80012b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800130:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800133:	83 c2 01             	add    $0x1,%edx
  800136:	83 c3 7c             	add    $0x7c,%ebx
  800139:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80013f:	75 d9                	jne    80011a <libmain+0x2d>
  800141:	89 f0                	mov    %esi,%eax
  800143:	84 c0                	test   %al,%al
  800145:	74 06                	je     80014d <libmain+0x60>
  800147:	89 3d 08 40 80 00    	mov    %edi,0x804008
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800151:	7e 0a                	jle    80015d <libmain+0x70>
		binaryname = argv[0];
  800153:	8b 45 0c             	mov    0xc(%ebp),%eax
  800156:	8b 00                	mov    (%eax),%eax
  800158:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80015d:	83 ec 08             	sub    $0x8,%esp
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0b 00 00 00       	call   80017b <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5f                   	pop    %edi
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800181:	e8 e9 10 00 00       	call   80126f <close_all>
	sys_env_destroy(0);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	6a 00                	push   $0x0
  80018b:	e8 e7 09 00 00       	call   800b77 <sys_env_destroy>
}
  800190:	83 c4 10             	add    $0x10,%esp
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80019a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a3:	e8 10 0a 00 00       	call   800bb8 <sys_getenvid>
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	ff 75 0c             	pushl  0xc(%ebp)
  8001ae:	ff 75 08             	pushl  0x8(%ebp)
  8001b1:	56                   	push   %esi
  8001b2:	50                   	push   %eax
  8001b3:	68 64 22 80 00       	push   $0x802264
  8001b8:	e8 b1 00 00 00       	call   80026e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bd:	83 c4 18             	add    $0x18,%esp
  8001c0:	53                   	push   %ebx
  8001c1:	ff 75 10             	pushl  0x10(%ebp)
  8001c4:	e8 54 00 00 00       	call   80021d <vcprintf>
	cprintf("\n");
  8001c9:	c7 04 24 57 22 80 00 	movl   $0x802257,(%esp)
  8001d0:	e8 99 00 00 00       	call   80026e <cprintf>
  8001d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d8:	cc                   	int3   
  8001d9:	eb fd                	jmp    8001d8 <_panic+0x43>

008001db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	53                   	push   %ebx
  8001df:	83 ec 04             	sub    $0x4,%esp
  8001e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e5:	8b 13                	mov    (%ebx),%edx
  8001e7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ea:	89 03                	mov    %eax,(%ebx)
  8001ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f8:	75 1a                	jne    800214 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	68 ff 00 00 00       	push   $0xff
  800202:	8d 43 08             	lea    0x8(%ebx),%eax
  800205:	50                   	push   %eax
  800206:	e8 2f 09 00 00       	call   800b3a <sys_cputs>
		b->idx = 0;
  80020b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800211:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800214:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800218:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800226:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022d:	00 00 00 
	b.cnt = 0;
  800230:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800237:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800246:	50                   	push   %eax
  800247:	68 db 01 80 00       	push   $0x8001db
  80024c:	e8 54 01 00 00       	call   8003a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800251:	83 c4 08             	add    $0x8,%esp
  800254:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80025a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800260:	50                   	push   %eax
  800261:	e8 d4 08 00 00       	call   800b3a <sys_cputs>

	return b.cnt;
}
  800266:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800274:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800277:	50                   	push   %eax
  800278:	ff 75 08             	pushl  0x8(%ebp)
  80027b:	e8 9d ff ff ff       	call   80021d <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 1c             	sub    $0x1c,%esp
  80028b:	89 c7                	mov    %eax,%edi
  80028d:	89 d6                	mov    %edx,%esi
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	8b 55 0c             	mov    0xc(%ebp),%edx
  800295:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800298:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a9:	39 d3                	cmp    %edx,%ebx
  8002ab:	72 05                	jb     8002b2 <printnum+0x30>
  8002ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b0:	77 45                	ja     8002f7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	ff 75 18             	pushl  0x18(%ebp)
  8002b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002bb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002be:	53                   	push   %ebx
  8002bf:	ff 75 10             	pushl  0x10(%ebp)
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d1:	e8 9a 1c 00 00       	call   801f70 <__udivdi3>
  8002d6:	83 c4 18             	add    $0x18,%esp
  8002d9:	52                   	push   %edx
  8002da:	50                   	push   %eax
  8002db:	89 f2                	mov    %esi,%edx
  8002dd:	89 f8                	mov    %edi,%eax
  8002df:	e8 9e ff ff ff       	call   800282 <printnum>
  8002e4:	83 c4 20             	add    $0x20,%esp
  8002e7:	eb 18                	jmp    800301 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	56                   	push   %esi
  8002ed:	ff 75 18             	pushl  0x18(%ebp)
  8002f0:	ff d7                	call   *%edi
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	eb 03                	jmp    8002fa <printnum+0x78>
  8002f7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fa:	83 eb 01             	sub    $0x1,%ebx
  8002fd:	85 db                	test   %ebx,%ebx
  8002ff:	7f e8                	jg     8002e9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800301:	83 ec 08             	sub    $0x8,%esp
  800304:	56                   	push   %esi
  800305:	83 ec 04             	sub    $0x4,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 87 1d 00 00       	call   8020a0 <__umoddi3>
  800319:	83 c4 14             	add    $0x14,%esp
  80031c:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
  800323:	50                   	push   %eax
  800324:	ff d7                	call   *%edi
}
  800326:	83 c4 10             	add    $0x10,%esp
  800329:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800334:	83 fa 01             	cmp    $0x1,%edx
  800337:	7e 0e                	jle    800347 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033e:	89 08                	mov    %ecx,(%eax)
  800340:	8b 02                	mov    (%edx),%eax
  800342:	8b 52 04             	mov    0x4(%edx),%edx
  800345:	eb 22                	jmp    800369 <getuint+0x38>
	else if (lflag)
  800347:	85 d2                	test   %edx,%edx
  800349:	74 10                	je     80035b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034b:	8b 10                	mov    (%eax),%edx
  80034d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800350:	89 08                	mov    %ecx,(%eax)
  800352:	8b 02                	mov    (%edx),%eax
  800354:	ba 00 00 00 00       	mov    $0x0,%edx
  800359:	eb 0e                	jmp    800369 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 02                	mov    (%edx),%eax
  800364:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800371:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800375:	8b 10                	mov    (%eax),%edx
  800377:	3b 50 04             	cmp    0x4(%eax),%edx
  80037a:	73 0a                	jae    800386 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037f:	89 08                	mov    %ecx,(%eax)
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	88 02                	mov    %al,(%edx)
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800391:	50                   	push   %eax
  800392:	ff 75 10             	pushl  0x10(%ebp)
  800395:	ff 75 0c             	pushl  0xc(%ebp)
  800398:	ff 75 08             	pushl  0x8(%ebp)
  80039b:	e8 05 00 00 00       	call   8003a5 <vprintfmt>
	va_end(ap);
}
  8003a0:	83 c4 10             	add    $0x10,%esp
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	57                   	push   %edi
  8003a9:	56                   	push   %esi
  8003aa:	53                   	push   %ebx
  8003ab:	83 ec 2c             	sub    $0x2c,%esp
  8003ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b7:	eb 12                	jmp    8003cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b9:	85 c0                	test   %eax,%eax
  8003bb:	0f 84 89 03 00 00    	je     80074a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	53                   	push   %ebx
  8003c5:	50                   	push   %eax
  8003c6:	ff d6                	call   *%esi
  8003c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003cb:	83 c7 01             	add    $0x1,%edi
  8003ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d2:	83 f8 25             	cmp    $0x25,%eax
  8003d5:	75 e2                	jne    8003b9 <vprintfmt+0x14>
  8003d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f5:	eb 07                	jmp    8003fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8d 47 01             	lea    0x1(%edi),%eax
  800401:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800404:	0f b6 07             	movzbl (%edi),%eax
  800407:	0f b6 c8             	movzbl %al,%ecx
  80040a:	83 e8 23             	sub    $0x23,%eax
  80040d:	3c 55                	cmp    $0x55,%al
  80040f:	0f 87 1a 03 00 00    	ja     80072f <vprintfmt+0x38a>
  800415:	0f b6 c0             	movzbl %al,%eax
  800418:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800422:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800426:	eb d6                	jmp    8003fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042b:	b8 00 00 00 00       	mov    $0x0,%eax
  800430:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800433:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800436:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80043a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800440:	83 fa 09             	cmp    $0x9,%edx
  800443:	77 39                	ja     80047e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800445:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800448:	eb e9                	jmp    800433 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 48 04             	lea    0x4(%eax),%ecx
  800450:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045b:	eb 27                	jmp    800484 <vprintfmt+0xdf>
  80045d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800460:	85 c0                	test   %eax,%eax
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
  800467:	0f 49 c8             	cmovns %eax,%ecx
  80046a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800470:	eb 8c                	jmp    8003fe <vprintfmt+0x59>
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800475:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047c:	eb 80                	jmp    8003fe <vprintfmt+0x59>
  80047e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800481:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800484:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800488:	0f 89 70 ff ff ff    	jns    8003fe <vprintfmt+0x59>
				width = precision, precision = -1;
  80048e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800491:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800494:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80049b:	e9 5e ff ff ff       	jmp    8003fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a6:	e9 53 ff ff ff       	jmp    8003fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 50 04             	lea    0x4(%eax),%edx
  8004b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	53                   	push   %ebx
  8004b8:	ff 30                	pushl  (%eax)
  8004ba:	ff d6                	call   *%esi
			break;
  8004bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c2:	e9 04 ff ff ff       	jmp    8003cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	99                   	cltd   
  8004d3:	31 d0                	xor    %edx,%eax
  8004d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d7:	83 f8 0f             	cmp    $0xf,%eax
  8004da:	7f 0b                	jg     8004e7 <vprintfmt+0x142>
  8004dc:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	75 18                	jne    8004ff <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e7:	50                   	push   %eax
  8004e8:	68 9f 22 80 00       	push   $0x80229f
  8004ed:	53                   	push   %ebx
  8004ee:	56                   	push   %esi
  8004ef:	e8 94 fe ff ff       	call   800388 <printfmt>
  8004f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004fa:	e9 cc fe ff ff       	jmp    8003cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ff:	52                   	push   %edx
  800500:	68 c1 26 80 00       	push   $0x8026c1
  800505:	53                   	push   %ebx
  800506:	56                   	push   %esi
  800507:	e8 7c fe ff ff       	call   800388 <printfmt>
  80050c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800512:	e9 b4 fe ff ff       	jmp    8003cb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800522:	85 ff                	test   %edi,%edi
  800524:	b8 98 22 80 00       	mov    $0x802298,%eax
  800529:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800530:	0f 8e 94 00 00 00    	jle    8005ca <vprintfmt+0x225>
  800536:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80053a:	0f 84 98 00 00 00    	je     8005d8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	ff 75 d0             	pushl  -0x30(%ebp)
  800546:	57                   	push   %edi
  800547:	e8 86 02 00 00       	call   8007d2 <strnlen>
  80054c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054f:	29 c1                	sub    %eax,%ecx
  800551:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800557:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800561:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	eb 0f                	jmp    800574 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	53                   	push   %ebx
  800569:	ff 75 e0             	pushl  -0x20(%ebp)
  80056c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056e:	83 ef 01             	sub    $0x1,%edi
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	85 ff                	test   %edi,%edi
  800576:	7f ed                	jg     800565 <vprintfmt+0x1c0>
  800578:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	0f 49 c1             	cmovns %ecx,%eax
  800588:	29 c1                	sub    %eax,%ecx
  80058a:	89 75 08             	mov    %esi,0x8(%ebp)
  80058d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800590:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800593:	89 cb                	mov    %ecx,%ebx
  800595:	eb 4d                	jmp    8005e4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800597:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059b:	74 1b                	je     8005b8 <vprintfmt+0x213>
  80059d:	0f be c0             	movsbl %al,%eax
  8005a0:	83 e8 20             	sub    $0x20,%eax
  8005a3:	83 f8 5e             	cmp    $0x5e,%eax
  8005a6:	76 10                	jbe    8005b8 <vprintfmt+0x213>
					putch('?', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	6a 3f                	push   $0x3f
  8005b0:	ff 55 08             	call   *0x8(%ebp)
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	eb 0d                	jmp    8005c5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	ff 75 0c             	pushl  0xc(%ebp)
  8005be:	52                   	push   %edx
  8005bf:	ff 55 08             	call   *0x8(%ebp)
  8005c2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c5:	83 eb 01             	sub    $0x1,%ebx
  8005c8:	eb 1a                	jmp    8005e4 <vprintfmt+0x23f>
  8005ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d6:	eb 0c                	jmp    8005e4 <vprintfmt+0x23f>
  8005d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e4:	83 c7 01             	add    $0x1,%edi
  8005e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005eb:	0f be d0             	movsbl %al,%edx
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	74 23                	je     800615 <vprintfmt+0x270>
  8005f2:	85 f6                	test   %esi,%esi
  8005f4:	78 a1                	js     800597 <vprintfmt+0x1f2>
  8005f6:	83 ee 01             	sub    $0x1,%esi
  8005f9:	79 9c                	jns    800597 <vprintfmt+0x1f2>
  8005fb:	89 df                	mov    %ebx,%edi
  8005fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800600:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800603:	eb 18                	jmp    80061d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 20                	push   $0x20
  80060b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060d:	83 ef 01             	sub    $0x1,%edi
  800610:	83 c4 10             	add    $0x10,%esp
  800613:	eb 08                	jmp    80061d <vprintfmt+0x278>
  800615:	89 df                	mov    %ebx,%edi
  800617:	8b 75 08             	mov    0x8(%ebp),%esi
  80061a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061d:	85 ff                	test   %edi,%edi
  80061f:	7f e4                	jg     800605 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800624:	e9 a2 fd ff ff       	jmp    8003cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800629:	83 fa 01             	cmp    $0x1,%edx
  80062c:	7e 16                	jle    800644 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 08             	lea    0x8(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 50 04             	mov    0x4(%eax),%edx
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800642:	eb 32                	jmp    800676 <vprintfmt+0x2d1>
	else if (lflag)
  800644:	85 d2                	test   %edx,%edx
  800646:	74 18                	je     800660 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	8b 00                	mov    (%eax),%eax
  800653:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800656:	89 c1                	mov    %eax,%ecx
  800658:	c1 f9 1f             	sar    $0x1f,%ecx
  80065b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065e:	eb 16                	jmp    800676 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 c1                	mov    %eax,%ecx
  800670:	c1 f9 1f             	sar    $0x1f,%ecx
  800673:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800676:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800679:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800681:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800685:	79 74                	jns    8006fb <vprintfmt+0x356>
				putch('-', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 2d                	push   $0x2d
  80068d:	ff d6                	call   *%esi
				num = -(long long) num;
  80068f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800692:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800695:	f7 d8                	neg    %eax
  800697:	83 d2 00             	adc    $0x0,%edx
  80069a:	f7 da                	neg    %edx
  80069c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a4:	eb 55                	jmp    8006fb <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 83 fc ff ff       	call   800331 <getuint>
			base = 10;
  8006ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b3:	eb 46                	jmp    8006fb <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 74 fc ff ff       	call   800331 <getuint>
			base = 8;
  8006bd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c2:	eb 37                	jmp    8006fb <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 30                	push   $0x30
  8006ca:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cc:	83 c4 08             	add    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	6a 78                	push   $0x78
  8006d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ec:	eb 0d                	jmp    8006fb <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f1:	e8 3b fc ff ff       	call   800331 <getuint>
			base = 16;
  8006f6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fb:	83 ec 0c             	sub    $0xc,%esp
  8006fe:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800702:	57                   	push   %edi
  800703:	ff 75 e0             	pushl  -0x20(%ebp)
  800706:	51                   	push   %ecx
  800707:	52                   	push   %edx
  800708:	50                   	push   %eax
  800709:	89 da                	mov    %ebx,%edx
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	e8 70 fb ff ff       	call   800282 <printnum>
			break;
  800712:	83 c4 20             	add    $0x20,%esp
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800718:	e9 ae fc ff ff       	jmp    8003cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	53                   	push   %ebx
  800721:	51                   	push   %ecx
  800722:	ff d6                	call   *%esi
			break;
  800724:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072a:	e9 9c fc ff ff       	jmp    8003cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 25                	push   $0x25
  800735:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 03                	jmp    80073f <vprintfmt+0x39a>
  80073c:	83 ef 01             	sub    $0x1,%edi
  80073f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800743:	75 f7                	jne    80073c <vprintfmt+0x397>
  800745:	e9 81 fc ff ff       	jmp    8003cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 18             	sub    $0x18,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 26                	je     800799 <vsnprintf+0x47>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 22                	jle    800799 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	ff 75 14             	pushl  0x14(%ebp)
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	68 6b 03 80 00       	push   $0x80036b
  800786:	e8 1a fc ff ff       	call   8003a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	eb 05                	jmp    80079e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a9:	50                   	push   %eax
  8007aa:	ff 75 10             	pushl  0x10(%ebp)
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	ff 75 08             	pushl  0x8(%ebp)
  8007b3:	e8 9a ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	eb 03                	jmp    8007ca <strlen+0x10>
		n++;
  8007c7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	75 f7                	jne    8007c7 <strlen+0xd>
		n++;
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e0:	eb 03                	jmp    8007e5 <strnlen+0x13>
		n++;
  8007e2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	39 c2                	cmp    %eax,%edx
  8007e7:	74 08                	je     8007f1 <strnlen+0x1f>
  8007e9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ed:	75 f3                	jne    8007e2 <strnlen+0x10>
  8007ef:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fd:	89 c2                	mov    %eax,%edx
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800809:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080c:	84 db                	test   %bl,%bl
  80080e:	75 ef                	jne    8007ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800810:	5b                   	pop    %ebx
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081a:	53                   	push   %ebx
  80081b:	e8 9a ff ff ff       	call   8007ba <strlen>
  800820:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800823:	ff 75 0c             	pushl  0xc(%ebp)
  800826:	01 d8                	add    %ebx,%eax
  800828:	50                   	push   %eax
  800829:	e8 c5 ff ff ff       	call   8007f3 <strcpy>
	return dst;
}
  80082e:	89 d8                	mov    %ebx,%eax
  800830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	56                   	push   %esi
  800839:	53                   	push   %ebx
  80083a:	8b 75 08             	mov    0x8(%ebp),%esi
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800840:	89 f3                	mov    %esi,%ebx
  800842:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	89 f2                	mov    %esi,%edx
  800847:	eb 0f                	jmp    800858 <strncpy+0x23>
		*dst++ = *src;
  800849:	83 c2 01             	add    $0x1,%edx
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800852:	80 39 01             	cmpb   $0x1,(%ecx)
  800855:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	39 da                	cmp    %ebx,%edx
  80085a:	75 ed                	jne    800849 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086d:	8b 55 10             	mov    0x10(%ebp),%edx
  800870:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	85 d2                	test   %edx,%edx
  800874:	74 21                	je     800897 <strlcpy+0x35>
  800876:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087a:	89 f2                	mov    %esi,%edx
  80087c:	eb 09                	jmp    800887 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800887:	39 c2                	cmp    %eax,%edx
  800889:	74 09                	je     800894 <strlcpy+0x32>
  80088b:	0f b6 19             	movzbl (%ecx),%ebx
  80088e:	84 db                	test   %bl,%bl
  800890:	75 ec                	jne    80087e <strlcpy+0x1c>
  800892:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800894:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800897:	29 f0                	sub    %esi,%eax
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strcmp+0x11>
		p++, q++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ae:	0f b6 01             	movzbl (%ecx),%eax
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x1c>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 ef                	je     8008a8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 c3                	mov    %eax,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d2:	eb 06                	jmp    8008da <strncmp+0x17>
		n--, p++, q++;
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008da:	39 d8                	cmp    %ebx,%eax
  8008dc:	74 15                	je     8008f3 <strncmp+0x30>
  8008de:	0f b6 08             	movzbl (%eax),%ecx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	74 04                	je     8008e9 <strncmp+0x26>
  8008e5:	3a 0a                	cmp    (%edx),%cl
  8008e7:	74 eb                	je     8008d4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 00             	movzbl (%eax),%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
  8008f1:	eb 05                	jmp    8008f8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	eb 07                	jmp    80090e <strchr+0x13>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 0f                	je     80091a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f2                	jne    800907 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	eb 03                	jmp    80092b <strfind+0xf>
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 04                	je     800936 <strfind+0x1a>
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f2                	jne    800928 <strfind+0xc>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 36                	je     80097e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 28                	jne    800978 <memset+0x40>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 23                	jne    800978 <memset+0x40>
		c &= 0xFF;
  800955:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800959:	89 d3                	mov    %edx,%ebx
  80095b:	c1 e3 08             	shl    $0x8,%ebx
  80095e:	89 d6                	mov    %edx,%esi
  800960:	c1 e6 18             	shl    $0x18,%esi
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 10             	shl    $0x10,%eax
  800968:	09 f0                	or     %esi,%eax
  80096a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096c:	89 d8                	mov    %ebx,%eax
  80096e:	09 d0                	or     %edx,%eax
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fc                   	cld    
  800974:	f3 ab                	rep stos %eax,%es:(%edi)
  800976:	eb 06                	jmp    80097e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	fc                   	cld    
  80097c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097e:	89 f8                	mov    %edi,%eax
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800993:	39 c6                	cmp    %eax,%esi
  800995:	73 35                	jae    8009cc <memmove+0x47>
  800997:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099a:	39 d0                	cmp    %edx,%eax
  80099c:	73 2e                	jae    8009cc <memmove+0x47>
		s += n;
		d += n;
  80099e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	09 fe                	or     %edi,%esi
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	75 13                	jne    8009c0 <memmove+0x3b>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 09                	jmp    8009c9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c0:	83 ef 01             	sub    $0x1,%edi
  8009c3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c6:	fd                   	std    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c9:	fc                   	cld    
  8009ca:	eb 1d                	jmp    8009e9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	09 c2                	or     %eax,%edx
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	75 0f                	jne    8009e4 <memmove+0x5f>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0a                	jne    8009e4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009da:	c1 e9 02             	shr    $0x2,%ecx
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 05                	jmp    8009e9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 87 ff ff ff       	call   800985 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	89 c6                	mov    %eax,%esi
  800a0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	eb 1a                	jmp    800a2c <memcmp+0x2c>
		if (*s1 != *s2)
  800a12:	0f b6 08             	movzbl (%eax),%ecx
  800a15:	0f b6 1a             	movzbl (%edx),%ebx
  800a18:	38 d9                	cmp    %bl,%cl
  800a1a:	74 0a                	je     800a26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1c:	0f b6 c1             	movzbl %cl,%eax
  800a1f:	0f b6 db             	movzbl %bl,%ebx
  800a22:	29 d8                	sub    %ebx,%eax
  800a24:	eb 0f                	jmp    800a35 <memcmp+0x35>
		s1++, s2++;
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	39 f0                	cmp    %esi,%eax
  800a2e:	75 e2                	jne    800a12 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	53                   	push   %ebx
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a40:	89 c1                	mov    %eax,%ecx
  800a42:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a45:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	eb 0a                	jmp    800a55 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4b:	0f b6 10             	movzbl (%eax),%edx
  800a4e:	39 da                	cmp    %ebx,%edx
  800a50:	74 07                	je     800a59 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	39 c8                	cmp    %ecx,%eax
  800a57:	72 f2                	jb     800a4b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	eb 03                	jmp    800a6d <strtol+0x11>
		s++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	0f b6 01             	movzbl (%ecx),%eax
  800a70:	3c 20                	cmp    $0x20,%al
  800a72:	74 f6                	je     800a6a <strtol+0xe>
  800a74:	3c 09                	cmp    $0x9,%al
  800a76:	74 f2                	je     800a6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a78:	3c 2b                	cmp    $0x2b,%al
  800a7a:	75 0a                	jne    800a86 <strtol+0x2a>
		s++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a84:	eb 11                	jmp    800a97 <strtol+0x3b>
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8b:	3c 2d                	cmp    $0x2d,%al
  800a8d:	75 08                	jne    800a97 <strtol+0x3b>
		s++, neg = 1;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9d:	75 15                	jne    800ab4 <strtol+0x58>
  800a9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa2:	75 10                	jne    800ab4 <strtol+0x58>
  800aa4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa8:	75 7c                	jne    800b26 <strtol+0xca>
		s += 2, base = 16;
  800aaa:	83 c1 02             	add    $0x2,%ecx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb 16                	jmp    800aca <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab4:	85 db                	test   %ebx,%ebx
  800ab6:	75 12                	jne    800aca <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 08                	jne    800aca <strtol+0x6e>
		s++, base = 8;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad2:	0f b6 11             	movzbl (%ecx),%edx
  800ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 09             	cmp    $0x9,%bl
  800add:	77 08                	ja     800ae7 <strtol+0x8b>
			dig = *s - '0';
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 30             	sub    $0x30,%edx
  800ae5:	eb 22                	jmp    800b09 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 57             	sub    $0x57,%edx
  800af7:	eb 10                	jmp    800b09 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 16                	ja     800b19 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b03:	0f be d2             	movsbl %dl,%edx
  800b06:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b09:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0c:	7d 0b                	jge    800b19 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0e:	83 c1 01             	add    $0x1,%ecx
  800b11:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b15:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b17:	eb b9                	jmp    800ad2 <strtol+0x76>

	if (endptr)
  800b19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1d:	74 0d                	je     800b2c <strtol+0xd0>
		*endptr = (char *) s;
  800b1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b22:	89 0e                	mov    %ecx,(%esi)
  800b24:	eb 06                	jmp    800b2c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b26:	85 db                	test   %ebx,%ebx
  800b28:	74 98                	je     800ac2 <strtol+0x66>
  800b2a:	eb 9e                	jmp    800aca <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	f7 da                	neg    %edx
  800b30:	85 ff                	test   %edi,%edi
  800b32:	0f 45 c2             	cmovne %edx,%eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
  800b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	89 c3                	mov    %eax,%ebx
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	89 c6                	mov    %eax,%esi
  800b51:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 01 00 00 00       	mov    $0x1,%eax
  800b68:	89 d1                	mov    %edx,%ecx
  800b6a:	89 d3                	mov    %edx,%ebx
  800b6c:	89 d7                	mov    %edx,%edi
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b85:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	89 cb                	mov    %ecx,%ebx
  800b8f:	89 cf                	mov    %ecx,%edi
  800b91:	89 ce                	mov    %ecx,%esi
  800b93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b95:	85 c0                	test   %eax,%eax
  800b97:	7e 17                	jle    800bb0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	50                   	push   %eax
  800b9d:	6a 03                	push   $0x3
  800b9f:	68 7f 25 80 00       	push   $0x80257f
  800ba4:	6a 23                	push   $0x23
  800ba6:	68 9c 25 80 00       	push   $0x80259c
  800bab:	e8 e5 f5 ff ff       	call   800195 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_yield>:

void
sys_yield(void)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be7:	89 d1                	mov    %edx,%ecx
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	89 d6                	mov    %edx,%esi
  800bef:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	be 00 00 00 00       	mov    $0x0,%esi
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c12:	89 f7                	mov    %esi,%edi
  800c14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 04                	push   $0x4
  800c20:	68 7f 25 80 00       	push   $0x80257f
  800c25:	6a 23                	push   $0x23
  800c27:	68 9c 25 80 00       	push   $0x80259c
  800c2c:	e8 64 f5 ff ff       	call   800195 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c53:	8b 75 18             	mov    0x18(%ebp),%esi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 05                	push   $0x5
  800c62:	68 7f 25 80 00       	push   $0x80257f
  800c67:	6a 23                	push   $0x23
  800c69:	68 9c 25 80 00       	push   $0x80259c
  800c6e:	e8 22 f5 ff ff       	call   800195 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 06                	push   $0x6
  800ca4:	68 7f 25 80 00       	push   $0x80257f
  800ca9:	6a 23                	push   $0x23
  800cab:	68 9c 25 80 00       	push   $0x80259c
  800cb0:	e8 e0 f4 ff ff       	call   800195 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccb:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800cde:	7e 17                	jle    800cf7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 08                	push   $0x8
  800ce6:	68 7f 25 80 00       	push   $0x80257f
  800ceb:	6a 23                	push   $0x23
  800ced:	68 9c 25 80 00       	push   $0x80259c
  800cf2:	e8 9e f4 ff ff       	call   800195 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d0d:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d20:	7e 17                	jle    800d39 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 09                	push   $0x9
  800d28:	68 7f 25 80 00       	push   $0x80257f
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 9c 25 80 00       	push   $0x80259c
  800d34:	e8 5c f4 ff ff       	call   800195 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d62:	7e 17                	jle    800d7b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 0a                	push   $0xa
  800d6a:	68 7f 25 80 00       	push   $0x80257f
  800d6f:	6a 23                	push   $0x23
  800d71:	68 9c 25 80 00       	push   $0x80259c
  800d76:	e8 1a f4 ff ff       	call   800195 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	be 00 00 00 00       	mov    $0x0,%esi
  800d8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 cb                	mov    %ecx,%ebx
  800dbe:	89 cf                	mov    %ecx,%edi
  800dc0:	89 ce                	mov    %ecx,%esi
  800dc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 0d                	push   $0xd
  800dce:	68 7f 25 80 00       	push   $0x80257f
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 9c 25 80 00       	push   $0x80259c
  800dda:	e8 b6 f3 ff ff       	call   800195 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	53                   	push   %ebx
  800deb:	83 ec 04             	sub    $0x4,%esp
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800df3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800df7:	74 11                	je     800e0a <pgfault+0x23>
  800df9:	89 d8                	mov    %ebx,%eax
  800dfb:	c1 e8 0c             	shr    $0xc,%eax
  800dfe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e05:	f6 c4 08             	test   $0x8,%ah
  800e08:	75 14                	jne    800e1e <pgfault+0x37>
		panic("faulting access");
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 aa 25 80 00       	push   $0x8025aa
  800e12:	6a 1d                	push   $0x1d
  800e14:	68 ba 25 80 00       	push   $0x8025ba
  800e19:	e8 77 f3 ff ff       	call   800195 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	6a 07                	push   $0x7
  800e23:	68 00 f0 7f 00       	push   $0x7ff000
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 c7 fd ff ff       	call   800bf6 <sys_page_alloc>
	if (r < 0) {
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	79 12                	jns    800e48 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e36:	50                   	push   %eax
  800e37:	68 c5 25 80 00       	push   $0x8025c5
  800e3c:	6a 2b                	push   $0x2b
  800e3e:	68 ba 25 80 00       	push   $0x8025ba
  800e43:	e8 4d f3 ff ff       	call   800195 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e48:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	68 00 10 00 00       	push   $0x1000
  800e56:	53                   	push   %ebx
  800e57:	68 00 f0 7f 00       	push   $0x7ff000
  800e5c:	e8 8c fb ff ff       	call   8009ed <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e61:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e68:	53                   	push   %ebx
  800e69:	6a 00                	push   $0x0
  800e6b:	68 00 f0 7f 00       	push   $0x7ff000
  800e70:	6a 00                	push   $0x0
  800e72:	e8 c2 fd ff ff       	call   800c39 <sys_page_map>
	if (r < 0) {
  800e77:	83 c4 20             	add    $0x20,%esp
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	79 12                	jns    800e90 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e7e:	50                   	push   %eax
  800e7f:	68 c5 25 80 00       	push   $0x8025c5
  800e84:	6a 32                	push   $0x32
  800e86:	68 ba 25 80 00       	push   $0x8025ba
  800e8b:	e8 05 f3 ff ff       	call   800195 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e90:	83 ec 08             	sub    $0x8,%esp
  800e93:	68 00 f0 7f 00       	push   $0x7ff000
  800e98:	6a 00                	push   $0x0
  800e9a:	e8 dc fd ff ff       	call   800c7b <sys_page_unmap>
	if (r < 0) {
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	79 12                	jns    800eb8 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ea6:	50                   	push   %eax
  800ea7:	68 c5 25 80 00       	push   $0x8025c5
  800eac:	6a 36                	push   $0x36
  800eae:	68 ba 25 80 00       	push   $0x8025ba
  800eb3:	e8 dd f2 ff ff       	call   800195 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800eb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ec6:	68 e7 0d 80 00       	push   $0x800de7
  800ecb:	e8 be 0e 00 00       	call   801d8e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed0:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed5:	cd 30                	int    $0x30
  800ed7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 17                	jns    800ef8 <fork+0x3b>
		panic("fork fault %e");
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	68 de 25 80 00       	push   $0x8025de
  800ee9:	68 83 00 00 00       	push   $0x83
  800eee:	68 ba 25 80 00       	push   $0x8025ba
  800ef3:	e8 9d f2 ff ff       	call   800195 <_panic>
  800ef8:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800efa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800efe:	75 21                	jne    800f21 <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f00:	e8 b3 fc ff ff       	call   800bb8 <sys_getenvid>
  800f05:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f0a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f0d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f12:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	e9 61 01 00 00       	jmp    801082 <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	6a 07                	push   $0x7
  800f26:	68 00 f0 bf ee       	push   $0xeebff000
  800f2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2e:	e8 c3 fc ff ff       	call   800bf6 <sys_page_alloc>
  800f33:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	c1 e8 16             	shr    $0x16,%eax
  800f40:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f47:	a8 01                	test   $0x1,%al
  800f49:	0f 84 fc 00 00 00    	je     80104b <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f4f:	89 d8                	mov    %ebx,%eax
  800f51:	c1 e8 0c             	shr    $0xc,%eax
  800f54:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f5b:	f6 c2 01             	test   $0x1,%dl
  800f5e:	0f 84 e7 00 00 00    	je     80104b <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f64:	89 c6                	mov    %eax,%esi
  800f66:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f69:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f70:	f6 c6 04             	test   $0x4,%dh
  800f73:	74 39                	je     800fae <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f75:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f84:	50                   	push   %eax
  800f85:	56                   	push   %esi
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	e8 aa fc ff ff       	call   800c39 <sys_page_map>
		if (r < 0) {
  800f8f:	83 c4 20             	add    $0x20,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	0f 89 b1 00 00 00    	jns    80104b <fork+0x18e>
		    	panic("sys page map fault %e");
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 ec 25 80 00       	push   $0x8025ec
  800fa2:	6a 53                	push   $0x53
  800fa4:	68 ba 25 80 00       	push   $0x8025ba
  800fa9:	e8 e7 f1 ff ff       	call   800195 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb5:	f6 c2 02             	test   $0x2,%dl
  800fb8:	75 0c                	jne    800fc6 <fork+0x109>
  800fba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc1:	f6 c4 08             	test   $0x8,%ah
  800fc4:	74 5b                	je     801021 <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	68 05 08 00 00       	push   $0x805
  800fce:	56                   	push   %esi
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 61 fc ff ff       	call   800c39 <sys_page_map>
		if (r < 0) {
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	79 14                	jns    800ff3 <fork+0x136>
		    	panic("sys page map fault %e");
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 ec 25 80 00       	push   $0x8025ec
  800fe7:	6a 5a                	push   $0x5a
  800fe9:	68 ba 25 80 00       	push   $0x8025ba
  800fee:	e8 a2 f1 ff ff       	call   800195 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	68 05 08 00 00       	push   $0x805
  800ffb:	56                   	push   %esi
  800ffc:	6a 00                	push   $0x0
  800ffe:	56                   	push   %esi
  800fff:	6a 00                	push   $0x0
  801001:	e8 33 fc ff ff       	call   800c39 <sys_page_map>
		if (r < 0) {
  801006:	83 c4 20             	add    $0x20,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 3e                	jns    80104b <fork+0x18e>
		    	panic("sys page map fault %e");
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	68 ec 25 80 00       	push   $0x8025ec
  801015:	6a 5e                	push   $0x5e
  801017:	68 ba 25 80 00       	push   $0x8025ba
  80101c:	e8 74 f1 ff ff       	call   800195 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	6a 05                	push   $0x5
  801026:	56                   	push   %esi
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	6a 00                	push   $0x0
  80102b:	e8 09 fc ff ff       	call   800c39 <sys_page_map>
		if (r < 0) {
  801030:	83 c4 20             	add    $0x20,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	79 14                	jns    80104b <fork+0x18e>
		    	panic("sys page map fault %e");
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	68 ec 25 80 00       	push   $0x8025ec
  80103f:	6a 63                	push   $0x63
  801041:	68 ba 25 80 00       	push   $0x8025ba
  801046:	e8 4a f1 ff ff       	call   800195 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80104b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801051:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801057:	0f 85 de fe ff ff    	jne    800f3b <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80105d:	a1 08 40 80 00       	mov    0x804008,%eax
  801062:	8b 40 64             	mov    0x64(%eax),%eax
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	50                   	push   %eax
  801069:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80106c:	57                   	push   %edi
  80106d:	e8 cf fc ff ff       	call   800d41 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801072:	83 c4 08             	add    $0x8,%esp
  801075:	6a 02                	push   $0x2
  801077:	57                   	push   %edi
  801078:	e8 40 fc ff ff       	call   800cbd <sys_env_set_status>
	
	return envid;
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801082:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <sfork>:

// Challenge!
int
sfork(void)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801090:	68 02 26 80 00       	push   $0x802602
  801095:	68 a1 00 00 00       	push   $0xa1
  80109a:	68 ba 25 80 00       	push   $0x8025ba
  80109f:	e8 f1 f0 ff ff       	call   800195 <_panic>

008010a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8010af:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d6:	89 c2                	mov    %eax,%edx
  8010d8:	c1 ea 16             	shr    $0x16,%edx
  8010db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e2:	f6 c2 01             	test   $0x1,%dl
  8010e5:	74 11                	je     8010f8 <fd_alloc+0x2d>
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	c1 ea 0c             	shr    $0xc,%edx
  8010ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f3:	f6 c2 01             	test   $0x1,%dl
  8010f6:	75 09                	jne    801101 <fd_alloc+0x36>
			*fd_store = fd;
  8010f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ff:	eb 17                	jmp    801118 <fd_alloc+0x4d>
  801101:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801106:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80110b:	75 c9                	jne    8010d6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80110d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801113:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801120:	83 f8 1f             	cmp    $0x1f,%eax
  801123:	77 36                	ja     80115b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801125:	c1 e0 0c             	shl    $0xc,%eax
  801128:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	c1 ea 16             	shr    $0x16,%edx
  801132:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801139:	f6 c2 01             	test   $0x1,%dl
  80113c:	74 24                	je     801162 <fd_lookup+0x48>
  80113e:	89 c2                	mov    %eax,%edx
  801140:	c1 ea 0c             	shr    $0xc,%edx
  801143:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114a:	f6 c2 01             	test   $0x1,%dl
  80114d:	74 1a                	je     801169 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80114f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801152:	89 02                	mov    %eax,(%edx)
	return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
  801159:	eb 13                	jmp    80116e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80115b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801160:	eb 0c                	jmp    80116e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801167:	eb 05                	jmp    80116e <fd_lookup+0x54>
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 08             	sub    $0x8,%esp
  801176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801179:	ba 98 26 80 00       	mov    $0x802698,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80117e:	eb 13                	jmp    801193 <dev_lookup+0x23>
  801180:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801183:	39 08                	cmp    %ecx,(%eax)
  801185:	75 0c                	jne    801193 <dev_lookup+0x23>
			*dev = devtab[i];
  801187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
  801191:	eb 2e                	jmp    8011c1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801193:	8b 02                	mov    (%edx),%eax
  801195:	85 c0                	test   %eax,%eax
  801197:	75 e7                	jne    801180 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801199:	a1 08 40 80 00       	mov    0x804008,%eax
  80119e:	8b 40 48             	mov    0x48(%eax),%eax
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	51                   	push   %ecx
  8011a5:	50                   	push   %eax
  8011a6:	68 18 26 80 00       	push   $0x802618
  8011ab:	e8 be f0 ff ff       	call   80026e <cprintf>
	*dev = 0;
  8011b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    

008011c3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 10             	sub    $0x10,%esp
  8011cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011db:	c1 e8 0c             	shr    $0xc,%eax
  8011de:	50                   	push   %eax
  8011df:	e8 36 ff ff ff       	call   80111a <fd_lookup>
  8011e4:	83 c4 08             	add    $0x8,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 05                	js     8011f0 <fd_close+0x2d>
	    || fd != fd2)
  8011eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ee:	74 0c                	je     8011fc <fd_close+0x39>
		return (must_exist ? r : 0);
  8011f0:	84 db                	test   %bl,%bl
  8011f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f7:	0f 44 c2             	cmove  %edx,%eax
  8011fa:	eb 41                	jmp    80123d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	ff 36                	pushl  (%esi)
  801205:	e8 66 ff ff ff       	call   801170 <dev_lookup>
  80120a:	89 c3                	mov    %eax,%ebx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 1a                	js     80122d <fd_close+0x6a>
		if (dev->dev_close)
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801219:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80121e:	85 c0                	test   %eax,%eax
  801220:	74 0b                	je     80122d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801222:	83 ec 0c             	sub    $0xc,%esp
  801225:	56                   	push   %esi
  801226:	ff d0                	call   *%eax
  801228:	89 c3                	mov    %eax,%ebx
  80122a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	56                   	push   %esi
  801231:	6a 00                	push   $0x0
  801233:	e8 43 fa ff ff       	call   800c7b <sys_page_unmap>
	return r;
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	89 d8                	mov    %ebx,%eax
}
  80123d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 c4 fe ff ff       	call   80111a <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 10                	js     80126d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	6a 01                	push   $0x1
  801262:	ff 75 f4             	pushl  -0xc(%ebp)
  801265:	e8 59 ff ff ff       	call   8011c3 <fd_close>
  80126a:	83 c4 10             	add    $0x10,%esp
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <close_all>:

void
close_all(void)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801276:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	53                   	push   %ebx
  80127f:	e8 c0 ff ff ff       	call   801244 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801284:	83 c3 01             	add    $0x1,%ebx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	83 fb 20             	cmp    $0x20,%ebx
  80128d:	75 ec                	jne    80127b <close_all+0xc>
		close(i);
}
  80128f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 2c             	sub    $0x2c,%esp
  80129d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a3:	50                   	push   %eax
  8012a4:	ff 75 08             	pushl  0x8(%ebp)
  8012a7:	e8 6e fe ff ff       	call   80111a <fd_lookup>
  8012ac:	83 c4 08             	add    $0x8,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	0f 88 c1 00 00 00    	js     801378 <dup+0xe4>
		return r;
	close(newfdnum);
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	56                   	push   %esi
  8012bb:	e8 84 ff ff ff       	call   801244 <close>

	newfd = INDEX2FD(newfdnum);
  8012c0:	89 f3                	mov    %esi,%ebx
  8012c2:	c1 e3 0c             	shl    $0xc,%ebx
  8012c5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012cb:	83 c4 04             	add    $0x4,%esp
  8012ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012d1:	e8 de fd ff ff       	call   8010b4 <fd2data>
  8012d6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012d8:	89 1c 24             	mov    %ebx,(%esp)
  8012db:	e8 d4 fd ff ff       	call   8010b4 <fd2data>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012e6:	89 f8                	mov    %edi,%eax
  8012e8:	c1 e8 16             	shr    $0x16,%eax
  8012eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f2:	a8 01                	test   $0x1,%al
  8012f4:	74 37                	je     80132d <dup+0x99>
  8012f6:	89 f8                	mov    %edi,%eax
  8012f8:	c1 e8 0c             	shr    $0xc,%eax
  8012fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801302:	f6 c2 01             	test   $0x1,%dl
  801305:	74 26                	je     80132d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801307:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	25 07 0e 00 00       	and    $0xe07,%eax
  801316:	50                   	push   %eax
  801317:	ff 75 d4             	pushl  -0x2c(%ebp)
  80131a:	6a 00                	push   $0x0
  80131c:	57                   	push   %edi
  80131d:	6a 00                	push   $0x0
  80131f:	e8 15 f9 ff ff       	call   800c39 <sys_page_map>
  801324:	89 c7                	mov    %eax,%edi
  801326:	83 c4 20             	add    $0x20,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 2e                	js     80135b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801330:	89 d0                	mov    %edx,%eax
  801332:	c1 e8 0c             	shr    $0xc,%eax
  801335:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	25 07 0e 00 00       	and    $0xe07,%eax
  801344:	50                   	push   %eax
  801345:	53                   	push   %ebx
  801346:	6a 00                	push   $0x0
  801348:	52                   	push   %edx
  801349:	6a 00                	push   $0x0
  80134b:	e8 e9 f8 ff ff       	call   800c39 <sys_page_map>
  801350:	89 c7                	mov    %eax,%edi
  801352:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801355:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801357:	85 ff                	test   %edi,%edi
  801359:	79 1d                	jns    801378 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	53                   	push   %ebx
  80135f:	6a 00                	push   $0x0
  801361:	e8 15 f9 ff ff       	call   800c7b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801366:	83 c4 08             	add    $0x8,%esp
  801369:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136c:	6a 00                	push   $0x0
  80136e:	e8 08 f9 ff ff       	call   800c7b <sys_page_unmap>
	return r;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	89 f8                	mov    %edi,%eax
}
  801378:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 14             	sub    $0x14,%esp
  801387:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	53                   	push   %ebx
  80138f:	e8 86 fd ff ff       	call   80111a <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	89 c2                	mov    %eax,%edx
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 6d                	js     80140a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	ff 30                	pushl  (%eax)
  8013a9:	e8 c2 fd ff ff       	call   801170 <dev_lookup>
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 4c                	js     801401 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b8:	8b 42 08             	mov    0x8(%edx),%eax
  8013bb:	83 e0 03             	and    $0x3,%eax
  8013be:	83 f8 01             	cmp    $0x1,%eax
  8013c1:	75 21                	jne    8013e4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8013c8:	8b 40 48             	mov    0x48(%eax),%eax
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	50                   	push   %eax
  8013d0:	68 5c 26 80 00       	push   $0x80265c
  8013d5:	e8 94 ee ff ff       	call   80026e <cprintf>
		return -E_INVAL;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e2:	eb 26                	jmp    80140a <read+0x8a>
	}
	if (!dev->dev_read)
  8013e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e7:	8b 40 08             	mov    0x8(%eax),%eax
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 17                	je     801405 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	ff 75 10             	pushl  0x10(%ebp)
  8013f4:	ff 75 0c             	pushl  0xc(%ebp)
  8013f7:	52                   	push   %edx
  8013f8:	ff d0                	call   *%eax
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	eb 09                	jmp    80140a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801401:	89 c2                	mov    %eax,%edx
  801403:	eb 05                	jmp    80140a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801405:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80140a:	89 d0                	mov    %edx,%eax
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 0c             	sub    $0xc,%esp
  80141a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801420:	bb 00 00 00 00       	mov    $0x0,%ebx
  801425:	eb 21                	jmp    801448 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	89 f0                	mov    %esi,%eax
  80142c:	29 d8                	sub    %ebx,%eax
  80142e:	50                   	push   %eax
  80142f:	89 d8                	mov    %ebx,%eax
  801431:	03 45 0c             	add    0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	57                   	push   %edi
  801436:	e8 45 ff ff ff       	call   801380 <read>
		if (m < 0)
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 10                	js     801452 <readn+0x41>
			return m;
		if (m == 0)
  801442:	85 c0                	test   %eax,%eax
  801444:	74 0a                	je     801450 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801446:	01 c3                	add    %eax,%ebx
  801448:	39 f3                	cmp    %esi,%ebx
  80144a:	72 db                	jb     801427 <readn+0x16>
  80144c:	89 d8                	mov    %ebx,%eax
  80144e:	eb 02                	jmp    801452 <readn+0x41>
  801450:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801452:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 14             	sub    $0x14,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	53                   	push   %ebx
  801469:	e8 ac fc ff ff       	call   80111a <fd_lookup>
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	89 c2                	mov    %eax,%edx
  801473:	85 c0                	test   %eax,%eax
  801475:	78 68                	js     8014df <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801481:	ff 30                	pushl  (%eax)
  801483:	e8 e8 fc ff ff       	call   801170 <dev_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 47                	js     8014d6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801496:	75 21                	jne    8014b9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801498:	a1 08 40 80 00       	mov    0x804008,%eax
  80149d:	8b 40 48             	mov    0x48(%eax),%eax
  8014a0:	83 ec 04             	sub    $0x4,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	50                   	push   %eax
  8014a5:	68 78 26 80 00       	push   $0x802678
  8014aa:	e8 bf ed ff ff       	call   80026e <cprintf>
		return -E_INVAL;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b7:	eb 26                	jmp    8014df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bf:	85 d2                	test   %edx,%edx
  8014c1:	74 17                	je     8014da <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	ff 75 10             	pushl  0x10(%ebp)
  8014c9:	ff 75 0c             	pushl  0xc(%ebp)
  8014cc:	50                   	push   %eax
  8014cd:	ff d2                	call   *%edx
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	eb 09                	jmp    8014df <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	eb 05                	jmp    8014df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014df:	89 d0                	mov    %edx,%eax
  8014e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	ff 75 08             	pushl  0x8(%ebp)
  8014f3:	e8 22 fc ff ff       	call   80111a <fd_lookup>
  8014f8:	83 c4 08             	add    $0x8,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 0e                	js     80150d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801502:	8b 55 0c             	mov    0xc(%ebp),%edx
  801505:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801508:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 14             	sub    $0x14,%esp
  801516:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801519:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	53                   	push   %ebx
  80151e:	e8 f7 fb ff ff       	call   80111a <fd_lookup>
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	89 c2                	mov    %eax,%edx
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 65                	js     801591 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	ff 30                	pushl  (%eax)
  801538:	e8 33 fc ff ff       	call   801170 <dev_lookup>
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 44                	js     801588 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801547:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154b:	75 21                	jne    80156e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801552:	8b 40 48             	mov    0x48(%eax),%eax
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	53                   	push   %ebx
  801559:	50                   	push   %eax
  80155a:	68 38 26 80 00       	push   $0x802638
  80155f:	e8 0a ed ff ff       	call   80026e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156c:	eb 23                	jmp    801591 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80156e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801571:	8b 52 18             	mov    0x18(%edx),%edx
  801574:	85 d2                	test   %edx,%edx
  801576:	74 14                	je     80158c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	ff 75 0c             	pushl  0xc(%ebp)
  80157e:	50                   	push   %eax
  80157f:	ff d2                	call   *%edx
  801581:	89 c2                	mov    %eax,%edx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	eb 09                	jmp    801591 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801588:	89 c2                	mov    %eax,%edx
  80158a:	eb 05                	jmp    801591 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80158c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801591:	89 d0                	mov    %edx,%eax
  801593:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 14             	sub    $0x14,%esp
  80159f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	ff 75 08             	pushl  0x8(%ebp)
  8015a9:	e8 6c fb ff ff       	call   80111a <fd_lookup>
  8015ae:	83 c4 08             	add    $0x8,%esp
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 58                	js     80160f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	ff 30                	pushl  (%eax)
  8015c3:	e8 a8 fb ff ff       	call   801170 <dev_lookup>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 37                	js     801606 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d6:	74 32                	je     80160a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e2:	00 00 00 
	stat->st_isdir = 0;
  8015e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ec:	00 00 00 
	stat->st_dev = dev;
  8015ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	53                   	push   %ebx
  8015f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015fc:	ff 50 14             	call   *0x14(%eax)
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb 09                	jmp    80160f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801606:	89 c2                	mov    %eax,%edx
  801608:	eb 05                	jmp    80160f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80160a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80160f:	89 d0                	mov    %edx,%eax
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	6a 00                	push   $0x0
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 e3 01 00 00       	call   80180b <open>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 1b                	js     80164c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	ff 75 0c             	pushl  0xc(%ebp)
  801637:	50                   	push   %eax
  801638:	e8 5b ff ff ff       	call   801598 <fstat>
  80163d:	89 c6                	mov    %eax,%esi
	close(fd);
  80163f:	89 1c 24             	mov    %ebx,(%esp)
  801642:	e8 fd fb ff ff       	call   801244 <close>
	return r;
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	89 f0                	mov    %esi,%eax
}
  80164c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	89 c6                	mov    %eax,%esi
  80165a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80165c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801663:	75 12                	jne    801677 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	6a 01                	push   $0x1
  80166a:	e8 82 08 00 00       	call   801ef1 <ipc_find_env>
  80166f:	a3 00 40 80 00       	mov    %eax,0x804000
  801674:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801677:	6a 07                	push   $0x7
  801679:	68 00 50 80 00       	push   $0x805000
  80167e:	56                   	push   %esi
  80167f:	ff 35 00 40 80 00    	pushl  0x804000
  801685:	e8 05 08 00 00       	call   801e8f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80168a:	83 c4 0c             	add    $0xc,%esp
  80168d:	6a 00                	push   $0x0
  80168f:	53                   	push   %ebx
  801690:	6a 00                	push   $0x0
  801692:	e8 86 07 00 00       	call   801e1d <ipc_recv>
}
  801697:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c1:	e8 8d ff ff ff       	call   801653 <fsipc>
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e3:	e8 6b ff ff ff       	call   801653 <fsipc>
}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 05 00 00 00       	mov    $0x5,%eax
  801709:	e8 45 ff ff ff       	call   801653 <fsipc>
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 2c                	js     80173e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	68 00 50 80 00       	push   $0x805000
  80171a:	53                   	push   %ebx
  80171b:	e8 d3 f0 ff ff       	call   8007f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801720:	a1 80 50 80 00       	mov    0x805080,%eax
  801725:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80172b:	a1 84 50 80 00       	mov    0x805084,%eax
  801730:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80174c:	8b 55 08             	mov    0x8(%ebp),%edx
  80174f:	8b 52 0c             	mov    0xc(%edx),%edx
  801752:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801758:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80175d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801762:	0f 47 c2             	cmova  %edx,%eax
  801765:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80176a:	50                   	push   %eax
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	68 08 50 80 00       	push   $0x805008
  801773:	e8 0d f2 ff ff       	call   800985 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
  80177d:	b8 04 00 00 00       	mov    $0x4,%eax
  801782:	e8 cc fe ff ff       	call   801653 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801787:	c9                   	leave  
  801788:	c3                   	ret    

00801789 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 40 0c             	mov    0xc(%eax),%eax
  801797:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ac:	e8 a2 fe ff ff       	call   801653 <fsipc>
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 4b                	js     801802 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b7:	39 c6                	cmp    %eax,%esi
  8017b9:	73 16                	jae    8017d1 <devfile_read+0x48>
  8017bb:	68 a8 26 80 00       	push   $0x8026a8
  8017c0:	68 af 26 80 00       	push   $0x8026af
  8017c5:	6a 7c                	push   $0x7c
  8017c7:	68 c4 26 80 00       	push   $0x8026c4
  8017cc:	e8 c4 e9 ff ff       	call   800195 <_panic>
	assert(r <= PGSIZE);
  8017d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d6:	7e 16                	jle    8017ee <devfile_read+0x65>
  8017d8:	68 cf 26 80 00       	push   $0x8026cf
  8017dd:	68 af 26 80 00       	push   $0x8026af
  8017e2:	6a 7d                	push   $0x7d
  8017e4:	68 c4 26 80 00       	push   $0x8026c4
  8017e9:	e8 a7 e9 ff ff       	call   800195 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	50                   	push   %eax
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	ff 75 0c             	pushl  0xc(%ebp)
  8017fa:	e8 86 f1 ff ff       	call   800985 <memmove>
	return r;
  8017ff:	83 c4 10             	add    $0x10,%esp
}
  801802:	89 d8                	mov    %ebx,%eax
  801804:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	53                   	push   %ebx
  80180f:	83 ec 20             	sub    $0x20,%esp
  801812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801815:	53                   	push   %ebx
  801816:	e8 9f ef ff ff       	call   8007ba <strlen>
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801823:	7f 67                	jg     80188c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	e8 9a f8 ff ff       	call   8010cb <fd_alloc>
  801831:	83 c4 10             	add    $0x10,%esp
		return r;
  801834:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801836:	85 c0                	test   %eax,%eax
  801838:	78 57                	js     801891 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	53                   	push   %ebx
  80183e:	68 00 50 80 00       	push   $0x805000
  801843:	e8 ab ef ff ff       	call   8007f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801853:	b8 01 00 00 00       	mov    $0x1,%eax
  801858:	e8 f6 fd ff ff       	call   801653 <fsipc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	79 14                	jns    80187a <open+0x6f>
		fd_close(fd, 0);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	6a 00                	push   $0x0
  80186b:	ff 75 f4             	pushl  -0xc(%ebp)
  80186e:	e8 50 f9 ff ff       	call   8011c3 <fd_close>
		return r;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	89 da                	mov    %ebx,%edx
  801878:	eb 17                	jmp    801891 <open+0x86>
	}

	return fd2num(fd);
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	ff 75 f4             	pushl  -0xc(%ebp)
  801880:	e8 1f f8 ff ff       	call   8010a4 <fd2num>
  801885:	89 c2                	mov    %eax,%edx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb 05                	jmp    801891 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801891:	89 d0                	mov    %edx,%eax
  801893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a8:	e8 a6 fd ff ff       	call   801653 <fsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	56                   	push   %esi
  8018b3:	53                   	push   %ebx
  8018b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	ff 75 08             	pushl  0x8(%ebp)
  8018bd:	e8 f2 f7 ff ff       	call   8010b4 <fd2data>
  8018c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	68 db 26 80 00       	push   $0x8026db
  8018cc:	53                   	push   %ebx
  8018cd:	e8 21 ef ff ff       	call   8007f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d2:	8b 46 04             	mov    0x4(%esi),%eax
  8018d5:	2b 06                	sub    (%esi),%eax
  8018d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e4:	00 00 00 
	stat->st_dev = &devpipe;
  8018e7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ee:	30 80 00 
	return 0;
}
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5e                   	pop    %esi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	53                   	push   %ebx
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801907:	53                   	push   %ebx
  801908:	6a 00                	push   $0x0
  80190a:	e8 6c f3 ff ff       	call   800c7b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190f:	89 1c 24             	mov    %ebx,(%esp)
  801912:	e8 9d f7 ff ff       	call   8010b4 <fd2data>
  801917:	83 c4 08             	add    $0x8,%esp
  80191a:	50                   	push   %eax
  80191b:	6a 00                	push   $0x0
  80191d:	e8 59 f3 ff ff       	call   800c7b <sys_page_unmap>
}
  801922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	57                   	push   %edi
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	83 ec 1c             	sub    $0x1c,%esp
  801930:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801933:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801935:	a1 08 40 80 00       	mov    0x804008,%eax
  80193a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80193d:	83 ec 0c             	sub    $0xc,%esp
  801940:	ff 75 e0             	pushl  -0x20(%ebp)
  801943:	e8 e2 05 00 00       	call   801f2a <pageref>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	89 3c 24             	mov    %edi,(%esp)
  80194d:	e8 d8 05 00 00       	call   801f2a <pageref>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	39 c3                	cmp    %eax,%ebx
  801957:	0f 94 c1             	sete   %cl
  80195a:	0f b6 c9             	movzbl %cl,%ecx
  80195d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801960:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801966:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801969:	39 ce                	cmp    %ecx,%esi
  80196b:	74 1b                	je     801988 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80196d:	39 c3                	cmp    %eax,%ebx
  80196f:	75 c4                	jne    801935 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801971:	8b 42 58             	mov    0x58(%edx),%eax
  801974:	ff 75 e4             	pushl  -0x1c(%ebp)
  801977:	50                   	push   %eax
  801978:	56                   	push   %esi
  801979:	68 e2 26 80 00       	push   $0x8026e2
  80197e:	e8 eb e8 ff ff       	call   80026e <cprintf>
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	eb ad                	jmp    801935 <_pipeisclosed+0xe>
	}
}
  801988:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80198b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198e:	5b                   	pop    %ebx
  80198f:	5e                   	pop    %esi
  801990:	5f                   	pop    %edi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	57                   	push   %edi
  801997:	56                   	push   %esi
  801998:	53                   	push   %ebx
  801999:	83 ec 28             	sub    $0x28,%esp
  80199c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80199f:	56                   	push   %esi
  8019a0:	e8 0f f7 ff ff       	call   8010b4 <fd2data>
  8019a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8019af:	eb 4b                	jmp    8019fc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b1:	89 da                	mov    %ebx,%edx
  8019b3:	89 f0                	mov    %esi,%eax
  8019b5:	e8 6d ff ff ff       	call   801927 <_pipeisclosed>
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	75 48                	jne    801a06 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019be:	e8 14 f2 ff ff       	call   800bd7 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c6:	8b 0b                	mov    (%ebx),%ecx
  8019c8:	8d 51 20             	lea    0x20(%ecx),%edx
  8019cb:	39 d0                	cmp    %edx,%eax
  8019cd:	73 e2                	jae    8019b1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019d6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019d9:	89 c2                	mov    %eax,%edx
  8019db:	c1 fa 1f             	sar    $0x1f,%edx
  8019de:	89 d1                	mov    %edx,%ecx
  8019e0:	c1 e9 1b             	shr    $0x1b,%ecx
  8019e3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019e6:	83 e2 1f             	and    $0x1f,%edx
  8019e9:	29 ca                	sub    %ecx,%edx
  8019eb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019f3:	83 c0 01             	add    $0x1,%eax
  8019f6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f9:	83 c7 01             	add    $0x1,%edi
  8019fc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ff:	75 c2                	jne    8019c3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a01:	8b 45 10             	mov    0x10(%ebp),%eax
  801a04:	eb 05                	jmp    801a0b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a06:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	57                   	push   %edi
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	83 ec 18             	sub    $0x18,%esp
  801a1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a1f:	57                   	push   %edi
  801a20:	e8 8f f6 ff ff       	call   8010b4 <fd2data>
  801a25:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a2f:	eb 3d                	jmp    801a6e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a31:	85 db                	test   %ebx,%ebx
  801a33:	74 04                	je     801a39 <devpipe_read+0x26>
				return i;
  801a35:	89 d8                	mov    %ebx,%eax
  801a37:	eb 44                	jmp    801a7d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a39:	89 f2                	mov    %esi,%edx
  801a3b:	89 f8                	mov    %edi,%eax
  801a3d:	e8 e5 fe ff ff       	call   801927 <_pipeisclosed>
  801a42:	85 c0                	test   %eax,%eax
  801a44:	75 32                	jne    801a78 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a46:	e8 8c f1 ff ff       	call   800bd7 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a4b:	8b 06                	mov    (%esi),%eax
  801a4d:	3b 46 04             	cmp    0x4(%esi),%eax
  801a50:	74 df                	je     801a31 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a52:	99                   	cltd   
  801a53:	c1 ea 1b             	shr    $0x1b,%edx
  801a56:	01 d0                	add    %edx,%eax
  801a58:	83 e0 1f             	and    $0x1f,%eax
  801a5b:	29 d0                	sub    %edx,%eax
  801a5d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a65:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a68:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6b:	83 c3 01             	add    $0x1,%ebx
  801a6e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a71:	75 d8                	jne    801a4b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a73:	8b 45 10             	mov    0x10(%ebp),%eax
  801a76:	eb 05                	jmp    801a7d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	e8 35 f6 ff ff       	call   8010cb <fd_alloc>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	89 c2                	mov    %eax,%edx
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	0f 88 2c 01 00 00    	js     801bcf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	68 07 04 00 00       	push   $0x407
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 41 f1 ff ff       	call   800bf6 <sys_page_alloc>
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	89 c2                	mov    %eax,%edx
  801aba:	85 c0                	test   %eax,%eax
  801abc:	0f 88 0d 01 00 00    	js     801bcf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac8:	50                   	push   %eax
  801ac9:	e8 fd f5 ff ff       	call   8010cb <fd_alloc>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	0f 88 e2 00 00 00    	js     801bbd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	68 07 04 00 00       	push   $0x407
  801ae3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 09 f1 ff ff       	call   800bf6 <sys_page_alloc>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	0f 88 c3 00 00 00    	js     801bbd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 75 f4             	pushl  -0xc(%ebp)
  801b00:	e8 af f5 ff ff       	call   8010b4 <fd2data>
  801b05:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b07:	83 c4 0c             	add    $0xc,%esp
  801b0a:	68 07 04 00 00       	push   $0x407
  801b0f:	50                   	push   %eax
  801b10:	6a 00                	push   $0x0
  801b12:	e8 df f0 ff ff       	call   800bf6 <sys_page_alloc>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	0f 88 89 00 00 00    	js     801bad <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff 75 f0             	pushl  -0x10(%ebp)
  801b2a:	e8 85 f5 ff ff       	call   8010b4 <fd2data>
  801b2f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b36:	50                   	push   %eax
  801b37:	6a 00                	push   $0x0
  801b39:	56                   	push   %esi
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 f8 f0 ff ff       	call   800c39 <sys_page_map>
  801b41:	89 c3                	mov    %eax,%ebx
  801b43:	83 c4 20             	add    $0x20,%esp
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 55                	js     801b9f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b53:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b58:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b68:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7a:	e8 25 f5 ff ff       	call   8010a4 <fd2num>
  801b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b82:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b84:	83 c4 04             	add    $0x4,%esp
  801b87:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8a:	e8 15 f5 ff ff       	call   8010a4 <fd2num>
  801b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b92:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9d:	eb 30                	jmp    801bcf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	56                   	push   %esi
  801ba3:	6a 00                	push   $0x0
  801ba5:	e8 d1 f0 ff ff       	call   800c7b <sys_page_unmap>
  801baa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bad:	83 ec 08             	sub    $0x8,%esp
  801bb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 c1 f0 ff ff       	call   800c7b <sys_page_unmap>
  801bba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 b1 f0 ff ff       	call   800c7b <sys_page_unmap>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be1:	50                   	push   %eax
  801be2:	ff 75 08             	pushl  0x8(%ebp)
  801be5:	e8 30 f5 ff ff       	call   80111a <fd_lookup>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 18                	js     801c09 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf7:	e8 b8 f4 ff ff       	call   8010b4 <fd2data>
	return _pipeisclosed(fd, p);
  801bfc:	89 c2                	mov    %eax,%edx
  801bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c01:	e8 21 fd ff ff       	call   801927 <_pipeisclosed>
  801c06:	83 c4 10             	add    $0x10,%esp
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c1b:	68 fa 26 80 00       	push   $0x8026fa
  801c20:	ff 75 0c             	pushl  0xc(%ebp)
  801c23:	e8 cb eb ff ff       	call   8007f3 <strcpy>
	return 0;
}
  801c28:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	57                   	push   %edi
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c3b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c40:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c46:	eb 2d                	jmp    801c75 <devcons_write+0x46>
		m = n - tot;
  801c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c4b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c4d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c50:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c55:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	53                   	push   %ebx
  801c5c:	03 45 0c             	add    0xc(%ebp),%eax
  801c5f:	50                   	push   %eax
  801c60:	57                   	push   %edi
  801c61:	e8 1f ed ff ff       	call   800985 <memmove>
		sys_cputs(buf, m);
  801c66:	83 c4 08             	add    $0x8,%esp
  801c69:	53                   	push   %ebx
  801c6a:	57                   	push   %edi
  801c6b:	e8 ca ee ff ff       	call   800b3a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c70:	01 de                	add    %ebx,%esi
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	89 f0                	mov    %esi,%eax
  801c77:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c7a:	72 cc                	jb     801c48 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    

00801c84 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c93:	74 2a                	je     801cbf <devcons_read+0x3b>
  801c95:	eb 05                	jmp    801c9c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c97:	e8 3b ef ff ff       	call   800bd7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c9c:	e8 b7 ee ff ff       	call   800b58 <sys_cgetc>
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	74 f2                	je     801c97 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	78 16                	js     801cbf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ca9:	83 f8 04             	cmp    $0x4,%eax
  801cac:	74 0c                	je     801cba <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb1:	88 02                	mov    %al,(%edx)
	return 1;
  801cb3:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb8:	eb 05                	jmp    801cbf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cca:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ccd:	6a 01                	push   $0x1
  801ccf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd2:	50                   	push   %eax
  801cd3:	e8 62 ee ff ff       	call   800b3a <sys_cputs>
}
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    

00801cdd <getchar>:

int
getchar(void)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ce3:	6a 01                	push   $0x1
  801ce5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce8:	50                   	push   %eax
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 90 f6 ff ff       	call   801380 <read>
	if (r < 0)
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 0f                	js     801d06 <getchar+0x29>
		return r;
	if (r < 1)
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	7e 06                	jle    801d01 <getchar+0x24>
		return -E_EOF;
	return c;
  801cfb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cff:	eb 05                	jmp    801d06 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d01:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	ff 75 08             	pushl  0x8(%ebp)
  801d15:	e8 00 f4 ff ff       	call   80111a <fd_lookup>
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 11                	js     801d32 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d24:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2a:	39 10                	cmp    %edx,(%eax)
  801d2c:	0f 94 c0             	sete   %al
  801d2f:	0f b6 c0             	movzbl %al,%eax
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <opencons>:

int
opencons(void)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3d:	50                   	push   %eax
  801d3e:	e8 88 f3 ff ff       	call   8010cb <fd_alloc>
  801d43:	83 c4 10             	add    $0x10,%esp
		return r;
  801d46:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 3e                	js     801d8a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d4c:	83 ec 04             	sub    $0x4,%esp
  801d4f:	68 07 04 00 00       	push   $0x407
  801d54:	ff 75 f4             	pushl  -0xc(%ebp)
  801d57:	6a 00                	push   $0x0
  801d59:	e8 98 ee ff ff       	call   800bf6 <sys_page_alloc>
  801d5e:	83 c4 10             	add    $0x10,%esp
		return r;
  801d61:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 23                	js     801d8a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d75:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	50                   	push   %eax
  801d80:	e8 1f f3 ff ff       	call   8010a4 <fd2num>
  801d85:	89 c2                	mov    %eax,%edx
  801d87:	83 c4 10             	add    $0x10,%esp
}
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d94:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d9b:	75 2a                	jne    801dc7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d9d:	83 ec 04             	sub    $0x4,%esp
  801da0:	6a 07                	push   $0x7
  801da2:	68 00 f0 bf ee       	push   $0xeebff000
  801da7:	6a 00                	push   $0x0
  801da9:	e8 48 ee ff ff       	call   800bf6 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	85 c0                	test   %eax,%eax
  801db3:	79 12                	jns    801dc7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801db5:	50                   	push   %eax
  801db6:	68 06 27 80 00       	push   $0x802706
  801dbb:	6a 23                	push   $0x23
  801dbd:	68 0a 27 80 00       	push   $0x80270a
  801dc2:	e8 ce e3 ff ff       	call   800195 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dca:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dcf:	83 ec 08             	sub    $0x8,%esp
  801dd2:	68 f9 1d 80 00       	push   $0x801df9
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 63 ef ff ff       	call   800d41 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	79 12                	jns    801df7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801de5:	50                   	push   %eax
  801de6:	68 06 27 80 00       	push   $0x802706
  801deb:	6a 2c                	push   $0x2c
  801ded:	68 0a 27 80 00       	push   $0x80270a
  801df2:	e8 9e e3 ff ff       	call   800195 <_panic>
	}
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801df9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dfa:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e01:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e04:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e08:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e0d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e11:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e13:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e16:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e17:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e1a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e1b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e1c:	c3                   	ret    

00801e1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	56                   	push   %esi
  801e21:	53                   	push   %ebx
  801e22:	8b 75 08             	mov    0x8(%ebp),%esi
  801e25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	75 12                	jne    801e41 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e2f:	83 ec 0c             	sub    $0xc,%esp
  801e32:	68 00 00 c0 ee       	push   $0xeec00000
  801e37:	e8 6a ef ff ff       	call   800da6 <sys_ipc_recv>
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	eb 0c                	jmp    801e4d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	50                   	push   %eax
  801e45:	e8 5c ef ff ff       	call   800da6 <sys_ipc_recv>
  801e4a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e4d:	85 f6                	test   %esi,%esi
  801e4f:	0f 95 c1             	setne  %cl
  801e52:	85 db                	test   %ebx,%ebx
  801e54:	0f 95 c2             	setne  %dl
  801e57:	84 d1                	test   %dl,%cl
  801e59:	74 09                	je     801e64 <ipc_recv+0x47>
  801e5b:	89 c2                	mov    %eax,%edx
  801e5d:	c1 ea 1f             	shr    $0x1f,%edx
  801e60:	84 d2                	test   %dl,%dl
  801e62:	75 24                	jne    801e88 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e64:	85 f6                	test   %esi,%esi
  801e66:	74 0a                	je     801e72 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801e68:	a1 08 40 80 00       	mov    0x804008,%eax
  801e6d:	8b 40 74             	mov    0x74(%eax),%eax
  801e70:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e72:	85 db                	test   %ebx,%ebx
  801e74:	74 0a                	je     801e80 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801e76:	a1 08 40 80 00       	mov    0x804008,%eax
  801e7b:	8b 40 78             	mov    0x78(%eax),%eax
  801e7e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e80:	a1 08 40 80 00       	mov    0x804008,%eax
  801e85:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8b:	5b                   	pop    %ebx
  801e8c:	5e                   	pop    %esi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	57                   	push   %edi
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	83 ec 0c             	sub    $0xc,%esp
  801e98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ea1:	85 db                	test   %ebx,%ebx
  801ea3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ea8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eab:	ff 75 14             	pushl  0x14(%ebp)
  801eae:	53                   	push   %ebx
  801eaf:	56                   	push   %esi
  801eb0:	57                   	push   %edi
  801eb1:	e8 cd ee ff ff       	call   800d83 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eb6:	89 c2                	mov    %eax,%edx
  801eb8:	c1 ea 1f             	shr    $0x1f,%edx
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	84 d2                	test   %dl,%dl
  801ec0:	74 17                	je     801ed9 <ipc_send+0x4a>
  801ec2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec5:	74 12                	je     801ed9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ec7:	50                   	push   %eax
  801ec8:	68 18 27 80 00       	push   $0x802718
  801ecd:	6a 47                	push   $0x47
  801ecf:	68 26 27 80 00       	push   $0x802726
  801ed4:	e8 bc e2 ff ff       	call   800195 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ed9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801edc:	75 07                	jne    801ee5 <ipc_send+0x56>
			sys_yield();
  801ede:	e8 f4 ec ff ff       	call   800bd7 <sys_yield>
  801ee3:	eb c6                	jmp    801eab <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	75 c2                	jne    801eab <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ee9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eec:	5b                   	pop    %ebx
  801eed:	5e                   	pop    %esi
  801eee:	5f                   	pop    %edi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801efc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801eff:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f05:	8b 52 50             	mov    0x50(%edx),%edx
  801f08:	39 ca                	cmp    %ecx,%edx
  801f0a:	75 0d                	jne    801f19 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f0c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f0f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f14:	8b 40 48             	mov    0x48(%eax),%eax
  801f17:	eb 0f                	jmp    801f28 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f19:	83 c0 01             	add    $0x1,%eax
  801f1c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f21:	75 d9                	jne    801efc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f30:	89 d0                	mov    %edx,%eax
  801f32:	c1 e8 16             	shr    $0x16,%eax
  801f35:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f41:	f6 c1 01             	test   $0x1,%cl
  801f44:	74 1d                	je     801f63 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f46:	c1 ea 0c             	shr    $0xc,%edx
  801f49:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f50:	f6 c2 01             	test   $0x1,%dl
  801f53:	74 0e                	je     801f63 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f55:	c1 ea 0c             	shr    $0xc,%edx
  801f58:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f5f:	ef 
  801f60:	0f b7 c0             	movzwl %ax,%eax
}
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    
  801f65:	66 90                	xchg   %ax,%ax
  801f67:	66 90                	xchg   %ax,%ax
  801f69:	66 90                	xchg   %ax,%ax
  801f6b:	66 90                	xchg   %ax,%ax
  801f6d:	66 90                	xchg   %ax,%ax
  801f6f:	90                   	nop

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
